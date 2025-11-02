#!/bin/sh

# scrip encodes video so it can be played on older TVs.
# if video is compatible video is not changed.

print_separator(){
    for i in $(seq 40) ; do
        printf "-"
    done

    printf "\n"
}

rename(){
	name="$(echo "$1" | sed -e 's/%2./-/g')"
	echo "$name"
}

input_file="$1"
name="$(basename "$1")"
name="$(rename "$name")"
qp="23"

ffmpeg_video="" # part for video convesion
ffmpeg_hwaccel="" # for vaapi config
ffmpeg_audio="" # part for audio conversin


# keep video or tell use h264_vaapi

# format -> stream_id,video_codec,pixel_format
# pixel_format yuv420p == 8 but
video_data="$(ffprobe -v error -select_streams v \
-show_entries stream=index,codec_name,pix_fmt -of csv=p=0 \
"$input_file")"

video_stream_id="$(echo "$video_data" | cut -d ',' -f 1 )"

echo "video data: $video_data"
if [ "$video_data" = "${video_stream_id},h264,yuv420p" ] ; then
    echo "Video is compatible."
    ffmpeg_video=" -map 0:$video_stream_id -c:v copy "
else
    echo "Video has to be converted."

    ffmpeg_video=" -map 0:$video_stream_id -c:v h264_vaapi  -profile:v main -preset quality -qp $qp  -vf format=nv12,hwupload "
    ffmpeg_hwaccel=" -hwaccel vaapi -vaapi_device /dev/dri/renderD128   "
fi

print_separator


audio_data="$(ffprobe -v error -select_streams a \
-show_entries stream=index,codec_name:stream_tags=language -of csv=p=0 \
"$input_file")"
echo "audio data: $audio_data"
selected_audio_id=""

if [ "$(echo "$audio_data" |  wc -l)" -gt 1 ]  ; then
    selected="$(echo "$audio_data" | fzf --prompt="select audio")"
    selected_audio_id="$(echo "$selected" | cut -d ',' -f 1)"

else
    selected_audio_id="$(echo "$audio_data" | cut -d ',' -f 1)"
    fi

audio_codec="$(echo "$audio_data" | cut -d ',' -f 2)"
if  echo "$audio_codec" | grep -Eq "^(aac|mp3|dts|dca|ac3)$" ; then
    echo "Audio is compatible."
    ffmpeg_audio=" -map 0:$selected_audio_id   -c:a copy "

else
    ffmpeg_audio=" -map 0:$selected_audio_id -c:a aac -b:a 160k -ac 2 "
    echo "Audio has to be converted."

fi

print_separator

if echo "$ffmpeg_audio" | grep -q "copy" ; then
    if echo "$ffmpeg_video" | grep -q "copy" ; then
        echo "Video can be played on TV."
        exit 0
    fi
fi

echo "This command will be run: "
echo "ffmpeg $ffmpeg_hwaccel -i $1  $ffmpeg_video   $ffmpeg_audio  -map 0:s?  TV-$name"
echo "Run this command [y/n]:"
read answer

if [ "$answer" = "y" ]; then
   ffmpeg $ffmpeg_hwaccel -i "$1"  $ffmpeg_video   $ffmpeg_audio  -map 0:s? -c:s copy "TV-$name"
fi
