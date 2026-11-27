#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO="${1:-}"

if [[ -z "$ISO" ]]; then
    ISO="$(find "$ROOT_DIR/build/out" -maxdepth 1 -type f -name '*.iso' -print -quit)"
fi
[[ -n "$ISO" && -f "$ISO" ]] || { echo "Usage: $0 path/to/BiruniOS.iso" >&2; exit 2; }

printf 'ISO: %s\n' "$ISO"
file "$ISO"
sha256sum "$ISO"
if command -v xorriso >/dev/null 2>&1; then
    xorriso -indev "$ISO" -report_el_torito plain
else
    echo "xorriso not installed; skipped El Torito boot-catalog inspection."
fi

echo "Structural ISO inspection completed. This does NOT replace booting the image in QEMU/KVM or on physical hardware."
