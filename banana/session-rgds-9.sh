#!/bin/bash
# RG DS session 9 (~6 min): the shipped configuration - BananaGBA final (auto renderer) in BananaFront at its defaults,
# 3 min of gbastress realistic with BananaFront's stats + threads (the render thread must be there), exactness first
B=~/banana-emu/BananaGBA/build
./gba-exact.sh rgds 3000 stock=$B/plus/mgba_libretro.so auto=$B/final-auto/mgba_libretro.so
BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-threads.sh ~/banana-emu/BananaFront/tools/devrun.sh rgds gba $B/final-auto/mgba_libretro.so $HOME/ovn-gba/tools/test-roms/gbastress-realistic.gba 180 shipped
