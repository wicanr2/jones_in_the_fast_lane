export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src; ./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 55 ./scummvm jones 2>/tmp/g.log &
sleep 9; xdotool key Return 2>/dev/null; sleep 3
for t in 1 2 3 4 5 6 7 8; do import -window root /out/shots/crc_$t.png 2>/dev/null; sleep 2; done
pkill scummvm 2>/dev/null; echo done
