require "values"
require "utils"
require "input"
require "audio"
require "game/unit"
require "game/movement"
require "game/rules"
require "game/undo"

sprites = {}
repeat_timers = {}

move_sound_data = nil
move_sound_source = nil

function clear()
  particles = {}
  tiles_by_name = {}
  units = {}
  units_by_id = {}
  units_by_name = {}
  units_by_tile = {}
  units_by_layer = {}
  undo_buffer = {}
  max_layer = 1
  max_unit_id = 0
  first_turn = true

  win = false
  win_size = 0
  music_fading = false
  if music_volume == 0 or not hasMusic() then
    playMusic("bab_be_u_them", 0.5)
  else
    music_volume = 0.5
  end

  for i,v in ipairs(tiles_list) do
    tiles_by_name[v.name] = i
  end

  for i,v in ipairs(map) do
    local tileid = i-1
    local x = tileid % mapwidth
    local y = math.floor(tileid / mapwidth)
    units_by_tile[tileid] = {}
    for _,id in ipairs(v) do
      local new_unit = createUnit(id, x, y)
      new_unit.scaley = 1
    end
  end

  parseRules()
end

function love.load()
  local files = love.filesystem.getDirectoryItems("assets/sprites")
  for _,file in ipairs(files) do
    if string.sub(file, -4) == ".png" then
      local spritename = string.sub(file, 1, -5)
      local sprite = love.graphics.newImage("assets/sprites/" .. file)
      sprites[spritename] = sprite
    end
  end
  registerSound("move")
  registerSound("break")
  registerSound("unlock")
  registerSound("sink")
  registerSound("rule")
  registerSound("win")

  clear()
end

function love.keypressed(key,scancode,isrepeat)
  for _,v in ipairs(repeat_keys) do
    if v == key then
      repeat_timers[v] = 0
    end
  end

  if key == "r" then
    clear()
  end
end

function love.keyreleased(key)
  for _,v in ipairs(repeat_keys) do
    if v == key then
      repeat_timers[v] = nil
    end
  end

  if key == "z" then
    UNDO_DELAY = MAX_UNDO_DELAY
  end
end

function checkInput()
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

function love.update(dt)
  checkInput()
  updateMusic()
end

function love.draw()
  local dt = love.timer.getDelta()

  love.graphics.setBackgroundColor(0.10, 0.1, 0.11)

  love.graphics.push()
  local roomwidth = mapwidth * TILE_SIZE
  local roomheight = mapheight * TILE_SIZE
  love.graphics.translate(love.graphics.getWidth() / 2 - roomwidth / 2, love.graphics.getHeight() / 2 - roomheight / 2)

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
        
        love.graphics.setColor(unit.color[1]/255 * brightness, unit.color[2]/255 * brightness, unit.color[3]/255 * brightness)
        love.graphics.draw(sprite, (drawx + 0.5)*TILE_SIZE, (drawy + 0.5)*TILE_SIZE, 0, unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
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

function doParticles(type,x,y,color)
  if type == "destroy" then
    local ps = love.graphics.newParticleSystem(sprites["circle"])
    local px = (x + 0.5) * TILE_SIZE
    local py = (y + 0.5) * TILE_SIZE
    ps:setPosition(px, py)
    ps:setSpread(0)
    ps:setEmissionArea("uniform", TILE_SIZE/3, TILE_SIZE/3, 0, true)
    ps:setSizes(0.15, 0.15, 0.15, 0)
    ps:setSpeed(50)
    ps:setLinearDamping(5)
    ps:setParticleLifetime(0.25)
    ps:setColors(color[1]/255, color[2]/255, color[3]/255, (color[4] or 255)/255)
    ps:start()
    ps:emit(20)
    table.insert(particles, ps)
  elseif type == "rule" then
    local ps = love.graphics.newParticleSystem(sprites["circle"])
    local px = (x + 0.5) * TILE_SIZE
    local py = (y + 0.5) * TILE_SIZE
    ps:setPosition(px, py)
    ps:setSpread(0)
    ps:setEmissionArea("borderrectangle", TILE_SIZE/3, TILE_SIZE/3, 0, true)
    ps:setSizes(0.1, 0.1, 0.1, 0)
    ps:setSpeed(50)
    ps:setLinearDamping(4)
    ps:setParticleLifetime(0.25)
    ps:setColors(color[1]/255, color[2]/255, color[3]/255, (color[4] or 255)/255)
    ps:start()
    ps:emit(10)
    table.insert(particles, ps)
  end
end