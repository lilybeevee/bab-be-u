local scene = {}

local title_font, label_font
local ui = {}

local width, height
local buttonheight, buttonheight
local buttons = {}

local world = nil

local scrollx = 0
local scrolly = 0

local scrolloffset = -1
local scrollvel = 0

local stopscrolltutorial = 1.0

--[[
  Math notes:
  world/level boxes are drawn with a width of 124, meaning 6 can fit with 8 pixels between them
]]

function scene.load()
  stopscrolltutorial = 1.0
  buttons = {}
  offbuttons = {} --not to be intepreted as "off buttons"

  local files = love.filesystem.getDirectoryItems("levels")
  local offfiles = love.filesystem.getDirectoryItems("officiallevels")
  for i,file in ipairs(files) do
    --print(file)
    if file:sub(-4) == ".bab" then
      local file = love.filesystem.read("levels/" .. file)

      if file ~= nil then
        local data = json.decode(file)

        table.insert(buttons, data)
      end
    end
  end
  --print("official levels")
  for i,file in ipairs(offfiles) do
    --print(file)
    if file:sub(-4) == ".bab" then
      local file = love.filesystem.read("officiallevels/" .. file)

      if file ~= nil then
        local data = json.decode(file)

        table.insert(offbuttons, data)
      end
    end
  end

  scene.updateWindowSize()
end

function scene.update(dt)
  scene.updateWindowSize()

  if scrolloffset > (#buttons+#offbuttons)*(0-buttonheight-10)-10+height and scrolloffset < 0 then
    scrolloffset = scrolloffset + scrollvel * dt
  elseif scrolloffset < (#buttons+#offbuttons)*(0-buttonheight-10)-10+height then
    scrolloffset = (#buttons+#offbuttons)*(0-buttonheight-10)-9+height
  elseif scrolloffset > 0 then
    scrolloffset = -1
  end
  scrollx = scrollx+0.1
  scrolly = scrolly+0.1

  scrollvel = scrollvel - scrollvel * math.min(dt * 10, 1)
  if scrollvel < 0.1 and scrollvel > -0.1 then scrollvel = 0 end
  debugDisplay("scrollvel", scrollvel)
  debugDisplay("scrolloffset", scrolloffset)

  if height > (#buttons+#offbuttons)*(buttonheight+10)+10 then
    scrolloffset = 0
  end
end

function scene.mousePressed(x, y, button)
  for i,button in ipairs(buttons) do
    if mouseOverBox(width/2-buttonwidth/2, buttonheight/2+(buttonheight+10)*(i-1)+scrolloffset, buttonwidth, buttonheight) then
      scene.loadLevel(button)
    end
  end
  for i,button in ipairs(offbuttons) do
    if mouseOverBox(width/2-buttonwidth/2, buttonheight/2+(buttonheight+10)*(i+#buttons)+scrolloffset, buttonwidth, buttonheight) then
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

  if height < (#buttons+#offbuttons)*(buttonheight+10)+10 and stopscrolltutorial > 0 then
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

  if #offbuttons ~= 0 then
    love.graphics.printf("official levels", width/2-buttonwidth/2, buttonheight/2+(buttonheight+10)*(#buttons)+5+scrolloffset, buttonwidth, "center")
  end

  for i,button in ipairs(offbuttons) do
    love.graphics.setColor(237/255, 114/255, 0) -- too lazy to enter colors manually

    if mouseOverBox(width/2-buttonwidth/2, buttonheight/2+(buttonheight+10)*(i+#buttons)+scrolloffset, buttonwidth, buttonheight) then love.graphics.setColor(237/255-0.1, 114/255-0.1, 0) end
    love.graphics.draw(sprites["ui/button_white_"..i%2+1], width/2-buttonwidth/2, buttonheight/2+(buttonheight+10)*(i+#buttons)+scrolloffset, 0, buttonwidth/sprites["ui/button_white_"..i%2+1]:getWidth(), buttonheight/sprites["ui/button_white_1"]:getHeight())

    love.graphics.setColor(1,1,1)
    
    love.graphics.printf(button.name, width/2-buttonwidth/2, buttonheight/2+(buttonheight+10)*(i+#buttons)+5+scrolloffset, buttonwidth, "center")
  end

  local icon = scene.generateIcon("BAB BE U")
  love.graphics.draw(icon)
end

function scene.updateWindowSize()
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()

  buttonheight = height*0.05
  buttonwidth = width*0.375
end

function scene.loadLevel(data)
  local loaddata = love.data.decode("string", "base64", data.map)
  level_compression = data.compression or "zlib"
  local mapstr = loadMaybeCompressedData(loaddata)

  loaded_level = true

  level_name = data.name
  level_author = data.author or ""
  current_palette = data.palette or "default"
  map_music = data.music or "bab be u them"
  mapwidth = data.width
  mapheight = data.height
  map_ver = data.version or 0
  level_parent_level = data.parent_level or ""
  level_next_level = data.next_level or ""
  level_is_overworld = data.is_overworld or false
  level_puffs_to_clear = data.puffs_to_clear or 0
  level_background_sprite = data.background_sprite or ""

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
    scrollvel = (buttonheight-10)*-40
  elseif key == "up" then
    scrollvel = (buttonheight-10)*40
  end
end

function scene.wheelMoved(whx, why) -- The wheel moved, Why?
  if buttonheight then
    if stopscrolltutorial == 1 then stopscrolltutorial = 0.9 end
    scrollvel = (buttonheight-10)*why*60
  end
  -- why = "well i dont fuckin know the person who moved it probably wanted it to move"
end

return scene