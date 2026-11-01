#!/bin/bash
# devrun MID hook: BananaFront's threads and their CPU over 20 s (is the render thread there, and how busy each is)
X=~/bananaos-0.4.3/dev.sh
$X $DEV 'P=$(pidof bananafront); for t in /proc/$P/task/*; do echo "$(cat $t/comm) $(cut -d" " -f14,15,39 $t/stat)"; done > /run/bdev/t0; sleep 20;
	for t in /proc/$P/task/*; do echo "$(cat $t/comm) $(cut -d" " -f14,15,39 $t/stat)"; done > /run/bdev/t1; echo == t0; cat /run/bdev/t0; echo == t1; cat /run/bdev/t1;
	echo == freq; cat /sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq; echo == rastats; tail -25 /run/bdev/bf/rastats.log 2>/dev/null' > "$OUT/threads.txt" 2>&1
