#!/usr/bin/env bash

set -euo pipefail

LIST_FILE="videolist.txt"

: > "$LIST_FILE"

for file in *.mkv; do
    [ -f "$file" ] || continue
    printf "file '%s'\n" "$file" >> "$LIST_FILE"
done

ffmpeg -f concat -safe 0 -i "$LIST_FILE" -c copy output.mp4

rm "$LIST_FILE"
