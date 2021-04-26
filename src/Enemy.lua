Enemy = Class{}

function Enemy:init()
    self.width = 74
    self.height = 74

    -- Regulate the speed when the entity bounces off a wall (the borders of the window)
    self.speed = 480

    -- Change in speed wrt x and y axes.
    self.dx = math.random(-480, 480)
    self.dy = math.random(-480, 480)

    -- Position in terms of x and y coordinates.
    self.x = math.random(0, VIRTUAL_WIDTH - self.width)
    self.y = math.random(0, VIRTUAL_HEIGHT - self.height)

    self.health = 10
end

--[[
    Takes a bounding box as an argument, in this case it would be the ball of the monkey,
    returns true if there's overlap between the bounding boxes of this and the argument.
]]
function Enemy:collides(target)
    -- First, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

--[[
    Play the hit sound and reduce the health.
]]
function Enemy:hit()
    gSounds['hit']:play()
    self.health = math.max(0, self.health - 1)
end


function Enemy:update(dt)
    -- Update the position of the entity.
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- Randomise the movement when it hits a wall.

    angle = math.atan2(self.dy * 3.14159 / 180, self.dx * 3.14159 / 180)
    angle = angle + math.random(10, 80)
    
    if self.x <= 0 then
        self.x = 0

        self.dx = math.cos(angle * 3.14159 / 180) * self.speed
        self.dy = math.sin(angle * 3.14159 / 180) * self.speed
    end

    if self.x >= VIRTUAL_WIDTH - self.width then
        self.x = VIRTUAL_WIDTH - self.width

        self.dx = - math.cos(angle * 3.14159 / 180) * self.speed
        self.dy = math.sin(angle * 3.14159 / 180) * self.speed
    end

    if self.y <= 0 then
        self.y = 0

        self.dy = math.cos(angle * 3.14159 / 180) * self.speed
    end

    if self.y >= VIRTUAL_HEIGHT - self.height then
        self.y = VIRTUAL_HEIGHT - self.height
        
        self.dy = - math.cos(angle * 3.14159 / 180) * self.speed
    end
    
end

function Enemy:render()
    -- Render the guy.    
    love.graphics.draw(gTextures['enemy'], self.x, self.y, 0, 0.2, 0.2)
    -- love.graphics.draw(gTextures['enemy'], gFrames['enemy'][1], self.x, self.y, 0, 2, 2)
end

