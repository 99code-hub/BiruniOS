# BiruniOS roadmap

This roadmap is aspirational. A milestone is complete only after its acceptance tests pass and the evidence is recorded in GitHub.

## 0.1 — Developer Preview

- [x] Repository layout, Kickstart, RPM scaffolding, and CI workflow.
- [ ] Compose a Fedora 45 x86_64 live/install ISO on GitHub Actions.
- [ ] Boot the ISO in QEMU/KVM using both UEFI and legacy boot where supported.
- [ ] Complete a clean installation on a disposable virtual disk.
- [ ] Verify KDE Plasma session, networking, audio, Discover, browser, and installer launcher.
- [ ] Publish known issues and build checksums.

## 0.2 — Desktop polish

- [ ] Complete visual identity, icon set, wallpaper variants, and login/boot branding.
- [ ] Review KDE defaults for light/dark appearance, panel layout, fonts, and scaling.
- [ ] Add accessible first-run setup and clear privacy choices.
- [ ] Add localization workflow, starting with English and Bengali translations.

## 0.3 — System tools

- [ ] Biruni System Center: hardware, storage, network, power, and troubleshooting overview.
- [ ] Biruni Update: clear update state, history, and reboot guidance.
- [ ] Biruni Recovery: documented recovery workflow and tested rescue environment.
- [ ] Add application permission explanations and a curated Flatpak source policy.

## 0.4 — Performance and hardware

- [ ] Establish reproducible Fedora KDE baseline benchmarks.
- [ ] Measure boot-to-login, idle RAM, app launch, responsiveness, battery, suspend/resume.
- [ ] Test Intel and AMD graphics, supported NVIDIA driver installation, Wi-Fi, Bluetooth, audio, and multi-monitor setups.
- [ ] Tune only measured bottlenecks; keep upstream defaults where they perform well.

## 0.5 — Beta readiness

- [ ] Signed RPM repository and signed ISO release process.
- [ ] Documented update and rollback strategy.
- [ ] Secure Boot and full-disk encryption test matrix.
- [ ] Installer partitioning defaults validated, including Btrfs subvolumes.
- [ ] Accessibility and usability review with novice users.
- [ ] Security review, SBOM, license audit, and release notes.

## 1.0 — Stable release

A stable release requires repeatable builds, tested installation/updates/recovery, signed artifacts, published support lifecycle, security response process, and a maintained package repository. No date is promised until these conditions are met.

## Later

- Optional image-based / atomic edition, after the classic RPM edition is dependable.
- Additional CPU architectures only after dedicated hardware and CI are available.
- BiruniOS developer workstation profile and optional gaming profile.
