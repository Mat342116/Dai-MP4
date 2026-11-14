# Dai-MP4

Original Nintendo DSi homebrew video-player project.

## Planned behavior
- Top screen: video playback.
- Bottom screen: touch controls and file browser.
- Physical START: open the SD-card file browser.
- Touch PLAY and STOP to control the selected video.
- Future companion: macOS Big Sur Intel (x86_64) video converter.

## Technical status
This is an early development scaffold, not a working MP4 player yet. MP4 is a container, not a codec, and arbitrary MP4 files cannot be assumed to decode on DSi hardware. We must first select and test a realistic decoder and video/audio profile against the DSi's CPU and memory limits. Only then can the Mac converter target that exact format.

## Build
Install devkitPro with devkitARM, libnds and libfat, then run `make`. Intended output: `Dai-MP4.nds`.

## Current status
Dual-screen UI/input and SD file-browser foundation are planned. Video decoding/rendering and audio playback are not implemented yet.