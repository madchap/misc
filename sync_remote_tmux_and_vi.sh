#!/bin/bash

[[ -z $1 ]] && echo "Need a host to connect to." && exit -1
RSYNC="$(which rsync) -rtuL"

# sync tmux config and plugins from local
echo "Sync'ing tmux config and plugins..."
$RSYNC ~/.tmux/plugins $1:~/.tmux/
$RSYNC ~/.tmux-server.conf $1:~/.tmux.conf

echo "Sync'ing vim config and plugins..."
# sync vim config
$RSYNC ~/.vim $1:~/.vim/
$RSYNC ~/.vimrc-server $1:~/.vimrc

TMUX_SESSION_NAME="fbi-mux"
ssh -t $1 "hash tmux 2>/dev/null || sudo yum -y install tmux; tmux attach -t $TMUX_SESSION_NAME || tmux new -s $TMUX_SESSION_NAME"
