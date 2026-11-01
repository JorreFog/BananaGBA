#!/bin/bash
# RG DS session 7 (~12 min): BananaGBA's threaded renderer in BananaFront at its defaults (system profile, low latency
# on), and with low latency off; main-thread psample + per-thread CPU + clock; then RetroArch unpinned stock vs final
B=~/banana-emu/BananaGBA/build
R=$HOME/ovn-gba/tools/test-roms/gbastress-realistic.gba
C=$B/plus-tvlto-g/mgba_libretro.so
OFF='~/bananaos-0.4.3/dev.sh $DEV "cat > /run/bdev/bf/off.opt" < ~/banana-emu/BananaGBA/banana/off.opt'
BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-bfprof.sh ~/banana-emu/BananaFront/tools/devrun.sh rgds gba $C $R 50 bfdef-on
PRE="$OFF" BF_ENV="BANANAFRONT_OPTIONS=/run/bdev/bf/off.opt" BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-bfprof.sh \
	~/banana-emu/BananaFront/tools/devrun.sh rgds gba $C $R 50 bfdef-off
BF_ENV="BANANAFRONT_LOWLAT_SET=off" BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-threads.sh \
	~/banana-emu/BananaFront/tools/devrun.sh rgds gba $C $R 50 bfnolat-on
PRE="$OFF" BF_ENV="BANANAFRONT_OPTIONS=/run/bdev/bf/off.opt BANANAFRONT_LOWLAT_SET=off" BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-threads.sh \
	~/banana-emu/BananaFront/tools/devrun.sh rgds gba $C $R 50 bfnolat-off
PIN_KHZ=0 ./gba-ab.sh rgds 50 unpinned 1 stock=$B/plus/mgba_libretro.so final=$B/final-pgo/mgba_libretro.so
