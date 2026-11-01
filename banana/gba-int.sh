#!/bin/bash
# gba-int.sh rgds|plus <core.so> <secs>: BananaGBA in BananaFront through the menu with the integrated banana-ui
# (ovn/gba + front/bananafront): game companion on (tier-1 def of gbastress, panel pictures) vs off (the companion's
# frame cost). Under locked.sh. Restores the setting and removes the def.
set -u
D=$1 SO=$2 SEC=$3
X=~/bananaos-0.4.3/dev.sh
DEF=~/ovn-gba/tools/stress-roms/gba/companion/gbastress-realistic.json
ROM=~/ovn-gba/tools/test-roms/gbastress-realistic.gba
$X $D 'mkdir -p /data/banana/companions; [ -e /data/banana/companions/gbastress-realistic.json ] || touch /run/gbaint-def-new; cat > /data/banana/companions/gbastress-realistic.json; sed -n "s/^game_companion = //p" /data/banana/settings.conf > /run/gbaint-gc.bak; cat /run/gbaint-gc.bak' < "$DEF"
restore() { $X $D 'c=$(cat /run/gbaint-gc.bak 2>/dev/null); if [ -n "$c" ]; then sed -i "s/^game_companion = .*/game_companion = $c/" /data/banana/settings.conf; else sed -i "/^game_companion = /d" /data/banana/settings.conf; fi
	[ -e /run/gbaint-def-new ] && rm -f /data/banana/companions/gbastress-realistic.json /run/gbaint-def-new; rmdir /data/banana/companions 2>/dev/null; rm -f /run/gbaint-gc.bak; grep -c "^game_companion" /data/banana/settings.conf'; }
trap restore EXIT
setgc() { $X $D "grep -q '^game_companion = ' /data/banana/settings.conf && sed -i 's/^game_companion = .*/game_companion = $1/' /data/banana/settings.conf || echo 'game_companion = $1' >> /data/banana/settings.conf"; }
setgc on
BF_UI=~/ovn-gba-int-deploy/banana-ui MID=~/banana-emu/BananaGBA/banana/mid-comp.sh ~/banana-emu/BananaFront/tools/devrun.sh $D gba "$SO" "$ROM" "$SEC" comp-on 2>&1 | tail -12
setgc off
BF_UI=~/ovn-gba-int-deploy/banana-ui ~/banana-emu/BananaFront/tools/devrun.sh $D gba "$SO" "$ROM" "$SEC" comp-off 2>&1 | tail -8
