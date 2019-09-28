ui = {}

ui.component = require 'ui/component'
ui.text_input = require 'ui/textinput'
ui.level_button = require 'ui/levelbutton'
ui.world_button = require 'ui/worldbutton'
ui.menu_button = require 'ui/menubutton'

ui.overlay = require 'ui/overlay'

ui.fonts = {}
ui.mouse = {left = "up", right = "up"}
ui.hovered = nil
ui.new_hovered = nil
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
  -- TEST: this function should be unnecessary as things only take 1 frame to clear naturally

  --[[ui.hovered = nil
  ui.setEditing()]]
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
    return true
  elseif ui.overlay.open then
    if key == "escape" then
      ui.overlay.close()
    elseif key == "return" then
      ui.overlay.close(true)
    end
    return true
  end
  return false
end

function ui.textInput(text)
  if ui.editing then
    ui.editing:textInput(text)
    return true
  end
  return false
end

function ui.update()
  -- clear references to UI elements that did not exist last draw
  if ui.editing and ui.editing.frame ~= frame then
    ui.editing:setEditing(false)
    ui.editing = false
  end
  ui.hovered = ui.new_hovered
  ui.new_hovered = nil

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
