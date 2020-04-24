local music_source = nil

music_volume = 1
sfx_volume = 1

current_music = ""
music_fading = false
sounds = {}
local current_volume = 1
local old_volume = 1
local sound_instances = {}

function registerSound(sound, volume)
  sounds[sound] = {
    data = love.sound.newSoundData(sound_path[sound]),
    volume = volume or 1
  }
  --[[if not (sounds[sound].data) then
    sounds[sound].data = love.sound.newSoundData("assets/audio/sfx/" .. sound .. ".xm")
  end]]
end

function playSound(sound, volume, pitch)
  if doing_past_turns and not do_past_effects then return end

  if spookmode or scene == game and hasRule("?","sing","?") then
    volume = 0.01
  end

  if sounds[sound] then
    if not sound_instances[sound] then
      sound_instances[sound] = 0
    end

    local source = love.audio.newSource(sounds[sound].data, "static")

    local adjusted_volume = 1/(2^sound_instances[sound])
    source:setVolume((volume or 1) * adjusted_volume * sounds[sound].volume * sfx_volume)
    source:setPitch(pitch or 1)

    source:play()

    sound_instances[sound] = sound_instances[sound] + 1
    tick.delay(function() sound_instances[sound] = sound_instances[sound] - 1 end, sounds[sound].data:getDuration()/4)
  end
end

function playMusic(music, volume)
  if spookmode then
    volume = 0.2
    music = "sayonabab"
  end

  if music_source ~= nil then
    music_source:stop()
  end

  current_volume = volume or 1
  old_volume = volume or 1
  
  if music_path[music] then
    music_source = love.audio.newSource(music_path[music], "static")
  else
    music_source = nil
  end
  if music_source ~= nil then
    music_source:setLooping(true)
    music_source:setVolume(current_volume * music_volume)
    music_source:play()
  end

  current_music = music
end

function stopMusic()
  if music_source ~= nil then
    music_source:stop()
    current_music = ""
  end
end

function resetMusic(name,volume)
  if spookmode then
    volume = 0.01
  end
  
  music_fading = false
  if current_volume == 0 or not hasMusic() or current_music ~= name then
    playMusic(name,volume)
  else
    current_volume = volume
    old_volume = volume
  end
end

function updateMusic()
  if music_source ~= nil then
    music_source:setVolume(current_volume * music_volume)
  end
  if music_fading then
    if current_volume > 0 then
      current_volume = math.max(0, current_volume - 0.01)
    end
  else
    current_volume = old_volume;
  end
end

function hasMusic()
  return music_source ~= nil
end