Monkey = Class{}


function Monkey:init()

    -- Start with the character in the middle of the screen.
    self.x = VIRTUAL_WIDTH / 2 - 33
    self.y = VIRTUAL_HEIGHT /2 - 39

    -- Start off with no velocity
    self.dx = 0
    self.dy = 0

    -- Starting dimensions
    self.width = 33
    self.height = 39

    -- Orientation determines which way our character faces. 1 corresponds to right, -1 to left.
    self.orientation = -1

    self.health = 5

    -- Determines whether or not the character is in contact with the enemy. 
    -- Since the health is deducted once for each time the character comes in contact with the enemy, we keep track if it's in contact 
    -- and reduce the health only if it wasn't previously in contact with the character.
    self.incontact = false
    
    -- Go invulnerable for 1 second (which means that once the enemy hits the character, any further hits within a span of 1 second will be disregarded)
    self.invulnerable = false
    self.invulnerableDuration = 0
    self.invulnerableTimer = 0
    self.flashTimer = 0

    self.speed = 200

end

function Monkey:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if target.x > self.x + self.width * math.max(0, self.orientation) or self.x + self.width * math.min(0, self.orientation) > target.x + target.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if target.y > self.y + self.height or self.y > target.y + target.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

function Monkey:goInvulnerable(duration)
    self.invulnerable = true
    self.invulnerableDuration = duration
end

--[[
    Reduce the health and go invulnerable for a second.
]]
function Monkey:hit()
    if self.incontact == false and self.invulnerable == false then
        if self.health ~= 0 then
            gSounds['hurt']:play()
        end
        self.health = math.max(0, self.health - 1)
        self:goInvulnerable(1)
    end

    self.incontact = true
end

--[[
    Update position and invulnerability.
]]
function Monkey:update(dt)

    -- Update variables if charachter is invulnerable
    if self.invulnerable then
        self.flashTimer = self.flashTimer + dt
        self.invulnerableTimer = self.invulnerableTimer + dt

        -- If the time limit for invulnerability has been reached, set self.invulnerable to false and reset all the other variables.
        if self.invulnerableTimer > self.invulnerableDuration then
            self.invulnerable = false
            self.invulnerableTimer = 0
            self.invulnerableDuration = 0
            self.flashTimer = 0
        end
    end

    -- Keyboard input
    if love.keyboard.isDown('left') then
        self.dx = -self.speed
        self.orientation = -1
    elseif love.keyboard.isDown('right') then
        self.dx = self.speed
        self.orientation = 1
    elseif love.keyboard.isDown('up') then
        self.dy = -self.speed
    elseif love.keyboard.isDown('down') then
        self.dy = self.speed
    else
        self.dx = 0
        self.dy = 0
    end


    -- Prevent the character from going beyond the window of play.
    if self.dx < 0 then
        self.x = math.max(self.width, self.x + self.dx * dt)
    else
        self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
    end

    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

--[[
    Render the character.
]]
function Monkey:render()

    -- Make the character slightly transparent if it's invulnerable.
    if self.invulnerable and self.flashTimer > 0.06 then
        self.flashTimer = 0
        love.graphics.setColor(255/255, 255/255, 255/255, 64/255)
    end

    love.graphics.draw(gTextures['monkey'], self.x, self.y, 0, self.orientation, 1)

    -- Reset the colour.
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)

end