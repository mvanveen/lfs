cd /mnt/lfs/sources

rm -rf Python-3.8.1
tar xf Python-3.8.1.tar.xz
cd Python-3.8.1

sed -i '/def add_multiarch_paths/a \        return' setup.py

./configure --prefix=/tools --without-ensurepip

make

make install
