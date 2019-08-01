local scene = {}
game = require '../game/scene'

local width = love.graphics.getWidth()
local height = love.graphics.getHeight()

local scrollx = 0
local scrolly = 0

local music_on = true



function scene.load()
  metaClear()
  clear()
  resetMusic("bab be u them REEEMAZTUR", 0.5)
  love.graphics.setBackgroundColor(0.10, 0.1, 0.11)
  local now = os.time(os.date("*t"))
  presence = {
    state = "main menu",
    details = "idling",
    largeImageKey = "titlescreen",
    largeimageText = "main menu",
    startTimestamp = now
  }
  nextPresenceUpdate = 0
  love.mouse.setGrabbed(false)
  love.keyboard.setKeyRepeat(false)
end

function scene.draw(dt)
  local buttons = {"play", "editor", "exit"}
  local bgsprite = sprites["ui/menu_background"]

  if is_mobile then
    local cursorx, cursory = love.mouse.getPosition()
    love.graphics.setColor(1, 1, 1)
    setRainbowModeColor(love.timer.getTime()/6, .5)
    love.graphics.draw(system_cursor, cursorx, cursory)
  end

  local cells_x = math.ceil(love.graphics.getWidth() / bgsprite:getWidth())
  local cells_y = math.ceil(love.graphics.getHeight() / bgsprite:getHeight())

  love.graphics.setColor(1, 1, 1, 1)
  setRainbowModeColor(love.timer.getTime()/6, .4)

  for x = -1, cells_x do
    for y = -1, cells_y do
      local draw_x = scrollx % bgsprite:getWidth() + x * bgsprite:getWidth()
      local draw_y = scrolly % bgsprite:getHeight() + y * bgsprite:getHeight()
      love.graphics.draw(bgsprite, draw_x, draw_y)
    end
  end

  local buttonwidth, buttonheight = sprites["ui/button_1"]:getDimensions()

  local buttoncolor = {84/255, 109/255, 255/255} --terrible but it works so /shrug
  if rainbowmode then buttoncolor = hslToRgb(love.timer.getTime()/6%1, .5, .5, .9) end

  for i=1, #buttons do
    love.graphics.push()
    local rot = 0

    local buttonx = width/2-buttonwidth/2
    local buttony = height/2-buttonheight/2+(buttonheight+10)*i

    love.graphics.setColor(buttoncolor[1], buttoncolor[2], buttoncolor[3])
    if mouseOverBox(width/2-sprites["ui/button_1"]:getWidth()/2, height/2-buttonheight/2+(buttonheight+10)*i, buttonwidth, buttonheight) then
      love.graphics.setColor(buttoncolor[1]-0.1, buttoncolor[2]-0.1, buttoncolor[3]-0.1) --i know this is horrible
      love.graphics.translate(buttonx+buttonwidth/2, buttony+buttonheight/2)
      playSound("mous hovvr")
      love.graphics.rotate(0.05 * math.sin(love.timer.getTime()*3))
      love.graphics.translate(-buttonx-buttonwidth/2, -buttony-buttonheight/2)
    end

    love.graphics.draw(sprites["ui/button_white_"..i%2+1], buttonx, buttony, rot, 1, 1)

    love.graphics.pop()

    love.graphics.setColor(1,1,1)
    love.graphics.printf(buttons[i], width/2-buttonwidth/2, height/2-buttonheight/2+(buttonheight+10)*i+5, buttonwidth, "center")
  end

  for _,pair in pairs({{1,0},{0,1},{1,1},{-1,0},{0,-1},{-1,-1},{1,-1},{-1,1}}) do
    local outlineSize = 2
    pair[1] = pair[1] * outlineSize
    pair[2] = pair[2] * outlineSize

    love.graphics.setColor(0,0,0)
    love.graphics.draw(sprites["ui/bab_be_u"], width/2 - sprites["ui/bab_be_u"]:getWidth() / 2 + pair[1], height/20 + pair[2])
  end

  love.graphics.setColor(1, 1, 1)
  setRainbowModeColor(love.timer.getTime()/3, .5)
  love.graphics.draw(sprites["ui/bab_be_u"], width/2 - sprites["ui/bab_be_u"]:getWidth() / 2, height/20)

  if is_mobile then
    love.graphics.push()

    local textx = width/2 + sprites["ui/bab_be_u"]:getWidth() / 2
    local texty = height/20+sprites["ui/bab_be_u"]:getHeight()

    love.graphics.translate(textx+love.graphics.getFont():getWidth("4mobile!")/2, texty+love.graphics.getFont():getHeight()/2)
    love.graphics.rotate(0.7*math.sin(love.timer.getTime()*2))
    love.graphics.translate(-textx-love.graphics.getFont():getWidth("4mobile!")/2, -texty-love.graphics.getFont():getHeight()/2)

    love.graphics.print("4mobile!", textx, texty)
    
    love.graphics.pop()
  end

  onstate = "on"
  if not settings["music_on"] then onstate = "off" end

  love.graphics.setColor(1, 1, 1)
  if mouseOverBox(10, height - sprites["ui/music-on"]:getHeight(), sprites["ui/music-on"]:getWidth(), sprites["ui/music-on"]:getHeight()) then
    love.graphics.setColor(.7, .7, .7)
  end

  love.graphics.draw(sprites["ui/music-"..onstate], 10, height - sprites["ui/music-"..onstate]:getHeight() - 10)

  love.graphics.setColor(1, 1, 1)
  if mouseOverBox(20+sprites["ui/github"]:getWidth(), height-sprites["ui/github"]:getHeight() - 10, sprites["ui/github"]:getWidth(), sprites["ui/github"]:getHeight()) then
    love.graphics.setColor(.7, .7, .7)
  end

  love.graphics.draw(sprites["ui/github"], 20+sprites["ui/github"]:getWidth(), height-sprites["ui/github"]:getHeight() - 10)

  if build_number and not debug then
    love.graphics.setColor(1, 1, 1)
    setRainbowModeColor(love.timer.getTime()/6, .6)
    --if haha number then make it rainbow anyways
    if string.find(build_number, "420") or string.find(build_number, "1337") or string.find(build_number, "666") or string.find(build_number, "69") then
      love.graphics.setColor(hslToRgb(love.timer.getTime()%1, .5, .5, .9))
    end
    love.graphics.print('v'..build_number)
  end
end

function scene.update(dt)
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()

  local buttonwidth, buttonheight = sprites["ui/button_1"]:getDimensions()

  local mousex, mousey = love.mouse.getPosition()

  scrollx = scrollx+dt*50
  scrolly = scrolly+dt*50

  if mouseOverBox(width/2-buttonwidth/2, height/2-buttonheight/2+(buttonheight+10)*3, buttonwidth, buttonheight) then
    love.mouse.setPosition(mousex, mousey-(buttonheight+10))
  end
end

function scene.mousePressed(x, y, button)
  if pointInside(x, y, 10, height - sprites["ui/music-on"]:getHeight(), sprites["ui/music-on"]:getWidth(), sprites["ui/music-on"]:getHeight()) and button == 1 then
    settings["music_on"] = not settings["music_on"]
    saveAll()
  end

  if pointInside(x, y, 20+sprites["ui/github"]:getWidth(), height-sprites["ui/github"]:getHeight() - 10, sprites["ui/github"]:getWidth(), sprites["ui/github"]:getHeight()) and button == 1 then
    love.system.openURL("https://github.com/lilybeevee/bab-be-u")
  end
end

return scene
