#!/bin/bash
# RG DS session 11 (~3 min): tier-0 save states on hardware (BananaGBA final in BananaFront, gbastress), then cleanup
B=~/banana-emu/BananaGBA/build
BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-states.sh ~/banana-emu/BananaFront/tools/devrun.sh rgds gba $B/final-auto/mgba_libretro.so $HOME/ovn-gba/tools/test-roms/gbastress-realistic.gba 40 states
~/bananaos-0.4.3/dev.sh rgds 'rm -f /data/states/*/gbastress-realistic.state* /data/saves/gba/gbastress-realistic.* ; ls /data/states/*/ | grep -c gbastress'
