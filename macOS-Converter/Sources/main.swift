import Cocoa
import Foundation

final class ConverterApp: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var input: NSTextField!
    var output: NSTextField!
    var status: NSTextField!
    var log: NSTextView!
    var convertButton: NSButton!

    private let videoWidth = 256
    private let videoHeight = 192
    private let frameRate = 15
    private let audioRate = 32000
    private let bytesPerFrame = 256 * 192 * 2
    private let fat32SafeLimit: UInt64 = 3_900_000_000

    func applicationDidFinishLaunching(_ notification: Notification) { buildUI() }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    private func field(_ value: String) -> NSTextField {
        let result = NSTextField(string: value)
        result.isEditable = false
        result.isSelectable = true
        result.lineBreakMode = .byTruncatingMiddle
        result.font = .systemFont(ofSize: 11)
        return result
    }

    private func button(_ title: String, _ action: Selector) -> NSButton {
        let result = NSButton(title: title, target: self, action: action)
        result.bezelStyle = .rounded
        return result
    }

    private func buildUI() {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 410),
                          styleMask: [.titled, .closable, .miniaturizable],
                          backing: .buffered, defer: false)
        window.title = "Dai-MP4 Converter"
        let root = NSView(frame: NSRect(x: 0, y: 0, width: 640, height: 410))
        window.contentView = root

        let heading = NSTextField(labelWithString: "Converti video per Nintendo DSi")
        heading.font = .boldSystemFont(ofSize: 21)
        heading.frame = NSRect(x: 24, y: 362, width: 590, height: 30)
        root.addSubview(heading)

        let subtitle = NSTextField(labelWithString: "Rocket Video · .rvid · RGB565 256×192 · 15 fps · audio PCM 32 kHz")
        subtitle.textColor = .secondaryLabelColor
        subtitle.frame = NSRect(x: 25, y: 337, width: 590, height: 20)
        root.addSubview(subtitle)

        input = field("Nessun video selezionato")
        input.frame = NSRect(x: 24, y: 290, width: 475, height: 28)
        root.addSubview(input)
        let choose = button("Scegli video…", #selector(chooseInput))
        choose.frame = NSRect(x: 508, y: 289, width: 108, height: 30)
        root.addSubview(choose)

        output = field("Scegli dove salvare il file RVID")
        output.frame = NSRect(x: 24, y: 245, width: 475, height: 28)
        root.addSubview(output)
        let destination = button("Destinazione…", #selector(chooseOutput))
        destination.frame = NSRect(x: 508, y: 244, width: 108, height: 30)
        root.addSubview(destination)

        let note = NSTextField(labelWithString: "Video non compresso RGB565: file grandi. Compatibile con Rocket Video Player (.rvid).")
        note.font = .systemFont(ofSize: 11)
        note.textColor = .secondaryLabelColor
        note.frame = NSRect(x: 25, y: 214, width: 590, height: 18)
        root.addSubview(note)

        let scroll = NSScrollView(frame: NSRect(x: 24, y: 70, width: 592, height: 132))
        scroll.hasVerticalScroller = true
        scroll.borderType = .bezelBorder
        log = NSTextView(frame: scroll.bounds)
        log.isEditable = false
        log.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        log.string = "Pronto. Seleziona un video e la destinazione.\n"
        scroll.documentView = log
        root.addSubview(scroll)

        status = NSTextField(labelWithString: "In attesa")
        status.frame = NSRect(x: 25, y: 37, width: 420, height: 20)
        root.addSubview(status)

        convertButton = button("Converti", #selector(convert))
        convertButton.frame = NSRect(x: 490, y: 27, width: 126, height: 34)
        convertButton.keyEquivalent = "\r"
        root.addSubview(convertButton)

        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func chooseInput() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["mp4", "m4v", "mov", "mkv", "avi"]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            input.stringValue = url.path
            if output.stringValue == "Scegli dove salvare il file RVID" {
                output.stringValue = url.deletingPathExtension().appendingPathExtension("rvid").path
            }
        }
    }

    @objc private func chooseOutput() {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["rvid"]
        panel.nameFieldStringValue = "video-DSi.rvid"
        if panel.runModal() == .OK, let url = panel.url {
            output.stringValue = url.path
        }
    }

    @objc private func convert() {
        let source = input.stringValue
        let destination = output.stringValue
        guard !source.isEmpty, FileManager.default.fileExists(atPath: source) else {
            alert("Seleziona un video sorgente valido.")
            return
        }
        guard !destination.isEmpty, destination != "Scegli dove salvare il file RVID" else {
            alert("Scegli dove salvare il file RVID.")
            return
        }
        guard URL(fileURLWithPath: source).standardizedFileURL != URL(fileURLWithPath: destination).standardizedFileURL else {
            alert("Il file di destinazione deve essere diverso dal video originale.")
            return
        }
        guard let ffmpeg = findTool("ffmpeg"), let ffprobe = findTool("ffprobe") else {
            alert("FFmpeg e ffprobe non trovati. Installa FFmpeg e riapri l'app.")
            return
        }

        convertButton.isEnabled = false
        status.stringValue = "Conversione in corso…"
        append("Preparazione conversione Rocket Video (.rvid)…")

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.performConversion(source: source, destination: destination,
                                           ffmpeg: ffmpeg, ffprobe: ffprobe)
                DispatchQueue.main.async {
                    self.status.stringValue = "Conversione completata"
                    self.append("File RVID creato: \(destination)")
                    self.convertButton.isEnabled = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.status.stringValue = "Conversione non riuscita"
                    self.append("ERRORE: \(error.localizedDescription)")
                    self.convertButton.isEnabled = true
                    self.alert(error.localizedDescription)
                }
            }
        }
    }

    private func performConversion(source: String, destination: String,
                                   ffmpeg: String, ffprobe: String) throws {
        let manager = FileManager.default
        let work = manager.temporaryDirectory.appendingPathComponent("DaiMP4-\(UUID().uuidString)", isDirectory: true)
        try manager.createDirectory(at: work, withIntermediateDirectories: true)
        defer { try? manager.removeItem(at: work) }

        let videoURL = work.appendingPathComponent("video.rgb565")
        let stereoURL = work.appendingPathComponent("audio.stereo.pcm")
        let leftURL = work.appendingPathComponent("audio.left.pcm")
        let rightURL = work.appendingPathComponent("audio.right.pcm")

        DispatchQueue.main.async { self.append("1/3 · Conversione video RGB565 256×192 a 15 fps…") }
        _ = try runTool(ffprobe, ["-v", "error", "-select_streams", "v:0",
                                  "-show_entries", "stream=codec_name", "-of", "csv=p=0", source])
        try runTool(ffmpeg, ["-hide_banner", "-loglevel", "error", "-y", "-i", source,
                             "-map", "0:v:0",
                             "-vf", "scale=256:192:force_original_aspect_ratio=decrease,pad=256:192:(ow-iw)/2:(oh-ih)/2,fps=15,format=rgb565le",
                             "-an", "-f", "rawvideo", videoURL.path])

        let videoAttributes = try manager.attributesOfItem(atPath: videoURL.path)
        let videoBytes = (videoAttributes[.size] as? NSNumber)?.uint64Value ?? 0
        guard videoBytes > 0, videoBytes % UInt64(bytesPerFrame) == 0 else {
            throw conversionError("Il video generato non contiene un numero valido di fotogrammi RGB565.")
        }
        let frameCount = videoBytes / UInt64(bytesPerFrame)
        guard frameCount <= UInt64(UInt32.max) else {
            throw conversionError("Il video è troppo lungo per il formato RVID.")
        }

        let audioProbe = try runTool(ffprobe, ["-v", "error", "-select_streams", "a:0",
                                               "-show_entries", "stream=index", "-of", "csv=p=0", source])
        let hasAudio = !audioProbe.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let secondsRoundedUp = (frameCount + UInt64(frameRate) - 1) / UInt64(frameRate)
        let audioSamples = hasAudio ? secondsRoundedUp * UInt64(audioRate) : 0
        let audioBytes = audioSamples * 4
        let estimatedSize = 512 + videoBytes + audioBytes
        guard estimatedSize < fat32SafeLimit else {
            throw conversionError("Il file supererebbe il limite prudente di 3,9 GB per schede SD FAT32. Prova un video più corto.")
        }

        if hasAudio {
            DispatchQueue.main.async { self.append("2/3 · Estrazione audio stereo PCM 16 bit a 32 kHz…") }
            try runTool(ffmpeg, ["-hide_banner", "-loglevel", "error", "-y", "-i", source,
                                 "-map", "0:a:0", "-vn", "-ac", "2", "-ar", "32000",
                                 "-c:a", "pcm_s16le", "-f", "s16le", stereoURL.path])
            try deinterleaveAudio(stereoURL: stereoURL, leftURL: leftURL,
                                  rightURL: rightURL, samples: audioSamples)
        }

        DispatchQueue.main.async { self.append("3/3 · Creazione intestazione RVID e assemblaggio file…") }
        let leftOffset = hasAudio ? UInt32(512 + videoBytes) : 0
        let rightOffset = hasAudio ? UInt32(UInt64(leftOffset) + audioSamples * 2) : 0
        let header = makeHeader(frameCount: UInt32(frameCount), hasAudio: hasAudio,
                                leftOffset: leftOffset, rightOffset: rightOffset)

        if manager.fileExists(atPath: destination) {
            try manager.removeItem(atPath: destination)
        }
        guard manager.createFile(atPath: destination, contents: nil) else {
            throw conversionError("Impossibile creare il file di destinazione.")
        }
        let outputHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: destination))
        defer { try? outputHandle.close() }
        outputHandle.write(header)
        outputHandle.write(Data(repeating: 0, count: 512 - header.count))
        try appendFile(videoURL, to: outputHandle)
        if hasAudio {
            try appendFile(leftURL, to: outputHandle)
            try appendFile(rightURL, to: outputHandle)
        }
        try outputHandle.synchronize()

        let finalSize = ((try? manager.attributesOfItem(atPath: destination)[.size]) as? NSNumber)?.uint64Value ?? 0
        guard finalSize == estimatedSize else {
            throw conversionError("Dimensione finale inattesa: il file RVID potrebbe essere incompleto.")
        }
    }

    // RVID v5 header layout follows the public format declaration in RocketVideoPlayer/common/rvidHeader.h.
    // This converter writes uncompressed 16-bit RGB565 frames and separate left/right 16-bit PCM streams.
    private func makeHeader(frameCount: UInt32, hasAudio: Bool,
                            leftOffset: UInt32, rightOffset: UInt32) -> Data {
        var data = Data()
        appendUInt32(0x44495652, to: &data) // "RVID" in little-endian byte order
        appendUInt32(5, to: &data)
        appendUInt32(frameCount, to: &data)
        data.append(UInt8(frameRate))
        data.append(UInt8(videoHeight))
        data.append(0) // progressive
        data.append(0) // single-screen video
        appendUInt16(hasAudio ? UInt16(audioRate) : 0, to: &data)
        data.append(1) // 16-bit audio samples
        data.append(2) // 16-bit RGB565 video
        appendUInt32(0, to: &data) // zero means uncompressed frames
        appendUInt32(leftOffset, to: &data)
        appendUInt32(rightOffset, to: &data)
        return data
    }

    private func deinterleaveAudio(stereoURL: URL, leftURL: URL, rightURL: URL,
                                   samples: UInt64) throws {
        FileManager.default.createFile(atPath: leftURL.path, contents: nil)
        FileManager.default.createFile(atPath: rightURL.path, contents: nil)
        let input = try FileHandle(forReadingFrom: stereoURL)
        let left = try FileHandle(forWritingTo: leftURL)
        let right = try FileHandle(forWritingTo: rightURL)
        defer {
            try? input.close()
            try? left.close()
            try? right.close()
        }

        var remaining = samples
        while remaining > 0 {
            let count = Int(min(remaining, 8192))
            var block = input.readData(ofLength: count * 4)
            if block.count < count * 4 {
                block.append(Data(repeating: 0, count: count * 4 - block.count))
            }
            var leftBlock = Data(capacity: count * 2)
            var rightBlock = Data(capacity: count * 2)
            block.withUnsafeBytes { raw in
                let bytes = raw.bindMemory(to: UInt8.self)
                for index in stride(from: 0, to: count * 4, by: 4) {
                    leftBlock.append(bytes[index])
                    leftBlock.append(bytes[index + 1])
                    rightBlock.append(bytes[index + 2])
                    rightBlock.append(bytes[index + 3])
                }
            }
            left.write(leftBlock)
            right.write(rightBlock)
            remaining -= UInt64(count)
        }
    }

    private func appendFile(_ source: URL, to destination: FileHandle) throws {
        let input = try FileHandle(forReadingFrom: source)
        defer { try? input.close() }
        while true {
            let chunk = input.readData(ofLength: 1024 * 1024)
            if chunk.isEmpty { break }
            destination.write(chunk)
        }
    }

    private func runTool(_ executable: String, _ arguments: [String]) throws -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: executable)
        task.arguments = arguments
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        do {
            try task.run()
        } catch {
            throw conversionError("Impossibile avviare \(URL(fileURLWithPath: executable).lastPathComponent): \(error.localizedDescription)")
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        task.waitUntilExit()
        let output = String(data: data, encoding: .utf8) ?? ""
        if task.terminationStatus != 0 {
            throw conversionError(output.isEmpty ? "FFmpeg/ffprobe è terminato con codice \(task.terminationStatus)." : output)
        }
        return output
    }

    private func appendUInt16(_ value: UInt16, to data: inout Data) {
        var little = value.littleEndian
        withUnsafeBytes(of: &little) { data.append(contentsOf: $0) }
    }

    private func appendUInt32(_ value: UInt32, to data: inout Data) {
        var little = value.littleEndian
        withUnsafeBytes(of: &little) { data.append(contentsOf: $0) }
    }

    private func findTool(_ name: String) -> String? {
        let candidates = ["/usr/local/bin/\(name)", "/opt/homebrew/bin/\(name)", "/opt/local/bin/\(name)"]
        return candidates.first { FileManager.default.isExecutableFile(atPath: $0) }
    }

    private func conversionError(_ message: String) -> NSError {
        NSError(domain: "DaiMP4Converter", code: 1,
                userInfo: [NSLocalizedDescriptionKey: message])
    }

    private func append(_ message: String) {
        log.textStorage?.append(NSAttributedString(string: message.hasSuffix("\n") ? message : message + "\n"))
        log.scrollToEndOfDocument(nil)
    }

    private func alert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Dai-MP4 Converter"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}

let app = NSApplication.shared
let delegate = ConverterApp()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
