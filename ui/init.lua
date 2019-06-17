ui = {}

ui.component = require 'ui/component'


-- mouse control
ui.mouse = {left = "up", right = "up"}

function ui.update()
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