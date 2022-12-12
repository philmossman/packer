#!/bin/bash

set -e
set -x

# Basic tooling
sudo pacman -S --noconfirm vim git wget ranger

# Install trizen (AUR helper)
mkdir -p /home/dev/git && cd $_
git clone https://aur.archlinux.org/yay-git.git
cd yay-git
makepkg --noconfirm -si

# install terminal toys
yay -S --noconfirm neofetch htop