#!/bin/bash

# Assemble a click package for Ubuntu Touch from a previously built Volla Messages deb.
# A previously set up environment with all the dependencies for click packaging is required.

# TODO:
# - Full testing and clean up required.
# - Integrate the webkit zoom hook provided as patch, because I have no idea how to apply it besides compiling the C code.
# - The original script pulls libraries, pressumably to fix issues. For now, this tests if it's really required.

set -e

DEB=$1

[ -f "$DEB" ] || { echo "usage: $0 Volla.Messages_*_amd64.deb"; exit 1; }

HERE=$(dirname "$(readlink -f "$0")")
OUT=$(pwd)
R=$(mktemp -d)
S=$R/stage
B=$R/click
dpkg-deb -x "$DEB" "$S"
cd "$R"

## This definitely serves a purpose in the original script, and I have yet to understand what our equivalent is.
#for d in *.deb; do dpkg-deb -x "$d" "$S"; done
#A=$S/usr/lib/
#cp -a "$A"/placeholder/. "$B/lib/"
#cp -a "$A"/libSDL2_ttf-2.0.so.0* "$A"/libswscale.so.7* \
cp "$S"/usr/share/icons/hicolor/116x116/apps/volla_messages.png "$B/volla_messages.png"
cp "$HERE"/manifest.json "$HERE"/volla-messages.apparmor "$HERE"/volla-messages.desktop "$B/"
gcc -O2 -o "$B/volla-messages-launcher" "$HERE/launcher.c" $(pkg-config --cflags --libs gio-2.0)
click build "$B"
mv "$R"/*.click "$OUT"/
rm -rf "$R"
