Name:           birunios-branding
Version:        %{_birunios_version}
Release:        1%{?dist}
Summary:        Logos, icons, and wallpapers for BiruniOS
License:        GPL-3.0-or-later
BuildArch:      noarch
Source0:        %{name}-%{version}.tar.gz

%description
Original BiruniOS project artwork, application icons, and default wallpaper.

%prep
%setup -q -n payload

%build

%install
mkdir -p %{buildroot}
cp -a . %{buildroot}/

%files
/usr/share/pixmaps/birunios.svg
/usr/share/icons/hicolor/scalable/apps/birunios.svg
/usr/share/backgrounds/birunios/birunios-default.svg
/usr/share/licenses/birunios-branding/LICENSE

%changelog
* Sat Nov 28 2026 BiruniOS contributors - 0.1.0-1
- Initial BiruniOS artwork package.
