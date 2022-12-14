#!/bin/bash

set -e
set -x

if [ -e /dev/vda ]; then
  device=/dev/vda
elif [ -e /dev/sda ]; then
  device=/dev/sda
else
  echo "ERROR: There is no disk available for installation" >&2
  exit 1
fi
export device

memory_size_in_kilobytes=$(free | awk '/^Mem:/ { print $2 }')
swap_size_in_kilobytes=$((memory_size_in_kilobytes * 2))
sfdisk "$device" <<EOF
label: dos
size=${swap_size_in_kilobytes}KiB, type=82
                                   type=83, bootable
EOF
mkswap "${device}1"
mkfs.ext4 "${device}2"
mount "${device}2" /mnt

# Get some US mirrors just to install reflector, which will rank the mirrors
# by speed before intalling the rest of the packages
curl -fsS "https://archlinux.org/mirrorlist/?country=GB" -o /tmp/mirrorlist
grep '^#Server' /tmp/mirrorlist | sort -R | head -n 50 | sed 's/^#//' > /etc/pacman.d/mirrorlist
pacman -Sy --noconfirm
pacman -S reflector --noconfirm
reflector --verbose --country GB --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

# Install base packages, just enough for a basic system
pacman -Sy --noconfirm
pacstrap /mnt base base-devel linux-lts grub openssh sudo qemu-guest-agent terminus-font
swapon "${device}1"
genfstab -U /mnt >> /mnt/etc/fstab
swapoff "${device}1"

arch-chroot /mnt /bin/bash