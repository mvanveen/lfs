export LFS=/mnt/lfs
mkdir -v $LFS/tools
mkdir -v $LFS/sources
chown -v lfs $LFS/tools

chown -v lfs $LFS/sources
chmod -v a+wt $LFS/sources

ln -s $LFS/tools /
