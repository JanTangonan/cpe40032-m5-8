--[[
    CMPE40032
    Super Mario Bros. Remake

    -- StartState Class --

]]

StartState = Class{__includes = BaseState}

function StartState:init()
    self.map = LevelMaker.generate(LEVEL_WIDTH, 10)
    self.background = math.random(3)
end

function StartState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play')
    end
end

function StartState:render()
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0, 0)
    love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], 0,
        gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
    self.map:render()

    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.printf('Group Alien 8!', 1, VIRTUAL_HEIGHT / 2 - 40 + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf('Group Alien 8!', 0, VIRTUAL_HEIGHT / 2 - 40, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.printf('Press Enter', 1, VIRTUAL_HEIGHT / 2 - 25 + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT / 2 - 25, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.printf('Press 1 for Music 1', 0, VIRTUAL_HEIGHT / 2 + 20,VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf('Press 1 for Music 1', 0, VIRTUAL_HEIGHT / 2 + 20 -1,VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.printf('Press 2 for Music 2', 0, VIRTUAL_HEIGHT / 2 + 30,VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf('Press 2 for Music 2', 0, VIRTUAL_HEIGHT / 2 + 30 - 1,VIRTUAL_WIDTH, 'center')

end