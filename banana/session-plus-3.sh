#!/bin/bash
# Plus (<= 5 min): stock mGBA vs BananaGBA final (threaded + LTO) on the quick ROM, clock pinned, one round each
B=~/banana-emu/BananaGBA/build
./gba-ab.sh plus 50 final-plus 1 stock=$B/plus/mgba_libretro.so bananagba=$B/n-tvlto/mgba_libretro.so
