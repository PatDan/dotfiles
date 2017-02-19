#!/usr/bin/bash

if [ $# -gt 0 ]; then
	if [ "$1" = "playpause" ]; then
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
	elif [ "$1" = "next" ]; then
		playerctl next
		status=$(playerctl status)
		info="Spotify"$(python ~/.config/lemonbar/blocks/music.py $status)
		echo $info > /tmp/panel_fifo
	elif [ "$1" = "previous" ]; then
		playerctl previous
		status=$(playerctl status)
		info="Spotify"$(python ~/.config/lemonbar/blocks/music.py $status)
		echo $info > /tmp/panel_fifo
	fi
fi

