--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
    
    self.medals = {
        ['gold_medal'] = love.graphics.newImage('gold_medal.png'),
        ['silver_medal'] = love.graphics.newImage('silver_medal.png'),
        ['bronze_medal'] = love.graphics.newImage('bronze_medal.png')
    }
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')
    
    reward = nil
    
    if self.score > 3 then
    	reward = 'bronze_medal'
    	if self.score > 10 then
    		reward = 'gold_medal'
    	elseif self.score > 6 then
    		reward = 'silver_medal'
    	end
    	love.graphics.printf('You got reward!', 0, 130, VIRTUAL_WIDTH, 'center')
    	love.graphics.draw(self.medals[reward], VIRTUAL_WIDTH / 2 - 25, 160, 0, 0.5, 0.5)
	end
    
    love.graphics.printf('Press Enter to Play Again!', 0, 230, VIRTUAL_WIDTH, 'center')
end