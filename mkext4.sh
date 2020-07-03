dd if=/dev/zero of=lfs.img count=1024 bs=20971520
losetup /dev/loop0 lfs.img 
mkfs -v -t ext4 /dev/loop0 

mkdir -p /mnt/lfs
mount -v -t ext4 /dev/loop0 /mnt/lfs
