#!/bin/bash
set -e

APP_NAME="Caffeine"
BUILD_DIR=".build/debug"
BUNDLE_DIR="$APP_NAME.app/Contents"

# Build
swift build

# Create .app bundle
rm -rf "$APP_NAME.app"
mkdir -p "$BUNDLE_DIR/MacOS"

# Copy binary
cp "$BUILD_DIR/CaffeineApp" "$BUNDLE_DIR/MacOS/$APP_NAME"

# Create Info.plist
cat > "$BUNDLE_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Caffeine</string>
    <key>CFBundleIdentifier</key>
    <string>com.local.caffeine</string>
    <key>CFBundleName</key>
    <string>Caffeine</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
</dict>
</plist>
EOF

echo "Built $APP_NAME.app successfully"
echo "Run with: open $APP_NAME.app"
