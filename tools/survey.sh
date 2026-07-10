export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
timeout 75 ./scummvm jones 2>/tmp/g.log &
# 跳過 intro credits(多次 Enter/Esc)，到主選單
sleep 5
for k in Return Return Return Return Return Return Return Return; do xdotool key $k 2>/dev/null; sleep 1.2; done
import -window root /out/survey/a_menu.png 2>/dev/null
xdotool key Return 2>/dev/null; sleep 2; import -window root /out/survey/b.png 2>/dev/null
xdotool key space 2>/dev/null; sleep 2; import -window root /out/survey/c.png 2>/dev/null
# 試著點畫面各處
xdotool mousemove 160 100 click 1 2>/dev/null; sleep 2; import -window root /out/survey/d.png 2>/dev/null
xdotool mousemove 320 150 click 1 2>/dev/null; sleep 2; import -window root /out/survey/e.png 2>/dev/null
pkill scummvm 2>/dev/null
