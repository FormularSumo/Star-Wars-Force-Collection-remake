GameState = Class{__includes = BaseState}
timer = -1
timer2 = -1

function GameState:init()
    sounds['Imperial March piano only']:pause()
    sounds['Imperial March duet']:pause()
    sounds['cool music']:play()
    sand_dunes:play()

    -- love.filesystem.remove('Player 1 deck.txt')
    P1_deck_file = love.filesystem.read('Player 1 deck.txt')
    P1_deck_cards_original = split(P1_deck_file,',')

    for k, pair in pairs(P1_deck_cards_original) do  
        P1_deck_cards[k-1] = pair
    end

    P1column = -1
    P2column = 12
    row_correctment = 0
    for i=0,17,1 do
        if i % 6 == 0 and i ~= 0 then
            P1column = -1 - i / 6 
            P2column = 12 + i / 6 
            row_correctment = i
        end
        row = i - row_correctment
        if P1_deck_cards[i] ~= none then
            P1_deck[i] = Card(P1_deck_cards[i],row,P1column,1,i)
        end
        if P2_deck_cards[i] ~= none then
            P2_deck[i] = Card(P2_deck_cards[i],row,P2column,2,i)
        end
    end
    next_round_P1_deck = P1_deck
    next_round_P2_deck = P2_deck
    P1_deck[0].health = 0
    P1_deck[2].health = 0 
    P1_deck[8].health = 0 
    P1_deck[14].health = 0 
    P1_deck[3].health = 990
end

function GameState:update(dt)
    timer = timer + dt 
    timer2 = timer2 + dt
    if timer >= 1 then
        timer = timer - 1
        move = true
        P1_deck = next_round_P1_deck
        P2_deck = next_round_P2_deck
        if timer2 > 3 then
            if P1_deck[2] == nil and P1_deck[8] == nil and P1_deck[14] == nil then
                x = 1
                for i=0,2,1 do
                    if P1_deck[x] ~= nil then
                        P1_deck[x].row = 2
                        P1_deck[x+1] = P1_deck[x]
                        P1_deck[x+1].number = x+1
                        P1_deck[x] = nil
                        x = x + 6
                    end
                end

                -- P1_deck[7].row = 2
                -- P1_deck[13].row = 2
                -- P1_deck[8] = P1_deck[7]
                -- P1_deck[14] = P1_deck[13]
                -- P1_deck[2].number = 2
                -- P1_deck[8].number = 8
                -- P1_deck[14].number = 14
                -- ,P1_deck[7],P1_deck[13] = nil
            end
            if P1_deck[1] == nil and P1_deck[7] == nil and P1_deck[13] == nil then
                x = 0
                for i=0,2,1 do
                    if P1_deck[x] ~= nil then
                        P1_deck[x].row = 1
                        P1_deck[x+1] = P1_deck[x]
                        P1_deck[x+1].number = x+1
                        P1_deck[x] = nil
                        x = x + 6
                    end
                end

                -- P1_deck[0].row = 1
                -- P1_deck[6].row = 1
                -- P1_deck[12].row = 1    
                -- P1_deck[1] = P1_deck[0]
                -- P1_deck[7] = P1_deck[6]
                -- P1_deck[13] = P1_deck[12]
                -- P1_deck[1].number = 1
                -- P1_deck[7].number = 7
                -- P1_deck[13].number = 13
                -- P1_deck[0],P1_deck[6],P1_deck[12] = nil
            end
        end
    else
        move = false
    end
    for k, pair in pairs(P1_deck) do
        P1_deck[k]:update(dt,move)
    end 
    for k, pair in pairs(P2_deck) do
        P2_deck[k]:update(dt,move)
    end 
    if love.keyboard.wasPressed('m') then 
        if sounds['cool music']:isPlaying() then
            sounds['cool music']:pause()
        else
            sounds['cool music']:play()
        end
    end                   
end

function GameState:render()
    love.graphics.draw(sand_dunes,0,0)
    -- love.graphics.draw(desert_background)
    for k, pair in pairs(P1_deck) do
        P1_deck[k]:render()
    end
    for k, pair in pairs(P2_deck) do
        P2_deck[k]:render()
    end
    -- love.graphics.setFont(font50)
    -- love.graphics.setColor(0, 255, 0, 255)
    -- love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    -- love.graphics.setColor(255, 255, 255, 255)
    -- love.graphics.setFont(font80SW)
end
