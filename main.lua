json = require "lib/json"
suit = require "lib/suit"
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

local libstatus, liberr = pcall(function() discordRPC = require "lib/discordRPC" end)

if libstatus then
  discordRPC = require "lib/discordRPC"
else
  print("WARNING: failed to require discordrpc: "..liberr)
end

function love.load()
  sprites = {}
  move_sound_data = nil
  move_sound_source = nil

  empty_sprite = love.image.newImageData(32, 32)
  empty_cursor = love.mouse.newCursor(empty_sprite)

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
  system_cursor = sprites["ui/mous"]
  --if love.system.getOS() == "OS X" then
    --system_cursor = sprites["ui/mous_osx"]
  --end
  
  registerSound("move")
  registerSound("break")
  registerSound("unlock")
  registerSound("sink")
  registerSound("rule")
  registerSound("win")

  scene = menu
  scene.load()

  if discordRPC and discordRPC ~= true then
    discordRPC.initialize("579475239646396436", true) -- app belongs to thefox, contact him if you wish to make any changes
  end
end

function love.keypressed(key,scancode,isrepeat)
  if key == "f1" and scene == editor then
    scene = game
    scene.load()
  elseif key == "f2" and scene == game then
    scene = editor
    scene.load()
  elseif key == "escape" then
    if scene == loadscene then
      scene = editor
      scene.load()
    elseif scene ~= menu then
      scene = menu
      scene.load()
    end
  elseif key == "g" and love.keyboard.isDown('f3') and scene ~= editor then
    rainbowmode = not rainbowmode
  elseif key == "f4" then
    debug = not debug
  end

  if scene and scene.keyPressed then
    scene.keyPressed(key)
  end

  suit.keypressed(key)
end

function love.keyreleased(key)
  if scene and scene.keyReleased then
    scene.keyReleased(key)
  end
end

function love.textinput(text)
  if scene and scene.textInput then
    scene.textInput(text)
  end
  
  suit.textinput(text)
end

function love.mousepressed(x, y, button)
  if scene == menu and button == 1 then
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    local buttonheight = height*0.05
    local buttonwidth = width*0.375
    if mouseOverBox(width/2-buttonwidth/2, height/2-buttonheight/2+buttonheight+10, buttonwidth, buttonheight) then
      scene = game
      scene.load()
    end
    if mouseOverBox(width/2-buttonwidth/2, height/2-buttonheight/2+(buttonheight+10)*2, buttonwidth, buttonheight) then
      scene = editor
      scene.load()
    end
  end

  if scene and scene.mousepressed then
    scene.mousepressed(x, y, button)
  end
end

function love.update(dt)
  if scene and scene.update then
    scene.update(dt)
  end

  if new_scene then
    scene = new_scene
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

  love.graphics.setFont(default_font)

  if scene and scene.draw then
    scene.draw(dt)
  end

  suit.draw()

  if debug then
    love.graphics.setColor(1, 1, 1, 0.9)
    if rainbowmode then
      love.graphics.setColor(hslToRgb(love.timer.getTime()/3%1, .5, .5, .9))
    end
    mousex, mousey = love.mouse.getPosition()
    local debugtext = '~~ !! DEBUG MENU !! ~~'..'\n'..
    'window height: '..love.graphics.getHeight()..'\n'..
    'window width: '..love.graphics.getWidth()..'\n'..
    'mouse: x'..mousex..' y'..mousey..'\n'..
    'press R to restart\n'..
    'press S to save level to clipboard (editor)\n' ..
    'press L to load level from clipboard (editor)\n' ..
    'F4 to toggle debug menu\n'..
    'F3+G to toggle rainbowmode\n'..
    'F2 for editor mode\n'..
    'F1 for game mode'
    for key, value in pairs(debug_values) do
      debugtext = debugtext..'\n'..
      key..': '..value
    end
    love.graphics.print(debugtext)
  end
end

function love.quit()
  if discordRPC and discordRPC ~= true then
    discordRPC.shutdown()
  end
end