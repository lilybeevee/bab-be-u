local startload = love.timer.getTime()

serpent = require "serpent"
require "lib/gooi"
json = require "lib/json"
tick = require "lib/tick"
tween = require "lib/tween"
colr = require "lib/colr-print"
require "ui"
require "values"
require "utils"
require "audio"
require "game/unit"
require "game/movement"
require "game/parser"
require "game/rules"
require "game/undo"
require "game/cursor"
local utf8 = require("utf8")
 
local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end
game = require 'game/scene'
editor = require 'editor/scene'
loadscene = require 'editor/loadscene'
menu = require 'menu/scene'
presence = {}
frame = 0
cmdargs = {}

currentfps = 0
peakfps = 0
averagefps = 0
fps_captures = {}
averagefps = 0

special_no = 1

spookmode = false

local debugEnabled = false
local drawnDebugScreen = false

bxb = nil

function tableAverage(table)
  local sum = 0
  local ave = 0
  local elements = #table

  for i = 1, elements do
    sum = sum + table[i]
  end

  ave = sum / elements

  return ave
end

local debugDrawText                           -- read the line below
local headerfont = love.graphics.newFont(32)  -- used for debug
local regularfont = love.graphics.newFont(16) -- read the line above

function love.load(arg)
  local current_arg = nil
  for i,v in ipairs(arg) do
    if v:sub(1,2) == "--" then
      current_arg = v:sub(3)
      cmdargs[current_arg] = ""
    elseif current_arg then
      cmdargs[current_arg] = cmdargs[current_arg] .. (cmdargs[current_arg] ~= "" and " " or "") .. v
    end
  end
  if cmdargs["help"] then
    print([[
bab arguments!

--test <scene>      Starts the game with a test scene
--theme [<theme>]   Starts the game with the specified theme (or none)
--randomize         Randomizes the game's assets
--spook             ????
]])
    love.event.quit()
    return
  end
  for i,v in pairs(cmdargs) do
    print(colr.dim("arg set: " .. i .. "=" .. v))
  end


  local babfound = false

  function searchbab(d)
    local dir = "assets/sprites"
    if d then
      dir = dir .. "/" .. d
    end
    local files = love.filesystem.getDirectoryItems(dir)
    for _,file in ipairs(files) do
      if string.sub(file, -4) == ".png" then
        local spritename = string.sub(file, 1, -5)
        local sprite = love.graphics.newImage(dir .. "/" .. file)
        if d then
          spritename = d .. "/" .. spritename
        end
        if spritename == "bab" then
          babfound = true
        end
      elseif love.filesystem.getInfo(dir .. "/" .. file).type == "directory" then
        local newdir = file
        if d then
          newdir = d .. "/" .. newdir
        end
        searchbab(file)
      end
    end
  end

  searchbab()
  
  if not babfound or cmdargs["spook"] or os.date("%m-%d") == "10-31" and os.date("%H") >= "22" then
    spookmode = true
  end

  print(colr.bright([[


                                  BBBBBBBBBB
                                  BBBBBBBBBBBBB            BBBBBBBBBB
                                  BBBBBBBBBBBBB            BBBBBBBBBB
                                BBBBBBBBBBBBBBB          BBBBBBBBBBBB
                                BBBBBBBBBBBBBBB          BBBBBBBBBBBB
                                BBBBBBBBBBBBBBB       BBBBBBBBBBBBBBB
                                BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
                                BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
                      BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
                 BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        BBBBBBBBBB
                 BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        BBBBBBBBBB
              BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        BBBBBBBBBB
              BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        BBBBBBBBBB
            BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        BBBBBBBBBB
         BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        BBBBBBBBBBBBBBBBBBBBBB
         BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        BBBBBBBBBBBBBBBBBBBBBB
         BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        BBBBBBBBBBBBBBBBBBBBBB
         BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        BBBBBBBBBBBBBBBBBBBBBB
         BBBBBBBBBBBBBBBBBBBBBBBBBBBBBB        BBBBBBBBBBBBBBBBBBBBBB
         BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
         BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
         BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
         BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
         BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
              BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
            BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
            BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
            BBBBBBBBBB  BBBBBBBB               BBBBBBBBBBBBBBBBB
           BBBBBBBBBBB  BBBBBBBB               BBBBBBBBBBBBBBBBB
         BBBBBBBBBBBBB  BBBBBBBB               BBBBBBB   BBBBBBB
         BBBBBBBBBB     BBBBBBBBBB             BBBBBBB   BBBBBBBBBB
         BBBBBBBBBB     BBBBBBBBBB             BBBBBBB   BBBBBBBBBB
         BBBBBBBB       BBBBBBBBBB                       BBBBBBBBBB
         BBBBBBBB          BBBBBBBBBB                    BBBBBBBBBB
         BBBBBBBB          BBBBBBBBBB                    BBBBBBBBBB
         BBBBBBBB          BBBBBBBBBB                      BBBBBBBB
         BBBBBBBB          BBBBBBBBBB                      BBBBBBBB
         BBBBBBBB          BBBBBBBBBB                      BBBBBBBB

  ]])..colr.magenta([[
                                   ]])..(spookmode and "  help" or "BAB BE U")..
"\n                                      v. "..build_number..[[
                                     ]]..colr.red('❤')..' v. '..love.getVersion()..'\n\n')

  local libstatus, liberr = pcall(function() discordRPC = require "lib/discordRPC" end)
  if libstatus then
    discordRPC = require "lib/discordRPC"
    print(colr.green("✓ discord rpc added"))
  else
    print(colr.yellow("⚠ failed to require discordrpc: "..liberr))
  end

  sprites = {}
  palettes = {}
  tweens = {}
  ticks = {}
  move_sound_data = nil
  move_sound_source = nil
  anim_stage = 0
  next_anim = ANIM_TIMER
  fullscreen = settings["fullscreen"]
  winwidth, winheight = love.graphics.getDimensions( )

  if fullscreen and love.window then
    if not love.window.isMaximized( ) then
      winwidth, winheight = love.graphics.getDimensions( )
    end
    love.window.setMode(0, 0, {borderless=false})
    love.window.maximize( )
  end

  empty_sprite = love.image.newImageData(32, 32)
  if not is_mobile then
    empty_cursor = love.mouse.newCursor(empty_sprite)
    gooi.desktopMode()
  end

  default_font = love.graphics.newFont()
  game_time_start = love.timer.getTime()

  love.graphics.setDefaultFilter("nearest","nearest")

  print(colr.green("✓ startup values added\n"))

  local function addsprites(d)
    local dir = "assets/sprites"
    if d then
      dir = dir .. "/" .. d
    end
    local files = love.filesystem.getDirectoryItems(dir)
    for _,file in ipairs(files) do
      if string.sub(file, -4) == ".png" then
        local spritename = string.sub(file, 1, -5)
        local sprite = love.graphics.newImage(dir .. "/" .. file)
        if d then
          spritename = d .. "/" .. spritename
        end
        sprites[spritename] = sprite
        --print(colr.cyan("ℹ️ added sprite "..spritename))
      elseif love.filesystem.getInfo(dir .. "/" .. file).type == "directory" then
        print(colr.cyan("ℹ️ found sprite dir: " .. file))
        local newdir = file
        if d then
          newdir = d .. "/" .. newdir
        end
        addsprites(file)
      end
    end
  end
  addsprites()
  
  randomize_assets = false or cmdargs["randomize"]
  math.randomseed(love.timer.getTime())
  if randomize_assets then
    local names = {}
    local spr = {}
    for n,s in pairs(sprites) do
      if s:getWidth() < 64 and s:getHeight() < 64 then
        table.insert(names, n)
        table.insert(spr, s)
      end
    end
    for i = #spr, 2, -1 do -- https://gist.github.com/Uradamus/10323382
      local j = math.random(i)
      spr[i], spr[j] = spr[j], spr[i]
    end
    for i,n in ipairs(names) do
      sprites[n] = spr[i]
    end
  end
  
  sprites["letters_/"] = sprites["letters_slash"]
  sprites["letters_:"] = sprites["letters_colon"]

  print(colr.green("✓ added sprites\n"))

  local function addPalettes(d)
    local dir = "assets/palettes"
    if d then
      dir = dir .. "/" .. d
    end
    local files = love.filesystem.getDirectoryItems(dir)
    for _,file in ipairs(files) do
      if string.sub(file, -4) == ".png" then
        local palettename = string.sub(file, 1, -5)
        local data = love.image.newImageData(dir .. "/" .. file)
        local sprite = love.graphics.newImage(data)
        if d then
          palettename = d .. "/" .. palettename
        end
        local palette = {}
        palettes[palettename] = palette
        palette.sprite = sprite
        for x = 0, sprite:getWidth()-1 do
          for y = 0, sprite:getHeight()-1 do
            local r, g, b, a = data:getPixel(x, y)
            palette[x + y * sprite:getWidth()] = {r, g, b, a}
          end
        end
        --print(colr.cyan("ℹ added palette "..palettename))
      elseif love.filesystem.getInfo(dir .. "/" .. file).type == "directory" then
        print(colr.cyan("ℹ️ found palette dir: " .. file))
        local newdir = file
        if d then
          newdir = d .. "/" .. newdir
        end
        addPalettes(file)
      end
    end
  end
  addPalettes()
  current_palette = "default"

  print(colr.green("✓ added palettes\n"))

  sound_exists = {}
  local function addAudio(d)
    local dir = "assets/audio"
    if d then
      dir = dir .. "/" .. d
    end
    local files = love.filesystem.getDirectoryItems(dir)
    for _,file in ipairs(files) do
      if love.filesystem.getInfo(dir .. "/" .. file).type == "directory" then
        local newdir = file
        if d then
          newdir = d .. "/" .. newdir
        end
        addAudio(file)
      else
        local audioname = file
        if file:ends(".wav") then audioname = file:sub(1, -5) end
        if file:ends(".mp3") then audioname = file:sub(1, -5) end
        if file:ends(".ogg") then audioname = file:sub(1, -5) end
        if file:ends(".flac") then audioname = file:sub(1, -5) end
        if file:ends(".xm") then audioname = file:sub(1, -4) end
        --[[if d then
          audioname = d .. "/" .. audioname
        end]]
        sound_exists[audioname] = true
        --print("ℹ️ audio "..audioname.." added")
      end
    end
  end
  addAudio()
  print(colr.green("✓ audio added"))

  system_cursor = sprites["ui/mous"]
  --if love.system.getOS() == "OS X" then
    --system_cursor = sprites["ui/mous_osx"]
  --end

  registerSound("move", 0.4)
  registerSound("mous sele", 0.3)
  registerSound("mous hovvr", 0.3)
  registerSound("mous kicc", 0.3)
  registerSound("mous snar", 0.3)
  registerSound("mous hihet", 0.3)
  registerSound("mous crash", 0.3)
  -- there is a more efficient way, i know.

  -- WHY NOT DO IT THEN
  -- ugh ill do it for you
  for i=1, 10 do
    registerSound("mous special "..i, 0.3)
  end

  for i=1, 6 do
    registerSound("honk"..i, 1)
  end

  -- ty. much appreciated
  registerSound("break", 0.5)
  registerSound("unlock", 0.6)
  registerSound("sink", 0.5)
  registerSound("rule", 0.5)
  registerSound("win", 0.5)
  registerSound("infloop", 0.5)
  registerSound("snacc", 1.0)
  registerSound("hotte", 1.0)
  registerSound("undo", 0.8)
  registerSound("fail", 0.5)
  registerSound("bonus", 0.4)
  registerSound("timestop", 1)
  registerSound("timestop long", 1)
  registerSound("time resume", 1)
  registerSound("time resume long", 1)
  registerSound("za warudo", 1)
  registerSound("time resume dio", 1)
  registerSound("bup", 0.5)
  registerSound("clicc", 1)
  registerSound("unwin", 0.5)
  registerSound("stopwatch", 1.0)
  registerSound("babbolovania", 0.7)
  
  
  
  print(colr.green("✓ sounds registered"))

  ui.init()
  ui.overlay.rebuild()
  print(colr.green("✓ ui initialized"))

  if discordRPC and discordRPC ~= true and not cmdargs["no-rpc"] then
    discordRPC.initialize("579475239646396436", true) -- app belongs to thefox, contact him if you wish to make any changes
    print(colr.green("✓ discord rpc initialized"))
  end

  if not love.filesystem.getInfo("profiles") then
    love.filesystem.createDirectory("profiles")
    print(colr.green("✓ created profiles directory"))
  end

  if not love.filesystem.getInfo("profiles/" .. profile.name) then
    love.filesystem.createDirectory("profiles/" .. profile.name)
    print(colr.green("✓ created '"..profile.name.."' profile directory"))
  end

  if is_mobile then
    love.window.setMode(640, 360)
  end

  if spookmode then
    for i=1, 20 do
      print(colr.red("⚠ bab not found"))
    end
    --love.errorhandler = function() print(colr.red("goodbye")) end
    love.window.setFullscreen(true)
    love.window.setIcon(love.image.newImageData("assets/sprites/wat.png"))
    love.window.setTitle("bxb bx x")
    love.window.requestAttention()
  else
    print(colr.bright("\nboot complete!"))
  end

  if cmdargs["test"] then
    metaClear()
    clear()
    presence = {
      state = cmdargs["test"] .. " test",
      details = "testing cool new fechures",
      largeImageKey = "titlescreen",
      largeimageText = "main menu",
      startTimestamp = os.time(os.date("*t"))
    }
    nextPresenceUpdate = 0
    scene = require("test/" .. cmdargs["test"])
  else
    scene = menu
  end
  scene.load()

  print(colr.dim("load took ~"..(math.floor((love.timer.getTime()-startload)*1000)/1000).."ms"))
end

function love.keypressed(key,scancode,isrepeat)
  if scene ~= loadscene then
    gooi.keypressed(key, scancode)
  end

  if key == "f1" then
    if scene == editor then
      scene = game
      load_mode = "play"
      clearGooi()
      scene.load()
    end
  elseif key == "f2" then
    if scene == game then
      scene = editor
      load_mode = "edit"
      clearGooi()
      scene.load()
	end
  elseif key == "g" and love.keyboard.isDown('f3') then
    rainbowmode = not rainbowmode
  elseif key == "q" and love.keyboard.isDown('f3') then
    superduperdebugmode = not superduperdebugmode
  elseif key == "m" and love.keyboard.isDown('f3') then
    if not is_mobile then
      winwidth, winheight = love.graphics.getDimensions( )
      love.window.setMode(800, 480, {borderless=false, resizable=true, minwidth=705, minheight=510})
      is_mobile = true
    elseif is_mobile then
      love.window.setMode(winwidth, winheight, {borderless=false, resizable=true, minwidth=705, minheight=510})
      is_mobile = false
    end
  elseif key == "d" and love.keyboard.isDown('f3') then
    drumMode = not drumMode
  elseif key == "r" and love.keyboard.isDown('f3') then
    remasterMode = not remasterMode
  elseif key == "h" and love.keyboard.isDown('f3') then
    settings["infomode"] = not settings["infomode"]
    saveAll()
  elseif key == "l" and love.keyboard.isDown('f3') then
    debugEnabled = true
  elseif key == "i" and love.keyboard.isDown('f3') then
    displayids = not displayids
  elseif key == "f4" and not spookmode then
    debug_view = not debug_view
  elseif key == "f5" then
    love.event.quit("restart")
  elseif key == "f11" then
    fullScreen()
  elseif key == "o" and love.keyboard.isDown('lctrl') then
    if scene == menu then
      love.system.openURL("file:///"..love.filesystem.getSaveDirectory())
    elseif scene == loadscene then
      if world == "" then
        if love.filesystem.getInfo("levels") then
          love.system.openURL("file:///"..love.filesystem.getSaveDirectory().."/levels/")
        else
          love.system.openURL("file:///"..love.filesystem.getSaveDirectory())
        end
      else
        if world_parent ~= "officialworlds" then
          love.system.openURL("file:///"..love.filesystem.getSaveDirectory().."/"..getWorldDir(true).."/")
        else
          love.system.openURL("file:///"..love.filesystem.getSource().."/"..getWorldDir(true).."/")
        end
      end
    end
  end

  if not ui.keyPressed(key) and scene and scene.keyPressed then
    scene.keyPressed(key, isrepeat)
  end
end

function love.keyreleased(key, scancode)
  if scene ~= loadscene then
    gooi.keyreleased(key, scancode)
  end

  if not ui.keyReleased(key) and scene and scene.keyReleased then
    scene.keyReleased(key)
  end
end

function love.textinput(text)
  if scene == editor then
    gooi.textinput(text)
  end

  if not ui.textInput(text) and scene and scene.textInput then
    scene.textInput(text)
  end
end

function love.wheelmoved(whx, why)
  if scene and scene.wheelMoved then
    scene.wheelMoved(whx, why)
  end
end

--[[function love.touchpressed(id, x, y)
  love.mousepressed(x,y,1)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
  love.mousereleased(x,y,1)
end]]

function love.mousepressed(x, y, button)
  if scene ~= loadscene then
    gooi.pressed()
  end

  if is_mobile then
    love.mouse.setPosition(x, y)
  end

  if not ui.hovered and scene ~= editor then
    if drumMode then
      if button == 1 then playSound("mous kicc") end
      if button == 2 then playSound("mous snar") end
      if button == 3 then playSound("mous hihet") end
      if button == 4 then playSound("mous crash") end
      if button == 5 then
        playSound("mous special "..special_no)

        if special_no == 10 then
          special_no = 1
        else
          special_no = special_no + 1
        end

      end
  end
  end

  if scene and scene.mousePressed then
    scene.mousePressed(x, y, button)
  end
end

function love.mousereleased(x, y, button)
  if scene and scene.mouseReleased then
    scene.mouseReleased(x, y, button)
  end

  if scene == menu and button == 1 then
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    local buttonwidth, buttonheight = sprites["ui/button_1"]:getDimensions()
  end

  if scene ~= loadscene then
    gooi.released()
  end
end

function addTween(tween, name, fn)
  tweens[name] = {tween, fn}
end

function addTick(name, delay, fn)
  if ticks[name] then ticks[name]:stop() end
  local ret = tick.delay(fn, delay)
  ticks[name] = ret
  return ret
end

function switchScene(name)
  scene = loadscene
  load_mode = name
  if spookmode then
    load_mode = "game"
  end
  clearGooi()
  scene.load()
end

local gettimetime = 0

love.timer.getRealTime = love.timer.getTime
love.timer.getTime = function()
  if spookmode then
    return gettimetime
  else
    return love.timer.getRealTime()
  end
end

cutscene_tick = tick.group()

function love.update(dt)
  if spookmode then
    dt = math.tan(love.timer.getRealTime()*20)/200
  end

  if not (love.window.isVisible or love.window.hasFocus or love.window.hasMouseFoxus) and spookmode then
    love.window.requestAttention()
  end

  gettimetime = gettimetime + dt

  currentfps = love.timer.getFPS()

  table.insert(fps_captures, currentfps)

  averagefps = tableAverage(fps_captures)

  if currentfps > peakfps then
    peakfps = currentfps
  end

  if shake_dur > 0 then
    shake_dur = shake_dur-dt
  else
    shake_intensity = 0
    shake_dur = 0
  end
  if shake_intensity > 0.4 then
    shake_intensity = 0.4
  end
  
  if spookmode then
    shake_intensity = 0.02
    shake_dur = 1000
  end

  for k,v in pairs(tweens) do
    if v[1]:update(dt) then
      tweens[k] = nil
      if v[2] then v[2]() end
    end
  end

  ui.update()
  if scene ~= loadscene then
    gooi.update(dt)
  end
  tick.update(dt)
  if not pause then
    cutscene_tick:update(dt)
  end

  if scene and scene.update then
    scene.update(dt)
  end

  if new_scene then
    scene = new_scene
    clearGooi()
    scene.load()
    new_scene = nil
  end

  if not settings["music_on"] then music_volume = 0 end
  if settings["music_on"] then music_volume = 1 end
  updateMusic()
  
  if not settings["sfx_on"] then sfx_volume = 0 end
  if settings["sfx_on"] then sfx_volume = 1 end

  if debugEnabled and drawnDebugScreen then
    debug.debug()

    debugEnabled = false
    drawnDebugScreen = false
  end

  if discordRPC and discordRPC ~= true then
    if nextPresenceUpdate < love.timer.getTime() then
      discordRPC.updatePresence(presence)
      nextPresenceUpdate = love.timer.getTime() + 2.0
    end
    discordRPC.runCallbacks()
  end
end

function love.draw()
  local dt = love.timer.getDelta()
  frame = frame + 1

  next_anim = next_anim - (dt * 1000)
  if next_anim <= 0 then
    anim_stage = (anim_stage + 1) % 3
    next_anim = next_anim + ANIM_TIMER
  end

  love.graphics.setFont(default_font)

  if scene and scene.draw then
    scene.draw(dt)
  end

  ui.overlay.draw()

  if debug_view and not spookmode then
    local mousex, mousey = love.mouse.getPosition()

    local debugheader = "SUPER DEBUG MENU V2.1"
    local debugtext = 'bab be u commit numero '..build_number..'\n'..
    'current fps: '..love.timer.getFPS()..'\n'..
    'peak fps: '..peakfps..'\n'..
    'average fps: '..averagefps..'\n'..
    '\nF5 to restart LÖVE\n'..
    'F4 to toggle debug menu\n'..
    'F3+G to toggle rainbowmode\n'..
    'F3+Q for SUPER DUPER DEBUG MODE (wip)\n'..
     'F3+L for CONSOLE DEBUGGER\n'..
	'F3+M to toggle mobile\n'..
    'F3+H to toggle additional tile info\n'..
    'F3+D for MOUS DRUM KIT MODE\n'..
    'F3+R for REMASTER MODE\n'..
    'F2 for editor mode\n'..
    'F1 for game mode\n'

    if superduperdebugmode then
      local stats = love.graphics.getStats()
      local name, version, vendor, device = love.graphics.getRendererInfo()
      local processorCount = love.system.getProcessorCount()

      debug_values["estimated amount of texture memory used"] = string.format("%.2f MB", stats.texturememory / 1024 / 1024)
      debug_values["renderer info"] = name..' v'..version..' by '..vendor..' using'..device
    else
      debug_values["estimated amount of texture memory used"], debug_values["renderer info"] = nil
    end

    for key, value in pairs(debug_values) do
      if value ~= nil then
        debugtext = debugtext..'\n'..
        key..': '..value
      end
    end

    if debugtext ~= olddebugtext or not debugDrawText then
      debugDrawText = {love.graphics.newText(regularfont, debugtext), love.graphics.newText(headerfont, debugheader)}
    end
    local debugmenuw, debugmenuh = debugDrawText[1]:getDimensions()
    if debugmenuw < debugDrawText[2]:getWidth() then debugmenuw = debugDrawText[2]:getWidth() end

    -- print the background
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, debugmenuw, debugmenuh+headerfont:getHeight())

    -- print the header and its shadow
    love.graphics.setFont(headerfont)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(debugheader, 1, 1)
    love.graphics.setColor(hslToRgb(love.timer.getTime()/3%1, .5, .5, .9))
    love.graphics.print(debugheader, 0, 0)

    --print the actual debug text and its shadow
    love.graphics.setFont(regularfont)

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(debugtext, 1, 1+headerfont:getHeight(), love.graphics.getWidth())
    love.graphics.setColor(1, 1, 1, 0.9)
    setRainbowModeColor(love.timer.getTime()/3)
    love.graphics.printf(debugtext, 0, 0+headerfont:getHeight(), love.graphics.getWidth())

    olddebugtext = debugtext
  end

  if superduperdebugmode and not spookmode then
    love.graphics.setColor(1,1,0, 0.7)
    love.graphics.line(love.mouse.getX()-love.mouse.getY(), 0, love.mouse.getX()+(love.graphics.getHeight()-love.mouse.getY()), love.graphics.getHeight())
    love.graphics.line(love.mouse.getX()+love.mouse.getY(), 0, love.mouse.getX()-(love.graphics.getHeight()-love.mouse.getY()), love.graphics.getHeight())

    love.graphics.setColor(1,0,0, 0.7)
    love.graphics.line(love.mouse.getX(), 0, love.mouse.getX(), love.graphics.getHeight())
    love.graphics.setColor(0,1,0, 0.7)
    love.graphics.line(0, love.mouse.getY(), love.graphics.getWidth(), love.mouse.getY())


    local formula =  "love.graphics.getWidth()-love.graphics.getWidth()/"..math.floor(love.graphics.getWidth()/love.mouse.getX()*100)/100
    local formula2 = "love.graphics.getHeight()-love.graphics.getHeight()/"..math.floor(love.graphics.getHeight()/love.mouse.getY()*100)/100

    local function drawmousething(x, y)
      love.graphics.printf('x'..love.mouse.getX()..'\ny'..love.mouse.getY()..'\n'..formula..'\n'..formula2, love.mouse.getX()+10+x, love.mouse.getY()+10+y, love.graphics.getWidth()-love.mouse.getX())
    end

    love.graphics.setFont(regularfont)

    love.graphics.setColor(0,0,0)
    drawmousething(1, 1)
    love.graphics.setColor(0,0,1)
    drawmousething(0, 0)
  end

  if spookmode and math.random(1000) == 500 then
    local bab = love.graphics.newImage("assets/sprites/ui/bxb bx x.jpg")
    love.graphics.draw(bab, 0, 0, 0, bab:getWidth()/love.graphics.getWidth(), bab:getHeight()/love.graphics.getHeight())
  end

  if debugEnabled then
    love.graphics.setColor(0.2,0.2,0.2,0.7)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1,1,1)
    love.graphics.printf("IN DEBUG - check console, use cont to exit", 0, love.graphics.getHeight()/2-love.graphics.getFont():getLineHeight(), love.graphics.getWidth(), 'center')
    drawnDebugScreen = true
  end

  ui.postDraw()
end

function love.visible()
  if spookmode then
    love.resize()
  end
end

function love.resize(w, h)
  if scene and scene.resize then
    scene.resize(w, h)
  end
  ui.overlay.rebuild()
  if spookmode then
    love.window.setFullscreen(true)
  end
end

function love.mousemoved(x, y, dx, dy)
  ui.lock_hovered = false
  if scene and scene.mouseMoved then
    scene.mouseMoved(x, y, dx, dy)
  end
end

function love.errorhandler(msg)
	msg = tostring(msg)
 
	error_printer(msg, 2)
 
	if not love.window or not love.graphics or not love.event then
		return
	end
 
	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end
 
	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
 
	love.graphics.reset()
	local font = love.graphics.setNewFont(14)
 
	love.graphics.setColor(1, 1, 1, 1)
 
	local trace = debug.traceback()
 
	love.graphics.origin()
 
	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)
 
	local err = {}
 
	table.insert(err, "uh ohhh!!! error!!\n")
	table.insert(err, sanitizedmsg)
 
	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end
 
	table.insert(err, "\n")
 
	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "here's what happnd:\n")
			table.insert(err, l)
		end
	end
 
  local p = table.concat(err, "\n")
  local popupactive = 0
 
	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")
 
  local function draw()
    if drawnDebugScreen then
      debugDrawText = false
      drawnDebugScreen = false
      debug.debug()
    end

		local pos = 70
    love.graphics.clear(23/255, 49/255, 84/255)
    love.graphics.setColor(1,1,1)
    love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
    if sprites["bab"] then
      local bab = sprites["bab"]
      local xoff = math.random(-2,2)
      local yoff = math.random(-2,2)

      love.graphics.push()
      love.graphics.translate(love.graphics.getWidth()-10-bab:getWidth(), love.graphics.getHeight()-10-bab:getHeight())
      love.graphics.rotate(love.timer.getTime())

      -- oh boy
      love.graphics.setColor(0,0,0)
      love.graphics.draw(bab, -bab:getWidth()/2+xoff-1, -bab:getHeight()/2+yoff)
      love.graphics.draw(bab, -bab:getWidth()/2+xoff-1, -bab:getHeight()/2+yoff-1)
      love.graphics.draw(bab, -bab:getWidth()/2+xoff, -bab:getHeight()/2+yoff-1)
      love.graphics.draw(bab, -bab:getWidth()/2+xoff+1, -bab:getHeight()/2+yoff)
      love.graphics.draw(bab, -bab:getWidth()/2+xoff+1, -bab:getHeight()/2+yoff+1)
      love.graphics.draw(bab, -bab:getWidth()/2+xoff, -bab:getHeight()/2+yoff+1)
      love.graphics.draw(bab, -bab:getWidth()/2+xoff-1, -bab:getHeight()/2+yoff+1)
      love.graphics.draw(bab, -bab:getWidth()/2+xoff+1, -bab:getHeight()/2+yoff-1)

      love.graphics.setColor(1,1,1)
      love.graphics.draw(bab, -bab:getWidth()/2+xoff, -bab:getHeight()/2+yoff)
      
      love.graphics.pop()

      love.graphics.print('u don goofed', love.graphics.getWidth()-10-bab:getWidth()*2-love.graphics.newText(love.graphics.getFont(), 'u don goofed'):getWidth(), love.graphics.getHeight()-10-bab:getHeight()*1.25)
    end
    if popupactive > 0 then
      popupactive = popupactive - 1
      love.graphics.setColor(1,1,1,popupactive/160)
      love.graphics.printf("okeys!!! the bab express will deliver dis to ur clipboard nowe!", 0, 0, love.graphics.getWidth(), 'right')
    end
    if debugDrawText then
      drawnDebugScreen = true
      love.graphics.setColor(1,1,1)
      love.graphics.rectangle('line',0,0,love.graphics.getWidth(),love.graphics.getHeight())
      love.graphics.setColor(0.5,0.5,0.5,0.5)
      love.graphics.rectangle('fill',0,0,love.graphics.getWidth(),love.graphics.getHeight())
      love.graphics.setColor(1,1,1)
      love.graphics.printf('debug mode active, use cont to exit', 0, love.graphics.getHeight()/2, love.graphics.getWidth(), 'center')
    end
		love.graphics.present()
	end
 
	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
    popupactive = 190
		draw()
	end
 
	if love.system then
		p = p .. "\n\nif u wanna copey dis ctrl+c or ta!p!!! and f5 to open debug mode"
	end
 
	return function()
		love.event.pump()
 
		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
        copyToClipboard()
      elseif e == "keypressed" and a == "f5" then
        debugDrawText = true
      elseif e == "touchpressed" then
        local name = love.window.getTitle()
        if #name == 0 or name == "Untitled" then name = "Game" end
        local buttons = {"okeys...", "nono i wanna see speen bab"}
        if love.system then
          buttons[3] = "copey it"
        end
        local pressed = love.window.showMessageBox("bab crashd!!! quit "..name.."?", "", buttons)
        if pressed == 1 then
          return 1
        elseif pressed == 3 then
          copyToClipboard()
        end
			end
		end
    draw()
 
		if love.timer then
			love.timer.sleep(0.01)
		end
	end
 
end

function love.quit()
  if discordRPC and discordRPC ~= true then
    discordRPC.shutdown()
  end
end
