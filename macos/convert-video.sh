#!/bin/bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Uso: $0 video-sorgente [video-destinazione.avi]" >&2
  exit 2
fi

INPUT="$1"
if [[ ! -f "$INPUT" ]]; then
  echo "File non trovato: $INPUT" >&2
  exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "FFmpeg non trovato. Se usi Homebrew: brew install ffmpeg" >&2
  exit 1
fi

if ! command -v ffprobe >/dev/null 2>&1; then
  echo "ffprobe non trovato. Reinstalla FFmpeg (Homebrew: brew install ffmpeg)." >&2
  exit 1
fi

if [[ $# -eq 2 ]]; then
  OUTPUT="$2"
else
  DIR="$(cd "$(dirname "$INPUT")" && pwd)"
  BASE="$(basename "$INPUT")"
  NAME="${BASE%.*}"
  OUTPUT="$DIR/$NAME-dsi-test.avi"
fi

echo "Informazioni sul file sorgente:"
ffprobe -v error -show_entries format=duration:stream=codec_type,codec_name,width,height -of default=noprint_wrappers=1 "$INPUT" || true

echo "Creo AVI sperimentale 256x192, 10 fps, Xvid/MPEG-4 Part 2 e MP3..."
ffmpeg -hide_banner -y -i "$INPUT" \
  -map 0:v:0 -map '0:a:0?' \
  -vf "scale=256:192:force_original_aspect_ratio=decrease,pad=256:192:(ow-iw)/2:(oh-ih)/2,setsar=1" \
  -r 10 -c:v mpeg4 -vtag XVID -q:v 5 -pix_fmt yuv420p \
  -c:a libmp3lame -ar 32000 -ac 2 -b:a 96k \
  -f avi "$OUTPUT"

echo "Creato: $OUTPUT"
echo "Nota: è un profilo di prova, non una garanzia di riproduzione su DSi."
