local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain
sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 12.0
    },
    color = colors.white,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
    background = { image = { corner_radius = 9 } },
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Semibold"],
      size = 11.0
    },
    color = colors.white,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  background = {
    height = 24,
    corner_radius = 10,
    border_width = 0,
    border_color = colors.transparent,
    color = colors.transparent,
    image = {
      corner_radius = 10,
      border_color = colors.transparent,
      border_width = 0
    }
  },
  popup = {
    background = {
      border_width = 0,
      corner_radius = 10,
      border_color = colors.transparent,
      color = colors.with_alpha(colors.nord.polar_night.nord1, 0.95),
      shadow = { drawing = true },
    },
    blur_radius = 50,
  },
  padding_left = 5,
  padding_right = 5,
  scroll_texts = true,
})
