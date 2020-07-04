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
	scp -P 2222 pkg/diffutils.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source diffutils.sh"
	scp -P 2222 pkg/file.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source file.sh"
	scp -P 2222 pkg/findutils.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source findutils.sh"
	scp -P 2222 pkg/gawk.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source gawk.sh"
	scp -P 2222 pkg/gettext.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source gettext.sh"
	scp -P 2222 pkg/grep.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source grep.sh"
	scp -P 2222 pkg/make.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source make.sh"
	scp -P 2222 pkg/patch.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source patch.sh"
	scp -P 2222 pkg/perl.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source perl.sh"
	scp -P 2222 pkg/python.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source python.sh"
	scp -P 2222 pkg/sed.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source sed.sh"
	scp -P 2222 pkg/tar.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source tar.sh"
	scp -P 2222 pkg/texinfo.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source texinfo.sh"
	scp -P 2222 pkg/xz.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source xz.sh"
	ssh -p 2222 root@localhost "chown -R root:root $LFS/tools"
	scp -P 2222 prep.sh root@localhost: && ssh -p 2222 root@localhost "source prep.sh"

all: docker-kill clean docker-build undo-known-hosts docker-run run-stage0 ext4-img run-stage1 dl-sources
