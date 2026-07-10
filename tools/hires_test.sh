export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_CHT_HIRES=1
Xvfb :99 -screen 0 1280x960x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 45 ./scummvm jones 2>/tmp/g.log &
sleep 7; import -window root /out/hires_copyright.png 2>/dev/null
for i in $(seq 1 9); do xdotool key Return 2>/dev/null; sleep 0.8; done
xdotool mousemove 185 395 click 1 2>/dev/null; sleep 2; xdotool mousemove 472 405 click 1 2>/dev/null; sleep 3
import -window root /out/hires_board.png 2>/dev/null
xdotool mousemove 95 205 click 1 2>/dev/null; sleep 4; import -window root /out/hires_dialogue.png 2>/dev/null
pkill scummvm 2>/dev/null
echo "screen size:"; grep -iE "resolution|640x400|display" /tmp/g.log | head -2
