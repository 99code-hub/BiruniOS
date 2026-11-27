#!/usr/bin/env bash
set -Eeuo pipefail
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 BiruniOS-version-x86_64.iso" >&2
    exit 2
fi
ISO_NAME="$1"
[[ "$ISO_NAME" == *.iso ]] || { echo "Expected an .iso filename" >&2; exit 2; }
shopt -s nullglob
parts=("${ISO_NAME}".part-*)
(( ${#parts[@]} > 0 )) || { echo "No split parts found for $ISO_NAME" >&2; exit 1; }
cat "${parts[@]}" > "$ISO_NAME"
sha256sum --check SHA256SUMS
