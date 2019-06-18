local level_button = {}

function level_button.new(file, extra)
  local o = ui.component.new()

  o.data.type = "level"
  o.data.file = file

  o:setSprite(sprites["ui/level box"])
  o:setFont(ui.fonts.default)

  o.data.extra = extra
  local default_color = {0.25, 0.5, 1, 1}
  if extra then
    default_color = {0.125, 0.25, 0.5, 1}
  end

  function o:getColor()
    if not self.color then return default_color
    else return unpack(self.color) end
  end

  function o:getName() return self.name end
  function o:setName(val) self.name = val; return self end

  function o:getIcon() return self.icon end
  function o:setIcon(val) self.icon = val; return self end

  function o:preDraw()
    if self:hovered() then
      if self:pressed() or self:down() then
        self:setScale(0.9)
      else
        self:setScale(1.1)
      end
      self:setRotation(0.05 * math.sin(love.timer.getTime()*5))
    else
      self:setScale(1)
      self:setRotation(0)
    end
  end

  function o:postDraw()
    local icon_y_mult = 1/2

    love.graphics.setColor(1, 1, 1, 1)

    if self:getName() then
      icon_y_mult = 2/3

      local font = self:getFont()
      love.graphics.setFont(font)

      local _,lines = font:getWrap(self:getName():upper(), self:getWidth() - 12)
      local height = #lines * font:getHeight()

      love.graphics.printf(self:getName():upper(), 6, 40 - height / 2, self:getWidth() - 12, "center")
    end

    if self:getIcon() then
      local iconw, iconh = 96, 96
      local sx, sy = iconw / self:getIcon():getWidth(), iconh / self:getIcon():getHeight()
      love.graphics.draw(self:getIcon(), self:getWidth() / 2 - iconw / 2, self:getHeight() * icon_y_mult - iconh / 2, 0, sx, sy)
    end
  end

  return o
end

return level_button