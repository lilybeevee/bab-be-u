function updateCursors()
  local del_cursors = {}

  for i,cursor in ipairs(cursors) do
    local deleted = false
    for _,cid in ipairs(del_cursors) do
      if cid == cursor.id then
        deleted = true
      end
    end
    if not deleted and cursor.removed then
      deleted = true
      table.insert(del_cursors, cursor.id)
    end

    if not deleted then
      cursor.screenx = cursor.screenx + mouse_X - mouse_oldX
      cursor.screeny = cursor.screeny + mouse_Y - mouse_oldY

      local x, y = screenToGameTile(cursor.screenx, cursor.screeny)
      
      cursor.x = x
      cursor.y = y

      cursor.overlay = {}
      if hasProperty(cursor,"enby") then
        table.insert(cursor.overlay, "enby")
      end
      if hasProperty(cursor,"tranz") and not hasProperty(cursor,"notranform") then
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

  mouse.screenx = x
  mouse.screeny = y

  -- unit compatibility
  mouse.x, mouse.y = screenToGameTile(x, y)
  mouse.dir = 7
  mouse.name = "mous"
  mouse.fullname = "mous"
  mouse.type = "object"
  mouse.color = {255, 255, 255}

  mouse.overlay = {}
  mouse.removed = false
  mouse.new = true

  if #cursors == 0 then
    mouse.primary = true
    mouse_X, mouse_Y = x, y
    mouse_oldX, mouse_oldY = x, y
    if (not unit_tests) then
      love.mouse.setPosition(x, y)
    end
  else
    mouse.primary = false
  end
  table.insert(cursors, mouse)
  cursors_by_id[mouse.id] = mouse
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
      break
    end
  end
  if needs_new_primary then
    if #cursors > 0 then
      local mous = cursors[1]
      mous.primary = true
      mouse_X, mouse_Y = mous.screenx, mous.screeny
      mouse_oldX, mouse_oldY = mous.screenx, mous.screeny
      if (not unit_tests) then
        love.mouse.setPosition(mous.screenx, mous.screeny)
      end
    end
  end
end

function updateMousePosition()
  if #cursors == 1 then
    love.mouse.setGrabbed(false)
    cursors[1].screenx, cursors[1].screeny = love.mouse.getPosition()
  else
    if mouse_grabbed then
      if (not unit_tests) then
        love.mouse.setPosition(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
      end
    end
    if just_released_mouse == 1 then
      just_released_mouse = 2
    elseif just_released_mouse == 2 then
      just_released_mouse = nil
    end
  end
end

function moveMouse(x, y, dx, dy)
  if not mouse_grabbed then return end
  if x == math.floor(love.graphics.getWidth() / 2) and y == math.floor(love.graphics.getHeight() / 2) then return end

  if just_grabbed_mouse then
    resetCursors(x, y)
    just_grabbed_mouse = false
  else
    if #cursors > 1 then
      local all_out = true
      local last_out = nil
      for i,cursor in ipairs(cursors) do
        local was_offscreen = cursor.offscreen

        cursor.screenx = cursor.screenx + dx
        cursor.screeny = cursor.screeny + dy

        cursor.offscreen = cursor.screenx < 0 or cursor.screenx > love.graphics.getWidth() or cursor.screeny < 0 or cursor.screeny > love.graphics.getHeight()
        if not cursor.offscreen then
          all_out = false
        elseif not was_offscreen then
          last_out = cursor
        end
      end
      if all_out and last_out then
        grabMouse(false)
        love.mouse.setPosition(last_out.screenx, last_out.screeny)
      end
    end
  end
end

function grabMouse(val)
  if mouse_grabbed == val then return end
  if not val then
    love.mouse.setGrabbed(false)
    mouse_grabbed = false
    just_released_mouse = 1
    --print("released mouse")
  else
    if #cursors ~= 1 then
      love.mouse.setGrabbed(true)
      mouse_grabbed = true
      just_grabbed_mouse = true
      --print("grabbed mouse")
    end
  end
end

function resetCursors(x, y)
  if #cursors == 1 then return end

  local p = {x = 0, y = 0}

  local px, py = getNearestPointInPerimeter(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), x, y)
  if px == 0 then p.x = 1 end
  if py == 0 then p.y = 1 end
  if px == love.graphics.getWidth() then p.x = -1 end
  if py == love.graphics.getHeight() then p.y = -1 end

  local best_cursor = nil
  for i,cursor in ipairs(cursors) do
    if cursor.offscreen then
      if not best_cursor then
        best_cursor = cursor
      else
        if (p.x >= 0 or cursor.screenx < best_cursor.screenx) and
           (p.x <= 0 or cursor.screenx > best_cursor.screenx) and
           (p.y >= 0 or cursor.screeny < best_cursor.screeny) and
           (p.y <= 0 or cursor.screeny > best_cursor.screeny) then
          best_cursor = cursor
        end
      end
    end
  end

  local ox, oy = 0, 0
  if best_cursor then
    ox, oy = x - best_cursor.screenx, y - best_cursor.screeny
  end

  for i,cursor in ipairs(cursors) do
    if cursor.offscreen then
      cursor.screenx = cursor.screenx + ox
      cursor.screeny = cursor.screeny + oy
    end
  end
end