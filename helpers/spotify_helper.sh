#!/bin/bash

# Get Spotify track info using AppleScript
get_spotify_info() {
    osascript << EOF
tell application "System Events"
    if exists process "Spotify" then
        tell application "Spotify"
            try
                set track_name to name of current track
                set track_artist to artist of current track
                set track_album to album of current track
                set player_state to player state as string

                return "{\"title\":\"" & track_name & "\",\"artist\":\"" & track_artist & "\",\"album\":\"" & track_album & "\",\"state\":\"" & player_state & "\",\"app\":\"Spotify\"}"
            on error
                return "{\"title\":\"\",\"artist\":\"\",\"album\":\"\",\"state\":\"stopped\",\"app\":\"\"}"
            end try
        end tell
    else
        return "{\"title\":\"\",\"artist\":\"\",\"album\":\"\",\"state\":\"stopped\",\"app\":\"\"}"
    end if
end tell
EOF
}

case "$1" in
    "get")
        case "$2" in
            "title"|"artist"|"album"|"state"|"app")
                info=$(get_spotify_info)
                echo "$info" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('$2', ''))"
                ;;
            *)
                get_spotify_info
                ;;
        esac
        ;;
    "togglePlayPause"|"toggle")
        osascript -e 'tell application "Spotify" to playpause'
        ;;
    "next")
        osascript -e 'tell application "Spotify" to next track'
        ;;
    "previous"|"prev")
        osascript -e 'tell application "Spotify" to previous track'
        ;;
    *)
        echo "Usage: $0 {get|togglePlayPause|next|previous}"
        ;;
esac