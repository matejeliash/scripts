#!/bin/bash

print_info(){
    echo "Usage: $0 <input_file> | -h | --help"
    echo "Example: $0 movie.mp4"
    echo ""
    echo "This script is an interactive video/audio/subtitle extractor/remuxer using ffmpeg and ffprobe."
    echo "It allows the user to select which streams from a media file to include in a new output file."
    echo "Select video, audio, and subtitle streams interactively using fzf."
    exit 1

}

if [ $# != 1 ]; then
    echo "[Error]: there can be only one argument"
    echo ""

    print_info
fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    print_info
fi

if [ ! -f "$1" ] ; then
    echo "[Error]: file with this name doesn't exist"
    echo ""

    print_info
fi


stream_info="$(ffprobe "$1" 2>&1)"
streams="$(echo "$stream_info" | grep "Stream #")"



select_option() {
    type_options="$(echo "$streams" | grep "$1")"

    # no streams present
    if [ -z "$type_options" ] ;then
     printf ""
     exit
     fi

    # Run fzf in the foreground
    selected=$(echo -e "EXIT\nNONE\n${type_options}" | fzf --multi --prompt="Choose $2 streams: ")


    [ "$selected" = "EXIT" ] && printf "EXIT" && return

    if [ -z "$selected" ] || [ "$selected" = "NONE" ]; then
        printf ""
        return
    fi

    # Process selection
    selected=$(echo "$selected" | cut -d '#' -f 2 | sed 's/[([].*//')
    formatted_selected=$(echo "$selected" | sed 's/^/-map /' | tr "\n" " " | cut -d ":" -f -2 | sed 's/[ \t]*$//')
    echo "$formatted_selected"
}


# main


selected_videos="$(select_option ": Video:" "video")"
 [ "$selected_videos" = "EXIT" ] && exit 1
selected_audios="$(select_option ": Audio:" "audio")"
[ "$selected_audios" = "EXIT" ] && exit 1
selected_subs="$(select_option ": Subtitle:" "subs")"
[ "$selected_subs" = "EXIT" ] && exit 1

if [ -z "$selected_subs" ] && [ -z "$selected_audios" ]  && [ -z "$selected_videos" ]; then
echo "You selected nothing !!!"
exit 1
fi

# echo " ffmpeg -i $1 $selected_videos  $selected_audios  $selected_subs -c copy $FILENAME"
# exit 1
read -e -i "$1" -p "Enter value: " FILENAME



ffmpeg -i "$1" $selected_videos  $selected_audios  $selected_subs -c copy "$FILENAME"


exit 1
