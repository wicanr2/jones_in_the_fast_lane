export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
# 1) 先把偵測到的遊戲加入 config
./scummvm --path=/game --add 2>/tmp/add.log
echo "=== added targets ==="; grep -A2 '^\[' /tmp/.config/scummvm/scummvm.ini 2>/dev/null | head; cat /tmp/.scummvmrc 2>/dev/null | grep -i '^\[' 
# 2) 用 SCI_DUMP_RES 跑該 target（dump 完即結束）
export SCI_DUMP_RES=/out
timeout 25 ./scummvm jones 2>/tmp/g.log
echo "=== stderr 重點 ==="
grep -iE "dump|identify|error|warning: SCI" /tmp/g.log | head -15
echo "=== dump 種類/數量 ==="
ls /out 2>/dev/null | sed 's/\.[0-9]*$//' | sort | uniq -c
