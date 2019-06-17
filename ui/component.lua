local component = {}

-- Basic component, used as a base for others
function component.new(t)
  local o = t or {}

  o.data = {}
  o.children = {}
  o.color = o.color or {1, 1, 1, 1}
  o.mouse = {x = -1, y = -1, left = "up", right = "up"}

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

  -- Text Functions

  function o:getText() return self.text or "" end
  function o:setText(val) self.text = val; return self end

  function o:getFont() return self.font end
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
  function o:setColor(r, g, b, a) self.color = {r, g, b, a or 1}; return self end

  function o:getHoverColor()
    if not self.hover_color then return self:getColor()
    else return unpack(self.hover_color) end
  end
  function o:setHoverColor(r, g, b, a) self.hover_color = {r, g, b, a or 1}; return self end

  function o:getActiveColor()
    if not self.active_color then return self:getHoverColor()
    else return unpack(self.active_color) end
  end
  function o:setActiveColor(r, g, b, a) self.active_color = {r, g, b, a or 1}; return self end

  function o:hovered()
    return self.mouse.x >= 0 and
           self.mouse.y >= 0 and
           self.mouse.x < self:getWidth() and 
           self.mouse.y < self:getHeight()
  end

  function o:pressed(button)
    if button == 2 then return self.mouse.right == "pressed"
    else return self.mouse.left == "pressed" end
  end

  function o:down(button)
    if button == 2 then return self.mouse.right == "down"
    else return self.mouse.left == "down" end
  end

  function o:released(button)
    if button == 2 then return self.mouse.right == "released"
    else return self.mouse.left == "released" end
  end

  function o:up(button)
    if button == 2 then return self.mouse.right == "up"
    else return self.mouse.left == "up" end
  end

  function o:onPressed(func) self.on_pressed = func; return self end
  function o:onReleased(func) self.on_released = func; return self end

  function o:draw()
    love.graphics.push()
    self:preTransform()
    self:updateMouse()
    self:postTransform()

    local sprite = nil
    if self:pressed() or self:down() then
      sprite = self:getActiveSprite()
      love.graphics.setColor(self:getActiveColor())
    elseif self:hovered() then
      sprite = self:getHoverSprite()
      love.graphics.setColor(self:getHoverColor())
    else 
      sprite = self:getSprite()
      love.graphics.setColor(self:getColor())
    end

    if self:getFill() then
      love.graphics.rectangle("fill", 0, 0, self:getWidth(), self:getHeight())
    end

    if sprite then
      local sx, sy = self:getWidth() / sprite:getWidth(), self:getHeight() / sprite:getHeight()
      love.graphics.draw(sprite, 0, 0, 0, sx, sy)
    end

    if self:getText() ~= "" then
      local font = self:getFont() or love.graphics.getFont()
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

    for i,child in ipairs(self.children) do
      child:draw()
    end

    love.graphics.pop()
  end

  -- Internal Functions

  function o:preTransform()
    love.graphics.translate(self:getPos())
  end

  function o:postTransform()
    love.graphics.translate(self:getWidth() / 2, self:getHeight() / 2)
    love.graphics.scale(self:getScale())
    love.graphics.rotate(self:getRotation())
    if not self:getCentered() then
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
      if ui.mouse.left == "pressed" then self.mouse.left = "pressed" end
      if ui.mouse.right == "pressed" then self.mouse.right = "pressed" end
    else
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