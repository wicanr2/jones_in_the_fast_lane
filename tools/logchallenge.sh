export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_LOG_GFX=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 40 ./scummvm jones 2>/tmp/g.log &
sleep 6
for i in $(seq 1 6); do xdotool key Return 2>/dev/null; sleep 1; done
echo "=MARK=" >> /tmp/g.log
sleep 1; import -window root /out/challenge.png 2>/dev/null
xdotool key Return 2>/dev/null; sleep 2; import -window root /out/challenge2.png 2>/dev/null
pkill scummvm 2>/dev/null
echo "=== MARK 後繪製的 view ==="; awk '/=MARK=/{f=1} f&&/SCI_LOG_GFX view/{print $3}' /tmp/g.log | sort -u | tr '\n' ' '
