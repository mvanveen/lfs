# Makefile: drives a Dockerized LFS 12.4 build, end-to-end.
#
# The Docker container acts as the “host” system described in LFS ch 2.
# Inside it, a sparse disk image is created, mounted at /mnt/lfs, and then
# the normal LFS procedure is followed: chapters 5–6 as the `lfs` user,
# chapters 7–10 as root (chapter 7 pivots into chroot).

SHELL          := /bin/bash
IMAGE          := linuxfromscratch
CONTAINER_PORT := 2222
SSH_ROOT       := ssh -p $(CONTAINER_PORT) -o StrictHostKeyChecking=no root@localhost
SSH_LFS        := ssh -p $(CONTAINER_PORT) -o StrictHostKeyChecking=no lfs@localhost
SCP_ROOT       := scp -P $(CONTAINER_PORT) -o StrictHostKeyChecking=no
SCP_LFS        := scp -P $(CONTAINER_PORT) -o StrictHostKeyChecking=no

.PHONY: all docker-build docker-run docker-kill clean undo-known-hosts \
        mkimg prep-host dl-sources upload-build \
        run-stage1 run-stage2 ssh ssh-lfs

all: docker-kill clean docker-build docker-run mkimg prep-host dl-sources \
     upload-build run-stage1 run-stage2

docker-build:
	docker build . -t $(IMAGE)

docker-run:
	docker run -p $(CONTAINER_PORT):22 -d --privileged $(IMAGE)
	# Wait for sshd to be reachable.
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

# 1. Partition & format the loopback disk image inside the container.
mkimg:
	$(SCP_ROOT) script/mkext4.sh root@localhost:/root/
	$(SSH_ROOT) 'bash /root/mkext4.sh'

# 2. Create the lfs user and prepare $LFS/{sources,tools}.
prep-host:
	$(SCP_ROOT) script/stage0.sh root@localhost:/root/
	$(SSH_ROOT) 'bash /root/stage0.sh'

# 3. Download every tarball and patch listed in the book.
dl-sources:
	$(SCP_ROOT) packages.txt md5sums root@localhost:/mnt/lfs/sources/
	$(SSH_ROOT) 'cd /mnt/lfs/sources && wget --continue --input-file=packages.txt'

# 4. Upload the build scripts (pkg/ tree plus stage scripts).
upload-build:
	$(SSH_ROOT) 'rm -rf /mnt/lfs/sources/pkg && mkdir -p /mnt/lfs/sources/pkg'
	$(SCP_ROOT) -r pkg/* root@localhost:/mnt/lfs/sources/pkg/
	$(SCP_ROOT) script/stage1.sh root@localhost:/mnt/lfs/sources/pkg/stage1.sh
	$(SCP_ROOT) script/stage2.sh root@localhost:/root/stage2.sh
	$(SCP_ROOT) script/stage3.sh root@localhost:/mnt/lfs/sources/stage3.sh
	$(SSH_ROOT) 'chown -R lfs:lfs /mnt/lfs/sources && chmod +x /mnt/lfs/sources/pkg/stage1.sh /mnt/lfs/sources/stage3.sh /root/stage2.sh'

# 5. Chapters 5 & 6 as the lfs user (cross toolchain + cross-compiled temp tools).
run-stage1:
	$(SSH_LFS) 'bash /mnt/lfs/sources/pkg/stage1.sh'

# 6. Chapters 7–10 as root, pivoting into chroot.
run-stage2:
	$(SSH_ROOT) 'bash /root/stage2.sh'

ssh:
	$(SSH_ROOT)

ssh-lfs:
	$(SSH_LFS)
