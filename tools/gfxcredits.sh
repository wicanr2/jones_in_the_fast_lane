export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_LOG_GFX=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 55 ./scummvm jones 2>/tmp/g.log &
sleep 9; xdotool key Return 2>/dev/null; sleep 2
echo "===CREDITS_START===" >> /tmp/g.log
sleep 14
pkill scummvm 2>/dev/null
# 取 CREDITS_START 之後的 view/pic 繪製
awk '/CREDITS_START/{f=1} f' /tmp/g.log | grep -oE 'view=[0-9]+|pic=[0-9]+' | sort | uniq -c | sort -rn > /out/credits_gfx.txt
echo "=== credits 期間繪製的 view/pic ==="; cat /out/credits_gfx.txt
