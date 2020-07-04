cd /mnt/lfs/sources;

rm -rf ncurses-6.2
tar xzf ncurses-6.2.tar.gz
cd ncurses-6.2

sed -i s/mawk// configure

./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
	    --without-ada   \
	    --enable-widec  \
	    --enable-overwrite

make

make install

#ln -s libcursesw.so /tools/lib/libncurses.so
