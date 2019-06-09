require "lib/gooi"
json = require "lib/json"
tick = require "lib/tick"
tween = require "lib/tween"
require "values"
require "utils"
require "audio"
require "game/unit"
require "game/movement"
require "game/parser"
require "game/rules"
require "game/undo"
require "game/cursor"
game = require 'game/scene'
editor = require 'editor/scene'
loadscene = require 'editor/loadscene'
menu = require 'menu/scene'
presence = {}

local frame = 0

local debugDrawText                           -- read the line below
local headerfont = love.graphics.newFont(32)  -- used for debug
local regularfont = love.graphics.newFont(16) -- read the line above

local libstatus, liberr = pcall(function() discordRPC = require "lib/discordRPC" end)

if libstatus then
  discordRPC = require "lib/discordRPC"
else
  print("WARNING: failed to require discordrpc: "..liberr)
end

function love.load()
  local startload = love.timer.getTime()

  sprites = {}
  palettes = {}
  tweens = {}
  ticks = {}
  move_sound_data = nil
  move_sound_source = nil
  anim_stage = 0
  next_anim = ANIM_TIMER

  empty_sprite = love.image.newImageData(32, 32)
  if not is_mobile then
    empty_cursor = love.mouse.newCursor(empty_sprite)
    gooi.desktopMode()
  end

  default_font = love.graphics.newFont()
  game_time_start = love.timer.getTime()

  love.graphics.setDefaultFilter("nearest","nearest")

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
      elseif love.filesystem.getInfo(dir .. "/" .. file).type == "directory" then
        print("found sprite dir: " .. file)
        local newdir = file
        if d then
          newdir = d .. "/" .. newdir
        end
        addsprites(file)
      end
    end
  end
  addsprites()

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
      elseif love.filesystem.getInfo(dir .. "/" .. file).type == "directory" then
        print("found sprite dir: " .. file)
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
        if file:ends(".xm") then audioname = file:sub(1, -4) end
        if d then
          audioname = d .. "/" .. audioname
        end
        sound_exists[audioname] = true
      end
    end
  end
  addAudio()

  system_cursor = sprites["ui/mous"]
  --if love.system.getOS() == "OS X" then
    --system_cursor = sprites["ui/mous_osx"]
  --end
  
  registerSound("move", 0.4)
  registerSound("break", 0.5)
  registerSound("unlock", 0.6)
  registerSound("sink", 0.5)
  registerSound("rule", 0.5)
  registerSound("win", 0.5)

  print([[

  
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
  ]])
  print([[
                                   BAB BE U
                                    v. ]]..build_number..[[
                                   ❤ v. ]]..love.getVersion()..'\n\n')

  scene = menu
  scene.load()

  if discordRPC and discordRPC ~= true then
    discordRPC.initialize("579475239646396436", true) -- app belongs to thefox, contact him if you wish to make any changes
  end

  print("load took "..love.timer.getTime()-startload.."ms")
end

function love.keypressed(key,scancode,isrepeat)
  if scene ~= loadscene then
    gooi.keypressed(key, scancode)
  end

  if key == "f1" then--and scene == editor then
    scene = game
    load_mode = "play"
    clearGooi()
    scene.load()
  elseif key == "f2" and scene == game then
    scene = editor
    load_mode = "edit"
    clearGooi()
    scene.load()
  elseif key == "g" and love.keyboard.isDown('f3') then
    rainbowmode = not rainbowmode
  elseif key == "f4" then
    debug = not debug
  elseif key == "f5" then
    love.event.quit("restart")
  elseif key == "f" and love.keyboard.isDown('lctrl') then
    if scene == menu then
      love.system.openURL("file://"..love.filesystem.getSaveDirectory())
    elseif world == "" then
      if love.filesystem.getInfo("levels") then
        love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/levels/")
      else
        love.system.openURL("file://"..love.filesystem.getSaveDirectory())
      end
    else
      if world_parent ~= "officialworlds" then
        love.system.openURL("file://"..love.filesystem.getSaveDirectory().."/"..world_parent.."/"..world.."/")
      else
        love.system.openURL("file://"..love.filesystem.getSource().."/"..world_parent.."/"..world.."/")
      end
    end
  end

  if scene and scene.keyPressed then
    scene.keyPressed(key, isrepeat)
  end
end

function love.keyreleased(key, scancode)
  if scene ~= loadscene then
    gooi.keyreleased(key, scancode)
  end

  if scene and scene.keyReleased then
    scene.keyReleased(key)
  end
end

function love.textinput(text)
  if scene ~= loadscene then
    gooi.textinput(text)
  end

  if scene and scene.textInput then
    scene.textInput(text)
  end
end

function love.wheelmoved(whx, why)
  if scene and scene.wheelMoved then
    scene.wheelMoved(whx, why)
  end
end

function love.touchpressed(id, x, y)
  love.mousepressed(x,y,1)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
  love.mousereleased(x,y,1)
end

function love.mousepressed(x, y, button)
  if scene ~= loadscene then
    gooi.pressed()
  end

  if is_mobile then
    love.mouse.setPosition(x, y)
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

    local buttonheight = height*0.05
    local buttonwidth = width*0.375
    if mouseOverBox(width/2-buttonwidth/2, height/2-buttonheight/2+buttonheight+10, buttonwidth, buttonheight) then
      scene = loadscene
      load_mode = "play"
      clearGooi()
      scene.load()
    end
    if mouseOverBox(width/2-buttonwidth/2, height/2-buttonheight/2+(buttonheight+10)*2, buttonwidth, buttonheight) then
      scene = loadscene
      load_mode = "edit"
      clearGooi()
      scene.load()
    end
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

function love.update(dt)
  for k,v in pairs(tweens) do
    if v[1]:update(dt) then
      tweens[k] = nil
      if v[2] then v[2]() end
    end
  end

  if scene ~= loadscene then
    gooi.update(dt)
  end
  tick.update(dt)

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

  if debug then
    local mousex, mousey = love.mouse.getPosition()

    local debugheader = "SUPER DEBUG MENU V2.0"
    local debugtext = 'bab be u commit n'..build_number..'\n'..
    'fps: '..love.timer.getFPS()..'\n'..
    '\npress R to restart\n'..
    'F4 to toggle debug menu\n'..
    'F3+G to toggle rainbowmode\n'..
    'F2 for editor mode\n'..
    'F1 for game mode\n'

    for key, value in pairs(debug_values) do
      debugtext = debugtext..'\n'..
      key..': '..value
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
    love.graphics.printf(debugtext, 1, 1+headerfont:getHeight(), love.graphics.getWidth()-love.graphics.getWidth()/4)
    love.graphics.setColor(1, 1, 1, 0.9)
    setRainbowModeColor(love.timer.getTime()/3)
    love.graphics.printf(debugtext, 0, 0+headerfont:getHeight(), love.graphics.getWidth()-love.graphics.getWidth()/4)

    olddebugtext = debugtext
  end
end

function love.resize(w, h)
  if scene and scene.resize then
    scene.resize(w, h)
  end
end

function love.quit()
  if discordRPC and discordRPC ~= true then
    discordRPC.shutdown()
  end
end