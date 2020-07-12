dd if=/dev/zero of=lfs.img count=1024 bs=31457280
printf 'o\nn\np\n1\n\n\nw\n' | fdisk "lfs.img"

LOOPVAL=$(kpartx -av lfs.img)
LOOPVAL=$(echo "$LOOPVAL" | cut -d" " -f3)

mke2fs -t ext4 /dev/mapper/$LOOPVAL

mkdir -p /mnt/lfs
mount -v -t ext4 /dev/mapper/$LOOPVAL /mnt/lfs
