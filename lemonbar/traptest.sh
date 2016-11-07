#!/usr/bin/bash

trap 'echo "hi"' 36

while :
do
    echo "yo" && sleep 3
done
