#!/bin/bash

set -x

[[ $UID -eq 0 ]] && echo "Run as your user, no sudo." && exit 1
[[ "$PWD" != '/home/fblaise/gitrepos/misc' ]] && echo "Wrong start directory" && exit 2

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin

# i3 by default
[[ -z "$1" ]] && WM=i3 || WM="$1"

sudo grep -q $(whoami) /etc/sudoers
if [[ $? -eq 1 ]]; then
	echo "Adding $(whoami) to sudoers"
	sudo bash -c "echo \"$(whoami) ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers"
fi

# setup the keyboard
sudo localectl set-keymap ch-fr
sudo localectl set-x11-keymap ch fr

[[ ! -f /etc/zypp/repos.d/packman.repo ]] && sudo zypper ar -f -n packman http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman
# [[ ! -f /etc/zypp/repos.d/vlc.repo ]] && sudo zypper ar -f -n vlc http://download.videolan.org/pub/vlc/SuSE/Tumbleweed/ vlc
[[ ! -f /etc/zypp/repos.d/home_ithod_signal.repo ]] && sudo zypper ar -f -n ithod https://download.opensuse.org/repositories/home:/ithod:/signal/openSUSE_Tumbleweed/ ithod
[[ ! -f /etc/zypp/repos.d/vscode.repo ]] && sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && sudo zypper ar -f -n vscode https://packages.microsoft.com/yumrepos/vscode vscode
[[ ! -f /etc/zypp/repos.d/google-chrome.repo ]] && sudo zypper ar -f -n google-chrome http://dl.google.com/linux/chrome/rpm/stable/x86_64 google-chrome
[[ ! -f /etc/zypp/repos.d/wireguard.repo ]] && sudo zypper ar -f obs://network:vpn:wireguard wireguard

# disabling gpg checks on repo temporarily
sudo zypper mr -G packman
sudo zypper mr -G ithod
sudo zypper mr -G wireguard

sudo zypper dup -y --auto-agree-with-product-licenses 

sudo zypper --non-interactive install zsh git curl vim python-pip jq tmux xclip xsel chromium remmina-plugin-rdp lsb synergy exfat-utils fuse-exfat virtualbox deluge autossh cmake pavucontrol inkscape docker docker-zsh-completion mlocate powertop expect whois kernel-source libinput-tools ansible xdotool net-tools-deprecated docker-compose weechat libinput-tools xdotool pdftk ipcalc tig nmap rpm-build xf86-video-intel fontawesome-fonts gnome-keyring minicom pwgen speedtest-cli gnome-keyring gnome-terminal pulseaudio pulseaudio-utils NetworkManager-applet NetworkManager-openconnect eog evince wireshark xbindkeys aws-cli sshuttle asciinema backintime backintime-qt MozillaFirefox python2-pip mosh xorg-x11-server xfce4-power-manager xinit adobe-sourcecodepro-fonts kubernetes-client gnome-colors-icon-theme go1.13 go1.12 pinentry-gtk2 NetworkManager-openvpn flameshot vlc-codecs wireguard-kmp-default wireguard-tools

sudo zypper -n install google-chrome

# install signal messenger from user repo
sudo zypper -n install signal-desktop

# ironkey needed
sudo zypper -n install glibc-32bit libgcc_s1-32bit

sudo zypper -n install python-devel python3-virtualenvwrapper
sudo zypper -n install powerline powerline-fonts

sudo zypper -n install -t pattern devel_python3 devel_basis
sudo zypper --non-interactive install -t pattern "VideoLAN - VLC media player"

sudo usermod -a -G vboxusers $(whoami)
sudo usermod -a -G docker $(whoami)
sudo usermod -a -G input $(whoami)

if [ $(getent passwd $(whoami) | cut -d: -f7) == "/bin/bash" ]; then
	echo "Changing shell to zsh.. please enter password for ${currentuser}."
	chsh -s $(which zsh)
fi

mkdir ~/.ssh
mkdir ~/.npm-packages
mkdir ~/Pictures
mkdir ~/Downloads

# set npm to look for user's directory
npm config set prefix "${HOME}/.npm-packages"

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

# fzf
if [ -d  ~/.fzf ]; then
	cd ~/.fzf
	git pull
else
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
fi

if [ ! -f ~/bin/bat ]; then
	wget https://github.com/sharkdp/bat/releases/download/v0.12.1/bat-v0.12.1-x86_64-unknown-linux-gnu.tar.gz -O ~/bin/bat.tar.gz
	tar zvxf ~/bin/bat.tar.gz -C ~/bin --strip 1
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
if [ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
    cd ~/.oh-my-zsh/custom/themes/powerlevel10k
    git pull
else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
fi


# vim
cd ~/gitrepos
if [ ! -d vim-wombat256mod ]; then
	git clone https://github.com/michalbachowski/vim-wombat256mod.git
	sudo cp ~/gitrepos/vim-wombat256mod/colors/wombat256mod.vim /usr/share/vim/vim82/colors
fi

# tmux
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    #sudo gem install tmuxinator
    #cp /var/lib/gems/2.3.0/gems/tmuxinator-0.9.0/completion/tmuxinator.zsh ~
fi

if [ ! -d ~/gitrepos/dotfiles ]; then
    git clone https://github.com/madchap/dotfiles.git

    cd ~/gitrepos/dotfiles
    pip3 install -r dotdrop/requirements.txt --user
    ./dotdrop.sh install -p gimli -f # take gimli profile as default linux profile
fi

# plasma config files
# kglobalshortcut has to be put prior to starting kdm to prevent being overwritten
cp -ar ~/gitrepos/misc/kde_plasma5/* ~/.config/

# Moving yubikey udev rules
sudo cp ~/gitrepos/misc/70-u2f.rules /etc/udev/rules.d/70-u2f.rules

# yubikey - smartcard reader
sudo zypper -n install pcsc-ccid
sudo systemctl enable pcscd

# Install vundle plugins
vim +PluginInstall +qall

# compile ycm_core
if [[ ! -f ~/.vim/bundle/YouCompleteMe/third_party/ycmd/ycm_core.so ]]; then
	cd ~/.vim/bundle/YouCompleteMe && ./install.py --gocode-completer
fi

# In the end, using the 'threadirqs' kernel param seems to do the trick! 4mn of audio playing with no stutter!
# Or not... nothing really seems to work a 100% at that time.
# sudo sed -i 's!splash=silent quiet showopts"!splash=0 verbose showopts threadirqs"!' /etc/default/grub
sudo sed -i 's!splash=silent!splash=0"!' /etc/default/grub
sudo sed -i 's!quiet!verbose"!' /etc/default/grub
sudo sed -i 's!GRUB_TIMEOUT=8!GRUB_TIMEOUT=1!' /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# oathtool
if [ ! hash oathtool 2>/dev/null ]; then
	cd ~/Downloads
	wget -q --show-progress http://download.savannah.nongnu.org/releases/oath-toolkit/oath-toolkit-2.6.2.tar.gz
	# Patches should already be fetched from vps
	tar zxf oath-toolkit-2.6.2.tar.gz
	cd oath-toolkit-2.6.2
	cp ~/apps/patch_*.patch .
	for i in $(find . -name intprops.h); do patch -p2 $i < patch_intprops.patch; done
	./configure && make -j3 && sudo make install
	sudo ldconfig
fi

# copy own desktop files
mkdir -p ~/.local/share/applications
# curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/gnome/mattermost.desktop > ~/.local/share/applications/mattermost.desktop
curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/gnome/postman.desktop > ~/.local/share/applications/postman.desktop
# curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/gnome/fortisslclient.desktop > ~/.local/share/applications/fortisslclient.desktop
# curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/gnome/google-chrome-kwallet.desktop > ~/.local/share/applications/google-chrome-kwallet.desktop
# curl -H 'Cache-Control: no-cache' -s https://raw.githubusercontent.com/madchap/misc/master/gnome/fortisslclient_icon.gif > ~/apps/forticlientsslvpn/icon.gif

# minikube, kubectl
# now a pkg for it
if [ ! hash kubectl 2>/dev/null ]; then
       	curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && sudo mv -f kubectl /usr/local/bin/ && sudo chmod +x /usr/local/bin/kubectl
fi
if [ ! hash minikube 2>/dev/null ]; then
       	curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv -f minikube /usr/local/bin/
fi

# more up-to-date version of vagrant
#if [ ! hash vagrant 2>/dev/null ]; then
#	version=2.0.1
#	cd ~/Downloads
#	wget -q --show-progress -O vagrant.rpm https://releases.hashicorp.com/vagrant/$version/vagrant_${version}_x86_64.rpm
#	sudo rpm -Uvh vagrant.rpm
#fi

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
# if [[ $(mount |awk '/on \/home\s{1}/ {print $5}') == 'btrfs' ]]; then
# 	sudo btrfs quota enable /home
# 	# init snapper for /home config
# 	~/gitrepos/misc/snapper/snapper_home.sh
# fi
# 
# if [[ $(mount |awk '/on \/\s{1}/ {print $5}') == 'btrfs' ]]; then
# 	sudo btrfs quota enable /
# fi

# remove synaptics if there, to the profit of libinput (gnome anyways)
[[ $(rpm --quiet -q xf86-input-synaptics) == 1 ]] && sudo zypper rm -y xf86-input-synaptics
sudo zypper addlock xf86-input-synaptics


if [[ "$WM" == "gnome" ]]; then
	sudo zypper --non-interactive install -t pattern "gnome"

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
	~/bin/gnomeshell-extension-manage --install --extension-id 1028
	~/bin/gnomeshell-extension-manage --install --extension-id 905		# wifi reload
	~/bin/gnomeshell-extension-manage --install --extension-id 1015		# gravatar9
	#freon not working ~/bin/gnomeshell-extension-manage --install --extension-id 841

	# gnome-screenshot
	gsettings set org.gnome.gnome-screenshot auto-save-directory "file:///home/$USER/Pictures/"
fi

if [[ "$WM" == "i3" ]]; then
	sudo zypper --non-interactive install i3 scrot xfce4-notifyd thunar thunar-plugin-archive thunar-plugin-vcs thunar-sendto-blueman xbacklight picom xev xautolock xkill xinput clipit rofi feh polkit-gnome NetworkManager-applet blueman bluez xfce4-settings file-roller rofi-calc

	mkdir -p ~/.config/i3
	mkdir -p ~/.i3/scripts
    # should dotdrop
	
	# runlevel 3
	# sudo systemctl disable display-manager.service
	# sudo systemctl set-default runlevel3.target
	# remove any kind of display-manager, that will still cause a mess
	# dm=( "sddm" "gdm" "kdm" "xdm" )
	# for dm in "${dm[@]}"; do
	#	rpm --quiet -q $dm
	#	[[ $? -eq 0 ]] && sudo zypper rm -y $dm
	# done

	# gnome keyring for pam
	pam_gnome_password_string="password optional  pam_gnome_keyring.so"
	if ! grep -q $pam_gnome_password_string /etc/pam.d/passwd; then 
		echo "$pam_gnome_password_string" |sudo tee -a /etc/pam.d/passwd
	fi

	pam_gnome_autostart_string="session    optional     pam_gnome_keyring.so        auto_start"
	if ! grep -q "$pam_gnome_autostart_string" /etc/pam.d/login; then
		echo "$pam_gnome_autostart_string" |sudo tee -a /etc/pam.d/login
	fi

	# get away avahi away from .local
	sudo sed -i 's!#domain-name=local!domain-name=here!' /etc/avahi/avahi-daemon.conf

	# multimonitor lock screen
	git clone https://github.com/shikherverma/i3lock-multimonitor.git ~/.i3/i3lock-multimonitor

	# cp assets around
	cp -f ~/gitrepos/misc/assets/linux-13.png ~/.i3/i3lock-multimonitor/img/background.png
	cp -f ~/gitrepos/misc/assets/i3_solarized_bg.png ~/Pictures/

	# installing python2 netifaces for i3prep.py -- i3 status bar
	sudo zypper --non-interactive in python2-netifaces

	# create the backlight_p.out to avoid i3prep.py to bomb
	echo 100 > ~/.i3/scripts/backlight_p.out
fi

# re-enabling gpg checks on repo temporarily
sudo zypper mr -g packman
sudo zypper mr -g ithod
sudo zypper mr -g wireguard

#firewalld rules
sh ~/gitrepos/misc/firewalld_rules.sh

# power button suspends and do not poweroff
sudo sed -i 's!#HandlePowerKey=poweroff!HandlePowerKey=suspend!' /etc/systemd/logind.conf

# potentially helps in not losing bluetooth after resuming from suspend state.. happens once every 20'ish times..
sudo sed -i 's!USB_BLACKLIST_BTUSB=0!USB_BLACKLIST_BTUSB=1!' /etc/default/tlp

# no DM, setting setuid
echo "/usr/bin/Xorg                 root:root       4711" | sudo tee -a /etc/permissions.local
sudo chkstat --system --set

echo
echo
echo "Setup script done."
