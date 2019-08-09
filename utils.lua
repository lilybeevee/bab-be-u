function clear()
  letters_exist = false
	replay_playback = false
  replay_playback_turns = nil
	replay_playback_string = nil
	replay_playback_turn = 1
	replay_playback_time = love.timer.getTime()
	replay_playback_interval = 0.3
  old_replay_playback_interval = 0.3
  replay_pause = false
	replay_string = ""
  new_units_cache = {}
  undoing = false
  successful_brite_cache = nil
  next_level_name = ""
  win_sprite_override = nil
  level_destroyed = false
  last_input_time = nil
  most_recent_key = nil
  just_moved = true
  should_parse_rules_at_turn_boundary = false
  should_parse_rules = false
  graphical_property_cache = {}
  initializeGraphicalPropertyCache();
  debug_values = {}
  rng_cache = {}
  reset_count = 0
  last_move = nil
  particles = {}
  units = {}
  units_by_id = {}
  units_by_name = {}
  units_by_tile = {}
  units_by_layer = {}
  backers_cache = {}
  empties_by_tile = {}
  outerlvl = nil
  still_converting = {}
  portaling = {}
  rules_effecting_names = {}
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
  last_click_x = nil
  last_click_y = nil
  mouse_oldX = mouse_X
  mouse_oldY = mouse_Y
  cursors = {}
  shake_dur = 0
  shake_intensity = 0.5
  
  --za warudo needs a lot
  timeless = false
  time_destroy = {}
  time_delfx = {}
  time_sfx = {}
  timeless_splitter = {}
  timeless_splittee = {}
  timeless_win = {}
  timeless_reset = false
  timeless_crash = false
  timeless_yote = {}
  firsttimestop = true

  --if scene == game then
  if load_mode == "play" then
    createMouse_direct(love.mouse.getX(), love.mouse.getY())
  end
  --createMouse_direct(20, 20)

  currently_winning = false
  music_fading = false
  won_this_session = false
  level_ending = false
  win_size = 0

  tile_grid = {}
  
  for i,page in ipairs(selector_grid_contents) do
    tile_grid[i] = {}
    for j,tile_name in ipairs(page) do
      if j and tiles_by_name[tile_name] then
        tile_grid[i][j-1] = tiles_by_name[tile_name]
      else
        tile_grid[i][j-1] = nil
      end
    end
  end

  love.mouse.setCursor()
end

function metaClear()
  parent_filename = nil;
  stay_ther = nil;
  surrounds = nil;
end

function initializeGraphicalPropertyCache()
  local properties_to_init = -- list of properties that require the graphical cache
    {
	  "flye", "slep", "tranz", "gay", "stelth", "colrful", "xwx", "rave", -- miscelleaneous graphical effects
	}
  for i = 1, #properties_to_init do
	local prop = properties_to_init[i]
	if (graphical_property_cache[prop] == nil) then graphical_property_cache[prop] = {} end
  end
end

function loadMap()
  for x=0,mapwidth-1 do
    for y=0,mapheight-1 do
      units_by_tile[x + y * mapwidth] = {}
    end
  end
  for _,mapdata in ipairs(maps) do
    local version = mapdata[1]
    local map = mapdata[2]
    if version == 0 then
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
        for _,id in ipairs(v) do
          local new_unit = createUnit(id, x, y, 1)
        end
      end
    elseif version >= 1 and version <= 3 then
      local pos = 1
      while pos <= #map do
        if version == 1 then
          local tile, x, y, dir
          tile, x, y, dir, pos = love.data.unpack(PACK_UNIT_V1, map, pos)
          if inBounds(x, y) then
            createUnit(tile, x, y, dir)
          end
        elseif version == 2 or version == 3 then
          local id, tile, x, y, dir, specials
          id, tile, x, y, dir, specials, pos = love.data.unpack(version == 2 and PACK_UNIT_V2 or PACK_UNIT_V3, map, pos)
          if inBounds(x, y) then
            local unit = createUnit(tile, x, y, dir, false, id)
            local spos = 1
            while spos <= #specials do
              local k, v
              k, v, spos = love.data.unpack(PACK_SPECIAL_V2, specials, spos)
              unit.special[k] = v
            end
          end
        end
      end
    else
      local ok = nil
      ok, map = serpent.load(map);
      if (ok ~= true) then
        print("Serpent error while loading:", ok, fullDump(map))
      end
      for _,unit in ipairs(map) do
        id, tile, x, y, dir, specials = unit.id, unit.tile, unit.x, unit.y, unit.dir, unit.special
        if inBounds(x, y) then
          local unit = createUnit(tile, x, y, dir, false, id)
          unit.special = specials
        end
      end
    end
  end
  if (load_mode == "play") then
    initializeOuterLvl()
    initializeEmpties()
    loadStayTher()
  end
  unsetNewUnits()
end

function loadStayTher()
  if stay_ther ~= nil then
    for _,unit in ipairs(stay_ther) do
      if inBounds(unit.x, unit.y) then
        local newunit = createUnit(unit.tile, unit.x, unit.y, unit.dir)
        newunit.special = unit.special
      end
    end
  end
end

function initializeOuterLvl()
  outerlvl = createUnit(tiles_by_name["lvl"], -999, -999,
  1, nil, nil, true)
end

function initializeEmpties()
  --TODO: other ways to make a text_no1 could be to have a text_text_no1 but that seems contrived that you'd have text_text_no1 but not text_no1?
  --text_her counts because it looks for no1, I think. similarly we could have text_text_her but again, contrived
  if ((not letters_exist) and (not units_by_name["text_no1"]) and (not units_by_name["text_her"])) then return end
  for x=0,mapwidth-1 do
    for y=0,mapheight-1 do
      local tileid = x + y * mapwidth
      empties_by_tile[tileid] = createUnit(tiles_by_name["no1"], x, y,
      (((tileid - 1) % 8) + 1), nil, nil, true)
    end
  end
end

function compactIds()
  units_by_id = {};
  for i,unit in ipairs(units) do
    unit.id = i;
    units_by_id[i] = unit;
  end
  max_unit_id = #units + 1;
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

function getUnitsWithRuleAndCount(rule1, rule2, rule3)
  local result = {}
  local rules = matchesRule(rule1, rule2, rule3);
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
withrecursion = {}

function testConds(unit,conds) --cond should be a {condtype,{object types},{cond_units}}
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

    local old_withrecursioncond = withrecursion[cond];
    
    withrecursion[cond] = true
    
    if (old_withrecursioncond) then
      result = false
    elseif condtype:starts("that") then
      result = true
      local verb = condtype:sub(6)
      for _,param in ipairs(params) do
        if not hasRule(unit,verb,param) then
          result = false
          break
        end
      end
    elseif condtype == "wfren" then
      for _,param in ipairs(params) do
        local others = {}
        if unit == outerlvl then --basically turns into sansn't
          if param ~= "lvl" then
            others = findUnitsByName(param);
          else
            for __,on in ipairs(findUnitsByName(param)) do
              if on ~= outerlvl then
                table.insert(others, on);
              end
            end
          end
        end
        if unit == outerlvl and surrounds ~= nil and surrounds_name == level_name then
          --use surrounds to remember what was around the level
          for __,on in ipairs(surrounds[0][0]) do
            if nameIs(on, param) then
              table.insert(others, on);
            end
          end
        else
          if param ~= "mous" then
            others = getUnitsOnTile(x, y, param, false, unit) --currently, conditions only work up to one layer of nesting, so the noun argument of the condition is assumed to be just a noun
          else
            others = getCursorsOnTile(x, y, false, unit)
          end
        end
        if #others == 0 then
          result = false
          break
        end
      end
    elseif condtype == "arond" then
      for _,param in ipairs(params) do
        --Vitellary: Deliberately ignore the tile we're on. This is different from baba.
        local others = {}
        for ndir=1,8 do
          local nx, ny = dirs8[ndir][1], dirs8[ndir][2]
          if unit == outerlvl and surrounds ~= nil and surrounds_name == level_name then
            --use surrounds to remember what was around the level
            for __,on in ipairs(surrounds[nx][ny]) do
              if nameIs(on, param) then
                table.insert(others, on);
              end
            end
          else
            local dx, dy, dir, px, py = getNextTile(unit, nx, ny, ndir)
            mergeTable(others, param ~= "mous" and getUnitsOnTile(px,py,param) or getCursorsOnTile(px, py, false, unit))
          end
        end
        if #others == 0 then
          result = false
          break
        end
      end
    elseif condtype == "seen by" then
      if unit == outerlvl then --basically turns into sans n't BUT the unit has to be looking inbounds as well!
        for _,param in ipairs(params) do
          local found = false
          local others = findUnitsByName(param)
          for _,on in ipairs(others) do
            if inBounds(on.x + dirs8[on.dir][1], on.y + dirs8[on.dir][2]) then
              found = true
              break
            end
          end
          if unit == outerlvl and surrounds ~= nil and surrounds_name == level_name then
            --use surrounds to remember what was around the level
            for nx=-1,1 do
              for ny=-1,1 do
                for __,on in ipairs(surrounds[nx][ny]) do
                  if nameIs(on, param) and nx + dirs8[on.dir][1] == 0 and ny + dirs8[on.dir][2] == 0 then
                    found = true
                    break
                  end
                end
              end
            end
          end
          if not found then
            result = false
            break
          end
        end
      else
        for _,param in ipairs(params) do
          local found = false
          local others = {}
          for ndir=1,8 do
            local dx, dy, dir, px, py = getNextTile(unit, dirs8[ndir][1], dirs8[ndir][2], ndir)
            mergeTable(others, param ~= "mous" and getUnitsOnTile(px,py,param) or {})
          end
          for _,other in ipairs(others) do
            local dx, dy, dir, px, py = getNextTile(other, dirs8[other.dir][1], dirs8[other.dir][2], other.dir)
            if px == unit.x and py == unit.y then
              found = true
              break
            else
              print(unit.x, unit.y)
              print(px, py)
            end
          end
          if not found then
            result = false
            break
          end
        end
      end
    elseif condtype == "look at" then
      for _,param in ipairs(params) do
        local isdir = false
        if param == "ortho" then
          isdir = true
          if (unit.dir % 2 == 0) then
            result = false
            break
          end
        elseif param == "diag" then
          isdir = true
          if (unit.dir % 2 == 1) then
            result = false
            break
          end
        else
          for i = 1,8 do
            if param == dirs8_by_name[i] then
              isdir = true
              if (unit.dir ~= i) then
                result = false
                break
              end
            end
          end
        end
        if (not isdir) then
          local others
          if unit == outerlvl and surrounds ~= nil and surrounds_name == level_name then
            others = {}
            --use surrounds to remember what was around the level
            for __,on in ipairs(surrounds[dirs8[unit.dir][1]][dirs8[unit.dir][2]]) do
              if nameIs(on, param) then
                table.insert(others, on);
              end
            end
          else
            local dx, dy, dir, px, py = getNextTile(unit, dirs8[unit.dir][1], dirs8[unit.dir][2], unit.dir)
            if param == "lvl" then
              --if we're looking in-bounds, then we're looking at a level technically!
              result = inBounds(px, py)
            elseif param ~= "mous" then
              others = getUnitsOnTile(px, py, param, false, unit) --currently, conditions only work up to one layer of nesting, so the noun argument of the condition is assumed to be just a noun
            else
              others = getCursorsOnTile(px, py, false, unit)
            end
          end
          if others ~= nil and #others == 0 then
            result = false
            break
          end
        end
      end
    elseif condtype == "look away" then
      for _,param in ipairs(params) do
        local isdir = false
        if param == "ortho" then
          isdir = true
          if (unit.dir % 2 == 0) then
            result = false
            break
          end
        elseif param == "diag" then
          isdir = true
          if (unit.dir % 2 == 1) then
            result = false
            break
          end
        else
          for i = 1,8 do
            if param == dirs8_by_name[i] then
              isdir = true
              if (unit.dir ~= i) then
                result = false
                break
              end
            end
          end
        end
        if (not isdir) then
          local others
          if unit == outerlvl and surrounds ~= nil and surrounds_name == level_name then
            others = {}
            --use surrounds to remember what was around the level
            for __,on in ipairs(surrounds[dirs8[unit.dir][1]][dirs8[unit.dir][2]]) do
              if nameIs(on, param) then
                table.insert(others, on);
              end
            end
          else
            local dx, dy, dir, px, py = getNextTile(unit, -dirs8[unit.dir][1], -dirs8[unit.dir][2], unit.dir)
            if param == "lvl" then
              --if we're looking in-bounds, then we're looking at a level technically!
              result = not inBounds(px, py)
            elseif param ~= "mous" then
              others = getUnitsOnTile(px, py, param, false, unit) --currently, conditions only work up to one layer of nesting, so the noun argument of the condition is assumed to be just a noun
            else
              others = getCursorsOnTile(px, py, false, unit)
            end
          end
          if others ~= nil and #others == 0 then
            result = false
            break
          end
        end
      end
    elseif condtype == "behind" then
        if unit == outerlvl then -- SANS n't but not when the unit is looking directly away from the border
            for _,param in ipairs(params) do
              local found = false
              local others = findUnitsByName(param)
              for _,on in ipairs(others) do
                if inBounds(on.x - dirs8[on.dir][1], on.y - dirs8[on.dir][2]) then
                  found = true
                  break
                end
              end
              if unit == outerlvl and surrounds ~= nil and surrounds_name == level_name then
                for nx=-1,1 do
                  for ny=-1,1 do
                    for __,on in ipairs(surrounds[nx][ny]) do
                      if not nameIs(on, param) and nx + dirs8[on.dir][1] == 0 and ny + dirs8[on.dir][2] == 0 then
                        found = true
                        break
                      end
                    end
                  end
                end
              end
              if not found then
                result = false
                break
              end
            end
        else
            for _,param in ipairs(params) do
              local found = false
              local others = {}
              for ndir=1,8 do
                local dx, dy, dir, px, py = getNextTile(unit, dirs8[ndir][1], dirs8[ndir][2], ndir)
                mergeTable(others, param ~= "mous" and getUnitsOnTile(px,py,param) or {})
              end
              for _,other in ipairs(others) do
                local dx, dy, dir, px, py = getNextTile(other, -dirs8[other.dir][1], -dirs8[other.dir][2], other.dir)
                if px == unit.x and py == unit.y then
                  found = true
                  break
                else
                  print(unit.x, unit.y)
                  print(px, py)
                end
              end
              if not found then
                result = false
                break
              end
            end
        end
    elseif condtype == "beside" then
        if unit == outerlvl then -- literally just SANS n't except when the unit is at the corner of the level and facing in/out
            for _,param in ipairs(params) do
              local found = false
              local others = findUnitsByName(param)
              for _,on in ipairs(others) do
                if inBounds(on.x - dirs8[on.dir][2], on.y + dirs8[on.dir][1]) or inBounds(on.x + dirs8[on.dir][2], on.y - dirs8[on.dir][1])then
                  found = true
                  break
                end
              end
              if unit == outerlvl and surrounds ~= nil and surrounds_name == level_name then
                for nx=-1,1 do
                  for ny=-1,1 do
                    for __,on in ipairs(surrounds[nx][ny]) do
                      if nameIs(on, param) and nx + dirs8[on.dir][1] == 0 and ny + dirs8[on.dir][2] == 0 then
                        found = true
                        break
                      end
                    end
                  end
                end
              end
              if not found then
                result = false
                break
              end
            end
        else
            for _,param in ipairs(params) do
              local found = false
              local others = {}
              for ndir=1,8 do
                local dx, dy, dir, px, py = getNextTile(unit, dirs8[ndir][1], dirs8[ndir][2], ndir)
                mergeTable(others, param ~= "mous" and getUnitsOnTile(px,py,param) or {})
              end
              for _,other in ipairs(others) do
                local dx, dy, dir, px, py = getNextTile(other, dirs8[other.dir][2], -dirs8[other.dir][1], other.dir)
                local dx, dy, dir, qx, qy = getNextTile(other, -dirs8[other.dir][2], dirs8[other.dir][1], other.dir)
                if px == unit.x and py == unit.y or qx == unit.x and qy == unit.y then
                  found = true
                  break
                else
                  print(unit.x, unit.y)
                  print(px, py)
                end
              end
              if not found then
                result = false
                break
              end
            end
        end
    elseif condtype == "sans" then
      for _,param in ipairs(params) do
        local others = findUnitsByName(param)
        if #others > 1 or #others == 1 and others[1] ~= unit then
          result = false
        end
      end
    elseif condtype == "samefloat" then
      for _,param in ipairs(params) do
        local others = findUnitsByName(param)
        local yes = false
        for _,other in ipairs(others) do
          if sameFloat(unit,other) then
            yes = true
          end
        end
        if not yes then result = false end
      end
    elseif condtype == "frenles" then
      if unit == outerlvl then
        result = false --kind of by definition, since the text to make the rule exists :p
      else
        local others = getUnitsOnTile(unit.x, unit.y, nil, false, unit)
        if #others > 0 then
          result = false
        end
      end
    elseif condtype == "wait" then
      result = last_move ~= nil and last_move[1] == 0 and last_move[2] == 0 and last_click_x == nil and last_click_y == nil
    elseif condtype == "mayb" then
      --add a dummy action so that undoing happens
      if (#undo_buffer > 0 and #undo_buffer[1] == 0) then
        addUndo({"dummy"});
      end
      rng = deterministicRng(unit, cond_unit);
      result = (rng*100) < threshold_for_dir[cond_unit.dir];
    elseif condtype == "an" then
      --add a dummy action so that undoing happens
      if (#undo_buffer > 0 and #undo_buffer[1] == 0) then
        addUndo({"dummy"});
      end
      rng = deterministicRandom(unit.fullname, cond_unit);
      result = unit.id == rng;
    elseif condtype == "lit" then
      --TODO: make it so if there are many lit objects then you cache FoV instead of doing many individual LoSes
      -- result = false
      -- if (successful_brite_cache ~= nil) then
      --   local cached = units_by_id[successful_brite_cache];
      --   if cached ~= nil and hasProperty(cached, "brite") and hasLineOfSight(cached, unit) then
      --     result = true
      --   end
      -- end
      -- if not result then
      --   --I am tempted to make it so N levels of BRITE can penetrate N-1 layers of OPAQUE but this mechanic would be too... opaque :drum:
      --   local others = getUnitsWithEffect("brite")
      --   for _,on in ipairs(others) do
      --     if hasLineOfSight(on, unit) then
      --       successful_brite_cache = on.id;
      --       result = true
      --       break
      --     end
      --   end
      -- end
      if (lightcanvas == nil) then calculateLight() end
      local pixelData = lightcanvas:newImageData(1, 1, unit.x*32+15, unit.y*32+15, 2, 2)
      local r1 = pixelData:getPixel(0, 0)
      local r2 = pixelData:getPixel(0, 1)
      local r3 = pixelData:getPixel(1, 0)
      local r4 = pixelData:getPixel(1, 1)
      result = (r1+r2+r3+r4 >= 2)
    elseif condtype == "corekt" then
      if not unit.blocked then
        result = unit.active
      else
        result = false
      end
    elseif condtype == "rong" then
      result = unit.blocked
    elseif condtype == "timles" then
      result = timeless
    elseif condtype == "clikt" then
        if unit.x == last_click_x and unit.y == last_click_y then
            result = true
        else
            result = false
        end
        --print(result)
        --print(x, y)
        --print(last_click_x, last_click_y)
    elseif condtype == "reed" or condtype == "bleu" or condtype == "blacc"
    or condtype == "grun" or condtype == "yello" or condtype == "orang"
    or condtype == "purp" or condtype == "whit" or condtype == "cyeann" or condtype == "pinc" then
      local colour = unit.color_override or unit.color;
      if (unit.fullname == "no1" or unit.stelth) then
        result = false
      elseif (unit.rave or unit.colrful or unit.gay) then
        result = true
      else
        result = colour_for_palette[colour[1]][colour[2]] == condtype
      end
    elseif condtype == "the" then
      local the = cond[3][1]
      
      local tx = the.x
      local ty = the.y
      local dir = the.dir
      local dx = dirs8[dir][1]
      local dy = dirs8[dir][2]
      
      dx,dy,dir,tx,ty = getNextTile(the,dx,dy,dir)
      result = ((unit.x == tx) and (unit.y == ty))
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
    
    withrecursion[cond] = old_withrecursioncond
  end
  return endresult
end

function hasLineOfSight(brite, lit)
  if (not sameFloat(brite, lit)) then
    return false;
  end
  if (rules_with["opaque"] == nil) then
    return true;
  end
  --https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
  local x0, y0, x1, y1 = brite.x, brite.y, lit.x, lit.y;
  local dx = x1 - x0;
  local dy = y1 - y0;
  if (dx == 0 and dy == 0) then return true end
  if (math.abs(dx) > math.abs(dy)) then
    local derr = math.abs(dy / dx);
    local err = 0;
    local y = y0
    local found_opaque = false;
    for x = x0, x1, sign(dx) do
      if found_opaque then return false end
      if x ~= x0 or y ~= y0 then
        for _,v in ipairs(getUnitsOnTile(x, y)) do
          if hasProperty(v, "opaque") then
            found_opaque = true
            break
          end
        end
      end
      err = err + derr;
      if err >= 0.5 then
        y = y + sign(dy);
        err = err - 1;
      end
    end
  elseif (math.abs(dy) > math.abs(dx)) then
    local derr = math.abs(dx / dy);
    local err = 0;
    local x = x0
    local found_opaque = false;
    for y = y0, y1, sign(dy) do
      if found_opaque then return false end
      if x ~= x0 or y ~= y0 then
        for _,v in ipairs(getUnitsOnTile(x, y)) do
          if hasProperty(v, "opaque") then
            found_opaque = true
            break
          end
        end
      end
      err = err + derr;
      if err >= 0.5 then
        x = x + sign(dx);
        err = err - 1;
      end
    end
  else --both equal
    local x = x0;
    local found_opaque = false;
    for y = y0, y1, sign(dy) do
      if x ~= x0 or y ~= y0 then
        if found_opaque then return false end
        for _,v in ipairs(getUnitsOnTile(x, y)) do
          if hasProperty(v, "opaque") then
            found_opaque = true
            break
          end
        end
      end
      x = x + sign(dx);
    end
  end
  return true;
end

lightcanvas = nil
temp_lightcanvas = nil
lightcanvas_width = 0
lightcanvas_height = 0

torc_angles = {20,45,90,120,180, 210, 270, }
function calculateLight()
  if lightcanvas_width ~= mapwidth or lightcanvas_height ~= mapheight then
    lightcanvas = love.graphics.newCanvas(mapwidth*32, mapheight*32)
    temp_lightcanvas = love.graphics.newCanvas(mapwidth*32, mapheight*32)
    lightcanvas_height = mapheight
    lightcanvas_width = mapwidth
  end
  local brites = getUnitsWithEffect("brite")
  local torcs = getUnitsWithEffect("torc")
  if (#brites == 0 and #torcs == 0) then
    love.graphics.setCanvas(lightcanvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setCanvas()
    return
  end
  local opaques = getUnitsWithEffect("opaque")
  if (#opaques == 0 and #brites ~= 0) then
    love.graphics.setCanvas(lightcanvas)
    love.graphics.clear(1, 1, 1, 1)
    love.graphics.setCanvas()
    return
  end
  love.graphics.setCanvas(lightcanvas)
  love.graphics.clear(0, 0, 0, 1)
  for _,unit in ipairs(brites) do
    love.graphics.setCanvas(temp_lightcanvas)
    love.graphics.clear(1, 1, 1, 1)
    drawShadows(unit, opaques)
    love.graphics.setCanvas(lightcanvas)
    love.graphics.setBlendMode("add", "premultiplied")
    love.graphics.draw(temp_lightcanvas)
    love.graphics.setBlendMode("alpha")
  end
  for _,unit in ipairs(torcs) do
    love.graphics.setCanvas(temp_lightcanvas)
    love.graphics.clear(0, 0, 0, 1)
    love.graphics.setColor(1, 1, 1, 1)
    local width = torc_angles[countProperty(unit,"torc")]
    if width then
      local facing = (1-unit.dir) * 45
      local cx = unit.x*32+16
      local cy = unit.y*32+16
      local ex = mapwidth*32
      local ey = mapheight*32
      local angle1 = (math.rad(facing - width/2)+math.pi*2) % (math.pi*2)
      local angle2 = (math.rad(facing + width/2)+math.pi*2) % (math.pi*2)
      local ur = math.atan2(unit.y+0.5, mapwidth-unit.x-0.5)
      local ul = math.atan2(unit.y+0.5, -unit.x-0.5)
      local dl = math.atan2(unit.y-mapheight+0.5, -unit.x-0.5)+math.pi*2
      local dr = math.atan2(unit.y-mapheight+0.5, mapwidth-unit.x-0.5)+math.pi*2
      if angle1 < ur or angle1 > dr then
        if angle2 < ur or angle2 > dr then
          love.graphics.polygon("fill", cx, cy, ex, cy+math.tan(angle1)*(cx-ex), ex, cy+math.tan(angle2)*(cx-ex))
        elseif angle2 < ul then
          love.graphics.polygon("fill", cx, cy, ex, cy+math.tan(angle1)*(cx-ex), ex, 0, cx+cy/math.tan(angle2), 0)
        elseif angle2 < dl then
        else
        end
      elseif angle1 < ul then
        if angle2 < ur or angle2 > dr then
        elseif angle2 < ul then
        elseif angle2 < dl then
        else
        end
      elseif angle1 < dl then
        if angle2 < ur or angle2 > dr then
        elseif angle2 < ul then
        elseif angle2 < dl then
        else
        end
      else
        if angle2 < ur or angle2 > dr then
        elseif angle2 < ul then
        elseif angle2 < dl then
        else
        end
      end
    else
      love.graphics.clear(1, 1, 1, 1)
    end
    drawShadows(unit, opaques)
    love.graphics.setCanvas(lightcanvas)
    love.graphics.setBlendMode("add", "premultiplied")
    love.graphics.draw(temp_lightcanvas)
    love.graphics.setBlendMode("alpha")
  end
  love.graphics.setCanvas()
end

function drawShadows(source, opaques)
  love.graphics.setColor(0, 0, 0, 1)
  for _,opaque in ipairs(opaques) do
    local sourceX = source.x*32+16
    local sourceY = source.y*32+16
    local closeX = (opaque.x*32) + (opaque.x<source.x and 32 or 0)
    local farX = (opaque.x*32) + (opaque.x>=source.x and 32 or 0)
    local edgeX = (opaque.x>=source.x and mapwidth*32 or 0)
    local closeY = (opaque.y*32) + (opaque.y<source.y and 32 or 0)
    local farY = (opaque.y*32) + (opaque.y>=source.y and 32 or 0)
    local edgeY = (opaque.y>=source.y and mapheight*32 or 0)
    if opaque.x == source.x and opaque.y == source.y then
      love.graphics.clear(0, 0, 0, 1)
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.rectangle("fill", closeX, closeY, 32, 32)
      return -- no light escapes this, no need to check other farther opaques from this light source
    elseif opaque.x == source.x then
      local diag2 = sourceX + (farX-sourceX)/(closeY-sourceY)*(edgeY-sourceY)
      local diag1 = sourceX + (closeX-sourceX)/(closeY-sourceY)*(edgeY-sourceY)
      -- love.graphics.polygon("fill", farX, farY, closeX, farY, closeX, closeY, diag1, edgeY, diag2, edgeY, farX, closeY)
      love.graphics.polygon("fill", closeX, farY, closeX, closeY, diag1, edgeY, farX, edgeY, farX, farY)
      love.graphics.polygon("fill", farX, edgeY, diag2, edgeY, farX, closeY)
    elseif opaque.y == source.y then
      local diag2 = sourceY + (farY-sourceY)/(closeX-sourceX)*(edgeX-sourceX)
      local diag1 = sourceY + (closeY-sourceY)/(closeX-sourceX)*(edgeX-sourceX)
      -- love.graphics.polygon("fill", farX, farY, closeX, farY, edgeX, diag1, edgeX, diag2, closeX, closeY, farX, closeY)
      love.graphics.polygon("fill", farX, closeY, closeX, closeY, edgeX, diag1, edgeX, farY, farX, farY)
      love.graphics.polygon("fill", edgeX, farY, edgeX, diag2, closeX, farY)
    else
      local diagX = sourceX + (closeX-sourceX)/(farY-sourceY)*(edgeY-sourceY) -- using triangle math here
      local diagY = sourceY + (closeY-sourceY)/(farX-sourceX)*(edgeX-sourceX) -- (not trigonometry, the other one)
      local cornerX = (edgeX > 0) and math.max(diagX, edgeX) or math.min(diagX, edgeX)
      local cornerY = (edgeY > 0) and math.max(diagY, edgeY) or math.min(diagY, edgeY)
      love.graphics.polygon("fill", farX, farY, closeX, farY, diagX, edgeY, cornerX, cornerY, edgeX, diagY, farX, closeY)
    end
  end
  love.graphics.setColor(1, 1, 1, 1)
end

threshold_for_dir = {50, 0.01, 0.1, 1, 2, 5, 10, 25};

function deterministicRandom(fullname, cond)
  --have to adjust #undo_buffer by 1 during undoing since we're in the process of rewinding to the previous turn
  local key = fullname..","..tostring(cond.x)..","..tostring(cond.y)..","..tostring(cond.dir)..","..tostring(undoing and #undo_buffer - 1 or #undo_buffer)
  if rng_cache[key] == nil then
    local arbitrary_unit_key = math.random();
    local arbitrary_unit = units_by_name[fullname][math.floor(arbitrary_unit_key*#units_by_name[fullname])+1];
    rng_cache[key] = arbitrary_unit.id;
  end
  return rng_cache[key]
end

function deterministicRng(unit, cond)
  --have to adjust #undo_buffer by 1 during undoing since we're in the process of rewinding to the previous turn
  local key = unit.name..","..tostring(unit.x)..","..tostring(unit.y)..","..tostring(unit.dir)..","..tostring(cond.x)..","..tostring(cond.y)..","..tostring(cond.dir)..","..tostring(undoing and #undo_buffer - 1 or #undo_buffer)
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

function getUnitsOnTile(x,y,name,not_destroyed,exclude,checkmous)
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
    if (name == "mous") or checkmous then
      for _,cursor in ipairs(cursors) do
        if cursor ~= exclude then
          if not not_destroyed or (not_destroyed and not cursor.removed) then
            if cursor.x == x and cursor.y == y then
              table.insert(result, cursor)
            end
          end
        end
      end
    end
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

function fullDump(o, r, fulldump)
  if type(o) == 'table' and (not r or r > 0) then
    local s = '{'
    local first = true
    if not fulldump and o["new"] ~= nil then --abridged print for table
      o = {fullname = o.textname, id = o.id, x = o.x, y = o.y, dir = o.dir};
    end
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

function dump(o, fulldump)
  if type(o) == 'table' then
    local s = '{'
    local cn = 1
    if #o ~= 0 then
      for _,v in ipairs(o) do
        if cn > 1 then s = s .. ',' end
        s = s .. dump(v, fulldump)
        cn = cn + 1
      end
    else
      if not fulldump and o["new"] ~= nil then --abridged print for table
        local tbl = {fullname = o.textname, id = o.id, x = o.x, y = o.y, dir = o.dir};
        for k,v in pairs(tbl) do
           if cn > 1 then s = s .. ',' end
          s = s .. tostring(k) .. ' = ' .. dump(v, fulldump)
          cn = cn + 1
        end
      else
        for k,v in pairs(o) do
          if cn > 1 then s = s .. ',' end
          s = s .. tostring(k) .. ' = ' .. dump(v, fulldump)
          cn = cn + 1
        end
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
  elseif type == "movement-puff" then
    local ps = love.graphics.newParticleSystem(sprites["circle"])
    local px = (x + 0.5) * TILE_SIZE
    local py = (y + 0.5) * TILE_SIZE
    local size = 0.2
    ps:setPosition(px, py)
    ps:setSpread(0.3)
    ps:setEmissionArea("borderrectangle", TILE_SIZE/4, TILE_SIZE/4, 0, true)
    ps:setSizes(size, size, size, 0)
    ps:setSpeed(math.random(30, 40))
    ps:setLinearDamping(5)
    ps:setParticleLifetime(math.random(0.50, 1.10))
    if #color == 2 then
      ps:setColors(getPaletteColor(color[1], color[2]))
    else
      ps:setColors(color[1]/255, color[2]/255, color[3]/255, (color[4] or 255)/255)
    end
    ps:start()
    ps:emit(count or 1)
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

function pointInside(px_,py_,x,y,w,h,t)
  local px, py = px_, py_
  if t then
    px, py = t:inverseTransformPoint(px, py)
  end
  return px > x and px < x+w and py > y and py < y+h
end

function mouseOverBox(x,y,w,h,t)
  for i,pos in ipairs(getMousePositions()) do
    if pointInside(pos.x, pos.y, x, y, w, h, t) then
      return true
    end
  end
  return false
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

function getNearestPointInPerimeter(l,t,w,h,x,y)
  local r, b = l+w, t+h

  x, y = clamp(x, l, r), clamp(y, t, b)

  local dl, dr, dt, db = math.abs(x-l), math.abs(x-r), math.abs(y-t), math.abs(y-b)
  local m = math.min(dl, dr, dt, db)

  if m == dt then return x, t end
  if m == db then return x, b end
  if m == dl then return l, y end
  return r, y
end

function sign(x)
  if (x > 0) then
    return 1
  elseif (x < 0) then
    return -1
  end
  return 0
end

function sameFloat(a, b, ignorefloat)
  if hasRule(a,"ignor",b) or hasRule(b,"ignor",a) or hasRule(a,"ignor",outerlvl) or hasRule(b,"ignor",outerlvl) or hasRule(outerlvl,"ignor",a) or hasRule(outerlvl,"ignor",b) then
    return false
  else
    if ignorefloat then
      return true
    else
      return (countProperty(a, "flye") == countProperty(b, "flye")) or hasProperty(a, "tall") or hasProperty(b, "tall")
    end
  end
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
-- t = {{tile1 words}, {tile2 words}, (until out of text)}
-- places the list of words into a full table of phrases (amount of words) long, {{11,21,31,41},{11,21,31,42},{11,21,32,41},...}
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

function getAbsolutelyEverythingExcept(except)
  local result = {}

  --four special objects
  if "mous" ~= except then
    table.insert(result, "mous")
  end
  if "lvl" ~= except then
    table.insert(result, "lvl")
  end
  if "no1" ~= except then
    table.insert(result, "no1")
  end
  --don't specify generic text if it's already a type of text
  if not except:starts("text") then
    table.insert(result, "text")
  end
  
  for i,ref in ipairs(referenced_objects) do
    if ref ~= except and (ref ~= "this" or not except:starts("this")) then
      table.insert(result, ref)
    end
  end
  
  if (except ~= "text") then
    for i,ref in ipairs(referenced_text) do
      --TODO: BEN'T text being returned here causes a stack overflow. Prevent it until a better solution is found.
      if ref ~= except and not ref:ends("n't") then
        table.insert(result, ref)
      end
    end
  end

  --print(dump(result))
  return result
end

function getEverythingExcept(except)
  local result = {}

  local ref_list = referenced_objects
  if except:starts("text_") then
    ref_list = referenced_text
  end

  for i,ref in ipairs(ref_list) do
    --TODO: BEN'T text being returned here causes a stack overflow. Prevent it until a better solution is found.
    if ref ~= except and not ref:ends("n't") then
      table.insert(result, ref)
    end
  end
  
  --print(except)
  --print(dump(result))
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

function deleteDir(dir)
  for _,file in ipairs(love.filesystem.getDirectoryItems(dir)) do
    if love.filesystem.getInfo(file, "directory") then
      deleteDir(dir .. "/" .. file)
    else
      love.filesystem.remove(dir .. "/" .. file)
    end
  end
  love.filesystem.remove(dir)
end

function setRainbowModeColor(value, brightness)
  brightness = brightness or 0.5

  if rainbowmode and not spookmode then
    love.graphics.setColor(hslToRgb(value%1, brightness, brightness, .9))
  end
end

function shakeScreen(dur, intensity)
  shake_dur = dur+shake_dur/4
  shake_intensity = shake_intensity + intensity/2
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

function loadLevels(levels, mode, level_objs)
  if #levels == 0 then
    return
  end
  
  --setup stay ther
  stay_ther = nil
  if (rules_with ~= nil) then
    stay_ther = {}
    local isstayther = getUnitsWithEffect("stay ther");
    for _,unit in ipairs(isstayther) do
      table.insert(stay_ther, unit);
    end
  end
  
  --setup surrounds
  surrounds = nil;
  if (level_objs ~= nil) then
    surrounds = {};
    for i = -1,1 do
      surrounds[i] = {}
      for j = -1,1 do
        surrounds[i][j] = {}
        for _,lvl in ipairs(level_objs) do
          for __,stuff in ipairs(getUnitsOnTile(lvl.x+i,lvl.y+j,nil,false,lvl)) do
            table.insert(surrounds[i][j], stuff);
          end
        end
      end
    end
  end

  local dir = "levels/"
  if world ~= "" then dir = world_parent .. "/" .. world .. "/" end

  maps = {}

  mapwidth = 0
  mapheight = 0
  --if we're entering a level object, then the level we were in is the parent
  parent_filename = level_objs ~= nil and level_filename or nil
  level_name = nil
  level_filename = nil

  for _,level in ipairs(levels) do
    local data
    if not level:starts("{") then
      data = json.decode(love.filesystem.read(dir .. level .. ".bab"))
    else
      data = json.decode(level)
    end
    level_compression = data.compression or "zlib"
    local loaddata = love.data.decode("string", "base64", data.map)
    local mapstr = loadMaybeCompressedData(loaddata)

    loaded_level = not new

    if not level_name then
      level_name = data.name
    else
      level_name = level_name .. " & " .. data.name
    end
    
    if not level_filename then
      level_filename = level
    else
      level_filename = level_filename .. "|" .. level
    end
    
    level_name = level_name:sub(1, 100)
    level_author = data.author or ""
    level_extra = data.extra or false
    current_palette = data.palette or "default"
    map_music = data.music or "bab be u them"
    mapwidth = math.max(mapwidth, data.width)
    mapheight = math.max(mapheight, data.height)
    map_ver = data.version or 0
    level_parent_level = data.parent_level or ""
    level_next_level = data.next_level or ""
    level_is_overworld = data.is_overworld or false
    level_puffs_to_clear = data.puffs_to_clear or 0
    level_background_sprite = data.background_sprite or ""

    if map_ver == 0 then
      table.insert(maps, {0, loadstring("return " .. mapstr)()})
    else
      table.insert(maps, {map_ver, mapstr})
    end

    if love.filesystem.getInfo(dir .. level .. ".png") then
      icon_data = love.image.newImageData(dir .. level .. ".png")
    else
      icon_data = nil
    end
  end

  if mode == "edit" then
    new_scene = editor
  else
    surrounds_name = level_name
    new_scene = game
  end
end

function getMousePositions()
  if scene ~= game then
    return {{x = love.mouse.getX(), y = love.mouse.getY()}}
  else
    local t = {}
    for i,cursor in ipairs(cursors) do
      table.insert(t, {x = cursor.screenx, y = cursor.screeny})
    end
    return t
  end
end

function unsetNewUnits()
  for unit,_ in pairs(new_units_cache) do
    unit.new = false
  end
  new_units_cache = {}
end

function timecheck(unit,verb,prop)
  if timeless then
    if hasProperty(unit,"za warudo") then
      return true
    elseif hasProperty(outerlvl,"za warudo") and not hasRule(unit,"ben't","za warudo") then
      return true
    elseif verb ~= nil and prop ~= nil then
      local rulecheck = matchesRule(unit,verb,prop)
      for _,ruleparent in ipairs(rulecheck) do
        for i=1,#ruleparent[1][4][1] do
          if ruleparent[1][4][1][i][1] == "timles" then
            return true
          end
        end
      end
    end
  else
    return true
  end
end

--[[function fillTextDetails(sentence, x, y, dir, len)
  --changes a sentence of pure text into a valid sentence.
  local ret = {}
  local w = 0
  for _,word in ipairs(sentence) do
    for i,tile in ipairs(tiles_list) do --full search to get id
      if tile.type == "text" and tile.texttype ~= "letter" and word == string.sub(tile.name:gsub("%s+", ""),6) then
        print("x: "..x)
        local unit = createUnit(i, x+ dirs8[dir][1]*w, y+ dirs8[dir][2]*w ,1)
        table.insert(ret,unit)
        break
      end
    end
    w = w+1
  end
  for i=w+1,len do
    local unit = createUnit(237, x+dirs8[dir][1]*i, y+dirs8[dir][2]*i ,1) --237 is ellipsis as of my local copy. If there's a way to refer by name, please change it to that.
    table.insert(ret,unit)
  end
  return ret
end]]

function fillTextDetails(sentence, old_sentence, orig_index, word_index)
  --print(#old_sentence, orig_index, word_index)
  --changes a sentence of pure text into a valid sentence.
  --print("what we started with:",dump(sentence))
  local ret = {}
  local w = 0
  for _,word in ipairs(sentence) do
    --print("sentence: "..fullDump(sentence))
    --print(text_list[word], old_sentence)
    local newname = text_list[word].name;
    if newname:starts("text_") then
      newname = newname:sub(6);
    end
    table.insert(ret,{type = text_list[word].texttype or "object", name = newname, unit=old_sentence[orig_index].unit})
    w = w+1
  end
  for i=orig_index+1,(word_index-1) do --extra ellipses for the purposes of making sure the parser gets it properly.
    --print("aa:",old_sentence[i])
    table.insert(ret,{type = text_list["..."].texttype or "object", name = "...", unit=old_sentence[i].unit})
  end
  return ret
end

function addTables(source, to_add)
  --adds to_add to the end of source. Seperate from table.insert because this adds multiple entries. Also returns itself.
  for _,x in ipairs(to_add) do
    table.insert(source, x)
  end
  return source
end

text_in_tiles = {} --list of text in an array, and textname only
for _,tile in ipairs(tiles_list) do
  if tile.type == "text" and tile.texttype ~= "letter" then
    local textname = string.sub(tile.name:gsub("%s+", ""),6) --removes spaces too
    table.insert(text_in_tiles,textname)
  end
end

text_list = {} --list of text with named keys (by textname)
for _,tile in ipairs(tiles_list) do
  if tile.type == "text" and tile.texttype ~= "letter" then
    local textname = string.sub(tile.name:gsub("%s+", ""),6)
    text_list[textname] = tile
    text_list[textname].textname = string.sub(tile.name,6)
  end
end

--[[function dumpOfProperty(table, searchterm)
  -- a dump that's easier to search through.
  local ret = ""
  for _,first in pairs(table) do
    for _,second in pairs(first) do
      for key,param in pairs(second) do
        if key == searchterm then
          ret = ret..", "..fullDump(param)
        end
      end
    end
  end
  return "{"..string.sub(ret,3).."}"
end]]

function pcallNewShader(code)
  local libstatus, liberr = pcall(function() love.graphics.newShader(code) end)

  if libstatus then
    return love.graphics.newShader(code)
  else
    print(colr.yellow("⚠ failed to create new shader: "..liberr))
    return nil
  end
end

function pcallSetShader(shader)
  if shader ~= nil then
    love.graphics.setShader(shader)
  end
end

function loadMaybeCompressedData(loaddata)
  local mapstr = nil
  if pcall(function() mapstr = love.data.decompress("string", "zlib", loaddata) end) then
    return mapstr
  else
    return loaddata
  end
end

function extendReplayString(movex, movey, key)
  if (not unit_tests and not replay_playback) then
    replay_string = replay_string..tostring(movex)..","..tostring(movey)..","..tostring(key)
    if (rules_with["mous"] ~= nil) then
      local cursor_table = {}
      for _,cursor in ipairs(cursors) do
        table.insert(cursor_table, {cursor.x, cursor.y})
      end
      replay_string = replay_string..","..love.data.encode("string", "base64", serpent.line(cursor_table))
    end
    replay_string = replay_string..";"
  end
end