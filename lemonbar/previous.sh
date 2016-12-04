#!/usr/bin/bash

playerctl previous
status=$(playerctl status)
info="Spotify"$(python ~/.config/lemonbar/blocks/music.py $status)
echo $info > /tmp/panel_fifo
