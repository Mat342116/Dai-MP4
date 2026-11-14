# Dai-MP4 Converter — macOS Big Sur Intel (prototype)

Native Cocoa app targeting Intel x86_64 and macOS 11.0 or newer.

## Important compatibility warning

This prototype currently converts MP4/M4V/MOV/MKV inputs to indexed AVI with MPEG-4 Part 2/XVID FourCC and MP3 audio. It is a candidate profile for the separate Tuna-viDS player. It does **not** create Rocket Video (`.rvid`) files and its output will not play in the Rocket Video Player included as the DSi playback engine in this repository.

A compatible `.rvid` converter is not yet included. The upstream Vid2RVID project currently declares no repository license, so its code is not copied or redistributed here.

## Requirements

FFmpeg must be installed separately and include the mpeg4 and libmp3lame encoders. The app searches /usr/local/bin/ffmpeg, /opt/homebrew/bin/ffmpeg and /opt/local/bin/ffmpeg.

## Build

On a Mac with Xcode Command Line Tools:

    cd macOS-Converter
    ./build.sh
    open 'build/Dai-MP4 Converter.app'

## Use

Choose a video (MP4/M4V/MOV/MKV), choose an AVI destination and press Convert. The preset creates a 256x192 canvas, 10 fps, MPEG-4 Part 2 with XVID FourCC, and MP3 audio at 32 kHz. Aspect ratio is preserved with black padding.

This is an experimental converter, not the finished MP4-to-RVID converter requested for the Rocket Video Player.
