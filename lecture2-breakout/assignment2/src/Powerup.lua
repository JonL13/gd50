Powerup = Class{}

function Powerup:init(x, y, type)
    -- simple positional and dimensional variables
    self.width = 16
    self.height = 16

    self.x = x
    self.y = y

    -- this impacts how quickly the powerup will fall
    self.dy = 0

    self.type = type
    self.inPlay = true
end

--[[
    Expects an argument with a bounding box, which should definitely just be the paddle
    (although I don't see why it wouldn't work with a brick other than it being really weird),
    and returns true if the bounding boxes of this and the argument overlap.
]]
function Powerup:collides(target)
    -- first, check to see if the left edge of either is farther to the right
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

function Powerup:update(dt)
    self.dy = self.dy + 1 * dt
    self.y = self.y + self.dy
end

function Powerup:render()
    -- gTexture is our global texture for all blocks
    -- gPowerups is a table of quads mapping to each individual powerup type in the texture
    love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type],
            self.x, self.y)
end