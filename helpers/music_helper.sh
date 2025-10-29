#!/bin/bash

# Universal music helper for Apple Music, Spotify, and other apps
get_music_info() {
    # Try Apple Music first
    if osascript -e 'tell application "System Events" to exists process "Music"' 2>/dev/null | grep -q "true"; then
        local music_info=$(osascript << 'EOF'
tell application "Music"
    try
        if player state is playing then
            set track_name to name of current track
            set track_artist to artist of current track
            set track_album to album of current track
            set player_state to player state as string

            return "{\"title\":\"" & track_name & "\",\"artist\":\"" & track_artist & "\",\"album\":\"" & track_album & "\",\"state\":\"" & player_state & "\",\"app\":\"Music\"}"
        else
            return "not_playing"
        end if
    on error
        return "error"
    end try
end tell
EOF
)
        if [[ "$music_info" != "error" && "$music_info" != "not_playing" && "$music_info" != "" ]]; then
            echo "$music_info"
            return
        fi
    fi    # Try nowplaying-cli (fallback for other apps)
    if command -v nowplaying-cli >/dev/null 2>&1; then
        local title=$(nowplaying-cli get title 2>/dev/null)
        local artist=$(nowplaying-cli get artist 2>/dev/null)
        local state=$(nowplaying-cli get playbackRate 2>/dev/null)

        if [[ "$title" != "null" && "$title" != "" ]]; then
            local playback_state="stopped"
            if [[ "$state" == "1" ]]; then
                playback_state="playing"
            fi
            echo "{\"title\":\"$title\",\"artist\":\"$artist\",\"album\":\"\",\"state\":\"$playback_state\",\"app\":\"NowPlaying\"}"
            return
        fi
    fi

    # Finally try Spotify
    if osascript -e 'tell application "System Events" to exists process "Spotify"' 2>/dev/null | grep -q "true"; then
        local spotify_info=$(osascript << 'EOF'
tell application "Spotify"
    try
        if player state is playing then
            set track_name to name of current track
            set track_artist to artist of current track
            set track_album to album of current track
            set player_state to player state as string

            return "{\"title\":\"" & track_name & "\",\"artist\":\"" & track_artist & "\",\"album\":\"" & track_album & "\",\"state\":\"" & player_state & "\",\"app\":\"Spotify\"}"
        else
            return "not_playing"
        end if
    on error
        return "error"
    end try
end tell
EOF
)
        if [[ "$spotify_info" != "error" && "$spotify_info" != "not_playing" && "$spotify_info" != "" ]]; then
            echo "$spotify_info"
            return
        fi
    fi    # No music playing
    echo "{\"title\":\"\",\"artist\":\"\",\"album\":\"\",\"state\":\"stopped\",\"app\":\"\"}"
}

case "$1" in
    "get")
        case "$2" in
            "title"|"artist"|"album"|"state"|"app")
                info=$(get_music_info)
                echo "$info" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('$2', ''))"
                ;;
            *)
                get_music_info
                ;;
        esac
        ;;
    "togglePlayPause"|"toggle")
        # Try Apple Music first, then Spotify
        osascript -e '
        tell application "System Events"
            if exists process "Music" then
                tell application "Music" to playpause
            else if exists process "Spotify" then
                tell application "Spotify" to playpause
            end if
        end tell'
        ;;
    "next")
        osascript -e '
        tell application "System Events"
            if exists process "Music" then
                tell application "Music" to next track
            else if exists process "Spotify" then
                tell application "Spotify" to next track
            end if
        end tell'
        ;;
    "previous"|"prev")
        osascript -e '
        tell application "System Events"
            if exists process "Music" then
                tell application "Music" to previous track
            else if exists process "Spotify" then
                tell application "Spotify" to previous track
            end if
        end tell'
        ;;
    *)
        echo "Usage: $0 {get|togglePlayPause|next|previous}"
        ;;
esac