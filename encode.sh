#!/bin/bash

echo "Loading configuration @ $1"
config_data=$(jq -r '.output_path, .input_path, .pixel_format, .bitrate, .input_width, .input_height, .output_width, .output_height, .codec' $1)

input_path=$(jq -r '.input_path' $1)
output_path=$(jq -r '.output_path' $1)
pixel_format=$(jq -r '.pixel_format' $1)
bitrate=$(jq -r '.bitrate' $1)
input_width=$(jq -r '.input_width' $1)
input_height=$(jq -r '.input_height' $1)
output_width=$(jq -r '.output_width' $1)
output_height=$(jq -r '.output_height' $1)
codec=$(jq -r '.codec' $1)

input_basename=$(basename $input_path)

IFS="." read name ext <<< $input_basename

output_path=$output_path/${name}_${bitrate}_${output_width}x${output_height}.${codec}

echo "Encoding YUV to $codec (${output_width}x${output_height}, ${bitrate}kbps) @ $output_path"

if [[ -z "$input_path" || -z "$pixel_format" || -z "$bitrate" || -z "$input_width" || -z "$input_height" || -z "$output_width" || -z "$output_height" ]]; then
  echo "Error: Missing required fields in JSON configuration."
  exit 1
fi

ffmpeg -pixel_format "$pixel_format" -video_size "${input_width}x${input_height}" -i "$input_path" \
       -f rawvideo -vcodec rawvideo \
       -c:v "$codec" -b:v $bitrate \
       -vf scale=${output_width}x${output_height} \
       -y "$output_path"
