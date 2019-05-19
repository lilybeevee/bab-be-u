local scene = {}
game = require '../game/scene'

local width = love.graphics.getWidth()
local height = love.graphics.getHeight()

local buttonheight = height*0.05
local buttonwidth = width*0.375

function scene.load()
  clear()
  love.graphics.setBackgroundColor(0.10, 0.1, 0.11)
  playMusic("bab_be_u_them", 0.5)
  local now = os.time(os.date("*t"))
  presence = {
    state = "main menu",
    details = "idling",
    largeImageKey = "titlescreen",
    largeimageText = "main menu",
    startTimestamp = now
  }
  nextPresenceUpdate = 0
end

function scene.draw(dt)
  local buttons = {"play", "editor", "exit"}

  for i=1, #buttons do
    if mouseOverBox(width/2-buttonwidth/2, height/2-buttonheight/2+(buttonheight+10)*i, buttonwidth, buttonheight) then love.graphics.setColor(.9, .9, .9) end
    love.graphics.draw(sprites["button_"..i%2+1], width/2-buttonwidth/2, height/2-buttonheight/2+(buttonheight+10)*i, 0, buttonwidth/sprites["button_"..i%2+1]:getWidth(), buttonheight/sprites["button_1"]:getHeight())

    love.graphics.setColor(1,1,1)
    love.graphics.printf(buttons[i], width/2-buttonwidth/2, height/2-buttonheight/2+(buttonheight+10)*i+5, buttonwidth, "center")
  end
  love.graphics.draw(sprites["bab_be_u"], width/2 - sprites["bab_be_u"]:getWidth() / 2, height/2 - sprites["bab_be_u"]:getHeight() / 2 - 200)
end

function scene.update()
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()

  buttonheight = height*0.05
  buttonwidth = width*0.375

  local mousex, mousey = love.mouse.getPosition()

  if mouseOverBox(width/2-buttonwidth/2, height/2-buttonheight/2+(buttonheight+10)*3, buttonwidth, buttonheight) then love.mouse.setPosition(mousex, mousey-(buttonheight+10)) end
end

return scene