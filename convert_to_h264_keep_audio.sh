#!/bin/sh


convert_file(){

	filename="$(basename "$1")"

	ffmpeg   -vaapi_device /dev/dri/renderD128 \
	  -y -i "$1"  \
	  -map 0:0 \
	  -map 0:1 \
	  -c:v h264_vaapi  -profile:v high    -rc_mode 4  -global_quality 18 -b:v 0  -vf format=nv12,hwupload    \
	  -c:a copy \
	  "$filename--TV--.mkv"

}


case "$0" in *convert_to_h264_keep_audio.sh)
	
	echo "running main"
		for i in "$@" ; do 
			convert_file "$i"
		done
	

	;;

esac






