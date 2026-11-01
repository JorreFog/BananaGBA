#!/bin/bash
# RG DS session 6 (~13 min): why BananaGBA costs as much in BananaFront as in RetroArch (gpSP costs 40 % less there):
# its threads in BananaFront with the threaded renderer on and off, stock mGBA RA vs BF, then the final build's profile
B=~/banana-emu/BananaGBA/build
R=$HOME/ovn-gba/tools/test-roms/gbastress-realistic.gba
PRE='~/bananaos-0.4.3/dev.sh $DEV "cat > /run/bdev/bf/rastats.so" < ~/banana-emu/common/rastats/rastats.so' BF_ENV="LD_PRELOAD=/run/bdev/bf/rastats.so RASTATS_LOG=/run/bdev/bf/rastats.log" \
	BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-threads.sh ~/banana-emu/BananaFront/tools/devrun.sh rgds gba $B/final-pgo/mgba_libretro.so $R 50 bf-tv-on
PRE='~/bananaos-0.4.3/dev.sh $DEV "cat > /run/bdev/bf/off.opt" < ~/banana-emu/BananaGBA/banana/off.opt' BF_ENV="BANANAFRONT_OPTIONS=/run/bdev/bf/off.opt" \
	BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-threads.sh ~/banana-emu/BananaFront/tools/devrun.sh rgds gba $B/final-pgo/mgba_libretro.so $R 50 bf-tv-off
./gba-front-ab.sh rgds mgba 50 stockmgba
./gba-prof.sh rgds mgba final ~/banana-emu/BananaGBA/build/plus-tvlto-g/mgba_libretro.so
