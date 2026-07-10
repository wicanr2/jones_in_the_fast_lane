export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 40 ./scummvm jones 2>/tmp/g.log &
for t in 1 2 3 4 5 6; do sleep 1.6; import -window root /out/shots/intro_${t}.png 2>/dev/null; done
pkill scummvm 2>/dev/null
