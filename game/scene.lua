local scene = {}

function scene.load()
  repeat_timers = {}
  selector_open = false

  clear()
  resetMusic("bab_be_u_them", 0.5)
  loadMap()
  parseRules()
  updateUnits(true)
end

function scene.update(dt)
  scene.checkInput()

  if not cursor_converted then
    love.mouse.setCursor()
    love.mouse.setGrabbed(false)
    if cursor_convert ~= nil then
      local hx,hy = getHoveredTile()
      if hx ~= nil then
        local new_unit = createUnit(cursor_convert, hx, hy, 1, true)
        addUndo({"create", new_unit.id, true})
        addUndo({"cursor", love.mouse.getX(), love.mouse.getY()})

        love.mouse.setCursor(empty_cursor)
        love.mouse.setGrabbed(true)

        cursor_converted = true
      end
    end
  end
end

function scene.keyPressed(key)
  for _,v in ipairs(repeat_keys) do
    if v == key then
      repeat_timers[v] = 0
    end
  end

  if key == "r" then
    clear()
    resetMusic("bab_be_u_them", 0.5)
    loadMap()
    parseRules()
    updateUnits(true)
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

  local roomwidth = mapwidth * TILE_SIZE
  local roomheight = mapheight * TILE_SIZE

  love.graphics.push()
  love.graphics.applyTransform(scene.getTransform())

  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, 0, roomwidth, roomheight)

  for i=1,max_layer do
    if units_by_layer[i] then
      local removed_units = {}
      for _,unit in ipairs(units_by_layer[i]) do
        local sprite = sprites[unit.sprite]
        local brightness = 1
        if unit.type == "text" and not unit.active then
          brightness = 0.33
        end
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

        if unit.overlay and eq(unit.color, tiles_list[unit.tile].color) then
          love.graphics.setColor(1, 1, 1)
        else
          love.graphics.setColor(unit.color[1]/255 * brightness, unit.color[2]/255 * brightness, unit.color[3]/255 * brightness)
        end
        love.graphics.draw(sprite, (drawx + 0.5)*TILE_SIZE, (drawy + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
        if unit.overlay then
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
          love.graphics.setColor(1, 1, 1)
          love.graphics.stencil(overlayStencil, "replace")
          love.graphics.setStencilTest("greater", 0)
          love.graphics.setBlendMode("multiply", "premultiplied")
          love.graphics.draw(sprites["overlay_" .. unit.overlay], (drawx + 0.5)*TILE_SIZE, (drawy + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
          love.graphics.setBlendMode("alpha", "alphamultiply")
          love.graphics.setStencilTest()  
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

  love.graphics.setColor(1, 1, 1)
  love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  love.graphics.scale(win_size, win_size)
  local win_sprite = sprites["u_r_win"]
  love.graphics.draw(win_sprite, -win_sprite:getWidth() / 2, -win_sprite:getHeight() / 2)

  if win and win_size < 1 then
    win_size = win_size + 0.02
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