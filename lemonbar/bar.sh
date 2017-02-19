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

Windowtitle() {
		echo "Windowtitle "$(~/.config/lemonbar/blocks/windowtitle)
}

Clock() {
	echo "Clock $(~/.config/lemonbar/blocks/calendar) $(~/.config/lemonbar/blocks/time)"
}

Battery() {
		echo "Battery "$(~/.config/lemonbar/blocks/battery)

		#echo 'Battery  96%' && sleep 1 && echo 'Battery  96%' && sleep 1 && echo 'Battery  96%' && sleep 1 && echo 'Battery  96%' && sleep 1 && echo 'Battery  96%' && sleep 1 &
}
Volume() {
		echo "Volume "$(~/.config/lemonbar/blocks/volume)
}
Network() {
		echo "Network "$(~/.config/lemonbar/blocks/network)
}
Spotify() {
		if [ $(pgrep -cx spotify) -gt 0 ] ; then
			status=$(playerctl status)
			echo "Spotify"$(python ~/.config/lemonbar/blocks/music.py $status)
        else
			echo "Spotify"
        fi

}

while :; do Volume; sleep 30s; done > "$fifo" &
while :; do Clock; sleep 60s; done > "$fifo" &
while :; do Battery; sleep 6s; done > "$fifo" &
while :; do Network; sleep 10s; done > "$fifo" &
while :; do Spotify; sleep 5s; done > "$fifo" &

/home/patrik/.config/lemonbar/events.py &


#testinfo="%{B#4D5764}%{T4}%{+u}%{U#DDDDDD}%{O#2E343c}  %{-u}%{T-}%{B-}%{B#2E343c}%{F#717C89}%{+u}%{U#717C89}%{O#2E343c}  %{-u}%{T-}%{B-}%{F-}"

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
		ResizeMode*)
			rs="%{F#A7B1BD} binding mode %{F#EEEEEE}%{T4}RESIZE %{B-}%{F-}%{T-}"
			;;
		DefaultMode*)
			rs=""
			;;
		Spotify*)
            sp="${line:7}"
			;;
    esac
	echo "%{l} %{F#FFFFFF}$nt $testinfo $vl%{F#FFFFFF}  $sp  $rs%{c}%{F#FFFFFF}%{T4}$ws%{T-}%{F-}%{B-}%{r}%{F#FFFFFF}$bn $bt %{A:gsimplecal &:}$cl %{A}%{F-}%{B-}"
done < "$fifo" | lemonbar -f "Hack:size=10" -o -2 -f "FontAwesome:size=10" \
	-o -3 -f "Material Design Icons:size=11" -o -2 -f "Hack:size=10" -o -2 -f "Material Icons:size=13" -o -1 -u 2 -U "#FFFFFF" -B "#2E343c" -g 1920x20+0+0 | sh
    
