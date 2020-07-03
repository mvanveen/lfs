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
	sed -i '$$ d' ~/.ssh/known_hosts # mac os x specific

clean:
	rm -rf lfs.img
	rm -rf sources/*
	docker rmi -f linuxfromscratch

ext4-img:
	cat mkext4.sh | ssh -p 2222 -o StrictHostKeyChecking=no -l "root" "localhost"

ssh:
	./ssh.sh

run-stage0:
	cat stage0.sh | ssh -p 2222 -o StrictHostKeyChecking=no -l "root" "localhost"

run-stage1:
	cat stage1.sh | ssh -p 2222 -o StrictHostKeyChecking=no -l "root" "localhost"

dl-sources:
	cat packages.txt | xargs -n 1 ssh -p 2222 lfs@localhost wget --continue --directory-prefix=/mnt/lfs/sources

pkgs:
	cat pkg/coreutils.sh | ssh -p 2222 lfs@localhost
	cat pkg/gcc-pass1.sh | ssh -p 2222 lfs@localhost
	cat pkg/linux-headers.sh | ssh -p 2222 lfs@localhost


all: docker-kill clean docker-build undo-known-hosts docker-run ext4-img run-stage0 stage1 dl-sources
