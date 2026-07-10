export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_DUMP_ALLVIEWS=/out
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 20 ./scummvm jones 2>/tmp/g.log &
sleep 12
pkill scummvm 2>/dev/null
ls /out/view_506_*.ppm 2>/dev/null
