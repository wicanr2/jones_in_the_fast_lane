export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_CHT_DEBUG=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src; ./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 70 ./scummvm jones 2>/tmp/g.log &
sleep 9; xdotool key Return 2>/dev/null; sleep 3; xdotool key Return 2>/dev/null; sleep 2
xdotool mousemove 320 340 click 1 2>/dev/null; sleep 2   # 觀看示範
for t in 1 2 3 4 5 6 7 8 9 10 11 12; do sleep 3.5; done
pkill scummvm 2>/dev/null
echo "=== text.700 標籤現在是 CHT-HIT?(Trade School/Professor/Refrigerator/Hamburgers/Bank/Factory)==="
grep -E 'CHT-HIT.*(Trade School|Professor|Teacher|Refrigerator|Hamburgers|Bank|Factory|University|Employment)' /tmp/g.log | sed 's/.*CHT-HIT\[[0-9]*\]://' | sort -u | head -20
echo "=== 還有沒有這些的 MISS? ==="
grep -E 'CHT-MISS.*(Trade School|Professor|Teacher|Refrigerator|Bank$)' /tmp/g.log | head -5
