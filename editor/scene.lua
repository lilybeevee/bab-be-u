local scene = {}

local brush

local paintedtiles = 0
local buttons = {}
local button_over = nil
local name_font = nil
local typing_name = false
local ignore_mouse = true
local saved_settings = false

local settings_open, settings_ui, properties
local label_palette, label_music
local input_name, input_author, input_palette, input_music, input_width, input_height, input_extra, input_parent_level, input_next_level, input_is_overworld, input_puffs_to_clear, input_background_sprite

local capturing, start_drag, end_drag
local screenshot, screenshot_image

local level_dialogue, last_lin_hidden

local saved_popup

local searchstr = ""
local subsearchstr = ""

local nt = false
-- for retaining information cross-scene
editor_save = {}

ICON_WIDTH = 96
ICON_HEIGHT = 96

function scene.load()
  metaClear()
  was_using_editor = true
  brush = {id = nil, dir = 1, mode = "none", picked_tile = nil, picked_index = 0, special = {}}
  properties = {enabled = false, scale = 0, x = 0, y = 0, w = 0, h = 0, components = {}} -- will do this later
  saved_popup = {sprite = sprites["ui/level_saved"], y = 16, alpha = 0}
  key_down = {}
  buttons = {}
  
  nt = false

  settings_open = false
  selector_open = false
  selector_page = 1
  current_tile_grid = tile_grid[selector_page]
  
  level_dialogue = {x = 0, y = 0, scale = 0, enabled = false}
  
  paint_open = false
  paint_colors = {}
  
  if not level_compression then
    level_compression = settings["level_compression"]
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
  saved_settings = false
  ignore_mouse = true
  capturing = false
  start_drag, end_drag = nil, nil
  screenshot, screenshot_image = nil, nil

  local dir = "levels/"
  if world ~= "" then dir = getWorldDir(true) .. "/" end

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

  scene.selecting = false
end

selector_tab_buttons_list = {}
function scene.setupGooi()
  local x = 0
  gooi.newButton({text = "", x = x, y = 0, w = 40, h = 40}):onRelease(function()
    scene.loadLevel()
  end):setBGImage(sprites["ui/load"], sprites["ui/load_h"], sprites["ui/load_a"]):bg({0, 0, 0, 0})
  x = x + 40
  gooi.newButton({text = "", x = x, y = 0, w = 40, h = 40}):onRelease(function()
    scene.saveLevel()
  end):setBGImage(sprites["ui/save"], sprites["ui/save_h"], sprites["ui/save_a"]):bg({0, 0, 0, 0})
  x = x + 40
  gooi.newButton({text = "", x = x, y = 0, w = 40, h = 40}):onRelease(function()
    scene.openSettings()
  end):setBGImage(sprites["ui/cog"], sprites["ui/cog_h"], sprites["ui/cog_a"]):bg({0, 0, 0, 0})
  x = x + 40
  gooi.newButton({text = "", x = x, y = 0, w = 40, h = 40}):onRelease(function()
    new_scene = game
    load_mode = "play"
  end):setBGImage(sprites["ui/play"],sprites["ui/play_h"], sprites["ui/play_a"]):bg({0, 0, 0, 0})
  x = x + 40
  gooi.newButton({text = "", x = x, y = 0, w = 40, h = 40}):onRelease(function()
    love.graphics.captureScreenshot(function(s)
      capturing = true
      start_drag, end_drag = nil, nil
      screenshot = s
      screenshot_image = love.graphics.newImage(s)
    end)
  end):setBGImage(sprites["ui/camera"],sprites["ui/camera_h"], sprites["ui/camera_a"]):bg({0, 0, 0, 0})
  x = x + 40
  if is_mobile then
    gooi.newButton({text = "", x = x, y = 0, w = 40, h = 40}):onRelease(function()
      scene.keyPressed("tab")
      scene.keyReleased("tab")
    end):setBGImage(sprites["ui/selector"],sprites["ui/selector_h"], sprites["ui/selector_a"]):bg({0, 0, 0, 0})
    x = x + 40
  end
  
  paint_button = gooi.newButton({text = "", x = x, y = 0, w = 40, h = 40}):onPress(function()
    if paint_open then
      paint_open = false
      paint_button:setBGImage(sprites["ui/paint"], sprites["ui/paint_h"])
      fullpaint_palette:setVisible(false)
    elseif key_down["lshift"] or key_down["rshift"] then
      paint_open = "full"
      paint_button:setBGImage(sprites["ui/paint_a"], sprites["ui/paint_h"])
      fullpaint_palette:setVisible(true)
    else
      paint_open = true
      paint_button:setBGImage(sprites["ui/paint_a"], sprites["ui/paint_h"])
      fullpaint_palette:setVisible(false)
    end
  end):setBGImage(sprites["ui/paint"], sprites["ui/paint_h"]):bg({0, 0, 0, 0})
  x = x + 40
  paint_colors[1] = {x}
  gooi.newButton({text = "", x = x, y = 4, h = 32, w = 32}):onPress(function()
    if paint_open then
      brush.color = nil
    end
  end):bg({0,0,0,0}) -- no BGImage since it needs to be recolored
  x = x + 36
  local fullpaint_palette_x = x
  fullpaint_palette = gooi.newButton({text = "", x = x, y = 4, h = 5*8, w = 7*8}):onPress(function()
    local x, y = love.mouse.getPosition()
    local palette_x = math.floor((x - fullpaint_palette_x) / 8)
    local palette_y = math.floor((y - 4) / 8)
    brush.color = {palette_x, palette_y}
  end):setBGImage(palettes[current_palette].sprite):bg({0,0,0,0})
  fullpaint_palette:setVisible(false)
  for _,color in pairs(color_names) do
    gooi.newButton({text = "", x = x, y = 4, h = 32, w = 32}):onPress(function()
      if paint_open == true then
        brush.color = main_palette_for_colour[color]
      end
    end):bg({0,0,0,0}) -- no BGImage since it needs to be recolored
    table.insert(paint_colors, {x, main_palette_for_colour[color]})
    x = x + 36 -- 4px padding
  end

  local dx = 208
  local i = 0

  settings_ui = {x = 0, y = y_top, w = dx*2, h = 450}
  local y_top = (love.graphics.getHeight() - settings_ui.h) / 2
  settings_ui.y = y_top

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
    settings_ui.y = 0
    settings_ui.w = love.graphics.getWidth()
    settings_ui.h = love.graphics.getHeight()
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
    i = 1
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
      current_tile_grid = tile_grid[selector_page]
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
  updateSelectorTabs()
  
  local twelfth = love.graphics.getWidth()/12

  --metatext
  gooi.newButton({text = "", x = 9.25*twelfth, y = 0.25*twelfth, w = twelfth, h = twelfth, group = "mobile-controls-selector"}):setBGImage(sprites["text_meta"]):onPress(function()
      scene.keyPressed("lalt")
      scene.keyReleased("lalt")
  end):bg({0, 0, 0, 0})
  --n'ttext
  gooi.newButton({text = "", x = 9.25*twelfth, y = 1.5*twelfth, w = twelfth, h = twelfth, group = "mobile-controls-selector"}):setBGImage(sprites["text_nt"]):onPress(function()
      scene.keyPressed("lctrl")
      scene.keyPressed("n")
      scene.keyReleased("lctrl")
  end):bg({0, 0, 0, 0})
  --reload tab
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
  
  -- level dialogue
  level_dialogue.iconnamebox = gooi.newText({w = 75, h = 20})
  level_dialogue.iconnamebox.style.font = love.graphics.newFont(10)
  level_dialogue.iconnamebox.style.bgColor = {getPaletteColor(0, 0)}
  level_dialogue.iconnamebox:setVisible(false)
  level_dialogue.iconnamebox:setEnabled(false)
end
mobile_picking = false
mobile_stackmode = "none"

function scene.keyPressed(key)
  if key == "escape" and not selector_open then
    if not capturing then
      if not spookmode then
        if saved_settings or maps[1].data ~= last_saved then
          ui.overlay.confirm({
            text = "Go back to level selector?\n(WARNING: You have unsaved changes)",
            okText = "Yes",
            cancelText = spookmode and "Yes" or "Cancel",
            ok = function()
              load_mode = "edit"
              new_scene = loadscene
            end
          })
        else
          load_mode = "edit"
          new_scene = loadscene
        end
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

  if key == "g" and key_down["lctrl"] and not selector_open then
    settings["draw_editor_lins"] = not settings["draw_editor_lins"]
    saveAll()
  end

  if selector_open then
    if key == "escape" or (key == "a" and (key_down["lctrl"] or key_down["rctrl"])) or (key == "backspace" and (key_down["lctrl"] or key_down["rctrl"])) then
      if #searchstr == 0 and key == "escape" then selector_open = false end
      searchstr = ""
    elseif key == "backspace" or (key == "z" and (key_down["lctrl"] or key_down["rctrl"])) then
      searchstr = string.sub(searchstr, 1, #searchstr-1)
    elseif key == "x" and (key_down["lctrl"] or key_down["rctrl"]) then
       love.system.setClipboardText(searchstr)
       searchstr = ""
    elseif key == "c" and (key_down["lctrl"] or key_down["rctrl"]) then
       love.system.setClipboardText(searchstr)
    elseif key == "v" and (key_down["lctrl"] or key_down["rctrl"]) then
      if #searchstr + #love.system.getClipboardText() > 50 then return end
      searchstr = searchstr..love.system.getClipboardText()
    elseif key == "return" then
      if key_down["lalt"] or key_down["ralt"] or key_down["lshift"] or key_down["rshift"] then
        if tiles_by_name["text_"..subsearchstr] then
          brush.id = tiles_by_name["text_"..subsearchstr]
          brush.special = {}
          selector_open = false
        end
      elseif key_down["lctrl"] or key_down["rctrl"] then
        if tiles_by_name["letter_"..subsearchstr] then
          brush.id = tiles_by_name["letter_"..subsearchstr]
          brush.special = {}
          selector_open = false
        elseif #subsearchstr >= 1 and #subsearchstr <= 6 then
          brush.id = tiles_by_name["letter_custom"]
          brush.special = {customletter = subsearchstr}
          --brush.customletter = subsearchstr
          selector_open = false
        end
      else
        if tiles_by_name[subsearchstr] then
          brush.id = tiles_by_name[subsearchstr]
          brush.special = {}
          selector_open = false
        elseif tiles_by_name["text_"..subsearchstr] then
          brush.id = tiles_by_name["text_"..subsearchstr]
          brush.special = {}
          selector_open = false
        end
      end
    elseif (#key == 1 or key == "space") and not (key_down["lctrl"] or key_down["rctrl"] or key_down["f3"]) then
      if #searchstr > 50 then return end
      local letter = key
      if key == "space" then 
        letter = " "
      end
      if key_down["lshift"] or key_down["rshift"] then
        if key == "`" then
            letter = "~"
        elseif key == "1" then
            letter = "!"
        elseif key == "2" then
            letter = "@"
        elseif key == "3" then
            letter = "#"
        elseif key == "4" then
            letter = "$"
        elseif key == "5" then
            letter = "%"
        elseif key == "6" then
            letter = "^"
        elseif key == "7" then
            letter = "&"
        elseif key == "8" then
            letter = "*"
        elseif key == "9" then
            letter = "("
        elseif key == "0" then
            letter = ")"
        elseif key == "-" then
            letter = "_"
        elseif key == "=" then
            letter = "+"
        elseif key == "[" then
            letter = "{"
        elseif key == "]" then
            letter = "}"
        elseif key == "\\" then
            letter = "|"
        elseif key == ";" then
            letter = ":"
        elseif key == "'" then
            letter = "\""
        elseif key == "," then
            letter = "<"
        elseif key == "." then
            letter = ">"
        elseif key == "/" then
            letter = "?"
        end
      end
      searchstr = searchstr..letter
    end
    subsearchstr = searchstr:gsub(" ","")
  end
  
  updateSelectorTabs()
  
  if key == "w" and (key_down["lctrl"] or key_down["rctrl"]) and not selector_open then
    load_mode = "edit"
    new_scene = loadscene
  end

  key_down[key] = true

  if not settings_open and not selector_open then
    if not (key_down["lshift"] or key_down["rshift"]) and (key == "up" or key == "left" or key == "down" or key == "right" or key == "w" or key == "a" or key == "s" or key == "d") then
      local dx, dy = 0, 0
      if key_down["up"] or key_down["w"] then dy = dy - 1 end
      if key_down["down"] or key_down["s"] then dy = dy + 1 end
      if key_down["left"] or key_down["a"] then dx = dx - 1 end
      if key_down["right"] or key_down["d"] then dx = dx + 1 end
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
        if unitsByTile(hx, hy) and #unitsByTile(hx, hy) > 0 then
          for _,unit in ipairs(unitsByTile(hx, hy)) do
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
      ui.overlay.confirm({
        text = "Clear the level?",
        okText = "Yes",
        cancelText = "Cancel",
        ok = function()
          clear()
          scene.updateMap()
          loaded_level = false
        end
      })
    elseif key == "return" and settings_open then
      scene.saveSettings()
    elseif key == "g" and (key_down["lctrl"] or key_down["rctrl"]) then
        settings["grid_lines"] = not settings["grid_lines"]
        saveAll()
    end
  end
  
  if not selector_open and not settings_open and not level_dialogue.enabled then
    if key_down["lshift"] or key_down["rshift"] then
        if key == "w" then
            scene.translateLevel(0, -1)
        elseif key == "a" then
            scene.translateLevel(-1, 0)
        elseif key == "s" then
            scene.translateLevel(0, 1)
        elseif key == "d" then
            scene.translateLevel(1, 0)
        end
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
  local old_selector_page = selector_page
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
    -- print(dump(selector_tab_buttons_list))
    selector_tab_buttons_list[selector_page]:setBGImage(sprites["ui/selector_tab_"..selector_page.."_a"], sprites["ui/selector_tab_"..selector_page.."_h"])
  end
  
  --create and display meta tiles 1 higher
  if selector_open and #searchstr == 0 and (key == "lalt" or key == "m" and (key_down["lctrl"] or key_down["rctrl"])) then
    --copy so we don't override original list
    current_tile_grid = copyTable(current_tile_grid)
    for i = 0,tile_grid_width*tile_grid_height do
      if current_tile_grid[i] ~= nil and current_tile_grid[i] > 0 then
        local new_tile_id = tiles_by_name["text_" .. tiles_list[current_tile_grid[i]].name]
        if (new_tile_id ~= nil) then
          current_tile_grid[i] = new_tile_id
        else
          current_tile_grid[i] = current_tile_grid[i] + meta_offset
          tiles_listPossiblyMeta(current_tile_grid[i])
        end
      end
    end
  end
  
  --toggle nt on/off
  
  if selector_open and (key == "n" and (key_down["lctrl"] or key_down["rctrl"])) then
    --copy so we don't override original list
    current_tile_grid = copyTable(current_tile_grid)
    --revert if we're already nt'd
    local already_nted = false
    for i = 0,tile_grid_width*tile_grid_height do   
      if (current_tile_grid[i] ~= nil and (current_tile_grid[i] % meta_offset) > nt_offset) then
        already_nted = true
        break
      end
    end
    if already_nted then
      current_tile_grid = tile_grid[selector_page]
    else
      for i = 0,tile_grid_width*tile_grid_height do
        if current_tile_grid[i] ~= nil and current_tile_grid[i] > 0 then
          local new_tile_id = tiles_by_name[tiles_list[current_tile_grid[i]].name .. "n't"]
          if (new_tile_id ~= nil) then
            current_tile_grid[i] = new_tile_id
          else
            current_tile_grid[i] = current_tile_grid[i] + nt_offset
            tiles_listPossiblyMeta(current_tile_grid[i])
          end
        end
      end
    end
  end
  
  if selector_open and #searchstr == 0 and key == "ralt" or key == "r" and (key_down["lctrl"] or key_down["rctrl"]) or key == "escape" then
    current_tile_grid = tile_grid[selector_page]
  end
  
  --[[if selector_open and key == "n" and (key_down["lctrl"] or key_down["rctrl"]) then
    nt = not nt
    current_tile_grid = copyTable(current_tile_grid)
    if nt then
        for i = 0,tile_grid_width*tile_grid_height do
            if current_tile_grid[i] ~= nil and current_tile_grid[i] > 0 then
                local new_tile_id = tiles_by_name[tiles_list[current_tile_grid[i] ].name .. "n't"]
                if (new_tile_id ~= nil) then
                    current_tile_grid[i] = new_tile_id
                end
            end
        end
    else
        current_tile_grid = tile_grid[selector_page]
    end
  end]]
  if not selector_open and not level_dialogue.enabled and key == "t" and (key_down["lctrl"] or key_down["rctrl"]) then
    -- if key_down["lshift"] or key_down["rshift"] then
    --   anagram_finder.enabled = true
    --   anagram_finder.advanced = not anagram_finder.advanced
    -- else
      anagram_finder.enabled = not anagram_finder.enabled
    -- end
    if anagram_finder.enabled then
      anagram_finder.run()
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
  
  if button == 3 or (button == 2 and (key_down["lshift"] or key_down["rshift"])) then
    local hx, hy = getHoveredTile()
    if hx ~= nil then
      local tileid = hx + hy * mapwidth

      local lvl = {}
      local lin = {}
      local hovered = {}
      if unitsByTile(hx, hy) then
        for _,v in ipairs(unitsByTile(hx, hy)) do
          if v.name == "lvl" then
            table.insert(lvl, v)
          end
          if v.name == "lin" then
            table.insert(lin, v)
          end
          table.insert(hovered, v)
        end
      end
      if #lvl == 1 then
        scene.setLevelDialogue(lvl[1])
      elseif #lvl == 0 and #lin == 1 then
        scene.setLevelDialogue(lin[1])
      elseif #lvl == 0 and #lin == 0 and #hovered == 1 then
        scene.setLevelDialogue(hovered[1])
      elseif level_dialogue.enabled then
        scene.setLevelDialogue()
      end
    end
  elseif level_dialogue.enabled then
    local t = love.math.newTransform():translate(gameTileToScreen(level_dialogue.x + 0.5, level_dialogue.y))
    if level_dialogue.unit.name ~= "lin" and mouseOverBox(-100, -118, 200, 110, t) then
      -- icon style
      if mouseOverBox(-56, -95, 16, 16, t) then
        level_dialogue.unit.special.iconstyle = "number"
        if level_dialogue.unit.special.number and level_dialogue.unit.special.number > 99 then
          level_dialogue.unit.special.number = 99
        end
        level_dialogue.iconnamebox:setVisible(false)
        level_dialogue.iconnamebox:setEnabled(false)
      end
      if mouseOverBox(-38, -95, 16, 16, t) then
        level_dialogue.unit.special.iconstyle = "dots"
        if level_dialogue.unit.special.number and level_dialogue.unit.special.number < 1 then
          level_dialogue.unit.special.number = 1
        end
        if level_dialogue.unit.special.number and level_dialogue.unit.special.number > 9 then
          level_dialogue.unit.special.number = 9
        end
        level_dialogue.iconnamebox:setVisible(false)
        level_dialogue.iconnamebox:setEnabled(false)
      end
      if mouseOverBox(-20, -95, 16, 16, t) then
        level_dialogue.unit.special.iconstyle = "letter"
        if level_dialogue.unit.special.number and level_dialogue.unit.special.number > 26 then
          level_dialogue.unit.special.number = 26
        end
        level_dialogue.iconnamebox:setVisible(false)
        level_dialogue.iconnamebox:setEnabled(false)
      end
      if mouseOverBox(-2, -95, 16, 16, t) then
        level_dialogue.unit.special.iconstyle = "other"
        level_dialogue.iconnamebox:setVisible(true)
        level_dialogue.iconnamebox:setEnabled(true)
        level_dialogue.iconnamebox:setText(level_dialogue.unit.special.iconname)
      end
      -- number
      if level_dialogue.unit.special.iconstyle ~= "other" then
        local shift = key_down["lshift"] or key_down["rshift"]
        if mouseOverBox(-38, -70, 11, 16, t) then
          local min = 1
          if not level_dialogue.unit.special.iconstyle or level_dialogue.unit.special.iconstyle == "number" then min = 0 end
          level_dialogue.unit.special.number = (level_dialogue.unit.special.number or 1) - (shift and 10 or 1)
          if (level_dialogue.unit.special.number or 1) < min then
            level_dialogue.unit.special.number = min
          end
        end
        if mouseOverBox(3, -70, 11, 16, t) then
          local max = 99
          if level_dialogue.unit.special.iconstyle == "dots" then max = 9 end
          if level_dialogue.unit.special.iconstyle == "letter" then max = 26 end
          level_dialogue.unit.special.number = (level_dialogue.unit.special.number or 1) + (shift and 10 or 1)
          if (level_dialogue.unit.special.number or 1) > max then
            level_dialogue.unit.special.number = max
          end
        end
      end
      -- hidden/locked/open
      if mouseOverBox(-38, -45, 16, 16, t) then level_dialogue.unit.special.visibility = "hidden" end
      if mouseOverBox(-20, -45, 16, 16, t) then level_dialogue.unit.special.visibility = "locked" end
      if mouseOverBox(-2, -45, 16, 16, t) then level_dialogue.unit.special.visibility = "open" end
      
      if mouseOverBox(30, -96, 62, 62, t) then -- level picture
        new_scene = loadscene
        load_mode = "select"
        selected_level = {id = level_dialogue.unit.id}
        old_world = {parent = world_parent, world = world, sub_worlds = deepCopy(sub_worlds)}

        editor_save.brush = brush
      end
      if mouseOverBox(30, -30, 62, 14, t) then -- go to level
        loadLevels({level_dialogue.unit.special.name}, "edit", level_dialogue.unit)
        clear()
        loadMap()
        resetMusic(map_music, 0.1)
      end
      scene.updateMap()
    elseif level_dialogue.unit.name == "lin" and mouseOverBox(-75, -58, 150, 50, t) then
      -- hidden/locked/open
      if mouseOverBox(-59, -50, 16, 16, t) then
        level_dialogue.unit.special.visibility = "hidden"
        last_lin_hidden = true
      end
      if mouseOverBox(-41, -50, 16, 16, t) then
        level_dialogue.unit.special.visibility = "open"
        last_lin_hidden = false
      end
      -- path lock
      if mouseOverBox(-2, -50, 16, 16, t) then level_dialogue.unit.special.pathlock = "none" end
      if mouseOverBox(16, -50, 16, 16, t) then level_dialogue.unit.special.pathlock = "puffs" end
      if mouseOverBox(34, -50, 16, 16, t) then level_dialogue.unit.special.pathlock = "blossoms" end
      if mouseOverBox(52, -50, 16, 16, t) then level_dialogue.unit.special.pathlock = "orbs" end
      -- number
      if level_dialogue.unit.special.pathlock ~= "none" then
        local shift = key_down["lshift"] or key_down["rshift"]
        if mouseOverBox(7, -30, 11, 16, t) then
          level_dialogue.unit.special.number = (level_dialogue.unit.special.number or 1) - (shift and 10 or 1)
          if (level_dialogue.unit.special.number or 1) < 1 then
            level_dialogue.unit.special.number = 1
          end
        end
        if mouseOverBox(48, -30, 11, 16, t) then
          level_dialogue.unit.special.number = (level_dialogue.unit.special.number or 1) + (shift and 10 or 1)
        end
      end
      scene.updateMap()
    else
      scene.setLevelDialogue()
    end
  end
end

function scene.setLevelDialogue(unit)
  if unit then
    if level_dialogue.scale == 0 then
      level_dialogue.enabled = true
      level_dialogue.unit = unit
      level_dialogue.x, level_dialogue.y = unit.x, unit.y
      addTween(tween.new(0.1, level_dialogue, {scale = 1}), "level dialogue", function()
        level_dialogue.iconnamebox:setBounds(love.math.newTransform():translate(gameTileToScreen(unit.x + 0.5, unit.y)):transformPoint(-60, -72))
        if unit.special.iconstyle == "other" then
          level_dialogue.iconnamebox:setText(level_dialogue.unit.special.iconname)
          level_dialogue.iconnamebox:setVisible(true)
          level_dialogue.iconnamebox:setEnabled(true)
        end
      end)
    elseif level_dialogue.unit ~= unit then
      level_dialogue.iconnamebox:setVisible(false)
      level_dialogue.iconnamebox:setEnabled(false)
      addTween(tween.new(0.05, level_dialogue, {scale = 0}), "level dialogue", function()
        level_dialogue.enabled = true
        level_dialogue.unit = unit
        level_dialogue.x, level_dialogue.y = unit.x, unit.y
        addTween(tween.new(0.1, level_dialogue, {scale = 1}), "level dialogue", function()
          level_dialogue.iconnamebox:setBounds(love.math.newTransform():translate(gameTileToScreen(unit.x + 0.5, unit.y)):transformPoint(-60, -72))
          if unit.special.iconstyle == "other" then
            level_dialogue.iconnamebox:setText(level_dialogue.unit.special.iconname)
            level_dialogue.iconnamebox:setVisible(true)
            level_dialogue.iconnamebox:setEnabled(true)
          end
        end)
      end)
    else
      level_dialogue.enabled = false
      level_dialogue.iconnamebox:setVisible(false)
      level_dialogue.iconnamebox:setEnabled(false)
      addTween(tween.new(0.1, level_dialogue, {scale = 0}), "level dialogue")
    end
    return
  end
  if level_dialogue.enabled then
    level_dialogue.enabled = false
    level_dialogue.iconnamebox:setVisible(false)
    level_dialogue.iconnamebox:setEnabled(false)
    addTween(tween.new(0.1, level_dialogue, {scale = 0}), "level dialogue")
    scene.updateMap()
  end
end

function scene.keyReleased(key)
  key_down[key] = false
end

function updateSelectorTabs()
  local scale, dx, dy = scene.transformParameters()
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
      return
    end

    if ui.hovered then
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
    elseif (not settings_open or not mouseOverBox(settings_ui.x, settings_ui.y, settings_ui.w, settings_ui.h)) and not level_dialogue.enabled then
      local hx,hy = getHoveredTile()
      if hx ~= nil and ((selector_open and inBounds(hx, hy)) or (not selector_open and inBounds(hx, hy, true))) then
        local tileid = hx + hy * mapwidth

        local hovered = {}
        if unitsByTile(hx, hy) then
          for _,v in ipairs(unitsByTile(hx, hy)) do
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
                if unit.tile == brush.id and (unit.tile ~= tiles_by_name["letter_custom"] or unit.special.customletter == brush.special.customletter)
                  and matchesColor(unit.color_override, brush.color, true) then
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
                  if type(brush.color) == "string" then
                    new_unit[brush.color] = true
                    updateUnitColourOverride(new_unit)
                  elseif type(brush.color) == "table" then
                    new_unit.color_override = brush.color
                  end
                  new_unit.special = deepCopy(brush.special)
                  if last_lin_hidden and brush.id == tiles_by_name["lin"] then
                    new_unit.special.visibility = "hidden"
                  end
                  --[[if brush.id == tiles_by_name["letter_custom"] then
                    new_unit.special.customletter = brush.customletter
                  end]]
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
              end
            end
          else
            local selected = hx + hy * tile_grid_width
            if current_tile_grid[selected] then
              brush.id = current_tile_grid[selected]
              brush.special = {}
              brush.picked_tile = nil
              brush.picked_index = 0
            else
              brush.id = nil
              brush.special = {}
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
                brush.color = hovered[new_index].color_override
                --brush.customletter = hovered[new_index].special.customletter
                if hovered[new_index].name == "lin" then
                  last_lin_hidden = (hovered[new_index].special.visibility == "hidden")
                end
                brush.special = hovered[new_index].special
              else
                brush.id = hovered[1].tile 
                brush.color = hovered[1].color_override
                --brush.customletter = hovered[1].special.customletter
                if hovered[1].name == "lin" then
                  last_lin_hidden = (hovered[1].special.visibility == "hidden")
                end
                brush.special = hovered[1].special
                brush.picked_index = 1
              end
              brush.mode = "picking"
            else
              brush.id = nil
              brush.special = {}
              brush.picked_tile = nil
              brush.picked_index = 0
              mobile_picking = false
            end
          end
        end
      end
    end
    
    if level_dialogue.enabled and level_dialogue.unit.name ~= "lin" and level_dialogue.unit.special.iconstyle == "other" then
      if level_dialogue.lastUnit == level_dialogue.unit then
        local iconname = level_dialogue.iconnamebox:getText()
        if sprites[iconname] or iconname == "" then
          level_dialogue.unit.special.iconname = iconname
          level_dialogue.iconnamebox.style.bgColor = {getPaletteColor(0, 0)}
        else
          level_dialogue.iconnamebox.style.bgColor = {getPaletteColor(2, 2)}
        end
      else
        level_dialogue.lastUnit = level_dialogue.unit
        local iconname = level_dialogue.iconnamebox:setText(level_dialogue.unit.special.iconname or "")
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

  local scales = {0.25, 0.375, 0.5, 0.75, 1, 2, 3, 4}
  if selector_open then
    table.insert(scales, 6, 1.5)
  end

  local scale = scales[1]
  for _,s in ipairs(scales) do
    if screenwidth >= roomwidth * s and screenheight >= roomheight * s + (selector_open and 120 or 0) then
        scale = s
    else break end
  end
  if settings["game_scale"] ~= "auto" and settings["game_scale"] < scale then
    scale = settings["game_scale"]
  end

  local scaledwidth = screenwidth * (1/scale)
  local scaledheight = screenheight * (1/scale)

  local dx = scaledwidth / 2 - roomwidth / 2
  local dy = scaledheight / 2 - roomheight / 2 + (is_mobile and sprites["ui/cog"]:getHeight()/scale or 0)
  
  return scale, dx, dy
end

function scene.getTransform()
  local transform = love.math.newTransform()

  local scale, dx, dy = scene.transformParameters()

  transform:scale(scale, scale)
  transform:translate(dx, dy)
  
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

    local function setColor(color, opacity)
      color = type(color[1]) == "table" and color[1] or color
      if #color == 3 then
        color = {color[1]/255, color[2]/255, color[3]/255, 1}
      else
        color = {getPaletteColor(color[1], color[2])}
        color[4] = color[4] * (opacity or 1)
      end
      love.graphics.setColor(color)
      return color
    end
  
    if not selector_open then
      if settings["grid_lines"] then
            love.graphics.setLineWidth(1)
            local r,g,b,a = getPaletteColor(0,1)
            love.graphics.setColor(r,g,b,0.3)
            for i=1,mapwidth-1 do
                love.graphics.line(i*TILE_SIZE,0,i*TILE_SIZE,roomheight)
            end
            for i=1,mapheight-1 do
                love.graphics.line(0,i*TILE_SIZE,roomwidth,i*TILE_SIZE)
            end
        end
    
      for i=1,max_layer do
        if units_by_layer[i] then
          for _,unit in ipairs(units_by_layer[i]) do
            local sprite = sprites[unit.sprite]
            local color = unit.color_override or unit.color
            setColor(color)
            if unit.name == "lin" then
              local name = "lin"
              --performance todos: each line gets drawn twice (both ways), so there's probably a way to stop that. might not be necessary though, since there is no lag so far
              --in fact, the double lines add to the pixelated look, so for now i'm going to make it intentional and actually add it in a couple places to be consistent
              if settings["draw_editor_lins"] and (not unit.special.pathlock or unit.special.pathlock == "none") then
                love.graphics.setLineStyle("rough")
                local orthos = {}
                local line = {}
                for ndir=1,4 do
                  local nx,ny = dirs[ndir][1],dirs[ndir][2]
                  local px,py = unit.x + nx, unit.y + ny
                  if inBounds(px,py) then
                    local around = getUnitsOnTile(px,py)
                    for _,other in ipairs(around) do
                      if other.name == "lin" or other.name == "lvl" then
                        orthos[ndir] = true
                        table.insert(line,{unit.x*2-unit.draw.x+nx+other.draw.x-other.x, unit.y*2-unit.draw.y+ny+other.draw.y-other.y, other.special.visibility == "hidden"})
                        break
                      else
                        orthos[ndir] = false
                      end
                    end
                  else
                    orthos[ndir] = true
                    table.insert(line,{px,py})
                  end
                end
                for ndir=2,8,2 do
                  local nx,ny = dirs8[ndir][1],dirs8[ndir][2]
                  local px,py = unit.x + nx, unit.y + ny
                  local around = getUnitsOnTile(px,py)
                  for _,other in ipairs(around) do
                    if (other.name == "lin" or other.name == "lvl") and not orthos[ndir/2] and not orthos[dirAdd(ndir,2)/2] then
                      table.insert(line,{unit.x*2-unit.draw.x+nx+other.draw.x-other.x, unit.y*2-unit.draw.y+ny+other.draw.y-other.y, other.special.visibility == "hidden"})
                      break
                    end
                  end
                end
                if (#line > 0) then
                  local fulldrawx, fulldrawy = (unit.x + 0.5)*TILE_SIZE, (unit.y + 0.5)*TILE_SIZE
                  -- love.graphics.rectangle("fill", fulldrawx-1, fulldrawy-1, 1, 3)
                  -- love.graphics.rectangle("fill", fulldrawx-2, fulldrawy, 3, 1)
                  for _,point in ipairs(line) do
                    --no need to change the rendering to account for movement, since all halflines are drawn to static objects (portals and oob)
                    local dx = unit.x-point[1]
                    local dy = unit.y-point[2]
                    
                    --draws it twice to make it look the same as the other lines. should be reduced to one if we figure out that performance todo above
                    --   love.graphics.setLineWidth(3)
                    -- if dx == 0 or dy == 0 then
                    --   love.graphics.setLineWidth(3)
                    -- else
                    --   love.graphics.setLineWidth(3)
                    -- end

                    if unit.special.visibility ~= "hidden" then
                      local odx = TILE_SIZE*dx/(point[3] and 4 or 2)
                      local ody = TILE_SIZE*dy/(point[3] and 4 or 2)
                      love.graphics.setLineWidth(4)
                      love.graphics.line(fulldrawx+dx,fulldrawy+dy,fulldrawx-odx,fulldrawy-ody)
                    else
                      local odx = TILE_SIZE*dx/4
                      local ody = TILE_SIZE*dy/4
                      love.graphics.setLineWidth(2)
                      love.graphics.line(fulldrawx+dx,fulldrawy+dy,fulldrawx-odx,fulldrawy-ody)
                    end
                  end
                end
                if #line > 0 then
                  name = "no1"
                end
                love.graphics.setLineWidth(2)
              end
              if unit.special.pathlock and unit.special.pathlock ~= "none" then
                name = name.."_gate"
                setColor({2, 2})
              end
              if name ~= "no1" then
                if unit.special.visibility == "hidden" then name = name.."_hidden" end
              end
              sprite = sprites[name]
            end
            if unit.name == "lvl" and unit.special.visibility == "hidden" then
              sprite = sprites["lvl_hidden"]
            end
            if not sprite then sprite = sprites["wat"] end
            
            local rotation = 0
            if unit.rotate then
              rotation = (unit.dir - 1) * 45
            end

            if rainbowmode then
              local newcolor = hslToRgb((love.timer.getTime()/3+unit.x/18+unit.y/18)%1, .5, .5, 1)
              newcolor[1] = newcolor[1]*255
              newcolor[2] = newcolor[2]*255
              newcolor[3] = newcolor[3]*255
              unit.color_override = newcolor
            end
            
            if unit.fullname == "letter_custom" then
              drawCustomLetter(unit.special.customletter, (unit.x + 0.5)*TILE_SIZE, (unit.y + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
            else
              if type(unit.sprite) == "table" then
                for j,image in ipairs(unit.sprite) do
                  sprite = sprites[image]
                  setColor(getUnitColors(unit, j))
                  love.graphics.draw(sprite, (unit.x + 0.5)*TILE_SIZE, (unit.y + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
                end
              else
                love.graphics.draw(sprite, (unit.x + 0.5)*TILE_SIZE, (unit.y + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
              end
            end
            if unit.name == "lvl" then
              if unit.special.visibility ~= "open" then
                local r,g,b,a = love.graphics.getColor()
                love.graphics.setColor(r,g,b, a*0.4)
              end
              local fulldrawx, fulldrawy = (unit.x + 0.5)*TILE_SIZE, (unit.y + 0.5)*TILE_SIZE
              if not unit.special.iconstyle or unit.special.iconstyle == "number" then
                local num = tostring(unit.special.number or 1)
                if #num == 1 then
                  num = "0"..num
                end
                love.graphics.draw(sprites["levelicon_"..num:sub(1,1)], fulldrawx+(4*unit.draw.scalex), fulldrawy+(4*unit.draw.scaley), 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
                love.graphics.draw(sprites["levelicon_"..num:sub(2,2)], fulldrawx+(16*unit.draw.scalex), fulldrawy+(4*unit.draw.scaley), 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
              elseif unit.special.iconstyle == "dots" then
                local num = tostring(unit.special.number or 1)
                love.graphics.draw(sprites["levelicon_dots_"..num], fulldrawx+(4*unit.draw.scalex), fulldrawy+(4*unit.draw.scaley), 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
              elseif unit.special.iconstyle == "letter" then
                local num = unit.special.number or 1
                local letter = ("abcdefghijklmnopqrstuvwxyz"):sub(num, num)
                love.graphics.draw(sprites["letter_"..letter], fulldrawx, fulldrawy, 0, unit.draw.scalex*3/4, unit.draw.scaley*3/4, sprite:getWidth() / 2, sprite:getHeight() / 2)
              elseif unit.special.iconstyle == "other" then
                local sprite = sprites[unit.special.iconname or "wat"] or sprites["wat"]
                love.graphics.draw(sprite, fulldrawx, fulldrawy, 0, unit.draw.scalex*3/4, unit.draw.scaley*3/4, sprite:getWidth() / 2, sprite:getHeight() / 2)
              end
            end
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
              local ntsprite = sprites["n't"]
              love.graphics.draw(ntsprite, (unit.x + 0.5)*TILE_SIZE, (unit.y + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
              setColor(unit.color)
            end
            if displayids then
              setColor({1,4})
              love.graphics.printf(tostring(unit.id), (unit.x + 0.5)*TILE_SIZE-3, (unit.y + 0.5)*TILE_SIZE-18, 32, "center")
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

            local color = brush.color or tile.color
            setColor(color)

            if rainbowmode then love.graphics.setColor(hslToRgb((love.timer.getTime()/3+x/tile_grid_width+y/tile_grid_height)%1, .5, .5, 1)) end
            
            local found_matching_tag = false
            local tilename = tile.name:gsub(" ","")
            
            if tile.tags ~= nil then
              for _,tag in ipairs(tile.tags) do
                tag = tag:gsub(" ","")
                if string.match(tag, subsearchstr) then
                  found_matching_tag = true
                  break
                end
              end
            end
            
            if string.match(tilename, subsearchstr) then
              found_matching_tag = true
            end
            
            if tile.type and string.match(tile.type, subsearchstr) then
              found_matching_tag = true
            end
            
            if tile.texttype ~= nil then
              for type,_ in pairs(tile.texttype) do
                if string.match(type, subsearchstr) then
                  found_matching_tag = true
                  break
                end
              end
            end
            
            if tile.pronouns ~= nil then
              for _,pronoun in ipairs(tile.pronouns) do
                if string.match(pronoun, subsearchstr) then
                  found_matching_tag = true
                  break
                end
              end
            end
            
            if tile.meta ~= nil and string.match("meta",subsearchstr) then
              found_matching_tag = true
            end
            
            if tile.nt ~= nil and (string.match("nt",subsearchstr) or string.match("n't",subsearchstr)) then
              found_matching_tag = true
            end
            
            if not found_matching_tag then love.graphics.setColor(0.2,0.2,0.2) end
            
            if type(tile.sprite) == "table" then
              for j,image in ipairs(tile.sprite) do
                sprite = sprites[image]
                if found_matching_tag then setColor(getUnitColors(tile, j, brush.color)) end
                love.graphics.draw(sprite, (x + 0.5)*TILE_SIZE, (y + 0.5)*TILE_SIZE, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
              end
            else
              love.graphics.draw(sprite, (x + 0.5)*TILE_SIZE, (y + 0.5)*TILE_SIZE, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
            end
            
            if (tile.meta ~= nil) then
              if found_matching_tag then setColor({4, 1}) end
              local metasprite = tile.meta == 2 and sprites["meta2"] or sprites["meta1"]
              love.graphics.draw(metasprite, (x + 0.5)*TILE_SIZE, (y + 0.5)*TILE_SIZE, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
              if tile.meta > 2 then
                love.graphics.printf(tostring(tile.meta), (x + 0.5)*TILE_SIZE-1, (y + 0.5)*TILE_SIZE+6, 32, "center")
              end
              setColor(tile.color)
            end
            if (tile.nt ~= nil) then
              if found_matching_tag then setColor({2, 2}) end
              local ntsprite = sprites["n't"]
              love.graphics.draw(ntsprite, (x + 0.5)*TILE_SIZE, (y + 0.5)*TILE_SIZE, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
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
      if not (ui.hovered or gooi.showingDialog or capturing) then
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("line", hx * TILE_SIZE, hy * TILE_SIZE, TILE_SIZE, TILE_SIZE)
        
        if brush.id and not selector_open then
          local tile = tiles_list[brush.id]
          local sprite_name = tile.sprite
          local sprite = sprites[sprite_name]
          if not sprite then sprite = sprites["wat"] end

          local rotation = 0
          if tile.rotate then
            rotation = (brush.dir - 1) * 45
          end
          
          local color = brush.color or tile.color
          color = type(color[1]) == "table" and color[1] or color
          if #color == 3 then
            love.graphics.setColor(color[1]/255, color[2]/255, color[3]/255, 0.25)
          else
            local r, g, b, a = getPaletteColor(color[1], color[2])
            love.graphics.setColor(r, g, b, a * 0.25)
          end
          
          if type(sprite_name) == "table" then
            for i,image in ipairs(sprite_name) do
              local r, g, b, a = getPaletteColor(tile.color_override and tile.color_override[i][1] or tile.color[i][1], tile.color_override and tile.color_override[i][2] or tile.color[i][2])
              love.graphics.setColor(r, g, b, a * 0.25)
              local sprit = sprites[image]
              love.graphics.draw(sprit, (hx + 0.5)*TILE_SIZE, (hy + 0.5)*TILE_SIZE, math.rad(rotation), 1, 1, sprit:getWidth() / 2, sprit:getHeight() / 2)
            end
          else
            love.graphics.draw(sprite, (hx + 0.5)*TILE_SIZE, (hy + 0.5)*TILE_SIZE, math.rad(rotation), 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
          end
          
          if tile.meta ~= nil then
            setColor({4,1},0.25)
            local metasprite = tile.meta == 2 and sprites["meta2"] or sprites["meta1"]
            love.graphics.draw(metasprite, (hx + 0.5)*TILE_SIZE, (hy + 0.5)*TILE_SIZE, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
            if tile.meta > 2 then
              love.graphics.printf(tostring(tile.meta), (hx + 0.5)*TILE_SIZE-1, (hy + 0.5)*TILE_SIZE+6, 32, "center")
            end
            setColor(tile.color)
          end
          if (tile.nt ~= nil) then
            setColor({2,2},0.25)
            local ntsprite = sprites["n't"]
            love.graphics.draw(ntsprite, (hx + 0.5)*TILE_SIZE, (hy + 0.5)*TILE_SIZE, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
            setColor(tile.color)
          end
        end
      end

      last_hovered_tile = {hx, hy}
    end

    if selector_open then
      love.graphics.setColor(getPaletteColor(0,3))
      if settings["infomode"] then love.graphics.print(last_hovered_tile[1] .. ', ' .. last_hovered_tile[2], 0, roomheight+36) end
      if not is_mobile then
        if not settings["infomode"] then
          love.graphics.printf("CTRL + TAB to change tabs", 0, roomheight, roomwidth, "right")
          love.graphics.printf("LALT to get meta text, RALT to refresh", 0, roomheight+12, roomwidth, "right")
          love.graphics.printf("CTRL + N to toggle n't text", 0, roomheight+24, roomwidth, "right")
        end
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
      if inBounds(last_hovered_tile[1], last_hovered_tile[2]) and i ~= nil then
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
        if settings["infomode"] then
          love.graphics.push()
          love.graphics.applyTransform(scene.getTransform())
          love.graphics.print("Name: " .. tile.name, 0, roomheight+12)
          love.graphics.print("Layer: " .. tostring(tile.layer), 150, roomheight)
          if tile.type then
            love.graphics.print("Type: " .. tile.type, 150, roomheight+12)
          else
            love.graphics.print("Type: object", 150, roomheight+12)
          end
          local color = dump(tile.color)
          if type(tile.color[1]) == "table" then
            color = color:sub(2,-2)
          end
          color = color:gsub("{","(")
          color = color:gsub("}",")")
          love.graphics.print("Color: " .. color, 150, roomheight+36)
          if tile.sing ~= nil then
            love.graphics.print("Instrument: " .. tile.sing, 250, roomheight)
          else
            love.graphics.print("Instrument: bit (default)", 250, roomheight)
          end
          local tags = ""
          if tile.type == "text" and tile.texttype then
            for key,_ in pairs(tile.texttype) do
              if key == "cond_infix" then
                tags = tags .. "infix condition, "
              elseif key == "cond_infix_dir" then
                tags = tags .. "direction infix condition, "
              elseif key == "cond_prefix" then
                tags = tags .. "prefix condition, "
              elseif key == "verb_unit" then
                tags = tags .. "unit verb, "
              elseif key == "verb_class" then
                tags = tags .. "class verb, "
              elseif key == "verb_sing" then
                tags = tags .. "special verb, "
              elseif key == "verb_be" or key == "and" or key == "not" then
              else
                tags = tags .. key:gsub("_"," ") .. ", "
              end
            end
          elseif tile.meta ~= nil then
            tags = tags .. "meta, "
          elseif tile.nt ~= nil then
            tags = tags .. "nt, "
          else
            tags = "object, "
          end
          if tile.tags ~= nil then
            tags = table.concat(tile.tags,", ") .. ", " .. tags
          end
          love.graphics.print(tags:sub(1,-3), 0, roomheight+24)
          love.graphics.pop()
        end
      end
    end
    
    if not selector_open and level_dialogue.scale > 0 then
      love.graphics.push()
      love.graphics.translate(gameTileToScreen(level_dialogue.x + 0.5, level_dialogue.y))
      love.graphics.scale(level_dialogue.scale)
      
      local unit = level_dialogue.unit
      
      if unit.name ~= "lin" then
        local width, height = 200, 110
        love.graphics.setColor(getPaletteColor(0, 4))
        love.graphics.polygon("fill", -4, -8, 0, 0, 4, -8)
        love.graphics.rectangle("fill", -width/2, -height-8, width, height)
    
        love.graphics.setColor(getPaletteColor(3, 3))
        love.graphics.setLineWidth(2)
        love.graphics.line(-width/2, -height-8, -width/2, -8, -4, -8, 0, 0, 4, -8, width/2, -8, width/2, -height-8, -width/2, -height-8)
        love.graphics.line(22, -height-0.5, 22, -15.5)
        
        love.graphics.setColor(1,1,1,1)
        love.graphics.print("Style", -92, -95)
        love.graphics.print(({number = "Number", dots = "Number", letter = "Letter", other = "Icon"})[unit.special.iconstyle or "number"], -92, -70)
        love.graphics.print(({hidden = "Hidden", locked = "Locked", open = "Open"})[unit.special.visibility or "locked"], -92, -45)
        
        
        love.graphics.setColor(getPaletteColor(0, 0))
        -- style
        love.graphics.rectangle("fill", -56, -95, 16, 16)
        love.graphics.rectangle("fill", -38, -95, 16, 16)
        love.graphics.rectangle("fill", -20, -95, 16, 16)
        love.graphics.rectangle("fill", -2, -95, 16, 16)
        -- number
        if unit.special.iconstyle ~= "other" then
          love.graphics.rectangle("fill", -27, -70, 30, 16)
        end
        -- hidden/locked/open
        love.graphics.rectangle("fill", -38, -45, 16, 16)
        love.graphics.rectangle("fill", -20, -45, 16, 16)
        love.graphics.rectangle("fill", -2, -45, 16, 16)
        
        love.graphics.rectangle("fill", 30, -96, 62, 62) -- level picture
        love.graphics.rectangle("fill", 30, -30, 62, 14) -- go to level
        
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(sprites["ui/iconstyle_number"], -56, -95)
        love.graphics.draw(sprites["ui/iconstyle_dots"], -38, -95)
        love.graphics.draw(sprites["ui/iconstyle_letter"], -20, -95)
        love.graphics.draw(sprites["ui/iconstyle_other"], -2, -95)
        
        if unit.special.iconstyle ~= "other" then
          love.graphics.draw(sprites["ui/arrow_small"], -38, -70)
          love.graphics.draw(sprites["ui/arrow_small"], 3, -70, math.pi, 1, 1, 11, 16)
        end
        
        love.graphics.draw(sprites["ui/levelbox_hidden"], -38, -45)
        love.graphics.draw(sprites["ui/levelbox_locked"], -20, -45)
        love.graphics.draw(sprites["ui/levelbox_open"], -2, -45)
        
        if not unit.special.iconstyle or unit.special.iconstyle == "number" or unit.special.iconstyle == "dots" then
          love.graphics.printf(tostring(unit.special.number or 1), -27, -70, 30, "center")
        elseif unit.special.iconstyle == "letter" then
          love.graphics.printf(("ABCDEFGHIJKLMNOPQRSTUVWXYZ"):sub(unit.special.number or 1, unit.special.number or 1), -27, -70, 30, "center")
        end
        love.graphics.setLineWidth(1)
        love.graphics.setColor(getPaletteColor(5, 2))
        love.graphics.rectangle("line", 15.5-18*({number = 4, dots = 3, letter = 2, other = 1})[unit.special.iconstyle or "number"], -95.5, 17, 17)
        love.graphics.rectangle("line", 15.5-18*({hidden = 3, locked = 2, open = 1})[unit.special.visibility or "locked"], -45.5, 17, 17)
        
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.setColor(1,1,1,1)
        local _, lines = love.graphics.getFont():getWrap((unit.special.name or "select level"):upper(), 64)
        love.graphics.printf(lines[1], 31, -110, 60, "center")
        if lines[2] then
          love.graphics.printf("...", 31, -106, 60, "center")
        end
        local dir = "levels/"
        if world ~= "" then dir = getWorldDir() .. "/" end
        if unit.special.level then
          icon_data = getIcon(dir .. unit.special.level)
        else
          icon_data = nil
        end
        love.graphics.draw(icon_data or sprites["ui/default icon"], 31, -95, 0, 0.625)
        
        if unit.special.name then
          love.graphics.printf("Go to Level", 31, -28, 60, "center")
        end
    
        love.graphics.pop()
      else -- unit.name == line
        local width, height = 150, 50
        love.graphics.setColor(getPaletteColor(0, 4))
        love.graphics.polygon("fill", -4, -8, 0, 0, 4, -8)
        love.graphics.rectangle("fill", -width/2, -height-8, width, height)
    
        love.graphics.setColor(getPaletteColor(3, 3))
        love.graphics.setLineWidth(2)
        love.graphics.line(-width/2, -height-8, -width/2, -8, -4, -8, 0, 0, 4, -8, width/2, -8, width/2, -height-8, -width/2, -height-8)
        love.graphics.line(-10, -height-0.5, -10, -15.5)
        
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf(({hidden = "Hidden", open = "Open"})[unit.special.visibility or "open"], -70, -31, 55, "center")
        if not unit.special.pathlock or unit.special.pathlock == "none" then
          love.graphics.printf("Unlocked", -5, -31, 75, "center")
        end
        
        
        love.graphics.setColor(getPaletteColor(0, 0))
        -- hidden/open
        love.graphics.rectangle("fill", -59, -50, 16, 16)
        love.graphics.rectangle("fill", -41, -50, 16, 16)
        -- number
        if unit.special.pathlock and unit.special.pathlock ~= "none" then
          love.graphics.rectangle("fill", 18, -30, 30, 16)
        end
        -- path lock
        love.graphics.rectangle("fill", -2, -50, 16, 16)
        love.graphics.rectangle("fill", 16, -50, 16, 16)
        love.graphics.rectangle("fill", 34, -50, 16, 16)
        love.graphics.rectangle("fill", 52, -50, 16, 16)
        
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(sprites["ui/levelbox_hidden"], -59, -50)
        love.graphics.draw(sprites["ui/lin_visible"], -41, -50)
        
        love.graphics.draw(sprites["ui/pathlock_none"], -2, -50)
        love.graphics.draw(sprites["ui/pathlock_puffs"], 16, -50)
        love.graphics.draw(sprites["ui/pathlock_blossoms"], 34, -50)
        love.graphics.draw(sprites["ui/pathlock_orbs"], 52, -50)
        
        if unit.special.pathlock and unit.special.pathlock ~= "none" then
          love.graphics.draw(sprites["ui/arrow_small"], 7, -30)
          love.graphics.draw(sprites["ui/arrow_small"], 48, -30, math.pi, 1, 1, 11, 16)
        end
        
        if unit.special.pathlock and unit.special.pathlock ~= "none" then
          love.graphics.printf(tostring(unit.special.number or 1), 18, -30, 30, "center")
        end
        love.graphics.setLineWidth(1)
        love.graphics.setColor(getPaletteColor(5, 2))
        love.graphics.rectangle("line", -23.5-18*({hidden = 2, open = 1})[unit.special.visibility or "open"], -50.5, 17, 17)
        love.graphics.rectangle("line", -20.5+18*({none = 1, puffs = 2, blossoms = 3, orbs = 4})[unit.special.pathlock or "none"], -50.5, 17, 17)
    
        love.graphics.pop()
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
    
    if anagram_finder.enabled then
      love.graphics.setColor(0, 0, 0, 0.4)
      love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  
      local words = ""
  
      local wordsnum = 0
      local lines = 0.5
  
      for i,word in pairs(anagram_finder.words) do
        words = words..word
        wordsnum = wordsnum + 1

        if wordsnum % 6 >= 5 then
          words = words..'\n'
          lines = lines + 1
        else
          words = words..'   '
        end
      end
  
      words = 'possible words:\n'..words
  
      love.graphics.setColor(1,1,1)
      love.graphics.printf(words, 0, love.graphics.getHeight()/2-love.graphics.getFont():getHeight()*lines/2+0.5, love.graphics.getWidth(), "center")
    end
    
    if is_mobile then
      local twelfth = love.graphics.getWidth()/12
      if mobile_picking then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(sprites["ui_plus"],10*twelfth,love.graphics.getHeight()-2*twelfth,0,twelfth/32,twelfth/32)
      elseif brush.id then
        local sprite = tiles_list[brush.id].sprite
        if not sprite then sprite = "wat" end
        
        local rotation = 0
        if tiles_list[brush.id].rotate then
          rotation = (brush.dir - 1) * 45
        end
        
        local color = tiles_list[brush.id].color
        if type(color[1]) ~= "table" then
          if #color > 2 then
            love.graphics.setColor(color[1]/255, color[2]/255, color[3]/255, color[4] and color[4]/255 or 1)
          else
            love.graphics.setColor(getPaletteColor(color[1], color[2]))
          end
        end
        
        if type(sprite) == "table" then
          for i,image in ipairs(sprite) do
            love.graphics.setColor(getPaletteColor(color[i][1], color[i][2]))
            love.graphics.draw(sprites[image], 10.5*twelfth, love.graphics.getHeight()-1.5*twelfth,math.rad(rotation),twelfth/32,twelfth/32,twelfth/4,twelfth/4)
          end
        else
          love.graphics.draw(sprites[sprite], 10.5*twelfth, love.graphics.getHeight()-1.5*twelfth,math.rad(rotation),twelfth/32,twelfth/32,twelfth/4,twelfth/4)
        end
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
    
    if paint_open then
      for _,button in ipairs(paint_colors) do
        local x = button[1]
        local tile, pal
        if brush.id then
          tile = tiles_list[brush.id]
          pal = button[2] or (type(tile.color[1]) == "table" and tile.color[1] or tile.color)
        else
          pal = button[2] or {0, 3}
        end
        if not tile then
          love.graphics.setColor(getPaletteColor(pal[1], pal[2]))
          love.graphics.draw(sprites["ui/splat"], x, 4)
        elseif type(tile.sprite) == "table" then
          for i,image in ipairs(tile.sprite) do
            if tile.colored[i] then
              love.graphics.setColor(getPaletteColor(pal[1], pal[2]))
            else
              love.graphics.setColor(getPaletteColor(tile.color[i][1], tile.color[i][2]))
            end
            love.graphics.draw(sprites[image], x, 4)
          end
        else
          love.graphics.setColor(getPaletteColor(pal[1], pal[2]))
          if tile.name == "letter_custom" then
            drawCustomLetter(brush.special.customletter, x, 4)
          else
            love.graphics.draw(sprites[tile.sprite], x, 4)
          end
        end
        if paint_open == "full" then break end
      end
    end

    love.graphics.setFont(name_font)
    love.graphics.setColor(1, 1, 1)

    if not paint_open then
      love.graphics.printf(level_name, 0, name_font:getLineHeight() / 2, love.graphics.getWidth(), "center")
    end
    
    love.graphics.setColor(1, 1, 1, saved_popup.alpha)
    if is_mobile then
      love.graphics.draw(saved_popup.sprite, 44, 40 + saved_popup.y)
    else
      love.graphics.draw(saved_popup.sprite, 0, 40 + saved_popup.y)
    end

    if settings_open then
      love.graphics.setColor(0.1, 0.1, 0.1, 1)
      love.graphics.rectangle("fill", settings_ui.x, settings_ui.y, settings_ui.w, settings_ui.h)
      love.graphics.setColor(1, 1, 1, 1)
      gooi.draw("settings")
    end
    love.graphics.pop()

    if capturing then
      love.graphics.setColor(0.5, 0.5, 0.5, 1)
      love.graphics.draw(screenshot_image)

      if start_drag then
        local rect, real_rect = scene.getCaptureRect()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setScissor(rect.x, rect.y, rect.w, rect.h)
        love.graphics.draw(screenshot_image)
        love.graphics.setScissor()
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h)
        love.graphics.setLineWidth(1)
        if real_rect then
          love.graphics.setColor(1, 1, 1, 0.5)
          love.graphics.rectangle("line", real_rect.x, real_rect.y, real_rect.w, real_rect.h)
        end
        love.graphics.setColor(1, 1, 1, 1)
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
      if unitsByTile(x, y) then
        for _,unit in ipairs(unitsByTile(x, y)) do
          table.insert(map, {id = unit.id, tile = unit.tile, x = unit.x, y = unit.y, dir = unit.dir, special = unit.special, color = unit.color_override})
        end
      end
    end
  end
  local info = {
    name = level_name,
    author = level_author,
    extra = level_extra,
    palette = current_palette,
    music = map_music,
    width = mapwidth,
    height = mapheight,
    version = map_ver,
    parent_level = level_parent_level,
    next_level = level_next_level,
    is_overworld = level_is_overworld,
    puffs_to_clear = level_puffs_to_clear,
    background_sprite = level_background_sprite,
  }
  map = serpent.dump(map)
  maps = {{data = map, info = info}}
  if anagram_finder.enabled then anagram_finder.run() end
  level_filename = level_name
  if #sub_worlds > 0 then level_filename = table.concat(sub_worlds, "/") .. "/" .. level_filename end
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

  local map = maps[1]

  level_compression = settings["level_compression"]
  local mapdata = level_compression == "zlib" and love.data.compress("string", "zlib", map.data) or map.data
  local savestr = love.data.encode("string", "base64", mapdata)

  map.info.compression = level_compression
  map.info.map = savestr
  
  local file_name = sanitize(level_name)

  if world == "" or (RELEASE_BUILD and world_parent == "officialworlds") then
    love.filesystem.createDirectory("levels")
    love.filesystem.write("levels/" .. file_name .. ".bab", json.encode(map.info))
    print("Saved to:","levels/" .. file_name .. ".bab")
    if icon_data then
      pcall(function() icon_data:encode("png", "levels/" .. file_name .. ".png") end)
    end
  else
    if world_parent == "officialworlds" then
      local file = love.filesystem.getSource() .. "/" .. getWorldDir(true) .. "/" .. file_name
      local f = io.open(file..".bab", "w"); f:write(json.encode(map.info)); f:close()
      if icon_data then
        local success, png_data = pcall(function() return icon_data:encode("png") end)
        if success then
          local f = io.open(file..".png", "wb")
          f:write(png_data:getString())
          f:close()
        end
      end
    else
      love.filesystem.createDirectory(getWorldDir(true))
      love.filesystem.write(getWorldDir(true) .. "/" ..file_name .. ".bab", json.encode(map.info))
      if icon_data then
        pcall(function() icon_data:encode("png", getWorldDir(true) .. "/" .. file_name .. ".png") end)
      end
    end
    print("Saved to:",getWorldDir(true) .. "/" ..file_name .. ".bab")
  end

  last_saved = map.data

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

  mapwidth = input_width:getValue()
  mapheight = input_height:getValue()
  level_extra = input_extra.checked
  
  scene.updateMap()

  clear()
  loadMap()
  resetMusic(map_music, 0.1)

  scene.updateMap()

  if author_change then
    ui.overlay.confirm({
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

  saved_settings = true
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
    maps = {{data = loadstring("return " .. mapstr)(), info = mapdata}}
  else
    maps = {{data = mapstr, info = mapdata}}
  end

  level_filename = level_name
  if #sub_worlds > 0 then level_filename = table.concat(sub_worlds, "/") .. "/" .. level_filename end

  clear()
  loadMap()

  if (brush ~= nil) then
    brush.picked_tile = nil
    brush.picked_index = 0
  end

  local dir = "levels/"
  if world ~= "" then dir = getWorldDir(true) .. "/" end
  icon_data = getIcon(dir .. level_name)

  resetMusic(map_music, 0.1)
end

function scene.captureIcon()
  if start_drag == nil then
    capturing = false
    screenshot = nil
    screenshot_image = nil
    return
  end

  local rect = scene.getCaptureRect()

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
  saved_settings = true
end

function scene.resize(w, h)
  clearGooi()
  scene.setupGooi()
end

function scene.translateLevel(dx, dy)
  for _,unit in ipairs(units) do
    local x, y = unit.x+dx, unit.y+dy
    if x > mapwidth-1 then x = 0 end
    if y > mapheight-1 then y = 0 end
    if x < 0 then x = mapwidth-1 end
    if y < 0 then y = mapheight-1 end
    moveUnit(unit, x, y)
  end
  scene.updateMap()
end

function scene.wheelMoved(whx, why)
  if brush.id and tiles_list[brush.id] and tiles_list[brush.id].name then
    local new = tiles_list[brush.id].name
    if why < 0 then -- modified from 'x be meta' code
      if tiles_list[brush.id].tometa then
        new = tiles_list[brush.id].tometa
      else
        new = "text_"..new
      end
    elseif why > 0 then
      if tiles_list[brush.id].demeta then
        new = tiles_list[brush.id].demeta
      else
        if new:starts("text_") then
          new = new:sub(6, -1)
        else
          new = new
        end -- not gonna set it to nothing
      end
    end
    brush.id = tiles_by_namePossiblyMeta(new) or brush.id
  end
end

function scene.getCaptureRect()
  local rect = {
    x = start_drag.x, 
    y = start_drag.y,
    w = love.mouse.getX() - start_drag.x,
    h = love.mouse.getY() - start_drag.y
  }

  if not love.keyboard.isDown("lshift") then
    local size = math.max(math.abs(rect.w), math.abs(rect.h))

    if rect.w < 0 then
      rect.x = rect.x - size
    end
    if rect.h < 0 then
      rect.y = rect.y - size
    end
    rect.w = size
    rect.h = size

    return rect
  else
    if rect.w < 0 then
      rect.x = rect.x + rect.w
      rect.w = math.abs(rect.w)
    end
    if rect.h < 0 then
      rect.y = rect.y + rect.h
      rect.h = math.abs(rect.h)
    end

    local cx = rect.x + rect.w / 2
    local cy = rect.y + rect.h / 2

    local size = math.max(rect.w, rect.h)
    return {
      x = cx - size / 2,
      y = cy - size / 2,
      w = size,
      h = size
    }, rect
  end
end

return scene