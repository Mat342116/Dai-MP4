# Development roadmap

## Phase 1 — DSi player
- [x] Create initial devkitPro/libnds project structure.
- [ ] Validate SD-card access and directory navigation on hardware.
- [ ] Replace text mock-up with touch-friendly graphical controls.
- [ ] Choose and integrate a decoder feasible on DSi CPU/RAM.
- [ ] Render decoded frames on the upper screen.
- [ ] Add PLAY/STOP state handling and error messages.
- [ ] Test on emulator and physical DSi/DSi XL.

## Video format constraints
MP4 is a container. Files can contain many codecs and profiles. The DSi has limited CPU and memory; arbitrary MP4 decoding and on-device transcoding may be impractical. Do not promise playback until a real decoder and supported profile are benchmarked on hardware.

## Phase 2 — Mac converter
After the player format is validated, create a separate macOS 11 Big Sur Intel (x86_64) app. It will transcode common source files to the exact tested player format and optionally copy results to an SD card.
