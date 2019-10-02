local scene = {}

local components = {}

function scene.load()
  scene.buildUI()
  scene.selecting = true
  love.keyboard.setKeyRepeat(true)
end

function scene.buildUI()
  local center_text = ui.text_input.new():setText("center text"):setFont(ui.fonts.title):setWidth(300):setPos(5, 5):setColor(0.2, 0.2, 0.2):setFill(true):onReleased(function(o) ui.setEditing(o) end)
  local left_text = ui.text_input.new():setText("left text"):setFont(ui.fonts.title):setAlign("left"):setPos(5, 5+center_text:getHeight()+5):setWidth(300):setColor(0.2, 0.2, 0.2):setFill(true):onReleased(function(o) ui.setEditing(o) end)

  table.insert(components, center_text)
  table.insert(components, left_text)
end

function scene.draw()
  love.graphics.clear(0.1, 0.1, 0.11)

  for _,c in ipairs(components) do
    c:draw()
  end
end

return scene