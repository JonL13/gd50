--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.balls = params.balls
    self.level = params.level
    self.powerups = params.powerups

    self.recoverPoints = 5000
    self.lengthenPoints = self.score + 2000


    -- give ball random starting velocity
    for k, ball in pairs(self.balls) do
        ball.dx = math.random(-200, 200)
        ball.dy = math.random(-80, -120)
    end
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') or love.keyboard.wasPressed(' ') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') or love.keyboard.wasPressed(' ') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    for k, ball in pairs(self.balls) do
        ball:update(dt)
    end

    for k, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))

                -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end
    end


    -- powerup collisions
    for k, powerup in pairs(self.powerups) do
        if powerup:collides(self.paddle) then
            if powerup.inPlay then
                if powerup.type == 9 then
                    for i = 1, 2 do
                        local ball = Ball()
                        ball.skin = math.random(7)
                        ball.dx = math.random(-200, 200)
                        ball.dy = math.random(-80, -120)
                        ball.x = powerup.x
                        ball.y = powerup.y
                        table.insert(self.balls, ball)
                    end
                elseif powerup.type == 10 then
                    for k, brick in pairs(self.bricks) do
                        if brick.isLocked == 1 then
                            brick.isLocked = 0
                            break
                        end
                    end
                end
            end

            powerup.inPlay = false
            powerup = nil
        end
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do

        for j, ball in pairs(self.balls) do
            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                -- add to score
                if brick.isLocked == 0 then
                    --this is a block that has been unlocked
                    self.score = self.score + 2500
                else
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)
                end

                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = math.min(self.recoverPoints + 100000, self.recoverPoints + (self.recoverPoints * 2))

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                if self.score > self.lengthenPoints then
                    self.lengthenPoints = self.lengthenPoints + LENGTHEN_POINTS
                    if self.paddle.size < 4 then
                        self.paddle.size = self.paddle.size + 1
                    end
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.balls[1],
                        recoverPoints = self.recoverPoints
                    })
                end

                -- generate powerup
                local powerupChance = math.random(0, 100)
                if powerupChance >= 50 then
                    local powerupType = 9
                    -- if a locked block is left, we'll generate the key powerup
                    for k, brick in pairs(self.bricks) do
                        if brick.isLocked == 1 then
                            powerupType = 10
                            break
                        end
                    end

                    if math.random(2) == 2 then
                        powerupType = 9
                    end

                    powerup = Powerup(brick.x + brick.width/2 - 8, brick.y + brick.height, powerupType)
                    table.insert(self.powerups, powerup)
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then

                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8

                    -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                    -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then

                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32

                    -- top edge if no X collisions, always check
                elseif ball.y < brick.y then

                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8

                    -- bottom edge if no X collisions or top collision, last possibility
                else

                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    for k, ball in pairs(self.balls) do
        if ball.y >= VIRTUAL_HEIGHT then
            self.balls[k] = nil
            if tableLength(self.balls) <= 0 then
                self.health = self.health - 1

                if self.paddle.size > 1 then
                    self.paddle.size = self.paddle.size - 1
                end

                gSounds['hurt']:play()

                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        powerups = self.powerups,
                        recoverPoints = self.recoverPoints
                    })
                end
            end
        end
    end



    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    for k, powerup in pairs(self.powerups) do
       powerup:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    for k, powerup in pairs(self.powerups) do
        if powerup.inPlay then
            powerup:render()
        end
    end


    self.paddle:render()

    for k, ball in pairs(self.balls) do
        ball:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    if love.keyboard.wasPressed('w') then
        return true
    end

    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end

--local function createNewBalls(numberOfBalls)
--    for i = 1, numberOfBalls do
--        local ball = Ball()
--        ball.skin = math.random(7)
--        ball.dx = math.random(-200, 200)
--        ball.dy = math.random(-80, -120)
--        table.insert(self.balls, ball)
--    end
--
--end

