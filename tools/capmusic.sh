export HOME=/tmp XDG_RUNTIME_DIR=/tmp DISPLAY=:99
pulseaudio --start --exit-idle-time=-1 >/tmp/pa.log 2>&1; sleep 1
pactl load-module module-null-sink sink_name=cap >/tmp/s.log 2>&1
export SDL_AUDIODRIVER=pulseaudio PULSE_SINK=cap
Xvfb :99 -screen 0 640x480x24 >/tmp/x.log 2>&1 & sleep 2
cd /src
./scummvm --path=/game --add >/dev/null 2>&1
parec -d cap.monitor --format=s16le --rate=44100 --channels=2 /out/cap.raw 2>/dev/null &
timeout 16 ./scummvm --music-driver=cms jones 2>/tmp/g.log &
sleep 6
for i in 1 2 3 4 5; do xdotool key F2 2>/dev/null; sleep 0.5; xdotool key Return 2>/dev/null; sleep 0.5; done
sleep 4; pkill scummvm 2>/dev/null; pkill parec 2>/dev/null; sleep 1
echo -n "[cms] "; ffmpeg -y -loglevel error -f s16le -ar 44100 -ac 2 -i /out/cap.raw /tmp/f.wav 2>/dev/null; ffmpeg -i /tmp/f.wav -af volumedetect -f null /dev/null 2>&1 | grep max_volume
