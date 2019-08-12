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
local input_name, input_author, input_palette, input_music, input_width, input_height, input_extra, input_parent_level, input_next_level, input_is_overworld, input_puffs_to_clear, input_background_sprite

local capturing, start_drag, end_drag
local screenshot, screenshot_image

local saved_popup

local searchstr = ""

local nt = false
-- for retaining information cross-scene
editor_save = {}

ICON_WIDTH = 96
ICON_HEIGHT = 96

function scene.load()
  metaClear()
  was_using_editor = true
  brush = {id = nil, dir = 1, mode = "none", picked_tile = nil, picked_index = 0}
  properties = {enabled = false, scale = 0, x = 0, y = 0, w = 0, h = 0, components = {}} -- will do this later
  saved_popup = {sprite = sprites["ui/level_saved"], y = 16, alpha = 0}
  key_down = {}
  buttons = {}
  
  nt = false

  settings_open = false
  selector_open = false
  selector_page = 1
  current_tile_grid = tile_grid[selector_page];
  
  if not level_compression then
    level_compression = "zlib"
  end
  if not level_name then
    level_name = "unnamed"
  end
  if not level_filename then
    level_filename = ""
  end
  if not level_author then
    level_author = ""
  end
  if not level_extra then
    level_extra = false
  end
  if not level_next_level_after_win then
    level_next_level_after_win = ""
  end
  if not level_is_overworld then
    level_is_overworld = false
  end
   if not level_puffs_to_clear then
    level_puffs_to_clear = 0
  end
  if not level_level_sprite then
    level_level_sprite = ""
  end
  if not level_level_number then
    level_level_number = 0
  end
  
  default_author = ""
  if love.filesystem.getInfo("author_name") then
    default_author = love.filesystem.read("author_name")
  end

  if (level_author == nil or level_author == "") then
    level_author = default_author
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
  resetMusic(map_music, 0.5)
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

  if spookmode then
    new_scene = game
    load_mode = "play"
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
  if is_mobile then
    gooi.newButton({text = "", x = 40*5, y = 0, w = 40, h = 40}):onRelease(function()
      scene.keyPressed("tab")
      scene.keyReleased("tab")
    end):setBGImage(sprites["ui/selector"],sprites["ui/selector_h"], sprites["ui/selector_a"]):bg({0, 0, 0, 0})
  end

  local dx = 208;
  local i = 0;

  settings = {x = 0, y = y_top, w = dx*2, h = 450}
  local y_top = (love.graphics.getHeight() - settings.h) / 2
  settings.y = y_top

  local w = 200
  local w_half = w/2 - 2 -- 98
  local h = 24
  local p = 4 -- padding

  if is_mobile then
    y_top = 0
    p = 8
    w = love.graphics.getWidth()/3 - 10
    w_half = w/2 - 2
    h = 50
    dx = w+8
    settings.y = 0
    settings.w = love.graphics.getWidth()
    settings.h = love.graphics.getHeight()
  end

  local y = y_top

  y = y + p
  gooi.newLabel({text = "Name", x = 4+dx*i, y = y, w = w, h = h}):center():setGroup("settings")
  y = y + h + p
  input_name = gooi.newText({text = level_name, x = 4+dx*i, y = y, w = w, h = h}):setGroup("settings")

  y = y + h + p
  gooi.newLabel({text = "Author", x = 4+dx*i, y = y, w = w, h = h}):center():setGroup("settings")
  y = y + h + p
  input_author = gooi.newText({text = level_author, x = 4+dx*i, y = y, w = w, h = h}):setGroup("settings")

  y = y + h + p
  label_palette = gooi.newLabel({text = "Palette", x = 4+dx*i, y = y, w = w, h = h}):center():setGroup("settings")
  y = y + h + p
  input_palette = gooi.newText({text = current_palette, x = 4+dx*i, y = y, w = w, h = h}):setGroup("settings")

  y = y + h + p
  label_music = gooi.newLabel({text = "Music", x = 4+dx*i, y = y, w = w, h = h}):center():setGroup("settings")
  y = y + h + p
  input_music = gooi.newText({text = map_music, x = 4+dx*i, y = y, w = w, h = h}):setGroup("settings")

  if is_mobile then
    y = y_top - h
    i = 1
  end

  -- Arbitrary limits of 512 until i come up with a reasonable limit
  if not is_mobile then
    y = y + h + p
    gooi.newLabel({text = "Width", x = 4+dx*i, y = y, w = w_half, h = h}):center():setGroup("settings")
    gooi.newLabel({text = "Height", x = 4+w_half+4+dx*i, y = y, w = w_half, h = h}):center():setGroup("settings")
    y = y + h + p
    input_width = gooi.newSpinner({value = mapwidth, min = 1, max = 512, x = 4+dx*i, y = y, w = w_half, h = h}):setGroup("settings")
    input_height = gooi.newSpinner({value = mapwidth, min = 1, max = 512, x = 4+w_half+4+dx*i, y = y, w = w_half, h = h}):setGroup("settings")
  
    y = y + h + p
    gooi.newLabel({text = "Extra", x = 4+dx*i, y = y, w = w, h = h}):center():setGroup("settings")
    y = y + h + p
    input_extra = gooi.newCheck({checked = level_extra, x = (w-h)/2+dx*i, y = y, w = h, h = h}):setGroup("settings")
    input_extra.checked = level_extra
  else
    y = y + h + p
    gooi.newLabel({text = "Width", x = 4+dx*i, y = y, w = w, h = h}):center():setGroup("settings")
    y = y + h + p
    input_width = gooi.newSpinner({value = mapwidth, min = 1, max = 512, x = 4+dx*i, y = y, w = w, h = h}):setGroup("settings")
    y = y + h + p
    gooi.newLabel({text = "Height", x = 4+dx*i, y = y, w = w, h = h}):center():setGroup("settings")
    y = y + h + p
    input_height = gooi.newSpinner({value = mapwidth, min = 1, max = 512, x = 4+dx*i, y = y, w = w, h = h}):setGroup("settings")
  end

  if not is_mobile then
    y = y_top - h
    i = 1;
  end
    
  y = y + h + p
  gooi.newLabel({text = "Parent Level", x = 4+dx*i, y = y, w = w, h = h}):center():setGroup("settings")
  y = y + h + p
  input_parent_level = gooi.newText({text = level_parent_level, x = 4+dx*i, y = y, w = w, h = h}):setGroup("settings")
  
  y = y + h + p
  gooi.newLabel({text = "Next Level", x = 4+dx*i, y = y, w = w, h = h}):center():setGroup("settings")
  y = y + h + p
  input_next_level = gooi.newText({text = level_next_level, x = 4+dx*i, y = y, w = w, h = h}):setGroup("settings")

  if is_mobile then
    y = y_top - h
    i = 2
  end
  
  if not is_mobile then
    y = y + h + p
    gooi.newLabel({text = "Is Overworld", x = 4+dx*i, y = y, w = w, h = h}):center():setGroup("settings")
    y = y + h + p
    input_is_overworld = gooi.newCheck({checked = level_is_overworld, x = (w-h)/2+dx*i, y = y, w = h, h = h}):setGroup("settings")
    input_is_overworld.checked = level_is_overworld
  else
    y = y + h + p
    gooi.newLabel({text = "Extra", x = 4+dx*i, y = y, w = w-h, h = h}):center():setGroup("settings")
    input_extra = gooi.newCheck({checked = level_extra, x = w-h+dx*i, y = y, w = h, h = h}):setGroup("settings")
    y = y + h + p
    gooi.newLabel({text = "Is Map", x = 4+dx*i, y = y,
w = w-h, h = h}):center():setGroup("settings")
    input_is_overworld = gooi.newCheck({checked = level_is_overworld, x = w-h+dx*i, y = y, w = h, h = h}):setGroup("settings")
    input_is_overworld.checked = level_is_overworld
    input_extra.checked = level_extra
  end
  
  y = y + h + p
  gooi.newLabel({text = "Puffs to Clear", x = 4+dx*i, y = y, w = w, h = h}):center():setGroup("settings")
  y = y + h + p
  input_puffs_to_clear = gooi.newSpinner({value = level_puffs_to_clear, min = 0, max = 999, x = 4+dx*i, y = y, w = w, h = h}):setGroup("settings")
  
  y = y + h + p
  gooi.newLabel({text = "Background", x = 4+dx*i, y = y, w = w, h = h}):center():setGroup("settings")
  y = y + h + p
  input_background_sprite = gooi.newText({text = level_background_sprite, x = 4+dx*i, y = y, w = w, h = h}):setGroup("settings")

  if not is_mobile then
    y = y_top + (h+p)*(is_mobile and 7 or 11) + p
    gooi.newButton({text = "Save", x = 4+dx*i, y = y, w = w_half, h = h}):onRelease(function()
      scene.saveSettings()
    end):center():success():setGroup("settings")
    gooi.newButton({text = "Cancel", x = 4+w_half+4+dx*i, y = y, w = w_half, h = h}):onRelease(function()
      scene.openSettings()
    end):center():danger():setGroup("settings")
  else
    y = y_top + (h+p)*(is_mobile and 6 or 10) + p
    gooi.newButton({text = "Save", x = 4+w/8+dx*i, y = y, w = w*3/4, h = h}):onRelease(function()
      scene.saveSettings()
    end):center():success():setGroup("settings")
    y = y + h + p
    gooi.newButton({text = "Cancel", x = 4+w/8+dx*i, y = y, w = w*3/4, h = h}):onRelease(function()
      scene.openSettings()
    end):center():danger():setGroup("settings")
  end

  gooi.setGroupVisible("settings", settings_open)
  gooi.setGroupEnabled("settings", settings_open)
  local x = love.graphics.getWidth()/2 - tile_grid_width*16 - 64
  local y = love.graphics.getHeight()/2 - tile_grid_height*16 - 32
  
  for i=1,#tile_grid do
    local j = i
    local button = gooi.newButton({text = "", x = x + 64*i, y = y, w = 64, h = 32}):onRelease(function()
      selector_tab_buttons_list[selector_page]:setBGImage(sprites["ui/selector_tab_"..selector_page], sprites["ui/selector_tab_"..selector_page.."_h"])
      selector_page = j
      current_tile_grid = tile_grid[selector_page];
      selector_tab_buttons_list[selector_page]:setBGImage(sprites["ui/selector_tab_"..j.."_a"])
    end)
    button:setBGImage(sprites["ui/selector_tab_"..i], sprites["ui/selector_tab_"..i.."_h"]):bg({0, 0, 0, 0})
    button:setVisible(selector_open)
    button:setEnabled(selector_open)
    selector_tab_buttons_list[i] = button
  end
  selector_tab_buttons_list[selector_page]:setBGImage(sprites["ui/selector_tab_"..selector_page.."_a"], sprites["ui/selector_tab_"..selector_page.."_h"])
  -- gooi.setGroupVisible("selectortabs", selector_open)
  -- gooi.setGroupEnabled("selectortabs", selector_open)
  updateSelectorTabs();
  
  local twelfth = love.graphics.getWidth()/12

  --metatext (lshift)
  gooi.newButton({text = "", x = 9.25*twelfth, y = 0.25*twelfth, w = twelfth, h = twelfth, group = "mobile-controls-selector"}):setBGImage(sprites["text_meta"]):onPress(function()
      scene.keyPressed("lshift")
      scene.keyReleased("lshift")
  end):bg({0, 0, 0, 0})
  --reload tab (rshift)
  gooi.newButton({text = "", x = 10.75*twelfth, y = 0.25*twelfth, w = twelfth, h = twelfth, group = "mobile-controls-selector"}):setBGImage(sprites["ui/reset"]):onPress(function()                                                               scene.keyPressed("rshift")                                 scene.keyReleased("rshift")                            end):bg({0, 0, 0, 0})

  gooi.setGroupVisible("mobile-controls-selector", false)

  local screenheight = love.graphics.getHeight()

  --rotate brush
  gooi.newButton({text = "",x = 10*twelfth,y = screenheight-3*twelfth,w = twelfth,h = twelfth,group = "mobile-controls-editor"}):onPress(function(c) brush.dir = dirs8_by_offset[0][-1] end):setBGImage(sprites["ui/arrow up"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "",x = 11*twelfth,y = screenheight-2*twelfth,w = twelfth,h = twelfth,group = "mobile-controls-editor"}):onPress(function(c) brush.dir = dirs8_by_offset[1][0] end):setBGImage(sprites["ui/arrow right"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "",x = 10*twelfth,y = screenheight-1*twelfth,w = twelfth,h = twelfth,group = "mobile-controls-editor"}):onPress(function(c) brush.dir = dirs8_by_offset[0][1] end):setBGImage(sprites["ui/arrow down"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "",x =  9*twelfth,y = screenheight-2*twelfth,w = twelfth,h = twelfth,group = "mobile-controls-editor"}):onPress(function(c) brush.dir = dirs8_by_offset[-1][0] end):setBGImage(sprites["ui/arrow left"]):bg({0, 0, 0, 0})
  --(diag)
  gooi.newButton({text = "",x = 11*twelfth,y = screenheight-3*twelfth,w = twelfth,h = twelfth,group = "mobile-controls-editor"}):onPress(function(c) brush.dir = dirs8_by_offset[1][-1] end):setBGImage(sprites["ui/arrow ur"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "",x = 11*twelfth,y = screenheight-1*twelfth,w = twelfth,h = twelfth,group = "mobile-controls-editor"}):onPress(function(c) brush.dir = dirs8_by_offset[1][1] end):setBGImage(sprites["ui/arrow dr"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "",x = 9*twelfth,y = screenheight-1*twelfth,w = twelfth,h = twelfth,group = "mobile-controls-editor"}):onPress(function(c) brush.dir = dirs8_by_offset[-1][1] end):setBGImage(sprites["ui/arrow dl"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "",x = 9*twelfth,y = screenheight-3*twelfth,w = twelfth,h = twelfth,group = "mobile-controls-editor"}):onPress(function(c) brush.dir = dirs8_by_offset[-1][-1] end):setBGImage(sprites["ui/arrow ul"]):bg({0, 0, 0, 0})

  --picker (visuals are down in scene.draw())
  gooi.newButton({text = "",x = 10*twelfth,y = screenheight-2*twelfth,w = twelfth,h = twelfth,group = "mobile-controls-editor"}):onPress(function(c) mobile_picking = not mobile_picking end):bg({0, 0, 0, 0})

  --stacking (shift/ctrl click)
  mobile_controls_stackmode_none = gooi.newButton({text = "",x = 9*twelfth,y = screenheight-4.15*twelfth,w = twelfth,h = twelfth,group = "mobile-controls-editor"}):onPress(function(c) mobile_stackmode = "none" end):setBGImage(sprites["bab"]):bg({0, 0, 0, 0})
  mobile_controls_stackmode_shift = gooi.newButton({text = "",x = 10*twelfth,y = screenheight-4.25*twelfth,w = twelfth,h = twelfth,group = "mobile-controls-editor"}):onPress(function(c) mobile_stackmode = "shift" end):setBGImage(sprites["ui/stack"]):bg({0, 0, 0, 0})
  mobile_controls_stackmode_ctrl = gooi.newButton({text = "",x = 11*twelfth,y = screenheight-4.25*twelfth,w = twelfth,h = twelfth,group = "mobile-controls-editor"}):onPress(function(c) mobile_stackmode = "ctrl" end):setBGImage(sprites["ui/stack_same"]):bg({0, 0, 0, 0})

  gooi.setGroupVisible("mobile-controls-editor", is_mobile)
end
mobile_picking = false
mobile_stackmode = "none"

function scene.keyPressed(key)
  if selector_open then
    if key == "escape" or (key == "a" and key_down["lctrl"]) or (key == "backspace" and key_down["lctrl"]) then
      if #searchstr == 0 then selector_open = false end
      searchstr = ""
    elseif key == "backspace" or  (key == "z" and key_down["lctrl"]) then
      searchstr = string.sub(searchstr, 1, #searchstr-1)
    elseif (#key == 1 or key == "space") and not (key_down["lctrl"] or key_down["rctrl"] or key_down["f3"]) then
      if #searchstr > 15 then return end
      if key == "space" then key = " " end
      searchstr = searchstr..key
    end
  end

  if key == "escape" and not selector_open then
    if not capturing then
      if not spookmode then
        gooi.confirm({
          text = spookmode and "Ģ͖̙̗̳̟̩̱̹̥̓͌͂ͤͫͫo̟̗͓̞̪̬͒̀ ̤̯̺̹͙̮̇bͯͣ̚͏̹̮a̸̡̯̜̦̝͓͑͋̾̊̾̏̔͢cͨ̿̏̔̆ͣ̎̊ͫ͟҉̗ǩ̬̰͕̭͊ͣͣ̈̇̀ ̩̖̮̹̣̰̫̫̏͐́͊̓̉̓̃͟ͅť̜̤̤̫ͯ͟ó̷͕̩̻̼͕̽͑̀̕ ̧̨͚̻̭̜̜͓̆̎͐͌͊̔l̷̰̖̳͈̰̞̄́̕e̷̫̾͑͌ͣ̎ͩ̍̑͞v̷̢̥̰̪͋͗̀̊ͤ͢é̛̼͖͖͓͕̖ͥ̔͑̐̔ͫ̿ļ̷̵̩̞̩̀͛͒̇͗̊̉̔̄ ̵͈ͪ̂̏ͧͨ͘͘ŝ̶̷̮̠͙͓̬̦̗ͭẽ͙̩͔͕͊̔ͯͮͤ̑͟ļ̗͈̈́̐ͨ̄̑ͪͪ͘ȩ͕̘̱͙̻̣̦̉̈ͨ̐ͪ̑̿̃̾ͅc͍̯͈̀ͥ̕͢t̨̩̹̲͍͕͇̊̇̈́̏ͮͬ̿͆͘ͅo̯̮͉̜͓͇̎̂̄ͧͭ̒ͫͫ͘͠͠r̰͍̝̯̿̆ͦ?ͪ͋͒ͩ̇̚҉̶̠̘̦" or "Go back to level selector?",
          okText = "Yes",
          cancelText = spookmode and "Yes" or "Cancel",
          ok = function()
            load_mode = "edit"
            new_scene = loadscene
          end
        })
      else
        load_mode = "play"
        new_scene = loadscene
      end
      return
    else
      capturing = false
      screenshot, screenshot_image = nil, nil
      ignore_mouse = true
    end
end
  
  if key == "w" and (key_down["lctrl"] or key_down["rctrl"]) and not selector_open then
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
          scene.updateMap()
        end
      end
    end
  end

  if not selector_open then
    if key == "s" and (key_down["lctrl"] or key_down["rctrl"]) then
      scene.saveLevel()
    elseif key == "l" and (key_down["lctrl"] or key_down["rctrl"]) then
      scene.loadLevel()
    elseif key == "o" and (key_down["lctrl"] or key_down["rctrl"]) then
      scene.openSettings()
    elseif key == "r" and (key_down["lctrl"] or key_down["rctrl"]) then
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
  end

  if key == "tab" and not (key_down["lctrl"] or key_down["rctrl"]) then
    selector_open = not selector_open
    updateSelectorTabs()
    if selector_open then
      presence["details"] = "browsing selector"
      gooi.setGroupVisible("mobile-controls-selector", is_mobile)
      gooi.setGroupVisible("mobile-controls-editor", false)
    else
      gooi.setGroupVisible("mobile-controls-selector", false)
      gooi.setGroupVisible("mobile-controls-editor", is_mobile)
    end
  end
  
  -- ctrl tab shortcuts
  local old_selector_page = selector_page;
  selector_tab_buttons_list[selector_page]:setBGImage(sprites["ui/selector_tab_"..selector_page], sprites["ui/selector_tab_"..selector_page.."_h"])
  
  if key == "tab" and (key_down["lctrl"] or key_down["rctrl"]) and not (key_down["lshift"] or key_down["rshift"]) then
    selector_page = selector_page % #tile_grid + 1
  elseif key == "tab" and (key_down["lctrl"] or key_down["rctrl"]) and (key_down["lshift"] or key_down["rshift"]) then
    selector_page = (selector_page - 2) % #tile_grid + 1
  elseif selector_open and tonumber(key) and tonumber(key) <= #tile_grid and tonumber(key) > 0 and (key_down["lctrl"] or key_down["rctrl"]) then
    selector_page = tonumber(key)
  end
  
  --only refresh tile grid if the page actually changed to preserve meta text levels
  if (old_selector_page ~= selector_page) then
    current_tile_grid = tile_grid[selector_page]
    print(dump(selector_tab_buttons_list))
    selector_tab_buttons_list[selector_page]:setBGImage(sprites["ui/selector_tab_"..selector_page.."_a"], sprites["ui/selector_tab_"..selector_page.."_h"])
  end
  
  --create and display meta tiles 1 higher
  if selector_open and (key == "lshift" or key == "m" and (key_down["lctrl"] or key_down["rctrl"])) then
    --copy so we don't override original list
    current_tile_grid = copyTable(current_tile_grid)
    for i = 0,tile_grid_width*tile_grid_height do
      if current_tile_grid[i] ~= nil and current_tile_grid[i] > 0 then
        local new_tile_id = tiles_by_name["text_" .. tiles_list[current_tile_grid[i]].name];
        if (new_tile_id ~= nil) then
          current_tile_grid[i] = new_tile_id
        else
          current_tile_grid[i] = current_tile_grid[i] + meta_offset
          tiles_listPossiblyMeta(current_tile_grid[i])
        end
      end
    end
  end
  
  if selector_open and key == "rshift" or key == "r" and (key_down["lctrl"] or key_down["rctrl"]) then
    current_tile_grid = tile_grid[selector_page]
  end
  
  if selector_open and key == "n" and (key_down["lctrl"] or key_down["rctrl"]) then
    nt = not nt
    current_tile_grid = copyTable(current_tile_grid)
    if nt then
        for i = 0,tile_grid_width*tile_grid_height do
            if current_tile_grid[i] ~= nil and current_tile_grid[i] > 0 then
                local new_tile_id = tiles_by_name[tiles_list[current_tile_grid[i]].name .. "n't"];
                if (new_tile_id ~= nil) then
                    current_tile_grid[i] = new_tile_id
                end
            end
        end
    else
        current_tile_grid = tile_grid[selector_page]
    end
  end
end

function scene.mousePressed(x, y, button)
  if capturing and button == 1 then
    start_drag = {x = love.mouse.getX(), y = love.mouse.getY()}
  end
  if selector_open and button == 1 then
    selectorhold = true
  end
end

function scene.mouseReleased(x, y, button)
  if capturing and button == 1 then
    scene.captureIcon()
  end

  if button == 1 then
    selectorhold = false
  end
end

function scene.keyReleased(key)
  key_down[key] = false
end

function updateSelectorTabs()
  local scale, dx, dy = scene.transformParameters();
    local x = (dx-64)*scale
    local y = (dy-32)*scale
    for i=1,#tile_grid do
      local button = selector_tab_buttons_list[i]
      button:setVisible(selector_open)
      button:setEnabled(selector_open)
      button:setBounds(x+64*i*scale, y, 64*scale, 32*scale)
    end
end

function scene.update(dt)
  if not spookmode then
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

        if love.mouse.isDown(1) and not (is_mobile and mobile_picking or brush.mode == "picking") then
          if not selector_open then
            local painted = false
            local new_unit = nil
            local existing = nil
            local ctrl_first_press = false
            local ctrl_active = key_down["lctrl"] or key_down["rctrl"] or (is_mobile and mobile_stackmode == "ctrl")
            local shift_active = key_down["lshift"] or (is_mobile and mobile_stackmode == "shift") or ctrl_active
            if ctrl_active and brush.mode == "none" then
              ctrl_first_press = true
            end
            if #hovered >= 1 then
              for _,unit in ipairs(hovered) do
                if unit.tile == brush.id then
                  if not (ctrl_active or selectorhold) then
                    existing = unit
                  end
                elseif brush.mode == "placing" and not (shift_active or selectorhold) then
                  deleteUnit(unit)
                  scene.updateMap()
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
                if existing and not selectorhold then
                  deleteUnit(existing)
                  scene.updateMap()
                  painted = true
                end
              elseif brush.mode == "placing" and not selectorhold then
                if existing then
                  existing.dir = brush.dir
                  painted = true
                  new_unit = existing
                elseif (not ctrl_active or ctrl_first_press) and (not is_mobile or mobile_firstpress) then
                  new_unit = createUnit(brush.id, hx, hy, brush.dir)
                  scene.updateMap()
                  painted = true
                end
              end
              if painted then
                if tileid == brush.picked_tile then
                  brush.picked_tile = nil
                  brush.picked_index = 0
                end
                paintedtiles = paintedtiles + 1
                if new_unit and brush.id == tiles_by_name["lvl"] then
                  new_scene = loadscene
                  load_mode = "select"
                  selected_level = {id = new_unit.id}
                  old_world = {parent = world_parent, world = world}

                  editor_save.brush = brush
                end
              end
            end
          else
            local selected = hx + hy * tile_grid_width
            if current_tile_grid[selected] then
              brush.id = current_tile_grid[selected]
              brush.picked_tile = nil
              brush.picked_index = 0
            else
              brush.id = nil
              brush.picked_tile = nil
              brush.picked_index = 0
            end
          end
          mobile_firstpress = false
        end
        if (love.mouse.isDown(2) or (is_mobile and mobile_picking and love.mouse.isDown(1))) and not selector_open then
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
              mobile_picking = false
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

    if not (love.mouse.isDown(1) and not (is_mobile and mobile_picking and brush.mode ~= "picking")) then
      if brush.mode == "placing" or brush.mode == "erasing" then
        brush.mode = "none"
      end
      mobile_firstpress = true
    end
    if not (love.mouse.isDown(2) or (is_mobile and love.mouse.isDown(1) and mobile_picking)) then
      if brush.mode == "picking" then
        brush.mode = "none"
        mobile_picking = false
      end
    end
  end
end

function scene.transformParameters()
  local roomwidth, roomheight

  if not selector_open then
    roomwidth = mapwidth * TILE_SIZE
    roomheight = mapheight * TILE_SIZE
  else
    roomwidth = tile_grid_width * TILE_SIZE
    roomheight = tile_grid_height * TILE_SIZE
  end

  local screenwidth = love.graphics.getWidth() * (is_mobile and 0.75 or 1)
  local screenheight = love.graphics.getHeight() - (is_mobile and sprites["ui/cog"]:getHeight() or 0)

  local scales = {0.25, 0.375, 0.5, 0.75, 1, 1.5, 2, 3, 4}

  local scale = scales[1]
  for _,s in ipairs(scales) do
    if screenwidth >= roomwidth * s and screenheight >= roomheight * s then
        scale = s
    else break end
  end

  local scaledwidth = screenwidth * (1/scale)
  local scaledheight = screenheight * (1/scale)

  local dx = scaledwidth / 2 - roomwidth / 2
  local dy = scaledheight / 2 - roomheight / 2 + (is_mobile and sprites["ui/cog"]:getHeight()/scale or 0)
  
  return scale, dx, dy;
end

function scene.getTransform()
  local transform = love.math.newTransform()

  local scale, dx, dy = scene.transformParameters();

  transform:scale(scale, scale)
  transform:translate(dx, dy);
  
  roomscale = scale
  return transform
end

last_hovered_tile = {0,0}
function scene.draw(dt)
  if not spookmode then
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

    love.graphics.setColor(getPaletteColor(0, 4))
    love.graphics.rectangle("fill", 0, 0, roomwidth, roomheight)
    if not selector_open and level_background_sprite ~= nil and level_background_sprite ~= "" and sprites[level_background_sprite] then
      love.graphics.setColor(1, 1, 1)
      local sprite = sprites[level_background_sprite]
      love.graphics.draw(sprite, 0, 0, 0, 1, 1, 0, 0)
    end

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
            if (unit.nt ~= nil) then
              setColor({2, 2})
              local ntsprite = sprites["nt"]
              love.graphics.draw(ntprite, (unit.x + 0.5)*TILE_SIZE, (unit.y + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
              setColor(unit.color)
            end
          end
        end
      end
    else
      for x=0,tile_grid_width-1 do
        for y=0,tile_grid_height-1 do
          local gridid = x + y * tile_grid_width
          local i = current_tile_grid[gridid]
          if i ~= nil then
            local tile = tiles_list[i]
            local sprite = sprites[tile.sprite]
            if not sprite then sprite = sprites["wat"] end

            -- local x = tile.grid[1]
            -- local y = tile.grid[2]

            local color = setColor(tile.color);

            if rainbowmode then love.graphics.setColor(hslToRgb((love.timer.getTime()/3+x/tile_grid_width+y/tile_grid_height)%1, .5, .5, 1)) end
            
            local found_matching_tag = false
            
            if tile.tags ~= nil then
                for _,tag in ipairs(tile.tags) do
                    if string.match(tag, searchstr) then
                        found_matching_tag = true
                    end
                end
            end
            
            if string.match(tile.name, searchstr) then
                found_matching_tag = true
            end
            
            if tile.texttype ~= nil then
              for type,_ in pairs(tile.texttype) do
                if string.match(type, searchstr) then
                    found_matching_tag = true
                end
              end
            end
            
            if not found_matching_tag then love.graphics.setColor(0.2,0.2,0.2) end
            
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
            if (tile.nt ~= nil) then
              setColor({2, 2})
              local ntsprite = sprites["nt"]
              love.graphics.draw(ntprite, (tile.x + 0.5)*TILE_SIZE, (tile.y + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
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
        if infomode then love.graphics.print(last_hovered_tile[1] .. ', ' .. last_hovered_tile[2], 0, roomheight+36) end
        if not is_mobile then
            love.graphics.printf("CTRL + TAB or CTRL + NUMBER to change tabs", 0, roomheight, roomwidth, "right")
            love.graphics.printf("CTLR + M to get meta text, CTRL + R to refresh", 0, roomheight+12, roomwidth, "right")
            love.graphics.printf("CTRL + N to get n't text", 0, roomheight+24, roomwidth, "right")
            if #searchstr > 0 then
                love.graphics.print("Searching for: " .. searchstr, 0, roomheight)
            else
                love.graphics.print("Type to search", 0, roomheight)
            end
        end
    end

    love.graphics.pop()

    if selector_open then
      love.graphics.setColor(1, 1, 1)
      local gridid = last_hovered_tile[1]  + last_hovered_tile[2] * tile_grid_width
      local i = current_tile_grid[gridid]
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
          love.graphics.rectangle("fill", love.mouse.getX()+10, love.mouse.getY()+10-tooltipyoffset, tooltipwidth+14, tooltipheight+12)
          love.graphics.setColor(getPaletteColor(0, 4))
          love.graphics.rectangle("fill", love.mouse.getX()+11, love.mouse.getY()+11-tooltipyoffset, tooltipwidth+12, tooltipheight+10)

          love.graphics.setColor(getPaletteColor(0,3))
          love.graphics.printf(tile.desc, love.mouse.getX()+16, love.mouse.getY()+14-tooltipyoffset, love.graphics.getWidth() - love.mouse.getX() - 20)
        end
        if infomode then
            love.graphics.push()
            love.graphics.applyTransform(scene.getTransform())
            love.graphics.print("Name: " .. tile.name, 0, roomheight+12)
            if tile.tags ~= nil then
                love.graphics.print("Tags: " .. table.concat(tile.tags,", "), 0, roomheight+24)
            end
            love.graphics.pop()
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
    gooi.draw("mobile-controls-selector")
    gooi.draw("mobile-controls-editor")
    
    if is_mobile then
      local twelfth = love.graphics.getWidth()/12
      if mobile_picking then
          love.graphics.setColor(1, 1, 1, 1)
          love.graphics.draw(sprites["ui_plus"],10*twelfth,love.graphics.getHeight()-2*twelfth,0,twelfth/32,twelfth/32)
      elseif brush.id then
        local sprite = sprites[tiles_list[brush.id].sprite]
        if not sprite then sprite = sprites["wat"] end
        
        local rotation = 0
        if tiles_list[brush.id].rotate then
            rotation = (brush.dir - 1) * 45
        end
        
        local color = tiles_list[brush.id].color
        if #color == 3 then
          love.graphics.setColor(color[1]/255, color[2]/255, color[3]/255, 1)
        else
          local r, g, b, a = getPaletteColor(color[1], color[2])
          love.graphics.setColor(r, g, b, a)
        end

        love.graphics.draw(sprite, 10.5*twelfth, love.graphics.getHeight()-1.5*twelfth,math.rad(rotation),twelfth/32,twelfth/32,twelfth/4,twelfth/4)
      end
      if mobile_stackmode == "none" then
        mobile_controls_stackmode_none:setBounds(9*twelfth, love.graphics.getHeight()-4.05*twelfth)
        mobile_controls_stackmode_shift:setBounds(10*twelfth, love.graphics.getHeight()-4.25*twelfth)
        mobile_controls_stackmode_ctrl:setBounds(11*twelfth, love.graphics.getHeight()-4.25*twelfth)
      elseif mobile_stackmode == "shift" then
        mobile_controls_stackmode_none:setBounds(9*twelfth, love.graphics.getHeight()-4.15*twelfth)
        mobile_controls_stackmode_shift:setBounds(10*twelfth, love.graphics.getHeight()-4.15*twelfth)
        mobile_controls_stackmode_ctrl:setBounds(11*twelfth, love.graphics.getHeight()-4.25*twelfth)
      elseif mobile_stackmode == "ctrl" then
        mobile_controls_stackmode_none:setBounds(9*twelfth, love.graphics.getHeight()-4.15*twelfth)
        mobile_controls_stackmode_shift:setBounds(10*twelfth, love.graphics.getHeight()-4.25*twelfth)
        mobile_controls_stackmode_ctrl:setBounds(11*twelfth, love.graphics.getHeight()-4.15*twelfth)
      end
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
  else
    love.graphics.setBackgroundColor(math.random(0,10)/1000,math.random(0,10)/1000,math.random(0,10)/1000)

    love.graphics.setColor(math.sin(love.timer.getRealTime()*5), 0, 0)

    local yoverride = false
    local y = 0

    while not yoverride do
      yoverride = y > love.graphics.getHeight()

      local xoverride = false
      local x = 0

      while not xoverride do
        xoverride = x > love.graphics.getWidth()
        love.graphics.print("esc", x, y)
        x = x + love.graphics.getFont():getWidth("esc")
      end

      y = y + love.graphics.getFont():getHeight()
    end
  end
end

function scene.updateMap()
  map_ver = 4
  local map = {}
  for x = 0, mapwidth-1 do
    for y = 0, mapheight-1 do
      local tileid = x + y * mapwidth
      if units_by_tile[tileid] then
        for _,unit in ipairs(units_by_tile[tileid]) do
          table.insert(map, {id = unit.id, tile = unit.tile, x = unit.x, y = unit.y, dir = unit.dir, special = unit.special});
        end
      end
    end
  end
  map = serpent.dump(map);
  maps = {{map_ver, map}}
end

function sanitize(filename)
  -- Bad as defined by wikipedia: https://en.wikipedia.org/wiki/Filename#Reserved_characters_and_words
  -- Also have to escape the backslash
  -- and the % and . since they have special meaning in lua regexes
  bad_chars = { '/', '\\', '?', '%%', '*', ':', '|', '"', '<', '>', '%.'}
  for _,bad_char in ipairs(bad_chars) do
    filename = filename:gsub(bad_char, '_')
  end
  return filename
end

function scene.saveLevel()
  compactIds()
  scene.updateMap()

  local map = maps[1][2]

  level_compression = "zlib"
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
    map = savestr,
    parent_level = level_parent_level,
    next_level = level_next_level,
    is_overworld = level_is_overworld,
    puffs_to_clear = level_puffs_to_clear,
    background_sprite = level_background_sprite,
  }
  
  local file_name = sanitize(level_name);

  if world == "" or world_parent == "officialworlds" then
    love.filesystem.createDirectory("levels")
    love.filesystem.write("levels/" .. file_name .. ".bab", json.encode(data))
    print("Saved to:","levels/" .. file_name .. ".bab")
    if icon_data then
      icon_data:encode("png", "levels/" .. file_name .. ".png")
    end
  else
    love.filesystem.createDirectory(world_parent .. "/" .. world)
    love.filesystem.write(world_parent .. "/" .. world .. "/" ..file_name .. ".bab", json.encode(data))
    print("Saved to:",world_parent .. "/" .. world .. "/" ..file_name .. ".bab")
    if icon_data then
      icon_data:encode("png", world_parent .. "/" .. world .. "/" .. file_name .. ".png")
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
    input_author:setText(level_author)
    input_palette:setText(current_palette)
    input_music:setText(map_music)
    input_width:setValue(mapwidth)
    input_height:setValue(mapheight)
    input_parent_level:setText(level_parent_level)
    input_next_level:setText(level_next_level)
    input_is_overworld.checked = level_is_overworld
    input_puffs_to_clear:setValue(level_puffs_to_clear)
    input_background_sprite:setText(level_background_sprite)
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
  level_author = input_author:getText()
  current_palette = input_palette:getText()
  map_music = input_music:getText()
  level_parent_level = input_parent_level:getText()
  level_next_level = input_next_level:getText()
  level_is_overworld = input_is_overworld.checked
  level_puffs_to_clear = input_puffs_to_clear:getValue()
  level_background_sprite = input_background_sprite:getText()

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
  local mapstr = loadMaybeCompressedData(loaddata)

  loaded_level = true

  level_name = mapdata.name
  level_author = mapdata.author or ""
  level_extra = mapdata.extra or false
  current_palette = mapdata.palette or "default"
  map_music = mapdata.music or "bab be u them"
  mapwidth = mapdata.width
  mapheight = mapdata.height
  map_ver = mapdata.version or 0
  level_parent_level = mapdata.parent_level or ""
  level_next_level = mapdata.next_level or ""
  level_is_overworld = mapdata.is_overworld or false
  level_puffs_to_clear = mapdata.level_puffs_to_clear or 0
  level_background_sprite = mapdata.background_sprite or ""

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
