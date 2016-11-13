if uname -v |grep -q Ubuntu; then
	sudo apt-get -y install zsh zsh-syntax-highlighting gitlab-shell git curl vim terminator powerline xfonts-terminus python-pip jq tmux xclip xsel

	if [ $(getent passwd $(whoami) | cut -d: -f7) = "/bin/bash" ]; then
		echo "Changing shell to zsh.. please enter your password."
		chsh -s $(which zsh)
	fi
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

# vim
cd ~/gitrepos
if [ ! -d vim-wombat256mod ]; then
	git clone https://github.com/michalbachowski/vim-wombat256mod.git
	sudo cp vim-wombat256mod/colors/wombat256mod.vim /usr/share/vim/vim74/colors
fi

# tmux
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    #sudo gem install tmuxinator
    #cp /var/lib/gems/2.3.0/gems/tmuxinator-0.9.0/completion/tmuxinator.zsh ~
fi

# get custom files from git
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.vimrc > ~/.vimrc
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.zshrc > ~/.zshrc
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/zsh_autosuggestions_config.zsh > ~/.oh-my-zsh/custom/config.zsh
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.tmux.conf > ~/.tmux.conf
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.tmux-macos.conf > ~/.tmux-macos.conf

# pip
# pip install --upgrade pip
hash openstack 2>/dev/null || sudo pip install python-openstackclient

