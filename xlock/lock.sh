#!/bin/bash
TMPBG=/tmp/screen.png
AVGPX=/tmp/average.txt

scrot /tmp/screen.png

convert $TMPBG -scale 10% -scale 1000% $TMPBG

convert  $TMPBG -resize 1x1  $AVGPX
lineout=$(awk '/#/{i++}i==2' $AVGPX)
index=`expr index "$lineout" "#"`
rgb=${lineout:$index:6}
red=$((16#${rgb:0:2}))
green=$((16#${rgb:2:2}))
blue=$((16#${rgb:4:2}))
brightness=$(python -c "print(round(float('$red')*0.3+float('$green')*0.59+float('$blue')*0.11))")
if [ $brightness -gt 100 ]
then
	ICON=$HOME/.xlock/iconblack.png
	color=11111188
else
	ICON=$HOME/.xlock/iconwhite.png
	color=EEEEEE44
	vercolor=FFFFFF99
fi

convert $TMPBG $ICON -gravity center -composite -matte $TMPBG
#i3lock --insidevercolor=ff000000 --insidewrongcolor=ff000000 --insidecolor=ff000000 --ringvercolor=ff000000 --ringwrongcolor=ff000000 --ringcolor=$color --linecolor=$color --textcolor=ff000000 --keyhlcolor=$vercolor --bshlcolor=ffff00ff -i $TMPBG 
i3lock -u -i $TMPBG
#-matte before composite
