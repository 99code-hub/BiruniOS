#!/bin/bash
set -e

sudo apt-get update
sudo apt-get install -y debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools debian-archive-keyring

mkdir -p work/{chroot,image/{live,boot/grub}}
sudo debootstrap --arch=amd64 bookworm work/chroot http://deb.debian.org/debian

sudo mount --bind /dev work/chroot/dev
sudo mount --bind /run work/chroot/run
sudo chroot work/chroot /bin/bash -c "mount -t proc none /proc && mount -t sysfs none /sys && mount -t devpts none /dev/pts"

cat << 'CHROOT_EOF' > work/chroot/setup.sh
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "birunios" > /etc/hostname
cat <<OS_EOF > /etc/os-release
PRETTY_NAME="BiruniOS 1.0"
NAME="BiruniOS"
VERSION_ID="1.0"
VERSION="1.0"
ID=birunios
ID_LIKE=debian
OS_EOF

apt-get update
apt-get install -y --no-install-recommends \
    linux-image-amd64 live-boot systemd-sysv \
    kde-plasma-desktop sddm konsole dolphin \
    network-manager plasma-nm firefox-esr sudo curl nano \
    zram-tools firmware-linux-free

useradd -m -s /bin/bash -G sudo biruni
echo "biruni:biruni" | chpasswd
echo "root:root" | chpasswd

systemctl enable sddm
systemctl enable NetworkManager

echo -e "ALGO=zstd\nPERCENT=50" > /etc/default/zramswap
cat <<SYS_EOF >> /etc/sysctl.conf
vm.swappiness=10
vm.vfs_cache_pressure=50
SYS_EOF

apt-get clean
rm -rf /tmp/* ~/.bash_history /var/lib/apt/lists/*
CHROOT_EOF

chmod +x work/chroot/setup.sh
sudo chroot work/chroot /setup.sh
rm work/chroot/setup.sh

sudo umount work/chroot/dev/pts || true
sudo umount work/chroot/dev || true
sudo umount work/chroot/proc || true
sudo umount work/chroot/sys || true
sudo umount work/chroot/run || true

sudo cp work/chroot/boot/vmlinuz-* work/image/live/vmlinuz
sudo cp work/chroot/boot/initrd.img-* work/image/live/initrd

sudo mksquashfs work/chroot work/image/live/filesystem.squashfs -comp zstd -e boot

cat << 'GRUB_EOF' > work/image/boot/grub/grub.cfg
set default="0"
set timeout=3

menuentry "Start BiruniOS 1.0 (Ultra-Fast Live Mode)" {
    linux /live/vmlinuz boot=live quiet splash
    initrd /live/initrd
}
GRUB_EOF

grub-mkrescue -o BiruniOS-1.0-amd64.iso work/image
