#!/bin/bash
# devrun MID hook: psample of BananaFront's main thread for 20 s (where the core's frame goes in BananaFront)
X=~/bananaos-0.4.3/dev.sh
$X $DEV 'cat > /run/bdev/bf/psample && chmod 755 /run/bdev/bf/psample' < ~/p3ds-opt/psample
$X $DEV 'P=$(pidof bananafront); /run/bdev/bf/psample $P 20 300; cat /sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq >&2' > "$OUT/main.samples" 2> "$OUT/freq.txt"
$X $DEV 'P=$(pidof bananafront); for t in /proc/$P/task/*; do echo "$(cat $t/comm) $(cut -d" " -f14,15 $t/stat)"; done > /run/bdev/t0; sleep 15;
	for t in /proc/$P/task/*; do echo "$(cat $t/comm) $(cut -d" " -f14,15 $t/stat)"; done > /run/bdev/t1; echo == t0; cat /run/bdev/t0; echo == t1; cat /run/bdev/t1;
	echo == freq; cat /sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq /sys/devices/system/cpu/cpufreq/policy0/scaling_governor' > "$OUT/threads.txt" 2>&1
