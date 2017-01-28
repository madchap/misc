#!/bin/bash
[[ -z $1 ]] && echo "Need a host to connect to." && exit -1

while getopts "s:fh" opt; do
	case $opt in 
		"h")
			echo "Usage $0 -s MYHOST [-f] [-h]"
			echo "	-f : force rsync of vim and tmux plugins"
			echo "	-h : help"
			exit 0
			;;
		"f")
			FORCE=1
			;;
		"s")
			MYHOST=${OPTARG}
			;;
		"*")
			echo "Unknown option."
			exit 2
			;;
	esac
done

RSYNC="$(which rsync) -rtuL"

if [ $FORCE ]; then
	# sync tmux config and plugins from local
	echo "Sync'ing tmux config and plugins..."
	$RSYNC --exclude 'tmux_resurrect_*' ~/.tmux/ $MYHOST:~/.tmux/
	$RSYNC ~/.tmux-server.conf $MYHOST:~/.tmux.conf
	ssh $MYHOST "sed -i '/set-option -g prefix C-x/d' .tmux.conf"

	echo "Sync'ing vim config and plugins..."
	# sync vim config
	$RSYNC ~/.vim/ $MYHOST:~/.vim/
	$RSYNC ~/.vimrc-server $MYHOST:~/.vimrc
fi

TMUX_SESSION_NAME="fbi-mux"
ssh -t $MYHOST "hash tmux 2>/dev/null || sudo yum -y install tmux; tmux attach -t $TMUX_SESSION_NAME || tmux new -s $TMUX_SESSION_NAME"
