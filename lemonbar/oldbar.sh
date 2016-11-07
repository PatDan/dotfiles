#!/usr/bin/bash
# Define the clock
Clock() {
		echo "$(~/.config/lemonbar/blocks/time)"
}

Battery() {
		echo "$(~/.config/lemonbar/blocks/battery)"
}
Brightness() {
		echo "$(~/.config/lemonbar/blocks/brightness)"
}
Volume() {
		echo "$(~/.config/lemonbar/blocks/volume)"
}


Workspaces() {
		WORKSPACES="$(i3-msg -t get_workspaces)"
		echo $(~/.config/lemonbar/workspaces.py $WORKSPACES)
}
Network() {
		echo "$(~/.config/lemonbar/blocks/network)"
}
Lock() {
		echo "$(~/.config/lemonbar/blocks/lock)"
}
Info() {
	str=" %{l}%{F#FFFFFF} $(Network) $(Brightness)%{c}$(Workspaces)%{F-}%{B-}%{r}%{f#ffffff}$(Battery) $(Volume) $(Clock)%{F-}%{B-}"
	#if [ -n "$str"  ]
	#then
		echo "$str"
	#fi
}
trap ':' 36
trap 'exit' SIGINT
while true; do
	echo $(Info)' '
	sleep 1 &
	wait
done
