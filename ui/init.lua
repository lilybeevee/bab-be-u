ui = {}

ui.component = require 'ui/component'
ui.text_input = require 'ui/textinput'
ui.level_button = require 'ui/levelbutton'
ui.world_button = require 'ui/worldbutton'

ui.fonts = {}
ui.mouse = {left = "up", right = "up"}
ui.hovered = nil
ui.editing = nil

function ui.init()
  ui.fonts.default = love.graphics.newFont(12)
  ui.fonts.default:setFilter("nearest","nearest")
  ui.fonts.title = love.graphics.newFont(32)
  ui.fonts.category = love.graphics.newFont(24)
  ui.fonts.world_name = love.graphics.newFont(16)
  ui.fonts.world_name:setFilter("nearest","nearest")
end

function ui.clear()
  ui.hovered = nil
  ui.setEditing()
end

function ui.setEditing(o)
  if ui.editing == o then return end
  if ui.editing then
    ui.editing:setEditing(false)
    if ui.editing.on_return then
      ui.editing:on_return(ui.editing:getText())
    end
  end
  if o then
    ui.editing = o:setEditing(true)
  else
    ui.editing = nil
  end
end

function ui.keyPressed(key)
  if ui.editing then
    ui.editing:keyPressed(key)
  end
end

function ui.textInput(text)
  if ui.editing then
    ui.editing:textInput(text)
  end
end

function ui.update()
  -- clear references to UI elements that did not exist last draw
  if ui.editing and ui.editing.frame ~= frame then
    ui.setEditing()
  end
  if ui.hovered and ui.hovered.frame ~= frame then
    ui.hovered = nil
  end

  if love.mouse.isDown(1) then
    if ui.mouse.left == "up" or ui.mouse.left == "released" then
      ui.mouse.left = "pressed"
    else
      ui.mouse.left = "down"
    end
  else
    if ui.mouse.left == "down" or ui.mouse.left == "pressed" then
      ui.mouse.left = "released"
    else
      ui.mouse.left = "up"
    end
  end

  if love.mouse.isDown(2) then
    if ui.mouse.right == "up" or ui.mouse.right == "released" then
      ui.mouse.right = "pressed"
    else
      ui.mouse.right = "down"
    end
  else
    if ui.mouse.right == "down" or ui.mouse.right == "pressed" then
      ui.mouse.right = "released"
    else
      ui.mouse.right = "up"
    end
  end
end
