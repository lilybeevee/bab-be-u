function clear()
  debug_values = {}
  rng_cache = {}
  reset_count = 0
  last_move = nil
  particles = {}
  tiles_by_name = {}
  units = {}
  units_by_id = {}
  units_by_name = {}
  units_by_tile = {}
  units_by_layer = {}
  empties_by_tile = {}
  still_converting = {}
  referenced_objects = {}
  referenced_text = {}
  undo_buffer = {}
  update_undo = true
  max_layer = 1
  max_unit_id = 0
  max_temp_id = 0
  max_mouse_id = 0
  first_turn = true
  cursor_convert = nil
  cursor_converted = false
  mouse_X = love.mouse.getX()
  mouse_Y = love.mouse.getY()
  mouse_oldX = mouse_X
  mouse_oldY = mouse_Y
  cursors = {}
  shake_dur = 0
  shake_intensity = 0.5

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
  initializeEmpties()
end

function initializeEmpties()
  for x=0,mapwidth-1 do
    for y=0,mapheight-1 do
      local tileid = x + y * mapwidth
      empties_by_tile[tileid] = createUnit(tiles_by_name["no1"], x, y,
      (((tileid - 1) % 8) + 1), nil, nil, true)
    end
  end
end

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

  --there are more properties than there are nouns, so we're more likely to miss based on a property not existing than based on a noun not existing
  rules_list = rules_with[nrules[3] or nrules[1] or nrules[2]] or {}
  mergeTable(rules_list, rules_with[fnrules[3] or fnrules[1] or fnrules[2]] or {})

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
        end
      end
      --don't test condition until the rule fully matches
      if result then
        for i=1,3 do
          if rule_units[i] ~= nil then
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

function validEmpty(unit)
  return #units_by_tile[unit.x + unit.y * mapwidth] == 0
end

function findUnitsByName(name)
  if name == "mous" then
    return cursors
  elseif name == "no1" then
    local result = {}
    for _,unit in ipairs(units_by_name["no1"]) do
      if validEmpty(unit) then
        table.insert(result, unit)
      end
    end
    return result
  else
    return units_by_name[name] or {}
  end
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

--to prevent infinite loops where a set of rules/conditions is self referencing
--TODO: If we end up with infinite loops for stuff that isn't pardoxical (should form a closed loop of false -> false or true -> true), then we can try improving it by tracking what conditions we're already testing, and if we re-entrantly test a condition, assume it's (false I guess? real world testing will be required since I'm not sure)
reentrance = 0

function testConds(unit,conds) --cond should be a {condtype,{object types},{cond_units}}
  if reentrance > 10 then
    print("testConds infinite loop!")
    destroyLevel("infloop");
    return false
  end
  reentrance = reentrance + 1
  local endresult = true
  for _,cond in ipairs(conds) do
    local condtype = cond[1]
    local params = cond[2]
    local cond_unit = cond[3][1]

    local result = true
    local cond_not = false
    if condtype:ends("n't") then
      condtype = condtype:sub(1, -4)
      cond_not = true
    end

    local x, y = unit.x, unit.y

    if condtype == "wfren" then
      for _,param in ipairs(params) do
        local others
        if param ~= "mous" then
          others = getUnitsOnTile(x, y, param, false, unit) --currently, conditions only work up to one layer of nesting, so the noun argument of the condition is assumed to be just a noun
        else
          others = getCursorsOnTile(x, y, false, unit)
        end
        if #others == 0 then
          result = false
        end
      end
    elseif condtype == "sit on" then
      --on that checks float. special condition for use with reflexive properties/verbs (GIV and NOU). warning: can cause paradoxes that destroy the level!
      for _,param in ipairs(params) do
        local others
        if param ~= "mous" then
          others = getUnitsOnTile(x, y, param, false, unit) --currently, conditions only work up to one layer of nesting, so the noun argument of the condition is assumed to be just a noun
        else
          others = getCursorsOnTile(x, y, false, unit)
        end
        result = false
        for _,on in ipairs(others) do
          if sameFloat(unit, on) then
            result = true
            break
          end
        end
      end
    elseif condtype == "arond" then
      for _,param in ipairs(params) do
        --Vitellary: Deliberately ignore the tile we're on. This is different from baba.
        local others = {}
        for nx=-1,1 do
          for ny=-1,1 do
            if (nx ~= 0) or (ny ~= 0) then
              mergeTable(others, param ~= "mous" and getUnitsOnTile(unit.x+nx,unit.y+ny,param) or getCursorsOnTile(x+nx, y+ny, false, unit))
            end
          end
        end
        if #others == 0 then
          result = false
        end
      end
    elseif condtype == "seen by" then
      for _,param in ipairs(params) do
        local others = {}
        for nx=-1,1 do
          for ny=-1,1 do
            if (nx ~= 0) or (ny ~= 0) then
              mergeTable(others, param ~= "mous" and getUnitsOnTile(unit.x+nx,unit.y+ny,param) or {})
            end
          end
        end
        result = false
        for _,other in ipairs(others) do
          if other.x+dirs8[other.dir][1] == unit.x and other.y+dirs8[other.dir][2] == unit.y then
            result = true
            break
          end
        end
      end
    elseif condtype == "look at" then
      for _,param in ipairs(params) do
        local others
        if param ~= "mous" then
          others = getUnitsOnTile(x + dirs8[unit.dir][1], y + dirs8[unit.dir][2], param, false, unit) --currently, conditions only work up to one layer of nesting, so the noun argument of the condition is assumed to be just a noun
        else
          others = getCursorsOnTile(x + dirs8[unit.dir][1], y + dirs8[unit.dir][2], false, unit)
        end
        if #others == 0 then
          result = false
        end
      end
    elseif condtype == "sans" then
      for _,param in ipairs(params) do
        local others = findUnitsByName(param)
        if #others > 1 or #others == 1 and others[1] ~= unit then
          result = false
        end
      end
    elseif condtype == "frenles" then
      local others = getUnitsOnTile(unit.x, unit.y, nil, false, unit)
      if #others > 0 then
        result = false
      end
    elseif condtype == "wait" then
      result = last_move ~= nil and last_move[1] == 0 and last_move[2] == 0
    elseif condtype == "mayb" then
      rng = deterministicRng(unit, cond_unit);
      result = (rng*100) < threshold_for_dir[cond_unit.dir];
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
  reentrance = reentrance - 1
  return endresult
end

threshold_for_dir = {50, 0.01, 0.1, 1, 2, 5, 10, 25};

function deterministicRng(unit, cond)
  local key = unit.name..","..tostring(unit.x)..","..tostring(unit.y)..","..tostring(unit.dir)..","..tostring(cond.x)..","..tostring(cond.y)..","..tostring(cond.dir)..","..tostring(#undo_buffer)
  if rng_cache[key] == nil then
     rng_cache[key] = math.random();
  end
  return rng_cache[key]
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
    --If we care about no1 and the tile is empty, find the no1 that's there.
    if (#units_by_tile[tileid] == 0 and (name == "no1" or name == nil) and empties_by_tile[tileid] ~= exclude) then
      table.insert(result, empties_by_tile[tileid]);
    end
    return result
  end
end

function getCursorsOnTile(x, y, not_destroyed, exclude)
  if not inBounds(x, y) then
    return {}
  else
    local result = {}
    for _,cursor in ipairs(cursors) do
      if cursor ~= exclude then
        if not not_destroyed or (not_destroyed and not cursor.removed) then
          if cursor.x == x and cursor.y == y then
            table.insert(result, cursor)
          end
        end
      end
    end
    return result
  end
end

function copyTable(t, l_)
  local l = l_ or 0
  local new_table = {}
  for k,v in pairs(t) do
    if type(v) == "table" and l > 0 then
      new_table[k] = copyTable(v, l - 1)
    else
      new_table[k] = v
    end
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
  if type(o) == 'table' and (not r or r > 0) then
    local s = '{'
    local first = true
    for k,v in pairs(o) do
      if not first then
        s = s .. ', '
      end
      local nr = nil
      if r then
        nr = r - 1
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
    return tilex, tiley
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
    local x, y = screenToGameTile(love.mouse.getX(), love.mouse.getY())
    if inBounds(x, y) then
      return x, y
    end
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

function mouseOverBox(x,y,w,h,t)
  local mousex, mousey = love.mouse.getPosition()
  if t then
    mousex, mousey = t:inverseTransformPoint(mousex, mousey)
  end
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

function clamp(x, min_, max_)
  if x < min_ then
    return min_
  elseif x > max_ then
    return max_
  end
  return x
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
  return (countProperty(a, "flye") == countProperty(b, "flye")) or hasProperty(a, "tall") or hasProperty(b, "tall")
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

function getUIScale()
  local width = love.graphics.getWidth()
  if width < DEFAULT_WIDTH then
    return 1/math.ceil(DEFAULT_WIDTH / width)
  elseif width > DEFAULT_WIDTH then
    return math.floor(width / DEFAULT_WIDTH)
  else
    return 1
  end
end

function clearGooi()
  gooi.closeDialog()
  for k, v in pairs(gooi.components) do
    gooi.removeComponent(gooi.components[k])
  end
end

function getCombinations(t, param_)
  local param = param_ or {}
  local ret = param.ret or {}
  local i = param.i or 1
  if t[i] then
    for _,v in ipairs(t[i]) do
      local current = copyTable(param.current or {})
      table.insert(current, v)
      if t[i+1] then
        getCombinations(t, {i = i+1, current = current, ret = ret})
      else
        table.insert(ret, current)
      end
    end
  end
  if i == 1 then
    return ret
  end
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function filter(xs, p)
  local newxs = {}
  for _,x in ipairs(xs) do
    if p(x) then table.insert(newxs, x) end
  end
  return newxs
end

function getEverythingExcept(except)
  local result = {}

  local ref_list = referenced_objects
  if except:starts("text_") then
    ref_list = referenced_text
  end

  for i,ref in ipairs(ref_list) do
    if ref ~= except then
      table.insert(result, ref)
    end
  end

  return result
end

function renameDir(from, to, cur_)
  local cur = cur_ or ""
  love.filesystem.createDirectory(to .. cur)
  for _,file in ipairs(love.filesystem.getDirectoryItems(from .. cur)) do
    if love.filesystem.getInfo(file, "directory") then
      renameDir(from, to, cur .. "/" .. file)
    else
      love.filesystem.write(to .. cur .. "/" .. file, love.filesystem.read(from .. cur .. "/" .. file))
      love.filesystem.remove(from .. cur .. "/" .. file)
    end
  end
  love.filesystem.remove(from .. cur)
end

function setRainbowModeColor(value, brightness)
  brightness = brightness or 0.5

  if rainbowmode then
    love.graphics.setColor(hslToRgb(value%1, brightness, brightness, .9))
  end
end

function shakeScreen(dur, intensity)
  shake_dur = dur+shake_dur/4
  shake_intensity = shake_intensity + intensity/2

  if shake_intensity > 3 then
    shake_intensity = 3
  end
end

function startTest(name)
  perf_test = {
    name = name,
    time = love.timer.getTime()
  }
end

function endTest()
  local time = love.timer.getTime() - perf_test.time
  print(perf_test.name .. ": " .. time .. "s")
end