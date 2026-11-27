#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/build/out"
RELEASE_DIR="$ROOT_DIR/build/release-assets"
ISO="$(find "$OUT_DIR" -maxdepth 1 -type f -name '*.iso' -print -quit)"
[[ -n "$ISO" && -s "$ISO" ]] || { echo "No ISO found in $OUT_DIR" >&2; exit 1; }
mkdir -p "$RELEASE_DIR"
rm -f "$RELEASE_DIR"/*
ISO_NAME="$(basename "$ISO")"
SIZE="$(stat -c '%s' "$ISO")"
LIMIT=$((1800 * 1024 * 1024))
if (( SIZE > LIMIT )); then
    echo "ISO exceeds a conservative GitHub Release asset size; splitting into 1800 MiB chunks."
    split -b 1800M -d -a 3 "$ISO" "$RELEASE_DIR/${ISO_NAME}.part-"
    cat > "$RELEASE_DIR/REASSEMBLE.txt" <<EOF
This ISO was split into parts to keep each GitHub Release asset below 2 GiB.
Download every file named ${ISO_NAME}.part-### into one directory, then run:

  cat ${ISO_NAME}.part-* > ${ISO_NAME}
  sha256sum --check SHA256SUMS

Do not boot an individual part. Reassemble all parts before using the ISO.
EOF
else
    cp -f "$ISO" "$RELEASE_DIR/"
fi
cp -f "$OUT_DIR/SHA256SUMS" "$RELEASE_DIR/"
cp -f "$OUT_DIR/BUILD-INFO.txt" "$RELEASE_DIR/"
(cd "$RELEASE_DIR" && sha256sum * > RELEASE-ASSETS-SHA256SUMS)
echo "Prepared release assets in $RELEASE_DIR"
ls -lh "$RELEASE_DIR"
