#!/bin/sh


# remove old panel fifo, create new one
fifo="/tmp/panel_fifo"
[ -e "$fifo" ] && rm "$fifo"
mkfifo "$fifo"

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
	str=" %{l}%{F#FFFFFF} $(Network) $(Brightness)%{c}$(Workspaces)%{F-}%{B-}%{r}%{f#ffffff}$(Battery) $(Volume) $(Clock)%{F-}%{B-}"
	#if [ -n "$str"  ]
	#then
		echo "$str"
	#fi
}
#run each applet in subshell and output to fifo
while :; do Workspaces; sleep 1s; done > "$fifo" &
while :; do Volume; sleep 5s; done > "$fifo" &
while :; do Clock; sleep 30s; done > "$fifo" &


while read -r line ; do
    case $line in
        Workspaces*)
            workspaces="poop"
            ;;
        Volume*)
            volume="yoyo"
            ;;
        Clock*)
            clock="fuu"
            ;;
    esac
    echo "${Workspaces}${Volume}${Clock}"
done
