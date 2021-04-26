Coin = Class{}


function Coin:init(params)
    -- Position in terms of x and y coordinates.
    self.x = params.x
    self.y = params.y
    
    
    self.width = 16
    self.height = 16
    
    -- Determines which frame is rendered at a particular instant.
    self.turn = 1
end

--[[
    Stop the score sound if it's already playing - so in case 2 or more coins are collected within the time frame of the audio clip, 
    the sound will play as many times.
]]
function Coin:hit()
    gSounds['score']:stop()
    gSounds['score']:play()
end

--[[
    Updates self.turn. When it moves to the next integer, the next frame is rendered. 
]]
function Coin:update(dt)
    self.turn = (self.turn % 6) + 0.25
end

--[[
    Render the coin.
]]
function Coin:render()
    love.graphics.draw(gTextures['coins'], gFrames['coins'][math.ceil(self.turn)], self.x, self.y)
end
