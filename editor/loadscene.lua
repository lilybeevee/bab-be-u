local scene = {}

local width, height
local buttonheight, buttonheight
local buttons = {}

function scene.load()
  buttons = {}

  local files = love.filesystem.getDirectoryItems("levels")
  for i,file in ipairs(files) do
    print(file)
    if file:sub(-4) == ".bab" then
      local file = love.filesystem.read("levels/" .. file)

      if file ~= nil then
        local data = json.decode(file)

        table.insert(buttons, data)
      end
    end
  end

  scene.updateWindowSize()
end

function scene.update(dt)
  scene.updateWindowSize()
end

function scene.mousepressed(x, y, button)
  for i,button in ipairs(buttons) do
    if mouseOverBox(width/2-buttonwidth/2, height/2-buttonheight/2+(buttonheight+10)*(i-1), buttonwidth, buttonheight) then
      scene.loadLevel(button)
    end
  end
end

function scene.draw(dt)
  love.graphics.setBackgroundColor(0, 0, 0)

  for i,button in ipairs(buttons) do
    love.graphics.setColor(1, 1, 1)

    if mouseOverBox(width/2-buttonwidth/2, height/2-buttonheight/2+(buttonheight+10)*(i-1), buttonwidth, buttonheight) then love.graphics.setColor(.9, .9, .9) end
    love.graphics.draw(sprites["ui/button_"..i%2+1], width/2-buttonwidth/2, height/2-buttonheight/2+(buttonheight+10)*(i-1), 0, buttonwidth/sprites["ui/button_"..i%2+1]:getWidth(), buttonheight/sprites["ui/button_1"]:getHeight())

    love.graphics.setColor(1,1,1)
    love.graphics.printf(button.name, width/2-buttonwidth/2, height/2-buttonheight/2+(buttonheight+10)*(i-1)+5, buttonwidth, "center")
  end
end

function scene.updateWindowSize()
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()

  buttonheight = height*0.05
  buttonwidth = width*0.375
end

function scene.loadLevel(data)
  local loaddata = love.data.decode("string", "base64", data.map)
  local mapstr = love.data.decompress("string", "zlib", loaddata)

  level_name = data.name
  mapwidth = data.width
  mapheight = data.height
  map = loadstring("return " .. mapstr)()

  new_scene = editor
  button_pressed = {}
end

return scene