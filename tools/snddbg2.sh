export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/cap.raw
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
timeout 20 ./scummvm --music-driver=adlib jones 2>/tmp/g.log &
sleep 18; pkill scummvm 2>/dev/null; sleep 1
echo "=== 音訊/mixer/驅動 init ==="
grep -iE "audio|mixer|sample|output rate|adlib|opl|midi|driver|22050|44100|48000" /tmp/g.log | grep -viE "resource\.|snd_" | head -20
