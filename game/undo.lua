function newUndo()
  table.insert(undo_buffer, 1, {})
  undo_buffer[1].last_move = last_move
end

function addUndo(data)
  if #undo_buffer > 0 then 
    table.insert(undo_buffer[1], 1, data)
  end
end

function undo()
  if undo_buffer[1] ~= nil then
    local update_rules = false
    
    last_move = undo_buffer[1].last_move or {0, 0}

    for _,v in ipairs(undo_buffer[1]) do
      local action = v[1]

      if action == "update" then
        local unit = units_by_id[v[2]]

        if unit ~= nil and not hasProperty(unit, "no undo") then
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

        if unit ~= nil and not hasProperty(unit, "no undo") then
          deleteUnit(unit, convert, true)
        end
      elseif action == "remove" then
        local convert = v[6];
        local unit = createUnit(v[2], v[3], v[4], v[5], convert, v[7])
        --If the unit was actually a destroyed 'no undo', oops. Don't actually bring it back. It's dead, Jim.
        if (unit ~= nil and not convert and hasProperty(unit, "no undo")) then
          deleteUnit(unit, convert, true)
        end

        if unit ~= nil and unit.type == "text" then
          update_rules = true
        end
        --TODO: If roc be no undo and we form water be roc then undo, should the water come back? If it shouldn't, then the 'remove, convert' event needs to 'know' what it came from so that if it came from a 'no undo' object then we can delete it in that circumstance too.
      elseif action == "create_cursor" then
        --love.mouse.setPosition(v[2], v[3])
        deleteMouse(v[2]) --id
      elseif action == "remove_cursor" then
        --love.mouse.setPosition(v[2], v[3])
        createMouse_direct(v[2], v[3], v[4]) --x, y, id
      end
    end

    updateUnits(true)
    if update_rules then
      parseRules(true)
    end
    updateUnits(true)

    table.remove(undo_buffer, 1)
  else
      return false
  end
  return true
end
