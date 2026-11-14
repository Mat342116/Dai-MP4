# Development roadmap

## DSi playback engine
- [x] Select established Rocket Video Player as the playback engine.
- [x] Pin the MIT-licensed upstream source as a Git submodule and preserve its identity/license.
- [x] Add a BlocksDS build script and GitHub Actions artifact workflow.
- [ ] Confirm the CI build succeeds and inspect the generated NDS artifact.
- [ ] Test launch, SD browsing, video and audio on a physical DSi/DSi XL.
- [ ] Decide whether to maintain the upstream player as a separately attributed application or develop a branded fork with asset/license review.

## macOS Big Sur Intel converter
- [x] Create native Cocoa x86_64 app shell and build script.
- [x] Implement an RVID v5 writer for uncompressed RGB565 video and planar 16-bit PCM audio.
- [x] Scale/pad input video to 256×192, 15 fps; convert audio to stereo 32 kHz.
- [ ] Confirm macOS CI compilation and packaging.
- [ ] Generate a sample file and validate it with Rocket Video Player in an emulator.
- [ ] Test audio/video sync and playback on a physical DSi.
- [ ] Add cancellation, progress percentage, and optional SD-card export.

## Legacy AVI prototype
- [x] Create devkitPro/libnds project structure.
- [x] Add preliminary AVI metadata validation.
- [x] Harden RIFF chunk bounds and select the first actual video stream even when audio appears first.
- [x] Add host-side parser regression tests and GitHub Actions.
- [ ] Validate parser and interface on hardware.

## Format constraints

The selected player uses `.rvid`. The converter currently writes uncompressed 16-bit RGB565 frames at 15 fps and separate left/right PCM audio streams at 32 kHz, based on the public version-5 header and reader implementation in Rocket Video Player. This profile creates large files and still requires sample-file and hardware validation. The separate Vid2RVID repository declares no license; its source is not copied or redistributed.
