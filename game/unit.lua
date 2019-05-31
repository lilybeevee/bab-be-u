function updateUnits(undoing, big_update)
  max_layer = 1
  units_by_layer = {}
  local del_units = {}
  
  presence["details"] = #undo_buffer.." turns done"

  for i,v in ipairs(units_by_tile) do
    units_by_tile[i] = {}
  end

  for _,unit in ipairs(units) do
    local tileid = unit.x + unit.y * mapwidth
    table.insert(units_by_tile[tileid], unit)
    --just in case undeleted units are lingering around
    if (unit.removed) then
      --table.insert(del_units, on)
    end
  end
  
  deleteUnits(del_units,false)
  
  --handle non-monotonic (creative, destructive) effects one at a time, so that we can process them in a set order instead of unit order
  --BABA order is as follows: DONE, BLUE, RED, MORE, SINK, WEAK, MELT, DEFEAT, SHUT, EAT, BONUS, END, WIN, MAKE, HIDE
  --(SHIFT, TELE, FOLLOW, BACK are handled in moveblock. FALL is handled in fallblock. But we can just put moveblock in the start here and it's more or less the same thing.)

  if (big_update and not undoing) then
    local isshift = getUnitsWithEffect("go");
    for _,unit in ipairs(isshift) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if unit ~= on and sameFloat(unit, on) then
          addUndo({"update", unit.id, unit.x, unit.y, unit.dir})
          on.dir = unit.dir
        end
      end
    end
    
    --TODO: TELE idea: Instead of randomly chosing between multiple other teleports, choose the next one in reading order.
    --Then... If you're TELE & TELE, choose the previous one. TELEx3, two ahead. TELEx4, two behind. TELEx5, three ahead. And so on.
    local istele = getUnitsWithEffect("visit fren");
    for _,unit in ipairs(istele) do
      --TODO: implement TELE
    end
    
    --TODO: MORE (MOAR?) idea: Make stacked MOREs give you 4-way, 8-way, double 4-way and double 8-way growth for 1, 2, 3 and 4 respectively.
    local ismoar = getUnitsWithEffect("moar");
    for _,unit in ipairs(ismoar) do
      for i=1,4 do
        local ndir = dirs[i];
        local dx = ndir[1];
        local dy = ndir[2];
        if canMove(unit, dx, dy, false, false, unit.name) then
          local new_unit = createUnit(tiles_by_name[unit.fullname], unit.x, unit.y, unit.dir)
          addUndo({"create", new_unit.id, false})
          moveUnit(new_unit,unit.x+dx,unit.y+dy)
          addUndo({"update", new_unit.id, unit.x, unit.y, unit.dir})
        end
      end
    end
  
    local to_destroy = {}
    
    local issink = getUnitsWithEffect("no swim");
    for _,unit in ipairs(issink) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if unit ~= on and sameFloat(unit, on) then
          table.insert(to_destroy, unit)
          table.insert(to_destroy, on)
          playSound("sink", 0.5)
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
          playSound("break", 0.5)
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
          playSound("sink", 0.5)
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
          playSound("break", 0.5)
          addParticles("destroy", unit.x, unit.y, unit.color)
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    local isshut = getUnitsWithEffect("ned kee");
    for _,unit in ipairs(isshut) do
      local stuff = getUnitsOnTile(unit.x, unit.y, nil, true)
      for _,on in ipairs(stuff) do
        if hasProperty("for dor") and sameFloat(unit, on) then
          table.insert(to_destroy, unit)
          table.insert(to_destroy, on)
          playSound("break", 0.5)
          playSound("unlock", 0.6)
          addParticles("destroy", unit.x, unit.y, unit.color)
          addParticles("destroy", on.x, on.y, on.color)
        end
      end
    end
    
    to_destroy = handleDels(to_destroy);
    
    --TODO: EAT (SNACC) goes here, as well as in movement (because a solid wall can eat you, I think? need to check how baba does it)
    
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
          table.insert(to_destroy, on)
          playSound("break", 0.5)
          addParticles("destroy", unit.x, unit.y, unit.color)
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
          playSound("win", 0.5)
        end
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

      unit.layer = tile.layer

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
end

function handleDels(to_destroy)
  local convert = false
  for _,unit in ipairs(to_destroy) do
    if not hasProperty(unit, "protecc") then
      unit.destroyed = true
      unit.removed = true
    end
  end
  return {}
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
      local new_unit = createUnit(obj_id, unit.x, unit.y, unit.dir, true)
      addUndo({"create", new_unit.id, true})
    end
  end
end

function convertUnits()
  for i,v in ipairs(units_by_tile) do
    units_by_tile[i] = {}
  end

  for _,unit in ipairs(units) do
    local tileid = unit.x + unit.y * mapwidth
    table.insert(units_by_tile[tileid], unit)
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

  for _,rules in ipairs(full_rules) do
    local rule = rules[1]
    local obj_name = rule[3]

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

    if units_by_name[rule[1]] then
      for i,unit in ipairs(units_by_name[rule[1]]) do
        unit.got_object = {}
        if rule[3] == "mous" or (obj_tile ~= nil and (obj_tile.type == "object" or istext)) then
          if rule[2] == "be" then
            if not unit.destroyed and rule[3] ~= unit.name then
              if testConds(unit,rule[4][1]) then
                if not unit.removed then
                  table.insert(converted_units, unit)
                end
                unit.removed = true
                if rule[3] == "mous" then
                  local new_mouse = createMouse(unit.x, unit.y)
                  addUndo({"create_cursor", new_mouse.id})
                else
                  local new_unit = createUnit(obj_id, unit.x, unit.y, unit.dir, true)
                  addUndo({"create", new_unit.id, true})
                end
                if rule[1] == "windo" then
                  local wx, wy = love.window.getPosition()
                  if rule[3] == "up" then
                    window_dir = 0
                  elseif rule[3] == "right" then
                    window_dir = 1
                  elseif rule[3] == "down" then
                    window_dir = 2
                  elseif rule[3] == "left" then
                    window_dir = 3
                  elseif rule[3] == "walk" then
                    if window_dir == 0 or window_dir == 2 then
                      love.window.setPosition(wx, wy+(window_dir/2%2-1)*50) -- i hate this
                    elseif window_dir == 1 or window_dir == 3 then
                      love.window.setPosition(wx+((window_dir-1)/2%2-1)*50, wy) -- i hate this too
                    end
                  end
                end
              end
            end
          elseif rule[2] == "creat" and not unit.destroyed then
            local new_unit = createUnit(obj_id, unit.x, unit.y, unit.dir)
            addUndo({"create", new_unit.id, false})
          elseif rule[2] == "consume" then
            if not unit.destroyed then
              if rule[3] == unit.name then
                unit.destroyed = true
                unit.removed = true
                playSound("break", 0.5)
                addParticles("destroy", unit.x, unit.y, unit.color)
              else
                if not undoing then
                  for _,on in ipairs(units_by_tile[unit.id]) do
                    if on ~= unit and rule[3] == on.name then
                      on.destroyed = true
                      on.removed = true
                      playSound("break", 0.5)
                      addParticles("destroy", on.x, on.y, on.color)
                      table.insert(del_units, on)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  deleteUnits(converted_units,true)
end

function deleteUnits(del_units,convert)
  for _,unit in ipairs(del_units) do
    deleteUnit(unit,convert)
    addUndo({"remove", unit.tile, unit.x, unit.y, unit.dir, convert or false, unit.id})
  end
end

function createUnit(tile,x,y,dir,convert,id_)
  local unit = {}
  unit.class = "unit"

  unit.id = id_ or newUnitID()
  unit.x = x or 0
  unit.y = y or 0
  unit.dir = dir or 1
  unit.active = false
  unit.blocked = false
  unit.removed = false

  unit.draw = {x = unit.x, y = unit.y, scalex = 1, scaley = 1, rotation = (unit.dir - 1) * 45}

  if convert then
    unit.draw.scaley = 0
    addTween(tween.new(0.1, unit.draw, {scaley = 1}), "unit:scale:" .. unit.id)
  end

  unit.old_active = unit.active
  unit.overlay = {}

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

  unit.fullname = data.name
  if unit.type == "text" then
    unit.name = "text"
    unit.textname = string.sub(unit.fullname, 6)
  else
    unit.name = unit.fullname
    unit.textname = unit.fullname
  end

  if unit.texttype == "object" then
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
  table.insert(units_by_tile[tileid], unit)

  table.insert(units, unit)

  updateDir(unit, unit.dir)

  return unit
end

function deleteUnit(unit,convert)
  unit.removed = true
  unit.removed_final = true
  if not convert and scene == game then
    gotters = matchesRule(unit, "got", "?");
    for _,ruleparent in ipairs(gotters) do
      local rule = ruleparent[1]
      dropGotUnit(unit, rule);
    end
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
    addTween(tween.new(0.1, unit.draw, {scaley = 0}), "unit:scale:" .. unit.id)
    tick.delay(function() removeFromTable(still_converting, unit) end, 0.1)
  end
end

function moveUnit(unit,x,y)
  local tileid = unit.x + unit.y * mapwidth
  removeFromTable(units_by_tile[tileid], unit)

  if x ~= unit.x or y ~= unit.y then
    addTween(tween.new(0.1, unit.draw, {x = x, y = y}), "unit:pos:" .. unit.id)
  end

  unit.x = x
  unit.y = y

  tileid = unit.x + unit.y * mapwidth
  table.insert(units_by_tile[tileid], unit)

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

  -- angles are literally the worst
  unit.draw.rotation = unit.draw.rotation % 360
  local target_rot = (dir - 1) * 45
  if unit.draw.rotation - target_rot > 180 then
    target_rot = target_rot + 360
  elseif target_rot - unit.draw.rotation > 180 then
    target_rot = target_rot - 360
  end
  addTween(tween.new(0.1, unit.draw, {rotation = target_rot}), "unit:dir:" .. unit.id)
end

function newUnitID()
  max_unit_id = max_unit_id + 1
  return max_unit_id
end

function newMouseID()
  max_mouse_id = max_mouse_id + 1
  return max_mouse_id
end