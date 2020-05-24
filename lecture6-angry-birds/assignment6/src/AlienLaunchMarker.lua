--[[
    GD50
    Angry Birds

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

AlienLaunchMarker = Class{}

function AlienLaunchMarker:init(world)
    self.world = world

    -- starting coordinates for launcher used to calculate launch vector
    self.baseX = 90
    self.baseY = VIRTUAL_HEIGHT - 100

    -- shifted coordinates when clicking and dragging launch alien
    self.shiftedX = self.baseX
    self.shiftedY = self.baseY

    -- rotation for the trajectory arrow
    self.rotation = 0

    -- whether our arrow is showing where we're aiming
    self.aiming = false

    -- whether we launched the alien and should stop rendering the preview
    self.launched = false

    -- our alien we will eventually spawn
    self.aliens = {}
end

function AlienLaunchMarker:update(dt)
    
    -- perform everything here as long as we haven't launched yet
    if not self.launched then

        -- grab mouse coordinates
        local x, y = push:toGame(love.mouse.getPosition())
        
        -- if we click the mouse and haven't launched, show arrow preview
        if love.mouse.wasPressed(1) and not self.launched then
            self.aiming = true

        -- if we release the mouse, launch an Alien
        elseif love.mouse.wasReleased(1) and self.aiming then
            self.launched = true

            -- spawn new alien in the world, passing in user data of player
            local alien = Alien(self.world, 'round', self.shiftedX, self.shiftedY, {type = 'Player', hasCollided = false, isSplittable = true})
            alien.body:setLinearVelocity((self.baseX - self.shiftedX) * 10, (self.baseY - self.shiftedY) * 10)
            alien.body:setAngularDamping(1)
            alien.fixture:setRestitution(0.4) -- make the alien pretty bouncy
            table.insert(self.aliens, alien)

            -- we're no longer aiming
            self.aiming = false

        -- re-render trajectory
        elseif self.aiming then
            self.rotation = self.baseY - self.shiftedY * 0.9
            self.shiftedX = math.min(self.baseX + 30, math.max(x, self.baseX - 30))
            self.shiftedY = math.min(self.baseY + 30, math.max(y, self.baseY - 30))
        end
    elseif self.launched and love.keyboard.wasPressed('space') then
        for k, alien in pairs(self.aliens) do
            if alien.fixture:getUserData().isSplittable == true and alien.fixture:getUserData().hasCollided == false then
                local velX, velY = alien.body:getLinearVelocity()

                local higherAlien = Alien(self.world, 'round', alien.body:getX(), alien.body:getY() - 50, {type = 'Player', hasCollided = false, isSplittable = false})
                higherAlien.body:setLinearVelocity(velX, velY - 50)
                higherAlien.body:setAngularDamping(1)
                higherAlien.fixture:setRestitution(.4)
                higherAlien.launched = true
                table.insert(self.aliens, higherAlien)

                local lowerAlien = Alien(self.world, 'round', alien.body:getX(), alien.body:getY() + 50, {type = 'Player', hasCollided = false, isSplittable = false})
                lowerAlien.body:setLinearVelocity(velX, velY + 50)
                lowerAlien.body:setAngularDamping(1)
                lowerAlien.fixture:setRestitution(.4)
                lowerAlien.launched = true
                table.insert(self.aliens, lowerAlien)

                alien.fixture:getUserData().isSplittable = false
            end
        end
    end
end

function AlienLaunchMarker:render()
    if not self.launched then
        -- render base alien, non physics based
        love.graphics.draw(gTextures['aliens'], gFrames['aliens'][9], 
            self.shiftedX - 17.5, self.shiftedY - 17.5)

        if self.aiming then
            
            -- render arrow if we're aiming, with transparency based on slingshot distance
            local impulseX = (self.baseX - self.shiftedX) * 10
            local impulseY = (self.baseY - self.shiftedY) * 10

            -- draw 6 circles simulating trajectory of estimated impulse
            local trajX, trajY = self.shiftedX, self.shiftedY
            local gravX, gravY = self.world:getGravity()

            -- http://www.iforce2d.net/b2dtut/projected-trajectory
            for i = 1, 90 do
                
                -- magenta color that starts off slightly transparent
                love.graphics.setColor(255, 80, 255, (255 / 12) * i)
                
                -- trajectory X and Y for this iteration of the simulation
                trajX = self.shiftedX + i * 1/60 * impulseX
                trajY = self.shiftedY + i * 1/60 * impulseY + 0.5 * (i * i + i) * gravY * 1/60 * 1/60

                -- render every fifth calculation as a circle
                if i % 5 == 0 then
                    love.graphics.circle('fill', trajX, trajY, 3)
                end
            end
        end
        
        love.graphics.setColor(255, 255, 255, 255)
    else
        for k, alien in pairs(self.aliens) do
            alien:render()
        end
    end
end