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
    elseif unit.name ~= "no1" and unit.fullname ~= "no1" then
      local tileid = unit.x + unit.y * mapwidth
      table.insert(units_by_tile[tileid], unit)
    end
  end
  
  deleteUnits(del_units,false)
  
  --handle non-monotonic (creative, destructive) effects one at a time, so that we can process them in a set order instead of unit order
  --BABA order is as follows: DONE, BLUE, RED, MORE, SINK, WEAK, MELT, DEFEAT, SHUT, EAT, BONUS, END, WIN, MAKE, HIDE
  --(SHIFT, TELE, FOLLOW, BACK are handled in moveblock. FALL is handled in fallblock. But we can just put moveblock in the start here and it's more or less the same thing.)

  if (big_update and not undoing) then
    local iszip = getUnitsWithEffect("zip");
    for _,unit in ipairs(iszip) do
      doZip(unit)
    end
  
    local isshift = getUnitsWithEffect("go");
    for _,unit in ipairs(isshift) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if unit ~= on and sameFloat(unit, on) then
          addUndo({"update", on.id, on.x, on.y, on.dir})
          on.olddir = on.dir
          updateDir(on, unit.dir)
        end
      end
    end
    
    --Currently using deterministic tele version. Number of teles a teleporter has influences whether it goes forwards or backwards and by how many steps.
    local istele = getUnitsWithEffectAndCount("visit fren");
    teles_by_name = {};
    teles_by_name_index = {};
    tele_targets = {};
    --form lists, by tele name, of what all the tele units are
    for unit,amt in pairs(istele) do
      if teles_by_name[unit.name] == nil then
        teles_by_name[unit.name] = {}
      end
      table.insert(teles_by_name[unit.name], unit);
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
        if unit ~= on and sameFloat(unit, on) --[[and unit.name ~= on.name]] then
          local destinations = teles_by_name[unit.name]
          local source_index = teles_by_name_index[unit.name][unit]
          
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
            if dist > 0 and hasProperty(stalker, "orthongl") then
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
          if hasProperty(on, "go away") then
            pushfront = true
            break
          end
        end
        if pushfront then
          for _,on in ipairs(stuff2) do
            if hasProperty(on, "go away") then
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
    
    --MOAR is 4-way growth, MOARx2 is 8-way growth, MOARx3 is 2x 4-way growth, MOARx4 is 2x 8-way growth, MOARx5 is 3x 4-way growth, etc.
    local give_me_moar = true;
    local moar_repeats = 0;
    while (give_me_moar) do
      give_me_moar = false;
      local ismoar = getUnitsWithEffectAndCount("moar");
      for unit,amt in pairs(ismoar) do
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
      moar_repeats = moar_repeats + 1
    end
  
    local to_destroy = {}
    
    --UNDO logic:
    --the first time something becomes UNDO, we track what turn it became UNDO on.
    --then every turn thereafter until it stops being UNDO, we undo the update (move backwards) and create (destroy units) events of a turn 2 turns further back (+1 so we keep undoing into the past, +1 because the undo_buffer gained a real turn as well!)
    --We have to keep track of the turn we started backing on in the undo buffer, so that if we undo to a past where a unit was UNDO, then we know what turn to pick back up from. We also have to save/restore backer_turn on destroy, so if we undo the unit's destruction it comes back with the right backer_turn.
    --(The cache is not necessary for the logic, it just removes our need to check ALL units to see if they need to be cleaned up.)
    
    local backed_this_turn = {};
    local not_backed_this_turn = {};
    
    local isback = getUnitsWithEffect("undo");
    for _,unit in ipairs(isback) do
      backed_this_turn[unit] = true;
      print(unit.backer_turn)
      if (unit.backer_turn == nil --[[or unit.backer_turn > #undo_buffer]]) then
        addUndo({"backer_turn", unit.id, nil})
        print("setting unit.backer_turn");
        unit.backer_turn = #undo_buffer;
        backers_cache[unit] = #undo_buffer;
      end
      print(tostring(#undo_buffer)..","..tostring(unit.backer_turn)..","..tostring(2*(#undo_buffer-unit.backer_turn)))
      doBack(unit, 2*(#undo_buffer-unit.backer_turn));
    end
    
    for unit,turn in pairs(backers_cache) do
      if turn ~= nil and not backed_this_turn[unit] then
        not_backed_this_turn[unit] = true;
      end
    end
    
    for unit,_ in pairs(not_backed_this_turn) do
      addUndo({"backer_turn", unit.id, unit.backer_turn})
      print("unsetting unit.backer_turn");
      unit.backer_turn = nil;
      backers_cache[unit] = nil;
    end
    
    to_destroy = handleDels(to_destroy);
    
    local issink = getUnitsWithEffect("no swim");
    for _,unit in ipairs(issink) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if unit ~= on and sameFloat(unit, on) then
          table.insert(to_destroy, unit)
          table.insert(to_destroy, on)
          playSound("sink")
          addParticles("destroy", unit.x, unit.y, on.color)
          shakeScreen(0.3, 0.1)
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local isweak = getUnitsWithEffect("ouch");
    for _,unit in ipairs(isweak) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if unit ~= on and sameFloat(unit, on) then
          table.insert(to_destroy, unit)
          playSound("break")
          addParticles("destroy", unit.x, unit.y, unit.color)
          shakeScreen(0.3, 0.1)
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local ishot = getUnitsWithEffect("hotte");
    for _,unit in ipairs(ishot) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if hasProperty(on, "fridgd") and sameFloat(unit, on) then
          table.insert(to_destroy, on)
          playSound("sink")
          addParticles("destroy", unit.x, unit.y, unit.color)
          shakeScreen(0.3, 0.1)
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local isdefeat = getUnitsWithEffect(":(");
    for _,unit in ipairs(isdefeat) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        is_u = hasProperty(on, "u")
        if is_u and sameFloat(unit, on) then
          table.insert(to_destroy, on)
          playSound("break")
          addParticles("destroy", unit.x, unit.y, unit.color)
          shakeScreen(0.3, 0.2)
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local isshut = getUnitsWithEffect("ned kee");
    for _,unit in ipairs(isshut) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if hasProperty(unit, "for dor") and sameFloat(unit, on) then
          table.insert(to_destroy, unit)
          table.insert(to_destroy, on)
          playSound("break")
          playSound("unlock")
          addParticles("destroy", unit.x, unit.y, unit.color)
          addParticles("destroy", on.x, on.y, on.color)
          shakeScreen(0.3, 0.1)
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local issnacc = matchesRule(nil, "snacc", "?");
    for _,ruleparent in ipairs(issnacc) do
      local unit = ruleparent[2]
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if hasRule(unit, "snacc", on) and sameFloat(unit, on) then
          table.insert(to_destroy, on)
          playSound("break")
          addParticles("destroy", unit.x, unit.y, unit.color)
          shakeScreen(0.3, 0.15)
        end
      end
    end
    
    local isreset = getUnitsWithEffect("try again");
    for _,unit in ipairs(isreset) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        is_u = hasProperty(on, "u")
        if is_u and sameFloat(unit, on) then
          will_undo = true
          break
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local iscrash = getUnitsWithEffect("xwx");
    for _,unit in ipairs(iscrash) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        is_u = hasProperty(on, "u")
        if is_u and sameFloat(unit, on) then
          love = {}
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local isbonus = getUnitsWithEffect(":o");
    for _,unit in ipairs(isbonus) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        is_u = hasProperty(on, "u")
        if is_u and sameFloat(unit, on) then
          table.insert(to_destroy, unit)
          playSound("rule")
          addParticles("bonus", unit.x, unit.y, unit.color)
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local split = getUnitsWithEffect("split");
    for _,unit in ipairs(split) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if unit ~= on and sameFloat(unit, on) then
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
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local iswin = getUnitsWithEffect(":)");
    for _,unit in ipairs(iswin) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        is_u = hasProperty(on, "u")
        if is_u and sameFloat(unit, on) then
          win = true
          music_fading = true
          playSound("win")
        end
      end
    end

    local creators = matchesRule(nil, "creat", "?")
    for _,match in ipairs(creators) do
      local creator = match[2]
      local createe = match[1][1][3]

      local tile = tiles_by_name[createe]
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
  
  local unitcount = #units
  for i,unit in ipairs(units) do
    --[[if i > unitcount then
      break
    end]]
    local deleted = false
    for _,del in ipairs(del_units) do
      if del == unit then
        deleted = true
      end
    end

    if not deleted and not unit.removed_final then
      local tile = tiles_list[unit.tile]
      local tileid = unit.x + unit.y * mapwidth
      local is_u = hasProperty(unit, "u")

      -- rich presence icon
      if is_u and discordRPC and discordRPC ~= true then
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

      unit.layer = tile.layer + (20 * countProperty(unit, "flye"))

      if unit.fullname == "os" then
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
        if unit.sprite ~= "wat" and hasProperty(unit,"slep") then
          unit.sprite = unit.sprite .. "_slep"
        end
      else
        if hasProperty(unit,"slep") and tiles_list[unit.tile].sleepsprite then
          unit.sprite = tiles_list[unit.tile].sleepsprite
        else
          unit.sprite = tiles_list[unit.tile].sprite
        end
      end

      if not undoing then
        for k,v in pairs(dirs8_by_name) do
          if hasProperty(unit, k) then
            unit.olddir = unit.dir
            if unit.dir ~= v then
              addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
            end
            updateDir(unit, v)
          end
        end
      end

      if unit.fullname == "text_direction" then
        for k,v in pairs(dirs8_by_name) do
          if unit.dir == v then
            unit.textname = k
          end
        end
      end
      
      if unit.fullname == "text_cilindr" then
        for k,v in pairs(cilindr_names) do
          if unit.dir == v then
            unit.textname = k
          end
        end
      end
      
      if unit.fullname == "text_mobyus" then
        for k,v in pairs(mobyus_names) do
          if unit.dir == v then
            unit.textname = k
          end
        end
      end

      unit.overlay = {}
      if hasProperty(unit,"tranz") then
        table.insert(unit.overlay, "trans")
      end
      if hasProperty(unit,"gay") then
        table.insert(unit.overlay, "gay")
      end

      -- for optimisation in drawing
      unit.stelth = hasProperty(unit,"stelth")
      unit.colrful = hasProperty(unit,"colrful")
      unit.red = hasProperty(unit,"reed")
      unit.blue = hasProperty(unit,"bleu")

      if not units_by_layer[unit.layer] then
        units_by_layer[unit.layer] = {}
      end
      table.insert(units_by_layer[unit.layer], unit)
      max_layer = math.max(max_layer, unit.layer)
      
      if unit.removed then
        table.insert(del_units, unit)
      end
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

  deleteUnits(del_units,false)
  
  if (will_undo) then
    local can_undo = true;
    while (can_undo) do
      can_undo = undo()
    end
    reset_count = reset_count + 1
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
  deleteUnits(del_units, false);
  return {}
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
  playSound("break")
  for _,unit in ipairs(units) do
    addParticles("destroy", unit.x, unit.y, unit.color)
  end
  handleDels(units, true)
  if (reason == "infloop") then
    local new_unit = createUnit(tiles_by_name["infloop"], math.floor(mapwidth/2), math.floor(mapheight/2), 0)
    addUndo({"create", new_unit.id, false})
  end
end

function dropGotUnit(unit, rule)
  --TODO: CLEANUP: Blatantly copypasta'd from convertUnits.
  local obj_name = rule[3]
  if (obj_name == "hatt" or obj_name == "gun") then
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

--TODO: Conversions need to be simultaneous, so that if e.g. bab on bab be hurcane and you stack two babs, they both become hurcanes. Also, I think creat timing should be tested to see if it matches baba's or not. (In Baba, it's pretty much at the end of the turn, but I don't know if it's before or after conversion.)
function convertUnits()
  for i,v in pairs(units_by_tile) do
    units_by_tile[i] = {}
  end

 --keep empty out of units_by_tile - it will be returned in getUnitsOnTile
 --TODO: CLEANUP: This is similar to updateUnits.
  for _,unit in ipairs(units) do
    if unit.name ~= "no1" and unit.fullname ~= "no1" then
      local tileid = unit.x + unit.y * mapwidth
      table.insert(units_by_tile[tileid], unit)
    end
  end

  local converted_units = {}

  local deconverts = matchesRule(nil,"ben't","?")
  for _,match in ipairs(deconverts) do
    local rules = match[1]
    local unit = match[2]

    local rule = rules[1]

    if nameIs(unit, rule[3]) then
      if not unit.removed then
        table.insert(converted_units, unit)
      end
      unit.removed = true
    end
  end

  deleteUnits(converted_units,true)

  converted_units = {}

  local converts = matchesRule(nil,"be","?")
  for _,match in ipairs(converts) do
    local rules = match[1]
    local unit = match[2]

    local rule = rules[1]

    if unit.class == "unit" and not nameIs(unit, rule[3]) then
      local tile = tiles_by_name[rule[3]]
      if rule[3] == "text" then
        tile = tiles_by_name["text_" .. rule[1]]
      end
      if tile ~= nil then
        if not unit.removed then
          table.insert(converted_units, unit)
        end
        unit.removed = true
        local new_unit = createUnit(tile, unit.x, unit.y, unit.dir, true)
        if (new_unit ~= nil) then
          print(dump(unit))
          print(dump(new_unit))
          print("create:"..tostring(unit.id))
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

  deleteUnits(converted_units,true)
end

function deleteUnits(del_units,convert)
  for _,unit in ipairs(del_units) do
    if (not unit.removed_final) then
      print("delete:"..tostring(unit.id))
      if (unit.backer_turn ~= nil) then
        addUndo({"backer_turn", unit.id, unit.backer_turn})
      end
      addUndo({"remove", unit.tile, unit.x, unit.y, unit.dir, convert or false, unit.id})
      print(unit.backer_turn)
    end
    deleteUnit(unit,convert)
  end
end

function createUnit(tile,x,y,dir,convert,id_,really_create_empty)
  local unit = {}
  unit.class = "unit"

  unit.id = id_ or newUnitID()
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

  local data = tiles_list[tile]

  unit.tile = tile
  unit.sprite = data.sprite
  unit.type = data.type
  unit.texttype = data.texttype or "object"
  unit.allowconds = data.allowconds or false
  unit.color = data.color
  unit.layer = data.layer
  unit.rotate = data.rotate or false
  unit.got_objects = {}
  unit.sprite_transforms = data.sprite_transforms or {}
  unit.eye = data.eye -- eye rectangle used for sans

  unit.fullname = data.name
  if unit.type == "text" then
    unit.name = "text"
    unit.textname = string.sub(unit.fullname, 6)
  else
    unit.name = unit.fullname
    unit.textname = unit.fullname
  end
  
  --abort if we're trying to create empty outside of initialization, to preserve the invariant 'there is exactly empty per tile'
  if ((unit.name == "no1" or unit.fullname == "no1") and not really_create_empty) then
    --print("not placing an empty:"..unit.name..","..unit.fullname..","..unit.textname)
    return nil
  end

  if unit.texttype == "object" and unit.textname ~= "every1" and unit.textname ~= "mous" and unit.textname ~= "no1" then
    if not table.has_value(referenced_objects, unit.textname) then
      table.insert(referenced_objects, unit.textname)
    end
  end
  if unit.type == "text" then
    if not table.has_value(referenced_text, unit.fullname) then
      table.insert(referenced_text, unit.fullname)
    end
  end

  units_by_id[unit.id] = unit

  if not units_by_name[unit.name] then
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
  if (not (unit.name == "no1" or unit.fullname == "no1")) then
    table.insert(units_by_tile[tileid], unit)
  end

  table.insert(units, unit)

  updateDir(unit, unit.dir)

  return unit
end

function deleteUnit(unit,convert,undoing)
  unit.removed = true
  unit.removed_final = true
  if not undoing and not convert and scene == game then
    gotters = matchesRule(unit, "got", "?");
    for _,ruleparent in ipairs(gotters) do
      local rule = ruleparent[1]
      dropGotUnit(unit, rule);
    end
  end
  --empty can't really be destroyed, only pretend to be, to preserve the invariant 'there is exactly empty per tile'
  if (unit.name == "no1" or unit.fullname == "no1") then
    unit.destroyed = false
    unit.removed = false
    unit.removed_final = false
    return
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

function moveUnit(unit,x,y)
  --when empty moves, swap it with the empty in its destination tile, to preserve the invariant 'there is exactly empty per tile'
  --also, keep empty out of units_by_tile - it will be added in getUnitsOnTile
  if (unit.name == "no1" or unit.fullname == "no1") then
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

    if x ~= unit.x or y ~= unit.y then
      if math.abs(x - unit.x) < 2 and math.abs(y - unit.y) < 2 then
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

function updateDir(unit,dir)
  unit.dir = dir
  if unit.fullname == "text_direction" then
    for k,v in pairs(dirs8_by_name) do
      if unit.dir == v then
        unit.textname = k
      end
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
end

function newUnitID()
  max_unit_id = max_unit_id + 1
  return max_unit_id
end

function newTempID()
  max_temp_id = max_temp_id + 1
  return max_temp_id
end

function newMouseID()
  max_mouse_id = max_mouse_id + 1
  return max_mouse_id
end