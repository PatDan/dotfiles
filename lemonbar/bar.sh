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
Info() {
	echo " %{l}%{F#FFFFFF}%{B#2E343C} $(Network) $(Brightness)%{c}$(Workspaces)%{F-}%{B-}%{r}%{f#ffffff}%{B#2E343C}$(Battery) $(Volume) $(Clock)%{F-}%{B-}"
}
trap 'kill $pid' 36
trap 'exit' SIGINT
while true; do
	echo $(Info)' '
    sleep 1 & pid=$!
	wait
done
