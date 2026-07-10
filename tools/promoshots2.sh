export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 90 ./scummvm jones 2>/tmp/g.log &
sleep 8;  import -window root /out/shots/s_copyright.png 2>/dev/null   # 版權(繁中)
# 過 intro → 進棋盤(此時跳出「公平競爭/全力一搏」對話框)
for i in $(seq 1 7); do xdotool key Return 2>/dev/null; sleep 1; done
import -window root /out/shots/s_playfair.png 2>/dev/null              # play-fair 對話框(公平競爭/全力一搏)
# 點「公平競爭」關掉對話框 → 乾淨棋盤
xdotool mousemove 408 315 click 1 2>/dev/null; sleep 3
import -window root /out/shots/s_board.png 2>/dev/null                 # 乾淨棋盤(中文招牌)
# 進一間商店(左側「超市」約 x=95 y=205)看店內中文品項
xdotool mousemove 95 205 click 1 2>/dev/null; sleep 4
import -window root /out/shots/s_store.png 2>/dev/null                 # 商店內(品項/價格)
xdotool key Return 2>/dev/null; sleep 2
import -window root /out/shots/s_store2.png 2>/dev/null
pkill scummvm 2>/dev/null
echo "=== g.log tail ==="; tail -8 /tmp/g.log
