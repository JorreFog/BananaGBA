#!/bin/bash
# RG DS session 8 (~9 min): does the threaded renderer win at LOW clocks? RetroArch, quick ROM, pinned 816 and 600 MHz
B=~/banana-emu/BananaGBA/build
PIN_KHZ=816000 ./gba-ab.sh rgds 45 pin816 1 stock=$B/plus/mgba_libretro.so final=$B/final-pgo/mgba_libretro.so pgooff=$B/final-pgo-off/mgba_libretro.so
PIN_KHZ=600000 ./gba-ab.sh rgds 45 pin600 1 stock=$B/plus/mgba_libretro.so final=$B/final-pgo/mgba_libretro.so pgooff=$B/final-pgo-off/mgba_libretro.so
PIN_KHZ=0 ./gba-ab.sh rgds 45 unpinned2 1 stock=$B/plus/mgba_libretro.so final=$B/final-pgo/mgba_libretro.so pgooff=$B/final-pgo-off/mgba_libretro.so
