#!/bin/sh

# script for gnome wallpaper slideshow


dir="/home/${USER}/Pictures/wallpapers"


while true ; do
    for file in "$dir"/* ; do
        if [ -d "$file" ] ;then
            continue
        fi
        #echo "$file"

        gsettings set org.gnome.desktop.background picture-uri "file://$file"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$file"
        sleep 10

    done
done
