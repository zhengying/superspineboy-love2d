-- Model class for Super Spineboy
-- Core game logic - manages all game information

local Player = require("player")
local Enemy = require("enemy")
local STI = require "libs.sti"

local Model = {}
Model.__index = Model

-- Constants
Model.scale = 1/64
Model.gravity = 32
Model.fps = 1/30
Model.gameOverSlowdown = 5.5
Model.mapCollisionLayer = 0

function Model.new(controller)
    local self = setmetatable({}, Model)
    self.controller = controller
    
    -- Parse TMX map data (simple version - just parse the XML)
    self:loadMap()
    
    self.timeScale = 1
    self.triggers = {}
    self.bullets = {}
    self.enemies = {}
    self.gameOverTimer = 0
    
    self:restart()
    
    return self
end

function Model:loadMap()
    local map = STI("assets/map/map.lua")
    self.mapWidth = map.width
    self.mapHeight = map.height
    self.tileWidth = map.tilewidth
    self.tileHeight = map.tileheight

    self.layerData = {}
    local layer = map.layers["Collisions"]
    if layer and layer.data then
        for row = 1, self.mapHeight do
            for col = 1, self.mapWidth do
                local gid = layer.data[row][col] and layer.data[row][col].gid or 0
                local flipped_row = self.mapHeight - row + 1
                local index = (flipped_row - 1) * self.mapWidth + col
                self.layerData[index] = gid
            end
        end
    end
end

function Model:restart()
    self.player = Player.new(self)
    self.player.position.x = 4
    self.player.position.y = 8
    
    self.bullets = {}
    self.enemies = {}
    self.gameOverTimer = 0
    
    -- Setup triggers to spawn enemies based on the x coordinate of the player
    self.triggers = {}
    self:addTrigger(17, 17 + 22, 8, "normal", 2)
    self:addTrigger(17, 17 + 22, 8, "strong", 1)
    self:addTrigger(31, 31 + 22, 8, "normal", 3)
    self:addTrigger(43, 43 + 22, 8, "strong", 3)
    self:addTrigger(64, 64 + 22, 8, "normal", 10)
    self:addTrigger(64, 64 + 29, 8, "strong", 1)
    self:addTrigger(76, 76 - 19, 8, "strong", 2)
    self:addTrigger(87, 87 - 19, 8, "normal", 2)
    self:addTrigger(97, 97 - 19, 8, "normal", 2)
    self:addTrigger(100, 100 + 34, 8, "strong", 2)
    self:addTrigger(103, 103 + 34, 8, "normal", 4)
    self:addTrigger(125, 60 - 19, 8, "normal", 10)
    self:addTrigger(125, 125 - 19, 8, "weak", 10)
    self:addTrigger(125, 125 - 45, 8, "becomesBig", 1)
    self:addTrigger(125, 125 + 22, 22, "normal", 5)
    self:addTrigger(125, 125 + 32, 22, "normal", 2)
    self:addTrigger(125, 220, 23, "strong", 3)
    self:addTrigger(158, 158 - 19, 8, "weak", 10)
    self:addTrigger(158, 158 - 23, 8, "strong", 1)
    self:addTrigger(158, 158 + 22, 23, "normal", 3)
    self:addTrigger(165, 165 + 22, 23, "strong", 4)
    self:addTrigger(176, 176 + 22, 23, "normal", 12)
    self:addTrigger(176, 176 + 22, 23, "weak", 10)
    self:addTrigger(176, 151, 8, "strong", 1)
    self:addTrigger(191, 191 - 19, 23, "normal", 5)
    self:addTrigger(191, 191 - 19, 23, "weak", 15)
    self:addTrigger(191, 191 - 27, 23, "strong", 2)
    self:addTrigger(191, 191 + 34, 23, "weak", 10)
    self:addTrigger(191, 191 + 34, 23, "weak", 8)
    self:addTrigger(191, 191 + 34, 23, "normal", 2)
    self:addTrigger(191, 191 + 42, 23, "strong", 2)
    self:addTrigger(213, 213 + 22, 23, "normal", 3)
    self:addTrigger(213, 213 + 22, 23, "strong", 3)
    self:addTrigger(213, 213 - 19, 23, "normal", 7)
    self:addTrigger(246, 247 - 30, 23, "strong", 7)
    self:addTrigger(246, 225, 23, "normal", 2)
    self:addTrigger(246, 220, 23, "becomesBig", 3)

    -- Performance test: Add many enemies
    for i = 1, 5 do
        self:addTrigger(5 + i * 2, 5 + i * 2 + 10, 8, "normal", 20)
    end
end

function Model:addTrigger(triggerX, spawnX, spawnY, type, count)
    local trigger = {
        x = triggerX,
        enemies = {}
    }
    
    local offset = spawnX > triggerX and 2 or -2
    for i = 1, count do
        local enemy = Enemy.new(self, type)
        enemy.position.x = spawnX
        enemy.position.y = spawnY
        table.insert(trigger.enemies, enemy)
        spawnX = spawnX + offset
    end
    
    table.insert(self.triggers, trigger)
end

function Model:update(delta)
    if self.player.hp == 0 then
        self.gameOverTimer = self.gameOverTimer + delta / self:getTimeScale() * self.timeScale
        if self.controller and self.controller.eventGameOver then
            self.controller:eventGameOver(false)
        end
    end
    
    self:updateEnemies(delta)
    self:updateBullets(delta)
    self.player:update(delta)
    self:updateTriggers()
end

function Model:updateTriggers()
    for i = #self.triggers, 1, -1 do
        local trigger = self.triggers[i]
        if self.player.position.x > trigger.x then
            for _, enemy in ipairs(trigger.enemies) do
                table.insert(self.enemies, enemy)
            end
            table.remove(self.triggers, i)
            break
        end
    end
end

function Model:updateEnemies(delta)
    local alive = 0
    
    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        enemy:update(delta)
        
        if enemy.deathTimer < 0 then
            table.remove(self.enemies, i)
        else
            if enemy.hp > 0 then
                alive = alive + 1
                
                if enemy.hp > 0 and self.player.hp > 0 then
                    if enemy.collisionTimer < 0 and self:rectOverlaps(enemy.rect, self.player.rect) then
                        -- Check for head bounce
                        if enemy.rect.y + enemy.rect.height * 0.6 < self.player.rect.y then
                            -- Enemy head bounce
                            local bounceX = Player.headBounceX
                            if enemy.position.x + enemy.rect.width / 2 < self.player.position.x + self.player.rect.width / 2 then
                                bounceX = bounceX * 1
                            else
                                bounceX = bounceX * -1
                            end
                            
                            enemy.collisionTimer = Enemy.collisionDelay
                            enemy.velocity.x = enemy.velocity.x - bounceX
                            enemy.velocity.y = enemy.velocity.y - 10
                            enemy:setGrounded(false)
                            enemy.hp = enemy.hp - 2
                            
                            if enemy.hp <= 0 then
                                enemy.state = "death"
                            else
                                enemy.state = "fall"
                            end
                            
                            self.player.velocity.x = bounceX
                            self.player.velocity.y = Player.headBounceY
                            self.player:setGrounded(false)
                            self.player:setState("fall")
                            
                            if self.controller and self.controller.eventHitEnemy then
                                self.controller:eventHitEnemy(enemy)
                            end
                        elseif self.player.collisionTimer < 0 then
                          -- Player gets hit  
                            local playerCenter = self.player.position.x + self.player.rect.width / 2
                            local enemyCenter = enemy.position.x + enemy.rect.width / 2
                            
                            self.player.dir = enemyCenter < playerCenter and -1 or 1
                            local amount = Player.knockbackX * self.player.dir
                            
                            self.player.velocity.x = -amount
                            self.player.velocity.y = self.player.velocity.y + Player.knockbackY
                            self.player:setGrounded(false)
                            self.player.hp = self.player.hp - 1
                            
                            if self.player.hp > 0 then
                                self.player:setState("fall")
                                self.player.collisionTimer = Player.collisionDelay
                                
                                enemy.velocity.x = amount * 1.6
                                enemy.velocity.y = enemy.velocity.y + 5
                                enemy:setState("fall")
                                enemy.jumpDelayTimer = math.random() * enemy.jumpDelay
                            else
                                self.player:setState("death")
                                self.player.velocity.y = self.player.velocity.y * 0.5
                            end
                            
                            enemy:setGrounded(false)
                            enemy.collisionTimer = Enemy.collisionDelay
                            
                            if self.controller and self.controller.eventHitPlayer then
                                self.controller:eventHitPlayer(enemy)
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- End the game when all enemies are dead and all triggers have occurred
    if alive == 0 and #self.triggers == 0 then
        if self.controller and self.controller.eventGameOver then
            self.controller:eventGameOver(true)
        end
    end
end

function Model:updateBullets(delta)
    for i = #self.bullets, 5, -5 do
        local vx = self.bullets[i-4]
        local vy = self.bullets[i-3]
        local x = self.bullets[i-2]
        local y = self.bullets[i-1]
        local angle = self.bullets[i]
        local nx = x + vx * delta
        local ny = y + vy * delta
        
        -- Check map collision
        if self:isTileSolid(math.floor(x), math.floor(y)) then
            -- Bullet hit map
            if self.controller and self.controller.eventHitBullet then
                self.controller:eventHitBullet(x, y, vx, vy)
            end
            table.remove(self.bullets, i-4)
            table.remove(self.bullets, i-4)
            table.remove(self.bullets, i-4)
            table.remove(self.bullets, i-4)
            table.remove(self.bullets, i-4)
        elseif math.abs(x - self.player.position.x) > 25 then
            -- Bullet traveled too far
            table.remove(self.bullets, i-4)
            table.remove(self.bullets, i-4)
            table.remove(self.bullets, i-4)
            table.remove(self.bullets, i-4)
            table.remove(self.bullets, i-4)
        else
            -- Check enemy collisions
            local hitEnemy = false
            for _, enemy in ipairs(self.enemies) do
                if enemy.state ~= "death" and enemy.bigTimer <= 0 then
                    if self:pointInRect(x, y, enemy.rect) or self:segmentIntersectsRect(x, y, nx, ny, enemy.rect) then
                        -- Bullet hit enemy
                        table.remove(self.bullets, i-4)
                        table.remove(self.bullets, i-4)
                        table.remove(self.bullets, i-4)
                        table.remove(self.bullets, i-4)
                        table.remove(self.bullets, i-4)
                        
                        if self.controller and self.controller.eventHitBullet then
                            self.controller:eventHitBullet(x, y, vx, vy)
                        end
                        if self.controller and self.controller.eventHitEnemy then
                            self.controller:eventHitEnemy(enemy)
                        end
                        
                        enemy.collisionTimer = Enemy.collisionDelay
                        enemy.hp = enemy.hp - 1
                        
                        if enemy.hp <= 0 then
                            enemy.state = "death"
                            enemy.velocity.y = enemy.velocity.y * 0.5
                        else
                            enemy.state = "fall"
                        end
                        
                        local knockbackDir = self.player.position.x < enemy.position.x + enemy.rect.width / 2 and 1 or -1
                        enemy.velocity.x = (math.random() * (enemy.knockbackX / 2) + enemy.knockbackX / 2) * knockbackDir
                        enemy.velocity.y = enemy.velocity.y + (math.random() * (enemy.knockbackY / 2) + enemy.knockbackY / 2)
                        
                        hitEnemy = true
                        break
                    end
                end
            end
            
            if not hitEnemy then
                x = nx
                y = ny
                self.bullets[i-2] = x
                self.bullets[i-1] = y
            end
        end
    end
end

function Model:segmentIntersectsRect(x1, y1, x2, y2, rect)
    local rx1 = rect.x
    local ry1 = rect.y
    local rx2 = rect.x + rect.width
    local ry2 = rect.y + rect.height
    local dx = x2 - x1
    local dy = y2 - y1
    local t0 = 0
    local t1 = 1
    local function clip(p, q)
        if p == 0 then
            if q < 0 then return false end
            return true
        end
        local r = q / p
        if p < 0 then
            if r > t1 then return false end
            if r > t0 then t0 = r end
        else
            if r < t0 then return false end
            if r < t1 then t1 = r end
        end
        return true
    end
    if clip(-dx, x1 - rx1) and clip(dx, rx2 - x1) and clip(-dy, y1 - ry1) and clip(dy, ry2 - y1) then
        return t0 <= t1 and t0 <= 1 and t1 >= 0
    end
    return false
end

function Model:addBullet(startX, startY, vx, vy, angle)
    table.insert(self.bullets, vx)
    table.insert(self.bullets, vy)
    table.insert(self.bullets, startX)
    table.insert(self.bullets, startY)
    table.insert(self.bullets, angle)
end

function Model:getCollisionTiles(startX, startY, endX, endY)
    local tiles = {}
    
    startX = math.max(0, math.floor(startX))
    startY = math.max(0, math.floor(startY))
    endX = math.min(self.mapWidth - 1, math.floor(endX))
    endY = math.min(self.mapHeight - 1, math.floor(endY))
    
    for y = startY, endY do
        for x = startX, endX do
            if self:isTileSolid(x, y) then
                table.insert(tiles, {x = x, y = y, width = 1, height = 1})
            end
        end
    end
    
    return tiles
end

function Model:isTileSolid(x, y)
    if not self.layerData then return false end
    
    local index = y * self.mapWidth + x + 1
    local tileId = self.layerData[index]
    
    -- Tiles with ID > 0 are solid (adjust based on your tileset)
    return tileId and tileId > 0
end

function Model:getTimeScale()
    if self.player.hp == 0 then
        local t = math.min(1, math.max(0.01, self.gameOverTimer / self.gameOverSlowdown))
        return self.timeScale * (t * t) -- pow2 interpolation
    end
    return self.timeScale
end

function Model:rectOverlaps(rect1, rect2)
    return rect1.x < rect2.x + rect2.width and
           rect1.x + rect1.width > rect2.x and
           rect1.y < rect2.y + rect2.height and
           rect1.y + rect1.height > rect2.y
end

function Model:pointInRect(x, y, rect)
    return x >= rect.x and x < rect.x + rect.width and
           y >= rect.y and y < rect.y + rect.height
end

return Model
