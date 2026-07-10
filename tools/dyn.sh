export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_CHT_DEBUG=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 60 ./scummvm jones 2>/tmp/g.log &
sleep 6
for i in $(seq 1 9); do xdotool key Return 2>/dev/null; sleep 1; done
import -window root /out/shots/dyn_goal.png 2>/dev/null
xdotool mousemove 472 405 click 1 2>/dev/null; sleep 3
import -window root /out/shots/dyn_board.png 2>/dev/null
pkill scummvm 2>/dev/null
echo "HIT=$(grep -c CHT-HIT /tmp/g.log) MISS=$(grep -c CHT-MISS /tmp/g.log)"
echo "=== 剩餘 MISS(前15) ==="; grep "CHT-MISS" /tmp/g.log | sed 's/.*CHT-MISS/M/' | sort -u | head -15 | cut -c1-55
