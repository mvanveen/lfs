# sqlite  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/sqlite.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf sqlite-autoconf-3500400
tar xf sqlite-autoconf-3500400.tar.gz
cd sqlite-autoconf-3500400

# (BLFS recipe; needed so CPython _sqlite3 extension builds.)

./configure --prefix=/usr     \
            --disable-static  \
            --enable-fts4     \
            --enable-fts5     \
            CPPFLAGS="-DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_ENABLE_UNLOCK_NOTIFY=1 -DSQLITE_ENABLE_DBSTAT_VTAB=1 -DSQLITE_SECURE_DELETE=1"

make

make install

cd /sources
rm -rf sqlite-autoconf-3500400
