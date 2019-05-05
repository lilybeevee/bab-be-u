function doMovement(key)
  local played_sound = {}
  local moving_units = {}

  for _,unit in ipairs(units) do
    if hasProperty(unit, "u") then
      table.insert(moving_units, {unit = unit, dir = dirs_by_name[key]})
    end
  end
  
  for _,v in ipairs(moving_units) do
    if not v.removed then
      local unit = v.unit
      local dir = v.dir

      local dpos = dirs[dir]
      local dx,dy = dpos[1],dpos[2]

      local success,movers,specials = canMove(unit, dx, dy)

      for _,special in ipairs(specials) do
        doAction(special)
      end
      if success then
        for _,mover in ipairs(movers) do
          if not mover.removed then
            addUndo({"update", mover.id, mover.x, mover.y})
            moveUnit(mover, mover.x + dx, mover.y + dy)
          end
        end
      end
    end
  end

  updateUnits()
  parseRules()
  updateUnits()
end

function doAction(action)
  local action_name = action[1]
  if action_name == "open" then
    playSound("break", 0.5)
    local opened = action[2]
    for _,unit in ipairs(opened) do
      unit.removed = true
      unit.destroyed = true
    end
  end
end

function canMove(unit,dx,dy)
  local movers = {}
  local specials = {}
  table.insert(movers,unit)

  local x = unit.x + dx
  local y = unit.y + dy

  if not inBounds(x,y) then
    return false,{},{}
  end

  local nedkee = hasProperty(unit, "ned kee")
  local fordor = hasProperty(unit, "for dor")

  local tileid = x + y * mapwidth
  for _,v in ipairs(units_by_tile[tileid]) do
    local stopped = false
    if (fordor and hasProperty(v, "ned kee")) or (nedkee and hasProperty(v, "for dor")) then
      table.insert(specials, {"open", {unit, v}})
    end
    if hasProperty(v, "go away") then
      local success,new_movers,new_specials = canMove(v, dx, dy)
      for _,special in ipairs(new_specials) do
        table.insert(specials, special)
      end
      if success then
        for _,mover in ipairs(new_movers) do
          table.insert(movers, mover)
        end
      else
        stopped = true
      end
    end
    if hasProperty(v, "no go") then
      stopped = true
    end
    if stopped then
      return false,movers,specials
    end
  end

  return true,movers,specials
end