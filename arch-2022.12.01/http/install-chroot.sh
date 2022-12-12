#!/bin/bash

set -e
set -x

ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

hwclock --systohc

echo "archlinux" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.local.mossmanphotography.co.uk arch" >> /etc/hosts

echo "FONT=ter-118n" >> /etc/vconsole.conf

sed -i -e 's/^#\(en_GB.UTF-8\)/\1/' /etc/locale.gen
locale-gen
echo 'LANG=en_GB.UTF-8' > /etc/locale.conf

mkinitcpio -P

echo -e 'piranha\npiranha' | passwd
useradd -m -U dev
echo -e 'piranha\npiranha' | passwd dev
cat <<EOF > /etc/sudoers.d/dev
Defaults:dev !requiretty
dev ALL=(ALL) NOPASSWD: ALL
EOF
chmod 440 /etc/sudoers.d/dev

mkdir -p /etc/systemd/network
ln -sf /dev/null /etc/systemd/network/99-default.link

pacman -S --noconfirm reflector networkmanager cloud-init gvfs gvfs-smb nfs-utils inetutils dnsutils bash-completion rsync dnsmasq openbsd-netcat firewalld os-prober

systemctl enable NetworkManager
systemctl enable reflector.timer
systemctl enable firewalld
systemctl enable sshd

grub-install --target=i386-pc "$device"
sed -i -e 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=1/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg