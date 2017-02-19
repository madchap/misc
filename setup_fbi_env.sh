currentuser=$(whoami)
if [[ `sudo grep -q "$currentuser" /etc/sudoers` -eq 1 ]]; then
	echo "Adding $currentuser to sudoers"
	sudo bash -c "echo \"$currentuser ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers"
fi

sudo zypper --non-interactive --gpg-auto-import-keys ar -f -n packman http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman
sudo zypper --non-interactive --gpg-auto-import-keys ar -f -n packman http://download.videolan.org/pub/vlc/SuSE/Tumbleweed/ vlc

sudo zypper up

sudo zypper --non-interactive install zsh git curl vim python-pip jq tmux xclip xsel chromium remmina-plugin-rdp lsb synergy exfat-utils fuse-exfat virtualbox deluge autossh shutter gnome-shell-devel libgtop-devel libgtop-2_0-10 cmake pavucontrol evolution-ews
sudo zypper --non-interactive install -t pattern devel_python devel_python3 devel_basis

sudo usermod -a -G vboxusers fblaise

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

# Install vundle plugins
vim +PluginInstall +qall

# compile ycm_core
cd ~/.vim/bundle/YouCompleteMe && ./install.py

# Make sure (or try) that my bluetooth headset work. OK as of Feb 12 2017
# kinda lots of breakouts/glitches it seems.. wifi/waves interferences? Useless at this point.
sudo bash -c 'cat <<EOF>>/etc/pulse/system.pa

## FBI -- bluetooth
load-module module-bluez5-device
load-module module-bluez5-discover
EOF'

# Apparently not needed since I got sound without it.. for doc. -- as root, https://wiki.archlinux.org/index.php/Bluetooth_headset
# # sudo mkdir -p ~gdm/.config/systemd/user
# # ln -s /dev/null ~gdm/.config/systemd/user/pulseaudio.socket
