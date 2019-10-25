function clear()
  puffs_this_world = 0
  levels_this_world = 0

  --groups_exist = false
  letters_exist = false
  if not doing_past_turns then
    replay_playback = false
    replay_playback_turns = nil
    replay_playback_string = nil
    replay_playback_turn = 1
    replay_playback_time = love.timer.getTime()
    replay_playback_interval = 0.3
    old_replay_playback_interval = 0.3
    replay_pause = false
    replay_string = ""
  end
  rhythm_time = love.timer.getTime()
  rhythm_interval = 1
  rhythm_queued_movement = {0, 0, "wait"}
  new_units_cache = {}
  undoing = false
  successful_brite_cache = nil
  next_level_name = ""
  win_sprite_override = {}
  level_destroyed = false
  last_input_time = nil
  most_recent_key = nil
  just_moved = true
  should_parse_rules_at_turn_boundary = false
  should_parse_rules = true
  graphical_property_cache = {}
  initializeGraphicalPropertyCache()
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
  drag_units = {}
  cursors = {}
  cursors_by_id = {}
  shake_dur = 0
  shake_intensity = 0.5
  current_turn = 0
  current_move = 0
  
  --za warudo needs a lot
  timeless = false
  time_destroy = {}
  time_delfx = {}
  time_sfx = {}
  timeless_split = {}
  timeless_win = {}
  timeless_unwin = {}
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

  if not doing_past_turns then
    change_past = false
    past_playback = false
    all_moves = {}
    past_rules = {}
    past_ends = {}
  end
  
  card_for_id = {}

  love.mouse.setCursor()
end

function pastClear()
  if stopwatch ~= nil then
    stopwatch.visible = false
  end
  should_parse_rules = true
  doing_past_turns = false
  past_playback = false
  past_rules = {}
  cutscene_tick = tick.group()
end

function metaClear()
  rules_with = nil
  rules_with_unit = nil
  level_tree = {}
  playing_world = false
  parent_filename = nil
  stay_ther = nil
  surrounds = nil
  pastClear()
end

function initializeGraphicalPropertyCache()
  local properties_to_init = -- list of properties that require the graphical cache
  {
	  "flye", "slep", "tranz", "gay", "stelth", "colrful", "xwx", "rave", "enby", -- miscelleaneous graphical effects
	}
  for i = 1, #properties_to_init do
    local prop = properties_to_init[i]
    if (graphical_property_cache[prop] == nil) then graphical_property_cache[prop] = {} end
  end
end

function loadMap()
  --no longer necessary, we now lazy initialize these
  --[[for x=0,mapwidth-1 do
    for y=0,mapheight-1 do
      units_by_tile[x + y * mapwidth] = {}
    end
  end]]
  local has_missing_levels = false
  local rects = {}
  local extra_units = {}
  for _,mapdata in ipairs(maps) do
    local version = mapdata.info.version
    local map = mapdata.data

    local offset = {x = 0, y = 0}
    if mapdata.info.width < mapwidth then
      offset.x = math.floor((mapwidth / 2) - (mapdata.info.width / 2))
    end
    if mapdata.info.height < mapheight then
      offset.y = math.floor((mapheight / 2) - (mapdata.info.height / 2))
    end
    table.insert(rects, {x = offset.x, y = offset.y, w = mapdata.info.width, h = mapdata.info.height})

    if version == 0 or version == nil then
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
            createUnit(tile, x + offset.x, y + offset.y, dir)
          end
        elseif version == 2 or version == 3 then
          local id, tile, x, y, dir, specials
          id, tile, x, y, dir, specials, pos = love.data.unpack(version == 2 and PACK_UNIT_V2 or PACK_UNIT_V3, map, pos)
          if inBounds(x + offset.y, y + offset.y) then
            local unit = createUnit(tile, x + offset.x, y + offset.y, dir, false, id)
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
      ok, map = serpent.load(map)
      if (ok ~= true) then
        print("Serpent error while loading:", ok, fullDump(map))
      end
      local floodfill = {}
      local objects = {}
      local lvls = {}
      local locked_lvls = {}
      local dofloodfill = scene ~= editor
      for _,unit in ipairs(map) do
        id, tile, x, y, dir, specials, color = unit.id, unit.tile, unit.x, unit.y, unit.dir, unit.special, unit.color
        x = x + offset.x
        y = y + offset.y
        
        --track how many puffs and levels exist in this world (have to do this separately so we count hidden levels etc)
        if specials.level then
          levels_this_world = levels_this_world + 1
          if readSaveFile{"levels", specials.level, "won"} then
            puffs_this_world = puffs_this_world + 1
          end
        end
        
        if scene == editor and specials.level then
          if not love.filesystem.getInfo(getWorldDir() .. "/" .. specials.level .. ".bab") then
            has_missing_levels = true
            print("missing level: " .. specials.level)
            local search = searchForLevels(getWorldDir(), specials.name, true)
            if #search > 0 then
              print("    - located: " .. search[1].file)
              specials.level = search[1].file
              specials.name = search[1].data.name
            else
              print("    - could not locate!")
            end
          end
        end
        if not dofloodfill then
          local unit = createUnit(tile, x, y, dir, false, id, nil, color)
          unit.special = specials
        elseif tile == tiles_by_name["lvl"] then
          if readSaveFile{"levels", specials.level, "seen"} then
            specials.visibility = "open"
            local tfs = readSaveFile{"levels", specials.level, "transform"}
            for i,t in ipairs(tfs or {tiles_listPossiblyMeta(tile).name}) do
              if i == 1 then
                local unit = createUnit(tiles_by_namePossiblyMeta(t), x, y, dir, false, id, nil, color)
                unit.special = deepCopy(specials)
                if readSaveFile{"levels", specials.level, "won"} or readSaveFile{"levels", specials.level, "clear"} then
                  table.insert(floodfill, {unit, 1})
                end
              else
                table.insert(extra_units, {tiles_by_namePossiblyMeta(t), x, y, dir, color, deepCopy(specials)})
              end
            end
          elseif specials.visibility == "open" then
            local unit = createUnit(tile, x, y, dir, false, id, nil, color)
            unit.special = specials
          elseif specials.visibility == "locked" then
            table.insert(locked_lvls, {id, tile, x, y, dir, specials, color})
            table.insert(objects, {id, tile, x, y, dir, specials, color})
          else
            table.insert(objects, {id, tile, x, y, dir, specials, color})
          end
        elseif tile == tiles_by_name["lin"] then
          if specials.visibility == "hidden" then
            table.insert(objects, {id, tile, x, y, dir, specials, color})
          else
            local unit = createUnit(tile, x, y, dir, false, id, nil, color)
            unit.special = specials
          end
        else
          if specials.level then
            if readSaveFile{"levels", specials.level, "seen"} then
              specials.visibility = "open"
            end
            local tfs = readSaveFile{"levels", specials.level, "transform"}
            for i,t in ipairs(tfs or {tiles_listPossiblyMeta(tile).name}) do
              if i == 1 then
                local unit = createUnit(tiles_by_namePossiblyMeta(t), x, y, dir, false, id, nil, color)
                unit.special = specials
              else
                table.insert(extra_units, {tiles_by_namePossiblyMeta(t), x, y, dir, color, deepCopy(specials)})
              end
            end
          else
            local unit = createUnit(tile, x, y, dir, false, id, nil, color)
            unit.special = specials
          end
        end
      end
      
      --now check if we should grant clear/complete
      if (level_puffs_to_clear > 0 and puffs_this_world >= level_puffs_to_clear) then
        writeSaveFile(true, {"levels", level_filename, "clear"})
      end
      if (levels_this_world > 0 and puffs_this_world >= levels_this_world) then
        writeSaveFile(true, {"levels", level_filename, "complete"})
      end
      
      if dofloodfill then
        local created = {}
        while #floodfill > 0 do
          local u, ptype = unpack(table.remove(floodfill, 1))
          local orthos = {[-1] = {}, [0] = {}, [1] = {}}
          for a = 0,1 do -- 0 = ortho, 1 = diag
            for i = #objects,1,-1 do
              local v = objects[i] -- {id, tile, x, y, dir, specials, color}
              local dx = u.x-v[3]
              local dy = u.y-v[4]
              if (((dx == -1 or dx == 1) and (dy == -a or dy == a)) or ((dx == -a or dx == a) and (dy == -1 or dy == 1)))
              and (a == 0 or (not orthos[dx][0] and not orthos[0][dy])) then
                orthos[dx][dy] = true
                if not created[v[1]] then
                  if v[2] == tiles_by_name["lvl"] then
                    if ptype ~= 2 then
                      local unit = createUnit(v[2], v[3], v[4], v[5], false, v[1], nil, v[7])
                      created[v[1]] = true
                      unit.special = v[6]
                      if ptype == 1 then
                        unit.special.visibility = "open"
                        table.insert(floodfill, {unit, 2})
                      elseif ptype == 3 then
                        unit.special.visibility = "open"
                      end
                    elseif ptype == 2 and not table.has_value(locked_lvls, v) then
                      table.insert(locked_lvls, v)
                      table.insert(floodfill, {{x = v[3], y = v[4]}, 2})
                    end
                  elseif (ptype == 1 or ptype == 3) and v[2] == tiles_by_name["lin"] and (not v[6].pathlock or v[6].pathlock == "none") then
                    local unit = createUnit(v[2], v[3], v[4], v[5], false, v[1], nil, v[7])
                    created[v[1]] = true
                    unit.special = v[6]
                    table.insert(floodfill, {unit, 3})
                  end
                end
              end
            end
          end
        end
        for _,v in ipairs(locked_lvls) do
          if not created[v[1]] then
            local unit = createUnit(v[2], v[3], v[4], v[5], false, v[1], nil, v[7])
            created[v[1]] = true
            unit.special = v[6]
          end
        end
      end
    end
  end
  for x=0,mapwidth-1 do
    for y=0,mapheight-1 do
      local in_bounds = false
      for _,rect in ipairs(rects) do
        if x >= rect.x and x < rect.x + rect.w and y >= rect.y and y < rect.y + rect.h then
          in_bounds = true
          break
        end
      end
      if not in_bounds then
        createUnit(tiles_by_name["bordr"], x, y, 1)
      end
    end
  end
  for _,t in ipairs(extra_units) do
    local unit = createUnit(t[1], t[2], t[3], t[4], false, nil, nil, t[5])
    unit.specials = t[6]
  end
  if (load_mode == "play") then
    initializeOuterLvl()
    initializeEmpties()
    loadStayTher()
    if (not unit_tests) then
      writeSaveFile(true, {"levels", level_filename, "seen"})
    end
  end
  if has_missing_levels then
    print(colr.red("\nLEVELS MISSING - PLEASE CHECK & SAVE!"))
  end
  
  --I don't know why, but this is slower by a measurable amount (70-84 seconds for example).
  --[[groups_exist = letters_exist
  if not groups_exist then
    for _,group_name in ipairs(group_names) do
      if units_by_name["text_"..group_name] then
        groups_exist = true
        break
      end
    end
  end]]
  
  unsetNewUnits()
end

function loadStayTher()
  if stay_ther ~= nil then
    for _,unit in ipairs(stay_ther) do
      local newunit = createUnit(unit.tile, unit.x, unit.y, unit.dir)
      newunit.special = unit.special
    end
  end
end

function initializeOuterLvl()
  outerlvl = createUnit(tiles_by_name["lvl"], -999, -999, 1, nil, nil, true)
end

function initializeEmpties()
  --TODO: other ways to make a text_no1 could be to have a text_text_no1 but that seems contrived that you'd have text_text_no1 but not text_no1?
  --text_her counts because it looks for no1, I think. similarly we could have text_text_her but again, contrived
  if ((not letters_exist) and (not units_by_name["text_no1"]) and (not units_by_name["text_every3"]) and (not units_by_name["text_her"])) then return end
  for x=0,mapwidth-1 do
    for y=0,mapheight-1 do
      local tileid = x + y * mapwidth
      empties_by_tile[tileid] = createUnit(tiles_by_name["no1"], x, y, (((tileid - 1) % 8) + 1), nil, nil, true)
    end
  end
end

function compactIds()
  units_by_id = {}
  for i,unit in ipairs(units) do
    unit.id = i
    units_by_id[i] = unit
  end
  max_unit_id = #units + 1
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
  
  local nrules = {} -- name
  local fnrules = {} -- fullname
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
  nrules[2] = rule2
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
  rules_list = rules_with[(nrules[2] ~= "be" and nrules[2]) or nrules[3] or nrules[1] or nrules[2]] or {}
  mergeTable(rules_list, rules_with[fnrules[3] or fnrules[1]] or {})

  if (debugging) then
    print ("found this many rules:"..tostring(#rules_list))
  end
  if #rules_list > 0 then
    for _,rules in ipairs(rules_list) do
      local rule = rules.rule
      if (debugging) then
        for i=1,3 do
          print("checking this rule,"..tostring(i)..":"..tostring(rule[ruleparts[i] ].name))
        end
      end
      local result = true
      for i=1,3 do
        local name = rule[ruleparts[i]].name
        --special case for stuff like 'group be x' - if we are in that group, we do match that rule
        --we also need to handle groupn't
        --seems to not impact performance much?
        local group_match = false
        if rule_units[i] ~= nil then
          if group_sets[name] and group_sets[name][rule_units[i] ] then
            group_match = true
          else
            if rule_units[i].type == "object" and group_names_set_nt[name] then
              local nament = name:sub(1, -4)
              if not group_sets[nament][rule_units[i] ] then
                group_match = true
              end
            end
          end
        end
        if not (group_match) then
          if nrules[i] ~= nil and nrules[i] ~= name and (fnrules[i] == nil or (fnrules[i] ~= nil and fnrules[i] ~= name)) then
            if (debugging) then
              print("false due to nrules/fnrules mismatch")
            end
            result = false
          end
        end
      end
      --don't test conditions until the rule fully matches
      if result then
        for i=1,3,2 do
          if rule_units[i] ~= nil then
            if not testConds(rule_units[i], rule[ruleparts[i]].conds, rule_units[1]) then
              if (debugging) then
                print("false due to cond", i)
              end
              result = false
            else
              --check that there isn't a verbn't rule - edge cases where this might happen: text vs specific text, group vs unit. This is slow (15% longer unit tests, 0.1 second per unit test) but it fixes old and new bugs so I think we just have to suck it up.
              if rules_with[rule.verb.name.."n't"] ~= nil and #matchesRule(rule_units[i], rule.verb.name.."n't", rule.object.name, true) > 0 then
                result = false
              end
            end
          end
        end
      end
      if result then
        if (debugging) then
          print("matched: " .. dump(rule) .. " | find: " .. find, nrules[1], fnrules[1], rule.subject.name, rule.subject.fullname)
        end
        if find == 0 then
          table.insert(ret, rules)
          if stopafterone then return ret end
        elseif find == 1 then
          for _,unit in ipairs(findUnitsByName(rule[ruleparts[find_arg]].name)) do
            local cond
            if testConds(unit, rule[ruleparts[find_arg]].conds) then
              --check that there isn't a verbn't rule - edge cases where this might happen: text vs specific text, group vs unit. This is slow (15% longer unit tests, 0.1 second per unit test) but it fixes old and new bugs so I think we just have to suck it up.
              if rules_with[rule.verb.name.."n't"] ~= nil and #matchesRule(unit, rule.verb.name.."n't", rule.object.name, true) > 0 then
              else
                table.insert(ret, {rules, unit})
                if stopafterone then return ret end
              end
            end
          end
        elseif find == 2 then
          local found1, found2
          for _,unit1 in ipairs(findUnitsByName(rule.subject)) do
            for _,unit2 in ipairs(findUnitsByName(rule.object)) do
              if testConds(unit1, rule.subject.conds) and testConds(unit2, rule.object.conds, unit1) then
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
  local gotten = {}
  local rules = matchesRule(nil, "be", effect)
  --print ("h:"..tostring(#rules))
  for _,dat in ipairs(rules) do
    local unit = dat[2]
    if not unit.removed and not hasRule(unit, "ben't", effect) then
      table.insert(result, unit)
      gotten[unit] = true
    end
  end
  
  local rules = matchesRule(nil, "giv", effect)
  for _,rule in ipairs(rules) do
    local unit = rule[2]
    if not unit.removed then
      for _,other in ipairs(getUnitsOnTile(unit.x, unit.y, nil, false, unit, nil, hasProperty(unit,"big"))) do
        if not gotten[other] and sameFloat(unit, other) and not hasRule(other, "ben't", effect) and ignoreCheck(other, unit) then
          table.insert(result, other)
          gotten[other] = true
        end
      end
    end
  end
  
  if hasRule(outerlvl, "giv", effect) then
    for _,unit in ipairs(units) do
      if not gotten[unit] and inBounds(unit.x, unit.y) and not hasRule(unit, "ben't", effect) and ignoreCheck(unit, outerlvl) then
        table.insert(result, unit)
      end
    end
  end
  
  if rules_with["rp"] then
    for _,unit in ipairs(result) do
      local isrp = matchesRule(nil,"rp",unit)
      for _,ruleparent in ipairs(isrp) do
        local mimic = ruleparent[2]
        if not gotten[mimic] and not hasRule(mimic,"ben't",effect) then
          gotten[mimic] = true
          table.insert(result,mimic)
        end
      end
    end
    local therp = matchesRule(nil,"rp","the")
    for _,ruleparent in ipairs(therp) do
      local the = ruleparent[1].rule.object.unit
      local tx = the.x+dirs8[the.dir][1]
      local ty = the.y+dirs8[the.dir][2]
      local mimic = ruleparent[2]
      local stuff = getUnitsOnTile(tx,ty)
      for _,unit in ipairs(stuff) do
        if hasProperty(unit,effect) and not hasRule(mimic,"ben't",effect) then
          table.insert(result,mimic)
          break
        end
      end
    end
  end
  
  return result
end

function getUnitsWithEffectAndCount(effect)
  local result = {}
  local rules = matchesRule(nil, "be", effect)
  --print ("h:"..tostring(#rules))
  for _,dat in ipairs(rules) do
    local unit = dat[2]
    if not unit.removed and not hasRule(unit, "ben't", effect) then
      if result[unit] == nil then
        result[unit] = 0
      end
      result[unit] = result[unit] + 1
    end
  end
  
  local rules = matchesRule(nil, "giv", effect)
  for _,rule in ipairs(rules) do
    local unit = rule[2]
    if not unit.removed then
      for _,other in ipairs(getUnitsOnTile(unit.x, unit.y, nil, false, unit, nil, hasProperty(unit,"big"))) do
        if sameFloat(unit, other) and not hasRule(other, "ben't", effect) and ignoreCheck(other, unit) then
          if result[other] == nil then
            result[other] = 0
          end
          result[other] = result[other] + 1
        end
      end
    end
  end
  
  if hasRule(outerlvl, "giv", effect) then
    for _,unit in ipairs(units) do
      if inBounds(unit.x, unit.y) and not hasRule(unit, "ben't", effect) and ignoreCheck(unit, outerlvl) then
        if result[unit] == nil then
          result[unit] = 0
        end
        result[unit] = result[unit] + 1
      end
    end
  end
  
  if rules_with["rp"] then
    for unit,count in pairs(result) do
      local isrp = matchesRule(nil,"rp",unit)
      for _,ruleparent in ipairs(isrp) do
        local mimic = ruleparent[2]
        if not mimic.removed and not hasRule(mimic,"ben't",effect) then
          result[mimic] = count
        end
      end
    end
    local therp = matchesRule(nil,"rp","the")
    for _,ruleparent in ipairs(therp) do
      local the = ruleparent[1].rule.object.unit
      local tx = the.x+dirs8[the.dir][1]
      local ty = the.y+dirs8[the.dir][2]
      local mimic = ruleparent[2]
      local stuff = getUnitsOnTile(tx,ty)
      for _,unit in ipairs(stuff) do
        if hasProperty(unit,effect) and not hasRule(mimic,"ben't",effect) then
          result[mimic] = countProperty(unit,effect)
        end
      end
    end
  end
  return result
end

function getUnitsWithRuleAndCount(rule1, rule2, rule3)
  local result = {}
  local rules = matchesRule(rule1, rule2, rule3)
  --print ("h:"..tostring(#rules))
  for _,dat in ipairs(rules) do
    local unit = dat[2]
    if not unit.removed then
      if result[unit] == nil then
        result[unit] = 0
      end
      result[unit] = result[unit] + 1
    end
  end
  if rules_with["rp"] then
    for unit,count in pairs(result) do
      local isrp = matchesRule(nil,"rp",unit)
      for _,ruleparent in ipairs(isrp) do
        local mimic = ruleparent[2]
        if not mimic.removed and not hasRule(mimic,rule2.."n't",rule3) then
          result[mimic] = count
        end
      end
    end
    local therp = matchesRule(nil,"rp","the")
    for _,ruleparent in ipairs(therp) do
      local the = ruleparent[1].rule.object.unit
      local tx = the.x+dirs8[the.dir][1]
      local ty = the.y+dirs8[the.dir][2]
      local mimic = ruleparent[2]
      local stuff = getUnitsOnTile(tx,ty)
      for _,unit in ipairs(stuff) do
        if hasRule(unit,rule2,rule3) and not hasRule(mimic,rule2.."n't",rule3) then
          result[mimic] = countProperty(unit,effect)
        end
      end
    end
  end
  return result
end


function hasRule(rule1,rule2,rule3)
  if #matchesRule(rule1,rule2,rule3, true) > 0 then return true end
  if not rules_with["rp"] then return false end
  if #matchesRule(rule1,rule2.."n't",rule3, true) > 0 then return false end
  local isrp = matchesRule(rule1,"rp",nil)
  for _,ruleparent in ipairs(isrp) do
    local mimic = ruleparent[2]
    if #matchesRule(mimic,rule2,rule3, true) > 0 then return true end
  end
  return false
end

function validEmpty(unit)
  return #unitsByTile(unit.x, unit.y) == 0
end

function findUnitsByName(name)
  if group_names_set_nt[name] then
    local everything_else_list = findUnitsByName(name:sub(1, -4))
    local everything_else_set = {}
    for _,unit in ipairs(everything_else_list) do
      everything_else_set[unit] = true
    end
    local result = {}
    for _,unit in ipairs(units) do
      if unit.type == "object" and not everything_else_set[unit] then
        table.insert(result, unit)
      end
    end
    return result
  elseif name == "mous" then
    return cursors
  elseif group_lists[name] ~= nil then
    return group_lists[name]
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
  if not rules_with[prop] and prop ~= "?" then return false end
  if hasRule(unit, "be", prop) then return true end
  if type(unit) ~= "table" then return false end
  if not rules_with["giv"] then return false end
  if hasRule(unit, "ben't", prop) then return false end
  if unit == outerlvl then return false end
  if unit and unit.class == "mous" then return false end
  if unit then
    if hasRule(outerlvl, "giv", prop) then return inBounds(unit.x, unit.y) end
    for _,other in ipairs(getUnitsOnTile(unit.x, unit.y, nil, false, unit, true, hasRule(unit,"be","big"))) do
      if #matchesRule(other, "giv", prop) > 0 and sameFloat(unit, other) and ignoreCheck(unit, other) then
        return true
      end
    end
  else
    if hasRule(outerlvl, "giv", prop) then return true end
    for _,ruleparent in ipairs(matchesRule(nil, "giv", prop)) do
      for _,other in ipairs(ruleparent.units) do
        if #getUnitsOnTile(other.x, other.y, nil, false, other, true, hasRule(unit,"be","big")) > 0 and sameFloat(unit, other) then
          return true
        end
      end
    end
  end
  return false
end

function countProperty(unit, prop, ignore_flye)
  if not rules_with[prop] and prop ~= "?" then return 0 end
  local result = #matchesRule(unit,"be",prop)
  if hasRule(unit, "ben't", prop) then return 0 end
  if not rules_with["giv"] then return result end
  if unit == outerlvl then return result end
  if unit and unit.class == "mous" then return result end
  result = result + #matchesRule(outerlvl, "giv", prop)
  if unit then
    for _,other in ipairs(getUnitsOnTile(unit.x, unit.y, nil, false, unit, true, hasProperty(unit,"big"))) do
      if ignoreCheck(unit, other) and (ignore_flye or sameFloat(unit, other)) then
        result = result + #matchesRule(other, "giv", prop)
      end
    end
  else -- I don't think anything uses this? it doesn't seem very useful at least, but I guess it's functional?
    for _,ruleparent in ipairs(matchesRule(nil, "giv", prop)) do
      for _,other in ipairs(ruleparent.units) do
        if ignoreCheck(unit, other) and (ignore_flye or sameFloat(unit, other)) then
          result = result + #getUnitsOnTile(other.x, other.y, nil, false, other, true, hasProperty(other,"big"))
        end
      end
    end
  end
  return result
end

function hasU(unit)
  return hasProperty(unit,"u") or hasProperty(unit,"u too") or hasProperty(unit,"u tres") or hasProperty(unit,"y'all")
end

function getUs()
  local yous = getUnitsWithEffect("u")
  mergeTable(yous,getUnitsWithEffect("u too"))
  mergeTable(yous,getUnitsWithEffect("u tres"))
  mergeTable(yous,getUnitsWithEffect("y'all"))
  return yous
end

--to prevent infinite loops where a set of rules/conditions is self referencing
withrecursion = {}

function testConds(unit, conds, compare_with) --cond should be a {condtype,{object types},{cond_units}}
  local endresult = true
  for _,cond in ipairs(conds or {}) do
    local condtype = cond.name
    local lists = {} -- for iterating
    local sets = {} -- for checking
    if condtype:starts("that") then
      lists = cond.others or {} -- using "lists" to store the names, since THAT doesn't allow nesting, and we need the name for hasRule
    elseif cond.others then
      for _,other in ipairs(cond.others) do
        local list = {}
        local set = {}
        if other.name == "lvl" then -- probably have to account for group/every1 here too, maybe more
          table.insert(list, outerlvl)
          set[outerlvl] = true
        elseif group_lists[other.name] then
          list = group_lists[other.name]
          set = group_sets[other.name]
        else
          for _,otherunit in ipairs(findUnitsByName(other.name)) do -- findUnitsByName handles mous and no1 already
            if testConds(otherunit, other.conds, unit) then
              table.insert(list, otherunit)
              set[otherunit] = true
            end
          end
        end
        table.insert(lists, list)
        table.insert(sets, set)
      end
    end
    

    local result = true
    local cond_not = false
    if condtype:ends("n't") then
      condtype = condtype:sub(1, -4)
      cond_not = true
    end

    local x, y = unit.x, unit.y

    local old_withrecursioncond = withrecursion[cond]
    
    withrecursion[cond] = true
    if (old_withrecursioncond) then
      result = false
    elseif condtype:starts("that") then
      result = true
      local verb = condtype:sub(6)
      for _,param in ipairs(lists) do -- using "lists" to store the names, since THAT doesn't allow nesting, and we need the name for hasRule
        local word = param.unit
        local wx = word.x
        local wy = word.y
        local wdir = word.dir
        local wdx = dirs8[wdir][1]
        local wdy = dirs8[wdir][2]
        if param.name == "her" then
          if unit.x ~= wx+wdx or unit.y ~= wy+wdy then
            result = false
          end
        elseif param.name == "thr" then
          local wtx,wty = wx+wdx,wy+wdy
          local stopped = false
          while not stopped do
            if canMove(unit,wdx,wdy,wdir,false,false,nil,nil,nil,wtx,wty) then
              wdx,wdy,wdir,wtx,wty = getNextTile(word, wdx, wdy, wdir, nil, wtx, wty)
            else
              stopped = true
            end
          end
          if unit.x ~= wtx or unit.y ~= wty then
            result = false
          end
        elseif param.name == "rithere" then
          if unit.x ~= wx or unit.y ~= wy then
            result = false
          end
        else
          if not hasRule(unit,verb,param.name) then
            result = false
            break
          end
        end
      end
    elseif condtype == "w/fren" then
      if unit == outerlvl then
        for _,other in ipairs(sets) do
          local found = false
          for _,fren in ipairs(units) do
            if inBounds(fren.x,fren.y) and other[fren] then
              found = true
              break
            end
          end
          if not found then
            result = false
            break
          end
        end
        --something something surrounds maybe?
        --[[if unit == outerlvl and surrounds ~= nil and surrounds_name == level_name then
          --use surrounds to remember what was around the level
          for __,on in ipairs(surrounds[0][0]) do
            if nameIs(on, param) then
              table.insert(others, on)
            end
          end]]
        for _,other in ipairs(lists) do
          if #other == 0 then
            result = false
            break
          end
        end
      else
        local frens = getUnitsOnTile(x, y, nil, false, unit, true, hasProperty(unit,"big"))
        for _,other in ipairs(sets) do
          if other[outerlvl] then
            if not inBounds(unit.x,unit.y) then
              result = false
            end
          else
            local found = false
            for _,fren in ipairs(frens) do
              if other[fren] then
                found = true
                break
              end
            end
            if not found then
              result = false
              break
            end
          end
        end
      end
    elseif condtype:ends("arond") then
      --Vitellary: Deliberately ignore the tile we're on. This is different from baba.
      local others = {}
      for i=-1,1 do
        others[i] = {}
        for j=-1,1 do
          others[i][j] = {}
        end
      end
      local found = false
      for ndir=1,8 do
        local nx, ny = dirs8[ndir][1], dirs8[ndir][2]
        if unit == outerlvl then
          if surrounds ~= nil and surrounds_name == level_name then
            --use surrounds to remember what was around the level
            for __,on in ipairs(surrounds[nx][ny]) do -- this part hasn't been updated, but it's not important yet
              if nameIs(on, param) then
                others[nx][ny] = on
              end
            end
          end
        else
          local dx, dy, dir, px, py = getNextTile(unit, nx, ny, ndir)
          others[nx][ny] = getUnitsOnTile(px, py, nil, false, unit, true, hasProperty(unit,"big"))
        end
      end
      for i=1,8 do
        if (condtype == "arond") or (condtype == "ortho arond" and i%2==1) or (condtype == "diag arond" and i%2==0) or (condtype == dirs8_by_name[i].." arond") or (condtype == "spin"..i.." arond") then
          local nx,ny
          if (condtype == "spin"..i.." arond") then
            local j = (i+unit.dir+3)%8+1
            nx,ny = dirs8[j][1],dirs8[j][2]
          else
            nx,ny = dirs8[i][1],dirs8[i][2]
          end
          for _,set in ipairs(sets) do
            for _,other in ipairs(others[nx][ny]) do
              if set[other] then
                found = true
                break
              end
            end
          end
        end
      end
      if not found then
        result = false
      end
    elseif condtype == "seen by" then
      local others = {}
      for ndir=1,8 do
        local nx, ny = dirs8[ndir][1], dirs8[ndir][2]
        if unit == outerlvl and surrounds ~= nil and surrounds_name == level_name then
          --use surrounds to remember what was around the level
          for __,on in ipairs(surrounds[nx][ny]) do -- this part hasn't been updated, but it's not important yet
            if nameIs(on, param) then
              table.insert(others, on)
            end
          end
        else
          local dx, dy, dir, px, py = getNextTile(unit, nx, ny, ndir)
          mergeTable(others, getUnitsOnTile(px, py, nil, false, unit, true, hasProperty(unit,"big")))
        end
      end
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
        for _,set in ipairs(sets) do
          local found = false
          for _,other in ipairs(others) do
            if set[other] then
              local dx, dy, dir, px, py = getNextTile(other, dirs8[other.dir][1], dirs8[other.dir][2], other.dir)
              if px == unit.x and py == unit.y then
                found = true
                break
              end
            end
          end
          if not found then
            result = false
            break
          end
        end
      end
    elseif condtype == "look at" then
      --TODO: look at dir, ortho, diag, surrounds
      if unit ~= outerlvl then
        local dx, dy, dir, px, py = getNextTile(unit, dirs8[unit.dir][1], dirs8[unit.dir][2], unit.dir)
        local frens = getUnitsOnTile(px, py, param, false, unit, nil, hasProperty(unit,"big"))
        for i,other in ipairs(sets) do
          local isdir = false
          if cond.others[i].name == "ortho" then
            isdir = true
            if (unit.dir % 2 == 0) then
              result = false
              break
            end
          elseif cond.others[i].name == "diag" then
            isdir = true
            if (unit.dir % 2 == 1) then
              result = false
              break
            end
          elseif cond.others[i].name:starts("spin") then
            isdir = true
            if (cond.others[i].name ~= "spin8") then
              result = false
              break
            end
          else
            for j = 1,8 do
              if cond.others[i].name == dirs8_by_name[j] then
                isdir = true
                if unit.dir ~= j then
                  result = false
                  break
                end
              end   
            end
          end
          if not isdir then
            if other[outerlvl] then
              if not inBounds(px,py) then
                result = false
                break
              end
            else
              local found = false
              for _,fren in ipairs(frens) do
                if other[fren] then
                  found = true
                  break
                end
              end
              if not found then
                result = false
                break
              end
            end
          end
        end
      else --something something surrounds
        result = false
      end
    elseif condtype == "look away" then
      --TODO: look at dir, ortho, diag, surrounds
      if unit ~= outerlvl then
        local dx, dy, dir, px, py = getNextTile(unit, -dirs8[unit.dir][1], -dirs8[unit.dir][2], unit.dir)
        local frens = getUnitsOnTile(px, py, param, false, unit, nil, hasProperty(unit,"big"))
        for _,other in ipairs(sets) do
          if other[outerlvl] then
              local dx, dy, dir, px, py = getNextTile(unit, dirs8[unit.dir][1], dirs8[unit.dir][2], unit.dir)
              if inBounds(px,py) then
                result = false
                break
              end
          else
            local found = false
            for _,fren in ipairs(frens) do
              if other[fren] then
                found = true
                break
              end
            end
            if not found then
              result = false
              break
            end
          end
        end
      else --something something surrounds
        result = false
      end
    elseif condtype == "behind" then
      local others = {}
      for ndir=1,8 do
        local nx, ny = dirs8[ndir][1], dirs8[ndir][2]
        if unit == outerlvl and surrounds ~= nil and surrounds_name == level_name then
          --use surrounds to remember what was around the level
          for __,on in ipairs(surrounds[nx][ny]) do -- this part hasn't been updated, but it's not important yet
            if nameIs(on, param) then
              table.insert(others, on)
            end
          end
        else
          local dx, dy, dir, px, py = getNextTile(unit, nx, ny, ndir)
          mergeTable(others, getUnitsOnTile(px, py, nil, false, unit, true, hasProperty(unit,"big")))
        end
      end
      if unit == outerlvl then --basically turns into sans n't BUT the unit's rear has to be looking inbounds as well!
        for _,param in ipairs(params) do
          local found = false
          local others = findUnitsByName(param)
          for _,on in ipairs(others) do
            if inBounds(on.x + -dirs8[on.dir][1], on.y + -dirs8[on.dir][2]) then
              found = true
              break
            end
          end
          if unit == outerlvl and surrounds ~= nil and surrounds_name == level_name then
            --use surrounds to remember what was around the level
            for nx=-1,1 do
              for ny=-1,1 do
                for __,on in ipairs(surrounds[nx][ny]) do
                  if nameIs(on, param) and nx + -dirs8[on.dir][1] == 0 and ny + -dirs8[on.dir][2] == 0 then
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
        for _,set in ipairs(sets) do
          local found = false
          for _,other in ipairs(others) do
            if set[other] then
              local dx, dy, dir, px, py = getNextTile(other, -dirs8[other.dir][1], -dirs8[other.dir][2], other.dir)
              if px == unit.x and py == unit.y then
                found = true
                break
              else
                -- print(unit.x, unit.y)
                -- print(px, py)
              end
            end
          end
          if not found then
            result = false
            break
          end
        end
      end
    elseif condtype == "beside" then
      local others = {}
      for ndir=1,8 do
        local nx, ny = dirs8[ndir][1], dirs8[ndir][2]
        if unit == outerlvl and surrounds ~= nil and surrounds_name == level_name then
          --use surrounds to remember what was around the level
          for __,on in ipairs(surrounds[nx][ny]) do -- this part hasn't been updated, but it's not important yet
            if nameIs(on, param) then
              table.insert(others, on)
            end
          end
        else
          local dx, dy, dir, px, py = getNextTile(unit, nx, ny, ndir)
          mergeTable(others, getUnitsOnTile(px, py, nil, false, unit, true, hasProperty(unit,"big")))
        end
      end
      if unit == outerlvl then --basically turns into sans n't BUT the unit's side has to be looking inbounds as well!
        for _,param in ipairs(params) do
          local found = false
          local others = findUnitsByName(param)
          for _,on in ipairs(others) do
            if inBounds(on.x - dirs8[on.dir][2], on.y + dirs8[on.dir][1]) or inBounds(on.x + dirs8[on.dir][2], on.y - dirs8[on.dir][1]) then
              found = true
              break
            end
          end
          if unit == outerlvl and surrounds ~= nil and surrounds_name == level_name then
            --use surrounds to remember what was around the level
            for nx=-1,1 do
              for ny=-1,1 do
                for __,on in ipairs(surrounds[nx][ny]) do
                  if nameIs(on, param) and ((nx - dirs8[on.dir][2] == 0 and ny + dirs8[on.dir][1] == 0) or (nx + dirs8[on.dir][2] == 0 and ny - dirs8[on.dir][1] == 0)) then
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
        for _,set in ipairs(sets) do
          local found = false
          for _,other in ipairs(others) do
            if set[other] then
              local dx, dy, dir, px, py = getNextTile(other, dirs8[other.dir][2], -dirs8[other.dir][1], other.dir)
              local dx, dy, dir, qx, qy = getNextTile(other, -dirs8[other.dir][2], dirs8[other.dir][1], other.dir)
              if px == unit.x and py == unit.y or qx == unit.x and qy == unit.y then
                found = true
                break
              end
            end
          end
          if not found then
            result = false
            break
          end
        end
      end
    elseif condtype == "sans" then
      for _,other in ipairs(lists) do
        if #other > 1 or #other == 1 and other[1] ~= unit then
          result = false
          break
        end
      end
    elseif condtype == "frenles" then
      if unit == outerlvl then --no longer by definition, since you can technically have the rules be oob!
        local found = false
        for _,fren in ipairs(units) do
          if inBounds(fren.x,fren.y) then
            found = true
            break
          end
        end
        if found then result = false end
      else
        local others = getUnitsOnTile(unit.x, unit.y, nil, false, unit, nil, hasProperty(unit,"big"))
        if #others > 0 then
          result = false
        end
      end
    elseif condtype == "wait..." then
      result = last_move ~= nil and last_move[1] == 0 and last_move[2] == 0 and last_click_x == nil and last_click_y == nil
    elseif condtype == "mayb" then
      local cond_unit = cond.unit
      --add a dummy action so that undoing happens
      if (#undo_buffer > 0 and #undo_buffer[1] == 0) then
        addUndo({"dummy"})
      end
      rng = deterministicRng(unit, cond.unit)
      result = (rng*100) < threshold_for_dir[cond.unit.dir]
    elseif condtype == "an" then
      local cond_unit = cond.unit
      --add a dummy action so that undoing happens
      if (#undo_buffer > 0 and #undo_buffer[1] == 0) then
        addUndo({"dummy"})
      end
      rng = deterministicRandom(unit.fullname, cond.unit)
      result = unit.id == rng
    elseif condtype == "lit" then
      --TODO: make it so if there are many lit objects then you cache FoV instead of doing many individual LoSes
      -- result = false
      -- if (successful_brite_cache ~= nil) then
      --   local cached = units_by_id[successful_brite_cache]
      --   if cached ~= nil and hasProperty(cached, "brite") and hasLineOfSight(cached, unit) then
      --     result = true
      --   end
      -- end
      -- if not result then
      --   --I am tempted to make it so N levels of BRITE can penetrate N-1 layers of OPAQUE but this mechanic would be too... opaque :drum:
      --   local others = getUnitsWithEffect("brite")
      --   for _,on in ipairs(others) do
      --     if hasLineOfSight(on, unit) then
      --       successful_brite_cache = on.id
      --       result = true
      --       break
      --     end
      --   end
      -- end
      if not ignoreCheck(unit,nil,"brite") or not ignoreCheck(unit,nil,"torc") then
        result = false
      elseif unit == outerlvl then
        local lights = getUnitsWithEffect("brite")
        mergeTable(lights,getUnitsWithEffect("torc"))
        local lit = false
        for _,light in ipairs(lights) do
          if inBounds(light.x,light.y) and sameFloat(light,outerlvl) then
            lit = true
            break
          end
        end
        result = lit
      else
        if inBounds(unit.x,unit.y) then
          if (lightcanvas == nil) then calculateLight() end
          local pixelData = lightcanvas:newImageData(1, 1, unit.x*32+15, unit.y*32+15, 2, 2)
          local r1 = pixelData:getPixel(0, 0)
          local r2 = pixelData:getPixel(0, 1)
          local r3 = pixelData:getPixel(1, 0)
          local r4 = pixelData:getPixel(1, 1)
          result = (r1+r2+r3+r4 >= 2)
        else result = false end
      end
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
    elseif main_palette_for_colour[condtype] then
      local colour = unit.color_override or unit.color
      if unit.fullname == "no1" then
        result = false
      elseif unit.rave or unit.colrful or unit.gay then
        if condtype == "blacc" or condtype == "whit" or condtype == "graey" or condtype == "brwn" then
          result = false
        else
          result = true
        end
      elseif unit.tranz then
        if not (condtype == "cyeann" or condtype == "whit" or condtype == "pinc") then
          result = false
        else
          result = true
        end
      elseif unit.enby then
        if not (condtype == "yello" or condtype == "whit" or condtype == "purp" or condtype == "blacc" or condtype == "graey") then
          result = false
        else
          result = true
        end
      else
        result = matchesColor(getUnitColors(unit), condtype)
      end
    elseif condtype == "the" then
      local the = cond.unit
      
      local tx = the.x
      local ty = the.y
      local dir = the.dir
      local dx = dirs8[dir][1]
      local dy = dirs8[dir][2]
      
      dx,dy,dir,tx,ty = getNextTile(the,dx,dy,dir)
      result = ((unit.x == tx) and (unit.y == ty))
    elseif condtype == "unlocked" then
      if unit.name == "lvl" and unit.special.visibility ~= "open" then
        result = false
      end
      if unit.name == "lin" and unit.special.pathlock and unit.special.pathlock ~= "none" then
        result = false
      end
    elseif condtype == "wun" then
      local name = unit.special.level or level_filename
      result = readSaveFile{"levels",name,"won"}
    elseif condtype == "past" then
      if cond_not then
        result = doing_past_turns
      else
        result = false
      end
    elseif condtype == "samefloat" then
      result = sameFloat(unit, compare_with)
    elseif condtype == "samepaint" then
      result = matchesColor(getUnitColors(unit), getUnitColors(compare_with))
    elseif condtype == "sameface" then
      result = unit.dir == compare_with.dir
    elseif condtype == "oob" then
      result = not inBounds(unit.x,unit.y)
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
  if not sameFloat(brite, lit) or not ignoreCheck(lit, brite, "brite") or not ignoreCheck(lit, nil, "torc") then
    return false
  end
  if (rules_with["tranparnt"] == nil) then
    return true
  end
  --https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
  local x0, y0, x1, y1 = brite.x, brite.y, lit.x, lit.y
  local dx = x1 - x0
  local dy = y1 - y0
  if (dx == 0 and dy == 0) then return true end
  if (math.abs(dx) > math.abs(dy)) then
    local derr = math.abs(dy / dx)
    local err = 0
    local y = y0
    local found_opaque = false
    for x = x0, x1, sign(dx) do
      if found_opaque then return false end
      if x ~= x0 or y ~= y0 then
        for _,v in ipairs(getUnitsOnTile(x, y)) do
          if hasProperty(v, "tranparnt") and ignoreCheck(brite, v, "tranparnt") then
            found_opaque = true
            break
          end
        end
      end
      err = err + derr
      if err >= 0.5 then
        y = y + sign(dy)
        err = err - 1
      end
    end
  elseif (math.abs(dy) > math.abs(dx)) then
    local derr = math.abs(dx / dy)
    local err = 0
    local x = x0
    local found_opaque = false
    for y = y0, y1, sign(dy) do
      if found_opaque then return false end
      if x ~= x0 or y ~= y0 then
        for _,v in ipairs(getUnitsOnTile(x, y)) do
          if hasProperty(v, "tranparnt") and not ignoreCheck(brite, v, "tranparnt") then
            found_opaque = true
            break
          end
        end
      end
      err = err + derr
      if err >= 0.5 then
        x = x + sign(dx)
        err = err - 1
      end
    end
  else --both equal
    local x = x0
    local found_opaque = false
    for y = y0, y1, sign(dy) do
      if x ~= x0 or y ~= y0 then
        if found_opaque then return false end
        for _,v in ipairs(getUnitsOnTile(x, y)) do
          if hasProperty(v, "tranparnt") and not ignoreCheck(brite, v, "tranparnt") then
            found_opaque = true
            break
          end
        end
      end
      x = x + sign(dx)
    end
  end
  return true
end

lightcanvas = nil
temp_lightcanvas = nil
lightcanvas_width = 0
lightcanvas_height = 0

torc_angles = {20,30,45,60,75,90,120,150,180,225,270,315,360}
function calculateLight()
  lights_ignored_opaque = {}
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
  local opaques = getUnitsWithEffect("tranparnt")
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
          love.graphics.polygon("fill", cx, cy, ex, cy+math.tan(angle1)*(cx-ex), ex, 0, 0, 0, 0, cy+math.tan(angle2)*cx)
        else
          love.graphics.polygon("fill", cx, cy, ex, cy+math.tan(angle1)*(cx-ex), ex, 0, 0, 0, 0, ey, cx-(ey-cy)/math.tan(angle2), ey)
        end
      elseif angle1 < ul then
        if angle2 < ur or angle2 > dr then
          love.graphics.polygon("fill", cx, cy, cx+cy/math.tan(angle1), 0, 0, 0, 0, ey, ex, ey, ex, cy+math.tan(angle2)*(cx-ex))
        elseif angle2 < ul then
          love.graphics.polygon("fill", cx, cy, cx+cy/math.tan(angle1), 0, cx+cy/math.tan(angle2), 0)
        elseif angle2 < dl then
          love.graphics.polygon("fill", cx, cy, cx+cy/math.tan(angle1), 0, 0, 0, 0, cy+math.tan(angle2)*cx)
        else
          love.graphics.polygon("fill", cx, cy, cx+cy/math.tan(angle1), 0, 0, 0, 0, ey, cx-(ey-cy)/math.tan(angle2), ey)
        end
      elseif angle1 < dl then
        if angle2 < ur or angle2 > dr then
          love.graphics.polygon("fill", cx, cy, 0, cy+math.tan(angle1)*cx, 0, ey, ex, ey, ex, cy+math.tan(angle2)*(cx-ex))
        elseif angle2 < ul then
          love.graphics.polygon("fill", cx, cy, 0, cy+math.tan(angle1)*cx, 0, ey, ex, ey, ex, 0, cx+cy/math.tan(angle2), 0)
        elseif angle2 < dl then
          love.graphics.polygon("fill", cx, cy, 0, cy+math.tan(angle1)*cx, 0, cy+math.tan(angle2)*cx)
        else
          love.graphics.polygon("fill", cx, cy, 0, cy+math.tan(angle1)*cx, 0, ey, cx-(ey-cy)/math.tan(angle2), ey)
        end
      else
        if angle2 < ur or angle2 > dr then
          love.graphics.polygon("fill", cx, cy, cx-(ey-cy)/math.tan(angle1), ey, ex, ey, ex, cy+math.tan(angle2)*(cx-ex))
        elseif angle2 < ul then
          love.graphics.polygon("fill", cx, cy, cx-(ey-cy)/math.tan(angle1), ey, ex, ey, ex, 0, cx+cy/math.tan(angle2), 0)
        elseif angle2 < dl then
          love.graphics.polygon("fill", cx, cy, cx-(ey-cy)/math.tan(angle1), ey, ex, ey, ex, 0, 0, 0, 0, cy+math.tan(angle2)*cx)
        else
          love.graphics.polygon("fill", cx, cy, cx-(ey-cy)/math.tan(angle1), ey, cx-(ey-cy)/math.tan(angle2), ey)
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
    if lights_ignored_opaque[source.id .. ":" ..opaque.id] == nil then
      lights_ignored_opaque[source.id .. ":" ..opaque.id] = not ignoreCheck(source, opaque, "tranparnt")
    end
    if lights_ignored_opaque[source.id .. ":" ..opaque.id] then
      -- the flood of light is unstoppable
    elseif opaque.x == source.x and opaque.y == source.y then
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

threshold_for_dir = {50, 0.01, 0.1, 1, 2, 5, 10, 25}

function deterministicRandom(fullname, cond)
  --have to adjust #undo_buffer by 1 during undoing since we're in the process of rewinding to the previous turn
  local key = fullname..","..tostring(cond.x)..","..tostring(cond.y)..","..tostring(cond.dir)..","..tostring(undoing and #undo_buffer - 1 or #undo_buffer)
  if rng_cache[key] == nil then
    local arbitrary_unit_key = math.random()
    local arbitrary_unit = units_by_name[fullname][math.floor(arbitrary_unit_key*#units_by_name[fullname])+1]
    rng_cache[key] = arbitrary_unit.id
  end
  return rng_cache[key]
end

function deterministicRng(unit, cond)
  --have to adjust #undo_buffer by 1 during undoing since we're in the process of rewinding to the previous turn
  local key = unit.name..","..tostring(unit.x)..","..tostring(unit.y)..","..tostring(unit.dir)..","..tostring(cond.x)..","..tostring(cond.y)..","..tostring(cond.dir)..","..tostring(undoing and #undo_buffer - 1 or #undo_buffer)
  if rng_cache[key] == nil then
     rng_cache[key] = math.random()
  end
  return rng_cache[key]
end

function inBounds(x,y,getting)
  if getting then
    return x >= 0 and x < mapwidth and y >= 0 and y < mapheight
  end
  if not selector_open then
    if x >= 0 and x < mapwidth and y >= 0 and y < mapheight then
      local borders = getUnitsOnTile(x,y)
      if borders ~= nil then
        for _,unit in ipairs(borders) do
          if unit.name == "bordr" then
            return false
          end
        end
      end
      return true
    else
      return false
    end
  else
    return x >=0 and x < tile_grid_width and y >= 0 and y < tile_grid_height
  end
end

function inScreen(x,y)
  local xmin,xmax,ymin,ymax = getCorners()
  
  return x >= xmin and x <= xmax and y >= ymin and y <= ymax
end

function getCorners()
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()
  local xmin,ymin = screenToGameTile(1,1)
  local xmax,ymax = screenToGameTile(width-1,height-1)
  
  return xmin,xmax,ymin,ymax
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
  return unit.name == name or unit.fullname == name or (group_sets[name] and group_sets[name][unit])
end

function tileHasUnitName(name,x,y)
  for _,v in ipairs(unitsByTile(x, y)) do
    if nameIs(v, name) then
      return true
    end
  end
end

function getUnitsOnTile(x,y,name,not_destroyed,exclude,checkmous,big)
  local result = {}
  for _,unit in ipairs(unitsByTile(x, y)) do
    if unit ~= exclude then
      if not not_destroyed or (not_destroyed and not unit.removed) then
        if not name or (name and nameIs(unit, name)) then
          table.insert(result, unit)
        end
      end
    end
  end
  if big then
    for i=1,3 do
      for _,unit in ipairs(unitsByTile(x+i%2,y+math.floor(i/2))) do
        if unit ~= exclude then
          if not not_destroyed or (not_destroyed and not unit.removed) then
            if not name or (name and nameIs(unit, name)) then
              table.insert(result, unit)
            end
          end
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
  if (#unitsByTile(x, y) == 0 and (name == "no1" or name == nil) and inBounds(x, y, true) and empties_by_tile[x + y * mapwidth] ~= exclude) then
    table.insert(result, empties_by_tile[x + y * mapwidth])
  end
  return result
end

function getCursorsOnTile(x, y, not_destroyed, exclude)
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

function copyTable(t, l_)
  if t == nil then return t end
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
      o = {fullname = o.textname, id = o.id, x = o.x, y = o.y, dir = o.dir}
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
        s = s .. tostring(k) .. ' = ' .. fullDump(v, nr)
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
        local tbl = {fullname = o.textname, id = o.id, x = o.x, y = o.y, dir = o.dir}
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

function addParticles(ptype,x,y,color,count)
  if doing_past_turns and not do_past_effects then return end
  
  if not settings["particles_on"] then return end
  
  if type(color[1]) == "table" then color = color[1] end
  if ptype == "destroy" then
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
  elseif ptype == "rule" then
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
  elseif ptype == "bonus" then
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
  elseif ptype == "unwin" then
    local ps = love.graphics.newParticleSystem(sprites["sparkle"])
    local px = (x + 0.5) * TILE_SIZE
    local py = (y + 0.5) * TILE_SIZE
    ps:setPosition(px, py)
    ps:setSpread(0.4)
    ps:setEmissionArea("uniform", TILE_SIZE*3/4, TILE_SIZE*3/4, 0, true)
    ps:setSizes(0.40, 0.40, 0.40, 0)
    ps:setSpeed(-40)
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
  elseif ptype == "love" then
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
  elseif ptype == "slep" then
    local ps = love.graphics.newParticleSystem(sprites["letter_z"])
    local px = (x + 1) * TILE_SIZE
    local py = y * TILE_SIZE
    ps:setPosition(px, py)
    ps:setSpread(0)
    ps:setEmissionArea("borderrectangle", 0, 0, 0, true)    
    ps:setSizes(0.5, 0.5, 0.5, 0)
    ps:setSpeed(10)
    ps:setLinearAcceleration(0,-50)
    ps:setParticleLifetime(2)
    if #color == 2 then
      ps:setColors(getPaletteColor(color[1], color[2]))
    else
      ps:setColors(color[1]/255, color[2]/255, color[3]/255, (color[4] or 255)/255)
    end
    ps:start()
    ps:emit(count or 10)
    table.insert(particles, ps)
  elseif ptype == "sing" then
    local ps = love.graphics.newParticleSystem(sprites["noet"])
    local px = (x + 1) * TILE_SIZE
    local py = y * TILE_SIZE
    ps:setPosition(px, py)
    ps:setSpread(0)
    ps:setEmissionArea("borderrectangle", 0, 0, 0, true)    
    ps:setSizes(0.5, 0.5, 0.5, 0)
    ps:setSpeed(10)
    ps:setLinearAcceleration(0,-50)
    ps:setParticleLifetime(2)
    if #color == 2 then
      ps:setColors(getPaletteColor(color[1], color[2]))
    else
      ps:setColors(color[1]/255, color[2]/255, color[3]/255, (color[4] or 255)/255)
    end
    ps:start()
    ps:emit(count or 10)
    table.insert(particles, ps)
  elseif ptype == "movement-puff" then
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
    if type(color[1]) == "table" then
      ps:setColors(getPaletteColor(color[1][1], color[1][2]))
    else
      if #color == 2 then
        ps:setColors(getPaletteColor(color[1], color[2]))
      else
        ps:setColors(color[1]/255, color[2]/255, color[3]/255, (color[4] or 255)/255)
      end
    end
    ps:start()
    ps:emit(count or 1)
    table.insert(particles, ps)
  elseif ptype == "sing" then
    local ps = love.graphics.newParticleSystem(sprites["noet"])
    local px = (x + 0.5) * TILE_SIZE
    local py = (y + 0.5) * TILE_SIZE
    local size = 0.2
    -- insert particles here
  end
end

function screenToGameTile(x, y, partial)
  if scene.getTransform then
    local transform = scene.getTransform()
    local mx,my = transform:inverseTransformPoint(x,y)
    local tilex = mx / TILE_SIZE
    local tiley = my / TILE_SIZE
    if not partial then
      tilex = math.floor(tilex)
      tiley = math.floor(tiley)
    end
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

function fullScreen()
  if not fullscreen then
    if not love.window.isMaximized( ) then
      winwidth, winheight = love.graphics.getDimensions( )
    end
    love.window.setMode(0, 0, {borderless=false})
    love.window.maximize( )
    fullscreen = true
  elseif fullscreen then
    love.window.setMode(winwidth, winheight, {borderless=false, resizable=true, minwidth=705, minheight=510})
    love.window.maximize()
    love.window.restore()
    fullscreen = false
  end
  settings["fullscreen"] = fullscreen
  saveAll()
  if scene ~= editor then
    scene.buildUI()
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
  if ignorefloat then
    return true
  else
    return (countProperty(a, "flye", true) == countProperty(b, "flye", true)) or hasProperty(a, "tall", true) or hasProperty(b, "tall", true)
  end
end

function ignoreCheck(unit, target, property)
  if not rules_with["ignor"] then
    return true
  elseif unit == target then
    return true
  elseif target and (hasRule(unit,"ignor",target) or hasRule(unit,"ignor",outerlvl) or hasRule(outerlvl,"ignor",target)) and (not property or (not hasRule(unit,"ignorn't",property) and not hasRule(outerlvl,"ignorn't",property))) then
    return false
  elseif property and (hasRule(unit,"ignor",property) or hasRule(outerlvl,"ignor",property)) and (not target or (not hasRule(unit,"ignorn't",target) and not hasRule(outerlvl,"ignorn't",target))) then
    return false
  end
  return true
end

function getPaletteColor(x, y, name_)
  local palette = palettes[name_ or current_palette] or palettes["default"]
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
      if ref ~= except and (ref == "text_n't" or not ref:ends("n't")) then
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
    if ref ~= except and (ref == "text_n't" or not ref:ends("n't")) then
      table.insert(result, ref)
    end
  end
  
  --print(except)
  --print(dump(result))
  return result
end

function renameDir(from, to, cur_)
  if from == to then
    return
  end
  local cur = cur_ or ""
  love.filesystem.createDirectory(to .. cur)
  for _,file in ipairs(love.filesystem.getDirectoryItems(from .. cur)) do
    if love.filesystem.getInfo(from .. cur .. "/" .. file, "directory") then
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
    if love.filesystem.getInfo(dir .. "/" .. file, "directory") then
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
  if doing_past_turns and not do_past_effects or not settings["shake_on"] then return end
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

function loadLevels(levels, mode, level_objs, xwx)
  if #levels == 0 then
    return
  end
  
  --setup stay ther
  stay_ther = nil
  if (rules_with ~= nil) and not xwx then
    stay_ther = {}
    local isstayther = getUnitsWithEffect("stay ther")
    for _,unit in ipairs(isstayther) do
      table.insert(stay_ther, unit)
    end
  end
  
  --setup surrounds
  surrounds = nil
  if (level_objs ~= nil) then
    surrounds = {}
    for i = -1,1 do
      surrounds[i] = {}
      for j = -1,1 do
        surrounds[i][j] = {}
        for _,lvl in ipairs(level_objs) do
          for __,stuff in ipairs(getUnitsOnTile(lvl.x+i,lvl.y+j,nil,false,lvl)) do
            table.insert(surrounds[i][j], stuff)
          end
        end
      end
    end
  end

  local dir = "levels/"
  if world ~= "" then dir = getWorldDir() .. "/" end

  maps = {}

  mapwidth = 0
  mapheight = 0
  --if we're entering a level object, then the level we were in is the parent
  parent_filename = level_objs ~= nil and level_filename or nil
  level_name = nil
  level_filename = nil

  for _,level in ipairs(levels) do
    local split_name = split(level, "/")

    local data
    if split_name[#split_name] ~= "{DEFAULT}" then
      data = json.decode(love.filesystem.read(dir .. level .. ".bab"))
    else
      data = json.decode(default_map)
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
      table.insert(maps, {data = loadstring("return " .. mapstr)(), info = data, file = level})
    else
      table.insert(maps, {data = mapstr, info = data, file = level})
    end

    icon_data = getIcon(dir .. level)

    table.remove(split_name)
    sub_worlds = split_name
  end

  if mode == "edit" then
    new_scene = editor
    if #maps == 1 and levels[1] ~= default_map then
      last_saved = maps[1].data
    else
      last_saved = nil
    end
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
  for _,unit in ipairs(cursors) do
    unit.new = false
  end
  new_units_cache = {}
end

function timecheck(unit,verb,prop)
  local zw_pass = false
  if timeless then
    if hasProperty(unit,"za warudo") then
      zw_pass = true
    elseif hasProperty(outerlvl,"za warudo") and not hasRule(unit,"ben't","za warudo") then
      zw_pass = true
    elseif verb and prop then
      local rulecheck = matchesRule(unit,verb,prop)
      for _,ruleparent in ipairs(rulecheck) do
        for i=1,#ruleparent.rule.subject.conds do
          if ruleparent.rule.subject.conds[i][1] == "timles" then
            zw_pass = true
          end
        end
      end
    end
  else
    zw_pass = true
  end
  local rhythm_pass = false
  if rules_with["rythm"] then
    if hasProperty(unit,"rythm") then
      rhythm_pass = true
    elseif hasProperty(outerlvl,"rythm") and not hasRule(unit,"ben't","rythm") then
      rhythm_pass = true
    end
    rhythm_pass = rhythm_pass == doing_rhythm_turn -- xnor
  else
    rhythm_pass = true
  end
  return zw_pass and rhythm_pass
end

function timecheckUs(unit)
  if timecheck(unit) then
    return true
  else
    local to_check = {"u","u too","u tres","y'all"}
    for _,prop in ipairs(to_check) do
      local rulecheck = matchesRule(unit,"be",prop)
      for _,ruleparent in ipairs(rulecheck) do
        for i=1,#ruleparent.rule.subject.conds do
          if ruleparent.rule.subject.conds[i][1] == "timles" then
            return true
          end
        end
      end
    end
  end
  return false
end

function fillTextDetails(sentence, old_sentence, orig_index, word_index)
  --print(#old_sentence, orig_index, word_index)
  --changes a sentence of pure text into a valid sentence.
  --print("what we started with:",dump(sentence))
  local ret = {}
  local w = 0
  for _,word in ipairs(sentence) do
    --print("sentence: "..fullDump(sentence))
    --print(text_list[word], old_sentence)
    local newname = text_list[word].name
    if newname:starts("text_") then
      newname = newname:sub(6)
    end
    table.insert(ret,{type = text_list[word].texttype or {object = true}, name = newname, unit=old_sentence[orig_index].unit})
    w = w+1
  end
  for i=orig_index+1,(word_index-1) do --extra ellipses for the purposes of making sure the parser gets it properly.
    --print("aa:",old_sentence[i])
    table.insert(ret,{type = text_list["..."].texttype or {object = true}, name = "...", unit=old_sentence[i].unit})
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

text_in_tiles = {} --list of text in an array, for ideal searching
for _,tile in ipairs(tiles_list) do
  if tile.type == "text" and not tile.texttype.letter then
    local textname = string.sub(tile.name:gsub("%s+", ""),6) --removes spaces too
    text_in_tiles[textname] = textname
    if (tile.alias ~= nil) then
      for a,ali in ipairs(tile.alias) do
        text_in_tiles[ali] = textname
      end
    end
  end
end

text_list = {} --list of text, but without aliases
for _,tile in ipairs(tiles_list) do
  if tile.type == "text" and not tile.texttype.letter then
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
  if (not unit_tests) then
    replay_string = replay_string..tostring(movex)..","..tostring(movey)..","..tostring(key)
    if (units_by_name["text_mous"] ~= nil or rules_with["mous"] ~= nil) then
      local cursor_table = {}
      for _,cursor in ipairs(cursors) do
        table.insert(cursor_table, {cursor.x, cursor.y})
      end
      replay_string = replay_string..","..love.data.encode("string", "base64", serpent.line(cursor_table))
    end
    replay_string = replay_string..";"
  end
end

local last_save_file_name = nil
local last_save_file = nil

function writeSaveFile(value, arg)
  --e.g. writeSaveFile(true, {"levels", "new level", "won"})
  if (unit_tests) then return false end
  save = {}
  local filename = world
  if (world == "" or world == nil) then
    filename = "levels"
  end
  filename = "profiles/"..profile.name.."/"..filename..".savebab"
  
  --cache save file until filename changes
  if (last_save_file_name ~= filename) then
    --print("changing in write:", filename, last_save_file_name)
    last_save_file_name = filename
      if love.filesystem.read(filename) ~= nil then
      save = json.decode(love.filesystem.read(filename))
    end
    last_save_file = save
  else
    save = last_save_file
  end
  
  if #arg > 0 then
    local current = save
    for i,category in ipairs(arg) do
      if i == #arg then break end
      if current[category] == nil then
        current[category] = {}
      end
      current = current[category]
    end
    current[arg[#arg]] = value
    love.filesystem.write(filename, json.encode(save))
  end
  return true
end

function readSaveFile(arg)
  --e.g. readSaveFile({"levels", "new level", "won"})
  if (unit_tests) then return nil end
  save = {}
  local filename = world
  if (world == "" or world == nil) then
    filename = "levels"
  end
  filename = "profiles/"..profile.name.."/"..filename..".savebab"
  
  --cache save file until filename changes
  if (last_save_file_name ~= filename) then
    --print("changing in read:", filename, last_save_file_name)
    last_save_file_name = filename
      if love.filesystem.read(filename) ~= nil then
      save = json.decode(love.filesystem.read(filename))
    end
    last_save_file = save
  else
    save = last_save_file
  end
  
  local current = save
  for i,key in ipairs(arg) do
    if current[key] == nil then return nil end
    current = current[key]
  end
  return current
end

function loadWorld(default)
  local new_levels = {}
  level_tree = readSaveFile{"level_tree"} or split(default, ",")
  new_levels = level_tree[1]
  table.remove(level_tree, 1)
  if type(new_levels) ~= "table" then
    new_levels = {new_levels}
  end
  in_world = true
  loadLevels(new_levels, "play")
end

function saveWorld()
  local new_tree = deepCopy(level_tree)
  table.insert(new_tree, 1, getMapEntry())
  writeSaveFile(new_tree, {"level_tree"})
end

function getMapEntry()
  if #maps == 1 then
    return maps[1].file or maps[1].info.name
  else
    local t = {}
    for _,map in ipairs(maps) do
      table.insert(t, map.file or map.info.name)
    end
    return t
  end
end

function addBaseRule(subject, verb, object, subjcond)
  addRule({
    rule = {
      subject = {
        name = subject,
        conds = {subjcond}
      },
      verb = {
        name = verb
      },
      object = {
        name = object
      }
    },
    units = {},
    dir = 1,
    hide_in_list = true
  })
end

function addRuleSimple(subject, verb, object, units, dir)
  -- print(subject.name, verb.name, object.name)
  -- print(subject, verb, object)
  addRule({
    rule = {
      subject = getTableWithDefaults(copyTable(subject), {
        name = subject[1],
        conds = subject[2]
      }),
      verb = getTableWithDefaults(copyTable(verb), {
        name = verb[1]
      }),
      object = getTableWithDefaults(copyTable(object), {
        name = object[1],
        conds = object[2]
      })
    },
    units = units,
    dir = dir
  })
end


group_lists = {}
group_sets = {}

function updateGroup(n)
  --if not groups_exist then return end
  local n = n or 0
  local changed = false
  for _,group in ipairs(group_names) do
    local list = {}
    local set = {}
    if (rules_with[group] ~= nil) then
      local rules = matchesRule(nil, "be", group)
      for _,rule in ipairs(rules) do
        local unit = rule[2]
        --by doing it this way, conds has already been tested, etc
        set[unit] = true
      end
      local rulesnt = matchesRule(nil, "ben't", group)
      for _,rule in ipairs(rulesnt) do
        local unit = rule[2]
        set[unit] = nil
      end
    end
    for unit,_ in pairs(set) do
      table.insert(list, unit)
    end
    local old_size = #(group_lists[group] or {})
    group_lists[group] = list
    group_sets[group] = set
    if #group_lists[group] ~= old_size then
      changed = true
    end
  end
  if changed then
    if n >= 1000 then
      print("group infinite loop! (1000 attempts to update list)")
      destroyLevel("infloop")
    else
      updateGroup(n+1)
    end
  end
end

function namesInGroup(group)
  local result = {}
  local tbl = copyTable(referenced_objects)
  mergeTable(tbl, referenced_text)
  table.insert(tbl, "lvl");
  table.insert(tbl, "mous");
  table.insert(tbl, "no1");
  table.insert(tbl, "bordr");
  for _,v in ipairs(tbl) do
    local group_membership = matchesRule(v, "be", group);
    for _,r in ipairs(group_membership) do
      if (#(r.rule.subject.conds) == 0) then
        table.insert(result, v)
      else
        for _,u in ipairs(units_by_name[v] or {v}) do
          if testConds(u, r.rule.subject.conds) then
            table.insert(result, v)
            break
          end
        end
      end
    end
  end
  return result
end

function serializeRule(rule)
  local result = ""
  result = result..serializeUnit(rule.subject, true)
  result = result..serializeWord(rule.verb)
  result = result..serializeUnit(rule.object, true) -- there's no reason for separate serializeClass/Property since the structure is the same
  return result
end

function serializeUnit(unit, outer)
  local prefix = ""
  local infix = ""
  local name = serializeWord(unit)
  if not unit.conds then
    return name
  end
  for i,cond in ipairs(unit.conds) do
    if not cond.others or #cond.others == 0 then
      prefix = prefix..serializeWord(cond)
    else
      infix = infix..serializeWord(cond)
      local infix_other = ""
      for j,other in ipairs(cond.others) do
        infix_other = infix_other..serializeUnit(other)
        infix_other = infix_other.."& "
      end
      infix_other = infix_other:sub(1,-3) -- remove last &
      infix = infix..infix_other.."& "
    end
  end
  infix = infix:sub(1,-3) -- remove last &
  local full = prefix..name..infix
  if not outer and full:find("&", 1) then
    full = "("..full..")"
  end
  return full
end

function serializeWord(word)
  if word.unit and hasProperty(word.unit, "stelth") then return "" end
  local name = word.name
  while name:starts("text_") do
    name = name:sub(6).." txt"
  end
  return name.." "
end

function unitsByTile(x, y)
  if units_by_tile[x] == nil then
    units_by_tile[x] = {}
  end
  if units_by_tile[x][y] == nil then
    units_by_tile[x][y] = {}
  end
  --print(x, y, fullDump(units_by_tile[x][y]))
  return units_by_tile[x][y]
end

anagram_finder = {}
anagram_finder.enabled = false
-- anagram_finder.advanced = false
function anagram_finder.run()
  local letters = {}
  local multi = {}
  for _,unit in ipairs(units_by_name["text"]) do
    if unit.texttype.letter then
      if #unit.textname == 1 then
        letters[unit.textname] = (letters[unit.textname] or 0) + 1
      else
        table.insert(multi, unit.textname)
      end
    end
  end
  anagram_finder.words = {}
  for _,tile in ipairs(tiles_list) do
    if tile.type == "text" and not tile.texttype.letter then
      local word = tile.name:sub(6):gsub(" ","")
      local letters = copyTable(letters)
      local multi = copyTable(multi)
      local not_match = false
      for i = #multi,1,-1 do -- multi in middle
        local new = word:gsub(multi[i],"|") -- | instead of nothing so that you can't have another multi span the gap, e.g. frgoen - go = fren
        if new ~= word then
          word = new
          table.remove(multi, i)
        end
      end
      for i = #multi,1,-1 do -- multi at end
        local m = multi[i]
        local found = false
        for j = #m,1,-1 do
          local s = m:sub(1,j)
          if word:ends(s) then
            word = word:sub(1, #word-j).."|"
            found = true
            break
          end
        end
        if found then
          table.remove(multi, i)
          break
        end
      end
      for i = #multi,1,-1 do -- multi at start
        local m = multi[i]
        local found = false
        for j = 1,#m do
          local s = m:sub(j)
          if word:starts(s) then
            word = "|"..word:sub(#s+1)
            found = true
            break
          end
        end
        if found then
          table.remove(multi, i)
          break
        end
      end
      for i = 1, #word do
        local l = word:sub(i,i)
        if l ~= "|" then -- represents a multiletter that has been accounted for already
          if letters[l] and letters[l] > 0 then
            letters[l] = letters[l] - 1
          else
            not_match = true
            break
          end
        end
      end
      if not not_match then
        table.insert(anagram_finder.words, tile.name:sub(6))
      end
    end
  end
end

function drawCustomLetter(text, x, y, rot, sx, sy, ox, oy)
  love.graphics.push()
  love.graphics.translate(x or 0, y or 0)
  love.graphics.rotate(rot or 0)
  love.graphics.scale(sx or 1, sy or 1)
  love.graphics.translate(-(ox or 0), -(oy or 0))
  for i,q in ipairs(custom_letter_quads[#(text or "-")]) do
    local quad, dx, dy = unpack(q)
    love.graphics.draw(sprites["letters_"..(text:sub(i,i) or "a")] or sprites["wut"], quad, dx, dy)
  end
  love.graphics.pop()
end

function getPastConds(conds)
  local result = false
  local new_conds = {}
  for _,cond in ipairs(conds) do
    if cond.name == "past" then
      result = true
    else
      table.insert(new_conds, cond)
    end
  end
  return result, new_conds
end

function jprint(str)
  if just_moved then
    print(str)
  end
end

function getTheme()
  if not settings["themes"] then return nil end
  if cmdargs["theme"] then
    if cmdargs["theme"] == "" then
      return nil
    else
      return cmdargs["theme"]
    end
  else
    if os.date("%m") == "10" then
      return "halloween"
    elseif os.date("%m") == "12" then
      return "christmas"
    end
  end
  return nil
end

function getTableWithDefaults(o, default)
  o = o or {}
  for k,v in pairs(default) do
    if not o[k] then o[k] = v end
  end
  return o
end

function buildOptions()
  if not display then
    scene.addOption("music_on", "music", {{"on", true}, {"off", false}})
    scene.addOption("sfx_on", "sound", {{"on", true}, {"off", false}})
    scene.addButton("video options", function() display = true; scene.buildUI() end)
    scene.addButton("back", function() options = false; scene.buildUI() end)
  else
    scene.addOption("game_scale", "game scale", {{"auto", "auto"}, {"0.5x", 0.5}, {"1x", 1}, {"1.5x", 1.5}, {"2x", 2}, {"4x", 4}})
    scene.addOption("particles_on", "particle effects", {{"on", true}, {"off", false}})
    scene.addOption("shake_on", "shakes", {{"on", true}, {"off", false}})
    scene.addOption("scribble_anim", "animated scribbles", {{"on", true}, {"off", false}})
    scene.addOption("epileptic", "reduce flashes", {{"on", true}, {"off", false}})
    scene.addOption("grid_lines", "grid lines", {{"on", true}, {"off", false}})
    scene.addOption("mouse_lines", "mouse lines", {{"on", true}, {"off", false}})
    scene.addOption("stopwatch_effect", "stopwatch effect", {{"on", true}, {"off", false}})
    scene.addOption("fullscreen", "screen mode", {{"windowed", false}, {"fullscreen", true}}, function() fullScreen() end)
    scene.addOption("focus_pause", "pause on defocus", {{"on", true}, {"off", false}})
    if scene == menu then
      scene.addOption("scroll_on", "background scrolling", {{"on", true}, {"off", false}})
      scene.addOption("themes", "menu themes", {{"on", true}, {"off", false}})
    end
    scene.addButton("back", function() display = false; scene.buildUI() end)
  end
end

function split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function selectLastLevels()
  if not units_by_name["selctr"] then return end
  local selctrs = units_by_name["selctr"]

  local last_selected = readSaveFile{"levels", level_filename, "selected"} or {}
  if type(last_selected) ~= "table" then
    last_selected = {last_selected}
  end
  
  for i,level in ipairs(last_selected) do
    local selctr = selctrs[((i-1)%#selctrs)+1]
    for _,unit in ipairs(units) do
      if unit.special.level == level then
        moveUnit(selctr, unit.x, unit.y, nil, true)
      end
    end
  end
end

function getWorldDir(include_sub_worlds)
  if world == "" then
    return "levels"
  else
    local dir = world_parent .. "/" .. world
    if include_sub_worlds and #sub_worlds > 0 then
      dir = dir .. "/" .. table.concat(sub_worlds, "/")
    end
    return dir
  end
end

function searchForLevels(dir, search, exact)
  local results = {}
  local files = love.filesystem.getDirectoryItems(dir)

  for _,file in ipairs(files) do
    local info = love.filesystem.getInfo(dir .. "/" .. file)
    if info then
      if info.type == "directory" then
        for _,level in ipairs(searchForLevels(dir .. "/" .. file, search, exact)) do
          table.insert(results, {file = file .. "/" .. level.file, data = level.data})
        end
      elseif file:ends(".bab") then
        local name = file:sub(1, -5)
        local data = json.decode(love.filesystem.read(dir .. "/" .. file))
        local found = false
        if (not search) or (exact and name == search) or (not exact and string.find(name, search)) then
          found = true
        elseif (not search) or (exact and data.name == search) or (not exact and string.find(data.name, search)) then
          found = true
        end
        if found then
          table.insert(results, {file = name, data = data})
        end
      end
    end
  end

  return results
end

-- i was originally making this to use .icon as an alternate icon format for official world saving but i figured out how to save pngs directly so this is a tiny function that serves almost no purpose now and also this comment is really long if you don't have wrapping then your scrollbar is huge now you're welcome
function getIcon(path)
  if love.filesystem.getInfo(path .. ".png") then
    return love.graphics.newImage(path .. ".png")
  end
end

function getUnitColors(unit, index, override_)
  local override = override_ or unit.color_override
  local colors = type(unit.color[1]) == "table" and unit.color or {unit.color}
  if index then
    if override then
      if not unit.colored or unit.colored[index] == true then
        return override
      elseif type(unit.colored[index]) == "table" and eq(override, colors[index]) then
        return unit.colored[index]
      end
      return colors[index]
    else
      return colors[index]
    end
  elseif override then
    colors = copyTable(colors)
    for i,_ in ipairs(colors) do
      if not unit.colored or unit.colored[i] == true then
        return override
      elseif type(unit.colored[i]) == "table" and eq(override, colors[i]) then
        return unit.colored[i]
      end
    end
    print(dump(colors))
    return colors
  else
    return colors
  end
end

-- logic for how this function works:
-- nil checks (both nil -> true, one nil -> false)
-- loop for colors in a if there are multiple
-- loop for colors in b if there are multiple
-- actually compare the color
function matchesColor(a, b, exact)
  if not a ~= not b then return false end
  if not a and not b then return true end
  if type(a) == "table" and type(a[1]) ~= "number" then
    for _,c in ipairs(a) do
      if matchesColor(c, b, exact) then return true end
    end
    return false
  end
  if type(b) == "table" and type(b[1]) ~= "number" then
    for _,c in ipairs(b) do
      if matchesColor(a, c, exact) then return true end
    end
    return false
  end
  if exact then
    if type(a) == "string" then
      a = main_palette_for_colour[a]
    end
    if type(b) == "string" then
      b = main_palette_for_colour[b]
    end
    if #a == 2 and #b == 2 then
      return a[1] == b[1] and a[2] == b[2]
    end
    -- just in case
    if #a == 3 then
      a = getPaletteColor(unpack(a))
    end
    if #b == 3 then
      b = getPaletteColor(unpack(a))
    end
    return a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
  else
    if type(a) == "table" then
      if #a == 2 then
        a = colour_for_palette[a[1]][a[2]]
      else
        return false -- I don't want to deal with this right now
      end
    end
    if type(b) == "table" then
      if #b == 2 then
        b = colour_for_palette[b[1]][b[2]]
      else
        return false -- I don't want to deal with this right now
      end
    end
    print(a, b)
    return a == b
  end
end
