export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 40 ./scummvm jones 2>/tmp/g.log &
sleep 8
# 版權 → 按鍵到標題
xdotool key Return 2>/dev/null; sleep 2
import -window root /out/shots/title_cht.png 2>/dev/null
pkill scummvm 2>/dev/null
