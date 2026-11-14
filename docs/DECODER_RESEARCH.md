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

## Additional candidate reviewed: Rocket Video Player (.rvid)

A promising clean-room integration candidate is Rocket Video Player: https://github.com/RocketRobz/RocketVideoPlayer. Its GitHub repository declares the MIT license and documents DSi playback with stereo audio up to 32 kHz, a built-in file browser, and support for long videos. The format is `.rvid`, not AVI, so the current AVI parser and FFmpeg AVI preset are not directly compatible.

The companion converter is Vid2RVID: https://github.com/RocketRobz/Vid2RVID. Its published material describes the conversion workflow, but I have not verified a redistributable license for that converter source. Do not copy, bundle, or adapt its implementation until an explicit license is confirmed. A separate implementation of the documented file format would require format-level investigation and test vectors.

**Current direction:** keep the AVI work as a validation prototype, but evaluate basing the DSi player on the MIT-licensed Rocket Video Player rather than reimplementing Xvid/MP3 decoding. Before adopting it, verify the exact upstream source revision, preserve its license and notices, understand the build/toolchain requirements, and make sure the project owner is comfortable changing Dai-MP4's target file format from `.avi` to `.rvid`.

Sources: DS-Homebrew's maintained comparison lists working `.rvid`, `.avi`/Xvid, `.dpg` and `.fv` players; Rocket Video Player's upstream README declares MIT and describes its capabilities. See https://wiki.ds-homebrew.com/ds-index/videoplayers and https://github.com/RocketRobz/RocketVideoPlayer.

## Implemented integration and independent RVID writer

The repository now pins Rocket Video Player at upstream commit `50803b9027ca43ab278c1486442fcfc70c90b309` as a Git submodule. Its upstream LICENSE is MIT. The build script and CI workflow build the upstream NDS player without changing its name or claiming its code as Dai-MP4 code.

The macOS converter has been changed to write RVID v5 using the public header layout in `common/rvidHeader.h` and the playback reader's uncompressed RGB565 and planar PCM paths. It writes 256x192 RGB565 frames at 15 fps, then left and right 16-bit PCM streams at 32 kHz. The format writer is independent; no Vid2RVID source is copied. This implementation still needs a successful macOS CI build, generated-file validation, and real DSi playback tests.

The uncompressed 16-bit profile is intentionally simple but produces large files (about 1.6 MB/s with audio). The converter refuses output files at or above 3.9 GB to stay below the FAT32 single-file limit.

The companion Vid2RVID repository currently has no declared license. Its code must not be copied or redistributed without permission.
