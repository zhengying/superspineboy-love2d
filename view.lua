-- View class for Super Spineboy
-- Handles all rendering and user input

local PlayerView = require("playerview")
local EnemyView = require("enemyview")
local MapRenderer = require("maprenderer")
local UI = require("ui")
local Player = require("player")

local View = {}
View.__index = View

-- Constants
View.bulletHitTime = 0.2
View.bulletHitOffset = 50 * (1/64)

View.cameraMinWidth = 16
View.cameraMaxWidth = 28
View.cameraHeight = 16
View.cameraZoom = 0.4
View.cameraZoomSpeed = 0.5
View.cameraBottom = 2
View.cameraTop = 7
View.cameraMinX = 1
View.cameraLookahead = 0.75
View.cameraLookaheadSpeed = 8
View.cameraLookaheadSpeedSlow = 3
View.cameraSpeed = 5
View.cameraShake = 6 * (1/64)

function View.new(model, assets)
    local self = setmetatable({}, View)
    self.model = model
    self.assets = assets
    
    self.camera = {
        x = 0,
        y = 0,
        zoom = 1
    }
    
    self.lookahead = 0
    self.shakeX = 0
    self.shakeY = 0
    
    self.hits = {}
    
    self.touched = false
    self.jumpPressed = false
    self.leftPressed = false
    self.rightPressed = false
    
    self.player = model.player
    self.player.view = PlayerView.new(self)
    self.camera.x = self.player.position.x
    self.camera.y = self.player.position.y + self:getCameraHeight() / 2 - View.cameraBottom
    
    self.mapRenderer = MapRenderer.new("assets/map")
    self.ui = UI.new(self)
    self.ui:showStart()
    
    self.targetZoom = 1
    self.drawBackground = true
    self.debug = false
    
    self:resize(love.graphics.getWidth(), love.graphics.getHeight())

    -- Initial camera clamp
    self.camera.x = math.max(self:getCameraWidth() / 2 + View.cameraMinX, self.camera.x)
    
    return self
end

function View:update(delta, dt)
    -- Update hit markers
    for i = #self.hits, 4, -4 do
        self.hits[i-3] = self.hits[i-3] - delta
        if self.hits[i-3] < 0 then
            table.remove(self.hits, i-3)
            table.remove(self.hits, i-3)
            table.remove(self.hits, i-3)
            table.remove(self.hits, i-3)
        end
    end
    
    self:updateInput(delta)
    self:updateCamera(delta, dt)
    
    self.ui:update(dt)
    
    self.player.view:update(delta)
    
    for _, enemy in ipairs(self.model.enemies) do
        if not enemy.view then
            enemy.view = EnemyView.new(self, enemy)
        end
        enemy.view:update(delta)
    end
end

function View:updateInput(delta)
    if self.player.hp == 0 then return end
    
    if self.leftPressed then
        self.player:moveLeft(delta)
    elseif self.rightPressed then
        self.player:moveRight(delta)
    elseif self.player.state == "run" then
        self.player:setState("idle")
    end
    
    if self.touched then
        self.player.view:shoot()
    end
end

function View:updateCamera(delta, dt)
    -- Smooth zoom
    if self.camera.zoom < self.targetZoom then
        self.camera.zoom = math.min(self.targetZoom, self.camera.zoom + View.cameraZoomSpeed * dt)
    elseif self.camera.zoom > self.targetZoom then
        self.camera.zoom = math.max(self.targetZoom, self.camera.zoom - View.cameraZoomSpeed * dt)
    end

    if self.player.hp > 0 then
        -- Reduce camera lookahead based on distance of enemies behind the player
        local enemyBehindDistance = 0
        for _, enemy in ipairs(self.model.enemies) do
            local dist = enemy.position.x - self.player.position.x
            if enemy.hp > 0 and (dist > 0) == (self.player.dir < 0) then
                local absDist = math.abs(dist)
                if enemyBehindDistance == 0 then
                    enemyBehindDistance = absDist
                else
                    enemyBehindDistance = math.min(enemyBehindDistance, absDist)
                end
            end
        end
        
        local lookaheadDist = View.cameraLookahead * (self:getCameraWidth() / 2) * 
                             (1 - math.min(1, enemyBehindDistance / 22))
        local lookaheadDiff = self.player.position.x + lookaheadDist * self.player.dir - self.camera.x
        local lookaheadAdjust = (enemyBehindDistance > 0 and View.cameraLookaheadSpeedSlow or View.cameraLookaheadSpeed) * delta
        
        if math.abs(self.lookahead - lookaheadDiff) > 0.001 then
            if self.lookahead < lookaheadDiff then
                self.lookahead = math.min(lookaheadDist, self.lookahead + lookaheadAdjust)
            elseif self.lookahead > lookaheadDiff then
                self.lookahead = math.max(-lookaheadDist, self.lookahead - lookaheadAdjust)
            end
        end
        
        if self.player.position.x + self.lookahead < View.cameraMinX then
            self.lookahead = View.cameraLookahead
        end
    end
    
    -- Move camera to the player position over time, adjusting for lookahead
    local minX = self.player.position.x + self.lookahead
    local maxX = self.player.position.x + self.lookahead
    
    if self.camera.x < minX then
        self.camera.x = self.camera.x + (minX - self.camera.x) * View.cameraSpeed * delta
        if math.abs(self.camera.x - minX) < 0.1 then
            self.camera.x = minX
        end
    elseif self.camera.x > maxX then
        self.camera.x = self.camera.x + (maxX - self.camera.x) * View.cameraSpeed * delta
        if math.abs(self.camera.x - maxX) < 0.1 then
            self.camera.x = maxX
        end
    end
    
    self.camera.x = math.max(self:getCameraWidth() / 2 + View.cameraMinX, self.camera.x)
    
    local top = self.camera.zoom ~= 1 and 5 or View.cameraTop
    local bottom = self.camera.zoom ~= 1 and 0 or View.cameraBottom
    local maxY = self.player.position.y + self:getCameraHeight() / 2 - bottom
    local minY = self.player.position.y - self:getCameraHeight() / 2 + top
    
    if self.camera.y < minY then
        self.camera.y = self.camera.y + (minY - self.camera.y) * View.cameraSpeed / self.camera.zoom * delta
        if math.abs(self.camera.y - minY) < 0.1 then
            self.camera.y = minY
        end
    elseif self.camera.y > maxY then
        self.camera.y = self.camera.y + (maxY - self.camera.y) * View.cameraSpeed / self.camera.zoom * delta
        if math.abs(self.camera.y - maxY) < 0.1 then
            self.camera.y = maxY
        end
    end
    
    -- Apply shake
    self.camera.x = self.camera.x - self.shakeX
    self.camera.y = self.camera.y - self.shakeY
    self.shakeX = 0
    self.shakeY = 0
end

function View:render()
    love.graphics.clear(0, 0, 0, 1)
    
    love.graphics.push()
    local scale = love.graphics.getWidth() / self:getCameraWidth()
    love.graphics.translate(0, love.graphics.getHeight())
    love.graphics.scale(scale, -scale)
    love.graphics.translate(-self.camera.x + self:getCameraWidth()/2,
                            -self.camera.y + self:getCameraHeight()/2)
    
    -- Draw map
    if self.drawBackground then
        self.mapRenderer:draw(self.camera)
    end
    
    -- Draw enemies
    for _, enemy in ipairs(self.model.enemies) do
        if enemy.view then
            local alpha = math.min(1, enemy.deathTimer / EnemyView.fadeTime)
            love.graphics.setColor(1, 1, 1, alpha)
            enemy.view:draw()
            
            if self.debug then
                -- Draw enemy debug info
                love.graphics.setColor(0, 1, 0, 1)
                love.graphics.rectangle("line", enemy.rect.x, enemy.rect.y, enemy.rect.width, enemy.rect.height)
            end
        end
    end
    
    -- Draw player
    love.graphics.setColor(1, 1, 1, 1)
    if self.player.collisionTimer < 0 or (math.floor(self.player.collisionTimer / PlayerView.flashTime * 1.5) % 2 ~= 0) then
        self.player.view:draw()
        
        if self.debug then
            -- Draw player debug info
            love.graphics.setColor(0, 1, 0, 1)
            love.graphics.rectangle("line", self.player.rect.x, self.player.rect.y, self.player.rect.width, self.player.rect.height)
        end
    end
    
    -- Draw bullets
    self:drawBullets()
    
    -- Draw hit markers
    self:drawHitMarkers()
    
    love.graphics.pop()
    
    -- Draw UI
    self.ui:draw()
    
    -- Draw crosshair
    local mx, my = love.mouse.getPosition()
    love.graphics.draw(self.assets.crosshairImage, mx - 10, my - 10)
end

function View:drawBullets()
    local bulletWidth = self.assets.bulletImage:getWidth() * self.assets.scale
    local bulletHeight = self.assets.bulletImage:getHeight() * self.assets.scale / 2
    
    love.graphics.setBlendMode("add")
    
    for i = 3, #self.model.bullets, 5 do
        local x = self.model.bullets[i]
        local y = self.model.bullets[i+1]
        local angle = self.model.bullets[i+2]
        
        local vx = math.cos(math.rad(angle))
        local vy = math.sin(math.rad(angle))
        
        -- Adjust position so bullet region is drawn with the bullet position in the center
        x = x - vx * bulletWidth * 0.65
        y = y - vy * bulletWidth * 0.65
        x = x + vy * bulletHeight / 2
        y = y - vx * bulletHeight / 2
        
        love.graphics.draw(self.assets.bulletImage, x, y, math.rad(angle), self.assets.scale, self.assets.scale / 2, 0, 0)
    end
    
    love.graphics.setBlendMode("alpha")
end

function View:drawHitMarkers()
    local bulletHeight = self.assets.bulletImage:getHeight() * self.assets.scale / 2
    
    love.graphics.setBlendMode("add")
    
    for i = 1, #self.hits, 4 do
        local time = self.hits[i]
        local x = self.hits[i+1]
        local y = self.hits[i+2]
        local angle = self.hits[i+3]
        
        local vx = math.cos(math.rad(angle))
        local vy = math.sin(math.rad(angle))
        
        x = x + vy * bulletHeight * 0.2
        y = y - vx * bulletHeight * 0.2
        
        local alpha = time / View.bulletHitTime
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.draw(self.assets.hitImage, x, y, math.rad(angle), self.assets.scale, self.assets.scale, self.assets.hitImage:getWidth()/2, 0)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha")
end

function View:resize(width, height)
    -- Handle resize if needed
end

function View:keyPressed(key, scancode, isrepeat)
    if self.ui:keyPressed(key) then return end

    if self.player.hp == 0 then return end
    
    if key == "w" or key == "up" or key == "space" then
        self.jumpPressed = true
        if self.player:isGrounded() then
            self.player.view:jump()
        end
    elseif key == "a" or key == "left" then
        self.leftPressed = true
    elseif key == "d" or key == "right" then
        self.rightPressed = true
    end
end

function View:keyReleased(key, scancode)
    if key == "w" or key == "up" or key == "space" then
        if self.player.velocity.y > 0 then
            self.player.velocity.y = self.player.velocity.y * Player.jumpDamping
        end
        self.jumpPressed = false
    elseif key == "a" or key == "left" then
        self.leftPressed = false
    elseif key == "d" or key == "right" then
        self.rightPressed = false
    end
end

function View:mousePressed(x, y, button)
    if self.ui:mousePressed(x, y, button) then return end

    if button == 1 then
        self.touched = true
        self.player.view:shoot()
    end
end

function View:mouseReleased(x, y)
    self.touched = false
end

function View:addHitEffect(x, y, vx, vy)
    local offset = math.sqrt(vx*vx + vy*vy)
    if offset > 0 then
        offset = 15 * self.assets.scale / offset
    else
        offset = 0
    end
    
    table.insert(self.hits, View.bulletHitTime)
    table.insert(self.hits, x + vx * offset)
    table.insert(self.hits, y + vy * offset)
    table.insert(self.hits, math.deg(math.atan2(vy, vx)) + 90)
end

function View:showGameOver(win)
    if not self.ui.showingGameOver then
        self.ui:showGameOver(win)
        self.jumpPressed = false
        self.leftPressed = false
        self.rightPressed = false
    end
end

function View:restart()
    self.player = self.model.player
    self.player.view = PlayerView.new(self)
    self.lookahead = 0
    self.touched = false
    self.hits = {}
    self.jumpPressed = false
    self.leftPressed = false
    self.rightPressed = false
    
    self.camera.x = self.player.position.x
    self.camera.y = self.player.position.y + self:getCameraHeight() / 2 - View.cameraBottom
    self.camera.zoom = 1
    self.targetZoom = 1
    
    if self.ui then
        self.ui.showingGameOver = false
        self.ui.gameOverAlpha = 0
    end
end

function View:getCameraWidth()
    return love.graphics.getWidth() / love.graphics.getHeight() * self:getCameraHeight()
end

function View:getCameraHeight()
    return View.cameraHeight / self.camera.zoom
end

return View
