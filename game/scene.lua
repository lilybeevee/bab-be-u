local scene = {}
window_dir = 0

local mask_shader = pcallNewShader[[
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
     if (Texel(texture, texture_coords).rgb == vec3(0.0)) {
        // a discarded pixel wont be applied as the stencil.
        discard;
     }
     return vec4(1.0);
  }
]]

local paletteshader_0 = pcallNewShader[[
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 texturecolor = Texel(texture, texture_coords);
    texturecolor = texturecolor * color;
    number r = texturecolor.r;
    number g = texturecolor.g;
    number b = texturecolor.b;
    return vec4(r, g, b, texturecolor.a);
  }
]]

local xwxShader = pcallNewShader[[
	extern number time;

	vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
		vec2 newCoord = texture_coords;
		float amt = 0.4;
		newCoord.x = newCoord.x - (amt/2) + (fract(sin(dot(vec2(texture_coords.y, time), vec2(12.9898,78.233))) * 43758.5453) * amt/2);
		vec4 pixel = Texel(texture, newCoord ); //This is the current pixel color
		return pixel * color;
    }
  ]]

--local paletteshader_autumn = love.graphics.newShader("paletteshader_autumn.txt")
--local paletteshader_dunno = love.graphics.newShader("paletteshader_dunno.txt")
local shader_zawarudo = pcallNewShader("shader_pucker.txt")

local level_shader = paletteshader_0
local doin_the_world = false
local shader_time = 0

local particle_timers = {}

local canv = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
local last_width,last_height = love.graphics.getWidth(),love.graphics.getHeight()

local displaywords = false

local stack_box, stack_font
local pathlock_box, pathlock_font
local initialwindoposition
stopwatch = nil

local drag_units

local sessionseed

local buttons = {}--{"resume", "editor", "exit", "restart"}
local darken = nil
local button_last_y = 0
pause = false
selected_pause_button = 1

doing_rhythm_turn = false

function scene.load()
  sessionseed = math.random(0,100000000)/100000000

  repeat_timers = {}
  key_down = {}
  selector_open = false

  stack_box = {x = 0, y = 0, scale = 0, units = {}, enabled = false}
  pathlock_box = {x = 0, y = 0, scale = 0, enabled = false}
  stack_font = love.graphics.newFont(12)
  stack_font:setFilter("nearest","nearest")
  pathlock_font = love.graphics.newFont(16)
  drag_units = {}

  scene.resetStuff()

  local now = os.time(os.date("*t"))
  presence = {
    state = "ingame",
    details = "playing the gam",
    largeImageKey = "cover",
    largeimageText = "bab be u",
    smallImageKey = "icon",
    smallImageText = "bab",
    startTimestamp = now
  }
  nextPresenceUpdate = 0

  if level_name then
    presence["details"] = "playing level: "..level_name
  end

  mouse_grabbed = false
  love.mouse.setGrabbed(false)

  -- mobile buttons
  local screenwidth = love.graphics.getWidth()
  local screenheight = love.graphics.getHeight()
  local twelfth = screenwidth/12

  mobile_controls_activekeys = "wasd"

  gooi.newButton({text = "",x = 10*twelfth,y = screenheight-3*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c) doOneMove(0,-1,mobile_controls_activekeys) end):setBGImage(sprites["ui/arrow up"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "",x = 11*twelfth,y = screenheight-2*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c) doOneMove(1,0,mobile_controls_activekeys) end):setBGImage(sprites["ui/arrow right"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "",x = 10*twelfth,y = screenheight-1*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c) doOneMove(0,1,mobile_controls_activekeys) end):setBGImage(sprites["ui/arrow down"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "",x =  9*twelfth,y = screenheight-2*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c) doOneMove(-1,0,mobile_controls_activekeys) end):setBGImage(sprites["ui/arrow left"]):bg({0, 0, 0, 0})

  gooi.newButton({text = "",x = 11*twelfth,y = screenheight-3*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c) doOneMove(1,-1,mobile_controls_activekeys) end):setBGImage(sprites["ui/arrow ur"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "",x = 11*twelfth,y = screenheight-1*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c) doOneMove(1,1,mobile_controls_activekeys) end):setBGImage(sprites["ui/arrow dr"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "",x = 9*twelfth,y = screenheight-1*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c) doOneMove(-1,1,mobile_controls_activekeys) end):setBGImage(sprites["ui/arrow dl"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "",x = 9*twelfth,y = screenheight-3*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c) doOneMove(-1,-1,mobile_controls_activekeys) end):setBGImage(sprites["ui/arrow ul"]):bg({0, 0, 0, 0})

  gooi.newButton({text = "",x = 10*twelfth,y = screenheight-2*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c) doOneMove(0,0,mobile_controls_activekeys) end):setBGImage(sprites["ui/square"]):bg({0, 0, 0, 0})

  gooi.newButton({text = "",x = 9.25*twelfth,y = 0.25*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c) doOneMove(0, 0, "undo") end):setBGImage(sprites["ui/undo"]):bg({0, 0, 0, 0})
  gooi.newButton({text = "",x = 10.75*twelfth,y = 0.25*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c) scene.resetStuff() end):setBGImage(sprites["ui/reset"]):bg({0, 0, 0, 0})

  mobile_controls_timeless = gooi.newButton({text = "",x = 10*twelfth,y = 1.5*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c) doOneMove(0, 0, "e") end):setBGImage(sprites["ui/timestop"]):bg({0, 0, 0, 0})

  mobile_controls_p1 = gooi.newButton({text = "",x = 9*twelfth,y = screenheight-4.15*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c)
    mobile_controls_activekeys = "wasd"
    mobile_controls_p1:setBounds(9*twelfth, screenheight-4.15*twelfth)
    mobile_controls_p2:setBounds(10*twelfth, screenheight-4.25*twelfth)
    mobile_controls_p3:setBounds(11*twelfth, screenheight-4.25*twelfth)
  end):setBGImage(sprites["ui_1"]):bg({0, 0, 0, 0})
  mobile_controls_p2 = gooi.newButton({text = "",x = 10*twelfth,y = screenheight-4.25*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c)
    mobile_controls_activekeys = "udlr"
    mobile_controls_p1:setBounds(9*twelfth, screenheight-4.25*twelfth)
    mobile_controls_p2:setBounds(10*twelfth, screenheight-4.15*twelfth)
    mobile_controls_p3:setBounds(11*twelfth, screenheight-4.25*twelfth)
  end):setBGImage(sprites["ui_2"]):bg({0, 0, 0, 0})
  mobile_controls_p3 = gooi.newButton({text = "",x = 11*twelfth,y = screenheight-4.25*twelfth,w = twelfth,h = twelfth,group = "mobile-controls"}):onPress(function(c)
    mobile_controls_activekeys = "numpad"
    mobile_controls_p1:setBounds(9*twelfth, screenheight-4.25*twelfth)
    mobile_controls_p2:setBounds(10*twelfth, screenheight-4.25*twelfth)
    mobile_controls_p3:setBounds(11*twelfth, screenheight-4.15*twelfth)
  end):setBGImage(sprites["ui_3"]):bg({0, 0, 0, 0})

  stopwatch = {visible = false, big = {rotation=0}, small = {rotation=0}}

  gooi.setGroupVisible("mobile-controls", is_mobile)

  pause = false
  scene.selecting = false

  scene.buildUI()
end

function scene.buildUI()
  -- darken is a UI element so that it can take focus from all UI underneath it
  darken = ui.component.new():setColor(0, 0, 0, 0.5):setSize(love.graphics.getWidth(), love.graphics.getHeight()):setFill(true)

  buttons = {}

  if not options then
    scene.addButton("resume", function() pause = false end)
    scene.addButton("restart", function() pause = false; scene.resetStuff() end)
    scene.addButton("editor", function() new_scene = editor; load_mode = "edit" end)
    scene.addButton("options", function() options = true; scene.buildUI() end)
    scene.addButton("exit to " .. escResult(false), function() escResult(true) end)
  else
    buildOptions()
  end

  local ox, oy = love.graphics.getWidth()/2, buttons[1]:getHeight()*3
  for _,button in ipairs(buttons) do
    local width, height = button:getSize()
    button:setPos(ox - width/2, oy)
    oy = oy + height + 10
  end
  button_last_y = oy
end

function scene.addButton(text, func)
  local button = ui.menu_button.new(text, #buttons%2+1, func)
  table.insert(buttons, button)
  return button
end

function scene.addOption(id, name, options, changed)
  local option = 1
  for i,v in ipairs(options) do
    if settings[id] == v[2] then
      option = i
    end
  end
  scene.addButton(name .. ": " .. options[option][1], function()
    settings[id] = options[(((option-1)+1)%#options)+1][2]
    saveAll()
    if changed then
      changed(settings[id])
    end
    scene.buildUI()
  end)
end

function scene.update(dt)
  mouse_X = love.mouse.getX()
  mouse_Y = love.mouse.getY()

  --mouse_movedX = love.mouse.getX() - love.graphics.getWidth()*0.5
  --mouse_movedY = love.mouse.getY() - love.graphics.getHeight()*0.5

  sound_volume = {}

  scene.checkInput()
  updateCursors()
  
  doDragbl()

  mouse_oldX = mouse_X
  mouse_oldY = mouse_Y

  if pause then dt = 0 end

  if xwxShader then
    xwxShader:send("time", dt) -- send delta time to the shader
  end

  --TODO: PERFORMANCE: If many things are producing particles, it's laggy as heck.
  scene.doPassiveParticles(dt, ":)", "bonus", 0.25, 1, 1, {2, 4})
  scene.doPassiveParticles(dt, ";d", "unwin", 0.25, 1, 1, {1, 2})
  scene.doPassiveParticles(dt, ":o", "bonus", 0.5, 0.8, 1, {4, 1})
  scene.doPassiveParticles(dt, "qt", "love", 0.25, 0.5, 1, {4, 2})
  scene.doPassiveParticles(dt, "slep", "slep", 1, 0.33, 1, {0, 3})
  scene.doPassiveParticles(dt, "try again", "bonus", 0.25, 0.25, 1, {3, 3})
  scene.doPassiveParticles(dt, "no undo", "bonus", 0.25, 0.25, 1, {5, 3})
  scene.doPassiveParticles(dt, "undo", "bonus", 0.25, 0.25, 1, {6, 1})
  scene.doPassiveParticles(dt, "brite", "bonus", 0.25, 0.25, 1, {2, 4})
	
  doReplay(dt)
  if rules_with and rules_with["rythm"] then
    doRhythm()
  end
end

function doRhythm()
  if replay_playback then return false end
	if love.timer.getTime() > (rhythm_time + rhythm_interval) then
    if not pause and not past_playback then
      rhythm_time = rhythm_time + rhythm_interval
      doMovement(0, 0, "rythm")
    end
	end
end

function doReplay(dt)
  if not replay_playback then return false end
	if love.timer.getTime() > (replay_playback_time + replay_playback_interval) then
    if not pause and not replay_pause and not past_playback then
      replay_playback_time = replay_playback_time + replay_playback_interval
      doReplayTurn(replay_playback_turn)
      replay_playback_turn = replay_playback_turn + 1
    else
      replay_playback_time = love.timer.getTime()
    end
	end
  return true
end

function doReplayTurn(turn)
    if (replay_playback_turns == nil) then
    replay_playback_string_parts = replay_playback_string:split("|")
    replay_playback_turns = replay_playback_string_parts[1]:split(";")
    if (replay_playback_string_parts[2] ~= nil) then
      local ok, loaded_rng_cache = serpent.load(love.data.decode("string", "base64", replay_playback_string_parts[2]))
      if (not ok) then
        print("Serpent error while loading:", ok, fullDump(loaded_rng_cache))
      end
      rng_cache = loaded_rng_cache
    end
  end
	local turn_string = replay_playback_turns[turn]
	if (turn_string == nil or turn_string == "") then
		replay_playback = false
		print("Finished playback at turn: "..tostring(turn))
    return
	end
	local turn_parts = turn_string:split(",")
	x, y, key = tonumber(turn_parts[1]), tonumber(turn_parts[2]), turn_parts[3]
	if (x == nil or y == nil) then
		replay_playback = false
		print("Finished playback at turn: "..tostring(turn))
    return
	else
    if (turn_parts[4] ~= nil) then
      local ok, cursor_table = serpent.load(love.data.decode("string", "base64", turn_parts[4]))
      if (not ok) then
        print("Serpent error while loading:", ok, fullDump(cursor_table))
      else
        for i,coords in ipairs(cursor_table) do
          local cursor = cursors[i]
          if (cursor == nil) then
            --print("Couldn't find cursor while doing replay, halp")
          else
            cursor.x = coords[1]
            cursor.y = coords[2]
            --[[if (not unit_tests) then
              local screenx, screeny = gameTileToScreen(cursor.x, cursor.y)
              cursor.screenx = screenx
              cursor.screeny = screeny
            end]]
          end
        end
      end
    end
    doOneMove(x, y, key)
  end
end

function string:split(sSeparator, nMax, bRegexp)
   assert(sSeparator ~= '')
   assert(nMax == nil or nMax >= 1)

   local aRecord = {}

   if self:len() > 0 then
      local bPlain = not bRegexp
      nMax = nMax or -1

      local nField, nStart = 1, 1
      local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
      while nFirst and nMax ~= 0 do
         aRecord[nField] = self:sub(nStart, nFirst-1)
         nField = nField+1
         nStart = nLast+1
         nFirst,nLast = self:find(sSeparator, nStart, bPlain)
         nMax = nMax-1
      end
      aRecord[nField] = self:sub(nStart)
   end

   return aRecord
end

function scene.resetStuff(forTime)
  if not forTime then
    pastClear()
  end
  timeless = false
  clear()
  if not is_mobile then
    love.mouse.setCursor(empty_cursor)
  end
  --love.mouse.setGrabbed(true)
  --resetMusic("bab be u them", 0.5)
  resetMusic(map_music, 0.9)
  loadMap()
  clearRules()
  parseRules()
  updateGroup()
  calculateLight()
  updateUnits(true)
  updatePortals()
  miscUpdates()
  next_levels, next_level_objs = getNextLevels()
  first_turn = false
  window_dir = 0
  
  if playing_world then
    saveWorld()
    selectLastLevels()
  end
end
    
function scene.keyPressed(key, isrepeat)
  if isrepeat then
    return
  end

  last_input_time = love.timer.getTime()

  if key == "escape" then
    
    --[[local current_level = level_name
    if readSaveFile(level_name, "won") then
      current_level = current_level.." (won) "
    end
    if readSaveFile(level_name, "clear") then
      current_level = current_level.." (cleared) "
    end
    if readSaveFile(level_name, "complete") then
      current_level = current_level.." (complete) "
    end
    if readSaveFile(level_name, "bonus") then
      current_level = current_level.." (bonused) "
    end
    local tfs = readSaveFile(level_name, "transform")
    if tfs then
      current_level = current_level.." (transformed into " .. fullDump(tfs) .. ") "
    end
    
    ui.overlay.confirm({
        text = current_level .. "\r\n\r\n" .. (spookmode and "G̴͔̭͇͎͕͔ͪ̾ͬͦ̇͑͋͟͡o̵̸͓̠̦̱̭̘͍̱͑̃̀ͅ ̱̫͉̆͐̇ͥ̽͆͂͑̿͜b̸̵͈̼̜̅͗̄̆ͅa͚̠͚̣̺̗͖͈̓̿̈́͆͐̉ͯ̀̚c͉̜̙̤͍̞̳̬ͪ̇k̙͙̼̀̓̂̑̈́̌ͯ̕͢ͅ ̶̛̠̹̈̒ͫ͐t̙͉͍͚̠̗̰͗͊͛ͫ͒ͥ̏ͫ͢͜ȍ̙͙̪̬̎̊ͫͭͫ͗̔̚ ̴̪͖͔̖̙̬͍̥ͪ̾̾͂͂l̪͉͙̪̩͙̎̏͌̽ͤ̈́̀͜͠e̡͓͍͉̖̤ͬ̓̏ͥͫ̀ͅv̱͈͍̞̼̀͋̂̃͋́̚͠ͅḛ̷̷̱̿͂l̢̮͇̫̗͍̱͈̟͌̐̎̑̈́ ̵̠͖̣̟̲̖̇̈̓ͭͫ͠s͚̝̻ͤ̓̀̀e̅͑̐̄͏̤̫̕͠lͨ͋͌ͤͩ̋̓͏̘̼̠̪̖͓͔̹e̵͖̤̒͒ͥ̓ͬ̓͘c͖͈̏̄̐̅̎ͨ͢ṫ͔̥͓̊̌̓̇ọ̞̤͔̩̒͗ͨ́̓͟ŗ̖͉̹̻̮̬̦͌̿͂?̶̡͈̫̗̈́̒̎̃̎̓" or "Go back to "..escResult(false).."?"),
        okText = "Yes",
        cancelText = spookmode and "Yes" or "Cancel",
        ok = function()
          escResult(true)
        end
      })
      return]]

    pause = not pause
    selected_pause_button = 1
  end
  
  
    if key == "g" and (key_down["lctrl"] or key_down["rctrl"]) then
        settings["grid_lines"] = not settings["grid_lines"]
        saveAll()
    end
  
  
  if pause then
    scene.selecting = true
    --[[if key == "w" or key == "up" or key == "i" or key == "kp8" then
      selected_pause_button = selected_pause_button - 1
      if selected_pause_button < 1 then
        selected_pause_button = #buttons
      end
    elseif key == "s" or key == "down" or key == "k" or key == "kp2" then
      selected_pause_button = selected_pause_button + 1
      if selected_pause_button > #buttons then
        selected_pause_button = 1
      end
    elseif key == "return" or key == "space" or key == "kpenter" then
      handlePauseButtonPressed(selected_pause_button)
    end]]
  else
    scene.selecting = false
    local do_turn_now = false

    if (key == "w" or key == "a" or key == "s" or key == "d") then
      if not repeat_timers["wasd"] or repeat_timers["wasd"] > 30 then
        repeat_timers["wasd"] = 30
      elseif repeat_timers["wasd"] <= 30 then
        do_turn_now = true
        repeat_timers["wasd"] = 0
      end
    elseif (key == "up" or key == "down" or key == "left" or key == "right") then
      if not repeat_timers["udlr"] or repeat_timers["udlr"] > 30 then
        repeat_timers["udlr"] = 30
      elseif repeat_timers["udlr"] <= 30 then
        do_turn_now = true
        repeat_timers["udlr"] = 0
      end
    elseif (key == "i" or key == "j" or key == "k" or key == "l") then
      if not repeat_timers["ijkl"] or repeat_timers["ijkl"] > 30 then
        repeat_timers["ijkl"] = 30
      elseif repeat_timers["ijkl"] <= 30 then
        do_turn_now = true
        repeat_timers["ijkl"] = 0
      end
    elseif (key == "kp1" or
    key == "kp2" or
    key == "kp3" or
    key == "kp4" or
    key == "kp5" or
    key == "kp6" or
    key == "kp7" or
    key == "kp8" or
    key == "kp9") then
      if not repeat_timers["udlr"] then
        do_turn_now = true
        repeat_timers["numpad"] = 0
      end
    elseif (key == "z" or key == "q" or key == "backspace" or key == "kp0" or key == "o") then
      if not repeat_timers["undo"] then
          do_turn_now = true
          repeat_timers["undo"] = 0
      end
    end
    
   if rules_with and rules_with["rythm"] then
        if key == "+" or key == "=" then
            rhythm_interval = rhythm_interval * 0.8
        elseif key == "-" or key == "_" then
            rhythm_interval = rhythm_interval / 0.8
        end
    end
    
    --print(rhythm_interval)

    for _,v in ipairs(repeat_keys) do
      if v == key then
        do_turn_now = true
        repeat_timers[v] = 0
      end
    end

    if key == "r" then
      if not currently_winning or not key_down["lctrl"] then
        scene.resetStuff()
      elseif not RELEASE_BUILD and world_parent == "officialworlds" then
        local file = love.filesystem.getSource() .. "/" .. getWorldDir() .. "/" .. level_filename .. ".replay"
        local f = io.open(file, "w"); f:write(official_replay_string); f:close()
        print("Replay successfully saved to " .. getWorldDir() .. "/" .. level_filename .. ".replay")
      end
    end
    
    -- Replay keys
      if key == "f12" then
          if not replay_playback then
              tryStartReplay()
          else
              replay_playback = false
          end
      end
      
      if replay_playback and not pause then
          if key == "+" or key == "=" or key == "w" or key == "up" then
              replay_playback_interval = replay_playback_interval * 0.8
          elseif key == "-" or key == "_" or key == "s" or key == "down" then
              replay_playback_interval = replay_playback_interval / 0.8
          elseif key == "0" or key == ")" then
              replay_playback_interval = 0.3
          elseif key == "space" then
              replay_pause = not replay_pause
          elseif key == "z" or key == "q" or key == "backspace" or key == "kp0" or key == "o" or key == "a" or key == "left" then
              replay_pause = true
              if replay_playback_turn > 1 then
                  replay_playback_turn = replay_playback_turn - 1
                  doOneMove(0,0,"undo")
              end
              print(replay_playback_turn)
          elseif key == "d" or key == "right" then
              doReplayTurn(replay_playback_turn)
              replay_playback_turn = replay_playback_turn + 1
          elseif key == "e" then
              replay_playback_interval = 0
          end
      end
      
    if key == "e" and not currently_winning and not replay_playback then
      doOneMove(0, 0, "e")
    end
    
    if key == "f" and not currently_winning and not replay_playback then
      doOneMove(0, 0, "f")
    end

    if key == "tab" then
      displaywords = true
    end
    
    if key == "y" and hasU("swan") and units_by_name["swan"] then
        playSound("honk"..love.math.random(1,6))
    end

    most_recent_key = key
    key_down[key] = true

    if (do_turn_now) then
      scene.checkInput()
    end
  end
end

function tryStartReplay()
  scene.resetStuff()
  local dir = getWorldDir() .. "/"
  local full_dir = getWorldDir(true) .. "/"
  if love.filesystem.getInfo(dir .. level_filename .. ".replay") then
    replay_playback_string = love.filesystem.read(dir .. level_filename .. ".replay")
    replay_playback = true
    print("Started replay from: "..dir .. level_filename .. ".replay")
  elseif love.filesystem.getInfo(full_dir .. level_name .. ".replay") then
    replay_playback_string = love.filesystem.read(full_dir .. level_name .. ".replay")
    replay_playback = true
    print("Started replay from: "..full_dir .. level_name .. ".replay")
  elseif love.filesystem.getInfo("levels/" .. level_filename .. ".replay") then
    replay_playback_string = love.filesystem.read("levels/" .. level_filename .. ".replay")
    replay_playback = true
    print("Started replay from: ".."levels/" .. level_filename .. ".replay")
  elseif love.filesystem.getInfo("levels/" .. level_name .. ".replay") then
    replay_playback_string = love.filesystem.read("levels/" .. level_name .. ".replay")
    replay_playback = true
    print("Started replay from: ".."levels/" .. level_name .. ".replay")
  else
    print("Failed to find replay: ".. dir .. level_filename .. ".replay")
  end
end

--TODO: Releasing a key could signal to instantly run input under certain circumstances.
--UPDATE: I tested it and it didn't help (the keyReleased function never got called before the 30ms elapsed). I have no idea why.
function scene.keyReleased(key)
  for _,v in ipairs(repeat_keys) do
    if v == key then
      repeat_timers[v] = nil
    end
  end

  if key == "tab" then
    displaywords = false
  end

  if key == "z" or key == "q" or key == "backspace" or key == "kp0" or key == "o" then
    UNDO_DELAY = MAX_UNDO_DELAY
  end

  --[[local do_turn_now = false

  print(key)
  if key == "w" or key == "s" and not key_down["a"] and not key_down["d"] then
    print(repeat_timers["wasd"])
    if repeat_timers["wasd"] <= 30 then
      do_turn_now = true
      repeat_timers["wasd"] = 0
    end
  elseif key == "a" or key == "d" and not key_down["w"] and not key_down["s"] then
    if repeat_timers["wasd"] <= 30 then
      do_turn_now = true
      repeat_timers["wasd"] = 0
    end
  elseif key == "up" or key == "down" and not key_down["left"] and not key_down["right"] then
    if repeat_timers["udlr"] <= 30 then
      do_turn_now = true
      repeat_timers["udlr"] = 0
    end
  elseif key == "left" or key == "right" and not key_down["up"] and not key_down["down"] then
    if repeat_timers["udlr"] <= 30 then
      do_turn_now = true
      repeat_timers["udlr"] = 0
    end
  end

  if (do_turn_now) then
    print("asdf")
    scene.checkInput()
  end]]--

  key_down[key] = false
end

function scene.getTransform()
  local transform = love.math.newTransform()

  local roomwidth = mapwidth * TILE_SIZE
  local roomheight = mapheight * TILE_SIZE

  local screenwidth = love.graphics.getWidth() * (is_mobile and 0.75 or 1)
  local screenheight = love.graphics.getHeight()

  local scales = {0.25, 0.375, 0.5, 0.75, 1, 2, 3, 4}

  local scale = scales[1]
  for _,s in ipairs(scales) do
    if screenwidth >= roomwidth * s and screenheight >= roomheight * s then
      scale = s
    else break end
  end
  if settings["game_scale"] ~= "auto" and settings["game_scale"] < scale then
    scale = settings["game_scale"]
  end

  local scaledwidth = screenwidth * (1/scale)
  local scaledheight = screenheight * (1/scale)

  transform:scale(scale, scale)
  transform:translate(scaledwidth / 2 - roomwidth / 2, scaledheight / 2 - roomheight / 2)

  if shake_dur > 0 and not hasProperty(outerlvl, "cool") then
    local range = 1
    transform:translate(math.random(-range, range), math.random(-range, range))
  end

  return transform
end

--TODO: PERFORMANCE: Calling hasProperty once per frame means that we have to index rules, check conditions, etc. with O(m*n) performance penalty. But, the results of these calls do not change until a new turn or undo. So, we can cache the values of these calls in a global table and dump the table whenever the turn changes for a nice and easy performance boost.
--(Though this might not be true for mice, which can change their position mid-frame?? Also for other meta stuff (like windo)? Until there's mouse conditional rules or meta stuff in a puzzle IDK how this should actually work or be displayed. Just keep that in mind tho.)
function scene.draw(dt)
  if pause then dt = 0 end

  local draw_empty = rules_with["no1"] ~= nil
  local start_time = love.timer.getTime()
  -- reset canvas if the screen size has changed
  if love.graphics.getWidth() ~= last_width or love.graphics.getHeight() ~= last_height then
    last_width = love.graphics.getWidth()
    last_height = love.graphics.getHeight()
    canv = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
  end

  love.graphics.setCanvas{canv, stencil=true}
  love.graphics.setShader()

  --background color
  local bg_color = {getPaletteColor(1, 0)}
  
  if timeless then bg_color = {getPaletteColor(0, 0)}
  elseif rainbowmode then bg_color = {hslToRgb(love.timer.getTime()/6%1, .2, .2, .9), 1} end

  love.graphics.setColor(bg_color[1], bg_color[2], bg_color[3], bg_color[4])

  -- fill the background with the background color
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

  local roomwidth = mapwidth * TILE_SIZE
  local roomheight = mapheight * TILE_SIZE

  love.graphics.push()
  love.graphics.applyTransform(scene.getTransform())

  love.graphics.setColor(getPaletteColor(0,3))
  love.graphics.printf(next_level_name, 0, -14, roomwidth)

  local lvl_color = {getPaletteColor(0, 4)}
  
  --[[if hasProperty(outerlvl,"tranz") then
    love.graphics.draw(sprites["overlay/trans"], 0, 0, 0, roomwidth / sprites["overlay/trans"]:getWidth(), roomheight / sprites["overlay/trans"]:getHeight()) 
  end
  if hasProperty(outerlvl,"gay") then
    table.insert(outerlvl.overlay, "gay")
  end]]
  
  -- Lvl be colors
  if hasProperty(outerlvl,"rave") then
    lvl_color = {hslToRgb((love.timer.getTime()/3+#undo_buffer/45)%1, 0.1, 0.1, .9), 1}
  elseif hasProperty(outerlvl,"colrful") or rainbowmode then
    lvl_color = {hslToRgb(love.timer.getTime()/6%1, .1, .1, .9), 1}
  elseif (hasProperty(outerlvl,"reed") and hasProperty(outerlvl,"whit")) or hasProperty(outerlvl,"pinc") then
    lvl_color = {getPaletteColor(4, 1)}
  elseif (hasProperty(outerlvl,"grun") and hasProperty(outerlvl,"whit")) then
    lvl_color = {getPaletteColor(5, 3)}
  elseif hasProperty(outerlvl,"whit") then
    lvl_color = {getPaletteColor(0, 3)}
  elseif (hasProperty(outerlvl,"bleu") and hasProperty(outerlvl,"reed")) or hasProperty(outerlvl,"purp") then
    lvl_color = {getPaletteColor(3, 1)}
  elseif (hasProperty(outerlvl,"reed") and hasProperty(outerlvl,"grun")) or hasProperty(outerlvl,"yello") then
    lvl_color = {getPaletteColor(2, 4)}
  elseif (hasProperty(outerlvl,"reed") and hasProperty(outerlvl,"yello")) or hasProperty(outerlvl,"orang") then
    lvl_color = {getPaletteColor(2, 3)}
  elseif (hasProperty(outerlvl,"bleu") and hasProperty(outerlvl,"grun")) or hasProperty(outerlvl,"cyeann") then
    lvl_color = {getPaletteColor(1, 4)}
  elseif hasProperty(outerlvl,"reed") then
    lvl_color = {getPaletteColor(2, 2)}
  elseif hasProperty(outerlvl,"bleu") then
    lvl_color = {getPaletteColor(1, 3)}
  elseif hasProperty(outerlvl,"grun") then
    lvl_color = {getPaletteColor(5, 2)}
  elseif hasProperty(outerlvl,"cyeann") then
    lvl_color = {getPaletteColor(1, 4)}
  elseif hasProperty(outerlvl,"blacc") then
    lvl_color = {getPaletteColor(0, 4)}
  end

  love.graphics.setColor(lvl_color[1], lvl_color[2], lvl_color[3], lvl_color[4])
  
  if not (level_destroyed or hasProperty(outerlvl, "stelth")) then
    local flyenes = countProperty(outerlvl,"flye")
    local mapy = 0 - math.sin(love.timer.getTime())*5*flyenes
    love.graphics.rectangle("fill", 0, mapy, roomwidth, roomheight)
    if level_background_sprite ~= nil and level_background_sprite ~= "" and sprites[level_background_sprite] then
      love.graphics.setColor(1, 1, 1)
      local sprite = sprites[level_background_sprite]
      love.graphics.draw(sprite, 0, 0, 0, 1, 1, 0, 0)
    end
  end
  
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

  local function drawUnit(unit, drawx, drawy, rotation, loop)
    if unit.name == "no1" and not (draw_empty and validEmpty(unit)) then return end
    
    local brightness = 1
    if ((unit.type == "text" and not hasRule(unit,"ben't","wurd")) or hasRule(unit,"be","wurd")) and not unit.active and not level_destroyed then
      brightness = 0.33
    end

    if (unit.name == "steev") and not hasU(unit) then
      brightness = 0.33
    end
    
    if unit.name == "casete" and not hasProperty(unit, "no go") then
      brightness = 0.5
    end
    
    if timeless and not hasProperty(unit,"za warudo") and not (unit.type == "text") then
      brightness = 0.33
    end

    if unit.fullname == "text_gay" then
      if unit.active then
        unit.sprite = "text_gay-colored"
      else
        unit.sprite = "text_gay"
      end
    end
    if unit.fullname == "text_tranz" then
      if unit.active then
        unit.sprite = "text_tranz-colored"
      else
        unit.sprite = "text_tranz"
      end
    end
    if unit.fullname == "text_enby" then
      if unit.active then
        unit.sprite = "text_enby-colored"
      else
        unit.sprite = "text_enby"
      end
    end
    if unit.fullname == "text_now" then
      if doing_past_turns then
        unit.sprite = "text_latr"
      else
        unit.sprite = "text_now"
      end
    end

    
    if unit.rave then
      -- print("unit " .. unit.name .. " is rave")
      local ravespeed = 0.75
      if settings["epileptic"] then
        ravespeed = 7.5
      end
      
      local newcolor = hslToRgb((love.timer.getTime()/ravespeed+#undo_buffer/45+unit.x/18+unit.y/18)%1, .5, .5, 1)
      newcolor[1] = newcolor[1]*255
      newcolor[2] = newcolor[2]*255
      newcolor[3] = newcolor[3]*255
      if type(unit.color[1]) == "table" then
        unit.color_override = {}
        for i,color in ipairs(unit.color) do
          if not unit.colored or (unit.colored and unit.colored[i]) then
            unit.color_override[i] = newcolor
          else
            unit.color_override[i] = color
          end
        end
      else
        unit.color_override = newcolor
      end
    elseif unit.colrful or rainbowmode then
      -- print("unit " .. unit.name .. " is colourful or rainbowmode")
      local newcolor = hslToRgb((love.timer.getTime()/15+#undo_buffer/45+unit.x/18+unit.y/18)%1, .5, .5, 1)
      newcolor[1] = newcolor[1]*255
      newcolor[2] = newcolor[2]*255
      newcolor[3] = newcolor[3]*255
      if type(unit.color[1]) == "table" then
        unit.color_override = {}
        for i,color in ipairs(unit.color) do
          if not unit.colored or (unit.colored and unit.colored[i]) then
            unit.color_override[i] = newcolor
          else
            unit.color_override[i] = color
          end
        end
      else
        unit.color_override = newcolor
      end
    end
    
    local sprite_name = unit.sprite
    local sprite
    
    if type(sprite_name) ~= "table" then
      if sprite_name == "lvl" and readSaveFile{"levels", unit.special.level, "won"} then
        sprite_name = "lvl_won"
      end
      local frame = (unit.frame + anim_stage) % 3 + 1
      if type(sprite_name) == "string" and sprites[sprite_name .. "_" .. frame] then
        sprite_name = sprite_name .. "_" .. frame
      end
      if not sprites[sprite_name] then sprite_name = "wat" end

      sprite = sprites[sprite_name]
    else
      sprite = sprites[sprite_name[1]]
    end

    --no tweening empty for now - it's buggy!
    --TODO: it's still a little buggy if you push/pull empties.
    if (unit.name == "no1") then
      --drawx = unit.x
      --drawy = unit.y
      --rotation = math.rad((unit.dir - 1) * 45)
      unit.draw.scalex = 1
      unit.draw.scaley = 1
    end

		local function setColor(color)
      color = type(color[1]) == "table" and color[1] or color
      if #color == 3 then
        if color[1] then
          color = {color[1]/255, color[2]/255, color[3]/255, 1}
        else
          color = {1,1,1,1}
        end
			else
				color = {getPaletteColor(color[1], color[2])}
			end

			-- multiply brightness by darkened bg color
			for i,c in ipairs(bg_color) do
				if i < 4 then
					color[i] = (1 - brightness) * (bg_color[i] * 0.5) + brightness * color[i]
				end
			end

			if #unit.overlay > 0 and type(unit.sprite) == "string" and eq(unit.color, tiles_list[unit.tile].color) then
				love.graphics.setColor(1, 1, 1, unit.draw.opacity)
			else
				love.graphics.setColor(color[1], color[2], color[3], unit.draw.opacity)
			end
			return color
		end
		
		local color = setColor(unit.color_override or unit.color)
    if unit.fullname == "tronk" then
      if math.floor(love.timer.getTime()*10)%2 == 1 then
        local r,g,b = getPaletteColor((unit.color_override or unit.color)[1],(unit.color_override or unit.color)[2])
        setColor{r*350,g*350,b*350}
      end
    end
    --check level_destroyed so that the object created by infloop is always white needs to be changed if we want objects to be able to survive level destruction
    if level_destroyed then
      setColor({0,3})
    end

    local fulldrawx = (drawx + 0.5)*TILE_SIZE
    local fulldrawy = (drawy + 0.5)*TILE_SIZE
    if hasProperty(unit,"big") then
      fulldrawx = fulldrawx + TILE_SIZE/2
      fulldrawy = fulldrawy + TILE_SIZE/2
    end

    if graphical_property_cache["flye"][unit] ~= nil or (unit.parent and graphical_property_cache["flye"][unit.parent] ~= nil) or unit.name == "o" or unit.name == "square" or unit.name == "triangle" then
      local flyenes = graphical_property_cache["flye"][unit] or (unit.parent and graphical_property_cache["flye"][unit.parent]) or 0
      if unit.name == "o" or unit.name == "square" or unit.name == "triangle" then
        flyenes = flyenes + 1
      end
      fulldrawy = fulldrawy - math.sin(love.timer.getTime())*5*flyenes
    end
    
    if unit.fullname == "text_temmi" and unit.active then
      local range = 0.5
      fulldrawx = fulldrawx + math.random(-range, range)
      fulldrawy = fulldrawy + math.random(-range, range)
    end

    local function getOffset()
      if hasProperty(unit,"cool") or not settings["shake_on"] then return 0,0 end
      if rules_with["temmi"] then
        local do_vibrate = false
        if unit.fullname == "temmi" then
          do_vibrate = true
        elseif unit.type == "text" and unit.active then
          local rules_list = rules_with_unit[unit]
          if rules_list then
            for _,rules in ipairs(rules_list) do
              for _,rule_unit in ipairs(rules.units) do
                if rule_unit.fullname == "text_temmi" then
                  do_vibrate = true
                  break
                end
              end
              if do_vibrate then break end
            end
          end
        end
        if do_vibrate then
          if unit.fullname == "temmi" then
            local props = countProperty(unit,"?")
            if math.random() > 1/(props+1) then
              return math.random(-props, props), math.random(-props, props)
            end
          else
            if math.random() > 0.5 then
              return math.random(-1, 1), math.random(-1, 1)
            end
          end
        end
      elseif shake_dur > 0 then
        local range = 0.5
        return math.random(-range, range), math.random(-range, range)
      end
      return 0,0
    end

    love.graphics.push()
    love.graphics.translate(fulldrawx, fulldrawy)
    if hasProperty(unit,"big") then
      love.graphics.scale(2)
    end

    love.graphics.push()
    love.graphics.rotate(math.rad(rotation))
    love.graphics.translate(-fulldrawx, -fulldrawy)
    
    local function drawSprite(overlay, onlycolor, stretch)
      local draw = sprites[overlay or unit.sprite]
      local ox, oy = getOffset()
      if not overlay and type(unit.sprite) == "table" then
        for i,image in ipairs(unit.sprite) do
          setColor(getUnitColors(unit, i))
          if onlycolor or (#unit.overlay > 0 and (unit.colored and unit.colored[i]) or not unit.colored) then
            love.graphics.setColor(1,1,1,1)
          end
          if not onlycolor or not unit.colored or (onlycolor and unit.colored and unit.colored[i]) then
            local sprit = sprites[image]
            love.graphics.draw(sprit, fulldrawx + ox, fulldrawy + oy, 0, unit.draw.scalex, unit.draw.scaley, sprit:getWidth() / 2, sprit:getHeight() / 2)
          end
        end
      else
        if overlay and stretch then
          love.graphics.draw(draw, fulldrawx + ox, fulldrawy + oy, 0, sprite:getWidth() / TILE_SIZE, sprite:getHeight() / TILE_SIZE, draw:getWidth() / 2, draw:getHeight() / 2)
        else
          if unit.fullname == "detox" and graphical_property_cache["slep"][unit] ~= nil then
            setColor{1,2}
          end
          if not draw then draw = sprites["wat"] end
          love.graphics.draw(draw, fulldrawx + ox, fulldrawy + oy, 0, unit.draw.scalex, unit.draw.scaley, draw:getWidth() / 2, draw:getHeight() / 2)
        end
      end
			if (unit.meta ~= nil) then
				setColor({4, 1})
        local metasprite = unit.meta == 2 and sprites["meta2"] or sprites["meta1"]
        if spookmode and sessionseed < drawx/3%0.5*2 then
          love.graphics.setColor(0,0,0)
        end
				love.graphics.draw(metasprite, fulldrawx, fulldrawy, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
				if unit.meta > 2 and unit.draw.scalex == 1 and unit.draw.scaley == 1 then
					love.graphics.printf(tostring(unit.meta), fulldrawx-1, fulldrawy+6, 32, "center")
				end
				setColor(unit.color)
			end
      if (unit.nt ~= nil) then
        setColor({2, 2})
        local ntsprite = sprites["n't"]
        love.graphics.draw(ntsprite, fulldrawx, fulldrawy, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
        setColor(unit.color)
      end
      if displayids then
        setColor({1,4})
        love.graphics.printf(tostring(unit.id), fulldrawx-3, fulldrawy-18, 32, "center")
        setColor(unit.color)
      end
    end
    
    --performance todos: each line gets drawn twice (both ways), so there's probably a way to stop that. might not be necessary though, since there is no lag so far
    --in fact, the double lines add to the pixelated look, so for now i'm going to make it intentional and actually add it in a couple places to be consistent
    if unit.name == "lin" and (not unit.special.pathlock or unit.special.pathlock == "none") and scene ~= editor and not loop then
      love.graphics.setLineWidth(4)
      love.graphics.setLineStyle("rough")
      local orthos = {}
      local line = {}
      for ndir=1,4 do
        local nx,ny = dirs[ndir][1],dirs[ndir][2]
        local dx,dy,dir,px,py,portal = getNextTile(unit,nx,ny,2*ndir-1)
        if inBounds(px,py) then
          local around = getUnitsOnTile(px,py)
          for _,other in ipairs(around) do
            if other.name == "lin" or other.name == "lvl" then
              orthos[ndir] = true
              table.insert(line,{unit.x*2-unit.draw.x+nx+other.draw.x-other.x, unit.y*2-unit.draw.y+ny+other.draw.y-other.y, portal})
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
        local dx,dy,dir,px,py,portal = getNextTile(unit,nx,ny,ndir)
        local around = getUnitsOnTile(px,py)
        for _,other in ipairs(around) do
          if (other.name == "lin" or other.name == "lvl") and not orthos[ndir/2] and not orthos[dirAdd(ndir,2)/2] then
            table.insert(line,{unit.x*2-unit.draw.x+nx+other.draw.x-other.x, unit.y*2-unit.draw.y+ny+other.draw.y-other.y, portal})
            break
          end
        end
      end
      if (#line > 0) then
        -- love.graphics.rectangle("fill", fulldrawx-1, fulldrawy-1, 1, 3)
        -- love.graphics.rectangle("fill", fulldrawx-2, fulldrawy, 3, 1)
        for _,point in ipairs(line) do
          --no need to change the rendering to account for movement, since all halflines are drawn to static objects (portals and oob)
          local dx = unit.x-point[1]
          local dy = unit.y-point[2]
          local odx = TILE_SIZE*dx/(point[3] and 1 or 2)
          local ody = TILE_SIZE*dy/(point[3] and 1 or 2)
          
          --draws it twice to make it look the same as the other lines. should be reduced to one if we figure out that performance todo above
          --   love.graphics.setLineWidth(3)
          -- if dx == 0 or dy == 0 then
          --   love.graphics.setLineWidth(3)
          -- else
          --   love.graphics.setLineWidth(3)
          -- end
          love.graphics.line(fulldrawx+dx,fulldrawy+dy,fulldrawx-odx,fulldrawy-ody)
        end
      end
      if (#line == 0) then
        drawSprite()
      end
    end
    
    if unit.name == "lin" and unit.special.pathlock and unit.special.pathlock ~= "none" then
      setColor(unit.color_override or {2, 2})
      drawSprite("lin_gate")
    end
    
    --reset back to values being used before
    love.graphics.setLineWidth(2)

    if hasRule(unit,"got","bowie") then
      local rule = matchesRule(unit,"got","bowie")[1].rule

      -- GOT object coloring!
      local c1, c2
      if rule.object.prefix then
        local dummy = {}
        dummy[rule.object.prefix] = true
        updateUnitColourOverride(dummy)
        if dummy.color_override then
          c1, c2 = dummy.color_override[1], dummy.color_override[2]
        end
      end

      local shake_x, shake_y = getOffset()

      local ur, ug, ub, ua = love.graphics.getColor()
      local o = getTableWithDefaults(unit.features.bowie, {x=0, y=0, sprite="bowie_smol"})
      love.graphics.setColor(getPaletteColor(c1 or 2, c2 or 2))
      love.graphics.draw(sprites[o.sprite], fulldrawx + o.x + shake_x, fulldrawy + o.y + shake_y, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      love.graphics.setColor(ur, ug, ub, ua)
    end

    if not (unit.xwx or spookmode) and unit.name ~= "lin" and unit.fullname ~= "letter_custom" then -- xwx takes control of the drawing sprite, so it shouldn't render the normal object
      drawSprite()
    end

    if unit.xwx or spookmode then -- if we're xwx, apply the special shader to our object
      if math.floor(love.timer.getTime() * 9) % 9 == 0 then
        pcallSetShader(xwxShader)
        drawSprite()
        love.graphics.setShader()
      else
        drawSprite()
      end
    end
    
    if unit.name == "lvl" and unit.special.visibility == "open" then
      love.graphics.push()
      if readSaveFile{"levels", unit.special.level, "won"} then
        local r,g,b,a = love.graphics.getColor()
        love.graphics.setColor(r,g,b, a*0.4)
      end
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
      love.graphics.pop()
    end
    
    if unit.fullname == "letter_custom" then
      drawCustomLetter(unit.special.customletter, fulldrawx, fulldrawy, 0, unit.draw.scalex, unit.draw.scaley, 16, 16)
    end

    if #unit.overlay > 0 and unit.fullname ~= "no1" then
      local function overlayStencil()
        pcallSetShader(mask_shader)
        drawSprite(nil,true)
        love.graphics.setShader()
      end
      for _,overlay in ipairs(unit.overlay) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.stencil(overlayStencil, "replace")
        local old_test_mode, old_test_value = love.graphics.getStencilTest()
        love.graphics.setStencilTest("greater", 0)
        love.graphics.setBlendMode("multiply", "premultiplied")
        drawSprite("overlay/" .. overlay, false, true)
        love.graphics.setBlendMode("alpha", "alphamultiply")
        love.graphics.setStencilTest(old_test_mode, old_test_value)
      end
    end

    if unit.is_portal then
      if loop or not unit.portal.objects then
        love.graphics.setColor(color[1] * 0.75, color[2] * 0.75, color[3] * 0.75, color[4])
        drawSprite(sprite_name .. "_bg")
      else
        love.graphics.setColor(lvl_color[1], lvl_color[2], lvl_color[3], lvl_color[4])
        drawSprite(sprite_name .. "_bg")
        love.graphics.setColor(1, 1, 1)
        local function holStencil()
          pcallSetShader(mask_shader)
          drawSprite(sprite_name .. "_mask")
          love.graphics.setShader()
        end
        local function holStencil2()
          love.graphics.rectangle("fill", fulldrawx + 0.5 * TILE_SIZE, fulldrawy - 0.5 * TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end
        love.graphics.stencil(holStencil, "replace", 2)
        love.graphics.stencil(holStencil2, "replace", 1, true)
        
        for _,peek in ipairs(unit.portal.objects) do
          if not peek.stelth then
            if not portaling[peek] then
              love.graphics.setStencilTest("greater", 1)
            else
              love.graphics.setStencilTest("greater", 0)
            end
            
            love.graphics.push()
            love.graphics.translate(fulldrawx, fulldrawy)
            love.graphics.rotate(-math.rad(rotation))
            if portaling[peek] ~= unit then
              love.graphics.rotate(math.rad(unit.portal.dir * 45))
            end
            love.graphics.translate(-fulldrawx, -fulldrawy)
            
            local x, y, rot = unit.draw.x, unit.draw.y, 0
            if peek.name ~= "no1" then
              if portaling[peek] ~= unit then
                x, y = (peek.draw.x - peek.x) + (peek.x - unit.portal.x) + x, (peek.draw.y - peek.y) + (peek.y - unit.portal.y) + y
                if peek.rotate then rot = peek.draw.rotation
                else rot = -unit.portal.dir * 45 end
              else
                x, y = peek.draw.x, peek.draw.y
                rot = peek.draw.rotation
              end
            else
              if peek.rotate then rot = (peek.dir - 1 + unit.portal.dir) * 45
              else rot = -unit.portal.dir * 45 end
            end
            if portaling[peek] == unit and peek.draw.x == peek.x and peek.draw.y == peek.y then
              portaling[peek] = nil
            else
              drawUnit(peek, x, y, rot, true)
            end
            
            love.graphics.pop()
          end
        end
        
        love.graphics.setStencilTest()
      end
    end
    
    if unit.fullname == "kat" and unit.color_override and colour_for_palette[unit.color_override[1]][unit.color_override[2]] == "blacc" then
      if graphical_property_cache["slep"][unit] ~= nil then
        love.graphics.setColor(getPaletteColor(2,1))
        love.graphics.draw(sprites["kat_eyes_slep"], fulldrawx, fulldrawy, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      else
        love.graphics.setColor(getPaletteColor(2,1))
        love.graphics.draw(sprites["kat_eyes"], fulldrawx, fulldrawy, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      end
    end
    
    if hasProperty(unit,"cool") then
      local o = getTableWithDefaults(unit.features.cool, {x=0, y=0, sprite="shades"})
      local shake_x, shake_y = getOffset()
      love.graphics.setColor(getPaletteColor(0,3))
      love.graphics.draw(sprites[o.sprite], fulldrawx + o.x + shake_x,  fulldrawy + o.y + shake_y, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
    end
    if hasProperty(unit,"sans") and unit.features.sans and not hasProperty(unit,"slep") then
      local topleft = {x = fulldrawx - 16, y = fulldrawy - 16}
      love.graphics.setColor(getPaletteColor(1,4))
      love.graphics.rectangle("fill", topleft.x + unit.features.sans.x, topleft.y + unit.features.sans.y, unit.features.sans.w, unit.features.sans.h)
      for i = 1, unit.features.sans.w-1 do
        love.graphics.rectangle("fill", topleft.x + unit.features.sans.x + i, topleft.y + unit.features.sans.y - i, unit.features.sans.w - i, 1)
      end
    end
    
    if unit.fullname == "der" and (hasProperty(unit,"brite") or hasProperty(unit,"torc")) then
      if graphical_property_cache["slep"][unit] ~= nil then
        love.graphics.setColor(getPaletteColor(2,2))
        love.graphics.draw(sprites["der_slep_nose"], fulldrawx, fulldrawy, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      else
        love.graphics.setColor(getPaletteColor(2,2))
        love.graphics.draw(sprites["der_nose"], fulldrawx, fulldrawy, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      end
    end

    local matchrules = matchesRule(unit,"got","?")
    for _,matchrule in ipairs(matchrules) do
      local name = matchrule.rule.object.name

      -- GOT object coloring!
      local c1, c2
      if matchrule.rule.object.prefix then
        local dummy = {}
        dummy[matchrule.rule.object.prefix] = true
        updateUnitColourOverride(dummy)
        if dummy.color_override then
          c1, c2 = dummy.color_override[1], dummy.color_override[2]
        end
      end

      local shake_x, shake_y = getOffset()

      if name == "which" then
        local o = getTableWithDefaults(unit.features.which, {x=0, y=0, sprite={"which_smol_base", "which_smol_that"}})
        love.graphics.setColor(getPaletteColor(0,0))
        love.graphics.draw(sprites[o.sprite[1]], fulldrawx + o.x + shake_x, fulldrawy - 0.5*TILE_SIZE + o.y + shake_y, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
        if c1 and c2 then
          love.graphics.setColor(getPaletteColor(c1,c2))
        elseif unit.color_override and colour_for_palette[unit.color_override[1]][unit.color_override[2]] == "blacc" then
          love.graphics.setColor(getPaletteColor(3,1))
        else
          love.graphics.setColor(color[1], color[2], color[3], color[4])
        end
        love.graphics.draw(sprites[o.sprite[2]], fulldrawx + o.x + shake_x, fulldrawy - 0.5*TILE_SIZE + o.y + shake_y, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      elseif name == "sant" then
        local o = getTableWithDefaults(unit.features.sant, {x=0, y=0, sprite={"sant_smol_base", "sant_smol_flof"}})
        love.graphics.setColor(getPaletteColor(c1 or 2, c2 or 2))
        love.graphics.draw(sprites[o.sprite[1]], fulldrawx + o.x + shake_x, fulldrawy - 0.5*TILE_SIZE + o.y + shake_y, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
        love.graphics.setColor(getPaletteColor(0,3))
        love.graphics.draw(sprites[o.sprite[2]], fulldrawx + o.x + shake_x, fulldrawy - 0.5*TILE_SIZE + o.y + shake_y, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      elseif name == "hatt" then
        local o = getTableWithDefaults(unit.features.hatt, {x=0, y=0, sprite="hatsmol"})
        if c1 and c2 then
          love.graphics.setColor(getPaletteColor(c1, c2))
        else
          love.graphics.setColor(color[1], color[2], color[3], color[4])
        end
        love.graphics.draw(sprites[o.sprite], fulldrawx + o.x + shake_x, fulldrawy - 0.5*TILE_SIZE + o.y + shake_y, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      elseif name == "katany" then
        local o = getTableWithDefaults(unit.features.katany, {x=0, y=0, sprite="katanysmol"})
        love.graphics.setColor(getPaletteColor(c1 or 0, c2 or 1))
        love.graphics.draw(sprites[o.sprite], fulldrawx + o.x + shake_x, fulldrawy + o.y + shake_y, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      elseif name == "knif" then
        local o = getTableWithDefaults(unit.features.knif, {x=0, y=0, sprite="knifsmol"})
        love.graphics.setColor(getPaletteColor(c1 or 0, c2 or 3))
        love.graphics.draw(sprites[o.sprite], fulldrawx + o.x + shake_x, fulldrawy + o.y + shake_y, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      elseif name == "slippers" then
        local o = getTableWithDefaults(unit.features.slippers, {x=0, y=0, sprite="slippers"})
        love.graphics.setColor(getPaletteColor(c1 or 1, c2 or 4))
        love.graphics.draw(sprites[o.sprite], fulldrawx + o.x + shake_x, fulldrawy+sprite:getHeight()/4 + o.y + shake_y, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      elseif name == "gunne" then
        local o = getTableWithDefaults(unit.features.gunne, {x=0, y=0, sprite="gunnesmol"})
        love.graphics.setColor(getPaletteColor(c1 or 0, c2 or 3))
        love.graphics.draw(sprites[o.sprite], fulldrawx + o.x + shake_x, fulldrawy + o.y + shake_y, 0, unit.draw.scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      elseif name ~= "bowie" and unit.fullname == "swan" then
        local tile = tiles_list[tiles_by_name[name]]
        if tile then
          -- temporarily replacing the current unit ... this is so janky im sorry
          local old_unit = unit
          unit = deepCopy(tile)
          unit.fullname = unit.name
          unit.overlay = {}
          unit.draw = {x = old_unit.draw.x, y = old_unit.draw.y, scalex = 0.5, scaley = 0.5, rotation = 0, opacity = 1}
          if c1 and c2 then
            if unit.colored then
              unit.color_override = {}
              for i,_ in ipairs(unit.colored) do
                if unit.colored[i] then
                  unit.color_override[i] = {c1, c2}
                else
                  unit.color_override[i] = unit.color[i]
                end
              end
            else
              unit.color_override = {c1, c2}
            end
          end

          love.graphics.push()
          love.graphics.translate(14, -4)
          if c1 and c2 then
            setColor{c1, c2}
          else
            setColor(tile.color)
          end
          drawSprite()
          love.graphics.pop()

          -- order is restored
          unit = old_unit
        end
      end
    end

    love.graphics.pop()

    if unit.blocked then
      local rotation = (unit.blocked_dir - 1) * 45

      love.graphics.push()
      love.graphics.rotate(math.rad(rotation))
      love.graphics.translate(-fulldrawx, -fulldrawy)

      local scalex = 1
      if unit.blocked_dir % 2 == 0 then
        scalex = math.sqrt(2)
      end

      love.graphics.setColor(getPaletteColor(2, 2))
      if settings["scribble_anim"] then
        love.graphics.draw(sprites["scribble_" .. anim_stage+1], fulldrawx, fulldrawy, 0, unit.draw.scalex * scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      else
        love.graphics.draw(sprites["scribble_1"], fulldrawx, fulldrawy, 0, unit.draw.scalex * scalex, unit.draw.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      end

      love.graphics.pop()
    end

    love.graphics.pop()

    if hasProperty(unit,"loop") then
      love.graphics.setColor(1,1,1,.4)
      love.graphics.rectangle("fill",fulldrawx-16,fulldrawy-16,32,32)
    end
  end

  for i=1,max_layer do
    if units_by_layer[i] then
      local removed_units = {}
      for _,unit in ipairs(units_by_layer[i]) do
        if not (unit.stelth or portaling[unit] or hasProperty(outerlvl, "stelth")) then
          local x, y, rot = unit.x, unit.y, 0
          if unit.name ~= "no1" then
            x, y = unit.draw.x, unit.draw.y
            rot = unit.draw.rotation
          else
            if (unit.rotate or hasProperty(unit,"rotatbl")) then rot = (unit.dir - 1) * 45 end
          end
          drawUnit(unit, x, y, rot)
        end
      end
      for _,unit in ipairs(removed_units) do
        removeFromTable(units_by_layer[i], unit)
      end
    end
  end
  local removed_particles = {}
  for _,ps in ipairs(particles) do
    ps:update(dt)
    if ps:getCount() == 0 then
      ps:stop()
      table.insert(removed_particles, ps)
    else
      love.graphics.setColor(255, 255, 255)
      love.graphics.draw(ps)
    end
  end
  for _,ps in ipairs(removed_particles) do
    removeFromTable(particles, ps)
  end

  --lightning !
  if (lightcanvas ~= nil) then
    love.graphics.setColor(0.05, 0.05, 0.05, 1)
    love.graphics.setBlendMode("add", "premultiplied")
    love.graphics.draw(lightcanvas, 0, 0)
    love.graphics.setBlendMode("alpha")
  end
  
  if settings["mouse_lines"] then
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setLineWidth(1)
    local r,g,b,a = getPaletteColor(0,1)
    love.graphics.setColor(r,g,b,0.3)
    for _,cursor in ipairs(cursors) do
      local cx,cy = cursor.screenx,cursor.screeny
      local width = love.graphics.getWidth()
      love.graphics.line(cx-width,cy-width,cx+width,cy+width)
      love.graphics.line(cx-width,cy,cx+width,cy)
      love.graphics.line(cx-width,cy+width,cx+width,cy-width)
      love.graphics.line(cx,cy-width,cx,cy+width)
    end
    love.graphics.pop()
  end

  --draw the stack box (shows what units are on a tile)
  if stack_box.scale > 0 then
    love.graphics.push()
    local screenx,screeny = gameTileToScreen(stack_box.x,stack_box.y)
    local onscreen = screeny > 40
    love.graphics.translate((stack_box.x + 0.5) * TILE_SIZE, (stack_box.y + (onscreen and 0 or 1)) * TILE_SIZE)
    love.graphics.scale(stack_box.scale)

    love.graphics.setColor(getPaletteColor(0, 4))
    if onscreen then
      love.graphics.polygon("fill", -4, -8, 0, 0, 4, -8)
    else
      love.graphics.polygon("fill", -4, 8, 0, 0, 4, 8)
    end

    local units = stack_box.units
    local draw_units = {}
    local already_added = {}
    for _,unit in ipairs(units) do
      local sprite = ""
      if type(unit.sprite) == "table" then
        sprite = unit.sprite[1]..(unit.meta or "")..(unit.nt and "nt" or "")..(unit.color_override and dump(unit.color_override) or "")
      else
        sprite = (unit.fullname ~= "letter_custom" and unit.sprite or "letter_"..unit.special.customletter)..(unit.meta or "")..(unit.nt and "nt" or "")..(unit.color_override and dump(unit.color_override) or "")
      end
      if not already_added[sprite] then already_added[sprite] = {} end
      local dir = unit.rotatdir
      if not already_added[sprite][dir] then
        table.insert(draw_units, {unit = unit, dir = dir, count = 1})
        already_added[sprite][dir] = #draw_units
      else
        draw_units[already_added[sprite][dir]].count = draw_units[already_added[sprite][dir]].count + 1
      end
    end

    local width = 44 * #draw_units - 4
    if onscreen then
      love.graphics.rectangle("fill", -width / 2, -48, width, 40)
    else
      love.graphics.rectangle("fill", -width / 2, 8, width, 40)
    end

    love.graphics.setColor(getPaletteColor(3, 3))
    love.graphics.setLineWidth(2)
    if onscreen then
      love.graphics.line(-width / 2, -48, -width / 2, -8, -4, -8, 0, 0, 4, -8, width / 2, -8, width / 2, -48, -width / 2, -48)
    else
      love.graphics.line(-width / 2, 48, -width / 2, 8, -4, 8, 0, 0, 4, 8, width / 2, 8, width / 2, 48, -width / 2, 48)
    end

    for i,draw in ipairs(draw_units) do
      local cx = (-width / 2) + ((i / #draw_units) * width) - 20
      local unit = draw.unit
      local dcolor = unit.color_override or unit.color

      love.graphics.push()
      if onscreen then
        love.graphics.translate(cx, -28)
      else
        love.graphics.translate(cx, 28)
      end
      love.graphics.push()
      love.graphics.rotate(math.rad((draw.dir - 1) * 45))
      
      if type(unit.sprite) ~= "table" then
        if #dcolor == 2 then
          love.graphics.setColor(getPaletteColor(dcolor[1], dcolor[2]))
        else
          love.graphics.setColor(dcolor[1], dcolor[2], dcolor[3], dcolor[4] or 1)
        end
        if unit.fullname == "letter_custom" then
          drawCustomLetter(unit.special.customletter, 0, 0, 0, 1, 1, 16, 16)
        else
          local sprite = sprites[unit.sprite]
          love.graphics.draw(sprite, 0, 0, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
        end
      else
        for j,image in ipairs(unit.sprite) do
          love.graphics.setColor(getPaletteColor(unpack(getUnitColors(unit, j))))
          local sprite = sprites[image]
          love.graphics.draw(sprite, 0, 0, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
        end
      end
      
      if (unit.meta ~= nil) then
				love.graphics.setColor(getPaletteColor(4, 1))
				local metasprite = unit.meta == 2 and sprites["meta2"] or sprites["meta1"]
				love.graphics.draw(metasprite, 0, 0, 0, 1, 1, TILE_SIZE / 2, TILE_SIZE / 2)
				if unit.meta > 2 then
					love.graphics.printf(tostring(unit.meta), -1, 6, 32, "center")
				end
			end
      if (unit.nt ~= nil) then
        love.graphics.setColor(getPaletteColor(2, 2))
        local ntsprite = sprites["n't"]
        love.graphics.draw(ntsprite, 0, 0, 0, 1, 1, TILE_SIZE / 2, TILE_SIZE / 2)
        love.graphics.setColor(getPaletteColor(unit.color[1], unit.color[2]))
      end
      love.graphics.pop()

      if draw.count > 1 then
        love.graphics.setFont(stack_font)
        love.graphics.setColor(getPaletteColor(0, 4))
        for x = -1, 1 do
          for y = -1, 1 do
            if x ~= 0 or y ~= 0 then
              love.graphics.printf(tostring(draw.count), x, 4+y, 32, "center")
            end
          end
        end
        love.graphics.setColor(getPaletteColor(0, 3))
        love.graphics.printf(tostring(draw.count), 0, 4, 32, "center")
      end
      love.graphics.pop()
    end

    love.graphics.pop()
  end
  if pathlock_box.scale > 0 then
    love.graphics.push()
    local screenx,screeny = gameTileToScreen(stack_box.x,stack_box.y)
    local onscreen = screeny > 40
    love.graphics.translate((pathlock_box.x + 0.5) * TILE_SIZE, (pathlock_box.y + (onscreen and 0 or 1)) * TILE_SIZE)
    love.graphics.scale(pathlock_box.scale)

    love.graphics.setColor(getPaletteColor(0, 4))
    if onscreen then
      love.graphics.polygon("fill", -4, -8, 0, 0, 4, -8)
    else
      love.graphics.polygon("fill", -4, 8, 0, 0, 4, 8)
    end

    local unit = pathlock_box.unit

    local width = 70
    if onscreen then
      love.graphics.rectangle("fill", -width / 2, -48, width, 40)
    else
      love.graphics.rectangle("fill", -width / 2, 8, width, 40)
    end

    love.graphics.setColor(getPaletteColor(3, 3))
    love.graphics.setLineWidth(2)
    if onscreen then
      love.graphics.line(-width / 2, -48, -width / 2, -8, -4, -8, 0, 0, 4, -8, width / 2, -8, width / 2, -48, -width / 2, -48)
    else
      love.graphics.line(-width / 2, 48, -width / 2, 8, -4, 8, 0, 0, 4, 8, width / 2, 8, width / 2, 48, -width / 2, 48)
    end
    
    local type = ({puffs = "puff", blossoms = "blossom", orbs = "orrb"})[unit.special.pathlock]
    love.graphics.setColor(type == "orrb" and {getPaletteColor(4,1)} or {1,1,1,1})
    love.graphics.draw(sprites[type], -30, -44)
    local num = unit.special.number or 1
    love.graphics.setFont(num > 99 and stack_font or pathlock_font)
    love.graphics.printf(tostring(num), 5, -36, 25, "center")

    love.graphics.pop()
  end
  love.graphics.pop()

  --176 98
  if stopwatch.visible then
    stopwatch.small.rotation = stopwatch.small.rotation + dt * 20

    local sw_sprite = sprites["ui/stopwatch"]
    local big_hand = sprites["ui/stopwatch_big_hand"]
    local small_hand = sprites["ui/stopwatch_small_hand"]

    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(1, 1, 1)
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    love.graphics.scale(getUIScale(), getUIScale())
    love.graphics.translate(-sw_sprite:getWidth() / 2, -sw_sprite:getHeight() / 2)
    love.graphics.draw(sw_sprite)

    love.graphics.setColor(1, 1, 1)
    love.graphics.push()
    love.graphics.translate(176 + small_hand:getWidth() / 2, 98 + small_hand:getHeight() / 2)
    love.graphics.rotate(stopwatch.small.rotation)
    love.graphics.draw(small_hand, -small_hand:getWidth() / 2, -small_hand:getHeight() / 2)
    love.graphics.pop()

    love.graphics.push()
    love.graphics.translate(big_hand:getWidth() / 2, big_hand:getHeight() / 2)
    love.graphics.rotate(math.rad(stopwatch.big.rotation))
    love.graphics.draw(big_hand, -big_hand:getWidth() / 2, -big_hand:getHeight() / 2)
    love.graphics.pop()
    love.graphics.pop()
  end

  love.graphics.push()
  love.graphics.setColor(1, 1, 1)
  love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  love.graphics.scale(win_size, win_size)
  local win_sprite = #win_sprite_override > 0 and sprites["ui/u_r_thing"] or sprites["ui/u_r_win"]
  love.graphics.draw(win_sprite, -win_sprite:getWidth() / 2, -win_sprite:getHeight() / 2, 0, 1, 1)

  if currently_winning and win_size < 1 then
    win_size = win_size + dt*2
    if (win_size > 1) then
      win_size = 1
    end
  end
  love.graphics.pop()
  
  if #win_sprite_override > 0 then
    for _,tile in ipairs(win_sprite_override) do
      love.graphics.push()
      love.graphics.setColor(0.92, 0.92, 1)
      love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
      love.graphics.scale(win_size, win_size)
      local tf_sprite = sprites[tile.sprite]
      love.graphics.draw(tf_sprite, -tf_sprite:getWidth() / 2 + 40, -tf_sprite:getHeight() / 2 - 45, 0, 4, 4)
      if (tile.meta ~= nil) then
        local metasprite = tile.meta == 2 and sprites["meta2"] or sprites["meta1"]
				love.graphics.draw(metasprite, -metasprite:getWidth() / 2 + 40, -metasprite:getHeight() / 2 - 45, 0, 4, 4)
				if tile.meta > 2 and win_size == 1 then
          --This doesn't print anything to the screen, though I'm uncertain why not
					love.graphics.printf(tostring(tile.meta), -metasprite:getWidth() / 2 + 40, -metasprite:getHeight() / 2 - 45, 32, "center")
				end
      end
      if (tile.nt ~= nil) then
        local nt_sprite = sprites["n't"];
        love.graphics.draw(nt_sprite, -nt_sprite:getWidth() / 2 + 40, -nt_sprite:getHeight() / 2 - 45, 0, 4, 4)
      end
      love.graphics.pop()
    end
  end
  
  -- Replay UI
  if replay_playback then
    local height, width = love.graphics.getHeight(), love.graphics.getWidth()
    local box = sprites["ui/32x32"]:getWidth()
  
    if not replay_pause then
        -- Play speeds
        if replay_playback_interval < 0.05 then
            love.graphics.draw(sprites["ui/replay_fff"], width - box*3)
        elseif replay_playback_interval < 0.2 and replay_playback_interval > 0.05 then
            love.graphics.draw(sprites["ui/replay_ff"], width - box*3)
        elseif replay_playback_interval > 0.5 and replay_playback_interval < 1 then
            love.graphics.draw(sprites["ui/replay_slow"], width - box*3)
        elseif replay_playback_interval > 1 then
            love.graphics.draw(sprites["ui/replay_snail"], width - box*3)
        else
            love.graphics.draw(sprites["ui/replay_play"], width - box*3)
        end
        love.graphics.draw(sprites["ui/replay_minus"], width - box*4)
        love.graphics.draw(sprites["ui/replay_plus"], width - box*2)
    elseif replay_pause then
        love.graphics.draw(sprites["ui/replay_pause"], width - box*3)
        love.graphics.draw(sprites["ui/replay_undo"], width - box*4)
        love.graphics.draw(sprites["ui/replay_skip"], width - box*2)
    end
    love.graphics.draw(sprites["ui/replay_stop"], width - box)
    -- print(replay_playback_interval)
  end
  
  love.graphics.setCanvas()
  pcallSetShader(level_shader)
  --[[
  if doin_the_world then
    level_shader:send("time", shader_time)
    shader_time = shader_time + 1
  end
  ]]
  love.graphics.draw(canv,0,0)
  if shader_time == 600 then
    pcallSetShader(paletteshader_0)
    doin_the_world = false
  end

  if not pause then gooi.draw() end
  if is_mobile then
    if rules_with["za warudo"] then
      mobile_controls_timeless:setVisible(true)
      mobile_controls_timeless:setBGImage(sprites[timeless and "ui/time resume" or "ui/timestop"])
    else
      mobile_controls_timeless:setVisible(false)
    end
    if rules_with["u"] then
      if rules_with["u too"] then
          mobile_controls_p1:setVisible(true)
          mobile_controls_p2:setVisible(true)
          mobile_controls_p3:setVisible(true)
        if rules_with["u tres"] then
          mobile_controls_p1:setBGImage(sprites["ui_1"])
          mobile_controls_p2:setBGImage(sprites["ui_2"])
          mobile_controls_p3:setBGImage(sprites["ui_3"])
        else
          mobile_controls_p1:setBGImage(sprites["ui_1"])
          mobile_controls_p2:setBGImage(sprites["ui_2"])
          mobile_controls_p3:setBGImage(sprites["ui_plus"])
        end
      elseif rules_with["u tres"] then
        mobile_controls_p1:setVisible(true)
        mobile_controls_p2:setVisible(true)
        mobile_controls_p3:setVisible(true)
        mobile_controls_p1:setBGImage(sprites["ui_1"])
        mobile_controls_p2:setBGImage(sprites["ui_plus"])
        mobile_controls_p3:setBGImage(sprites["ui_3"])
      else
        mobile_controls_p1:setVisible(false)
        mobile_controls_p2:setVisible(false)
        mobile_controls_p3:setVisible(false)
      end
    elseif rules_with["u too"] and rules_with["u tres"] then
      mobile_controls_p1:setVisible(true)
      mobile_controls_p2:setVisible(true)
      mobile_controls_p3:setVisible(true)
      mobile_controls_p1:setBGImage(sprites["ui_plus"])
      mobile_controls_p2:setBGImage(sprites["ui_2"])
      mobile_controls_p3:setBGImage(sprites["ui_3"])
    else
      mobile_controls_p1:setVisible(false)
      mobile_controls_p2:setVisible(false)
      mobile_controls_p3:setVisible(false)
    end
  end

  gooi.draw("mobile-controls")

  if love.window.hasMouseFocus() then
    for i,cursor in ipairs(cursors) do
      local color
      
      -- Mous be colors
      if hasProperty(cursor,"rave") then
        local newcolor = hslToRgb((love.timer.getTime()/0.75+#undo_buffer/45+cursor.screenx/18+cursor.screeny/18)%1, .5, .5, 1)
        newcolor[1] = newcolor[1]*255
        newcolor[2] = newcolor[2]*255
        newcolor[3] = newcolor[3]*255
        color = newcolor
      elseif hasProperty(cursor,"colrful") or rainbowmode then
        local newcolor = hslToRgb((love.timer.getTime()/15+#undo_buffer/45+cursor.screenx/18+cursor.screeny/18)%1, .5, .5, 1)
        newcolor[1] = newcolor[1]*255
        newcolor[2] = newcolor[2]*255
        newcolor[3] = newcolor[3]*255
        color = newcolor
	  elseif (hasProperty(cursor,"reed") and hasProperty(cursor,"whit")) or hasProperty(cursor,"pinc") then
	    color = {4, 1}
	  elseif (hasProperty(cursor,"grun") and hasProperty(cursor,"whit")) then
	    color = {5, 3}
	  elseif (hasProperty(cursor,"bleu") and hasProperty(cursor,"reed")) or hasProperty(cursor,"purp") then
        color = {3, 1}
	  elseif (hasProperty(cursor,"reed") and hasProperty(cursor,"grun")) or hasProperty(cursor,"yello") then
	    color = {2, 4}
	  elseif (hasProperty(cursor,"reed") and hasProperty(cursor,"yello")) or hasProperty(cursor,"orang") then
	    color = {2, 3}
	  elseif (hasProperty(cursor,"bleu") and hasProperty(cursor,"grun")) or hasProperty(cursor,"cyeann") then
	    color = {1, 4}
	  elseif hasProperty(cursor,"reed") then
        color = {2, 2}
	  elseif hasProperty(cursor,"bleu") then
	    color = {1, 3}
	  elseif hasProperty(cursor,"grun") then
	    color = {5, 2}
      elseif hasProperty(cursor,"cyeann") then
        color = {1, 4}
      elseif hasProperty(cursor,"blacc") then
        color = {0, 4}
      end

      if not color then
        love.graphics.setColor(1, 1, 1)
      else
        if #color == 3 then
          love.graphics.setColor(color[1]/255, color[2]/255, color[3]/255)
        else
          love.graphics.setColor(getPaletteColor(color[1], color[2]))
        end
      end

      if rainbowmode then love.graphics.setColor(hslToRgb((love.timer.getTime()/6+i*10)%1, .5, .5, .9)) end
      
      if not hasProperty(cursor,"stelth") then
        love.graphics.draw(system_cursor, cursor.screenx, cursor.screeny)
      end

      love.graphics.setColor(1,1,1)
      color = nil

      if #cursor.overlay > 0 then
        local function overlayStencil()
          pcallSetShader(mask_shader)
          love.graphics.draw(system_cursor, cursor.screenx, cursor.screeny)
          love.graphics.setShader()
        end
        for _,overlay in ipairs(cursor.overlay) do
          love.graphics.setColor(1, 1, 1)
          love.graphics.stencil(overlayStencil, "replace")
          love.graphics.setStencilTest("greater", 0)
          love.graphics.setBlendMode("multiply", "premultiplied")
          love.graphics.draw(sprites["overlay/" .. overlay], cursor.screenx, cursor.screeny, 0, 14/32, 14/32)
          love.graphics.setBlendMode("alpha", "alphamultiply")
          love.graphics.setStencilTest()
        end
      end
    end
  end

  
  if displaywords or pause then
    darken:draw()

    local rules = ""

    local lines = 0.5
    local curline = ""

    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    local buttonwidth, buttonheight = sprites["ui/button_1"]:getDimensions()

    local buttoncolor = {84/255, 109/255, 255/255}

    local y = (not pause) and 0 or button_last_y

    for i,rule in pairs(full_rules) do
      if not rule.hide_in_list then
        local serialized = serializeRule(rule.rule)
        if serialized ~= "" then
          
          if curline == "" then
            -- do nothing, this is just a ~= on the other two cases
          elseif (#curline + #serialized) > 50 then
            rules = rules..curline.."\n"
            curline = ""
            lines = lines + 1
          else
            curline = curline..'   '
          end
          curline = curline..serialized
        end
      end
    end
    rules = rules..curline

	  rules = 'da rulz:\n'..rules

    love.graphics.setColor(1,1,1)

    if pause then
    
      local current_level = level_name
      if readSaveFile{"levels", level_filename, "won"} then
        current_level = current_level.." (won) "
      end
      if readSaveFile{"levels", level_filename, "clear"} then
        current_level = current_level.." (cleared) "
      end
      if readSaveFile{"levels", level_filename, "complete"} then
        current_level = current_level.." (complete) "
      end
      if readSaveFile{"levels", level_filename, "bonus"} then
        current_level = current_level.." (bonused) "
      end
      local tfs = readSaveFile{"levels", level_filename, "transform"}
      if tfs then
        local tfstr = ""
        for _,tf in ipairs(tfs) do
          while tf:starts("text_") do
            tf = tf:sub(6)
            tf = tf.." txt"
          end
          tfstr = tfstr.." & "..tf
        end
        tfstr = tfstr:sub(4)
        current_level = current_level.." (transformed into " .. tfstr .. ") "
      end
      
      love.graphics.printf(current_level, width/2-buttonwidth/2, buttonheight, buttonwidth, "center")
  
      for _,button in ipairs(buttons) do
        button:draw()
      end
    end

    local rules_height = love.graphics.getHeight()/2-love.graphics.getFont():getHeight()*lines+y 
    if pause then
      rules_height = buttonheight*4+(buttonheight+10)*(#buttons)
    end
    love.graphics.printf(rules, 0, rules_height, love.graphics.getWidth(), "center")

    love.graphics.setColor(1,1,1)
    love.graphics.draw(sprites["ui/mous"], love.mouse.getX(), love.mouse.getY())

    gooi.draw()
  end

  if (just_moved and not unit_tests) then
    local end_time = love.timer.getTime()
      print("scene.draw() took: "..tostring(round((end_time-start_time)*1000)).."ms")
    just_moved = false
  end
end

function scene.checkInput()
  if replay_playback or past_playback then return end
  local start_time = love.timer.getTime()
  do_move_sound = false
  
  
  if settings["focus_pause"] and not (love.window.hasFocus() or love.window.hasMouseFocus()) then
    pause = true
  end
  
  if not (key_down["w"] or key_down["a"] or key_down["s"] or key_down["d"]) then
      repeat_timers["wasd"] = nil
  end
  if not (key_down["up"] or key_down["down"] or key_down["left"] or key_down["right"]) then
      repeat_timers["udlr"] = nil
  end
  if not (key_down["i"] or key_down["j"] or key_down["k"] or key_down["l"]) then
      repeat_timers["ijkl"] = nil
  end
  if not (key_down["kp1"] or
        key_down["kp2"] or
        key_down["kp3"] or
        key_down["kp4"] or
        key_down["kp5"] or
        key_down["kp6"] or
        key_down["kp7"] or
        key_down["kp8"] or
        key_down["kp9"]) then
    repeat_timers["numpad"] = nil
  end
  
  if not (key_down["z"] or key_down["q"] or key_down["backspace"] or key_down["kp0"] or key_down["o"]) then
      repeat_timers["undo"] = nil
  end

  for _,key in ipairs(repeat_keys) do
    if repeat_timers[key] ~= nil and repeat_timers[key] <= 0 then
      if key == "undo" then
        just_moved = true
        if (last_input_time ~= nil) then
          print("input latency: "..tostring(round((start_time-last_input_time)*1000)).."ms")
          last_input_time = nil
        end
        local result = doOneMove(0, 0, "undo")
        if result then playSound("undo") else playSound("fail") end
        do_move_sound = false
				local end_time = love.timer.getTime()
        if not unit_tests then print("undo took: "..tostring(round((end_time-start_time)*1000)).."ms") end
      else
        local x, y = 0, 0
        if key == "udlr" then
            if key_down["up"] and most_recent_key ~= "down" then y = y - 1 end
            if key_down["down"] and most_recent_key ~= "up" then y = y + 1 end
            if key_down["left"] and most_recent_key ~= "right" then x = x - 1 end
            if key_down["right"] and most_recent_key ~= "left" then x = x + 1 end
        elseif key == "wasd" then
            if key_down["w"] and most_recent_key ~= "s" then y = y - 1 end
            if key_down["s"] and most_recent_key ~= "w" then y = y + 1 end
            if key_down["a"] and most_recent_key ~= "d" then x = x - 1 end
            if key_down["d"] and most_recent_key ~= "a" then x = x + 1 end
        elseif key == "ijkl" then
            if key_down["i"] and most_recent_key ~= "k" then y = y - 1 end
            if key_down["k"] and most_recent_key ~= "i" then y = y + 1 end
            if key_down["j"] and most_recent_key ~= "l" then x = x - 1 end
            if key_down["l"] and most_recent_key ~= "j" then x = x + 1 end
        elseif key == "numpad" then
            if key_down["kp1"] and most_recent_key ~= "kp9" then x = x + -1; y = y + 1 end
            if key_down["kp2"] and most_recent_key ~= "kp8" then x = x + 0; y = y + 1 end
            if key_down["kp3"] and most_recent_key ~= "kp7" then x = x + 1; y = y + 1 end
            if key_down["kp4"] and most_recent_key ~= "kp6" then x = x + -1; y = y + 0 end
            if key_down["kp6"] and most_recent_key ~= "kp4" then x = x + 1; y = y + 0 end
            if key_down["kp7"] and most_recent_key ~= "kp3" then x = x + -1; y = y + -1 end
            if key_down["kp8"] and most_recent_key ~= "kp2" then x = x + 0; y = y + -1 end
            if key_down["kp9"] and most_recent_key ~= "kp1" then x = x + 1; y = y + -1 end
        end
        x = sign(x); y = sign(y)
        if (last_input_time ~= nil) then
          print("input latency: "..tostring(round((start_time-last_input_time)*1000)).."ms")
          last_input_time = nil
        end
        doOneMove(x, y, key)
        local end_time = love.timer.getTime()
        if not unit_tests then print("gameplay logic took: "..tostring(round((end_time-start_time)*1000)).."ms") end
        -- SING
        if tiles_by_name["text_sing"] then
          
          local sing_rules = matchesRule(nil, "sing", "?")
          for _,ruleparent in ipairs(sing_rules) do
            local unit = ruleparent[2]
            
            if unit.name == "no1" then break end
            if unit.name == "swan" then
              local sound = love.sound.newSoundData("assets/audio/sfx/honk" .. math.random(1,6) .. ".wav");
              local source = love.audio.newSource(sound, "static")
              source:setVolume(1)
              source:setPitch(math.random() * ((2^(11/12)) - 1) + 1)
              source:play()
            else
              local specific_sing = tiles_list[unit.tile].sing or "bit";
              if (unit.name == "pata") then
                specific_sing = "pata" .. tostring(unit.dir)
              end
              
              local sing_note = ruleparent[1].rule.object.name;
              local sing_color = ruleparent[1].rule.object.unit.color_override or ruleparent[1].rule.object.unit.color;
              local sing_octave = 0;
              if (sing_color[1] <= 6 and sing_color[2] <= 4) then
                local sing_color_word = colour_for_palette[sing_color[1]][sing_color[2]];
                if sing_color_word == "whit" then
                  sing_octave = 0
                elseif sing_color_word == "blacc" then
                  sing_octave = -5
                elseif sing_color_word == "brwn" then
                  sing_octave = -4
                elseif sing_color_word == "reed" then
                  sing_octave = -3
                elseif sing_color_word == "orang" then
                  sing_octave = -2
                elseif sing_color_word == "yello" then
                  sing_octave = -1
                elseif sing_color_word == "grun" then
                  sing_octave = 0
                elseif sing_color_word == "cyeann" then
                  sing_octave = 1
                elseif sing_color_word == "bleu" then
                  sing_octave = 2
                elseif sing_color_word == "purp" then
                  sing_octave = 3
                elseif sing_color_word == "pinc" then
                  sing_octave = 4
                elseif sing_color_word == "graey" then
                  sing_octave = 5
                end
              end
              local sing_pitch = 1
              if sing_note == "c" or sing_note == "b_sharp" then
                sing_pitch = 1
              elseif sing_note == "c_sharp" or sing_note == "d_flat" then
                sing_pitch = 2^(1/12)
              elseif sing_note == "d" then
                sing_pitch = 2^(2/12)
              elseif sing_note == "d_sharp" or sing_note == "e_flat" then
                sing_pitch = 2^(3/12)
              elseif sing_note == "e" or sing_note == "f_flat" then
                sing_pitch = 2^(4/12)
              elseif sing_note == "f" or sing_note == "e_sharp" then
                sing_pitch = 2^(5/12)
              elseif sing_note == "f_sharp" or sing_note == "g_flat" then
                sing_pitch = 2^(6/12)
              elseif sing_note == "g" then
                sing_pitch = 2^(7/12)
              elseif sing_note == "g_sharp" or sing_note == "a_flat" then
                sing_pitch = 2^(8/12)
              elseif sing_note == "a" then
                sing_pitch = 2^(9/12)
              elseif sing_note == "a_sharp" or sing_note == "b_flat" then
                sing_pitch = 2^(10/12)
              elseif sing_note == "b" or sing_note == "c_flat" then
                sing_pitch = 2^(11/12)
              end
              
              sing_pitch = sing_pitch * 2^sing_octave
              --slightly randomize for chorusing purposes between 99% and 101%
              sing_pitch = sing_pitch * 0.99+(math.random()/50)
              
              sound = love.sound.newSoundData("assets/audio/sfx/" .. specific_sing .. ".wav");
              local source = love.audio.newSource(sound, "static")
              source:setVolume(1)
              source:setPitch(sing_pitch or 1)
              source:play()
            
              addParticles("sing", unit.x, unit.y, sing_color)
            end
          end
        end
        -- BUP
        if hasU("bup") and units_by_name["bup"] then
            playSound("bup")
        end
      end
    end

    if repeat_timers[key] ~= nil then
      if repeat_timers[key] <= 0 then
        if key ~= "undo" then
          repeat_timers[key] = repeat_timers[key] + INPUT_DELAY
        else
          repeat_timers[key] = repeat_timers[key] + UNDO_DELAY
          UNDO_DELAY = math.max(MIN_UNDO_DELAY, UNDO_DELAY - UNDO_SPEED)
        end
      end
      repeat_timers[key] = repeat_timers[key] - (love.timer.getDelta() * 1000)
    end
  end

  if do_move_sound then
    playSound("move")
  end

  if stack_box.enabled then
    local keep = false
    for _,unit in ipairs(stack_box.units) do
      if unit.x == stack_box.x and unit.y == stack_box.y and not unit.removed then
        keep = true
      end
    end
    if not keep then
      scene.setStackBox(-1, -1)
    else
      stack_box.units = getUnitsOnTile(stack_box.x, stack_box.y)
    end
  end
end

function escResult(do_actual, xwx)
  if was_using_editor then
    if do_actual then
      load_mode = "edit"
      new_scene = editor
    else
      return "the editor"
    end
  else
    -- i dont know what this is :owoXD:
    if win_reason == "nxt" and level_next_level ~= nil and level_next_level ~= "" then
      if do_actual then
        loadLevels({level_next_level}, "play", nil, xwx)
        return
      else
        return level_next_level
      end
    elseif #level_tree > 0 then
      local parent = level_tree[1]
      local seen = true
      --[[if type(parent) == "table" then
        for _,name in ipairs(parent) do
          if not readSaveFile{"levels", name, "seen"} then
            seen = false
            break
          end
        end
      else
        seen = readSaveFile{"levels", parent, "seen"}
      end]]
      if seen then
        if do_actual then
          if type(parent) == "table" then
            loadLevels(parent, "play", nil, xwx)
          else
            loadLevels({parent}, "play", nil, xwx)
          end
          table.remove(level_tree, 1)
          return
        else
          if type(parent) == "table" then
            return table.concat(parent, " & ")
          else
            return parent
          end
        end
      end
    end
    if do_actual then
      load_mode = "play"
      new_scene = loadscene
      if (love.filesystem.getInfo(getWorldDir(true) .. "/" .. "overworld.txt")) then
        world = ""
      end
    else
      return "the level selection menu"
    end
  end
end

function doOneMove(x, y, key, past)
  if pause then return end
  
  if not past then
    table.insert(all_moves, {x, y, key})
  end
  current_move = current_move + 1

	if (currently_winning and not past) then
    --undo: undo win.
    --idle on the winning screen: go to the editor, if we were editing; go to the parent level, if known (prefer explicit to implicit), else go back to the world we were looking at.
    if (key == "undo") then
      undoWin()
    else
      if x == 0 and y == 0 and key ~= "e" and not past then
        escResult(true)
      end
      return
    end
  end
  
  if (key == "e") then
		if hasProperty(nil,"za warudo") then
      --[[
      level_shader = shader_zawarudo
      shader_time = 0
      doin_the_world = true
      ]]
      newUndo()
      timeless = not timeless
      if timeless then
        if not doing_past_turns then
          extendReplayString(0, 0, "e")
        end
        if firsttimestop then
          playSound("timestop long",0.5)
          if units_by_name["za warudo"] then
            playSound("za warudo",0.5)
          end
        else
          playSound("timestop",0.5)
        end
      else
        addUndo({"timeless_rules", rules_with, full_rules})
        parseRules()
        should_parse_rules = true
        doMovement(0,0,"e")
        if firsttimestop then
          playSound("time resume long",0.5)
          firsttimestop = false
          if units_by_name["za warudo"] then
            playSound("time resume dio",0.5)
          end
        else
          playSound("time resume",0.5)
        end
      end
      addUndo({"za warudo", timeless})
      unsetNewUnits()
    else
      addUndo({"timeless_rules", rules_with, full_rules})
      timeless = false
      should_parse_rules = true
    end
    mobile_controls_timeless:setBGImage(sprites[timeless and "ui/time resume" or "ui/timestop"])
  elseif (key == "f") then
    if not doing_past_turns then
      extendReplayString(0, 0, "f")
    end

    if hasRule("press","f2",":)") then
      doWin("won")
    end
    if hasRule("press","f2","try again") then
      doTryAgain()
    end
    if hasRule("press","f2","xwx") then
      love = {}
    end
    if hasRule("press","f2","nxt") then
      doWin("nxt")
    end

    local to_destroy = {}
    if hasRule("press","f2","hotte") then
      local melters = getUnitsWithEffect("fridgd")
      for _,unit in ipairs(melters) do
        table.insert(to_destroy, unit)
        addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
      end
      if #to_destroy > 0 then
        playSound("hotte")
      end
    end
    to_destroy = handleDels(to_destroy)
    
    if hasRule("press","f2",":(") then
      local yous = getUs()
      for _,unit in ipairs(yous) do
        table.insert(to_destroy, unit)
        addParticles("destroy", unit.x, unit.y, unit.color_override or unit.color)
      end
    end
    to_destroy = handleDels(to_destroy)
	elseif (key == "undo") then
    local result = undo()
    if not doing_past_turns then
      extendReplayString(0, 0, "undo")
    end
    unsetNewUnits()
		return result
  else
    if key ~= "drag" then
      newUndo()
    end
		last_move = {x, y}
		just_moved = true
		doMovement(x, y, key)
    last_click_x, last_click_y = nil, nil
		if #undo_buffer > 0 and #undo_buffer[1] == 0 then
			table.remove(undo_buffer, 1)
		end
    unsetNewUnits()
    scene.doPastTurns()
	end
  return true
end

function scene.doPassiveParticles(timer,word,effect,delay,chance,count,color)
  local do_particles = false
  if not particle_timers[word] then
    particle_timers[word] = 0
  else
    particle_timers[word] = particle_timers[word] + timer
    if particle_timers[word] >= delay then
      particle_timers[word] = particle_timers[word] - delay
      do_particles = true
    end
  end
  
  if do_particles and not timeless then
    local matches = matchesRule(nil,"be",word)
    for _,match in ipairs(matches) do
      local unit = match[2]
      local real_count = 0
      for i = 1, count do
        if math.random() < chance then
          real_count = real_count + 1
        end
      end
      if not unit.stelth and particlesRngCheck() then
        if word == ":)" and countProperty(unit,":)") > countProperty (unit,";d") then
          addParticles(effect, unit.x, unit.y, color, real_count)
        elseif word == ";d" and countProperty(unit,":)") < countProperty (unit,";d") then
          addParticles(effect, unit.x, unit.y, color, real_count)
        elseif word ~= ":)" and word ~= ";d" then
          addParticles(effect, unit.x, unit.y, color, real_count)
        end
      end
    end
  end
end

function scene.doPastTurns()
  if not doing_past_turns and change_past then
    old_units = units
    old_units_by_id = units_by_id
    doing_past_turns = true
    past_playback = true
    past_queued_wins = {}

    if (unit_tests or not settings["stopwatch_effect"]) then
      do_past_effects = true
      playSound("stopwatch")
    end

    cutscene_tick:delay(function() 
      do_past_effects = false
      local start_time = love.timer.getTime()
      local destroy_level = false
      local old_move = current_move
      local old_move_total = #all_moves
      
      --[[while change_past and not destroy_level do
        change_past = false
        local past_buffer = undo_buffer
        scene.resetStuff()
        current_move = 0
        undo_buffer = {}
        for i,past_move in ipairs(all_moves) do
          doOneMove(past_move[1], past_move[2], past_move[3], true)
          if change_past then break end
          if love.timer.getTime() - start_time > 10 then
            destroy_level = true
            break
          end
        end
        undo_buffer = past_buffer
      end]]
      if destroy_level then
        destroyLevel("infloop")
      elseif (settings["stopwatch_effect"] and not unit_tests) then
        local moves_per_tick = 1
        local delay = math.max(1/#all_moves, 1/20)
        while delay < 1/60 do
          moves_per_tick = moves_per_tick * 2
          delay = delay * 2
        end
        stopwatch.visible = true
        stopwatch.big.rotation = 0
        stopwatch.small.rotation = 0
        clock_tween = tween.new(delay * math.ceil(#all_moves / moves_per_tick), stopwatch.big, {rotation = 360})
        addTween(clock_tween, "stopwatch")

        do_past_effects = true
        playSound("stopwatch")
        local past_buffer = undo_buffer
        scene.resetStuff(true)
        current_move = 0
        local iterations = 1
        local count = math.min(#all_moves - i, moves_per_tick - 1)
        local function pastMove(i, count)
          change_past = false
          local finished = false
          for j = 0, count do
            if i+j == #all_moves then
              finished = true
            end
            doOneMove(all_moves[i+j][1], all_moves[i+j][2], all_moves[i+j][3], true)
          end
          if change_past then
            cutscene_tick:delay(function()
              addTween(tween.new(delay, stopwatch.big, {rotation = 0}), "stopwatch")
              change_past = false
              --past_buffer = undo_buffer
              scene.resetStuff(true)
              current_move = 0
              iterations = iterations + 1
            end, delay):after(function()
              clock_tween:set(0)
              addTween(clock_tween, "stopwatch")
              playSound("stopwatch")
              pastMove(1, math.min(#all_moves - 1, moves_per_tick - 1))
            end, delay)
          elseif finished then
            stopwatch.visible = false
            should_parse_rules = true
            doing_past_turns = false
            past_playback = false
            past_rules = {}
            
            for result, payload in pairs(past_queued_wins) do
              doWin(result, payload)
            end
            
            undo_buffer = past_buffer
            createUndoBasedOnUnitsChanges(old_units, old_units_by_id, units, units_by_id)
            old_units = nil; old_units_by_id = nil;
          elseif iterations > 20 then
            destroyLevel("infloop")
          else
            cutscene_tick:delay(function() pastMove(i+count+1, math.min(#all_moves - i+count, moves_per_tick - 1)) end, delay)
          end 
        end
        cutscene_tick:delay(function() pastMove(1, math.min(#all_moves - 1, moves_per_tick - 1)) end, delay)
      else
        --[[local past_buffer = undo_buffer
        scene.resetStuff(true)
        current_move = 0
        undo_buffer = {}]]
        while change_past and not destroy_level do
          change_past = false
          local past_buffer = undo_buffer
          scene.resetStuff(true)
          current_move = 0
          undo_buffer = {}
          for i,past_move in ipairs(all_moves) do
            do_past_effects = i <= 10 or #all_moves - i < 10
            if i == #all_moves then
              should_parse_rules = true
            end
            doOneMove(past_move[1], past_move[2], past_move[3], true)
            if change_past then break end
            if love.timer.getTime() - start_time > 10 then
              destroy_level = true
              break
            end
          end
          undo_buffer = past_buffer
        end
        if destroy_level then
          destroyLevel("infloop")
        else
          --[[for i,past_move in ipairs(all_moves) do
            do_past_effects = i <= 10 or #all_moves - i < 10
            if i == #all_moves then
              should_parse_rules = true
            end
            doOneMove(past_move[1], past_move[2], past_move[3], true)
          end]]
          should_parse_rules = true
          doing_past_turns = false
          past_playback = false
          past_rules = {}
          
          for result, payload in pairs(past_queued_wins) do
            doWin(result, payload)
          end
          
          --undo_buffer = past_buffer
          createUndoBasedOnUnitsChanges(old_units, old_units_by_id, units, units_by_id)
          old_units = nil; old_units_by_id = nil;
          for k,v in pairs(tweens) do
            v[1]:set(v[1].duration)
          end
        end
      end
    end, 0.25)
  end
end

--have a probability to produce particles if there are more than 50 emitters, so that performance degradation is capped.
function particlesRngCheck()
  if #particles < 50 then return true end
  return math.random() < math.pow(0.5, (#particles-50)/50)
end

function scene.mouseReleased(x, y, button)
  local height, width = love.graphics.getHeight(), love.graphics.getWidth()
  local box = sprites["ui/32x32"]:getWidth()
  
  if button == 1 then
    -- DRAGBL release
    if units_by_name["text_dragbl"] then
      local dragged = false
      for _,unit in ipairs(drag_units) do
        local dest_x, dest_y = math.floor(unit.draw.x + 0.5), math.floor(unit.draw.y + 0.5)
        local stuff = getUnitsOnTile(dest_x,dest_y)
        local nodrag = false
        for _,other in ipairs(stuff) do
          if hasProperty(other,"no drag") then
            nodrag = true
            break
          end
        end
        if not nodrag then
          if not dragged then
            newUndo()
          end
          addUndo{"update",unit.id,unit.x,unit.y,unit.dir}
          moveUnit(unit,dest_x,dest_y)
          dragged = true
        end
        addTween(tween.new(0.1, unit.draw, {x = unit.x, y = unit.y}), "dragbl release:"..tostring(unit))
      end
      if dragged then
        doOneMove(last_click_x,last_click_y,"drag")
        last_click_x, last_click_y = nil, nil
      end
      drag_units = {}
    end
    -- CLIKT prefix
    if units_by_name["text_clikt"] then
      last_click_x, last_click_y = screenToGameTile(love.mouse.getX(), love.mouse.getY())
      doOneMove(last_click_x,last_click_y,"clikt")
      last_click_x, last_click_y = nil, nil
      playSound("clicc")
    end
    -- Replay buttons
    if replay_playback then
      if pointInside(x, y, width - box*3, 0, box, box) then
        replay_pause = not replay_pause
      end
      if not replay_pause then
        if pointInside(x, y, width - box*4, 0, box, box) then
          replay_playback_interval = replay_playback_interval / 0.8
        elseif pointInside(x, y, width - box*2, 0, box, box) then
          replay_playback_interval = replay_playback_interval * 0.8
        end
      elseif replay_pause then
        if pointInside(x, y, width - box*4, 0, box, box) then
          if replay_playback_turn > 1 then
            replay_playback_turn = replay_playback_turn - 1
            doOneMove(0,0,"undo")
          end
        elseif pointInside(x, y, width - box*2, 0, box, box) then
          doReplayTurn(replay_playback_turn)
          replay_playback_turn = replay_playback_turn + 1
        end
      end
      if pointInside(x, y, width - box, 0, box, box) then
        replay_playback = false
      end
    end
  elseif button == 2 then
    -- Stacks preview
    scene.setStackBox(screenToGameTile(x, y))
  end

  if pause then
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    local buttonwidth, buttonheight = sprites["ui/button_1"]:getDimensions()

    local mousex, mousey = love.mouse.getPosition()

    --[[for i=1, #buttons do
      local buttony = buttonheight*4+(buttonheight+10)*(i-2)
      if mouseOverBox(width/2-sprites["ui/button_1"]:getWidth()/2, buttony, buttonwidth, buttonheight) then
        if button == 1 then
          handlePauseButtonPressed(i)
        end
      end
    end]]
  end
end

function handlePauseButtonPressed(i)
  if buttons[i] == "exit" then
    escResult(true)
  elseif buttons[i] == "resume" then
    pause = false
  elseif buttons[i] == "editor" then
    new_scene = editor
    load_mode = "edit"
  elseif buttons[i] == "restart" then
    pause = false
    scene.resetStuff()
  end
end

function scene.resize(w, h)
  scene.buildUI()
end

function scene.mousePressed(x, y, button)
  if not rules_with["dragbl"] then return end
  
  if button == 1 then
    local tx,ty = screenToGameTile(x,y)
    local stuff = getUnitsOnTile(tx,ty)
    for _,unit in ipairs(stuff) do
      if hasProperty(unit,"dragbl") then
        table.insert(drag_units, unit)
      end
    end
  end
end

function scene.setStackBox(x, y)
  local units = getUnitsOnTile(x, y)
  for _,unit in ipairs(units) do
    if unit.name ~= "no1" then
      if stack_box.scale == 0 then
        stack_box.enabled = true
        stack_box.units = units
        stack_box.x, stack_box.y = unit.x, unit.y
        addTween(tween.new(0.1, stack_box, {scale = 1}), "stack box")
      elseif stack_box.x ~= unit.x or stack_box.y ~= unit.y then
        addTween(tween.new(0.05, stack_box, {scale = 0}), "stack box", function()
          stack_box.enabled = true
          stack_box.units = units
          stack_box.x, stack_box.y = unit.x, unit.y
          addTween(tween.new(0.1, stack_box, {scale = 1}), "stack box")
        end)
      else
        stack_box.enabled = false
        addTween(tween.new(0.1, stack_box, {scale = 0}), "stack box")
      end
      return
    end
  end
  if stack_box.enabled then
    stack_box.enabled = false
    addTween(tween.new(0.1, stack_box, {scale = 0}), "stack box")
  end
end

function scene.setPathlockBox(unit)
  if unit then
    if pathlock_box.scale == 0 then
      pathlock_box.enabled = true
      pathlock_box.unit = unit
      pathlock_box.x, pathlock_box.y = unit.x, unit.y
      addTween(tween.new(0.1, pathlock_box, {scale = 1}), "pathlock box")
    elseif pathlock_box.x ~= unit.x or pathlock_box.y ~= unit.y then
      addTween(tween.new(0.05, pathlock_box, {scale = 0}), "pathlock box", function()
        pathlock_box.enabled = true
        pathlock_box.unit = unit
        pathlock_box.x, pathlock_box.y = unit.x, unit.y
        addTween(tween.new(0.1, pathlock_box, {scale = 1}), "pathlock box")
      end)
    end
    return
  end
  if pathlock_box.enabled then
    pathlock_box.enabled = false
    addTween(tween.new(0.1, pathlock_box, {scale = 0}), "pathlock box")
  end
end

function doDragbl()
  if drag_units and #drag_units > 0 then
    local mx, my = screenToGameTile(mouse_X, mouse_Y, true)
    mx, my = mx - 0.5, my - 0.5
    local tx, ty = screenToGameTile(mouse_X, mouse_Y, false)
    for _,unit in ipairs(drag_units) do
      local oldx, oldy = math.floor(unit.draw.x), math.floor(unit.draw.y)
      local dirx, diry = sign(mx - unit.draw.x), sign(my - unit.draw.y)
      
      if  canMove(unit,dirx,0,0,nil,nil,nil,"drag",nil,math.floor(unit.draw.x),math.floor(unit.draw.y))
      and canMove(unit,dirx,0,0,nil,nil,nil,"drag",nil,math.floor(unit.draw.x),math.ceil( unit.draw.y)) then
        local diff = mx - unit.draw.x
        if diff < -0.25 then diff = -0.25 end
        if diff > 0.25 then diff = 0.25 end
        unit.draw.x = unit.draw.x + diff
      else
        if mx * dirx < oldx * dirx then
          unit.draw.x = mx
        else
          unit.draw.x = oldx
        end
      end
      if  canMove(unit,0,diry,0,nil,nil,nil,"drag",nil,math.floor(unit.draw.x),math.floor(unit.draw.y))
      and canMove(unit,0,diry,0,nil,nil,nil,"drag",nil,math.ceil( unit.draw.x),math.floor(unit.draw.y)) then
        local diff = my - unit.draw.y
        if diff < -0.25 then diff = -0.25 end
        if diff > 0.25 then diff = 0.25 end
        unit.draw.y = unit.draw.y + diff
      else
        if my * diry < oldy * diry then
          unit.draw.y = my
        else
          unit.draw.y = oldy
        end
      end
    end
  end
end

return scene
