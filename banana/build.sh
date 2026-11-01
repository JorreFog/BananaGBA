#!/bin/bash
# banana/build.sh <host|plus|rgds> [build-dir] [extra cmake args...]: the libretro core (mgba_libretro.so).
# Cross builds use the Buildroot toolchain of that board (same as package/libretro-mgba). Run through buildslot.sh.
set -euo pipefail
T=${1:?host|plus|rgds}; shift
SRC=$(cd "$(dirname "$0")/.." && pwd)
B=${1:-$SRC/build/$T}; [ $# -gt 0 ] && shift
BOARD=$T; [ "$T" = plus ] && BOARD=rgds-plus
ARGS=(-DLIBMGBA_ONLY=ON -DBUILD_LIBRETRO=ON -DCMAKE_BUILD_TYPE=Release)
if [ "$T" != host ]; then
	ARGS+=(-DCMAKE_TOOLCHAIN_FILE=$HOME/BananaLinux/output/$BOARD/host/share/buildroot/toolchainfile.cmake)
fi
cmake -S "$SRC" -B "$B" -G "Unix Makefiles" "${ARGS[@]}" "$@" > "$B.cmake.log" 2>&1 || { tail -20 "$B.cmake.log"; exit 1; }
make -C "$B" -j4 > "$B.make.log" 2>&1 || { grep -E 'error|Error' "$B.make.log" | head -20; exit 1; }
find "$B" -name mgba_libretro.so
