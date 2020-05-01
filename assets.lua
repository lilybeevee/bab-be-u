local assets = {}

function assets.clear()
  print(colr.cyan("ℹ️ clearing assets"))

  sprites = {}
  palettes = {}
  sound_path = {}
  music_path = {}

  tiles_list = {}
  tiles_by_old_name = {}
  text_list = {}
  text_in_tiles = {}
  wobble_text_list = {}
  wobble_text_in_tiles = {}
  group_names = {}
  group_names_nt = {}
  group_names_set = {}
  group_names_set_nt = {}
  group_subsets = {}
  overlay_props = {}
end

function assets.load(base)
  print(colr.cyan("ℹ️ loading " .. base))

  assets.addSprites(base)
  print(colr.green("✓ added sprites"))

  assets.addTiles(base)
  print(colr.green("✓ added tiles"))

  assets.addPalettes(base)
  print(colr.green("✓ added palettes"))

  assets.addAudio(base)
  print(colr.green("✓ added audio"))
end

function assets.addSprites(base, d)
  local dir = base.."/sprites"
  if d then
    dir = dir .. "/" .. d
  end
  local files = love.filesystem.getDirectoryItems(dir)
  for _,file in ipairs(files) do
    if string.sub(file, -4) == ".png" then
      local spritename = string.sub(file, 1, -5)
      local sprite = love.graphics.newImage(dir .. "/" .. file)
      if d then
        spritename = d .. "/" .. spritename
      end
      sprites[spritename] = sprite
      --print(colr.cyan("ℹ️ added sprite "..spritename))
    elseif love.filesystem.getInfo(dir .. "/" .. file).type == "directory" then
      --print(colr.cyan("ℹ️ found sprite dir: " .. file))
      local newdir = file
      if d then
        newdir = d .. "/" .. newdir
      end
      assets.addSprites(base, newdir)
    end
  end
end

function assets.addTiles(base, d)
  local dir = base.."/tiles"
  if d then
    dir = dir .. "/" .. d
  end
  local files = love.filesystem.getDirectoryItems(dir)
  for _,file in ipairs(files) do
    if string.sub(file, -5) == ".json" then
      local tiles = json.decode(love.filesystem.read(dir .. "/" .. file))
      for _,tile in ipairs(tiles) do
        addTile(tile)
      end
    elseif love.filesystem.getInfo(dir .. "/" .. file).type == "directory" then
      local newdir = file
      if d then
        newdir = d .. "/" .. newdir
      end
      assets.addTiles(base, newdir)
    end
  end
end

function assets.addPalettes(base, d)
  local dir = base.."/palettes"
  if d then
    dir = dir .. "/" .. d
  end
  local files = love.filesystem.getDirectoryItems(dir)
  for _,file in ipairs(files) do
    if string.sub(file, -4) == ".png" then
      local palettename = string.sub(file, 1, -5)
      local data = love.image.newImageData(dir .. "/" .. file)
      local sprite = love.graphics.newImage(data)
      if d then
        palettename = d .. "/" .. palettename
      end
      local palette = {}
      palettes[palettename] = palette
      palette.sprite = sprite
      for x = 0, sprite:getWidth()-1 do
        for y = 0, sprite:getHeight()-1 do
          local r, g, b, a = data:getPixel(x, y)
          palette[x + y * sprite:getWidth()] = {r, g, b, a}
        end
      end
      --print(colr.cyan("ℹ added palette "..palettename))
    elseif love.filesystem.getInfo(dir .. "/" .. file).type == "directory" then
      --print(colr.cyan("ℹ️ found palette dir: " .. file))
      local newdir = file
      if d then
        newdir = d .. "/" .. newdir
      end
      assets.addPalettes(base, newdir)
    end
  end
end

function assets.addAudio(base, d, type)
  local dir = base.."/audio"
  if d then
    dir = dir .. "/" .. d
  end
  local files = love.filesystem.getDirectoryItems(dir)
  for _,file in ipairs(files) do
    if love.filesystem.getInfo(dir .. "/" .. file).type == "directory" then
      local newdir = file
      if d then
        newdir = d .. "/" .. newdir
      end
      assets.addAudio(base, newdir, type or file)
    else
      local audioname = file
      if file:ends(".wav") then audioname = file:sub(1, -5) end
      if file:ends(".mp3") then audioname = file:sub(1, -5) end
      if file:ends(".ogg") then audioname = file:sub(1, -5) end
      if file:ends(".flac") then audioname = file:sub(1, -5) end
      if file:ends(".xm") then audioname = file:sub(1, -4) end
      --[[if d then
        audioname = d .. "/" .. audioname
      end]]
      if type == "sfx" then
        sound_path[audioname] = dir .. "/" .. file

        if sounds and sounds[audioname] then
          registerSound(audioname, sounds[audioname].volume)
        end
      elseif type == "bgm" then
        music_path[audioname] = dir .. "/" .. file
      end
      --print("ℹ️ audio "..audioname.." added")
    end
  end
end

return assets