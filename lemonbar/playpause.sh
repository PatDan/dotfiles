#!/usr/bin/bash

status=$(playerctl status)
playerctl play-pause
if [ $status = "Paused" ]
then
	status="Playing"
else
	status="Paused"
fi
info="Spotify"$(python ~/.config/lemonbar/blocks/music.py $status)
echo $info > /tmp/panel_fifo
