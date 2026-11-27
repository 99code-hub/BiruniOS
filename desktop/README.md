# KDE Plasma desktop integration

BiruniOS uses upstream KDE Plasma. Current defaults are packaged by `birunios-default-settings`; original project art is packaged by `birunios-branding`.

Do not copy arbitrary Plasma configuration into user home directories at runtime. Prefer documented `/etc/xdg` defaults and allow users to override them. Test Wayland, scaling, multiple monitors, accessibility, touchpads, and both light/dark modes.
