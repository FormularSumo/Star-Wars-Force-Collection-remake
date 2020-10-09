Card = Class{}

function Card:init(name,row,column)
    self.name = name
    self.row = row
    self.column = column
    self.image = love.graphics.newImage('Characters/' .. self.name .. '/' .. self.name .. '.png')
    self.width = self.image:getWidth() / 9.1
    self.height = self.image:getHeight() / 9.1
    self.health = 1000
    self.attack = _G[self.name]['attack']
    self.defense = _G[self.name]['defense']
    self.evade = _G[self.name]['evade']
    self.range = _G[self.name]['range']
end

function Card:update()
    self.x = ((VIRTUAL_WIDTH / 6) * self.column) + (self.width / 6)
    self.y = ((VIRTUAL_HEIGHT / 6) * self.row + (self.height / 6 / 4))
end

function Card:render()
    love.graphics.draw(self.image,self.x,self.y,0,0.11,sx)
    love.graphics.setFont(font80SW)
    -- love.graphics.print(self.attack, self.x, self.y)
    -- love.graphics.print(self.defense, self.x, self.y)
    -- love.graphics.print(self.evade, self.x, self.y)
    -- love.graphics.print(tostring(self.y),100,0)
end