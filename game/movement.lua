--format: {unit = unit, type = "movement", payload = {x = x, y = y, dir = dir}} 
update_queue = {}

function doUpdate()
  for _,update in ipairs(update_queue) do
    if update.reason == "movement" then
      local unit = update.unit
      local x = update.payload.x
      local y = update.payload.y
      local dir = update.payload.dir
      unit.dir = dir
      moveUnit(unit, x, y)
      unit.already_moving = false
      update_undo = true
    end
  end
  update_queue = {}
end

function doMovement(movex, movey)
  local played_sound = {}
  local moving_units = {}
  local moving_units_next = {}
  local slippers = {}
  local flippers = {}

  print("[---- begin turn ----]")
  print("move: " .. movex .. ", " .. movey)

  local move_stage = -1
  while move_stage < 3 do
    local already_added = {}
    local kikers = {} --so two sidekikers don't trigger each other indefinitely
    for _,unit in ipairs(units) do
      unit.already_moving = false
      if move_stage == -1 then
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
    
    --TODO: Patashu: We probably want to invert this so it goes for each unit that is moving -> move it once, to help prevent some units moving far ahead of others.
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
            while data.times > 0 do
              local success,movers,specials = canMove(unit, dx, dy, true)

              for _,special in ipairs(specials) do
                doAction(special)
              end
              if success then
                unit.already_moving = true
                something_moved = true
                for _,mover in ipairs(movers) do
                  moveIt(mover, dx, dy, data, false, already_added, moving_units, kikers, slippers)
                end
                --Patashu: only the mover itself pulls, otherwise it's a mess. stuff like STICKY/STUCK will require ruggedizing this logic.
                doPull(unit, dx, dy, data, already_added, moving_units, kikers, slippers)
              else
                --the first time a walker fails to walk per turn, flip it. (TODO: Patashu: We need to not flip early if the only reason we can't walk is because something in front of us hasn't moved yet (like a walk/stop or a walk/pull. Re-investigate after simultaneous movement)
                if data.reason == "walk" and flippers[unit.id] ~= true then
                  dir = rotate8(dir); unit.dir = dir; data.dir = dir;
                  dpos = dirs8[dir]
                  dx,dy = dpos[1],dpos[2]
                  flippers[unit.id] = true
                  data.times = data.times + 1
                else
                  break --if we failed to move, then stop moving (table.remove below will be hit)
                end
              end
              --otherwise just count down once
              data.times = data.times - 1
            end
          end
          table.remove(unit.moves, 1)
        end
      end
      doUpdate()
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
  update_undo = true
end

function moveIt(mover, dx, dy, data, pulling, already_added, moving_units, kikers, slippers)
  if not mover.removed then
    if not ((data.reason == "icy" or data.reason == "sidekik") and slippers[mover.id] == true) then
      update_undo = true
      addUndo({"update", mover.id, mover.x, mover.y, mover.dir})
      mover.dir = data.dir --print("moving:"..mover.name..","..tostring(mover.x)..","..tostring(mover.y)..","..tostring(dx)..","..tostring(dy))
      table.insert(update_queue, {unit = mover, reason = "movement", payload = {x = mover.x + dx, y = mover.y + dy, dir = mover.dir}})
      --moveUnit(mover, mover.x + dx, mover.y + dy)
      --finishing a slip locks you out of U/WALK for the rest of the turn
      --TODO: Patashu: Possibly simultaneous movement will prevent the specific 'pull/sidekik' exception from being needed...?
      if (data.reason == "icy" and data.times == 1) then
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
  dx = sign(dx);
  dy = sign(dy);
  local dir = dirs8_by_offset[dx][dy];
  local dirleft = (dir + 2 - 1) % 8 + 1;
  local dirright = (dir + 6 - 1) % 8 + 1;
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

function doPull(unit,dx,dy,data, already_added, moving_units, kikers, slippers)
  local x = unit.x;
  local y = unit.y;
  local something_moved = true
  while (something_moved) do
    something_moved = false
    x = x - dx;
    y = y - dy;
    for _,v in ipairs(getUnitsOnTile(x, y)) do
      if hasProperty(v, "come pls") then
        local success,movers,specials = canMove(v, dx, dy, true)
        for _,special in ipairs(specials) do
          doAction(special)
        end
        if (success) then
          unit.already_moving = true
          something_moved = true
          for _,mover in ipairs(movers) do
            moveIt(mover, dx, dy, data, true, already_added, moving_units, kikers, slippers)
          end
        end
      end
    end
  end
end

function canMove(unit,dx,dy,pushing_,pulling_)
  local pushing = false
  if (pushing_ ~= nil) then
		pushing = pushing_
	end
  --TODO: Patashu: this isn't used now but might be in the future??
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
    --Patashu: treat moving things as intangible in general
    if (not v.already_moving) then
      local stopped = false
      if (fordor and hasProperty(v, "ned kee")) or (nedkee and hasProperty(v, "for dor")) then
        table.insert(specials, {"open", {unit, v}})
      end
      if hasProperty(v, "go away") then
        if pushing then
          local success,new_movers,new_specials = canMove(v, dx, dy, pushing, pulling)
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
        else
          stopped = true
        end
      end
      if hasProperty(v, "no go") then
        stopped = true
      end
      if hasProperty(v, "sidekik") then
        stopped = true
      end
      if hasProperty(v, "come pls") and not hasProperty(v, "go away") and not pulling then
        stopped = true
      end
      --if thing is ouch, it will not stop things. probably recreates the normal baba behaviour pretty well
      if hasProperty(v, "ouch") then
      stopped = false
      end
      if stopped then
        return false,movers,specials
      end
    end
  end

  return true,movers,specials
end