# Dai-MP4

Original Nintendo DSi homebrew video-player project.

## Planned behavior
- Top screen: video playback.
- Bottom screen: touch controls and file browser.
- Physical START: open the SD-card file browser.
- Touch PLAY and STOP to control the selected video.
- Future companion: macOS Big Sur Intel (x86_64) video converter.

## Technical status
This is an early development scaffold, not a working MP4 player yet. MP4 is a container, not a codec, and arbitrary MP4 files cannot be assumed to decode on DSi hardware. The first format being evaluated is indexed AVI with Xvid/MPEG-4 Part 2 video, at a conservative 256x192 and 10 fps profile, with MP3 audio. This is a research target based on the existing Tuna-viDS player, not yet an implemented decoder or a guarantee of playback. See [decoder research](docs/DECODER_RESEARCH.md). Only after hardware tests will the Mac converter target the exact supported profile.

## Build
Install devkitPro with devkitARM, libnds and libfat, then run `make`. Intended output: `Dai-MP4.nds`.

## Current status
Dual-screen UI/input and SD file-browser foundation are planned. Video decoding/rendering and audio playback are not implemented yet.
## Current AVI validation prototype

The PLAY touch area now probes the selected root-level AVI before reporting its status. The metadata check looks for an AVI RIFF container, an `idx1` index, a first video stream, an Xvid-family FourCC, and a 256-pixel-wide frame no taller than 192 pixels. It does **not** decode or play the video, and it does not yet validate frame rate, audio codec, or every AVI variant. A successful check currently means only that the file passes these preliminary checks.
