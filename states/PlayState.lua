--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0
	self.intervalPeriod = 2
	self.prevIntervalPeriod = 0
	self.pipeGap = 90

    -- initialize our last recorded Y value for a gap placement to base other gaps off of
    self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end

function PlayState:update(dt)
	-- check for activate of God Mode    
    listenerForGodMode()

    -- update timer for pipe spawning
    self.timer = self.timer + dt
	
    -- spawn a new pipe pair every second and a half
    if self.timer > self.intervalPeriod then
        -- modify the last Y coordinate we placed so pipe gaps aren't too far apart
        -- no higher than 10 pixels below the top edge of the screen,
        -- and no lower than a gap length from the bottom
        
        local y = math.max(-PIPE_HEIGHT + 10, 
            math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - self.pipeGap - PIPE_HEIGHT - 10))
        self.lastY = y

        -- add a new pipe pair at the end of the screen at our new Y
        table.insert(self.pipePairs, PipePair(y, self.pipeGap))

        -- reset timer
        self.timer = 0
        
        -- reset interval period and pipegap
        if self.intervalPeriod == 3.5 and self.intervalPeriod ~= self.prevIntervalPeriod then
        	self.prevIntervalPeriod = self.intervalPeriod
        	self.intervalPeriod = 3.5
        else
			self.prevIntervalPeriod = self.intervalPeriod
       	 	self.intervalPeriod = 1.7 + math.random(-1,1)/5
        	if math.random(6) == 1 then
        		self.intervalPeriod = 2.5
        	end
        	if math.random(10) == 1 then
        		self.intervalPeriod = 3.5
       		end
        end
        
        self.pipeGap = math.random(80, 105)
        if math.random(5) == 1 then
        	self.pipeGap = 130
        end
        
    end

    -- for every pair of pipes..
    for k, pair in pairs(self.pipePairs) do
        -- score a point if the pipe has gone past the bird to the left all the way
        -- be sure to ignore it if it's already been scored
        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                sounds['score']:play()
            end
        end

        -- update position of pair
        pair:update(dt)
    end

    -- we need this second loop, rather than deleting in the previous loop, because
    -- modifying the table in-place without explicit keys will result in skipping the
    -- next pipe, since all implicit keys (numerical indices) are automatically shifted
    -- down after a table removal
    for k, pair in pairs(self.pipePairs) do
        if pair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    -- simple collision between bird and all pipes in pairs
    for k, pair in pairs(self.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                sounds['explosion']:play()
                sounds['hurt']:play()

                gStateMachine:change('score', {
                    score = self.score
                })
            end
        end
    end

    -- update bird based on gravity and input
    self.bird:update(dt)

    -- reset if we get to the ground
    if self.bird.y > VIRTUAL_HEIGHT - 40 then
    	if not godMode then
        	sounds['explosion']:play()
        	sounds['hurt']:play()

        	gStateMachine:change('score', {
            	score = self.score
        	})
        else
        	self.bird.y = VIRTUAL_HEIGHT - 40
        end
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)
    
    self.bird:render()
    
    if godMode then
    	love.graphics.setColor(255, 0, 0, 255)
    	love.graphics.print('GodMode: Active', 8, 45)
    	love.graphics.setColor(255,255,255)
	end
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter()
    -- if we're coming from death, restart scrolling
    scrolling = true
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    -- stop scrolling for the death/score screen
    scrolling = false
end

function listenerForGodMode()
	if love.keyboard.keysPressedQ[3] == 'd' and love.keyboard.keysPressedQ[2] == 'd' and love.keyboard.keysPressedQ[1] == 'i' then
    	switchGodMode()
    end
end

function switchGodMode()
	if godMode == true then
    	godMode = false
    	-- chit activated, reseting of Queue of Keys 
		love.keyboard.keysPressedQ = {0,0,0}
   	else
    	godMode = true
    	-- chit activated, reseting of Queue of Keys 
		love.keyboard.keysPressedQ = {0,0,0}
    end
end