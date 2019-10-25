function newUndo()
  table.insert(undo_buffer, 1, {})
  undo_buffer[1].last_move = last_move
end

function addUndo(data)
  --print("addUndo:",data[1],data[2],data[3],data[4],data[5],data[6],data[7])
  if #undo_buffer > 0 then 
    table.insert(undo_buffer[1], 1, data)
  end
end

function consolidateUndo(turn)
  --Goal of this function - if we ended on a trivial movement infinite loop, consolidate the 1000 updates into one.
  if #undo_buffer > 0 then 
    local buff = undo_buffer[1]
    local prev_undo = nil
    local cur_undo = nil
    for i = #buff,1,-1 do
      cur_undo = buff[i]
      if (prev_undo ~= nil and prev_undo[1] == "update" and cur_undo[1] == "update" and prev_undo[2] == cur_undo[2]) then
        --we found two updates for the same unit in a row - we can ditch the older one
        table.remove(buff, i)
      else
        prev_undo = cur_undo
      end
    end
  end
end

function addUndoMaybeOverwrite(data)
  --to save space when crazy infloop/try again stuff happens
  if #undo_buffer > 0 then 
    local most_recent_undo = undo_buffer[1][1]
    if most_recent_undo[1] == data[1] and most_recent_undo[2] == data[2] then
      --this causes bugs, need to investigate I guess
      --returning seems to work better on average?
      --print("abort!")
      return
      --print("replacing:", fullDump(most_recent_undo), "with:", fullDump(data))
      --table.remove(undo_buffer[1], 1)
    end
    table.insert(undo_buffer[1], 1, data)
  end
end

function undoOneAction(turn, i, v, ignore_no_undo)
  --print("undoOneAction:",v[1],v[2],v[3],v[4],v[5],v[6],v[7])
  local update_rules = false
  local action = v[1]
  local unit = nil
  
  if action == "update" then
    unit = units_by_id[v[2]]
    --print("undoOneAction update", unit.name, v[3], v[4])
    if unit ~= nil and (ignore_no_undo or not isNoUndo(unit)) then
      moveUnit(unit,v[3],v[4])
      --force updates when we're rewinding time - it ABSOLUTELY had that direction in the past
      updateDir(unit, v[5], true)

      if unit.type == "text" or rules_effecting_names[unit.name] or rules_effecting_names[unit.fullname] then
        update_rules = true
      end
    end
  elseif action == "create" then
    local convert = v[3]
    unit = units_by_id[v[2]]
    --print("undoOneAction create:",fullDump(v), unit)
    if unit ~= nil and (unit.type == "text" or rules_effecting_names[unit.name] or rules_effecting_names[unit.fullname])  then
      update_rules = true
    end

    if unit ~= nil and (ignore_no_undo or not isNoUndo(unit)) then
      deleteUnit(unit, convert, true)
    end
  elseif action == "remove" then
    local convert = v[6]
    --If the unit was converted into 'no undo' byproducts that still exist, don't bring it back.
    local proceed = true
    if (convert and not ignore_no_undo and rules_with["no undo"] ~= nil) then
      proceed = not turnedIntoOnlyNoUndoUnits(turn, i, v[7])
    end
    if (proceed) then
      unit = createUnit(v[2], v[3], v[4], v[5], convert, v[7])
      if unit ~= nil then
        unit.special = v[8]
      end
      --If the unit was actually a destroyed 'no undo', oops. Don't actually bring it back. It's dead, Jim.
      if (unit ~= nil and not convert and (not ignore_no_undo and isNoUndo(unit))) then
        deleteUnit(unit, convert, true)
      end

      if unit ~= nil and (unit.type == "text" or rules_effecting_names[unit.name] or rules_effecting_names[unit.fullname])  then
        update_rules = true
      end
    end
    --TODO: test MOUS vs NO UNDO interactions
  elseif action == "create_cursor" then
    --love.mouse.setPosition(v[2], v[3])
    deleteMouse(v[2]) --id
  elseif action == "remove_cursor" then
    --love.mouse.setPosition(v[2], v[3])
    createMouse_direct(v[2], v[3], v[4]) --x, y, id
  elseif action == "backer_turn" then
    unit = units_by_id[v[2]]
    --print("undo backer_turn:", unit.fullname, backers_cache[unit], unit.backer_turn, v[3])
    if (unit ~= nil and (ignore_no_undo or not isNoUndo(unit))) then
      backers_cache[unit] = v[3]
      unit.backer_turn = v[3]
    end
  elseif action == "destroy_level" then
    level_destroyed = false
  elseif action == "za warudo" then
    timeless = not v[2]
    if timeless then playSound("timestop", 0.5)
    else playSound("time resume", 0.5)
    end
  elseif action == "time_destroy" then
		unitid = v[2]
    --iterate backwards because we probably got added to the end (but maybe not due to no undo shenanigans e.g.)
    for i=#time_destroy,1,-1 do
      if time_destroy[i] == unitid then
        table.remove(time_destroy, i)
        break
      end
    end
  elseif action == "time_destroy_remove" then
    table.insert(time_destroy, v[2])
  elseif action == "timeless_win_add" then
		unitid = v[2]
    --iterate backwards because we probably got added to the end (but maybe not due to no undo shenanigans e.g.)
    for i=#timeless_win,1,-1 do
      if timeless_win[i] == unitid then
        table.remove(timeless_win, i)
        break
      end
    end
  elseif action == "timeless_win_remove" then
    table.insert(timeless_win, v[2])
  elseif action == "timeless_unwin_add" then
		unitid = v[2]
    --iterate backwards because we probably got added to the end (but maybe not due to no undo shenanigans e.g.)
    for i=#timeless_unwin,1,-1 do
      if timeless_unwin[i] == unitid then
        table.remove(timeless_unwin, i)
        break
      end
    end
  elseif action == "timeless_unwin_remove" then
    table.insert(timeless_unwin, v[2])
  elseif action == "timeless_split_add" then
		timeless_split[v[2]] = nil
  elseif action == "timeless_split_remove" then
    timeless_split[v[2]] = v[3]
  elseif action == "timeless_reset_add" then
		timeless_reset = false
  elseif action == "timeless_reset_remove" then
    --causes an infinite loop, and kind of meaningless by definition I guess
    --timeless_reset = true
  elseif action == "timeless_crash_add" then
		timeless_crash = false
  elseif action == "timeless_crash_remove" then
    --meaningless by definition
    --timeless_crash = true
  elseif action == "timeless_yeet_add" or action == "timeless_yeet_remove" then
    timeless_yote[v[2]] = v[3]
  elseif action == "timeless_rules" then
    rules_with = v[2]
    full_rules = v[3]
    for _,rule in ipairs(full_rules) do
      for _,unit in ipairs(rule.units) do
        unit.active = true
      end
    end
	elseif action == "colour_change" then
    unit = units_by_id[v[2]]
    colour = v[3]
    value = v[4]
    if (unit ~= nil and (ignore_no_undo or not isNoUndo(unit))) then
      unit[colour] = value
      updateUnitColourOverride(unit)
    end
  elseif action == "color_override_change" then
    unit = units_by_id[v[2]]
    value = v[3]
    if (unit ~= nil and (ignore_no_undo or not isNoUndo(unit))) then
      unit.color_override = value
    end
  elseif action == "past" then
    current_move = v[2]
    while #all_moves >= v[3] do
      table.remove(all_moves)
    end
  elseif action == "tween" then
    removeFromTable(still_converting, v[2])
  end
  return update_rules, unit
end

function doBack(unitid, turn, _ignore_no_undo)
  --UNDO being able to supercede NO UNDO sounds more interesting than if it's a non-interaction imo, means you could make a puzzle where you have to rewind something that was otherwise impossible to rewind
  local ignore_no_undo = _ignore_no_undo
  if (ignore_no_undo == nil) then ignore_no_undo = true end
  if (turn <= 0) then
    return false
  end
  if undo_buffer[turn] ~= nil then
    --add a dummy action so that undoing happens
    if (#undo_buffer[1] == 0) then
      addUndo({"dummy"})
    end
    for _,v in ipairs(undo_buffer[turn]) do 
      local action = v[1]
      local unit = units_by_id[v[2]]
      --print("doBack:", fullDump(v))
      if (action == "remove") then --should be impossible with UNDO, for TRY AGAIN purposes
        local id = v[7];
        addUndo({"create", v[7], true, v.created_from_id})
        undoOneAction(turn, _, v, ignore_no_undo)
      end
      if unit ~= nil and (unit.id == unitid or unitid == nil) then
        if (action == "update") then
          --print("doBack update", unit.name, unit.x, unit.y, v[3], v[4])
          addUndoMaybeOverwrite({"update", unit.id, unit.x, unit.y, unit.dir})
          undoOneAction(turn, _, v, ignore_no_undo)
        elseif (action == "create") then
          local convert = v[6]
          local created_from_id = v.created_from_id
          if (unit.backer_turn ~= nil) then
            addUndo({"backer_turn", unit.id, unit.backer_turn})
          end
          addUndo({"remove", unit.tile, unit.x, unit.y, unit.dir, convert or false, unit.id})
          undoOneAction(turn, _, v, ignore_no_undo)
          scanAndRecreateOldUnit(turn, _, unit.id, created_from_id, ignore_no_undo)
        elseif (action == "create_cursor") then
          addUndo({"remove_cursor", unit.screenx, unit.screeny, unit.id})
          undoOneAction(turn, _, v, ignore_no_undo)
          --TODO: test MOUS vs UNDO interactions
        elseif (action == "colour_change") then
          colour = v[3]
          value = v[4]
          addUndo({"colour_change", unit.id, colour, unit[colour]})
          unit[colour] = value
          updateUnitColourOverride(unit)
        elseif action == "color_override_change" then
          value = v[3]
          addUndo({"color_override_change", unit.id, unit.color_override})
          unit.color_override = value
        end
      end
    end
    --print(fullDump(undo_buffer[1]))
    return true
  end
  return false
end

--If gras becomes roc, then later roc becomes undo, when it disappears we want the gras to come back. This is how we code that - by scanning for the related remove event and undoing that too.
function scanAndRecreateOldUnit(turn, i, unit_id, created_from_id, ignore_no_undo)
  while (true) do
    local v = undo_buffer[turn][i]
    if (v == nil) then
      return
    end
    local action = v[1]
    --TODO: implement for MOUS
    if (action == "remove") then
      local old_creator_id = v[7]
      if v[7] == created_from_id then
        --no exponential cloning if gras turned into 2 rocs - abort if there's already a unit with that name on that tile
        local tile, x, y = v[2], v[3], v[4]
        local data = tiles_list[tile]
        local stuff = getUnitsOnTile(x, y, nil, true)
        for _,on in ipairs(stuff) do
          if on.name == data.name then
            return
          end
        end
        local _, new_unit = undoOneAction(turn, i, v, ignore_no_undo)
        if (new_unit ~= nil) then
          addUndo({"create", new_unit.id, true, created_from_id = unit_id})
        end
        return
      end
    end
    i = i - 1
  end
end

--if water becomes roc, and roc is no undo, if we undo then the water shouldn't come back. This is how we code that - by scanning for all related create events. If we find one existing no undo byproduct and no existing non-no undo byproducts, we return false.
function turnedIntoOnlyNoUndoUnits(turn, i, unit_id)
  local found_no_undo = false
  local found_non_no_undo = false
  while (true) do
    local v = undo_buffer[turn][i]
    if (v == nil) then
      break
    end
    local action = v[1]
    --TODO: implement for MOUS
    if (action == "create") and v.created_from_id == unit_id then
      local still_exists = units_by_id[v[2]]
      if (still_exists ~= nil) then
        if (isNoUndo(still_exists)) then
          found_no_undo = true
        else
          found_non_no_undo = true
          break
        end
      end
    end
    i = i + 1
  end
  return not (found_non_no_undo or not found_no_undo)
end

function undo(dont_update_rules)
  if isNoUndo(outerlvl) and not replay_pause then return end
  undoing = true
  if undo_buffer[1] ~= nil then
    local update_rules = false
    
    last_move = undo_buffer[1].last_move or {0, 0}
    current_turn = current_turn - 1

    for _,v in ipairs(undo_buffer[1]) do
      local new_update_rules = undoOneAction(1, _, v, false)
      update_rules = update_rules or new_update_rules
    end
    updateUnits(true)
    if (dont_update_rules ~= true) and update_rules then
      should_parse_rules = true
      parseRules(true)
    end
    updateGroup()
    calculateLight()
    updateUnits(true)
    updatePortals()
    miscUpdates()

    table.remove(undo_buffer, 1)
  else
      undoing = false
      return false
  end
  undoing = false
  return true
end

function doTryAgain(_ignore_no_undo)
  local ignore_no_undo = _ignore_no_undo
  if (ignore_no_undo == nil) then ignore_no_undo = false end
  in_try_again = true
  try_again_cache = {}
  --cache units that are no undo so even if it's conditional they remain that way the entire time
  local isnoundo = getUnitsWithEffect("no undo")
  for _,unit in ipairs(isnoundo) do
    try_again_cache[unit] = true
  end
  local can_undo = true
  local i = 1
  --instead of literally undoing everything, use BACK code to create new undo events. That way 1) TRY AGAIN can be undone. 2) Units don't forget their previous history each TRY AGAIN, should they be NO UNDO now but not in the future.
  while (can_undo) do
    can_undo = doBack(nil, i, ignore_no_undo)
    i = i + 1
  end
  parseRules(true)
  reset_count = reset_count + 1
  in_try_again = false
  try_again_cache = nil
  consolidateUndo(1)
end

function isNoUndo(unit)
  if in_try_again then
    return try_again_cache[unit] == true
  else
    return hasProperty(unit, "no undo")
  end
end

function createUndoBasedOnUnitsChanges(old_units, old_units_by_id, new_units, new_units_by_id)
  --[[
1) For every unit in old units, if it exists in new units (same id and fullname) and x/y/dir differ, add an update event.
2) Else, add a create event with its old state.
3) For every unit in new units, if it doesn't exist in old units (same id and fullname), add a destroy event.
  TODO: Handle mous, timefuck stuff (timeless, UNDO), no1?
]]
  
  for _,unit in ipairs(old_units) do
    if new_units_by_id[unit.id] ~= nil and new_units_by_id[unit.id].fullname == unit.fullname then
      local new_unit = new_units_by_id[unit.id];
      if (new_unit.x ~= unit.x) or (new_unit.y ~= unit.y) or (new_unit.dir ~= unit.dir) then
        addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
      end
      if (new_unit.color ~= unit.color) then
        for _,colour in ipairs(color_names) do
          if new_unit[colour] ~= unit[colour] then
            addUndo({"colour_change", unit.id, colour, unit[colour]})
          end
        end
      end
    else
      addUndo({"remove", unit.tile, unit.x, unit.y, unit.dir, convert or false, unit.id, unit.special})
    end
  end
  for _,unit in ipairs(new_units) do
    if old_units_by_id[unit.id] ~= nil and old_units_by_id[unit.id].fullname == unit.fullname then
      --already handled 'exists in both' case
    else
      addUndo({"create", unit.id, true, nil})
    end
  end
  if (level_destroyed) then
    addUndo({"destroy_level"})
  end
end