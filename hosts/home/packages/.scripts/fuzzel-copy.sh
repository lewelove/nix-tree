#!/usr/bin/env bash

OPTIONS=(
  "Unix Epoch"
  "YYYYMMDD"
)

selection=$(printf "%s\n" "${OPTIONS[@]}" | fuzzel --dmenu --prompt="Copy: " --width 20)

[[ -z "$selection" ]] && exit 0

case "$selection" in
    "YYYYMMDD")
        echo -n "$(date +'%Y%m%d')" | wl-copy
        ;;
    "Unix Epoch")
        echo -n "$(date +%s)" | wl-copy
        ;;
esac
