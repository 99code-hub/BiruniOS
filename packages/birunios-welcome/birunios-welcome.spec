Name:           birunios-welcome
Version:        %{_birunios_version}
Release:        1%{?dist}
Summary:        First-run welcome application for BiruniOS
License:        GPL-3.0-or-later
Source0:        %{name}-%{version}.tar.gz
BuildRequires:  cmake
BuildRequires:  gcc-c++
BuildRequires:  make
BuildRequires:  qt6-qtbase-devel
Requires:       qt6-qtbase-gui

%description
A small native Qt 6 welcome application with shortcuts to KDE System Settings,
Discover, and the BiruniOS documentation.

%prep
%setup -q -n %{name}-%{version}

%build
%cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%{_prefix} -DBIRUNIOS_VERSION=%{version}
%cmake_build

%install
%cmake_install

%files
%{_bindir}/birunios-welcome
%{_datadir}/applications/birunios-welcome.desktop
%{_datadir}/icons/hicolor/scalable/apps/birunios-welcome.svg

%changelog
* Sat Nov 28 2026 BiruniOS contributors - 0.1.0-1
- Initial Qt 6 welcome application.
