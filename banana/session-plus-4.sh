#!/bin/bash
# Plus (<= 3 min): Emerald's Dex entry of a wild Pokémon (Poochyena): the companion's "where" from the ROM's map groups
B=~/banana-emu/BananaGBA/build
DEXX=290 DEXY=100 PADSEQ="start w2 a w2 a w3 a w2" BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-pk.sh \
	~/banana-emu/BananaFront/tools/devrun.sh plus gba $B/n-tvlto/mgba_libretro.so "/nonexistent/Pokemon Emerald Version.zip" 50 emerald-where
