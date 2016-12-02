#!/bin/sh
if [[ $# -gt 0 ]]
then
	a=$(cat $HOME/.config/termite/config | grep color4 | awk '{print $NF}')
	$1 -fn 'Hack'-11 -h 20 -sb $a -nb '#2E343C' -sf '#2E343C' -nf white
fi
