#!/bin/bash                                                                      
# Using weechat socket, quick way to send the same private message to people.    
                                                                                 
set -ex

TEAM=( member1 member2 member3 )
[[ -z $1 ]] && echo "Please type a message to PM to your team member" && exit -1

for member in ${TEAM[@]}; do
        echo "*/query $member $@" > ~/.weechat/weechat_fifo
done 
