#!/bin/sh
if [[ $# -gt 0 ]]
then
	a=$(cat $HOME/.config/termite/config | grep color4 | awk '{print $NF}' | head -1 )
	$1 -fn 'Hack'-11 -h 20 -sb $a -nb '#272C33' -sf '#272C33' -nf '#ffffff'
fi
