#!/usr/bin/bash

if [ $# -gt 0 ]; then
	if [ "$1" = "next" ]; then
		playerctl next
		status=$(playerctl status)
		info="Spotify"$(python ~/.config/lemonbar/blocks/music.py $status)
		echo $info > /tmp/panel_fifo
	fi
fi
