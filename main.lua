require 'src/Dependencies'

--[[
    Called just once at the beginning of the game; used to set up
    game objects, variables, etc. and prepare the game world.
]]
function love.load()
    -- Set love's default filter to "nearest-neighbor", so there wouldn't be any filtering of pixels.
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Seed the RNG so calls to random are actually random.
    math.randomseed(os.time())

    -- Set the title bar.
    love.window.setTitle('enemy')

    -- Load the fonts.
    gFonts = {
        ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
        ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
    }
    love.graphics.setFont(gFonts['small'])

    -- Load the graphics.
    gTextures = {
        ['background'] = love.graphics.newImage('graphics/background.jpg'),
        ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
        ['particle'] = love.graphics.newImage('graphics/particle.png'),
        ['enemy'] = love.graphics.newImage('graphics/enemy.png'),
        ['monkey'] = love.graphics.newImage('graphics/monkey.png'),
        ['ball'] = love.graphics.newImage('graphics/ball.png'),
        ['coins'] = love.graphics.newImage('graphics/coins.png')
    }

    -- Quads we will generate for these textures, which allow us to break a single image into multiple parts
    -- and show only one part at a time.
    gFrames = {
        ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9),
        ['coins'] = GenerateQuads(gTextures['coins'], 16, 16),
    }
    
    -- Initialise our virtual resolution, which will be rendered within our actual window regardless of its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- Load the sound effects.
    gSounds = {
        ['shoot'] = love.audio.newSource('sounds/shoot.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['death'] = love.audio.newSource('sounds/death.wav', 'static'),
        ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
        ['hit'] = love.audio.newSource('sounds/hit.wav', 'static'),
        ['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
        ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),

        ['music'] = love.audio.newSource('sounds/music.wav', 'static')
    }

    -- The state machine we'll be using to transition between various states
    -- in our game instead of clumping them together in our update and draw
    -- methods.
    --
    -- Our current game state can be any of the following:
    -- 1. 'start' (the beginning of the game, where we're told to press Enter)
    -- 2. 'play' (kill the enemy)
    -- 3. 'game-over' (player has lost, restart to try again)
    -- 4. 'victory' (player has won, some music is the only reward)
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end,
        ['victory'] = function() return VictoryState() end
    }
    gStateMachine:change('start')

    -- Play the music loop it.
    gSounds['music']:play()
    gSounds['music']:setLooping(true)

    -- A table we'll use to keep track of which keys have been pressed this
    -- frame, to get around the fact that LÖVE's default callback won't let us
    -- test for input from within other functions.
    love.keyboard.keysPressed = {}
end

--[[
    Called whenever we change the dimensions of our window, as by dragging
    out its bottom corner, for example. In this case, we only need to worry
    about calling out to `push` to handle the resizing. Takes in a `w` and
    `h` variable representing width and height, respectively.
]]
function love.resize(w, h)
    push:resize(w, h)
end

--[[
    Called every frame, passing in `dt` (delta time, measured in seconds) 
    since the last frame. Multiplying this by any changes we make in the game 
    will allow it to perform consistently across all hardware.
]]
function love.update(dt)
    -- This time, we pass in dt to the state object we're currently using.
    gStateMachine:update(dt)

    -- Quite if the escape key is pressed.
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
    -- Reset keys pressed.
    love.keyboard.keysPressed = {}
end

--[[
    A callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a
    separate function (`love.keyboard.isDown`). Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)
    -- Add to our table of keys pressed this frame.
    love.keyboard.keysPressed[key] = true
end

--[[
    A custom function that will let us test for individual keystrokes outside
    of the default `love.keypressed` callback, since we can't call that logic
    elsewhere by default.
]]
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

--[[
    Called each frame after update; is responsible simply for
    drawing all of our game objects and more to the screen.
]]
function love.draw()
    -- Begin drawing with push, in our virtual resolution.
    push:apply('start')

    -- Background should be drawn regardless of state, scaled to fit our virtual resolution.
    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()

    love.graphics.draw(gTextures['background'], 
        -- Draw at coordinates 0, 0
        0, 0, 
        -- No rotation.
        0,
        -- Scale factors on X and Y axis so it fills the screen.
        VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))
    
    -- Use the state machine to defer rendering to the current state we're in.
    gStateMachine:render()
    push:apply('end')
end


--[[
    Renders the health of the entity in terms of hearts at the postion passed as parameter. 
    First renders full hearts, then empty hearts based on the health.
]]
function renderHealth(health, position)
    -- Position to start health rendering.
    local healthX = position
    
    -- Render health.
    for i = 1, health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 4)
        healthX = healthX + 11
    end

    -- Render missing health.
    for i = 1, 5 - health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)
        healthX = healthX + 11
    end
end

--[[
    Renders the player's score at the given position.
]]
function renderScore(str, score, position)
    love.graphics.setFont(gFonts['small'])
    love.graphics.print(str, position, 5)
    love.graphics.printf(tostring(score), position + string.len(str) + 15, 5, 40, 'right')
end