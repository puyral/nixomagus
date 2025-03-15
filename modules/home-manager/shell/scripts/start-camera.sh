#!/usr/bin/env -S nix shell nixpkgs#bash  nixpkgs#gphoto2 nixpkgs#ffmpeg nixpkgs#v4l-utils --command bash

video="/dev/$(ls /sys/class/video4linux)"

gphoto2 --stdout --capture-movie \
  | ffmpeg \
      -hwaccel nvdec \
      -c:v mjpeg_cuvid \
      -i - \
      -vf "vflip" \
      -vcodec rawvideo \
      -pix_fmt yuv420p \
      -threads 0 \
      -f v4l2 $video