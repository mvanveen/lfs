cd /sources

rm -rf v8.2.1114
tar xzf v8.2.1114.tar.gz
cd vim-8.2.1114

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr

make

chown -Rv nobody .

#echo 'testing vim...'
#su nobody -s /bin/bash -c "LANG=en_US.UTF-8 make -j1 test" &> vim-test.log

echo 'installing vim...'

make install

ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done

ln -sv ../vim/vim82/doc /usr/share/doc/vim-8.2.0190

# TODO: pull my own vimrc!

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
