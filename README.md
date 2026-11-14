# Dai-MP4

Nintendo DSi video-player project with a separately maintained macOS converter prototype.

## Working DSi playback engine

This repository now pins [Rocket Video Player](https://github.com/RocketRobz/RocketVideoPlayer) as a Git submodule at a fixed upstream revision. Rocket Video Player is an existing DSi video player released under the MIT License; its license and upstream identity are retained. It supports the Rocket Video `.rvid` format, not ordinary MP4 or AVI files.

The upstream player supports 8-bit and 16-bit video, dual-screen playback and stereo audio up to 32 kHz. Actual performance depends on the video and the DSi model. See the [DS-Homebrew video-player comparison](https://wiki.ds-homebrew.com/ds-index/videoplayers).

### Get the player

Clone this repository including submodules:

```sh
git clone --recurse-submodules https://github.com/Mat342116/Dai-MP4.git
cd Dai-MP4
```

If you already cloned it without submodules:

```sh
git submodule update --init --recursive
```

The CI build uses BlocksDS and creates an artifact named `RocketVideoPlayer.nds`. Build locally on Linux with Wonderful Toolchain and BlocksDS installed:

```sh
source /opt/wonderful/bin/wf-env -a
./scripts/build-dsi-player.sh
```

Copy `dist/RocketVideoPlayer.nds` to the SD card and launch it using your usual DSi homebrew method. Put converted `.rvid` files on the SD card for the player to browse.

## Converter status — important

The separate `macOS-Converter/` app currently creates an AVI/Xvid candidate for the older Tuna-viDS player. **It does not create .rvid files and is not compatible with the Rocket Video Player integration above.** Do not use its AVI output expecting it to play in Rocket Video Player.

The upstream companion tool [Vid2RVID](https://github.com/RocketRobz/Vid2RVID) is the intended .rvid converter, but its repository currently declares no license. This project does not copy or redistribute its source. A native macOS Big Sur Intel converter that outputs .rvid remains unfinished until a compatible implementation can be legally used or written and tested.

## Legacy Dai-MP4 AVI prototype

The original `source/main.c` application and AVI metadata parser remain in the repository as an experimental prototype. They are not the integrated video decoder. The host parser tests can be run with:

```sh
make -f tests/Makefile
```

See [decoder research](docs/DECODER_RESEARCH.md), [roadmap](docs/ROADMAP.md), and [the upstream MIT license](vendor/README.md).
