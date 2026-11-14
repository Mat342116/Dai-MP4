# Dai-MP4

Nintendo DSi video-player project with a separate macOS Big Sur Intel converter.

## DSi video player

The repository pins [Rocket Video Player](https://github.com/RocketRobz/RocketVideoPlayer) as a Git submodule at a fixed upstream revision. It is an established DSi player released under the MIT License; its original name, credits and license are retained. It plays Rocket Video `.rvid` files, not ordinary MP4 or AVI files.

The upstream player supports 8-bit and 16-bit video, dual-screen playback and stereo audio up to 32 kHz. Actual performance depends on the content and console. See the [DS-Homebrew video-player comparison](https://wiki.ds-homebrew.com/ds-index/videoplayers).

### Build and install

Clone this repository including submodules:

```sh
git clone --recurse-submodules https://github.com/Mat342116/Dai-MP4.git
cd Dai-MP4
```

If already cloned:

```sh
git submodule update --init --recursive
```

With Wonderful Toolchain and BlocksDS installed on Linux:

```sh
source /opt/wonderful/bin/wf-env -a
./scripts/build-dsi-player.sh
```

The generated file is `dist/RocketVideoPlayer.nds`. GitHub Actions also builds it and publishes it as an artifact. Copy the NDS file and converted `.rvid` videos to the DSi SD card and launch the player using your usual homebrew method.

## macOS Big Sur Intel converter

A separate native Cocoa application is in `macOS-Converter/`. It now targets the Rocket Video `.rvid` format using a clean implementation of the public version-5 header layout and uncompressed RGB565 frames, plus planar 16-bit PCM audio.

Build on an Intel Mac with Xcode Command Line Tools and FFmpeg installed:

```sh
cd macOS-Converter
./build.sh
open 'build/Dai-MP4 Converter.app'
```

The converter creates 256×192 RGB565 video at 15 fps and stereo PCM audio at 32 kHz. This uncompressed profile produces large files (roughly 1.6 MB/s with audio); the app refuses outputs above a conservative FAT32 file-size limit. FFmpeg and ffprobe must be installed separately.

**Compatibility status:** the .rvid writer is implemented from the public format declaration and player reader, but its output has not yet been validated on a physical DSi. Treat the converter as a test build until the GitHub macOS build passes and a generated sample is played successfully.

## Legacy AVI prototype

The original `source/main.c` application and AVI metadata parser remain as an experimental prototype, not the active playback engine. Host parser tests can be run with:

```sh
make -f tests/Makefile
```

See [decoder research](docs/DECODER_RESEARCH.md), [roadmap](docs/ROADMAP.md), and [upstream licensing details](vendor/README.md).
