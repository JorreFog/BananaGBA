#!/bin/bash
# RG DS session 4 (~8 min): BananaGBA as Settings' core through the menu + RetroArch (companion over RetroArch's pipe),
# then the owner's games in BananaFront: FireRed with the Pokémon companion (a wild Pokémon's Dex entry), Aladdin
B=~/banana-emu/BananaGBA/build
./gba-menu.sh rgds $B/n-tvlto/mgba_libretro.so 25
DEXX=290 DEXY=100 PADSEQ="start w2 a w2 a w3 a w2" BF_ENV="BANANAGBA_STATS=1" BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-pk.sh \
	~/banana-emu/BananaFront/tools/devrun.sh rgds gba $B/n-tvlto/mgba_libretro.so "/nonexistent/Pokemon - FireRed Version (USA, Europe) (Rev 1).gba" 60 firered-pk
./gba-game.sh rgds $B/n-tvlto/mgba_libretro.so "Aladdin.zip" 50 aladdin "start w2 a w2 right w1 right w1 a w1"
