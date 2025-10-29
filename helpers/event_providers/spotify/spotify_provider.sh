#!/bin/bash

CONFIG_DIR="$HOME/.config/sketchybar"
SPOTIFY_HELPER="$CONFIG_DIR/helpers/spotify_helper.sh"

if [ $# -lt 2 ]; then
    echo "Usage: $0 <event-name> <update-frequency>"
    exit 1
fi

EVENT_NAME="$1"
UPDATE_FREQ="$2"

# Add the event to sketchybar
sketchybar --add event "$EVENT_NAME"

while true; do
    # Get Spotify info
    TITLE=$("$SPOTIFY_HELPER" get title)
    ARTIST=$("$SPOTIFY_HELPER" get artist)
    ALBUM=$("$SPOTIFY_HELPER" get album)
    STATE=$("$SPOTIFY_HELPER" get state)
    APP=$("$SPOTIFY_HELPER" get app)

    # Create JSON-like info string
    INFO="{\"title\":\"$TITLE\",\"artist\":\"$ARTIST\",\"album\":\"$ALBUM\",\"state\":\"$STATE\",\"app\":\"$APP\"}"

    # Trigger the event
    sketchybar --trigger "$EVENT_NAME" INFO="$INFO"

    sleep "$UPDATE_FREQ"
done