function doMovement(movex, movey)
  local played_sound = {}
  local already_added = {}
  local moving_units = {}
  local slippers = {}

  first_turn = false

  print("[---- begin turn ----]")
  print("move: " .. movex .. ", " .. movey)

  local move_stage = -1
  while move_stage < 3 do
    for _,unit in ipairs(units) do
      if move_stage == -1 then
        unit.already_moving = false
        unit.moves = {}
      end
        if move_stage == -1 then
          for __,other in ipairs(getUnitsOnTile(unit.x, unit.y)) do
            if other.id ~= unit.id then
              local icyness = countProperty(other, "icy");
              if icyness > 0 then
                table.insert(unit.moves, {reason = "icy", dir = unit.dir, times = icyness})
              end
            end
          end
        elseif move_stage == 0 and slippers[unit.id] == nil and not hasProperty(unit, "slep") then
          if (movex ~= 0 or movey ~= 0) and hasProperty(unit, "u") then
            table.insert(unit.moves, {reason = "u", dir = dirs8_by_offset[movex][movey], times = 1})
            unit.olddir = unit.dir
          end
        elseif move_stage == 1 and slippers[unit.id] == nil and not hasProperty(unit, "slep") then
          local moveness = countProperty(unit, "walk")
          if moveness > 0 then
            table.insert(unit.moves, {reason = "walk", dir = unit.dir, times = moveness})
          end
        elseif move_stage == 2 then
          for __,other in ipairs(getUnitsOnTile(unit.x, unit.y)) do
            if other.id ~= unit.id then
              local goness = countProperty(other, "go");
              if goness > 0 then
                table.insert(unit.moves, {reason = "go", dir = other.dir, times = goness})
              end
            end
          end
        end
      if #unit.moves > 0 and not already_added[unit] then
        table.insert(moving_units, unit)
        already_added[unit] = true
      end
    end
    
    for _,unit in ipairs(moving_units) do
      while #unit.moves > 0 do
        local data = unit.moves[1]
        if not unit.removed then
          local dir = data.dir

          local dpos = dirs8[dir]
          print(tostring(dpos)..","..tostring(dir))
          local dx,dy = dpos[1],dpos[2]
          for i=1,data.times do
            local success,movers,specials = canMove(unit, dx, dy)

            for _,special in ipairs(specials) do
              doAction(special)
            end
            if success then
              unit.already_moving = true
              for _,mover in ipairs(movers) do
                if not mover.removed then
                  if not (data.reason == "icy" and slippers[mover.id] == true) then
                    mover.dir = dir
                    addUndo({"update", mover.id, mover.x, mover.y, mover.dir})
                    moveUnit(mover, mover.x + dx, mover.y + dy)
                    if (data.reason == "icy" and i == data.times) then
                      slippers[mover.id] = true
                    end
                  end
                end
              end
            else
              if data.reason == "walk" and i == 1 then
                unit.dir = rotate8(unit.dir)
                print(tostring(unit.dir))
                table.insert(unit.moves, {reason = "walk", dir = unit.dir, times = data.times})
              end
              break
            end
          end
        end
        table.remove(unit.moves, 1)
      end
    end
    move_stage = move_stage + 1
  end
  updateUnits()
  parseRules()
  convertUnits()
  updateUnits()
  parseRules()
end

function doAction(action)
  local action_name = action[1]
  if action_name == "open" then
    playSound("break", 0.5)
    playSound("unlock", 0.6)
    local opened = action[2]
    for _,unit in ipairs(opened) do
      addParticles("destroy", unit.x, unit.y, {237,226,133})
      unit.removed = true
      unit.destroyed = true
    end
  end
end

function canMove(unit,dx,dy)
  local movers = {}
  local specials = {}
  table.insert(movers, unit)

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
      if not v.already_moving then
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