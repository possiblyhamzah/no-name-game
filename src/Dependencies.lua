-- Lbrary that allows us to draw our game at a virtual resolution, instead of 
-- the actual window size.
-- https://github.com/Ulydev/push
push = require 'lib/push'

-- Library that allows us to use classes in Lua.
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'lib/class'

-- Some global constants.
require 'src/constants'

-- The character.
require 'src/Monkey'

-- The enemy.
require 'src/Enemy'

-- The ball that is fired by the character.
require 'src/Ball'

-- The coin that is dropped by the enemy.
require 'src/Coin'

-- a basic StateMachine class which will allow us to transition to and from
-- game states smoothly and avoid monolithic code in one file
require 'src/StateMachine'

-- utility functions, mainly for splitting our sprite sheet into various Quads
-- of differing sizes for paddles, balls, bricks, etc.
require 'src/Util'


-- each of the individual states our game can be in at once; each state has
-- its own update and render methods that can be called by our state machine
-- each frame, to avoid bulky code in main.lua
require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/PlayState'
require 'src/states/GameOverState'
require 'src/states/VictoryState'