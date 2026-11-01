#!/bin/bash
# gba-front-ab.sh <dev> <gpsp|mgba> <secs> <tag> [core.so]: front's ab.sh (RetroArch vs BananaFront, same core, same
# outside measurement: process CPU %, mean clock, temperatures) for the GBA, with Settings' core.gba set to <core> for
# the run and [core.so] (BananaGBA) bind-mounted over that core's file. Under locked.sh; restores everything.
set -u
D=$1 CORE=$2 SEC=$3 TAG=$4 SO=${5:-}
X=~/bananaos-0.4.3/dev.sh
ROM=${ROM:-$HOME/ovn-gba/tools/test-roms/gbastress-realistic.gba}
dev() { "$X" "$D" "$@"; }
cleanup() {
	dev 'c=$(cat /run/gbafab/core.bak 2>/dev/null); [ -n "$c" ] && sed -i "s/^core\.gba = .*/core.gba = $c/" /data/banana/settings.conf
		m=/usr/lib/libretro/'"$CORE"'_libretro.so; grep -q " $m " /proc/mounts && umount $m
		sed -i "/^mgba_banana_/d" /data/retroarch/config/mGBA/mGBA.opt 2>/dev/null; rm -rf /run/gbafab; grep "^core.gba" /data/banana/settings.conf' 2>&1 | sed 's/^/cleanup: /'
}
trap cleanup EXIT
dev 'mkdir -p /run/gbafab; sed -n "s/^core\.gba = //p" /data/banana/settings.conf > /run/gbafab/core.bak; sed -i "s/^core\.gba = .*/core.gba = '"$CORE"'/" /data/banana/settings.conf; sed -i "/^mgba_banana_/d" /data/retroarch/config/mGBA/mGBA.opt 2>/dev/null'
if [ -n "$SO" ]; then
	~/BananaLinux/output/rgds-plus/host/bin/aarch64-linux-strip -o $HOME/banana-emu/BananaGBA/build/gbafab.so "$SO" 2>/dev/null || cp "$SO" $HOME/banana-emu/BananaGBA/build/gbafab.so
	dev "cat > /run/gbafab/core.so && mount --bind /run/gbafab/core.so /usr/lib/libretro/${CORE}_libretro.so" < $HOME/banana-emu/BananaGBA/build/gbafab.so || exit 1
	rm -f $HOME/banana-emu/BananaGBA/build/gbafab.so
fi
~/banana-emu/BananaFront/tools/ab.sh "$D" gba "$CORE" "$ROM" "$SEC" 2 "$TAG"
