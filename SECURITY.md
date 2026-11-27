# Security policy

BiruniOS is an experimental project. Do not use developer-preview images for sensitive work or as the only copy of important data.

## Reporting a vulnerability

Please do not publish exploit details in a public issue. Use GitHub's **Report a vulnerability** feature (Security tab) when it is enabled for this repository. If private vulnerability reporting is unavailable, contact the maintainers through a private channel listed in the repository profile and request a secure reporting route.

Include:

- affected BiruniOS version / commit;
- affected package and version;
- reproduction steps and impact;
- any mitigation already identified.

Do not include real user data, passwords, private keys, or tokens.

## Security commitments before stable release

- SELinux enforcing by default where supported;
- firewalld enabled with a minimal default policy;
- signed packages and repository metadata;
- verifiable ISO checksums and signed release manifests;
- protected release-signing keys outside GitHub source code;
- documented security update policy and advisories;
- minimal enabled services and no mandatory telemetry;
- review of third-party repositories and Flatpak permissions.

## Disclosure

The maintainers will acknowledge reports, assess severity, coordinate a fix, and publish an advisory after a fix is available. Response times are not guaranteed while the project is experimental.
