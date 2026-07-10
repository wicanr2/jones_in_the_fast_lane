export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_CHT_DEBUG=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 90 ./scummvm jones 2>/tmp/g.log &
sleep 6
# 跳 intro credits
for i in $(seq 1 9); do xdotool key Return 2>/dev/null; sleep 1; done
import -window root /out/shots/nav_goal.png 2>/dev/null
# 目標畫面點 DONE (~470,405)
xdotool mousemove 472 405 click 1 2>/dev/null; sleep 3
import -window root /out/shots/nav_board.png 2>/dev/null
# 點布萊克超市(左側 ~95,205)讓角色前往
xdotool mousemove 95 205 click 1 2>/dev/null; sleep 5
import -window root /out/shots/nav_store1.png 2>/dev/null
xdotool key Return 2>/dev/null; sleep 2
import -window root /out/shots/nav_store2.png 2>/dev/null
xdotool mousemove 320 240 click 1 2>/dev/null; sleep 3
import -window root /out/shots/nav_store3.png 2>/dev/null
pkill scummvm 2>/dev/null; sleep 1
echo "HIT=$(grep -c CHT-HIT /tmp/g.log) MISS=$(grep -c CHT-MISS /tmp/g.log)"
echo "=== HIT 樣本 ==="; grep "CHT-HIT" /tmp/g.log | sed 's/.*CHT-HIT/HIT/' | head -12 | cut -c1-55
