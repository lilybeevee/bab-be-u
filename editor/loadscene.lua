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

local scroll_height

local oldmousex, oldmousey = love.mouse.getPosition()

function scene.load()
  metaClear()
  clear()
  was_using_editor = false
  resetMusic(current_music, 0.8)
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
  mobile_scroll_time = 0 -- when you started to press
  mobile_scroll_start = 0 -- where you started to press
  mobile_scroll_pos = 0 -- where the scroll bar started
end
mobile_scroll_delay = 0.1 -- how long you have to press to not click on a level

function scene.update(dt)
  scrolloffset = scrolloffset + scrollvel * dt

  if is_mobile then
    if love.mouse.isDown(1) then
      x, y = love.mouse.getPosition()

      local scrollbutton = false

      if pointInside(x, y, love.graphics.getWidth()-10-sprites["ui/arrow up"]:getWidth(), 10, sprites["ui/arrow up"]:getWidth(), sprites["ui/arrow up"]:getHeight()) and mobile_scroll_timer == 0 then
        scrollvel = scrollvel - 100
        scrollbutton = true
      end
      if pointInside(x, y, love.graphics.getWidth()-10-sprites["ui/arrow down"]:getWidth(), love.graphics.getHeight()-10-sprites["ui/arrow down"]:getHeight(), sprites["ui/arrow down"]:getWidth(), sprites["ui/arrow down"]:getHeight()) and mobile_scroll_timer == 0 then
        scrollvel = scrollvel + 100
        scrollbutton = true
      end

      if not scrollbutton then
        scrolloffset = mobile_scroll_pos + (mobile_scroll_start - y)
      end
    end
  end

  scrollvel = scrollvel - scrollvel * math.min(dt * 10, 1)
  if scrollvel < 0.1 and scrollvel > -0.1 then scrollvel = 0 end
  debugDisplay("scrollvel", scrollvel)
  debugDisplay("scrolloffset", scrolloffset)

  scroll_height = math.max(0, full_height - love.graphics.getHeight())
  debugDisplay("scrollheight", scroll_height)

  if mouseOverBox(love.graphics.getWidth()-5, 0, 5, love.graphics.getHeight()) and love.mouse.isDown(1) and not is_mobile then
    scrolloffset = love.mouse.getY()/(love.graphics.getHeight()-20)*scroll_height
  end

  if scrolloffset > scroll_height then
    scrolloffset = scroll_height
    scrollvel = 0
  elseif scrolloffset < 0 then
    scrolloffset = 0
    scrollvel = 0
  end

  scrollx = scrollx+75*dt
  scrolly = scrolly+75*dt

  oldmousex, oldmousey = love.mouse.getPosition()
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
  elseif key == "f12" then
    print("Entering Unit Test mode.")
    runUnitTests()
  end
end

function runUnitTests()
  unit_tests = true
  local levels = scene.searchDir(world_parent .. "/" .. world, "level")
  local fail_levels = {}
  local succ_levels = {}
  local noreplay_levels = {}
  load_mode = "play"
  for _,v in ipairs(levels) do
    scene.loadLevel(v.data, "play")
    game.load()
    tryStartReplay()
    if replay_playback then
      replay_playback_interval = 0
      local still_going = true;
      while (still_going) do
        still_going = doReplay(0)
      end
      if not won_this_session then
        table.insert(fail_levels, v.file)
      else
        table.insert(succ_levels, v.file)
      end
    else
      table.insert(noreplay_levels, v.file)
    end
  end
  print ("Unit tested " .. tostring(#succ_levels + #fail_levels) .. " levels!");
  print (tostring(#noreplay_levels) .. " levels lacked a replay: " .. dump(noreplay_levels));
  print (tostring(#succ_levels) .. " levels passed: " .. dump(succ_levels));
  print (tostring(#fail_levels) .. " levels failed: " .. dump(fail_levels));
  unit_tests = false
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
  love.graphics.clear(0, 0, 0, 1)

  local bgsprite = sprites["ui/menu_background"]

  local cells_x = math.ceil(love.graphics.getWidth() / bgsprite:getWidth())
  local cells_y = math.ceil(love.graphics.getHeight() / bgsprite:getHeight())

  love.graphics.setColor(1, 1, 1, 0.6)
  setRainbowModeColor(love.timer.getTime()/6, .4)
  
  if not spookmode then
    for x = -1, cells_x do
      for y = -1, cells_y do
        local draw_x = scrollx % bgsprite:getWidth() + x * bgsprite:getWidth()
        local draw_y = scrolly % bgsprite:getHeight() + y * bgsprite:getHeight()

        if shake_dur > 0.1 then
          draw_x = draw_x + math.random(-shake_intensity*16, shake_intensity*16)
          draw_y = draw_y + math.random(-shake_intensity*16, shake_intensity*16)
        end

        love.graphics.draw(bgsprite, draw_x, draw_y)
      end
    end
  end

  -- ui
  love.graphics.push()
  love.graphics.applyTransform(scene.getTransform())
  love.graphics.setColor(1, 1, 1, 1)

  for i,o in ipairs(components) do
    local xoffset = 0
    local yoffset = 0

    if shake_dur > 0.1 then
      xoffset = xoffset + math.random(-shake_intensity*6, shake_intensity*6)
      yoffset = yoffset + math.random(-shake_intensity*6, shake_intensity*6)
    end

    love.graphics.push()
    love.graphics.translate(xoffset, yoffset)
    o.rainbowoffset = i
    o:draw()
    love.graphics.pop()
  end

  love.graphics.pop()
  
  if is_mobile then
    love.graphics.setColor(0.6,0.6,0.6)
    love.graphics.rectangle("fill", love.graphics.getWidth()-10-sprites["ui/arrow up"]:getWidth(), 10, sprites["ui/arrow up"]:getWidth(), love.graphics.getHeight()-20)

    love.graphics.setColor(0.9,0.9,0.9)
    love.graphics.rectangle("fill", love.graphics.getWidth()-10-sprites["ui/arrow up"]:getWidth(), 10+sprites["ui/arrow up"]:getHeight()+scrolloffset/scroll_height*(love.graphics.getHeight()-20-sprites["ui/arrow up"]:getHeight()*2.5), sprites["ui/arrow up"]:getWidth(), sprites["ui/arrow up"]:getHeight()/2)

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", love.graphics.getWidth()-10-sprites["ui/arrow ul"]:getWidth(), 10, sprites["ui/arrow up"]:getWidth(), sprites["ui/arrow up"]:getHeight())
    love.graphics.setColor(0.1,0.1,0.1)
    love.graphics.draw(sprites["ui/arrow up"], love.graphics.getWidth()-10-sprites["ui/arrow up"]:getWidth(), 10)

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", love.graphics.getWidth()-10-sprites["ui/arrow down"]:getWidth(), love.graphics.getHeight()-10-sprites["ui/arrow down"]:getHeight(), sprites["ui/arrow down"]:getWidth(), sprites["ui/arrow down"]:getHeight())
    love.graphics.setColor(0.1,0.1,0.1)
    love.graphics.draw(sprites["ui/arrow down"], love.graphics.getWidth()-10-sprites["ui/arrow down"]:getWidth(), love.graphics.getHeight()-10-sprites["ui/arrow down"]:getHeight())
  elseif scroll_height > 0 then
    love.graphics.setColor(0.6,0.6,0.6,0.3)
    love.graphics.rectangle("fill", love.graphics.getWidth()-5, 0, 5, love.graphics.getHeight())

    love.graphics.setColor(0.6,0.6,0.6)
    love.graphics.rectangle("fill", love.graphics.getWidth()-5, scrolloffset/scroll_height*(love.graphics.getHeight()-20), 5, 20)
  end

  gooi.draw()
end

function scene.loadLevel(data, new)
  local loaddata = love.data.decode("string", "base64", data.map)
  level_compression = data.compression or "zlib"
  local mapstr = loadMaybeCompressedData(loaddata)

  loaded_level = not new

  level_name = data.name
  level_author = data.author or ""
  level_extra = data.extra
  current_palette = data.palette or "default"
  map_music = data.music or "bab be u them"
  mapwidth = data.width
  mapheight = data.height
  map_ver = data.version or 0
  level_parent_level = data.parent_level or ""
  level_next_level = data.next_level or ""
  level_is_overworld = data.is_overworld or false
  level_puffs_to_clear = data.puffs_to_clear or 0
  level_background_sprite = data.background_sprite or ""

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
    if load_mode == "play" and love.filesystem.getInfo(world_parent .. "/" .. world .. "/" .. "overworld.txt") then
      local overworld_file_name = love.filesystem.read(world_parent .. "/" .. world .. "/" .. "overworld.txt")
      if love.filesystem.getInfo(world_parent .. "/" .. world .. "/" .. overworld_file_name .. ".bab") then
        loadLevels({overworld_file_name}, "play")
      end
    end
  
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
        local label_width, label_height = ui.fonts.category:getWidth(spookmode and "no" or "Official Worlds"), ui.fonts.category:getHeight()
        table.insert(components, ui.component.new()
          :setText(spookmode and "no" or "Official Worlds")
          :setFont(ui.fonts.category)
          :setPos(0, oy)
          :setSize(love.graphics.getWidth(), label_height))
        oy = oy + label_height + 8

        oy = scene.addButtons("world", worlds, oy)
      end

      worlds = scene.searchDir("worlds", "world")
      if #worlds > 0 or load_mode == "edit" then
        label_width, label_height = ui.fonts.category:getWidth(spookmode and "stop" or "Official Worlds"), ui.fonts.category:getHeight()
        table.insert(components, ui.component.new()
          :setText(spookmode and "stop" or "Official Worlds")
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
      label_width, label_height = ui.fonts.category:getWidth(spookmode and "what is this" or "Official Worlds"), ui.fonts.category:getHeight()
      table.insert(components, ui.component.new()
        :setText(spookmode and "what is this" or "Official Worlds")
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
      if spookmode then
      t.icon = love.graphics.newImage("assets/sprites/ui/bxb bx x.jpg")
      elseif love.filesystem.getInfo(dir .. "/" .. t.file .. ".png") then
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
  if is_mobile and love.timer.getTime() - mobile_scroll_time > mobile_scroll_delay then return end
  world = o:getName()
  world_parent = o.data.file
  love.filesystem.createDirectory(world_parent .. "/" .. world)
  scene.buildUI()
end

function scene.createLevel(o)
  if is_mobile and love.timer.getTime() -mobile_scroll_time > mobile_scroll_delay then return end
  loaded_level = false
  loadLevels({default_map}, load_mode)
	level_compression = "zlib"
end

function scene.selectWorld(o, button)
  if is_mobile and love.timer.getTime() -mobile_scroll_time > mobile_scroll_delay then return end
  if button == 1 then
    if o.data.deleting then
      o.data.deleting = 0
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
        shakeScreen(0.4, 0.2)
        playSound("move")
      elseif o.data.deleting == 1 then
        o.data.deleting = 2
        o:setSprite(sprites["ui/world box delete 2"])
        shakeScreen(0.4, 0.3)
        playSound("unlock")
      elseif o.data.deleting == 2 then
        deleteDir(o.data.file .. "/" .. o:getName())
        playSound("break")
        shakeScreen(0.5, 0.4)
        scene.buildUI()
      end
    else
      playSound("fail")
    end
  end
end

function scene.mousePressed(x, y, button)
  if is_mobile then
    local scrollbutton = false

    if pointInside(x, y, love.graphics.getWidth()-10-sprites["ui/arrow up"]:getWidth(), 10, sprites["ui/arrow up"]:getWidth(), sprites["ui/arrow up"]:getHeight()) then
      scrollvel = scrollvel - 400
      scrollbutton = true
    end
    if pointInside(x, y, love.graphics.getWidth()-10-sprites["ui/arrow down"]:getWidth(), love.graphics.getHeight()-10-sprites["ui/arrow down"]:getHeight(), sprites["ui/arrow down"]:getWidth(), sprites["ui/arrow down"]:getHeight()) then
      scrollvel = scrollvel + 400
      scrollbutton = true
    end

    if not scrollbutton then
      mobile_scroll_start = y
      mobile_scroll_pos = scrolloffset
      mobile_scroll_time = love.timer.getTime()
    end
  end
end

function scene.selectLevel(o, button)
  if is_mobile and love.timer.getTime() -mobile_scroll_time > mobile_scroll_delay then return end
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
        shakeScreen(0.3, 0.1)
        playSound("move")
      elseif o.data.deleting == 1 then
        o.data.deleting = 2
        o:setSprite(sprites["ui/level box delete 2"])
        shakeScreen(0.3, 0.2)
        playSound("unlock")
      elseif o.data.deleting == 2 then
        local dir = "levels/"
        if world ~= "" then dir = world_parent .. "/" .. world .. "/" end
        love.filesystem.remove(dir .. o.data.file .. ".bab")
        love.filesystem.remove(dir .. o.data.file .. ".png")
        playSound("break")
        shakeScreen(0.4, 0.3)
        scene.buildUI()
      end
    else
      playSound("fail")
    end
  end
end

return scene
