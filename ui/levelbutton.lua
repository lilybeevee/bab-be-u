local level_button = {}

function level_button.new(file, extra)
  local o = ui.component.new()

  o.data.type = "level"
  o.data.file = file

  o.rainbowoffset = 0

  o:setSprite(sprites["ui/level box"])
  o:setFont(ui.fonts.default)
  o:setPivot(0.5, 0.5)
  o:onPreDraw(ui.buttonFX)

  o.data.extra = extra
  local default_color
  if getTheme() == "halloween" then
    default_color = {0.5, 0.2, 0.7, 1}
    if extra then
        default_color = {0.8, 0.4, 0, 1}
    end
  else
    default_color = {0.25, 0.5, 1, 1}
    if extra then
        default_color = {0.125, 0.25, 0.5, 1}
    end
  end

  function o:getColor()
    if spookmode then
      return {0,0,0}
    end
    if rainbowmode then
      return self.data.extra and hslToRgb((love.timer.getTime()/3+self.rainbowoffset/20)%1, 0.25, 0.25, .9) or hslToRgb((love.timer.getTime()/3+self.rainbowoffset/20)%1, 0.4, 0.5, .9)
    end
    if not self.color then return default_color
    else return unpack(self.color) end
  end

  function o:getName() return self.name end
  function o:setName(val) self.name = val; return self end

  function o:drawIcon()
    local y_mult = 1/2
    if self:getName() then
      y_mult = 2/3
    end

    if self:getIcon() then
      local iconw, iconh = 96, 96
      local sx, sy = iconw / self:getIcon():getWidth(), iconh / self:getIcon():getHeight()
      if spookmode then
        love.graphics.setColor(math.random(1,3)/10,math.random(0,5)/100,math.random(0,5)/100)
      end
      love.graphics.draw(self:getIcon(), self:getWidth() / 2 - iconw / 2, self:getHeight() * y_mult - iconh / 2, 0, sx, sy)
    end
  end

  function o:postDraw()
    love.graphics.setColor(1, 1, 1, 1)

    if self:getName() then
      local font = self:getFont()
      love.graphics.setFont(font)

      local _,lines = font:getWrap(self:getName():upper(), self:getWidth() - 12)
      local height = #lines * font:getHeight()

      love.graphics.printf(spookmode and (math.random(1,100) == 1 and "stop it" or "help") or self:getName():upper(), 6, 40 - height / 2, self:getWidth() - 12, "center")
    end
  end

  return o
end

return level_button