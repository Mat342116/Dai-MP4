# Development roadmap

## DSi playback engine
- [x] Research established DSi video-player implementations.
- [x] Select Rocket Video Player as a known working playback engine.
- [x] Pin the MIT-licensed upstream source as a Git submodule and preserve its license/identity.
- [x] Add a reproducible BlocksDS build script and GitHub Actions artifact workflow.
- [ ] Confirm the CI build succeeds and inspect the generated NDS artifact.
- [ ] Test launch, SD browsing, video and audio on a physical DSi/DSi XL.
- [ ] Decide whether to keep the upstream player as a separately attributed application or develop a branded fork with full attribution and asset review.

## macOS Big Sur Intel converter
- [x] Create a native Cocoa x86_64 app shell and build script.
- [ ] Replace the current AVI/Xvid output with a legally distributable .rvid conversion pipeline.
- [ ] Verify output against Rocket Video Player using sample videos.
- [ ] Add progress reporting, cancellation, error handling and SD export.
- [ ] Test on a physical DSi.

## Legacy AVI prototype
- [x] Create devkitPro/libnds project structure.
- [x] Add preliminary AVI metadata validation.
- [x] Harden RIFF chunk bounds and select the first actual video stream even when audio appears first.
- [x] Add host-side parser regression tests and GitHub Actions.
- [ ] Validate the parser and interface on hardware.

## Format and licensing constraints

MP4 is a container, not a codec. The selected DSi player uses `.rvid`, a distinct format. The separate Vid2RVID repository currently has no declared license, so its source must not be copied or redistributed without permission. The current Mac converter's AVI output is for a different player and must not be described as compatible with Rocket Video Player.
