local scene = {}

world_parent = ""
world = ""

local title_font, label_font, icon_font, name_font
local components

local scrollx = 0
local scrolly = 0
local scrolloffset = 0
local scrollvel = 0

local full_height = 0

function scene.load()
  clear()
  resetMusic(current_music, 0.1)
  selected_levels = {}
  scene.buildUI()
  love.mouse.setGrabbed(false)
  love.keyboard.setKeyRepeat(true)

  presence = {
    state = "in "..(load_mode == "edit" and "editor" or "game"),
    details = "browsing levels. .......... . .. ...",
    largeImageKey = "cover",
    largeimageText = "bab be u",
    smallImageKey = load_mode == "edit" and "edit" or "icon",
    smallImageText = load_mode == "edit" and "editor" or "game",
    startTimestamp = now
  }
end

function scene.update(dt)
  scrolloffset = scrolloffset + scrollvel * dt

  scrollvel = scrollvel - scrollvel * math.min(dt * 10, 1)
  if scrollvel < 0.1 and scrollvel > -0.1 then scrollvel = 0 end
  debugDisplay("scrollvel", scrollvel)
  debugDisplay("scrolloffset", scrolloffset)

  local scroll_height = math.max(0, full_height - love.graphics.getHeight())
  if scrolloffset > scroll_height then
    scrolloffset = scroll_height
    scrollvel = 0
  elseif scrolloffset < 0 then
    scrolloffset = 0
    scrollvel = 0
  end

  scrollx = scrollx+75*dt
  scrolly = scrolly+75*dt
end

function scene.keyPressed(key)
  if key == "escape" then
    if load_mode == "select" then
      new_scene = editor
      selected_level = nil
    elseif world ~= "" then
      world_parent = ""
      world = ""
      scene.buildUI()
    else
      new_scene = menu
    end
  end
end

function scene.wheelMoved(whx, why) -- The wheel moved, Why?
  scrollvel = scrollvel + (-191 * why * 3)
  -- why = "well i dont fuckin know the person who moved it probably wanted it to move"
end

function scene.getTransform()
  local transform = love.math.newTransform()

  transform:translate(0, -scrolloffset)

  return transform
end

function scene.draw()
  love.graphics.clear(0.10, 0.1, 0.11, 1)

  local bgsprite = sprites["ui/menu_background"]

  local cells_x = math.ceil(love.graphics.getWidth() / bgsprite:getWidth())
  local cells_y = math.ceil(love.graphics.getHeight() / bgsprite:getHeight())

  love.graphics.setColor(1, 1, 1, 0.6)
  setRainbowModeColor(love.timer.getTime()/6, .4)
  
  for x = -1, cells_x do
    for y = -1, cells_y do
      local draw_x = scrollx % bgsprite:getWidth() + x * bgsprite:getWidth()
      local draw_y = scrolly % bgsprite:getHeight() + y * bgsprite:getHeight()
      love.graphics.draw(bgsprite, draw_x, draw_y)
    end
  end

  -- ui
  love.graphics.push()
  love.graphics.applyTransform(scene.getTransform())
  love.graphics.setColor(1, 1, 1, 1)

  for i,o in ipairs(components) do
    o:draw()
  end

  love.graphics.pop()
  gooi.draw()
end

function scene.loadLevel(data, new)
  local loaddata = love.data.decode("string", "base64", data.map)
  level_compression = data.compression or "zlib"
  local mapstr = level_compression == "zlib" and love.data.decompress("string", "zlib", loaddata) or loaddata

  loaded_level = not new

  level_name = data.name
  level_author = data.author or ""
  current_palette = data.palette or "default"
  map_music = data.music or "bab be u them"
  mapwidth = data.width
  mapheight = data.height
  map_ver = data.version or 0

  if map_ver == 0 then
    maps = {{0, loadstring("return " .. mapstr)()}}
  else
    maps = {{map_ver, mapstr}}
  end

  if load_mode == "edit" then
    new_scene = editor
  elseif load_mode == "play" then
    new_scene = game
  end

  local dir = "levels/"
  if world ~= "" then dir = world_parent .. "/" .. world .. "/" end
  if love.filesystem.getInfo(dir .. level_name .. ".png") then
    icon_data = love.image.newImageData(dir .. level_name .. ".png")
  else
    icon_data = nil
  end
end

function scene.buildUI()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

  components = {}

  local oy = 4
  if world ~= "" then
    local title_width, title_height = ui.fonts.title:getWidth(world:upper()), ui.fonts.title:getHeight()
    local world_label = ui.text_input.new()
      :setText(world:upper())
      :setFont(ui.fonts.title)
      :setPos(0, oy)
      :setSize(love.graphics.getWidth(), title_height)
      :onReturn(scene.renameWorld)
      :onTextEdited(function(o) o:setText(o:getText():upper()) end)
    if load_mode == "edit" and world_parent ~= "officialworlds" and world ~= "" then
      world_label:setTextHoverColor(0.75, 0.75, 0.75)
      world_label:onReleased(function(o) ui.setEditing(o) end)
    end
    table.insert(components, world_label)
    oy = oy + title_height + 24
  end

  if world == "" then
    if load_mode ~= "select" then
      local worlds = scene.searchDir("officialworlds", "world")
      if #worlds > 0 then
        local label_width, label_height = ui.fonts.category:getWidth("Official Worlds"), ui.fonts.category:getHeight()
        table.insert(components, ui.component.new()
          :setText("Official Worlds")
          :setFont(ui.fonts.category)
          :setPos(0, oy)
          :setSize(love.graphics.getWidth(), label_height))
        oy = oy + label_height + 8

        oy = scene.addButtons("world", worlds, oy)
      end

      worlds = scene.searchDir("worlds", "world")
      if #worlds > 0 or load_mode == "edit" then
        label_width, label_height = ui.fonts.category:getWidth("Custom Worlds"), ui.fonts.category:getHeight()
        table.insert(components, ui.component.new()
          :setText("Custom Worlds")
          :setFont(ui.fonts.category)
          :setPos(0, oy)
          :setSize(love.graphics.getWidth(), label_height))
        oy = oy + label_height + 8

        if load_mode == "edit" and world_parent ~= "officialworlds" then
          table.insert(worlds, 1, {
            create = true,
            name = "new world",
            path = "worlds",
            icon = sprites["ui/create icon"]
          })
        end

        oy = scene.addButtons("world", worlds, oy)
      end
    end

    local levels = scene.searchDir("levels", "level")
    if #levels > 0 or load_mode == "edit" then
      label_width, label_height = ui.fonts.category:getWidth("Custom Levels"), ui.fonts.category:getHeight()
      table.insert(components, ui.component.new()
        :setText("Custom Levels")
        :setFont(ui.fonts.category)
        :setPos(0, oy)
        :setSize(love.graphics.getWidth(), label_height))
      oy = oy + label_height + 8

      if load_mode == "edit" and world_parent ~= "officialworlds" then
        table.insert(levels, 1, {
          create = true,
          file = default_map,
          data = json.decode(default_map),
          icon = sprites["ui/create icon"]
        })
      end

      oy = scene.addButtons("level", levels, oy)
    end
  else
    local levels = scene.searchDir(world_parent .. "/" .. world, "level")
    if #levels > 0 or load_mode == "edit" then
      label_width, label_height = ui.fonts.category:getWidth("Levels"), ui.fonts.category:getHeight()
      table.insert(components, ui.component.new()
        :setText("Levels")
        :setFont(ui.fonts.category)
        :setPos(0, oy)
        :setSize(love.graphics.getWidth(), label_height))
      oy = oy + label_height + 8

      if load_mode == "edit" and world_parent ~= "officialworlds" then
        table.insert(levels, 1, {
          create = true,
          file = default_map,
          data = json.decode(default_map),
          icon = sprites["ui/create icon"]
        })
      end

      oy = scene.addButtons("level", levels, oy)
    end
  end

  full_height = oy + 8
end

function scene.searchDir(dir, type)
  local ret = {}
  local dirs = love.filesystem.getDirectoryItems(dir)

  local filtered = filter(dirs, function(file)
    if type == "world" then
      return love.filesystem.getInfo(dir .. "/" .. file).type == "directory"
    elseif type == "level" then
      return file:ends(".bab")
    end
  end)

  table.sort(filtered, function(a, b)
    local a_, b_ = a, b
    if type == "level" then
      a_ = a:sub(1, -5)
      b_ = b:sub(1, -5)
    end
    return a_ < b_
  end)

  for _,file in ipairs(filtered) do
    local t = {}
    if type == "world" then
      t.name = file
      t.path = dir
      if love.filesystem.getInfo(dir .. "/" .. file .. "/icon.png") then
        t.icon = love.graphics.newImage(dir .. "/" .. file .. "/icon.png")
      end
    elseif type == "level" then
      t.file = file:sub(1, -5)
      t.data = json.decode(love.filesystem.read(dir .. "/" .. file))
      if love.filesystem.getInfo(dir .. "/" .. t.file .. ".png") then
        t.icon = love.graphics.newImage(dir .. "/" .. t.file .. ".png")
      else
        t.icon = sprites["ui/default icon"]
      end
    end
    table.insert(ret, t)
  end
  return ret
end

function scene.addButtons(type, list, oy)
  local sw = love.graphics.getWidth()
  local btn_width, btn_height
  if type == "world" then
    btn_width, btn_height = sprites["ui/world box"]:getWidth(), sprites["ui/world box"]:getHeight()
  elseif type == "level" then
    btn_width, btn_height = sprites["ui/level box"]:getWidth(), sprites["ui/level box"]:getHeight()
  end
  local final_list = {}
  for i,v in ipairs(list) do
    local row = math.floor((i - 1) / math.floor(sw / (btn_width + 8))) + 1
    if not final_list[row] then
      final_list[row] = {}
    end
    table.insert(final_list[row], v)
  end
  for row,cols in ipairs(final_list) do
    local width = (btn_width * #cols) + ((#cols - 1) * 8)
    local ox = (sw / 2) - (width / 2)
    for col,v in ipairs(cols) do
      local button
      if type == "world" then
        button = ui.world_button.new(v.path):setName(v.name):setIcon(v.icon):setPos(ox, oy)
        if v.create then
          button:onReleased(scene.createWorld)
        else
          button:onReleased(scene.selectWorld)
        end
      elseif type == "level" then
        button = ui.level_button.new(v.file, v.data.extra):setName(v.data.name):setIcon(v.icon):setPos(ox, oy)
        if v.create then
          button:onReleased(scene.createLevel)
        else
          button:onReleased(scene.selectLevel)
        end
      end
      table.insert(components, button)
      ox = ox + btn_width + 8
    end
    oy = oy + btn_height + 8
  end
  return oy
end

function scene.resize(w, h)
  scene.buildUI()
end

function scene.renameWorld(o, text)
  renameDir(world_parent .. "/" .. world, world_parent .. "/" .. text:lower())
  world = text:lower()
  scene.buildUI()
end

function scene.createWorld(o)
  world = o:getName()
  world_parent = o.data.file
  love.filesystem.createDirectory(world_parent .. "/" .. world)
  scene.buildUI()
end

function scene.createLevel(o)
  loaded_level = false
  loadLevels({default_map}, load_mode)
end

function scene.selectWorld(o, button)
  if button == 1 then
    if o.data.deleting then
      o.data.deleting = nil
      o:setColor()
      o:setSprite(sprites["ui/world box"])
    else
      world = o:getName()
      world_parent = o.data.file
      scene.buildUI()
    end
  elseif button == 2 then
    if o.data.file ~= "officialworlds" then
      if not o.data.deleting then
        o.data.deleting = 1
        o:setColor(1, 1, 1)
        o:setSprite(sprites["ui/world box delete"])
        playSound("move")
      elseif o.data.deleting == 1 then
        o.data.deleting = 2
        o:setSprite(sprites["ui/world box deleteconfirm"])
        playSound("unlock")
      elseif o.data.deleting == 2 then
        deleteDir(o.data.file .. "/" .. o:getName())
        playSound("break")
        shakeScreen(0.3, 0.1)
        scene.buildUI()
      end
    end
  end
end

function scene.selectLevel(o, button)
  if button == 1 then
    if o.data.deleting then
      o.data.deleting = nil
      o:setColor()
      o:setSprite(sprites["ui/level box"])
    else
      if love.keyboard.isDown("lshift") then
        if o.data.selected then
          o:setColor()
          o.data.selected = false
          removeFromTable(selected_levels, o.data.file)
        else
          o:setColor(0.5, 0.25, 1)
          o.data.selected = true
          table.insert(selected_levels, o.data.file)
        end
      else
        if load_mode == "select" then
          new_scene = editor
          selected_level.level = o.data.file
          selected_level.name = o:getName()
        else
          if not o.data.selected then
            o.data.selected = true
            table.insert(selected_levels, o.data.file)
          end
          loadLevels(selected_levels, load_mode)
        end
      end
    end
  elseif button == 2 then
    if #selected_levels > 0 then
      for _,o in ipairs(components) do
        if o.data.selected then
          o:setColor()
          o.data.selected = false
        end
      end
      selected_levels = {}
    elseif world_parent ~= "officialworlds" then
      if not o.data.deleting then
        o.data.deleting = 1
        o:setColor(1, 1, 1)
        o:setSprite(sprites["ui/level box delete"])
        playSound("move")
      elseif o.data.deleting == 1 then
        o.data.deleting = 2
        o:setSprite(sprites["ui/level box deleteconfirm"])
        playSound("unlock")
      elseif o.data.deleting == 2 then
        local dir = "levels/"
        if world ~= "" then dir = world_parent .. "/" .. world .. "/" end
        love.filesystem.remove(dir .. o.data.file .. ".bab")
        love.filesystem.remove(dir .. o.data.file .. ".png")
        playSound("break")
        shakeScreen(0.3, 0.1)
        scene.buildUI()
      end
    end
  end
end

return scene