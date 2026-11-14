# Strumenti macOS Big Sur per Dai-MP4

Questa cartella contiene gli strumenti per preparare e compilare il progetto Nintendo DS/DSi dal Mac.

## Importante: stato reale del progetto

Dai-MP4 è ancora uno scaffold: l'interfaccia e la selezione dei file sono in sviluppo. Il decoder video e la riproduzione audio **non sono ancora implementati**. La conversione AVI qui sotto prepara un file di prova nel profilo sperimentale, ma non rende ancora possibile riprodurlo sulla console.

## Requisiti

- macOS Big Sur 11.
- Xcode Command Line Tools (xcode-select --install).
- devkitPro con devkitARM, libnds e libfat.
- FFmpeg (include ffprobe).

## 1. Installa gli strumenti

Esegui nel Terminale:

~~~bash
xcode-select --install
~~~

Installa devkitPro seguendo la guida ufficiale: https://devkitpro.org/wiki/Getting_Started

Nel setup devkitPro seleziona devkitARM e i pacchetti libnds e libfat. Poi configura le variabili DEVKITPRO e DEVKITARM come indicato dall'installer.

Se Homebrew è già installato, FFmpeg si installa con:

~~~bash
brew install ffmpeg
~~~

Non scaricare ffprobe da endpoint API non documentati: FFmpeg installato con Homebrew include anche ffprobe.

## 2. Compila Dai-MP4

Dalla cartella principale del repository:

~~~bash
chmod +x macos/build.sh macos/convert-video.sh
./macos/build.sh
~~~

Se la compilazione riesce, il file atteso è Dai-MP4.nds nella cartella principale.

## 3. Prepara un AVI di test

~~~bash
./macos/convert-video.sh "video-originale.mp4"
~~~

Il risultato sarà video-originale-dsi-test.avi nella stessa cartella del video sorgente. Profilo sperimentale: 256x192, 10 fps, MPEG-4 Part 2/Xvid e MP3 a 32 kHz.

Questo profilo è solo un obiettivo iniziale di compatibilità da testare su hardware. Non è una garanzia di riproduzione.

## Diagnostica

~~~bash
uname -m
sw_vers
command -v ffmpeg
command -v ffprobe
echo "$DEVKITPRO"
echo "$DEVKITARM"
~~~

Se il Mac restituisce x86_64, è Intel. Se restituisce arm64, è Apple Silicon. Il progetto documenta attualmente il futuro convertitore Big Sur Intel, ma la toolchain devkitPro va verificata sul Mac specifico.
