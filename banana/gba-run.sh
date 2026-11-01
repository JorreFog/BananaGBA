#!/bin/bash
# gba-run.sh plus|rgds <core> <seconds> <tag> [core.so] [rom]
# One GBA stress run through the real menu launcher (run-retroarch) with frame stats (rastats.so preloaded) and
# full data collection (stress-test-roms' stress-run.sh). <core>: gpsp | mgba (Settings' core.gba for this run).
# [core.so]: a build to test, bind-mounted over /usr/lib/libretro/<core>_libretro.so for the run.
# Run it under locked.sh. Leaves nothing behind: settings line restored, bind mounts removed (trap).
set -u
D=$1 CORE=$2 SEC=$3 TAG=$4 SO=${5:-} ROM=${6:-$HOME/ovn-gba/tools/test-roms/gbastress-realistic.gba}
DEV=~/bananaos-0.4.3/dev.sh
RS=~/banana-emu/common/rastats/rastats.so
dev() { "$DEV" "$D" "$@"; }
cleanup() {
	dev 'c=$(cat /run/rastats/core.bak 2>/dev/null); [ -n "$c" ] && sed -i "s/^core\.gba = .*/core.gba = $c/" /data/banana/settings.conf
		for m in /usr/lib/libretro/'"$CORE"'_libretro.so /usr/libexec/banana/run-retroarch; do grep -q " $m " /proc/mounts && umount "$m"; done
		grep "^core.gba" /data/banana/settings.conf; grep -c rastats /proc/mounts' 2>&1 | sed 's/^/cleanup: /'
}
trap cleanup EXIT
dev 'mkdir -p /run/rastats && cat > /run/rastats/rastats.so' < "$RS" || exit 1
dev 'sed "s#LD_PRELOAD=/usr/lib/banana/banana-leaseshim.so #LD_PRELOAD=\"/usr/lib/banana/banana-leaseshim.so /run/rastats/rastats.so\" #" /usr/libexec/banana/run-retroarch > /run/rastats/run-retroarch
	chmod 755 /run/rastats/run-retroarch; grep -c rastats.so /run/rastats/run-retroarch >/dev/null || exit 1
	mount --bind /run/rastats/run-retroarch /usr/libexec/banana/run-retroarch
	sed -n "s/^core\.gba = //p" /data/banana/settings.conf > /run/rastats/core.bak
	sed -i "s/^core\.gba = .*/core.gba = '"$CORE"'/" /data/banana/settings.conf; grep "^core.gba" /data/banana/settings.conf' || exit 1
if [ -n "$SO" ]; then
	dev "cat > /run/rastats/${CORE}_libretro.so" < "$SO" || exit 1
	dev "mount --bind /run/rastats/${CORE}_libretro.so /usr/lib/libretro/${CORE}_libretro.so && md5sum /usr/lib/libretro/${CORE}_libretro.so"
	echo "local $(md5sum < "$SO")"
fi
STRESS_LIBDIR=/data/roms/gba ~/.claude/skills/stress-test-roms/scripts/stress-run.sh "$D" "$ROM" "$SEC" "$TAG"
