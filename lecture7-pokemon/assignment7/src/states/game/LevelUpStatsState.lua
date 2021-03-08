
LevelUpStatsState = Class{__includes = BaseState}

function LevelUpStatsState:init(def)
    self.pokemon = def.pokemon
    self.initialHP = def.pokemon.HP
    self.initialAttack = def.pokemon.attack
    self.initialDefense = def.pokemon.defense
    self.initialSpeed = def.pokemon.speed
end

function LevelUpStatsState:enter(params)
    gSounds['levelup']:play()

    -- set our exp to whatever the overlap is
    self.pokemon.currentExp = self.pokemon.currentExp - self.pokemon.expToLevel
    self.HPIncrease, self.attackIncrease, self.defenseIncrease, self.speedIncrease = self.pokemon:levelUp()

    self.levelUpMenu = Menu {
        x = VIRTUAL_WIDTH/2 - 100,
        y = VIRTUAL_HEIGHT/2 - 64,
        width = 200,
        height = 128,
        drawCursor = false,
        items = {
            {
                text = string.format('HP: %d + %d = %d', self.initialHP, self.HPIncrease, self.pokemon.HP),
                onSelect = function()
                end
            },
            {
                text = string.format('Attack: %d + %d = %d', self.initialAttack, self.attackIncrease, self.pokemon.attack),
                onSelect = function()
                end
            },
            {
                text = string.format('Defense: %d + %d = %d', self.initialDefense, self.defenseIncrease, self.pokemon.defense),
                onSelect = function()
                end
            },
            {
                text = string.format('Speed: %d + %d = %d', self.initialSpeed, self.speedIncrease, self.pokemon.speed),
                onSelect = function()
                end
            },
            --{
            --    text = 'Run',
            --    onSelect = function()
            --    end
            --}
        }
    }

end

function LevelUpStatsState:update(dt)
    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        self:fadeOutWhite()
    end
end

function LevelUpStatsState:render()
    if self.levelUpMenu then
        self.levelUpMenu:render()
    else
        print('no level up menu')
    end
end

function LevelUpStatsState:fadeOutWhite()
    -- fade in
    gStateStack:push(FadeInState({
        r = 255, g = 255, b = 255
    }, 1,
            function()

                -- resume field music
                gSounds['victory-music']:stop()
                gSounds['field-music']:play()

                -- pop off the battle state
                gStateStack:pop()
                gStateStack:pop()
                gStateStack:push(FadeOutState({
                    r = 255, g = 255, b = 255
                }, 1, function() end))
            end))
end