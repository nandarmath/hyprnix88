#!/usr/bin/env bash
# dmenu_hyprland_stream
# Script untuk streaming rekaman layar di Wayland dengan Hyprland
# Terinspirasi dari dmenu_ffmpeg

# Required:
# - wl-screenrec (untuk merekam layar di Wayland)
# - ffmpeg
# - rofi
# - jq
# - pipewire
# - hyprctl (bagian dari Hyprland compositor)
# - v4l2loopback kernel module (untuk virtual video device)

DMENU="rofi -dmenu -i"
VIDEO="$HOME/Videos/record"
AUDIO="$HOME/Music/record"
recordid="/tmp/recordid"
streamid="/tmp/streamid"

function getInputAudio() {
    description=$(pactl -f json list | jq -r '[.sinks[], .sources[]] [].description' | $DMENU -p "Input Audio " -theme-str 'window {width: 40%;} listview {lines: 8;}')
    pactl -f json list | jq -r '[.sinks[], .sources[]] [] | select(.description == $DESCRIPTION) | .name' --arg DESCRIPTION "$description"
}

function getMonitor() {
    # Get list of available monitors for Hyprland
    monitors=$(hyprctl monitors -j | jq -r '.[].name')
    echo "$monitors" | $DMENU -p "Select Monitor " -theme-str 'window {width: 40%;} listview {lines: 8;}'
}

function getResolution() {
    # Get resolution for the selected monitor in Hyprland
    monitor=$1
    hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor\") | \"\(.width)x\(.height)\""
}

function audioVideo() {
    filename="$VIDEO/video-$(date '+%y%m%d-%H%M-%S').mp4"
    monitor=$(getMonitor)
    
    if [ -z "$monitor" ]; then
        notify-send "Recording Canceled" "No monitor selected"
        exit 1
    fi
    
    audio=$(getInputAudio)

    if [ -n "$audio" ]; then
        notify-send "Start Recording" "With:\nVideo On\nAudio On\nMonitor: $monitor"
        
        # Record screen with audio using wl-screenrec
        wl-screenrec --filename "$filename" --output "$monitor" --audio --audio-device "$audio" &
        echo $! > $recordid
    else
        notify-send "Recording Canceled" "No audio input selected"
    fi
}

function video() {
    filename="$VIDEO/video-$(date '+%y%m%d-%H%M-%S').mp4"
    monitor=$(getMonitor)
    
    if [ -z "$monitor" ]; then
        notify-send "Recording Canceled" "No monitor selected"
        exit 1
    fi
    
    notify-send "Start Recording" "With:\nVideo On\nAudio Off\nMonitor: $monitor"
    
    # Record screen without audio using wl-screenrec
    wl-screenrec --filename "$filename" --output "$monitor" &
    echo $! > $recordid
}

function audio() {
    filename="$AUDIO/audio-$(date '+%y%m%d-%H%M-%S').mp3"
    audio=$(getInputAudio)

    if [ -n "$audio" ]; then
        notify-send "Start Recording" "With:\nVideo Off\nAudio On"
        ffmpeg -f pulse -i $audio -ac 1 -acodec libmp3lame -ab 128k $filename &
        echo $! > $recordid
    else
        notify-send "Recording Canceled" "No audio input selected"
    fi
}

function stream() {
    output=$2
    platform=$1
    monitor=$(getMonitor)
    
    if [ -z "$monitor" ]; then
        notify-send "Streaming Canceled" "No monitor selected"
        exit 1
    fi
    
    audio=$(getInputAudio)

    if [ -n "$audio" ]; then
        notify-send "Start Streaming On $platform" "With:\nVideo On\nAudio On\nMonitor: $monitor"
        
        resolution=$(getResolution "$monitor")
        
        # Tentukan resolusi yang lebih rendah untuk streaming
        # Ini membantu menghindari masalah alokasi memori
        stream_resolution="1280x720"
        
        # Pendekatan dua langkah:
        # 1. Rekam ke file sementara yang dimaksudkan untuk streaming
        temp_file="/tmp/stream_temp.mp4"
        
        # Gunakan wl-screenrec dengan resolusi dan bitrate yang dioptimalkan
        wl-screenrec --filename "$temp_file" --output "$monitor" \
            --audio --audio-device "$audio" \
            --codec "avc" --bitrate "2 MB" \
            --encode-pixfmt "yuv420p" \
            --encode-resolution "$stream_resolution" \
            --low-power "on" &
        
        wl_recorder_pid=$!
        echo $wl_recorder_pid > $recordid
        
        # Beri waktu untuk memastikan file mulai terekam
        sleep 3
        
        # 2. Stream menggunakan ffmpeg
        ffmpeg -re -i "$temp_file" \
            -c:v libx264 -preset ultrafast -tune zerolatency \
            -c:a aac -b:a 128k \
            -b:v 2000k -maxrate 2000k -bufsize 4000k \
            -f flv "$output" &
        
        stream_pid=$!
        echo $stream_pid > $streamid
        
        notify-send "Streaming Started" "Streaming to $platform"
    else
        notify-send "Streaming Canceled" "No audio input selected"
    fi
}

function getStreamToken() {
    $DMENU -p "Stream" -mesg "Insert $1 Token" -theme-str 'listview {lines: 0;}'
}

function startStreaming() {
    platform="$1"
    streamurl="$2"
    token=$(getStreamToken "$platform")

    if [ -z "$token" ]; then
        exit
    fi

    stream "$platform" "$streamurl/$token"
}

function streamOnFacebook() {
    startStreaming "Facebook" "rtmps://live-api-s.facebook.com:443/rtmp"
}

function streamOnYoutube() {
    startStreaming "Youtube" "rtmp://a.rtmp.youtube.com/live2"
}

function streamOnTwitch() {
    startStreaming "Twitch" "rtmp://sin.contribute.live-video.net/app"
}

function streamOnVimeo() {
    startStreaming "Vimeo" "rtmps://rtmp-global.cloud.vimeo.com:443/live"
}

function stoprecord() {
    if [ -f $recordid ]; then
        kill -15 $(cat $recordid)
        rm $recordid
    fi
    
    if [ -f $streamid ]; then
        kill -15 $(cat $streamid)
        rm $streamid
    fi

    sleep 3
    if [ "$(pidof wl-screenrec)" != "" ]; then
        pkill wl-screenrec
    fi
    
    if [ "$(pidof ffmpeg)" != "" ]; then
        pkill ffmpeg
    fi
    
    # Hapus file sementara jika ada
    if [ -f "/tmp/stream_temp.mp4" ]; then
        rm "/tmp/stream_temp.mp4"
    fi
    
    notify-send "Recording Stopped" "Recording or streaming has been terminated"
}

function endrecord() {
    OPTIONS='["Yes", "No"]'
    select=$(echo $OPTIONS | jq -r ".[]" | $DMENU -p "Record" -mesg "Stop Recording/Streaming" -theme-str 'window {width: 30%;} listview {lines: 2;}')
    [ "$select" == "Yes" ] && stoprecord
}

function startrecord() {
    OPTIONS='''
    [
        ["難 Audio Video",        "audioVideo"],
        ["  Video Only",         "video"],
        ["  Audio Only",         "audio"],
        ["  Stream On Facebook", "streamOnFacebook"],
        ["既 Stream On Youtube",  "streamOnYoutube"],
        ["  Stream On Twitch",   "streamOnTwitch"],
        ["  Stream On Vimeo",    "streamOnVimeo"]
    ]
    '''

    select=$(echo $OPTIONS | jq -r ".[][0]" | $DMENU -p "Record" -theme-str 'window {width: 30%;} listview {lines: 5;}')
    eval $(echo $OPTIONS | jq -r ".[] | select(.[0] == \"$select\") | .[1]")
}

function createSaveFolder() {
    if [ ! -d $VIDEO ]; then
        mkdir -p $VIDEO
    fi
    if [ ! -d $AUDIO ]; then
        mkdir -p $AUDIO
    fi
}

function checkDependencies() {
    dependencies=("wl-screenrec" "ffmpeg" "rofi" "jq" "pactl" "hyprctl")
    missing_deps=()
    
    for dep in "${dependencies[@]}"; do
        if ! command -v $dep &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        notify-send "Missing Dependencies" "Please install: ${missing_deps[*]}"
        exit 1
    fi
}

function setupEnvironment() {
    # Periksa apakah /dev/video0 sudah ada dan dapat diakses
    if [ ! -e "/dev/video0" ]; then
        notify-send "Error" "Virtual video device /dev/video0 not found."
        exit 1
    fi
    
    if [ ! -w "/dev/video0" ]; then
        notify-send "Error" "No write permission to /dev/video0. Run: sudo chmod a+rw /dev/video0"
        exit 1
    fi
}

# Check dependencies first
checkDependencies

# Setup environment
setupEnvironment

# Create save folders
createSaveFolder

# Check if already recording
if [ -f $recordid ] || [ -f $streamid ]; then
    endrecord
else
    startrecord
fi
