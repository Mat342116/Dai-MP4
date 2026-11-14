#include <nds.h>
#include <fat.h>
#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <stdbool.h>
#define MAX_FILES 64
#define NAME_LEN 256
static PrintConsole topConsole, bottomConsole;
static char videoFiles[MAX_FILES][NAME_LEN];
static int videoCount, selectedFile = -1;
static bool browserOpen;
static bool is_video_file(const char *name) {
 const char *dot = strrchr(name, '.');
 if (!dot) return false;
 return strcasecmp(dot, ".mp4") == 0 || strcasecmp(dot, ".avi") == 0 ||
        strcasecmp(dot, ".fv") == 0 || strcasecmp(dot, ".rvid") == 0;
}
static void scan_sd_root(void) {
 DIR *dir = opendir("fat:/"); struct dirent *entry; videoCount = 0;
 if (!dir) return;
 while ((entry = readdir(dir)) && videoCount < MAX_FILES) {
  if (entry->d_name[0] == '.' || !is_video_file(entry->d_name)) continue;
  strncpy(videoFiles[videoCount], entry->d_name, NAME_LEN - 1);
  videoFiles[videoCount][NAME_LEN - 1] = '\0'; videoCount++;
 }
 closedir(dir);
}
static void draw_home(void) {
 consoleSelect(&bottomConsole); consoleClear();
 iprintf("          DAI-MP4\n------------------------------\n\n");
 iprintf("START: scegli un file\n\nSelezionato:\n");
 if (selectedFile >= 0 && selectedFile < videoCount) iprintf("%s\n", videoFiles[selectedFile]);
 else iprintf("(nessuno)\n");
 iprintf("\n\n   [ PLAY ]       [ STOP ]\n");
 iprintf("\nVideo sullo schermo superiore\nDecoder video: da integrare\n");
}
static void draw_browser(void) {
 consoleSelect(&bottomConsole); consoleClear();
 iprintf("          SCEGLI VIDEO\n------------------------------\nTocca il nome del file\n\n");
 for (int i = 0; i < videoCount; i++)
  iprintf("%c %02d  %s\n", i == selectedFile ? '>' : ' ', i + 1, videoFiles[i]);
 if (!videoCount) iprintf("Nessun video trovato\n");
 iprintf("\nSTART: torna al lettore\n");
}
int main(void) {
 videoSetMode(MODE_0_2D); videoSetModeSub(MODE_0_2D);
 vramSetBankA(VRAM_A_MAIN_BG); vramSetBankC(VRAM_C_SUB_BG);
 consoleInit(&topConsole, 0, BgType_Text4bpp, BgSize_T_256x256, 31, 0, true, true);
 consoleInit(&bottomConsole, 0, BgType_Text4bpp, BgSize_T_256x256, 31, 0, false, true);
 consoleSelect(&topConsole); consoleClear();
 bool sdReady = fatInitDefault(); if (sdReady) scan_sd_root(); draw_home();
 while (1) {
  scanKeys(); u32 down = keysDown();
  if (down & KEY_START) {
   browserOpen = !browserOpen;
   if (browserOpen) scan_sd_root();
   if (browserOpen) draw_browser(); else draw_home();
  }
  if (down & KEY_TOUCH) {
   touchPosition touch; touchRead(&touch);
   if (browserOpen) {
    int row = (touch.py - 32) / 8;
    if (row >= 0 && row < videoCount) { selectedFile = row; draw_browser(); }
   } else if (touch.py > 150) {
    /* PLAY/STOP hitboxes are placeholders until the graphical UI is implemented. */
    draw_home();
   }
  }
  swiWaitForVBlank();
 }
 return 0;
}
