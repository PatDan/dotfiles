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
	ICON=$HOME/.xlock/keyblack.png
	ringcol=000000B2
	vercolor=FFFFFFB2
else
	ICON=$HOME/.xlock/keywhite.png
	ringcol=FFFFFFB2
	vercolor=000000B2
fi

wrongcolor=888888B2
rightcolor=888888B2
hide=00000000
backslash=888888FF
# backslash=FFFF88B2

convert $TMPBG $ICON -gravity center -composite -matte $TMPBG


i3lock --insidevercolor=$hide --insidewrongcolor=$hide --insidecolor=$hide \
		--ringvercolor=$rightcolor --ringwrongcolor=$wrongcolor --ringcolor=$ringcol \
		--linecolor=$hide --textcolor=$hide --keyhlcolor=$vercolor \
		--bshlcolor=$backslash -i $TMPBG 

#i3lock -u -i $TMPBG
