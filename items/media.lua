local icons = require("icons")
local colors = require("colors")

-- Start Spotify event provider
sbar.exec("killall spotify_provider.sh >/dev/null 2>&1; $CONFIG_DIR/helpers/event_providers/spotify/spotify_provider.sh media_change 2 &")

local media_widget = sbar.add("item", "media.widget", {
  position = "right",
  icon = {
    string = "♪",
    color = colors.white,
  },
  label = {
    string = "No Music",
    color = colors.white,
    max_chars = 30,
  },
  background = {
    color = colors.bg1,
    border_width = 1,
    border_color = colors.grey,
    corner_radius = 6,
  },
  padding_left = 5,
  padding_right = 5,
})

media_widget:subscribe("media_change", function(env)
  -- Debug log
  sbar.exec("echo 'Media event triggered: " .. (env.INFO or "NO INFO") .. "' >> /tmp/sketchybar_debug.log")

  local info_str = env.INFO or "{}"

  -- Parse JSON string manually (simple parsing)
  local title = info_str:match('"title":"([^"]*)"') or ""
  local artist = info_str:match('"artist":"([^"]*)"') or ""
  local state = info_str:match('"state":"([^"]*)"') or "stopped"

  local is_playing = state == "playing"

  if is_playing and title ~= "" then
    local display_text = title
    if artist ~= "" then
      display_text = title .. " - " .. artist
    end

    media_widget:set({
      label = display_text,
      icon = { string = "▶" }, -- Playing icon
      background = { color = colors.green }
    })
  else
    media_widget:set({
      label = "No Music",
      icon = { string = "♪" },
      background = { color = colors.bg1 }
    })
  end
end)media_widget:subscribe("mouse.clicked", function(env)
  sbar.exec("$CONFIG_DIR/helpers/spotify_helper.sh togglePlayPause")
end)