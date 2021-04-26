PlayState = Class{__includes = BaseState}

--[[
    We initialise what's in our PlayState via a state table that we pass between states.
]]

function PlayState:enter(params)
    
    -- Initialise the character and the enemy.
    self.monkey = Monkey()
    self.enemy = Enemy()

    -- The table of balls.
    self.balls = {}

    -- The table of balls.
    self.coins = {}

    -- Score and high score.
    self.score = 0
    self.highScore = params.highScore
end

function PlayState:update(dt)
    -- Shoot a ball from the characters position when space is pressed.
    if love.keyboard.wasPressed('space') then
        gSounds['shoot']:play()
        table.insert(self.balls, Ball({x = self.monkey.x - (self.monkey.width / 2), y = self.monkey.y + (self.monkey.height / 2), orientation = self.monkey.orientation}))

    end

    -- Drop coins from the enemy with a probability of 1/50 per instant.
    if math.random(0, 50) == 0 then
        table.insert(self.coins, Coin({x = self.enemy.x + self.enemy.width/2, y = self.enemy.y + self.enemy.height/2}))
    end

    for k, ball in pairs(self.balls) do
        ball:update(dt)

        -- Remove ball from the table if it goes outside the bounds.
        if ball.x < 0 or ball.x > VIRTUAL_WIDTH then
            table.remove(self.balls, k)
        end

        -- Determine whether a ball has hit the enemy.
        if self.enemy:collides(ball) and not ball.hasHit then
            ball:hit()
            ball.hasHit = true
            ball.dx = 0
            ball.dy = 0
            self.score = self.score + 25
            self.enemy:hit()

            -- Change the state to victory if the health of the enemy drops to 0 i.e. the enemy has been defeated.
            if self.enemy.health == 0 then
                gSounds['music']:stop()

                -- Play the appropriate track.
                if self.highScore and self.score > self.highScore then
                    gSounds['high-score']:play()
                else
                    gSounds['victory']:play()
                end

                gStateMachine:change('victory', {
                    enemy = self.enemy,
                    monkey = self.monkey,
                    score = self.score,
                    highScore = self.highScore
                })
            end
        end
    end

    self.monkey:update(dt)
    self.enemy:update(dt)

    if self.monkey:collides(self.enemy) then
        self.monkey:hit()

        -- Change the state to game over if the health of the enemy drops to 0 i.e. the character has been defeated.
        if self.monkey.health == 0 then
            gSounds['death']:play()
            gSounds['music']:stop()

            gStateMachine:change('game-over', {
                enemy = self.enemy,
                monkey = self.monkey,
                highScore = self.highScore
            })
        end
    else
        -- Set incontact to true, so that the character's health will be deducted only if it wansn't already in contact with the enemy.
        self.monkey.incontact = false
    end

    for k, coin in pairs(self.coins) do
        coin:update(dt)

        -- Check for coin collection
        if self.monkey:collides(coin) then
            coin:hit()
            self.score = self.score + 50

            -- Remove the coin once it has been collected.
            table.remove(self.coins, k)
        end
    end
end

function PlayState:render()

    -- Render the balls.
    for k, ball in pairs(self.balls) do
        if not ball.hasHit then
            ball:render()
        end
    end
    
    -- Render the coins.
    for k, coin in pairs(self.coins) do
        coin:render()
    end   
     

    -- Render the protagonist and the antagonist.
    self.monkey:render()
    self.enemy:render()


    -- Render the particles.    
    for k, ball in pairs(self.balls) do
        ball:renderParticles()
    end

    -- Render the health of the character on the left, the enemy on the right.
    renderHealth(self.monkey.health, 50)
    renderHealth(math.ceil(self.enemy.health / 2), VIRTUAL_WIDTH - 100)
    renderScore('Score', self.score, VIRTUAL_WIDTH/2 - 100)

    if self.highScore then
        renderScore('High Score', self.highScore, VIRTUAL_WIDTH/2 + 10)
    end
end
