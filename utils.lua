function clear()
  particles = {}
  tiles_by_name = {}
  units = {}
  units_by_id = {}
  units_by_name = {}
  units_by_tile = {}
  units_by_layer = {}
  undo_buffer = {}
  rainbowmode = false
  max_layer = 1
  max_unit_id = 0
  max_mouse_id = 0
  first_turn = true
  cursor_convert = nil
  cursor_converted = false
  mouse_X = love.mouse.getX()
  mouse_Y = love.mouse.getY()
  mouse_movedX = 0
  mouse_movedY = 0
  cursors = {}
  createMouse_direct(love.mouse.getX(), love.mouse.getY())
  --createMouse_direct(20, 20)

  win = false
  win_size = 0

  tile_grid = {}
  tile_grid_width = 1
  tile_grid_height = 1

  local add_to_grid = {}
  for i,v in ipairs(tiles_list) do
    tiles_by_name[v.name] = i
    if v.grid then
      tile_grid_width = math.max(tile_grid_width, v.grid[1]+1)
      tile_grid_height = math.max(tile_grid_height, v.grid[2]+1)
      table.insert(add_to_grid, {i, v.grid[1], v.grid[2]})
    end
  end
  for _,v in ipairs(add_to_grid) do
    local gridid = v[2] + v[3] * tile_grid_width
    tile_grid[gridid] = v[1]
  end

  love.mouse.setCursor()
  love.mouse.setGrabbed(false)
end

function loadMap()
  if map == nil then
    print("its nil!")
    map = {}
    for x=1,mapwidth do
      for y=1,mapheight do
        table.insert(map, {})
      end
    end
  end
  for i,v in ipairs(map) do
    local tileid = i-1
    local x = tileid % mapwidth
    local y = math.floor(tileid / mapwidth)
    units_by_tile[tileid] = {}
    for _,id in ipairs(v) do
      local new_unit = createUnit(id, x, y, 1)
    end
  end
end

function hasProperty(unit,prop)
  if rules_with[unit.name] then
    for _,v in ipairs(rules_with[unit.name]) do
      local rule = v[1]
      if rule[1] == unit.name and rule[2] == "be" and rule[3] == prop then
        return true
      end
    end
  end
  return false
end

function inBounds(x,y)
  if not selector_open then
    return x >= 0 and x < mapwidth and y >= 0 and y < mapheight
  else
    return x >=0 and x < tile_grid_width and y >= 0 and y < tile_grid_height
  end
end

function removeFromTable(t, obj)
  if not t then
    return
  end
  for i,v in ipairs(t) do
    if v == obj then
      table.remove(t, i)
      return
    end
  end
end

function rotate(dir)
  return (dir-1 + 2) % 4 + 1
end

function rotate8(dir)
  return (dir-1 + 4) % 8 + 1
end

function nameIs(unit,name)
  return unit.name == name or unit.fullname == name
end

function tileHasUnitName(name,x,y)
  local tileid = x + y * mapwidth
  for _,v in ipairs(units_by_tile[tileid]) do
    if nameIs(v, name) then
      return true
    end
  end
end

function getUnitsOnTile(x,y,name)
  if not inBounds(x,y) then
    return {}
  else
    local result = {}
    local tileid = x + y * mapwidth
    for _,unit in ipairs(units_by_tile[tileid]) do
      if not name or (name and nameIs(unit, name)) then
        table.insert(result, unit)
      end
    end
    return result
  end
end

function copyTable(table)
  local new_table = {}
  for k,v in pairs(table) do
    new_table[k] = v
  end
  return new_table
end

function lerp(a,b,t) return (1-t)*a + t*b end

function fullDump(o)
  if type(o) == 'table' then
     local s = '{ '
     for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump(v) .. ','
     end
     return s .. '} '
  else
     return tostring(o)
  end
end

function dump(o)
  if type(o) == 'table' then
    local s = '{'
    local cn = 1
    if #o ~= 0 then
      for _,v in ipairs(o) do
        if cn > 1 then s = s .. ',' end
        s = s .. dump(v)
        cn = cn + 1
      end
    else
      for k,v in pairs(o) do
        if cn > 1 then s = s .. ',' end
        s = s .. tostring(k) .. ' = ' .. dump(v)
        cn = cn + 1
      end
    end
    return s .. '}'
  elseif type(o) == 'string' then
    return '"' .. o .. '"'
  else
    return tostring(o)
  end
end

function hslToRgb(h, s, l, a)
  local r, g, b

  if s == 0 then
      r, g, b = l, l, l -- achromatic
  else
      function hue2rgb(p, q, t)
          if t < 0   then t = t + 1 end
          if t > 1   then t = t - 1 end
          if t < 1/6 then return p + (q - p) * 6 * t end
          if t < 1/2 then return q end
          if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
          return p
      end

      local q
      if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
      local p = 2 * l - q

      r = hue2rgb(p, q, h + 1/3)
      g = hue2rgb(p, q, h)
      b = hue2rgb(p, q, h - 1/3)
  end

  return {r, g, b} --a removed cus unused
end

function addParticles(type,x,y,color)
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

function screenToGameTile(x,y)
  if scene.getTransform then
    local transform = scene.getTransform()
    local mx,my = transform:inverseTransformPoint(x,y)
    local tilex = math.floor(mx / TILE_SIZE)
    local tiley = math.floor(my / TILE_SIZE)
    if inBounds(tilex, tiley) then
      return tilex, tiley
    end
  end
  return nil,nil
end

function gameTileToScreen(x,y)
  if scene.getTransform then
  	local screenx = (x * TILE_SIZE)
    local screeny = (y * TILE_SIZE)
    local transform = scene.getTransform()
    local mx,my = transform:transformPoint(screenx,screeny)
    return mx, my
  end
  return nil,nil
end

function getHoveredTile()
  if not cursor_converted then
    return screenToGameTile(love.mouse.getX(), love.mouse.getY())
  end
end

function eq(a,b)
  if type(a) == "table" or type(b) == "table" then
    if type(a) ~= "table" or type(b) ~= "table" then
      return false
    end
    local result = true
    if #a == #b then
      for i,v in pairs(a) do
        if v ~= b[i] then
          result = false
          break
        end
      end
    else
      result = false
    end
    return result
  else
    return a == b
  end
end

function mouseOverBox(x,y,w,h)
  mousex, mousey = love.mouse.getPosition()
  return mousex > x and mousex < x+w and mousey > y and mousey < y+h
end