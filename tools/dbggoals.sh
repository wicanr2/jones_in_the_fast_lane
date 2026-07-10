export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_CHT_DEBUG=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 55 ./scummvm jones 2>/tmp/g.log &
sleep 8
for i in $(seq 1 7); do xdotool key Return 2>/dev/null; sleep 1; done
xdotool mousemove 408 315 click 1 2>/dev/null; sleep 3
pkill scummvm 2>/dev/null
grep 'CHT-' /tmp/g.log | sort -u > /out/cht_goals.log
echo "=== 總 CHT 行 ==="; wc -l /out/cht_goals.log
echo "=== 含 Goal/Point/數字 ==="; grep -iE 'goal|point|= ?[0-9]' /out/cht_goals.log | head
echo "=== goals 畫面附近 MISS 樣本(前 30) ==="; grep 'CHT-MISS' /out/cht_goals.log | head -30
