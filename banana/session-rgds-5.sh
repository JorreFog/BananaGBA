#!/bin/bash
# RG DS session 5 (~12 min): RetroArch vs BananaFront at the user's settings (front's ab.sh: process CPU, mean clock,
# temperatures), gbastress realistic: today's default gpSP, then BananaGBA (final build) as the core
B=~/banana-emu/BananaGBA/build
./gba-front-ab.sh rgds gpsp 60 gpsp
./gba-front-ab.sh rgds mgba 60 bananagba $B/n-tvlto/mgba_libretro.so
