local scene = {}

function scene.load()
	brush = nil
	selector_open = false

	clear()
	resetMusic("bab_be_u_them", 0.1)
	loadMap()
end

function scene.keyPressed(key)
	if key == "s" then
		print(dump(map))
	end

	if key == "tab" then
		selector_open = not selector_open
	end
end

function scene.update(dt)
	local hx,hy = getHoveredTile()
	if hx ~= nil then
		local tileid = hx + hy * mapwidth

		local hovered = {}
		if units_by_tile[tileid] then
			for _,v in ipairs(units_by_tile[tileid]) do
				table.insert(hovered, v)
			end
		end

		if love.mouse.isDown(1) then
			if not selector_open then
				if #hovered > 1 or (#hovered == 1 and hovered[1].tile ~= brush) or (#hovered == 0 and brush ~= nil) then
					if brush then
						map[tileid+1] = {brush}
					else
						map[tileid+1] = {}
					end
					clear()
					loadMap()
				end
			else
				local selected = hx + hy * getSelectorSize()
				if tiles_list[selected] then
					brush = selected
				else
					print("no tile for: " .. tileid)
					brush = nil
				end
			end
		end
		if love.mouse.isDown(2) and not selector_open then
			if #hovered >= 1 then
				brush = hovered[1].tile
			else
				brush = nil
			end
		end
	end
end

function scene.getTransform()
	local transform = love.math.newTransform()

	if not selector_open then
	  local roomwidth = mapwidth * TILE_SIZE
	  local roomheight = mapheight * TILE_SIZE
	  transform:translate(love.graphics.getWidth() / 2 - roomwidth / 2, love.graphics.getHeight() / 2 - roomheight / 2)
	else
		local size = getSelectorSize() * TILE_SIZE
		transform:translate(love.graphics.getWidth() / 2 - size / 2, love.graphics.getHeight() / 2 - size / 2)
	end

  return transform
end

function scene.draw(dt)
  love.graphics.setBackgroundColor(0.10, 0.1, 0.11)

  local roomwidth, roomheight
  if not selector_open then
	  roomwidth = mapwidth * TILE_SIZE
	  roomheight = mapheight * TILE_SIZE
	else
		roomwidth = getSelectorSize() * TILE_SIZE
		roomheight = getSelectorSize() * TILE_SIZE
	end

  love.graphics.push()
  love.graphics.applyTransform(scene.getTransform())

  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, 0, roomwidth, roomheight)

  if not selector_open then
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
	else
		for i=1,#tiles_list do
			local tile = tiles_list[i]
			local sprite = sprites[tile.sprite]

			local x = i % getSelectorSize()
			local y = math.floor(i / getSelectorSize())

			love.graphics.setColor(tile.color[1]/255, tile.color[2]/255, tile.color[3]/255)
			love.graphics.draw(sprite, (x + 0.5)*TILE_SIZE, (y + 0.5)*TILE_SIZE, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
		end
	end

  local hx,hy = getHoveredTile()
  if hx ~= nil then
	  if brush and not selector_open then
	  	local sprite = sprites[tiles_list[brush].sprite]
	  	local color = tiles_list[brush].color

			love.graphics.setColor(color[1]/255, color[2]/255, color[3]/255, 0.25)
	  	love.graphics.draw(sprite, (hx + 0.5)*TILE_SIZE, (hy + 0.5)*TILE_SIZE, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
	  end

	  love.graphics.setColor(1, 1, 0)
	  love.graphics.rectangle("line", hx * TILE_SIZE, hy * TILE_SIZE, TILE_SIZE, TILE_SIZE)
	end

  love.graphics.pop()
end

return scene