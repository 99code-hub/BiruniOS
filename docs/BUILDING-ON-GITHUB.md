# Building BiruniOS with GitHub Actions

## Repository setup

Create an empty GitHub repository named `birunios`, push this source tree, and enable Actions. Keep the repository public if you want to use GitHub's standard public-repository hosted runner allowance. Private repositories are subject to the plan's included minutes/storage and overage rules.

## Start a build

1. Open the repository's **Actions** tab.
2. Select **BiruniOS ISO**.
3. Choose **Run workflow**.
4. Leave the version at `0.1.0` for the first preview, or enter a new version string.
5. Open the run when it finishes and download the `BiruniOS-ISO-*` artifact.

The build job creates a short-lived Fedora 45 container, installs Lorax/Anaconda and RPM build dependencies, builds the BiruniOS RPM packages, creates a local repository for the compose, validates the Kickstart, and calls `livemedia-creator --no-virt --make-iso`.

## Disk and isolation limits

The standard GitHub-hosted Linux runner currently provides 4 vCPUs, 16 GB RAM, and 14 GB SSD. The workflow removes selected preinstalled tools to free disk space, but an entire KDE image compose is storage-intensive and may exceed the remaining capacity. A disk-space failure does not mean the Kickstart or packages are invalid. Use a larger runner if available, or a self-hosted runner / disposable Fedora VM with at least 25 GB free disk.

The ISO composition container runs with elevated privileges because Anaconda/Lorax image composition needs mount and loop-device operations. The GitHub runner is a disposable VM. Do not run this privileged build container on a shared or important host. For local testing, use a disposable VM with no valuable disks attached.

## Release tags

Pushing a tag such as `v0.1.0` triggers an ISO build and publishes a prerelease after successful composition. GitHub release assets have a per-file size limit, so ISO images larger than 1,800 MiB are split into chunks. Download every `.part-###` file and run:

```bash
cat BiruniOS-0.1.0-x86_64.iso.part-* > BiruniOS-0.1.0-x86_64.iso
sha256sum --check SHA256SUMS
```

Never boot a part file. Verify the reconstructed ISO checksum before use.

## What CI does not prove

A successful build means that image composition completed; it does not prove that the image boots on all hardware, installs safely, supports all GPUs, survives upgrades, or has acceptable battery life. Follow `docs/TESTING.md` before announcing a release.
