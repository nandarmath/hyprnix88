

#!/bin/bash
# dmenu_ffmpeg
# Copyright (c) 2021 M. Nabil Adani <nblid48[at]gmail[dot]com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# required
# - ffmpeg
# - rofi
# - jq

{pkgs}:
pkgs.writeShellScriptBin "dmenu_ffmpeg" ''
DMENU="rofi -dmenu -i"
VIDEO="$HOME/Videos/record"
AUDIO="$HOME/Music/record"
recordid="/tmp/recordid"

function getInputAudio() {
	description=$(pactl -f json list | jq -r '[.sinks[], .sources[]] [].description' | $DMENU -p "Input Audio " -theme-str 'window {width: 40%;} listview {lines: 8;}')
	pactl -f json list | jq -r '[.sinks[], .sources[]] [] | select(.description == $DESCRIPTION) | .name' --arg DESCRIPTION "$description"
}

function getResolution() {
	xrandr | grep "*" | awk '{print $1}'
}

function audioVideo() {
	filename="$VIDEO/video-$(date '+%y%m%d-%H%M-%S').mp4"
	dimensions=$(getResolution)
	audio=$(getInputAudio)

	if [ -n "$audio" ]; then
		notify-send "Start Recording" "With:\nVideo On\nAudio On"
		ffmpeg -y -f x11grab -framerate 30 -s $dimensions \
			-i :0.0 -f pulse -i $audio -ac 1 \
			-c:v libx264 -pix_fmt yuv420p -preset veryfast -q:v 1 \
			-c:a aac $filename &

		echo $! >$recordid
	fi
}

function video() {
	filename="$VIDEO/video-$(date '+%y%m%d-%H%M-%S').mp4"
	dimensions=$(getResolution)

	notify-send "Start Recording" "With:\nVideo On\nAudio Off"
	ffmpeg -y -f x11grab -framerate 30 -s $dimensions \
		-i :0.0 -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 \
		-c:v libx264 -pix_fmt yuv420p -preset veryfast -q:v 1 $filename &

	echo $! >$recordid
}

function audio() {
	filename="$AUDIO/audio-$(date '+%y%m%d-%H%M-%S').mp3"
	audio=$(getInputAudio)

	if [ -n "$audio" ]; then
		notify-send "Start Recording" "With:\nVideo Off\nAudio On"
		ffmpeg -f pulse -i $audio -ac 1 -acodec libmp3lame -ab 128k $filename &

		echo $! >$recordid
	fi
}

function stream() {
	output=$2
	platform=$1
	dimensions=$(getResolution)
	audio=$(getInputAudio)

	if [ -n "$audio" ]; then
		notify-send "Start Streaming On $platform" "With:\nVideo On\nAudio On"
		ffmpeg -y -f x11grab -framerate 23 -s $dimensions \
			-i :0.0 -f pulse -i $audio -ac 1 \
			-c:v libx264 -pix_fmt yuv420p -preset veryfast -q:v 1 \
			-b:v 500k -b:a 128k \
			-vf scale=854x480 \
			-f flv $output &

		echo $1 >$recordid
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

function streamOnTwitch() {
	startStreaming "Twitch" "rtmp://sin.contribute.live-video.net/app"
}

function streamOnYoutube() {
	startStreaming "Youtube" "rtmp://a.rtmp.youtube.com/live2"
}

function streamOnVimeo() {
	startStreaming "Vimeo" "rtmps://rtmp-global.cloud.vimeo.com:443/live"
}

function stoprecord() {
	if [ -f $recordid ]; then
		kill -15 $(cat $recordid)
		rm $recordid
	fi

	sleep 5
	if [ "$(pidof ffmpeg)" != "" ]; then
		pkill ffmpeg
	fi
}

function endrecord() {
	OPTIONS='["Yes", "No"]'
	select=$(echo $OPTIONS | jq -r ".[]" | $DMENU -p "Record" -mesg "Stop Recording" -theme-str 'window {width: 30%;} listview {lines: 2;}')
	[ "$select" == "Yes" ] && stoprecord
}

function startrecord() {
	OPTIONS='''
    [
        ["難 Audio Video",        "audioVideo"],
        ["  Video Only",         "video"],
        ["  Audio Only",         "audio"],
        ["  Stream On Facebook", "streamOnFacebook"],
        ["既 Stream On Twitch",   "streamOnTwitch"],
        ["  Stream On Youtube",  "streamOnYoutube"],
        ["  Stream On Vimeo",    "streamOnVimeo"]
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

createSaveFolder

if [ -f $recordid ]; then
	endrecord
else
	startrecord
fi
''
