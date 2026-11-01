#!/bin/bash
# RG DS session 2: PGO training (headless, threaded+instrumented core) + BananaGBA in BananaFront with the companion
B=~/banana-emu/BananaGBA/build
find $B/plus-tv-pgogen -name '*.gcda' -delete
./gba-pgo-train.sh rgds $B/plus-tv-pgogen/mgba_libretro.so $B/plus-tv-pgogen 9300
./gba-int.sh rgds $B/plus-tv/mgba_libretro.so 60
