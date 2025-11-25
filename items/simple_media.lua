local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local helper_script = os.getenv("HOME") .. "/.config/sketchybar/helpers/music_helper_v2.sh"

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
  padding_right = settings.paddings + 6,
  popup = { align = "center" }
})

local selected_player = "auto"
local player_choices = {
  { id = "auto", label = "Active Player" },
  { id = "Music", label = "Apple Music" },
  { id = "Spotify", label = "Spotify" },
}

local player_option_items = {}

local function update_player_option_styles()
  for _, option in ipairs(player_choices) do
    local option_item = player_option_items[option.id]
    if option_item then
      local is_selected = option.id == selected_player
      option_item:set({
        icon = {
          string = is_selected and "●" or "○",
          align = "left",
          width = 16,
          color = colors.blue,
        },
        label = {
          string = option.label,
          align = "left",
          color = is_selected and colors.white or colors.grey,
        },
      })
    end
  end
end

local function select_player(option_id)
  selected_player = option_id
  update_player_option_styles()
end

for _, option in ipairs(player_choices) do
  local option_item = sbar.add("item", "media.player_option." .. option.id, {
    position = "popup." .. media.name,
    width = 160,
    align = "left",
    padding_left = 8,
  })
  player_option_items[option.id] = option_item

  option_item:subscribe("mouse.clicked", function()
    select_player(option.id)
    media:set({ popup = { drawing = false } })
  end)
end

select_player(selected_player)

-- Function to update media info
local function update_media_info()
  sbar.exec(helper_script .. " get title", function(title)
    sbar.exec(helper_script .. " get artist", function(artist)
      sbar.exec(helper_script .. " get state", function(state)
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

-- Click to force immediate update or toggle play/pause
media:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    local drawing = media:query().popup.drawing
    media:set({ popup = { drawing = (drawing == "on") and "off" or "on" } })
    update_player_option_styles()
    return
  end

  sbar.exec(helper_script .. " togglePlayPause " .. selected_player)
  update_media_info()
end)

media:subscribe("mouse.exited.global", function()
  media:set({ popup = { drawing = false } })
end)

-- Background around the media item
sbar.add("bracket", "media.universal.bracket", { media.name }, {
  background = { color = colors.nord.polar_night.nord1 }
})

-- Background around the media item
sbar.add("item", "media.universal.padding", {
  position = "right",
  width = settings.group_paddings
})
