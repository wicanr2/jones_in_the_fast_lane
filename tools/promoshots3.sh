export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 110 ./scummvm jones 2>/tmp/g.log &
sleep 8
for i in $(seq 1 7); do xdotool key Return 2>/dev/null; sleep 1; done
# 關 play-fair(公平競爭)
xdotool mousemove 408 315 click 1 2>/dev/null; sleep 3
# 關 JONES GOALS(綠色「完成」鈕 ~430,388)
xdotool mousemove 430 388 click 1 2>/dev/null; sleep 3
import -window root /out/shots/s_realboard.png 2>/dev/null              # 可玩棋盤
# 進商店:超市(左 ~95,205)
xdotool mousemove 95 205 click 1 2>/dev/null; sleep 4
import -window root /out/shots/s_store.png 2>/dev/null
xdotool key Return 2>/dev/null; sleep 2
import -window root /out/shots/s_store2.png 2>/dev/null
# 再點另一店:銀行(左下 ~63,315)
xdotool key Escape 2>/dev/null; sleep 2
xdotool mousemove 63 315 click 1 2>/dev/null; sleep 4
import -window root /out/shots/s_bank.png 2>/dev/null
pkill scummvm 2>/dev/null
echo "=== g.log tail ==="; tail -6 /tmp/g.log
