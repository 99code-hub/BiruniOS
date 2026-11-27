# Known limitations of the starter repository

- The ISO build workflow has not been executed against this repository yet; the first GitHub Actions run is an integration test.
- GitHub-hosted standard runners have limited local SSD capacity. The full desktop compose may exceed available disk even when compute time is available.
- The live image build uses Lorax `--no-virt` inside a privileged disposable container. This needs careful validation on the current GitHub runner image.
- The Kickstart uses Fedora 45 package groups and package names; package solving is part of the first actual compose test.
- Anaconda's installed-system Btrfs defaults, snapshots, encryption, dual boot, and rollback have not been validated.
- The default configuration package is minimal and may need adjustment after testing on Plasma 6.8.
- The welcome app's handbook URL contains a `99code-hub` placeholder and should be updated after the canonical GitHub repository is created.
- NVIDIA proprietary drivers and third-party multimedia codecs are not included in the base image.
- ISO and RPM cryptographic signing are not implemented in this preview.

- The temporary local RPM repository used only while composing the preview ISO contains unsigned development RPMs. It is deliberately a local build input, not a public update repository. Fedora 45 requires signed RPMs by default; a stable BiruniOS repository must sign packages and metadata with a protected project key and install the corresponding public key. Never disable signature checking globally.
