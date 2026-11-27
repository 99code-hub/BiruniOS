# BiruniOS test plan

## ISO validation

- ISO exists and SHA-256 checksum matches.
- ISO has a valid boot catalog and expected boot files.
- Boot in QEMU/KVM under UEFI.
- Boot in QEMU/KVM under BIOS/CSM where supported.
- Live desktop starts without falling back to a text console.

## Installation

- Install to a blank UEFI/GPT virtual disk.
- Verify partition layout and filesystem.
- Verify first boot and user creation.
- Verify bootloader entry and kernel selection.
- Confirm a second reboot succeeds.
- Test encrypted installation separately.

## Desktop

- Wayland login, logout, lock, and screen blanking.
- System Settings and Discover launch.
- Dolphin, Konsole, Firefox, Okular, and office applications launch.
- Audio input/output and Bluetooth audio.
- Wi-Fi, Ethernet, and VPN configuration.
- Display scaling, multiple monitors, touchpad, keyboard shortcuts.
- Screen reader, high contrast, and font scaling.

## System lifecycle

- Apply Fedora security updates and reboot.
- Confirm the kernel fallback is available.
- Test suspend/resume and battery behavior on laptops.
- Test storage-full and interrupted-update recovery.
- Validate backup and restore documentation.

## Performance

Compare to an unmodified Fedora 45 KDE installation on identical hardware and with identical drivers. Record warm/cold app launch, boot-to-ready, idle memory, CPU wakeups, battery runtime, and compositor latency. Do not use single synthetic numbers as proof of general speed.
