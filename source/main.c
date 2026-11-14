#include <nds.h>
#include <fat.h>
#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <stdbool.h>

#define MAX_FILES 64
#define NAME_LEN 256
#define VISIBLE_ROWS 16

static PrintConsole topConsole, bottomConsole;
static char videoFiles[MAX_FILES][NAME_LEN];
static int videoCount = 0;
static int selectedFile = -1;
static int firstVisible = 0;
static bool browserOpen = false;
static bool sdReady = false;
static bool playRequested = false;

static bool is_video_file(const char *name) {
    const char *dot = strrchr(name, '.');
    if (!dot) return false;
    return strcasecmp(dot, ".mp4") == 0 ||
           strcasecmp(dot, ".avi") == 0 ||
           strcasecmp(dot, ".fv") == 0 ||
           strcasecmp(dot, ".rvid") == 0;
}

static void scan_sd_root(void) {
    DIR *dir;
    struct dirent *entry;

    videoCount = 0;
    if (selectedFile >= MAX_FILES) selectedFile = -1;
    firstVisible = selectedFile >= VISIBLE_ROWS ? selectedFile - VISIBLE_ROWS + 1 : 0;

    dir = opendir("fat:/");
    if (!dir) return;

    while ((entry = readdir(dir)) != NULL && videoCount < MAX_FILES) {
        if (entry->d_name[0] == '.' || !is_video_file(entry->d_name))
            continue;

        strncpy(videoFiles[videoCount], entry->d_name, NAME_LEN - 1);
        videoFiles[videoCount][NAME_LEN - 1] = '\0';
        videoCount++;
    }
    closedir(dir);
}

static void draw_top_screen(void) {
    consoleSelect(&topConsole);
    consoleClear();
    iprintf("\n\n\n\n");
    iprintf("          DAI-MP4\n\n");
    iprintf("  Il video verra mostrato qui.\n");
    iprintf("\n\n\n");
    iprintf("  Lettore in sviluppo");
}

static void draw_home(void) {
    consoleSelect(&bottomConsole);
    consoleClear();

    iprintf("          DAI-MP4\n");
    iprintf("------------------------------\n\n");
    iprintf("START: apri selezione video\n\n");
    iprintf("File selezionato:\n");
    if (selectedFile >= 0 && selectedFile < videoCount)
        iprintf("%.27s\n", videoFiles[selectedFile]);
    else
        iprintf("(nessuno)\n");

    iprintf("\n");
    iprintf("   [ PLAY ]       [ STOP ]\n");
    iprintf("\n");
    if (!sdReady)
        iprintf("Errore: scheda SD non disponibile\n");
    else if (playRequested)
        iprintf("PLAY ricevuto: decoder da integrare\n");
    else
        iprintf("Pronto. Riproduzione da integrare.\n");
    iprintf("\nVideo previsto sullo schermo superiore");
}

static void draw_browser(void) {
    int i;
    consoleSelect(&bottomConsole);
    consoleClear();

    iprintf("          SCEGLI VIDEO\n");
    iprintf("------------------------------\n");
    iprintf("Tocca un file per selezionarlo\n\n");

    if (!sdReady) {
        iprintf("Scheda SD non disponibile.\n");
    } else if (videoCount == 0) {
        iprintf("Nessun video nella cartella SD.\n");
    } else {
        for (i = 0; i < VISIBLE_ROWS && firstVisible + i < videoCount; i++) {
            int index = firstVisible + i;
            iprintf("%c %.27s\n",
                    index == selectedFile ? '>' : ' ',
                    videoFiles[index]);
        }
        iprintf("\n");
        iprintf("A/B o frecce: naviga  ");
        iprintf("%d/%d\n", selectedFile + 1, videoCount);
    }
    iprintf("\nSTART: torna al lettore");
}

static void move_selection(int delta) {
    if (videoCount == 0) return;

    if (selectedFile < 0)
        selectedFile = 0;
    else
        selectedFile += delta;

    if (selectedFile < 0) selectedFile = 0;
    if (selectedFile >= videoCount) selectedFile = videoCount - 1;

    if (selectedFile < firstVisible)
        firstVisible = selectedFile;
    if (selectedFile >= firstVisible + VISIBLE_ROWS)
        firstVisible = selectedFile - VISIBLE_ROWS + 1;
}

int main(void) {
    videoSetMode(MODE_0_2D);
    videoSetModeSub(MODE_0_2D);
    vramSetBankA(VRAM_A_MAIN_BG);
    vramSetBankC(VRAM_C_SUB_BG);

    consoleInit(&topConsole, 0, BgType_Text4bpp, BgSize_T_256x256,
                31, 0, true, true);
    consoleInit(&bottomConsole, 0, BgType_Text4bpp, BgSize_T_256x256,
                31, 0, false, true);

    sdReady = fatInitDefault();
    if (sdReady) scan_sd_root();

    draw_top_screen();
    draw_home();

    while (1) {
        scanKeys();
        u32 down = keysDown();

        if (down & KEY_START) {
            browserOpen = !browserOpen;
            if (browserOpen) {
                if (sdReady) scan_sd_root();
                draw_browser();
            } else {
                draw_home();
            }
        }

        if (browserOpen) {
            if (down & KEY_UP) {
                move_selection(-1);
                draw_browser();
            }
            if (down & KEY_DOWN) {
                move_selection(1);
                draw_browser();
            }
            if (down & KEY_A) {
                if (selectedFile >= 0) {
                    browserOpen = false;
                    draw_home();
                }
            }
            if (down & KEY_TOUCH) {
                touchPosition touch;
                touchRead(&touch);
                /* Header uses four text rows; each console row is 8 pixels. */
                int row = (touch.py / 8) - 4;
                int index = firstVisible + row;
                if (row >= 0 && row < VISIBLE_ROWS && index < videoCount) {
                    selectedFile = index;
                    browserOpen = false;
                    draw_home();
                }
            }
        } else if (down & KEY_TOUCH) {
            touchPosition touch;
            touchRead(&touch);
            /* PLAY and STOP occupy text row 9 on the lower screen. */
            if (touch.py >= 64 && touch.py < 80) {
                if (touch.px >= 16 && touch.px < 112) {
                    if (selectedFile >= 0) playRequested = true;
                } else if (touch.px >= 144 && touch.px < 232) {
                    playRequested = false;
                }
                draw_home();
            }
        }

        swiWaitForVBlank();
    }

    return 0;
}
