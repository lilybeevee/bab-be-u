function clear()
  particles = {}
  tiles_by_name = {}
  units = {}
  units_by_id = {}
  units_by_name = {}
  units_by_tile = {}
  units_by_layer = {}
  still_converting = {}
  referenced_objects = {}
  undo_buffer = {}
  update_undo = true
  rainbowmode = false
  max_layer = 1
  max_unit_id = 0
  max_mouse_id = 0
  first_turn = true
  cursor_convert = nil
  cursor_converted = false
  mouse_X = love.mouse.getX()
  mouse_Y = love.mouse.getY()
  mouse_oldX = mouse_X
  mouse_oldY = mouse_Y
  cursors = {}

  if scene == game then
    createMouse_direct(love.mouse.getX(), love.mouse.getY())
  end
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
      if (v.grid[1]+1 < 100) then
        tile_grid_width = math.max(tile_grid_width, v.grid[1]+1)
      end
      if (v.grid[2]+1 < 100) then 
        tile_grid_height = math.max(tile_grid_height, v.grid[2]+1)
      end
      table.insert(add_to_grid, {i, v.grid[1], v.grid[2]})
    end
  end
  for _,v in ipairs(add_to_grid) do
    local gridid = v[2] + v[3] * tile_grid_width
    if (tile_grid[gridid] ~= nil and v[2] >= 0) then
      print("WARNING: "..tostring(v[2])..","..tostring(v[3]).." used by multiple tiles!")
    end
    tile_grid[gridid] = v[1]
  end

  love.mouse.setCursor()
  love.mouse.setGrabbed(false)
end

function loadMap()
  if map_ver == 0 then
    if map == nil then
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
  elseif map_ver == 1 then
    local pos = 1
    for x=0,mapwidth-1 do
      for y=0,mapheight-1 do
        units_by_tile[x + y * mapwidth] = {}
      end
    end
    while pos <= #map do
      local id, x, y, dir
      id, x, y, dir, pos = love.data.unpack(PACK_UNIT_V1, map, pos)
      if inBounds(x, y) then
        createUnit(id, x, y, dir)
      end
    end
  end
end

--TODO: PERFORMANCE: Sometimes we care about how many instances of a rule exist, sometimes we only care if there's one or zero matches and thus can return as soon as we find the first one. Either write two sets of functions for these two use cases or make an 'any' boolean flag to do this.

--[[
  First and third arguments can be:
    unit, string, nil
  Second argument can be:
    string

  Unit argument will check conditions for that unit, and match rules using its name
  Both nil and "?" act as a wildcard, however a nil wildcard will only check units & return the argument as a unit
  Return value changes depending on how many arguments are nil
  Example:
    Rules:
    BAB BE U - FLOG BE =) - ROC BE KEEK - KEEK GOT MEEM

    Units:
    [BAB] [FLOG] [KEEK] [MEEM]

    matchesRule(bab unit,"be","u") => {BAB BE U}
    - Returns the matching "BAB BE U" rule, as it checks the unit's name

    matchesRule("bab","be","?") => {BAB BE U}
    - Same result, as the U property matches the wildcard

    matchesRule(nil,"be","?") => {{BAB BE U, bab unit}, {FLOG BE =), flog unit}}
    - The rule for ROC is not returned because no ROC exists, however the others do

    matchesRule("?","be",nil) => {{ROC BE KEEK, keek unit}}
    - The first two rules are not returned because properties have no matching units

    matchesRule(nil,"?",nil) => {{KEEK GOT MEEM, keek unit, meem unit}}
    - Both KEEK and MEEM units exist and GOT matches the wildcard, so it returns both units in order
  
  Note that the rules returned are full rules, formatted like: {{subject,verb,object,{preconds,postconds}}, {ids}} 
]]
function matchesRule(rule1,rule2,rule3,stopafterone,debugging)
  if (debugging) then
    print("matchesRule arguments:"..tostring(rule1)..","..tostring(rule2)..","..tostring(rule3))
  end
  local nrules = {}
  local fnrules = {}
  local rule_units = {}

  local function getnrule(o,i)
    if type(o) == "table" then
      local name
      local fullname
      if o.class == "unit" then
        name = o.name
        if o.fullname ~= o.name then
          fullname = o.fullname
        end
      elseif o.class == "cursor" then
        name = "mous"
      end
      nrules[i] = name
      if fullname then
        fnrules[i] = fullname
      end
      rule_units[i] = o
    else
      if o ~= "?" then
        nrules[i] = o
      end
    end
  end

  getnrule(rule1,1)
  getnrule(rule2,2)
  getnrule(rule3,3)
  
  if (debugging) then
    for x,y in ipairs(nrules) do
      print("in nrules:"..tostring(x)..","..tostring(y))
    end
  end

  local ret = {}

  local find = 0
  local find_arg = 0
  if (rule1 == nil and rule3 ~= nil) or (rule1 ~= nil and rule3 == nil) then
    find = 1
    if rule1 == nil then
      find_arg = 1
    elseif rule3 == nil then
      find_arg = 3
    end
  elseif rule1 == nil and rule3 == nil then
    find = 2
  end

  local rules_list

  rules_list = rules_with[nrules[1] or nrules[3] or nrules[2]] or {}
  mergeTable(rules_list, rules_with[fnrules[1] or fnrules[3] or fnrules[2]] or {})

  if (debugging) then
    print ("found this many rules:"..tostring(#rules_list))
  end
  if #rules_list > 0 then
    for _,rules in ipairs(rules_list) do
      local rule = rules[1]
      if (debugging) then
        for i=1,3 do
          print("checking this rule,"..tostring(i)..":"..tostring(rule[i]))
        end
      end
      local result = true
      for i=1,3 do
        if nrules[i] ~= nil and nrules[i] ~= rule[i] and (fnrules[i] == nil or (fnrules[i] ~= nil and fnrules[i] ~= rule[i])) then
          if (debugging) then
            print("false due to nrules/fnrules mismatch")
          end
          result = false
        elseif rule_units[i] ~= nil then
          if i == 1 then
            cond = 1
          elseif i == 3 then
            cond = 2
          end
          if cond and not testConds(rule_units[i], rule[4][cond]) then
            if (debugging) then
              print("false due to cond")
            end
            result = false
          end
        end
      end
      if result then
        if (debugging) then
          print("matched: " .. dump(rule) .. " | find: " .. find)
        end
        if find == 0 then
          table.insert(ret, rules)
          if stopafterone then return ret end
        elseif find == 1 then
          for _,unit in ipairs(findUnitsByName(rule[find_arg])) do
            local cond
            if find_arg == 1 then
              cond = 1
            elseif find_arg == 3 then
              cond = 2
            end
            if testConds(unit, rule[4][cond]) then
              table.insert(ret, {rules, unit})
              if stopafterone then return ret end
            end
          end
        elseif find == 2 then
          local found1, found2
          for _,unit1 in ipairs(findUnitsByName(rule[1])) do
            for _,unit2 in ipairs(findUnitsByName(rule[3])) do
              if testConds(unit1, rule[4][1]) and testConds(unit2, rule[4][2]) then
                table.insert(ret, {rules, unit1, unit2})
                if stopafterone then return ret end
              end
            end
          end
        end
      end
    end
  end

  return ret
end

function getUnitsWithEffect(effect)
  local result = {}
  local rules = matchesRule(nil, "be", effect);
  --print ("h:"..tostring(#rules))
  for _,dat in ipairs(rules) do
    local unit = dat[2];
    if not unit.removed then
      table.insert(result, unit)
    end
  end
  return result
end

function getUnitsWithEffectAndCount(effect)
  local result = {}
  local rules = matchesRule(nil, "be", effect);
  --print ("h:"..tostring(#rules))
  for _,dat in ipairs(rules) do
    local unit = dat[2];
    if not unit.removed then
      if result[unit] == nil then
        result[unit] = 0
      end
      result[unit] = result[unit] + 1
    end
  end
  return result
end

function hasRule(rule1,rule2,rule3)
  return #matchesRule(rule1,rule2,rule3, true) > 0
end

function findUnitsByName(name)
  return copyTable(units_by_name[name] or {})
end

function hasProperty(unit,prop)
  --[[local name
  if unit.class == "unit" then
    name = unit.name
  elseif unit.class == "cursor" then
    name = "mous"
  end
  if rules_with[name] then
    for _,v in ipairs(rules_with[name]) do
      local rule = v[1]
      if rule[1] == name and rule[2] == "be" and rule[3] == prop then
        print("par : " .. rule[1] .. " - " .. rule[2] .. " - " .. rule[3])
        return testConds(unit,rule[4][1])
      end
    end
  end
  return false]]
  return hasRule(unit,"be",prop)
end

function countProperty(unit,prop)
  return #matchesRule(unit,"be",prop)
end

function testConds(unit,conds) --cond should be a {cond,{object types}}
  local endresult = true
  for _,cond in ipairs(conds) do
    local condtype = cond[1]
    local params = cond[2]

    local result = true
    local cond_not = false
    if condtype:ends("n't") then
      condtype = condtype:sub(1, -4)
      cond_not = true
    end

    if condtype == "on" then
      for _,param in ipairs(params) do
        local others = getUnitsOnTile(unit.x, unit.y, param, false, unit) --currently, conditions only work up to one layer of nesting, so the noun argument of the condition is assumed to be just a noun
        if #others == 0 then
          result = false
        end
      end
    elseif condtype == "arond" then
      for _,param in ipairs(params) do
        local others = getUnitsOnTile(unit.x-1, unit.y-1, param, false, unit)
        for nx=-1,1 do
          for ny=-1,1 do
            if (nx ~= 0) or (ny ~= 0) then
              mergeTable(others,getUnitsOnTile(unit.x+nx,unit.y+ny,param))
            end
          end
        end
        if #others == 0 then
          result = false
        end
      end
    elseif condtype == "look at" then
      for _,param in ipairs(params) do
        local others = getUnitsOnTile(unit.x + dirs8[unit.dir][1],unit.y + dirs8[unit.dir][2],param)
        if #others == 0 then
          result = false
        end
      end
    elseif condtype == "frenles" then
      local others = getUnitsOnTile(unit.x, unit.y, nil, false, unit)
      if #others > 0 then
        result = false
      end
    else
      print("unknown condtype: " .. condtype)
      result = false
    end

    if cond_not then
      result = not result
    end
    if not result then
      endresult = false
    end
  end
  return endresult
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

function getUnitsOnTile(x,y,name,not_destroyed,exclude)
  if not inBounds(x,y) then
    return {}
  else
    local result = {}
    local tileid = x + y * mapwidth
    for _,unit in ipairs(units_by_tile[tileid]) do
      if unit ~= exclude then
        if not not_destroyed or (not_destroyed and not unit.removed) then
          if not name or (name and nameIs(unit, name)) then
            table.insert(result, unit)
          end
        end
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

function deepCopy(o)
  if type(o) == "table" then
    local new_table = {}
    for k,v in pairs(o) do
      new_table[k] = deepCopy(v)
    end
    return new_table
  else
    return o
  end
end

function lerp(a,b,t) return (1-t)*a + t*b end

function fullDump(o, r)
  if type(o) == 'table' and r ~= 2 then
    local s = '{'
    local first = true
    for k,v in pairs(o) do
      if not first then
        s = s .. ', '
      end
      local nr = nil
      if r then
        nr = 2
      end
      if type(k) ~= 'number' then
        s = s .. k .. ' = ' .. fullDump(v, nr)
      else
        s = s .. fullDump(v, nr)
      end
      first = false
    end
    return s .. '}'
  elseif type(o) == 'string' then
    return '"' .. o .. '"'
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

function addParticles(type,x,y,color,count)
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
    if #color == 2 then
      ps:setColors(getPaletteColor(color[1], color[2]))
    else
      ps:setColors(color[1]/255, color[2]/255, color[3]/255, (color[4] or 255)/255)
    end
    ps:start()
    ps:emit(count or 20)
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
    if #color == 2 then
      ps:setColors(getPaletteColor(color[1], color[2]))
    else
      ps:setColors(color[1]/255, color[2]/255, color[3]/255, (color[4] or 255)/255)
    end
    ps:start()
    ps:emit(count or 10)
    table.insert(particles, ps)
  elseif type == "bonus" then
    --print("sparkle !!")
    local ps = love.graphics.newParticleSystem(sprites["sparkle"])
    local px = (x + 0.5) * TILE_SIZE
    local py = (y + 0.5) * TILE_SIZE
    ps:setPosition(px, py)
    ps:setSpread(0.8)
    ps:setEmissionArea("uniform", TILE_SIZE / 2, TILE_SIZE / 2, 0, true)
    ps:setSizes(0.40, 0.40, 0.40, 0)
    ps:setSpeed(30)
    ps:setLinearDamping(2)
    ps:setParticleLifetime(0.6)
    if #color == 2 then
      ps:setColors(getPaletteColor(color[1], color[2]))
    else
      ps:setColors(color[1]/255, color[2]/255, color[3]/255, (color[4] or 255)/255)
    end
    ps:start()
    ps:emit(count or 10)
    table.insert(particles, ps)
  elseif type == "love" then
    local ps = love.graphics.newParticleSystem(sprites["luv"])
    local px = (x + 0.5) * TILE_SIZE
    local py = (y + 0.5) * TILE_SIZE
    ps:setPosition(px, py)
    ps:setSpread(0)
    ps:setEmissionArea("borderrectangle", TILE_SIZE/3, TILE_SIZE/3, 0, true)
    ps:setSizes(0.5, 0.5, 0.5, 0)
    ps:setSpeed(20)
    ps:setParticleLifetime(1)
    if #color == 2 then
      ps:setColors(getPaletteColor(color[1], color[2]))
    else
      ps:setColors(color[1]/255, color[2]/255, color[3]/255, (color[4] or 255)/255)
    end
    ps:start()
    ps:emit(count or 10)
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

function HSL(h, s, l, a)
	if s<=0 then return l,l,l,a end
	h, s, l = h*6, s, l
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return (r+m),(g+m),(b+m),a
end

function string.starts(str, start)
  return str:sub(1, #start) == start
end

function string.ends(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

function table.has_value(tab, val)
  for index, value in ipairs(tab) do
      if value == val then
          return true
      end
  end

  return false
end

function mergeTable(t, other)
  if other ~= nil then
    for k,v in pairs(other) do
      if type(k) == "number" then
        if not table.has_value(t, v) then
          table.insert(t, v)
        end
      else
        if t[k] ~= nil then
          if type(t[k]) == "table" and type(v) == "table" then
            mergeTable(t[k], v)
          end
        else
          t[k] = v
        end
      end
    end
  end
end

function saveAll()
  love.filesystem.write("Settings.bab", json.encode(settings))
end

function debugDisplay(key, val)
  debug_values[key] = val
end

function keyCount(t)
  local count = 0
  for k,v in pairs(t) do
    count = count + 1
  end
  return count
end

function sign(x)
  if (x > 0) then
    return 1
  elseif (x < 0) then
    return -1
  end
  return 0
end

function sameFloat(a, b)
  return countProperty(a, "flye") == countProperty(b, "flye")
end

function getPaletteColor(x, y, name_)
  local palette = palettes[name_ or current_palette]
  local pixelid = x + y * palette.sprite:getWidth()
  if palette[pixelid] then
    return palette[pixelid][1], palette[pixelid][2], palette[pixelid][3], palette[pixelid][4]
  else
    return 1, 1, 1, 1
  end
end