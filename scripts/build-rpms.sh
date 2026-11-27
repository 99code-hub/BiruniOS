#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${BIRUNIOS_VERSION:-0.1.0}"
if [[ ! "$VERSION" =~ ^[0-9]+([.][0-9]+){1,2}([.-][A-Za-z0-9]+)*$ ]]; then
    echo "Invalid BiruniOS version: $VERSION" >&2
    exit 2
fi
TOPDIR="${ROOT_DIR}/build/rpmbuild"
RPM_OUT="${ROOT_DIR}/build/rpms"

for command in rpmbuild tar; do
    command -v "$command" >/dev/null 2>&1 || {
        echo "Missing required command: $command" >&2
        exit 1
    }
done

mkdir -p "$TOPDIR"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} "$RPM_OUT"
rm -f "$TOPDIR"/RPMS/*/*.rpm "$TOPDIR"/SRPMS/*.src.rpm

build_payload_package() {
    local package="$1"
    local package_dir="$ROOT_DIR/packages/$package"
    local archive="$TOPDIR/SOURCES/${package}-${VERSION}.tar.gz"
    local staged="$TOPDIR/BUILD/${package}-payload"

    [[ -d "$package_dir/payload" ]] || {
        echo "Missing payload directory for $package" >&2
        exit 1
    }
    rm -rf "$staged"
    mkdir -p "$staged"
    cp -a "$package_dir/payload" "$staged/"
    # Keep one canonical license in source control and stage it into each RPM.
    install -D -m 0644 "$ROOT_DIR/LICENSE" \
        "$staged/payload/usr/share/licenses/$package/LICENSE"
    if [[ "$package" == "birunios-release" ]]; then
        find "$staged/payload" -type f -exec sed -i "s/@BIRUNIOS_VERSION@/$VERSION/g" {} +
    fi
    tar -czf "$archive" -C "$staged" payload
    rpmbuild -ba "$package_dir/${package}.spec" \
        --define "_topdir $TOPDIR" \
        --define "_birunios_version $VERSION"
}

build_payload_package birunios-release
build_payload_package birunios-branding
build_payload_package birunios-default-settings

# The welcome application uses a normal CMake source archive.
WELCOME_ARCHIVE="$TOPDIR/SOURCES/birunios-welcome-${VERSION}.tar.gz"
tar -czf "$WELCOME_ARCHIVE" \
    --transform "s,^,birunios-welcome-${VERSION}/," \
    -C "$ROOT_DIR/applications/welcome" .
rpmbuild -ba "$ROOT_DIR/packages/birunios-welcome/birunios-welcome.spec" \
    --define "_topdir $TOPDIR" \
    --define "_birunios_version $VERSION"

find "$TOPDIR/RPMS" -type f -name '*.rpm' -exec cp -f {} "$RPM_OUT/" \;

if command -v createrepo_c >/dev/null 2>&1; then
    mkdir -p "$ROOT_DIR/build/repo"
    cp -f "$RPM_OUT"/*.rpm "$ROOT_DIR/build/repo/"
    createrepo_c --update "$ROOT_DIR/build/repo"
fi

printf 'RPM packages built successfully:\n'
find "$RPM_OUT" -maxdepth 1 -type f -name '*.rpm' -printf '  %f\n' | sort
