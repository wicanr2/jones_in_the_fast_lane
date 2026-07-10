export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_CHT_DEBUG=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 60 ./scummvm jones 2>/tmp/g.log &
sleep 9
xdotool key Return 2>/dev/null      # 版權 → 標題
sleep 3
echo "===MARK_TITLE===" >> /tmp/g.log
import -window root /out/shots/cr_title.png 2>/dev/null
# 讓 credits 自動播放,沿途截圖
for t in 1 2 3 4 5 6 7 8; do sleep 2.2; import -window root /out/shots/cr_$t.png 2>/dev/null; done
pkill scummvm 2>/dev/null
grep -E 'CHT-(HIT|MISS)|MARK' /tmp/g.log | sort -u > /out/credits_cht.log
echo "=== credits 相關 CHT 記錄(Producer/Design/William/Programm/Art/Music/by)==="
grep -iE 'CHT-(MISS|HIT).*(produc|design|william|programm|art|music|direct|writ| by |lead|manag|test)' /out/credits_cht.log | head -30
echo "=== 全部不重複 CHT-MISS 數 ==="; grep -c 'CHT-MISS' /out/credits_cht.log
