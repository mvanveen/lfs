dl-sources:
	mkdir -v ${LFS}/sources
	chmod -v a+wt ${LFS}/sources
	wget --input-file=wget-list --continue --directory-prefix=${LFS}/sources

docker-build:
	docker build . -t linuxfromscratch

docker-run:
	docker run -v sources:/sources -it linuxfromscratch /bin/sh

clean:
	docker rmi linuxfromscratch
