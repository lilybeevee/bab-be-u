function love.conf(t)
    t.identity = "bab"
    t.window.icon = "assets/sprites/ui/baboutline.png"
    t.version = "11.1"
    t.release = false
    t.window.title = 'bab be u'
    t.window.resizable = true
    t.window.vsync = false
    t.window.minwidth = 640
    t.window.minheight = 360

    --t.gammacorrect = true
    --t.window.msaa = 4

    t.modules.joystick = false
    t.modules.physics = false
    t.modules.video = false

    t.console = false -- i mean, why turn it off?
    -- because it looks weird and unprofessional to non-devs. just launch the game with lovec
end
