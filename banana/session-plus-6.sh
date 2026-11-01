#!/bin/bash
# Plus (<= 5 min): tier 0 on hardware (Emerald's GAME tab: rich presence + closest achievements from BananaFront's RA
# block) and the Pokémon companion on a CFRU hack (Pokémon Unbound: party, summary with learns-next)
B=~/banana-emu/BananaGBA/build
for g in "Pokemon Emerald Version.zip:emerald-t0" "Pokemon Unbound (v2.1.1.1).zip:unbound"; do
	PADSEQ="start w2 a w2 a w3 a w2" BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-pk2.sh \
		~/banana-emu/BananaFront/tools/devrun.sh plus gba $B/final-auto/mgba_libretro.so "/nonexistent/${g%%:*}" 50 "${g##*:}"
done
