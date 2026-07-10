export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_LOG_GFX=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 45 ./scummvm jones 2>/tmp/g.log &
sleep 6
for i in $(seq 1 9); do xdotool key Return 2>/dev/null; sleep 1; done   # 到目標畫面
sleep 1; echo "=MARK_GOAL=" >> /tmp/g.log
pkill scummvm 2>/dev/null
echo "=== 目標畫面前後繪製的 view(去重) ==="
grep "SCI_LOG_GFX view" /tmp/g.log | awk '{print $3}' | sort -u | tr '\n' ' '
