# System configuration policy

This directory is reserved for reviewed defaults. The current 0.1 defaults are delivered through RPM packages and the live Kickstart.

Do not disable systemd units just because they appear in `systemd-analyze blame`. Measure whether a service is actually on the critical boot path, confirm what depends on it, and test upgrades and hardware behavior before changing service policy.
