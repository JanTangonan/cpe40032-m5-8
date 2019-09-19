--[[
    CMPE40032
    Super Mario Bros. Remake

    -- PlayState Class --
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()

    self.camX = 0
    self.camY = 0
end

function PlayState:update(dt)
    -----------------------------------------------------------
    if self.paused then
        if love.keyboard.wasPressed('p') then
            self.paused = false
            gSounds['pickup']:play()
            gSounds['music']:resume()
            gSounds['music2']:resume()
        else                                            -- this part is the pause function just like the logic from
            return                                      -- from the last module
        end
    elseif love.keyboard.wasPressed('p') then
        self.paused = true
        gSounds['pickup']:play()
        gSounds['music']:pause()
        gSounds['music2']:pause()
        --Timer.tween(2, {[overlay] = {opacity = 255} })
        return
    end
    -------------------------------------------------------------
    Timer.update(dt)

    -- remove any nils from pickups, etc.
    self.level:clear()

    -- update player and level
    self.player:update(dt)
    self.level:update(dt)

    -- constrain player X no matter which state
    if self.player.x <= 0 then
        self.player.x = 0
    elseif self.player.x > TILE_SIZE * self.tileMap.width - self.player.width then
        self.player.x = TILE_SIZE * self.tileMap.width - self.player.width
    end

    self:updateCamera()
end

function PlayState:enter(enterParams)
    if enterParams then
        levelWidth = LEVEL_WIDTH*enterParams.currentLevel
    else
        levelWidth = LEVEL_WIDTH
    end

    self.level = LevelMaker.generate(levelWidth, 10)
    self.tileMap = self.level.tileMap
    self.background = math.random(3)
    self.backgroundX = 0

    self.gravityOn = true
    self.gravityAmount = 6

    self.player = Player({
        x = 0, y = 0,
        width = 16, height = 20,
        texture = 'green-alien',
        stateMachine = StateMachine {
            ['idle'] = function() return PlayerIdleState(self.player) end,
            ['walking'] = function() return PlayerWalkingState(self.player) end,
            ['jump'] = function() return PlayerJumpState(self.player, self.gravityAmount) end,
            ['falling'] = function() return PlayerFallingState(self.player, self.gravityAmount) end
        },
        map = self.tileMap,
        level = self.level
    })

    if enterParams then
        self.player.score = enterParams.score
        self.player.currentLevel = enterParams.currentLevel + 1
    end

    print(self.player.score)
    print(self.player.currentLevel)

    self:spawnEnemies()

    self.player:changeState('falling')
end

function PlayState:render()
    if self.paused then
        love.graphics.setColor(255, 255, 255, 200)
        love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 2 - 40, 100, 70, 15)
        
        love.graphics.setColor(99, 155, 255, 255)
        love.graphics.setFont(gFonts['medium'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(gFonts['small'])
        love.graphics.printf('Press P to Continue', 0, VIRTUAL_HEIGHT / 2 , VIRTUAL_WIDTH, 'center')
    else
        love.graphics.push()
        love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX), 0)
        love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX),
            gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)
        love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256), 0)
        love.graphics.draw(gTextures['backgrounds'], gFrames['backgrounds'][self.background], math.floor(-self.backgroundX + 256),
            gTextures['backgrounds']:getHeight() / 3 * 2, 0, 1, -1)

        -- translate the entire view of the scene to emulate a camera
        love.graphics.translate(-math.floor(self.camX), -math.floor(self.camY))

        self.level:render()

        self.player:render()
        love.graphics.pop()

        -- render score
        

        love.graphics.setFont(gFonts['medium'])
        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.print(tostring(self.player.score), 5, 5)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(tostring(self.player.score), 4, 4)
        ---------------------------------------
        love.graphics.setFont(gFonts['small'])
        love.graphics.setColor(99, 155, 255, 255)
        love.graphics.print("Level - " .. tostring(self.player.currentLevel), 5, VIRTUAL_HEIGHT - 15)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print("Level - " .. tostring(self.player.currentLevel), 4, VIRTUAL_HEIGHT - 16)

        love.graphics.setFont(gFonts['small'])
        love.graphics.setColor(99, 155, 255, 255)
        love.graphics.printf('Press P to pause', 0, 8, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.printf('Press P to pause', 0, 7, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:updateCamera()
    -- clamp movement of the camera's X between 0 and the map bounds - virtual width,
    -- setting it half the screen to the left of the player so they are in the center
    self.camX = math.max(0,
        math.min(TILE_SIZE * self.tileMap.width - VIRTUAL_WIDTH,
        self.player.x - (VIRTUAL_WIDTH / 2 - 8)))

    -- adjust background X to move a third the rate of the camera for parallax
    self.backgroundX = (self.camX / 3) % 256
end

--[[
    Adds a series of enemies to the level randomly.
]]
function PlayState:spawnEnemies()
    -- spawn snails in the level
    for x = 1, self.tileMap.width do

        -- flag for whether there's ground on this column of the level
        local groundFound = false

        for y = 1, self.tileMap.height do
            if not groundFound then
                if self.tileMap.tiles[y][x].id == TILE_ID_GROUND then
                    groundFound = true

                    -- random chance, 1 in 20
                    if math.random(20) == 1 then

                        -- instantiate snail, declaring in advance so we can pass it into state machine
                        local snail
                        snail = Snail {
                            texture = 'creatures',
                            x = (x - 1) * TILE_SIZE,
                            y = (y - 2) * TILE_SIZE + 2,
                            width = 16,
                            height = 16,
                            stateMachine = StateMachine {
                                ['idle'] = function() return SnailIdleState(self.tileMap, self.player, snail) end,
                                ['moving'] = function() return SnailMovingState(self.tileMap, self.player, snail) end,
                                ['chasing'] = function() return SnailChasingState(self.tileMap, self.player, snail) end
                            }
                        }
                        snail:changeState('idle', {
                            wait = math.random(5)
                        })

                        table.insert(self.level.entities, snail)
                    end
                end
            end
        end
    end
end