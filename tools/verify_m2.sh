export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_CHT_DEBUG=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 60 ./scummvm jones 2>/tmp/g.log &
sleep 8; import -window root /out/shots/copyright.png 2>/dev/null
# 跳過 intro 到棋盤
for k in Return Return Return Return Return Return Return Return; do xdotool key $k 2>/dev/null; sleep 1; done
import -window root /out/shots/board.png 2>/dev/null
xdotool mousemove 160 100 click 1 2>/dev/null; sleep 2; import -window root /out/shots/click1.png 2>/dev/null
pkill scummvm 2>/dev/null; sleep 1
echo "HIT=$(grep -c CHT-HIT /tmp/g.log) MISS=$(grep -c CHT-MISS /tmp/g.log)"
echo "=== MISS 樣本(前10) ==="; grep "CHT-MISS" /tmp/g.log | sed 's/.*CHT-MISS/MISS/' | head -10 | cut -c1-70
