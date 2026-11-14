# Dai-MP4 Converter — macOS Big Sur Intel

Native Cocoa application targeting Intel x86_64 and macOS 11.0 or newer. It converts common video inputs into Rocket Video `.rvid` files for the DSi player included in this repository.

## Requirements

Install FFmpeg (including ffprobe) separately. On Intel Macs with Homebrew, the expected executable paths are `/usr/local/bin/ffmpeg` and `/usr/local/bin/ffprobe`. The app also checks `/opt/homebrew/bin` and `/opt/local/bin`.

## Build

On an Intel Mac with Xcode Command Line Tools:

    cd macOS-Converter
    ./build.sh
    open 'build/Dai-MP4 Converter.app'

## Conversion profile

- Input: MP4, M4V, MOV, MKV or AVI.
- Container: Rocket Video `.rvid`, version 5.
- Video: 256×192 canvas, aspect ratio preserved with black padding, 15 fps, uncompressed 16-bit RGB565.
- Audio: stereo 16-bit PCM at 32 kHz, stored as separate left and right streams.
- File-size guard: refuses estimated output at or above 3.9 GB to avoid FAT32's single-file limit.

The RVID writer uses the public header layout and playback behavior declared by the MIT-licensed Rocket Video Player project. It is an independent implementation; no Vid2RVID source is copied. The companion Vid2RVID repository currently declares no license.

## Validation status

The writer is implemented, but the app must still pass the macOS CI build and generated files must be checked in Rocket Video Player and on a physical DSi. Do not assume successful end-to-end playback until those tests pass.
