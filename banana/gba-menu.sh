#!/bin/bash
# gba-menu.sh <dev> <core.so> <secs>: BananaGBA as Settings' GBA core (core.gba = bananagba) through the menu and
# RetroArch (the fallback frontend): the image's core folder + bananagba_libretro.so bind-mounted, the integrated
# banana-ui deployed, gbastress (its tier-1 companion definition on the card, game companion on) started from the
# library. Checks: RetroArch runs core bananagba, the companion reads through RetroArch's pipe. Under locked.sh.
set -u
D=$1 SO=$2 SEC=$3
X=~/bananaos-0.4.3/dev.sh
DS=~/.claude/skills/banana-device-test/scripts
ROM=~/ovn-gba/tools/test-roms/gbastress-realistic.gba
DEF=~/ovn-gba/tools/stress-roms/gba/companion/gbastress-realistic.json
OUT=~/stress-runs/gba-menu/$(date +%Y%m%d-%H%M%S)-$D; mkdir -p "$OUT"
dev() { "$X" "$D" "$@"; }
shot() { dev "python3 /data/ovn-prs/grab.py /run/bfshot.png all >/dev/null 2>&1; for c in 0 1; do [ -f /run/bfshot-crtc\$c.png ] && echo \$c; done" | while read c; do dev "cat /run/bfshot-crtc$c.png" > "$OUT/$1-crtc$c.png"; done; dev 'rm -f /run/bfshot*.png'; }
cleanup() {
	dev 'P=$(pidof retroarch); [ -n "$P" ] && kill -TERM $P; for i in $(seq 20); do [ -e /run/banana/game.pid ] || break; sleep 0.5; done
		c=$(cat /run/gbamenu/core.bak 2>/dev/null); [ -n "$c" ] && sed -i "s/^core\.gba = .*/core.gba = $c/" /data/banana/settings.conf
		g=$(cat /run/gbamenu/gc.bak 2>/dev/null); if [ -n "$g" ]; then sed -i "s/^game_companion = .*/game_companion = $g/" /data/banana/settings.conf; else sed -i "/^game_companion = /d" /data/banana/settings.conf; fi
		[ -e /run/gbamenu/def-new ] && rm -f /data/banana/companions/gbastress-realistic.json; rmdir /data/banana/companions 2>/dev/null
		grep -q " /usr/lib/libretro " /proc/mounts && umount /usr/lib/libretro
		rm -f /data/roms/gba/gbastress-realistic.gba /data/saves/gba/gbastress-realistic.*; sed -i "/^mgba_banana_/d" /data/retroarch/config/mGBA/mGBA.opt 2>/dev/null
		rm -rf /run/gbamenu; grep -E "^core.gba|^game_companion" /data/banana/settings.conf' 2>&1 | sed 's/^/cleanup: /'
	$DS/deploy.sh "$D" undo 2>&1 | tail -1
}
trap cleanup EXIT
dev 'mkdir -p /run/gbamenu/cores && cp -a /usr/lib/libretro/. /run/gbamenu/cores/' || exit 1
dev 'cat > /run/gbamenu/cores/bananagba_libretro.so && mount --bind /run/gbamenu/cores /usr/lib/libretro && ls /usr/lib/libretro | grep -c banana' < "$SO" || exit 1
dev 'sed -n "s/^core\.gba = //p" /data/banana/settings.conf > /run/gbamenu/core.bak; sed -i "s/^core\.gba = .*/core.gba = bananagba/" /data/banana/settings.conf
	sed -n "s/^game_companion = //p" /data/banana/settings.conf > /run/gbamenu/gc.bak
	grep -q "^game_companion = " /data/banana/settings.conf && sed -i "s/^game_companion = .*/game_companion = on/" /data/banana/settings.conf || echo "game_companion = on" >> /data/banana/settings.conf
	mkdir -p /data/banana/companions; [ -e /data/banana/companions/gbastress-realistic.json ] || touch /run/gbamenu/def-new' || exit 1
dev 'cat > /data/banana/companions/gbastress-realistic.json' < "$DEF"
$DS/deploy.sh "$D" --restart ui ~/ovn-gba-int-deploy/banana-ui=/usr/bin/banana-ui 2>&1 | tail -2
sleep 6
dev "cat > /data/roms/gba/gbastress-realistic.gba" < "$ROM"; sleep 6
dev "P=; for try in 1 2 3 4; do echo /data/roms/gba/gbastress-realistic.gba > /run/banana/launch; for i in \$(seq 20); do P=\$(pidof retroarch) && break; sleep 0.5; done; [ -n \"\$P\" ] && break; sleep 5; done; echo retroarch=\$P"
sleep "$SEC"
shot run
dev 'grep -a -E "run-retroarch: core|companion" /data/banana/logs/banana-ui.log | tail -4; grep -a -i "core.*banana\|bananagba\|mGBA" /run/banana/retroarch.log | head -3' > "$OUT/checks.txt" 2>&1
cat "$OUT/checks.txt"; echo "-> $OUT"
