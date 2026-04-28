#!/bin/sh



filename="$(basename "$1")"

ffmpeg   -vaapi_device /dev/dri/renderD128 \
  -y -i "$1"  \
  -map 0:0 \
  -map 0:1 \
  -c:v h264_vaapi  -profile:v high    -rc_mode 4  -global_quality 18 -b:v 0  -vf format=nv12,hwupload    \
  -c:a aac -b:a 192k -ac 2 \
  "ICQ-$filename"



