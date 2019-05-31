local scene = {}

local brush

local paintedtiles = 0
local buttons = {}
local button_over = nil
local name_font = nil
local typing_name = false
local ignore_mouse = true

local settings, settings_open, settings_pos
local input_name, input_palette, input_music, input_width, input_height

local saved_popup

function scene.load()
  brush = {id = nil, dir = 1, mode = "none", picked_tile = nil, picked_index = 0}
  saved_popup = {sprite = sprites["ui/level_saved"], y = 16, alpha = 0}
  settings_pos = {x = -320}
  key_down = {}
  buttons = {}

  settings_open = false
  selector_open = false
  
  if not level_name then
    level_name = "unnamed"
  end
  typing_name = false
  ignore_mouse = true

  width = love.graphics.getWidth()
  height = love.graphics.getHeight()
  name_font = love.graphics.newFont(24)
  settings = suit.new()

  input_name = {text = level_name}
  input_palette = {text = current_palette}
  input_music = {text = map_music}
  input_width = {text = tostring(mapwidth)}
  input_height = {text = tostring(mapheight)}

  clear()
  resetMusic(map_music, 0.1)
  loadMap()
  local now = os.time(os.date("*t"))
  presence = {
    state = "in editor",
    details = "making a neat new level",
    largeImageKey = "cover",
    largeimageText = "bab be u",
    smallImageKey = "edit",
    smallImageText = "editor",
    startTimestamp = now
  }
  nextPresenceUpdate = 0
  love.keyboard.setKeyRepeat(true)

  if map_ver == 0 then
    scene.updateMap()
  end
end

function scene.keyPressed(key)
  key_down[key] = true

  if settings_open then
    settings:keypressed(key)
  elseif not selector_open then
    if key == "up" or key == "left" or key == "down" or key == "right" then
      local dx, dy = 0, 0
      if key_down["up"] then dy = dy - 1 end
      if key_down["down"] then dy = dy + 1 end
      if key_down["left"] then dx = dx - 1 end
      if key_down["right"] then dx = dx + 1 end
      local dir = dirs8_by_offset[dx][dy]
      brush.dir = dir
      local hx,hy = getHoveredTile()
      if hx ~= nil then
        local tileid = hx + hy * mapwidth
        if units_by_tile[tileid] and #units_by_tile[tileid] > 0 then
          for _,unit in ipairs(units_by_tile[tileid]) do
            unit.dir = brush.dir
          end
        end
      end
    end
  end


  if key == "s" and key_down["lctrl"] then
    scene.saveLevel()
  elseif key == "l" and key_down["lctrl"] then
    scene.loadLevel()
  elseif key == "o" and key_down["lctrl"] then
    scene.openSettings()
  elseif key == "f" and key_down["lctrl"] then
    if love.filesystem.getInfo("levels") then
      love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/levels/")
    else
      love.system.openURL("file://"..love.filesystem.getSaveDirectory())
    end
  end

  if key == "tab" then
    selector_open = not selector_open
    if selector_open then
      presence["details"] = "browsing selector"
    end
  end
end

function scene.keyReleased(key)
  key_down[key] = false
end

function scene.update(dt)
  if ignore_mouse then
    if not love.mouse.isDown(1) then
      ignore_mouse = false
    end
    return
  end

  width = love.graphics.getWidth()
  height = love.graphics.getHeight()
  
  local mousex, mousey = love.mouse.getPosition()
  settings:updateMouse(mousex - settings_pos.x, mousey, love.mouse.isDown(1))

  settings.layout:reset(10, 10)
  settings.layout:padding(4, 4)

  settings:Label("Level Name", {align = "center"}, settings.layout:row(300, 24))
  local name = settings:Input(input_name, {align = "center"}, settings.layout:row())
  settings.layout:row()
  settings:Label("Level Palette", {align = "center"}, settings.layout:row(300, 24))
  local palette = settings:Input(input_palette, {align = "center"}, settings.layout:row())
  settings.layout:row()
  settings:Label("Level Music", {align = "center"}, settings.layout:row(300, 24))
  local music = settings:Input(input_music, {align = "center"}, settings.layout:row())
  settings.layout:row()
  settings:Label("Level Size", {align = "center"}, settings.layout:row())
  settings.layout:push(settings.layout:row())
  local winput = settings:Input(input_width, {align = "center"}, settings.layout:col((300 - 4)/2, 24))
  local hinput = settings:Input(input_height, {align = "center"}, settings.layout:col())
  settings.layout:pop()
  settings.layout:row()
  settings.layout:push(settings.layout:row())
  local save = settings:Button("Save", settings.layout:col((300 - 4*2)/3, 24))
  settings.layout:col()
  local cancel = settings:Button("Cancel", settings.layout:col())
  settings.layout:pop()

  if settings_open then
    if name.submitted or palette.submitted or music.submitted or winput.submitted or hinput.submitted then
      scene.saveSettings()
    elseif save.hit then
      scene.saveSettings()
      scene.openSettings()
    elseif cancel.hit then
      scene.openSettings()
    end
  else
    suit.layout:reset(0, 0)

    love.graphics.setColor(1, 1, 1)

    local fn
    if is_mobile then
      fn = suit.layout.row
    else
      fn = suit.layout.col
    end

    local load_btn = suit.ImageButton(sprites["ui/load"], {hovered = sprites["ui/load_h"], active = sprites["ui/load_a"]}, fn(suit.layout, 40, 40))
    local save_btn = suit.ImageButton(sprites["ui/save"], {hovered = sprites["ui/save_h"], active = sprites["ui/save_a"]}, fn(suit.layout))
    local settings_btn = suit.ImageButton(sprites["ui/cog"], {hovered = sprites["ui/cog_h"], active = sprites["ui/cog_a"]}, fn(suit.layout))
    local play_btn = suit.ImageButton(sprites["ui/play"], {hovered = sprites["ui/play_h"], active = sprites["ui/play_a"]}, fn(suit.layout))
    local selector_btn

    if is_mobile then
      selector_btn = suit.ImageButton(sprites["ui/selector"], {hovered = sprites["ui/selector_h"], active = sprites["ui/selector_a"]}, fn(suit.layout))
    else
      selector_btn = {hit = false}
    end

    if load_btn.hit then
      scene.loadLevel()
    elseif save_btn.hit then
      scene.saveLevel()
    elseif settings_btn.hit then
      scene.openSettings()
    elseif play_btn.hit then
      love.keypressed("f1")
    elseif selector_btn.hit then
      selector_open = not selector_open
    else
      local hx,hy = getHoveredTile()
      if hx ~= nil then
        local tileid = hx + hy * mapwidth

        local hovered = {}
        if units_by_tile[tileid] then
          for _,v in ipairs(units_by_tile[tileid]) do
            table.insert(hovered, v)
          end
        end

        if love.mouse.isDown(1) then
          if not selector_open then
            local painted = false
            local existing = nil
            if #hovered >= 1 then
              for _,unit in ipairs(hovered) do
                if unit.tile == brush.id then
                  existing = unit
                elseif brush.mode == "placing" and not key_down["lshift"] then
                  deleteUnit(unit)
                  painted = true
                end
              end
            end
            if existing and brush.mode == "none" then
              brush.mode = "erasing"
            elseif not existing and brush.mode == "none" then
              brush.mode = "placing"
            end
            if brush.id ~= nil then
              if brush.mode == "erasing" then
                if existing then
                  deleteUnit(existing)
                  painted = true
                end
              elseif brush.mode == "placing" then
                if existing then
                  existing.dir = brush.dir
                  painted = true
                else
                  createUnit(brush.id, hx, hy, brush.dir)
                  painted = true
                end
              end
            end
            if painted then
              if tileid == brush.picked_tile then
                brush.picked_tile = nil
                brush.picked_index = 0
              end
              paintedtiles = paintedtiles + 1
              presence["details"] = "painted "..paintedtiles.." tiles"
              scene.updateMap()
            end
          else
            local selected = hx + hy * tile_grid_width
            if tile_grid[selected] then
              brush.id = tile_grid[selected]
              brush.picked_tile = nil
              brush.picked_index = 0
            else
              brush.id = nil
              brush.picked_tile = nil
              brush.picked_index = 0
            end
          end
        end
        if love.mouse.isDown(2) and not selector_open then
          if brush.mode ~= "picking" then
            if #hovered >= 1 then
              brush.picked_tile = tileid
              if brush.picked_tile == tileid and brush.picked_index > 0 then
                local new_index = brush.picked_index + 1
                if new_index > #hovered then
                  new_index = 1
                end
                brush.picked_index = new_index
                brush.id = hovered[new_index].tile
              else
                brush.id = hovered[1].tile
                brush.picked_index = 1
              end
              brush.mode = "picking"
            else
              brush.id = nil
              brush.picked_tile = nil
              brush.picked_index = 0
            end
          end
        end
      end
    end
  end

  max_layer = 1
  units_by_layer = {}
  for _,unit in ipairs(units) do
    if not units_by_layer[unit.layer] then
      units_by_layer[unit.layer] = {}
    end

    table.insert(units_by_layer[unit.layer], unit)
    max_layer = math.max(max_layer, unit.layer)
  end

  if not love.mouse.isDown(1) then
    if brush.mode == "placing" or brush.mode == "erasing" then
      brush.mode = "none"
    end
  end
  if not love.mouse.isDown(2) then
    if brush.mode == "picking" then
      brush.mode = "none"
    end
  end
end

function scene.getTransform()
  local transform = love.math.newTransform()

  local roomwidth, roomheight

  if not selector_open then
    roomwidth = mapwidth * TILE_SIZE
    roomheight = mapheight * TILE_SIZE
  else
    roomwidth = tile_grid_width * TILE_SIZE
    roomheight = tile_grid_height * TILE_SIZE
  end

  local screenwidth = love.graphics.getWidth()
  local screenheight = love.graphics.getHeight()

  local scale = 1
  if roomwidth >= screenwidth or roomheight >= screenheight then
    scale = 0.5
  elseif screenwidth >= roomwidth * 4 and screenheight >= roomheight * 4 then
    scale = 4
  elseif screenwidth >= roomwidth * 2 and screenheight >= roomheight * 2 then
    scale = 2
  end

  local scaledwidth = screenwidth * (1/scale)
  local scaledheight = screenheight * (1/scale)

  transform:scale(scale, scale)
  transform:translate(scaledwidth / 2 - roomwidth / 2, scaledheight / 2 - roomheight / 2)

  return transform
end

last_hovered_tile = {0,0}
function scene.draw(dt)
  love.graphics.setBackgroundColor(getPaletteColor(1, 0))

  local roomwidth, roomheight
  if not selector_open then
    roomwidth = mapwidth * TILE_SIZE
    roomheight = mapheight * TILE_SIZE
  else
    roomwidth = tile_grid_width * TILE_SIZE
    roomheight = tile_grid_height * TILE_SIZE
  end

  if is_mobile then
    local cursorx, cursory = love.mouse.getPosition()
    love.graphics.draw(system_cursor, cursorx, cursory)
  end

  love.graphics.push()
  love.graphics.applyTransform(scene.getTransform())

  love.graphics.setColor(getPaletteColor(0, 4))
  love.graphics.rectangle("fill", 0, 0, roomwidth, roomheight)

  if not selector_open then
    for i=1,max_layer do
      if units_by_layer[i] then
        for _,unit in ipairs(units_by_layer[i]) do
          local sprite = sprites[unit.sprite]
          if not sprite then sprite = sprites["wat"] end
          
          local rotation = 0
          if unit.rotate then
            rotation = (unit.dir - 1) * 45
          end
          
          if #unit.color == 3 then
            love.graphics.setColor(unit.color[1]/255, unit.color[2]/255, unit.color[3]/255)
          else
            love.graphics.setColor(getPaletteColor(unit.color[1], unit.color[2]))
          end
          love.graphics.draw(sprite, (unit.x + 0.5)*TILE_SIZE, (unit.y + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
        end
      end
    end
  else
    for x=0,tile_grid_width-1 do
      for y=0,tile_grid_height-1 do
        local gridid = x + y * tile_grid_width
        local i = tile_grid[gridid]
          if i ~= nil then
          local tile = tiles_list[i]
          local sprite = sprites[tile.sprite]
          if not sprite then sprite = sprites["wat"] end

          local x = tile.grid[1]
          local y = tile.grid[2]

          if #tile.color == 3 then
            love.graphics.setColor(tile.color[1]/255, tile.color[2]/255, tile.color[3]/255)
          else
            love.graphics.setColor(getPaletteColor(tile.color[1], tile.color[2]))
          end
          love.graphics.draw(sprite, (x + 0.5)*TILE_SIZE, (y + 0.5)*TILE_SIZE, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)

          if brush.id == i then
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("line", x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
          end
        elseif gridid == 0 and brush.id == nil then
          love.graphics.setColor(1, 0, 0)
          love.graphics.rectangle("line", x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end
      end
    end
  end

  local hx,hy = getHoveredTile()
  if hx ~= nil then
    if brush.id and not selector_open then
      local sprite = sprites[tiles_list[brush.id].sprite]
      if not sprite then sprite = sprites["wat"] end

      local rotation = 0
      if tiles_list[brush.id].rotate then
        rotation = (brush.dir - 1) * 45
      end

      local color = tiles_list[brush.id].color
      if #color == 3 then
        love.graphics.setColor(color[1]/255, color[2]/255, color[3]/255, 0.25)
      else
        local r, g, b, a = getPaletteColor(color[1], color[2])
        love.graphics.setColor(r, g, b, a * 0.25)
      end

      love.graphics.draw(sprite, (hx + 0.5)*TILE_SIZE, (hy + 0.5)*TILE_SIZE, math.rad(rotation), 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
    end

    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("line", hx * TILE_SIZE, hy * TILE_SIZE, TILE_SIZE, TILE_SIZE)

    last_hovered_tile = {hx, hy}
  end

  if selector_open then
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(last_hovered_tile[1] .. ', ' .. last_hovered_tile[2], 0, roomheight)
  end

  love.graphics.pop()

  local btnx = 0
  for _,btn in ipairs(buttons) do
    local sprite = sprites["ui/" .. btn[1]]

    if button_pressed then
      if button_pressed == btn then
        love.graphics.setColor(0.5, 0.5, 0.5)
      else
        love.graphics.setColor(1, 1, 1)
      end
    else
      if button_over == btn then
        love.graphics.setColor(0.8, 0.8, 0.8)
      else
        love.graphics.setColor(1, 1, 1)
      end
    end

    love.graphics.draw(sprite, btnx, 0)

    btnx = btnx + sprite:getWidth() + 4
  end

  love.graphics.setFont(name_font)
  love.graphics.setColor(1, 1, 1)

  love.graphics.printf(level_name, 0, name_font:getLineHeight() / 2, love.graphics.getWidth(), "center")

  love.graphics.setColor(1, 1, 1, saved_popup.alpha)
  if is_mobile then
    love.graphics.draw(saved_popup.sprite, 44, 40 + saved_popup.y)
  else
    love.graphics.draw(saved_popup.sprite, 0, 40 + saved_popup.y)
  end

  love.graphics.push()
  love.graphics.translate(settings_pos.x, 0)

  love.graphics.setColor(0.1, 0.1, 0.1, 1)
  love.graphics.rectangle("fill", 0, 0, 320, height)
  love.graphics.setColor(1, 1, 1, 1)
  settings:draw()

  love.graphics.pop()
end

function scene.textInput(t)
  if settings then
    settings:textinput(t)
  end
end

function scene.updateMap()
  map_ver = 1
  map = ""
  for x = 0, mapwidth-1 do
    for y = 0, mapheight-1 do
      local tileid = x + y * mapwidth
      if units_by_tile[tileid] then
        for _,unit in ipairs(units_by_tile[tileid]) do
          map = map .. love.data.pack("string", PACK_UNIT_V1, unit.tile, unit.x, unit.y, unit.dir)
        end
      end
    end
  end
end

function scene.saveLevel()
  scene.updateMap()

  local mapdata = love.data.compress("string", "zlib", map)
  local savestr = love.data.encode("string", "base64", mapdata)

  local data = {
    name = level_name,
    palette = current_palette,
    music = map_music,
    width = mapwidth,
    height = mapheight,
    version = 1,
    map = savestr
  }

  love.filesystem.createDirectory("levels")
  love.filesystem.write("levels/" .. level_name .. ".bab", json.encode(data))

  addTween(tween.new(0.25, saved_popup, {y = 0, alpha = 1}, 'outQuad'), "saved_popup")
  addTick("saved_popup", 1, function()
    addTween(tween.new(0.5, saved_popup, {y = 16, alpha = 0}), "saved_popup")
  end)
end

function scene.loadLevel()
  new_scene = loadscene
end

function scene.openSettings()
  if not settings_open then
    settings_open = true

    input_name.text = level_name
    input_palette.text = current_palette
    input_music.text = map_music
    input_width.text = tostring(mapwidth)
    input_height.text = tostring(mapheight)

    addTween(tween.new(0.5, settings_pos, {x = 0}, 'outBounce'), "settings")
  else
    settings_open = false
    addTween(tween.new(0.5, settings_pos, {x = -320}, 'outCubic'), "settings")
  end
end

function scene.saveSettings()
  level_name = input_name.text
  current_palette = input_palette.text
  map_music = input_music.text

  scene.updateMap()

  mapwidth = tonumber(input_width.text)
  mapheight = tonumber(input_height.text)
  
  clear()
  loadMap()
  resetMusic(map_music, 0.1)

  scene.updateMap()
end

function love.filedropped(file)
  local data = file:read()
  local mapdata = json.decode(data)

  local loaddata = love.data.decode("string", "base64", mapdata.map)
  local mapstr = love.data.decompress("string", "zlib", loaddata)

  level_name = mapdata.name
  current_palette = mapdata.palette or "default"
  map_music = mapdata.music or "bab be u them"
  mapwidth = mapdata.width
  mapheight = mapdata.height
  map_ver = mapdata.version or 0

  if map_ver == 0 then
    map = loadstring("return " .. mapstr)()
  else
    map = mapstr
  end

  clear()
  loadMap()

  brush.picked_tile = nil
  brush.picked_index = 0
end

return scene