#!/bin/bash
# ======================= VERSI FINAL BERSIH =======================
# Menangkap notifikasi, menyimpannya ke file, dan secara proaktif
# memberitahu EWW untuk memperbarui UI.

HISTORY_FILE="$HOME/.config/dunst/history.json"
MAX_HISTORY=50

# Bagian 1: Simpan notifikasi ke file
timestamp=$(date +%s)
new_notification=$(jq -n --arg ts "$timestamp" --arg appname "$1" --arg summary "$2" --arg body "$3" \
  '{timestamp: $ts | tonumber, appname: $appname, summary: $summary, body: $body}')

if [ ! -f "$HISTORY_FILE" ]; then
  echo "[]" >"$HISTORY_FILE"
fi

TMP_FILE="${HISTORY_FILE}.tmp"
jq --argjson new_notif "$new_notification" --arg max_h "$MAX_HISTORY" \
  '[ $new_notif ] + . | .[0:($max_h | tonumber)]' "$HISTORY_FILE" >"$TMP_FILE"

if [ $? -eq 0 ]; then
  mv "$TMP_FILE" "$HISTORY_FILE"
else
  rm -f "$TMP_FILE"
  exit 1
fi

# Bagian 2: Push update ke EWW
EWW_NOTIFICATIONS_SCRIPT="$HOME/.config/eww/scripts/notifications"

if [ -x "$EWW_NOTIFICATIONS_SCRIPT" ]; then
  formatted_json=$($EWW_NOTIFICATIONS_SCRIPT)
  # Ganti '/path/absolut/ke/eww' dengan hasil dari `which eww`
  $HOME/.local/bin/eww update "notifications=$formatted_json"
fi
