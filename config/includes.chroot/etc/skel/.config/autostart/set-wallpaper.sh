#!/bin/bash
WALLPAPER="/usr/share/backgrounds/ph4ntxm.png"

# wait until XFCE has initialized displays
sleep 2

# overwrite wallpaper for every monitor/workspace
for prop in $(xfconf-query -c xfce4-desktop -l | grep last-image); do
    xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPER" --create -t string
    basepath="${prop%/last-image}"
    xfconf-query -c xfce4-desktop -p "$basepath/image-style" -s 5 --create -t int
done
