export LFS=/mnt/lfs
mkdir -v $LFS/tools
mkdir -v $LFS/sources
chown -v lfs $LFS/tools

chown -v lfs $LFS/sources
chmod -v a+wt $LFS/sources

ln -s $LFS/tools /

rm -f /usr/bin/awk
ln -s /usr/bin/gawk /usr/bin/awk

rm -f /usr/bin/yacc
ln -s /usr/bin/bison /usr/bin/yacc
