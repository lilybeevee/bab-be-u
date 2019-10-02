local component = {}

-- Basic component, used as a base for others
function component.new(t)
  local o = t or {}

  o.data = {}
  o.children = {}
  o.mouse = {x = -1, y = -1, left = "up", right = "up"}
  o.frame = 0
  o.select_state = nil
  o.draw_params = {}

  -- Event Tables
  o.on_hovered = {}
  o.on_exited = {}
  o.on_pressed = {}
  o.on_released = {}

  o.on_pre_draw = {}
  o.on_draw = {}

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
      elseif self:getText() ~= "" then return self:getFont():getWidth(self:getText())
      else return 0 end
    else return self.w end
  end
  function o:getHeight()
    if not self.h then
      if self:getSprite() then return self:getSprite():getHeight()
      elseif self:getText() ~= "" then return self:getFont():getHeight()
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

  function o:getDrawX() return self.draw_params.x or self:getX() end
  function o:getDrawY() return self.draw_params.y or self:getY() end
  function o:getDrawPos() return self:getDrawX(), self:getDrawY() end
  function o:getDrawWidth() return self.draw_params.w or self:getWidth() end
  function o:getDrawHeight() return self.draw_params.h or self:getHeight() end
  function o:getDrawSize() return self:getDrawWidth(), self:getDrawHeight() end

  function o:getEnabled() if self.enabled == nil then return true else return self.enabled end end
  function o:setEnabled(val) self.enabled = val; return self end

  -- Container Functions

  function o:addChild(child)
    if not table.has_value(self.children, child) then
      table.insert(self.children, child)
      child.parent = child.parent or self
    end
  end

  function o:removeChild(child)
    for i,v in ipairs(self.children) do
      if v == child then
        table.remove(self.children, i)
        if child.parent == self then child.parent = nil end
        break
      end
    end
  end

  function o:hasParent(parent)
    if not self.parent then
      return false
    else
      return self.parent == parent or self.parent:hasParent(parent)
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

  function o:getPivotX() return self.px or 0 end
  function o:getPivotY() return self.py or 0 end
  
  function o:setPivotX(val) self.px = val; return self end
  function o:setPivotY(val) self.py = val; return self end

  function o:getPivot() return self:getPivotX(), self:getPivotY() end
  function o:setPivot(x, y)
    self:setPivotX(x)
    self:setPivotY(y or x)
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

  function o:getMarginX() return self.margin_x or 0 end
  function o:getMarginY() return self.margin_y or 0 end

  function o:setMarginX(val) self.margin_x = val; return self end
  function o:setMarginY(val) self.margin_y = val; return self end

  function o:getMargin() return self:getMarginX(), self:getMarginY() end
  function o:setMargin(x, y)
    self:setMarginX(x)
    self:setMarginY(y or x)
    return self
  end

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

  function o:getSelectable()
    if self.selectable == nil then
      return #self.on_pressed > 0 or #self.on_released > 0
    else return self.selectable end
  end
  function o:setSelectable(val) self.selectable = val; return self end

  function o:hovered(ignore_global)
    if not ignore_global and ui.hovered and ui.hovered ~= self and ui.selected ~= self then
      if not self.parent or (self.parent and not self.parent:hovered()) then
        return false
      end
    end
    if not ignore_global then
      if self.select_state ~= nil then return true end
      if ui.lock_hovered and ui.selected then return false end
    end
    return self.mouse.x >= 0 and
          self.mouse.y >= 0 and
          self.mouse.x < self:getWidth() and 
          self.mouse.y < self:getHeight()
  end

  function o:pressed(button)
    if self.select_state == "pressed" then return true end
    if button == 2 then return self.mouse.right == "pressed" end
    if button == 1 then return self.mouse.left == "pressed" end
    return (self.mouse.left == "pressed" and self.mouse.right ~= "down") or
           (self.mouse.right == "pressed" and self.mouse.left ~= "down")
  end

  function o:down(button)
    if self.select_state == "down" then return true end
    if button == 2 then return self.mouse.right == "down" end
    if button == 1 then return self.mouse.left == "down" end
    return self.mouse.left == "down" or self.mouse.right == "down"
  end

  function o:released(button)
    if self.select_state == "released" then return true end
    if button == 2 then return self.mouse.right == "released" end
    if button == 1 then return self.mouse.left == "released" end
    return (self.mouse.left == "released" and self.mouse.right ~= "pressed" and self.mouse.right ~= "down") or
           (self.mouse.right == "released" and self.mouse.left ~= "pressed" and self.mouse.left ~= "down")
  end

  function o:up(button)
    if self.select_state == "selected" then return true end
    if button == 2 then return self.mouse.right == "up" end
    if button == 1 then return self.mouse.left == "up" end
    return (self.mouse.left == "up" and self.mouse.right ~= "pressed" and self.mouse.right ~= "down") or
           (self.mouse.right == "up" and self.mouse.left ~= "pressed" and self.mouse.left ~= "down")
  end

  function o:onHovered(func) table.insert(self.on_hovered, func); return self end
  function o:onExited(func) table.insert(self.on_exited, func); return self end
  function o:onPressed(func) table.insert(self.on_pressed, func); return self end
  function o:onReleased(func) table.insert(self.on_released, func); return self end

  function o:onPreDraw(func) table.insert(self.on_pre_draw, func); return self end
  function o:onDraw(func) table.insert(self.on_draw, func); return self end

  function o:call(event, ...)
    local args = {...}
    local cancel = false
    for _,f in ipairs(event) do cancel = f(self, unpack(args)) or cancel end
    return cancel
  end

  function o:draw(parent)
    if not self:getEnabled() then return end

    self.frame = frame
    self.parent = parent

    love.graphics.push()
    local cancel_pre_draw = self:call(self.on_pre_draw)
    if not cancel_pre_draw and self.preDraw then
      self:preDraw()
    end
    self:transform()
    self:updateMouse()
    self:updateDrawParams()
    
    local cancel_draw = self:call(self.on_draw)
    if not cancel_draw then
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
    end

    if self.postDraw then
      self:postDraw()
    end

    for i,child in ipairs(self.children) do
      child:draw(self)
    end

    love.graphics.pop()

    if self:getSelectable() then
      table.insert(ui.selectables, self)
    end
  end

  -- Internal Functions

  function o:useColor()
    if rainbowmode then
      love.graphics.setColor(hslToRgb((love.timer.getTime()/4+self:getX()/18+self:getY()/18)%1, .5, .5, .9))
    elseif self:pressed() or self:down() then
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
        local _,lines = font:getWrap(self:getText(), self:getWidth() - self:getMarginX()*2)
        height = #lines * font:getHeight()
      else
        height = font:getHeight()
      end

      love.graphics.printf(self:getText(), self:getMarginX(), self:getMarginY() + (self:getHeight() - self:getMarginY()*2) / 2 - height / 2, self:getWidth() - self:getMarginX()*2, self:getAlign())
    end
  end

  function o:transform()
    love.graphics.translate(self:getPos())
    if self:getCentered() then
      love.graphics.translate(-self:getWidth() / 2, -self:getHeight() / 2)
    end
    love.graphics.translate(self:getWidth() * self:getPivotX(), self:getHeight() * self:getPivotY())
    love.graphics.scale(self:getScale())
    love.graphics.rotate(self:getRotation())
    love.graphics.translate(-self:getWidth() * self:getPivotX(), -self:getHeight() * self:getPivotY())
  end

  function o:updateDrawParams()
    local dx1, dy1, dx2, dy2
    if not self:getCentered() then
      dx1, dy1 = love.graphics.transformPoint(0, 0)
      dx2, dy2 = love.graphics.transformPoint(self:getWidth(), self:getHeight())
    else
      dx1, dy1 = love.graphics.transformPoint(-self:getWidth()/2, -self:getHeight()/2)
      dx2, dy2 = love.graphics.transformPoint(self:getWidth()/2, self:getHeight()/2)
    end
    self.draw_params.x = dx1
    self.draw_params.y = dy1
    self.draw_params.w = dx2 - dx1
    self.draw_params.h = dy2 - dy1
  end

  function o:updateMouse(transform)
    if transform then
      self.mouse.x, self.mouse.y = transform:transformPoint(love.mouse.getPosition())
    else
      self.mouse.x, self.mouse.y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
    end
    if self.mouse.left ~= "up" then self.mouse.left = ui.mouse.left end
    if self.mouse.right ~= "up" then self.mouse.right = ui.mouse.right end
    if not ui.lock_hovered then
      if self:getFocus() and self:hovered(true) then ui.new_hovered = self end
    end
    if self:hovered() then
      if not self.last_hovered then
        self.last_hovered = true
        self:call(self.on_hovered, not ui.lock_hovered)
      end
      if ui.mouse.left == "pressed" then self.mouse.left = "pressed" end
      if ui.mouse.right == "pressed" then self.mouse.right = "pressed" end
    else
      if self.last_hovered then
        self.last_hovered = false
        self:call(self.on_exited, not ui.lock_hovered)
      end
      if self.mouse.left == "released" then self.mouse.left = "up" end
      if self.mouse.right == "released" then self.mouse.right = "up" end
    end
    if self.mouse.left == "pressed" then self:call(self.on_pressed, 1) end
    if self.mouse.right == "pressed" then self:call(self.on_pressed, 2) end
    if self.mouse.left == "released" then self:call(self.on_released, 1) end
    if self.mouse.right == "released" then self:call(self.on_released, 2) end

    if self.select_state == "pressed" then self:call(self.on_pressed, 1) end
    if self.select_state == "released" then self:call(self.on_released, 1) end
  end

  return o
end

return component