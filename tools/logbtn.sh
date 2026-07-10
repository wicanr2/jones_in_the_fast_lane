export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_LOG_GFX=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src; ./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 45 ./scummvm jones 2>/tmp/g.log &
sleep 9; for i in $(seq 1 7); do xdotool key Return 2>/dev/null; sleep 1; done
xdotool mousemove 408 315 click 1 2>/dev/null; sleep 3   # 關 play-fair → goals
pkill scummvm 2>/dev/null
echo "=== goals 畫面的 view=250 繪製(loop/cel/尺寸/位置)==="
grep 'view=250' /tmp/g.log | sort | uniq -c | sort -rn | head -20
