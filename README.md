# BiruniOS

**Fast. Elegant. Open.**

BiruniOS is an early-stage, Fedora-based Linux desktop distribution project. Its initial target is an x86-64 live/install image built around the Fedora Linux 45 package base and KDE Plasma 6.8.

> **Status: Developer Preview / experimental.** This repository is a reproducible starting point, not a production-ready operating system. The first ISO must be built, booted, installed, upgraded, and tested on physical hardware before anyone should rely on it for daily use or important data.

## Project decisions

| Area | Initial decision |
|---|---|
| Base | Fedora Linux 45 |
| Architecture | x86_64 (AMD64) |
| Desktop | KDE Plasma, Wayland-first |
| Kernel | Fedora-maintained Linux kernel; no kernel fork in 0.1 |
| Init | systemd |
| Audio | PipeWire / WirePlumber |
| Native packages | RPM / DNF5 |
| Additional desktop apps | Flatpak; Flathub is added as an optional software source |
| Installer/image builder | Anaconda + Lorax `livemedia-creator` |
| Initial filesystem policy | Btrfs is the target for installed systems; installer defaults still require end-to-end validation |
| Build platform | GitHub Actions, with a local Docker-compatible build path |

## What is in this repository

- A self-contained Fedora 45 Kickstart for the BiruniOS live image.
- A Fedora 45 build container definition.
- RPM specs and payloads for BiruniOS release identity, artwork, KDE defaults, and a small Qt 6 welcome application.
- Scripts to build RPMs, create a local RPM repository, compose an ISO, and validate outputs.
- GitHub Actions workflows for repository checks, RPM builds, and manually requested ISO builds / tagged releases.
- Project, contributor, security, and testing documentation.

## Build on GitHub

1. Create an empty public GitHub repository named `birunios` under `99code-hub`.
2. Extract this repository archive locally, or upload its contents to the new repository.
3. Commit and push the files to the default branch.
4. Open **Actions** and enable workflows if GitHub asks.
5. Run **BiruniOS ISO** from the Actions tab using **Run workflow**.
6. Download the `BiruniOS-ISO-*` artifact from the completed workflow run.

The ISO workflow uses a privileged Fedora build container because Lorax/Anaconda image composition needs low-level mount and filesystem operations. The container is confined to the disposable GitHub-hosted runner. Do not copy this privileged build pattern to a shared production server without isolation and review.

### Git commands

```bash
git init -b main
git add .
git commit -m "Initial BiruniOS 0.1 repository"
git remote add origin https://github.com/99code-hub/birunios.git
git push -u origin main
```

Replace `99code-hub` with your GitHub username or organization.

## Build locally on a Linux computer

Requirements: Docker or Podman, Git, and enough free disk space. ISO composition is disk-intensive; plan for at least 25 GB free for a local build. The GitHub-hosted standard runner has less disk space, so cloud composition can fail if the runner runs out of storage.

```bash
./scripts/build-local.sh
```

The generated ISO and checksum are placed in `build/out/`.

## Build RPM packages only

On Fedora 45:

```bash
sudo dnf install -y rpm-build cmake gcc-c++ make qt6-qtbase-devel createrepo_c
./scripts/build-rpms.sh
```

RPMs are written to `build/rpms/`; a DNF repository is written to `build/repo/`.

## Validate source and Kickstart

```bash
bash -n scripts/*.sh
python3 scripts/check-repo.py
```

On Fedora 45, install `pykickstart` and run:

```bash
ksvalidator -v F45 kickstarts/birunios-live.ks
```

## Triggering builds

- `Validate`: runs on pushes and pull requests.
- `Build RPM packages`: builds the project's RPMs and uploads them as an Actions artifact.
- `BiruniOS ISO`: manual build from the Actions tab; also runs for version tags such as `v0.1.0`.
- A tag build publishes an ISO release only after the ISO job completes successfully. ISO files larger than 1,800 MiB are split into numbered chunks because GitHub Release assets have a per-file size limit; use `scripts/join-iso-parts.sh` or the instructions in `REASSEMBLE.txt` to reconstruct the ISO.

## Important build notes

1. The image build tracks Fedora 45. A future Fedora release must be adopted deliberately by updating the `FEDORA_RELEASE` setting, the Fedora container image, the Kickstart source URL, and the validation matrix together.
2. Do not blindly use `dnf system-upgrade` to move a custom distribution between Fedora releases. Define and test a supported upgrade path first.
3. The first build uses the Fedora-maintained kernel and upstream KDE packages. It does not introduce a custom kernel or replace systemd, DNF, Anaconda, or KDE.
4. RPM package signing and ISO signing are not enabled in this starter repository. Before public stable releases, configure protected signing keys and repository metadata signing. Never commit private keys or passwords.
5. The ISO workflow's automated checks validate the image artifact and metadata. They do not prove that the desktop works on every physical device. Test the ISO in QEMU/KVM and on representative Intel/AMD/NVIDIA hardware.
6. The installer storage profile, Secure Boot behavior, NVIDIA driver path, firmware updates, and full upgrade/rollback story require additional release testing.

## Fedora relationship and trademarks

BiruniOS is an independent downstream project. It is not an official Fedora product. Follow Fedora trademark guidelines, preserve upstream notices, and use original BiruniOS branding. Package licenses and attribution must be reviewed before redistribution.

## Project links

- Source: `https://github.com/99code-hub/birunios`
- Issues: use the repository's GitHub Issues page.
- Security: see [SECURITY.md](SECURITY.md).
- Roadmap: see [ROADMAP.md](ROADMAP.md).

## License

The original source code and build scripts in this repository are licensed under GPL-3.0-or-later unless a file says otherwise. Each included upstream component retains its own license. The BiruniOS artwork in `branding/` is original project artwork and is provided under the same license in this starter repository.
