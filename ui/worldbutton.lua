local world_button = {}

function world_button.new(file)
  local o = ui.component.new()

  o.data.type = "world"
  o.data.file = file

  o:setSprite(sprites["ui/world box"])
  o:setFont(ui.fonts.world_name)
  o:setPivot(0.5, 0.5)
  o:onPreDraw(ui.buttonFX)

  function o:getColor()
    if spookmode then
      return {0,0,0}
    end
    if rainbowmode then
      return hslToRgb(love.timer.getTime()/3%1, 0.4, 0.5, .9)
    end
    if not self.color then
        if getTheme() == "halloween" then
            return {0.5, 0.2, 0.7, 1}
        else
            return {0.25, 0.5, 1, 1}
        end
    else return unpack(self.color) end
  end

  function o:getName() return self.name end
  function o:setName(val) self.name = val; return self end

  function o:postDraw()
    love.graphics.setColor(1, 1, 1, 1)

    if self:getName() and not self:getIcon() then
      local font = self:getFont()
      love.graphics.setFont(font)

      local _,lines = font:getWrap(self:getName():upper(), self:getWidth() - 24)
      local height = #lines * font:getHeight()

      love.graphics.printf(spookmode and (math.random(1,100) == 1 and "stop it" or "help") or self:getName():upper(), 12, self:getHeight() / 2 - height / 2, self:getWidth() - 24, "center")
    end
  end

  return o
end

return world_button