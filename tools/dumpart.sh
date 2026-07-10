export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_DUMP_ALLVIEWS=/out/allviews SCI_DUMP_PIC=/out/pics
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 30 ./scummvm jones 2>/tmp/g.log &
sleep 8
# 走到棋盤觸發 pic dump
for i in $(seq 1 9); do xdotool key Return 2>/dev/null; sleep 1; done
xdotool mousemove 472 405 click 1 2>/dev/null; sleep 3
pkill scummvm 2>/dev/null; sleep 1
echo "views dumped: $(ls /out/allviews 2>/dev/null | wc -l)"
echo "pics dumped: $(ls /out/pics 2>/dev/null | wc -l)"
