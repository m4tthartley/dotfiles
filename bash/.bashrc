#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

export PATH="$HOME/code/core/bin:$PATH"
export N64_INST=/opt/libdragon
export T3D_INST=/home/matt/code/tiny3d


. "$HOME/.local/bin/env"
