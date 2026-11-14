# Dai-MP4 Converter — macOS Big Sur Intel

Native Cocoa app targeting Intel x86_64 and macOS 11.0 or newer.

## Requirements
FFmpeg must be installed separately and include the mpeg4 and libmp3lame encoders. The app searches /usr/local/bin/ffmpeg, /opt/homebrew/bin/ffmpeg and /opt/local/bin/ffmpeg. On Intel Macs, Homebrew normally installs to /usr/local/bin.

## Build
On a Mac with Xcode Command Line Tools:

    cd macOS-Converter
    ./build.sh
    open 'build/Dai-MP4 Converter.app'

## Use
Choose a video (MP4/M4V/MOV/MKV), choose an AVI destination and press Convert. The preset creates a 256x192 canvas, 10 fps, MPEG-4 Part 2 with XVID FourCC, and MP3 audio at 32 kHz. Aspect ratio is preserved with black padding.

## Playback warning
This creates an AVI conversion candidate based on the published Tuna-viDS Xvid profile. The Dai-MP4 DSi homebrew in this repository still does not contain an integrated video/audio decoder, so this converter alone cannot make the current NDS app play video. The decoder must be implemented, license-reviewed and tested on a physical DSi before claiming end-to-end playback. This project does not copy Tuna-viDS code or binaries.