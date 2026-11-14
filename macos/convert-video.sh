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

for tool in ffmpeg ffprobe; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "$tool non trovato. Esegui prima: ./macos/install-deps.sh" >&2
    exit 1
  fi
done

ENCODERS="$(ffmpeg -hide_banner -encoders 2>/dev/null)"
if ! printf "%s\n" "$ENCODERS" | grep -q 'libmp3lame'; then
  echo "La build FFmpeg non include libmp3lame. Reinstalla FFmpeg con Homebrew." >&2
  exit 1
fi
if printf "%s\n" "$ENCODERS" | grep -q 'libxvid'; then
  VIDEO_ENCODER="libxvid"
else
  if ! printf "%s\n" "$ENCODERS" | grep -Eq '[[:space:]]mpeg4[[:space:]]'; then
    echo "Nessun encoder MPEG-4 Part 2 compatibile trovato." >&2
    exit 1
  fi
  VIDEO_ENCODER="mpeg4"
fi

if [[ $# -eq 2 ]]; then
  OUTPUT="$2"
else
  DIR="$(cd "$(dirname "$INPUT")" && pwd)"
  BASE="$(basename "$INPUT")"
  NAME="${BASE%.*}"
  OUTPUT="$DIR/$NAME-dsi-test.avi"
fi

if [[ "$INPUT" -ef "$OUTPUT" ]]; then
  echo "Sorgente e destinazione non possono essere lo stesso file." >&2
  exit 1
fi

echo "Sorgente:"
ffprobe -v error -show_entries format=duration:stream=codec_type,codec_name,width,height -of default=noprint_wrappers=1 "$INPUT"

echo "Encoder video scelto: $VIDEO_ENCODER"
echo "Conversione in AVI 256x192, 10 fps, MPEG-4 Part 2/XVID, MP3 32 kHz..."
ffmpeg -hide_banner -y -i "$INPUT" \
  -map 0:v:0 -map '0:a:0?' \
  -vf "scale=256:192:force_original_aspect_ratio=decrease,pad=256:192:(ow-iw)/2:(oh-ih)/2,setsar=1" \
  -r 10 -c:v "$VIDEO_ENCODER" -vtag XVID -q:v 5 -pix_fmt yuv420p \
  -c:a libmp3lame -ar 32000 -ac 2 -b:a 96k \
  -f avi "$OUTPUT"

echo
echo "Verifica del file generato:"
ffprobe -v error -show_entries format=format_name,duration:stream=codec_type,codec_name,width,height,r_frame_rate,sample_rate,channels -of default=noprint_wrappers=1 "$OUTPUT"
echo
echo "Creato: $OUTPUT"
echo "ATTENZIONE: questo AVI segue il profilo sperimentale, ma il decoder Dai-MP4 non è ancora implementato."
