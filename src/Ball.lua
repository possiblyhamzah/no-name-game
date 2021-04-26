Ball = Class{}

function Ball:init(params)
    self.width = 8
    self.height = 8

    -- Change in speed wrt x and y axes. Orientation determines whether the ball moves to the right or the left.
    -- Projectile motion is promptly ignored.
    self.dx = params.orientation * 500

    -- Position in terms of x and y coordinates.
    self.x = params.x
    self.y = params.y

    
    -- Particle system stuff ahead (for when the ball hits the enemy).
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)

    -- Lasts between 0.5-1 seconds seconds.
    self.psystem:setParticleLifetime(0.5, 1)

    -- Give it an acceleration of somewhere between x1,y1 and x2,y2 (0, 0) and (80, 80) here 
    self.psystem:setLinearAcceleration(-15, 0, 15, 80)

    -- Fuck yeah spread it
    self.psystem:setEmissionArea('normal', 10, 10)
    
    -- Variable to determine whether a ball has hit the enemy. If it has, then this is set to true and the existence of the ball is ignored.
    --  It's useful for particle emission, as if we immediately remove the ball from the table of balls, the particle emission wouldn't take place properly. 
    self.hasHit = false
end

--[[
    Sets off particle emission.
]]
function Ball:hit()   
    self.psystem:emit(64)
end

--[[
    Updates position of the ball, and the particle system, if any.
]]
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.psystem:update(dt)
end

--[[
    Renders the ball
]]
function Ball:render()
    love.graphics.draw(gTextures['ball'], self.x, self.y, 0, 0.25, 0.25)
end

--[[
    Renders the particles
]]
function Ball:renderParticles()
    love.graphics.draw(self.psystem, self.x + 16, self.y + 8)
end