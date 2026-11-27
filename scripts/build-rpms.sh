#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${BIRUNIOS_VERSION:-0.1.0}"
TOPDIR="$ROOT_DIR/build/rpmbuild"
RPM_OUT="$ROOT_DIR/build/rpms"

if [[ ! "$VERSION" =~ ^[0-9]+([.][0-9]+){1,2}([.-][A-Za-z0-9]+)*$ ]]; then
    echo "Invalid BiruniOS version: $VERSION" >&2
    exit 2
fi

for command in rpmbuild tar cp find install mkdir; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Missing required command: $command" >&2
        exit 1
    fi
done

mkdir -p \
    "$TOPDIR/BUILD" \
    "$TOPDIR/BUILDROOT" \
    "$TOPDIR/RPMS" \
    "$TOPDIR/SOURCES" \
    "$TOPDIR/SPECS" \
    "$TOPDIR/SRPMS" \
    "$RPM_OUT"

find "$TOPDIR/RPMS" -type f -name '*.rpm' -delete
find "$TOPDIR/SRPMS" -type f -name '*.src.rpm' -delete
find "$RPM_OUT" -maxdepth 1 -type f -name '*.rpm' -delete

build_payload_package() {
    local package="$1"
    local package_dir="$ROOT_DIR/packages/$package"
    local archive="$TOPDIR/SOURCES/${package}-${VERSION}.tar.gz"
    local staged="$TOPDIR/BUILD/${package}-payload"

    if [[ ! -d "$package_dir/payload" ]]; then
        echo "Missing payload directory for $package" >&2
        exit 1
    fi
    if [[ ! -f "$ROOT_DIR/LICENSE" ]]; then
        echo "Missing repository LICENSE file." >&2
        exit 1
    fi
    if [[ ! -f "$package_dir/${package}.spec" ]]; then
        echo "Missing RPM spec for $package" >&2
        exit 1
    fi

    rm -rf -- "$staged"
    mkdir -p "$staged"
    cp -a "$package_dir/payload" "$staged/"

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

echo "==> Building birunios-release"
build_payload_package birunios-release

echo "==> Building birunios-branding"
build_payload_package birunios-branding

echo "==> Building birunios-default-settings"
build_payload_package birunios-default-settings

WELCOME_DIR="$ROOT_DIR/applications/welcome"
WELCOME_SPEC="$ROOT_DIR/packages/birunios-welcome/birunios-welcome.spec"
if [[ ! -d "$WELCOME_DIR" || ! -f "$WELCOME_SPEC" ]]; then
    echo "Missing welcome application source or RPM spec." >&2
    exit 1
fi

WELCOME_ARCHIVE="$TOPDIR/SOURCES/birunios-welcome-${VERSION}.tar.gz"
tar -czf "$WELCOME_ARCHIVE" \
    --transform "s,^,birunios-welcome-${VERSION}/," \
    -C "$WELCOME_DIR" .

 echo "==> Building birunios-welcome"
rpmbuild -ba "$WELCOME_SPEC" \
    --define "_topdir $TOPDIR" \
    --define "_birunios_version $VERSION"

find "$TOPDIR/RPMS" -type f -name '*.rpm' -exec cp -f -- {} "$RPM_OUT/" \;

RPM_COUNT="$(find "$RPM_OUT" -maxdepth 1 -type f -name '*.rpm' | wc -l)"
if [[ "$RPM_COUNT" -eq 0 ]]; then
    echo "RPM build finished but no binary RPMs were found in $RPM_OUT." >&2
    exit 1
fi

if command -v createrepo_c >/dev/null 2>&1; then
    REPO_DIR="$ROOT_DIR/build/repo"
    mkdir -p "$REPO_DIR"
    find "$REPO_DIR" -maxdepth 1 -type f -name '*.rpm' -delete
    cp -f "$RPM_OUT"/*.rpm "$REPO_DIR/"
    createrepo_c --update "$REPO_DIR"
fi

printf 'RPM packages built successfully:\n'
find "$RPM_OUT" -maxdepth 1 -type f -name '*.rpm' -printf '  %f\n' | sort
