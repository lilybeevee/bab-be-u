local scene = {}

local paintedtiles = 0
local buttons = {}
local button_over = nil
local name_font = nil
local typing_name = false
local ignore_mouse = true

local settings
local input_name, input_palette, input_width, input_height

function scene.load()
  brush = nil
  selector_open = false
  
  if not level_name then
    level_name = "unnamed"
  end
  typing_name = false
  ignore_mouse = true

  buttons = {}
  --table.insert(buttons, {"load", scene.loadLevel})
  --table.insert(buttons, {"save", scene.saveLevel})
  --table.insert(buttons, {"cog", scene.openSettings})

  name_font = love.graphics.newFont(24)

  clear()
  resetMusic(current_music, 0.1)
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
end

function scene.keyPressed(key)
  if settings then
    settings:keypressed(key)
  else
    if key == "s" then
      scene.saveLevel()
    elseif key == "l" then
      scene.loadLevel()
    end
  end

  if key == "tab" then
    selector_open = not selector_open
    if selector_open then
      presence["details"] = "browsing selector"
    end
  end
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
  
  if settings then
    --local mousex, mousey = scene.getTransform():transformPoint(love.mouse.getPosition())
    --settings:updateMouse(mousex, mousey, love.mouse.isDown(1))

    settings.layout:reset(10, 10)
    settings.layout:padding(4, 4)

    settings:Label("Level Name", {align = "center"}, settings.layout:row(300, 24))
    local name = settings:Input(input_name, {align = "center"}, settings.layout:row())
    settings.layout:row()
    settings:Label("Level Palette", {align = "center"}, settings.layout:row(300, 24))
    local palette = settings:Input(input_palette, {align = "center"}, settings.layout:row())
    settings:Label("Level Size", {align = "center"}, settings.layout:row())
    settings.layout:push(settings.layout:row())
    settings:Input(input_width, {align = "center"}, settings.layout:col((300 - 4)/2, 24))
    settings:Input(input_height, {align = "center"}, settings.layout:col())
    settings.layout:pop()
    settings.layout:row()
    settings.layout:push(settings.layout:row())
    local save = settings:Button("Save", settings.layout:col((300 - 4*2)/3, 24))
    settings.layout:col()
    local cancel = settings:Button("Cancel", settings.layout:col())
    settings.layout:pop()

    if name.submitted then
      level_name = input_name.text
    end

    if palette.submitted then
      current_palette = input_palette.text
    end

    if save.hit then
      scene.saveSettings()
    elseif cancel.hit then
      scene.openSettings()
    end
  else
    suit.layout:reset(0, 0)
    suit.layout:padding(4, 4)

    love.graphics.setColor(1, 1, 1)

    local load_btn = suit.ImageButton(sprites["ui/load"], {color = load_color}, suit.layout:col(32, 32))
    local save_btn = suit.ImageButton(sprites["ui/save"], {color = save_color}, suit.layout:col())
    local settings_btn = suit.ImageButton(sprites["ui/cog"], {color = settings_color}, suit.layout:col())

    if load_btn.hit then
      scene.loadLevel()
    elseif save_btn.hit then
      scene.saveLevel()
    elseif settings_btn.hit then
      scene.openSettings()
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
            if #hovered > 1 or (#hovered == 1 and hovered[1].tile ~= brush) or (#hovered == 0 and brush ~= nil) then
              if brush then
                map[tileid+1] = {brush}
              else
                map[tileid+1] = {}
              end
              paintedtiles = paintedtiles + 1
              presence["details"] = "painted "..paintedtiles.." tiles"
              clear()
              loadMap()
            end
          else
            local selected = hx + hy * tile_grid_width
            if tile_grid[selected] then
              brush = tile_grid[selected]
            else
              brush = nil
            end
          end
        end
        if love.mouse.isDown(2) and not selector_open then
          if #hovered >= 1 then
            brush = hovered[1].tile
          else
            brush = nil
          end
        end
      end
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
            rotation = (unit.dir - 1) * 90
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

          if brush == i then
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("line", x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
          end
        elseif gridid == 0 and brush == nil then
          love.graphics.setColor(1, 0, 0)
          love.graphics.rectangle("line", x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end
      end
    end
  end

  local hx,hy = getHoveredTile()
  if hx ~= nil then
    if brush and not selector_open then
      local sprite = sprites[tiles_list[brush].sprite]
      if not sprite then sprite = sprites["wat"] end
      local color = tiles_list[brush].color

      if #color == 3 then
        love.graphics.setColor(color[1]/255, color[2]/255, color[3]/255, 0.25)
      else
        local r, g, b, a = getPaletteColor(color[1], color[2])
        love.graphics.setColor(r, g, b, a * 0.25)
      end
      love.graphics.draw(sprite, (hx + 0.5)*TILE_SIZE, (hy + 0.5)*TILE_SIZE, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
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

  if settings then
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, 320, height)
    love.graphics.setColor(1, 1, 1)
    settings:draw()
  end
end

function scene.textInput(t)
  if settings then
    settings:textinput(t)
  end
end

function scene.saveLevel()
  local mapdata = love.data.compress("string", "zlib", dump(map))
  local savestr = love.data.encode("string", "base64", mapdata)

  local data = {
    name = level_name,
    palette = current_palette,
    width = mapwidth,
    height = mapheight,
    map = savestr
  }

  love.filesystem.createDirectory("levels")
  love.filesystem.write("levels/" .. level_name .. ".bab", json.encode(data))
end

function scene.loadLevel()
  new_scene = loadscene
end

function scene.openSettings()
  if settings == nil then
    input_name = {text = level_name}
    input_palette = {text = current_palette}
    input_width = {text = tostring(mapwidth)}
    input_height = {text = tostring(mapheight)}

    settings = suit.new()
  else
    settings = nil
  end
end

function scene.saveSettings()
  level_name = input_name.text
  current_palette = input_palette.text

  local new_width = tonumber(input_width.text)
  local new_height = tonumber(input_height.text)
  local new_map = {}

  for x=0,new_width-1 do
    for y=0,new_height-1 do
      local tileid = (x + y * mapwidth)
      local new_id = (x + y * new_width)
      if inBounds(x, y) then
        new_map[new_id+1] = map[tileid+1]
      else
        new_map[new_id+1] = {}
      end
    end
  end

  mapwidth = new_width
  mapheight = new_height
  map = new_map

  clear()
  loadMap()
end

function love.filedropped(file)
  local data = file:read()
  local mapdata = json.decode(data)
  
  local loaddata = love.data.decode("string", "base64", mapdata.map)
  local mapstr = love.data.decompress("string", "zlib", loaddata)

  level_name = mapdata.name
  current_palette = mapdata.palette or "default"
  mapwidth = mapdata.width
  mapheight = mapdata.height
  map = loadstring("return " .. mapstr)()

  clear()
  loadMap()
end

return scene