--format: {unit = unit, type = "update", payload = {x = x, y = y, dir = dir}} 
update_queue = {}
walkdirchangingrulesexist = false
sliderulesexist = false

movedebugflag = false
function movedebug(message)
  if movedebugflag then
    print(message)
  end
end

function doUpdate(already_added, moving_units_next)
  local sliders = {}
  for _,update in ipairs(update_queue) do
    if update.reason == "update" then
      local unit = update.unit
      local x = update.payload.x
      local y = update.payload.y
      local dir = update.payload.dir
      local portal = update.payload.portal
      local geometry_spin = update.payload.geometry_spin
      if (sliderulesexist) then
        table.insert(sliders, unit)
      end
      local changedDir = updateDir(unit, dir)
      if not changedDir then
        updateDir(unit, dirAdd(dir, geometry_spin), true)
      end
      --movedebug("doUpdate:"..tostring(unit.fullname)..","..tostring(x)..","..tostring(y)..","..tostring(dir))
      moveUnit(unit, x, y, update.payload.portal)
      unit.already_moving = false
    elseif update.reason == "dir" then
      local unit = update.unit
      local dir = update.payload.dir
      unit.olddir = unit.dir
      updateDir(unit, dir)
    end
  end
  for _,unit in ipairs(sliders) do
    applySlide(unit, already_added, moving_units_next)
  end
  update_queue = {}
end

function doDirRules()
  --Algorithm: Similar to COPCAT, we add up all direction rules that apply. Then the final direction is what the unit faces. If it's 0,0 then nothing happens. Numbers are clamped to -1,1.
  units_to_change = {}
  for k,v in pairs(dirs8_by_name) do
    local isdir = getUnitsWithEffect(v)
    for _,unit in ipairs(isdir) do
      if (units_to_change[unit] == nil) then
        units_to_change[unit] = {0, 0}
      end
      units_to_change[unit][1] = units_to_change[unit][1] + dirs8[k][1]
      units_to_change[unit][2] = units_to_change[unit][2] + dirs8[k][2]
    end
  end
  
  for unit,dir in pairs(units_to_change) do
    if dir[1] ~= 0 or dir[2] ~= 0 then
      k = dirs8_by_offset[sign(dir[1])][sign(dir[2])]
      if unit.dir ~= k then
        addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
      end
      updateDir(unit, k)
    end
  end
  
  doSpinRules(units_to_change)
end

function doSpinRules(units_to_change)
  --technically spin0/spin8 does nothing, so skip it
  --TODO: redo to work as if it was a go^
  for i=1,7 do
    local isspin = getUnitsWithEffectAndCount("spin" .. tostring(i))
    for unit,amt in pairs(isspin) do
      if (units_to_change == nil or units_to_change[unit] ~= nil) then
        addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
        unit.olddir = unit.dir
        --if we aren't allowed to rotate to the indicated direction, skip it
        for j=1,8 do
          local result = updateDir(unit, dirAdd(unit.dir, amt*i))
          if not result then
            amt = amt + 1
          else
            break
          end
        end
      end
    end
  end
end

function doMovement(movex, movey, key)
  --I guess this is the right place to do this?
  if (should_parse_rules_at_turn_boundary) then
    should_parse_rules = true
  end
  
  if key == "rythm" then
    doing_rhythm_turn = true
    local old_rhythm_queued_movement = rhythm_queued_movement
    rhythm_queued_movement = {0, 0, "wait"}
    movex, movey, key = unpack(old_rhythm_queued_movement or rhythm_queued_movement)
  else
    rhythm_queued_movement = {movex, movey, key}
    doing_rhythm_turn = false
  end

  if not doing_past_turns then
    extendReplayString(movex, movey, key)
  end
  if (key == "clikt" or key == "drag") then
    last_click_x, last_click_y = movex, movey
    movex = 0
    movey = 0
  end
  walkdirchangingrulesexist = rules_with["munwalk"] or rules_with["sidestep"] or rules_with["diagstep"] or rules_with["hopovr"] or rules_with["knightstep"]
  sliderulesexist = rules_with["icyyyy"] or rules_with["goooo"] or rules_with["reflecc"]
  local played_sound = {}
  local slippers = {}
  local flippers = {}

  if not unit_tests then
    print("[---- begin turn "..tostring(#undo_buffer).." ----]")
    print("move: " .. movex .. ", " .. movey)
  end

  next_levels, next_level_objs = getNextLevels()

  if movex == 0 and movey == 0 and #next_levels > 0 then
    local going_up = false
    if #level_tree > 0 then
      if type(level_tree[1]) == "table" then
        going_up = eq(level_tree[1], next_levels)
      elseif #next_levels == 1 then
        going_up = level_tree[1] == next_levels[1]
      end
    end
    if not going_up then
      table.insert(level_tree, 1, getMapEntry())
    else
      table.remove(level_tree, 1)
    end
    if playing_world then
      if #next_levels == 1 then
        writeSaveFile(next_levels[1], {"levels", level_filename, "selected"})
      else
        writeSaveFile(next_levels, {"levels", level_filename, "selected"})
      end
    end
    loadLevels(next_levels, nil, next_level_objs)
    return
  end

  if movex == 0 and movey == 0 and units_by_name["swan"] and hasU("swan") then
    playSound("honk"..love.math.random(1,6))
  end

  portaling = {}
  
  updateGroup()

  local move_stage = -1
  while move_stage < 3 do
    local moving_units = {}
    local moving_units_next = {}
    local already_added = {}
    
    for _,unit in ipairs(units) do
      unit.already_moving = false
      unit.moves = {}
    end
    outerlvl.moves = {}
    for _,cursor in ipairs(cursors) do
      cursor.moves = {}
    end
    
    if move_stage == -1 then
      local icy = getUnitsWithEffectAndCount("icy")
      for unit,icyness in pairs(icy) do
        local others = (unit == outerlvl and units or getUnitsOnTile(unit.x, unit.y, nil, nil, nil, nil, hasProperty(unit,"big")))
        for __,other in ipairs(others) do
          if other.fullname ~= "no1" and other.id ~= unit.id and sameFloat(unit, other) and timecheck(unit,"be","icy") and ignoreCheck(other,unit,"icy") and undo_buffer[2] ~= nil then
            for _,undo in ipairs(undo_buffer[2]) do
              if undo[1] == "update" and undo[2] == other.id and ((undo[3] ~= other.x) or (undo[4] ~= other.y)) then
                local dx = other.x-undo[3]
                local dy = other.y-undo[4]
                local slipdir = dirs8_by_offset[sign(dx)][sign(dy)]
                table.insert(other.moves, {reason = "icy", dir = slipdir, times = icyness})
                if #other.moves > 0 and not already_added[other] and not hasRule(other,"got","slippers") then
                  table.insert(moving_units, other)
                  already_added[other] = true
                end
                break
              end
            end
          end
        end
      end
      local icyyyy = getUnitsWithEffectAndCount("icyyyy")
      for unit,icyness in pairs(icyyyy) do
        if timeless and not timecheck(unit,"be","icyyyy") then
          local others = (unit == outerlvl and units or getUnitsOnTile(unit.x, unit.y, nil, nil, nil, nil, hasProperty(unit,"big")))
          for __,other in ipairs(others) do
            if other.fullname ~= "no1" and other.id ~= unit.id and sameFloat(unit, other) and ignoreCheck(other,unit,"icyyyy") and undo_buffer[2] ~= nil then
              for _,undo in ipairs(undo_buffer[2]) do
                if undo[1] == "update" and undo[2] == other.id and ((undo[3] ~= other.x) or (undo[4] ~= other.y)) then
                  local dx = other.x-undo[3]
                  local dy = other.y-undo[4]
                  local slipdir = dirs8_by_offset[sign(dx)][sign(dy)]
                  table.insert(other.moves, {reason = "icy", dir = slipdir, times = icyness})
                  if #other.moves > 0 and not already_added[other] and not hasRule(other,"got","slippers") then
                    table.insert(moving_units, other)
                    already_added[other] = true
                  end
                  break
                end
              end
            end
          end
        end
      end
    elseif move_stage == 0 and (movex ~= 0 or movey ~= 0) then
      local u = getUnitsWithEffectAndCount("u")
      for unit,uness in pairs(u) do
        if not hasProperty(unit, "slep") and slippers[unit.id] == nil and timecheck(unit,"be","u") then
          if (key == "wasd") or ((key == "udlr") and not hasProperty(nil,"u too")) or ((key == "numpad" or key == "ijkl") and not hasProperty(nil,"u tres")) then
            local dir = dirs8_by_offset[movex][movey]
            --If you want baba style 'when you moves, even if it fails to move, it changes direction', uncomment this.
            table.insert(unit.moves, {reason = "u", dir = dir, times = 1})
            --[[addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
            updateDir(unit, dir)]]
            if #unit.moves > 0 and not already_added[unit] then
              table.insert(moving_units, unit)
              already_added[unit] = true
            end
          end
        end
      end
      
      local utoo = getUnitsWithEffectAndCount("u too")
      for unit,uness in pairs(utoo) do
        if not hasProperty(unit, "slep") and slippers[unit.id] == nil and timecheck(unit,"be","u too") then
          if ((key == "wasd") and not hasProperty(nil,"u")) or (key == "udlr") or ((key == "numpad" or key == "ijkl") and not hasProperty(nil,"u tres")) then
            local dir = dirs8_by_offset[movex][movey]
            --If you want baba style 'when you moves, even if it fails to move, it changes direction', uncomment this.
            table.insert(unit.moves, {reason = "u", dir = dir, times = 1})
            --[[addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
            updateDir(unit, dir)]]
            if #unit.moves > 0 and not already_added[unit] then
              table.insert(moving_units, unit)
              already_added[unit] = true
            end
          end
        end
      end
      
      local utres = getUnitsWithEffectAndCount("u tres")
      for unit,uness in pairs(utres) do
        if not hasProperty(unit, "slep") and slippers[unit.id] == nil and timecheck(unit,"be","u tres") then
          if ((key == "wasd") and not hasProperty(nil,"u")) or ((key == "udlr") and not hasProperty(nil,"u too")) or (key == "numpad") or (key == "ijkl") then
            local dir = dirs8_by_offset[movex][movey]
            --If you want baba style 'when you moves, even if it fails to move, it changes direction', uncomment this.
            table.insert(unit.moves, {reason = "u", dir = dir, times = 1})
            --[[addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
            updateDir(unit, dir)]]
            if #unit.moves > 0 and not already_added[unit] then
              table.insert(moving_units, unit)
              already_added[unit] = true
            end
          end
        end
      end
      
      local yall = getUnitsWithEffectAndCount("y'all")
      for unit,uness in pairs(yall) do
        if not hasProperty(unit, "slep") and slippers[unit.id] == nil and timecheck(unit,"be","y'all") then
          if (key == "wasd") or (key == "udlr") or (key == "numpad" or key == "ijkl") then
            local dir = dirs8_by_offset[movex][movey]
            --If you want baba style 'when you moves, even if it fails to move, it changes direction', uncomment this.
            table.insert(unit.moves, {reason = "u", dir = dir, times = 1})
            --[[addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
            updateDir(unit, dir)]]
            if #unit.moves > 0 and not already_added[unit] then
              table.insert(moving_units, unit)
              already_added[unit] = true
            end
          end
        end
      end
    elseif move_stage == 1 then
      local isspoop = matchesRule(nil, "spoop", "?")
      local spoopunits = {}
      for _,ruleparent in ipairs(isspoop) do
        local unit = ruleparent[2]
        spoopunits[unit] = true
      end
      for unit,_ in pairs(spoopunits) do
        local others = {}
        for nx=-1,1 do
          for ny=-1,1 do
            if (nx ~= 0) or (ny ~= 0) then
              mergeTable(others,getUnitsOnTile(unit.x+nx,unit.y+ny,nil,nil,nil,nil,hasProperty(unit,"big")))
            end
          end
        end
        for _,other in ipairs(others) do
          local is_spoopy = #matchesRule(unit, "spoop", other)
          if (is_spoopy > 0 and not hasProperty(other, "slep")) and timecheck(unit,"spoop",other) and timecheck(other) and ignoreCheck(other,unit) then
            spoop_dir = dirs8_by_offset[sign(other.x - unit.x)][sign(other.y - unit.y)]
            if (spoop_dir % 2 == 1 or (not hasProperty(unit, "ortho") and not hasProperty(other, "ortho"))) then
              addUndo({"update", other.id, other.x, other.y, other.dir})
              other.olddir = other.dir
              updateDir(other, spoop_dir)
              table.insert(other.moves, {reason = "spoop", dir = other.dir, times = is_spoopy})
              if #other.moves > 0 and not already_added[other] then
                table.insert(moving_units, other)
                already_added[other] = true
              end
            end
          end
        end
      end
      local walk = getUnitsWithEffectAndCount("walk")
      for unit,walkness in pairs(walk) do
        if not hasProperty(unit, "slep") and slippers[unit.id] == nil and timecheck(unit,"be","walk") then
          table.insert(unit.moves, {reason = "walk", dir = unit.dir, times = walkness})
          if #unit.moves > 0 and not already_added[unit] then
            table.insert(moving_units, unit)
            already_added[unit] = true
          end
        end
      end
      if (rules_with["moov"]) then
        for mdir,mdirname in ipairs(dirs8_by_name) do
          local isshift = matchesRule(nil, "moov", mdirname)
          for _,ruleparent in ipairs(isshift) do
            local unit = ruleparent[2]
            table.insert(unit.moves, {reason = "moov dir", dir = mdir, times = 1})
            if #unit.moves > 0 and not already_added[unit] then
              table.insert(moving_units, unit)
              already_added[unit] = true
            end
          end
        end
        for i = 0,8 do
          local isshift = matchesRule(nil, "moov", "spin"..tostring(i))
          for _,ruleparent in ipairs(isshift) do
            local unit = ruleparent[2]
            table.insert(unit.moves, {reason = "moov dir", dir = dirAdd(unit.dir, i), times = 1})
            if #unit.moves > 0 and not already_added[unit] then
              table.insert(moving_units, unit)
              already_added[unit] = true
            end
          end
        end
      end
      local isactualstalk = matchesRule("?", "stalk", "?")
      for _,ruleparent in ipairs(isactualstalk) do
        local stalkers = findUnitsByName(ruleparent.rule.subject.name)
        local stalker_conds = ruleparent.rule.subject.conds
        local stalkee_conds = ruleparent.rule.object.conds
        if #findUnitsByName(ruleparent.rule.object.name) > 0 then
          for _,stalker in ipairs(stalkers) do
            if testConds(stalker, stalker_conds) then
              local found_target = nil
              for _,stalkee in ipairs(getUnitsOnTile(stalker.x, stalker.y, ruleparent.rule.object.name)) do -- is it standing on the target
                if testConds(stalkee, stalkee_conds, stalker) and stalker.id ~= stalkee.id and timecheck(stalker, stalkee) then
                  found_target = 0
                  break
                end
              end
              if not found_target then
                local visited = {} -- 2d array the size of the map
                for i = 1,mapwidth do
                  visited[i] = {}
                  for j = 1,mapheight do
                    visited[i][j] = 0
                  end
                end
                visited[stalker.x+1][stalker.y+1] = 1
                local queue = {{x = stalker.x, y = stalker.y}}
                (function () -- 'return' allows breaking from the outer loop, skipping inner loops
                  local first_loop = true
                  while (queue[1]) do
                    local pos = table.remove(queue, 1)
                    for i=1,8 do
                      if hasProperty(stalker, "ortho") and not hasProperty(stalker, "diag") and i % 2 == 0 then i = i + 1 end
                      if hasProperty(stalker, "diag") and not hasProperty(stalker, "ortho") and i % 2 == 1 then i = i + 1 end
                      if i > 8 then break end
                      local dx = ({1,1,0,-1,-1,-1,0,1})[i]
                      local dy = ({0,1,1,1,0,-1,-1,-1})[i]
                      local dir = dirs8_by_offset[dx][dy]
                      local dx_next, dy_next, dir_next, x, y, portal_unit = getNextTile(stalker, dx, dy, dir, nil, pos.x, pos.y)
                      if inBounds(x,y) and visited[x+1][y+1] == 0 then
                        visited[x+1][y+1] = first_loop and dir or visited[pos.x+1][pos.y+1] -- value depicts which way to travel to get there
                        local success, movers, specials = canMove(stalker,dx,dy,dir,false,false,nil,nil,nil,pos.x,pos.y)
                        if success then
                          local stalkees = getUnitsOnTile(x, y, ruleparent.rule.object.name)
                          for _,stalkee in ipairs(stalkees) do
                            if testConds(stalkee, stalkee_conds, stalker) and stalker.id ~= stalkee.id and timecheck(stalker, stalkee) then
                              found_target = visited[x+1][y+1]
                              return
                            end
                          end
                          table.insert(queue, {x = x, y = y})
                        end
                      end
                    end
                    first_loop = false
                  end
                end)()
              end
              -- print(dump(visited))
              if found_target then
                if found_target ~= 0 then
                  addUndo({"update", stalker.id, stalker.x, stalker.y, stalker.dir})
                  stalker.olddir = stalker.dir
                  updateDir(stalker, found_target)
                  table.insert(stalker.moves, {reason = "stalk", dir = stalker.dir, times = 1})
                  if #stalker.moves > 0 and not already_added[stalker] then
                    table.insert(moving_units, stalker)
                    already_added[stalker] = true
                  end
                end
              -- else
              --   TODO: Make this depend on it being stubborn.
              --   local stalkees = copyTable(findUnitsByName(ruleparent[1][3]))
              --   table.sort(stalkees, function(a, b) return euclideanDistance(a, stalker) < euclideanDistance(b, stalker) end )
              --   for _,stalkee in ipairs(stalkees) do
              --     if testConds(stalkee, stalkee_conds) then
              --       local dist = euclideanDistance(stalker, stalkee)
              --       local stalk_dir = dist > 0 and dirs8_by_offset[sign(stalkee.x - stalker.x)][sign(stalkee.y - stalker.y)] or stalkee.dir
              --       if dist > 0 and hasProperty(stalker, "ortho") then
              --         local use_hori = math.abs(stalkee.x - stalker.x) > math.abs(stalkee.y - stalker.y)
              --         stalk_dir = dirs8_by_offset[use_hori and sign(stalkee.x - stalker.x) or 0][not use_hori and sign(stalkee.y - stalker.y) or 0]
              --       end
              --       addUndo({"update", stalker.id, stalker.x, stalker.y, stalker.dir})
              --       stalker.olddir = stalker.dir
              --       updateDir(stalker, stalk_dir)
              --       table.insert(stalker.moves, {reason = "stalk", dir = stalker.dir, times = 1})
              --       if #stalker.moves > 0 and not already_added[stalker] then
              --         table.insert(moving_units, stalker)
              --         already_added[stalker] = true
              --       end
              --       break
              --     end
              --   end
              end
            end
          end
        end
      end
    elseif move_stage == 2 then
      --local yeeting_level = matchesRule(outerlvl, "yeet", "?")
      local isyeet = matchesRule(nil, "yeet", "?")
      for _,ruleparent in ipairs(isyeet) do
        local unit = ruleparent[2]
        local others = (unit == outerlvl and units or getUnitsOnTile(unit.x, unit.y, nil, nil, nil, nil, hasProperty(unit,"big")))
        for __,other in ipairs(others) do
          if other.fullname ~= "no1" and other.id ~= unit.id and sameFloat(unit, other) and ignoreCheck(other, unit) then
            local is_yeeted = hasRule(unit, "yeet", other)
            if (is_yeeted) then
              if timecheck(unit,"yeet",other) and timecheck(other) then
                table.insert(other.moves, {reason = "yeet", dir = unit.dir, times = 1002})
                if #other.moves > 0 and not already_added[other] then
                  table.insert(moving_units, other)
                  already_added[other] = true
                end
              elseif timecheck(unit,"yeet",other) then
                addUndo({"timeless_yeet_add",other,timeless_yote[other]})
                timeless_yote[other] = unit.dir
              end
            end
          end
        end
      end
      for unit,dir in pairs(timeless_yote) do
        local dx = dirs8[dir][1]
        local dy = dirs8[dir][2]
        if timeless then
          if canMove(unit,dx,dy,dir,true,true,nil,"timeless yeet") then
            table.insert(unit.moves, {reason = "timeless yeet", dir = dir, times = 1})
            if #unit.moves > 0 and not already_added[unit] then
              table.insert(moving_units, unit)
              already_added[unit] = true
            end
          else
            addUndo({"timeless_yeet_remove",unit,dir})
            timeless_yote[unit] = nil
          end
        else
          table.insert(unit.moves, {reason = "yeet", dir = dir, times = 1002})
          if #unit.moves > 0 and not already_added[unit] then
            table.insert(moving_units, unit)
            already_added[unit] = true
          end
          addUndo({"timeless_yeet_remove",unit,dir})
          timeless_yote[unit] = nil
        end
      end
      local go = getUnitsWithEffectAndCount("go")
      for unit,goness in pairs(go) do
        local others = (unit == outerlvl and units or getUnitsOnTile(unit.x, unit.y, nil, nil, nil, nil, hasProperty(unit,"big")))
        for __,other in ipairs(others) do 
          if other.fullname ~= "no1" and other.id ~= unit.id and sameFloat(unit, other) and timecheck(unit,"be","go") and ignoreCheck(other,unit,"go") then
            table.insert(other.moves, {reason = "go", dir = unit.dir, times = goness})
            if #other.moves > 0 and not already_added[other] then
              table.insert(moving_units, other)
              already_added[other] = true
            end
          end
        end
      end
      local go = getUnitsWithEffectAndCount("goooo")
      for unit,goness in pairs(go) do
        local others = (unit == outerlvl and units or getUnitsOnTile(unit.x, unit.y, nil, nil, nil, nil, hasProperty(unit,"big")))
        for __,other in ipairs(others) do 
          if other.fullname ~= "no1" and other.id ~= unit.id and sameFloat(unit, other) and ignoreCheck(other,unit,"goooo") then
            table.insert(other.moves, {reason = "goooo", dir = unit.dir, times = goness})
            if #other.moves > 0 and not already_added[other] then
              table.insert(moving_units, other)
              already_added[other] = true
            end
          end
        end
      end
      local ismoov = matchesRule(nil, "moov", "?")
      local moovunits = {}
      for _,ruleparent in ipairs(ismoov) do
        local unit = ruleparent[2]
        moovunits[unit] = true
      end
      for unit,_ in pairs(moovunits) do
        local others = getUnitsOnTile(unit.x,unit.y,nil,nil,nil,nil,hasProperty(unit,"big"))
        for _,other in ipairs(others) do
          local is_moover = #matchesRule(unit, "moov", other)
          if is_moover > 0 and timecheck(unit,"moov",other) and other.fullname ~= "no1" and other.id ~= unit.id and sameFloat(unit, other) and ignoreCheck(unit,other) and ignoreCheck(other,unit) then
            table.insert(other.moves, {reason = "moov", dir = unit.dir, times = 1})
            if #other.moves > 0 and not already_added[other] then
              table.insert(moving_units, other)
              already_added[other] = true
            end
          end
        end
      end
    end

    for _,unit in pairs(moving_units) do
      if not unit.stelth and not hasProperty(unit, "loop") and timecheck(unit) then
        addParticles("movement-puff", unit.x, unit.y, unit.color_override or unit.color)
      end
    end
    
    --[[
Simultaneous movement algorithm, basically a simple version of Baba's:
1) Make a list of all things that are moving this stage, moving_units.
2a) Try to move each of them once. For each success, move it to moving_units_next and set it already_moving with one less move point and an update queued. If there was at least one success, repeat 2 until there are no successes. (During this process, things that are currently moving are considered intangible in canMove.)
2b) But wait, we're still not done! Flip all walkers that failed to flip, then continue until we once again have no successes. (Flipping still only happens once per turn.)
2c) Finally, if we had at least one success, everything left is moved to moving_units_next with one less move point and we repeat from 2a). If we had no successes, the stage is totally resolved. doupdate() and unset all current_moving.
3) if SLIDE/LAUNCH/BOUNCE gets made, we'll need to figure out where to insert it... but if it's like baba, it goes after the move succeeds but before do_update(), and it adds either another update or another movement as appropriate.

ALTERNATE MOVEMENT ALGORITHM that would preserve properties like 'x is move and stop pulls apart' and is mostly move order independent:
1) Do it as before, except instead of moving a unit when you discover it can be moved, mark it and wait until the inner loop is over.
2) After the inner loop is over, move all the things that you marked.

But if we want to go a step further and e.g. make it so X IS YOU AND PUSH lets you catapult one of yourselves two tiles, we have to go a step further and stack up all of the movement that would occur instead of making it simultaneous and override itself.

But if we do THIS, then we can now attempt to move to different destination tiles than we tried the first time around. So we have to re-evaluate the outcome of that by calling canMove again. And if that new movement can also cause push/pull/sidekik/slide/launch, then we have to recursively check everything again, and it's unclear what order things should evaluate in, and etc.

It is probably possible to do, but lily has decided that it's not important enough if it's difficult, so we shall stay with simultanous movement for now.
]]
    --loop_stage and loop_tick are infinite loop detection.
    local loop_stage = 0
    local successes = 1
    --Stage loop continues until nothing moves in the inner loop, and does a doUpdate after each inner loop, to allow for multimoves to exist.
    while (#moving_units > 0 and successes > 0) do
      if (loop_stage > 1000) then
        print("movement infinite loop! (1000 attempts at a stage)")
        destroyLevel("infloop")
        break
      end
      --movedebug("loop_stage:"..tostring(loop_stage))
      successes = 0
      local loop_tick = 0
      loop_stage = loop_stage + 1
      local something_moved = true
      --Tick loop tries to move everything at least once, and gives up if after an iteration, nothing can move. (It also tries to do flips to see if that helps.) (Incrementing loop_tick once is a 'sub-tick'. Calling doUpdate and incrementing loop_stage is a 'tick'. Incrementing move_stage is a 'stage'.)
      while (something_moved) do
         if (loop_tick > 1000) then
          print("movement infinite loop! (1000 attempts at a single tick)")
          destroyLevel("infloop")
          break
        end
        --movedebug("loop_tick:"..tostring(loop_tick))
        local remove_from_moving_units = {}
        local has_flipped = false
        something_moved = false
        loop_tick = loop_tick + 1
        --TODO: PERFORMANCE: Iterating through moving_units is the slowest part, unsurprisingly. Investigate if it's due to canMove, moveIt, doPull or something else.
        for _,unit in ipairs(moving_units) do
          while #unit.moves > 0 and unit.moves[1].times <= 0 do
            table.remove(unit.moves, 1)
          end
          if #unit.moves > 0 and not unit.removed then
            local data = unit.moves[1]
            local dir = data.dir
            local dpos = dirs8[dir]
            local dx,dy = dpos[1],dpos[2]
            --dx/dy collation logic for copykat moves
            if (data.reason == "copkat") and timecheck(unit) then
              dx = sign(data.dx)
              dy = sign(data.dy)
              if (dx == 0 and dy == 0) or slippers[unit.id] ~= nil or hasProperty(unit, "slep") then
                data.times = data.times - 1
                while #unit.moves > 0 and unit.moves[1].times <= 0 do
                  table.remove(unit.moves, 1)
                end
                break
              else
                dir = dirs8_by_offset[dx][dy]
                data.dir = dir
              end
            end
            --movedebug("considering:"..unit.fullname..","..dir)
            local success,movers,specials = true,{},{}
            if hasProperty(unit,"glued") then
              --Glued units get moved as a single group.
              local units, pushers, pullers = FindEntireGluedUnit(unit, dx, dy)
              for _,pusher in ipairs(pushers) do
                local success_,movers_,specials_ = canMove(pusher, dx, dy, dir, true, false, nil, data.reason)
                mergeTable(movers,movers_)
                mergeTable(specials,specials_)
                success = success and success_
              end
              if #movers > 0 then
                for _,add in ipairs(units) do
                  table.insert(movers, {unit = add, dx = dx, dy = dy, dir = dir, move_dx = movers[1].move_dx, move_dy = movers[1].move_dy, move_dir = movers[1].move_dir, geometry_spin = movers[1].geometry_spin, portal = movers[1].portal_unit})
                end
              end
            else
              success,movers,specials = canMove(unit, dx, dy, dir, true, false, nil, data.reason)
            end
            for _,special in ipairs(specials) do
              doAction(special)
            end
            if success then
              something_moved = true
              successes = successes + 1
              
              for k = #movers, 1, -1 do
                moveIt(movers[k].unit, movers[k].dx, movers[k].dy, data.reason == "moov dir" and movers[k].unit.dir or movers[k].dir, movers[k].move_dir, movers[k].geometry_spin, data, false, already_added, moving_units, moving_units_next, slippers, remove_from_moving_units, movers[k].portal)
              end
              --Patashu: only the mover itself pulls, otherwise it's a mess. stuff like STICKY/STUCK will require ruggedizing this logic.
              --Patashu: TODO: Doing the pull right away means that in a situation like this: https://cdn.discordapp.com/attachments/579519329515732993/582179745006092318/unknown.png the pull could happen before the bounce depending on move order. To fix this... I'm not sure how Baba does this? But it's somewhere in that mess of code.
              if not table.has_value(unitsByTile(unit.x-dx,unit.y-dy),unit) then
                doPull(unit, dx, dy, dir, data, already_added, moving_units, moving_units_next,  slippers, remove_from_moving_units)
              end
              
              --add to moving_units_next if we have another pending move
              data.times = data.times - 1
              while #unit.moves > 0 and unit.moves[1].times <= 0 do
                table.remove(unit.moves, 1)
              end
              if #unit.moves > 0 and not remove_from_moving_units[unit] then
                table.insert(moving_units_next, unit)
              end
              --we made our move this iteration, wait until the next iteration to move again
              remove_from_moving_units[unit] = true
            end
          else
            remove_from_moving_units[unit] = true
          end
        end
        --do flips if we failed to move anything
        if (not something_moved and not has_flipped) then
          --TODO: CLEANUP: This is getting a little duplicate-y.
          for _,unit in ipairs(moving_units) do
            while #unit.moves > 0 and unit.moves[1].times <= 0 do
              table.remove(unit.moves)
            end
            if #unit.moves > 0 and not unit.removed and unit.moves[1].times > 0 then
              local data = unit.moves[1]
              if data.reason == "walk" and flippers[unit.id] ~= true and not hasProperty(unit, "stubbn") and not hasProperty(unit,"loop") and timecheck(unit,"be","walk") then
                dir = rotate8(data.dir); data.dir = dir
                addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
                table.insert(update_queue, {unit = unit, reason = "dir", payload = {dir = data.dir}})
                flippers[unit.id] = true
                something_moved = true
                successes = successes + 1
                if not (remove_from_moving_units[unit]) then
                  table.insert(moving_units_next, unit)
                  remove_from_moving_units[unit] = true
                end
              end
            end
          end
          has_flipped = true
        end
        for i=#moving_units,1,-1 do
          local unit = moving_units[i]
          if (remove_from_moving_units[unit]) then
            table.remove(moving_units, i)
            already_added[unit] = false
          end
        end
      end
      --Patashu: If we want to satisfy the invariant 'when multiple units move simultaneously, if some of them can't move the first time around, they lose their chance to move', then uncomment this. This lets you do things like bab be u & bounded no1 and have a blob of babs break up (since initially only the front row can move).
      --[[for i=#moving_units,1,-1 do
        local unit = moving_units[i]
        if #unit.moves > 0 and unit.moves[1].times > 0 then
          unit.moves[1].times = unit.moves[1].times - 1
          while #unit.moves > 0 and unit.moves[1].times <= 0 do
            table.remove(unit.moves)
          end
          if #unit.moves == 0 then
            table.remove(moving_units, i)
          end
        end
      end]]--
      doUpdate(already_added, moving_units_next)
      for _,unit in ipairs(moving_units_next) do
        --movedebug("re-added:"..unit.fullname)
        table.insert(moving_units, unit)
        already_added[unit] = true
      end
      moving_units_next = {}
    end
    updateGroup()
    calculateLight()
    move_stage = move_stage + 1
  end
  --https://babaiswiki.fandom.com/wiki/Advanced_rulebook (for comparison)
  parseRules()
  updateGroup()
  calculateLight()
  moveBlock()
  parseRules()
  updateGroup()
  calculateLight()
  fallBlock()
  parseRules()
  updateGroup()
  calculateLight()
  parseRules()
  updateGroup()
  calculateLight()
  updateUnits(false, true)
  parseRules()
  updateGroup()
  calculateLight()
	convertUnits(1)
  parseRules()
  updateGroup()
  calculateLight()
  updatePortals()
  miscUpdates()
  
  if scene.setPathlockBox then 
    local showlock
    for _,u in ipairs(getUnitsWithEffect("u")) do
      for _,dir in ipairs(dirs8) do
        local _, __, ___, x, y = getNextTile(u, dir[1], dir[2], dirs8_by_offset[dir[1]][dir[2]])
        local facing = getUnitsOnTile(x, y, "lin")
        for _,v in ipairs(facing) do
          if v.special.pathlock and v.special.pathlock ~= "none" then
            showlock = v
            break
          end
        end
        if showlock then break end
      end
    end
    scene.setPathlockBox(showlock)
  end
  
  next_levels = getNextLevels()
end

function doAction(action)
  local action_name = action[1]
  if action_name == "open" then
    local victims = action[2]
    --don't do open/shut unless both victims are still alive
    for _,unit in ipairs(victims) do
      if unit.removed or unit.destroyed then
        return
      end
    end
    playSound("break", 0.5)
    playSound("unlock", 0.6)
    for _,unit in ipairs(victims) do
      addParticles("destroy", unit.x, unit.y, {237,226,133})
      if not hasProperty(unit, "protecc") then
        unit.removed = true
        unit.destroyed = true
      end
    end
  elseif action_name == "weak" then
    playSound("break", 0.5)
    local victims = action[2]
    for _,unit in ipairs(victims) do
      addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
      --no protecc check because it can't safely be prevented here (we might be moving OoB)
      unit.removed = true
      unit.destroyed = true
    end
  elseif action_name == "snacc" then
    playSound("snacc", 0.5)
    local victims = action[2]
    for _,unit in ipairs(victims) do
      addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
      if not hasProperty(unit, "protecc") then
        unit.removed = true
        unit.destroyed = true
      end
    end
  end
end

function moveIt(mover, dx, dy, facing_dir, move_dir, geometry_spin, data, pulling, already_added, moving_units, moving_units_next, slippers, remove_from_moving_units, portal)
  if not mover.removed then
    local move_dx, move_dy = dirs8[move_dir][1], dirs8[move_dir][2]
    queueMove(mover, dx, dy, facing_dir, false, geometry_spin, portal)
    --applySlide(mover, dx, dy, already_added, moving_units_next)
    applySwap(mover, dx, dy)
    applyPortalHoover(mover, dx, dy)
    --finishing a slip locks you out of U/WALK for the rest of the turn
    if data.reason == "icy" and not hasRule(mover,"got","slippers") then
      slippers[mover.id] = true
    end
    --add SIDEKIKERs to move in the next sub-tick
    --move_dir is more accurate in the presence of WRAP/PORTAL than dx/dy (which can fling you across the map)
    for sidekiker,skdir in pairs(findSidekikers(mover, move_dx, move_dy)) do
      local currently_moving = false
      for _,mover2 in ipairs(moving_units) do
        if mover2 == sidekiker then
          currently_moving = true
          break
        end
      end
      if not currently_moving then
        table.insert(sidekiker.moves, {reason = "sidekik", dir = skdir, times = 1}) --TODO: dx/dy, dir and mover.dir could possibly all be different, explore advanced movement interactions with sidekik and wrap, portal, stubborn
        table.insert(moving_units, sidekiker) --Patashu: I think moving_units is correct (since it should happen 'at the same time' like a push or pull) but maybe changing this to moving_units_next will fix a bug in the future...?
        already_added[sidekiker] = true
      end
    end
    --add COPYKATs to move in the next tick
    --basically: if they're currently copying, ignore the first move we find. if we find a non-ignored move, add to it. else, add a new move.
    --On that new move, we add up all dx and dy. The final dx and dy will be the sign (so limited to -1/1) of its dx and dy.
    for copykat,reason in pairs(findCopykats(mover)) do
      local currently_moving = false
      for _,mover2 in ipairs(moving_units) do
        if mover2 == copykat then
          currently_moving = true
          break
        end
      end
      local found = false
      for i,move in ipairs(copykat.moves) do
        if move.reason == "copkat" then
          if currently_moving then
            currently_moving = false
          else
            move.dx = move.dx + move_dx
            move.dy = move.dy + move_dy
            --movedebug("copykat collate:"..tostring(move.dx)..","..tostring(move.dy))
            found = true
            break
          end
        end
      end
      if not found then
        table.insert(copykat.moves, {reason = reason, dir = mover.dir, times = 1, dx = move_dx, dy = move_dy})
        --the reason for this weird check is - we only want to add to moving_units_next if we're not already on it, and we're not already on it if we previously had zero moves OR we haven't been removed from moving units yet. This is pretty ugly imo.
        if (#copykat.moves == 1 or not remove_from_moving_units[copykat]) then
          table.insert(moving_units_next, copykat)
          remove_from_moving_units[copykat] = true
          already_added[copykat] = true
        end
      end
    end
  end
end

function queueMove(mover, dx, dy, dir, priority, geometry_spin, portal)
  addUndo({"update", mover.id, mover.x, mover.y, mover.dir, portal})
  mover.olddir = mover.dir
  updateDir(mover, dir)
  --movedebug("moving:"..mover.fullname..","..tostring(mover.id)..","..tostring(mover.x)..","..tostring(mover.y)..","..tostring(dx)..","..tostring(dy))
  mover.already_moving = true
  table.insert(update_queue, (priority and 1 or (#update_queue + 1)), {unit = mover, reason = "update", payload = {x = mover.x + dx, y = mover.y + dy, dir = mover.dir, geometry_spin = geometry_spin, portal = portal}})
end

function applySlide(mover, already_added, moving_units_next)
  --Before we add a new LAUNCH/SLIDE move, deleting all existing LAUNCH/SLIDE moves, so that if we 'move twice in the same tick' (such as because we're being pushed or pulled while also sliding) it doesn't stack. (this also means e.g. SLIDE & SLIDE gives you one extra move at the end, rather than multiplying your movement.)
  local did_clear_existing = false
  --LAUNCH will take precedence over SLIDE, so that puzzles where you move around launchers on an ice rink will behave intuitively.
  local did_launch = false
   --we haven't actually moved yet, so check the tile we will be on
  local others = getUnitsOnTile(mover.x, mover.y, nil, false, mover, nil, nil, nil, hasProperty(mover,"big"))
  table.insert(others, outerlvl)
  --REFLECC is now also handled here, and goes before anything else.
  for _,v in ipairs(others) do
    if (sameFloat(mover, v) and not v.already_moving) and timecheck(v) and ignoreCheck(mover,v,"reflecc") then
      local reflecc = hasProperty(v, "reflecc")
      if (reflecc) then
        local dirToUse;
        --SLOOP is oriented TL-BR when facing 1.
        --Entering it 1 knocks you down to 3.
        --Entering it 2 is forbidden.
        --Entering it 3 knocks you down to 1.
        --Entering it 4 knocks you back to 8.
        --Entering it 5 knocks you back to 7.
        --Entering it 6 is forbidden.
        --Entering it 7 knocks you back to 5.
        --Entering it 8 knocks you back to 4.
        --SLOOP is oriented T-B when facing 2.
        --Entering it 1 knocks you back to 5.
        --Entering it 2 knocks you back to 4.
        --Entering it 3 is forbidden.
        --Entering it 4 knocks you back to 2.
        --Entering it 5 knocks you back to 1.
        --Entering it 6 knocks you back to 8.
        --Entering it 7 is forbidden.
        --Entering it 8 knocks you back to 6.
        --TL;DR:
        --v.dir is paired with v.dir+2.
        --v.dir+1 is forbidden, as is v.dir+5.
        --v.dir+3 is paired with v.dir v.dir+7.
        --v.dir+4 is paired with v.dir+6.
        local dirDifference = mover.dir - v.dir;
        if (dirDifference < 0) then dirDifference = dirDifference + 8; end
        if (dirDifference == 0) then
          dirToUse = dirAdd(mover.dir, 2);
        elseif (dirDifference == 1) then
          dirToUse = nil;
        elseif (dirDifference == 2) then
           dirToUse = dirAdd(mover.dir, -2);
        elseif (dirDifference == 3) then
          dirToUse = dirAdd(mover.dir, 4);
        elseif (dirDifference == 4) then
          dirToUse = dirAdd(mover.dir, 2);
        elseif (dirDifference == 5) then
          dirToUse = nil;
        elseif (dirDifference == 6) then
          dirToUse = dirAdd(mover.dir, -2);
        elseif (dirDifference == 7) then
          dirToUse = dirAdd(mover.dir, 4);
        end
        if (dirToUse ~= nil) then
          if (not did_clear_existing) then
            for i = #mover.moves,1,-1 do
              if mover.moves[i].reason == "reflecc" or mover.moves[i].reason == "goooo" or mover.moves[i].reason == "icyyyy" then
                table.remove(mover.moves, i)
              end
            end
            did_clear_existing = true
          end
          --the new moves will be at the start of the unit's moves data, so that it takes precedence over what it would have done next otherwise
          --movedebug("launching:"..mover.fullname..","..v.dir)
          
          table.insert(mover.moves, 1, {reason = "reflecc", dir = dirToUse, times = 1})
          if not already_added[mover] then
            --movedebug("did add launcher")
            table.insert(moving_units_next, mover)
            already_added[mover] = true
          end
          did_launch = true
        end
      end
    end
  end
  if (did_launch) then
    return
  end
  
  for _,v in ipairs(others) do
    if (sameFloat(mover, v) and not v.already_moving) and timecheck(v) and ignoreCheck(mover,v,"goooo") then
      local launchness = countProperty(v, "goooo")
      if (launchness > 0) then
        if (not did_clear_existing) then
          for i = #mover.moves,1,-1 do
            if mover.moves[i].reason == "reflecc" or mover.moves[i].reason == "goooo" or mover.moves[i].reason == "icyyyy" then
              table.remove(mover.moves, i)
            end
          end
          did_clear_existing = true
        end
        --the new moves will be at the start of the unit's moves data, so that it takes precedence over what it would have done next otherwise
        --TODO: CLEANUP: Figure out a nice way to not have to pass this around/do this in a million places.
        --movedebug("launching:"..mover.fullname..","..v.dir)
        table.insert(mover.moves, 1, {reason = "goooo", dir = v.dir, times = launchness})
        if not already_added[mover] then
          --movedebug("did add launcher")
          table.insert(moving_units_next, mover)
          already_added[mover] = true
        end
        did_launch = true
      end
    end
  end
  if (did_launch) then
    return
  end
  for _,v in ipairs(others) do
    if (sameFloat(mover, v) and not v.already_moving) and timecheck(v) and ignoreCheck(mover,v,"icyyyy") then
      local slideness = countProperty(v, "icyyyy")
      if (slideness > 0) then
        if (not did_clear_existing) then
          for i = #mover.moves,1,-1 do
            if mover.moves[i].reason == "reflecc" or mover.moves[i].reason == "goooo" or mover.moves[i].reason == "icyyyy" then
              table.remove(mover.moves, i)
            end
          end
          did_clear_existing = true
        end
        if not hasRule(mover,"got","slippers") then
          --movedebug("sliding:"..mover.fullname..","..mover.dir)
          table.insert(mover.moves, 1, {reason = "icyyyy", dir = mover.dir, times = slideness})
        end
        if not already_added[mover] then
          --movedebug("did add slider")
          table.insert(moving_units_next, mover)
          already_added[mover] = true
        end
      end
    end
  end
end

function applySwap(mover, dx, dy)
  --fast track
  if rules_with["behin u"] == nil then return end
  --we haven't actually moved yet, same as applySlide
  --two priority related things:
  --1) don't swap with things that are already moving, to prevent move order related behaviour
  --2) swaps should occur before any other kind of movement, so that the swap gets 'overriden' by later, more intentional movement e.g. in a group of swap and you moving things, or a swapper pulling boxen behind it
  --[[addUndo({"update", unit.id, unit.x, unit.y, unit.dir})]]--
  local swap_mover = hasProperty(mover, "behin u")
  local did_swap = false
  for _,v in ipairs(getUnitsOnTile(mover.x+dx, mover.y+dy, nil, nil, nil, nil, hasProperty(mover,"big"))) do
  --if not v.already_moving then --this made some things move order dependent, so taking it out
    local swap_v = hasProperty(v, "behin u")
    --Don't swap with non-swap empty.
    if ((swap_mover and v.fullname ~= "no1") or swap_v) and sameFloat(mover,v,true) then
      if ignoreCheck(v,mover) and (not swap_mover or ignoreCheck(v,mover,"behin u")) then
        queueMove(v, -dx, -dy, swap_v and rotate8(mover.dir) or v.dir, true, 0)
      end
      if ignoreCheck(mover,v) then
        did_swap = true
      end
    end
  end
  --end
  if (swap_mover and did_swap) then
    table.insert(update_queue, {unit = mover, reason = "dir", payload = {dir = rotate8(mover.dir)}})
  end
end

--Explanation: At Vitellary's request, a moving portal hoovers everything it moves onto (passing through it as though it moved into the portal vountarily).
function applyPortalHoover(mover, dx, dy)
  --fast track
  if rules_with["poor toll"] == nil then return end
  if (not hasProperty(mover, "poor toll")) then return end
  
  local xx, yy = mover.x+dx, mover.y+dy
  
  for _,v in ipairs(getUnitsOnTile(mover.x+dx, mover.y+dy, nil, false, nil, nil, hasProperty(unit,"big"))) do
    if sameFloat(mover, v) and ignoreCheck(v,mover,"poor toll") then
      local dx, dy, dir, px, py = getNextTile(v, -dx, -dy, v.dir)
      if (px ~= xx and py ~= yy) then
        queueMove(v, px-v.x, py-v.y, v.dir, false, 0, mover)
      end
    end
  end
end

function findSidekikers(unit,dx,dy)
  --fast track
  if rules_with["sidekik"] == nil and rules_with["diagkik"] == nil then return {} end
  if table.has_value(unitsByTile(unit.x+dx,unit.y+dy),unit) then return {} end
  local result = {}
  if hasProperty(unit, "shy...") then
    return result
  end
  local x = unit.x
  local y = unit.y
  dx = sign(dx)
  dy = sign(dy)
  local dir = dirs8_by_offset[dx][dy]
  
  local dir90 = (dir + 2 - 1) % 8 + 1
  for i = 1,2 do
    local curdir = (dir90 + 4*i - 1) % 8 + 1
    local curdx = dirs8[curdir][1]
    local curdy = dirs8[curdir][2]
    local curx = x+curdx
    local cury = y+curdy
    local _dx, _dy, _dir, _x, _y = getNextTile(unit, curdx, curdy, curdir)
    for _,v in ipairs(getUnitsOnTile(_x, _y, nil, nil, nil, nil, hasProperty(unit,"big"))) do
      if hasProperty(v, "sidekik") and sameFloat(unit,v,true) and ignoreCheck(v,unit) then
        result[v] = dirAdd(dir, dirDiff(_dir, curdir))
      end
    end
  end
  
  local dir45 = (dir + 1 - 1) % 8 + 1
  for i = 1,4 do
    local curdir = (dir45 + 2*i - 1) % 8 + 1
    local curdx = dirs8[curdir][1]
    local curdy = dirs8[curdir][2]
    local curx = x+curdx
    local cury = y+curdy
    local _dx, _dy, _dir, _x, _y = getNextTile(unit, curdx, curdy, curdir)
    for _,v in ipairs(getUnitsOnTile(_x, _y, nil, nil, nil, nil, hasProperty(unit,"big"))) do
      local diagkikness = countProperty(v, "diagkik")
      if ((i > 2) and (diagkikness >= 1) or (diagkikness >= 2)) and sameFloat(unit,v,true) and ignoreCheck(v,unit) then
        result[v] = dirAdd(dir, dirDiff(_dir, curdir))
      end
    end
  end
  
  return result
end

function findCopykats(unit)
  --fast track
  if rules_with["copkat"] == nil then return {} end
  local result = {}
  local iscopykat = matchesRule("?", "copkat", unit)
  for _,ruleparent in ipairs(iscopykat) do
    local copykats = findUnitsByName(ruleparent.rule.subject.name)
    local copykat_conds = ruleparent.rule.subject.conds
    for _,copykat in ipairs(copykats) do
      if testConds(copykat, copykat_conds) and ignoreCheck(copykat,unit) then
        result[copykat] = "copkat"
      end
    end
  end
  return result
end

--same stubborn logic as canMove, only the puller gets to branch though! also, we can't attempt a pull before going ahead with it, so just do the first one we can I guess.
function doPull(unit,dx,dy,dir,data, already_added, moving_units, moving_units_next, slippers, remove_from_moving_units)
  local result = doPullCore(unit,dx,dy,dir,data, already_added, moving_units, moving_units_next, slippers, remove_from_moving_units)
  --fast track
  if rules_with["come pls"] == nil then return 0 end
  if result > 0 then return result end
  if dir > 0 then
   local stubbn = countProperty(unit, "stubbn")
    if stubbn > 0 and (dir % 2 == 0) or stubbn > 1 then
      for i = 1,clamp(stubbn-1, 1, 4) do
        local stubborndir1 = ((dir+i-1)%8)+1
        local stubborndir2 = ((dir-i-1)%8)+1
        local result1 = doPullCore(unit,dirs8[stubborndir1][1],dirs8[stubborndir1][2],stubborndir1,data,already_added, moving_units, moving_units_next, slippers, remove_from_moving_units)
        if (result1 > 0) then
          return result1
        end
        local result2 = doPullCore(unit,dirs8[stubborndir2][1],dirs8[stubborndir2][2],stubborndir2,data,already_added, moving_units, moving_units_next, slippers, remove_from_moving_units)
        if (result2 > 0) then
          return result2
        end
      end
    end
  end
end

function doPullCore(unit,dx,dy,dir,data, already_added, moving_units, moving_units_next, slippers, remove_from_moving_units)
  --TODO: CLEANUP: This is a big ol mess now and there's no way it needs to be THIS complicated.
  local result = 0
  local something_moved = not hasProperty(unit, "shy...")
  local prev_unit = unit
  while (something_moved) do
    something_moved = false
    local changed_unit = false
    --To implement WRAP/PORTAL, we pick an arbitrary unit along our pull chain and make it the next puller.
    --We have to momentarily reverse dir/dx/dy so that we check what the tile is BEHIND us instead of AHEAD of us.
    --To successfully pull through a portal, we have to track how much our direction changes after taking a portal, so that we can continue the pull in the appropriate direction on the other side.
    local x, y = 0, 0
    dx = dirs8[dir][1]
    dy = dirs8[dir][2]
    local old_dir = dir
    dx, dy, dir, x, y = getNextTile(unit, dx, dy, dir, true)
    local dir_diff = dirDiff(old_dir, dir)
    for _,v in ipairs(getUnitsOnTile(x, y, nil, nil, nil, nil, hasProperty(unit,"big"))) do
      if hasProperty(v, "come pls") and sameFloat(unit,v,true) and ignoreCheck(v,unit) then
        local success,movers,specials = canMove(v, dx, dy, dir, true) --TODO: I can't remember why pushing is set but pulling isn't LOL, but if nothing's broken then shrug??
        for _,special in ipairs(specials) do
          doAction(special)
        end
        if (success) then
          --unit.already_moving = true
          
          for _,mover in ipairs(movers) do
            if not changed_unit and (mover.unit.x ~= unit.x or mover.unit.y ~= unit.y) and not hasProperty(mover.unit, "shy...") then
              something_moved = true
              --Here's where we pick our arbitrary next unit as the puller. (I guess if we're pulling a wrap and a non wrap thing simultaneously it will be ambiguous, so don't use this in a puzzle so I don't have to be recursive...?) (IDK how I'm going to code moonwalk/drunk/drunker/skip pull though LOL, I guess that WOULD have to be recursive??)
              prev_unit = unit
              unit = mover.unit
              dx = mover.dx
              dy = mover.dy
              dir = dirAdd(mover.dir, dir_diff)
              changed_unit = true
            end
            result = result + 1
            moveIt(mover.unit, mover.dx, mover.dy, mover.dir, mover.move_dir, mover.geometry_spin, data, true, already_added, moving_units, moving_units_next, slippers, remove_from_moving_units, mover.portal)
          end
        end
      end
    end
  end
  return result
end

function fallBlock() --TODO: add support for spin
  --1) gather all fallers
  local fallers = {}
  --and all timeless fallers
  local timeless_fallers = {}
  
  function addFallersFromLoop(verb, property, gravity_dir, relative)
    local falling = (verb == "be" and getUnitsWithEffectAndCount(property) or getUnitsWithRuleAndCount(nil, verb, property))
    for unit,count in pairs(falling) do
      if fallers[unit] == nil then
        fallers[unit] = {0, 0};
      end
      local actual_dir = gravity_dir;
      if (relative) then
        actual_dir = dirs8[dirAdd(unit.dir, gravity_dir)];
      end
      fallers[unit][1] = fallers[unit][1] + count*actual_dir[1];
      fallers[unit][2] = fallers[unit][2] + count*actual_dir[2];
      if timecheck(unit, verb, property) then
        timeless_fallers[unit] = true
      end
    end
  end
  
  addFallersFromLoop("be", "haet skye", {0, 1});
  addFallersFromLoop("be", "haet flor", {0, -1});
  
  
  --[[if (rules_with["haet"]) then
    for k,v in pairs(dirs8_by_name) do
      local gravity_dir = copyTable(dirs8[k]);
      gravity_dir[1] = -gravity_dir[1];
      gravity_dir[2] = -gravity_dir[2];
      addFallersFromLoop("haet", v, gravity_dir);
    end
  end]]
  if (rules_with["yeet"]) then
    for k,v in pairs(dirs8_by_name) do
      addFallersFromLoop("yeet", v, dirs8[k], false);
    end
    for i = 0,8 do
      addFallersFromLoop("yeet", "spin"..tostring(i), i, true);
    end
  end
  --2) normalize to an 8-way faller direction, and remove if it's 0,0
  for unit,dir in pairs(fallers) do
    dir[1] = sign(dir[1]);
    dir[2] = sign(dir[2]);
    if (dir[1] == 0 and dir[2] == 0) then
      fallers[unit] = nil
    else
      fallers[unit] = dir
    end
  end
  
  --3) move them simultaneously one step each loop. if nothing moved, loop over. portals can change
  --falling dir, so be aware.
  --Because we resolve simultaneously, it doesn't matter what order we iterate the table in.
  
  local something_moved = true
  local loop_fall = 0
  while something_moved do
    something_moved = false
    local movers = {}
    loop_fall = loop_fall + 1
    if (loop_fall > 1000) then
      print("movement infinite loop! (1000 attempts at a faller)")
      destroyLevel("infloop")
      return
    end
    for unit,dir in pairs(fallers) do
      local gravity_dir = dirs8_by_offset[dir[1]][dir[2]]
      local dx, dy, dir, px, py = dir[1], dir[2], gravity_dir, -1, -1
      local old_dir = gravity_dir
      new_dx, new_dy, new_dir, px, py = getNextTile(unit, dx, dy, dir)
      --TODO: add GLUED support here by checking to see if other units are returned too
      if canMove(unit, dx, dy, dir, false, false, nil, "haet skye") then
        addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
        table.insert(movers, {unit = unit, old_dir = old_dir, dir = new_dir, px = px, py = py});
        something_moved = true;
      end
    end
    for _,payload in ipairs(movers) do
      updateDir(payload.unit, dirAdd(payload.unit.dir, dirDiff(payload.old_dir, payload.dir)))
      fallers[payload.unit] = dirs8[payload.dir];
      moveUnit(payload.unit,payload.px, payload.py)
      if timeless_fallers[payload.unit] == nil then
        fallers[payload.unit] = nil
      end
    end
  end
  
  --TODO: Need to add timeless fall back in.
  
  --TODO: If we have multiple gravity directions, then we probably want a simultaneous single step algorithm to resolve everything neatly.
  --[[local gravity_dir = {0,1}
  
  local fallers = getUnitsWithEffect("haet skye")
  table.sort(fallers, function(a, b) return a.y > b.y end )
  
  local vallers = getUnitsWithEffect("haet flor")
  table.sort(vallers, function(a, b) return a.y < b.y end )
  
  for _,unit in ipairs(fallers) do
    local caught = false
    
    local fallcount = countProperty(unit,"haet skye")
    local vallcount = countProperty(unit,"haet flor")
    
    if (fallcount > vallcount) then
      addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
      if timecheck(unit,"be","haetskye") then
        local loop_fall = 0
        local dx, dy, dir, px, py = gravity_dir[1], gravity_dir[2], 3, -1, -1
        local old_dir = 3
        while (caught == false) do
          loop_fall = loop_fall + 1
          if (loop_fall > 1000) then
            print("movement infinite loop! (1000 attempts at a faller)")
            destroyLevel("infloop")
            return
          end
          new_dx, new_dy, new_dir, px, py = getNextTile(unit, dx, dy, dir)
          if not canMove(unit, dx, dy, dir, false, false, nil, "haet skye") then
            caught = true
          end
          if caught == false then
            updateDir(unit, dirAdd(unit.dir, dirDiff(old_dir, dir)))
            old_dir = dir
            moveUnit(unit,px,py)
          end
          dx, dy, dir = new_dx, new_dy, new_dir
        end
      else
        if canMove(unit, 0, 1, 3, false, false, nil, "haet skye") then
          moveUnit(unit,unit.x,unit.y+1)
        end
      end
    end
  end
  
  for _,unit in ipairs(vallers) do
    local caught = false
    
    local fallcount = countProperty(unit,"haet skye")
    local vallcount = countProperty(unit,"haet flor")
    
    if (vallcount > fallcount) then
      if timecheck(unit,"be","haetflor") then
        addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
        local loop_fall = 0
        local dx, dy, dir, px, py = -gravity_dir[1], -gravity_dir[2], 3, -1, -1
        local old_dir = 3
        while (caught == false) do
          loop_fall = loop_fall + 1
          if (loop_fall > 1000) then
            print("movement infinite loop! (1000 attempts at a faller)")
            destroyLevel("infloop")
            return
          end
          new_dx, new_dy, new_dir, px, py = getNextTile(unit, dx, dy, dir)
          if not canMove(unit, dx, dy, dir, false, false, nil, "haet skye") then
            caught = true
          end
          if caught == false then
            updateDir(unit, dirAdd(unit.dir, dirDiff(old_dir, dir)))
            old_dir = dir
            moveUnit(unit,px,py)
          end
          dx, dy, dir = new_dx, new_dy, new_dir
        end
      else
        if canMove(unit, 0, -1, 3, false, false, nil, "haet skye") then
          moveUnit(unit,unit.x,unit.y-1)
        end
      end
    end
  end]]
end

function doZip(unit)
  if not canMove(unit, 0, 0, -1, false, false, unit.name, "zip") then
    --try to zip to the tile behind us - this is usually elegant, since we probably just left that tile. if that fails, try increasingly larger squares around our current position until we give up. prefer squares closer to the tile behind us, arbitrarily break ties via however table.sort and the order we put tiles into it decides to do it!
    local dx = -dirs8[unit.dir][1]
    local dy = -dirs8[unit.dir][2]
    if canMove(unit, dx, dy, -1, false, false, unit.name, "zip") then
      addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
      moveUnit(unit,unit.x+dx,unit.y+dy)
      return
    end
    
    local orig = {x = dx, y = dy}
    start_radius = 1
    end_radius = 5
    for radius = start_radius, end_radius do
      places = {}
      for dx = -radius, radius do
        for dy = -radius, radius do
          table.insert(places, {x = dx, y = dy})
        end
      end
      table.sort(places, function(a, b) return euclideanDistance(a, orig) < euclideanDistance(b, orig) end )
      for _,place in ipairs(places) do
        local dx = place.x
        local dy = place.y
        --TODO: ZIP doesn't interact with WRAP/PORTAL. Maybe it should?
        if canMove(unit, dx, dy, -1, false, false, unit.name, "zip") then
          addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
          moveUnit(unit,unit.x+dx,unit.y+dy)
          return
        end
      end
    end
  end
end

--for use with wrap and portal. portals can change the facing dir, and facing dir can already be different from dx and dy, so we need to keep track of everything.
function getNextTile(unit,dx,dy,dir,reverse_,start_x,start_y)
  local reverse = reverse_ or false
  local rs = reverse and -1 or 1
  dx = dx*rs
  dy = dy*rs
  local move_dir = dirs8_by_offset[sign(dx)][sign(dy)] or 0
  local px, py = (start_x or unit.x)+dx, (start_y or unit.y)+dy
  --we have to loop because a portal might put us oob, which wraps and puts us in another portal, which puts us oob... etc
  local did_update = true
  local loop_portal = 0
  local portal_unit = nil
  while (did_update) do
    local pxold, pyold = px, py
    did_update = false
    loop_portal = loop_portal + 1
    if loop_portal > 1000 then
      print("movement infinite loop! (1000 attempts at wrap/portal)")
      destroyLevel("infloop")
    end
    px, py, move_dir, dir = doWrap(unit, px, py, move_dir, dir)
    px, py, move_dir, dir, punit = doPortal(unit, px, py, move_dir, dir, reverse)
    if punit then
      portal_unit = punit
    end
    if (px ~= pxold or py ~= pyold) then
      did_update = true
    end
  end
  dx = move_dir > 0 and dirs8[move_dir][1] or 0
  dy = move_dir > 0 and dirs8[move_dir][2] or 0
  return rs*dx, rs*dy, dir, px, py, portal_unit
end

function doWrap(unit, px, py, move_dir, dir)
  --fast track if we don't need to wrap anyway
  if inBounds(px,py) and not units_by_name["bordr"] then
    return px, py, move_dir, dir
  end
  --TODO: make mirr arnd also work with bordr. hard to know how that should work though
  if hasProperty(unit, "mirr arnd") or hasProperty(outerlvl, "mirr arnd") then --projective plane wrapping
    local dx, dy = 0, 0
    if (px < 0) then
      dx = -px
      px = 0
    elseif (px >= mapwidth) then
      dx = px-mapwidth+1
      px = mapwidth-1
    end
    if (py < 0) then
      dy = -py
      py = 0
    elseif (py >= mapheight) then
      dy = py-mapheight+1
      py = mapheight-1
    end
    if (dx ~= 0 or dy ~= 0) then
      px = px + (mapwidth/2-0.5-px)*2
      py = py + (mapheight/2-0.5-py)*2
    end
  end
  if hasProperty(unit, "go arnd") or hasProperty(outerlvl, "go arnd") then --torus wrapping
    --Orthogonal wrapping is trivial - eject backwards as far as we can.
    --Diagonal wrapping is a bit harder - it depends on if we're walking into a wall or a corner (inward or outward). If we're walking into a wall, eject perpendicularly out of it as far as we can. If we're walking into a corner, eject backwards as far as we can.
    if not inBounds(px,py) then
      local mx,my = dirs8[move_dir][1],dirs8[move_dir][2]
      local found = false
      if (mx == 0 or my == 0) then --orthgonal
        while not found do
          if inBounds(px-mx,py-my) then
            px = px-mx
            py = py-my
          else
            found = true
          end
        end
      else --diagonal, but into what?
        local vert_wall = not inBounds(px,py-my);
        local hori_wall = not inBounds(px-mx,py);
        if vert_wall == hori_wall then --inward or outward corner
          while not found do
            if inBounds(px-mx,py-my) then
              px = px-mx
              py = py-my
            else
              found = true
            end
          end
        elseif vert_wall then --vertical wall - eject horizontally
          while not found do
            if inBounds(px-mx,py) then
              px = px-mx
              py = py
            else
              found = true
            end
          end
        else --horizontal wall - eject vertically
          while not found do
            if inBounds(px,py-my) then
              px = px
              py = py-my
            else
              found = true
            end
          end
        end
      end
    end
  end

  return px, py, move_dir, dir
end

function doPortal(unit, px, py, move_dir, dir, reverse)
  if not inBounds(px,py) or rules_with["poor toll"] == nil then
    return px, py, move_dir, dir
  else
    local rs = reverse and -1 or 1
    --arbitrarily pick the first paired portal we find while iterating - can't think of a more 'simultaneousy' logic
    --I thought about making portals go backwards/forwards twice/etc depending on property count, but it doesn't play nice with pull - if two portals lead to a portal you move away from, which one do you pull from?
    --This was already implemented in cg5's mod, but I overlooked it the first time around - PORTAL is FLOAT respecting, so now POOR TOLL is FLYE respecting. Spooky! (I already know this will have weird behaviour with PULL and SIDEKIK, so looking forward to that.)
    for _,v in ipairs(getUnitsOnTile(px, py, nil, false)) do
      --At Vitellary's request, make it so you can only enter the front of a portal.
      if dirAdd(v.dir, 4) == move_dir and hasProperty(v, "poor toll") and sameFloat(unit, v, true) and not hasRule(unit,"haet",v) and ignoreCheck(unit,v,"poor toll") then
        local portal_rules = matchesRule(v.fullname, "be", "poor toll")
        local portals_direct = {}
        local portals = {}
        local portal_index = -1
        for _,rule in ipairs(portal_rules) do
          for _,s in ipairs(findUnitsByName(v.fullname)) do
            if testConds(s, rule.rule.subject.conds) then
              portals_direct[s] = true
            end
          end
        end
        -- Count portal colors
        local found_colored = {}
        for p,_ in pairs(portals_direct) do
          local color_id = getColor(p)[1]..","..getColor(p)[2]
          found_colored[color_id] = (found_colored[color_id] or 0) + 1
        end
        -- Only add portals to list if:
        -- A. They share the same color, or
        -- B. Only one of both color exists
        for p,_ in pairs(portals_direct) do
          local p_color_id = getColor(p)[1]..","..getColor(p)[2]
          local v_color_id = getColor(v)[1]..","..getColor(v)[2]
          if p_color_id == v_color_id then
            table.insert(portals, p)
          elseif found_colored[p_color_id] == 1 and found_colored[v_color_id] == 1 then
            table.insert(portals, p)
          end
        end
        table.sort(portals, readingOrderSort)
        --find our place in the list
        for pk,pv in ipairs(portals) do
          if pv == v then
            portal_index = pk
            break
          end
        end
        --did I ever mention I hate 1 indexed arrays?
        local dest_index = ((portal_index + rs - 1) % #portals) + 1
        local dest_portal = portals[dest_index]
        --I don't know how this bug happens, but it'll be easier to debug if it doesn't immediately crash the game LOL
        if (dest_portal == nil) then
          print("Expected to find a portal destination and didn't!"..","..tostring(#portals)..","..tostring(dest_index))
          break
        end
        local dir1 = v.dir
        --At Vitellary's request, and as a baba/bab difference, let's try making it so when you go in a (side), you come out the same (side) on the destination. Front to front, back to back, left side to left side and so on.
        local dir2 = rotate8(dest_portal.dir)
        move_dir = move_dir > 0 and dirAdd(move_dir, dirDiff(dir1, dir2)) or 0
        dir = dir > 0 and dirAdd(dir, dirDiff(dir1, dir2)) or 0
        local dx, dy = 0, 0
        if (move_dir > 0) then
          dx = dirs8[move_dir][1]
          dy = dirs8[move_dir][2]
        end
        px = dest_portal.x + dx
        py = dest_portal.y + dy
        return px, py, move_dir, dir, dest_portal
      end
    end
  end
  return px, py, move_dir, dir, nil
end

function dirDiff(dir1, dir2)
  if (dir1 == nil or dir2 == nil) then
    print("dirDiff:",dir1,dir2)
    return 0
  end
  if dir1 <= dir2 then
    return dir2 - dir1
  else
    return dir2 - (dir1+8)
  end
end

function dirAdd(dir1, diff)
  if (diff == nil) then
    print("dirAdd:",dir1,diff)
    return dir1 or 1
  elseif (dir1 == nil) then
    print("dirAdd:",dir1,diff)
    return diff
  end
  dir1 = dir1 + diff
  while dir1 < 1 do
    dir1 = dir1 + 8
  end
  while dir1 > 8 do
    dir1 = dir1 - 8
  end
  return dir1
end

--stubborn units will try to slide around an obstacle in their way. everyone else just passes through!
--stubbornness increases with amount of stacks:
--1 stack: 45 degree angles for diagonal moves only
--2 stacks: 45 degree angles for all moves
--3 stacks: up to 90 degrees
--4 stacks: up to 135 degrees
--5 stacks: up to 180 degrees (e.g. all directions)
function canMove(unit,dx,dy,dir,pushing_,pulling_,solid_name,reason,push_stack_,start_x,start_y)
  if hasProperty(unit, "loop") or hasProperty(unit, "stukc") then
    return false,{},{}
  end
  local success, movers, specials = canMoveCore(unit,dx,dy,dir,pushing_,pulling_,solid_name,reason,push_stack_,start_x,start_y)
  if hasProperty(unit,"big") then
    for i=1,3 do
      local newsuccess, newmovers, newspecials = canMoveCore(unit,dx,dy,dir,pushing_,pulling_,solid_name,reason,push_stack_,(start_x or unit.x)+i%2,(start_y or unit.y)+math.floor(i/2))
      mergeTable(movers,newmovers)
      mergeTable(specials,newspecials)
      success = success and newsuccess
    end
  end
  if success then
    return success, movers, specials
  elseif dir > 0 and pushing_ then
    local stubbn = countProperty(unit, "stubbn")
    if stubbn > 0 and (dir % 2 == 0) or stubbn > 1 then
      for i = 1,clamp(stubbn-1, 1, 4) do
        local stubborndir1 = ((dir+i-1)%8)+1
        local stubborndir2 = ((dir-i-1)%8)+1
        local success1, movers1, specials1 = canMoveCore(unit,dirs8[stubborndir1][1],dirs8[stubborndir1][2],dir,pushing_,pulling_,solid_name,reason,push_stack_,start_x,start_y)
        local success2, movers2, specials2 = canMoveCore(unit,dirs8[stubborndir2][1],dirs8[stubborndir2][2],dir,pushing_,pulling_,solid_name,reason,push_stack_,start_x,start_y)
        if (success1 and not success2) then
          return success1,movers1,specials1
        elseif (success2 and not success1) then
          return success2,movers2,specials2
        elseif (success1 and success2) then --both succeeded - return whichever requires less effort
          if #movers1 <= #movers2 then
            return success1,movers1,specials1
          else
            return success2,movers2,specials2
          end
        end
      end
    end
  end
  return success, movers, specials
end

function canMoveCore(unit,dx,dy,dir,pushing_,pulling_,solid_name,reason,push_stack_,start_x,start_y)
  --if we haet outerlvl, we can't move, period.
  if rules_with["haet"] ~= nil and hasRule(unit, "haet", outerlvl) and not ignoreCheck(unit,outerlvl) then
    return false,{},{}
  end
  
  if rules_with["go my way"] ~= nil and hasProperty(outerlvl,"go my way") and not ignoreCheck(unit,outerlvl) and goMyWayPrevents(outerlvl.dir,dx,dy) then
    return false,{},{}
  end

  --prevent infinite push loops by returning false if a push intersects an already considered unit
  --EDIT: let's try returning true instead and allowing them to happen. plays nicely with portal loops. For stubborn, maybe we just allow max one direction change or something... (So we pass a flag along to know if we've made our one change or not.)
  local push_stack = push_stack_ or {}
  
  if (push_stack[unit] == true) then
    return true,{},{}
  end
  
  local pushing = false
  if (pushing_ ~= nil and not hasProperty(unit, "shy...")) then
		pushing = pushing_
	end
  --TODO: Patashu: this isn't used now but might be in the future??
  local pulling = false
	if (pulling_ ~= nil and not hasProperty(unit, "shy...")) then
		pulling = pulling_
	end
  
  --apply munwalk, sidestep and diagstep here (only if making a push move, to not mess up other checks)
  if (pushing and walkdirchangingrulesexist) then
    local old_dx, old_dy = dx, dy
    local movecount = 4 * countProperty(unit, "munwalk") + 2 * countProperty(unit, "sidestep") + countProperty(unit, "diagstep")
    if movecount % 2 == 1 then
      local root2 = math.sqrt(0.5)
      local diagx = round(root2*old_dx-root2*old_dy)
      local diagy = round(root2*old_dx+root2*old_dy)
      dx = diagx
      dy = diagy
    end
    if movecount % 4 >= 2 then
      old_dx = dx
      dx = -dy
      dy = old_dx
    end
    if movecount % 8 >= 4 then
      dx = -dx
      dy = -dy
    end
    if hasProperty(unit, "knightstep") then
      local root2 = math.sqrt(0.5)
      local diagx = round(root2*dx-root2*dy)
      local diagy = round(root2*dx+root2*dy)
      local knights = countProperty(unit,"knightstep")
      if (dx - dy) % 2 == 1 then
        dx = knights * diagx + dx
        dy = knights * diagy + dy
      elseif (dx - dy) % 2 == 0 then
        dx = diagx + dx * knights
        dy = diagy + dy * knights
      end
    end
    if hasProperty(unit, "hopovr") then
      local hops = countProperty(unit, "hopovr")
      dx = dx * (hops + 1)
      dy = dy * (hops + 1)
    end
  end
	
	
  local move_dx, move_dy = dx, dy
  local move_dir = dirs8_by_offset[sign(move_dx)][sign(move_dy)] or 0
  local old_dir = dir
  local dx, dy, dir, x, y, portal_unit = getNextTile(unit, dx, dy, dir, nil, start_x, start_y)
  local geometry_spin = dirDiff(dir, old_dir)
  
  local movers = {}
  local specials = {}
  table.insert(movers, {unit = unit, dx = x-unit.x, dy = y-unit.y, dir = dir, move_dx = move_dx, move_dy = move_dy, move_dir = move_dir, geometry_spin = geometry_spin, portal = portal_unit})
  
  if rules_with["ignor"] ~= nil and not ignoreCheck(unit,outerlvl) then
    return true,movers,{}
  end
  
  --STUB: We probably want to do something more explicit like synthesize bordr units around the border so they can be explicitly moved/created/destroyed/have conditional rules apply to them.
  if not (inBounds(x,y) or hasRule("bordr","ben't","no go") or not ignoreCheck(unit,"bordr")) then
    if pushing and hasProperty(unit, "ouch") and not hasProperty(unit, "protecc") and (reason ~= "walk" or hasProperty(unit, "stubbn")) then
      table.insert(specials, {"weak", {unit}})
      return true,movers,specials
    end
    return false,{},{}
  end

  if hasProperty(unit, "diag") and (not hasProperty(unit, "ortho")) and (dx == 0 or dy == 0) then
    return false,movers,specials
  end
  if hasProperty(unit, "ortho") and (not hasProperty(unit, "diag")) and (dx ~= 0 and dy ~= 0) then
    return false,movers,specials
  end
  
  --bounded: if we're bounded and there are no units in the destination that satisfy a bounded rule, AND there's no units at our feet that would be moving there to carry us, we can't go
  --we used to have a fast track, but now selector is ALWAYS bounded to stuff, so it's never going to be useful.
  --liek only triggers if there is at least one unit we currently liek in existence
  local bound_to_object = #matchesRule(unit, "liek", nil) > 0
  if (bound_to_object) then
    local isbounded = matchesRule(unit, "liek", "?")
    for i,ruleparent in ipairs(isbounded) do
      local liek = ruleparent.rule.object.name
      local success = false
      if hasRule(unit,"liek",liek) and hasRule(unit,"haet",liek) then
        success = true
      end
      for _,v in ipairs(getUnitsOnTile(x, y, nil, false, nil, true)) do
        if hasRule(unit, "liek", v) and ignoreCheck(unit,v) then
          success = true
          break
        end
      end
      if not success then
        for _,update in ipairs(update_queue) do
          if update.reason == "update" then
            local unit2 = update.unit
            local x2 = update.payload.x
            local y2 = update.payload.y
            if x2 == x and y2 == y and hasRule(unit, "liek", unit2) and ignoreCheck(unit,unit2) then
              success = true
              break
            end
          end
        end
      end
      if not success then
        return false,{},{}
      end
    end
  end
  
  local isnthere = matchesRule(unit,"ben't","her")
  if (#isnthere > 0) then
    for _,ruleparent in ipairs(isnthere) do
      local here = ruleparent.rule.object.unit
      local hx = dirs8[here.dir][1]
      local hy = dirs8[here.dir][2]
      
      if (x == here.x+hx) and (y == here.y+hy) then
        return false,movers,specials
      end
    end
  end
  
  local isntthere = matchesRule(unit,"ben't","thr")
  if (#isntthere > 0) then
    for _,ruleparent in ipairs(isntthere) do
      local there = ruleparent.rule.object.unit
      
      local tx = there.x
      local ty = there.y
      local tdir = there.dir
      local tdx = dirs8[there.dir][1]
      local tdy = dirs8[there.dir][2]
      
      local tstopped = false
      while not tstopped do
        if canMove(there,tdx,tdy,tdir,false,false,nil,nil,nil,tx,ty) then
          tdx,tdy,tdir,tx,ty = getNextTile(there, tdx, tdy, tdir, nil, tx, ty)
          if (x == tx) and (y == ty) then
            return false,movers,specials
          end
        else
          tstopped = true
        end
      end
    end
  end
  
  local isntrithere = matchesRule(unit,"ben't","rithere")
  if (#isntrithere > 0) then
    for _,ruleparent in ipairs(isntrithere) do
      local here = ruleparent.rule.object.unit
      if (x == here.x) and (y == here.y) then
        return false,movers,specials
      end
    end
  end
  
  local nedkee = hasProperty(unit, "ned kee")
  local fordor = hasProperty(unit, "for dor")
  local swap_mover = hasProperty(unit, "behin u")
  
  --normal checks
  local stopped = false
  --we have to iterate every object even after we're stopped, in case later we find something we open/snacc/ouch on
  for _,v in ipairs(getUnitsOnTile(x, y, nil, false, nil, true)) do
    --Patashu: treat moving things as intangible in general. also, ignore ourselves for zip purposes
    if (v ~= unit and not v.already_moving and sameFloat(unit,v,true)) then
      if (v.name == solid_name) and ignoreCheck(unit,v) then
        return false,movers,specials
      end
      --local would_swap_with = (swap_mover and ignoreCheck(v,unit,"behin u")) or (hasProperty(v, "behin u") and ignoreCheck(unit,v,"behin u")) and pushing
      local would_swap_with = swap_mover or hasProperty(v, "behin u") and pushing
      --pushing a key into a door automatically works
      if ((fordor and hasProperty(v, "ned kee")) or (nedkee and hasProperty(v, "for dor"))) and sameFloat(unit, v) then
        local dont_ignore_unit = (nedkee and ignoreCheck(unit,v,"for dor")) or (fordor and ignoreCheck(unit,v,"ned kee"))
        local dont_ignore_other = (hasProperty(v,"ned kee") and ignoreCheck(v,unit,"for dor")) or (hasProperty(v,"for dor") and ignoreCheck(unit,v,"ned kee"))
        if dont_ignore_unit or dont_ignore_other then
          if (timecheck(unit,"be","ned kee") and timecheck(v,"be","for dor")) or (timecheck(unit,"be","for dor") and timecheck(v,"be","ned kee")) then
            local opened = {}
            if dont_ignore_unit then
              table.insert(opened, unit)
            end
            if dont_ignore_other then
              table.insert(opened, v)
            end
            table.insert(specials, {"open", opened})
            return true,{movers[1]},specials
          else
            if dont_ignore_unit then
              table.insert(time_destroy,unit.id)
              addUndo({"time_destroy",unit.id})
              addParticles("destroy", unit.x, unit.y, {237,226,133})
            end
            if dont_ignore_other then
              table.insert(time_destroy,v.id)
              addUndo({"time_destroy",v.id})
              addParticles("destroy", v.x, v.y, {237,226,133})
            end
            table.insert(time_sfx,"break")
            table.insert(time_sfx,"unlock")
          end
        end
      end
      --New FLYE mechanic, as decreed by the bab dictator - if you aren't sameFloat as a push/pull/sidekik, you can enter it.
      -- print("checking if",v.name,"has goawaypls")
      if not table.has_value(unitsByTile(v.x,v.y),unit) then
        local push = hasProperty(v, "go away pls") and ignoreCheck(unit,v,"go away pls")
        local moov = hasRule(unit, "moov", v) and ignoreCheck(unit,v);
        if (push or moov) and not would_swap_with then
          -- print("success")
          if pushing and ignoreCheck(v,unit) then
            --glued units are pushed all at once or not at all
            if hasProperty(v, "glued") then
              local units, pushers, pullers = FindEntireGluedUnit(v, dx, dy)
              
              local all_success = true
              local newer_movers = {}
              for _,v2 in ipairs(pushers) do
                push_stack[unit] = true
                local success,new_movers,new_specials = canMove(v2, dx, dy, dir, pushing, pulling, solid_name, push and "go away pls" or "moov", push_stack)
                push_stack[unit] = nil
                mergeTable(specials, new_specials)
                mergeTable(newer_movers, new_movers)
                if not success then all_success = false end
              end
              if all_success then
                mergeTable(movers, newer_movers)
                for _,add in ipairs(units) do
                  table.insert(movers, {unit = add, dx = dx, dy = dy, dir = dir, move_dx = move_dx, move_dy = move_dy, move_dir = move_dir, geometry_spin = geometry_spin, portal = portal_unit})
                end
                --print(dump(movers))
              elseif push then
                stopped = stopped or sameFloat(unit, v)
              end
            else
              --single units have to be able to move themselves to be pushed
              push_stack[unit] = true
              local success,new_movers,new_specials = canMove(v, dx, dy, dir, pushing, pulling, solid_name, push and "go away pls" or "moov", push_stack)
              push_stack[unit] = nil
              for _,special in ipairs(new_specials) do
                table.insert(specials, special)
              end
              if success then
                for _,mover in ipairs(new_movers) do
                  table.insert(movers, mover)
                end
              elseif push then
                stopped = stopped or sameFloat(unit, v)
              end
            end
          elseif push then
            stopped = stopped or sameFloat(unit, v)
          end
        else
          -- print("fail (or would_swap_with)")
        end
      end
      
      --if/elseif chain for everything that sets stopped to true if it's true - no need to check the remainders after all! (but if anything ignores flye, put it first, like haet!)
      if rules_with["haet"] ~= nil and hasRule(unit, "haet", v) and not hasRule(unit,"liek",v) and ignoreCheck(unit,v) then
        stopped = true
      elseif hasProperty(v, "no go") then --Things that are STOP stop being PUSH or PULL, unlike in Baba. Also unlike Baba, a wall can be floated across if it is not tall!
        stopped = stopped or (sameFloat(unit, v) and ignoreCheck(unit,v,"no go"))
      elseif hasProperty(v, "sidekik") and not hasProperty(v, "go away pls") and not would_swap_with then
        stopped = stopped or (sameFloat(unit, v) and ignoreCheck(unit,v,"sidekik"))
      elseif hasProperty(v, "diagkik") and not hasProperty(v, "go away pls") and not would_swap_with then
        stopped = stopped or (sameFloat(unit, v) and ignoreCheck(unit,v,"diagkik"))
      elseif hasProperty(v, "come pls") and not hasProperty(v, "go away pls") and not would_swap_with and not pulling then
        stopped = stopped or (sameFloat(unit, v) and ignoreCheck(unit,v,"come pls"))
      elseif hasProperty(v, "reflecc") and refleccPrevents(v.dir, dx, dy) then
        stopped = stopped or (sameFloat(unit, v) and ignoreCheck(unit,v,"reflecc"))
      elseif hasProperty(v, "go my way") and goMyWayPrevents(v.dir, dx, dy) then
        stopped = stopped or (sameFloat(unit, v) and ignoreCheck(unit,v,"go my way"))
      end
      if stopped and v.name == "gato" then
        v.draw.rotation = v.draw.rotation - 10
        addTween(tween.new(0.5, v.draw, {rotation = (v.rotatdir-1)*45}, "outElastic"), "v:rotation:" .. v.tempid)
      end
      
      --ouch/snacc logic:
      --1) if mover can destroy wall via ouch/snacc, then allow movement AND destroy the wall immediately
      --2) if mover will be destroyed by walking into a wall, prevent movement AND destroy mover immediately
      --3) if both are true, then block movement AND destroy BOTH immediately
      
      if stopped then
        local exploding = false
        --Case 1 or 3 - wall will be destroyed by us walking onto it.
        local ouch = hasProperty(v, "ouch")
        local snacc = rules_with["snacc"] ~= nil and hasRule(unit, "snacc", v)
        if (ouch or snacc) and not hasProperty(v, "protecc") and sameFloat(unit, v) and ignoreCheck(v,unit) then
          table.insert(specials, {ouch and "weak" or "snacc", {v}})
          exploding = true
        end
      
        --Case 2 or 3 - we will be destroyed by walking onto a wall.
        local ouch = hasProperty(unit, "ouch")
        local snacc = rules_with["snacc"] ~= nil and hasRule(v, "snacc", unit)
        if (ouch or snacc) and not hasProperty(unit, "protecc") and (reason ~= "walk" or not hasProperty(unit, "stubbn")) and ignoreCheck(unit,v) then
          table.insert(specials, {ouch and "weak" or "snacc", {unit}})
          exploding = true
        end
        
        if exploding then return true,movers,specials end
        --if exploding then return true,{movers[1]},specials end
      end
    end
  end
  
  --go my way DOES Not also prevents things from leaving them against their direction
  --[[for _,v in ipairs(getUnitsOnTile(unit.x, unit.y, nil, false)) do
    if hasProperty(v, "go my way") and goMyWayPrevents(v.dir, dx, dy) then
      return false,movers,specials
    end
  end]]--

  return not stopped,movers,specials
end

function refleccPrevents(dir, dx, dy)
  dx = sign(dx)
  dy = sign(dy)
  local otherDir = dirs8_by_offset[dx][dy];
  local dirDifference = otherDir - dir;
  if (dirDifference < 0) then dirDifference = dirDifference + 8; end
  return dirDifference == 1 or dirDifference == 5
end

function goMyWayPrevents(dir, dx, dy)
  dx = sign(dx)
  dy = sign(dy)
  return
     (dir == 1 and dx == -1) or (dir == 2 and (dx == -1 or dy == -1) and (dx ~=  1 and dy ~=  1))
  or (dir == 3 and dy == -1) or (dir == 4 and (dx ==  1 or dy == -1) and (dx ~= -1 and dy ~=  1))
  or (dir == 5 and dx ==  1) or (dir == 6 and (dx ==  1 or dy ==  1) and (dx ~= -1 and dy ~= -1)) 
  or (dir == 7 and dy ==  1) or (dir == 8 and (dx == -1 or dy ==  1) and (dx ~=  1 and dy ~= -1))
end

function getNextLevels()
  local next_levels, next_level_objs = {}, {}
  local us = getUnitsWithEffect("u")
  for _,unit in ipairs(us) do
    local lvls = getUnitsOnTile(unit.x, unit.y, nil, false, unit)
    for _,lvl in ipairs(lvls) do
      if lvl.special.level and lvl.special.visibility == "open" then
        table.insert(next_level_objs, lvl)
        table.insert(next_levels, lvl.special.level)
      end
    end
  end
  
  next_level_name = ""
  for _,name in ipairs(next_levels) do
    local split_name = split(name, "/")
    if _ > 1 then
      next_level_name = next_level_name .. " & " .. split_name[#split_name]
    else
      next_level_name = split_name[#split_name]
    end
  end
  
  return next_levels, next_level_objs
end

function FindEntireGluedUnit(unit, dx, dy)
  --print("0:",unit.x,unit.y,dx,dy)
  local units, pushers, pullers = {}, {}, {}
  local visited = {}
  local ignored = {}
  visited[tostring(unit.x)..","..tostring(unit.y)] = unit
  local mycolor = unit.color_override or unit.color
  local myorthook = not hasProperty(unit,"diag") or hasProperty(unit,"ortho")
  local mydiagok = not hasProperty(unit,"ortho") or hasProperty(unit,"diag")
  
  --base case - add the original unit
  table.insert(units, unit)
  
  --base case - add the original unit and check if it's a pusher and/or puller
  --[[table.insert(units, unit)
  
  local others = getUnitsOnTile(x+dx, y+dy, unit.name)
  for _,other in others do
    if hasProperty(other,"glued") then
      local ocolor = other.color_override or other.color
      if (mycolor[1] == ocolor[1] and mycolor[2] == ocolor[2]) then
        table.insert(pushers, unit)
        break
      end
    end
  end
  
  local others = getUnitsOnTile(x-dx, y-dy, unit.name)
  for _,other in others do
    if hasProperty(other,"glued") then
      local ocolor = other.color_override or other.color
      if (mycolor[1] == ocolor[1] and mycolor[2] == ocolor[2]) then
        table.insert(pullers, unit)
        break
      end
    end
  end]]
  
  --on with the floodfill!
  local unchecked_tiles = {{unit.x, unit.y}}
  
  while #unchecked_tiles > 0 do
    local x, y = unchecked_tiles[1][1], unchecked_tiles[1][2]
    local cur_unit = visited[tostring(x)..","..tostring(y)]
    --print("a:",x,y,cur_unit)
    table.remove(unchecked_tiles, 1)
    --print("a.5:",#unchecked_tiles)
    
    --check all 8 directions
    for i = 1,8 do if (i % 2 == 1 and myorthook) or (i % 2 == 0 and mydiagok) then
      local cur_dx, cur_dy = dirs8[i][1], dirs8[i][2]
      local xx, yy = x+cur_dx, y+cur_dy
      --print("b:",cur_dx,cur_dy,xx,yy,tostring(xx)..","..tostring(yy),visited[tostring(xx)..","..tostring(yy)])
      --visit surrounding tiles if we don't know their status yet
      if visited[tostring(xx)..","..tostring(yy)] == nil then
        --print("c")
        visited[tostring(xx)..","..tostring(yy)] = false
        local others = getUnitsOnTile(xx, yy)
        local first = false
        for _,other in ipairs(others) do
          --print("d:",other.name)
          if hasProperty(other,"glued") and ignoreCheck(cur_unit,other,"glued") then
            local ocolor = other.color_override or other.color
            --print("e:", dump(mycolor),dump(ocolor))
            if (mycolor[1] == ocolor[1] and mycolor[2] == ocolor[2]) then
              --print("f, we did it")
              if ignoreCheck(other,cur_unit,"glued") then
                table.insert(units, other)
              else
                ignored[other] = true
              end
              --print(#units)
              --we haven't expanded out from this tile yet - queue it
              if not first then
                table.insert(unchecked_tiles, {xx, yy})
                --print("f.5:",#unchecked_tiles)
                first = true
                visited[tostring(xx)..","..tostring(yy)] = other
              end
            end
          end
        end
        --END iterate units on that tile
      end
      --END visit surrounding unvisited tile
        
      --while checking the forward/backward direction, add the current unit to pushers/pullers if we know the tile ahead of/behind it is vacant
      --print("g", dx, cur_dx, dy, cur_dy, visited[tostring(xx)..","..tostring(yy)], not visited[tostring(xx)..","..tostring(yy)])
      if dx == cur_dx and dy == cur_dy and not visited[tostring(xx)..","..tostring(yy)] and not ignored[cur_unit] then
        --print("added a pusher:",cur_unit.x,cur_unit.y)
        table.insert(pushers, cur_unit)
      elseif -dx == cur_dx and -dy == cur_dy and not visited[tostring(xx)..","..tostring(yy)] and not ignored[cur_unit] then
        --print("added a puller")
        table.insert(pullers, cur_unit)
      end

    end end
    --END check all 8 directions 
    --print("final:",#unchecked_tiles)
  end
  --END check all unchecked tiles

  --failsafe: return the original unit in case we couldn't floodfill at all for whatever reason
  
  if #units == 0 then
    table.insert(units, unit)
  end
  if #pushers == 0 then
    table.insert(pushers, unit)
  end
  if #pullers == 0 then
    table.insert(pullers, unit)
  end

  return units, pushers, pullers
end