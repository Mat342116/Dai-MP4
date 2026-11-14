#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Questo script è destinato a macOS." >&2
  exit 1
fi

if [[ -z "${DEVKITPRO:-}" || -z "${DEVKITARM:-}" ]]; then
  echo "DEVKITPRO o DEVKITARM non sono configurate." >&2
  echo "Installa devkitPro con devkitARM, libnds e libfat; poi configura le variabili d'ambiente." >&2
  exit 1
fi

if [[ ! -f "$DEVKITARM/ds_rules" ]]; then
  echo "Non trovo $DEVKITARM/ds_rules. Verifica l'installazione di devkitARM." >&2
  exit 1
fi

if ! command -v make >/dev/null 2>&1; then
  echo "make non è disponibile. Installa Xcode Command Line Tools con: xcode-select --install" >&2
  exit 1
fi

echo "Compilazione di Dai-MP4..."
make

if [[ -f "$ROOT/Dai-MP4.nds" ]]; then
  echo "Compilazione completata: $ROOT/Dai-MP4.nds"
else
  echo "Make è terminato ma Dai-MP4.nds non è stato trovato." >&2
  exit 1
fi
