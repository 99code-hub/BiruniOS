# Release process

1. Update package versions and release notes.
2. Build RPMs and ISO from a clean commit.
3. Validate Kickstart and repository metadata.
4. Test ISO boot/install/upgrade on disposable VMs.
5. Test representative physical hardware.
6. Generate SHA-256 checksums and a software bill of materials.
7. Sign RPMs, repository metadata, and ISO using protected signing keys.
8. Publish a GitHub Release with ISO, checksums, signatures, build info, and known issues.
9. Retain build logs and source commit information.

The current starter workflow generates checksums but does not sign them. Do not call a release stable until signing and all release gates are implemented.
