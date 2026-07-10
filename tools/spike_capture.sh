export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SCI_CHT_DEBUG=1
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 40 ./scummvm jones 2>/tmp/g.log &
SV=$!
for i in 05 07 09 11 13; do sleep 2; import -window root /out/shots/z${i}.png 2>/dev/null; done
kill $SV 2>/dev/null
echo "HIT=$(grep -c CHT-HIT /tmp/g.log) MISS=$(grep -c CHT-MISS /tmp/g.log)"
grep "CHT-HIT" /tmp/g.log | head -3 | cut -c1-60
