#! /bin/bash
echo "[" > /home/patrik/.cache/custom_dmenu_run
IFS=':' read -ra ADDR <<< "$CUSTOMPATH"
for i in "${ADDR[@]}"; do
    echo $i >> /home/patrik/.cache/custom_dmenu_run
done

bins=$(find /home/patrik/Programs/* -maxdepth 0 -type f && find $HOME/Programs/* -maxdepth 0 -type l)
for i in $bins; do
	echo $(basename $i) >> /home/patrik/.cache/custom_dmenu_run
done
temp=$(sort /home/patrik/.cache/custom_dmenu_run)
rm /home/patrik/.cache/custom_dmenu_run
touch /home/patrik/.cache/custom_dmenu_run
for i in $temp; do
	echo $i >> /home/patrik/.cache/custom_dmenu_run
done
