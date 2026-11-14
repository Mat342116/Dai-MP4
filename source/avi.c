#include "avi.h"

#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define MAX_RIFF_SIZE 0x7fffffffUL

typedef struct {
    int found;
    int is_video;
    uint32_t width;
    uint32_t height;
    char handler[5];
    char compression[5];
} AviStreamInfo;

static uint32_t le32(const unsigned char *p) {
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) |
           ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

static uint16_t le16(const unsigned char *p) {
    return (uint16_t)p[0] | ((uint16_t)p[1] << 8);
}

static int read_exact(FILE *fp, void *dst, size_t size) {
    return fread(dst, 1, size, fp) == size;
}

static int seek_to(FILE *fp, uint32_t offset) {
    return offset <= MAX_RIFF_SIZE && fseek(fp, (long)offset, SEEK_SET) == 0;
}

static int codec_supported(const char *handler, const char *compression) {
    return !memcmp(handler, "XVID", 4) ||
           !memcmp(handler, "DIVX", 4) ||
           !memcmp(handler, "DX50", 4) ||
           !memcmp(handler, "MP4V", 4) ||
           !memcmp(compression, "XVID", 4) ||
           !memcmp(compression, "DIVX", 4) ||
           !memcmp(compression, "DX50", 4) ||
           !memcmp(compression, "MP4V", 4);
}

static int parse_stream_list(FILE *fp, uint32_t start, uint32_t end,
                             AviStreamInfo *info) {
    unsigned char hdr[8];
    unsigned char strh[56];
    unsigned char strf[40];
    uint32_t pos = start;

    memset(info, 0, sizeof(*info));
    while (pos + 8 <= end) {
        uint32_t size, data, next;
        if (!seek_to(fp, pos) || !read_exact(fp, hdr, 8)) return 0;
        size = le32(hdr + 4);
        data = pos + 8;
        next = data + size + (size & 1U);
        if (next < data || next > end) return 0;

        if (!memcmp(hdr, "strh", 4) && size >= sizeof(strh)) {
            if (!seek_to(fp, data) || !read_exact(fp, strh, sizeof(strh)))
                return 0;
            info->is_video = !memcmp(strh, "vids", 4);
            memcpy(info->handler, strh + 4, 4);
            info->handler[4] = '\0';
        } else if (!memcmp(hdr, "strf", 4) && size >= sizeof(strf)) {
            if (!seek_to(fp, data) || !read_exact(fp, strf, sizeof(strf)))
                return 0;
            info->width = le32(strf + 4);
            info->height = le32(strf + 8);
            memcpy(info->compression, strf + 16, 4);
            info->compression[4] = '\0';
        }
        pos = next;
    }
    info->found = info->is_video;
    return 1;
}

static int parse_hdrl(FILE *fp, uint32_t start, uint32_t end,
                      AviStreamInfo *first_stream, int *stream_count) {
    unsigned char hdr[8], list_type[4];
    uint32_t pos = start;

    *stream_count = 0;
    memset(first_stream, 0, sizeof(*first_stream));
    while (pos + 8 <= end) {
        uint32_t size, data, next;
        if (!seek_to(fp, pos) || !read_exact(fp, hdr, 8)) return 0;
        size = le32(hdr + 4);
        data = pos + 8;
        next = data + size + (size & 1U);
        if (next < data || next > end) return 0;

        if (!memcmp(hdr, "LIST", 4) && size >= 4) {
            if (!seek_to(fp, data) || !read_exact(fp, list_type, 4))
                return 0;
            if (!memcmp(list_type, "strl", 4)) {
                AviStreamInfo current;
                if (!parse_stream_list(fp, data + 4, data + size, &current))
                    return 0;
                if (*stream_count == 0) *first_stream = current;
                (*stream_count)++;
            }
        }
        pos = next;
    }
    return 1;
}

AviProbeResult avi_probe(const char *path, char *message, size_t message_size) {
    FILE *fp;
    unsigned char riff[12], hdr[8], list_type[4];
    uint32_t riff_end, pos;
    int have_hdrl = 0, have_index = 0, stream_count = 0;
    AviStreamInfo first_stream;

    if (message && message_size) message[0] = '\0';
    fp = fopen(path, "rb");
    if (!fp) {
        if (message && message_size) snprintf(message, message_size, "Impossibile aprire il file");
        return AVI_PROBE_OPEN_FAILED;
    }

    if (!read_exact(fp, riff, sizeof(riff)) ||
        memcmp(riff, "RIFF", 4) || memcmp(riff + 8, "AVI ", 4)) {
        fclose(fp);
        if (message && message_size) snprintf(message, message_size, "Non e un AVI valido");
        return AVI_PROBE_BAD_CONTAINER;
    }

    riff_end = le32(riff + 4) + 8;
    if (riff_end < 12 || riff_end > MAX_RIFF_SIZE) {
        fclose(fp);
        if (message && message_size) snprintf(message, message_size, "Dimensione AVI non valida");
        return AVI_PROBE_BAD_CONTAINER;
    }

    pos = 12;
    while (pos + 8 <= riff_end) {
        uint32_t size, data, next;
        if (!seek_to(fp, pos) || !read_exact(fp, hdr, 8)) break;
        size = le32(hdr + 4);
        data = pos + 8;
        next = data + size + (size & 1U);
        if (next < data || next > riff_end) break;

        if (!memcmp(hdr, "idx1", 4)) have_index = 1;
        if (!memcmp(hdr, "LIST", 4) && size >= 4) {
            if (!seek_to(fp, data) || !read_exact(fp, list_type, 4)) break;
            if (!memcmp(list_type, "hdrl", 4)) {
                have_hdrl = parse_hdrl(fp, data + 4, data + size,
                                       &first_stream, &stream_count);
                if (!have_hdrl) break;
            }
        }
        pos = next;
    }
    fclose(fp);

    if (!have_hdrl || stream_count == 0 || !first_stream.found) {
        if (message && message_size) snprintf(message, message_size, "Traccia video non trovata o non prima");
        return AVI_PROBE_UNSUPPORTED_VIDEO;
    }
    if (!have_index) {
        if (message && message_size) snprintf(message, message_size, "AVI senza indice idx1");
        return AVI_PROBE_NO_INDEX;
    }
    if (!codec_supported(first_stream.handler, first_stream.compression)) {
        if (message && message_size) snprintf(message, message_size, "Codec video non supportato");
        return AVI_PROBE_UNSUPPORTED_VIDEO;
    }

    if (first_stream.width != 256 || first_stream.height == 0 ||
        first_stream.height > 192) {
        if (message && message_size) snprintf(message, message_size, "Serve video 256x massimo 192");
        return AVI_PROBE_BAD_DIMENSIONS;
    }

    if (message && message_size)
        snprintf(message, message_size, "AVI compatibile: %lux%lu (decoder da integrare)",
                 (unsigned long)first_stream.width,
                 (unsigned long)first_stream.height);
    return AVI_PROBE_OK;
}
