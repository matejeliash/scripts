#!/bin/sh


# this script convert  video stream to h264 codec so it can be played on more devices
# this uses ffmpeg and vaapi for faster encoding
# audio stream is not changed most of time audio stream is not problem
# this also work with http video streams

rename(){
	name="$(echo "$1" | sed -e 's/%2./-/g')"
	echo "$name"
}

for file in "$@" ; do
	qp="20"
	name="qp${qp}-$(basename "$file")"
	name="$(rename "$name")"
	echo "$name"

	ffmpeg -hwaccel vaapi -vaapi_device /dev/dri/renderD128 \
	  -i "$file" \
	  -c:v h264_vaapi  -profile:v high -preset quality -qp "$qp"   -vf 'format=nv12,hwupload' -map 0   -c:a copy  -sn "$name"


done
