export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 70 ./scummvm jones 2>/tmp/g.log &
sleep 8;  import -window root /out/shots/s_copyright.png 2>/dev/null   # 版權
# 過 intro
for i in $(seq 1 7); do xdotool key Return 2>/dev/null; sleep 1; done
import -window root /out/shots/s_charsel.png 2>/dev/null               # 選角(選擇角色)
xdotool mousemove 185 395 click 1 2>/dev/null; sleep 3
import -window root /out/shots/s_goals.png 2>/dev/null                 # 目標畫面
xdotool mousemove 472 405 click 1 2>/dev/null; sleep 3
import -window root /out/shots/s_board.png 2>/dev/null                 # 棋盤(中文招牌)
xdotool mousemove 95 205 click 1 2>/dev/null; sleep 4
import -window root /out/shots/s_dialogue.png 2>/dev/null              # 商店對白
pkill scummvm 2>/dev/null
