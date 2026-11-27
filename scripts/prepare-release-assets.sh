#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/build/out"
RELEASE_DIR="$ROOT_DIR/build/release-assets"

for command in find stat split sha256sum cp mkdir; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Missing required command: $command" >&2
        exit 1
    fi
done

ISO="$(find "$OUT_DIR" -maxdepth 1 -type f -name '*.iso' -size +0c -print -quit)"
if [[ -z "$ISO" ]]; then
    echo "No non-empty ISO found in $OUT_DIR" >&2
    exit 1
fi

for required_file in "$OUT_DIR/SHA256SUMS" "$OUT_DIR/BUILD-INFO.txt"; do
    if [[ ! -s "$required_file" ]]; then
        echo "Required release metadata is missing or empty: $required_file" >&2
        exit 1
    fi
done

mkdir -p "$RELEASE_DIR"
find "$RELEASE_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +

ISO_NAME="$(basename "$ISO")"
SIZE="$(stat -c '%s' "$ISO")"
LIMIT=$((1800 * 1024 * 1024))

if (( SIZE > LIMIT )); then
    echo "ISO exceeds the 1800 MiB release-asset threshold; splitting into numbered parts."
    split -b 1800M -d -a 3 "$ISO" "$RELEASE_DIR/${ISO_NAME}.part-"
    cat > "$RELEASE_DIR/REASSEMBLE.txt" <<REASSEMBLE
This ISO was split into parts to keep each GitHub Release asset below 2 GiB.
Download every file named ${ISO_NAME}.part-### into one directory, then run:

  cat ${ISO_NAME}.part-* > ${ISO_NAME}
  sha256sum --check SHA256SUMS

Run the commands from the directory containing the downloaded parts and SHA256SUMS.
Do not boot an individual part. Reassemble all parts before using the ISO.
REASSEMBLE
else
    cp -f -- "$ISO" "$RELEASE_DIR/"
fi

cp -f -- "$OUT_DIR/SHA256SUMS" "$RELEASE_DIR/"
cp -f -- "$OUT_DIR/BUILD-INFO.txt" "$RELEASE_DIR/"

(
    cd "$RELEASE_DIR"
    sha256sum -- * > RELEASE-ASSETS-SHA256SUMS
)

echo "Prepared release assets in $RELEASE_DIR"
ls -lh "$RELEASE_DIR"
