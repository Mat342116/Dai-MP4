#include "avi.h"
#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

static unsigned char buf[512];
static size_t n;
static void four(const char *s) { memcpy(buf+n,s,4); n+=4; }
static void u32(uint32_t v) {
    buf[n++]=(unsigned char)v; buf[n++]=(unsigned char)(v>>8);
    buf[n++]=(unsigned char)(v>>16); buf[n++]=(unsigned char)(v>>24);
}
static size_t begin(const char *id) { four(id); size_t p=n; u32(0); return p; }
static void end(size_t p) {
    uint32_t z=(uint32_t)(n-p-4);
    buf[p]=(unsigned char)z; buf[p+1]=(unsigned char)(z>>8);
    buf[p+2]=(unsigned char)(z>>16); buf[p+3]=(unsigned char)(z>>24);
    if(z&1U) buf[n++]=0;
}
static void stream(const char *kind,const char *codec,uint32_t w,uint32_t h) {
    size_t l=begin("LIST"); four("strl");
    size_t s=begin("strh"); four(kind); four(codec);
    while(n<s+4+56) buf[n++]=0;
    end(s);
    s=begin("strf"); u32(40); u32(w); u32(h); u32(1); u32(24); four(codec);
    while(n<s+4+40) buf[n++]=0;
    end(s); end(l);
}
static void fixture(int audio_first,uint32_t width,int index) {
    n=0; four("RIFF"); u32(0); four("AVI ");
    size_t l=begin("LIST"); four("hdrl");
    if(audio_first) stream("auds","    ",0,0);
    stream("vids","XVID",width,192);
    end(l);
    if(index) { size_t x=begin("idx1"); while(n<x+20) buf[n++]=0; end(x); }
    uint32_t z=(uint32_t)(n-8);
    buf[4]=(unsigned char)z; buf[5]=(unsigned char)(z>>8);
    buf[6]=(unsigned char)(z>>16); buf[7]=(unsigned char)(z>>24);
}
static AviProbeResult run(void) {
    FILE *f=fopen("avi-test.tmp","wb"); assert(f);
    assert(fwrite(buf,1,n,f)==n); fclose(f);
    return avi_probe("avi-test.tmp",NULL,0);
}
int main(void) {
    fixture(0,256,1); assert(run()==AVI_PROBE_OK);
    fixture(1,256,1); assert(run()==AVI_PROBE_OK);
    fixture(0,320,1); assert(run()==AVI_PROBE_BAD_DIMENSIONS);
    fixture(0,256,0); assert(run()==AVI_PROBE_NO_INDEX);
    fixture(0,256,1); n-=7; assert(run()==AVI_PROBE_BAD_CONTAINER);
    remove("avi-test.tmp"); puts("AVI parser tests passed"); return 0;
}
