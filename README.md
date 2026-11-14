# Dai-MP4

Nintendo DSi homebrew video-player project.

## Project status

This repository is an early player prototype, **not yet a working video player**. The current application provides a dual-screen text interface, SD-card root browsing and preliminary AVI metadata validation. It does not decode or play video or audio.

MP4 is a container, not a codec. The first research target is indexed AVI with Xvid/MPEG-4 Part 2 video, 256 pixels wide by at most 192 high. Frame rate, bitrate and audio compatibility still need to be validated on real DSi hardware. Arbitrary MP4 playback is not supported.

## Build on Nintendo DS/DSi

Install devkitPro with devkitARM, libnds and libfat, configure `DEVKITPRO` and `DEVKITARM`, then run:

```sh
make
```

The intended output is `Dai-MP4.nds`.

## Host-side parser tests

The AVI metadata parser can be tested without devkitPro:

```sh
make -f tests/Makefile
```

GitHub Actions runs the same host test suite for pushes and pull requests.

## Current limitations

- AVI validation checks RIFF chunk bounds, the AVI header, an `idx1` index, a video stream, Xvid-family FourCC and conservative frame dimensions. It is a metadata check, not a decoder.
- OpenDML AVI, arbitrary codecs, frame-rate/bitrate limits and audio decoding are not implemented.
- The DSi interface is still text-based; physical touch, SD-card and performance testing remain necessary.
- Decoder integration requires a source-by-source license review before code is reused.
- The planned macOS Big Sur Intel converter is a later phase and must target a format proven to work on hardware.

See [decoder research](docs/DECODER_RESEARCH.md) and the [roadmap](docs/ROADMAP.md).

## macOS converter

A separate Intel macOS Big Sur converter app is under [`macOS-Converter/`](macOS-Converter/README.md). It produces an Xvid AVI candidate; it does not replace the still-missing DSi decoder.
