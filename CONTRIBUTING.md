# Contributing to BiruniOS

Thanks for considering a contribution. BiruniOS is experimental; small, testable changes are preferred over large unreviewed rewrites.

## Before opening a pull request

1. Open or find an issue describing the problem or proposal.
2. Keep changes focused and explain user impact.
3. Do not commit downloaded Fedora packages, generated ISO files, private credentials, signing keys, or personal data.
4. Preserve license and attribution notices.
5. Run `bash -n scripts/*.sh` and `python3 scripts/check-repo.py`.
6. For Kickstart edits, run `ksvalidator -v F45 kickstarts/birunios-live.ks` on Fedora 45.
7. For RPM changes, build and install/test the package in a disposable Fedora 45 VM.

## Pull request checklist

- [ ] The reason for the change is explained.
- [ ] Related docs are updated.
- [ ] No secrets or private signing material are included.
- [ ] Shell scripts pass syntax checks.
- [ ] Package build/install/removal is tested where relevant.
- [ ] Any hardware-specific behavior is identified and documented.
- [ ] User-facing changes are accessible and understandable.

## Design principles

- Prefer upstream Fedora, Linux, KDE, and systemd components over custom forks.
- Optimize from measurements, not assumptions.
- Keep safe defaults and make advanced controls available.
- Do not disable services or security controls just to improve a benchmark.
- Avoid telemetry by default; any future diagnostics must be opt-in and documented.
- Be explicit about unsupported hardware and known limitations.

## Code style

- Shell scripts: Bash, `set -Eeuo pipefail`, quote expansions, and handle errors.
- C++: modern C++ with Qt 6; use clear names and avoid unnecessary dependencies.
- RPM: keep payloads reproducible and list runtime/build dependencies accurately.
- Documentation: state verified behavior separately from planned behavior.
