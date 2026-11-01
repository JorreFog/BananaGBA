#!/bin/bash
# devrun MID hook for a Pokémon game: pad presses ($PADSEQ) into the game, then the companion's pages through
# /run/banana/panel-tap (640x480 coordinates): party, a member's summary (learns next), the Dex and an entry (where)
X=~/bananaos-0.4.3/dev.sh
shot() { $X $DEV "python3 /data/ovn-prs/grab.py /run/bfshot.png all >/dev/null 2>&1; for c in 0 1; do [ -f /run/bfshot-crtc\$c.png ] && echo \$c; done" | while read c; do $X $DEV "cat /run/bfshot-crtc$c.png" > "$OUT/$1-crtc$c.png"; done; $X $DEV 'rm -f /run/bfshot*.png'; }
tap() { $X $DEV "echo '$1 $2' > /run/banana/panel-tap"; sleep 2; }
[ -n "${PADSEQ:-}" ] && $X $DEV "python3 /data/ovn-prs/pad.py $PADSEQ"
sleep 5
shot party
tap 100 70; shot summary
tap 560 380; tap 370 447; shot dex
tap ${DEXX:-120} ${DEXY:-90}; shot dexentry
tap 300 200; tap 68 447
$X $DEV 'cat /run/banana/game-id 2>/dev/null; grep -a -E "companion|identified|pokemon" /data/banana/logs/banana-ui.log | tail -6' > "$OUT/companion.txt" 2>&1
