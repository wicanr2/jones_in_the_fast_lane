set -e
export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_DUMP_PIC=/out/pic904_spike
mkdir -p /out/pic904_spike
Xvfb :99 -screen 0 640x480x24 >/tmp/xvfb.log 2>&1 &
sleep 2
cd /src
timeout 140 ./scummvm --path=/game --auto-detect --language=tw 2>/tmp/sv.log &
SV=$!
for s in $(seq 1 17); do sleep 4.5; xdotool key Escape 2>/dev/null||true; xdotool mousemove 320 240 click 1 2>/dev/null||true; done
sleep 2; xdotool mousemove 300 220 click 1 2>/dev/null||true
sleep 3; xdotool key Return 2>/dev/null||true; xdotool mousemove 320 240 click 1 2>/dev/null||true
for s in $(seq 1 8); do sleep 5; xdotool key Return 2>/dev/null||true; import -window root /out/shots_spike/cc_$(printf %02d $s).png 2>/dev/null||true; done
kill $SV 2>/dev/null || true
sleep 1
ls -la /out/pic904_spike/ || true
