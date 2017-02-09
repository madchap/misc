if uname -v |grep -q Ubuntu; then
	sudo apt-get -y install zsh zsh-syntax-highlighting gitlab-shell git curl vim terminator powerline xfonts-terminus python-pip jq tmux xclip xsel
else
	# knowing me, probably opensuse
	sudo zypper --non-interactive install zsh git curl vim terminator python-pip jq tmux xclip xsel chromium remmina-plugin-rdp lsb synergy 
	sudo zypper --non-interactive install -t pattern devel_python devel_python3 devel_basis

	sudo zypper ar -f -n packman http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman
	sudo zypper ar -f -n packman http://download.videolan.org/pub/vlc/SuSE/Tumbleweed/ vlc

fi

if [ $(getent passwd $(whoami) | cut -d: -f7) = "/bin/bash" ]; then
	echo "Changing shell to zsh.. please enter your password."
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

    #sudo gem install tmuxinator
    #cp /var/lib/gems/2.3.0/gems/tmuxinator-0.9.0/completion/tmuxinator.zsh ~
fi

# get custom files from git
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.vimrc > ~/.vimrc
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.vimrc-server > ~/.vimrc-server
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.zshrc > ~/.zshrc
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/zsh_autosuggestions_config.zsh > ~/.oh-my-zsh/custom/config.zsh
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.tmux.conf > ~/.tmux.conf
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.tmux-server.conf > ~/.tmux-server.conf
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.tmux-macos.conf > ~/.tmux-macos.conf
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.sshrc > ~/.ssh/rc
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.alias > ~/.alias
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/sync_remote_tmux_and_vi.sh > ~/sync_remote_tmux_and_vi.sh && chmod u+x ~/sync_remote_tmux_and_vi.sh

# pip
# pip install --upgrade pip
hash openstack 2>/dev/null || sudo pip install python-openstackclient

