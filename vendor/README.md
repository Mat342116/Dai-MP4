# Nintendo DS/DSi playback engine

The actual video playback engine is included as a pinned Git submodule:

- Project: https://github.com/RocketRobz/RocketVideoPlayer
- Upstream revision: `50803b9027ca43ab278c1486442fcfc70c90b309`
- License: MIT (the upstream `LICENSE` file is retained in the submodule)
- Output: `RocketVideoPlayer.nds`
- Video format: `.rvid`, not MP4 or AVI

This is deliberately kept as a separately attributed upstream application. Dai-MP4 does not rebrand the upstream UI or claim its code as original. Build it with `scripts/build-dsi-player.sh` after cloning with submodules.

The companion Vid2RVID repository currently has no declared repository license. Do not copy or redistribute its source until its copyright holder grants permission. The macOS converter must target .rvid through a separately licensed implementation or an explicitly authorized converter.
