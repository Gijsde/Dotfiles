#!/bin/bash

echo "file loaded"
chosen=$(echo -e "⏻ Shutdown\n Restart\n Sleep" | wofi --dmenu --width 200 --height 220 --prompt "Power Menu")

case "$chosen" in
  *Shutdown) systemctl poweroff ;;
  *Restart) systemctl reboot ;;
  *Sleep) systemctl suspend ;;
esac
