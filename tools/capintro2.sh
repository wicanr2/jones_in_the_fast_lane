export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
sed -i 's/^language=en$/language=tw/' /tmp/.config/scummvm/scummvm.ini
timeout 45 ./scummvm jones 2>/tmp/g.log &
# 密集取樣開頭
for t in $(seq 1 20); do import -window root /out/shots/seq_$(printf %02d $t).png 2>/dev/null; sleep 0.5; done
# 之後按鍵推進看 credits
for i in 1 2 3; do xdotool key Return 2>/dev/null; sleep 0.8; import -window root /out/shots/seq_a$i.png 2>/dev/null; done
pkill scummvm 2>/dev/null
