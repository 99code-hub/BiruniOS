#version=F45
# BiruniOS 0.1 x86_64 live/install image.
# This Kickstart is for composing the live medium with Lorax livemedia-creator.
# The partition directives below apply to the temporary compose target, not to
# a user's existing disk. Always review installer storage choices before install.

lang en_US.UTF-8
keyboard --vckeymap=us --xlayouts='us'
timezone Etc/UTC --utc
rootpw --lock
selinux --enforcing
firewall --enabled --service=mdns
network --bootproto=dhcp --device=link --activate
bootloader --location=none
clearpart --all --initlabel
reqpart
part / --fstype=btrfs --size=10240

url --url="https://dl.fedoraproject.org/pub/fedora/linux/releases/45/Everything/x86_64/os/"
repo --name="updates"
repo --name="birunios-local" --baseurl="file:///workspace/build/repo" --cost=1

services --enabled="NetworkManager,livesys,livesys-late,firewalld" --disabled="sshd"
shutdown

%packages
@^kde-desktop-environment
@hardware-support

# Anaconda live-install support and live boot
anaconda
anaconda-install-env-deps
anaconda-live
anaconda-tui
dracut-config-generic
dracut-live
dracut-network
tar
kernel
kernel-modules
kernel-modules-extra
livesys-scripts

# BiruniOS packages built by scripts/build-rpms.sh
birunios-release
birunios-branding
birunios-default-settings
birunios-welcome

# Core desktop applications
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

# Productivity and hardware support
libreoffice-writer
libreoffice-calc
libreoffice-impress
flatpak
NetworkManager-wifi
NetworkManager-bluetooth
bluez
pipewire
pipewire-pulseaudio
wireplumber
fwupd
btrfs-progs
firewalld

# Basic utilities
curl
wget
git

# Keep the image focused; applications can be installed later.
-gnome-boxes
-gnome-software
%end

%post --erroronfail --log=/root/birunios-kickstart-post.log
set -e
systemctl enable NetworkManager.service || true
systemctl enable firewalld.service || true

# Make Flathub available as an optional source in Discover. This does not
# automatically install third-party applications.
if command -v flatpak >/dev/null 2>&1; then
    flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
fi

# Keep a human-readable release marker even if a later Fedora package update
# changes the upstream os-release file.
install -d -m 0755 /usr/share/birunios
cp -f /usr/share/birunios-release/release /usr/share/birunios/release
%end
