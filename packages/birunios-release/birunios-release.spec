Name:           birunios-release
Version:        %{_birunios_version}
Release:        1%{?dist}
Summary:        Release identity for the BiruniOS Linux distribution
License:        GPL-3.0-or-later
BuildArch:      noarch
Source0:        %{name}-%{version}.tar.gz

%description
Release identity and operating-system identification metadata for BiruniOS.
The package retains Fedora's underlying package base and does not replace
Fedora's RPM database release provider.

%prep
%setup -q -n payload

%build

%install
mkdir -p %{buildroot}
cp -a . %{buildroot}/

%posttrans
if [ -f /usr/share/birunios-release/os-release ]; then
    tmpfile="$(mktemp /etc/os-release.XXXXXX)"
    install -m 0644 /usr/share/birunios-release/os-release "$tmpfile"
    mv -f "$tmpfile" /etc/os-release
fi

%files
%dir /usr/share/birunios-release
/usr/share/birunios-release/os-release
/usr/share/birunios-release/release
/usr/share/licenses/birunios-release/LICENSE

%changelog
* Sat Nov 28 2026 BiruniOS contributors - 0.1.0-1
- Initial developer preview release identity.
