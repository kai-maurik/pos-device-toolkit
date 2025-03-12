#!/bin/sh

VERSION="0.1"
HOME_DIR="/home/$USER"

echo "Starting install for POS Device Toolkit v$VERSION by kaivanmaurik.com"
#wget through github?
sudo snap install chromium
cp ./resources/db.sh "$HOME_DIR/db.sh"
sudo cp ./resources/icon.png "/usr/share/icons/kassa.png"
cp ./resources/pos.desktop "$HOME_DIR/.config/autostart/pos.desktop"
cp ./resources/pos.desktop "$HOME_DIR/Desktop/pos.desktop"
sudo cp ./resources/pos.desktop "/usr/share/applications/pos.desktop"

if [ ! -d "$HOME_DIR/.local/share/gnome-shell/extensions/" ]; then
	mkdir "$HOME_DIR/.local/share/gnome-shell/extensions/"
fi
if [ ! -d "$HOME_DIR/.local/share/gnome-shell/extensions/pdt@kaivanmaurik.com" ]; then
	sudo cp -r ./pdt@kaivanmaurik.com "$HOME_DIR/.local/share/gnome-shell/extensions/pdt@kaivanmaurik.com"
fi

echo "POS Device Toolkit install script finished!"
echo "WARNING: Changes only take effect on the next log in session."
echo "Test if the Gnome Shell extension is working by running ~/db.sh"
echo "You may need to enable the extension by running 'gnome-extensions enable pdt@kaivanmaurik.com' once. After this it will run automatically"
