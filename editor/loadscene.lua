local scene = {}

local width, height
local buttonheight, buttonheight
local buttons = {}

local scrollx = 0
local scrolly = 0

local scrolloffset = -1
local scrollvel = 0

local stopscrolltutorial = 1.0

function scene.load()
  stopscrolltutorial = 1.0
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

  if scrolloffset > (#buttons)*(0-buttonheight-10)-10+height and scrolloffset < 0 then
    scrolloffset = scrolloffset + scrollvel * dt
  elseif scrolloffset < (#buttons)*(0-buttonheight-10)-10+height then
    scrolloffset = (#buttons)*(0-buttonheight-10)-9+height
  elseif scrolloffset > 0 then
    scrolloffset = -1
  end
  scrollx = scrollx+0.1
  scrolly = scrolly+0.1

  scrollvel = scrollvel - scrollvel * math.min(dt * 10, 1)
  if scrollvel < 0.1 and scrollvel > -0.1 then scrollvel = 0 end
  debugDisplay("scrollvel", scrollvel)
  debugDisplay("scrolloffset", scrolloffset)

  if height > (#buttons)*(buttonheight+10)+10 then
    scrolloffset = 0
  end
end

function scene.mousePressed(x, y, button)
  for i,button in ipairs(buttons) do
    if mouseOverBox(width/2-buttonwidth/2, buttonheight/2+(buttonheight+10)*(i-1)+scrolloffset, buttonwidth, buttonheight) then
      scene.loadLevel(button)
    end
  end
end

function scene.draw(dt)
  if stopscrolltutorial < 1 and stopscrolltutorial > 0 then
    stopscrolltutorial = stopscrolltutorial - dt
  end

  love.graphics.setBackgroundColor(0.10, 0.1, 0.11)

  local bgsprite = sprites["ui/menu_background"]

  -- no need to insult me, i know this is terrible code
  love.graphics.setColor(1, 1, 1, 0.6)
  love.graphics.draw(bgsprite, scrollx%bgsprite:getWidth(), scrolly%bgsprite:getHeight(), 0)
  
  love.graphics.draw(bgsprite, scrollx%bgsprite:getWidth()-bgsprite:getWidth(), scrolly%bgsprite:getHeight()-bgsprite:getHeight(), 0)
  love.graphics.draw(bgsprite, scrollx%bgsprite:getWidth()-bgsprite:getWidth(), scrolly%bgsprite:getHeight(), 0)
  love.graphics.draw(bgsprite, scrollx%bgsprite:getWidth(), scrolly%bgsprite:getHeight()-bgsprite:getHeight(), 0)

  love.graphics.draw(bgsprite, scrollx%bgsprite:getWidth()+bgsprite:getWidth(), scrolly%bgsprite:getHeight()+bgsprite:getHeight(), 0)
  love.graphics.draw(bgsprite, scrollx%bgsprite:getWidth()+bgsprite:getWidth(), scrolly%bgsprite:getHeight(), 0)
  love.graphics.draw(bgsprite, scrollx%bgsprite:getWidth(), scrolly%bgsprite:getHeight()+bgsprite:getHeight(), 0)

  love.graphics.draw(bgsprite, scrollx%bgsprite:getWidth()+bgsprite:getWidth(), scrolly%bgsprite:getHeight()-bgsprite:getHeight(), 0)
  love.graphics.draw(bgsprite, scrollx%bgsprite:getWidth()-bgsprite:getWidth(), scrolly%bgsprite:getHeight()+bgsprite:getHeight(), 0)

  if height < (#buttons)*(buttonheight+10)+10 and stopscrolltutorial > 0 then
    love.graphics.setColor(1, 1, 1, stopscrolltutorial)
    love.graphics.print("press up and down arrows or use the scrollbar to scroll")
  end

  for i,button in ipairs(buttons) do
    love.graphics.setColor(1, 1, 1)

    if mouseOverBox(width/2-buttonwidth/2, buttonheight/2+(buttonheight+10)*(i-1)+scrolloffset, buttonwidth, buttonheight) then love.graphics.setColor(.9, .9, .9) end
    love.graphics.draw(sprites["ui/button_"..i%2+1], width/2-buttonwidth/2, buttonheight/2+(buttonheight+10)*(i-1)+scrolloffset, 0, buttonwidth/sprites["ui/button_"..i%2+1]:getWidth(), buttonheight/sprites["ui/button_1"]:getHeight())

    love.graphics.setColor(1,1,1)
    
    love.graphics.printf(button.name, width/2-buttonwidth/2, buttonheight/2+(buttonheight+10)*(i-1)+5+scrolloffset, buttonwidth, "center")
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

  loaded_level = true

  level_name = data.name
  level_author = data.author or ""
  current_palette = data.palette or "default"
  map_music = data.music or "bab be u them"
  mapwidth = data.width
  mapheight = data.height
  map_ver = data.version or 0

  if map_ver == 0 then
    map = loadstring("return " .. mapstr)()
  else
    map = mapstr
  end

  new_scene = editor
  button_pressed = {}
end

function scene.keyPressed(key)
  if stopscrolltutorial == 1 and (key == "down" or key == "up") then stopscrolltutorial = 0.9 end
  if key == "down" then
    scrollvel = (buttonheight-10)*-35
  elseif key == "up" then
    scrollvel = (buttonheight-10)*35
  end
end

function love.wheelmoved(whx, why)
  if buttonheight then
    if stopscrolltutorial == 1 then stopscrolltutorial = 0.9 end
    scrollvel = (buttonheight-10)*why*45
  end
end

return scene