export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
export SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/cap.raw
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
INI=/tmp/.config/scummvm/scummvm.ini
# 開音樂 + 音量最大 + adlib
cat >> "$INI" <<CFG
music_driver=adlib
music_volume=255
sfx_volume=255
speech_volume=255
mute=false
CFG
timeout 30 ./scummvm jones 2>/tmp/g.log &
sleep 28
pkill scummvm 2>/dev/null; sleep 1
ls -la /out/cap.raw 2>/dev/null
grep -iE "adlib|opl|midi|music|audio" /tmp/g.log | grep -viE "alsa" | head -5
