#include "avi.h"
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define MAX_RIFF_SIZE 0x7fffffffUL
typedef struct { int found; uint32_t width, height; char handler[5], compression[5]; } AviStreamInfo;

static uint32_t le32(const unsigned char *p) {
    return (uint32_t)p[0] | ((uint32_t)p[1]<<8) | ((uint32_t)p[2]<<16) | ((uint32_t)p[3]<<24);
}
static int read_exact(FILE *f, void *p, size_t n) { return fread(p,1,n,f)==n; }
static int seek_to(FILE *f, uint32_t p) { return p<=MAX_RIFF_SIZE && fseek(f,(long)p,SEEK_SET)==0; }

/* Validate the complete chunk, including its even-byte padding, before use. */
static int chunk_at(FILE *f, uint32_t pos, uint32_t end, unsigned char h[8],
                    uint32_t *data, uint32_t *next) {
    uint64_t d, n;
    if ((uint64_t)pos+8U>end || !seek_to(f,pos) || !read_exact(f,h,8)) return 0;
    d=(uint64_t)pos+8U;
    n=d+(uint64_t)le32(h+4)+(le32(h+4)&1U);
    if(n>end || n>MAX_RIFF_SIZE) return 0;
    *data=(uint32_t)d; *next=(uint32_t)n; return 1;
}
static int codec_ok(const char *a,const char *b) {
    static const char *ids[]={"XVID","DIVX","DX50","MP4V"};
    unsigned i; for(i=0;i<4;i++) if(!memcmp(a,ids[i],4)||!memcmp(b,ids[i],4)) return 1;
    return 0;
}
static int parse_strl(FILE *f,uint32_t start,uint32_t end,AviStreamInfo *out) {
    unsigned char h[8],sh[56],sf[40]; uint32_t p=start,d,n; int video=0,format=0;
    memset(out,0,sizeof(*out));
    while(p<end) {
        uint32_t size;
        if(!chunk_at(f,p,end,h,&d,&n)) return 0;
        size=le32(h+4);
        if(!memcmp(h,"strh",4)&&size>=sizeof(sh)) {
            if(!seek_to(f,d)||!read_exact(f,sh,sizeof(sh))) return 0;
            video=!memcmp(sh,"vids",4); memcpy(out->handler,sh+4,4); out->handler[4]=0;
        } else if(!memcmp(h,"strf",4)&&size>=sizeof(sf)) {
            if(!seek_to(f,d)||!read_exact(f,sf,sizeof(sf))) return 0;
            out->width=le32(sf+4); out->height=le32(sf+8);
            memcpy(out->compression,sf+16,4); out->compression[4]=0; format=1;
        }
        p=n;
    }
    out->found=video&&format; return 1;
}
static int parse_hdrl(FILE *f,uint32_t start,uint32_t end,AviStreamInfo *video,int *count) {
    unsigned char h[8],type[4]; uint32_t p=start,d,n; *count=0; memset(video,0,sizeof(*video));
    while(p<end) {
        uint32_t size;
        if(!chunk_at(f,p,end,h,&d,&n)) return 0;
        size=le32(h+4);
        if(!memcmp(h,"LIST",4)&&size>=4) {
            if(!seek_to(f,d)||!read_exact(f,type,4)) return 0;
            if(!memcmp(type,"strl",4)) {
                AviStreamInfo cur;
                if(!parse_strl(f,d+4,d+size,&cur)) return 0;
                ++*count;
                /* Audio streams can precede video in AVI headers. */
                if(!video->found&&cur.found) *video=cur;
            }
        }
        p=n;
    }
    return 1;
}
AviProbeResult avi_probe(const char *path,char *msg,size_t cap) {
    FILE *f; unsigned char riff[12],h[8],type[4]; uint32_t end,p,d,n;
    long length; int hdrl=0,index=0,count=0; AviStreamInfo video;
    if(msg&&cap) msg[0]=0;
    f=fopen(path,"rb");
    if(!f) { if(msg&&cap) snprintf(msg,cap,"Impossibile aprire il file"); return AVI_PROBE_OPEN_FAILED; }
    if(fseek(f,0,SEEK_END)|| (length=ftell(f))<12 || length>(long)MAX_RIFF_SIZE ||
       fseek(f,0,SEEK_SET)||!read_exact(f,riff,12)||memcmp(riff,"RIFF",4)||memcmp(riff+8,"AVI ",4)) {
        fclose(f); if(msg&&cap) snprintf(msg,cap,"Non e un AVI valido o leggibile"); return AVI_PROBE_BAD_CONTAINER;
    }
    {
        uint64_t e=(uint64_t)le32(riff+4)+8U;
        if(e<12U||e>(uint64_t)length||e>MAX_RIFF_SIZE) {
            fclose(f); if(msg&&cap) snprintf(msg,cap,"Dimensione AVI non valida o file troncato"); return AVI_PROBE_BAD_CONTAINER;
        }
        end=(uint32_t)e;
    }
    p=12;
    while(p<end) {
        uint32_t size;
        if(!chunk_at(f,p,end,h,&d,&n)) {
            fclose(f); if(msg&&cap) snprintf(msg,cap,"Struttura RIFF/AVI danneggiata"); return AVI_PROBE_BAD_CONTAINER;
        }
        size=le32(h+4);
        if(!memcmp(h,"idx1",4)&&size>=16U) index=1;
        if(!memcmp(h,"LIST",4)&&size>=4U) {
            if(!seek_to(f,d)||!read_exact(f,type,4)) {
                fclose(f); if(msg&&cap) snprintf(msg,cap,"LIST AVI incompleta"); return AVI_PROBE_BAD_CONTAINER;
            }
            if(!memcmp(type,"hdrl",4)) {
                if(!parse_hdrl(f,d+4,d+size,&video,&count)) {
                    fclose(f); if(msg&&cap) snprintf(msg,cap,"Header AVI danneggiato"); return AVI_PROBE_BAD_CONTAINER;
                }
                hdrl=1;
            }
        }
        p=n;
    }
    fclose(f);
    if(!hdrl||!count||!video.found) { if(msg&&cap) snprintf(msg,cap,"Traccia video non trovata"); return AVI_PROBE_UNSUPPORTED_VIDEO; }
    if(!index) { if(msg&&cap) snprintf(msg,cap,"AVI senza indice idx1 valido"); return AVI_PROBE_NO_INDEX; }
    if(!codec_ok(video.handler,video.compression)) { if(msg&&cap) snprintf(msg,cap,"Codec video non supportato"); return AVI_PROBE_UNSUPPORTED_VIDEO; }
    if(video.width!=256U||!video.height||video.height>192U) {
        if(msg&&cap) snprintf(msg,cap,"Serve video largo 256 e alto massimo 192"); return AVI_PROBE_BAD_DIMENSIONS;
    }
    if(msg&&cap) snprintf(msg,cap,"AVI compatibile: %lux%lu (solo metadati)",(unsigned long)video.width,(unsigned long)video.height);
    return AVI_PROBE_OK;
}
