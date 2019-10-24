local scene = {}

world_parent = ""
world = ""
sub_worlds = {}

local title_font, label_font, icon_font, name_font
local components
local searching = false
local search_string = ""

local scrollx = 0
local scrolly = 0
local scroll = {vel = 0, offset = 0}

local full_height = 0

local scroll_height

local oldmousex, oldmousey = love.mouse.getPosition()

local hasreplaylist = {}

function scene.load()
  metaClear()
  clear()
  was_using_editor = false
  resetMusic(current_music, 0.8)
  selected_levels = {}
  scene.selecting = true
  scene.buildUI()
  love.keyboard.setKeyRepeat(true)

  hasreplaylist = {}

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
  scroll.offset = scroll.offset + scroll.vel * dt

  if is_mobile then
    if love.mouse.isDown(1) then
      x, y = love.mouse.getPosition()
      scroll.offset = mobile_scroll_pos + (mobile_scroll_start - y)
    end
  end

  scroll.vel = scroll.vel - scroll.vel * math.min(dt * 10, 1)
  if scroll.vel < 0.1 and scroll.vel > -0.1 then scroll.vel = 0 end
  debugDisplay("scrollvel", scroll.vel)
  debugDisplay("scrolloffset", scroll.offset)

  scroll_height = math.max(0, full_height - love.graphics.getHeight())
  debugDisplay("scrollheight", scroll_height)

  if ui.new_selected then
    local o = ui.new_selected
    local new_y = o:getY() + o:getHeight()/2 - love.graphics.getHeight()/2
    new_y = math.max(0, math.min(scroll_height, new_y))
    if new_y ~= scroll.offset then
      addTween(tween.new(0.2, scroll, {offset = new_y}), "load_scroll")
    end
  end

  if mouseOverBox(love.graphics.getWidth()-5, 0, 5, love.graphics.getHeight()) and love.mouse.isDown(1) then
    scroll.offset = love.mouse.getY()/(love.graphics.getHeight()-20)*scroll_height
    tweens["load_scroll"] = nil
  end

  if scroll.offset > scroll_height then
    scroll.offset = scroll_height
    scroll.vel = 0
  elseif scroll.offset < 0 then
    scroll.offset = 0
    scroll.vel = 0
  end

  if settings["scroll_on"] then
    scrollx = scrollx+75*dt
    scrolly = scrolly+75*dt
  else
    scrollx, scrolly = 0,0
  end

  oldmousex, oldmousey = love.mouse.getPosition()
end

function scene.keyPressed(key)
  if key == "escape" then
    if searching then
      searching = false
      scene.buildUI()
    elseif #sub_worlds > 0 then
      table.remove(sub_worlds)
      scene.buildUI()
    elseif load_mode == "select" then
      new_scene = editor
      selected_level = nil
      sub_worlds = old_world.sub_worlds
    elseif world ~= "" then
      world_parent = ""
      world = ""
      scene.buildUI()
    else
      new_scene = menu
    end
  elseif key == "f" and love.keyboard.isDown("lctrl") and load_mode ~= "select" then
    searching = true
    search_string = ""
    scene.buildUI()
  elseif key == "tab" then
    if load_mode == "play" then
      load_mode = "edit"
      scene.buildUI()
    elseif load_mode == "edit" then
      load_mode = "play"
      scene.buildUI()
    end
  elseif key == "f1" and load_mode == "edit" then
    load_mode = "play"
    scene.buildUI()
  elseif key == "f2" and load_mode == "play" then
    load_mode = "edit"
    scene.buildUI()
  elseif key == "f12" then
    print("Entering Unit Test mode.")
    runUnitTests()
  end
end

function runUnitTests()
  local start_time = love.timer.getTime()
  unit_tests = true
  local dir = "levels/"
  if world ~= "" then dir = getWorldDir(true) .. "/" end
  local levels = searchForLevels(dir)
  local fail_levels = {}
  local succ_levels = {}
  local noreplay_levels = {}
  load_mode = "play"
  for _,v in ipairs(levels) do
    --if (v.file == "it's about time") then
      level_filename = v.file
      if #sub_worlds > 0 then
        level_filename = table.concat(sub_worlds, "/") .. "/" .. level_filename
      end
      scene.loadLevel(v.data, "play")
      game.load()
      tryStartReplay()
      if replay_playback then
        replay_playback_interval = 0
        local still_going = true
        while (still_going) do
          still_going = doReplay(0)
          cutscene_tick:update(1) --for past and other cutscenes
        end
        if not won_this_session then
          table.insert(fail_levels, v.file)
        else
          table.insert(succ_levels, v.file)
        end
      else
        table.insert(noreplay_levels, v.file)
      end
    --end
  end
  local end_time = love.timer.getTime()
  print ("Unit tested " .. tostring(#succ_levels + #fail_levels) .. " levels!")
  print (tostring(#noreplay_levels) .. " levels lacked a replay: " .. dump(noreplay_levels))
  print (tostring(#succ_levels) .. " levels passed: " .. dump(succ_levels))
  print (tostring(#fail_levels) .. " levels failed: " .. dump(fail_levels))
  print("Unit tests took: "..tostring(round((end_time-start_time))).."s")
  unit_tests = false
end

function scene.wheelMoved(whx, why) -- The wheel moved, Why?
  scroll.vel = scroll.vel + (-191 * why * 3)
  tweens["load_scroll"] = nil
  -- why = "well i dont fuckin know the person who moved it probably wanted it to move"
end

function scene.getTransform()
  local transform = love.math.newTransform()

  transform:translate(0, -scroll.offset)

  return transform
end

function scene.draw()
  love.graphics.clear(0, 0, 0, 1)

  local bgsprite 
  if getTheme() == "halloween" then
    bgsprite = sprites["ui/menu_background_halloween"]
  elseif getTheme() == "christmas" then
    bgsprite = sprites["ui/menu_background_christmas"]
  else
    bgsprite = sprites["ui/menu_background"]
  end

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

    if not ui.editing and love.keyboard.isDown("r") and o.data.type == "level" then
      local level_name = o.data.file

      if hasreplaylist[level_name] == nil then
        local dir = getWorldDir(true) .. "/"
        if not (love.filesystem.getInfo(dir .. level_name .. ".replay") or love.filesystem.getInfo("levels/" .. level_name .. ".replay")) then
          print("not found: " .. dir .. level_name .. ".replay")
          hasreplaylist[level_name] = true
        else
          hasreplaylist[level_name] = false
        end
      end

      if hasreplaylist[level_name] then
        love.graphics.setColor(1, 0, 0)
        love.graphics.draw(sprites["ui/x"], o.x-16, o.y-16)
      end
    end

    love.graphics.pop()
  end

  love.graphics.pop()
  
  if scroll_height > 0 then
    love.graphics.setColor(0.6,0.6,0.6,0.3)
    love.graphics.rectangle("fill", love.graphics.getWidth()-5, 0, 5, love.graphics.getHeight())

    love.graphics.setColor(0.6,0.6,0.6)
    love.graphics.rectangle("fill", love.graphics.getWidth()-5, scroll.offset/scroll_height*(love.graphics.getHeight()-20), 5, 20)
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
    maps = {{data = loadstring("return " .. mapstr)(), info = data}}
  else
    maps = {{data = mapstr, info = data}}
  end

  if load_mode == "edit" then
    new_scene = editor
  elseif load_mode == "play" then
    new_scene = game
  end

  local dir = "levels/"
  if world ~= "" then dir = getWorldDir(true) .. "/" end
  icon_data = getIcon(dir .. level_name)
end

function scene.buildUI()
  local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()

  components = {}

  local oy = 4
  if searching then
    local text = search_string:upper()
    if text == "" then
      text = "ENTER SEARCH"
    end

    local title_width, title_height = ui.fonts.title:getWidth(text), ui.fonts.title:getHeight()
    local search_label = ui.text_input.new()
      :setText(text)
      :setFont(ui.fonts.title)
      :setPos(0, oy)
      :setSize(love.graphics.getWidth(), title_height)
      :onReturn(function(o)
        search_string = o:getText():lower()
        scene.buildUI()
      end)
      :onTextEdited(function(o) 
        o:setText(o:getText():upper())
      end)
    search_label:setTextHoverColor(0.75, 0.75, 0.75)
    search_label:onReleased(function(o) 
      if o:getText():lower() == "enter search" then
        o:setText("")
      end
      ui.setEditing(o)
    end)

    table.insert(components, search_label)
    oy = oy + title_height + 24
  elseif world ~= "" then
    local title_text = world:upper()
    local small_text

    if #sub_worlds > 0 then
      title_text = sub_worlds[#sub_worlds]:upper()
      local less_worlds = deepCopy(sub_worlds)
      table.remove(less_worlds)
      table.insert(less_worlds, 1, world)
      small_text = table.concat(less_worlds, " > "):upper()
    end
  
    local title_y = oy
    local title_width, title_height = ui.fonts.title:getWidth(title_text), ui.fonts.title:getHeight()
    local world_folder
    local world_label = ui.text_input.new()
      :setText(title_text)
      :setFont(ui.fonts.title)
      :setPos(0, title_y)
      :setSize(love.graphics.getWidth(), title_height)
      :onReturn(scene.renameWorld)
      :onTextEdited(function(o) 
        o:setText(o:getText():upper())
        local width, height = o:getFont():getWidth(o:getText()), ui.fonts.title:getHeight()
        if world_folder then
          world_folder:setPos(love.graphics.getWidth()/2 - width/2 - sprites["ui/open_folder"]:getWidth(), title_y + height/2)
        end
      end)
    if load_mode == "edit" and world_parent ~= "officialworlds" and world ~= "" then
      world_label:setTextHoverColor(0.75, 0.75, 0.75)
      world_label:onReleased(function(o) ui.setEditing(o) end)
    end
    table.insert(components, world_label)
    if load_mode == "edit" and not is_mobile then
      world_folder = ui.component.new()
        :setSprite(sprites["ui/open_folder"]):setHoverSprite(sprites["ui/open_folder_h"]):setActiveSprite(sprites["ui/open_folder_a"])
        :setPos(love.graphics.getWidth()/2 - title_width/2 - sprites["ui/open_folder"]:getWidth(), title_y + title_height/2):setCentered(true)
        :onReleased(function()
          if world_parent ~= "officialworlds" then
            love.system.openURL("file:///"..love.filesystem.getSaveDirectory().."/"..getWorldDir(true).."/")
          else
            love.system.openURL("file:///"..love.filesystem.getSource().."/"..getWorldDir(true).."/")
          end
        end):setSelectable(false)
      table.insert(components, world_folder)
    end

    oy = oy + title_height

    if small_text then
      local sub_width, sub_height = ui.fonts.category:getWidth(small_text), ui.fonts.category:getHeight()
      table.insert(components, ui.component.new()
        :setText(small_text)
        :setFont(ui.fonts.category)
        :setPos(0, oy)
        :setSize(love.graphics.getWidth(), sub_height))

      oy = oy + sub_height
    end

    oy = oy + 24
  end

  if searching then
    local outside_levels = searchForLevels("levels", search_string)
    local world_levels = searchForLevels("worlds", search_string)
    local official_levels = searchForLevels("officialworlds", search_string)

    local function makeLevelButtons(levels, parent)
      local btns = {}
      for _,level in ipairs(levels) do
        local file = level.file
        local world = {world = "", world_parent = parent, sub_worlds = {}}
        local path = split(level.file, "/")
        if #path > 1 then
          file = path[#path]
          world.world = path[1]
          table.remove(path, 1)
          table.remove(path)
          for _,sub in ipairs(path) do
            table.insert(world.sub_worlds, sub)
          end
        end
        local f
        if parent == "" then
          f = "levels/" .. level.file
        else
          f = parent .. "/" .. level.file
        end
        local icon = getIcon(f) or sprites["ui/default icon"]
        table.insert(btns, {
          file = file,
          data = level.data,
          world = world,
          icon = icon
        })
      end
      return btns
    end

    local levels = {}
    mergeTable(levels, makeLevelButtons(outside_levels, ""))
    mergeTable(levels, makeLevelButtons(official_levels, "officialworlds"))
    mergeTable(levels, makeLevelButtons(world_levels, "worlds"))

    table.sort(levels, function(a, b)
      return a.file < b.file
    end)

    oy = scene.addButtons("level", levels, oy)
  elseif world == "" then
    if load_mode ~= "select" then
      local worlds = scene.searchDir("officialworlds", "world")
      if #worlds > 0 then
        local label_width, label_height = ui.fonts.category:getWidth(spookmode and "no" or "Official Worlds"), ui.fonts.category:getHeight()
        table.insert(components, ui.component.new()
          :setText(spookmode and "no" or "Official Worlds")
          :setFont(ui.fonts.category)
          :setPos(0, oy)
          :setSize(love.graphics.getWidth(), label_height))
        if load_mode == "edit" and not is_mobile then
          table.insert(components, ui.component.new()
            :setSprite(sprites["ui/open_folder"]):setHoverSprite(sprites["ui/open_folder_h"]):setActiveSprite(sprites["ui/open_folder_a"])
            :setPos(love.graphics.getWidth()/2 - label_width/2 - sprites["ui/open_folder"]:getWidth(), oy + label_height/2):setCentered(true)
            :onReleased(function()
              love.system.openURL("file:///"..love.filesystem.getSource().."/officialworlds/")
            end):setSelectable(false))
        end
        oy = oy + label_height + 8

        oy = scene.addButtons("world", worlds, oy)
      end

      worlds = scene.searchDir("worlds", "world")
      if #worlds > 0 or load_mode == "edit" then
        local label_width, label_height = ui.fonts.category:getWidth(spookmode and "stop" or "Custom Worlds"), ui.fonts.category:getHeight()
        table.insert(components, ui.component.new()
          :setText(spookmode and "stop" or "Custom Worlds")
          :setFont(ui.fonts.category)
          :setPos(0, oy)
          :setSize(love.graphics.getWidth(), label_height))
        if load_mode == "edit" and not is_mobile then
          table.insert(components, ui.component.new()
            :setSprite(sprites["ui/open_folder"]):setHoverSprite(sprites["ui/open_folder_h"]):setActiveSprite(sprites["ui/open_folder_a"])
            :setPos(love.graphics.getWidth()/2 - label_width/2 - sprites["ui/open_folder"]:getWidth(), oy + label_height/2):setCentered(true)
            :onReleased(function()
              if not love.filesystem.getInfo("worlds") then
                love.filesystem.createDirectory("worlds")
              end
              love.system.openURL("file:///"..love.filesystem.getSaveDirectory().."/worlds/")
            end):setSelectable(false))
        end
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
      local label_width, label_height = ui.fonts.category:getWidth(spookmode and "what is this" or "Custom Levels"), ui.fonts.category:getHeight()
      table.insert(components, ui.component.new()
        :setText(spookmode and "what is this" or "Custom Levels")
        :setFont(ui.fonts.category)
        :setPos(0, oy)
        :setSize(love.graphics.getWidth(), label_height))
      if load_mode == "edit" and not is_mobile then
        table.insert(components, ui.component.new()
          :setSprite(sprites["ui/open_folder"]):setHoverSprite(sprites["ui/open_folder_h"]):setActiveSprite(sprites["ui/open_folder_a"])
          :setPos(love.graphics.getWidth()/2 - label_width/2 - sprites["ui/open_folder"]:getWidth(), oy + label_height/2):setCentered(true)
          :onReleased(function()
            if not love.filesystem.getInfo("levels") then
              love.filesystem.createDirectory("levels")
            end
            love.system.openURL("file:///"..love.filesystem.getSaveDirectory().."/levels/")
          end):setSelectable(false))
      end
      oy = oy + label_height + 8

      if load_mode == "edit" and world_parent ~= "officialworlds" then
        table.insert(levels, 1, {
          create = true,
          file = "{DEFAULT}",
          data = json.decode(default_map),
          icon = sprites["ui/create icon"]
        })
      end

      oy = scene.addButtons("level", levels, oy)
    end
  else
    local worlds = scene.searchDir(getWorldDir(true), "world")
    if #worlds > 0 or load_mode == "edit" then
      local label_width, label_height = ui.fonts.category:getWidth("Worlds"), ui.fonts.category:getHeight()
      table.insert(components, ui.component.new()
        :setText("Worlds")
        :setFont(ui.fonts.category)
        :setPos(0, oy)
        :setSize(love.graphics.getWidth(), label_height))
      oy = oy + label_height + 8

      if load_mode == "edit" and world_parent ~= "officialworlds" then
        table.insert(worlds, 1, {
          create = true,
          name = "new world",
          path = world_parent,
          icon = sprites["ui/create icon"]
        })
      end

      oy = scene.addButtons("world", worlds, oy)
    end

    local levels = scene.searchDir(getWorldDir(true), "level")
    if #levels > 0 or load_mode == "edit" then
      local label_width, label_height = ui.fonts.category:getWidth("Levels"), ui.fonts.category:getHeight()
      table.insert(components, ui.component.new()
        :setText("Levels")
        :setFont(ui.fonts.category)
        :setPos(0, oy)
        :setSize(love.graphics.getWidth(), label_height))
      oy = oy + label_height + 8

      if load_mode == "edit" and world_parent ~= "officialworlds" then
        table.insert(levels, 1, {
          create = true,
          file = "{DEFAULT}",
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
      return love.filesystem.getInfo(dir .. "/" .. file) and love.filesystem.getInfo(dir .. "/" .. file).type == "directory"
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
      else
        t.icon = getIcon(dir .. "/" .. t.file) or sprites["ui/default icon"]
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
        button = ui.level_button.new(v.file, v.data.extra):setIcon(v.icon):setPos(ox, oy)
        if v.world then
          button.data.world = v.world
        end
        if v.create then
          button:onReleased(scene.createLevel)
        else
          button:onReleased(scene.selectLevel)
          button:setName(v.data.name)
        end
      end
      table.insert(components, button)
      ox = ox + btn_width + 8
    end
    oy = oy + btn_height + 8
  end
  return oy
end

function scene.addFolderBtn(x, y, dir)
  if love.filesystem.getInfo("levels") then
    love.system.openURL("file:///"..love.filesystem.getSaveDirectory().."/levels/")
  else
    love.system.openURL("file:///"..love.filesystem.getSaveDirectory())
  end
end

function scene.resize(w, h)
  scene.buildUI()
end

function scene.renameWorld(o, text)
  local world_dir_tree = split(getWorldDir(true), "/")
  table.remove(world_dir_tree)
  renameDir(getWorldDir(true), table.concat(world_dir_tree, "/") .. "/" .. text:lower())
  if #sub_worlds == 0 then
    world = text:lower()
  else
    sub_worlds[#sub_worlds] = text:lower()
  end
  scene.buildUI()
end

function scene.createWorld(o)
  if is_mobile and love.timer.getTime() - mobile_scroll_time > mobile_scroll_delay then return end
  if world == "" then
    world = o:getName()
    world_parent = o.data.file
  else
    table.insert(sub_worlds, o:getName())
  end
  love.filesystem.createDirectory(getWorldDir(true))
  scene.buildUI()
end

function scene.createLevel(o)
  if is_mobile and love.timer.getTime() -mobile_scroll_time > mobile_scroll_delay then return end
  local level_to_load = "{DEFAULT}"
  if #sub_worlds > 0 then level_to_load = table.concat(sub_worlds, "/") .. "/" .. level_to_load end
  loadLevels({level_to_load}, load_mode)
  loaded_level = false
	level_compression = settings["level_compression"]
end

function scene.selectWorld(o, button)
  if is_mobile and love.timer.getTime() -mobile_scroll_time > mobile_scroll_delay then return end
  if button == 1 then
    if o.data.deleting then
      o.data.deleting = 0
      o:setColor()
      o:setSprite(sprites["ui/world box"])
    else
      hasreplaylist = {}
      if world == "" then
        world = o:getName()
        world_parent = o.data.file
      else
        table.insert(sub_worlds, o:getName())
      end
      if load_mode == "play" and love.filesystem.getInfo(getWorldDir(true) .. "/" .. "overworld.txt") then
        local overworld = love.filesystem.read(getWorldDir(true) .. "/" .. "overworld.txt")
        loadWorld(overworld)
        playing_world = true
      else
        scene.buildUI()
      end
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
        if world == "" then
          deleteDir(o.data.file .. "/" .. o:getName())
        else
          deleteDir(getWorldDir(true) .. "/" .. o:getName())
        end
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
      scroll.vel = scroll.vel - 400
      scrollbutton = true
    end
    if pointInside(x, y, love.graphics.getWidth()-10-sprites["ui/arrow down"]:getWidth(), love.graphics.getHeight()-10-sprites["ui/arrow down"]:getHeight(), sprites["ui/arrow down"]:getWidth(), sprites["ui/arrow down"]:getHeight()) then
      scroll.vel = scroll.vel + 400
      scrollbutton = true
    end

    if not scrollbutton then
      mobile_scroll_start = y
      mobile_scroll_pos = scroll.offset
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
      if not searching then
        local file = o.data.file
        if #sub_worlds > 0 then file = table.concat(sub_worlds, "/") .. "/" .. file end
        if love.keyboard.isDown("lshift") then
          if o.data.selected then
            o:setColor()
            o.data.selected = false
            removeFromTable(selected_levels, file)
          else
            o:setColor(0.5, 0.25, 1)
            o.data.selected = true
            table.insert(selected_levels, file)
          end
        else
          if load_mode == "select" then
            new_scene = editor
            selected_level.level = file
            selected_level.name = o:getName()
            sub_worlds = old_world.sub_worlds
          else
            if not o.data.selected then
              o.data.selected = true
              table.insert(selected_levels, file)
            end
            loadLevels(selected_levels, load_mode)
          end
        end
      else
        world = o.data.world.world
        world_parent = o.data.world.world_parent
        sub_worlds = o.data.world.sub_worlds

        local file = o.data.file
        if #sub_worlds > 0 then file = table.concat(sub_worlds, "/") .. "/" .. file end

        loadLevels({file}, load_mode)
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
    elseif world_parent ~= "officialworlds" and (not o.data.world or o.data.world.world_parent ~= "officialworlds") then
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
        if o.data.world then
          if o.data.world.world ~= "" then
            dir = o.data.world.world_parent .. "/" .. o.data.world.world .. "/"
            if #o.data.world.sub_worlds > 0 then
              dir = dir .. table.concat(o.data.world.sub_worlds, "/") .. "/"
            end
          end
        elseif world ~= "" then dir = getWorldDir(true) .. "/" end
        love.filesystem.remove(dir .. o.data.file .. ".bab")
        love.filesystem.remove(dir .. o.data.file .. ".png")
        love.filesystem.remove(dir .. o.data.file .. ".replay")
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
