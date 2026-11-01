#!/bin/bash
# gba-ab.sh plus|rgds <secs> <tag> <rounds> name=core.so [name=core.so ...]
# A/B series of BananaGBA builds on the quick stress ROM through the real menu launcher (RetroArch, rastats.so
# preloaded), the CPU clock pinned (PIN_KHZ, default 1416000) after each start, A/B/A/B order. Per run: rastats.log,
# the emulator's per-thread CPU (stat delta), SoC temperature before/after. Under locked.sh; < 20 min; leaves nothing.
set -u
D=$1 SEC=$2 TAG=$3 ROUNDS=$4; shift 4
PIN=${PIN_KHZ:-1416000}
DEV=~/bananaos-0.4.3/dev.sh
ROM=${ROM:-$HOME/ovn-gba/tools/test-roms/gbastress-quick.gba}
B=$(basename "$ROM")
OUT=~/stress-runs/gba-ab/$(date +%Y%m%d-%H%M%S)-$D-$TAG; mkdir -p "$OUT"
dev() { "$DEV" "$D" "$@"; }
cleanup() {
	dev 'P=$(pidof retroarch); [ -n "$P" ] && kill -TERM $P; for i in $(seq 20); do [ -e /run/banana/game.pid ] || break; sleep 0.5; done
		c=$(cat /run/rastats/core.bak 2>/dev/null); [ -n "$c" ] && sed -i "s/^core\.gba = .*/core.gba = $c/" /data/banana/settings.conf
		for m in /usr/lib/libretro/mgba_libretro.so /usr/libexec/banana/run-retroarch; do grep -q " $m " /proc/mounts && umount "$m"; done
		f=/sys/devices/system/cpu/cpufreq/policy0; cat $f/cpuinfo_min_freq > $f/scaling_min_freq; cat $f/cpuinfo_max_freq > $f/scaling_max_freq
		rm -f "/data/roms/gba/'"$B"'" /data/saves/gba/'"${B%.*}"'.*; sed -i "/^mgba_banana_/d" /data/retroarch/config/mGBA/mGBA.opt 2>/dev/null; rm -rf /run/rastats; grep "^core.gba" /data/banana/settings.conf' 2>&1 | sed 's/^/cleanup: /'
}
trap cleanup EXIT
dev 'mkdir -p /run/rastats/cores && cat > /run/rastats/rastats.so' < ~/banana-emu/common/rastats/rastats.so || exit 1
dev 'sed "s#LD_PRELOAD=/usr/lib/banana/banana-leaseshim.so #LD_PRELOAD=\"/usr/lib/banana/banana-leaseshim.so /run/rastats/rastats.so\" #" /usr/libexec/banana/run-retroarch > /run/rastats/run-retroarch
	chmod 755 /run/rastats/run-retroarch; mount --bind /run/rastats/run-retroarch /usr/libexec/banana/run-retroarch
	sed -n "s/^core\.gba = //p" /data/banana/settings.conf > /run/rastats/core.bak; sed -i "s/^core\.gba = .*/core.gba = mgba/" /data/banana/settings.conf' || exit 1
NAMES=()
for a in "$@"; do
	n=${a%%=*} so=${a#*=}; NAMES+=("$n")
	~/BananaLinux/output/rgds-plus/host/bin/aarch64-linux-strip -o "$OUT/$n.so" "$so"
	dev "cat > /run/rastats/cores/$n.so" < "$OUT/$n.so" || exit 1
	echo "$n $(md5sum < "$so" | cut -c1-12) $so" >> "$OUT/variants.txt"
done
dev "cat > '/data/roms/gba/$B'" < "$ROM"; sleep 5
for r in $(seq "$ROUNDS"); do
	for n in "${NAMES[@]}"; do
		# (RetroArch saves every core option it saw into mGBA.opt on exit: a variant's own default must not come from the
		# run before; BananaGBA's options are removed again in cleanup)
		dev "sed -i '/^mgba_banana_/d' /data/retroarch/config/mGBA/mGBA.opt 2>/dev/null
			grep -q ' /usr/lib/libretro/mgba_libretro.so ' /proc/mounts && umount /usr/lib/libretro/mgba_libretro.so
			mount --bind /run/rastats/cores/$n.so /usr/lib/libretro/mgba_libretro.so
			t0=\$(cat /sys/class/thermal/thermal_zone0/temp)
			P=
			for try in 1 2 3 4; do
				echo '/data/roms/gba/$B' > /run/banana/launch
				for i in \$(seq 20); do P=\$(pidof retroarch) && break; sleep 0.5; done
				[ -n \"\$P\" ] && break
				sleep 5	# (the library reads a new file only on its home screen: a game list or a closing game delays it)
			done
			[ -n \"\$P\" ] || { echo 'no game'; exit 1; }
			f=/sys/devices/system/cpu/cpufreq/policy0; sleep 1; echo $PIN > \$f/scaling_max_freq; echo $PIN > \$f/scaling_min_freq
			for t in /proc/\$P/task/*; do echo \"\$(cat \$t/comm) \$(cut -d' ' -f14,15 \$t/stat)\"; done > /run/rastats/cpu0
			sleep $SEC
			for t in /proc/\$P/task/*; do echo \"\$(cat \$t/comm) \$(cut -d' ' -f14,15 \$t/stat)\"; done > /run/rastats/cpu1
			echo \"temp \$t0 \$(cat /sys/class/thermal/thermal_zone0/temp) freq \$(cat \$f/scaling_cur_freq)\"
			kill -TERM \$P; for i in \$(seq 40); do [ -e /run/banana/game.pid ] || break; sleep 0.5; done
			echo == cpu0; cat /run/rastats/cpu0; echo == cpu1; cat /run/rastats/cpu1; echo == rastats; cat /run/banana/rastats.log
			cat \$f/cpuinfo_min_freq > \$f/scaling_min_freq; cat \$f/cpuinfo_max_freq > \$f/scaling_max_freq" > "$OUT/$n-$r.txt" 2>&1
		echo "$n round $r: $(grep -m1 '^temp' "$OUT/$n-$r.txt") $(grep 'rastats total' "$OUT/$n-$r.txt")"
		grep -q '^no game' "$OUT/$n-$r.txt" && { echo "the game didn't start: stopping the series"; exit 1; }
	done
done
echo "data: $OUT"
python3 ~/banana-emu/BananaGBA/banana/absum.py "$OUT" "$SEC"
