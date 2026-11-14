#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/build/Dai-MP4 Converter.app"
mkdir -p "$ROOT/build" "$APP/Contents/MacOS"
swiftc -O -target x86_64-apple-macosx11.0 -framework Cocoa "$ROOT/Sources/main.swift" -o "$APP/Contents/MacOS/Dai-MP4-Converter"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>Dai-MP4-Converter</string>
<key>CFBundleIdentifier</key><string>com.daimp4.converter</string>
<key>CFBundleName</key><string>Dai-MP4 Converter</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>LSMinimumSystemVersion</key><string>11.0</string>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
echo "Created $APP"
