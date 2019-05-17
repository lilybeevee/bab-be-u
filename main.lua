require "values"
require "utils"
require "input"
require "audio"
require "game/unit"
require "game/movement"
require "game/rules"
require "game/undo"
game = require 'game/scene'
editor = require 'editor/scene'

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
  registerSound("move")
  registerSound("break")
  registerSound("unlock")
  registerSound("sink")
  registerSound("rule")
  registerSound("win")

  scene = game
  scene.load()
end

function love.keypressed(key,scancode,isrepeat)
  if key == "f1" and scene ~= game then
    scene = game
    scene.load()
  elseif key == "f2" and scene ~= editor then
    scene = editor
    scene.load()
  elseif key == "g" and love.keyboard.isDown('f3') and scene ~= editor then
    rainbowmode = not rainbowmode
    print(rainbowmode)
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

function love.update(dt)
  if scene and scene.update then
    scene.update(dt)
  end

  updateMusic()
end

function love.draw()
  local dt = love.timer.getDelta()

  if scene and scene.draw then
    scene.draw(dt)
  end
end