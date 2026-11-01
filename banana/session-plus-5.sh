#!/bin/bash
# Plus (<= 4 min): the shipped configuration (BananaGBA final, auto renderer) in BananaFront at its defaults, 2 min
B=~/banana-emu/BananaGBA/build
BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-threads.sh ~/banana-emu/BananaFront/tools/devrun.sh plus gba $B/final-auto/mgba_libretro.so $HOME/ovn-gba/tools/test-roms/gbastress-realistic.gba 120 shipped
