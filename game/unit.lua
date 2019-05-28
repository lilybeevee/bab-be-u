function updateUnits(undoing)
  max_layer = 1
  units_by_layer = {}
  
  presence["details"] = #undo_buffer.." turns done"

  for i,v in ipairs(units_by_tile) do
    units_by_tile[i] = {}
  end

  for _,unit in ipairs(units) do
    local tileid = unit.x + unit.y * mapwidth
    table.insert(units_by_tile[tileid], unit)
  end

  local del_units = {}
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

      if not undoing then
        for _,on in ipairs(units_by_tile[tileid]) do
          if hasProperty(on, "go") and on ~= unit then
            unit.dir = on.dir
          end
          if hasProperty(on, "no swim") and on ~= unit then
            unit.destroyed = true
            unit.removed = true
            on.destroyed = true
            on.removed = true
            playSound("sink", 0.5)
            addParticles("destroy", unit.x, unit.y, on.color)
          end
          if hasProperty(on, "ned kee") and hasProperty(unit, "for dor") then
            doAction({"open", {unit, on}})
          end
          if hasProperty(on, "for dor") and hasProperty(unit, "ned kee") then
            doAction({"open", {unit, on}})
          end
          if hasProperty(unit, "ouch") and on ~= unit then
            unit.destroyed = true
            unit.removed = true
            playSound("break", 0.5)
            addParticles("destroy", unit.x, unit.y, unit.color)
          end
		      if (hasProperty(on, "hotte") and hasProperty(unit, "fridgd"))
          or (hasProperty(on, "fridgd") and hasProperty(unit, "hotte")) then
		        unit.destroyed = true
            unit.removed = true
		      	playSound("sink", 0.5)
            addParticles("destroy", unit.x, unit.y, unit.color)
          end
          if is_u and hasProperty(on, ":(") then
            unit.destroyed = true
            unit.removed = true
            playSound("break", 0.5)
            addParticles("destroy", unit.x, unit.y, unit.color)
          end
          if hasProperty(unit, "protecc") then
            unit.destroyed = false
            unit.removed = false
          end
          if hasProperty(on, "protecc") then
            on.destroyed = false
            on.removed = false
          end
        end
      end
      
      if is_u and not undoing and not unit.removed then
        unit.layer = unit.layer + 10
        for _,on in ipairs(units_by_tile[tileid]) do
          if hasProperty(on, "xwx") then
            love = {}
          elseif hasProperty(on, ":o") and not hasProperty(on, "protecc") then
            on.destroyed = true
            on.removed = true
            playSound("rule", 0.5)
            addParticles("bonus", unit.x, unit.y, on.color)
            table.insert(del_units, on)
          elseif hasProperty(on, ":)") then
            win = true
            music_fading = true
            playSound("win", 0.5)
          end
        end
      end

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

      if hasProperty(unit,"up") then
        unit.olddir = unit.dir
        unit.dir = 7
      elseif hasProperty(unit,"right") then
        unit.olddir = unit.dir
        unit.dir = 1
      elseif hasProperty(unit,"down") then
        unit.olddir = unit.dir
        unit.dir = 3
      elseif hasProperty(unit,"left") then
        unit.olddir = unit.dir
        unit.dir = 5
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

  deleteUnits(del_units)
end

function convertUnits()
  local converted_units = {}

  for i,v in ipairs(units_by_tile) do
    units_by_tile[i] = {}
  end

  for _,unit in ipairs(units) do
    local tileid = unit.x + unit.y * mapwidth
    table.insert(units_by_tile[tileid], unit)
  end

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
          if rule[2] == "got" then
            if not table.has_value(unit.got_objects, rule[3]) and testConds(unit,rule[4][1]) then
              table.insert(unit.got_objects, rule[3])
            end
            if unit.destroyed and testConds(unit,rule[4][1]) then
              local new_unit = createUnit(obj_id, unit.x, unit.y, unit.dir)
              addUndo({"create", new_unit.id, false})
            end
          elseif rule[2] == "be" then
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
  unit.removed = false

  unit.scalex = 1
  unit.scaley = 1
  if convert then
    unit.scaley = 0
  end
  unit.oldx = unit.x
  unit.oldy = unit.y
  unit.olddir = unit.dir
  unit.move_timer = MAX_MOVE_TIMER
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

  unit.argtypes = {}
  if data.argtypes then
    for _,v in ipairs(data.argtypes) do
      unit.argtypes[v] = true
    end
  else
    unit.argtypes["object"] = true
  end

  unit.fullname = data.name
  if unit.type == "text" then
    unit.name = "text"
    unit.textname = string.sub(unit.fullname, 6)
  else
    unit.name = unit.fullname
    unit.textname = unit.fullname
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

  return unit
end

function deleteUnit(unit,convert)
  unit.removed = true
  unit.removed_final = true
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
  end
end

function moveUnit(unit,x,y)
  local tileid = unit.x + unit.y * mapwidth
  removeFromTable(units_by_tile[tileid], unit)

  unit.oldx = lerp(unit.oldx, unit.x, unit.move_timer/MAX_MOVE_TIMER)
  unit.oldy = lerp(unit.oldy, unit.y, unit.move_timer/MAX_MOVE_TIMER)
  unit.x = x
  unit.y = y
  unit.move_timer = 0

  tileid = unit.x + unit.y * mapwidth
  table.insert(units_by_tile[tileid], unit)

  do_move_sound = true
end

function newUnitID()
  max_unit_id = max_unit_id + 1
  return max_unit_id
end

function newMouseID()
  max_mouse_id = max_mouse_id + 1
  return max_mouse_id
end