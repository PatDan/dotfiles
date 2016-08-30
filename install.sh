#!/bin/bash
if [ ! -e "$HOME/.i3" ]; then
	ln -s $HOME/.dotfiles/i3 $HOME/.i3
fi
if [ ! -e "$HOME/.i3blocks.conf" ]; then
	ln -s $HOME/.dotfiles/i3blocks.conf $HOME/.i3blocks.conf
fi
if [ ! -e "$HOME/.config/i3blocks" ]; then
	ln -s $HOME/.dotfiles/i3blocks $HOME/.config/i3blocks
fi
if [ ! -e "$HOME/.config/termite" ]; then
	ln -s $HOME/.dotfiles/termite $HOME/.config/termite
fi
if [ ! -e "$HOME/.tmux.conf" ]; then
	ln -s $HOME/.dotfiles/tmux.conf $HOME/.tmux.conf
fi
if [ ! -e "$HOME/.vim" ]; then
	ln -s $HOME/.dotfiles/vim $HOME/.vim &&
	git clone https://github.com/klen/python-mode.git $HOME/.vim/bundle/python-mode &&
	git clone https://github.com/scrooloose/nerdtree.git $HOME/.vim/bundle/nerdtree &&
	git clone https://github.com/jistr/vim-nerdtree-tabs.git $HOME/.vim/bundle/vim-nerdtree-tabs &&
	git clone https://github.com/vim-scripts/indentpython.vim.git $HOME/.vim/bundle/indentpython.vim &&
	git clone https://github.com/ctrlpvim/ctrlp.vim.git $HOME/.vim/bundle/ctrlp.vim &&
	git clone https://github.com/tpope/vim-sensible.git $HOME/.vim/bundle/vim-sensible
fi
if [ ! -e "$HOME/.vimrc" ]; then
	ln -s $HOME/.dotfiles/vim/vimrc $HOME/.vimrc
fi
if [ ! -e "$HOME/.xlock" ]; then
	ln -s $HOME/.dotfiles/xlock $HOME/.xlock
fi
if [ ! -e "$HOME/.zshrc" ]; then
	ln -s $HOME/.dotfiles/zshrc $HOME/.zshrc
fi
if [ ! -e "$HOME/.config/powerline" ]; then
	ln -s $HOME/.dotfiles/powerline $HOME/.config/powerline
fi
