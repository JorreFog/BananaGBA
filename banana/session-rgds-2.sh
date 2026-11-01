#!/bin/bash
# RG DS session 2 (~10 min): PGO training (headless), BananaGBA in BananaFront with the companion on/off, and a clean
# A/B of LTO alone (session 1's "lto" ran threaded: RetroArch had saved the option) + -O2 + hidden visibility
B=~/banana-emu/BananaGBA/build
find $B/plus-tv-pgogen -name '*.gcda' -delete
./gba-pgo-train.sh rgds $B/plus-tv-pgogen/mgba_libretro.so $B/plus-tv-pgogen 9300
./gba-int.sh rgds $B/plus-tv/mgba_libretro.so 60
./gba-exact.sh rgds 3000 stock=$B/plus/mgba_libretro.so o2=$B/plus-tv-o2/mgba_libretro.so hid=$B/plus-tv-hid/mgba_libretro.so
./gba-ab.sh rgds 50 lto-o2-hid 1 stock=$B/plus/mgba_libretro.so lto=$B/plus-lto/mgba_libretro.so tv=$B/plus-tv/mgba_libretro.so o2=$B/plus-tv-o2/mgba_libretro.so hid=$B/plus-tv-hid/mgba_libretro.so
