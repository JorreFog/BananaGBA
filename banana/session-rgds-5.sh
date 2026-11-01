#!/bin/bash
# RG DS session 5 (~14 min): the final build (threaded + LTO + PGO from the repo's profile): exactness + one A/B round vs
# stock, then RetroArch vs BananaFront at the user's settings (front's ab.sh): gpSP (today's default), then BananaGBA
B=~/banana-emu/BananaGBA/build
./gba-exact.sh rgds 3000 stock=$B/plus/mgba_libretro.so final=$B/final-pgo/mgba_libretro.so
./gba-ab.sh rgds 50 finalpgo 1 stock=$B/plus/mgba_libretro.so final=$B/final-pgo/mgba_libretro.so
./gba-front-ab.sh rgds gpsp 50 gpsp
./gba-front-ab.sh rgds mgba 50 bananagba $B/final-pgo/mgba_libretro.so
