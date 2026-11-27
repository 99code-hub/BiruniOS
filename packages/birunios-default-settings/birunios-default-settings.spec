Name:           birunios-default-settings
Version:        %{_birunios_version}
Release:        1%{?dist}
Summary:        Default KDE Plasma configuration for BiruniOS
License:        GPL-3.0-or-later
BuildArch:      noarch
Source0:        %{name}-%{version}.tar.gz
Requires:       plasma-workspace

%description
Conservative KDE defaults for the BiruniOS developer preview. Users remain
free to customize Plasma, themes, panels, widgets, and applications.

%prep
%setup -q -n payload

%build

%install
mkdir -p %{buildroot}
cp -a . %{buildroot}/

%files
/etc/xdg/kdeglobals
/etc/skel/.config/kdeglobals
/usr/share/licenses/birunios-default-settings/LICENSE

%changelog
* Sat Nov 28 2026 BiruniOS contributors - 0.1.0-1
- Add initial KDE appearance defaults.
