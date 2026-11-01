#!/bin/bash
# devrun MID hook for a real game: the pad presses in $PADSEQ (pad.py words, e.g. "start w2 a w2 a"), then panel pictures
X=~/bananaos-0.4.3/dev.sh
shot() { $X $DEV "python3 /data/ovn-prs/grab.py /run/bfshot.png all >/dev/null 2>&1; for c in 0 1; do [ -f /run/bfshot-crtc\$c.png ] && echo \$c; done" | while read c; do $X $DEV "cat /run/bfshot-crtc$c.png" > "$OUT/$1-crtc$c.png"; done; $X $DEV 'rm -f /run/bfshot*.png'; }
shot before
[ -n "${PADSEQ:-}" ] && $X $DEV "python3 /data/ovn-prs/pad.py $PADSEQ"
sleep 4
shot after
$X $DEV 'cat /run/banana/game-id 2>/dev/null; grep -a -E "companion|identified|game panel" /data/banana/logs/banana-ui.log | tail -5' > "$OUT/companion.txt" 2>&1
