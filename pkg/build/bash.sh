cd /sources

rm -rf bash-5.0
tar xzf bash-5.0.tar.gz
cd bash-5.0

patch -Np1 -i ../bash-5.0-upstream_fixes-1.patch

./configure --prefix=/usr                    \
            --docdir=/usr/share/doc/bash-5.0 \
            --without-bash-malloc            \
            --with-installed-readline

make

chown -Rv nobody .

su nobody -s /bin/bash -c "PATH=$PATH HOME=/home make tests"

make install
mv -vf /usr/bin/bash /bin

#exec /bin/bash --login +h
