function newUndo()
  table.insert(undo_buffer, 1, {})
end

function addUndo(data)
  if #undo_buffer > 0 then 
    table.insert(undo_buffer[1], 1, data)
  end
end

function undo()
  if undo_buffer[1] ~= nil then
    local update_rules = false

    for _,v in ipairs(undo_buffer[1]) do
      local action = v[1]

      if action == "update" then
        local unit = units_by_id[v[2]]

        if unit ~= nil then
          moveUnit(unit,v[3],v[4])
          updateDir(unit, v[5])

          if unit.type == "text" then
            update_rules = true
          end
        end
      elseif action == "create" then
        local unit = units_by_id[v[2]]

        if unit ~= nil then
          deleteUnit(unit, v[3])
        end
      elseif action == "remove" then
        createUnit(v[2], v[3], v[4], v[5], v[6], v[7])
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
     print("undo failed")
  end
end