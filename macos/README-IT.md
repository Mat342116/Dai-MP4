# Strumenti macOS Big Sur Intel per Dai-MP4

Questa cartella prepara video AVI di test e verifica FFmpeg/FFprobe sul Mac Intel.

## Stato del progetto (da leggere)

Dai-MP4 è un prototipo homebrew Nintendo DS/DSi. L'interfaccia mostra la lista dei file AVI e il comando PLAY esegue soltanto un controllo preliminare dei metadati. **Non esiste ancora un decoder video/audio: il file convertito NON può essere riprodotto dal programma sulla console.** Questi strumenti permettono di preparare e controllare i campioni necessari allo sviluppo.

## Requisiti

- macOS Big Sur 11 su Mac Intel (x86_64).
- Connessione Internet per installare gli strumenti.
- Homebrew.
- Per compilare il programma DSi: devkitPro con devkitARM, libnds e libfat.

## 1. Installa FFmpeg e FFprobe

Apri Terminale nella cartella del progetto ed esegui:

```bash
chmod +x macos/*.sh
./macos/install-deps.sh
```

Se Homebrew manca, installalo dal sito ufficiale https://brew.sh/ e rilancia il comando. FFprobe viene installato insieme a FFmpeg.

Controlla l'installazione:

```bash
./macos/check-ffmpeg.sh
```

Il controllo verifica i percorsi di entrambi i programmi e l'encoder MP3. Se la build non offre `libxvid`, lo script di conversione usa l'encoder MPEG-4 Part 2 integrato di FFmpeg e imposta comunque il tag AVI `XVID`. Quindi l'assenza di `libxvid` non è di per sé un errore.

## 2. Converti un video di prova

```bash
./macos/convert-video.sh "/percorso/al/video.mp4"
```

Puoi anche specificare il nome del file destinazione:

```bash
./macos/convert-video.sh "/percorso/al/video.mp4" "/percorso/uscita/test.avi"
```

Profilo sperimentale: 256x192, 10 fps, MPEG-4 Part 2 con tag XVID, MP3 32 kHz stereo. L'immagine viene adattata senza deformarla.

## 3. Compila il programma Nintendo DS/DSi

Installa devkitPro seguendo https://devkitpro.org/wiki/Getting_Started e assicurati di avere devkitARM, libnds e libfat. Dopo aver configurato le variabili DEVKITPRO e DEVKITARM:

```bash
./macos/build.sh
```

Il risultato atteso è `Dai-MP4.nds` nella cartella principale.

## 4. Prova sulla console (solo test del prototipo)

Copia `Dai-MP4.nds` e un AVI convertito nella root della scheda SD. Avvia il file .nds con il tuo ambiente homebrew. Il browser dovrebbe mostrare il nome AVI; PLAY verifica alcuni metadati e mostra un messaggio di validazione. Non avvia la riproduzione.

## Diagnostica

Se qualcosa non funziona, copia qui l'output di:

```bash
sw_vers
uname -m
command -v ffmpeg
command -v ffprobe
ffmpeg -hide_banner -encoders | grep -E 'libxvid|libmp3lame|mpeg4'
```
