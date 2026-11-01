#!/bin/bash
# devrun MID hook: the game panel with the game companion - panel pictures of two pages and the probe through the shm
X=~/bananaos-0.4.3/dev.sh
shot() { $X $DEV "python3 /data/ovn-prs/grab.py /run/bfshot.png all >/dev/null 2>&1; for c in 0 1; do [ -f /run/bfshot-crtc\$c.png ] && echo \$c; done" | while read c; do $X $DEV "cat /run/bfshot-crtc$c.png" > "$OUT/$1-crtc$c.png"; done; $X $DEV 'rm -f /run/bfshot*.png'; }
shot status
$X $DEV 'echo "tab 1" > /run/banana/panel-tap'; sleep 2
shot phases
$X $DEV 'echo "tab 0" > /run/banana/panel-tap'; sleep 1
$X $DEV 'ls -la /run/banana/companion.shm /run/banana/game-id 2>&1; cat /run/banana/game-id 2>/dev/null | head -20; grep -a -E "companion|game companion" /data/banana/logs/banana-ui.log | tail -4' > "$OUT/companion.txt" 2>&1
