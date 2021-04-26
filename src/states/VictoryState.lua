VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
    self.enemy = params.enemy
    self.monkey = params.monkey
    self.score = params.score
    self.highScore = params.highScore
end

function VictoryState:update(dt)

    -- Change to play state when enter is pressed.
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        local score = nil
        -- If a previous high score exists, then pass the higher of the current score and high score to the play state as high score.
        -- If a previous high score doesn't exist, make the current score as the high score.
        if self.highScore then
            score = math.max(self.score,self.highScore)
        else
            score = self.score
        end
        gSounds['select']:play()

        -- Stop the tracks that may be playing and play the background music, and loop it.
        gSounds['high-score']:stop()
        gSounds['victory']:stop()
        gSounds['music']:play()
        gSounds['music']:setLooping(true)
        
        gStateMachine:change('play', {highScore = score})
    end
end

function VictoryState:render()
    -- Render the character and the enemy.
    self.monkey:render()
    self.enemy:render()

    renderHealth(self.monkey.health, 100)

    renderHealth(math.ceil(self.enemy.health / 2), VIRTUAL_WIDTH - 100)

    -- Level complete text
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("You Win!",
        0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('This game is shit and has no levels. Press enter to restart the fuckery.', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
end