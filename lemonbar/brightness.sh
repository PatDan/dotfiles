#!/bin/bash

echo "Brightness "$(~/.config/lemonbar/blocks/brightness) >  "/tmp/panel_fifo"
sleep 3
if [ $(pgrep -cx brightness.sh) -lt 2 ] ; then
	echo "Brightness" >  "/tmp/panel_fifo"
fi
