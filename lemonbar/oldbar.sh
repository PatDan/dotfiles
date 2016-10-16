#!/usr/bin/bash
# Define the clock
Clock() {
		echo "$(~/.config/i3blocks/time)"
}

Battery() {
		echo "$(~/.config/i3blocks/battery)"
}
 # █  🌔  ;♚
Brightness() {
		echo "$(~/.config/i3blocks/brightness)"
}
Volume() {
		echo "$(~/.config/i3blocks/volume)"
}


Workspaces() {
		WORKSPACES="$(i3-msg -t get_workspaces)"
		echo $(~/.config/lemonbar/example.py $WORKSPACES)
}
Network() {
		echo "$(~/.config/i3blocks/network)"
}
Info() {
	echo " %{l}%{F#FFFFFF}%{B#2E343C} $(Network) $(Brightness)%{c}$(Workspaces)%{F-}%{B-}%{r}%{f#ffffff}%{B#2E343C}$(Battery) $(Volume) $(Clock)%{F-}%{B-}"
}
Empty() {
	echo ""
}
Generate() {
while true; do
	echo $(Info)' '
	sleep 1 &
	wait
done
}
trap 'Generate' 36
echo $(Generate)


#clockinfo=$(Clock)
#batteryinfo=$(Battery)
#brightnessinfo=$(Brightness)
#volumeinfo=$(Volume)
#wsinfo=$(Workspaces)
#netinfo=$(Network)
#
#trap 'echo %{l}%{F#FFFFFF}%{B#2E343C} $netinfo $brightnessinfo%{c}$(Workspaces)%{F-}%{B-}%{r}%{f#ffffff}%{B#2E343C}$batteryinfo $(Volume) $clockinfo%{F-}%{B-}' 36
#while true; do
#	clockinfo=$(Clock)
#	batteryinfo=$(Battery)
#	brightnessinfo=$(Brightness)
#	volumeinfo=$(Volume)
#	wsinfo=$(Workspaces)
#	netinfo=$(Network)
#	echo " %{l}%{F#FFFFFF}%{B#2E343C} $netinfo $brightnessinfo%{c}$wsinfo%{F-}%{B-}%{r}%{f#ffffff}%{B#2E343C}$batteryinfo $volumeinfo $clockinfo%{F-}%{B-}"
#	read -t 1
#done
#
