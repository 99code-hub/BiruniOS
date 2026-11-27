#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="birunios-fedora45-builder:local"

command -v docker >/dev/null 2>&1 || {
    echo "Docker is required. Podman users can adapt the docker commands to podman." >&2
    exit 1
}

echo "==> Building Fedora 45 BiruniOS build container"
docker build -f "$ROOT_DIR/ci/Fedora45.Dockerfile" -t "$IMAGE" "$ROOT_DIR"

echo "WARNING: ISO composition requires a privileged container and low-level mount access."
echo "Run this only inside a disposable Linux VM with no valuable disks attached."
echo "==> Running the ISO composer in a disposable privileged container"
docker run --rm --privileged \
    --volume "$ROOT_DIR:/workspace:Z" \
    --workdir /workspace \
    --env BIRUNIOS_VERSION="${BIRUNIOS_VERSION:-0.1.0}" \
    --env FEDORA_RELEASE=45 \
    "$IMAGE"

echo "ISO output: $ROOT_DIR/build/out/"
