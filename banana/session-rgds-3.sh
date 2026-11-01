#!/bin/bash
# RG DS session 3 (~10 min): the final candidates - threaded+LTO (latest code), + PGO (trained in session 2), and the
# render thread's wake-up interval (8 / 32 lines) - exactness then one A/B round each against stock
B=~/banana-emu/BananaGBA/build
./gba-exact.sh rgds 3000 stock=$B/plus/mgba_libretro.so tvlto=$B/n-tvlto/mgba_libretro.so pgo=$B/plus-tv-lto-pgo/mgba_libretro.so w8=$B/plus-tv-w8/mgba_libretro.so w32=$B/plus-tv-w32/mgba_libretro.so
./gba-ab.sh rgds 60 final 1 stock=$B/plus/mgba_libretro.so tvlto=$B/n-tvlto/mgba_libretro.so pgo=$B/plus-tv-lto-pgo/mgba_libretro.so w8=$B/plus-tv-w8/mgba_libretro.so w32=$B/plus-tv-w32/mgba_libretro.so
