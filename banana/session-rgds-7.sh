#!/bin/bash
# RG DS session 7 (~4 min): BananaGBA (threaded, symbols) in BananaFront: psample of the main thread, renderer on/off
B=~/banana-emu/BananaGBA/build
R=$HOME/ovn-gba/tools/test-roms/gbastress-realistic.gba
BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-bfprof.sh ~/banana-emu/BananaFront/tools/devrun.sh rgds gba $B/plus-tvlto-g/mgba_libretro.so $R 50 bfprof-on
PRE='~/bananaos-0.4.3/dev.sh $DEV "cat > /run/bdev/bf/off.opt" < ~/banana-emu/BananaGBA/banana/off.opt' BF_ENV="BANANAFRONT_OPTIONS=/run/bdev/bf/off.opt" \
	BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-bfprof.sh ~/banana-emu/BananaFront/tools/devrun.sh rgds gba $B/plus-tvlto-g/mgba_libretro.so $R 50 bfprof-off
# RetroArch at the user's governor (no pin): stock vs final, the mean clock recorded (work = CPU % x clock)
PIN_KHZ=0 ./gba-ab.sh rgds 50 unpinned 2 stock=$B/plus/mgba_libretro.so final=$B/final-pgo/mgba_libretro.so
