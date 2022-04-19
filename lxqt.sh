#!/bin/bash

sudo timedatectl set-ntp true
sudo hwclock --systohc

sudo reflector -c 'United States' -a 12 --sort rate --save /etc/pacman.d/mirrorlist

#git clone https://aur.archlinux.org/pikaur.git
#cd pikaur/
#makepkg -si --noconfirm

sudo pacman -S --needed lxqt xorg xorg-server sddm xf86-video-intel chromium arc-gtk-theme arc-icon-theme papirus-icon-theme xscreensaver archlinux-wallpaper mousepad
sudo pacman -S --needed cantarell-fonts terminus-font ttf-dejavu ttf-powerline ttf-croscore noto-fonts ttf-bitstream-vera ttf-ibm-plex ttf-liberation ttf-freefont
sudo pacman -S --needed libpulse libstatgrab libsysstat lm_sensors oxygen-icons pavucontrol-qt
#sudo pacman -S -needed python python-setuptools python-pip python-wheel
#sudo pacman -S --needed php
#sudo pacman -S --needed perl perl-cgi

 
sudo systemctl enable sddm
sudo systemctl enable NetworkManager

printf "\e[1;32mDone! Type reboot\e[0m"
