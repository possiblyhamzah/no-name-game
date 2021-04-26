StartState = Class{__includes = BaseState}

--[[
     Nothing to be initialised here.
]]
function StartState:enter()
    
end

function StartState:update(dt)
    -- Change state to play when enter is pressed.
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['select']:play()
        gStateMachine:change('play', {highScore = nil})
    end
end

function StartState:render()
    -- Title.
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("No Name Game", 0, VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH, 'center')
    
    -- Instruction(s).
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf("Press enter to start", 0, VIRTUAL_HEIGHT / 2 + 70, VIRTUAL_WIDTH, 'center')


    -- Reset the colour.
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
end