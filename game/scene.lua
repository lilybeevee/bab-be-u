local scene = {}

function scene.load()
  repeat_timers = {}
  selector_open = false
  game_started = false

  scene.resetStuff()

  game_started = true
end

function scene.update(dt)
  --mouse_X = love.mouse.getX()
  --mouse_Y = love.mouse.getY()
  
  mouse_movedX = love.mouse.getX() - love.graphics.getWidth()*0.5
  mouse_movedY = love.mouse.getY() - love.graphics.getHeight()*0.5
  
  scene.checkInput()
  
  for i,mous in ipairs(cursors) do
  	cursors[i].x = cursors[i].x + mouse_movedX
  	cursors[i].y = cursors[i].y + mouse_movedY
  end
  
  if game_started and cursor_convert_to ~= nil then
    for i,mous in ipairs(cursors) do
      local hx,hy = screenToGameTile(cursors[i].x, cursors[i].y)
      if hx ~= nil and hy ~= nil then
        local new_unit = createUnit(cursor_convert_to, hx, hy, 1, true)
        addUndo({"create", new_unit.id, true})
        addUndo({"remove_cursor", cursors[i].x, cursors[i].y, cursors[i].id})
        deleteMouse(cursors[i].id)
      end
    end
  end
  
  
  love.mouse.setPosition(love.graphics.getWidth()*0.5, love.graphics.getHeight()*0.5)
end

function scene.resetStuff()
  clear()
  love.mouse.setCursor(empty_cursor)
  love.mouse.setGrabbed(true)
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
          local mask_shader = love.graphics.newShader[[
             vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
                if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
                   // a discarded pixel wont be applied as the stencil.
                   discard;
                }
                return vec4(1.0);
             }
          ]]
          local function overlayStencil()
             love.graphics.setShader(mask_shader)
             love.graphics.draw(sprite, (drawx + 0.5)*TILE_SIZE, (drawy + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
             love.graphics.setShader()
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
  
  for i,mous in ipairs(cursors) do
    love.graphics.draw(system_cursor, cursors[i].x, cursors[i].y)
  end
end

function scene.checkInput()
  do_move_sound = false

  for _,key in ipairs(repeat_keys) do
    if not win and repeat_timers[key] ~= nil and repeat_timers[key] <= 0 then
      local dir = key
      if key == "w" then
        dir = "up"
      elseif key == "a" then
        dir = "left"
      elseif key == "s" then
        dir = "down"
      elseif key == "d" then
        dir = "right"
      end
      if dir == "up" or dir == "down" or dir == "right" or dir == "left" then
        newUndo()
        doMovement(dir)
      elseif key == "z" then
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