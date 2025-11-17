return {
  black = 0xff181819,
  white = 0xffe2e2e3,
  red = 0xfffc5d7c,
  green = 0xff9ed072,
  blue = 0xff76cce0,
  yellow = 0xffe7c664,
  orange = 0xfff39660,
  magenta = 0xffb39df3,
  grey = 0xff7f8490,
  transparent = 0x00000000,

  -- Nord theme colors
  nord = {
    polar_night = {
      nord0 = 0xff2e3440,
      nord1 = 0xff3b4252,
      nord2 = 0xff434c5e,
      nord3 = 0xff4c566a,
    },
    snow_storm = {
      nord4 = 0xffd8dee9,
      nord5 = 0xffe5e9f0,
      nord6 = 0xffeceff4,
    },
    frost = {
      nord7 = 0xff8fbcbb,  -- Cyan
      nord8 = 0xff88c0d0,  -- Bright cyan
      nord9 = 0xff81a1c1,  -- Blue
      nord10 = 0xff5e81ac, -- Dark blue
    },
    aurora = {
      nord11 = 0xffbf616a, -- Red
      nord12 = 0xffd08770, -- Orange
      nord13 = 0xffebcb8b, -- Yellow
      nord14 = 0xffa3be8c, -- Green
      nord15 = 0xffb48ead, -- Purple
    }
  },

  bar = {
    bg = 0xf02c2e34,
    border = 0xff2c2e34,
  },
  popup = {
    bg = 0xc02c2e34,
    border = 0xff7f8490
  },
  bg1 = 0xff363944,
  bg2 = 0xff414550,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
