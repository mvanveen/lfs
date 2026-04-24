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
SSH_ROOT := ssh -p $(CONTAINER_PORT) -o StrictHostKeyChecking=no root@localhost
SSH_LFS  := ssh -p $(CONTAINER_PORT) -o StrictHostKeyChecking=no lfs@localhost
SCP      := scp -P $(CONTAINER_PORT) -o StrictHostKeyChecking=no

.PHONY: all docker-build docker-run docker-kill clean undo-known-hosts \
        mkimg prep-host dl-sources upload-pkgs \
        prep-pkgs build-pkgs ssh ssh-lfs lint \
        status reset-stamps logs

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
	$(SCP) script/mkext4.sh root@localhost:/root/
	$(SSH_ROOT) 'bash /root/mkext4.sh'

prep-host:
	$(SCP) script/stage0.sh root@localhost:/root/
	$(SSH_ROOT) 'bash /root/stage0.sh'

dl-sources:
	$(SCP) packages.txt md5sums root@localhost:/mnt/lfs/sources/
	$(SSH_ROOT) 'cd /mnt/lfs/sources && wget --continue --input-file=packages.txt'

# Bulk-copy the prep + build trees.  rsync preserves /mnt/lfs/sources/.done
# and .log from prior runs so re-uploads don't clobber resume state.
RSYNC := rsync -a --delete -e 'ssh -p $(CONTAINER_PORT) -o StrictHostKeyChecking=no'
upload-pkgs:
	$(RSYNC) pkg/prep/  root@localhost:/mnt/lfs/sources/prep/
	$(RSYNC) pkg/build/ root@localhost:/mnt/lfs/sources/build/
	$(SCP) script/stage1.sh root@localhost:/mnt/lfs/sources/prep/stage1.sh
	$(SSH_ROOT) 'chown -R lfs:lfs /mnt/lfs/sources && chmod +x /mnt/lfs/sources/prep/*.sh /mnt/lfs/sources/build/*.sh'

# FORCE=pkg1,pkg2  re-run those packages even if stamped.
# FORCE=all        wipe all stamps (full rebuild).
FORCE ?=
prep-pkgs:
	$(SSH_LFS) 'FORCE=$(FORCE) bash /mnt/lfs/sources/prep/stage1.sh'

build-pkgs:
	$(SSH_ROOT) 'FORCE=$(FORCE) bash /mnt/lfs/sources/build/run-build.sh'

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

# ----------------------------------------------------------------- utilities
ssh:
	$(SSH_ROOT)
ssh-lfs:
	$(SSH_LFS)

lint:
	shellcheck -S warning script/*.sh pkg/*/*.sh run.sh kill_container.sh
	@command -v hadolint >/dev/null 2>&1 && hadolint Dockerfile \
	  || docker run --rm -i hadolint/hadolint < Dockerfile
	bash -n $$(find script pkg -name '*.sh')
	python3 -m py_compile script/*.py
