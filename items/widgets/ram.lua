local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "ram_update" for
-- the ram usage data, which is fired every 2.0 seconds.
sbar.exec("killall ram_load >/dev/null; $CONFIG_DIR/helpers/event_providers/ram_load/bin/ram_load ram_update 2.0")

local ram = sbar.add("graph", "widgets.ram" , 42, {
  position = "right",
  graph = { color = colors.nord.aurora.nord14 },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { string = icons.cpu }, -- Using same icon as CPU
  label = {
    string = "ram ??%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    align = "right",
    padding_right = 0,
    width = 0,
    y_offset = 4
  },
  padding_right = settings.paddings + 6
})

ram:subscribe("ram_update", function(env)
  local usage = tonumber(env.usage_percentage)
  ram:push({ usage / 100. })

  local color = colors.green
  if usage > 30 then
    if usage < 60 then
      color = colors.yellow
    elseif usage < 80 then
      color = colors.orange
    else
      color = colors.red
    end
  end

  ram:set({
    graph = { color = color },
    label = "ram " .. env.usage_percentage .. "%",
  })
end)

ram:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a 'Activity Monitor'")
end)

-- Background around the ram item
sbar.add("bracket", "widgets.ram.bracket", { ram.name }, {
  background = { color = colors.nord.polar_night.nord1 }
})

-- Background around the ram item
sbar.add("item", "widgets.ram.padding", {
  position = "right",
  width = settings.group_paddings
})