export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_CHT_DEBUG=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src; ./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 80 ./scummvm jones 2>/tmp/g.log &
sleep 9; xdotool key Return 2>/dev/null; sleep 3   # 版權→標題
xdotool key Return 2>/dev/null; sleep 2            # 標題→(credits/選單)
# 點「觀看示範」(主選單第 3 顆按鈕,約 y=340)
xdotool mousemove 320 340 click 1 2>/dev/null; sleep 2
# 讓示範自動跑,沿途截圖
for t in 1 2 3 4 5 6 7 8 9 10 11 12; do sleep 3.5; import -window root /out/shots/demo_$t.png 2>/dev/null; done
pkill scummvm 2>/dev/null
grep 'CHT-MISS' /tmp/g.log | sort -u > /out/demo_miss.log
echo "=== 沒翻的繪製文字(CHT-MISS,去重)前 40 ==="
grep 'CHT-MISS' /tmp/g.log | sed 's/.*CHT-MISS\[[0-9]*\]://' | sort -u | grep -vE '^%|^\s*$' | head -40
echo "=== 總 MISS 數 ==="; grep -c 'CHT-MISS' /out/demo_miss.log
