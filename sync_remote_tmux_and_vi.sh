#!/bin/bash

REMOTE=$1
RSYNC=$(which rsync)

# sync tmux config and plugins from local
echo "Sync'ing tmux config and plugins..."
$RSYNC -a ~/.tmux/plugins $1:~ 
$RSYNC -a ~/.tmux.conf $1:~

echo "Sync'ing vim config and plugins..."
# sync vim config
$RSYNC -a ~/.vim $1:~
$RSYNC -a ~/.vimrc $1:~

TMUX_SESSION_NAME="fbi-mux"
ssh -t $1 "sed -i '/set-option -g prefix/d' ~/.tmux.conf; tmux attach -t $TMUX_SESSION_NAME || tmux new -s $TMUX_SESSION_NAME"
