#!/bin/bash

# Kill any existing bars
killall -q polybar

# Wait for Polybar to actually close
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.2; done

# Launch
# polybar main &
for m in $(polybar --list-monitors | cut -d":" -f1); do
  MONITOR=$m polybar main &
done
