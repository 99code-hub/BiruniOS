# BiruniOS RPM repository — release setup

The 0.1 ISO workflow creates a temporary local RPM repository under `build/repo/` so that the live image can install BiruniOS-specific packages. It is not a public update repository.

Before enabling a public repository:

1. Choose and publish the canonical repository domain.
2. Create a protected RPM signing key outside the source repository.
3. Sign all RPMs and repository metadata.
4. Publish `repomd.xml`, metadata, and packages over HTTPS.
5. Add a `birunios.repo` file with `gpgcheck=1` and `repo_gpgcheck=1`.
6. Publish and rotate the public key through a documented process.
7. Test key revocation and recovery.

Do not set `gpgcheck=0` or ship a repo file pointing at a placeholder hostname.
