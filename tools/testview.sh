export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 45 ./scummvm jones 2>/tmp/g.log &
sleep 6
for i in $(seq 1 10); do xdotool key Return 2>/dev/null; sleep 1; import -window root /out/g_$i.png 2>/dev/null; done
pkill scummvm 2>/dev/null
grep -iE "506.v56|patch" /tmp/g.log | head -3
