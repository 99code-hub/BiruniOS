# Kernel policy

BiruniOS 0.1 uses the signed, Fedora-maintained Linux kernel and Fedora kernel packages. There is no custom kernel fork or scheduler patch set in this repository.

Future kernel customization requires:

- a documented reason and benchmark showing a real benefit;
- review of Fedora kernel config and security options;
- reproducible build inputs and package signing;
- Secure Boot/module-signing strategy;
- fallback kernel and recovery tests;
- support coverage for Intel and AMD CPUs and supported GPUs.

Do not disable mitigations, SELinux, signature verification, or other security features to obtain benchmark gains.
