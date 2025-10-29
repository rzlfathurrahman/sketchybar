local icons = require("icons")
local colors = require("colors")

-- Simple test media widget that's always visible
local test_media = sbar.add("item", "test.media", {
  position = "right",
  icon = {
    string = "♪",
    color = colors.white,
  },
  label = {
    string = "Testing Media",
    color = colors.white,
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

-- Add a simple click handler
test_media:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a 'Spotify'")
end)