# vim  --  https://www.linuxfromscratch.org/lfs/view/stable/chapter08/vim.html
# shellcheck disable=SC2046,SC2086,SC2038,SC2155,SC2217,SC2226,SC2061
set -e
cd /sources
rm -rf vim-9.1.1629
tar xf vim-9.1.1629.tar.gz
cd vim-9.1.1629

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr

make

chown -R tester .
sed '/test_plugin_glvs/d' -i src/testdir/Make_all.mak

if [ "${RUN_TESTS:-0}" = 1 ]; then
  su tester -c "TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test" \
     &> vim-test.log \
    || echo "WARN: tests failed (advisory)"
else
  echo "skip tests (RUN_TESTS=0)"
fi
make install

ln -sfv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sfv vim.1 $(dirname $L)/vi.1
done

ln -sfv ../vim/vim91/doc /usr/share/doc/vim-9.1.1629

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF
# book: vim -c ':options'  (interactive; skipped)

cd /sources
rm -rf vim-9.1.1629
