#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
GODOT_BIN=${GODOT_BIN:-.tools/godot/Godot.app/Contents/MacOS/Godot}
if [ ! -x "$GODOT_BIN" ]; then GODOT_BIN=godot; fi
exec "$GODOT_BIN" --path . "$@"
