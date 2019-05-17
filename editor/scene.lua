local scene = {}

function scene.load()
	clear()
	resetMusic("bab_be_u_them", 0.1)
	loadMap()
end

function scene.getTransform()
	local transform = love.math.newTransform()
  local roomwidth = mapwidth * TILE_SIZE
  local roomheight = mapheight * TILE_SIZE
  transform:translate(love.graphics.getWidth() / 2 - roomwidth / 2, love.graphics.getHeight() / 2 - roomheight / 2)

  return transform
end

function scene.draw(dt)
  love.graphics.setBackgroundColor(0.10, 0.1, 0.11)

  local roomwidth = mapwidth * TILE_SIZE
  local roomheight = mapheight * TILE_SIZE
  local transform = scene.getTransform()

  love.graphics.push()
  love.graphics.applyTransform(transform)

  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, 0, roomwidth, roomheight)

  for i=1,max_layer do
    if units_by_layer[i] then
      for _,unit in ipairs(units_by_layer[i]) do
        local sprite = sprites[unit.sprite]

        local rotation = 0
        if unit.rotate then
        	rotation = (unit.dir - 1) * 90
        end
        
        love.graphics.setColor(unit.color[1]/255, unit.color[2]/255, unit.color[3]/255)
        love.graphics.draw(sprite, (unit.x + 0.5)*TILE_SIZE, (unit.y + 0.5)*TILE_SIZE, math.rad(rotation), unit.scalex, unit.scaley, sprite:getWidth() / 2, sprite:getHeight() / 2)
      end
    end
  end

  local mx,my = transform:inverseTransformPoint(love.mouse.getX(), love.mouse.getY())
  local hoverx = math.floor(mx / TILE_SIZE) * TILE_SIZE
  local hovery = math.floor(my / TILE_SIZE) * TILE_SIZE

  love.graphics.setColor(1, 1, 0)
  love.graphics.rectangle("line", hoverx, hovery, TILE_SIZE, TILE_SIZE)

  love.graphics.pop()
end

return scene