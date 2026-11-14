#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLAYER="$ROOT/vendor/RocketVideoPlayer"
if [[ ! -f "$PLAYER/nds/Makefile" ]]; then
  echo "RocketVideoPlayer submodule missing. Run: git submodule update --init --recursive" >&2
  exit 1
fi
: "${BLOCKSDS:=/opt/blocksds/core}"
export BLOCKSDS
make -C "$PLAYER/nds" clean
make -C "$PLAYER/nds" -j"$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 2)"
mkdir -p "$ROOT/dist"
cp "$PLAYER/nds/RocketVideoPlayer.nds" "$ROOT/dist/RocketVideoPlayer.nds"
echo "Built: $ROOT/dist/RocketVideoPlayer.nds"
