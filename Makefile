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
	scp -P 2222 scripts/mkext4.sh root@localhost: && ssh -p 2222 -o StrictHostKeyChecking=no -l "root" "localhost" "source mkext4.sh"

ssh:
	./ssh.sh

run-stage0:
	cat scripts/stage0.sh | ssh -p 2222 -o StrictHostKeyChecking=no -l "root" "localhost"

run-stage1:
	cat scripts/stage1.sh | ssh -p 2222 -o StrictHostKeyChecking=no -l "root" "localhost"

dl-sources:
	cat packages.txt | xargs -n1 ssh -p 2222 lfs@localhost wget --continue --directory-prefix=/mnt/lfs/sources

prep-pkgs:
	scp -P 2222 pkg/prep/binutils.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source binutils.sh"
	scp -P 2222 pkg/prep/gcc-pass1.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source gcc-pass1.sh"
	scp -P 2222 pkg/prep/linux-headers.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source linux-headers.sh"
	scp -P 2222 pkg/prep/glibc.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source glibc.sh"
	scp -P 2222 pkg/prep/libstdcplusplus.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source libstdcplusplus.sh"
	scp -P 2222 pkg/prep/binutils-pass-2.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source binutils-pass-2.sh"
	scp -P 2222 pkg/prep/gcc-pass2.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source gcc-pass2.sh"
	scp -P 2222 pkg/prep/tcl.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source tcl.sh"
	scp -P 2222 pkg/prep/expect.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source expect.sh"
	scp -P 2222 pkg/prep/dejagnu.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source dejagnu.sh"
	scp -P 2222 pkg/prep/m4.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source m4.sh"
	scp -P 2222 pkg/prep/ncurses.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source ncurses.sh"
	scp -P 2222 pkg/prep/bash.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source bash.sh"
	scp -P 2222 pkg/prep/bison.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source bison.sh"
	scp -P 2222 pkg/prep/bzip2.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source bzip2.sh"
	scp -P 2222 pkg/prep/coreutils.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source coreutils.sh"
	scp -P 2222 pkg/prep/diffutils.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source diffutils.sh"
	scp -P 2222 pkg/prep/file.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source file.sh"
	scp -P 2222 pkg/prep/findutils.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source findutils.sh"
	scp -P 2222 pkg/prep/gawk.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source gawk.sh"
	scp -P 2222 pkg/prep/gettext.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source gettext.sh"
	scp -P 2222 pkg/prep/grep.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source grep.sh"
	scp -P 2222 pkg/prep/make.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source make.sh"
	scp -P 2222 pkg/prep/patch.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source patch.sh"
	scp -P 2222 pkg/prep/perl.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source perl.sh"
	scp -P 2222 pkg/prep/python.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source python.sh"
	scp -P 2222 pkg/prep/sed.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source sed.sh"
	scp -P 2222 pkg/prep/tar.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source tar.sh"
	scp -P 2222 pkg/prep/texinfo.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source texinfo.sh"
	scp -P 2222 pkg/prep/xz.sh lfs@localhost: && ssh -p 2222 lfs@localhost "source xz.sh"

build-pkgs:
	# TODO: restart ssh daemon for some raisin
	scp -P 2222 pkg/build/* root@localhost:/mnt/lfs/tools && ssh -p 2222 root@localhost "sh /tools/run-build.sh"

	
all: docker-kill clean docker-build  docker-run run-stage0 ext4-img run-stage1 dl-sources prep-pkgs build-pkgs
