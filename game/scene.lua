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

local xwxShader = love.graphics.newShader[[
	extern number time;

	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		vec2 newCoord = texture_coords;
		float amt = 0.4;
		newCoord.x = newCoord.x - (amt/2) + (fract(sin(dot(vec2(texture_coords.y, time), vec2(12.9898,78.233))) * 43758.5453) * amt/2);
		vec4 pixel = Texel(texture, newCoord ); //This is the current pixel color
		return pixel * color;
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

local displaywords = false

local stack_box, stack_font
local initialwindoposition

function scene.load()
  repeat_timers = {}
  key_down = {}
  selector_open = false

  stack_box = {x = 0, y = 0, scale = 0, units = {}, enabled = false}
  stack_font = love.graphics.newFont(12)
  stack_font:setFilter("nearest","nearest")

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

  if level_name then
    presence["details"] = "playing level: "..level_name
  end

  mouse_grabbed = false
  love.mouse.setGrabbed(false)
end

function scene.update(dt)
  mouse_X = love.mouse.getX()
  mouse_Y = love.mouse.getY()

  updateMousePosition()

  --mouse_movedX = love.mouse.getX() - love.graphics.getWidth()*0.5
  --mouse_movedY = love.mouse.getY() - love.graphics.getHeight()*0.5

  sound_volume = {}

  scene.checkInput()
  updateCursors()

  mouse_oldX = mouse_X
  mouse_oldY = mouse_Y

  xwxShader:send("time", dt) -- send delta time to the shader

  --TODO: PERFORMANCE: If many things are producing particles, it's laggy as heck.
  scene.doPassiveParticles(dt, ":)", "bonus", 0.25, 1, 1, {2, 4})
  scene.doPassiveParticles(dt, ":o", "bonus", 0.5, 0.8, 1, {4, 1})
  scene.doPassiveParticles(dt, "qt", "love", 0.25, 0.5, 1, {4, 2})
  scene.doPassiveParticles(dt, "try again", "bonus", 0.25, 0.25, 1, {3, 3})
  scene.doPassiveParticles(dt, "no undo", "bonus", 0.25, 0.25, 1, {5, 3})
  scene.doPassiveParticles(dt, "undo", "bonus", 0.25, 0.25, 1, {6, 1})
  scene.doPassiveParticles(dt, "brite", "bonus", 0.25, 0.25, 1, {2, 4})

  debugDisplay('window dir', window_dir)
  if shake_dur > 0 then
    shake_dur = shake_dur-dt
    --shake_intensity = shake_intensity-dt/2

    --[[local windowx, windowy = love.window.getPosition()
    if shake_intensity > 0.6 and not fullscreen and frame%2 == 1 then
      love.window.setPosition(windowx+(math.random(0.00, 20.00)*shake_intensity*2)-shake_intensity*20.0,
                              windowy+(math.random(0.00, 20.00)*shake_intensity*2)-shake_intensity*20.0)
    end]]
  else
    shake_intensity = 0
    shake_dur = 0
  end
end

function scene.resetStuff()
  timeless = false
  clear()
  if not is_mobile then
    love.mouse.setCursor(empty_cursor)
  end
  --love.mouse.setGrabbed(true)
  --resetMusic("bab be u them", 0.5)
  resetMusic(map_music, 0.5)
  loadMap()
  clearRules()
  parseRules()
  calculateLight()
  updateUnits(true)
  updatePortals()
  next_levels, next_level_objs = getNextLevels()

  first_turn = false
  window_dir = 0
end

function scene.mouseMoved(x, y, dx, dy, istouch)
  if not just_released_mouse then
    moveMouse(x, y, dx, dy)
    if not just_released_mouse then
      --print("grabby grabby")
      grabMouse(true)
    end
  end
end

function scene.focus(f)
  if not f then grabMouse(false) end
end

function scene.mouseFocus(f)
  --print("focus changed! " .. tostring(f))
  grabMouse(f)
end

function scene.keyPressed(key, isrepeat)
  if isrepeat then
    return
  end

  last_input_time = love.timer.getTime();

  if key == "escape" then
    new_scene = loadscene
  end

  local do_turn_now = false

  --TODO: PERFORMANCE: Some ways to cut down on input latency:
  --1) If we see a second input before the 30ms is up, then we know the input and we can instantly get rid of the 30ms delay.
  --2) If we know what the next move is (either it was an orthogonal move and we can see the 30ms delay already elapsed, or we just got our 2nd input for the move) we can do checkInput() from THIS function instead of waiting for love2d to call update().
  --3) Instead of having this 30ms delay, we could assume it's an orthogonal move, process the next turn as though it was, and then if before the 30ms delay we discover that it was actually a diagonal input, we can undo the orthogonal input and process the next turn with the diagonal input. (But this will behave badly with CRASH/RESET/PERSIST (since those aren't invariant over undo/redo), so we'd have to make sure it works with those features. And you'll also be able to see and hear the ghosts of unintended orthogonal moves for the 0-30ms before they get corrected, like a GGPO netcode game, which might be unsettling.)
  if key == "w" or key == "a" or key == "s" or key == "d" then
    if not repeat_timers["wasd"] or repeat_timers["wasd"] > 30 then
      repeat_timers["wasd"] = 30
    elseif repeat_timers["wasd"] <= 30 then
      do_turn_now = true
      repeat_timers["wasd"] = 0
    end
  elseif key == "up" or key == "down" or key == "left" or key == "right" then
    if not repeat_timers["udlr"] or repeat_timers["udlr"] > 30 then
      repeat_timers["udlr"] = 30
    elseif repeat_timers["udlr"] <= 30 then
      do_turn_now = true
      repeat_timers["udlr"] = 0
    end
  elseif key == "i" or key == "j" or key == "k" or key == "l" then
    if not repeat_timers["ijkl"] or repeat_timers["ijkl"] > 30 then
      repeat_timers["ijkl"] = 30
    elseif repeat_timers["ijkl"] <= 30 then
      do_turn_now = true
      repeat_timers["ijkl"] = 0
    end
  elseif key == "kp1" or
  key == "kp2" or
  key == "kp3" or
  key == "kp4" or
  key == "kp5" or
  key == "kp6" or
  key == "kp7" or
  key == "kp8" or
  key == "kp9" then
    if not repeat_timers["udlr"] then
      do_turn_now = true
      repeat_timers["numpad"] = 0
    end
  elseif key == "z" or key == "q" or key == "backspace" or key == "kp0" or key == "o" then
    if not repeat_timers["undo"] then
      do_turn_now = true
      repeat_timers["undo"] = 0
    end
  end

  for _,v in ipairs(repeat_keys) do
    if v == key then
      do_turn_now = true
      repeat_timers[v] = 0
    end
  end

  if key == "r" then
    scene.resetStuff()
  end

  if key == "e" and not win then
    if hasProperty(nil,"za warudo") then
      --[[
      level_shader = shader_zawarudo
      shader_time = 0
      doin_the_world = true
      ]]
      newUndo()
      timeless = not timeless
      if not timeless then
        parseRules()
        doMovement(0,0,"e")
      end
      addUndo({"za warudo"})
    else
      timeless = false
    end
  end

  if key == "tab" then
    displaywords = true
  end

  most_recent_key = key
  key_down[key] = true

  if (do_turn_now) then
    scene.checkInput()
  end
end

--TODO: Releasing a key could signal to instantly run input under certain circumstances.
--UPDATE: I tested it and it didn't help (the keyReleased function never got called before the 30ms elapsed). I have no idea why.
function scene.keyReleased(key)
  for _,v in ipairs(repeat_keys) do
    if v == key then
      repeat_timers[v] = nil
    end
  end

  if key == "tab" then
    displaywords = false
  end

  if key == "z" or key == "q" or key == "backspace" or key == "kp0" or key == "o" then
    UNDO_DELAY = MAX_UNDO_DELAY
  end

  --[[local do_turn_now = false

  print(key)
  if key == "w" or key == "s" and not key_down["a"] and not key_down["d"] then
    print(repeat_timers["wasd"])
    if repeat_timers["wasd"] <= 30 then
      do_turn_now = true
      repeat_timers["wasd"] = 0
    end
  elseif key == "a" or key == "d" and not key_down["w"] and not key_down["s"] then
    if repeat_timers["wasd"] <= 30 then
      do_turn_now = true
      repeat_timers["wasd"] = 0
    end
  elseif key == "up" or key == "down" and not key_down["left"] and not key_down["right"] then
    if repeat_timers["udlr"] <= 30 then
      do_turn_now = true
      repeat_timers["udlr"] = 0
    end
  elseif key == "left" or key == "right" and not key_down["up"] and not key_down["down"] then
    if repeat_timers["udlr"] <= 30 then
      do_turn_now = true
      repeat_timers["udlr"] = 0
    end
  end

  if (do_turn_now) then
    print("asdf")
    scene.checkInput()
  end]]--

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

  if shake_dur > 0 then
    local range = 1
    transform:translate(math.random(-range, range), math.random(-range, range))
  end

  return transform
end

--TODO: PERFORMANCE: Calling hasProperty once per frame means that we have to index rules, check conditions, etc. with O(m*n) performance penalty. But, the results of these calls do not change until a new turn or undo. So, we can cache the values of these calls in a global table and dump the table whenever the turn changes for a nice and easy performance boost.
--(Though this might not be true for mice, which can change their position mid-frame?? Also for other meta stuff (like windo)? Until there's mouse conditional rules or meta stuff in a puzzle IDK how this should actually work or be displayed. Just keep that in mind tho.)
function scene.draw(dt)
  local draw_empty = rules_with["no1"] ~= nil
  local start_time = love.timer.getTime();
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
  if rainbowmode then bg_color = {hslToRgb(love.timer.getTime()/6%1, .2, .2, .9), 1} end

  love.graphics.setColor(bg_color[1], bg_color[2], bg_color[3], bg_color[4])

  -- fill the background with the background color
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

  local roomwidth = mapwidth * TILE_SIZE
  local roomheight = mapheight * TILE_SIZE

  love.graphics.push()
  love.graphics.applyTransform(scene.getTransform())

  love.graphics.setColor(getPaletteColor(0,3))
  love.graphics.printf(next_level_name, 0, -14, roomwidth)

  local lvl_color = {getPaletteColor(0, 4)}
  if rainbowmode then lvl_color = {hslToRgb(love.timer.getTime()/6%1, .1, .1, .9), 1} end

  love.graphics.setColor(lvl_color[1], lvl_color[2], lvl_color[3], lvl_color[4])
  if (not level_destroyed) then
    love.graphics.rectangle("fill", 0, 0, roomwidth, roomheight)
  end

  local function drawUnit(unit, drawx, drawy, rotation, loop)
    if unit.name == "no1" and not (draw_empty and validEmpty(unit)) then return end

    local brightness = 1
    if ((unit.type == "text") or hasRule(unit,"be","wurd")) and not unit.active then
      brightness = 0.33
    end

    if (unit.name == "steev") and not hasRule("steev","be","u") then
      brightness = 0.33
    end
    
    if timeless and not hasProperty(unit,"za warudo") and not (unit.type == text) then
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
    if unit.fullname == "text_katany" then
      if hasRule("steev","got","katany") then
        unit.sprite = "text_katanya"
      else
        unit.sprite = "text_katany"
      end
    end

    if unit.colrful or rainbowmode then
      -- print("unit " .. unit.name .. " is colourful or rainbowmode")
      local newcolor = hslToRgb((love.timer.getTime()/15+#undo_buffer/45+unit.x/18+unit.y/18)%1, .5, .5, 1)
      newcolor[1] = newcolor[1]*255
      newcolor[2] = newcolor[2]*255
      newcolor[3] = newcolor[3]*255
      unit.color = newcolor
    elseif unit.rave then
      -- print("unit " .. unit.name .. " is rave")
      local newcolor = hslToRgb((love.timer.getTime()/1000+#undo_buffer/45+unit.x/18+unit.y/18)%1, .5, .5, 1)
      newcolor[1] = newcolor[1]*255
      newcolor[2] = newcolor[2]*255
      newcolor[3] = newcolor[3]*255
    elseif (unit.reed and unit.bleu) or (unit.purp) then
      -- print("unit " .. unit.name .. " is red & blue, or purple")
      unit.color = {3, 1}
    elseif unit.reed then
      -- print("unit " .. unit.name .. " is red")
      unit.color = {2, 2}
    elseif unit.bleu then
      -- print("unit " .. unit.name .. " is blue")
      unit.color = {1, 3}
    elseif unit.grun then
      -- print("unit " .. unit.name .. " is green")
      unit.color = {5, 2}
    elseif (unit.reed and unit.grun) or unit.yello then
      -- print("unit " .. unit.name .. " is red & green, or yellow")
      unit.color = {2, 4}
    elseif unit.orang then
      -- print("unit " .. unit.name .. " is orange")
      unit.color = {2, 3}
    elseif (unit.bleu and unit.grun) or  unit.cyeann then
      -- print("unit " .. unit.name .. " is blue & green, or cyan")
      unit.color = {1, 4}
    elseif (unit.reed and unit.grun and unit.bleu) or unit.whit then
      -- print("unit " .. unit.name .. " is red & green & blue, or white")
      unit.color = {0, 3}
    elseif unit.blacc then
      -- print("unit " .. unit.name .. " is black")
      unit.color = {0, 4}
    else
      if unit.color_override ~= nil then
        unit.color = unit.color_override
      else
        unit.color = copyTable(tiles_list[unit.tile].color)
      end
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

    --no tweening empty for now - it's buggy!
    --TODO: it's still a little buggy if you push/pull empties.
    if (unit.name == "no1") then
      --drawx = unit.x
      --drawy = unit.y
      --rotation = math.rad((unit.dir - 1) * 45)
      unit.draw.scalex = 1
      unit.draw.scaley = 1
    end

		local function setColor(color)
			if #color == 3 then
				color = {color[1]/255, color[2]/255, color[3]/255, 1}
			else
				color = {getPaletteColor(color[1], color[2])}
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
			return color
		end
		
		local color = setColor(unit.color)

    local fulldrawx = (drawx + 0.5)*TILE_SIZE
    local fulldrawy = (drawy + 0.5)*TILE_SIZE

    if graphical_property_cache["flye"][unit] ~= nil or unit.name == "o" then
      local flyenes = graphical_property_cache["flye"][unit] or 0
      if unit.name == "o" then flyenes = flyenes + 1 end
      fulldrawy = fulldrawy - math.sin(love.timer.getTime())*5*flyenes
    end

    if shake_dur > 0 then
      local range = 0.5
      fulldrawx = fulldrawx + math.random(-range, range)
      fulldrawy = fulldrawy + math.random(-range, range)
      --fulldrawx = fulldrawx + (math.random(0.00, TILE_SIZE)*shake_intensity*2)-shake_intensity*TILE_SIZE
      --fulldrawy = fulldrawy + (math.random(0.00, TILE_SIZE)*shake_intensity*2)-shake_intensity*TILE_SIZE
    end

    love.graphics.push()
    love.graphics.translate(fulldrawx, fulldrawy)

    love.graphics.push()
    love.graphics.rotate(math.rad(rotation))
    love.graphics.translate(-fulldrawx, -fulldrawy)

    local function drawSprite(overlay)
      local sprite = overlay or sprite
      love.graphics.draw(sprite, fulldrawx, fulldrawy, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
			if (unit.meta ~= nil) then
				setColor({4, 1})
				local metasprite = unit.meta == 2 and sprites["meta2"] or sprites["meta1"]
				love.graphics.draw(metasprite, fulldrawx, fulldrawy, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
				if unit.meta > 2 then
					love.graphics.printf(tostring(unit.meta), fulldrawx-1, fulldrawy+6, 32, "center")
				end
				setColor(unit.color)
			end
    end

    if not unit.xwx then -- xwx takes control of the drawing sprite, so it shouldn't render the normal object
      drawSprite()
    end

    if unit.xwx then -- if we're xwx, apply the special shader to our object
      if math.floor(love.timer.getTime() * 9) % 9 == 0 then
        love.graphics.setShader(xwxShader)
        drawSprite()
        love.graphics.setShader()
      else
        drawSprite()
      end
    end

    if #unit.overlay > 0 then
      local function overlayStencil()
         love.graphics.setShader(mask_shader)
         drawSprite()
         love.graphics.setShader()
      end
      for _,overlay in ipairs(unit.overlay) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.stencil(overlayStencil, "replace")
        local old_test_mode, old_test_value = love.graphics.getStencilTest()
        love.graphics.setStencilTest("greater", 0)
        love.graphics.setBlendMode("multiply", "premultiplied")
        drawSprite(sprites["overlay/" .. overlay])
        love.graphics.setBlendMode("alpha", "alphamultiply")
        love.graphics.setStencilTest(old_test_mode, old_test_value)
      end
    end

    if unit.is_portal then
      if loop or not unit.portal.objects then
        love.graphics.setColor(color[1] * 0.75, color[2] * 0.75, color[3] * 0.75, color[4])
        drawSprite(sprites[sprite_name .. "_bg"])
      else
        love.graphics.setColor(lvl_color[1], lvl_color[2], lvl_color[3], lvl_color[4])
        drawSprite(sprites[sprite_name .. "_bg"])
        love.graphics.setColor(1, 1, 1)
        local function holStencil()
          love.graphics.setShader(mask_shader)
          drawSprite(sprites[sprite_name .. "_mask"])
          love.graphics.setShader()
        end
        local function holStencil2()
          love.graphics.rectangle("fill", fulldrawx + 0.5 * TILE_SIZE, fulldrawy - 0.5 * TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end
        love.graphics.stencil(holStencil, "replace", 2)
        love.graphics.stencil(holStencil2, "replace", 1, true)

        for _,peek in ipairs(unit.portal.objects) do
          if not portaling[peek] then
            love.graphics.setStencilTest("greater", 1)
          else
            love.graphics.setStencilTest("greater", 0)
          end

          love.graphics.push()
          love.graphics.translate(fulldrawx, fulldrawy)
          love.graphics.rotate(-math.rad(rotation))
          if portaling[peek] ~= unit then
            love.graphics.rotate(math.rad(unit.portal.dir * 45))
          end
          love.graphics.translate(-fulldrawx, -fulldrawy)

          local x, y, rot = unit.draw.x, unit.draw.y, 0
          if peek.name ~= "no1" then
            if portaling[peek] ~= unit then
              x, y = (peek.draw.x - peek.x) + (peek.x - unit.portal.x) + x, (peek.draw.y - peek.y) + (peek.y - unit.portal.y) + y
              if peek.rotate then rot = peek.draw.rotation
              else rot = -unit.portal.dir * 45 end
            else
              x, y = peek.draw.x, peek.draw.y
              rot = peek.draw.rotation
            end
          else
            if peek.rotate then rot = (peek.dir - 1 + unit.portal.dir) * 45
            else rot = -unit.portal.dir * 45 end
          end
          if portaling[peek] == unit and peek.draw.x == peek.x and peek.draw.y == peek.y then
            portaling[peek] = nil
          else
            drawUnit(peek, x, y, rot, true)
          end

          love.graphics.pop()
        end

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
    if hasRule(unit,"got","katany") then
      love.graphics.setColor(0.45, 0.45, 0.45)
      love.graphics.draw(sprites["katanysmol"], fulldrawx, fulldrawy, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
    end
    if hasRule(unit,"got","slippers") then
      love.graphics.setColor(getPaletteColor(1,4))
      love.graphics.draw(sprites["slippers"], fulldrawx, fulldrawy+sprite:getHeight()/4, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
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

    if hasProperty(unit,"loop") then
      love.graphics.setColor(1,1,1,.4)
      love.graphics.rectangle("fill",fulldrawx-16,fulldrawy-16,32,32)
    end
  end

  for i=1,max_layer do
    if units_by_layer[i] then
      local removed_units = {}
      for _,unit in ipairs(units_by_layer[i]) do
        if not unit.stelth and not portaling[unit] then
          local x, y, rot = unit.x, unit.y, 0
          if unit.name ~= "no1" then
            x, y = unit.draw.x, unit.draw.y
            if unit.rotate then rot = unit.draw.rotation end
          else
            if unit.rotate then rot = (unit.dir - 1) * 45 end
          end
          drawUnit(unit, x, y, rot)
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
  if stack_box.scale > 0 then
    love.graphics.push()
    love.graphics.translate((stack_box.x + 0.5) * TILE_SIZE, stack_box.y * TILE_SIZE)
    love.graphics.scale(stack_box.scale)

    love.graphics.setColor(getPaletteColor(0, 4))
    love.graphics.polygon("fill", -4, -8, 0, 0, 4, -8)

    local units = stack_box.units
    local draw_units = {}
    local already_added = {}
    for _,unit in ipairs(units) do
      if not already_added[unit.sprite] then already_added[unit.sprite] = {} end
      local dir = unit.dir
      if not unit.rotate then dir = 1 end -- dont separate non-rotatable objects with different dirs
      if not already_added[unit.sprite][dir] then
        table.insert(draw_units, {unit = unit, dir = dir, count = 1})
        already_added[unit.sprite][dir] = #draw_units
      else
        draw_units[already_added[unit.sprite][dir]].count = draw_units[already_added[unit.sprite][dir]].count + 1
      end
    end

    local width = (40 + 4) * #draw_units - 4
    love.graphics.rectangle("fill", -width / 2, -48, width, 40)

    love.graphics.setColor(getPaletteColor(3, 3))
    love.graphics.setLineWidth(2)
    love.graphics.line(-width / 2, -48, -width / 2, -8, -4, -8, 0, 0, 4, -8, width / 2, -8, width / 2, -48, -width / 2, -48)

    for i,draw in ipairs(draw_units) do
      local cx = (-width / 2) + ((i / #draw_units) * width) - 20

      love.graphics.push()
      love.graphics.translate(cx, -28)

      love.graphics.push()
      love.graphics.rotate(math.rad((draw.dir - 1) * 45))

      if #draw.unit.color == 2 then
        love.graphics.setColor(getPaletteColor(draw.unit.color[1], draw.unit.color[2]))
      else
        love.graphics.setColor(draw.unit.color[1], draw.unit.color[2], draw.unit.color[3], draw.unit.color[4] or 1)
      end

      local sprite = sprites[draw.unit.sprite]
      love.graphics.draw(sprite, 0, 0, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
      love.graphics.pop()

      if draw.count > 1 then
        love.graphics.setFont(stack_font)
        love.graphics.setColor(getPaletteColor(0, 4))
        for x = -1, 1 do
          for y = -1, 1 do
            if x ~= 0 or y ~= 0 then
              love.graphics.printf(tostring(draw.count), x, 4+y, 32, "center")
            end
          end
        end
        love.graphics.setColor(getPaletteColor(0, 3))
        love.graphics.printf(tostring(draw.count), 0, 4, 32, "center")
      end
      love.graphics.pop()
    end

    love.graphics.pop()
  end
  love.graphics.pop()
  
  if (lightcanvas ~= nil) then
    love.graphics.setColor(0.05, 0.05, 0.05, 1)
    love.graphics.setBlendMode("add", "premultiplied")
    love.graphics.draw(lightcanvas, love.graphics.getWidth()/2-mapwidth*16, love.graphics.getHeight()/2-mapheight*16)
    love.graphics.setBlendMode("alpha")
  end

  love.graphics.push()
  love.graphics.setColor(1, 1, 1)
  love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  love.graphics.scale(win_size, win_size)
  local win_sprite = win_sprite_override and sprites[win_sprite_override] or sprites["ui/u_r_win"]
  local scale = win_sprite_override and 10 or 1
  love.graphics.draw(win_sprite, scale*-win_sprite:getWidth() / 2, scale*-win_sprite:getHeight() / 2, 0, scale, scale)

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

  love.graphics.setCanvas()
  love.graphics.setShader(level_shader)
  --[[
  if doin_the_world then
    level_shader:send("time", shader_time)
    shader_time = shader_time + 1
  end
  ]]
  love.graphics.draw(canv,0,0)
  if shader_time == 600 then
    love.graphics.setShader(paletteshader_0)
    doin_the_world = false
  end

  if is_mobile then
    local screenwidth = love.graphics.getWidth()
    local screenheight = love.graphics.getHeight()

    local arrowsprite = sprites["ui/arrow"]
	local darrowsprite = sprites["ui/darrow"]
    local squaresprite = sprites["ui/square"]
	local undosprite = sprites["ui/undo"]
	local resetsprite = sprites["ui/reset"]

	love.graphics.draw(arrowsprite, screenwidth-arrowsprite:getWidth()*2, screenheight-arrowsprite:getHeight()*3)
	love.graphics.draw(arrowsprite, screenwidth, screenheight-arrowsprite:getHeight()*2, 3.14/2)
    love.graphics.draw(arrowsprite, screenwidth-arrowsprite:getWidth(), screenheight, 3.14)
    love.graphics.draw(arrowsprite, screenwidth-arrowsprite:getWidth()*3, screenheight-arrowsprite:getHeight(), 3.14*1.5)

	love.graphics.draw(darrowsprite, screenwidth-darrowsprite:getWidth(), screenheight-darrowsprite:getHeight()*3)
	love.graphics.draw(darrowsprite, screenwidth, screenheight-darrowsprite:getHeight(), 3.14/2)
	love.graphics.draw(darrowsprite, screenwidth-darrowsprite:getWidth()*2, screenheight, 3.14)
	love.graphics.draw(darrowsprite, screenwidth-darrowsprite:getWidth()*3, screenheight-darrowsprite:getHeight()*2, 3.14*1.5)

    love.graphics.draw(squaresprite, screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight()*2)

	love.graphics.draw(undosprite, undosprite:getWidth(), screenheight-undosprite:getHeight()*2)
	love.graphics.draw(resetsprite, screenwidth-resetsprite:getWidth()*2, resetsprite:getHeight())
  end

  gooi.draw()

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
      elseif hasProperty(cursor,"caiyan") then
        color = {0, 255, 255}
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

      if rainbowmode then love.graphics.setColor(hslToRgb((love.timer.getTime()/6+i*10)%1, .5, .5, .9)) end

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

  if displaywords then
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    local rules = ""

    local rulesnum = 0
    local lines = 0.5

    for i,rule in pairs(full_rules) do
      rules = rules..rule[1][1]..' '..rule[1][2]..' '..rule[1][3]
      rulesnum = rulesnum + 1

      if rulesnum % 4 >= 3 then
        rules = rules..'\n'
        lines = lines + 1
      else
        rules = rules..'   '
      end
    end

	rules = 'da rulz:\n'..rules

    love.graphics.setColor(1,1,1)
    love.graphics.printf(rules, 0, love.graphics.getHeight()/2-love.graphics.getFont():getHeight()*lines, love.graphics.getWidth(), "center")
  end

  if (just_moved) then
    local end_time = love.timer.getTime();
      print("scene.draw() took: "..tostring(round((end_time-start_time)*1000)).."ms")
    just_moved = false;
  end
end

function scene.checkInput()
  local start_time = love.timer.getTime();
  do_move_sound = false

  if not (key_down["w"] or key_down["a"] or key_down["s"] or key_down["d"]) then
    repeat_timers["wasd"] = nil
  end
  if not (key_down["up"] or key_down["down"] or key_down["left"] or key_down["right"]) then
    repeat_timers["udlr"] = nil
  end
  if not (key_down["i"] or key_down["j"] or key_down["k"] or key_down["l"]) then
    repeat_timers["ijkl"] = nil
  end
  if not (key_down["kp1"] or
  key_down["kp2"] or
  key_down["kp3"] or
  key_down["kp4"] or
  key_down["kp5"] or
  key_down["kp6"] or
  key_down["kp7"] or
  key_down["kp8"] or
  key_down["kp9"]) then
    repeat_timers["numpad"] = nil
  end
  if not (key_down["z"] or key_down["q"] or key_down["backspace"] or key_down["kp0"] or key_down["o"]) then
    repeat_timers["undo"] = nil
  end

  for _,key in ipairs(repeat_keys) do
    if not win and repeat_timers[key] ~= nil and repeat_timers[key] <= 0 then
      if key == "undo" then
        just_moved = true
        if (last_input_time ~= nil) then
          print("input latency: "..tostring(round((start_time-last_input_time)*1000)).."ms")
          last_input_time = nil
        end
        local result = undo()
        if result then playSound("undo") else playSound("fail") end
        do_move_sound = false;
        local end_time = love.timer.getTime();
        unsetNewUnits()
        print("undo took: "..tostring(round((end_time-start_time)*1000)).."ms")
      else
        local x, y = 0, 0
        if key == "udlr" then
          if key_down["up"] and most_recent_key ~= "down" then y = y - 1 end
          if key_down["down"] and most_recent_key ~= "up" then y = y + 1 end
          if key_down["left"] and most_recent_key ~= "right" then x = x - 1 end
          if key_down["right"] and most_recent_key ~= "left" then x = x + 1 end
        elseif key == "wasd" then
          if key_down["w"] and most_recent_key ~= "s" then y = y - 1 end
          if key_down["s"] and most_recent_key ~= "w" then y = y + 1 end
          if key_down["a"] and most_recent_key ~= "d" then x = x - 1 end
          if key_down["d"] and most_recent_key ~= "a" then x = x + 1 end
        elseif key == "ijkl" then
          if key_down["i"] and most_recent_key ~= "k" then y = y - 1 end
          if key_down["k"] and most_recent_key ~= "i" then y = y + 1 end
          if key_down["j"] and most_recent_key ~= "l" then x = x - 1 end
          if key_down["l"] and most_recent_key ~= "j" then x = x + 1 end
        elseif key == "numpad" then
          if key_down["kp1"] and most_recent_key ~= "kp9" then x = x + -1; y = y + 1; end
          if key_down["kp2"] and most_recent_key ~= "kp8" then x = x + 0; y = y + 1; end
          if key_down["kp3"] and most_recent_key ~= "kp7" then x = x + 1; y = y + 1; end
          if key_down["kp4"] and most_recent_key ~= "kp6" then x = x + -1; y = y + 0; end
          if key_down["kp6"] and most_recent_key ~= "kp4" then x = x + 1; y = y + 0; end
          if key_down["kp7"] and most_recent_key ~= "kp3" then x = x + -1; y = y + -1; end
          if key_down["kp8"] and most_recent_key ~= "kp2" then x = x + 0; y = y + -1; end
          if key_down["kp9"] and most_recent_key ~= "kp1" then x = x + 1; y = y + -1; end
        end
        x = sign(x); y = sign(y);
        if (last_input_time ~= nil) then
          print("input latency: "..tostring(round((start_time-last_input_time)*1000)).."ms")
          last_input_time = nil
        end
        newUndo()
        last_move = {x, y}
        just_moved = true
        doMovement(x, y, key)
        if #undo_buffer > 0 and #undo_buffer[1] == 0 then
          table.remove(undo_buffer, 1)
        end
        local end_time = love.timer.getTime();
        unsetNewUnits()
        print("gameplay logic took: "..tostring(round((end_time-start_time)*1000)).."ms")
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
    playSound("move")
  end

  if stack_box.enabled then
    local keep = false
    for _,unit in ipairs(stack_box.units) do
      if unit.x == stack_box.x and unit.y == stack_box.y and not unit.removed then
        keep = true
      end
    end
    if not keep then
      scene.setStackBox(-1, -1)
    else
      stack_box.units = getUnitsOnTile(stack_box.x, stack_box.y)
    end
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

  if do_particles and not timeless then
    local matches = matchesRule(nil,"be",word)
    for _,match in ipairs(matches) do
      local unit = match[2]
      local real_count = 0
      for i = 1, count do
        if math.random() < chance then
          real_count = real_count + 1
        end
      end
      if not unit.stelth and particlesRngCheck() then
        addParticles(effect, unit.x, unit.y, color, real_count)
      end
    end
  end
end

--have a probability to produce particles if there are more than 50 emitters, so that performance degradation is capped.
function particlesRngCheck()
  if #particles < 50 then return true end
  return math.random() < math.pow(0.5, (#particles-50)/50)
end

function scene.mouseReleased(x,y,button)
  scene.setStackBox(screenToGameTile(x, y))

  if pointInside(x,y,0,0,sprites["ui/cog"]:getHeight(),sprites["ui/cog"]:getWidth()) then
    --love.keypressed("f2")
    new_scene = editor
    load_mode = "edit"
  end
  if is_mobile then
    local screenwidth = love.graphics.getWidth()
    local screenheight = love.graphics.getHeight()

    local arrowsprite = sprites["ui/arrow"]
    local squaresprite = sprites["ui/square"]

    local key = "0"

    if     pointInside(x, y, screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight()*2, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "space"
	elseif pointInside(x, y, screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight()*3, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "kp8"
	elseif pointInside(x, y, screenwidth-squaresprite:getWidth(),   screenheight-squaresprite:getHeight()*3, squaresprite:getWidth(), squaresprite:getHeight()) then
	  key = "kp9"
    elseif pointInside(x, y, screenwidth-squaresprite:getWidth(),   screenheight-squaresprite:getHeight()*2, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "kp6"
	elseif pointInside(x, y, screenwidth-squaresprite:getWidth(),   screenheight-squaresprite:getHeight(),   squaresprite:getWidth(), squaresprite:getHeight()) then
	  key = "kp3"
	 elseif pointInside(x, y, screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight(),   squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "kp2"
    elseif pointInside(x, y, screenwidth-squaresprite:getWidth()*3, screenheight-squaresprite:getHeight(),   squaresprite:getWidth(), squaresprite:getHeight()) then
	  key = "kp1"
	elseif pointInside(x, y, screenwidth-squaresprite:getWidth()*3, screenheight-squaresprite:getHeight()*2, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "kp4"
    elseif pointInside(x, y, screenwidth-squaresprite:getWidth()*3, screenheight-squaresprite:getHeight()*3, squaresprite:getWidth(), squaresprite:getHeight()) then
	  key = "kp7"
    elseif pointInside(x, y, screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight()*5, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "z"
    elseif pointInside(x, y, screenwidth-squaresprite:getWidth()*2, squaresprite:getHeight(),                squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "r"
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

	if     mouseOverBox(screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight()*2, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "space"
	elseif mouseOverBox(screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight()*3, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "kp8"
	elseif mouseOverBox(screenwidth-squaresprite:getWidth(),   screenheight-squaresprite:getHeight()*3, squaresprite:getWidth(), squaresprite:getHeight()) then
	  key = "kp9"
    elseif mouseOverBox(screenwidth-squaresprite:getWidth(),   screenheight-squaresprite:getHeight()*2, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "kp6"
	elseif mouseOverBox(screenwidth-squaresprite:getWidth(),   screenheight-squaresprite:getHeight(),   squaresprite:getWidth(), squaresprite:getHeight()) then
	  key = "kp3"
	 elseif mouseOverBox(screenwidth-squaresprite:getWidth()*2, screenheight-squaresprite:getHeight(),   squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "kp2"
    elseif mouseOverBox(screenwidth-squaresprite:getWidth()*3, screenheight-squaresprite:getHeight(),   squaresprite:getWidth(), squaresprite:getHeight()) then
	  key = "kp1"
	elseif mouseOverBox(screenwidth-squaresprite:getWidth()*3, screenheight-squaresprite:getHeight()*2, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "kp4"
    elseif mouseOverBox(screenwidth-squaresprite:getWidth()*3, screenheight-squaresprite:getHeight()*3, squaresprite:getWidth(), squaresprite:getHeight()) then
	  key = "kp7"
    elseif mouseOverBox(squaresprite:getWidth(),               screenheight-squaresprite:getHeight()*2, squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "z"
    elseif mouseOverBox(screenwidth-squaresprite:getWidth()*2, squaresprite:getHeight(),                squaresprite:getWidth(), squaresprite:getHeight()) then
      key = "r"
    end

    scene.keyPressed(key)
  end
end

function scene.setStackBox(x, y)
  local units = getUnitsOnTile(x, y)
  for _,unit in ipairs(units) do
    if unit.name ~= "no1" then
      if stack_box.scale == 0 then
        stack_box.enabled = true
        stack_box.units = units
        stack_box.x, stack_box.y = unit.x, unit.y
        addTween(tween.new(0.1, stack_box, {scale = 1}), "stack box")
      elseif stack_box.x ~= unit.x or stack_box.y ~= unit.y then
        addTween(tween.new(0.05, stack_box, {scale = 0}), "stack box", function()
          stack_box.enabled = true
          stack_box.units = units
          stack_box.x, stack_box.y = unit.x, unit.y
          addTween(tween.new(0.1, stack_box, {scale = 1}), "stack box")
        end)
      else
        stack_box.enabled = false
        addTween(tween.new(0.1, stack_box, {scale = 0}), "stack box")
      end
      return
    end
  end
  if stack_box.enabled then
    stack_box.enabled = false
    addTween(tween.new(0.1, stack_box, {scale = 0}), "stack box")
  end
end

return scene
