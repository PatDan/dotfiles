#!/usr/bin/bash

playerctl next
status=$(playerctl status)
info="Spotify"$(python ~/.config/lemonbar/blocks/music.py $status)
echo $info > /tmp/panel_fifo
