# Development roadmap

## Phase 1 — reliable foundation
- [x] Create the devkitPro/libnds project structure.
- [x] Add preliminary AVI metadata validation.
- [x] Harden RIFF chunk bounds and select the first actual video stream even when audio appears first.
- [x] Add host-side parser regression tests and GitHub Actions.
- [ ] Build with devkitARM/libnds and fix any target-toolchain issues.
- [ ] Validate SD-card access, navigation and touch coordinates on a real DSi/DSi XL.

## Phase 2 — playback
- [ ] Replace the text mock-up with a touch-friendly graphical interface.
- [ ] Complete a source-by-source decoder and dependency license review.
- [ ] Select or implement a decoder that fits ARM9 CPU and memory limits.
- [ ] Decode and display one frame on the upper screen.
- [ ] Add frame pacing and robust PLAY/STOP/error states.
- [ ] Benchmark supported video profiles on physical DSi hardware.
- [ ] Add audio only after stable video playback.

## Phase 3 — Mac converter
- [ ] Build a separate macOS 11 Big Sur Intel (x86_64) converter.
- [ ] Transcode common input formats to the exact profile proven on DSi.
- [ ] Add optional SD-card export and conversion validation.

## Format constraints

MP4 is a container, not a codec. The initial research target is indexed AVI with Xvid/MPEG-4 Part 2, 256x192 maximum dimensions and a 10 fps starting target. This is not a playback guarantee. Do not promise arbitrary MP4 support or finalize converter settings before hardware benchmarks.
