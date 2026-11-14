#!/bin/bash
set -euo pipefail

echo "Dai-MP4 - configurazione strumenti macOS"
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Errore: questo script richiede macOS." >&2
  exit 1
fi

ARCH="$(uname -m)"
if [[ "$ARCH" != "x86_64" ]]; then
  echo "Nota: rilevata architettura $ARCH; questa guida è pensata per Mac Intel x86_64."
fi

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installo/avvio la richiesta degli Xcode Command Line Tools..."
  xcode-select --install || true
  echo "Completa la finestra di installazione, poi rilancia questo script."
  exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew non è installato."
  echo "Installa Homebrew da https://brew.sh/ e poi rilancia questo script."
  exit 1
fi

echo "Aggiorno gli indici Homebrew e installo FFmpeg..."
brew update
brew install ffmpeg

echo
"$(dirname "$0")/check-ffmpeg.sh"
