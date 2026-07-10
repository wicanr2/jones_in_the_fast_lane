export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/cap.raw
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
printf 'music_volume=255\nsfx_volume=255\nmute=false\n' >> /tmp/.config/scummvm/scummvm.ini
# driver 放 target 前
timeout 45 ./scummvm --music-driver=adlib jones 2>/tmp/g.log &
sleep 6
for i in $(seq 1 10); do xdotool key Return 2>/dev/null; sleep 0.8; done
xdotool mousemove 185 395 click 1 2>/dev/null; sleep 2
xdotool mousemove 472 405 click 1 2>/dev/null; sleep 2
sleep 16
pkill scummvm 2>/dev/null; sleep 1
echo "=== music/driver log ==="; grep -iE "music|adlib|opl|driver|sound" /tmp/g.log | grep -viE "alsa|snd" | head -5
