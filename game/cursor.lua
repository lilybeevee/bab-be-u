function updateCursors()
  local del_cursors = {}
  cursor_convert_to = nil

  for i,rules in ipairs(full_rules) do
    local rule = rules[1]
    local obj_name = rule[3]

    local istext = false
    if rule[3] == "text" then
      istext = true
      obj_name = "text_" .. rule[1]
    end
    local obj_id = tiles_by_name[obj_name]
    local obj_tile = tiles_list[obj_id]

    if rule[1] == "mous" then
      if obj_tile ~= nil and (obj_tile.type == "object" or istext) then
        if rule[2] == "be" then
          if rule[3] ~= "mous" then
            cursor_convert_to = obj_id
          end
        end
      end
    end
  end

  for i,cursor in ipairs(cursors) do
    local deleted = false
    for _,cid in ipairs(del_cursors) do
      if cid == cursor.id then
        deleted = true
      end
    end

    if not deleted then
      cursor.x = cursor.x + mouse_X - mouse_oldX
      cursor.y = cursor.y + mouse_Y - mouse_oldY

      local hx,hy = screenToGameTile(cursor.x, cursor.y)

      if hx ~= nil and hy ~= nil then
        if cursor_convert_to ~= nil then
          local new_unit = createUnit(cursor_convert_to, hx, hy, 1, true)
          addUndo({"create", new_unit.id, true})
          addUndo({"remove_cursor", cursor.x, cursor.y, cursor.id})
          table.insert(del_cursors, cursor.id)
        end
      end

      cursor.overlay = {}
      if hasProperty(cursor,"tranz") then
        table.insert(cursor.overlay, "trans")
      end
      if hasProperty(cursor,"gay") then
        table.insert(cursor.overlay, "gay")
      end
    end
  end
  for i,cid in ipairs(del_cursors) do
    deleteMouse(cid)
  end
end

function createMouse_direct(x,y,id_)
  local mouse = {}
  mouse.class = "cursor"

  mouse.id = id_ or newMouseID()
  mouse.x = x
  mouse.y = y

  mouse.overlay = {}
  mouse.removed = false

  if #cursors == 0 then
    mouse.primary = true
    mouse_X, mouse_Y = x, y
    mouse_oldX, mouse_oldY = x, y
    love.mouse.setPosition(x, y)
  else
    mouse.primary = false
  end
  table.insert(cursors, mouse)
  return mouse
end

function createMouse(gamex,gamey,id_)
  local gx,gy = gameTileToScreen(gamex+0.5,gamey+0.5)
  return createMouse_direct(gx, gy, id_)
end

function deleteMouse(id)
  local needs_new_primary = false
  for i,mous in ipairs(cursors) do
    if mous.id == id then
      if mous.primary then
        needs_new_primary = true
      end
      mous.removed = true
      table.remove(cursors,i)
      return
    end
  end
  if needs_new_primary then
    if #cursors > 0 then
      local mous = cursors[1]
      mous.primary = true
      mouse_X, mouse_Y = mous.x, mous.y
      mouse_oldX, mouse_oldY = mous.x, mous.y
      love.mouse.setPosition(mous.x, mous.y)
    end
  end
end

--[[function deleteMice(gamex,gamey)
  local toBeDeleted = {}
  local numberDeleted = 0
  local hx,hy = gameTileToScreen(gamex,gamey)
  for i,mous in ipairs(cursors) do
  	if cursors[i].x >= hx and cursors[i].x <= hx + TILE_SIZE and cursors[i].y >= hy and cursors[i].y <= hy + TILE_SIZE then
  	  table.insert(toBeDeleted, i)
  	end
  end
  for i=table.getn(toBeDeleted),1,-1 do
    table.remove(toBeDeleted)
    numberDeleted = numberDeleted + 2
  end
  return numberDeleted
end]]--