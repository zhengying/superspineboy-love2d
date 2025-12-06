-- Super Spineboy - Love2D Port
-- Based on spine-superspineboy-java by Esoteric Software

package.path = package.path .. ";spine-love2d/?.lua;spine-love2d/?/?.lua;spine-love2d/?/init.lua"

-- Use pcall to safely try loading spine
local spine_load_success, spine = pcall(require, "spine-love2d")
if not spine_load_success then
    package.path = package.path .. ";../spine-love2d/?.lua;../spine-love2d/?/?.lua;../spine-love2d/?/init.lua;../../spine-love2d/?.lua;../../spine-love2d/?/?.lua;../../spine-love2d/?/init.lua"
    spine = require("spine-love2d")
end
local Model = require("model")
local View = require("view")
local Assets = require("assets")

-- Game controller
local game = {
    model = nil,
    view = nil,
    assets = nil
}

function love.load(arg)
    love.window.setTitle("Super Spineboy")
    love.window.setMode(800, 450)
    
    -- Debug: Check working directory
    print("Working directory: " .. love.filesystem.getWorkingDirectory())
    print("Save directory: " .. love.filesystem.getSaveDirectory())
    print("Source directory: " .. love.filesystem.getSource())
    
    -- List files in current directory for debugging
    print("Files in current directory:")
    local files = love.filesystem.getDirectoryItems("")
    for i, file in ipairs(files) do
        print("  " .. file)
    end
    
    -- Initialize spine runtime
    spine.init()
    
    -- Debug: Print spine.skeleton structure to find SkeletonData
    print("spine.skeleton contents:")
    for k, v in pairs(spine.skeleton) do
        if type(v) == "table" then
            print("  spine.skeleton." .. k .. " (table) = " .. tostring(v))
        else
            print("  spine.skeleton." .. k .. " = " .. tostring(v))
        end
    end
    
    -- Load assets
    game.assets = Assets()
    
    -- Create model and view
    game.model = Model.new(game)
    game.view = View.new(game.model, game.assets)
    
    print("Super Spineboy loaded successfully!")
    print("Controls: A/D or Arrow keys to move, W/Space to jump, click to shoot")
end

function love.errhand(msg)
    print("Error: " .. tostring(msg))
    print(debug.traceback())
    
    -- Return to main error handler
    return love.errhand(msg)
end

function love.update(dt)
    -- Cap delta time
    dt = math.min(dt, 1/30)
    
    if game.model and game.view then
        -- Pause if showing start screen
        if game.view.ui and game.view.ui.showingStart then
            return
        end
        
        local timeScale = game.model:getTimeScale()
        local delta = dt * timeScale
        
        game.model:update(delta)
        game.view:update(delta, dt)
    end
end

function love.draw()
    if game.view then
        game.view:render()
    end
end

function love.resize(width, height)
    if game.view then
        game.view:resize(width, height)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if game.view then
        game.view:keyPressed(key, scancode, isrepeat)
    end
end

function love.keyreleased(key, scancode)
    if game.view then
        game.view:keyReleased(key, scancode)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if game.view then
        game.view:mousePressed(x, y, button)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 and game.view then
        game.view:mouseReleased(x, y)
    end
end

-- Controller events (called from model)
function game:eventHitPlayer(enemy)
    if game.assets then
        game.assets:playSound("hurtPlayer")
        if game.view.player.view.hitAnimation then
            game.view.player.view.animationState:setAnimation(1, game.view.player.view.hitAnimation, false)
        end
    end
end

function game:eventHitEnemy(enemy)
    if game.assets then
        game.assets:playSound("hurtAlien")
        if enemy.view.hitAnimation then
            enemy.view.animationState:setAnimation(1, enemy.view.hitAnimation, false)
        end
    end
end

function game:eventHitBullet(x, y, vx, vy)
    game.view:addHitEffect(x, y, vx, vy)
    if game.assets then
        game.assets:playSound("hit")
    end
end

function game:eventGameOver(win)
    game.view:showGameOver(win)
end

function game:restart()
    if game.model then game.model:restart() end
    if game.view then game.view:restart() end
end
