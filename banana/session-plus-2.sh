#!/bin/bash
# Plus (<= 5 min): the Pokémon companion through BananaFront's export with the fixed BananaGBA (maps at load)
B=~/banana-emu/BananaGBA/build
PADSEQ="start w2 a w2 a w3 a w2" BF_ENV="BANANAGBA_STATS=1" BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-pk.sh \
	~/banana-emu/BananaFront/tools/devrun.sh plus gba $B/n-tvlto/mgba_libretro.so "/nonexistent/Pokemon Emerald Version.zip" 60 emerald-pk2
