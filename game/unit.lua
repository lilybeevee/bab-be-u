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
          if euclideanDistance(stalker, stalkee) > 0 and testConds(stalker, stalker_conds) and testConds(stalkee, stalkee_conds) then
            local stalk_dir = dirs8_by_offset[sign(stalkee.x - stalker.x)][sign(stalkee.y - stalker.y)]
            if hasProperty(stalker, "orthongl") then
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
              if canMove(unit, dx, dy, false, false, unit.name) then
                if unit.class == "unit" then
                  local new_unit = createUnit(tiles_by_name[unit.fullname], unit.x, unit.y, unit.dir)
                  addUndo({"create", new_unit.id, false})
                  moveUnit(new_unit,unit.x+dx,unit.y+dy)
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
              if canMove(unit, dx, dy, false, false, unit.name) then
                if unit.class == "unit" then
                  local new_unit = createUnit(tiles_by_name[unit.fullname], unit.x, unit.y, unit.dir)
                  addUndo({"create", new_unit.id, false})
                  moveUnit(new_unit,unit.x+dx,unit.y+dy)
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
    
    local issink = getUnitsWithEffect("no swim");
    for _,unit in ipairs(issink) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if unit ~= on and sameFloat(unit, on) then
          table.insert(to_destroy, unit)
          table.insert(to_destroy, on)
          playSound("sink")
          addParticles("destroy", unit.x, unit.y, on.color)
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

      unit.overlay = {}
      if hasProperty(unit,"tranz") then
        table.insert(unit.overlay, "trans")
      end
      if hasProperty(unit,"gay") then
        table.insert(unit.overlay, "gay")
      end

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
          addUndo({"create", new_unit.id, true})
        end
      elseif rule[3] == "mous" then
        if not unit.removed then
          table.insert(converted_units, unit)
        end
        unit.removed = true
        local new_mouse = createMouse(unit.x, unit.y)
        addUndo({"create_cursor", new_mouse.id})
      end
    end
  end

  deleteUnits(converted_units,true)
end

function deleteUnits(del_units,convert)
  for _,unit in ipairs(del_units) do
    if (not unit.removed_final) then
      addUndo({"remove", unit.tile, unit.x, unit.y, unit.dir, convert or false, unit.id})
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
      addTween(tween.new(0.1, unit.draw, {x = x, y = y}), "unit:pos:" .. unit.tempid)
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