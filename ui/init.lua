ui = {}

ui.component = require 'ui/component'
ui.text_input = require 'ui/textinput'
ui.level_button = require 'ui/levelbutton'
ui.world_button = require 'ui/worldbutton'
ui.menu_button = require 'ui/menubutton'

ui.overlay = require 'ui/overlay'

ui.selecting = false

ui.fonts = {}
ui.mouse = {left = "up", right = "up"}
ui.selectables = {}
ui.hovered = nil
ui.new_hovered = nil
ui.lock_hovered = false
ui.selected = nil
ui.last_selected = nil
ui.editing = nil

function ui.init()
  ui.fonts.default = love.graphics.newFont(12)
  ui.fonts.default:setFilter("nearest","nearest")
  ui.fonts.title = love.graphics.newFont(32)
  ui.fonts.category = love.graphics.newFont(24)
  ui.fonts.world_name = love.graphics.newFont(16)
  ui.fonts.world_name:setFilter("nearest","nearest")
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
  else
    if ui.selecting then
      if ui.selected == nil then
        if key == "down" or key == "s" then
          if not ui.last_selected then ui.selectNearest(love.graphics.getWidth()/2, 0)
          else ui.select(ui.last_selected) end
          return true
        elseif key == "up" or key == "w" then
          if not ui.last_selected then ui.selectNearest(love.graphics.getWidth()/2, love.graphics.getHeight())
          else ui.select(ui.last_selected) end
          return true
        elseif key == "right" or key == "d" then
          if not ui.last_selected then ui.selectNearest(0, love.graphics.getHeight()/2)
          else ui.select(ui.last_selected) end
          return true
        elseif key == "left" or key == "a" then
          if not ui.last_selected then ui.selectNearest(love.graphics.getWidth(), love.graphics.getHeight()/2)
          else ui.select(ui.last_selected) end
          return true
        end
      else
        local x, y = ui.selected:getDrawPos()
        local w, h = ui.selected:getDrawSize()
        x = x + w/2
        y = y + h/2
        if key == "down" or key == "s" then
          ui.selectNearest(x, y, {min_y = y + h/4})
          return true
        elseif key == "up" or key == "w" then
          ui.selectNearest(x, y, {max_y = y - h/4})
          return true
        elseif key == "right" or key == "d" then
          ui.selectNearest(x, y, {min_x = x + 1, min_y = y - h/2, max_y = y + h/2})
          return true
        elseif key == "left" or key == "a" then
          ui.selectNearest(x, y, {max_x = x, min_y = y - h/2, max_y = y + h/2})
          return true
        elseif key == "return" or key == "space" or key == "kpenter" then
          if ui.selected.select_state == "released" or ui.selected.select_state == "selected" then
            ui.selected.select_state = "pressed"
          end
          return true
        end
      end
    end
    if ui.overlay.open then
      if key == "escape" then
        ui.overlay.close()
      elseif key == "return" then
        ui.overlay.close(true)
      end
      return true
    end
  end
  return false
end

function ui.keyReleased(key)
  if not ui.editing and ui.selected then
    if key == "return" or key == "space" or key == "kpenter" then
      if ui.selected.select_state == "pressed" or ui.selected.select_state == "down" then
        ui.selected.select_state = "released"
      end
      return true
    end
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
  if ui.overlay.open then
    ui.selecting = true
  else
    ui.selecting = scene.selecting
  end

  -- clear references to UI elements that did not exist last draw
  if ui.editing and ui.editing.frame ~= frame then
    ui.editing:setEditing(false)
    ui.editing = false
  end
  if ui.selected and ui.selected.frame ~= frame then
    if ui.selecting then
      local x, y = ui.selected:getDrawPos()
      local w, h = ui.selected:getDrawSize()
      ui.selectNearest(x + w/2, y + h/2, {}, true)
    else
      ui.selected.select_state = nil
      ui.selected = nil
    end
  end
  if ui.selecting and ui.last_selected and ui.last_selected ~= frame then ui.last_selected = nil end
  
  if ui.lock_hovered then
    ui.new_hovered = nil
  elseif ui.new_hovered ~= nil then
    if ui.new_hovered:getSelectable() then
      ui.select(nil)
      ui.last_selected = ui.new_hovered
    end
  end
  ui.hovered = ui.new_hovered
  ui.new_hovered = nil

  if love.mouse.isDown(1) then
    ui.select(nil)
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
    ui.select(nil)
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

  ui.selectables = {}
end

function ui.postDraw()
  if ui.selected then
    if ui.selected.select_state == "pressed" then
      ui.selected.select_state = "down"
    elseif ui.selected.select_state == "released" then
      ui.selected.select_state = "selected"
    end
  end
end

function ui.select(o)
  if ui.selected then ui.selected.select_state = nil end
  if o then o.select_state = "selected" end
  ui.selected = o
  ui.last_selected = o
  ui.new_selected = o
  if o ~= nil then
    ui.lock_hovered = true
  end
end

function ui.selectNearest(x, y, bounds, force)
  bounds = bounds or {}
  local nearest = nil
  local nearest_dist = 0
  for _,v in ipairs(ui.selectables) do
    local vx, vy = v:getDrawPos()
    vx = vx + v:getDrawWidth()/2
    vy = vy + v:getDrawHeight()/2
    if (not bounds.min_x or (vx >= bounds.min_x)) and
       (not bounds.min_y or (vy >= bounds.min_y)) and
       (not bounds.max_x or (vx < bounds.max_x)) and
       (not bounds.max_y or (vy < bounds.max_y)) then
      local dist = euclideanDistance({x = x, y = y}, {x = vx, y = vy})
      if nearest == nil or dist < nearest_dist then
        nearest = v
        nearest_dist = dist
      end
    end
  end
  if not (ui.selected and not nearest) or force then
    ui.select(nearest)
  end
end

function ui.buttonFX(o, args)
  args = args or {}
  args.defaults = args.defaults or {}
  local scale = args.defaults.scale or 1
  local rot = args.defaults.rotation or 0
  if o:hovered() then
    if args.scale ~= false then
      if o:pressed() or o:down() then
        o:setScale(scale - (args.shrink or 0.1))
      else
        o:setScale(scale + (args.grow or 0.1))
      end
    end
    if settings["shake_on"] and args.rotate ~= false then
      o:setRotation(rot + (args.intensity or 0.05) * math.sin(love.timer.getTime()*(args.speed or 5)))
    end
  else
    if args.scale ~= false then o:setScale(scale) end
    if args.rotate ~= false then o:setRotation(rot) end
  end
end