#!/bin/bash

sudo grep -q $(whoami) /etc/sudoers
if [[ $? -eq 1 ]]; then
	echo "Adding $(whoami) to sudoers"
	sudo bash -c "echo \"$(whoami) ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers"
fi

sudo zypper --non-interactive --gpg-auto-import-keys ar -f -n packman http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman
sudo zypper --non-interactive --gpg-auto-import-keys ar -f -n vlc http://download.videolan.org/pub/vlc/SuSE/Tumbleweed/ vlc

sudo zypper up

sudo zypper --non-interactive install zsh git curl vim python-pip jq tmux xclip xsel chromium remmina-plugin-rdp lsb synergy exfat-utils fuse-exfat virtualbox deluge autossh shutter gnome-shell-devel libgtop-devel libgtop-2_0-10 cmake pavucontrol evolution-ews inkscape docker docker-zsh-completion mlocate powertop expect whois kernel-source libinput-tools yakuake ansible xdotool net-tools-deprecated docker-compose weechat kernel-source libinput-tools yakuake ansible xdotool net-tools-deprecated docker-compose weechat kernel-firmware
sudo zypper --non-interactive install -t pattern devel_python devel_python3 devel_basis
sudo zypper --non-interactive install -t pattern "VideoLAN - VLC media player"
sudo zypper --non-interactive install -t pattern "gnome"

sudo usermod -a -G vboxusers fblaise
sudo usermod -a -G docker fblaise
sudo usermod -a -G input fblaise

if [ $(getent passwd $(whoami) | cut -d: -f7) = "/bin/bash" ]; then
	echo "Changing shell to zsh.. please enter password for ${currentuser}."
	chsh -s $(which zsh)
fi

if [ ! -d ~/gitrepos ]; then 
	mkdir ~/gitrepos 
fi

if [ ! -d ~/apps ]; then 
	mkdir ~/apps 
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
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.sshrc > ~/.ssh/myrc
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/.alias > ~/.alias
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/sync_remote_tmux_and_vi.sh > ~/sync_remote_tmux_and_vi.sh && chmod u+x ~/sync_remote_tmux_and_vi.sh
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/yubikey/70-u2f.rules > ~/70-u2f.rules
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/gnome/gtk.css > ~/.config/gtk-3.0/gtk.css
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/scripts/launch_fortivpnsslcli_cli > ~/bin/launch_fortivpnsslcli_cli
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/scripts/establish_tunnels.sh > ~/bin/establish_tunnels.sh

# plasma config files
# kglobalshortcut has to be put prior to starting kdm to prevent being overwritten
cp -ar ~/gitrepos/misc/kde_plasma5/* ~/.config/

# Moving yubikey udev rules
sudo mv ~/70-u2f.rules /etc/udev/rules.d/70-u2f.rules

# pip
# pip install --upgrade pip
hash openstack 2>/dev/null || sudo pip install python-openstackclient

# Install vundle plugins
vim +PluginInstall +qall

# compile ycm_core
cd ~/.vim/bundle/YouCompleteMe && ./install.py

# Make sure (or try) that my bluetooth headset work. OK as of Feb 12 2017
# kinda lots of breakouts/glitches it seems.. wifi/waves interferences? Useless at this point.
# sudo bash -c 'cat <<EOF>>/etc/pulse/system.pa

## FBI -- bluetooth
#load-module module-bluez5-device
#load-module module-bluez5-discover
#EOF'

# Prevent GDM from starting pulseaudio and a2dp sink
# or you can just kill the gdm owned process, so that the user's process take precedence somehow?
#sudo bash -c 'cat <<EOF>>/var/lib/gdm/.config/pulse/client.conf
## FBI -- prevent gdm to start pulseaudio
#autospawn = no
#daemon-binary = /bin/true
#EOF'

# In the end, using the 'threadirqs' kernel param seems to do the trick! 4mn of audio playing with no stutter!
sudo sed -i 's!quiet showopts"!quiet showopts threadirqs"!' /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Installing extra soft
if [ ! -f ~/.extra_softs_installed ]; then
	# Get extra softwares instead of going to download them again from websites.
	echo "Downloading extra software from vps"
	scp 149.202.49.79:~/softwares/* ~/apps/
	
	sudo rpm -Uvh ~/Downloads/google-chrome-stable_current_x86_64.rpm
	cd ~/apps
	tar zxf forticlientsslvpn_linux_4.4.2332.tar.gz
	tar zxf sdtconnector-1.7.5.tar.gz
	tar zxvf mattermost-desktop-3.7.0-linux-x64.tar.gz && ln -s mattermost-desktop-3.7.0 mattermost

	touch ~/.extra_softs_installed
fi

# Extra github repos
if [ ! -d ~/gitrepos/luxafor-python ]; then
	cd ~/gitrepos
	git clone https://github.com/vmitchell85/luxafor-python.git
fi

# oathtool
if [ ! $(hash oathtool 2>/dev/null) ]; then
	cd ~/Downloads
	wget -q --show-progress http://download.savannah.nongnu.org/releases/oath-toolkit/oath-toolkit-2.6.2.tar.gz
	# Patches should already be fetched from vps
	tar zxf oath-toolkit-2.6.2.tar.gz
	cd oath-toolkit-2.6.2
	mv ~/Downloads/patch_*.patch .
	for i in $(find . -name intprops.h); do patch -p2 $i < patch_intprops.patch; done
	./configure && make -j3 && sudo make install
fi

# copy own desktop files
mkdir -p ~/.local/share/applications
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/gnome/mattermost.desktop > ~/.local/share/applications/mattermost.desktop
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/gnome/fortisslclient.desktop > ~/.local/share/applications/fortisslclient.desktop
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/gnome/fortisslclient_icon.gif > ~/apps/forticlientsslvpn/icon.gif

# minikube, kubectl
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && sudo mv kubectl /usr/local/bin/ && sudo chmod +x /usr/local/bin/kubectl
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

# more up-to-date version of vagrant
if [ ! $(hash vagrant 2>/dev/null) ]; then
	cd ~/Downloads
	wget -q --show-progress -O vagrant.rpm https://releases.hashicorp.com/vagrant/1.9.7/vagrant_1.9.7_x86_64.rpm
	sudo rpm -Uvh vagrant.rpm
fi

# coreOS for vagrant
if [ ! -d ~/gitrepos/coreos-vagrant ]; then
	cd ~/gitrepos
	git clone https://github.com/coreos/coreos-vagrant.git
	# coreOS for k8s
	# git clone https://github.com/coreos/coreos-kubernetes.git
fi

# libgestures libinput
if [ ! -d ~/gitrepos/libinput-gestures ]; then
	cd ~/gitrepos
	git clone https://github.com/bulletmark/libinput-gestures.git
	sudo gpasswd -a $USER input
	cd ~/gitrepos/libinput-gestures
	sudo ./libinput-gestures-setup install
	./libinput-gestures-setup start
	./libinput-gestures-setup autostart
fi

# enable btrfs quotas
sudo btrfs quota enable /home

# init snapper for /home config
~/gitrepos/misc/snapper/snapper_home.sh

# remove synaptics if there, to the profit of libinput (gnome anyways)
sudo zypper rm xf86-input-synaptics

# Get gnomeshell install script
if [ ! -f ~/bin/gnomeshell-ext-manage ]; then
	curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/gnomeshell-extension-manage > ~/bin/gnomeshell-extension-manage
	chmod +x ~/bin/gnomeshell-extension-manage
fi

# install my wanted gnome extensions, thanks to Nicolas (http://bernaerts.dyndns.org/linux/76-gnome/345-gnome-shell-install-remove-extension-command-line-script)
~/bin/gnomeshell-extension-manage --install --extension-id 15
~/bin/gnomeshell-extension-manage --install --extension-id 118
~/bin/gnomeshell-extension-manage --install --extension-id 818
~/bin/gnomeshell-extension-manage --install --extension-id 1160
~/bin/gnomeshell-extension-manage --install --extension-id 545
~/bin/gnomeshell-extension-manage --install --extension-id 779
~/bin/gnomeshell-extension-manage --install --extension-id 826
~/bin/gnomeshell-extension-manage --install --extension-id 1031
~/bin/gnomeshell-extension-manage --install --extension-id 1276
#freon not working ~/bin/gnomeshell-extension-manage --install --extension-id 841

# Setting up onedrive client
if [ -d ~/gitrepos/onedrive ]; then
	sudo zypper in sqlite3-devel libcurl-devel
	cd ~/gitrepos
	git clone https://github.com/skilion/onedrive.git
	cd ~/gitrepos/onedrive
	curl -fsS https://dlang.org/install.sh | bash -s dmd
	source ~/dlang/dmd-2.076.0/activate
	make
	sudo make install
	cp ./onedrive ~/bin/
	echo "Please initiate the setup manually."
	systemctl --user enable onedrive
fi


echo
echo
echo "Done."
