#!/bin/bash

while true; do
  current_ws=$(hyprctl activeworkspace -j | jq '.id')
  clients=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == $current_ws)] | length")

  if [ "$clients" -eq 0 ]; then
    # No clients: kill waybar if running    
      if ! pgrep -x "waybar" > /dev/null; then

      waybar &
      fi
  else
    # Check if waybar is already running
          pkill -x waybar
  fi

  sleep 1  # check every second, adjust if needed
done

