#ifndef DAI_MP4_AVI_H
#define DAI_MP4_AVI_H

#include <stddef.h>

typedef enum {
    AVI_PROBE_OK = 0,
    AVI_PROBE_OPEN_FAILED,
    AVI_PROBE_BAD_CONTAINER,
    AVI_PROBE_NO_INDEX,
    AVI_PROBE_UNSUPPORTED_VIDEO,
    AVI_PROBE_BAD_DIMENSIONS
} AviProbeResult;

/* Checks the AVI container and the conservative first-playback profile.
   This validates metadata only; it does not decode or play video. */
AviProbeResult avi_probe(const char *path, char *message, size_t message_size);

#endif
