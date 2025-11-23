#!/bin/bash
#
# script for making gnome workspaces like on window managers

gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 10

# disable Super+number app switching
for i in {1..9}; do
  gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
done

# set Super+number to switch to workspace
for i in {1..9}; do
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
done

# set Super+Shift+number to move active window to workspace
for i in {1..9}; do
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Shift><Super>$i']"
done


# kill windows with super+q
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"

# alt tab switch windows not app groups
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"

gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab', '<Super>Tab']"

echo "all configured"
