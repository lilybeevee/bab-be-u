function moveBlock()
  --baba order: FOLLOW, BACK, TELE, SHIFT
  --bab order: big, zip, look at, undo, visit fren, go, goooo, shy, spin, folo wal, turn cornr
  
  for _,unit in ipairs(units_by_name["text_xwx"] or {}) do
    local newname = hasProperty(unit, "slep") and "uwu" or "xwx"
    should_parse_rules = unit.textname ~= newname
    unit.textname = newname
  end
  
  --currently very bad method of making sure big stuff gets updated: go through all units and make sure they're set up properly
  if units_by_name["text_big"] then
    for _,unit in ipairs(units) do
      if hasProperty(unit,"big") then
        for i=1,3 do
          if not table.has_value(unitsByTile(unit.x+i%2,unit.y+math.floor(i/2)),unit) then
            table.insert(unitsByTile(unit.x+i%2,unit.y+math.floor(i/2)),unit)
          end
        end
      else
        for i=1,3 do
          if table.has_value(unitsByTile(unit.x+i%2,unit.y+math.floor(i/2)),unit) then
            removeFromTable(unitsByTile(unit.x+i%2,unit.y+math.floor(i/2)),unit)
          end
        end
      end
    end
  end
  
  local iszip = getUnitsWithEffect("zip")
  for _,unit in ipairs(iszip) do
    doZip(unit)
  end
  
  local isstalk = matchesRule("?", "look at", "?")
  for _,ruleparent in ipairs(isstalk) do
    local stalkers = findUnitsByName(ruleparent.rule.subject.name)
    local stalkees = copyTable(findUnitsByName(ruleparent.rule.object.name))
    local stalker_conds = ruleparent.rule.subject.conds
    local stalkee_conds = ruleparent.rule.object.conds
    for _,stalker in ipairs(stalkers) do
      table.sort(stalkees, function(a, b) return euclideanDistance(a, stalker) < euclideanDistance(b, stalker) end )
      for _,stalkee in ipairs(stalkees) do
        if testConds(stalker, stalker_conds) and testConds(stalkee, stalkee_conds, stalker) then
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
  
  local isstalknt = matchesRule("?", "look away", "?")
  for _,ruleparent in ipairs(isstalknt) do
    local stalkers = findUnitsByName(ruleparent.rule.subject.name)
    local stalkees = copyTable(findUnitsByName(ruleparent.rule.object.name))
    local stalker_conds = ruleparent.rule.subject.conds
    local stalkee_conds = ruleparent.rule.object.conds
    for _,stalker in ipairs(stalkers) do
      table.sort(stalkees, function(a, b) return euclideanDistance(a, stalker) < euclideanDistance(b, stalker) end )
      for _,stalkee in ipairs(stalkees) do
        if testConds(stalker, stalker_conds) and testConds(stalkee, stalkee_conds, stalker) then
          local dist = euclideanDistance(stalker, stalkee)
          local stalk_dir = dist > 0 and dirs8_by_offset[-sign(stalkee.x - stalker.x)][-sign(stalkee.y - stalker.y)] or stalkee.dir
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
  
  local backed_this_turn = {}
  local not_backed_this_turn = {}
  
  local isback = getUnitsWithEffectAndCount("undo")
  if hasProperty(outerlvl, "undo") then
    for _,unit in ipairs(units) do
      if isback[unit] then
        isback[unit] = isback[unit] + 1
      else
        isback[unit] = 1
      end
    end
  end
  for unit,amt in pairs(isback) do
    --print("backing 1:", unit.fullname, amt, unit.backer_turn, backers_cache[unit])
    backed_this_turn[unit] = true
    if (unit.backer_turn == nil) then
      addUndo({"backer_turn", unit.id, nil})
      unit.backer_turn = #undo_buffer+(0.5*(amt-1))
      backers_cache[unit] = unit.backer_turn
    end
    --print("backing 2:", unit.fullname, amt, unit.backer_turn, backers_cache[unit])
    doBack(unit.id, 2*(#undo_buffer-unit.backer_turn))
    for i = 2,amt do
      addUndo({"backer_turn", unit.id, unit.backer_turn})
      unit.backer_turn = unit.backer_turn - 0.5
      doBack(unit.id, 2*(#undo_buffer-unit.backer_turn))
    end
  end
  
  for unit,turn in pairs(backers_cache) do
    if turn ~= nil and not backed_this_turn[unit] then
      not_backed_this_turn[unit] = true
    end
  end
  
  for unit,_ in pairs(not_backed_this_turn) do
    addUndo({"backer_turn", unit.id, unit.backer_turn})
    unit.backer_turn = nil
    backers_cache[unit] = nil
  end
  
  to_destroy = handleDels(to_destroy)
  
  --Currently using deterministic tele version. Number of teles a teleporter has influences whether it goes forwards or backwards and by how many steps.
  local istele = getUnitsWithEffectAndCount("visit fren")
  teles_by_name = {}
  teles_by_name_index = {}
  tele_targets = {}
  --form lists, by tele name, of what all the tele units are
  for unit,amt in pairs(istele) do
    if teles_by_name[unit.fullname] == nil then
      teles_by_name[unit.fullname] = {}
    end
    table.insert(teles_by_name[unit.fullname], unit)
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
    local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, nil, hasProperty(unit,"big"))
    for _,on in ipairs(stuff) do
      --we're going to deliberately let two same name teles tele if they're on each other, since with the deterministic behaviour it's predictable and interesting
      if unit ~= on and sameFloat(unit, on) and ignoreCheck(unit, on, "visitfren") and timecheck(unit,"be","visitfren") --[[and unit.fullname ~= on.fullname]] then
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
        local fullrule = ruleparent.units
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
        local fullrule = ruleparent.units
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
        local fullrule = ruleparent.units
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
  
  --Use a similar simultaneous/additive algorithm to copkat/go^.
  
  units_to_change = {}
  
  
  local isshift = getUnitsWithEffect("go")
  for _,unit in ipairs(isshift) do
    local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, nil, hasProperty(unit,"big"))
    for _,on in ipairs(stuff) do
      if unit ~= on and sameFloat(unit, on) and ignoreCheck(unit, on, "go") and timecheck(unit,"be","go") then
        if (units_to_change[on] == nil) then
          units_to_change[on] = {0, 0}
        end
        units_to_change[on][1] = units_to_change[on][1] + dirs8[unit.dir][1]
        units_to_change[on][2] = units_to_change[on][2] + dirs8[unit.dir][2]
      end
    end
  end
  
  local isshift = getUnitsWithEffect("goooo")
  for _,unit in ipairs(isshift) do
    local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, nil, hasProperty(unit,"big"))
    for _,on in ipairs(stuff) do
      if unit ~= on and sameFloat(unit, on) and ignoreCheck(unit, on, "goooo") and timecheck(unit,"be","goooo") then
         if (units_to_change[on] == nil) then
          units_to_change[on] = {0, 0}
        end
        units_to_change[on][1] = units_to_change[on][1] + dirs8[unit.dir][1]
        units_to_change[on][2] = units_to_change[on][2] + dirs8[unit.dir][2]
      end
    end
  end
  
  for unit,dir in pairs(units_to_change) do
    if dir[1] ~= 0 or dir[2] ~= 0 then
      k = dirs8_by_offset[sign(dir[1])][sign(dir[2])]
      if unit.dir ~= k then
        addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
      end
      updateDir(unit, k)
    end
  end
  
  local isshy = getUnitsWithEffect("shy...")
  for _,unit in ipairs(isshy) do
    if not hasProperty("folo wal") and not hasProperty("turn cornr") then
      local dpos = dirs8[unit.dir]
      local dx, dy = dpos[1], dpos[2]
      local stuff = getUnitsOnTile(unit.x+dx, unit.y+dy, nil, true, nil, nil, hasProperty(unit,"big"))
      local stuff2 = getUnitsOnTile(unit.x-dx, unit.y-dy, nil, true, nil, nil, hasProperty(unit,"big"))
      local pushfront = false
      local pushbehin = false
      for _,on in ipairs(stuff) do
        if hasProperty(on, "go away pls") and ignoreCheck(unit, on, "go away pls") then
          pushfront = true
          break
        end
      end
      if pushfront then
        for _,on in ipairs(stuff2) do
          if hasProperty(on, "go away pls") and ignoreCheck(unit, on, "go away pls") then
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
  
  doSpinRules()
  
  local folo_wall = getUnitsWithEffectAndCount("folo wal")
  for unit,amt in pairs(folo_wall) do
    local fwd = unit.dir
    local right = (((unit.dir + 2)-1)%8)+1
    local bwd = (((unit.dir + 4)-1)%8)+1
    local left = (((unit.dir + 6)-1)%8)+1
    local result = changeDirIfFree(unit, right) or changeDirIfFree(unit, fwd) or changeDirIfFree(unit, left) or changeDirIfFree(unit, bwd)
  end
  
  local turn_cornr = getUnitsWithEffectAndCount("turn cornr")
  for unit,amt in pairs(turn_cornr) do
    local fwd = unit.dir
    local right = (((unit.dir + 2)-1)%8)+1
    local bwd = (((unit.dir + 4)-1)%8)+1
    local left = (((unit.dir + 6)-1)%8)+1
    local result = changeDirIfFree(unit, fwd) or changeDirIfFree(unit, right) or changeDirIfFree(unit, left) or changeDirIfFree(unit, bwd)
  end
end

function updateUnits(undoing, big_update)
  max_layer = 1
  units_by_layer = {}
  local del_units = {}
  local will_undo = false
  
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
    
    local wins,unwins = levelBlock()
    
    --MOAR is 4-way growth, MOARx2 is 8-way growth, MOARx3 is 2x 4-way growth, MOARx4 is 2x 8-way growth, MOARx5 is 3x 4-way growth, etc.
    --TODO: If you write txt be moar, it's ambiguous which of a stacked text pair will be the one to grow into an adjacent tile first. But if you make it simultaneous, then you get double growth into corners which turns into exponential growth, which is even worse. It might need to be special cased in a clever way.
    local isgone = getUnitsWithEffect("gone")
    for _,unit in ipairs(isgone) do
      unit.destroyed = true
      unit.removed = true
    end
    deleteUnits(isgone, false, true)
    
    local give_me_moar = true
    local moar_repeats = 0
    while (give_me_moar) do
      give_me_moar = false
      local ismoar = getUnitsWithEffectAndCount("moar")
      for unit,amt in pairs(ismoar) do
        if unit.name ~= "lie/8" and timecheck(unit,"be","moar") then
          amt = amt - 2*moar_repeats
          if amt > 0 then
            if (amt % 2) == 1 then
              for i=1,4 do
                local ndir = dirs[i]
                local dx = ndir[1]
                local dy = ndir[2]
                if hasProperty(unit,"big") then
                  dx = dx*2
                  dy = dy*2
                end
                if canMove(unit, dx, dy, i*2-1, false, false, unit.name) then
                  if unit.class == "unit" then
                    local new_unit = createUnit(tiles_by_name[unit.fullname], unit.x, unit.y, unit.dir)
                    addUndo({"create", new_unit.id, false})
                    _, __, ___, x, y = getNextTile(unit, dx, dy, i*2-1, false)
                    moveUnit(new_unit,x,y)
                    addUndo({"update", new_unit.id, unit.x, unit.y, unit.dir})
                  elseif unit.class == "cursor" then
                    local others = getCursorsOnTile(unit.x + dx, unit.y + dy)
                    if #others == 0 then
                      local new_mouse = createMouse(unit.x + dx, unit.y + dy)
                      addUndo({"create_cursor", new_mouse.id})
                    end
                  end
                  give_me_moar = give_me_moar or amt >= 3
                end
              end
            else
              for i=1,8 do
                local ndir = dirs8[i]
                local dx = ndir[1]
                local dy = ndir[2]
                if hasProperty(unit,"big") then
                  dx = dx*2
                  dy = dy*2
                end
                if canMove(unit, dx, dy, i, false, false, unit.name) then
                  if unit.class == "unit" then
                    local new_unit = createUnit(tiles_by_name[unit.fullname], unit.x, unit.y, unit.dir)
                    addUndo({"create", new_unit.id, false})
                    _, __, ___, x, y = getNextTile(unit, dx, dy, i, false)
                    moveUnit(new_unit,x,y)
                    addUndo({"update", new_unit.id, unit.x, unit.y, unit.dir})
                  elseif unit.class == "cursor" then
                    local others = getCursorsOnTile(unit.x + dx, unit.y + dy)
                    if #others == 0 then
                      local new_mouse = createMouse(unit.x + dx, unit.y + dy)
                      addUndo({"create_cursor", new_mouse.id})
                    end
                  end
                  give_me_moar = give_me_moar or amt >= 3
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
    
    local nukes = getUnitsWithEffect("nuek")
    local fires = copyTable(findUnitsByName("xplod"))
    if #nukes > 0 then
      for _,nuke in ipairs(nukes) do
        local check = getUnitsOnTile(nuke.x,nuke.y,nil,nil,nil,nil,hasProperty(nuek,"big"))
        local lit = false
        for _,other in ipairs(check) do
          if other.name == "xplod" then
            lit = true
          end
        end
        if not lit then
          local new_unit = createUnit(tiles_by_name["xplod"], nuke.x, nuke.y, nuke.dir)
          new_unit.parent = nuke
          addUndo({"create", new_unit.id, false})
          if hasProperty(nuke,"big") then
            for i=1,3 do
              local _new_unit = createUnit(tiles_by_name["xplod"], nuke.x+i%2, nuke.y+math.floor(i/2), nuke.dir)
              _new_unit.parent = nuke
              addUndo({"create", _new_unit.id, false})
            end
          end
          for _,other in ipairs(check) do
            if other ~= nuke and ignoreCheck(other, nuke, "nuek") then
              table.insert(to_destroy,other)
              playSound("break")
              addParticles("destroy", other.x, other.y, {2,2})
            end
          end
        end
      end
      for _,fire in ipairs(fires) do
        if inBounds(fire.x,fire.y) and not fire.parent.removed then
          for i=1,7,2 do
            local dx = dirs8[i][1]
            local dy = dirs8[i][2]
            local lit = false
            local others = getUnitsOnTile(fire.x+dx,fire.y+dy)
            if inBounds(fire.x+dx,fire.y+dy) then
              for _,on in ipairs(others) do
                if ignoreCheck(on, fire.parent, "nuek") then
                  if on.name == "xplod" or hasProperty(on, "nuek") then
                    lit = true
                  elseif sameFloat(on,fire.parent) then
                    table.insert(to_destroy,on)
                    playSound("break")
                    addParticles("destroy", on.x, on.y, {2,2})
                  end
                end
              end
              if not lit then
                local new_unit = createUnit(tiles_by_name["xplod"], fire.x+dx, fire.y+dy, 1)
                new_unit.parent = fire.parent
                addUndo({"create", new_unit.id, false})
              end
            end
          end
        else
          table.insert(to_destroy,fire)
        end
      end
    else
      for _,fire in ipairs(fires) do
        table.insert(to_destroy,fire)
      end
    end
    
    to_destroy = handleDels(to_destroy)
    
    local split_movers = {}
    if not timeless then
      for on,unit in pairs(timeless_split) do
        addUndo({"timeless_split_remove", on, unit})
        unit = units_by_id[unit]
        on = units_by_id[on]
        if (unit ~= nil and on ~= nil) then
          table.insert(to_destroy, on)
          local dir1 = dirAdd(unit.dir,0)
          local dx1 = dirs8[dir1][1]
          local dy1 = dirs8[dir1][2]
          local dir2 = dirAdd(unit.dir,4)
          local dx2 = dirs8[dir2][1]
          local dy2 = dirs8[dir2][2]
          if canMove(on, dx1, dy1, dir1, false, false) then
            if on.class == "unit" then
              local new_unit = createUnit(tiles_by_name[on.fullname], on.x, on.y, dir1)
              addUndo({"create", new_unit.id, false})
              _, __, ___, x, y = getNextTile(on, dx1, dy1, dir1, false)
              table.insert(split_movers,{unit = new_unit, x = x, y = y, ox = on.x, oy = on.y, dir = dir1})
            elseif unit.class == "cursor" then
              local others = getCursorsOnTile(on.x + dx1, on.y + dy1)
              if #others == 0 then
                local new_mouse = createMouse(on.x + dx1, on.y + dy1)
                addUndo({"create_cursor", new_mouse.id})
              end
            end
          end
          if canMove(on, dx2, dy2, dir2, false, false) then
            if on.class == "unit" then
              local new_unit = createUnit(tiles_by_name[on.fullname], on.x, on.y, dir2)
              addUndo({"create", new_unit.id, false})
              _, __, ___, x, y = getNextTile(on, dx2, dy2, dir2, false)
              table.insert(split_movers,{unit = new_unit, x = x, y = y, ox = on.x, oy = on.y, dir = dir2})
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
      timeless_split = {}
    end
    
    --an attempt to prevent stacking split from crashing by limiting how many splits we try to do per tile. it's OK, it leads to weird traffic jams though because the rest of the units just stay still.
    local splits_per_tile = {}
    local split = getUnitsWithEffect("split")
    for _,unit in ipairs(split) do
      if unit.name ~= "lie" then
        local coords = tostring(unit.x)..","..tostring(unit.y)
        if (splits_per_tile[coords]) == nil then
          splits_per_tile[coords] = 0
        end
        if splits_per_tile[coords] < 16 then
          local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, nil, hasProperty(unit,"big"))
          for _,on in ipairs(stuff) do
            if splits_per_tile[coords] >= 16 then break end
            if unit ~= on and sameFloat(unit, on) and not on.new and ignoreCheck(on, unit, "split") then
              if timecheck(unit,"be","split") and timecheck(on) then
                local dir1 = dirAdd(unit.dir,0)
                local dx1 = dirs8[dir1][1]
                local dy1 = dirs8[dir1][2]
                local dir2 = dirAdd(unit.dir,4)
                local dx2 = dirs8[dir2][1]
                local dy2 = dirs8[dir2][2]
                if canMove(on, dx1, dy1, dir1, false, false) then
                  if on.class == "unit" then
                    splits_per_tile[coords] = splits_per_tile[coords] + 1
                    local new_unit = createUnit(tiles_by_name[on.fullname], on.x, on.y, dir1)
                    addUndo({"create", new_unit.id, false})
                    _, __, ___, x, y = getNextTile(on, dx1, dy1, dir1, false)
                    table.insert(split_movers,{unit = new_unit, x = x, y = y, ox = on.x, oy = on.y, dir = dir1})
                  elseif unit.class == "cursor" then
                    local others = getCursorsOnTile(on.x + dx1, on.y + dy1)
                    if #others == 0 then
                      local new_mouse = createMouse(on.x + dx1, on.y + dy1)
                      addUndo({"create_cursor", new_mouse.id})
                    end
                  end
                end
                if canMove(on, dx2, dy2, dir2, false, false) then
                  if on.class == "unit" then
                    splits_per_tile[coords] = splits_per_tile[coords] + 1
                    local new_unit = createUnit(tiles_by_name[on.fullname], on.x, on.y, dir2)
                    addUndo({"create", new_unit.id, false})
                    _, __, ___, x, y = getNextTile(on, dx2, dy2, dir2, false)
                    table.insert(split_movers,{unit = new_unit, x = x, y = y, ox = on.x, oy = on.y, dir = dir2})
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
                if not timeless_split[on.id] then
                  addUndo({"timeless_split_add", on.id})
                  timeless_split[on.id] = unit.id
                  addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
                end
              end
            end
          end
        end
      else
        if timecheck(unit,"be","split") then
          for i=1,8 do
            local ndir = dirs8[i]
            local dx = ndir[1]
            local dy = ndir[2]
            if canMove(unit, dx, dy, i, false, false) then
              local new_unit = createUnit(tiles_by_name["lie/8"], unit.x, unit.y, i)
              addUndo({"create", new_unit.id, false})
              _, __, ___, x, y = getNextTile(unit, dx, dy, i, false)
              moveUnit(new_unit,x,y)
              addUndo({"update", new_unit.id, unit.x, unit.y, unit.dir})
            end
          end
          table.insert(to_destroy, unit)
        end
      end
    end
    
    for _,move in ipairs(split_movers) do
      moveUnit(move.unit,move.x,move.y)
      addUndo({"update", move.unit.id, move.ox, move.oy, move.dir})
    end
    
    to_destroy = handleDels(to_destroy)
    
    local isvs = matchesRule(nil,"vs","?")
    for _,ruleparent in ipairs(isvs) do
      local unit = ruleparent[2]
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, true, hasProperty(unit,"big"))
      for _,on in ipairs(stuff) do
        if unit ~= on and hasRule(unit, "vs", on) and sameFloat(unit, on) then
          local unitmoved = false
          local onmoved = false
          for _,undo in ipairs(undo_buffer[1]) do
            if undo[1] == "update" and undo[2] == unit.id and ((undo[3] ~= unit.x) or (undo[4] ~= unit.y)) then
              unitmoved = true
            end
            if undo[1] == "update" and undo[2] == on.id and ((undo[3] ~= on.x) or (undo[4] ~= on.y)) then
              onmoved = true
            end
          end
          if unitmoved and ignoreCheck(on, unit) then
            if timecheck(unit,"vs",on) then
              table.insert(to_destroy,on)
              playSound("break")
            else
              table.insert(time_destroy,on.id)
              addUndo({"time_destroy",on.id})
            end
            addParticles("destroy", on.x, on.y, on.color)
          end
          if onmoved and ignoreCheck(unit, on) then
            if timecheck(unit,"vs",on) then
              table.insert(to_destroy,unit)
              playSound("break")
            else
              table.insert(time_destroy,unit.id)
              addUndo({"time_destroy",unit.id})
            end
            addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
          end
        end
      end
    end
    
    to_destroy = handleDels(to_destroy)
    
    local issink = getUnitsWithEffect("no swim")
    for _,unit in ipairs(issink) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, nil, hasProperty(unit,"big"))
      for _,on in ipairs(stuff) do
        if unit ~= on and sameFloat(unit, on) then
          local ignore_unit = ignoreCheck(unit, on)
          local ignore_on = ignoreCheck(on, unit, "no swim")
          if ignore_unit or ignore_on then
            if timecheck(unit,"be","no swim") and timecheck(on) then
              if ignore_unit then
                table.insert(to_destroy, unit)
              end
              if ignore_on then
                table.insert(to_destroy, on)
              end
              playSound("sink")
              shakeScreen(0.3, 0.1)
            else
              if ignore_unit then
                table.insert(time_destroy,unit.id)
                addUndo({"time_destroy",unit.id})
              end
              if ignore_on then
                table.insert(time_destroy,on.id)
                addUndo({"time_destroy",on.id})
              end
              table.insert(time_sfx,"sink")
            end
            if ignore_unit then
              addParticles("destroy", unit.x, unit.y, ignore_on and on.color or unit.color)
            else
              addParticles("destroy", on.x, on.y, on.color)
            end
          end
        end
      end
    end
    
    to_destroy = handleDels(to_destroy)
    
    local isweak = getUnitsWithEffect("ouch")
    for _,unit in ipairs(isweak) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, nil, hasProperty(unit,"big"))
      for _,on in ipairs(stuff) do
        if unit ~= on and sameFloat(unit, on) and ignoreCheck(unit, on) then
          if timecheck(unit,"be","ouch") and timecheck(on) then
            table.insert(to_destroy, unit)
            playSound("break")
            shakeScreen(0.3, 0.1)
          else
            table.insert(time_destroy,unit.id)
						addUndo({"time_destroy",unit.id})
            table.insert(time_sfx,"break")
          end
          addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
        end
      end
    end
    
    to_destroy = handleDels(to_destroy)
    
    local ishot = getUnitsWithEffect("hotte")
    for _,unit in ipairs(ishot) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, nil, hasProperty(unit,"big"))
      for _,on in ipairs(stuff) do
        if hasProperty(on, "fridgd") and sameFloat(unit, on) and ignoreCheck(on, unit, "hotte") then
          if timecheck(unit,"be","hotte") and timecheck(on,"be","fridgd") then
            table.insert(to_destroy, on)
            playSound("hotte")
            shakeScreen(0.3, 0.1)
          else
            table.insert(time_destroy,on.id)
						addUndo({"time_destroy",on.id})
            table.insert(time_sfx,"hotte")
          end
          addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
        end
      end
    end
    
    to_destroy = handleDels(to_destroy)
    
    local isdefeat = getUnitsWithEffect(":(")
    for _,unit in ipairs(isdefeat) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, nil, hasProperty(unit,"big"))
      for _,on in ipairs(stuff) do
        if hasU(on) and sameFloat(unit, on) and ignoreCheck(on, unit, ":(") then
          if timecheck(unit,"be",":(") and (timecheckUs(on)) then
            table.insert(to_destroy, on)
            playSound("break")
            shakeScreen(0.3, 0.2)
          else
            table.insert(time_destroy,on.id)
						addUndo({"time_destroy",on.id})
            table.insert(time_sfx,"break")
          end
          addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
        end
      end
    end
    
    to_destroy = handleDels(to_destroy)
    
    local isshut = getUnitsWithEffect("ned kee")
    for _,unit in ipairs(isshut) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, nil, hasProperty(unit,"big"))
      for _,on in ipairs(stuff) do
        if hasProperty(on, "for dor") and sameFloat(unit, on) then
          local ignore_unit = ignoreCheck(unit, on, "for dor")
          local ignore_on = ignoreCheck(on, unit, "ned kee")
          if ignore_unit or ignore_on then
            if timecheck(unit,"be","ned kee") and timecheck(on,"be","for dor") then
              if ignore_unit then
                table.insert(to_destroy, unit)
              end
              if ignore_on then
                table.insert(to_destroy, on)
              end
              playSound("break")
              playSound("unlock")
              shakeScreen(0.3, 0.1)
            else
              if ignore_unit then
                table.insert(time_destroy,unit.id)
                addUndo({"time_destroy",unit.id})
              end
              if ignore_on then
                table.insert(time_destroy,on.id)
                addUndo({"time_destroy",on.id})
              end
              table.insert(time_sfx,"break")
              table.insert(time_sfx,"unlock")
            end
            if ignore_unit then
              addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
            end
            if ignore_on then
              addParticles("destroy", on.x, on.y, on.color)
            end
            --unlike other destruction effects, keys and doors pair off one-by-one
            to_destroy = handleDels(to_destroy)
            break
          end
        end
      end
    end
    
    local issnacc = matchesRule(nil, "snacc", "?")
    for _,ruleparent in ipairs(issnacc) do
      local unit = ruleparent[2]
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, true, hasProperty(unit,"big"))
      for _,on in ipairs(stuff) do
        if unit ~= on and hasRule(unit, "snacc", on) and sameFloat(unit, on) and ignoreCheck(on, unit) then
          if timecheck(unit,"snacc",on) and timecheck(on) then
            table.insert(to_destroy, on)
            playSound("snacc")
            shakeScreen(0.3, 0.15)
          else
            table.insert(time_destroy,on.id)
						addUndo({"time_destroy",on.id})
            table.insert(time_sfx,"snacc")
          end
          addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
        end
      end
    end
    
    local isreset = getUnitsWithEffect("try again")
    for _,unit in ipairs(isreset) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, nil, hasProperty(unit,"big"))
      for _,on in ipairs(stuff) do
        if hasU(on) and sameFloat(unit, on) and ignoreCheck(on, unit, "try again") then
          if timecheck(unit,"be","try again") and (timecheckUs(on)) then
            will_undo = true
            break
          else
            addUndo({"timeless_reset_add"})
            timeless_reset = true
            addParticles("bonus", unit.x, unit.y, unit.color_override or unit.color)
          end
        end
      end
    end
    
    to_destroy = handleDels(to_destroy)
    
    local iscrash = matchesRule(nil,"be","xwx")
    for _,ruleparent in ipairs(iscrash) do
      local unit = ruleparent[2]
      if not hasProperty(ruleparent[1].rule.object,"slep") then
        local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, nil, hasProperty(unit,"big"))
        for _,on in ipairs(stuff) do
          if hasU(on) and sameFloat(unit, on) and ignoreCheck(on, unit, "xwx") then
            if timecheck(unit,"be","xwx") and (timecheckUs(on)) then
              doXWX()
            else
              addUndo({"timeless_crash_add"})
              timeless_crash = true
              addParticles("bonus", unit.x, unit.y, unit.color_override or unit.color)
            end
          end
        end
      end
    end
    
    to_destroy = handleDels(to_destroy)
    
    local isbonus = getUnitsWithEffect(":o")
    for _,unit in ipairs(isbonus) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, nil, hasProperty(unit,"big"))
      for _,on in ipairs(stuff) do
        if hasU(on) and sameFloat(unit, on) and ignoreCheck(on, unit, ":o") then
          writeSaveFile(true, {"levels", level_filename, "bonus"})
          if timecheck(unit,"be",":o") and (timecheckUs(on)) then
            table.insert(to_destroy, unit)
            playSound("bonus")
          else
            table.insert(time_destroy,unit.id)
						addUndo({"time_destroy",unit.id})
            table.insert(time_sfx,"bonus")
          end
          addParticles("bonus", unit.x, unit.y, unit.color_override or unit.color)
        end
      end
    end
    
    to_destroy = handleDels(to_destroy)
    
    local isunwin = getUnitsWithEffect(";d")
    for _,unit in ipairs(isunwin) do
      local stuff = getUnitsOnTile(unit.x,unit.y, nil, true, nil, nil, hasProperty(unit,"big"))
      for _,on in ipairs(stuff) do
        if hasU(on) and sameFloat(unit, on) and ignoreCheck(on, unit, ";d") then
          if timecheck(unit,"be","d") and (timecheckUs(on)) then
            unwins = unwins + 1
          else
            addUndo({"timeless_unwin_add", on.id})
            table.insert(timeless_unwin,on.id)
            addParticles("bonus", unit.x, unit.y, unit.color_override or unit.color)
          end
        end
      end
    end
    
    local iswin = getUnitsWithEffect(":)")
    for _,unit in ipairs(iswin) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, nil, hasProperty(unit,"big"))
      for _,on in ipairs(stuff) do
        if hasU(on) and sameFloat(unit, on) and ignoreCheck(on, unit, ":)") then
          if timecheck(unit,"be",":)") and (timecheckUs(on)) then
            wins = wins + 1
          else
            addUndo({"timeless_win_add", on.id})
            table.insert(timeless_win,on.id)
            addParticles("bonus", unit.x, unit.y, unit.color_override or unit.color)
          end
        end
      end
    end
    
    local issoko = matchesRule(nil,"soko","?")
    local sokowins = {}
    for _,ruleparent in ipairs(issoko) do
      local unit = ruleparent[2]
      if sokowins[unit] == nil then
        sokowins[unit] = true
      end
      local others = findUnitsByName(ruleparent[1].rule.object.name)
      local fail = false
      if #others > 0 then
        for _,other in ipairs(others) do
          local ons = getUnitsOnTile(other.x,other.y,nil,nil,other,nil,hasProperty(unit,"big"))
          local innersuccess = false
          for _,on in ipairs(ons) do
            if sameFloat(other,on) and ignoreCheck(other,on) then
              innersuccess = true
            end
          end
          if not innersuccess then
            fail = true
          end
        end
      end
      if fail then
        sokowins[unit] = false
      end
    end
    for unit,v in pairs(sokowins) do
      if v then
        local stuff = getUnitsOnTile(unit.x,unit.y,nil,nil,nil,nil,hasProperty(unit,"big"))
        for _,on in ipairs(stuff) do
          if hasU(on) and sameFloat(unit,on) and ignoreCheck(on,unit) then
            wins = wins + 1
          end
        end
      end
    end

    function doOneCreate(rule, creator, createe)
      local object = createe
      if (createe == "text") then
        createe = "text_"..creator.fullname
      end
      
      local tile = tiles_by_namePossiblyMeta(createe)
      --let x ben't x txt prevent x be txt, and x ben't txt prevent x be y txt
      local overriden = false;
      if object == "text" then
        overriden = hasRule(creator, "creatn't", "text_" .. creator.fullname)
      elseif object:starts("text_") then
        overriden = hasRule(creator, "creatn't", "text")
      end
      if tile ~= nil and not overriden then
        local others = getUnitsOnTile(creator.x, creator.y, createe, true, nil, nil, nil, hasProperty(unit,"big"))
        if #others == 0 then
          local color = rule.object.prefix
          if color == "samepaint" then
            if creator.color_override then
              color = colour_for_palette[creator.color_override[1]][creator.color_override[2]]
            else
              if type(color[1]) == "table" then
                color = colour_for_palette[creator.color[1][1]][creator.color[1][2]]
              else
                color = colour_for_palette[creator.color[1]][creator.color[2]]
              end
            end
          end
          local new_unit = createUnit(tile, creator.x, creator.y, creator.dir, nil, nil, nil, color)
          addUndo({"create", new_unit.id, false})
        end
      elseif createe == "mous" then
        local new_mouse = createMouse(creator.x, creator.y)
        addUndo({"create_cursor", new_mouse.id})
      end
    end
    
    local creators = matchesRule(nil, "creat", "?")
    for _,match in ipairs(creators) do
      local creator = match[2]
      local createe = match[1].rule.object.name
      if timecheck(creator,"creat",createe) then
        if (group_names_set[createe] ~= nil) then
          for _,v in ipairs(namesInGroup(createe)) do
            doOneCreate(match[1].rule, creator, v)
          end
        else
          doOneCreate(match[1].rule, creator, createe)
        end
      end
    end
    
    if not timeless then
      wins = wins + #timeless_win
      unwins = unwins + #timeless_unwin
      for i,win in ipairs(timeless_win) do
        addUndo("timeless_win_remove",win)
        table.remove(timeless_win,i)
      end
      for i,unwin in ipairs(timeless_unwin) do
        addUndo("timeless_unwin_remove",unwin)
        table.remove(timeless_unwin,i)
      end
    end
    
    if wins > unwins then
      doWin("won")
    elseif unwins > wins then
      doWin("won", false)
    end
    
    doDirRules()
  end
  
  DoDiscordRichPresence()
  
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
  if (big_update and not undoing) then
    local backed_this_turn = {}
    local not_backed_this_turn = {}
    
    local isback = getUnitsWithEffectAndCount("undo")
    if hasProperty(outerlvl, "undo") then
      for _,unit in ipairs(units) do
        if isback[unit] then
          isback[unit] = isback[unit] + 1
        else
          isback[unit] = 1
        end
      end
    end
    for unit,amt in pairs(isback) do
      backed_this_turn[unit] = true
    end
    
    for unit,turn in pairs(backers_cache) do
      if turn ~= nil and not backed_this_turn[unit] then
        not_backed_this_turn[unit] = true
      end
    end
    
    for unit,_ in pairs(not_backed_this_turn) do
      --print("oh no longer a backer huh, neat", unit.fullname)
      addUndo({"backer_turn", unit.id, unit.backer_turn})
      unit.backer_turn = nil
      backers_cache[unit] = nil
    end
  end
  
  if (will_undo) or (timeless_reset and not timeless) then
    addUndo({"timeless_reset_remove"})
    timeless_reset = false
    doTryAgain()
  end
  
  if timeless_crash and not timeless then
    addUndo({"timeless_crash_remove"})
    love = {}
  end
end

function miscUpdates()
  updateGraphicalPropertyCache()
  
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
      unit.sprite = deepCopy(tiles_list[unit.tile].sprite)
      
      if unit.fullname == "boooo" then
        if hasProperty(unit,"shy...") then
          unit.sprite = {"boooo_shy","boooo_mouth_shy","boooo_blush"}
        elseif graphical_property_cache["slep"][unit] ~= nil then
          unit.sprite = {"boooo_slep","boooo_mouth_slep"}
        else
          unit.sprite = {"boooo","boooo_mouth"}
        end
      end
      
      if unit.fullname == "casete" then
        if unit.color_override then
          local color = colour_for_palette[unit.color_override[1]][unit.color_override[2]]
          if color == "bleu" or color == "cyeann" then
            unit.sprite = "casete_bleu"
          elseif color == "reed" or color == "pinc" then
            unit.sprite = "casete_pinc"
          elseif color == "orang" or color == "yello" then
            unit.sprite = "casete_yello"
          elseif color == "grun" then
            unit.sprite = "casete_grun"
          else
            unit.sprite = "casete_wut"
          end
        else
          unit.sprite = "casete_wut"
        end
        if not hasProperty(unit,"no go") then
          unit.sprite = unit.sprite.."_sunk"
        end
      end
      
      if unit.fullname == "bolble" then
        if unit.color_override then
          local color = colour_for_palette[unit.color_override[1]][unit.color_override[2]]
          if color == "whit" then
            unit.sprite = "bolble_snow"
          elseif color == "bleu" then
            unit.sprite = "bolble_waves"
          elseif color == "cyeann" then
            unit.sprite = "bolble_12"
          elseif color == "purp" then
            unit.sprite = "bolble_clock"
          elseif color == "brwn" then
            unit.sprite = "bolble_choco"
          elseif color == "blacc" then
            unit.sprite = "bolble_twirl"
          elseif color == "graey" then
            unit.sprite = "bolble_checker"
          elseif color == "orang" then
            unit.sprite = "bolble_dots"
          elseif color == "pinc" then
            unit.sprite = "bolble_hearts"
          elseif color == "yello" then
            unit.sprite = "bolble_stars"
          elseif color == "grun" then
            unit.sprite = "bolble_tree"
          else
            unit.sprite = "bolble"
          end
        end
      end
      
      if unit.fullname == "ches" then
        if hasProperty(unit,"ned kee") then
          unit.sprite = "chest_close"
        else
          unit.sprite = "chest_open"
        end
      end
      
      if unit.fullname == "mimi" then
        if graphical_property_cache["slep"][unit] ~= nil then
          unit.sprite = "mimic_sleep"
        elseif hasProperty(unit,"ned kee") then
          unit.sprite = "mimic_close"
        else
          unit.sprite = "mimic_open"
        end
      end
      
      if unit.fullname == "pumkin" then
        if hasProperty(unit,"sans") or hasProperty(unit,":(") or hasProperty(unit,"brite") or hasProperty(unit,"torc") or hasRule(unit,"spoop","?") then
          if graphical_property_cache["slep"][unit] ~= nil then
            unit.sprite = "pumkin_slep"
          else
            unit.sprite = "pumkin_jack"
          end
        else
          unit.sprite = "pumkin"
        end
      end
      
      -- here goes the legendary ditto transformations
      if unit.fullname == "ditto" then
        if hasProperty(unit,"dragbl") then
          unit.sprite = "ditto_dragbl"
        elseif hasProperty(unit,"notranform") then
          unit.sprite = "ditto_notranform"
        elseif hasRule(unit,"got","which") then
          unit.sprite = "ditto_which"
        elseif hasRule(unit,"spoop","?") then
          unit.sprite = "ditto_spoop"
        elseif hasProperty(unit,"xwx") then
          unit.sprite = "ditto_xwx"
        elseif hasProperty(unit,"rong") then
          unit.sprite = "ditto_rong"
        elseif hasProperty(unit,"wurd") then
          unit.sprite = "ditto_wurd"
        elseif hasProperty(unit,"no drag") then
          unit.sprite = "ditto_no drag"
        elseif graphical_property_cache["slep"][unit] ~= nil then
          unit.sprite = "ditto_slep"
        elseif hasProperty(unit,"rithere") then
          unit.sprite = "ditto_rithere"
        elseif hasProperty(unit,"thr") then
          unit.sprite = "ditto_thr"
        elseif hasProperty(unit,"stelth") then
          unit.sprite = "ditto_stelth"
        elseif hasProperty(unit,"sans") then
          unit.sprite = "ditto_sans"
        elseif hasProperty(unit,"ouch") then
          unit.sprite = "ditto_ouch"
        elseif hasProperty(unit,"protecc") then
          unit.sprite = "ditto_protecc"
        elseif hasProperty(unit,"no undo") then
          unit.sprite = "ditto_no undo"
        -- Eeveelutions
        elseif hasProperty(unit,"qt") then
          if hasProperty(unit,"icy") then
            unit.sprite = "ditto_qt_icy"
          elseif hasProperty(unit,"hopovr") then
            unit.sprite = "ditto_qt_hopovr"
          else
            unit.sprite = "ditto_qt"
          end
        elseif hasProperty(unit,"poor toll") then
          unit.sprite = "ditto_poor toll"
        -- Rotom formes
        elseif hasProperty(unit,"zip") then
          unit.sprite = "ditto_zip"
        elseif hasRule(unit,"sing","?") then
          unit.sprite = "ditto_sing"
        elseif hasRule(unit,"paint","?") then
          unit.sprite = "ditto_paint"
        elseif hasRule(unit,"got","sant") then
          unit.sprite = "ditto_sant"
        elseif hasProperty(unit,"go") then
          unit.sprite = "ditto_go"
        elseif hasProperty(unit,"folo wal") then
          unit.sprite = "ditto_folo wal"
        elseif hasProperty(unit,"tall") then
          unit.sprite = "ditto_tall"
        elseif hasProperty(unit,"rave") then
          unit.sprite = "ditto_rave"
        elseif hasProperty(unit,"colrful") then
          unit.sprite = "ditto_colrful"
        elseif hasProperty(unit,"torc") then
          unit.sprite = "ditto_torc"
        elseif hasProperty(unit,"split") then
          unit.sprite = "ditto_split"
        elseif hasProperty(unit,"icyyyy") then
          unit.sprite = "ditto_icyyyy"
        elseif hasProperty(unit,"icy") then
          unit.sprite = "ditto_icy"
        elseif hasProperty(unit,"hopovr") then
          unit.sprite = "ditto_hopovr"
        elseif hasProperty(unit,"right") or hasProperty(unit,"downright") or hasProperty(unit,"down") or hasProperty(unit,"downleft") or hasProperty(unit,"left") or hasProperty(unit,"upleft") or hasProperty(unit,"up") or hasProperty(unit,"upright") then
          unit.sprite = "ditto_direction"
        elseif hasProperty(unit,"nuek") then
          unit.sprite = "ditto_nuek"
        elseif hasProperty(unit,";d") then
          unit.sprite = "ditto_;d"
        elseif hasProperty(unit,"knightstep") then
          unit.sprite = "ditto_knightstep"
        elseif hasProperty(unit,"diagstep") then
          unit.sprite = "ditto_diagstep"
        elseif hasProperty(unit,"sidestep") then
          unit.sprite = "ditto_sidestep"
        elseif hasProperty(unit,"munwalk") then
          unit.sprite = "ditto_munwalk"
        elseif hasProperty(unit,"visit fren") then
          unit.sprite = "ditto_visit fren"
        elseif hasProperty(unit,"walk") then
          unit.sprite = "ditto_walk"
        elseif hasProperty(unit,"no swim") then
          unit.sprite = "ditto_no swim"
        elseif hasProperty(unit,"haet flor") then
          unit.sprite = "ditto_haet flor"
        elseif hasProperty(unit,"haet skye") then
          unit.sprite = "ditto_haet skye"
        elseif hasRule(unit,"got","gunne") then
          unit.sprite = "ditto_gunne"
        elseif hasProperty(unit,"glued") then
          unit.sprite = "ditto_glued"
        elseif hasProperty(unit,"flye") then
          unit.sprite = "ditto_flye"
        elseif hasProperty(unit,"enby") then
          unit.sprite = "ditto_enby"
        elseif hasProperty(unit,"tranz") then
          unit.sprite = "ditto_tranz"
        elseif hasProperty(unit,"come pls") then
          unit.sprite = "ditto_come pls"
        elseif hasProperty(unit,"go away pls") then
          unit.sprite = "ditto_go away pls"
        elseif hasProperty(unit,"goooo") then
          unit.sprite = "ditto_goooo"
        elseif hasRule(unit,"snacc","?") then
          unit.sprite = "ditto_snacc"
        elseif hasProperty(unit,"moar") then
          unit.sprite = "ditto_moar"
        elseif hasProperty(unit,"ned kee") then
          unit.sprite = "ditto_ned kee"
        elseif hasProperty(unit,"for dor") then
          unit.sprite = "ditto_fordor"
        elseif hasProperty(unit,"hotte") then
          unit.sprite = "ditto_hotte"
        elseif hasProperty(unit,"fridgd") then
          unit.sprite = "ditto_fridgd"
        elseif hasProperty(unit,":)") then
          unit.sprite = "ditto_yay"
        elseif hasProperty(unit,":o") then
          unit.sprite = "ditto_whoa"
        elseif hasProperty(unit,"no go") then
          unit.sprite = "ditto_no go"
        elseif hasProperty(unit,"y'all") then
          unit.sprite = "ditto_y'all"
        elseif hasProperty(unit,"u tres") then
          unit.sprite = "ditto_u tres"
        elseif hasProperty(unit,"u too") then
          unit.sprite = "ditto_u too"
        elseif hasProperty(unit,"u") then
          unit.sprite = "ditto_u"
        elseif hasProperty(unit,"thingify") then
          unit.sprite = "ditto_thingify"
        else
          unit.sprite = "ditto"
        end
      end
      
      if unit.fullname == "fube" then
        if hasProperty(unit,"haet skye") or hasProperty(unit,"haet flor") or hasRule(unit,"yeet","?") or hasRule(unit,"moov","?") then
          unit.sprite = {"fube_cube","fube_arrow"}
        else
          unit.sprite = {"fube_arrow","fube_cube"}
        end
      end
      
      if unit.fullname == "bup" then
        if hasProperty(unit,"torc") then
          unit.sprite = {"bup","bup_band","bup_capn","bup_light"}
        else
          unit.sprite = {"bup","no1","no1","no1"}
        end
        if graphical_property_cache["slep"][unit] ~= nil then
          unit.sprite[1] = "bup_slep"
        end
      end
      
      if unit.fullname == "die" and (first_turn or not (hasProperty(unit,"stukc") or hasProperty(unit,"no turn"))) then
        local roll = math.random(6)
        unit.sprite[2] = "die_"..roll
      end

      if unit.fullname == "text_katany" then
        unit.sprite = "text_katany"
        if rules_with_unit[unit] then
          for _,rules in ipairs(rules_with_unit[unit]) do
            if rules.rule.object.unit == unit then
              local tile_id = tiles_by_name[rules.rule.subject.name]
              if tile_id then
                local tile = tiles_list[tile_id]
                if tile.features and tile.features.katany and tile.features.katany.nya then
                  unit.sprite = "text_katanya"
                end
              end
            end
          end
        end
      end
      
      if unit.name == "byc" and scene ~= editor then -- playing cards
        if not card_for_id[unit.id] then
          card_for_id[unit.id] = {math.random(13), ({"spade","heart","clubs","diamond"})[math.random(4)]}
        end
        local num, suit = unpack(card_for_id[unit.id])
        print("a")
        unit.sprite[2] = "byc_"..num
        unit.sprite[3] = "byc_"..suit
        if suit == "spade" or suit == "clubs" then
          unit.color = {{0, 3}, {0, 0}, {0, 0}}
          unit.colored = {{0, 0}, false, false}
        end
      end
      
      for type,name in pairs(unit.sprite_transforms) do
        if table.has_value(unit.used_as, type) then
          unit.sprite = name
          break
        end
      end
      
      if graphical_property_cache["slep"][unit] ~= nil then
        if type(unit.sprite) == "table" then
          for j,name in ipairs(unit.sprite) do
            if sprites[name.."_slep"] then
              unit.sprite[j] = name.."_slep"
            end
          end
        elseif sprites[unit.sprite.."_slep"] then
          unit.sprite = unit.sprite.."_slep"
          if unit.fullname == "detox" then
            unit.color = {1,2}
          end
        end
      else
        if unit.fullname == "detox" then
          unit.color = {2,4}
        end
      end

      unit.overlay = {}
      if (graphical_property_cache["enby"][unit] ~= nil) then
        table.insert(unit.overlay, "enby")
      end
      if (graphical_property_cache["tranz"][unit] ~= nil) and not hasProperty(unit,"notranform") then
        table.insert(unit.overlay, "trans")
      end
      if (graphical_property_cache["gay"][unit] ~= nil) then
        table.insert(unit.overlay, "gay")
      end
      
      -- for optimisation in drawing
      local objects_to_check = {
      "stelth", "colrful", "xwx", "rave", "gay", "tranz", "enby"
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
  
  mergeTable(still_converting, still_gone)

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
    local count = prop == "flye"
    new_tbl = {}
    if (count) then
      local isprop = getUnitsWithEffectAndCount(prop)
      for unit,amt in pairs(isprop) do
        new_tbl[unit] = unit.fullname ~= "selctr" and amt or nil
      end
    else
      local isprop = getUnitsWithEffect(prop)
      for _,unit in pairs(isprop) do
        new_tbl[unit] = true
      end
    end
    graphical_property_cache[prop] = new_tbl
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
        addUndo({"colour_change", unit.id, colour, true})
        unit[colour] = false
        to_update[unit] = {}
      end
      --If a unit ben't its native colour, make it blacc.
      if palette[1] == tiles_list[unit.tile].color[1] and palette[2] == tiles_list[unit.tile].color[2]  and unitNotRecoloured(unit) then
        addUndo({"colour_change", unit.id, "blacc", false})
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
    local stuff = getUnitsOnTile(unit.x, unit.y, nil, true, nil, true, hasProperty(unit,"big"))
    for _,on in ipairs(stuff) do
      if unit ~= on and hasRule(unit, "paint", on) and sameFloat(unit, on) and ignoreCheck(on, unit, "paint") then
        if timecheck(unit,"paint",on) and timecheck(on) then
          local old_colour = unit.color_override or unit.color
          local colour = colour_for_palette[old_colour[1]][old_colour[2]]
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
    unitUnsetColours(unit)
    to_update[unit] = {}
  end
  
  for unit,colours in pairs(to_update) do
    unitUnsetColours(unit)
    for _,colour in ipairs(colours) do
      if (unit[colour] ~= true) then
        addUndo({"colour_change", unit.id, colour, false})
        unit[colour] = true
      end
    end
    updateUnitColourOverride(unit)
  end
end

function unitUnsetColours(unit)
  for colour,palette in pairs(main_palette_for_colour) do
    if unit[colour] == true then
      addUndo({"colour_change", unit.id, colour, true})
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
  if unit.pinc or (unit.reed and unit.whit) then -- pink
    unit.color_override = {4, 1}
  elseif unit.purp or (unit.reed and unit.bleu) then -- purple
    unit.color_override = {3, 1}
  elseif unit.yello or (unit.reed and unit.grun) then -- yellow
    unit.color_override = {2, 4}
  elseif unit.orang or (unit.reed and unit.yello) then -- orange
      unit.color_override = {2, 3}
  elseif unit.cyeann or (unit.bleu and unit.grun) then -- cyan
    unit.color_override = {1, 4}
  elseif unit.brwn or (unit.orang and unit.blacc) then -- brown
    unit.color_override = {6, 0}
  elseif unit.reed then -- red
    unit.color_override = {2, 2}
  elseif unit.bleu then -- blue
    unit.color_override = {1, 3}
  elseif unit.grun then -- green
    unit.color_override = {5, 2}
  elseif unit.graey or (unit.blacc and unit.whit) then -- grey
    unit.color_override = {0, 1}
  elseif unit.whit or (unit.reed and unit.grun and unit.bleu) or (unit.reed and unit.cyeann) or (unit.bleu and unit.yello) or (unit.grun and unit.purp) then -- white
    unit.color_override = {0, 3}
  elseif unit.blacc then -- black
    unit.color_override = {0, 0}
  end
end

function updatePortals()
  for i,unit in ipairs(units) do
    if unit.is_portal and hasProperty(unit, "poor toll") then
      local px, py, move_dir, dir = doPortal(unit, unit.x, unit.y, rotate8(unit.dir), rotate8(unit.dir), true)
      unit.portal.x, unit.portal.y = px, py
      local portal_objects = getUnitsOnTile(px, py, nil, true, nil, nil, hasProperty(unit,"big"))
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
    local isu = getUnitsWithEffect("u")
    if (#isu > 0) then
      local unit = isu[1]
      if love.filesystem.read("author_name") == "jill" or unit.fullname == "jill" then
        presence["smallImageText"] = "jill"
        presence["smallImageKey"] = "jill"
      elseif love.filesystem.read("author_name") == "fox" or unit.fullname == "o" then
        presence["smallImageText"] = "o"
        presence["smallImageKey"] = "o"
      elseif unit.fullname == "bab" or unit.fullname == "keek" or unit.fullname == "meem" or unit.fullname == "bup" then
        presence["smallImageText"] = unit.fullname
        presence["smallImageKey"] = unit.fullname
      elseif unit.type == "text" then
        presence["smallImageKey"] = "txt"
        presence["smallImageText"] = unit.name
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
    else
      presence["smallImageText"] = "nothing :("
      presence["smallImageKey"] = "nothing"
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
  local already_added = {}
  for _,unitid in ipairs(time_destroy) do
    if unitid > 0 then
      unit = units_by_id[unitid]
    else
      unit = cursors_by_id[unitid]
    end
    addUndo({"time_destroy_remove", unitid})
    if unit ~= nil and not hasProperty(unit, "protecc") then
      if not already_added[unitid] then
        addParticles("destroy",unit.x,unit.y,unit.color)
      end
      unit.destroyed = true
      unit.removed = true
      table.insert(del_units,unit)
      already_added[unitid] = true
      for i,win in ipairs(timeless_win) do
        if unit.id == win then
          addUndo({"timeless_win_remove", win})
          table.remove(timeless_win,i)
        end
      end
      for i,unwin in ipairs(timeless_unwin) do
        if unit.id == unwin then
          addUndo({"timeless_unwin_remove", unwin})
          table.remove(timeless_unwin,i)
        end
      end
      for split,_ in pairs(timeless_split) do
        if unit.id == split then
          addUndo({"timeless_split_remove", split})
          timeless_split[split] = nil
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
  
  if hasProperty(outerlvl,"notranform") then
    writeSaveFile(nil, {"levels", level_filename, "transform"})
  end
  
  if hasProperty(outerlvl, "loop") then
    destroyLevel("infloop")
  end
  
  if hasProperty(outerlvl, "visit fren") then
    for _,unit in ipairs(units) do
      if sameFloat(unit,outerlvl) and inBounds(unit.x,unit.y) and ignoreCheck(unit,outerlvl,"visit fren") then
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
        --random version for fun
        --[[
        local tx,ty = math.random(0,mapwidth-1),math.random(0,mapheight-1)
        moveUnit(unit,tx,ty)
        ]]
      end
    end
  end
  
  if hasProperty(outerlvl, "nuek") then
    for _,unit in ipairs(units) do
      if sameFloat(unit, outerlvl) and inBounds(unit.x,unit.y) and ignoreCheck(unit,outerlvl,"nuek") then
        table.insert(to_destroy, unit)
        addParticles("destroy", unit.x, unit.y, {2,2})
      end
    end
  end
  
  to_destroy = handleDels(to_destroy)
  
  local isvs = matchesRule(nil,"vs",outerlvl)
  mergeTable(isvs,matchesRule(outerlvl,"vs",nil))
  for _,ruleparent in ipairs(isvs) do
    local unit = ruleparent[2]
    if unit ~= outerlvl and sameFloat(outerlvl,unit) and inBounds(unit.x,unit.y) then
      local unitmoved = false
      for _,undo in ipairs(undo_buffer[1]) do
        if undo[1] == "update" and undo[2] == unit.id and ((undo[3] ~= unit.x) or (undo[4] ~= unit.y)) then
          unitmoved = true
        end
      end
      if unitmoved and ignoreCheck(outerlvl, unit) then
        destroyLevel("vs")
        if not lvlsafe then return 0,0 end
      end
    end
  end
  
  if hasProperty(outerlvl, "no swim") then
    for _,unit in ipairs(units) do
      if sameFloat(unit, outerlvl) and inBounds(unit.x,unit.y) then
        if ignoreCheck(outerlvl, unit) then
          destroyLevel("sink")
          if not lvlsafe then return 0,0 end
        elseif ignoreCheck(unit, outerlvl, "no swim") then
          table.insert(to_destroy, unit)
          addParticles("destroy", unit.x, unit.y, unit.color)
        end
      end
    end
    if #to_destroy > 0 then
      playSound("sink")
      shakeScreen(0.3, 0.1)
    end
  end

  to_destroy = handleDels(to_destroy)
  
  if hasProperty(outerlvl, "ouch") then
    for _,unit in ipairs(units) do
      if sameFloat(unit, outerlvl) and inBounds(unit.x,unit.y) and ignoreCheck(outerlvl, unit) then
        destroyLevel("snacc")
        if not lvlsafe then return 0,0 end
      end
    end
  end
  
  if hasProperty(outerlvl, "hotte") then
    local melters = getUnitsWithEffect("fridgd")
    for _,unit in ipairs(melters) do
      if sameFloat(unit,outerlvl) and inBounds(unit.x,unit.y) and ignoreCheck(unit,outerlvl,"hotte") then
        table.insert(to_destroy, unit)
        addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
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
      if not lvlsafe then return 0,0 end
    end
    local melters = getUnitsWithEffect("hotte")
    for _,unit in ipairs(melters) do
      if sameFloat(unit,outerlvl) and inBounds(unit.x,unit.y) and ignoreCheck(outerlvl,unit,"hotte") then
        destroyLevel("hotte")
        if not lvlsafe then return 0,0 end
      end
    end
  end
  
  if hasProperty(outerlvl, ":(") then
    local yous = getUs()
    for _,unit in ipairs(yous) do
      if sameFloat(unit,outerlvl) and inBounds(unit.x,unit.y) and ignoreCheck(unit,outerlvl,":(") then
        table.insert(to_destroy, unit)
        addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
      end
    end
  end
  
  to_destroy = handleDels(to_destroy)
  
  if hasProperty(outerlvl, "ned kee") then
    if hasProperty(outerlvl, "for dor") then
      destroyLevel("unlock")
      if not lvlsafe then return 0,0 end
    end
    local dors = getUnitsWithEffect("for dor")
    for _,unit in ipairs(dors) do
      if sameFloat(unit,outerlvl) and inBounds(unit.x,unit.y) then
        if ignoreCheck(outerlvl,unit,"for dor") then
          destroyLevel("unlock")
        end
        if lvlsafe then
          if ignoreCheck(unit,outerlvl,"ned kee") then
            table.insert(to_destroy, unit)
            addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
          end
        else return 0,0 end
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
      if sameFloat(unit,outerlvl) and inBounds(unit.x,unit.y) then
        if ignoreCheck(outerlvl,unit,"ned kee") then
          destroyLevel("unlock")
        end
        if lvlsafe then
          if ignoreCheck(unit,outerlvl,"for dor") then
            table.insert(to_destroy, unit)
            addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
          end
        else return 0,0 end
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
    if unit ~= outerlvl and sameFloat(outerlvl,unit) and inBounds(unit.x,unit.y) and ignoreCheck(unit,outerlvl) then
      addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
      table.insert(to_destroy, unit)
    end
  end
  
  local issnacc = matchesRule(nil,"snacc",outerlvl)
  for _,ruleparent in ipairs(issnacc) do
    local unit = ruleparent[2]
    if unit ~= outerlvl and sameFloat(outerlvl,unit) and inBounds(unit.x,unit.y) and ignoreCheck(outerlvl,unit) then
      destroyLevel("snacc")
      if not lvlsafe then return 0,0 end
    end
  end
  
  if #to_destroy > 0 then
    playSound("snacc")
    shakeScreen(0.3, 0.1)
  end
  
  to_destroy = handleDels(to_destroy)
  
  local will_undo = false
  if hasProperty(outerlvl, "try again") then
    local yous = getUs()
    for _,unit in ipairs(yous) do
      if sameFloat(unit,outerlvl) and inBounds(unit.x,unit.y) and ignoreCheck(unit,outerlvl,"try again") then
        doTryAgain()
      end
    end
  end
  
  if hasProperty(outerlvl, "xwx") then
    local yous = getUs()
    for _,unit in ipairs(yous) do
      if sameFloat(unit,outerlvl) and inBounds(unit.x,unit.y) and ignoreCheck(unit,outerlvl,"xwx") then
        doXWX()
      end
    end
  end
  
  if hasProperty(outerlvl, ":o") then
    local yous = getUs()
    for _,unit in ipairs(yous) do
      if sameFloat(unit,outerlvl) and inBounds(unit.x,unit.y) and ignoreCheck(outerlvl,unit) then
        writeSaveFile(true, {"levels", level_filename, "bonus"})
        destroyLevel("bonus")
        if not lvlsafe then return 0,0 end
      end
    end
  end
  
  local unwins = 0
  if hasProperty(outerlvl, ";d") then
    local yous = getUs()
    for _,unit in ipairs(yous) do
      if sameFloat(unit,outerlvl) and inBounds(unit.x,unit.y) and ignoreCheck(unit,outerlvl,";d") then
        unwins = unwins + 1
      end
    end
  end
  
  local wins = 0
  if hasProperty(outerlvl, ":)") then
    local yous = getUs()
    for _,unit in ipairs(yous) do
      if sameFloat(unit,outerlvl) and inBounds(unit.x,unit.y) and ignoreCheck(unit,outerlvl,":)") then
        wins = wins + 1
      end
    end
  end
  
  if hasProperty(outerlvl, "nxt") then
		table.insert(win_sprite_override,tiles_list[tiles_by_name["text_nxt"]]);
    doWin("nxt")
  end
  
  return wins,unwins
end

function changeDirIfFree(unit, dir)
  if canMove(unit, dirs8[dir][1], dirs8[dir][2], dir, false, false, unit.name, "dir check") then
    addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
    unit.olddir = unit.dir
    updateDir(unit, dir)
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
	if reason == "infloop" or (not hasRule(outerlvl,"got","lvl") and not hasProperty(outerlvl,"protecc")) then
    level_destroyed = true
  end
  
  transform_results = {}
  local holds = matchesRule(outerlvl,"got","?")
  for _,match in ipairs(holds) do
    if not nameIs(outerlvl, match.rule.object.name) then
      local obj_name = match.rule.object.name
      if obj_name == "text" then
        istext = true
        obj_name = "text_" .. match.rule.subject.name
      end
      local tile = tiles_by_name[obj_name]
      --let x ben't x txt prevent x be txt, and x ben't txt prevent x be y txt
      local overriden = false;
      if match.rule.object.name == "text" then
        overriden = hasRule(outerlvl, "gotn't", "text_" .. match.rule.subject.name)
      elseif match.rule.object.name:starts("text_") then
        overriden = hasRule(outerlvl, "gotn't", "text")
      end
      if tile ~= nil and not overriden then
        table.insert(transform_results, tiles_list[tile].name)
        table.insert(win_sprite_override,tiles_list[tile])
      end
    end
  end
  
  addUndo({"destroy_level", reason})
  playSound(reason)
  if reason == "unlock" or reason == "convert" then
    playSound("break")
  end
  
  if reason == "infloop" then
    if hasProperty("loop","try again") then
      doTryAgain()
      level_destroyed = false
    elseif hasProperty("loop","xwx") then
      doXWX()
    elseif hasProperty("loop",":)") then
      doWin("won")
      level_destroyed = true
    elseif hasProperty("loop",";d") then
      doWin("won", false)
      level_destroyed = true
    end
    local berule = matchesRule("loop","be","?")
    for _,rule in ipairs(berule) do
      local object = rule.rule.object.name
      if tiles_by_name[object] then
        table.insert(transform_results,object)
        table.insert(win_sprite_override,tiles_list[tiles_by_name[object]])
      end
    end
  end
  
  if level_destroyed then
    local units_to_destroy = {}
    for _,unit in ipairs(units) do
      if inBounds(unit.x, unit.y) then
        table.insert(units_to_destroy, unit);
      end
    end
    for _,unit in ipairs(units_to_destroy) do
      addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
    end
    handleDels(units_to_destroy,true)
    if reason == "infloop" and #transform_results == 0 then
      local new_unit = createUnit(tiles_by_name["infloop"], math.floor(mapwidth/2), math.floor(mapheight/2), 1)
      addUndo({"create", new_unit.id, false})
    end
  end
  
  if (#transform_results > 0) then
    doWin("transform", transform_results)
  end
end

function dropGotUnit(unit, rule)
  --TODO: CLEANUP: Blatantly copypasta'd from convertUnits.
  if unit == outerlvl then
    return
  end
  
  function dropOneGotUnit(unit, rule, obj_name)
    local object = obj_name
    if rule.object.name == "text" then
      obj_name = "text_" .. unit.fullname
    end
    if object:starts("this") then
      obj_name = "this"
    end
    local obj_id = tiles_by_name[obj_name]
    local obj_tile = tiles_list[obj_id]
    --let x ben't x txt prevent x be txt, and x ben't txt prevent x be y txt
    local overriden = false
    if object == "text" then
      overriden = hasRule(unit, "gotn't", "text_" .. unit.fullname)
    elseif object:starts("text_") or object:starts("letter_") then
      overriden = hasRule(unit, "gotn't", "text")
    end
    if not overriden and (obj_name == "mous" or obj_tile ~= nil) then
      if obj_name == "mous" then
        local new_mouse = createMouse(unit.x, unit.y)
        addUndo({"create_cursor", new_mouse.id})
      else
        local color = rule.object.prefix
        if color == "samepaint" then
          if unit.color_override then
            color = colour_for_palette[unit.color_override[1]][unit.color_override[2]]
          else
            if type(color[1]) == "table" then
              color = colour_for_palette[unit.color[1][1]][unit.color[1][2]]
            else
              color = colour_for_palette[unit.color[1]][unit.color[2]]
            end
          end
        end
        local new_unit = createUnit(obj_id, unit.x, unit.y, unit.dir, false, nil, nil, color)
        addUndo({"create", new_unit.id, false})
      end
    end
  end
  
  local obj_name = rule.object.name
  if (group_names_set[obj_name] ~= nil) then
    for _,v in ipairs(namesInGroup(obj_name)) do
      dropOneGotUnit(unit, rule, v)
    end
  else
    dropOneGotUnit(unit, rule, obj_name)
  end
end

function convertLevel()
  local deconverts = matchesRule(outerlvl,"ben't","lvl")
  if #deconverts > 0 then
    destroyLevel("convert")
    return true
  end
  
  transform_results = {}
  
  local meta = matchesRule(outerlvl,"be","txtify")
  if (#meta > 0) then
   local tile = nil
    local nametocreate = outerlvl.fullname
    for i = 1,#meta do
      nametocreate = "text_"..nametocreate
    end
    tile = tiles_by_namePossiblyMeta(nametocreate)
    if tile ~= nil then
       table.insert(transform_results, tiles_list[tile].name)
      table.insert(win_sprite_override,tiles_list[tile])
    end
  end

  local converts = matchesRule(outerlvl,"be","?")
  for _,match in ipairs(converts) do
    if not (hasProperty(outerlvl, "lvl") or hasProperty(outerlvl, "notranform")) and match.rule.object.type and match.rule.object.type.object then
      local tile = tiles_by_name[match.rule.object.name]
      if match.rule.object.name == "text" then
        tile = tiles_by_name["text_lvl"]
      end
      if tile == nil and match.rule.object.name == "every1" and not hasRule(outerlvl, "be", "lvl") then
        for _,v in ipairs(referenced_objects) do
          if not hasRule(outerlvl, "ben't", v) then
            table.insert(transform_results, tiles_list[tiles_by_name[v]].name)
            table.insert(win_sprite_override,tiles_list[tiles_by_name[v]])
          end
        end
      end
      if match.rule.object.name:starts("this") then
        tile = tiles_by_name["this"]
      end
      --let x ben't x txt prevent x be txt, and x ben't txt prevent x be y txt
      local overriden = false;
      if match.rule.object.name == "text" then
        overriden = hasRule(outerlvl, "ben't", "text_" .. match.rule.subject.name)
      elseif match.rule.object.name:starts("text_") then
        overriden = hasRule(outerlvl, "ben't", "text")
      end
      if tile ~= nil and not overriden then
        table.insert(transform_results, tiles_list[tile].name)
        table.insert(win_sprite_override,tiles_list[tile])
      end
    end
  end
  
  if (#transform_results > 0) then
    doWin("transform", transform_results)
  end
end

function convertUnits(pass)
  
  if level_destroyed then return end
  if convertLevel() then return end

  local converted_units = {}
  local del_cursors = {}
  
  local meta = getUnitsWithEffectAndCount("txtify")
  for unit,amt in pairs(meta) do
    if (unit.fullname == "mous") then
      local cursor = unit
      if inBounds(cursor.x, cursor.y) then
        local tile = tiles_by_name["text_mous"]
        if tile ~= nil then
          table.insert(del_cursors, cursor)
        end
        local new_unit = createUnit(tile, unit.x, unit.y, unit.dir, true)
        if (new_unit ~= nil) then
          addUndo({"create", new_unit.id, true, created_from_id = unit.id})
        end
      end
    elseif not unit.new and unit.type ~= "outerlvl" and timecheck(unit,"be","txtify") then
      table.insert(converted_units, unit)
      addParticles("bonus", unit.x, unit.y, unit.color_override or unit.color)
      local tile = nil
      local nametocreate = unit.fullname
      for i = 1,amt do
        local tile = tiles_by_name[nametocreate]
        if tile ~= nil and tiles_list[tile].tometa then
          nametocreate = tiles_list[tile].tometa
        else
          nametocreate = "text_"..nametocreate
        end
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
  
  local demeta = getUnitsWithRuleAndCount(nil,"be","thingify")
  for unit,amt in pairs(demeta) do
    if not unit.new and unit.type ~= "outerlvl" and timecheck(unit,"be","thingify") then
      --remove "text_" as many times as we're de-metaing
      local nametocreate = unit.fullname
      for i = 1,amt do
        local newname = nametocreate
        local tile = tiles_by_name[nametocreate]
        if tiles_list[tile].demeta then
          newname = tiles_list[tile].demeta
        else
          if nametocreate:starts("text_") then
            newname = nametocreate:sub(6, -1)
          elseif nametocreate:starts("letter_") then
            newname = nametocreate:sub(8, -1)
            if newname == "custom" then
              local letter = unit.special.customletter
              if letter == "aa" or letter == "aaa" or letter == "aaaa" then
                newname = "battry"
              elseif letter == "aaaaa" or letter == "aaaaaa" then
                newname = "aaaaaa"
              end
            end
          end
        end
        if not tiles_by_name[newname] then
          break
        end
        nametocreate = newname
      end
      if nametocreate ~= unit.fullname then
        table.insert(converted_units, unit)
        addParticles("bonus", unit.x, unit.y, unit.color_override or unit.color)
        if (nametocreate == "mous") then
          local new_mouse = createMouse(unit.x, unit.y)
          addUndo({"create_cursor", new_mouse.id, created_from_id = unit.id})
        else
          local tile = tiles_by_name[nametocreate]
          if tile ~= nil then
            local new_unit = createUnit(tile, unit.x, unit.y, unit.dir, true)
            if (new_unit ~= nil) then
              addUndo({"create", new_unit.id, true, created_from_id = unit.id})
            end
          end
        end
      end
    end
  end

  local deconverts = matchesRule(nil,"ben't","?")
  for _,match in ipairs(deconverts) do
    local rules = match[1]
    local unit = match[2]

    local rule = rules.rule
    
    if (rule.subject.name == "mous" and rule.object.name == "mous") then
      for _,cursor in ipairs(cursors) do
        if inBounds(cursor.x, cursor.y) and testConds(cursor, rule.subject.conds) then
          addParticles("bonus", unit.x, unit.y, unit.color_override or unit.color)
          table.insert(del_cursors, cursor)
        end
      end
    elseif not unit.new and nameIs(unit, rule.object.name) and timecheck(unit) then
      if not unit.removed and unit.type ~= "outerlvl" then
        addParticles("bonus", unit.x, unit.y, unit.color_override or unit.color)
        table.insert(converted_units, unit)
      end
    end
  end

  local all = matchesRule(nil,"be","every1")
  for _,match in ipairs(all) do
    local rules = match[1]
    local unit = match[2]
    local rule = rules.rule
    if not hasProperty(unit, "notranform") then
      if (rule.subject.name == "mous" and rule.object.name ~= "mous") then
        for _,cursor in ipairs(cursors) do
          if inBounds(cursor.x, cursor.y) and testConds(cursor, rule.subject.conds) then
            for _,v in ipairs(referenced_objects) do
              local tile = tiles_by_name[v]
              if v == "text" then
                tile = tiles_by_name["text_" .. rule.subject.name]
              end
              if tile ~= nil then
                table.insert(del_cursors, cursor)
              end
              local new_unit = createUnit(tile, unit.x, unit.y, unit.dir, true)
              if (new_unit ~= nil) then
                addUndo({"create", new_unit.id, true, created_from_id = unit.id})
              end
            end
          end
        end
      elseif not unit.new and unit.class == "unit" and unit.type ~= "outerlvl" and not hasRule(unit, "be", unit.name) and timecheck(unit) then
        for _,v in ipairs(referenced_objects) do
          local tile = tiles_by_name[v]
          if v == "text" then
            tile = tiles_by_name["text_" .. rule.subject.name]
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
  end
  
  local all2 = matchesRule(nil,"be","every2")
  for _,match in ipairs(all2) do
    local rules = match[1]
    local unit = match[2]
    local rule = rules.rule
    if not hasProperty(unit, "notranform") then
      if (rule.subject.name == "mous" and rule.object.name ~= "mous") then
        for _,cursor in ipairs(cursors) do
          if inBounds(cursor.x, cursor.y) and testConds(cursor, rule.subject.conds) then
            local tbl = copyTable(referenced_objects)
            mergeTable(tbl, referenced_text)
            for _,v in ipairs(tbl) do
              local tile = tiles_by_name[v]
              if v == "text" then
                tile = tiles_by_name["text_" .. rule.subject.name]
              end
              if tile ~= nil then
                table.insert(del_cursors, cursor)
              end
              local new_unit = createUnit(tile, unit.x, unit.y, unit.dir, true)
              if (new_unit ~= nil) then
                addUndo({"create", new_unit.id, true, created_from_id = unit.id})
              end
            end
          end
        end
      elseif not unit.new and unit.class == "unit" and unit.type ~= "outerlvl" and not hasRule(unit, "be", unit.name) and timecheck(unit) then
        local tbl = copyTable(referenced_objects)
        mergeTable(tbl, referenced_text)
        for _,v in ipairs(tbl) do
          local tile = tiles_by_name[v]
          if v == "text" then
            tile = tiles_by_name["text_" .. rule.subject.name]
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
  end
  
  local all3 = matchesRule(nil,"be","every3")
  for _,match in ipairs(all3) do
    local rules = match[1]
    local unit = match[2]
    local rule = rules.rule
    if not hasProperty(unit, "notranform") then
      if (rule.subject.name == "mous" and rule.object.name ~= "mous") then
        for _,cursor in ipairs(cursors) do
          if inBounds(cursor.x, cursor.y) and testConds(cursor, rule.subject.conds) then
            local tbl = copyTable(referenced_objects)
            mergeTable(tbl, referenced_text)
            mergeTable(tbl, special_objects)
            for _,v in ipairs(tbl) do
              local tile = tiles_by_name[v]
              if v == "text" then
                tile = tiles_by_name["text_" .. rule.subject.name]
              end
              if tile ~= nil then
                table.insert(del_cursors, cursor)
              end
              local new_unit = createUnit(tile, unit.x, unit.y, unit.dir, true)
              if (new_unit ~= nil) then
                addUndo({"create", new_unit.id, true, created_from_id = unit.id})
              end
            end
          end
        end
      elseif not unit.new and unit.class == "unit" and unit.type ~= "outerlvl" and not hasRule(unit, "be", unit.name) and timecheck(unit) then
        local tbl = copyTable(referenced_objects)
        mergeTable(tbl, referenced_text)
        mergeTable(tbl, special_objects)
        for _,v in ipairs(tbl) do
          local tile = tiles_by_name[v]
          if v == "text" then
            tile = tiles_by_name["text_" .. rule.subject.name]
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
  end
  
  local converts = matchesRule(nil,"be","?")
  for _,match in ipairs(converts) do
    local rules = match[1]
    local unit = match[2]
    local rule = rules.rule
    
    if not hasProperty(unit, "notranform") then
      if (rule.subject.name == "mous" and rule.object.name ~= "mous") then
        for _,cursor in ipairs(cursors) do
          if inBounds(cursor.x, cursor.y) and testConds(cursor, rule.subject.conds) then
            local tile = tiles_by_name[rule.object.name]
            if rule.object.name == "text" then
              tile = tiles_by_name["text_" .. rule.subject.name]
            elseif rule.object.name:starts("this") and not rule.object.name:ends("n't") then
              tile = tiles_by_name["this"]
            end
            if tile ~= nil then
              table.insert(del_cursors, cursor)
              local color = rule.object.prefix
              if color == "samepaint" then
                if unit.color_override then
                  color = colour_for_palette[unit.color_override[1]][unit.color_override[2]]
                else
                  if type(color[1]) == "table" then
                    color = colour_for_palette[unit.color[1][1]][unit.color[1][2]]
                  else
                    color = colour_for_palette[unit.color[1]][unit.color[2]]
                  end
                end
              end
              local new_unit = createUnit(tile, unit.x, unit.y, unit.dir, true, nil, nil, color)
              if (new_unit ~= nil) then
                addUndo({"create", new_unit.id, true, created_from_id = unit.id})
              end
            end
          end
        end
      elseif not unit.new and unit.class == "unit" and not nameIs(unit, rule.object.name) and unit.type ~= "outerlvl" and timecheck(unit) then
        local tile = tiles_by_name[rule.object.name]
        if rule.object.name == "text" then
          tile = tiles_by_name["text_" .. rule.subject.name]
        elseif rule.object.name:starts("this") and not rule.object.name:ends("n't") then
          tile = tiles_by_name["this"]
        end
        --prevent transformation into certain objects
        if tile ~= nil and tiles_list[tile].convertible ~= nil and not tiles_list[tile].convertible then
          tile = nil
        end
        --let x ben't x txt prevent x be txt, and x ben't txt prevent x be y txt
        local overriden = false;
        if rule.object.name == "text" then
          overriden = hasRule(unit, "ben't", "text_" .. rule.subject.name)
        elseif rule.object.name:starts("text_") then
          overriden = hasRule(unit, "ben't", "text")
        end
        if tile ~= nil and not overriden then
          if not unit.removed then
            table.insert(converted_units, unit)
          end
          local color = rule.object.prefix
          if color == "samepaint" then
            if unit.color_override then
              color = colour_for_palette[unit.color_override[1]][unit.color_override[2]]
            else
              if type(color[1]) == "table" then
                color = colour_for_palette[unit.color[1][1]][unit.color[1][2]]
              else
                color = colour_for_palette[unit.color[1]][unit.color[2]]
              end
            end
          end
          local new_unit = createUnit(tile, unit.x, unit.y, unit.dir, true, nil, nil, color)
          if (new_unit ~= nil) then
            if rule.object.name == "lvl" and not new_unit.color_override then
              new_unit.color_override = unit.color_override or unit.color
            end
            new_unit.special = unit.special
            addUndo({"create", new_unit.id, true, created_from_id = unit.id})
          end
        elseif rule.object.name == "mous" then
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
    if not hasProperty(unit, "notranform") then
      local the = ruleparent[1].rule.object.unit
      
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
  end
  
  for i,cursor in ipairs(del_cursors) do
    if (not cursor.removed) then  
      addUndo({"remove_cursor", cursor.screenx, cursor.screeny, cursor.id})
      deleteMouse(cursor.id)
    end
  end

  deleteUnits(converted_units,true)
end

function deleteUnits(del_units,convert,gone)
  for _,unit in ipairs(del_units) do
    if (not unit.removed_final) then
      if (unit.color_override ~= nil) then
        addUndo({"color_override_change", unit.id, unit.color_override})
      end
      for colour,_ in pairs(main_palette_for_colour) do
        if unit[colour] == true then
          addUndo({"colour_change", unit.id, colour, true})
        end
      end
      if (unit.backer_turn ~= nil) then
        addUndo({"backer_turn", unit.id, unit.backer_turn})
      end
      if unit.class == "cursor" then
        addUndo({"remove_cursor",unit.screenx,unit.screeny,unit.id})
      else
        addUndo({"remove", unit.tile, unit.x, unit.y, unit.dir, convert or false, unit.id, unit.special})
      end
    end
    deleteUnit(unit,convert,false,gone)
  end
end

function createUnit(tile,x,y,dir,convert,id_,really_create_empty,prefix)
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

  unit.old_active = unit.active
  unit.overlay = {}
  unit.used_as = {} -- list of text types, used for determining sprite transformation
  unit.frame = math.random(1, 3)-1 -- for potential animation
  unit.special = {} -- for lvl objects
  unit.portal = {dir = 1, last = {}, extra = {}} -- for hol objects

  local data = tiles_listPossiblyMeta(tile)

  unit.tile = tile
  unit.sprite = deepCopy(data.sprite)
  unit.type = data.type
  unit.texttype = data.texttype or {object = true}
	unit.meta = data.meta
  unit.nt = data.nt
  unit.allowconds = data.allowconds or false
  unit.color = data.color
  unit.colored = data.colored
  unit.layer = data.layer
  unit.rotate = data.rotate or false
  unit.got_objects = {}
  unit.sprite_transforms = data.sprite_transforms or {}
  unit.features = data.features or {}
  unit.is_portal = data.portal or false
  unit.rotatdir = unit.rotate and unit.dir or 1
  
  if (not unit_tests) then
    unit.draw = {x = unit.x, y = unit.y, scalex = 1, scaley = 1, rotation = (unit.rotatdir - 1) * 45, opacity = 1}
    if convert then
      unit.draw.scaley = 0
      addTween(tween.new(0.1, unit.draw, {scaley = 1}), "unit:scale:" .. unit.tempid)
    end
  end

  unit.fullname = data.name

  if unit.type == "text" then
    should_parse_rules = true
    unit.name = "text"
    if unit.texttype.letter then
      letters_exist = true
      unit.textname = string.sub(unit.fullname, 8)
    else
      unit.textname = string.sub(unit.fullname, 6)
    end
  else
    unit.name = unit.fullname
    unit.textname = unit.fullname
  end
  
  if rules_effecting_names[unit.name] then
    should_parse_rules = true
  end
  
  if prefix then
    if type(prefix) == "table" then
      unit.color_override = prefix
    else
      unit[prefix] = true
      updateUnitColourOverride(unit)
    end
  end
  
  --abort if we're trying to create outerlvl outside of the start
  if (x < -10 or y < -10) and unit.name == "lvl" and not really_create_empty then
    return
  end
  
  --make outerlvl here
  if ((unit.name == "lvl" or unit.fullname == "lvl") and really_create_empty) then
    unit.type = "outerlvl"
  end
  
  --abort if we're trying to create empty outside of initialization, to preserve the invariant 'there is exactly empty per tile'
  if ((unit.fullname == "no1") and not really_create_empty) then
    --print("not placing an empty:"..unit.name..","..unit.fullname..","..unit.textname)
    return nil
  end
  
  --do this before the 'this' change to textname so that we only get 'this' in referenced_objects
  if unit.texttype.object and unit.textname ~= "every1" and unit.textname ~= "every2" and unit.textname ~= "every3" and unit.textname ~= "mous" and unit.textname ~= "bordr" and unit.textname ~= "no1" and unit.textname ~= "lvl" and unit.textname ~= "the" and unit.textname ~= "text" and unit.textname ~= "this" and group_names_set[unit.textname] ~= true then
    if not unit.textname:ends("n't") and not unit.textname:starts("text_") and not unit.textname:starts("letter_") and not table.has_value(referenced_objects, unit.textname) then
      table.insert(referenced_objects, unit.textname)
    end
  end
  
  if unit.fullname == "this" then
    unit.name = unit.name .. unit.id
    unit.textname = unit.textname .. unit.id
  end
  
  if unit.type == "text" then
    updateNameBasedOnDir(unit)
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
  
  if unit.name:starts("this") then
    if not units_by_name["text"] then
      units_by_name["text"] = {}
    end
    table.insert(units_by_name["text"], unit)
  end

  if not units_by_layer[unit.layer] then
    units_by_layer[unit.layer] = {}
  end
  table.insert(units_by_layer[unit.layer], unit)
  max_layer = math.max(max_layer, unit.layer)
  
  --keep empty out of units_by_tile - it will be returned in getUnitsOnTile
  if (not (unit.fullname == "no1" or unit.type == "outerlvl")) then
    table.insert(unitsByTile(x, y), unit)
  end

  table.insert(units, unit)

  --updateDir(unit, unit.dir)
  new_units_cache[unit] = true
  unit.new = true
  --print("createUnit:", unit.fullname, unit.id, unit.x, unit.y)
  return unit
end

function deleteUnit(unit,convert,undoing,gone)
  unit.removed = true
  unit.removed_final = true
  if not undoing and not convert and not gone and not level_destroyed and rules_with ~= nil then
    gotters = matchesRule(unit, "got", "?")
    for _,ruleparent in ipairs(gotters) do
      local rule = ruleparent.rule
      dropGotUnit(unit, rule)
    end
  end
  --empty can't really be destroyed, only pretend to be, to preserve the invariant 'there is exactly empty per tile'
  if (unit.fullname == "no1" or unit.type == "outerlvl") then
    unit.destroyed = false
    unit.removed = false
    unit.removed_final = false
    return
  end
  if unit.type == "text" or rules_effecting_names[unit.name] then
    should_parse_rules = true
  end
  removeFromTable(units, unit)
  units_by_id[unit.id] = nil
  removeFromTable(units_by_name[unit.name], unit)
  if unit.name ~= unit.fullname then
    removeFromTable(units_by_name[unit.fullname], unit)
  end
  removeFromTable(unitsByTile(unit.x, unit.y), unit)
  if rules_with and hasProperty(unit,"big") then
    removeFromTable(unitsByTile(unit.x+1,unit.y),unit)
    removeFromTable(unitsByTile(unit.x,unit.y+1),unit)
    removeFromTable(unitsByTile(unit.x+1,unit.y+1),unit)
  end
  if not convert and not gone then
    removeFromTable(units_by_layer[unit.layer], unit)
  end
  if not unit_tests then
    if convert then
      table.insert(still_converting, unit)
      addUndo{"tween",unit}
      addTween(tween.new(0.1, unit.draw, {scaley = 0}), "unit:scale:" .. unit.tempid)
      tick.delay(function() removeFromTable(still_converting, unit) end, 0.1)
    elseif gone then
      if unit.fullname == "ditto" then
        if hasProperty(unit,"notranform") then
            unit.sprite = "ditto_notranform"
        else
            unit.sprite = "ditto_gone"
        end
      end
      table.insert(still_converting, unit)
      addUndo{"tween",unit}
      local rise = love.math.random(5,9)
      local rotate = (90 + love.math.random(0,180)) * (love.math.random() > .5 and 1 or -1)
      local method = love.math.random() > .01 and "inSine" or "inElastic"
      addTween(tween.new(1.5, unit.draw, {y = unit.y-rise, rotation = rotate, opacity = 0}, method), "unit:rotation:" .. unit.tempid)
      tick.delay(function() removeFromTable(still_converting, unit) end, 1.5)
    end
  end
end

function moveUnit(unit,x,y,portal,instant)
  --print("moving:", unit.fullname, unit.x, unit.y, "to:", x, y)
  --when empty moves, swap it with the empty in its destination tile, to preserve the invariant 'there is exactly empty per tile'
  --also, keep empty out of units_by_tile - it will be added in getUnitsOnTile
  if (unit.type == "outerlvl") then
  elseif (unit.name == "mous") then
    --find out how far apart two tiles are in screen co-ordinates
    local x0,y0 = gameTileToScreen(0,0)
    local x1,y1 = gameTileToScreen(1,1)
    local dx = x1-x0
    local dy = y1-y0
    local oldx = unit.x
    local oldy = unit.y
    local mx = dx*(x-oldx)
    local my = dy*(y-oldy)
    unit.x = x
    unit.y = y
    if unit.primary then
      love.mouse.setPosition(unit.screenx + mx,unit.screeny + my)
      --updating the real mouse position moves every mous, so to counter this we move every non-real mous in the opposite direction
      for _,cursor in ipairs(cursors) do
        if not cursor.primary then
          cursor.x = cursor.x - (x-oldx)
          cursor.y = cursor.y - (y-oldy)
          cursor.screenx = cursor.screenx - mx
          cursor.screeny = cursor.screeny - my
        end
      end
    else
      unit.screenx = unit.screenx + mx
      unit.screeny = unit.screeny + my
    end
  elseif (unit.fullname == "no1") and inBounds(x, y) then
    local tileid = unit.x + unit.y * mapwidth
    local oldx = unit.x
    local oldy = unit.y
    unit.x = x
    unit.y = y
    local dest_tileid = unit.x + unit.y * mapwidth
    dest_empty = empties_by_tile[dest_tileid]
    dest_empty.x = oldx
    dest_empty.y = oldy
    dest_empty.dir = unit.dir
    empties_by_tile[tileid] = dest_empty
    empties_by_tile[dest_tileid] = unit
  else
    removeFromTable(unitsByTile(unit.x, unit.y), unit)
    if rules_with and hasProperty(unit,"big") then
      removeFromTable(unitsByTile(unit.x+1,unit.y),unit)
      removeFromTable(unitsByTile(unit.x,unit.y+1),unit)
      removeFromTable(unitsByTile(unit.x+1,unit.y+1),unit)
    end

    -- putting portal check above same-position check to give portal effect through one-tile gap
    if portal and portal.is_portal and x - portal.x == dirs8[portal.dir][1] and y - portal.y == dirs8[portal.dir][2] and not instant then
      if unit.type == "text" or rules_effecting_names[unit.name] or rules_effecting_names[unit.fullname] then
        should_parse_rules = true
      end
      if (not unit_tests) then
        portaling[unit] = portal
        -- set draw positions to portal offset to interprolate through portals
        unit.draw.x, unit.draw.y = portal.draw.x, portal.draw.y
        addTween(tween.new(0.1, unit.draw, {x = x, y = y}), "unit:pos:" .. unit.tempid)
        if portal.name == "smol" then
          addTween(tween.new(0.05, unit.draw, {scaley = 0.5}), "unit:pos:" .. unit.tempid, function()
          unit.draw.x = x
          unit.draw.y = y
          addTween(tween.new(0.05, unit.draw, {scaley = 1}), "unit:pos:" .. unit.tempid)
          end)
        end
        -- instantly change object's rotation, weirdness ensues otherwise
        unit.draw.rotation = (unit.rotatdir - 1) * 45
        tweens["unit:dir:" .. unit.tempid] = nil
      end
    elseif (x ~= unit.x or y ~= unit.y) and not instant then
      if unit.type == "text" or rules_effecting_names[unit.name] or rules_effecting_names[unit.fullname] then
        should_parse_rules = true
      end
      if not unit_tests then
        if rules_with and not hasProperty(unit,"big") and unit.draw.x == x and unit.draw.y == y then
          --'bump' effect to show movement failed
          unit.draw.x = (unit.x+x*2)/3
          unit.draw.y = (unit.y+y*2)/3
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
    elseif instant then
      unit.draw.x = x
      unit.draw.y = y
    end

    unit.x = x
    unit.y = y
    
    table.insert(unitsByTile(unit.x, unit.y), unit)
    if rules_with and hasProperty(unit,"big") then
      for i=1,3 do
        if not table.has_value(unitsByTile(unit.x+i%2,unit.y+math.floor(i/2)),unit) then
          table.insert(unitsByTile(unit.x+i%2,unit.y+math.floor(i/2)),unit)
        end
      end
    end
  end

  if not instant then
    do_move_sound = true
  end
end

function updateDir(unit, dir, force)
  if not force and rules_with ~= nil then
    if hasProperty(unit, "no turn") then
      return false
    end
    if hasRule(unit, "ben't", dirs8_by_name[dir]) then
      return false
    end
    for i=1,8 do
      if hasRule(unit, "ben't", "spin"..i) then
        if (dir == (unit.dir+i-1)%8+1) then return false end
      end
    end
    if unit.dir == dir then return true end
  end
  if unit.name == "mous" then
    unit.dir = dir
    return true
  end
  
  unit.dir = dir
  if (unit.rotate and not hasRule(unit,"ben't","rotatbl")) or (rules_with ~= nil and hasProperty(unit,"rotatbl")) then
    unit.rotatdir = dir
  end
  
  --Some units in rules_effecting_names are there because their direction matters (a portal or part of a parse-effecting look at/seen by condition).
  if rules_effecting_names[unit.fullname] then
    should_parse_rules = true
  end
  
  updateNameBasedOnDir(unit)
  
  if (not unit_tests) then
    unit.draw.rotation = unit.draw.rotation % 360
    local target_rot = (unit.rotatdir - 1) * 45
    if (unit.rotate or (rules_with ~= nil and hasProperty(unit,"rotatbl"))) and math.abs(unit.draw.rotation - target_rot) == 180 then
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
  end
  return true
end

function updateNameBasedOnDir(unit)
  if unit.fullname == "text_mayb" then
    should_parse_rules = true
  elseif unit.fullname == "text_direction" then
    unit.textname = dirs8_by_name[unit.dir]
    should_parse_rules = true
  elseif unit.fullname == "text_spin" then
    unit.textname = "spin" .. tostring(unit.dir)
    should_parse_rules = true
  elseif unit.fullname == "letter_colon" then
    if unit.dir == 1 or unit.dir == 2 or unit.dir == 3 then
      unit.textname = ":"
    else
      unit.textname = "  "
    end
    should_parse_rules = true
  elseif unit.fullname == "letter_parenthesis" then
    if unit.dir == 1 or unit.dir == 2 or unit.dir == 3 then
      unit.textname = "("
    elseif unit.dir == 5 or unit.dir == 6 or unit.dir == 7 then
      unit.textname = ")"
    end
    should_parse_rules = true
  elseif unit.fullname == "letter_h" then
    if unit.rotatdir == 3 or unit.rotatdir == 7 then
      unit.textname = "i"
    else
      unit.textname = "h"
    end
  elseif unit.fullname == "letter_i" then
    if unit.rotatdir == 3 or unit.rotatdir == 7 then
      unit.textname = "h"
    else
      unit.textname = "i"
    end
  elseif unit.fullname == "letter_n" then
    if unit.rotatdir == 3 or unit.rotatdir == 7 then
      unit.textname = "z"
    else
      unit.textname = "n"
    end
  elseif unit.fullname == "letter_z" then
    if unit.rotatdir == 3 or unit.rotatdir == 7 then
      unit.textname = "n"
    else
      unit.textname = "z"
    end
  elseif unit.fullname == "letter_m" then
    if unit.rotatdir == 5 then
      unit.textname = "w"
    else
      unit.textname = "m"
    end
  elseif unit.fullname == "letter_w" then
    if unit.rotatdir == 5 then
      unit.textname = "m"
    else
      unit.textname = "w"
    end
  elseif unit.fullname == "letter_6" then
    if unit.rotatdir == 5 then
      unit.textname = "9"
    else
      unit.textname = "6"
    end
  elseif unit.fullname == "letter_9" then
    if unit.rotatdir == 5 then
      unit.textname = "6"
    else
      unit.textname = "9"
    end
  elseif unit.fullname == "letter_no" then
    if unit.rotatdir == 5 then
      unit.textname = "on"
    else
      unit.textname = "no"
    end
  end
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
  max_mouse_id = max_mouse_id - 1
  return max_mouse_id
end

meta_offset = 100000
nt_offset = meta_offset/2 --50000
custom_offset = nt_offset/2 --25000
--Explanation: All non-custom tiles should be in range 1-24999. All custom tiles (unique to a specific world) should be in range 25000-49999, so that when a non-custom tile is added they don't become invalid. Then, all tiles 50000-99999 are n't versions of the tiles 50000 less. Then, all tiles beyond that are meta versions of the tiles 100000 less.
function tiles_listPossiblyMeta(tile_id)
  local tile = tiles_list[tile_id]
  if (tile ~= nil) then
    return tile
  end
  --check if this is an n't tile
  if (tile_id % meta_offset > nt_offset) then
    local premeta_tile = tiles_listPossiblyMeta(tile_id-nt_offset)
    --now we can make our new n't tile!
    tile = makeNtTile(premeta_tile)
    tiles_by_name[tile.name] = tile_id
    tiles_list[tile_id] = tile
  end
  
  --recursively make all less meta tiles
  if (tile_id > meta_offset) then
    local premeta_tile = tiles_listPossiblyMeta(tile_id-meta_offset)
    --now we can make our new meta tile!
    tile = makeMetaTile(premeta_tile)
    tiles_by_name[tile.name] = tile_id
    tiles_list[tile_id] = tile
  end
  return tile
end

function tiles_by_namePossiblyMeta(name)
  local tile_id = tiles_by_name[name]
  if (tile_id ~= nil) then
    return tile_id
  end
  --recursively make all less meta tiles
  if name:starts("text_") then
    local premeta_tile_id = tiles_by_namePossiblyMeta(name:sub(6, -1))
    local premeta_tile = tiles_list[premeta_tile_id]
    tile_id = premeta_tile_id+meta_offset
    --now we can make our new meta tile!
    local tile = makeMetaTile(premeta_tile)
    tiles_by_name[name] = tile_id
    tiles_list[tile_id] = tile
  end
  return tile_id
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

function makeNtTile(premeta_tile)
  return {
    name = premeta_tile.name .. "n't",
    sprite = premeta_tile.metasprite or premeta_tile.sprite,
    type = "text",
    color = premeta_tile.color,
    layer = 20,
    texttype = premeta_tile.texttype,
    sprite_transforms = premeta_tile.sprite_transforms,
    nt = true
  }
end

function undoWin()
  if hasProperty(outerlvl, "no undo") then return end
  currently_winning = false
  music_fading = false
  win_size = 0
  win_sprite_override = {}
end

function doWin(result_, payload_)
  if not currently_winning then
    local result = result_ or "won"
    local payload = payload_
    if payload == nil then
      payload = true
    end
    if doing_past_turns then
      past_queued_wins[result] = payload
    elseif result == "won" and payload == false then
      if readSaveFile{"levels",level_filename,"won"} then
        playSound("unwin")
        writeSaveFile(false, {"levels",level_filename,"won"})
      end
    else
      won_this_session = true
      win_reason = result
      currently_winning = true
      music_fading = true
      win_size = 0
      playSound("win")
      if (not replay_playback) then
        writeSaveFile(payload, {"levels", level_filename, result})
        love.filesystem.createDirectory("levels")
        local to_save = replay_string
        local rng_cache_populated = false
        for _,__ in pairs(rng_cache) do
          rng_cache_populated = true
          break
        end
        if (rng_cache_populated) then
          to_save = to_save.."|"..love.data.encode("string", "base64", serpent.line(rng_cache))
        end
        if not RELEASE_BUILD and world_parent == "officialworlds" then
          official_replay_string = to_save
        else
          local dir = "levels/"
          if world_parent ~= "officialworlds" then dir = getWorldDir() .. "/" end
          love.filesystem.write(dir .. level_filename .. ".replay", to_save)
          print("Replay successfully saved to " .. dir .. level_filename .. ".replay")
        end
      end
    end
	end
end

function doXWX()
  writeSaveFile(nil,{"levels",level_filename,"seen"})
  writeSaveFile(nil,{"levels",level_filename,"won"})
  writeSaveFile(nil,{"levels",level_filename,"bonus"})
  writeSaveFile(nil,{"levels",level_filename,"transform"})
  escResult(true, true)
end

function getColor(unit)
  return unit.color_override or unit.color
end