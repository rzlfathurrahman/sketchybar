local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
  height = 32,
  color = colors.with_alpha(colors.nord.polar_night.nord0, 0.90),
  corner_radius = 0,
  padding_right = 2,
  padding_left = 2,
  blur_radius = 30,
})
