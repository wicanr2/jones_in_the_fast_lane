export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_LOG_GFX=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 60 ./scummvm jones 2>/tmp/g.log &
sleep 8
for i in $(seq 1 7); do xdotool key Return 2>/dev/null; sleep 1; done
echo "===MARK_BEFORE_DISMISS===" >> /tmp/g.log
# 關 play-fair(公平競爭)→ 進 JONES GOALS 畫面
xdotool mousemove 408 315 click 1 2>/dev/null; sleep 3
echo "===MARK_GOALS_SHOWN===" >> /tmp/g.log
import -window root /out/shots/goals_logged.png 2>/dev/null
pkill scummvm 2>/dev/null
# 只保留 GFX log 到 out
grep 'SCI_LOG_GFX\|MARK' /tmp/g.log > /out/goals_gfx.log
echo "=== 最後 40 條 GFX 繪製(goals 畫面)==="; grep 'SCI_LOG_GFX\|MARK' /tmp/g.log | tail -40
