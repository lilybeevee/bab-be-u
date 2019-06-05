local scene = {}
window_dir = 0

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
--local paletteshader_autumn = love.graphics.newShader("paletteshader_autumn.txt")
--local paletteshader_dunno = love.graphics.newShader("paletteshader_dunno.txt")
if not is_mobile then
  local shader_zawarudo = love.graphics.newShader("shader_pucker.txt")
end
local level_shader = paletteshader_0
local doin_the_world = false
local shader_time = 0

local particle_timers = {}

local canv = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
local last_width,last_height = love.graphics.getWidth(),love.graphics.getHeight()

function scene.load()
  repeat_timers = {}
  key_down = {}
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

  scene.doPassiveParticles(dt, ":)", "bonus", 0.25, 1, 1, {237,226,133})
  scene.doPassiveParticles(dt, ":o", "bonus", 0.5, 0.8, 1, {257,57,106})
  scene.doPassiveParticles(dt, "qt", "love", 0.25, 0.5, 1, {235,145,202})

  debugDisplay('window dir', window_dir)
end

function scene.resetStuff()
  clear()
  if not is_mobile then
    love.mouse.setCursor(empty_cursor)
  end
  --love.mouse.setGrabbed(true)
  --resetMusic("bab be u them", 0.5)
  resetMusic(map_music, 0.5)
  loadMap()
  parseRules()
  updateUnits(true)

  first_turn = false
  window_dir = 0
end

function scene.keyPressed(key, isrepeat)
  if isrepeat then
    return
  end

  if key == "w" or key == "a" or key == "s" or key == "d" then
    if not repeat_timers["wasd"] then
      repeat_timers["wasd"] = 30
    end
  elseif key == "up" or key == "down" or key == "left" or key == "right" then
    if not repeat_timers["udlr"] then
      repeat_timers["udlr"] = 30
    end
  elseif key == "z" or key == "backspace" then
    if not repeat_timers["undo"] then
      repeat_timers["undo"] = 0
    end
  end

  for _,v in ipairs(repeat_keys) do
    if v == key then
      repeat_timers[v] = 0
    end
  end

  if key == "r" then
    scene.resetStuff()
  end
  
  if key == "y" then
    level_shader = shader_zawarudo
    shader_time = 0
    doin_the_world = true
  end

  key_down[key] = true
end

function scene.keyReleased(key)
  for _,v in ipairs(repeat_keys) do
    if v == key then
      repeat_timers[v] = nil
    end
  end

  if key == "z" or key == "backspace" then
    UNDO_DELAY = MAX_UNDO_DELAY
  end

  key_down[key] = false
end

function scene.getTransform()
  local transform = love.math.newTransform()

  local roomwidth = mapwidth * TILE_SIZE
  local roomheight = mapheight * TILE_SIZE

  local screenwidth = love.graphics.getWidth()
  local screenheight = love.graphics.getHeight()

  local scale = 1
  if roomwidth >= screenwidth or roomheight >= screenheight then
    scale = 0.5
  elseif screenwidth >= roomwidth * 4 and screenheight >= roomheight * 4 then
    scale = 4
  elseif screenwidth >= roomwidth * 2 and screenheight >= roomheight * 2 then
    scale = 2
  end

  local scaledwidth = screenwidth * (1/scale)
  local scaledheight = screenheight * (1/scale)

  transform:scale(scale, scale)
  transform:translate(scaledwidth / 2 - roomwidth / 2, scaledheight / 2 - roomheight / 2)

  return transform
end

--TODO: PERFORMANCE: Calling hasProperty once per frame means that we have to index rules, check conditions, etc. with O(m*n) performance penalty. But, the results of these calls do not change until a new turn or undo. So, we can cache the values of these calls in a global table and dump the table whenever the turn changes for a nice and easy performance boost.
--(Though this might not be true for mice, which can change their position mid-frame?? Also for other meta stuff (like windo)? Until there's mouse conditional rules or meta stuff in a puzzle IDK how this should actually work or be displayed. Just keep that in mind tho.)
function scene.draw(dt)
  -- reset canvas if the screen size has changed
  if love.graphics.getWidth() ~= last_width or love.graphics.getHeight() ~= last_height then
    last_width = love.graphics.getWidth()
    last_height = love.graphics.getHeight()
    canv = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
  end

  love.graphics.setCanvas{canv, stencil=true}
  love.graphics.setShader()

  --background color
  local bg_color = {getPaletteColor(1, 0)}

  love.graphics.setColor(bg_color[1], bg_color[2], bg_color[3], bg_color[4])
  if rainbowmode then love.graphics.setColor(hslToRgb(love.timer.getTime()/6%1, .2, .2, .9)) end

  -- fill the background with the background color
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

  local roomwidth = mapwidth * TILE_SIZE
  local roomheight = mapheight * TILE_SIZE

  love.graphics.push()
  love.graphics.applyTransform(scene.getTransform())

  love.graphics.setColor(getPaletteColor(0, 4))
  if rainbowmode then love.graphics.setColor(hslToRgb(love.timer.getTime()/6%1, .1, .1, .9)) end
  love.graphics.rectangle("fill", 0, 0, roomwidth, roomheight)

  for i=1,max_layer do
    if units_by_layer[i] then
      local removed_units = {}
      for _,unit in ipairs(units_by_layer[i]) do
        if not hasProperty(unit,"stelth") and (unit.name ~= "no1" or validEmpty(unit)) then
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

          if hasProperty(unit,"colrful") or rainbowmode then
            local newcolor = hslToRgb((#undo_buffer/45+unit.x/18+unit.y/18)%1, .5, .5, 1)
            newcolor[1] = newcolor[1]*255
            newcolor[2] = newcolor[2]*255
            newcolor[3] = newcolor[3]*255
            unit.color = newcolor
          elseif hasProperty(unit,"bleu") and hasProperty(unit,"reed") then
            unit.color = {3, 1}
          elseif hasProperty(unit,"reed") then
            unit.color = {2, 2}
          elseif hasProperty(unit,"bleu") then
            unit.color = {1, 3}
          end

          if not hasProperty(unit,"colrful") and not hasProperty(unit, "reed") and not hasProperty(unit, "bleu") and not rainbowmode then
            unit.color = copyTable(tiles_list[unit.tile].color)
          end

          local sprite_name = unit.sprite
          
          for type,name in pairs(unit.sprite_transforms) do
            if table.has_value(unit.used_as, type) then
              sprite_name = name
              break
            end
          end
          local frame = (unit.frame + anim_stage) % 3 + 1
          if sprites[sprite_name .. "_" .. frame] then
            sprite_name = sprite_name .. "_" .. frame
          end
          if not sprites[sprite_name] then sprite_name = "wat" end

          local sprite = sprites[sprite_name]

          local drawx, drawy = unit.draw.x, unit.draw.y

          local rotation = 0
          if unit.rotate then
            rotation = math.rad(unit.draw.rotation)
          end
          
          --no tweening empty for now - it's buggy!
          --TODO: it's still a little buggy if you push/pull empties.
          if (unit.name == "no1") then
            drawx = unit.x
            drawy = unit.y
            rotation = math.rad((unit.dir - 1) * 45)
            unit.draw.scalex = 1
            unit.draw.scaley = 1
          end

          local color
          if #unit.color == 3 then
            color = {unit.color[1]/255, unit.color[2]/255, unit.color[3]/255, 1}
          else
            color = {getPaletteColor(unit.color[1], unit.color[2])}
          end

          -- multiply brightness by darkened bg color
          for i,c in ipairs(bg_color) do
            if i < 4 then
              color[i] = (1 - brightness) * (bg_color[i] * 0.5) + brightness * color[i]
            end
          end

          if #unit.overlay > 0 and eq(unit.color, tiles_list[unit.tile].color) then
            love.graphics.setColor(1, 1, 1)
          else
            love.graphics.setColor(color[1], color[2], color[3], color[4])
          end

          local fulldrawx = (drawx + 0.5)*TILE_SIZE
          local fulldrawy = (drawy + 0.5)*TILE_SIZE

          if hasRule(unit,"be","flye") then
            local flyenes = countProperty(unit, "flye")
            fulldrawy = fulldrawy - 5 - math.sin(love.timer.getTime())*2.5*(flyenes^2)
          end

          love.graphics.push()
          love.graphics.translate(fulldrawx, fulldrawy)

          love.graphics.push()
          love.graphics.rotate(rotation)
          love.graphics.translate(-fulldrawx, -fulldrawy)

          local function drawSprite(overlay)
            local sprite = overlay or sprite
            love.graphics.draw(sprite, fulldrawx, fulldrawy, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
          end
          drawSprite()

          if #unit.overlay > 0 then
            local function overlayStencil()
               love.graphics.setShader(mask_shader)
               drawSprite()
               love.graphics.setShader()
            end
            for _,overlay in ipairs(unit.overlay) do
              love.graphics.setColor(1, 1, 1)
              love.graphics.stencil(overlayStencil, "replace")
              love.graphics.setStencilTest("greater", 0)
              love.graphics.setBlendMode("multiply", "premultiplied")
              drawSprite(sprites["overlay/" .. overlay])
              love.graphics.setBlendMode("alpha", "alphamultiply")
              love.graphics.setStencilTest() 
            end 
          end

          if hasRule(unit,"be","sans") and unit.eye then
            local topleft = {x = drawx * TILE_SIZE, y = drawy * TILE_SIZE}
            love.graphics.setColor(0, 1, 1, 1)
            love.graphics.rectangle("fill", topleft.x + unit.eye.x, topleft.y + unit.eye.y, unit.eye.w, unit.eye.h)
            for i = 1, unit.eye.w-1 do
              love.graphics.rectangle("fill", topleft.x + unit.eye.x + i, topleft.y + unit.eye.y - i, unit.eye.w - i, 1)
            end
          end

          if hasRule(unit,"got","hatt") then
            love.graphics.setColor(color[1], color[2], color[3], color[4])
            love.graphics.draw(sprites["hatsmol"], fulldrawx, fulldrawy - 0.5*TILE_SIZE, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
          end
          if hasRule(unit,"got","gun") then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(sprites["gunsmol"], fulldrawx, fulldrawy, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
          end
          if false then -- stupid lua comments
            if hasRule(unit,"got","?") then
              local matchrules = matchesRule(unit,"got","?")
              
              for _,matchrule in ipairs(matchrules) do
                local tile = tiles_list[tiles_by_name[matchrule[1][3]]]

                if #tile.color == 3 then
                  gotcolor = {tile.color[1]/255 * brightness, tile.color[2]/255 * brightness, tile.color[3]/255 * brightness, 1}
                else
                  local r,g,b,a = getPaletteColor(tile.color[1], tile.color[2])
                  gotcolor = {r * brightness, g * brightness, b * brightness, a}
                end

                love.graphics.setColor(gotcolor[1], gotcolor[2], gotcolor[3], gotcolor[4])
                love.graphics.draw(sprites[tile.sprite], fulldrawx/4*3, fulldrawy/4*3, 0, 1/4, 1/4, sprite:getWidth() / 2, sprite:getHeight() / 2)
              end
            end
          end

          love.graphics.pop()

          if unit.blocked then
            local rotation = (unit.blocked_dir - 1) * 45

            love.graphics.push()
            love.graphics.rotate(math.rad(rotation))
            love.graphics.translate(-fulldrawx, -fulldrawy)

            local scalex = 1
            if unit.blocked_dir % 2 == 0 then
              scalex = math.sqrt(2)
            end

            love.graphics.setColor(getPaletteColor(2, 2))
            love.graphics.draw(sprites["scribble_" .. anim_stage+1], fulldrawx, fulldrawy, 0, unit.draw.scalex * scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)

            love.graphics.pop()
          end

          love.graphics.pop()
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
  local win_sprite = sprites["ui/u_r_win"]
  love.graphics.draw(win_sprite, -win_sprite:getWidth() / 2, -win_sprite:getHeight() / 2)

  if win and win_size < 1 then
    win_size = win_size + dt*2
  end
  love.graphics.pop()
  
  if mouseOverBox(0,0,sprites["ui/cog"]:getHeight(),sprites["ui/cog"]:getWidth()) then
    if love.mouse.isDown(1) then
      love.graphics.draw(sprites["ui/cog_a"], 0, 0)
    else
      love.graphics.draw(sprites["ui/cog_h"], 0, 0)
    end
  else
    love.graphics.draw(sprites["ui/cog"], 0, 0)
  end

  if love.window.hasMouseFocus() then
    for i,cursor in ipairs(cursors) do
      local color

      if hasProperty(cursor,"colrful") or rainbowmode then
        local newcolor = hslToRgb((#undo_buffer/45+cursor.screenx/18+cursor.screeny/18)%1, .5, .5, 1)
        newcolor[1] = newcolor[1]*255
        newcolor[2] = newcolor[2]*255
        newcolor[3] = newcolor[3]*255
        color = newcolor
      elseif hasProperty(cursor,"bleu") and hasProperty(cursor,"reed") then
        color = {3, 1}
      elseif hasProperty(cursor,"reed") then
        color = {2, 2}
      elseif hasProperty(cursor,"bleu") then
        color = {1, 3}
      end

      if not color then
        love.graphics.setColor(1, 1, 1)
      else
        if #color == 3 then
          love.graphics.setColor(color[1]/255, color[2]/255, color[3]/255)
        else
          love.graphics.setColor(getPaletteColor(color[1], color[2]))
        end
      end
      love.graphics.draw(system_cursor, cursor.screenx, cursor.screeny)
      
      love.graphics.setColor(1,1,1)
      color = nil

      if #cursor.overlay > 0 then
        local function overlayStencil()
          love.graphics.setShader(mask_shader)
          love.graphics.draw(system_cursor, cursor.screenx, cursor.screeny)
          love.graphics.setShader()
        end
        for _,overlay in ipairs(cursor.overlay) do
          love.graphics.setColor(1, 1, 1)
          love.graphics.stencil(overlayStencil, "replace")
          love.graphics.setStencilTest("greater", 0)
          love.graphics.setBlendMode("multiply", "premultiplied")
          love.graphics.draw(sprites["overlay/" .. overlay], cursor.screenx, cursor.screeny, 0, 14/32, 14/32)
          love.graphics.setBlendMode("alpha", "alphamultiply")
          love.graphics.setStencilTest() 
        end
      end
    end
  end
  love.graphics.setCanvas()
  love.graphics.setShader(level_shader)
  if doin_the_world then
    level_shader:send("time", shader_time)
    shader_time = shader_time + 1
  end
  love.graphics.draw(canv,0,0)
  if shader_time == 600 then
    love.graphics.setShader(paletteshader_0)
    doin_the_world = false
  end

  if is_mobile then
    local screenwidth = love.graphics.getWidth()
    local screenheight = love.graphics.getHeight()

    local arrowsprite = sprites["ui/arrow"]
    local squaresprite = sprites["ui/square"]

    love.graphics.draw(arrowsprite, screenwidth-arrowsprite:getWidth(), screenheight, 3.14)
    love.graphics.draw(arrowsprite, screenwidth, screenheight-arrowsprite:getHeight()*2, 3.14/2)
    love.graphics.draw(arrowsprite, screenwidth-arrowsprite:getWidth()*3, screenheight-arrowsprite:getHeight(), 3.14*1.5)
    love.graphics.draw(arrowsprite, screenwidth-arrowsprite:getWidth()*2, screenheight-arrowsprite:getHeight()*3)
    love.graphics.draw(squaresprite, screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight()*2)
  end
end

function scene.checkInput()
  do_move_sound = false

  if not (key_down["w"] or key_down["a"] or key_down["s"] or key_down["d"]) then
    repeat_timers["wasd"] = nil
  end
  if not (key_down["up"] or key_down["down"] or key_down["left"] or key_down["right"]) then
    repeat_timers["udlr"] = nil
  end
  if not (key_down["z"] or key_down["backspace"]) then
    repeat_timers["undo"] = nil
  end

  for _,key in ipairs(repeat_keys) do
    if not win and repeat_timers[key] ~= nil and repeat_timers[key] <= 0 then
      if key == "undo" then
        undo()
      else
        local x, y = 0, 0
        if key == "udlr" then
          if key_down["up"] then y = y - 1 end
          if key_down["down"] then y = y + 1 end
          if key_down["left"] then x = x - 1 end
          if key_down["right"] then x = x + 1 end
        elseif key == "wasd" then
          if key_down["w"] then y = y - 1 end
          if key_down["s"] then y = y + 1 end
          if key_down["a"] then x = x - 1 end
          if key_down["d"] then x = x + 1 end
        end
        newUndo()
        last_move = {x, y}
        doMovement(x, y)
        if #undo_buffer[1] == 0 then
          table.remove(undo_buffer, 1)
        end
      end
    end

    if repeat_timers[key] ~= nil then
      if repeat_timers[key] <= 0 then
        if key ~= "undo" then
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

function scene.doPassiveParticles(timer,word,effect,delay,chance,count,color)
  local do_particles = false
  if not particle_timers[word] then
    particle_timers[word] = 0
  else
    particle_timers[word] = particle_timers[word] + timer
    if particle_timers[word] >= delay then
      particle_timers[word] = particle_timers[word] - delay
      do_particles = true
    end
  end

  if do_particles then
    local matches = matchesRule(nil,"be",word)
    for _,match in ipairs(matches) do
      local unit = match[2]
      local real_count = 0
      for i = 1, count do
        if math.random() < chance then
          real_count = real_count + 1
        end
      end
      addParticles(effect, unit.x, unit.y, color, real_count)
    end
  end
end

function scene.mouseReleased(x,y,button)
  if mouseOverBox(0,0,sprites["ui/cog"]:getHeight(),sprites["ui/cog"]:getWidth()) then
    --love.keypressed("f2")
    new_scene = editor
  end
  if is_mobile then
    local screenwidth = love.graphics.getWidth()
    local screenheight = love.graphics.getHeight()

    local arrowsprite = sprites["ui/arrow"]
    local squaresprite = sprites["ui/square"]

    local key = "0"
    
    if mouseOverBox(screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight()*2, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "space"
    elseif mouseOverBox(screenwidth-squaresprite:getWidth()*3, screenheight-squaresprite:getHeight()*2, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "left"
    elseif mouseOverBox(screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight()*3, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "up"
    elseif mouseOverBox(screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight(), squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "down"
    elseif mouseOverBox(screenwidth-squaresprite:getWidth(), screenheight-squaresprite:getHeight()*2, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "right"
    end

    scene.keyReleased(key)
  end
end

function scene.mousePressed(x, y, button)
  if is_mobile then
    local screenwidth = love.graphics.getWidth()
    local screenheight = love.graphics.getHeight()

    local arrowsprite = sprites["ui/arrow"]
    local squaresprite = sprites["ui/square"]

    local key = "0"
    
    if mouseOverBox(screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight()*2, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "space"
    elseif mouseOverBox(screenwidth-squaresprite:getWidth()*3, screenheight-squaresprite:getHeight()*2, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "left"
    elseif mouseOverBox(screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight()*3, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "up"
    elseif mouseOverBox(screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight(), squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "down"
    elseif mouseOverBox(screenwidth-squaresprite:getWidth(), screenheight-squaresprite:getHeight()*2, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "right"
    end

    scene.keyPressed(key)
  end
end

return scene
