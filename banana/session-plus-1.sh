#!/bin/bash
# Plus (<= 5 min): BananaGBA in BananaFront with the integrated banana-ui - tier 0 (RA on the Plus) + tier 1 (Advance
# Wars' definition), then the Pokémon companion through the shm (Emerald)
B=~/banana-emu/BananaGBA/build
./gba-game.sh plus $B/plus-tv/mgba_libretro.so "Advance Wars (USA) (Rev 1).gba" 50 aw-tier0 "start w2 a w2 a w2"
./gba-game.sh plus $B/plus-tv/mgba_libretro.so "Pokemon Emerald Version.zip" 50 emerald-pk "start w2 a w2 a w3 a w2"
