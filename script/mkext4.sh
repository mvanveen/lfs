#dd if=/dev/zero of=lfs.img count=1024 bs=31457280
#printf 'o\nn\np\n1\n\n\nw\n' | fdisk "lfs.img"
#LOOPVAL=$(kpartx -av lfs.img)
#LOOPVAL=$(echo "$LOOPVAL" | cut -d" " -f3)
#mke2fs -t ext4 /dev/mapper/$LOOPVAL
#mount -v -t ext4 /dev/mapper/$LOOPVAL /mnt/lfs
#TODO: check to make sure loopval is set

mkdir -p /mnt/lfs
