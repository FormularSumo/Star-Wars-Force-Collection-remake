Card = Class{}

function Card:init(name,row,column,team,number)
    self.name = name
    self.row = row
    self.column = column
    self.image = love.graphics.newImage('Characters/' .. self.name .. '/' .. self.name .. '.png')
    self.width = self.image:getWidth() / 8.7
    self.height = self.image:getHeight() / 8.7
    self.x = 0
    self.y = 0
    self.team = team 
    self.number = number
    self.health = 1000
    self.attack = _G[self.name]['attack']
    self.defense = _G[self.name]['defense']
    self.evade = _G[self.name]['evade']
    self.range = _G[self.name]['range']
end

function Card:update(dt,move)
    self.x = ((VIRTUAL_WIDTH / 12) * self.column) + 22 - 10
    self.y = ((VIRTUAL_HEIGHT / 6) * self.row + (self.height / 48))
    if self.column > 5 then
        self.x = self.x + 20
    end
    if move == true then
        if self.team == 1 then
            if (self.number < 6 and self.column < 5) or (self.number < 12 and self.column < 4) or (self.number < 18 and self.column < 3) then
                self.column = self.column + 1
            end
            if P1_deck[self.number-6] == nil and self.number - 6 >= 0 then
                next_round_P1_deck[self.number - 6] = P1_deck[self.number]
                next_round_P1_deck[self.number] = nil
                self.number = self.number - 6
            end
        else
            if (self.number < 6 and self.column > 6) or (self.number < 12 and self.column > 7) or (self.number < 18 and self.column > 8) then
                self.column = self.column - 1
            end
            if P2_deck[self.number-6] == nil and self.number - 6 >= 0 then
                next_round_P2_deck[self.number - 6] = P2_deck[self.number]
                next_round_P2_deck[self.number] = nil
                self.number = self.number - 6
            end
        end
    end
    if self.health <= 0 then
        if self.team == 1 then
            next_round_P1_deck[self.number] = next_round_P1_deck[self.number-6]
            next_round_P1_deck[self.number-6] = nil 
        else
            next_round_P2_deck[self.number] = next_round_P2_deck[self.number-6]
            next_round_P2_deck[self.number-6] = nil 
        end
    end    
end

function Card:render()
    love.graphics.draw(self.image,self.x,self.y,0,0.115,sx)
    love.graphics.setFont(font80SW)
    love.graphics.line(VIRTUAL_WIDTH / 2,0,VIRTUAL_WIDTH / 2,VIRTUAL_HEIGHT)
    -- love.graphics.print(self.attack, self.x, self.y)
    -- love.graphics.print(self.defense, self.x, self.y)
    -- love.graphics.print(self.evade, self.x, self.y)
    -- love.graphics.print(tostring(self.y),100,0)
end