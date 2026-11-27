#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${BIRUNIOS_VERSION:-0.1.0}"
FEDORA_RELEASE="${FEDORA_RELEASE:-45}"
RESULT_DIR="$ROOT_DIR/build/lmc-results"
OUT_DIR="$ROOT_DIR/build/out"
LOG_DIR="$ROOT_DIR/build/logs"
ISO_NAME="BiruniOS-${VERSION}-x86_64.iso"

if [[ "$(id -u)" -ne 0 ]]; then
    echo "Run this script as root inside the disposable Fedora build container." >&2
    exit 1
fi

for command in livemedia-creator ksvalidator createrepo_c rpmbuild; do
    command -v "$command" >/dev/null 2>&1 || {
        echo "Missing build dependency: $command" >&2
        exit 1
    }
done

if [[ "$FEDORA_RELEASE" != "45" ]]; then
    echo "This starter repository is pinned to Fedora 45. Update all release references and test them before changing FEDORA_RELEASE." >&2
    exit 2
fi

mkdir -p "$RESULT_DIR" "$OUT_DIR" "$LOG_DIR"
rm -rf "$RESULT_DIR"/* "$OUT_DIR"/*

echo "==> Building BiruniOS RPMs"
"$ROOT_DIR/scripts/build-rpms.sh" 2>&1 | tee "$LOG_DIR/rpm-build.log"

echo "==> Validating Kickstart"
ksvalidator -v F45 "$ROOT_DIR/kickstarts/birunios-live.ks"

echo "==> Checking available workspace"
df -h "$ROOT_DIR"
FREE_KB="$(df -Pk "$ROOT_DIR" | awk 'NR==2 {print $4}')"
if [[ -n "$FREE_KB" && "$FREE_KB" -lt 6500000 ]]; then
    echo "Less than 6.5 GB of free space is available. ISO composition may fail; use a larger runner or build locally." >&2
    exit 3
fi

echo "==> Composing ${ISO_NAME} with Fedora ${FEDORA_RELEASE}"
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

ISO_PATH="$(find "$RESULT_DIR" -type f -name '*.iso' -print -quit)"
if [[ -z "$ISO_PATH" ]]; then
    echo "livemedia-creator finished without an ISO. Inspect build/logs and build/lmc-results." >&2
    exit 4
fi

cp -f "$ISO_PATH" "$OUT_DIR/$ISO_NAME"
(
    cd "$OUT_DIR"
    sha256sum "$ISO_NAME" > SHA256SUMS
)

cat > "$OUT_DIR/BUILD-INFO.txt" <<EOF
BiruniOS ${VERSION} Developer Preview
Fedora base: ${FEDORA_RELEASE}
Architecture: x86_64
Build method: Fedora Lorax livemedia-creator --no-virt
Source commit: ${GITHUB_SHA:-local-build}
Build timestamp (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)

This is an experimental preview. Verify SHA256SUMS and test in a disposable VM before installing on physical hardware.
EOF

echo "==> Build completed"
ls -lh "$OUT_DIR"
