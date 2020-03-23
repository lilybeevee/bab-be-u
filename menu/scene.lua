local scene = {}
game = require '../game/scene'

local scrollx = 0
local scrolly = 0

local music_on = true

local oldmousex = 0
local oldmousey = 0

local buttons = {}--{"play", "editor", "options", "exit"}
local git_btn = nil

local splash = love.timer.getTime() % 1

local babtitletween = love.timer.getTime()
local babtitlespeen = math.random(1,1000) == 1

function scene.load()
  metaClear()
  clear()
  was_using_editor = false
  if getTheme() == "halloween" then
    resetMusic("bab spoop u", 0.5)
  else
    resetMusic("bab be u them REEEMAZTUR", 0.5)
  end
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
  love.keyboard.setKeyRepeat(false)
  scene.buildUI()
  scene.selecting = true
  if settings["menu_anim"] then
    babtitletween = love.timer.getTime()
    babtitlespeen = math.random(1,1000) == 1
  end
end

function scene.buildUI()
  buttons = {}
  if getTheme() == "halloween" then
    if not settings["epileptic"] and (love.timer.getTime()%10 > 8.7 and love.timer.getTime()%10 < 8.8 or love.timer.getTime()%10 > 8.9 and love.timer.getTime()%10 < 9) then
        giticon = sprites["ui/github_halloween_blood"]
    else
        giticon = sprites["ui/github_halloween"]
    end
  else
    giticon = sprites["ui/github"]
  end
  
  git_btn = ui.component.new()
    :setSprite(giticon)
    :setColor(1, 1, 1)
    :setPos(10, love.graphics.getHeight()-sprites["ui/github"]:getHeight()-10)
    :setPivot(0.5, 0.5)
    :onPreDraw(function(o) ui.buttonFX(o, {rotate = false}) end)
    :onReleased(function() love.system.openURL("https://github.com/lilybeevee/bab-be-u") end)

  local ox, oy
  if not options then
    scene.addButton("play", function() switchScene("play") end)
    scene.addButton("edit", function() switchScene("edit") end)
    scene.addButton("options", function() options = true; scene.buildUI() end)
    scene.addButton("exit", function() love.event.quit() end)
    ox, oy = love.graphics.getWidth()/2, love.graphics.getHeight()/2
  else
    buildOptions()
    ox, oy = love.graphics.getWidth() * (3/4) , buttons[1]:getHeight()+10
  end

  for i,button in ipairs(buttons) do
    local width, height = button:getSize()
    button:setPos(ox - width/2, oy - height/2)
    oy = oy + height + 10
  end
end

function scene.addButton(text, func)
  local button = ui.menu_button.new(text, #buttons%2+1, func)
  table.insert(buttons, button)
  return button
end

function scene.addOption(id, name, options, changed)
  local option = 1
  for i,v in ipairs(options) do
    if settings[id] == v[2] then
      option = i
    end
  end
  scene.addButton(name .. ": " .. options[option][1], function()
    settings[id] = options[(((option-1)+1)%#options)+1][2]
    saveAll()
    if changed then
      changed(settings[id])
    end
    scene.buildUI()
  end)
end

function scene.update(dt)
  if settings["scroll_on"] then
    scrollx = scrollx+dt*50
    scrolly = scrolly+dt*50
  else
    scrollx, scrolly = 0,0
  end

  git_btn:setPos(10, love.graphics.getHeight()-sprites["ui/github"]:getHeight()-10 + ease.outExpo(math.min(love.timer.getTime()-babtitletween-0.5, 1.2), sprites["ui/github"]:getHeight()+10, -sprites["ui/github"]:getHeight()-10, 1.2))
end

function scene.draw(dt)
  local bgsprite = sprites["ui/bgs/"..getTheme()]
  if not bgsprite then bgsprite = sprites["ui/bgs/default"] end
  
  if not settings["epileptic"] and getTheme() == "halloween" and (love.timer.getTime()%10 > 8.6 and love.timer.getTime()%10 < 8.7 or love.timer.getTime()%10 > 8.8 and love.timer.getTime()%10 < 8.9 or love.timer.getTime()%10 > 9)  then
    bgsprite = sprites["ui/bgs/halloween_flash"]
  end

  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()

  local cells_x = math.ceil(width / bgsprite:getWidth())
  local cells_y = math.ceil(height / bgsprite:getHeight())

  if not spookmode then
    love.graphics.setColor(1, 1, 1, 1)
    setRainbowModeColor(love.timer.getTime()/6, .4)
  else
    love.graphics.setColor(0.2,0.2,0.2,1)
  end

  for x = -1, cells_x do
    for y = -1, cells_y do
      local draw_x = scrollx % bgsprite:getWidth() + x * bgsprite:getWidth()
      local draw_y = scrolly % bgsprite:getHeight() + y * bgsprite:getHeight()
      love.graphics.draw(bgsprite, draw_x, draw_y)
    end
  end

  for _,button in ipairs(buttons) do
    button:draw()
  end
  git_btn:draw()

  if not options then
    local bab_logo = sprites["ui/title/"..getTheme()] or sprites["ui/title/default"]
    if getTheme() == "halloween" and not settings["epileptic"] and (love.timer.getTime()%10 > 8.7 and love.timer.getTime()%10 < 8.8 or love.timer.getTime()%10 > 8.9 and love.timer.getTime()%10 < 9) then 
      bab_logo = sprites["ui/title/halloween_blood"]
    end
    
    love.graphics.push()
    love.graphics.translate(width/2, height/20 + bab_logo:getHeight()/2)
    love.graphics.rotate(ease.outBack(math.min(love.timer.getTime()-babtitletween, babtitlespeen and 99999999 or 1.2), -math.pi*2, math.pi*2, 1.2, 2.6))
    love.graphics.scale(ease.outBack(math.min(love.timer.getTime()-babtitletween, 1), 0, 1, 1, 1.9))

    for _,pair in pairs({{1,0},{0,1},{1,1},{-1,0},{0,-1},{-1,-1},{1,-1},{-1,1}}) do
      local outlineSize = 2
      pair[1] = pair[1] * outlineSize
      pair[2] = pair[2] * outlineSize

      love.graphics.setColor(0,0,0)
      love.graphics.draw(bab_logo, pair[1]-bab_logo:getWidth()/2, pair[2]-bab_logo:getHeight()/2)
    end

    if not spookmode then
      love.graphics.setColor(1, 1, 1)
      setRainbowModeColor(love.timer.getTime()/3, .5)
      love.graphics.draw(bab_logo, -bab_logo:getWidth()/2, -bab_logo:getHeight()/2)
    end
    love.graphics.translate(-width/2, -height/20 + bab_logo:getHeight()/2)
    love.graphics.pop()
    -- Splash text here
    
    love.graphics.push()
    
    if string.find(build_number, "420") or string.find(build_number, "1337") or string.find(build_number, "666") or string.find(build_number, "69") then
      love.graphics.setColor(hslToRgb(love.timer.getTime()%1, .5, .5, .9))
      splashtext = "nice"
    end
    if is_mobile then
      splashtext = "4mobile!"
    elseif getTheme() == "christmas" then
      love.graphics.setColor(0,1,0)
      if splash > 0.66 then
        splashtext = "merery crimsmas!!"
      elseif splash < 0.33 then
        splashtext = "happi hollydays!"
      else
        splashtext = "happi hunnukkah!!"
      end
    elseif getTheme() == "halloween" then
      if not settings["epileptic"] and (love.timer.getTime()%10 > 8.7 and love.timer.getTime()%10 < 8.8 or love.timer.getTime()%10 > 8.9 and love.timer.getTime()%10 < 9) then
        splashtext = "BAB IS DEAD"
      elseif love.filesystem.read("author_name") == "lilybeevee" and splash > 0.5 then
        splashtext = "happy spooky month lily!"
      else
        splashtext = "spooky month!"
      end
    elseif splash > 0.5 then
      splashtext = "bab be u!"
    else
      splashtext = "splosh txt!"
    end
    
    local textx = width/2 + bab_logo:getWidth() / 2
    local texty = height/20+bab_logo:getHeight()

    love.graphics.translate(textx+love.graphics.getFont():getWidth(splashtext)/2, texty+love.graphics.getFont():getHeight()/2)
    if settings["shake_on"] then
      love.graphics.rotate(0.7*math.sin(love.timer.getTime()*2))
    else
      love.graphics.rotate(math.pi/4)
    end
    love.graphics.translate(-textx-love.graphics.getFont():getWidth(splashtext)/2, -texty-love.graphics.getFont():getHeight()/2)

    love.graphics.setColor(1,1,1,love.timer.getTime()-babtitletween)
    love.graphics.print(splashtext, textx, texty)
    
    love.graphics.pop()
  else
    local img = sprites["ui/bab cog"]
    if getTheme() == "halloween" then
      img = sprites["ui/bab cog_halloween"]
    elseif getTheme() == "christmas" then
      img = sprites["ui/bab cog_christmas"]
    else
      img = sprites["ui/bab cog"]
    end
    local txt = sprites["ui/many toggls"]
    
    if getTheme() == "halloween" then
        love.graphics.draw(sprites["ui/cobweb"])
    end

    local full_height = img:getHeight()*2 + 10 + txt:getHeight()

    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() * (1/4), love.graphics.getHeight()/2)
    love.graphics.scale(2 * getUIScale())
    love.graphics.translate(0, -full_height/2)
    
    love.graphics.push()
    love.graphics.scale(2)
    love.graphics.translate(0, img:getHeight()/2)
    if settings["shake_on"] then
      love.graphics.rotate(0.1*math.sin(love.timer.getTime()))
    end
    love.graphics.draw(img, -img:getWidth()/2, -img:getHeight()/2)
    love.graphics.pop()
    
    local ox, oy = math.floor(math.random()*4)/2-1, math.floor(math.random()*4)/2-1
    if not settings["shake_on"] then ox, oy = 0,0 end
    if getTheme() == "halloween" then
      love.graphics.setColor(0.5, 0.25, 0.75)
    elseif getTheme() == "christmas" then
      love.graphics.setColor(0.9,0.1,0)
    end
    love.graphics.draw(txt, -txt:getWidth()/2 + ox, full_height - txt:getHeight() + oy)

    love.graphics.pop()
  end

  if build_number and not debug_view then
    love.graphics.setColor(1, 1, 1)
    setRainbowModeColor(love.timer.getTime()/6, .6)
    --if haha number then make it rainbow anyways
    if string.find(build_number, "420") or string.find(build_number, "1337") or string.find(build_number, "666") or string.find(build_number, "69") then
      love.graphics.setColor(hslToRgb(love.timer.getTime()%1, .5, .5, .9))
    end
    local height = love.graphics.getFont():getHeight()
    local y = ease.outExpo(math.min(love.timer.getTime()-babtitletween-0.5, 1.2), -height, height, 1.2)
    love.graphics.print(spookmode and "error" or 'v'..build_number, 0, y)
    debugDisplay('y', y)
  end

  if is_mobile then
    local cursorx, cursory = love.mouse.getPosition()
    love.graphics.setColor(1, 1, 1)
    setRainbowModeColor(love.timer.getTime()/6, .5)
    love.graphics.draw(system_cursor, cursorx, cursory)
  end
end

function scene.keyPressed(key)
  if key == "escape" and options then
    options = false
    scene.buildUI()
  end
end

function scene.resize(w, h)
  scene.buildUI()
end

return scene
