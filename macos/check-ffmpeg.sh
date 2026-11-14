#!/bin/bash
set -euo pipefail

echo "=== Sistema ==="
sw_vers
printf "Architettura: "
uname -m

echo
echo "=== Percorsi ==="
for tool in ffmpeg ffprobe; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf "%s: " "$tool"
    command -v "$tool"
  else
    echo "$tool: NON TROVATO"
    exit 1
  fi
done

echo
echo "=== Versione FFmpeg ==="
ffmpeg -hide_banner -version | head -n 2
echo
echo "=== Encoder richiesti ==="
ENCODERS="$(ffmpeg -hide_banner -encoders 2>/dev/null)"
if printf "%s\n" "$ENCODERS" | grep -q 'libmp3lame'; then
  echo "OK: libmp3lame disponibile"
else
  echo "ERRORE: libmp3lame non disponibile in questa build di FFmpeg"
  exit 1
fi
if printf "%s\n" "$ENCODERS" | grep -q 'libxvid'; then
  echo "OK: libxvid disponibile"
else
  echo "NOTA: libxvid non disponibile; il convertitore userà l'encoder MPEG-4 Part 2 integrato (FourCC XVID)."
  if ! printf "%s\n" "$ENCODERS" | grep -Eq '[[:space:]]mpeg4[[:space:]]'; then
    echo "ERRORE: nemmeno l'encoder mpeg4 integrato è disponibile."
    exit 1
  fi
fi

echo
echo "Installazione FFmpeg/FFprobe pronta."
