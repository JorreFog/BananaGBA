#!/bin/bash
# gba-game.sh <dev> <core.so> "<the game's file name in /data/roms/gba>" <secs> <tag> [pad sequence]
# The final validation in one of the owner's games: BananaGBA in BananaFront through the menu (integrated banana-ui:
# companions + tier 0), workload fingerprint on (BANANAGBA_STATS=1), pad presses half-way, panel pictures. The game
# file never leaves the handheld (devrun uses the device's copy; the local path is only its name). Under locked.sh.
set -u
D=$1 SO=$2 G=$3 SEC=$4 TAG=$5
PADSEQ=${6:-} BF_ENV="BANANAGBA_STATS=1" BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-game.sh \
	~/banana-emu/BananaFront/tools/devrun.sh "$D" gba "$SO" "/nonexistent/$G" "$SEC" "$TAG"
