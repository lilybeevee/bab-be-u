local scene = {}

local mask_shader = love.graphics.newShader[[
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
     if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
        // a discarded pixel wont be applied as the stencil.
        discard;
     }
     return vec4(1.0);
  }
]]

local paletteshader_0 = love.graphics.newShader[[
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 texturecolor = Texel(texture, texture_coords);
    texturecolor = texturecolor * color;
    number r = texturecolor.r;
    number g = texturecolor.g;
    number b = texturecolor.b;
    return vec4(r, g, b, texturecolor.a);
  }
]]
local paletteshader_1 = love.graphics.newShader[[
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 texturecolor = Texel(texture, texture_coords);
    texturecolor = texturecolor * color;
    number r = texturecolor.r + 0.1;
    number g = texturecolor.g - 0.1 + (texturecolor.b * 0.3);
    number b = texturecolor.b * 0.8;
    return vec4(r, g, b, texturecolor.a);
  }
]]
local palette_shader = paletteshader_1

function scene.load()
  repeat_timers = {}
  selector_open = false

  scene.resetStuff()

  local now = os.time(os.date("*t"))
  presence = {
    state = "ingame",
    details = "playing the gam",
    largeImageKey = "cover",
    largeimageText = "bab be u",
    smallImageKey = "icon",
    smallImageText = "bab",
    startTimestamp = now
  }
  nextPresenceUpdate = 0
end

function scene.update(dt)
  mouse_X = love.mouse.getX()
  mouse_Y = love.mouse.getY()
  
  --mouse_movedX = love.mouse.getX() - love.graphics.getWidth()*0.5
  --mouse_movedY = love.mouse.getY() - love.graphics.getHeight()*0.5
  
  scene.checkInput()
  updateCursors()
  
  mouse_oldX = mouse_X
  mouse_oldY = mouse_Y

  if #cursors == 0 then
    love.mouse.setGrabbed(true)
  else
    love.mouse.setGrabbed(false)
  end
end

function scene.resetStuff()
  clear()
  love.mouse.setCursor(empty_cursor)
  --love.mouse.setGrabbed(true)
  --resetMusic("bab_be_u_them", 0.5)
  resetMusic("bab be go", 0.4)
  loadMap()
  parseRules()
  updateUnits(true)
end

function scene.keyPressed(key)
  for _,v in ipairs(repeat_keys) do
    if v == key then
      repeat_timers[v] = 0
    end
  end

  if key == "r" then
    scene.resetStuff()
  end
end

function scene.keyReleased(key)
  for _,v in ipairs(repeat_keys) do
    if v == key then
      repeat_timers[v] = nil
    end
  end

  if key == "z" then
    UNDO_DELAY = MAX_UNDO_DELAY
  end
end

function scene.getTransform()
  local transform = love.math.newTransform()

  local roomwidth = mapwidth * TILE_SIZE
  local roomheight = mapheight * TILE_SIZE
  transform:translate(love.graphics.getWidth() / 2 - roomwidth / 2, love.graphics.getHeight() / 2 - roomheight / 2)

  return transform
end

function scene.draw(dt)
  love.graphics.setShader(palette_shader)
  love.graphics.setBackgroundColor(0.10, 0.1, 0.11)
  if rainbowmode then love.graphics.setBackgroundColor(hslToRgb(love.timer.getTime()/6%1, .2, .2, .9)) end

  local roomwidth = mapwidth * TILE_SIZE
  local roomheight = mapheight * TILE_SIZE

  love.graphics.push()
  love.graphics.applyTransform(scene.getTransform())

  love.graphics.setColor(0, 0, 0)
  if rainbowmode then love.graphics.setColor(hslToRgb(love.timer.getTime()/6%1, .1, .1, .9)) end
  love.graphics.rectangle("fill", 0, 0, roomwidth, roomheight)

  for i=1,max_layer do
    if units_by_layer[i] then
      local removed_units = {}
      for _,unit in ipairs(units_by_layer[i]) do
        local brightness = 1
        if unit.type == "text" and not unit.active then
          brightness = 0.33
        end

        if unit.fullname == "text_gay" then
          if unit.active then
            unit.sprite = "text_gay-colored"
          else
            unit.sprite = "text_gay"
          end
        end
        if unit.fullname == "text_tranz" then
          if unit.active then
            unit.sprite = "text_tranz-colored"
          else
            unit.sprite = "text_tranz"
          end
        end

        --os
        if unit.fullname == "os" then
          local os = love.system.getOS()
          if os == "Windows" then
            unit.sprite = "os_windous"
          elseif os == "OS X" or os == "iOS" then
            unit.sprite = "os_mak"
          elseif os == "Linux" then
            unit.sprite = "os_linx"
          elseif os == "Android" then
            unit.sprite = "os_androd"
          else
            unit.sprite = "wat"
          end
        end


        if hasProperty(unit,"colrful") or rainbowmode then
          local newcolor = hslToRgb((#undo_buffer/45+unit.x/18+unit.y/18)%1, .5, .5, 1)
          newcolor[1] = newcolor[1]*255
          newcolor[2] = newcolor[2]*255
          newcolor[3] = newcolor[3]*255
          unit.color = newcolor
        end

        if hasProperty(unit,"reed") then
          unit.color = {229,83,59}
        end
        if hasProperty(unit,"bleu") then
          unit.color = {145,131,215}
        end

        if hasProperty(unit,"bleu") and hasProperty(unit,"reed") then
          unit.color = {187,107,137}
        end

        if not hasProperty(unit,"colrful") and not hasProperty(unit, "reed") and not hasProperty(unit, "bleu") and not rainbowmode then
          unit.color = copyTable(tiles_list[unit.tile].color)
        end

        local sprite = sprites[unit.sprite]
        if not sprite then sprite = sprites["wat"] end

        local drawx = lerp(unit.oldx, unit.x, unit.move_timer/MAX_MOVE_TIMER)
        local drawy = lerp(unit.oldy, unit.y, unit.move_timer/MAX_MOVE_TIMER)

        if unit.removed then
          unit.scaley = math.max(0, unit.scaley - (dt*10))
          if unit.scaley == 0 then
            table.insert(removed_units, unit)
          end
        elseif unit.scaley < 1 then
          unit.scaley = math.min(1, unit.scaley + (dt*10))
        end

        local rotation = 0
        if unit.rotate then
          rotation = (unit.dir - 1) * 90
        end

        if #unit.overlay > 0 and eq(unit.color, tiles_list[unit.tile].color) then
          love.graphics.setColor(1, 1, 1)
        else
          love.graphics.setColor(unit.color[1]/255 * brightness, unit.color[2]/255 * brightness, unit.color[3]/255 * brightness)
        end
        love.graphics.draw(sprite, (drawx + 0.5)*TILE_SIZE, (drawy + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
        if #unit.overlay > 0 then
          local function overlayStencil()
             love.graphics.setShader(mask_shader)
             love.graphics.draw(sprite, (drawx + 0.5)*TILE_SIZE, (drawy + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
             love.graphics.setShader(palette_shader)
          end
          for _,overlay in ipairs(unit.overlay) do
            love.graphics.setColor(1, 1, 1)
            love.graphics.stencil(overlayStencil, "replace")
            love.graphics.setStencilTest("greater", 0)
            love.graphics.setBlendMode("multiply", "premultiplied")
            love.graphics.draw(sprites["overlay_" .. overlay], (drawx + 0.5)*TILE_SIZE, (drawy + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
            love.graphics.setBlendMode("alpha", "alphamultiply")
            love.graphics.setStencilTest() 
          end 
        end

        if unit.move_timer < MAX_MOVE_TIMER then
          unit.move_timer = math.min(MAX_MOVE_TIMER, unit.move_timer + (dt * 1000))
        end
      end
      for _,unit in ipairs(removed_units) do
        removeFromTable(units_by_layer[i], unit)
      end
    end
  end
  local removed_particles = {}
  for _,ps in ipairs(particles) do
    ps:update(dt)
    if ps:getCount() == 0 then
      ps:stop()
      table.insert(removed_particles, ps)
    else
      love.graphics.setColor(255, 255, 255)
      love.graphics.draw(ps)
    end
  end
  for _,ps in ipairs(removed_particles) do
    removeFromTable(particles, ps)
  end
  love.graphics.pop()

  love.graphics.push()
  love.graphics.setColor(1, 1, 1)
  love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  love.graphics.scale(win_size, win_size)
  local win_sprite = sprites["u_r_win"]
  love.graphics.draw(win_sprite, -win_sprite:getWidth() / 2, -win_sprite:getHeight() / 2)

  if win and win_size < 1 then
    win_size = win_size + 0.02
  end
  love.graphics.pop()
  
  if love.window.hasMouseFocus() then
    for i,cursor in ipairs(cursors) do
      local color

      if hasProperty(cursor,"colrful") or rainbowmode then
        local newcolor = hslToRgb((#undo_buffer/45+cursor.x/18+cursor.y/18)%1, .5, .5, 1)
        newcolor[1] = newcolor[1]*255
        newcolor[2] = newcolor[2]*255
        newcolor[3] = newcolor[3]*255
        color = newcolor
      elseif hasProperty(cursor,"bleu") and hasProperty(cursor,"reed") then
        color = {187,107,137}
      elseif hasProperty(cursor,"reed") then
        color = {229,83,59}
      elseif hasProperty(cursor,"bleu") then
        color = {145,131,215}
      end

      if not color then
        love.graphics.setColor(1, 1, 1)
      else
        love.graphics.setColor(color[1]/255, color[2]/255, color[3]/255)
      end
      love.graphics.draw(system_cursor, cursor.x, cursor.y)

      if #cursor.overlay > 0 then
        local function overlayStencil()
          love.graphics.setShader(mask_shader)
          love.graphics.draw(system_cursor, cursor.x, cursor.y)
          love.graphics.setShader(palette_shader)
        end
        for _,overlay in ipairs(cursor.overlay) do
          love.graphics.setColor(1, 1, 1)
          love.graphics.stencil(overlayStencil, "replace")
          love.graphics.setStencilTest("greater", 0)
          love.graphics.setBlendMode("multiply", "premultiplied")
          love.graphics.draw(sprites["overlay_" .. overlay], cursor.x, cursor.y, 0, 14/32, 14/32)
          love.graphics.setBlendMode("alpha", "alphamultiply")
          love.graphics.setStencilTest() 
        end
      end
    end
  end
end

function scene.checkInput()
  do_move_sound = false

  for _,key in ipairs(repeat_keys) do
    if not win and repeat_timers[key] ~= nil and repeat_timers[key] <= 0 then
      local control = key
      if key == "w" then
        control = "up"
      elseif key == "a" then
        control = "left"
      elseif key == "s" then
        control = "down"
      elseif key == "d" then
        control = "right"
      elseif key == "space" then
        control = "wait"
      end
      if control == "up" or control == "down" or control == "right" or control == "left" or control == "wait" then
        newUndo()
        update_undo = false
        doMovement(control)
      elseif key == "z" then
        update_undo = false
        undo()
      end
    end

    if repeat_timers[key] ~= nil then
      if repeat_timers[key] <= 0 then
        if key ~= "z" then
          repeat_timers[key] = repeat_timers[key] + INPUT_DELAY
        else
          repeat_timers[key] = repeat_timers[key] + UNDO_DELAY
          UNDO_DELAY = math.max(MIN_UNDO_DELAY, UNDO_DELAY - UNDO_SPEED)
        end
      end
      repeat_timers[key] = repeat_timers[key] - (love.timer.getDelta() * 1000)
    end
  end

  if do_move_sound then
    playSound("move", 0.33)
  end
end

return scene