# Installing BiruniOS Developer Preview

## Before you start

BiruniOS 0.1 is experimental. Back up all important data. For the first test, use a disposable virtual machine and a blank virtual disk.

## Verify the download

From the directory containing the ISO and `SHA256SUMS`:

```bash
sha256sum --check SHA256SUMS
```

## Test in QEMU/KVM

A typical test uses a UEFI-capable virtual machine with 4 CPU cores, 6–8 GB RAM, and a 40 GB disposable virtual disk. Boot the ISO and check the live desktop before attempting installation.

## Physical installation

Only test on a machine with a verified backup. Review the target disk carefully in Anaconda. Do not proceed if the destination disk or partition layout is unclear. Secure Boot, disk encryption, dual-boot, NVIDIA drivers, and Btrfs layout require additional validation in this preview.

## After installation

Check networking, audio, display scaling, KDE session type, updates, software installation, suspend/resume, and reboot. Report reproducible issues with hardware details and logs, but remove personal data and secrets first.
