export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99 SDL_AUDIODRIVER=disk SDL_DISKAUDIOFILE=/out/cap.raw
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
INI=/tmp/.config/scummvm/scummvm.ini
printf 'music_volume=255\nsfx_volume=255\nmute=false\n' >> "$INI"
timeout 55 ./scummvm jones 2>/tmp/g.log &
sleep 6
for i in $(seq 1 10); do xdotool key Return 2>/dev/null; sleep 0.8; done
xdotool mousemove 185 395 click 1 2>/dev/null; sleep 2   # 選角
xdotool mousemove 472 405 click 1 2>/dev/null; sleep 2   # goal done
# 到棋盤,hold 錄音樂
sleep 22
pkill scummvm 2>/dev/null; sleep 1
ls -la /out/cap.raw
