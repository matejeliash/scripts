#!/bin/sh

# scrip encodes video so it can be played on older TVs.
# if video is compatible video is not changed.



ffmpeg_hwaccel="" # for vaapi config
cpu_info="$(cat /proc/cpuinfo)"
video_stream_id=""

mb_bitrate=4
mb_maxrate=$(( mb_bitrate*2 ))
mb_bufsize=$(( mb_bitrate*2 ))

qp="20"
input_file="$1"

ffmpeg_video="" # part for video convesion
ffmpeg_audio="" # part for audio conversin

print_separator(){
    for i in $(seq 40) ; do
        printf "-"
    done

    printf "\n"
}

set_hwaccel(){
    if  echo "$cpu_info" | grep -q "Intel" ; then
        ffmpeg_hwaccel=" -hwaccel vaapi -vaapi_device /dev/dri/renderD128   "
    fi

}

set_video_encoder(){
    if  echo "$cpu_info" | grep -q "Intel" ; then
        ffmpeg_video=" -map 0:$video_stream_id -c:v h264_vaapi  -profile:v main -preset quality -qp $qp  -vf format=nv12,hwupload "
    elif echo "$cpu_info" |  grep -q "Raspberry" ;then
        ffmpeg_video="  -map 0:$video_stream_id  -c:v h264_v4l2m2m -b:v ${mb_bitrate}M -maxrate ${mb_maxrate}M -bufsize ${mb_bufsize}M  -pix_fmt yuv420p "
    else

        ffmpeg_video=" -map 0:$video_stream_id -c:v libx264 -b:v ${mb_bitrate}M -maxrate ${mb_maxrate}M -bufsize ${mb_bufsize}M -pix_fmt yuv420p "

    fi


}


rename(){
    name="$(basename "$1")"
	name="$(echo "$name" | sed -e 's/%2./-/g')"
    newname=$(echo "$name" | sed 's/\.[^.]*$/.mkv/')
	echo "TV-$newname"
}



# keep video or tell use h264_vaapi

# format -> stream_id,video_codec,pixel_format
# pixel_format yuv420p == 8 but

setup_video_encoding(){

    video_data="$(ffprobe -v error -select_streams v \
    -show_entries stream=index,codec_name,pix_fmt -of csv=p=0 \
    "$input_file")"

    video_stream_id="$(echo "$video_data" | cut -d ',' -f 1  | head -n 1)"
    echo "$video_stream_id"

    echo "video data: $video_data"
    if [ "$video_data" = "${video_stream_id},h264,yuv420p" ] ; then
        echo "Video is compatible."
        ffmpeg_video=" -map 0:$video_stream_id -c:v copy "
    else
        echo "Video has to be converted."

        set_video_encoder

    fi
}

setup_audio_encoding(){

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
        ffmpeg_audio=" -map 0:$selected_audio_id -c:a aac -b:a 200k -ac 2 "
        echo "Audio has to be converted."

    fi
}


### main


name=$(rename "$1")

if [ -f "$name" ] ; then
    echo "File is already present."
    exit 0

fi


set_hwaccel
setup_audio_encoding
print_separator
setup_video_encoding
print_separator

# nothing to convert
if echo "$ffmpeg_audio" | grep -q "copy" ; then
    if echo "$ffmpeg_video" | grep -q "copy" ; then
        echo "Video can be played on TV."
        exit 0
    fi
fi





 echo "This command will be run: "
 echo "ffmpeg $ffmpeg_hwaccel -y -i $1  $ffmpeg_video   $ffmpeg_audio  -map 0:s? -c:s copy $name"
 echo "Run this command [y/n]:"
 read answer



# if [ "$answer" = "y" ]; then
   ffmpeg $ffmpeg_hwaccel -y -i "$1"  $ffmpeg_video   $ffmpeg_audio -sn "$name"
# fi
