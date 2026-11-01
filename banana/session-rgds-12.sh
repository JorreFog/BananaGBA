#!/bin/bash
# RG DS session 12 (~4 min): the shipped configuration again with BananaFront ba071e3 (owed-frame fix), 3 min
B=~/banana-emu/BananaGBA/build
BF_UI=~/ovn-gba-int-deploy/banana-ui ~/banana-emu/BananaFront/tools/devrun.sh rgds gba $B/final-auto/mgba_libretro.so $HOME/ovn-gba/tools/test-roms/gbastress-realistic.gba 180 shipped-ba071e3
