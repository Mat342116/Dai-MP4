import Cocoa
final class ConverterApp: NSObject, NSApplicationDelegate {
 var window:NSWindow!, input:NSTextField!, output:NSTextField!, status:NSTextField!, log:NSTextView!, convertButton:NSButton!
 var process:Process?
 func applicationDidFinishLaunching(_ n:Notification){ buildUI() }
 func applicationShouldTerminateAfterLastWindowClosed(_ s:NSApplication)->Bool{true}
 func field(_ s:String)->NSTextField{let f=NSTextField(string:s);f.isEditable=false;f.isSelectable=true;f.lineBreakMode = .byTruncatingMiddle;f.font = .systemFont(ofSize:11);return f}
 func button(_ s:String,_ a:Selector)->NSButton{let b=NSButton(title:s,target:self,action:a);b.bezelStyle = .rounded;return b}
 func buildUI(){
  window=NSWindow(contentRect:NSRect(x:0,y:0,width:620,height:390),styleMask:[.titled,.closable,.miniaturizable],backing:.buffered,defer:false)
  window.title="Dai-MP4 Converter";let root=NSView(frame:NSRect(x:0,y:0,width:620,height:390));window.contentView=root
  let h=NSTextField(labelWithString:"Converti video per Nintendo DSi");h.font = .boldSystemFont(ofSize:21);h.frame=NSRect(x:24,y:342,width:570,height:30);root.addSubview(h)
  let sub=NSTextField(labelWithString:"AVI / Xvid / MP3 · 256×192 · 10 fps · macOS Big Sur Intel");sub.textColor = .secondaryLabelColor;sub.frame=NSRect(x:25,y:318,width:570,height:20);root.addSubview(sub)
  input=field("Nessun video selezionato");input.frame=NSRect(x:24,y:270,width:455,height:28);root.addSubview(input)
  let o=button("Scegli video…",#selector(chooseInput));o.frame=NSRect(x:488,y:269,width:108,height:30);root.addSubview(o)
  output=field("Scegli dove salvare il file AVI");output.frame=NSRect(x:24,y:225,width:455,height:28);root.addSubview(output)
  let s=button("Destinazione…",#selector(chooseOutput));s.frame=NSRect(x:488,y:224,width:108,height:30);root.addSubview(s)
  let note=NSTextField(labelWithString:"Mantiene le proporzioni con bande nere. Audio MP3 a 32 kHz.");note.font = .systemFont(ofSize:11);note.textColor = .secondaryLabelColor;note.frame=NSRect(x:25,y:194,width:570,height:18);root.addSubview(note)
  let scroll=NSScrollView(frame:NSRect(x:24,y:66,width:572,height:116));scroll.hasVerticalScroller=true;scroll.borderType = .bezelBorder
  log=NSTextView(frame:scroll.bounds);log.isEditable=false;log.font = .monospacedSystemFont(ofSize:11,weight:.regular);log.string = "Pronto. Seleziona un video e la destinazione.\n";scroll.documentView=log;root.addSubview(scroll)
  status=NSTextField(labelWithString:"In attesa");status.frame=NSRect(x:25,y:35,width:350,height:20);root.addSubview(status)
  convertButton=button("Converti",#selector(convert));convertButton.frame=NSRect(x:470,y:25,width:126,height:34);convertButton.keyEquivalent="\r";root.addSubview(convertButton)
  window.center();window.makeKeyAndOrderFront(nil);NSApp.activate(ignoringOtherApps:true)
 }
 @objc func chooseInput(){let p=NSOpenPanel();p.allowedFileTypes=["mp4","m4v","mov","mkv","avi"];p.allowsMultipleSelection=false;p.canChooseDirectories=false;if p.runModal() == .OK,let u=p.url{input.stringValue=u.path;if output.stringValue=="Scegli dove salvare il file AVI"{output.stringValue=u.deletingPathExtension().appendingPathExtension("avi").path}}}
 @objc func chooseOutput(){let p=NSSavePanel();p.allowedFileTypes=["avi"];p.nameFieldStringValue="video-DSi.avi";if p.runModal() == .OK,let u=p.url{output.stringValue=u.path}}
 @objc func convert(){
  let src=input.stringValue,dst=output.stringValue
  guard !src.isEmpty,FileManager.default.fileExists(atPath:src) else{alert("Seleziona un video valido.");return}
  guard !dst.isEmpty,dst != "Scegli dove salvare il file AVI" else{alert("Scegli la destinazione AVI.");return}
  guard URL(fileURLWithPath:src).standardizedFileURL != URL(fileURLWithPath:dst).standardizedFileURL else{alert("Il file di destinazione deve essere diverso dal video originale.");return}
  guard let ff=findFFmpeg() else{alert("FFmpeg non trovato. Installalo e riapri l'app; consulta il README.");return}
  convertButton.isEnabled=false;status.stringValue="Conversione in corso…";append("Avvio: \((src as NSString).lastPathComponent)")
  let task=Process();process=task;task.executableURL=URL(fileURLWithPath:ff)
  task.arguments=["-hide_banner","-y","-i",src,"-map","0:v:0","-map","0:a:0?","-vf","scale=256:192:force_original_aspect_ratio=decrease,pad=256:192:(ow-iw)/2:(oh-ih)/2,fps=10,format=yuv420p","-c:v","mpeg4","-vtag","XVID","-b:v","192k","-maxrate","256k","-bufsize","512k","-c:a","libmp3lame","-ar","32000","-b:a","96k","-ac","2","-f","avi",dst]
  let pipe=Pipe();task.standardError=pipe;task.standardOutput=pipe
  task.terminationHandler={[weak self] p in DispatchQueue.main.async{guard let self=self else{return};self.convertButton.isEnabled=true;self.status.stringValue=p.terminationStatus==0 ? "Conversione completata":"Conversione non riuscita";self.append(p.terminationStatus==0 ? "Creato: \(dst)":"FFmpeg terminato con codice \(p.terminationStatus).")}}
  do{try task.run();pipe.fileHandleForReading.readabilityHandler={[weak self] h in let d=h.availableData;if !d.isEmpty,let t=String(data:d,encoding:.utf8){DispatchQueue.main.async{self?.append(t)}}}}catch{process=nil;convertButton.isEnabled=true;status.stringValue="Errore";append(error.localizedDescription)}
 }
 func findFFmpeg()->String?{["/usr/local/bin/ffmpeg","/opt/homebrew/bin/ffmpeg","/opt/local/bin/ffmpeg"].first{FileManager.default.isExecutableFile(atPath:$0)}}
 func append(_ s:String){log.textStorage?.append(NSAttributedString(string:s.hasSuffix("\n") ? s:s+"\n"));log.scrollToEndOfDocument(nil)}
 func alert(_ s:String){let a=NSAlert();a.messageText="Dai-MP4 Converter";a.informativeText=s;a.alertStyle = .warning;a.runModal()}
}
let app=NSApplication.shared;let delegate=ConverterApp();app.delegate=delegate;app.setActivationPolicy(.regular);app.run()
