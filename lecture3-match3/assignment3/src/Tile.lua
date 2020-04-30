--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety, shiny)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety

    self.isShiny = shiny
    self.shinyColor = 255
    self.shinyModifier = 1
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    -- draw shiny overlay
    if self.isShiny then
        love.graphics.setColor(self.shinyColor, self.shinyColor, self.shinyColor, 255)
        love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
                self.x + x, self.y + y)
        love.graphics.setColor(255, 255, 255, 255)
    end
end

function Tile:setShinyColor()
    self.shinyColor = self.shinyColor + self.shinyModifier
    if self.shinyColor >= 253 then
        self.shinyModifier = -2
    elseif self.shinyColor <= 150 then
        self.shinyModifier = 2
    end
end