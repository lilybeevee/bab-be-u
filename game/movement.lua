--format: {unit = unit, type = "update", payload = {x = x, y = y, dir = dir}} 
update_queue = {}

function doUpdate()
  for _,update in ipairs(update_queue) do
    if update.reason == "update" then
      local unit = update.unit
      local x = update.payload.x
      local y = update.payload.y
      local dir = update.payload.dir
      unit.dir = dir
      moveUnit(unit, x, y)
      unit.already_moving = false
    end
  end
  update_queue = {}
end

function doMovement(movex, movey)
  local played_sound = {}
  local slippers = {}
  local flippers = {}

  print("[---- begin turn ----]")
  print("move: " .. movex .. ", " .. movey)

  local move_stage = -1
  while move_stage < 3 do
    local moving_units = {}
    local moving_units_next = {}
    local already_added = {}
    for _,unit in ipairs(units) do
      unit.already_moving = false
      unit.moves = {}
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
    
    --[[
Simultaneous movement algorithm, basically a simple version of Baba's:
1) Make a list of all things that are moving this take, moving_units
2a) Try to move each of them once. For each success, move it to moving_units_next and set it already_moving with one less move point and an update queued. If there was at least one success, repeat 2 until there are no successes. (During this process, things that are currently moving are considered intangible in canMove.)
2b) But wait, we're still not done! Flip all walkers that failed to flip, then continue until we once again have no successes. (Flipping still only happens once per turn.)
2c) Finally, if we had at least one success, everything left is moved to moving_units_next with one less move point and we repeat from 2a). If we had no successes, the take is totally resolved. doupdate() and unset all current_moving.
3) when SLIDE/LAUNCH/BOUNCE exists, we'll need to figure out where to insert it... but if it's like baba, it goes after the move succeeds but before do_update(), and it adds either another update or another movement as appropriate.

ALTERNATE MOVEMENT ALGORITHM that would preserve properties like 'x is move and stop pulls apart' and is mostly move order independent:
1) Do it as before, except instead of moving a unit when you discover it can be moved, mark it and wait until the inner loop is over.
2) After the inner loop is over, move all the things that you marked.

But if we want to go a step further and e.g. make it so X IS YOU AND PUSH lets you catapult one of yourselves two tiles, we have to go a step further and stack up all of the movement that would occur instead of making it simultaneous and override itself.

But if we do THIS, then we can now attempt to move to different destination tiles than we tried the first time around. So we have to re-evaluate the outcome of that by calling canMove again. And if that new movement can also cause push/pull/sidekik/slide/launch, then we have to recursively check everything again, and it's unclear what order things should evaluate in, and etc.

It is probably possible to do, but lily has decided that it's not important enough if it's difficult, so we shall stay with simultanous movement for now.
]]
    --loopa and loopb are just infinite loop protection.
    local loopa = 0
    local successes = 1
    --Outer loop continues until nothing moves in the inner loop, and does a doUpdate after each inner loop, to allow for multimoves to exist.
    while (#moving_units > 0 and successes > 0 and loopa < 99) do 
      successes = 0
      local loopb = 0
      loopa = loopa + 1
      local something_moved = true
      --Inner loop tries to move everything at least once, and gives up if after an iteration, nothing can move. (It also tries to do flips to see if that helps.)
      while (something_moved and loopb < 99) do
        local remove_from_moving_units = {}
        local has_flipped = false
        local kikers = {} --so two sidekikers don't trigger each other indefinitely
        something_moved = false
        loopb = loopb + 1
        for _,unit in ipairs(moving_units) do
          while #unit.moves > 0 and unit.moves[1].times <= 0 do
            table.remove(unit.moves, 1)
          end
          if #unit.moves > 0 and not unit.removed then
            local data = unit.moves[1]
            local dir = data.dir
            local dpos = dirs8[dir]
            local dx,dy = dpos[1],dpos[2]
            local success,movers,specials = canMove(unit, dx, dy, true)

            for _,special in ipairs(specials) do
              doAction(special)
            end
            if success then
              something_moved = true
              successes = successes + 1
              remove_from_moving_units[unit] = true;
              table.insert(moving_units_next, unit);
              
              for k = #movers, 1, -1 do
                moveIt(movers[k], dx, dy, data, false, already_added, moving_units, kikers, slippers)
              end
              --Patashu: only the mover itself pulls, otherwise it's a mess. stuff like STICKY/STUCK will require ruggedizing this logic.
              --Patashu: TODO: Doing the pull right away means that in a situation like this: https://cdn.discordapp.com/attachments/579519329515732993/582179745006092318/unknown.png the pull could happen before the bounce depending on move order. To fix this... I'm not sure how Baba does this? But it's somewhere in that mess of code.
              doPull(unit, dx, dy, data, already_added, moving_units, kikers, slippers)
              data.times = data.times - 1;
            end
          else
            remove_from_moving_units[unit] = true;
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
              if data.reason == "walk" and flippers[unit.id] ~= true then
                dir = rotate8(data.dir); data.dir = dir;
                addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
                table.insert(update_queue, {unit = unit, reason = "update", payload = {x = unit.x, y = unit.y, dir = data.dir}})
                flippers[unit.id] = true
                something_moved = true
                successes = successes + 1
                remove_from_moving_units[unit] = true;
                table.insert(moving_units_next, unit);
              end
            end
          end
          has_flipped = true;
        end
        for i=#moving_units,1,-1 do
          local unit = moving_units[i];
          if (remove_from_moving_units[unit]) then
            table.remove(moving_units, i);
          end
        end
      end
      for _,unit in ipairs(moving_units_next) do
        table.insert(moving_units, unit);
      end
      moving_units_next = {}
      doUpdate()
    end
    move_stage = move_stage + 1
  end
  parseRules()
  updateUnits(false, true)
  parseRules()
  convertUnits()
  updateUnits(false, false)
  parseRules()
end

function doAction(action)
  local action_name = action[1]
  if action_name == "open" then
    playSound("break", 0.5)
    playSound("unlock", 0.6)
    local victims = action[2]
    for _,unit in ipairs(victims) do
      addParticles("destroy", unit.x, unit.y, {237,226,133})
      if not hasProperty("protecc") then
        unit.removed = true
        unit.destroyed = true
      end
    end
  elseif action_name == "weak" then
    playSound("break", 0.5)
    local victims = action[2]
    for _,unit in ipairs(victims) do
      print("instant weak")
      addParticles("destroy", unit.x, unit.y, unit.color)
      if not hasProperty("protecc") then
        unit.removed = true
        unit.destroyed = true
      end
    end
  end
end

function moveIt(mover, dx, dy, data, pulling, already_added, moving_units, kikers, slippers)
  if not mover.removed then
    queueMove(mover, dx, dy, data.dir, false);
    applySlide(mover, dx, dy, already_added, moving_units);
    applySwap(mover, dx, dy);
    --finishing a slip locks you out of U/WALK for the rest of the turn
    if (data.reason == "icy") then
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

function queueMove(mover, dx, dy, dir, priority)
  addUndo({"update", mover.id, mover.x, mover.y, mover.dir})
  mover.olddir = mover.dir
  mover.dir = dir
  print("moving:"..mover.name..","..tostring(mover.id)..","..tostring(mover.x)..","..tostring(mover.y)..","..tostring(dx)..","..tostring(dy))
  mover.already_moving = true;
  table.insert(update_queue, (priority and 1 or (#update_queue + 1)), {unit = mover, reason = "update", payload = {x = mover.x + dx, y = mover.y + dy, dir = mover.dir}})
end

function applySlide(mover, dx, dy, already_added, moving_units)
  --Before we add a new LAUNCH/SLIDE move, deleting all existing LAUNCH/SLIDE moves, so that if we 'move twice in the same tick' (such as because we're being pushed or pulled while also sliding) it doesn't stack. (this also means e.g. SLIDE & SLIDE gives you one extra move at the end, rather than multiplying your movement.)
  local did_clear_existing = false
  --LAUNCH will take precedence over SLIDE, so that puzzles where you move around launchers on an ice rink will behave intuitively.
  local did_launch = false
   --we haven't actually moved yet, so check the tile we will be on
  for _,v in ipairs(getUnitsOnTile(mover.x+dx, mover.y+dy)) do
    if (not v.already_moving) then
      local launchness = countProperty(v, "goooo");
      if (launchness > 0) then
        if (not did_clear_existing) then
          for i = #mover.moves,1,-1 do
            if mover.moves[i].reason == "goooo" or mover.moves[i].reason == "icyyyy" then
              table.remove(mover.moves, i)
            end
          end
          did_clear_existing = true
        end
        --the new moves will be at the start of the unit's moves data, so that it takes precedence over what it would have done next otherwise
        --TODO: CLEANUP: Figure out a nice way to not have to pass this around/do this in a million places.
        table.insert(mover.moves, 1, {reason = "goooo", dir = v.dir, times = launchness})
        if not already_added[mover] then
          table.insert(moving_units, mover)
          already_added[mover] = true
        end
        did_launch = true
      end
    end
  end
  if (did_launch) then
    return
  end
  for _,v in ipairs(getUnitsOnTile(mover.x+dx, mover.y+dy)) do
    if (not v.already_moving) then
      local slideness = countProperty(v, "icyyyy");
      if (slideness > 0) then
        if (not did_clear_existing) then
          for i = #mover.moves,1,-1 do
            if mover.moves[i].reason == "goooo" or mover.moves[i].reason == "icyyyy" then
              table.remove(mover.moves, i)
            end
          end
          did_clear_existing = true
        end
        table.insert(mover.moves, 1, {reason = "icyyyy", dir = mover.dir, times = slideness})
        if not already_added[mover] then
          table.insert(moving_units, mover)
          already_added[mover] = true
        end
      end
    end
  end
end

function applySwap(mover, dx, dy)
  --we haven't actually moved yet, same as applySlide
  --two priority related things:
  --1) don't swap with things that are already moving, to prevent move order related behaviour
  --2) swaps should occur before any other kind of movement, so that the swap gets 'overriden' by later, more intentional movement e.g. in a group of swap and you moving things, or a swapper pulling boxen behind it
  if hasProperty(mover, "edgy") then
    for _,v in ipairs(getUnitsOnTile(mover.x+dx, mover.y+dy)) do
      if not v.already_moved then
        queueMove(v, -dx, -dy, v.dir, true);
      end
    end
  else
    for _,v in ipairs(getUnitsOnTile(mover.x+dx, mover.y+dy)) do
      if not v.already_moved and hasProperty(v, "edgy") then
        queueMove(v, -dx, -dy, v.dir, true);
      end
    end
  end
end

function findSidekikers(unit,dx,dy)
  local result = {}
  local x = unit.x;
  local y = unit.y;
  dx = sign(dx);
  dy = sign(dy);
  local dir = dirs8_by_offset[dx][dy];
  
  local dir90 = (dir + 2 - 1) % 8 + 1;
  for i = 1,2 do
    local curdir = (dir90 + 4*i - 1) % 8 + 1;
    local curx = x+dirs8[curdir][1];
    local cury = y+dirs8[curdir][2];
    for _,v in ipairs(getUnitsOnTile(curx, cury)) do
      if hasProperty(v, "sidekik") then
        table.insert(result, v);
      end
    end
  end
  
  --Testing a new feature: sidekik & come pls objects follow you even on diagonals, to make them very hard to get away from in bab 8 way geometry, while just sidekik objects behave as they are right now so they're appropriate for 4 way geometry or being easy to walk away from
  local dir45 = (dir + 1 - 1) % 8 + 1;
  for i = 1,4 do
    local curdir = (dir45 + 2*i - 1) % 8 + 1;
    local curx = x+dirs8[curdir][1];
    local cury = y+dirs8[curdir][2];
    for _,v in ipairs(getUnitsOnTile(curx, cury)) do
      if hasProperty(v, "sidekik") and hasProperty(v, "come pls") then
        table.insert(result, v);
      end
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
          --unit.already_moving = true
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
  
  local x = unit.x + dx
  local y = unit.y + dy
  
  local movers = {}
  local specials = {}
  table.insert(movers, unit)
  
  if not inBounds(x,y) then
    if hasProperty(unit, "ouch") then
      table.insert(specials, {"weak", {unit}})
      return true,movers,specials
    end
    return false,{},{}
  end

  if hasProperty(unit, "diagnal") and (dx == 0 or dy == 0) then
    return false,movers,specials
  end
  if hasProperty(unit, "orthongl") and (dx ~= 0 and dy ~= 0) then
    return false,movers,specials
  end

  local nedkee = hasProperty(unit, "ned kee")
  local fordor = hasProperty(unit, "for dor")

  local tileid = x + y * mapwidth
  for _,v in ipairs(units_by_tile[tileid]) do
    --Patashu: treat moving things as intangible in general
    if (not v.already_moving) then
      local stopped = false
      local would_swap_with = hasProperty(v, "edgy") and pushing
      --pushing a key into a door automatically works
      if (fordor and hasProperty(v, "ned kee")) or (nedkee and hasProperty(v, "for dor")) then
        table.insert(specials, {"open", {unit, v}})
        return true,movers,specials
      end
      if hasProperty(v, "go away") and not would_swap_with then
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
      if hasProperty(v, "no go") then --Things that are STOP stop being PUSH or PULL, unlike in Baba. This is currently intended.
        stopped = true
      end
      if hasProperty(v, "sidekik") and not hasProperty(v, "go away") and not would_swap_with then
        stopped = true
      end
      if hasProperty(v, "come pls") and not hasProperty(v, "go away") and not would_swap_with and not pulling then
        stopped = true
      end
      if hasProperty(v, "go my wey") and ((v.dir == 1 and dx == -1) or (v.dir == 2 and (dx == -1 or dy == -1) and (dx ~= 1 and dy ~= 1)) or (v.dir == 3 and dy == -1) or (v.dir == 4 and (dx == 1 or dy == -1) and (dx ~= -1 and dy ~= 1)) or (v.dir == 5 and dx == 1) or (v.dir == 6 and (dx == 1 or dy == 1) and (dx ~= -1 and dy ~= -1)) or (v.dir == 7 and dy == 1)) or (v.dir == 8 and (dx == -1 or dy == 1) and (dx ~= 1 and dy ~= -1)) then
        --TODO: I think this is just 'direction is 2 or less away'? and we can turn dx/dy into dir by looking at dirs8_by_offset, similar to findSidekikers.
        stopped = true
      end
      --if thing is ouch, it will not stop things. probably recreates the normal baba behaviour pretty well (TODO: test that items dropped by GOT are dropped in the expected tiles for all ouch combinations)
      if hasProperty(v, "ouch") then
      stopped = false
      end
      --if a weak thing tries to move and fails, destroy it
      if stopped and hasProperty(unit, "ouch") then
        table.insert(specials, {"weak", {unit}})
        return true,movers,specials
      end
      if stopped then
        return false,movers,specials
      end
    end
  end

  return true,movers,specials
end