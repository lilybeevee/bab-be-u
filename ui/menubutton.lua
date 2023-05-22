local menu_button = {}

function menu_button.new(text, id, func)
  local o = ui.component.new()

  o:setSprite(sprites[("ui/button_white_" .. id) or 1])
  if not spookmode then
    if getTheme() == "halloween" then
      o:setText(text)
      o:setColor(0.5, 0.25, 0.75)
      o:setHoverColor(0.4, 0, 0.75)
	elseif getTheme() == "baba" then
      o:setText(text)
      o:setColor(love.math.colorFromBytes(71, 89, 177))
      o:setHoverColor(love.math.colorFromBytes(85, 122, 224))
    elseif getTheme() == "christmas" then
      o:setText(text)
      o:setColor(0, 0.7, 0)
      o:setHoverColor(0.7, 0, 0)
    else
      local r,g,b = getPaletteColor(3,4,getTheme())
      o:setText(text)
      o:setColor(r,g,b)
      o:setHoverColor(r-.2,g-.2,b-.2)
    end
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
  local babspr
  if getTheme() == "halloween" then
    babspr = sprites["ghost"]
  elseif getTheme() == "christmas" then
    babspr = sprites["snoman"]
  else
    babspr = sprites["bab"]
  end
  if not spookmode then
    local bab = ui.component.new():setSprite(babspr):setX(-sprites["bab"]:getWidth()-2):setEnabled(false)
    o:addChild(bab)
    o:onHovered(function() bab:setEnabled(true) end)
    o:onExited(function() bab:setEnabled(false) end)
  end

  return o
end

return menu_button