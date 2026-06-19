-- Hyprland Submap Indicator bar widget

local glyph = barWidget.getConfig("glyph")
local showGlyph = barWidget.getConfig("show_glyph")
local command = barWidget.getConfig("command")

local function apply(name)
  if name == nil or name == "" then
    barWidget.setText("")
    barWidget.setTooltip("")
    barWidget.setVisible(false)
    return
  end

  if showGlyph then
    barWidget.setGlyph(glyph)
  end
  barWidget.setText(name)
  barWidget.setTooltip(noctalia.tr("active") .. name)
  barWidget.setVisible(true)
end

-- Static otherwise: slow periodic tick down
function update()
  noctalia.setUpdateInterval(60000)
end

-- Start hidden until first event arrives
apply("")

if command ~= nil and command ~= "" then
  noctalia.runStream(command, function(line)
    local name = string.match(line, "^submap>>(.*)$")
    if name ~= nil then
      apply(name)
    end
  end)
end
