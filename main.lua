push = require 'push'

Class = require 'class'

require 'Card'
require 'Button'
require 'Characters/Character stats'
require 'StateMachine'
require 'states/BaseState'
require 'states/GameState'
require 'states/HomeState'

function love.load()
    -- app window title
    love.window.setTitle('Star Wars Force Collection Remake')
    
    VIRTUAL_WIDTH = 1920
    VIRTUAL_HEIGHT = 1080

    math.randomseed(os.time()) --Randomises randomiser each time program is run. 

    -- initialize virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, 0, 0, {
        vsync = true,
        fullscreen = true,
        resizable = true
    })

    -- load fonts
    font50 = love.graphics.newFont(50)
    font80 = love.graphics.newFont(80)
    font80SW = love.graphics.newFont('Fonts/Distant Galaxy.ttf',80)
    font80SW_runes = love.graphics.newFont('Fonts/Aurebesh Bold.ttf',80)
    love.graphics.setFont(font80)

    love.audio.setVolume(1)
    sounds = {
        ['Imperial March piano only'] = love.audio.newSource('Music/Imperial March piano only.flac','stream'),
        ['Imperial March duet'] = love.audio.newSource('Music/Imperial March duet.mp3','stream'),
        ['Battle music 1'] = love.audio.newSource('Music/Battle music 1.ogg','stream')
    }

    background_video = love.graphics.newVideo('Videos/Starry Background.ogv')

    sand_dunes = love.graphics.newVideo('Videos/Sand Dunes.ogv')

    desert_background = love.graphics.newImage('Backgrounds/Desert_background.png')
    
    buttons = {
        ['Battle 1'] = Button('Battle 1','centre',100,'homestate'),
        ['Prebuilt deck'] = Button('Prebuilt deck',50,50,'homestate'),
        ['Pause'] = Button('Pause','centre',920,'gamestate')
    }

    P1_deck = {}
    P2_deck = {}
    next_round_P1_deck = {}
    next_round_P2_deck = {}
    P1_deck_cards = {}
    P2_deck_cards = {}

    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
    mouseLastX = 0
    mouseLastY = 0
    pause = false

    -- love.filesystem.remove('Player 1 deck.txt')

    P1_deck_file = love.filesystem.read('Player 1 deck.txt')

    if P1_deck_file == nil then
        love.filesystem.write('Player 1 deck.txt',',,,,,,,,,,,,,,,,,,')
    end

    -- initialize state machine with all state-returning functions
    gStateMachine = StateMachine {
        ['home'] = function() return HomeState() end,
        ['game'] = function() return GameState() end,
    }
    gStateMachine:change('home')
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result
end

function P1_deck_edit(position,name)
    P1_deck_file = love.filesystem.read('Player 1 deck.txt')
    P1_deck_cards_original = split(P1_deck_file,',')
    for k, pair in pairs(P1_deck_cards_original) do 
        P1_deck_cards[k-1] = pair
    end
    length = #P1_deck_cards
    P1_deck_cards[position] = tostring(name)
    P1_deck_cards_string = ''
    x = -1
    for k, pair in pairs(P1_deck_cards) do
        x = x + 1
        if x < length then
            P1_deck_cards_string = P1_deck_cards_string .. pair .. ','
        else
            P1_deck_cards_string = P1_deck_cards_string .. pair --stops extra comma being written
        end
    end

    love.filesystem.write('Player 1 Deck.txt',P1_deck_cards_string)

    read_P1_deck()
end

function read_P1_deck()
    P1_deck_cards = {}
    P1_deck_file = love.filesystem.read('Player 1 deck.txt')
    P1_deck_cards_original = split(P1_deck_file,',')

    for k, pair in pairs(P1_deck_cards_original) do 
        if pair ~= '' then
            P1_deck_cards[k-1] = pair
        end
    end
end


function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true

    --Escape exits fullscreen
    if key == 'escape' then
        love.window.setFullscreen(false)
        love.window.maximize()
    end
    --F11 toggles between fullscreen and maximised
    if key == 'f11' then
        if love.window.getFullscreen() == false then
            love.window.setFullscreen(true)
        else
            love.window.setFullscreen(false)
            love.window.maximize()
        end
    end
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key] 
end

function love.mousereleased(x,y,button)
    love.mouse.buttonsPressed[button] = true
    mouseLastX,mouseLastY = love.mouse.getPosition()
    mouseLastX,mouseLastY = push:toGame(mouseLastX,mouseLastY)
end

function love.touchreleased()
    love.mouse.buttonsPressed[1] = true
    mouseLastX,mouseLastY = love.mouse.getPosition()
    mouseLastX,mouseLastY = push:toGame(mouseLastX,mouseLastY)
end

function love.update(dt)
    gStateMachine:update(dt)
    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
end


function love.draw()
    push:start()
    gStateMachine:render()
    push:finish()
end