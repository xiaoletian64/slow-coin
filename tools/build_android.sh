#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
GODOT_BIN=${GODOT_BIN:-.tools/godot/Godot.app/Contents/MacOS/Godot}
if [ ! -x "$GODOT_BIN" ]; then GODOT_BIN=godot; fi
mkdir -p builds/android
python3 tools/prepare_android.py
exec "$GODOT_BIN" --headless --language en --path . --export-debug Android builds/android/SlowCoin.apk
