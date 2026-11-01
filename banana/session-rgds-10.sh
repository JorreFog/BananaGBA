#!/bin/bash
# RG DS session 10 (~4 min): the shipped run's late frames came in the loader scene (120-150 s): the same 3 min with the
# renderer OFF, to see whether the thread (and the low clock it lets schedutil pick) causes them
B=~/banana-emu/BananaGBA/build
PRE='~/bananaos-0.4.3/dev.sh $DEV "cat > /run/bdev/bf/off.opt" < ~/banana-emu/BananaGBA/banana/off.opt' BF_ENV="BANANAFRONT_OPTIONS=/run/bdev/bf/off.opt" \
	BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-threads.sh ~/banana-emu/BananaFront/tools/devrun.sh rgds gba $B/final-auto/mgba_libretro.so $HOME/ovn-gba/tools/test-roms/gbastress-realistic.gba 180 shipped-off
