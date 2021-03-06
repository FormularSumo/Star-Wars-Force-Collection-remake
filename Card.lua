Card = Class{__includes = BaseState}

function Card:init(name,row,column,team,number)
    self.name = name
    self.row = row
    self.column = column
    self.image = love.graphics.newImage('Characters/' .. self.name .. '/' .. self.name .. '.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.x = -self.width
    self.y = -self.height
    self.team = team 
    self.number = number
    self.health = 1000
    self.offense = _G[self.name]['offense']
    self.defense = _G[self.name]['defense']
    self.evade = _G[self.name]['evade']
    self.range = _G[self.name]['range']
    self.laser_colour = _G[self.name]['laser_colour']
    if self.laser_colour == 'Red' then
        self.laser_image = RedLaser
    elseif self.laser_colour == 'Blue' then
        self.laser_image = BlueLaser
    else
        self.laser_image = GreenLaser
    end
    self.alive = true
    self.attack_roll = 0
    self.ranged_attack_roll = 0
    self.possible_targets = {}
    self.dodge = 0
    self.attacks_taken = 0
    if self.team == 1 then
        self.enemy_deck = P2_deck
        self.laser = P1_lasers
    else
        self.enemy_deck = P1_deck
        self.laser = P2_lasers
    end
    self.damage = 0
    self.defence_down = 0
end

function Card:update(dt,timer)
    self.x = ((VIRTUAL_WIDTH / 12) * self.column) + 22 - 20
    self.y = ((VIRTUAL_HEIGHT / 6) * self.row + (self.height / 48))
    if self.column > 5 then
        self.x = self.x + 40
    end
    if self.health <= 0 and self.alive == true then
        if self.team == 1 then
            next_round_P1_deck[self.number] = nil
        else
            next_round_P2_deck[self.number] = nil
        end 
        self.alive = false
    end
    if timer > 6 then
        if self.team == 1 then
            self.number = self.row + (math.abs(6 - self.column)) * 6 - 6
        else
            self.number = self.row + (self.column - 5) * 6 - 6
        end
    end
    if self.laser ~= nil then
        self.laser:update(dt)
    end
end

function Card:move()
    if self.team == 1 then
        if (self.number < 6 and self.column < 5) or (self.number < 12 and self.column < 4) or (self.number < 18 and self.column < 3) then
            self.column = self.column + 1
        end
        if next_round_P1_deck[self.number-6] == nil and self.number - 6 >= 0 then
            self.column = self.column + 1
            next_round_P1_deck[self.number-6] = next_round_P1_deck[self.number]
            next_round_P1_deck[self.number] = nil
        end
    else
        if (self.number < 6 and self.column > 6) or (self.number < 12 and self.column > 7) or (self.number < 18 and self.column > 8) then
            self.column = self.column - 1
        end
        if next_round_P2_deck[self.number-6] == nil and self.number - 6 >= 0 then
            self.column = self.column - 1
            next_round_P2_deck[self.number-6] = next_round_P2_deck[self.number]
            next_round_P2_deck[self.number] = nil
        end
    end
end

function Card:distance(target)
    return math.abs(self.column - self.enemy_deck[target].column) + math.abs(self.row - self.enemy_deck[target].row)
end

function Card:aim()
    if self.column == 5 or self.column == 6 then
        if self.enemy_deck[self.number] ~= nil then
            self.target = self.number
        elseif self.enemy_deck[self.number-1] ~= nil and (self.enemy_deck[self.number-1].column == 6 or self.enemy_deck[self.number-1].column == 5) then
            self.target = self.number-1
        elseif self.enemy_deck[self.number+1] ~= nil and (self.enemy_deck[self.number+1].column == 6 or self.enemy_deck[self.number+1].column == 6) then 
            self.target = self.number+1
        end
    else
        if self.range > 1 then
            self.possible_targets = {}
            self.total_probability = 0
            i = 0
            for k, pair in pairs(self.enemy_deck) do
                distance = self:distance(k)
                if distance <= self.range then
                    self.possible_targets[k] = self.total_probability + self.range/distance
                    self.total_probability = self.total_probability + self.range/distance
                end
                i = i + 1
            end
            self.ranged_attack_roll = math.random() * self.total_probability
            i = 0
            for k, pair in pairs(self.possible_targets) do
                if self.ranged_attack_roll < self.possible_targets[k] then
                    self.target = k
                    break
                end
            end
            self.centrex = self.x + self.width / 2
            self.centrey = self.x + self.height / 2
            if self.target ~= nil then
                self.laser = Laser(self.x, self.y, self.enemy_deck[self.target].x, self.enemy_deck[self.target].y, self.laser_image, self.team, self.width, self.height)
            end
        end
    end
end

function Card:attack()
    if self.target ~= nil then
        self.attack_roll = math.random(100) / 100
        self.enemy_deck[self.target].attacks_taken = self.enemy_deck[self.target].attacks_taken + 1
        if self.attack_roll > self.enemy_deck[self.target].evade then
            self.damage = ((self.offense - self.enemy_deck[self.target].defense) / 800)
            if self.damage < 0 then self.damage = 0 end
            self.damage = (self.damage ^ 3)
            self.defence_down = (self.offense / 100) * (self.offense / self.enemy_deck[self.target].defense) ^ 3
            if self.target ~= self.number then 
                self.damage = self.damage / 2 
                self.defence_down = self.defence_down / 2 
            end
            self.enemy_deck[self.target].health = self.enemy_deck[self.target].health - (self.damage + 1)
            if self.enemy_deck[self.target].defense > 0 then
                self.enemy_deck[self.target].defense = self.enemy_deck[self.target].defense - self.defence_down
                if self.enemy_deck[self.target].defense < 0 then self.enemy_deck[self.target].defense = 0 end
            else
                self.enemy_deck[self.target].defense = 0
            end
        else
            self.enemy_deck[self.target].dodge = self.enemy_deck[self.target].dodge + 1
        end
        self.target = nil
    end
    self.laser = nil
end

function Card:render()
    love.graphics.draw(self.image,self.x,self.y,0,1,sx)
    if self.health < 1000 then
        love.graphics.setColor(0.3,0.3,0.3)
        love.graphics.rectangle('fill',self.x-2,self.y-4,self.width+4,10,5,5)
        self.colour = self.dodge / self.attacks_taken
        self.colour = self.colour + (1-self.colour) / 2 --Proportionally increases brightness of self.colour so it's between 0.5 and 1 rather than 0 and 1 
        if self.dodge == 0 then
            love.graphics.setColor(1,0.82,0)
        else
            love.graphics.setColor(self.colour,self.colour,self.colour)
        end
        love.graphics.rectangle('fill',self.x-2,self.y-4,(self.width+4)/(1000/self.health),10,5,5)
        love.graphics.setColor(1,1,1)
    end

    -- if self.number == 13 and self.team == 1 then
        -- love.graphics.print(self.laser.angle)
        -- love.graphics.print(self:distance(1))
        -- x = 0
        -- for k, pair in pairs(self.possible_targets) do
        --     x = x + 100
        --     love.graphics.print(k,0,x)
        -- end
        -- love.graphics.print(self.laser_colour)
    -- end

    -- if self.number == 15 then
    --     if self.team == 1 then
    --         if self.possible_targets ~= nil then
    --             y = 100
    --             for k, pair in pairs(self.possible_targets) do
    --                 y = y + 100
    --                 love.graphics.print(tostring(k) .. ' ' .. tostring(pair),0,y)
    --                 love.graphics.print(self.ranged_attack_roll,800,100)
    --                 love.graphics.print(self.total_probability,0,100)
    --             end
    --         end
    --         love.graphics.print(self.name,0,0)
    --     end
    -- end
    -- if self.number == 2 then
    --     if self.team == 2 then
    --         love.graphics.print(self.attacks_taken)
    --         love.graphics.print(self.defense,0,100)
    --     end
    -- end
    --         love.graphics.print(self.damage)
    --         love.graphics.print(self.defence_down,0,100)
    --         love.graphics.print(self.defense,0,200)
    --     elseif self.team == 2 then
    --         love.graphics.print(self.damage,1600)
    --         love.graphics.print(self.defence_down,1600,100)
    --         love.graphics.print(self.defense,1600,200)
    --     end       
    -- end
    -- love.graphics.line(VIRTUAL_WIDTH / 2,0,VIRTUAL_WIDTH / 2,VIRTUAL_HEIGHT)
    -- love.graphics.print(self.offense, self.x, self.y)
    -- love.graphics.print(self.defense, self.x, self.y)
    -- love.graphics.print(self.evade, self.x, self.y)
    -- love.graphics.print(tostring(self.y),100,0)
end