
#!/usr/bin/env bash
set -Eeuo pipefail

# ============================================================
# BiruniOS ISO Builder
# Fedora 45 | KDE Plasma | x86_64
# ============================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BUILD_DIR="$ROOT_DIR/build"
RESULT_DIR="$BUILD_DIR/lmc-results"
OUT_DIR="$BUILD_DIR/out"
LOG_DIR="$BUILD_DIR/logs"
RPM_DIR="$BUILD_DIR/rpms"

VERSION="${BIRUNIOS_VERSION:-0.1.0}"
FEDORA_RELEASE="${FEDORA_RELEASE:-45}"
MIN_FREE_KB="${BIRUNIOS_MIN_FREE_KB:-15728640}"

ISO_NAME="BiruniOS-${VERSION}-x86_64.iso"

# ============================================================
# Error reporting
# ============================================================

on_error() {
    local status=$?
    echo >&2
    echo "============================================================" >&2
    echo "BiruniOS build FAILED (exit code: ${status})" >&2
    echo "============================================================" >&2
    echo "Last command: ${BASH_COMMAND}" >&2
    echo "Build logs: $LOG_DIR" >&2
    echo "RPM output: $RPM_DIR" >&2
    echo "Lorax results: $RESULT_DIR" >&2
    exit "$status"
}

trap on_error ERR

# ============================================================
# Validate configuration
# ============================================================

if [[ ! "$VERSION" =~ ^[0-9]+([.][0-9]+){1,2}([.-][A-Za-z0-9]+)*$ ]]; then
    echo "Invalid BiruniOS version: $VERSION" >&2
    exit 2
fi

if [[ ! "$MIN_FREE_KB" =~ ^[0-9]+$ ]]; then
    echo "Invalid BIRUNIOS_MIN_FREE_KB value: $MIN_FREE_KB" >&2
    exit 2
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "Run this script as root inside the disposable Fedora build container." >&2
    exit 1
fi

if [[ "$FEDORA_RELEASE" != "45" ]]; then
    echo "This repository is pinned to Fedora 45." >&2
    echo "Update and test all release references before changing FEDORA_RELEASE." >&2
    exit 2
fi

# ============================================================
# Check build dependencies
# ============================================================

REQUIRED_COMMANDS=(
    livemedia-creator
    ksvalidator
    createrepo_c
    rpmbuild
    bash
    tar
    find
    cp
    rm
    mkdir
    tee
    df
    awk
    sha256sum
    date
    install
)

echo "==> Checking build dependencies"

for command in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Missing build dependency: $command" >&2
        exit 1
    fi
done

# ============================================================
# Check source files
# ============================================================

REQUIRED_FILES=(
    "$ROOT_DIR/kickstarts/birunios-live.ks"
    "$ROOT_DIR/scripts/build-rpms.sh"
    "$ROOT_DIR/packages/birunios-release/birunios-release.spec"
    "$ROOT_DIR/packages/birunios-branding/birunios-branding.spec"
    "$ROOT_DIR/packages/birunios-default-settings/birunios-default-settings.spec"
    "$ROOT_DIR/packages/birunios-welcome/birunios-welcome.spec"
    "$ROOT_DIR/applications/welcome/CMakeLists.txt"
    "$ROOT_DIR/applications/welcome/src/main.cpp"
    "$ROOT_DIR/LICENSE"
)

echo "==> Checking BiruniOS source files"

for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "Missing required source file: $file" >&2
        exit 1
    fi
done

# ============================================================
# Prepare build directories
# ============================================================

echo "==> Preparing build directories"

mkdir -p "$BUILD_DIR"
mkdir -p "$OUT_DIR"
mkdir -p "$LOG_DIR"

# IMPORTANT:
# Lorax requires RESULT_DIR itself not to exist.
# Do not use mkdir -p on RESULT_DIR.
rm -rf -- "$RESULT_DIR"

# Remove previous ISO outputs but preserve previous logs
# until the corresponding new log files are generated.
find "$OUT_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +

rm -f -- \
    "$LOG_DIR/rpm-build.log" \
    "$LOG_DIR/compose-console.log" \
    "$LOG_DIR/livemedia-creator.log"

# ============================================================
# Build custom BiruniOS RPM packages
# ============================================================

echo
echo "============================================================"
echo "==> Building BiruniOS RPM packages"
echo "============================================================"

/bin/bash "$ROOT_DIR/scripts/build-rpms.sh" \
    2>&1 | tee "$LOG_DIR/rpm-build.log"

# Verify that RPM packages were actually created.

RPM_COUNT="$(find "$RPM_DIR" -maxdepth 1 -type f -name '*.rpm' | wc -l)"

if [[ "$RPM_COUNT" -lt 4 ]]; then
    echo "Expected at least four BiruniOS RPM packages." >&2
    echo "Found: $RPM_COUNT" >&2
    exit 1
fi

echo "==> Successfully built $RPM_COUNT RPM packages"
find "$RPM_DIR" -maxdepth 1 -type f -name '*.rpm' -printf '  %f\n' | sort

# ============================================================
# Validate Kickstart
# ============================================================

echo
echo "============================================================"
echo "==> Validating Fedora 45 Kickstart"
echo "============================================================"

ksvalidator -v F45 "$ROOT_DIR/kickstarts/birunios-live.ks"

echo "==> Kickstart validation passed"

# ============================================================
# Check available disk space
# ============================================================

echo
echo "============================================================"
echo "==> Checking available workspace"
echo "============================================================"

df -h "$ROOT_DIR"

FREE_KB="$(df -Pk "$ROOT_DIR" | awk 'NR==2 {print $4}')"

if [[ -z "$FREE_KB" || ! "$FREE_KB" =~ ^[0-9]+$ ]]; then
    echo "Could not determine available workspace disk space." >&2
    exit 3
fi

FREE_GIB="$(awk -v kb="$FREE_KB" 'BEGIN {printf "%.1f", kb/1024/1024}')"
MIN_FREE_GIB="$(awk -v kb="$MIN_FREE_KB" 'BEGIN {printf "%.1f", kb/1024/1024}')"

echo "Available disk space: ${FREE_GIB} GiB"
echo "Required minimum: ${MIN_FREE_GIB} GiB"

if [[ "$FREE_KB" -lt "$MIN_FREE_KB" ]]; then
    echo "Insufficient disk space for ISO composition." >&2
    echo "Free additional space or use a larger build runner." >&2
    exit 3
fi

# ============================================================
# Prepare Lorax results directory
# ============================================================

echo
echo "============================================================"
echo "==> Preparing Lorax ISO composition"
echo "============================================================"

# Lorax requires the result directory not to exist.
# Remove it again immediately before composition as a safeguard.
rm -rf -- "$RESULT_DIR"

if [[ -e "$RESULT_DIR" || -L "$RESULT_DIR" ]]; then
    echo "Unable to remove the Lorax results directory: $RESULT_DIR" >&2
    exit 3
fi

echo "Lorax results directory is ready."
echo "Lorax will create it during ISO composition."

# ============================================================
# Compose BiruniOS ISO
# ============================================================

echo
echo "============================================================"
echo "==> Composing ${ISO_NAME}"
echo "==> Fedora ${FEDORA_RELEASE} | x86_64"
echo "============================================================"

cd "$ROOT_DIR"

livemedia-creator \
    --no-virt \
    --make-iso \
    --iso-only \
    --ks="$ROOT_DIR/kickstarts/birunios-live.ks" \
    --resultdir="$RESULT_DIR" \
    --logfile="$LOG_DIR/livemedia-creator.log" \
    --project=BiruniOS \
    --releasever="$FEDORA_RELEASE" \
    --iso-name="$ISO_NAME" \
    --volid="BIRUNIOS_010" \
    2>&1 | tee "$LOG_DIR/compose-console.log"

# ============================================================
# Locate and verify generated ISO
# ============================================================

echo
echo "============================================================"
echo "==> Searching for generated ISO"
echo "============================================================"

if [[ ! -d "$RESULT_DIR" ]]; then
    echo "Lorax did not create its results directory." >&2
    exit 4
fi

ISO_PATH="$(
    find "$RESULT_DIR" \
        -type f \
        -name '*.iso' \
        -size +0c \
        -print -quit
)"

if [[ -z "$ISO_PATH" ]]; then
    echo "Lorax finished without producing a non-empty ISO." >&2
    echo "Inspect the following locations:" >&2
    echo "  $LOG_DIR/livemedia-creator.log" >&2
    echo "  $LOG_DIR/compose-console.log" >&2
    echo "  $RESULT_DIR" >&2
    exit 4
fi

echo "Generated ISO: $ISO_PATH"

# ============================================================
# Copy ISO to final output
# ============================================================

echo
echo "==> Copying ISO to build/out"

cp -f -- "$ISO_PATH" "$OUT_DIR/$ISO_NAME"

if [[ ! -s "$OUT_DIR/$ISO_NAME" ]]; then
    echo "ISO copy failed or the resulting ISO is empty." >&2
    exit 4
fi

# ============================================================
# Generate SHA256 checksum
# ============================================================

echo
echo "==> Generating SHA256 checksum"

(
    cd "$OUT_DIR"
    sha256sum -- "$ISO_NAME" > SHA256SUMS
)

# Verify checksum immediately.
(
    cd "$OUT_DIR"
    sha256sum --check SHA256SUMS
)

# ============================================================
# Generate build information
# ============================================================

echo
echo "==> Generating build information"

cat > "$OUT_DIR/BUILD-INFO.txt" <<BUILD_INFO
BiruniOS ${VERSION} Developer Preview

Operating system: BiruniOS
Fedora base: Fedora ${FEDORA_RELEASE}
Desktop environment: KDE Plasma
Architecture: x86_64

Build method:
Fedora Lorax livemedia-creator --no-virt

Source commit:
${GITHUB_SHA:-local-build}

Build timestamp (UTC):
$(date -u +%Y-%m-%dT%H:%M:%SZ)

Build output:
${ISO_NAME}

Checksum:
SHA256SUMS

This is an experimental developer preview.
Verify the SHA256 checksum before using this ISO.
Test in a disposable virtual machine before installing
on physical hardware.
BUILD_INFO

# ============================================================
# Final build report
# ============================================================

echo
echo "============================================================"
echo "             BIRUNIOS BUILD COMPLETED"
echo "============================================================"

echo
echo "ISO:"
ls -lh "$OUT_DIR/$ISO_NAME"

echo
echo "Checksum:"
cat "$OUT_DIR/SHA256SUMS"

echo
echo "Build information:"
cat "$OUT_DIR/BUILD-INFO.txt"

echo
echo "All output files:"
ls -lh "$OUT_DIR"

echo
echo "============================================================"
echo "ISO composition and checksum verification succeeded."
echo "============================================================"
