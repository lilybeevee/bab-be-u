local text_input = {}

function text_input.new()
  local o = ui.component.new()

  o:setFont(ui.fonts.default)

  o.scroll_x = 0
  o.selection = nil
  o.selecting = -1;

  function o:getEditing() return self.editing or false end
  function o:setEditing(val)
    love.keyboard.setTextInput(val)
    self.editing = val
    return self
  end

  function o:getEditPos() return self.edit_pos or self:getText():len() end
  function o:setEditPos(val) self.edit_pos = val; return self end

  function o:getSelection() return self.selection end
  function o:setSelection(a, b) self.selection = a and {a = a, b = b or self:getText():len()} or nil; return self end

  function o:onReturn(func) self.on_return = func; return self end
  function o:onTextEdited(func) self.on_text_edited = func; return self end

  function o:textInput(text)
    if not self:getEditing() or love.keyboard.isDown("lctrl") then return end

    self:plsMakeSureThatTheEditPosIsWithinTheTextLimitsBeforeDoingAnythingWithItOrElseStuffWillProbablyBreak()

    local a = self:getText():sub(1, self:getEditPos())
    local b = self:getText():sub(self:getEditPos() + 1)
    self:setText(a .. text .. b)
    self:setEditPos(self:getEditPos() + text:len())
    if self.on_text_edited then
      self:on_text_edited("add", text)
    end
  end

  function o:keyPressed(key)
    if not self:getEditing() then return end

    self:plsMakeSureThatTheEditPosIsWithinTheTextLimitsBeforeDoingAnythingWithItOrElseStuffWillProbablyBreak()

    if key == "left" then
      self:setEditPos(self:getEditPos() - 1)
    elseif key == "right" then
      self:setEditPos(self:getEditPos() + 1)
    elseif key == "home" then
      self:setEditPos(0)
    elseif key == "end" then
      self:setEditPos(#self:getText())
    elseif key == "backspace" then
      if self:getEditPos() > 0 then
        local a = self:getText():sub(1, self:getEditPos() - 1)
        local b = self:getText():sub(self:getEditPos() + 1)
        self:setText(a .. b)
        self:setEditPos(self:getEditPos() - 1)
        if self.on_text_edited then
          self:on_text_edited("delete")
        end
      end
    elseif key == "delete" then
      if self:getEditPos() < self:getText():len() then
        local a = self:getText():sub(1, self:getEditPos())
        local b = self:getText():sub(self:getEditPos() + 2)
        self:setText(a .. b)
        if self.on_text_edited then
          self:on_text_edited("delete")
        end
      end
    elseif key == "return" or key == "escape" then
      ui.setEditing()
    elseif key == "v" and love.keyboard.isDown("lctrl") then
      self:textInput(love.system.getClipboardText())
    end
  end

  function o:drawText()
    self:plsMakeSureThatTheEditPosIsWithinTheTextLimitsBeforeDoingAnythingWithItOrElseStuffWillProbablyBreak()

    local font = self:getFont()
    love.graphics.setFont(font)

    local lines = {}
    if self:getWrap() then
      _,lines = font:getWrap(self:getText(), self:getWidth())
    else
      lines = {self:getText()}
    end

    local selector_x = 0
    local selector_y = 0
    local selector_line = 1

    local current_line = 1
    local line_pos = 0
    for i = 1, self:getEditPos() do
      line_pos = line_pos + 1
      if line_pos > lines[current_line]:len() then
        if not lines[current_line] then break
        else
          current_line = current_line + 1
          line_pos = 1
        end
      end
    end
    selector_x = font:getWidth(lines[current_line]:sub(1, line_pos))
    selector_y = font:getHeight()
    selector_line = current_line

    local sx, sy = love.graphics.transformPoint(0, 0)
    local sx2, sy2 = love.graphics.transformPoint(self:getWidth(), self:getHeight())
    local sw, sh = sx2 - sx, sy2 - sy

    love.graphics.setScissor(sx, sy, sw, sh)

    local height = #lines * font:getHeight()
    local y = self:getHeight() / 2 - height / 2
    for i,line in ipairs(lines) do
      local width = font:getWidth(line)
      local x = 0
      if self:getAlign() == "center" then
        x = self:getWidth() / 2 - width / 2
      elseif self:getAlign() == "right" then
        x = self:getWidth() - width
      end

      if selector_line == i and self:getEditing() then
        if selector_x + x + self.scroll_x + 1 < 0 then
          self.scroll_x = -(x + selector_x + 1)
        elseif selector_x + x + self.scroll_x + 1 > self:getWidth() then
          self.scroll_x = -(x + selector_x + 1) - self:getWidth()
        end

        local min_x = math.min(0, self:getWidth() - (font:getWidth(line) + 1))
        if self.scroll_x < min_x then self.scroll_x = min_x end
        if self.scroll_x > 0 then self.scroll_x = 0 end

        x = x + self.scroll_x

        if math.floor(love.timer.getTime()*2) % 2 == 0 then
          love.graphics.rectangle("fill", x + selector_x, y + (i - 1) * font:getHeight(), 1, font:getHeight())
        end
      end

      love.graphics.print(self:getText(), x, y + (i - 1) * font:getHeight())
    end

    love.graphics.setScissor()
  end

  function o:plsMakeSureThatTheEditPosIsWithinTheTextLimitsBeforeDoingAnythingWithItOrElseStuffWillProbablyBreak()
    self.edit_pos = math.max(0, math.min(self:getText():len(), self:getEditPos()))
    if self.selection then
      self.selection.a = math.max(0, math.min(self:getText():len(), self.selection.a))
      self.selection.b = math.max(0, math.min(self:getText():len(), self.selection.b))
    end
  end

  return o
end

return text_input