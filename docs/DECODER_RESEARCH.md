# Decoder research and first playback target

## Decision for the first prototype

Use indexed AVI with Xvid / MPEG-4 Part 2 video as the first target format, with a conservative initial profile:

- Frame size: 256 x 192 pixels (or smaller, preserving aspect ratio).
- Frame rate: start at 10 fps; test 12 fps only after profiling.
- Video: Xvid-compatible MPEG-4 Part 2, progressive/non-interlaced.
- Audio: MP3 at 32 kHz, initially mono or stereo at a conservative bitrate.
- Container: AVI with an index; video stream first.

This is a compatibility target, not a guarantee that every AVI/Xvid file will play. AVI is only a container; stream profile, bitrate, frame rate and audio layout matter.

## Existing implementation reference

Tuna-viDS is an established Nintendo DS Xvid/AVI player: https://github.com/chishm/tuna-vids

Its published format notes specify 256 pixels wide, up to 192 pixels tall, roughly 10–12 fps, Xvid video and MP3 audio. It is a useful technical reference and demonstrates that this class of playback is feasible on DS-family hardware.

Its source has mixed licensing notes: the ARM9 binary is GPL v2, while the ARM7 binary is GPL v2 plus RealNetworks Public Source License. Do not copy or link its decoder/audio code into Dai-MP4 until each source file and dependency license has been checked and the project's licensing approach is settled.

## Other candidate

DS-Homebrew's video-player comparison lists FastVideoDS as a separate format with higher possible frame rates in DSi mode. It may be worth benchmarking later, but it is a different format and does not mean ordinary MP4 files are supported.

## Work still required

1. Confirm the DSi model and homebrew launch environment used for testing.
2. Choose between a clean decoder integration and adapting a clearly licensed existing implementation.
3. Parse AVI headers/index and reject unsupported streams with a clear message.
4. Decode one frame and display it on the top screen only.
5. Add frame pacing and audio only after stable video output.
6. Benchmark real files on the user's DSi; do not infer performance from emulator results alone.

## Converter consequence

The future macOS Big Sur Intel converter should produce only the exact profile validated by Dai-MP4. An initial FFmpeg preset can target 256x192, 10 fps, Xvid-compatible MPEG-4 Part 2, AVI and MP3, but final bitrate/audio settings must be confirmed by hardware tests.

## AVI probe implemented in Dai-MP4

The project now has `source/avi.c` and `source/avi.h`. The PLAY touch area calls `avi_probe()`, which performs preliminary metadata checks: RIFF/AVI signature, `idx1` presence, first stream type, Xvid-family FourCC and 256x192 maximum dimensions (256 pixels wide, up to 192 high). It is deliberately a metadata probe, not a decoder. It does not yet validate frame rate, MP3 audio, all OpenDML variants, or decode a frame. Test it with real files and malformed AVI samples before relying on it.
