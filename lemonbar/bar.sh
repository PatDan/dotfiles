#!/usr/bin/bash

barpid="$$"
trap 'trap - TERM; kill 0' INT TERM QUIT EXIT
if [ $(pgrep -cx lemonbar) -gt 0 ] ; then
	printf "%s\n" "The panel is already running." >&2
	exit 1
fi

fifo="/tmp/panel_fifo"
[ -e "$fifo" ] && rm "$fifo"
mkfifo "$fifo"

windowtitle() {
		echo "Windowtitle "$(~/.config/lemonbar/blocks/windowtitle)
}
clock() {
	echo "Clock %{+u +o}%{B-}%{U#272C33}$(~/.config/lemonbar/blocks/calendar) $(~/.config/lemonbar/blocks/time)%{B-}%{U-}%{-u -o}"
}
battery() {
		echo "Battery "$(~/.config/lemonbar/blocks/battery)
		#echo 'Battery  96%' && sleep 1 && echo 'Battery  96%' && sleep 1 && echo 'Battery  96%' && sleep 1 && echo 'Battery  96%' && sleep 1 && echo 'Battery  96%' && sleep 1 &
}
volume() {
		echo "Volume "$(~/.config/lemonbar/blocks/volume)
}
network() {
		echo "Network "$(~/.config/lemonbar/blocks/network)
}
spotify() {
		if [ $(pgrep -cx spotify) -gt 0 ] ; then
			status=$(playerctl status)
			echo "Spotify"$(python ~/.config/lemonbar/blocks/music.py $status)
        else
			echo "Spotify"
        fi
}

while :; do volume; sleep 30s; done > "$fifo" &
while :; do clock; sleep 60s; done > "$fifo" &
while :; do battery; sleep 6s; done > "$fifo" &
while :; do network; sleep 10s; done > "$fifo" &
while :; do spotify; sleep 5s; done > "$fifo" &

/home/patrik/.config/lemonbar/events.py &

while read -r line ; do
    case $line in
        Workspaces*)
            ws="${line:11}"
            ;;
        Volume*)
            vl="%{T4}${line:7}%{T-}"
            ;;
        Clock*)
            cl="${line:5}"
            ;;
        Battery*)
            bt="${line:7}"
            ;;
        Network*)
            nt="${line:7}"
            ;;
        Brightness*)
            bn="${line:10}"
            ;;
        Windowtitle*)
            wt="${line:11}"
            ;;
		resizemode*)
            rs="${line:10}"
			;;
		defaultmode*)
			rs=""
			;;
		Spotify*)
            sp="${line:7}"
			;;
    esac
	echo "%{l}%{#FFFFFF}$nt $testinfo$vl  $sp $rs%{c}%{T4}$ws%{T-}%{B-}%{r}$bn $bt%{A:gsimplecal &:}$cl%{A}%{F-}"
done < "$fifo" | lemonbar -f "Hack:size=10" -o 0 -f "FontAwesome:size=10" \
	-o -2.5 -f "Material Icons:size=12" -o -1.5 -f "Hack:size=10" -o 0 -f "FontAwesome:size=12" -o 0 -u 0 -U "#FFFFFF" -B "#272C33" -F "#FFFFFF" -g 1920x20+0+0 | sh
    
