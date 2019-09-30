local menu_button = {}

function menu_button.new(text, id, func)
  local o = ui.component.new()

  o:setSprite(sprites["ui/button_white_" .. id or 1])
  if not spookmode then
    o:setText(text)
    o:setColor(0.25, 0.5, 1)
    o:setHoverColor(0.15, 0.4, 0.9)
  else
    o:setText(math.random(1,100) == 1 and "stop it" or "help")
    o:setTextColor(0, 0, 0)
    o:setColor(0.5, 0.5, 0.5)
    o:setHoverColor(0.4, 0.4, 0.4)
  end
  o:setFont(ui.fonts.default)
  o:setPivot(0.5, 0.5)
  o:onPreDraw(ui.buttonFX)
  o:onHovered(function() playSound("mous hovvr") end)
  if func then
    o:onReleased(func)
  end

  -- lazy copy/paste uwu
  local bab = ui.component.new():setSprite(sprites["bab"]):setX(-sprites["bab"]:getWidth()-2):setEnabled(false)
  o:addChild(bab)
  o:onHovered(function() bab:setEnabled(true) end)
  o:onExited(function() bab:setEnabled(false) end)

  return o
end

return menu_button