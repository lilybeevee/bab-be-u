function newUndo()
  table.insert(undo_buffer, 1, {})
end

function addUndo(data)
  table.insert(undo_buffer[1], 1, data)
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
        createUnit(v[2], v[3], v[4], v[5], v[6])
      end
    end

    updateUnits(true)
    if update_rules then
      parseRules()
    end
    updateUnits(true)

    table.remove(undo_buffer, 1)
  end
end