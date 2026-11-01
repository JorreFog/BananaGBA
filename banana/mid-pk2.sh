#!/bin/bash
# devrun MID hook: pad presses into the game, then the Pokémon companion's party + summary and the GAME tab (tier 0:
# RetroAchievements rich presence / closest achievements from BananaFront's RA block)
X=~/bananaos-0.4.3/dev.sh
shot() { $X $DEV "python3 /data/ovn-prs/grab.py /run/bfshot.png all >/dev/null 2>&1; for c in 0 1; do [ -f /run/bfshot-crtc\$c.png ] && echo \$c; done" | while read c; do $X $DEV "cat /run/bfshot-crtc$c.png" > "$OUT/$1-crtc$c.png"; done; $X $DEV 'rm -f /run/bfshot*.png'; }
tap() { $X $DEV "echo '$1 $2' > /run/banana/panel-tap"; sleep 2; }
[ -n "${PADSEQ:-}" ] && $X $DEV "python3 /data/ovn-prs/pad.py $PADSEQ"
sleep 6
shot party
tap 100 70; shot summary
tap 560 380; tap 570 447; sleep 3; shot game
tap 68 447
$X $DEV 'cat /run/banana/game-id 2>/dev/null; grep -a -E "companion|identified|pokemon:" /data/banana/logs/banana-ui.log | tail -6' > "$OUT/companion.txt" 2>&1
