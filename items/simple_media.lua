local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local media = sbar.add("item", "media.spotify", {
  position = "right",
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = {
    string = "♪",
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 14.0,
    },
    y_offset = 0,
  },
  label = {
    string = "No Music",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    align = "left",
    padding_left = 3,
    padding_right = 3,
    width = "dynamic",
    max_chars = 20,
    y_offset = 0
  },
  padding_left = 5,
  padding_right = settings.paddings + 6
})

-- Function to update media info
local function update_media_info()
  sbar.exec("/Users/macbook/.config/sketchybar/helpers/spotify_helper.sh get title", function(title)
    sbar.exec("/Users/macbook/.config/sketchybar/helpers/spotify_helper.sh get artist", function(artist)
      sbar.exec("/Users/macbook/.config/sketchybar/helpers/spotify_helper.sh get state", function(state)
        if state:match("playing") and title ~= "" then
          local display_text = title
          if artist ~= "" then
            display_text = title .. " - " .. artist
          end

          media:set({
            label = display_text,
            icon = { string = "▶" },
          })
        else
          media:set({
            label = "No Music",
            icon = { string = "♪" },
          })
        end
      end)
    end)
  end)
end

-- Auto-update every 2 seconds
media:subscribe("routine", update_media_info)
media:set({ script = "echo 'update'", update_freq = 2 })

-- Click to force immediate update
media:subscribe("mouse.clicked", function(env)
  update_media_info()
end)-- Background around the media item
sbar.add("bracket", "media.spotify.bracket", { media.name }, {
  background = { color = colors.bg1 }
})

-- Background around the media item
sbar.add("item", "media.spotify.padding", {
  position = "right",
  width = settings.group_paddings
})