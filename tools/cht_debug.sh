export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_CHT_DEBUG=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 22 ./scummvm jones 2>/tmp/g.log
echo "=== CHT 載入筆數 ==="; grep -i "CHT: loaded" /tmp/g.log
echo "=== CHT-HIT 次數 ==="; grep -c "CHT-HIT" /tmp/g.log
echo "=== CHT-MISS 樣本(前20，看遊戲實際查什麼) ==="; grep "CHT-MISS" /tmp/g.log | head -20
