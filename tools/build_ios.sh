#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
GODOT_BIN=${GODOT_BIN:-.tools/godot/Godot.app/Contents/MacOS/Godot}
if [ ! -x "$GODOT_BIN" ]; then GODOT_BIN=godot; fi
mkdir -p builds/ios
"$GODOT_BIN" --headless --language en --path . --export-debug iOS builds/ios/SlowCoin.zip
# Godot 4.6.3's official simulator slice declares arm64 but only contains x86_64.
# Patch the generated project only; leave system templates and device arm64 untouched.
COIN_SIM_LIB=${COIN_SIM_LIB:-.tools/godot-4.6.3-stable/bin/libgodot.ios.template_debug.arm64.simulator.a}
if [ -f "$COIN_SIM_LIB" ]; then
    cp "$COIN_SIM_LIB" builds/ios/SlowCoin.xcframework/ios-arm64_x86_64-simulator/libgodot.a
    python3 - <<'PY'
import plistlib
p='builds/ios/SlowCoin.xcframework/Info.plist'
with open(p,'rb') as f: data=plistlib.load(f)
for item in data['AvailableLibraries']:
    if item.get('SupportedPlatformVariant')=='simulator': item['SupportedArchitectures']=['arm64']
with open(p,'wb') as f: plistlib.dump(data,f)
PY
fi
python3 tools/patch_ios_export.py
xcodebuild -project builds/ios/SlowCoin.xcodeproj -scheme SlowCoin -configuration Debug \
    -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath builds/ios-derived CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO DEVELOPMENT_TEAM= build
