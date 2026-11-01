#!/bin/bash
# RG DS: exactness of the rebuilt variants (toolchain flags kept), then the A/B series
B=~/banana-emu/BananaGBA/build
./gba-exact.sh rgds 3000 stock=$B/plus/mgba_libretro.so tv=$B/plus-tv/mgba_libretro.so lto=$B/plus-lto/mgba_libretro.so tvlto=$B/plus-tv-lto/mgba_libretro.so
./gba-ab.sh rgds 50 tv-lto 2 stock=$B/plus/mgba_libretro.so tv=$B/plus-tv/mgba_libretro.so lto=$B/plus-lto/mgba_libretro.so tvlto=$B/plus-tv-lto/mgba_libretro.so
