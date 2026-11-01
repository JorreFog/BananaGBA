#!/bin/bash
# gba-prof.sh plus|rgds <core> <tag> [core.so]: sample RetroArch's main thread (retro_run) with psample in each
# gbastress scene (20 s from 5 s into each 30 s phase) and symbolize per scene -> ~/banana-emu/BananaGBA/banana/prof/<tag>-<scene>.prof
# Separate from the measured runs (sampling distorts timing). Under locked.sh. The unstripped core must be the one
# given (its symbols are read from it).
set -u
D=$1 CORE=$2 TAG=$3 SO=${4:-}
DEV=~/bananaos-0.4.3/dev.sh
ROM=$HOME/ovn-gba/tools/test-roms/gbastress-realistic.gba
B=$(basename "$ROM"); OUT=~/banana-emu/BananaGBA/banana/prof; mkdir -p "$OUT/sym"
dev() { "$DEV" "$D" "$@"; }
cleanup() {
	dev 'P=$(pidof retroarch); [ -n "$P" ] && kill -TERM $P; sleep 2
		c=$(cat /run/rastats/core.bak 2>/dev/null); [ -n "$c" ] && sed -i "s/^core\.gba = .*/core.gba = $c/" /data/banana/settings.conf
		for m in /usr/lib/libretro/'"$CORE"'_libretro.so; do grep -q " $m " /proc/mounts && umount "$m"; done
		rm -f /data/roms/gba/'"$B"' /data/saves/gba/'"${B%.*}"'.*; grep "^core.gba" /data/banana/settings.conf' 2>&1 | sed 's/^/cleanup: /'
}
trap cleanup EXIT
dev 'mkdir -p /run/rastats && cat > /run/rastats/psample && chmod 755 /run/rastats/psample' < ~/p3ds-opt/psample || exit 1
dev 'sed -n "s/^core\.gba = //p" /data/banana/settings.conf > /run/rastats/core.bak; sed -i "s/^core\.gba = .*/core.gba = '"$CORE"'/" /data/banana/settings.conf'
if [ -n "$SO" ]; then
	cp "$SO" "$OUT/sym/${CORE}_libretro.so"
	~/BananaLinux/output/rgds-plus/host/bin/aarch64-linux-strip -o "$OUT/sym/strip.so" "$SO"
	dev "cat > /run/rastats/${CORE}_libretro.so && mount --bind /run/rastats/${CORE}_libretro.so /usr/lib/libretro/${CORE}_libretro.so" < "$OUT/sym/strip.so"
else
	dev "cat /usr/lib/libretro/${CORE}_libretro.so" > "$OUT/sym/${CORE}_libretro.so"
fi
dev "cat > '/data/roms/gba/$B'" < "$ROM"; sleep 5
dev "echo '/data/roms/gba/$B' > /run/banana/launch; for i in \$(seq 60); do pidof retroarch >/dev/null && break; sleep 0.5; done; pidof retroarch" || exit 1
for s in racer shooter town raster loader; do
	sleep 5
	dev 'P=$(pidof retroarch); /run/rastats/psample $P 20 300' > "$OUT/$TAG-$s.samples"
	sleep 5
done
for s in racer shooter town raster loader; do
	python3 ~/p3ds-opt/psym.py "$OUT/$TAG-$s.samples" "$OUT/sym" ~/BananaLinux/output/rgds-plus/host/aarch64-buildroot-linux-gnu/sysroot/lib64 > "$OUT/$TAG-$s.prof" 2>/dev/null
	echo "== $s"; head -${TOPN:-14} "$OUT/$TAG-$s.prof"
done
