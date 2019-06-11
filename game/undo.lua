function newUndo()
  table.insert(undo_buffer, 1, {})
  undo_buffer[1].last_move = last_move
end

function addUndo(data)
  if #undo_buffer > 0 then 
    table.insert(undo_buffer[1], 1, data)
  end
end

function undoOneAction(v, ignore_no_undo)
  local update_rules = false
  local action = v[1]

  if action == "update" then
    local unit = units_by_id[v[2]]

    if unit ~= nil and (ignore_no_undo or not hasProperty(unit, "no undo")) then
      moveUnit(unit,v[3],v[4])
      updateDir(unit, v[5])

      if unit.type == "text" then
        update_rules = true
      end
    end
  elseif action == "create" then
  local convert = v[3];
    local unit = units_by_id[v[2]]

    if unit.type == "text" then
      update_rules = true
    end

    if unit ~= nil and (ignore_no_undo or not hasProperty(unit, "no undo")) then
      deleteUnit(unit, convert, true)
    end
  elseif action == "remove" then
    local convert = v[6];
    local unit = createUnit(v[2], v[3], v[4], v[5], convert, v[7])
    --If the unit was actually a destroyed 'no undo', oops. Don't actually bring it back. It's dead, Jim.
    if (unit ~= nil and not convert and (not ignore_no_undo and hasProperty(unit, "no undo"))) then
      deleteUnit(unit, convert, true)
    end

    if unit ~= nil and unit.type == "text" then
      update_rules = true
    end
    --TODO: If roc be no undo and we form water be roc then undo, should the water come back? If it shouldn't, then the 'remove, convert' event needs to 'know' what it came from so that if it came from a 'no undo' object then we can delete it in that circumstance too.
    --TODO: We also want a similar mechanic for undo, now. If we form grass be roc then later form roc be undo, when the roc un-converts into gras, we want gras to come back.
    --TODO: test mous vs no undo interactions
  elseif action == "create_cursor" then
    --love.mouse.setPosition(v[2], v[3])
    deleteMouse(v[2]) --id
  elseif action == "remove_cursor" then
    --love.mouse.setPosition(v[2], v[3])
    createMouse_direct(v[2], v[3], v[4]) --x, y, id
  elseif action == "backer_turn" then
    local unit = units_by_id[v[2]]
    
    if (unit ~= nil and (ignore_no_undo or not hasProperty(unit, "no undo"))) then
      backers_cache[unit] = v[3];
      unit.backer_turn = v[3];
    end
  end
  return update_rules;
end

function doBack(unit, turn)
  --UNDO being able to supercede NO UNDO sounds more interesting than if it's a non-interaction imo, means you could make a puzzle where you have to rewind something that was otherwise impossible to rewind
  local ignore_do_undo = true;
  if (turn <= 1) then
    return
  end
  if undo_buffer[turn] ~= nil then
    --add a dummy action so that undoing happens
    if (#undo_buffer[1] == 0) then
      addUndo({"dummy"});
    end
    for _,v in ipairs(undo_buffer[turn]) do 
      local action = v[1]
      if units_by_id[v[2]] == unit then
        if (action == "update") then
          addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
          undoOneAction(v, respect_do_undo);
        elseif (action == "create") then
          local convert = v[6];
          addUndo({"remove", unit.tile, unit.x, unit.y, unit.dir, convert or false, unit.id})
          undoOneAction(v, respect_do_undo);
        elseif (action == "create_cursor") then
          addUndo({"remove_cursor", unit.screenx, unit.screeny, unit.id})
          undoOneAction(v, respect_do_undo);
        end
      end
    end
  end
end

function undo()
  if undo_buffer[1] ~= nil then
    local update_rules = false
    
    last_move = undo_buffer[1].last_move or {0, 0}

    for _,v in ipairs(undo_buffer[1]) do
      update_rules = undoOneAction(v, false);
    end

    updateUnits(true)
    if update_rules then
      parseRules(true)
      parseRules(true)
    end
    updateUnits(true)

    table.remove(undo_buffer, 1)
  else
      return false
  end
  return true
end
