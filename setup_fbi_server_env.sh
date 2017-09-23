#!/bin/bash

sudo yum -y install http://mirror.ghettoforge.org/distributions/gf/el/7/plus/x86_64/tmux-2.4-2.gf.el7.x86_64.rpm
curl -L https://copr.fedorainfracloud.org/coprs/mcepl/vim8/repo/epel-7/mcepl-vim8-epel-7.repo -o /etc/yum.repos.d/mcepl-vim8-epel-7.repo
sudo yum update vim+

if [ $(getent passwd $(whoami) | cut -d: -f7) = "/bin/bash" ]; then
	echo "Changing shell to zsh.. please enter password for ${currentuser}."
	chsh -s $(which zsh)
fi

if [ ! -d ~/gitrepos ]; then 
	mkdir ~/gitrepos 
fi

# zsh
if [ -d  ~/.oh-my-zsh ]; then
	cd ~/.oh-my-zsh
	git pull
else
	git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
fi

if [ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
	cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	git pull
else
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

if [ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
	cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
	git pull
else
	git clone git://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

# vim
cd ~/gitrepos
if [ ! -d vim-wombat256mod ]; then
	git clone https://github.com/michalbachowski/vim-wombat256mod.git
	sudo cp ~/gitrepos/vim-wombat256mod/colors/wombat256mod.vim /usr/share/vim/vim74/colors
	sudo cp ~/gitrepos/vim-wombat256mod/colors/wombat256mod.vim /usr/share/vim/vim80/colors
fi

# tmux
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# get custom files from git
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.vimrc > ~/.vimrc
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.vimrc-server > ~/.vimrc-server
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.zshrc > ~/.zshrc
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/zsh_autosuggestions_config.zsh > ~/.oh-my-zsh/custom/config.zsh
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.tmux.conf > ~/.tmux.conf
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.tmux-server.conf > ~/.tmux-server.conf
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.sshrc > ~/.ssh/myrc
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.alias > ~/.alias
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/sync_remote_tmux_and_vi.sh > ~/sync_remote_tmux_and_vi.sh && chmod u+x ~/sync_remote_tmux_and_vi.sh

# pip
# pip install --upgrade pip
hash openstack 2>/dev/null || sudo pip install python-openstackclient

# Install vundle plugins
vim +PluginInstall +qall

# compile ycm_core
cd ~/.vim/bundle/YouCompleteMe && ./install.py

echo
echo
echo "Done."
