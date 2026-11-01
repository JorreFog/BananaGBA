#!/bin/bash
# one locked RG DS session: exactness of the variants (headless lrhost) then the A/B series (menu launcher, pinned)
B=~/banana-emu/BananaGBA/build
./gba-exact.sh rgds 3000 stock=$B/plus/mgba_libretro.so tv=$B/plus-tv/mgba_libretro.so lto=$B/plus-lto/mgba_libretro.so tvlto=$B/plus-tv-lto/mgba_libretro.so
./gba-ab.sh rgds 50 tv-lto 2 stock=$B/plus/mgba_libretro.so tv=$B/plus-tv/mgba_libretro.so lto=$B/plus-lto/mgba_libretro.so tvlto=$B/plus-tv-lto/mgba_libretro.so
