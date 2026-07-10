export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_CHT_DEBUG=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 55 ./scummvm jones 2>/tmp/g.log &
sleep 6
# 逐步過 intro，每步截圖找 challenge 畫面
for i in 1 2 3 4 5 6 7 8 9 10; do xdotool key Return 2>/dev/null; sleep 1.3; import -window root /out/shots/ch_$i.png 2>/dev/null; done
pkill scummvm 2>/dev/null
echo "challenge HIT: $(grep -c 'challenge Jones\|like Jones to\|Would you like' /tmp/g.log)"
grep "CHT-HIT" /tmp/g.log | grep -iE "would|jones|goal|player" | sed 's/.*CHT-HIT/HIT/' | head | cut -c1-45
