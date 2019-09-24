local component = {}

-- Basic component, used as a base for others
function component.new(t)
  local o = t or {}

  o.data = {}
  o.children = {}
  o.mouse = {x = -1, y = -1, left = "up", right = "up"}
  o.frame = 0

  -- Basic Functions

  function o:getX() return self.x or 0 end
  function o:getY() return self.y or 0 end

  function o:setX(val) self.x = val; return self end
  function o:setY(val) self.y = val; return self end

  function o:getPos() return self:getX(), self:getY() end
  function o:setPos(x, y)
    self:setX(x)
    self:setY(y)
    return self
  end

  function o:getWidth()
    if not self.w then
      if self:getSprite() then return self:getSprite():getWidth()
      else return 0 end
    else return self.w end
  end
  function o:getHeight()
    if not self.h then
      if self:getSprite() then return self:getSprite():getHeight()
      else return 0 end
    else return self.h end
  end

  function o:setWidth(val) self.w = val; return self end
  function o:setHeight(val) self.h = val; return self end

  function o:getSize() return self:getWidth(), self:getHeight() end
  function o:setSize(w, h)
    self:setWidth(w)
    self:setHeight(h or w)
    return self
  end

  -- Container Functions

  function o:addChild(child)
    if not table.has_value(self.children, child) then
      table.insert(self.children, child)
    end
  end

  function o:removeChild(child)
    for i,v in ipairs(self.children) do
      if v == child then
        table.remove(self.children, i)
        break
      end
    end
  end

  -- Transformation Functions

  function o:getScaleX() return self.sx or 1 end
  function o:getScaleY() return self.sy or 1 end
  
  function o:setScaleX(val) self.sx = val; return self end
  function o:setScaleY(val) self.sy = val; return self end

  function o:getScale() return self:getScaleX(), self:getScaleY() end
  function o:setScale(x, y)
    self:setScaleX(x)
    self:setScaleY(y or x)
    return self
  end

  function o:getRotation() return self.rotation or 0 end
  function o:setRotation(val) self.rotation = val; return self end

  function o:getCentered() return self.centered or false end
  function o:setCentered(val) self.centered = val; return self end

  -- Sprite Functions

  function o:getSprite() return self.sprite end
  function o:setSprite(val) self.sprite = val; return self end

  function o:getHoverSprite() return self.hover_sprite or self:getSprite() end
  function o:setHoverSprite(val) self.hover_sprite = val; return self end

  function o:getActiveSprite() return self.active_sprite or self:getHoverSprite() end
  function o:setActiveSprite(val) self.active_sprite = val; return self end

  function o:getIcon() return self.icon end
  function o:setIcon(val) self.icon = val; return self end

  -- Text Functions

  function o:getText() return self.text or "" end
  function o:setText(val) self.text = val; return self end

  function o:getFont() return self.font or ui.fonts.default end
  function o:setFont(val) self.font = val; return self end

  function o:getAlign() return self.align or "center" end
  function o:setAlign(val) self.align = val; return self end

  function o:getWrap() return self.wrap or false end
  function o:setWrap(val) self.wrap = val; return self end

  -- Color Functions

  function o:getFill() return self.fill or false end
  function o:setFill(val) self.fill = val; return self end

  function o:getColor()
    if not self.color then return {1, 1, 1, 1}
    else return unpack(self.color) end
  end
  function o:setColor(r, g, b, a) 
    if not r then self.color = nil
    else self.color = {r, g, b, a or 1} end
    return self
  end

  function o:getHoverColor()
    if not self.hover_color then return self:getColor()
    else return unpack(self.hover_color) end
  end
  function o:setHoverColor(r, g, b, a) 
    if not r then self.hover_color = nil
    else self.hover_color = {r, g, b, a or 1} end
    return self
  end

  function o:getActiveColor()
    if not self.active_color then return self:getHoverColor()
    else return unpack(self.active_color) end
  end
  function o:setActiveColor(r, g, b, a) 
    if not r then self.active_color = nil
    else self.active_color = {r, g, b, a or 1} end
    return self
  end

  function o:getTextColor()
    if not self.text_color then return {1, 1, 1, 1}
    else return unpack(self.text_color) end
  end
  function o:setTextColor(r, g, b, a) 
    if not r then self.text_color = nil
    else self.text_color = {r, g, b, a or 1} end
    return self
  end

  function o:getTextHoverColor()
    if not self.text_hover_color then return self:getTextColor()
    else return unpack(self.text_hover_color) end
  end
  function o:setTextHoverColor(r, g, b, a) 
    if not r then self.text_hover_color = nil
    else self.text_hover_color = {r, g, b, a or 1} end
    return self
  end

  function o:getTextActiveColor()
    if not self.text_active_color then return self:getTextHoverColor()
    else return unpack(self.text_active_color) end
  end
  function o:setTextActiveColor(r, g, b, a) 
    if not r then self.text_active_color = nil
    else self.text_active_color = {r, g, b, a or 1} end
    return self
  end

  -- Mouse Functions

  function o:getFocus()
    if self.focus == nil then return true
    else return self.focus end
  end
  function o:setFocus(val) self.focus = val; return self end

  function o:hovered()
    if ui.hovered and ui.hovered ~= self then
      if not self.parent or (self.parent and not self.parent:hovered()) then
        return false
      end
    end
    return self.mouse.x >= 0 and
          self.mouse.y >= 0 and
          self.mouse.x < self:getWidth() and 
          self.mouse.y < self:getHeight()
  end

  function o:pressed(button)
    if button == 2 then return self.mouse.right == "pressed" end
    if button == 1 then return self.mouse.left == "pressed" end
    return (self.mouse.left == "pressed" and self.mouse.right ~= "down") or
           (self.mouse.right == "pressed" and self.mouse.left ~= "down")
  end

  function o:down(button)
    if button == 2 then return self.mouse.right == "down" end
    if button == 1 then return self.mouse.left == "down" end
    return self.mouse.left == "down" or self.mouse.right == "down"
  end

  function o:released(button)
    if button == 2 then return self.mouse.right == "released" end
    if button == 1 then return self.mouse.left == "released" end
    return (self.mouse.left == "released" and self.mouse.right ~= "pressed" and self.mouse.right ~= "down") or
           (self.mouse.right == "released" and self.mouse.left ~= "pressed" and self.mouse.left ~= "down")
  end

  function o:up(button)
    if button == 2 then return self.mouse.right == "up" end
    if button == 1 then return self.mouse.left == "up" end
    return (self.mouse.left == "up" and self.mouse.right ~= "pressed" and self.mouse.right ~= "down") or
           (self.mouse.right == "up" and self.mouse.left ~= "pressed" and self.mouse.left ~= "down")
  end

  function o:onHovered(func) self.on_hovered = func; return self end
  function o:onExited(func) self.on_exited = func; return self end
  function o:onPressed(func) self.on_pressed = func; return self end
  function o:onReleased(func) self.on_released = func; return self end

  function o:draw(parent)
    self.frame = frame
    self.parent = parent

    love.graphics.push()
    if self.preDraw then
      self:preDraw()
    end
    self:transform()
    self:updateMouse()
    
    self:useColor()
    self:drawRect()
    self:drawSprite()

    love.graphics.setColor(1, 1, 1)
    if spookmode then
      love.graphics.setColor(0.2,0.2,0.2)
    end
    self:drawIcon()

    self:useTextColor()
    self:drawText()

    if self.postDraw then
      self:postDraw()
    end

    for i,child in ipairs(self.children) do
      child:draw(self)
    end

    love.graphics.pop()
  end

  -- Internal Functions

  function o:useColor()
    if self:pressed() or self:down() then
      love.graphics.setColor(self:getActiveColor())
    elseif self:hovered() then
      love.graphics.setColor(self:getHoverColor())
    else 
      love.graphics.setColor(self:getColor())
    end
  end

  function o:useTextColor()
    if self:pressed() or self:down() then
      love.graphics.setColor(self:getTextActiveColor())
    elseif self:hovered() then
      love.graphics.setColor(self:getTextHoverColor())
    else 
      love.graphics.setColor(self:getTextColor())
    end
  end

  function o:drawRect()
    if self:getFill() then
      love.graphics.rectangle("fill", 0, 0, self:getWidth(), self:getHeight())
    end
  end

  function o:drawSprite()
    local sprite = nil
    if self:pressed() or self:down() then
      sprite = self:getActiveSprite()
    elseif self:hovered() then
      sprite = self:getHoverSprite()
    else 
      sprite = self:getSprite()
    end

    if sprite then
      local sx, sy = self:getWidth() / sprite:getWidth(), self:getHeight() / sprite:getHeight()
      love.graphics.draw(sprite, 0, 0, 0, sx, sy)
    end
  end

  function o:drawIcon()
    if self:getIcon() then
      local x, y = self:getWidth() / 2 - self:getIcon():getWidth() / 2, self:getHeight() / 2 - self:getIcon():getHeight() / 2
      love.graphics.draw(self:getIcon(), x, y)
    end
  end

  function o:drawText()
    if self:getText() ~= "" then
      local font = self:getFont()
      love.graphics.setFont(font)

      local height
      if self:getWrap() then
        local _,lines = font:getWrap(self:getText(), self:getWidth())
        height = #lines * font:getHeight()
      else
        height = font:getHeight()
      end

      love.graphics.printf(self:getText(), 0, self:getHeight() / 2 - height / 2, self:getWidth(), self:getAlign())
    end
  end

  function o:transform()
    love.graphics.translate(self:getPos())
    love.graphics.translate(self:getWidth() / 2, self:getHeight() / 2)
    love.graphics.scale(self:getScale())
    love.graphics.rotate(self:getRotation())
    love.graphics.translate(-self:getWidth() / 2, -self:getHeight() / 2)
    if self:getCentered() then
      love.graphics.translate(-self:getWidth() / 2, -self:getHeight() / 2)
    end
  end

  function o:updateMouse(transform)
    if transform then
      self.mouse.x, self.mouse.y = transform:transformPoint(love.mouse.getPosition())
    else
      self.mouse.x, self.mouse.y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
    end
    if self.mouse.left ~= "up" then self.mouse.left = ui.mouse.left end
    if self.mouse.right ~= "up" then self.mouse.right = ui.mouse.right end
    if self:hovered() then
      if self:getFocus() then ui.hovered = self end
      if not self.last_hovered then
        self.last_hovered = true
        if self.on_hovered then self.on_hovered(self) end
      end
      if ui.mouse.left == "pressed" then self.mouse.left = "pressed" end
      if ui.mouse.right == "pressed" then self.mouse.right = "pressed" end
    else
      if ui.hovered == self then ui.hovered = nil end
      if self.last_hovered then
        self.last_hovered = false
        if self.on_exited then self.on_exited(self) end
      end
      if self.mouse.left == "released" then self.mouse.left = "up" end
      if self.mouse.right == "released" then self.mouse.right = "up" end
    end
    if self.on_pressed then
      if self.mouse.left == "pressed" then self.on_pressed(self, 1) end
      if self.mouse.right == "pressed" then self.on_pressed(self, 2) end
    end
    if self.on_released then
      if self.mouse.left == "released" then self.on_released(self, 1) end
      if self.mouse.right == "released" then self.on_released(self, 2) end
    end
  end

  return o
end

return component