
# Check the track numbers in the file
mkvmerge -i input.mkv

# Output with only certain tracks, example:
mkvmerge --audio-tracks 2,3 --subtitle-tracks 4 -o ./S03E11.mkv The.Grand.Tour.S03E11.2160p.AMZN.WEBRip.DDP5.1.x265.mkv

