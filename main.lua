require "values"
require "utils"
require "audio"
require "game/unit"
require "game/movement"
require "game/rules"
require "game/undo"
require "game/cursor"
game = require 'game/scene'
editor = require 'editor/scene'
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

  local files = love.filesystem.getDirectoryItems("assets/sprites")
  for _,file in ipairs(files) do
    if string.sub(file, -4) == ".png" then
      local spritename = string.sub(file, 1, -5)
      local sprite = love.graphics.newImage("assets/sprites/" .. file)
      sprites[spritename] = sprite
    end
  end
  system_cursor = sprites["mous"]
  --if love.system.getOS() == "OS X" then
    --system_cursor = sprites["mous_osx"]
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
  elseif key == "escape" and scene ~= menu then
    scene = menu
    scene.load()
  elseif key == "g" and love.keyboard.isDown('f3') and scene ~= editor then
    rainbowmode = not rainbowmode
  elseif key == "f4" then
    debug = not debug
  end

  if scene and scene.keyPressed then
    scene.keyPressed(key)
  end
end

function love.keyreleased(key)
  if scene and scene.keyReleased then
    scene.keyReleased(key)
  end
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

  if scene and scene.draw then
    scene.draw(dt)
  end
  if debug then
    love.graphics.setColor(1, 1, 1, 0.9)
    if rainbowmode then
      love.graphics.setColor(hslToRgb(love.timer.getTime()/3%1, .5, .5, .9))
    end
    mousex, mousey = love.mouse.getPosition()
    love.graphics.print('~~ !! DEBUG MENU !! ~~'..'\n'..
        'window height: '..love.graphics.getHeight()..'\n'..
        'window width: '..love.graphics.getWidth()..'\n'..
        'mouse : x'..mousex..' y'..mousey..'\n'..
        'press r to restart\n'..
        'f4 to toggle debug menu\n'..
        'f3+g to toggle rainbowmode\n'..
        'f2 for editor mode\n'..
        'f1 for game mode')
  end
end

function love.quit()
  if discordRPC and discordRPC ~= true then
    discordRPC.shutdown()
  end
end