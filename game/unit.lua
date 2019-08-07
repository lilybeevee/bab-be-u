function moveBlock()
  --baba order: FOLLOW, BACK, TELE, SHIFT
  --bab order: zip, look at, undo, visit fren, go, goooo, shy, spin, folo wal, turn cornr

  local iszip = getUnitsWithEffect("zip");
  for _,unit in ipairs(iszip) do
    doZip(unit)
  end
  
  local isstalk = matchesRule("?", "look at", "?");
  for _,ruleparent in ipairs(isstalk) do
    local stalkers = findUnitsByName(ruleparent[1][1])
    local stalkees = copyTable(findUnitsByName(ruleparent[1][3]))
    local stalker_conds = ruleparent[1][4][1]
    local stalkee_conds = ruleparent[1][4][2]
    for _,stalker in ipairs(stalkers) do
      table.sort(stalkees, function(a, b) return euclideanDistance(a, stalker) < euclideanDistance(b, stalker) end )
      for _,stalkee in ipairs(stalkees) do
        if testConds(stalker, stalker_conds) and testConds(stalkee, stalkee_conds) then
          local dist = euclideanDistance(stalker, stalkee)
          local stalk_dir = dist > 0 and dirs8_by_offset[sign(stalkee.x - stalker.x)][sign(stalkee.y - stalker.y)] or stalkee.dir
          if dist > 0 and hasProperty(stalker, "ortho") then
            local use_hori = math.abs(stalkee.x - stalker.x) > math.abs(stalkee.y - stalker.y)
            stalk_dir = dirs8_by_offset[use_hori and sign(stalkee.x - stalker.x) or 0][not use_hori and sign(stalkee.y - stalker.y) or 0]
          end
          addUndo({"update", stalker.id, stalker.x, stalker.y, stalker.dir})
          stalker.olddir = stalker.dir
          updateDir(stalker, stalk_dir)
          break
        end
      end
    end
  end
  
  local to_destroy = {}
  local time_destroy = {}
  
  --UNDO logic:
  --the first time something becomes UNDO, we track what turn it became UNDO on.
  --then every turn thereafter until it stops being UNDO, we undo the update (move backwards) and create (destroy units) events of a turn 2 turns further back (+1 so we keep undoing into the past, +1 because the undo_buffer gained a real turn as well!)
  --We have to keep track of the turn we started backing on in the undo buffer, so that if we undo to a past where a unit was UNDO, then we know what turn to pick back up from. We also have to save/restore backer_turn on destroy, so if we undo the unit's destruction it comes back with the right backer_turn.
  --(The cache is not necessary for the logic, it just removes our need to check ALL units to see if they need to be cleaned up.)
  
  local backed_this_turn = {};
  local not_backed_this_turn = {};
  
  local isback = getUnitsWithEffectAndCount("undo");
  for unit,amt in pairs(isback) do
    backed_this_turn[unit] = true;
    if (unit.backer_turn == nil) then
      addUndo({"backer_turn", unit.id, nil})
      unit.backer_turn = #undo_buffer+(0.5*(amt-1));
      backers_cache[unit] = unit.backer_turn;
    end
    doBack(unit, 2*(#undo_buffer-unit.backer_turn));
    for i = 2,amt do
      addUndo({"backer_turn", unit.id, unit.backer_turn})
      unit.backer_turn = unit.backer_turn - 0.5;
      doBack(unit, 2*(#undo_buffer-unit.backer_turn));
    end
  end
  
  for unit,turn in pairs(backers_cache) do
    if turn ~= nil and not backed_this_turn[unit] then
      not_backed_this_turn[unit] = true;
    end
  end
  
  for unit,_ in pairs(not_backed_this_turn) do
    addUndo({"backer_turn", unit.id, unit.backer_turn})
    unit.backer_turn = nil;
    backers_cache[unit] = nil;
  end
  
  to_destroy = handleDels(to_destroy);
  
  --Currently using deterministic tele version. Number of teles a teleporter has influences whether it goes forwards or backwards and by how many steps.
  local istele = getUnitsWithEffectAndCount("visit fren");
  teles_by_name = {};
  teles_by_name_index = {};
  tele_targets = {};
  --form lists, by tele name, of what all the tele units are
  for unit,amt in pairs(istele) do
    if teles_by_name[unit.fullname] == nil then
      teles_by_name[unit.fullname] = {}
    end
    table.insert(teles_by_name[unit.fullname], unit);
  end
  --then sort those lists in reading order (tiebreaker is id).
  --skip this step if doing random version, the sorting won't matter then!
  for name,tbl in pairs(teles_by_name) do
    table.sort(tbl, readingOrderSort)
  end
  --form a lookup index for each of those lists
  for name,tbl in pairs(teles_by_name) do
    teles_by_name_index[name] = {}
    for k,v in ipairs(tbl) do
      teles_by_name_index[name][v] = k
    end
  end
  --now do the actual teleports. we can use the index to know our own place in the list so we can skip ourselves
  for unit,amt in pairs(istele) do
    local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
    for _,on in ipairs(stuff) do
      --we're going to deliberately let two same name teles tele if they're on each other, since with the deterministic behaviour it's predictable and interesting
      if unit ~= on and sameFloat(unit, on) and timecheck(unit,"be","visitfren") --[[and unit.fullname ~= on.fullname]] then
        local destinations = teles_by_name[unit.fullname]
        local source_index = teles_by_name_index[unit.fullname][unit]
        
        --RANDOM VERSION: just pick any tele that isn't us
        --[[local dest = math.floor(math.random()*(#destinations-1))+1 --even distribution of each integer. +1 because lua is 1 indexed, -1 because we want one less than the number of teleporters (since we're going to ignore our own)
        if (dest >= source_index) then
          dest = dest + 1
        end]]
        
        --DETERMINISTIC VERSION: 1/-1/2/-2/3/-3... based on amount of TELE, in reading order.
        local dest = source_index + (math.floor(amt/2+0.5) * (amt % 2 == 1 and 1 or -1))
        --have to subtract 1/add 1 because arrays are 1 indexed but modulo arithmetic is 0 indexed.
        dest = ((dest-1) % (#destinations))+1
        if dest == source_index then
          dest = dest + 1
        end
        dest = ((dest-1) % (#destinations))+1
        tele_targets[on] = destinations[dest]
      end
    end
  end
  for a,b in pairs(tele_targets) do
    addUndo({"update", a.id, a.x, a.y, a.dir})
    moveUnit(a, b.x, b.y)
  end
  
  local ishere = getUnitsWithEffect("her")
  local hashered = {}
  for _,unit in ipairs(ishere) do
    --checks to see if the unit has already been moved by "her"
    local already = false
    for _,moved in ipairs(hashered) do
      if unit == moved then
        already = true
      end
    end
    
    --if it has, then don't run code this iteration
    if not already then
      local getheres = matchesRule(unit,"be","her")
      local heres = {}
      local found = false
      
      --gets each destination the unit needs to go to
      for _,ruleparent in ipairs(getheres) do
        local fullrule = ruleparent[2]
        for i,hererule in ipairs(fullrule) do
          if hererule.fullname == "text_her" then
            table.insert(heres,hererule)
            break
          end
        end
      end
      --sorts it like "visitfren"
      for name,tbl in pairs(heres) do
        table.sort(tbl, readingOrderSort)
      end
      
      --actual teleport
      for i,here in ipairs(heres) do
        local dx = dirs8[here.dir][1]
        local dy = dirs8[here.dir][2]
        
        --if this is true, it means that on the last iteration it found a unit at a destination, so on this iteration it teleports it to the following one
        if found then
          addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
          moveUnit(unit,here.x+dx,here.y+dy)
          table.insert(hashered,unit)
          break
        end
        
        --if i == #heres, that means it's at the last one in line, meaning we can just use the system that sends it to the first word
        --otherwise, if it finds unit at one of the places, that means that it should send it to the next one on the next turn
        if (unit.x == here.x+dx) and (unit.y == here.y+dy) and (i ~= #heres) then
          found = true
        end
      end
      
      --sends it to the first "here" if it isn't at any existing destination or if it's at the last
      if not found then
        local firsthere = heres[1]
        local dx = dirs8[firsthere.dir][1]
        local dy = dirs8[firsthere.dir][2]
        
        addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
        moveUnit(unit,firsthere.x+dx,firsthere.y+dy)
        table.insert(hashered,unit)
      end
    end
  end
  
  local isthere = getUnitsWithEffect("thr")
  local hasthered = {}
  for _,unit in ipairs(isthere) do
    --the early stuff is the same as "her"; finds "thr"s and sort them
    local already = false
    for _,moved in ipairs(hasthered) do
      if unit == moved then
        already = true
      end
    end
    
    if not already then
      local gettheres = matchesRule(unit,"be","thr")
      local theres = {}
      local found = false
      
      for i,ruleparent in ipairs(gettheres) do
        local fullrule = ruleparent[2]
        for i,thererule in ipairs(fullrule) do
          if thererule.fullname == "text_thr" then
            table.insert(theres,thererule)
            break
          end
        end
      end
      for name,tbl in pairs(theres) do
        table.sort(tbl, readingOrderSort)
      end
      
      --starts differing from "her"
      local ftx,fty = 0,0
      for i,there in ipairs(theres) do
        local dx = dirs8[there.dir][1]
        local dy = dirs8[there.dir][2]
        local dir = there.dir
        
        --get first position of there destination, which is the tile in front of the text, since that interpretation makes the most sense to me
        local tx = there.x+dx
        local ty = there.y+dy
        
        --while it hasn't found a wall, check the next tile until is finds one, updating tx and ty each time
        local stopped = false
        while not stopped do
          if canMove(unit,dx,dy,dir,false,false,nil,nil,nil,tx,ty) then
            dx,dy,dir,tx,ty = getNextTile(there, dx, dy, dir, nil, tx, ty)
          else
            stopped = true
          end
        end
        
        --stores the first destination for use later so we don't have to run the while loop twice
        if i == 1 then
          ftx,fty = tx,ty
        end
        
        if found then
          addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
          moveUnit(unit,tx,ty)
          table.insert(hasthered,unit)
        end
        
        if (unit.x == tx) and (unit.y == ty) and (i ~= #theres) then
          found = true
        end
      end
      
      if not found then
        addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
        moveUnit(unit,ftx,fty)
        table.insert(hasthered,unit)
      end
    end
  end
  
  local isrighthere = getUnitsWithEffect("rithere")
  local hasrighthered = {}
  for _,unit in ipairs(isrighthere) do
    local already = false
    for _,moved in ipairs(hasrighthered) do
      if unit == moved then
        already = true
      end
    end
    
    if not already then
      local getrightheres = matchesRule(unit,"be","rithere")
      local rightheres = {}
      local found = false
      
      for _,ruleparent in ipairs(getrightheres) do
        local fullrule = ruleparent[2]
        for i,righthererule in ipairs(fullrule) do
          if righthererule.fullname == "text_rithere" then
            table.insert(rightheres,righthererule)
            break
          end
        end
      end
      
      for name,tbl in pairs(rightheres) do
        table.sort(tbl, readingOrderSort)
      end
      
      for i,righthere in ipairs(rightheres) do
        if found then
          addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
          moveUnit(unit,righthere.x,righthere.y)
          table.insert(hasrighthered,unit)
          break
        end
        if (unit.x == righthere.x) and (unit.y == righthere.y) and (i ~= #rightheres) then
          found = true
        end
      end
      
      if not found then
        local firstrighthere = rightheres[1]
        addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
        moveUnit(unit,firstrighthere.x,firstrighthere.y)
        table.insert(hasrighthered,unit)
      end
    end
  end
  
  local isshift = getUnitsWithEffect("go");
  for _,unit in ipairs(isshift) do
    local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
    for _,on in ipairs(stuff) do
      if unit ~= on and sameFloat(unit, on) and timecheck(unit,"be","go") then
        addUndo({"update", on.id, on.x, on.y, on.dir})
        on.olddir = on.dir
        updateDir(on, unit.dir)
      end
    end
  end
  
  local isshift = getUnitsWithEffect("goooo");
  for _,unit in ipairs(isshift) do
    local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
    for _,on in ipairs(stuff) do
      if unit ~= on and sameFloat(unit, on) and timecheck(unit,"be","goooo") then
        addUndo({"update", on.id, on.x, on.y, on.dir})
        on.olddir = on.dir
        updateDir(on, unit.dir)
      end
    end
  end
  
  local isshy = getUnitsWithEffect("shy");
  for _,unit in ipairs(isshy) do
    if not hasProperty("folo wal") and not hasProperty("turn cornr") then
      local dpos = dirs8[unit.dir];
      local dx, dy = dpos[1], dpos[2];
      local stuff = getUnitsOnTile(unit.x+dx, unit.y+dy, nil, true)
      local stuff2 = getUnitsOnTile(unit.x-dx, unit.y-dy, nil, true)
      local pushfront = false
      local pushbehin = false
      for _,on in ipairs(stuff) do
        if hasProperty(on, "go away pls") then
          pushfront = true
          break
        end
      end
      if pushfront then
        for _,on in ipairs(stuff2) do
          if hasProperty(on, "go away pls") then
            pushbehin = true
            break
          end
        end
      end
      if pushfront and not pushbehin then
        addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
        updateDir(unit, rotate8(unit.dir))
      end
    end
  end
  
  --technically spin_8 does nothing, so skip it
  for i=1,7 do
    local isspin = getUnitsWithEffectAndCount("spin_" .. tostring(i));
    for unit,amt in pairs(isspin) do
      addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
      unit.olddir = unit.dir
      --if we aren't allowed to rotate to the indicated direction, skip it
      for j=1,8 do
        local result = updateDir(unit, dirAdd(unit.dir, amt*i));
        if not result then
          amt = amt + 1
        else
          break
        end
      end
    end
  end
  
  local folo_wall = getUnitsWithEffectAndCount("folo wal")
  for unit,amt in pairs(folo_wall) do
    local fwd = unit.dir;
    local right = (((unit.dir + 2)-1)%8)+1;
    local bwd = (((unit.dir + 4)-1)%8)+1;
    local left = (((unit.dir + 6)-1)%8)+1;
    local result = changeDirIfFree(unit, right) or changeDirIfFree(unit, fwd) or changeDirIfFree(unit, left) or changeDirIfFree(unit, bwd);
  end
  
  local turn_cornr = getUnitsWithEffectAndCount("turn cornr")
  for unit,amt in pairs(turn_cornr) do
    local fwd = unit.dir;
    local right = (((unit.dir + 2)-1)%8)+1;
    local bwd = (((unit.dir + 4)-1)%8)+1;
    local left = (((unit.dir + 6)-1)%8)+1;
    local result = changeDirIfFree(unit, fwd) or changeDirIfFree(unit, right) or changeDirIfFree(unit, left) or changeDirIfFree(unit, bwd);
  end
end

function updateUnits(undoing, big_update)
  max_layer = 1
  units_by_layer = {}
  local del_units = {}
  local will_undo = false

  for i,v in pairs(units_by_tile) do
    units_by_tile[i] = {}
  end

  for _,unit in ipairs(units) do
    --delete units that were deleted during movement (like from walking oob while ouch)
    if (unit.removed) then
      table.insert(del_units, on)
    --keep empty out of units_by_tile - it will be returned in getUnitsOnTile
    elseif unit.fullname ~= "no1" and unit.type ~= "outerlvl" then
      local tileid = unit.x + unit.y * mapwidth
      table.insert(units_by_tile[tileid], unit)
    end
  end
  
  deleteUnits(del_units,false)
  
  --handle non-monotonic (creative, destructive) effects one at a time, so that we can process them in a set order instead of unit order
  --BABA order is as follows: DONE, BLUE, RED, MORE, SINK, WEAK, MELT, DEFEAT, SHUT, EAT, BONUS, END, WIN, MAKE, HIDE
  --(FOLLOW, BACK, TELE, SHIFT are handled in moveblock. FALL is handled in fallblock.)

  if (big_update and not undoing) then
    if not hasProperty(nil,"za warudo") then
      timeless = false
    end
    
    if not timeless then
      time_destroy = handleTimeDels(time_destroy)
    end
    
    --MOAR is 4-way growth, MOARx2 is 8-way growth, MOARx3 is 2x 4-way growth, MOARx4 is 2x 8-way growth, MOARx5 is 3x 4-way growth, etc.
    --TODO: If you write txt be moar, it's ambiguous which of a stacked text pair will be the one to grow into an adjacent tile first. But if you make it simultaneous, then you get double growth into corners which turns into exponential growth, which is even worse. It might need to be special cased in a clever way.
    local give_me_moar = true;
    local moar_repeats = 0;
    while (give_me_moar) do
      give_me_moar = false;
      local ismoar = getUnitsWithEffectAndCount("moar");
      for unit,amt in pairs(ismoar) do
        if unit.name ~= "lie/8" and timecheck(unit,"be","moar") then
          amt = amt - 2*moar_repeats;
          if amt > 0 then
            if (amt % 2) == 1 then
              for i=1,4 do
                local ndir = dirs[i];
                local dx = ndir[1];
                local dy = ndir[2];
                if canMove(unit, dx, dy, i*2-1, false, false, unit.name) then
                  if unit.class == "unit" then
                    local new_unit = createUnit(tiles_by_name[unit.fullname], unit.x, unit.y, unit.dir)
                    addUndo({"create", new_unit.id, false})
                    _, __, ___, x, y = getNextTile(unit, dx, dy, i*2-1, false);
                    moveUnit(new_unit,x,y)
                    addUndo({"update", new_unit.id, unit.x, unit.y, unit.dir})
                  elseif unit.class == "cursor" then
                    local others = getCursorsOnTile(unit.x + dx, unit.y + dy)
                    if #others == 0 then
                      local new_mouse = createMouse(unit.x + dx, unit.y + dy)
                      addUndo({"create_cursor", new_mouse.id})
                    end
                  end
                  give_me_moar = give_me_moar or amt >= 3;
                end
              end
            else
              for i=1,8 do
                local ndir = dirs8[i];
                local dx = ndir[1];
                local dy = ndir[2];
                if canMove(unit, dx, dy, i, false, false, unit.name) then
                  if unit.class == "unit" then
                    local new_unit = createUnit(tiles_by_name[unit.fullname], unit.x, unit.y, unit.dir)
                    addUndo({"create", new_unit.id, false})
                    _, __, ___, x, y = getNextTile(unit, dx, dy, i, false);
                    moveUnit(new_unit,x,y);
                    addUndo({"update", new_unit.id, unit.x, unit.y, unit.dir})
                  elseif unit.class == "cursor" then
                    local others = getCursorsOnTile(unit.x + dx, unit.y + dy)
                    if #others == 0 then
                      local new_mouse = createMouse(unit.x + dx, unit.y + dy)
                      addUndo({"create_cursor", new_mouse.id})
                    end
                  end
                  give_me_moar = give_me_moar or amt >= 3;
                end
              end
            end
          end
        end
      end
      moar_repeats = moar_repeats + 1
    end
    
    local to_destroy = {}
    if time_destroy == nil then
      time_destroy = {}
    end
    
    local split = getUnitsWithEffect("split");
    for _,unit in ipairs(split) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if unit ~= on and sameFloat(unit, on) then
          if timecheck(unit,"be","split") and timecheck(on) then
            local dir1 = dirAdd(unit.dir,0)
            local dx1 = dirs8[dir1][1]
            local dy1 = dirs8[dir1][2]
            local dir2 = dirAdd(unit.dir,4)
            local dx2 = dirs8[dir2][1]
            local dy2 = dirs8[dir2][2]
            if canMove(on, dx1, dy1, dir1, false, false, on.name) then
              if on.class == "unit" then
                local new_unit = createUnit(tiles_by_name[on.fullname], on.x, on.y, dir1)
                addUndo({"create", new_unit.id, false})
                _, __, ___, x, y = getNextTile(on, dx1, dy1, dir1, false);
                moveUnit(new_unit,x,y)
                addUndo({"update", new_unit.id, on.x, on.y, dir1})
              elseif unit.class == "cursor" then
                local others = getCursorsOnTile(on.x + dx1, on.y + dy1)
                if #others == 0 then
                  local new_mouse = createMouse(on.x + dx1, on.y + dy1)
                  addUndo({"create_cursor", new_mouse.id})
                end
              end
            end
            if canMove(on, dx2, dy2, dir2, false, false, on.name) then
              if on.class == "unit" then
                local new_unit = createUnit(tiles_by_name[on.fullname], on.x, on.y, dir2)
                addUndo({"create", new_unit.id, false})
                _, __, ___, x, y = getNextTile(on, dx2, dy2, dir2, false);
                moveUnit(new_unit,x,y)
                addUndo({"update", new_unit.id, on.x, on.y, dir2})
              elseif unit.class == "cursor" then
                local others = getCursorsOnTile(on.x + dx2, on.y + dy2)
                if #others == 0 then
                  local new_mouse = createMouse(on.x + dx2, on.y + dy2)
                  addUndo({"create_cursor", new_mouse.id})
                end
              end
            end
            table.insert(to_destroy, on)
          else
            addUndo({"timeless_splitter_add", unit.id});
            table.insert(timeless_splitter,unit.id)
            addUndo({"timeless_splittee_add", on.id});
            table.insert(timeless_splittee,on.id)
          end
        end
      end
    end
    
    if not timeless then
      for _,unit in ipairs(timeless_splitter) do
        addUndo({"timeless_splitter_remove", unit});
        unit = units_by_id[unit];
        for _,on in ipairs(timeless_splittee) do
          on = units_by_id[on];
          if (unit ~= nil and on ~= nil) then
            table.insert(to_destroy, on)
            local dir1 = dirAdd(unit.dir,0)
            local dx1 = dirs8[dir1][1]
            local dy1 = dirs8[dir1][2]
            local dir2 = dirAdd(unit.dir,4)
            local dx2 = dirs8[dir2][1]
            local dy2 = dirs8[dir2][2]
            if canMove(on, dx1, dy1, dir1, false, false, on.name) then
              if on.class == "unit" then
                local new_unit = createUnit(tiles_by_name[on.fullname], on.x, on.y, dir1)
                addUndo({"create", new_unit.id, false})
                _, __, ___, x, y = getNextTile(on, dx1, dy1, dir1, false);
                moveUnit(new_unit,x,y)
                addUndo({"update", new_unit.id, on.x, on.y, dir1})
              elseif unit.class == "cursor" then
                local others = getCursorsOnTile(on.x + dx1, on.y + dy1)
                if #others == 0 then
                  local new_mouse = createMouse(on.x + dx1, on.y + dy1)
                  addUndo({"create_cursor", new_mouse.id})
                end
              end
            end
            if canMove(on, dx2, dy2, dir2, false, false, on.name) then
              if on.class == "unit" then
                local new_unit = createUnit(tiles_by_name[on.fullname], on.x, on.y, dir2)
                addUndo({"create", new_unit.id, false})
                _, __, ___, x, y = getNextTile(on, dx2, dy2, dir2, false);
                moveUnit(new_unit,x,y)
                addUndo({"update", new_unit.id, on.x, on.y, dir2})
              elseif unit.class == "cursor" then
                local others = getCursorsOnTile(on.x + dx2, on.y + dy2)
                if #others == 0 then
                  local new_mouse = createMouse(on.x + dx2, on.y + dy2)
                  addUndo({"create_cursor", new_mouse.id})
                end
              end
            end
          end
        end
      end
      for _,on in ipairs(timeless_splittee) do
        addUndo({"timeless_splittee_remove", on});
      end
      timeless_splitter = {}
      timeless_splittee = {}
    end
    
    to_destroy = handleDels(to_destroy);
    
    local isvs = matchesRule(nil,"vs","?")
    for _,ruleparent in ipairs(isvs) do
      local unit = ruleparent[2]
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, true)
      for _,on in ipairs(stuff) do
        if unit ~= on and hasRule(unit, "vs", on) and sameFloat(unit, on) then
          local unitmoved = false
          local onmoved = false
          for _,undo in ipairs(undo_buffer[2]) do
            if undo[1] == "update" and undo[2] == unit.id and ((undo[3] ~= unit.x) or (undo[4] ~= unit.y)) then
              unitmoved = true
            end
            if undo[1] == "update" and undo[2] == on.id and ((undo[3] ~= on.x) or (undo[4] ~= on.y)) then
              onmoved = true
            end
          end
          if unitmoved then
            if timecheck(on,"vs",unit) then
              table.insert(to_destroy,on)
              playSound("break")
              addParticles("destroy", on.x, on.y, on.color)
            else
              table.insert(time_destroy,on.id)
              addUndo({"time_destroy",on.id})
            end
          end
          if onmoved then
            if timecheck(unit,"vs",on) then
              table.insert(to_destroy,unit)
              playSound("break")
              addParticles("destroy", unit.x, unit.y, unit.color)
            else
              table.insert(time_destroy,unit.id)
              addUndo({"time_destroy",unit.id})
            end
          end
        end
      end
    end
    
    to_destroy = handleDels(to_destroy)
    
    local issink = getUnitsWithEffect("no swim");
    for _,unit in ipairs(issink) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if unit ~= on and sameFloat(unit, on) then
          if timecheck(unit,"be","no swim") and timecheck(on) then
            table.insert(to_destroy, unit)
            table.insert(to_destroy, on)
            playSound("sink")
            addParticles("destroy", unit.x, unit.y, on.color)
            shakeScreen(0.3, 0.1)
          else
            table.insert(time_destroy,unit.id)
            table.insert(time_destroy,on.id)
						addUndo({"time_destroy",unit.id});
						addUndo({"time_destroy",on.id});
            table.insert(time_sfx,"sink")
          end
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local isweak = getUnitsWithEffect("ouch");
    for _,unit in ipairs(isweak) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if unit ~= on and sameFloat(unit, on) then
          if timecheck(unit,"be","ouch") and timecheck(on) then
            table.insert(to_destroy, unit)
            playSound("break")
            addParticles("destroy", unit.x, unit.y, unit.color)
            shakeScreen(0.3, 0.1)
          else
            table.insert(time_destroy,unit.id)
						addUndo({"time_destroy",unit.id});
            table.insert(time_sfx,"break")
          end
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local ishot = getUnitsWithEffect("hotte");
    for _,unit in ipairs(ishot) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if hasProperty(on, "fridgd") and sameFloat(unit, on) then
          if timecheck(unit,"be","hotte") and timecheck(on) then
            table.insert(to_destroy, on)
            playSound("hotte")
            addParticles("destroy", unit.x, unit.y, unit.color)
            shakeScreen(0.3, 0.1)
          else
            table.insert(time_destroy,on.id)
						addUndo({"time_destroy",on.id});
            table.insert(time_sfx,"hotte")
          end
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local isdefeat = getUnitsWithEffect(":(");
    for _,unit in ipairs(isdefeat) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        is_u = hasProperty(on, "u") or hasProperty(on, "u too") or hasProperty(on, "u tres")
        if is_u and sameFloat(unit, on) then
          if timecheck(unit,"be",":(") and timecheck(on) then
            table.insert(to_destroy, on)
            playSound("break")
            addParticles("destroy", unit.x, unit.y, unit.color)
            shakeScreen(0.3, 0.2)
          else
            table.insert(time_destroy,on.id)
						addUndo({"time_destroy",on.id});
            table.insert(time_sfx,"break")
          end
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local isshut = getUnitsWithEffect("ned kee");
    for _,unit in ipairs(isshut) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if hasProperty(on, "for dor") and sameFloat(unit, on) then
          if timecheck(unit,"be","ned kee") and timecheck(on) then
            table.insert(to_destroy, unit)
            table.insert(to_destroy, on)
            playSound("break")
            playSound("unlock")
            addParticles("destroy", unit.x, unit.y, unit.color)
            addParticles("destroy", on.x, on.y, on.color)
            shakeScreen(0.3, 0.1)
          else
            table.insert(time_destroy,unit.id)
            table.insert(time_destroy,on.id)
            table.insert(time_sfx,"break")
            table.insert(time_sfx,"unlock")
          end
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local issnacc = matchesRule(nil, "snacc", "?");
    for _,ruleparent in ipairs(issnacc) do
      local unit = ruleparent[2]
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, true)
      for _,on in ipairs(stuff) do
        if unit ~= on and hasRule(unit, "snacc", on) and sameFloat(unit, on) then
          if timecheck(unit,"snacc",on) and timecheck(on) then
            table.insert(to_destroy, on)
            playSound("snacc")
            addParticles("destroy", unit.x, unit.y, unit.color)
            shakeScreen(0.3, 0.15)
          else
            table.insert(time_destroy,on.id)
						addUndo({"time_destroy",on.id});
            table.insert(time_sfx,"snacc")
          end
        end
      end
    end
    
    local isreset = getUnitsWithEffect("try again");
    for _,unit in ipairs(isreset) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        is_u = hasProperty(on, "u") or hasProperty(on, "u too") or hasProperty(on, "u tres")
        if is_u and sameFloat(unit, on) then
          if timecheck(unit,"be","try again") and timecheck(on) then
            will_undo = true
            break
          else
          addUndo({"timeless_reset_add"});
            timeless_reset = true
          end
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local iscrash = getUnitsWithEffect("xwx");
    for _,unit in ipairs(iscrash) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        is_u = hasProperty(on, "u") or hasProperty(on, "u too") or hasProperty(on, "u tres")
        if is_u and sameFloat(unit, on) then
          if timecheck(unit,"be","xwx") and timecheck(on) then
            love = {}
          else
            addUndo({"timeless_crash_add"});
            timeless_crash = true
          end
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local isbonus = getUnitsWithEffect(":o");
    for _,unit in ipairs(isbonus) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        is_u = hasProperty(on, "u") or hasProperty(on, "u too") or hasProperty(on, "u tres")
        if is_u and sameFloat(unit, on) then
          if timecheck(unit,"be",":o") and timecheck(on) then
            table.insert(to_destroy, unit)
            playSound("bonus")
            addParticles("bonus", unit.x, unit.y, unit.color)
          else
            table.insert(time_destroy,unit.id)
						addUndo({"time_destroy",unit.id});
            table.insert(time_sfx,"bonus")
          end
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local iswin = getUnitsWithEffect(":)");
    for _,unit in ipairs(iswin) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        is_u = hasProperty(on, "u") or hasProperty(on, "u too") or hasProperty(on, "u tres")
        if is_u and sameFloat(unit, on) then
          if timecheck(unit,"be",":)") and timecheck(on) then
            doWin()
          else
            addUndo({"timeless_win_add", on.id});
            table.insert(timeless_win,on.id)
          end
        end
      end
    end

    local creators = matchesRule(nil, "creat", "?")
    for _,match in ipairs(creators) do
      local creator = match[2]
      local createe = match[1][1][3]

      local tile = tiles_by_name[createe]
      if timecheck(creator,"creat",createe) then
        if tile ~= nil then
          local others = getUnitsOnTile(creator.x, creator.y, createe, true, creator)
          if #others == 0 then
            local new_unit = createUnit(tile, creator.x, creator.y, creator.dir)
            addUndo({"create", new_unit.id, false})
          end
        elseif createe == "mous" then
          local new_mouse = createMouse(creator.x, creator.y)
          addUndo({"create_cursor", new_mouse.id})
        end
      end
    end
    
    if (#timeless_win > 0) and not timeless then
      doWin()
    end
    
    doDirRules();
  end
  
  DoDiscordRichPresence();
  
  for i,unit in ipairs(units) do
    local deleted = false
    for _,del in ipairs(del_units) do
      if del == unit then
        deleted = true
      end
    end
    
    if not deleted and not unit.removed_final then
      if unit.removed then
        table.insert(del_units, unit)
      end
    end
  end

  deleteUnits(del_units,false)
  
  --Fix the 'txt be undo' bug by checking an additional time if we need to unset backer_turn for a unit.
  
  local backed_this_turn = {};
  local not_backed_this_turn = {};
  
  local isback = getUnitsWithEffectAndCount("undo");
  for unit,amt in pairs(isback) do
    backed_this_turn[unit] = true;
  end
  
  for unit,turn in pairs(backers_cache) do
    if turn ~= nil and not backed_this_turn[unit] then
      not_backed_this_turn[unit] = true;
    end
  end
  
  for unit,_ in pairs(not_backed_this_turn) do
    addUndo({"backer_turn", unit.id, unit.backer_turn})
    unit.backer_turn = nil;
    backers_cache[unit] = nil;
  end
  
  if (will_undo) or (timeless_reset and not timeless) then
    addUndo({"timeless_reset_remove"});
    timeless_reset = false
    local can_undo = true;
    while (can_undo) do
      can_undo = undo(true)
    end
    parseRules(true)
    reset_count = reset_count + 1
  end
  
  if timeless_crash and not timeless then
    addUndo({"timeless_crash_remove"});
    love = {}
  end
end

function miscUpdates()
  updateGraphicalPropertyCache();

  if units_by_name["os"] then
    for i,unit in ipairs(units_by_name["os"]) do
      local os = love.system.getOS()
      if os == "Windows" then
        unit.sprite = "os_windous"
      elseif os == "OS X" or os == "iOS" then
        unit.sprite = "os_mak"
      elseif os == "Linux" then
        unit.sprite = "os_linx"
      elseif os == "Android" then
        unit.sprite = "os_androd"
      else
        unit.sprite = "wat"
      end
      if unit.sprite ~= "wat" and graphical_property_cache["slep"][unit] ~= nil then
        unit.sprite = unit.sprite .. "_slep"
      end
    end
  end
  
  for i,unit in ipairs(units) do
    if not deleted and not unit.removed_final then
      local tile = tiles_list[unit.tile]
      unit.layer = tile.layer + (20 * (graphical_property_cache["flye"][unit] or 0))

      if unit.fullname ~= "os" then
        if tiles_list[unit.tile].sleepsprite and graphical_property_cache["slep"][unit] ~= nil then
          unit.sprite = tiles_list[unit.tile].sleepsprite
        else
          unit.sprite = tiles_list[unit.tile].sprite
        end
      end

      unit.overlay = {}
      if (graphical_property_cache["tranz"][unit] ~= nil) then
        table.insert(unit.overlay, "trans")
      end
      if (graphical_property_cache["gay"][unit] ~= nil) then
        table.insert(unit.overlay, "gay")
      end
      
      -- for optimisation in drawing
      local objects_to_check = {
      "stelth", "colrful", "xwx", "rave",
      }
      for i = 1, #objects_to_check do
        local prop = objects_to_check[i]
        unit[prop] = graphical_property_cache[prop][unit] ~= nil
      end

      if not units_by_layer[unit.layer] then
        units_by_layer[unit.layer] = {}
      end
      table.insert(units_by_layer[unit.layer], unit)
      max_layer = math.max(max_layer, unit.layer)
    end
  end

  for _,unit in ipairs(still_converting) do
    if not units_by_layer[unit.layer] then
      units_by_layer[unit.layer] = {}
    end
    if not table.has_value(units_by_layer[unit.layer], unit) then
      table.insert(units_by_layer[unit.layer], unit)
    end
    max_layer = math.max(max_layer, unit.layer)
  end
end

function updateGraphicalPropertyCache()
  for prop,tbl in pairs(graphical_property_cache) do
    --only flye has a stacking graphical effect and we want to ignore selector, the rest are boolean
    local count = prop == "flye";
    new_tbl = {};
    if (count) then
      local isprop = getUnitsWithEffectAndCount(prop);
      for unit,amt in pairs(isprop) do
        new_tbl[unit] = unit.fullname ~= "selctr" and amt or nil;
      end
    else
      local isprop = getUnitsWithEffect(prop);
      for _,unit in pairs(isprop) do
        new_tbl[unit] = true;
      end
    end
    graphical_property_cache[prop] = new_tbl;
  end
  
  updateUnitColours()
end

--Colour logic:
--If a unit be colour, it becomes that colour until it ben't that colour or it be a different colour. It persists even after breaking the rule.
function updateUnitColours()
  to_update = {}
  
  for colour,palette in pairs(main_palette_for_colour) do
    local decolour = matchesRule(nil,"ben't",colour)
    for _,match in ipairs(decolour) do
      local unit = match[2]
      if (unit[colour] == true) then
        addUndo({"colour_change", unit.id, colour, true});
        unit[colour] = false
        to_update[unit] = {}
      end
      --If a unit ben't its native colour, make it blacc.
      if palette[1] == tiles_list[unit.tile].color[1] and palette[2] == tiles_list[unit.tile].color[2]  and unitNotRecoloured(unit) then
        addUndo({"colour_change", unit.id, "blacc", false});
        unit["blacc"] = true
        to_update[unit] = {}
      end
    end
    
    local newcolour = matchesRule(nil,"be",colour)
    for _,match in ipairs(newcolour) do
      local unit = match[2]
      if (unit[colour] ~= true) then
        if to_update[unit] == nil then
          to_update[unit] = {}
        end
        table.insert(to_update[unit], colour)
      end
    end
  end
  
  local painting = matchesRule(nil, "paint", "?")
  for _,ruleparent in ipairs(painting) do
    local unit = ruleparent[2]
    local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, true)
    for _,on in ipairs(stuff) do
      if unit ~= on and hasRule(unit, "paint", on) and sameFloat(unit, on) then
        if timecheck(unit,"paint",on) and timecheck(on) then
          local colour = colour_for_palette[unit.color[1]][unit.color[2]];
          if (colour ~= nil and on[colour] ~= true) then
            if to_update[on] == nil then
              to_update[on] = {}
            end
            table.insert(to_update[on], colour)
          end
        end
      end
    end
  end
  
  --BEN'T PAINT removes and prevents all other colour shenanigans.
  local depaint = matchesRule(nil,"ben't","paint")
  for _,match in ipairs(depaint) do
    local unit = match[2]
    unitUnsetColours(unit);
    to_update[unit] = {}
  end
  
  for unit,colours in pairs(to_update) do
    unitUnsetColours(unit)
    for _,colour in ipairs(colours) do
      if (unit[colour] ~= true) then
        addUndo({"colour_change", unit.id, colour, false});
        unit[colour] = true
      end
    end
    updateUnitColourOverride(unit)
  end
end

function unitUnsetColours(unit)
  for colour,palette in pairs(main_palette_for_colour) do
    if unit[colour] == true then
      addUndo({"colour_change", unit.id, colour, true});
      unit[colour] = false
    end
  end
end

function unitNotRecoloured(unit)
  for colour,palette in pairs(main_palette_for_colour) do
    if unit[colour] == true then
      return false
    end
  end
  return true
end

function updateUnitColourOverride(unit)
  unit.color_override = nil
  --[[if unit.whit and unit.reed then
	unit.color_override = {4, 2}
  if unit.whit and unit.grun then
    unit.color_override = {5, 3} ]]
  if unit.whit or (unit.reed and unit.grun and unit.bleu) or (unit.reed and unit.cyeann) or (unit.bleu and unit.yello) or (unit.grun and unit.purp) then
    unit.color_override = {0, 3}
  elseif unit.purp or (unit.reed and unit.bleu) then
    unit.color_override = {3, 1}
  elseif unit.yello or (unit.reed and unit.grun) then
    unit.color_override = {2, 4}
  elseif unit.orang or (unit.reed and unit.yello) then
      unit.color_override = {2, 3}
  elseif unit.cyeann or (unit.bleu and unit.grun) then
    unit.color_override = {1, 4}
  elseif unit.reed then
    unit.color_override = {2, 2}
  elseif unit.bleu then
    unit.color_override = {1, 3}
  elseif unit.grun then
    unit.color_override = {5, 2}
  elseif unit.blacc then
    unit.color_override = {0, 4}
  end
end

function updatePortals()
  for i,unit in ipairs(units) do
    if unit.is_portal and hasProperty(unit, "poor toll") then
      local px, py, move_dir, dir = doPortal(unit, unit.x, unit.y, rotate8(unit.dir), rotate8(unit.dir), true)
      unit.portal.x, unit.portal.y = px, py
      local portal_objects = getUnitsOnTile(px, py, nil, true)
      unit.portal.objects = portal_objects
      unit.portal.dir = rotate8(unit.dir) - dir
      local new_last_objs = copyTable(unit.portal.objects)
      for _,v in ipairs(unit.portal.last) do
        if not table.has_value(unit.portal.objects, v) then
          table.insert(unit.portal.objects, v)
        end
      end
      table.sort(portal_objects, function(a, b) return a.layer < b.layer end)
      unit.portal.last = new_last_objs
    else
      unit.portal.objects = nil
      unit.portal.last = {}
    end
  end
end

function DoDiscordRichPresence()
  if (discordRPC ~= true) then
    local isu = getUnitsWithEffect("u");
    if (#isu > 0) then
      local unit = isu[1];
      if unit.fullname == "bab" or unit.fullname == "keek" or unit.fullname == "meem" then
          presence["smallImageText"] = unit.fullname
          presence["smallImageKey"] = unit.fullname
      elseif unit.fullname == "os" then
        local os = love.system.getOS()

        if os == "Windows" then
          presence["smallImageKey"] = "windous"
        elseif os == "OS X" then
          presence["smallImageKey"] = "maac" -- i know, the mac name is inconsistent but SHUSH you cant change it after you upload the image
        elseif os == "Linux" then
          presence["smallImageKey"] = "linx"
        else
          presence["smallImageKey"] = "other"
        end

        presence["smallImageText"] = "os"
      else
        presence["smallImageText"] = "other"
        presence["smallImageKey"] = "other"
      end
    end
  end
end

function handleDels(to_destroy, unstoppable)
  local convert = false
  local del_units = {}
  for _,unit in ipairs(to_destroy) do
    if unstoppable or not hasProperty(unit, "protecc") then
      unit.destroyed = true
      unit.removed = true
      table.insert(del_units, unit)
    end
  end
  deleteUnits(del_units, false)
  return {}
end

function handleTimeDels(time_destroy)
  local convert = false
  local del_units = {}
  for _,unitid in ipairs(time_destroy) do
    unit = units_by_id[unitid];
    addUndo({"time_destroy_remove", unitid});
    if unit ~= nil and not hasProperty(unit, "protecc") then
      addParticles("destroy",unit.x,unit.y,unit.color)
      unit.destroyed = true
      unit.removed = true
      table.insert(del_units,unit)
      for i,win in ipairs(timeless_win) do
        if unit.id == win then
          addUndo({"timeless_win_remove", win});
          table.remove(timeless_win,i)
        end
      end
      for i,split in ipairs(timeless_splittee) do
        if unit.id == win then
          addUndo({"timeless_splittee_remove", split});
          table.remove(timeless_splittee,i)
        end
      end
    end
  end
  for _,sound in ipairs(time_sfx) do
    playSound(sound,1/#time_sfx)
  end
  time_sfx = {}
  deleteUnits(del_units, false)
  return {}
end

function levelBlock()
  local to_destroy = {}
  local lvlsafe = hasRule(outerlvl,"got","lvl") or hasProperty(outerlvl,"protecc")
  
  if hasProperty(outerlvl, "loop") then
    destroyLevel("infloop")
  end
  
  if hasProperty(outerlvl, "visit fren") then
    for _,unit in ipairs(units) do
      if sameFloat(unit,outerlvl) then
        addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
        if inBounds(unit.x+1,unit.y) then
          moveUnit(unit,unit.x+1,unit.y)
        else
          if inBounds(0,unit.y+1) then
            moveUnit(unit,0,unit.y+1)
          else
            moveUnit(unit,0,0)
          end
        end
      end
    end
  end
  
  if hasProperty(outerlvl, "no swim") then
    for _,unit in ipairs(units) do
      if sameFloat(unit, outerlvl) then
        destroyLevel("sink")
        if not lvlsafe then return end
      end
    end
  end
  
  if hasProperty(outerlvl, "ouch") then
    for _,unit in ipairs(units) do
      if sameFloat(unit, outerlvl) then
        destroyLevel("snacc")
        if not lvlsafe then return end
      end
    end
  end
  
  if hasProperty(outerlvl, "hotte") then
    local melters = getUnitsWithEffect("fridgd")
    for _,unit in ipairs(melters) do
      if sameFloat(unit,outerlvl) then
        table.insert(to_destroy, unit)
        addParticles("destroy", unit.x, unit.y, unit.color)
      end
    end
    if #to_destroy > 0 then
      playSound("hotte")
    end
  end
  
  to_destroy = handleDels(to_destroy)
  
  if hasProperty(outerlvl, "fridgd") then
    if hasProperty(outerlvl, "hotte") then
      destroyLevel("hotte")
      if not lvlsafe then return end
    end
    local melters = getUnitsWithEffect("hotte")
    for _,unit in ipairs(melters) do
      if sameFloat(unit,outerlvl) then
        destroyLevel("hotte")
        if not lvlsafe then return end
      end
    end
  end
  
  if hasProperty(outerlvl, ":(") then
    local yous = getUnitsWithEffect("u")
    local youtoos = getUnitsWithEffect("u too")
    local youtres = getUnitsWithEffect("u tres")
    mergeTable(yous, youtoos)
    mergeTable(yous, youtres)
    for _,unit in ipairs(yous) do
      if sameFloat(unit,outerlvl) then
        table.insert(to_destroy, unit)
        addParticles("destroy", unit.x, unit.y, unit.color)
      end
    end
  end
  
  to_destroy = handleDels(to_destroy)
  
  if hasProperty(outerlvl, "ned kee") then
    if hasProperty(outerlvl, "for dor") then
      destroyLevel("unlock")
      if not lvlsafe then return end
    end
    local dors = getUnitsWithEffect("for dor")
    for _,unit in ipairs(dors) do
      if sameFloat(unit,outerlvl) then
        destroyLevel("unlock")
        if lvlsafe then
          table.insert(to_destroy, unit)
          addParticles("destroy", unit.x, unit.y, unit.color)
        else return end
      end
    end
    if #to_destroy > 0 then
      playSound("unlock",0.5)
      playSound("break",0.5)
    end
  end
  
  to_destroy = handleDels(to_destroy)
  
  if hasProperty(outerlvl, "for dor") then
    local kees = getUnitsWithEffect("ned kee")
    for _,unit in ipairs(kees) do
      if sameFloat(unit,outerlvl) then
        destroyLevel("unlock")
        if lvlsafe then
          table.insert(to_destroy, unit)
          addParticles("destroy", unit.x, unit.y, unit.color)
        else return end
      end
    end
    if #to_destroy > 0 then
      playSound("unlock",0.5)
      playSound("break",0.5)
    end
  end
  
  to_destroy = handleDels(to_destroy)
  
  local issnacc = matchesRule(outerlvl,"snacc",nil)
  for _,ruleparent in ipairs(issnacc) do
    local unit = ruleparent[2]
    if unit ~= outerlvl and sameFloat(outerlvl,unit) then
      addParticles("destroy", unit.x, unit.y, unit.color)
      table.insert(to_destroy, unit)
    end
  end
  
  local issnacc = matchesRule(nil,"snacc",outerlvl)
  for _,ruleparent in ipairs(issnacc) do
    local unit = ruleparent[2]
    if unit ~= outerlvl and sameFloat(outerlvl,unit) then
      destroyLevel("snacc")
      if not lvlsafe then return end
    end
  end
  
  if #to_destroy > 0 then
    playSound("snacc")
    shakeScreen(0.3, 0.1)
  end
  
  to_destroy = handleDels(to_destroy)
  
  local will_undo = false
  if hasProperty(outerlvl, "try again") then
    local yous = getUnitsWithEffect("u")
    local youtoos = getUnitsWithEffect("u too")
    local youtres = getUnitsWithEffect("u tres")
    mergeTable(yous, youtoos)
    mergeTable(yous, youtres)
    for _,unit in ipairs(yous) do
      if sameFloat(unit,outerlvl) then
        will_undo = true
        break
      end
    end
  end
  
  if hasProperty(outerlvl, "xwx") then
    local yous = getUnitsWithEffect("u")
    local youtoos = getUnitsWithEffect("u too")
    local youtres = getUnitsWithEffect("u tres")
    mergeTable(yous, youtoos)
    mergeTable(yous, youtres)
    for _,unit in ipairs(yous) do
      if sameFloat(unit,outerlvl) then
        love = {}
      end
    end
  end
  
  if hasProperty(outerlvl, ":o") then
    local yous = getUnitsWithEffect("u")
    local youtoos = getUnitsWithEffect("u too")
    local youtres = getUnitsWithEffect("u tres")
    mergeTable(yous, youtoos)
    mergeTable(yous, youtres)
    for _,unit in ipairs(yous) do
      if sameFloat(unit,outerlvl) then
        destroyLevel("bonus")
        if not lvlsafe then return end
      end
    end
  end
  
  if hasProperty(outerlvl, ":)") then
    local yous = getUnitsWithEffect("u")
    local youtoos = getUnitsWithEffect("u too")
    local youtres = getUnitsWithEffect("u tres")
    mergeTable(yous, youtoos)
    mergeTable(yous, youtres)
    for _,unit in ipairs(yous) do
      if sameFloat(unit,outerlvl) then
        doWin()
      end
    end
  end
  
  if hasProperty(outerlvl, "nxt") then
		--placeholder until NXT is coded
    doWin()
  end
  
  if (will_undo) then
    local can_undo = true
    while (can_undo) do
      can_undo = undo(true)
    end
    parseRules(true)
    reset_count = reset_count + 1
  end
end

function changeDirIfFree(unit, dir)
  if canMove(unit, dirs8[dir][1], dirs8[dir][2], dir, false, false, unit.name, "dir check") then
    addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
    unit.olddir = unit.dir
    updateDir(unit, dir);
    return true
  end
  return false
end

function taxicabDistance(a, b)
  return math.abs(a.x - b.x) + math.abs(a.y - b.y)
end

function bishopDistance(a, b)
  if ((a.x + a.y) % 2) == ((b.x + b.y) % 2) then
    return kingDistance(a, b)
  else
    return -1
  end
end

function kingDistance(a, b)
  return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

function euclideanDistance(a, b)
  return (a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y)
end

function readingOrderSort(a, b)
  if a.y ~= b.y then
    return a.y < b.y
  elseif a.x ~= b.x then
    return a.x < b.x
  else
    return a.id < b.id
  end
end

function destroyLevel(reason)
	if not hasRule(outerlvl,"got","lvl") and not hasProperty(outerlvl,"protecc") and (reason ~= "infloop") then
    level_destroyed = true
    for _,unit in ipairs(units) do
      addParticles("destroy", unit.x, unit.y, unit.color)
    end
    handleDels(units, true)
  end
  
  local holds = matchesRule(outerlvl,"got","?")
  for _,match in ipairs(holds) do
    if not nameIs(outerlvl, match[1][3]) then
      local tile = tiles_by_name[match[1][3]]
      if tile == nil and match[1][3] == "every1" then
        tile = tiles_by_name["text_every1"]
      end
      if tile ~= nil then
        --placeholder - just make 'u r win' pop up for now
        doWin()
        win_sprite_override = tiles_list[tile].sprite
      end
    end
  end
  
  addUndo({"destroy_level", reason});
  playSound(reason)
  if reason == "unlock" or reason == "convert" then
    playSound("break")
  end
  
  if reason == "infloop" then
    if hasRule("loop","be",":)") then
      doWin()
    elseif hasRule("loop","be","xwx") then
      love = {}
    elseif hasRule("loop","be","try again") then
      local can_undo = true;
      while (can_undo) do
        can_undo = undo(true)
      end
      parseRules(true)
      reset_count = reset_count + 1
    else
      level_destroyed = true
      for _,unit in ipairs(units) do
        addParticles("destroy", unit.x, unit.y, unit.color)
      end
      handleDels(units, true)
      local new_unit = createUnit(tiles_by_name["infloop"], math.floor(mapwidth/2), math.floor(mapheight/2), 0)
      addUndo({"create", new_unit.id, false})
    end
  end
end

function dropGotUnit(unit, rule)
  --TODO: CLEANUP: Blatantly copypasta'd from convertUnits.
  local obj_name = rule[3]
  if (obj_name == "hatt" or obj_name == "gunne" or obj_name == "katany" or unit == outerlvl) then
    return
  end
  
  local istext = false
  if rule[3] == "text" then
    istext = true
    obj_name = "text_" .. rule[1]
  end
  if rule[3]:starts("text_") then
    istext = true
  end
  if rule[3]:starts("this") then
    obj_name = "this"
  end
  local obj_id = tiles_by_name[obj_name]
  local obj_tile = tiles_list[obj_id]
  if rule[3] == "mous" or (obj_tile ~= nil and (obj_tile.type == "object" or istext)) then
    --if testConds(unit,rule[4][1]) then
    if rule[3] == "mous" then
      local new_mouse = createMouse(unit.x, unit.y)
      addUndo({"create_cursor", new_mouse.id})
    else
      local new_unit = createUnit(obj_id, unit.x, unit.y, unit.dir, false)
      addUndo({"create", new_unit.id, false})
    end
  end
end

function convertLevel()
  local deconverts = matchesRule(outerlvl,"ben't","lvl")
  if #deconverts > 0 then
    destroyLevel("convert")
    return true
  end
  
  local demeta = matchesRule(outerlvl,"ben't","meta")
  if #demeta > 0 then
    destroyLevel("convert")
    return true
  end
  
  local meta = matchesRule(outerlvl, "be","meta")
  if (#meta > 0) then
   local tile = nil
    local nametocreate = outerlvl.fullname;
    for i = 1,#meta do
      nametocreate = "text_"..nametocreate;
    end
    tile = tiles_by_namePossiblyMeta(nametocreate)
    if tile ~= nil then
      --placeholder - just make 'u r win' pop up for now
      doWin()
      win_sprite_override = tiles_list[tile].sprite
      return true
    end
  end

  local converts = matchesRule(outerlvl,"be","?")
  for _,match in ipairs(converts) do
    if not nameIs(outerlvl, match[1][3]) then
      local tile = tiles_by_name[match[1][3]]
      if match[1][3] == "text" then
        tile = tiles_by_name["text_lvl"]
      end
      if tile == nil and match[1][3] == "every1" and not hasRule(outerlvl, "be", "lvl") then
        tile = tiles_by_name["text_every1"]
      end
      if match[1][3]:starts("this") then
        tile = tiles_by_name["this"]
      end
      if tile ~= nil then
        --placeholder - just make 'u r win' pop up for now
        doWin()
        win_sprite_override = tiles_list[tile].sprite
        return true
      end
    end
  end
end

function ruleHasCondition(rule, cond_name)
	if rule[4] == nil then return false end
	if rule[4][1] == nil then return false end
	if rule[4][1][1] == nil then return false end
	if rule[4][1][1][1] == nil then return false end
	for _,cond in ipairs(rule[4][1]) do
		if cond[1] == cond_name then return true end
	end
	return false
end

function convertUnits(pass)
  for i,v in pairs(units_by_tile) do
    units_by_tile[i] = {}
  end
  
  if level_destroyed then return end
  if convertLevel() then return end

 --keep empty out of units_by_tile - it will be returned in getUnitsOnTile
 --TODO: CLEANUP: This is similar to updateUnits.
  for _,unit in ipairs(units) do
    if unit.fullname ~= "no1" and unit.type ~= "outerlvl" then
      local tileid = unit.x + unit.y * mapwidth
      table.insert(units_by_tile[tileid], unit)
    end
  end

  local converted_units = {}
  
  local meta = getUnitsWithRuleAndCount(nil, "be","meta")
  for unit,amt in pairs(meta) do
    if not unit.new and unit.type ~= "outerlvl" and timecheck(unit,"be","meta") then
      table.insert(converted_units, unit)
      addParticles("bonus", unit.x, unit.y, unit.color)
      local tile = nil
      local nametocreate = unit.fullname;
      for i = 1,amt do
        nametocreate = "text_"..nametocreate;
      end
      tile = tiles_by_namePossiblyMeta(nametocreate)
      if tile ~= nil then
        local new_unit = createUnit(tile, unit.x, unit.y, unit.dir, true)
        if (new_unit ~= nil) then
          addUndo({"create", new_unit.id, true, created_from_id = unit.id})
        end
      end
    end
  end
  
  --[[local meta = matchesRule(nil, "be", "meta")
  for _,match in ipairs(meta) do
    local rules = match[1]
    local unit = match[2]
    local rule = rules[1]
    if not unit.new and unit.type ~= "outerlvl" and timecheck(unit) then
      table.insert(converted_units, unit)
      addParticles("bonus", unit.x, unit.y, unit.color)
      tile = tiles_by_namePossiblyMeta("text_" .. unit.fullname)
      if tile ~= nil then
        local new_unit = createUnit(tile, unit.x, unit.y, unit.dir, true)
        if (new_unit ~= nil) then
          addUndo({"create", new_unit.id, true, created_from_id = unit.id})
        end
      end
    end
  end]]
  
  local demeta = getUnitsWithRuleAndCount(nil, "ben't","meta")
  for unit,amt in pairs(demeta) do
    if not unit.new and unit.type ~= "outerlvl" and timecheck(unit,"ben't","meta") then
      table.insert(converted_units, unit)
      addParticles("bonus", unit.x, unit.y, unit.color)
      --remove "text_" as many times as we're de-metaing
      local nametocreate = unit.fullname;
      for i = 1,amt do
        if nametocreate:starts("text_") then
          nametocreate = nametocreate:sub(6, -1);
        else
          nametocreate = "no1"
          break
        end
      end
      local tile = tiles_by_name[nametocreate];
      if tile ~= nil then
        local new_unit = createUnit(tile, unit.x, unit.y, unit.dir, true)
        if (new_unit ~= nil) then
          addUndo({"create", new_unit.id, true, created_from_id = unit.id})
        end
      end
    end
  end

  local deconverts = matchesRule(nil,"ben't","?")
  for _,match in ipairs(deconverts) do
    local rules = match[1]
    local unit = match[2]

    local rule = rules[1]

    if not unit.new and nameIs(unit, rule[3]) and timecheck(unit) and (pass < 2 or not ruleHasCondition(rule, "arond")) then
      if not unit.removed and unit.type ~= "outerlvl" then
        addParticles("bonus", unit.x, unit.y, unit.color)
        table.insert(converted_units, unit)
      end
    end
  end

  local all = matchesRule(nil,"be","every1")
  for _,match in ipairs(all) do
    local rules = match[1]
    local unit = match[2]
    local rule = rules[1]
    
    if not unit.new and unit.class == "unit" and unit.type ~= "outerlvl" and not hasRule(unit, "be", unit.name) and timecheck(unit and (pass < 2 or not ruleHasCondition(rule, "arond"))) then
      for _,v in ipairs(referenced_objects) do
        local tile = tiles_by_name[v]
        if v == "text" then
          tile = tiles_by_name["text_" .. rule[1]]
        end
        if tile ~= nil then
          if not unit.removed then
            table.insert(converted_units, unit)
          end
          local new_unit = createUnit(tile, unit.x, unit.y, unit.dir, true)
          if (new_unit ~= nil) then
            addUndo({"create", new_unit.id, true, created_from_id = unit.id})
          end
        elseif v == "mous" then
          if not unit.removed then
            table.insert(converted_units, unit)
          end
          unit.removed = true
          local new_mouse = createMouse(unit.x, unit.y)
          addUndo({"create_cursor", new_mouse.id, created_from_id = unit.id})
        end
      end
    end
  end
  
  local converts = matchesRule(nil,"be","?")
  for _,match in ipairs(converts) do
    local rules = match[1]
    local unit = match[2]
    local rule = rules[1]

    if not unit.new and unit.class == "unit" and not nameIs(unit, rule[3]) and unit.type ~= "outerlvl" and timecheck(unit) and (pass < 2 or not ruleHasCondition(rule, "arond")) then
      local tile = tiles_by_name[rule[3]]
      if rule[3] == "text" then
        tile = tiles_by_name["text_" .. rule[1]]
      elseif rule[3]:starts("this") then
        tile = tiles_by_name["this"]
      end
      if tile ~= nil then
        if not unit.removed then
          table.insert(converted_units, unit)
        end
        local new_unit = createUnit(tile, unit.x, unit.y, unit.dir, true)
        if (new_unit ~= nil) then
          addUndo({"create", new_unit.id, true, created_from_id = unit.id})
        end
      elseif rule[3] == "mous" then
        if not unit.removed then
          table.insert(converted_units, unit)
        end
        unit.removed = true
        local new_mouse = createMouse(unit.x, unit.y)
        addUndo({"create_cursor", new_mouse.id, created_from_id = unit.id})
      end
    end
  end
  
  local moars = getUnitsWithEffect("moar")
  for _,slice in  ipairs(moars) do
    if slice.name == "lie/8" then
      if not slice.removed then
        table.insert(converted_units, slice)
      end
      local tile = tiles_by_name["lie"]
      local new_unit = createUnit(tile, slice.x, slice.y, slice.dir, true)
      addUndo({"create", new_unit.id, true, created_from_id = slice.id})
    end
  end
  
  local thes = matchesRule(nil,"be","the")
  for _,ruleparent in ipairs(thes) do
    local unit = ruleparent[2]
    local the = ruleparent[1][2][3]
    
    local tx = the.x
    local ty = the.y
    local dir = the.dir
    local dx = dirs8[dir][1]
    local dy = dirs8[dir][2]
    dx,dy,dir,tx,ty = getNextTile(the,dx,dy,dir)
    
    local tfd = false
    local tfs = getUnitsOnTile(tx,ty)
    for _,other in ipairs(tfs) do
      if not hasRule(unit,"be",unit.name) and not hasRule(unit,"ben't",other.fullname) then
        local tile = tiles_by_name[other.fullname]
        local new_unit = createUnit(tile, unit.x, unit.y, unit.dir, true)
        if new_unit ~= nil then
          tfd = true
          addUndo({"create", new_unit.id, true, created_from_id = unit.id})
        end
      end
    end
    
    if tfd and not unit.removed then
      table.insert(converted_units, unit)
    end
  end

  deleteUnits(converted_units,true)
end

function deleteUnits(del_units,convert)
  for _,unit in ipairs(del_units) do
    if (not unit.removed_final) then
      for colour,_ in pairs(main_palette_for_colour) do
        if unit[colour] == true then
          addUndo({"colour_change", unit.id, colour, true});
        end
      end
      if (unit.backer_turn ~= nil) then
        addUndo({"backer_turn", unit.id, unit.backer_turn})
      end
      addUndo({"remove", unit.tile, unit.x, unit.y, unit.dir, convert or false, unit.id})
    end
    deleteUnit(unit,convert)
  end
end

function createUnit(tile,x,y,dir,convert,id_,really_create_empty)
  local unit = {}
  unit.class = "unit"

  unit.id = newUnitID(id_)
  unit.tempid = newTempID()
  unit.x = x or 0
  unit.y = y or 0
  unit.dir = dir or 1
  unit.active = false
  unit.blocked = false
  unit.removed = false

  unit.draw = {x = unit.x, y = unit.y, scalex = 1, scaley = 1, rotation = (unit.dir - 1) * 45}

  if convert then
    unit.draw.scaley = 0
    addTween(tween.new(0.1, unit.draw, {scaley = 1}), "unit:scale:" .. unit.tempid)
  end

  unit.old_active = unit.active
  unit.overlay = {}
  unit.used_as = {} -- list of text types, used for determining sprite transformation
  unit.frame = math.random(1, 3)-1 -- for potential animation
  unit.special = {} -- for lvl objects
  unit.portal = {dir = 1, last = {}, extra = {}} -- for hol objects

  local data = tiles_listPossiblyMeta(tile)

  unit.tile = tile
  unit.sprite = data.sprite
  unit.type = data.type
  unit.texttype = data.texttype or "object"
	unit.meta = data.meta
  unit.allowconds = data.allowconds or false
  unit.color = data.color
  unit.layer = data.layer
  unit.rotate = data.rotate or false
  unit.got_objects = {}
  unit.sprite_transforms = data.sprite_transforms or {}
  unit.eye = data.eye -- eye rectangle used for sans
  unit.is_portal = data.portal or false

  unit.fullname = data.name
  if rules_effecting_names[unit.name] or rules_effecting_names[unit.fullname] then
    should_parse_rules = true
  end

  if unit.type == "text" then
    should_parse_rules = true
    unit.name = "text"
    if unit.texttype == "letter" then
      unit.textname = string.sub(unit.fullname, 8)
    else
      unit.textname = string.sub(unit.fullname, 6)
    end
  else
    unit.name = unit.fullname
    unit.textname = unit.fullname
  end
  
  --abort if we're trying to create outerlvl outside of the start
  if (x < -10 or y < -10) and unit.name == "lvl" and not really_create_empty then
    return
  end
  
  --make outerlvl here
  if ((unit.name == "lvl" or unit.fullname == "lvl") and really_create_empty) then
    unit.type = "outerlvl";
  end
  
  --abort if we're trying to create empty outside of initialization, to preserve the invariant 'there is exactly empty per tile'
  if ((unit.fullname == "no1") and not really_create_empty) then
    --print("not placing an empty:"..unit.name..","..unit.fullname..","..unit.textname)
    return nil
  end
  
  if unit.fullname == "this" then
    unit.name = unit.name .. unit.id
    unit.textname = unit.textname .. unit.id
  end

  if unit.texttype == "object" and unit.textname ~= "every1" and unit.textname ~= "mous" and unit.textname ~= "no1" and unit.textname ~= "lvl" and unit.textname ~= "text" then
    if not unit.textname:ends("n't") and not unit.textname:starts("text_") and not table.has_value(referenced_objects, unit.textname) then
      table.insert(referenced_objects, unit.textname)
    end
  end
  if unit.type == "text" then
    if not table.has_value(referenced_text, unit.fullname) then
      table.insert(referenced_text, unit.fullname)
    end
  end

  units_by_id[unit.id] = unit

  if (not units_by_name[unit.name] and not unit.type ~= "outerlvl") then
    units_by_name[unit.name] = {}
  end
  table.insert(units_by_name[unit.name], unit)

  if unit.fullname ~= unit.name then
    if not units_by_name[unit.fullname] then
      units_by_name[unit.fullname] = {}
    end
    table.insert(units_by_name[unit.fullname], unit)
  end

  if not units_by_layer[unit.layer] then
    units_by_layer[unit.layer] = {}
  end
  table.insert(units_by_layer[unit.layer], unit)
  max_layer = math.max(max_layer, unit.layer)

  local tileid = x + y * mapwidth
  --keep empty out of units_by_tile - it will be returned in getUnitsOnTile
  if (not (unit.fullname == "no1" or unit.type == "outerlvl")) then
    table.insert(units_by_tile[tileid], unit)
  end

  table.insert(units, unit)

  updateDir(unit, unit.dir)
  new_units_cache[unit] = true
  unit.new = true
  return unit
end

function deleteUnit(unit,convert,undoing)
  unit.removed = true
  unit.removed_final = true
  if not undoing and not convert and rules_with ~= nil then
    gotters = matchesRule(unit, "got", "?");
    for _,ruleparent in ipairs(gotters) do
      local rule = ruleparent[1]
      dropGotUnit(unit, rule);
    end
  end
  --empty can't really be destroyed, only pretend to be, to preserve the invariant 'there is exactly empty per tile'
  if (unit.fullname == "no1" or unit.type == "outerlvl") then
    unit.destroyed = false
    unit.removed = false
    unit.removed_final = false
    return
  end
  if unit.type == "text" or rules_effecting_names[unit.name] or rules_effecting_names[unit.fullname] then
    should_parse_rules = true
  end
  removeFromTable(units, unit)
  units_by_id[unit.id] = nil
  removeFromTable(units_by_name[unit.name], unit)
  if unit.name ~= unit.fullname then
    removeFromTable(units_by_name[unit.fullname], unit)
  end
  local tileid = unit.x + unit.y * mapwidth
  removeFromTable(units_by_tile[tileid], unit)
  if not convert then
    removeFromTable(units_by_layer[unit.layer], unit)
  else
    table.insert(still_converting, unit)
    addTween(tween.new(0.1, unit.draw, {scaley = 0}), "unit:scale:" .. unit.tempid)
    tick.delay(function() removeFromTable(still_converting, unit) end, 0.1)
  end
end

function moveUnit(unit,x,y,portal)
  --when empty moves, swap it with the empty in its destination tile, to preserve the invariant 'there is exactly empty per tile'
  --also, keep empty out of units_by_tile - it will be added in getUnitsOnTile
  if (unit.type == "outerlvl") then
  elseif (unit.fullname == "no1") then
    local tileid = unit.x + unit.y * mapwidth
    local oldx = unit.x
    local oldy = unit.y
    unit.x = x
    unit.y = y
    local dest_tileid = unit.x + unit.y * mapwidth
    dest_empty = empties_by_tile[dest_tileid];
    dest_empty.x = oldx;
    dest_empty.y = oldy;
    dest_empty.dir = unit.dir;
    empties_by_tile[tileid] = dest_empty;
    empties_by_tile[dest_tileid] = unit;
  else
    local tileid = unit.x + unit.y * mapwidth
    removeFromTable(units_by_tile[tileid], unit)

    -- putting portal check above same-position check to give portal effect through one-tile gap
    if portal and portal.is_portal and x - portal.x == dirs8[portal.dir][1] and y - portal.y == dirs8[portal.dir][2] then
      if unit.type == "text" or rules_effecting_names[unit.name] or rules_effecting_names[unit.fullname] then
        should_parse_rules = true
      end
      portaling[unit] = portal
      -- set draw positions to portal offset to interprolate through portals
      unit.draw.x, unit.draw.y = portal.draw.x, portal.draw.y
      addTween(tween.new(0.1, unit.draw, {x = x, y = y}), "unit:pos:" .. unit.tempid)
      -- instantly change object's rotation, weirdness ensues otherwise
      unit.draw.rotation = (unit.dir - 1) * 45
      tweens["unit:dir:" .. unit.tempid] = nil
    elseif x ~= unit.x or y ~= unit.y then
      if unit.type == "text" or rules_effecting_names[unit.name] or rules_effecting_names[unit.fullname] then
        should_parse_rules = true
      end
      if (unit.draw.x == x and unit.draw.y == y) then
        --'bump' effect to show movement failed
        unit.draw.x = (unit.x+x*2)/3;
        unit.draw.y = (unit.y+y*2)/3;
        addTween(tween.new(0.1, unit.draw, {x = x, y = y}), "unit:pos:" .. unit.tempid)
      elseif math.abs(x - unit.x) < 2 and math.abs(y - unit.y) < 2 then
        --linear interpolate to adjacent destination
        addTween(tween.new(0.1, unit.draw, {x = x, y = y}), "unit:pos:" .. unit.tempid)
      else
        --fade in, fade out effect
        addTween(tween.new(0.05, unit.draw, {scalex = 0}), "unit:pos:" .. unit.tempid, function()
        unit.draw.x = x
        unit.draw.y = y
        addTween(tween.new(0.05, unit.draw, {scalex = 1}), "unit:pos:" .. unit.tempid)
        end)
      end
    end

    unit.x = x
    unit.y = y

    tileid = unit.x + unit.y * mapwidth
    table.insert(units_by_tile[tileid], unit)
  end

  do_move_sound = true
end

function updateDir(unit, dir, force)
  if not unit.rotate and rules_with ~= nil and not hasProperty(unit,"rotatbl") then
    return false
  end
  if not force and rules_with ~= nil then
    if not timecheck(unit) then
      return false
    end
    if hasProperty(unit, "no turn") then
      return false
    end
    if hasRule(unit, "ben't", dirs8_by_name[dir]) then
      return false
    end
  end
  unit.dir = dir
  if unit.type == "text" or rules_effecting_names[unit.name] or rules_effecting_names[unit.fullname]  then
    should_parse_rules = true
  end
  if unit.fullname == "text_direction" then
    unit.textname = dirs8_by_name[unit.dir];
  end
  if unit.fullname == "text_spin" then
    unit.textname = "spin_" .. tostring(unit.dir);
  end
  
  if unit.fullname == "letter_colon" then
    if unit.dir == 1 or unit.dir == 2 then
      unit.textname = ":"
    elseif unit.dir == 3 then
      local isumlaut = getTextOnTile(unit.x,unit.y+1)
      if isumlaut ~= nil then
        for _,umlautee in ipairs(isumlaut) do
          if umlautee.fullname == "letter_u" or (umlautee.fullname == "letter_h" and (umlautee.dir == 3 or umlautee.dir == 7)) then
            unit.textname = ""
            break
          else
            unit.textname = ".."
          end
        end
      else
        unit.textname = ".."
      end
    else
      unit.textname = "  "
    end
  end
  
  if unit.fullname == "letter_u" then
    local umlauts = getTextOnTile(unit.x,unit.y-1)
    for _,umlaut in ipairs(umlauts) do
      if umlaut.fullname == "letter_colon" and umlaut.dir == 3 then
        unit.textname = "..u"
        break
      end
    end
  end
  
  if unit.fullname == "letter_i" then
    local umlauts = getTextOnTile(unit.x,unit.y-1)
    if umlauts ~= nil then
      for _,umlaut in ipairs(umlauts) do
        if umlaut.fullname == "letter_colon" and umlaut.dir == 3 then
          unit.textname = "..i"
          break
        else
          unit.textname = "i"
        end
      end
    else
      unit.textname = "i"
    end
  end
  
  if unit.fullname == "letter_parenthesis" then
    if unit.dir == 1 or unit.dir == 2 or unit.dir == 3 then
      unit.textname = "("
    elseif unit.dir == 5 or unit.dir == 6 or unit.dir == 7 then
      unit.textname = ")"
    end
  end
  
  unit.draw.rotation = unit.draw.rotation % 360
  local target_rot = (dir - 1) * 45
  if unit.rotate and math.abs(unit.draw.rotation - target_rot) == 180 then
    -- flip "mirror" effect
    addTween(tween.new(0.05, unit.draw, {scalex = 0}), "unit:dir:" .. unit.tempid, function()
      unit.draw.rotation = target_rot
      addTween(tween.new(0.05, unit.draw, {scalex = 1}), "unit:dir:" .. unit.tempid)
    end)
  else
    -- smooth angle rotation
    if unit.draw.rotation - target_rot > 180 then
      target_rot = target_rot + 360
    elseif target_rot - unit.draw.rotation > 180 then
      target_rot = target_rot - 360
    end
    addTween(tween.new(0.1, unit.draw, {scalex = 1, rotation = target_rot}), "unit:dir:" .. unit.tempid)
  end
  return true
end

function newUnitID(id)
  if id then
    max_unit_id = math.max(id, max_unit_id)
    return id
  else
    max_unit_id = max_unit_id + 1
    return max_unit_id
  end
end

function newTempID()
  max_temp_id = max_temp_id + 1
  return max_temp_id
end

function newMouseID()
  max_mouse_id = max_mouse_id + 1
  return max_mouse_id
end

meta_offset = 100000
function tiles_listPossiblyMeta(tile_id)
  local tile = tiles_list[tile_id];
  if (tile ~= nil) then
    return tile
  end
  --recursively make all less meta tiles
  if (tile_id > 100000) then
    local premeta_tile = tiles_listPossiblyMeta(tile_id-meta_offset);
    --now we can make our new meta tile!
    tile = makeMetaTile(premeta_tile);
    tiles_by_name[tile.name] = tile_id;
    tiles_list[tile_id] = tile;
  end
  return tile;
end

function tiles_by_namePossiblyMeta(name)
  local tile_id = tiles_by_name[name];
  if (tile_id ~= nil) then
    return tile_id
  end
  --recursively make all less meta tiles
  if name:starts("text_") then
    local premeta_tile_id = tiles_by_namePossiblyMeta(name:sub(6, -1));
    local premeta_tile = tiles_list[premeta_tile_id];
    tile_id = premeta_tile_id+meta_offset;
    --now we can make our new meta tile!
    local tile = makeMetaTile(premeta_tile);
    tiles_by_name[name] = tile_id;
    tiles_list[tile_id] = tile;
  end
  return tile_id;
end

function makeMetaTile(premeta_tile)
  return {
    name = "text_" .. premeta_tile.name,
    sprite = premeta_tile.metasprite or premeta_tile.sprite,
    type = "text",
    color = premeta_tile.color,
    layer = 20,
    meta = premeta_tile.meta ~= nil and premeta_tile.meta + 1 or 1
  }
end

function undoWin()
    if hasProperty(outerlvl, "no undo") then return end
    currently_winning = false
	music_fading = false
    win_size = 0
end

function doWin()
	if not currently_winning then
		won_this_session = true
    currently_winning = true
		music_fading = true
    win_size = 0
		playSound("win")
		love.filesystem.createDirectory("levels")
    love.filesystem.write("levels/" .. level_name .. ".replay", replay_string)
		print("Replay successfully saved to ".."levels/" .. level_name .. ".replay")
	end
end