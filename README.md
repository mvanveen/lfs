Linux From Scratch
==================

sourced from [linux from scratch]()

### notes

- uses an Ubuntu 18.04 docker container to do build out everything
- mounts dd'd image within container as a loopback device that's then formatted ext4
- all commands are run on host OS (or later within chroot jail of new file system tree)
  over SSH
  
### dependencies

Host system just needs docker w/ priviledgd access (for mounting loopback device) and make.

The dockerized ubuntu host that performs buildout has dependencies declared within the
Dockerfile.

### installation

```bash
$ make all
```
