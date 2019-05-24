function doMovement(movex, movey)
  local played_sound = {}
  local already_added = {}
  local moving_units = {}
  --TODO: Patashu: slippers as a construct is probably unnecessary after we have simultaneous doupdate movement, since they won't get a chance to 'double move' until after all slipping has been computed. (Also, simultaneous doupdate movement will remove the 'u & push separates' behaviour.)
  local slippers = {}
  local flippers = {}
  local kikers = {}

  print("[---- begin turn ----]")
  print("move: " .. movex .. ", " .. movey)

  local move_stage = -1
  while move_stage < 3 do
    kikers = {}
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
              local yeeter = hasRule(other, "yeet", unit)
              if (yeeter) then
                table.insert(unit.moves, {reason = "yeet", dir = other.dir, times = 99})
              end
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
    
    local something_moved = true
    local infinite_loop_protection = 0
    while (something_moved and infinite_loop_protection < 99) do
      something_moved = false
      infinite_loop_protection = infinite_loop_protection + 1
      for _,unit in ipairs(moving_units) do
        while #unit.moves > 0 do
          local data = unit.moves[1]
          if not unit.removed then
            local dir = data.dir

            local dpos = dirs8[dir]
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
                      something_moved = true
                      if (data.reason == "icy" and i == data.times) then
                        slippers[mover.id] = true
                      end
                      --add SIDEKIKERs to move in the next iteration
                      for __,sidekiker in ipairs(findSidekikers(mover, dx, dy)) do
                        if (kikers[sidekiker.id] ~= true) then
                          kikers[sidekiker.id] = true
                          table.insert(sidekiker.moves, {reason = "sidekik", dir = mover.dir, times = 1})
                          if not already_added[sidekiker] then
                            table.insert(moving_units, sidekiker)
                            already_added[sidekiker] = true
                          end
                        end
                      end
                    end
                  end
                end
                --Patashu: only the mover itself pulls, otherwise it's a mess. stuff like STICKY/STUCK will require ruggedizing this logic.
                doPull(unit, dx, dy, already_added, moving_units, kikers)
              else
                if data.reason == "walk" and i == 1 and flippers[unit.id] ~= true then
                  unit.dir = rotate8(unit.dir)
          flippers[unit.id] = true
                  table.insert(unit.moves, {reason = "walk", dir = unit.dir, times = data.times})
                end
                break
              end
            end
          end
          table.remove(unit.moves, 1)
        end
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

function sign(x)
  if (x > 0) then
    return 1
  elseif (x < 0) then
    return -1
  end
  return 0
end

function findSidekikers(unit,dx,dy)
  local result = {}
  local x = unit.x;
  local y = unit.y;
  --TODO: Patashu: since movement is instant right now, we have to do it from the old location
  x = x - dx;
  y = y - dy;
  dx = sign(dx);
  dy = sign(dy);
  local dir = dirs8_by_offset[dx][dy];
  local dirleft = (dir + 2) % 8;
  local dirright = (dir + 6) % 8;
  local x_left = x+dirs8[dirleft][1];
  local y_left = y+dirs8[dirleft][2];
  local x_right = x+dirs8[dirright][1];
  local y_right = y+dirs8[dirright][2];
  
  for _,v in ipairs(getUnitsOnTile(x_left, y_left)) do
    if hasProperty(v, "sidekik") then
      table.insert(result, v);
    end
  end
  for _,v in ipairs(getUnitsOnTile(x_right, y_right)) do
    if hasProperty(v, "sidekik") then
      table.insert(result, v);
    end
  end
  return result;
end

function doPull(unit,dx,dy, already_added, moving_units, kikers)
  local x = unit.x;
  local y = unit.y;
  --TODO: Patashu: since movement is instant right now, we have to do it from the old location
  x = x - dx;
  y = y - dy;
  local failure = false;
  while (not failure) do
    local successes = 0;
    x = x - dx;
    y = y - dy;
    for _,v in ipairs(getUnitsOnTile(x, y)) do
      if hasProperty(v, "come pls") then
        local success,movers,specials = canMove(v, dx, dy)
        for _,special in ipairs(specials) do
          doAction(special)
        end
        if (success) then
          successes = successes + 1
          unit.already_moving = true
          for _,mover in ipairs(movers) do
            if not mover.removed then
              mover.dir = unit.dir
              addUndo({"update", mover.id, mover.x, mover.y, mover.dir})
              moveUnit(mover, mover.x + dx, mover.y + dy)
              --add SIDEKIKERs to move in the next iteration
              --TODO: Patashu: Cleanup would be nice here. It's annoying that we have to
              --1) duplicate the logic to move a unit in two different places
              --2) pass around a bunch of state to do it
              for __,sidekiker in ipairs(findSidekikers(mover, dx, dy)) do
                if (kikers[sidekiker.id] ~= true) then
                  kikers[sidekiker.id] = true
                  table.insert(sidekiker.moves, {reason = "sidekik", dir = mover.dir, times = 1})
                  if not already_added[sidekiker] then
                    table.insert(moving_units, sidekiker)
                    already_added[sidekiker] = true
                  end
                end
              end
            end
          end
        end
      end
    end
    failure = successes == 0;
  end
end

function canMove(unit,dx,dy,pulling_)
  local pulling = false
	if (pulling_ ~= nil) then
		pulling = pulling_
	end
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
    if hasProperty(v, "sidekik") then
      stopped = true
    end
    if hasProperty(v, "come pls") and not pulling then
      stopped = true
    end
    if stopped then
      return false,movers,specials
    end
  end

  return true,movers,specials
end