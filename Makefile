dl-sources:
	cat packages.txt | xargs -n 1 ssh -p 2222 root@localhost wget --continue --directory-prefix=${LFS}/sources
#wget - --continue --directory-prefix=${LFS}/sources

docker-build:
	docker build . -t linuxfromscratch

docker-run:
	docker run -v sources:/sources -p 2222:22 -d linuxfromscratch

docker-kill:
	./kill_container.sh

undo-known-hosts:
	sed -i '' -e '$$ d' ~/.ssh/known_hosts # mac os x specific

clean:
	docker rmi -f linuxfromscratch

all: docker-kill clean docker-build undo-known-hosts docker-run
