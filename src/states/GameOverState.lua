GameOverState = Class{__includes = BaseState}

function GameOverState:enter(params)
    self.enemy = params.enemy
    self.monkey = params.monkey
    self.highScore = params.highScore
end

function GameOverState:update(dt)
    -- Change to play state when enter is pressed.
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['select']:play()
        gSounds['music']:play()
        gStateMachine:change('play', {highScore = self.highScore})
    end
end

function GameOverState:render()
    -- Render the character and the enemy.
    self.monkey:render()
    self.enemy:render()

    renderHealth(self.monkey.health, 100)

    renderHealth(math.ceil(self.enemy.health / 2), VIRTUAL_WIDTH - 100)

    -- Game over text.
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('GAME OVER', 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
    
    -- Instruction(s)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press enter to play again', 0, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 4,
        VIRTUAL_WIDTH, 'center')
end