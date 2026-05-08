# End-to-end driver for a dockerized LFS 12.4 (SysV) build.
#
# Flow
# ----
#   docker-build / docker-run   build the Ubuntu host image and start it
#   mkimg                       partition, format, mount /mnt/lfs inside it
#   prep-host                   create the `lfs` user, set up env/dirs
#   dl-sources                  wget all tarballs + patches
#   upload-pkgs                 copy pkg/prep + pkg/build into /mnt/lfs/sources
#   prep-pkgs                   (lfs user) ch 5 + ch 6 - cross toolchain +
#                               cross-compiled temp tools
#   build-pkgs                  (root) chroot in; ch 7 + 8 + 9 + 10
#
# `make all` chains all of the above.

SHELL          := /bin/bash
IMAGE          := linuxfromscratch
CONTAINER_PORT := 2222
SSH_OPTS := -p $(CONTAINER_PORT) -o StrictHostKeyChecking=no
SSH_ROOT := ssh $(SSH_OPTS) root@localhost
SSH_LFS  := ssh $(SSH_OPTS) lfs@localhost
# One tool for host->container copies: rsync over ssh.  Works for single
# files or whole trees; -a preserves perms/times; --delete (only where
# used below) keeps the destination in sync with the source.
RSYNC    := rsync -a -e 'ssh $(SSH_OPTS)'

.PHONY: all docker-build docker-run docker-kill clean undo-known-hosts \
        mkimg prep-host dl-sources upload-pkgs \
        prep-pkgs build-pkgs ssh ssh-lfs lint \
        status reset-stamps logs trim \
        sources-partition pkgsrc-bootstrap pkgsrc-baseline

all: docker-kill clean docker-build docker-run mkimg prep-host \
     dl-sources upload-pkgs prep-pkgs build-pkgs

# ----------------------------------------------------------------- container
docker-build:
	docker build . -t $(IMAGE)

docker-run:
	docker run -p $(CONTAINER_PORT):22 -d --privileged $(IMAGE)
	@for i in $$(seq 1 30); do \
	   $(SSH_ROOT) true 2>/dev/null && exit 0; sleep 1; \
	 done; echo "sshd unreachable" >&2; exit 1

docker-kill:
	./kill_container.sh

undo-known-hosts:
	ssh-keygen -R '[localhost]:$(CONTAINER_PORT)' || true

clean:
	rm -f lfs.img
	docker rmi -f $(IMAGE) || true

# ----------------------------------------------------------------- build steps
mkimg:
	$(RSYNC) script/mkext4.sh root@localhost:/root/
	$(SSH_ROOT) 'bash /root/mkext4.sh'

prep-host:
	$(RSYNC) script/stage0.sh root@localhost:/root/
	$(SSH_ROOT) 'bash /root/stage0.sh'

dl-sources:
	$(RSYNC) packages.txt md5sums root@localhost:/mnt/lfs/sources/
	$(SSH_ROOT) 'cd /mnt/lfs/sources && wget --continue --timeout=30 --tries=3 --input-file=packages.txt && md5sum -c md5sums'

# --delete on the pkg trees so renames / removals propagate; the sibling
# .done/ and .log/ dirs under /mnt/lfs/sources/ are unaffected because
# we sync into prep/ and build/ subdirs, not the parent.
upload-pkgs:
	$(RSYNC) --delete pkg/prep/  root@localhost:/mnt/lfs/sources/prep/
	$(RSYNC) --delete pkg/build/ root@localhost:/mnt/lfs/sources/build/
	$(RSYNC) script/stage1.sh root@localhost:/mnt/lfs/sources/prep/stage1.sh
	$(SSH_ROOT) 'chown -R lfs:lfs /mnt/lfs/sources && chmod +x /mnt/lfs/sources/prep/*.sh /mnt/lfs/sources/build/*.sh'

# FORCE=pkg1,pkg2  re-run those packages even if stamped.
# FORCE=all        wipe all stamps (full rebuild).
# RUN_TESTS=1      run `make check` / `make test` (advisory; failures warn).
FORCE     ?=
RUN_TESTS ?= 0
prep-pkgs:
	$(SSH_LFS) 'FORCE=$(FORCE) RUN_TESTS=$(RUN_TESTS) bash /mnt/lfs/sources/prep/stage1.sh'

build-pkgs:
	$(SSH_ROOT) 'FORCE=$(FORCE) RUN_TESTS=$(RUN_TESTS) bash /mnt/lfs/sources/build/run-build.sh'

# Inspect / manage resume state.
status:
	@$(SSH_ROOT) 'for phase in prep build; do \
	   d=/mnt/lfs/sources/.done/$$phase; \
	   echo "== $$phase =="; \
	   [ -d $$d ] && ls $$d | sort || echo "(nothing built)"; \
	 done'

reset-stamps:
	$(SSH_ROOT) 'rm -rf /mnt/lfs/sources/.done'

logs:
	@$(SSH_ROOT) 'ls -lrt /mnt/lfs/sources/.log/prep /mnt/lfs/sources/.log/build 2>/dev/null || true'

# fstrim the loop-mounted ext4 so the host can reclaim blocks freed by
# `rm -rf <pkg>-<ver>` after each package build.  Useful between phases
# on space-constrained hosts.
trim:
	$(SSH_ROOT) 'fstrim -v /mnt/lfs'

# ----------------------------------------------------------------- utilities
ssh:
	$(SSH_ROOT)
ssh-lfs:
	$(SSH_LFS)

lint:
	shellcheck -S warning script/*.sh pkg/*/*.sh pkgsrc/*.sh run.sh kill_container.sh
	@command -v hadolint >/dev/null 2>&1 && hadolint Dockerfile \
	  || docker run --rm -i hadolint/hadolint < Dockerfile
	bash -n $$(find script pkg pkgsrc -name '*.sh')
	python3 -m py_compile script/*.py

# ----------------------------------------------------------- pkgsrc layer
# Phase 1 + 2 + 3 of docs/pkgsrc-plan.md.
#
# These run on the LFS system once the base build is complete and the
# system can reach the network.  They are deliberately separate from the
# docker-driven base build above so they can be re-run on a real (or
# qemu-booted) target without rebuilding LFS.
#
# Override on the cmdline as needed:
#   make pkgsrc-bootstrap QUARTER=2025Q4 JOBS=4
#   make pkgsrc-baseline  LIST=pkg/pkgsrc-baseline.list

QUARTER ?= 2025Q3
JOBS    ?= $(shell nproc 2>/dev/null || echo 2)
LIST    ?= pkg/pkgsrc-baseline.list
LFS_MNT ?= /mnt/lfs

# All three targets push their script into the LFS rootfs at $(LFS_MNT)/root
# and then `chroot` into it (with /proc, /sys, /dev, /run bind-mounts and
# a working /etc/resolv.conf already plumbed by the base build) so the
# pkgsrc layer is installed *into the LFS system*, not into the build
# container.

sources-partition:
	$(RSYNC) pkgsrc/sources-partition.sh root@localhost:$(LFS_MNT)/root/
	$(SSH_ROOT) 'chroot $(LFS_MNT) /usr/bin/env -i HOME=/root TERM=$$TERM \
	      PATH=/usr/bin:/usr/sbin:/bin:/sbin \
	      bash /root/sources-partition.sh'

pkgsrc-bootstrap:
	$(RSYNC) pkgsrc/bootstrap.sh root@localhost:$(LFS_MNT)/root/
	$(SSH_ROOT) 'chroot $(LFS_MNT) /usr/bin/env -i HOME=/root TERM=$$TERM \
	      PATH=/usr/bin:/usr/sbin:/bin:/sbin \
	      QUARTER=$(QUARTER) JOBS=$(JOBS) \
	      bash /root/bootstrap.sh'

pkgsrc-baseline:
	$(RSYNC) pkgsrc/baseline.sh $(LIST) root@localhost:$(LFS_MNT)/root/
	$(SSH_ROOT) 'chroot $(LFS_MNT) /usr/bin/env -i HOME=/root TERM=$$TERM \
	      PATH=/usr/bin:/usr/sbin:/bin:/sbin \
	      QUARTER=$(QUARTER) LIST=/root/$(notdir $(LIST)) \
	      bash /root/baseline.sh'
