export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
pulseaudio --start --exit-idle-time=-1 >/tmp/pa.log 2>&1; sleep 1
pactl load-module module-null-sink sink_name=cap >/tmp/s.log 2>&1
export SDL_AUDIODRIVER=pulseaudio PULSE_SINK=cap
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
INI=/tmp/.config/scummvm/scummvm.ini
sed -i 's/^language=en$/language=tw/' "$INI"
printf 'music_driver=pcjr\nmusic_volume=192\n' >> "$INI"
parec -d cap.monitor --format=s16le --rate=44100 --channels=2 /out/verify.raw 2>/dev/null &
timeout 40 ./scummvm jones 2>/tmp/g.log &
sleep 6; for i in $(seq 1 9); do xdotool key Return 2>/dev/null; sleep 0.7; done
xdotool mousemove 185 395 click 1 2>/dev/null; sleep 2; xdotool mousemove 472 405 click 1 2>/dev/null; sleep 12
pkill scummvm 2>/dev/null; pkill parec 2>/dev/null; sleep 1
ffmpeg -y -loglevel error -f s16le -ar 44100 -ac 2 -i /out/verify.raw /tmp/v.wav 2>/dev/null
echo -n "config pcjr 音量: "; ffmpeg -i /tmp/v.wav -af volumedetect -f null /dev/null 2>&1 | grep mean_volume
