#!/bin/bash

# Improved music helper with timeout protection
get_music_info() {
    # Function to check process with timeout
    check_process() {
        local app_name="$1"
        timeout 2 osascript -e "tell application \"System Events\" to exists process \"$app_name\"" 2>/dev/null
    }

    # Function to get music info with timeout
    get_app_music() {
        local app_name="$1"
        timeout 3 osascript << EOF 2>/dev/null
tell application "$app_name"
    try
        if player state is playing then
            set track_name to name of current track
            set track_artist to artist of current track
            set track_album to album of current track
            set player_state to player state as string

            return "{\"title\":\"" & track_name & "\",\"artist\":\"" & track_artist & "\",\"album\":\"" & track_album & "\",\"state\":\"" & player_state & "\",\"app\":\"$app_name\"}"
        else
            return "not_playing"
        end if
    on error
        return "error"
    end try
end tell
EOF
    }

    # Try Apple Music first
    if pgrep -f "Music.app" >/dev/null 2>&1; then
        local music_info=$(get_app_music "Music")
        if [[ "$music_info" =~ ^\{.*\}$ ]]; then
            echo "$music_info"
            return
        fi
    fi

    # Try nowplaying-cli (faster than AppleScript)
    if command -v nowplaying-cli >/dev/null 2>&1; then
        local title=$(timeout 2 nowplaying-cli get title 2>/dev/null)
        local artist=$(timeout 2 nowplaying-cli get artist 2>/dev/null)
        local state=$(timeout 2 nowplaying-cli get playbackRate 2>/dev/null)

        if [[ "$title" != "null" && "$title" != "" && "$state" == "1" ]]; then
            echo "{\"title\":\"$title\",\"artist\":\"$artist\",\"album\":\"\",\"state\":\"playing\",\"app\":\"NowPlaying\"}"
            return
        fi
    fi

    # Finally try Spotify
    if pgrep -f "Spotify.app" >/dev/null 2>&1; then
        local spotify_info=$(get_app_music "Spotify")
        if [[ "$spotify_info" =~ ^\{.*\}$ ]]; then
            echo "$spotify_info"
            return
        fi
    fi

    # No music playing
    echo "{\"title\":\"\",\"artist\":\"\",\"album\":\"\",\"state\":\"stopped\",\"app\":\"\"}"
}

case "$1" in
    "get")
        case "$2" in
            "title"|"artist"|"album"|"state"|"app")
                info=$(get_music_info)
                echo "$info" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('$2', ''))" 2>/dev/null || echo ""
                ;;
            *)
                get_music_info
                ;;
        esac
        ;;
    "togglePlayPause"|"toggle")
        preferred="${2:-auto}"
        normalized=$(printf "%s" "$preferred" | tr '[:upper:]' '[:lower:]')
        target_app=""

        case "$normalized" in
            ""|"auto"|"active")
                target_app=""
                ;;
            "music"|"apple")
                target_app="Music"
                ;;
            "spotify")
                target_app="Spotify"
                ;;
            *)
                target_app="$preferred"
                ;;
        esac

        if [ -n "$target_app" ]; then
            timeout 3 osascript -e "tell application \"$target_app\" to playpause" 2>/dev/null
            exit 0
        fi

        # Determine which app is currently active and toggle that player
        info=$(get_music_info)
        active_app=$(printf "%s" "$info" | python3 -c 'import sys, json; data=json.load(sys.stdin); print(data.get("app", ""))' 2>/dev/null)

        if [ "$active_app" = "Music" ] || [ "$active_app" = "Spotify" ]; then
            timeout 3 osascript -e "tell application \"$active_app\" to playpause" 2>/dev/null
        else
            # Fallback to the previous order if we do not know the active player
            timeout 3 osascript -e '
            try
                tell application "Music" to playpause
            on error
                try
                    tell application "Spotify" to playpause
                end try
            end try' 2>/dev/null
        fi
        ;;
    "next")
        timeout 3 osascript -e '
        try
            tell application "Music" to next track
        on error
            try
                tell application "Spotify" to next track
            end try
        end try' 2>/dev/null
        ;;
    "previous"|"prev")
        timeout 3 osascript -e '
        try
            tell application "Music" to previous track
        on error
            try
                tell application "Spotify" to previous track
            end try
        end try' 2>/dev/null
        ;;
    *)
        echo "Usage: $0 {get|togglePlayPause|next|previous}"
        ;;
esac
