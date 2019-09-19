--[[
    Hello my name is Jan Arvin Tangonan
    Group 8 Bs CpE 2 - 1
    and this is the screen cast of our Mario modification

    these are the task

    •   generate a random-colored key and lock block 

    •   trigger a goal post to spawn at the end of the level

    •	When the player touches this goal post, we should regenerate the level

    we still added the features we added during the past modules

    nwo lets try the game !
]]

require 'src/Dependencies'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(gFonts['medium'])
    love.window.setTitle(' Super Alien Bros.')

    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end
    }
    gStateMachine:change('start')

    --[[gSounds['music']:setLooping(true)
    gSounds['music']:setVolume(0.5)
    gSounds['music']:play()]]

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)

    if key == '1' then
        gSounds['music']:setLooping(true)
        gSounds['music2']:stop()
        gSounds['music']:play()
                                                        -- just like the last module, i set 2 sound tracks so that 
    elseif key == '2' then                              -- the player can choose music according to his/her taste
        gSounds['music2']:setLooping(true)
        gSounds['music']:stop()
        gSounds['music2']:play()
    end
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    gStateMachine:render()
    push:finish()
end