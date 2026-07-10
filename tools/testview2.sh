export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 55 ./scummvm jones 2>/tmp/g.log &
sleep 6
# 過 intro 到選角(約 8-9 次 Return)
for i in $(seq 1 9); do xdotool key Return 2>/dev/null; sleep 1; done
import -window root /out/sg_charsel.png 2>/dev/null
# 點 player1 的 SELECT 按鈕(約 185,395)
xdotool mousemove 185 395 click 1 2>/dev/null; sleep 3
import -window root /out/sg_after_select.png 2>/dev/null
xdotool key Return 2>/dev/null; sleep 2
import -window root /out/sg_goals.png 2>/dev/null
pkill scummvm 2>/dev/null
