#!/usr/bin/bash
WORKSPACES="$(i3-msg -t get_workspaces)"
echo "Workspaces "$(~/.config/lemonbar/workspaces.py $WORKSPACES) > /tmp/panel_fifo

