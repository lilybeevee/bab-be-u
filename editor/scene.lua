local scene = {}

local brush

local paintedtiles = 0
local buttons = {}
local button_over = nil
local name_font = nil
local typing_name = false
local ignore_mouse = true

local settings_open, settings, properties
local label_palette, label_music
local input_name, input_author, input_compression, input_palette, input_music, input_width, input_height, input_extra

local capturing, start_drag, end_drag
local screenshot, screenshot_image

local saved_popup

-- for retaining information cross-scene
editor_save = {}

ICON_WIDTH = 96
ICON_HEIGHT = 96

function scene.load()
  brush = {id = nil, dir = 1, mode = "none", picked_tile = nil, picked_index = 0}
  properties = {enabled = false, scale = 0, x = 0, y = 0, w = 0, h = 0, components = {}} -- will do this later
  saved_popup = {sprite = sprites["ui/level_saved"], y = 16, alpha = 0}
  key_down = {}
  buttons = {}

  settings_open = false
  selector_open = false
  selector_page = 1
  
  if not level_compression then
    level_compression = "zlib"
  end
  if not level_name then
    level_name = "unnamed"
  end
  if not level_author then
    level_author = ""
  end
  if not level_extra then
    level_extra = false
  end

  if not loaded_level then
    if love.filesystem.getInfo("author_name") then
      level_author = love.filesystem.read("author_name")
    end
    default_author = level_author
  end

  typing_name = false
  ignore_mouse = true
  capturing = false
  start_drag, end_drag = nil, nil
  screenshot, screenshot_image = nil, nil

  local dir = "levels/"
  if world ~= "" then dir = world_parent .. "/" .. world .. "/" end

  width = love.graphics.getWidth()
  height = love.graphics.getHeight()
  name_font = love.graphics.newFont(24)
  
  if editor_save.brush then brush = editor_save.brush end
  editor_save = {}

  scene.setupGooi()

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
  if level_name then
    presence["details"] = "working on "..level_name..".bab"
  end

  love.mouse.setGrabbed(false)
  love.keyboard.setKeyRepeat(true)

  if map_ver == 0 then
    scene.updateMap()
  end

  if selected_level then
    local unit = units_by_id[selected_level.id]
    if unit then
      unit.special.level = selected_level.level
      unit.special.name = selected_level.name
      scene.updateMap()
    end
    selected_level = nil
  end
end

selector_tab_buttons_list = {}
function scene.setupGooi()
  gooi.newButton({text = "", x = 40*0, y = 0, w = 40, h = 40}):onRelease(function()
    scene.loadLevel()
  end):setBGImage(sprites["ui/load"], sprites["ui/load_h"], sprites["ui/load_a"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "", x = 40*1, y = 0, w = 40, h = 40}):onRelease(function()
    scene.saveLevel()
  end):setBGImage(sprites["ui/save"], sprites["ui/save_h"], sprites["ui/save_a"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "", x = 40*2, y = 0, w = 40, h = 40}):onRelease(function()
    scene.openSettings()
  end):setBGImage(sprites["ui/cog"], sprites["ui/cog_h"], sprites["ui/cog_a"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "", x = 40*3, y = 0, w = 40, h = 40}):onRelease(function()
    new_scene = game
    load_mode = "play"
  end):setBGImage(sprites["ui/play"],sprites["ui/play_h"], sprites["ui/play_a"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "", x = 40*4, y = 0, w = 40, h = 40}):onRelease(function()
    love.graphics.captureScreenshot(function(s)
      capturing = true
      start_drag, end_drag = nil, nil
      screenshot = s
      screenshot_image = love.graphics.newImage(s)
    end)
  end):setBGImage(sprites["ui/camera"],sprites["ui/camera_h"], sprites["ui/camera_a"]):bg({0, 0, 0, 0})

  settings = {x = 0, y = 0, w = 208, h = 336}

  local y = (love.graphics.getHeight() - settings.h) / 2

  settings.y = y

  y = y + 4
  gooi.newLabel({text = "Name", x = 4, y = y, w = 200, h = 24}):center():setGroup("settings")
  y = y + 24 + 4
  input_name = gooi.newText({text = level_name, x = 4, y = y, w = 200, h = 24}):setGroup("settings")

  y = y + 24 + 4
  gooi.newLabel({text = "Author", x = 4, y = y, w = 200, h = 24}):center():setGroup("settings")
  y = y + 24 + 4
  input_author = gooi.newText({text = level_author, x = 4, y = y, w = 200, h = 24}):setGroup("settings")

  y = y + 24 + 4
  label_palette = gooi.newLabel({text = "Palette", x = 4, y = y, w = 200, h = 24}):center():setGroup("settings")
  y = y + 24 + 4
  input_palette = gooi.newText({text = current_palette, x = 4, y = y, w = 200, h = 24}):setGroup("settings")

  y = y + 24 + 4
  label_music = gooi.newLabel({text = "Music", x = 4, y = y, w = 200, h = 24}):center():setGroup("settings")
  y = y + 24 + 4
  input_music = gooi.newText({text = map_music, x = 4, y = y, w = 200, h = 24}):setGroup("settings")

  -- Arbitrary limits of 512 until i come up with a reasonable limit
  y = y + 24 + 4
  gooi.newLabel({text = "Width", x = 4, y = y, w = 98, h = 24}):center():setGroup("settings")
  gooi.newLabel({text = "Height", x = 106, y = y, w = 98, h = 24}):center():setGroup("settings")
  y = y + 24 + 4
  input_width = gooi.newSpinner({value = mapwidth, min = 1, max = 512, x = 4, y = y, w = 98, h = 24}):setGroup("settings")
  input_height = gooi.newSpinner({value = mapwidth, min = 1, max = 512, x = 106, y = y, w = 98, h = 24}):setGroup("settings")

  y = y + 24 + 4
  gooi.newLabel({text = "Compression", x = 4, y = y, w = 200, h = 24}):center():setGroup("settings")
  y = y + 24 + 4
  input_compression = gooi.newText({text = level_compression, x = 4, y = y, w = 200, h = 24}):setGroup("settings")
  
  y = y + 24 + 4
  gooi.newLabel({text = "Extra", x = 4, y = y, w = 200, h = 24}):center():setGroup("settings")
  y = y + 24 + 4
  input_extra = gooi.newCheck({checked = level_extra, x = 4, y = y}):setGroup("settings")

  input_extra.checked = level_extra

  y = y + (24 * 2) + 4
  gooi.newButton({text = "Save", x = 4, y = y, w = 98, h = 24}):onRelease(function()
    scene.saveSettings()
  end):center():success():setGroup("settings")
  gooi.newButton({text = "Cancel", x = 106, y = y, w = 98, h = 24}):onRelease(function()
    scene.openSettings()
  end):center():danger():setGroup("settings")

  y = y + 24 + 4
  --print("height: " .. y - settings.y)

  gooi.setGroupVisible("settings", settings_open)
  gooi.setGroupEnabled("settings", settings_open)
  
  local x = love.graphics.getWidth()/2 - tile_grid_width*16 - 64
  y = love.graphics.getHeight()/2 - tile_grid_height*16 - 32
  
  for i=1,#tile_grid do
    local j = i
    local button = gooi.newButton({text = "", x = x + 64*i, y = y, w = 64, h = 32}):onRelease(function()
      selector_tab_buttons_list[selector_page]:setBGImage(sprites["ui/selector_tab_"..selector_page], sprites["ui/selector_tab_"..selector_page.."_h"])
      selector_page = j
      selector_tab_buttons_list[selector_page]:setBGImage(sprites["ui/selector_tab_"..j.."_a"], sprites["ui/selector_tab_"..j.."_h"])
    end)
    button:setBGImage(sprites["ui/selector_tab_"..i], sprites["ui/selector_tab_"..i.."_h"]):bg({0, 0, 0, 0})
    button:setVisible(selector_open)
    button:setEnabled(selector_open)
    selector_tab_buttons_list[i] = button
  end
  selector_tab_buttons_list[selector_page]:setBGImage(sprites["ui/selector_tab_"..selector_page.."_a"], sprites["ui/selector_tab_"..selector_page.."_h"])
  -- gooi.setGroupVisible("selectortabs", selector_open)
  -- gooi.setGroupEnabled("selectortabs", selector_open)
  
end

function scene.keyPressed(key)
  if key == "escape" then
    if not capturing then
      gooi.confirm({
        text = "Go back to level selector?",
        okText = "Yes",
        cancelText = "Cancel",
        ok = function()
          load_mode = "edit"
          new_scene = loadscene
        end
      })
      return
    else
      capturing = false
      screenshot, screenshot_image = nil, nil
      ignore_mouse = true
    end
  end
  if key == "w" and key_down["lctrl"] then
    load_mode = "edit"
    new_scene = loadscene
  end

  key_down[key] = true

  if gooi.showingDialog then
    return
  end

  if not settings_open and not selector_open then
    if key == "up" or key == "left" or key == "down" or key == "right" then
      local dx, dy = 0, 0
      if key_down["up"] then dy = dy - 1 end
      if key_down["down"] then dy = dy + 1 end
      if key_down["left"] then dx = dx - 1 end
      if key_down["right"] then dx = dx + 1 end
      local dir
      if dx ~= 0 or dy ~= 0 then
        dir = dirs8_by_offset[dx][dy]
      else
        dir = rotate8(brush.dir)
      end
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
  elseif key == "r" and key_down["lctrl"] then
    gooi.confirm({
      text = "Clear the level?",
      okText = "Yes",
      cancelText = "Cancel",
      ok = function()
        maps = {{2, ""}}
        clear()
        loadMap()
        loaded_level = false
      end
    })
  elseif key == "return" and settings_open then
    scene.saveSettings()
  end

  if key == "tab" then
    selector_open = not selector_open
    for i=1,#tile_grid do
      local button = selector_tab_buttons_list[i]
      button:setVisible(selector_open)
      button:setEnabled(selector_open)
    end
    if selector_open then
      presence["details"] = "browsing selector"
    end
  end
  
  if selector_open and tonumber(key) and tonumber(key) <= #tile_grid and tonumber(key) > 0 then
    selector_tab_buttons_list[selector_page]:setBGImage(sprites["ui/selector_tab_"..selector_page], sprites["ui/selector_tab_"..selector_page.."_h"])
    selector_page = tonumber(key)
    selector_tab_buttons_list[selector_page]:setBGImage(sprites["ui/selector_tab_"..tonumber(key).."_a"], sprites["ui/selector_tab_"..tonumber(key).."_h"])
  end
end

function scene.mousePressed(x, y, button)
  if capturing and button == 1 then
    start_drag = {x = love.mouse.getX(), y = love.mouse.getY()}
  end
end

function scene.mouseReleased(x, y, button)
  if capturing and button == 1 then
    scene.captureIcon()
  end
end

function scene.keyReleased(key)
  key_down[key] = false
end

function scene.update(dt)
  if capturing then
    if start_drag then
      local rect = {
        x = start_drag.x, 
        y = start_drag.y,
        w = love.mouse.getX() - start_drag.x,
        h = love.mouse.getY() - start_drag.y
      }
      local highest = math.max(math.abs(rect.w), math.abs(rect.h))
      if math.abs(rect.w) < highest then
        if rect.w < 0 then rect.w = -highest end
        if rect.w > 0 then rect.w = highest end
      end
      if math.abs(rect.h) < highest then
        if rect.h < 0 then rect.h = -highest end
        if rect.h > 0 then rect.h = highest end
      end
      end_drag = {x = rect.x + rect.w, y = rect.y + rect.h}
    end
    return
  end

  if gooi.showingDialog then
    return
  end

  if ignore_mouse then
    if not love.mouse.isDown(1) then
      ignore_mouse = false
    end
    return
  end

  width = love.graphics.getWidth()
  height = love.graphics.getHeight()

  if settings_open then
    if not palettes[input_palette:getText()] then
      label_palette:setIcon(sprites["ui/smol warning"])
    else
      label_palette:setIcon()
    end
    if not sound_exists[input_music:getText()] then
      label_music:setIcon(sprites["ui/smol warning"])
    else
      label_music:setIcon()
    end
  elseif not settings_open or not mouseOverBox(settings.x, settings.y, settings.w, settings.h) then
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
          local new_unit = nil
          local existing = nil
          local ctrl_first_press = false
          if key_down["lctrl"] and brush.mode == "none" then
            ctrl_first_press = true
          end
          if #hovered >= 1 then
            for _,unit in ipairs(hovered) do
              if unit.tile == brush.id then
                if not key_down["lctrl"] then
                  existing = unit
                end
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
                new_unit = existing
              elseif not key_down["lctrl"] or ctrl_first_press then
                new_unit = createUnit(brush.id, hx, hy, brush.dir)
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
            scene.updateMap()
            if new_unit and brush.id == tiles_by_name["lvl"] then
              new_scene = loadscene
              load_mode = "select"
              selected_level = {id = new_unit.id}
              old_world = {parent = world_parent, world = world}

              editor_save.brush = brush
            end
          end
        else
          local selected = hx + hy * tile_grid_width
          if tile_grid[selector_page][selected] then
            brush.id = tile_grid[selector_page][selected]
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
  --background color
  local bg_color = {getPaletteColor(1, 0)}

  love.graphics.setColor(bg_color[1], bg_color[2], bg_color[3], bg_color[4])
  setRainbowModeColor(love.timer.getTime()/6, .2)

  -- fill the background with the background color
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

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

  -- if selector_open then
  --   for i=1,#tile_grid do
  --     love.graphics.setColor(getPaletteColor(1, 3))
  --     setRainbowModeColor(love.timer.getTime()/3+i*1.3, .5)
      
  --     -- love.graphics.draw(sprites["ui/button_white_"..i%2+1], (sprites["ui/button_1"]:getHeight()+5)*i, 0-sprites["ui/button_1"]:getHeight(), math.pi/2)
  --     local j = i
  --     gooi.newButton({text = i, x = 45*i, y = 0, w = 40, h = 40, group = "selectortabs"}):onRelease(function()
  --       selector_page = j
  --     end):setBGImage(sprites["ui/button_1"], sprites["ui/button_1_h"], sprites["ui/button_1_a"]):bg({0, 0, 0, 0})
      
  --     -- love.graphics.setColor(1, 1, 1)
  --     -- love.graphics.printf(i, (sprites["ui/button_1"]:getHeight()+5)*(i-1), 0-sprites["ui/button_1"]:getHeight()/3*2, sprites["ui/button_1"]:getHeight()+5, "center")
  --   end
  -- end

  love.graphics.setColor(getPaletteColor(0, 4))
  love.graphics.rectangle("fill", 0, 0, roomwidth, roomheight)

	local function setColor(color)
		if #color == 3 then
			color = {color[1]/255, color[2]/255, color[3]/255, 1}
		else
			color = {getPaletteColor(color[1], color[2])}
		end
		love.graphics.setColor(color)
		return color
	end
	
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
          
					local color = setColor(unit.color);

          if rainbowmode then
            local newcolor = hslToRgb((love.timer.getTime()/3+unit.x/18+unit.y/18)%1, .5, .5, 1)
            newcolor[1] = newcolor[1]*255
            newcolor[2] = newcolor[2]*255
            newcolor[3] = newcolor[3]*255
            unit.color = newcolor
          end

          love.graphics.draw(sprite, (unit.x + 0.5)*TILE_SIZE, (unit.y + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
					if (unit.meta ~= nil) then
						setColor({4, 1})
						local metasprite = unit.meta == 2 and sprites["meta2"] or sprites["meta1"]
						love.graphics.draw(metasprite, (unit.x + 0.5)*TILE_SIZE, (unit.y + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
						if unit.meta > 2 then
							love.graphics.printf(tostring(unit.meta), (unit.x + 0.5)*TILE_SIZE-1, (unit.y + 0.5)*TILE_SIZE+6, 32, "center")
						end
						setColor(unit.color)
					end
        end
      end
    end
  else
    for x=0,tile_grid_width-1 do
      for y=0,tile_grid_height-1 do
        local gridid = x + y * tile_grid_width
        local i = tile_grid[selector_page][gridid]
        if i ~= nil then
          local tile = tiles_list[i]
          local sprite = sprites[tile.sprite]
          if not sprite then sprite = sprites["wat"] end

          -- local x = tile.grid[1]
          -- local y = tile.grid[2]

          local color = setColor(tile.color);

          if rainbowmode then love.graphics.setColor(hslToRgb((love.timer.getTime()/3+x/tile_grid_width+y/tile_grid_height)%1, .5, .5, 1)) end

          love.graphics.draw(sprite, (x + 0.5)*TILE_SIZE, (y + 0.5)*TILE_SIZE, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
					if (tile.meta ~= nil) then
						setColor({4, 1})
						local metasprite = tile.meta == 2 and sprites["meta2"] or sprites["meta1"]
						love.graphics.draw(metasprite, (x + 0.5)*TILE_SIZE, (y + 0.5)*TILE_SIZE, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
						if tile.meta > 2 then
							love.graphics.printf(tostring(tile.meta), (x + 0.5)*TILE_SIZE-1, (y + 0.5)*TILE_SIZE+6, 32, "center")
						end
						setColor(tile.color)
					end

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
    if not (gooi.showingDialog or capturing) then
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
    end

    last_hovered_tile = {hx, hy}
  end

  if selector_open then
    love.graphics.setColor(getPaletteColor(0,3))
    love.graphics.print(last_hovered_tile[1] .. ', ' .. last_hovered_tile[2], 0, roomheight)
  end

  love.graphics.pop()

  if selector_open then
    love.graphics.setColor(1, 1, 1)
    local gridid = last_hovered_tile[1]  + last_hovered_tile[2] * tile_grid_width
    local i = tile_grid[selector_page][gridid]
    if i ~= nil then
      local tile = tiles_list[i]
      if (tile.desc ~= nil and hx ~= nil) then
        local tooltipwidth, ttlines = love.graphics.getFont():getWrap(tile.desc, love.graphics.getWidth() - love.mouse.getX() - 20)
        local tooltipheight = love.graphics.getFont():getHeight() * #ttlines

        local tooltipyoffset = 0

        if love.mouse.getY() + (tooltipheight + 20) - love.graphics.getHeight() > 0 then
          tooltipyoffset = love.mouse.getY() + (tooltipheight + 20) - love.graphics.getHeight()
        end

        love.graphics.setColor(getPaletteColor(1, 3))
        love.graphics.rectangle("fill", love.mouse.getX()+10, love.mouse.getY()+10-tooltipyoffset, tooltipwidth+13, tooltipheight+13)
        love.graphics.setColor(getPaletteColor(0, 4))
        love.graphics.rectangle("fill", love.mouse.getX()+11, love.mouse.getY()+11-tooltipyoffset, tooltipwidth+11, tooltipheight+11)

        love.graphics.setColor(getPaletteColor(0,3))
        love.graphics.printf(tile.desc, love.mouse.getX()+11, love.mouse.getY()+11-tooltipyoffset, love.graphics.getWidth() - love.mouse.getX() - 20)
      end
    end
  end

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

  love.graphics.push()
  gooi.draw()

  love.graphics.setFont(name_font)
  love.graphics.setColor(1, 1, 1)

  love.graphics.printf(level_name, 0, name_font:getLineHeight() / 2, love.graphics.getWidth(), "center")

  love.graphics.setColor(1, 1, 1, saved_popup.alpha)
  if is_mobile then
    love.graphics.draw(saved_popup.sprite, 44, 40 + saved_popup.y)
  else
    love.graphics.draw(saved_popup.sprite, 0, 40 + saved_popup.y)
  end

  if settings_open then
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", settings.x, settings.y, settings.w, settings.h)
    love.graphics.setColor(1, 1, 1, 1)
    gooi.draw("settings")
  end
  love.graphics.pop()

  if capturing then
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.draw(screenshot_image)

    if start_drag and end_drag then
      local rect = {
        x = math.min(start_drag.x, end_drag.x), 
        y = math.min(start_drag.y, end_drag.y),
        w = math.abs(end_drag.x - start_drag.x),
        h = math.abs(end_drag.y - start_drag.y)
      }
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h)
      love.graphics.setScissor(rect.x, rect.y, rect.w, rect.h)
      love.graphics.draw(screenshot_image)
      love.graphics.setScissor()
    end
  end

  if is_mobile then
    local cursorx, cursory = love.mouse.getPosition()
    love.graphics.draw(system_cursor, cursorx, cursory)
  end

  if is_mobile then
    local cursorx, cursory = love.mouse.getPosition()
    love.graphics.draw(system_cursor, cursorx, cursory)
  end
end

function scene.updateMap()
  map_ver = 3
  local map = ""
  for x = 0, mapwidth-1 do
    for y = 0, mapheight-1 do
      local tileid = x + y * mapwidth
      if units_by_tile[tileid] then
        for _,unit in ipairs(units_by_tile[tileid]) do
          local specials = ""
          for k,v in pairs(unit.special) do
            specials = specials .. love.data.pack("string", PACK_SPECIAL_V2, k, v)
          end
          map = map .. love.data.pack("string", PACK_UNIT_V3, unit.id, unit.tile, unit.x, unit.y, unit.dir, specials)
        end
      end
    end
  end
  maps = {{map_ver, map}}
end

function scene.saveLevel()
  compactIds()
  scene.updateMap()

  local map = maps[1][2]

  local mapdata = level_compression == "zlib" and love.data.compress("string", "zlib", map) or map
  local savestr = love.data.encode("string", "base64", mapdata)
  
  local data = {
    name = level_name,
    author = level_author,
    compression = level_compression,
    extra = level_extra,
    palette = current_palette,
    music = map_music,
    width = mapwidth,
    height = mapheight,
    version = map_ver,
    map = savestr
  }
  
  print(level_compression, data.compression)

  if world == "" or world_parent == "officialworlds" then
    love.filesystem.createDirectory("levels")
    love.filesystem.write("levels/" .. level_name .. ".bab", json.encode(data))
    if icon_data then
      icon_data:encode("png", "levels/" .. level_name .. ".png")
    end
  else
    love.filesystem.createDirectory(world_parent .. "/" .. world)
    love.filesystem.write(world_parent .. "/" .. world .. "/" .. level_name .. ".bab", json.encode(data))
    if icon_data then
      icon_data:encode("png", world_parent .. "/" .. world .. "/" .. level_name .. ".png")
    end
  end

  addTween(tween.new(0.25, saved_popup, {y = 0, alpha = 1}, 'outQuad'), "saved_popup")
  addTick("saved_popup", 1, function()
    addTween(tween.new(0.5, saved_popup, {y = 16, alpha = 0}), "saved_popup")
  end)
end

function scene.loadLevel()
  load_mode = "edit"
  new_scene = loadscene
end

function scene.openSettings()
  if not settings_open then
    settings_open = true

    input_name:setText(level_name)
    input_compression:setText(level_compression)
    input_author:setText(level_author)
    input_palette:setText(current_palette)
    input_music:setText(map_music)
    input_width:setValue(mapwidth)
    input_height:setValue(mapheight)
    input_extra.checked = level_extra

    gooi.setGroupVisible("settings", true)
    gooi.setGroupEnabled("settings", true)
    --addTween(tween.new(0.5, settings_pos, {x = 0}, 'outBounce'), "settings")
  else
    settings_open = false

    gooi.setGroupVisible("settings", false)
    gooi.setGroupEnabled("settings", false)
    --addTween(tween.new(0.5, settings_pos, {x = -320}, 'outCubic'), "settings")
  end
end

function scene.saveSettings()
  local success = true
  if not palettes[input_palette:getText()] then
    success = false
    input_palette:danger()
  else
    input_palette:primary()
  end
  if not sound_exists[input_music:getText()] then
    success = false
    input_music:danger()
  else
    input_music:primary()
  end
  if not success then
    return
  end

  local author_change = false
  if not loaded_level then
    if input_author:getText() ~= level_author and input_author:getText() ~= default_author then
      author_change = true
    end
  end

  level_name = input_name:getText()
  level_compression = input_compression:getText()
  level_author = input_author:getText()
  current_palette = input_palette:getText()
  map_music = input_music:getText()

  scene.updateMap()

  mapwidth = input_width:getValue()
  mapheight = input_height:getValue()
  level_extra = input_extra.checked
  
  clear()
  loadMap()
  resetMusic(map_music, 0.1)

  scene.updateMap()

  if author_change then
    gooi.confirm({
      text = 'Set your default author name to:\n' .. level_author,
      okText = "Yes",
      cancelText = "No",
      ok = function()
        default_author = level_author
        love.filesystem.write("author_name", default_author)
        scene.openSettings()
      end,
      cancel = function()
        scene.openSettings()
      end
    })
  else
    scene.openSettings()
  end
end

function love.filedropped(file)
  local data = file:read()
  local mapdata = json.decode(data)

  level_compression = mapdata.compression or "zlib"
  local loaddata = love.data.decode("string", "base64", mapdata.map)
  local mapstr = level_compression == "zlib" and love.data.decompress("string", "zlib", loaddata) or loaddata

  loaded_level = true

  level_name = mapdata.name
  level_author = mapdata.author or ""
  level_extra = mapdata.extra or false
  current_palette = mapdata.palette or "default"
  map_music = mapdata.music or "bab be u them"
  mapwidth = mapdata.width
  mapheight = mapdata.height
  map_ver = mapdata.version or 0

  if map_ver == 0 then
    maps = {{0, loadstring("return " .. mapstr)()}}
  else
    maps = {{map_ver, mapstr}}
  end

  clear()
  loadMap()

  if (brush ~= nil) then
    brush.picked_tile = nil
    brush.picked_index = 0
  end

  local dir = "levels/"
  if world ~= "" then dir = world_parent .. "/" .. world .. "/" end
  if love.filesystem.getInfo(dir .. level_name .. ".png") then
    icon_data = love.image.newImageData(dir .. level_name .. ".png")
  else
    icon_data = nil
  end

  resetMusic(map_music, 0.1)
end

function scene.captureIcon()
  if start_drag == nil or end_drag == nil then
    capturing = false
    screenshot = nil
    screenshot_image = nil
    return
  end

  local rect = {
    x = math.min(start_drag.x, end_drag.x),
    y = math.min(start_drag.y, end_drag.y),
    w = math.abs(end_drag.x - start_drag.x),
    h = math.abs(end_drag.y - start_drag.y)
  }

  if rect.w == 0 or rect.h == 0 then
    capturing = false
    screenshot = nil
    screenshot_image = nil
    return
  end

  local new_data = love.image.newImageData(rect.w, rect.h)
  new_data:paste(screenshot, 0, 0, rect.x, rect.y, rect.w, rect.h)

  local new_image = love.graphics.newImage(new_data)
  new_image:setFilter("linear","nearest")
  
  local canvas = love.graphics.newCanvas(ICON_WIDTH, ICON_HEIGHT)
  love.graphics.origin()
  love.graphics.setCanvas(canvas)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(new_image, 0, 0, 0, ICON_WIDTH / rect.w, ICON_HEIGHT / rect.h)
  love.graphics.setCanvas()

  icon_data = canvas:newImageData()

  capturing = false
  screenshot = nil
  screenshot_image = nil
end

function scene.resize(w, h)
  clearGooi()
  scene.setupGooi()
end

return scene