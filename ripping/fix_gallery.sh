
# Examples of fixing a gallery ripped from a DVD

ffmpeg -i "05 Photo Gallery.mkv" -vf mpdecimate,setpts="N/FRAME_RATE/TB" -fps_mode passthrough photos/img%04d.tiff

ffmpeg -f image2 -framerate 1/5 -i photos/img%04d.tiff -c:v libx264 -pix_fmt yuv420p gallery.mkv
