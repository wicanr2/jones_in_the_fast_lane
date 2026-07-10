export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/cap.raw
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
printf 'music_volume=255\nsfx_volume=255\nmute=false\n' >> /tmp/.config/scummvm/scummvm.ini
# 標題畫面 hold,不按鍵(標題曲應播);sound debug
timeout 25 ./scummvm --music-driver=adlib --debugflags=Sound,Music --debuglevel=2 jones 2>/tmp/g.log &
sleep 23; pkill scummvm 2>/dev/null; sleep 1
echo "=== sound 相關 log ==="
grep -iE "sound|music|adlib|opl|midi|track|patch.*bank|kDoSound|play" /tmp/g.log | grep -viE "alsa|snd_|resource\.00" | head -20
