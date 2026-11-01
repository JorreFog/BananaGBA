#!/bin/bash
# devrun MID hook: tier-0 save states on hardware - save slot 3 through the game panel's pipe, open the States view (a
# tap on the achievements box), tap slot 3 twice (load), pictures; the test's state files are removed afterwards
X=~/bananaos-0.4.3/dev.sh
shot() { $X $DEV "python3 /data/ovn-prs/grab.py /run/bfshot.png all >/dev/null 2>&1; for c in 0 1; do [ -f /run/bfshot-crtc\$c.png ] && echo \$c; done" | while read c; do $X $DEV "cat /run/bfshot-crtc$c.png" > "$OUT/$1-crtc$c.png"; done; $X $DEV 'rm -f /run/bfshot*.png'; }
tap() { $X $DEV "echo '$1 $2' > /run/banana/panel-tap"; sleep 2; }
$X $DEV 'echo "SAVE_STATE_SLOT 3" > /run/banana/retroarch.cmd'; sleep 3
tap 7 447; tap 300 150; shot states
tap 400 150; tap 400 150; sleep 2; shot loaded
$X $DEV 'ls -la /data/states/*/gbastress-realistic.state* 2>&1; grep -a -E "game panel|LOAD_STATE|state" /data/banana/logs/banana-ui.log | tail -4; grep -a -i "state" /data/banana/logs/bananafront.log | tail -4' > "$OUT/states.txt" 2>&1
