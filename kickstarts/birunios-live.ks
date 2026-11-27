
#version=F45

# ============================================================
# BiruniOS 0.1 - Fedora 45 KDE Live / Install Image
# Architecture: x86_64
# Boot support: Legacy BIOS + UEFI
# ============================================================

lang en_US.UTF-8
keyboard --vckeymap=us --xlayouts='us'
timezone Etc/UTC --utc

rootpw --lock

selinux --enforcing
firewall --enabled --service=mdns

network --bootproto=dhcp --device=link --activate

# This is a temporary image used by Lorax.
# Lorax generates the actual BIOS and UEFI boot media.
bootloader --location=none

clearpart --all --initlabel
reqpart
part / --fstype=btrfs --size=10240

# ============================================================
# Fedora 45 repositories
# ============================================================

url --url="https://dl.fedoraproject.org/pub/fedora/linux/releases/45/Everything/x86_64/os/"

repo --name="updates"

repo --name="birunios-local" \
     --baseurl="file:///workspace/build/repo" \
     --cost=1

# ============================================================
# System services
# ============================================================

services --enabled="NetworkManager,livesys,livesys-late,firewalld" --disabled="sshd"

shutdown

# ============================================================
# Package selection
# ============================================================

%packages

# ------------------------------------------------------------
# KDE Plasma desktop
# ------------------------------------------------------------

@^kde-desktop-environment
@hardware-support

# ------------------------------------------------------------
# Anaconda installer and live environment
# ------------------------------------------------------------

anaconda
anaconda-install-env-deps
anaconda-live
anaconda-tui

dracut-config-generic
dracut-live
dracut-network

livesys-scripts

kernel
kernel-modules
kernel-modules-extra

tar

# ------------------------------------------------------------
# Legacy BIOS boot support
# Required by Lorax x86.tmpl.
# ------------------------------------------------------------

grub2-pc-modules

# ------------------------------------------------------------
# UEFI x86_64 boot support
# Required by Lorax efi.tmpl.
# ------------------------------------------------------------

grub2-efi-x64
grub2-efi-x64-cdboot
grub2-efi-x64-modules
shim-x64

# ------------------------------------------------------------
# BiruniOS custom packages
# ------------------------------------------------------------

birunios-release
birunios-branding
birunios-default-settings
birunios-welcome

# ------------------------------------------------------------
# Core KDE applications
# ------------------------------------------------------------

firefox

plasma-discover
plasma-discover-flatpak
plasma-systemmonitor

systemsettings
dolphin
konsole
kate

okular
ark
gwenview
spectacle
kcalc

# ------------------------------------------------------------
# Productivity applications
# ------------------------------------------------------------

libreoffice-writer
libreoffice-calc
libreoffice-impress

# ------------------------------------------------------------
# Networking and hardware support
# ------------------------------------------------------------

NetworkManager-wifi
NetworkManager-bluetooth

bluez

fwupd
btrfs-progs
firewalld

# ------------------------------------------------------------
# Audio
# ------------------------------------------------------------

pipewire
pipewire-pulseaudio
wireplumber

# ------------------------------------------------------------
# Application management
# ------------------------------------------------------------

flatpak

# ------------------------------------------------------------
# Basic utilities
# ------------------------------------------------------------

curl
wget
git

# ------------------------------------------------------------
# Exclusions
# ------------------------------------------------------------

-gnome-boxes
-gnome-software

%end

# ============================================================
# BiruniOS post-install configuration
# ============================================================

%post --erroronfail --log=/root/birunios-kickstart-post.log

set -e

# ------------------------------------------------------------
# Enable essential services
# ------------------------------------------------------------

systemctl enable NetworkManager.service || true
systemctl enable firewalld.service || true

# ------------------------------------------------------------
# Configure optional Flathub repository
# ------------------------------------------------------------

if command -v flatpak >/dev/null 2>&1; then
    flatpak remote-add \
        --system \
        --if-not-exists \
        flathub \
        https://flathub.org/repo/flathub.flatpakrepo || true
fi

# ------------------------------------------------------------
# Create BiruniOS release information
# ------------------------------------------------------------

install -d -m 0755 /usr/share/birunios

cp -f \
    /usr/share/birunios-release/release \
    /usr/share/birunios/release

# ------------------------------------------------------------
# Verify BIOS GRUB assets required by Lorax
# ------------------------------------------------------------

test -s /usr/lib/grub/i386-pc/moddep.lst
test -s /usr/lib/grub/i386-pc/iso9660.mod
test -s /usr/lib/grub/i386-pc/biosdisk.mod
test -s /usr/lib/grub/i386-pc/boot_hybrid.img

# ------------------------------------------------------------
# Verify UEFI boot assets required by Lorax
# ------------------------------------------------------------

test -s /boot/efi/EFI/fedora/gcdx64.efi
test -s /boot/efi/EFI/fedora/shimx64.efi
test -s /boot/efi/EFI/fedora/mmx64.efi

# ------------------------------------------------------------
# Verify GRUB EFI modules and fonts
# ------------------------------------------------------------

test -s /usr/lib/grub/x86_64-efi/moddep.lst
test -s /usr/share/grub/unicode.pf2

echo "BiruniOS BIOS and UEFI boot assets verified successfully."

%end
