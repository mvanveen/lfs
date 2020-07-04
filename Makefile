docker-build:
	docker build . -t linuxfromscratch

docker-run:
	#docker run -v sources:/sources -p 2222:22 -d linuxfromscratch
	#-v ${CURDIR}/lfs.img:/root/lfs.img 
	docker run -p 2222:22 -d --privileged linuxfromscratch

docker-kill:
	./kill_container.sh

undo-known-hosts:
	#sed -i '' -e '$$ d' ~/.ssh/known_hosts # mac os x specific
	#sed -i '$$ d' ~/.ssh/known_hosts # linux specific
	rm -rf ~/.ssh/known_hosts

clean:
	rm -rf lfs.img
	rm -rf sources/*
	docker rmi -f linuxfromscratch

ext4-img:
	scp -P 2222 mkext4.sh root@localhost: && ssh -p 2222 -o StrictHostKeyChecking=no -l "root" "localhost" "source mkext4.sh"

ssh:
	./ssh.sh

run-stage0:
	cat stage0.sh | ssh -p 2222 -o StrictHostKeyChecking=no -l "root" "localhost"

run-stage1:
	cat stage1.sh | ssh -p 2222 -o StrictHostKeyChecking=no -l "root" "localhost"

dl-sources:
	cat packages.txt | xargs -n1 ssh -p 2222 lfs@localhost wget --continue --directory-prefix=/mnt/lfs/sources

pkgs:
	scp -P 2222 pkg/binutils.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source binutils.sh"
	scp -P 2222 pkg/gcc-pass1.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source gcc-pass1.sh"
	scp -P 2222 pkg/linux-headers.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source linux-headers.sh"
	scp -P 2222 pkg/glibc.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source glibc.sh"
	scp -P 2222 pkg/libstdcplusplus.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source libstdcplusplus.sh"
	scp -P 2222 pkg/binutils-pass-2.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source binutils-pass-2.sh"
	scp -P 2222 pkg/gcc-pass2.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source gcc-pass2.sh"
	scp -P 2222 pkg/tcl.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source tcl.sh"
	scp -P 2222 pkg/expect.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source expect.sh"
	scp -P 2222 pkg/dejagnu.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source dejagnu.sh"
	scp -P 2222 pkg/m4.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source m4.sh"
	scp -P 2222 pkg/ncurses.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source ncurses.sh"
	scp -P 2222 pkg/bash.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source bash.sh"
	scp -P 2222 pkg/bison.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source bison.sh"
	scp -P 2222 pkg/bzip2.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source bzip2.sh"
	scp -P 2222 pkg/coreutils.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source coreutils.sh"


all: docker-kill clean docker-build undo-known-hosts docker-run run-stage0 ext4-img run-stage1 dl-sources
