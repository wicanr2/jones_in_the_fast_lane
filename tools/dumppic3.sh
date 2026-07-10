export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_DUMP_PIC=/out
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 40 ./scummvm jones 2>/tmp/g.log &
sleep 7
for i in $(seq 1 10); do xdotool key Return 2>/dev/null; sleep 1; done
xdotool mousemove 472 405 click 1 2>/dev/null; sleep 3
xdotool mousemove 95 205 click 1 2>/dev/null; sleep 3
pkill scummvm 2>/dev/null
ls /out/pic_11.ppm 2>/dev/null
