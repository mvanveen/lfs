dd if=/dev/zero of=lfs.img count=1024 bs=31457280
LOOPDEV=$(losetup -P -f --show lfs.img)
mkfs -v -t ext4 $LOOPDEV

mkdir -p /mnt/lfs
mount -v -t ext4 $LOOPDEV /mnt/lfs