#!/bin/bash

machine_hostname="arch" #hostname
root_pw="password" #root pass

#username ada dibagian bawah stlh install vga driver

# Untuk Data user
user_pw="password" #user pass

ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
hwclock --systohc
sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "KEYMAP=de_CH-latin1" >> /etc/vconsole.conf
echo "${machine_hostname}" >> /etc/hostname
echo "
127.0.0.1 localhost
::1       localhost
127.0.1.1 ${machine_hostname}.localdomain ${machine_hostname}
" >> /etc/hosts
echo root:${root_pw} | chpasswd

# xorg diinstall terpisah, sesuai wm/de yang akan dipakai nanti
# Hapus tlp package jika install didesktop atau vm

pacman -S base-devel linux-headers grub efibootmgr networkmanager network-manager-applet dialog reflector avahi wpa_supplicant mtools dosfstools xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync curl acpi acpi_call tlp virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld flatpak sof-firmware nss-mdns acpid os-prober ntfs-3g zsh python python-pip htop neofetch firefox alacritty sudo

# Uncomment GPU driver dibawah berdasarkan yang dibutuhkan (Harus salahsatu saja)
# pacman -S --noconfirm xf86-video-amdgpu
# pacman -S --noconfirm nvidia nvidia-utils nvidia-settings

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Archlinux
grub-mkconfig -o /boot/grub/grub.cfg

# user
useradd -m canqalloid
echo canqalloid:${user_pw} | chpasswd

#TODO: this is only needed for a non-vm installs
usermod -aG libvirt canqalloid
newgrp libvirt

usermod -aG wheel,audio,video,optical,storage canqalloid

echo "canqalloid ALL=(ALL) ALL" >> /etc/sudoers.d/canqalloid

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syyy

# systemd
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable tlp # beri Comment jika ga install tlp (baca diatas)
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable libvirtd
systemctl enable firewalld
systemctl enable acpid

printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"

