-- Enemy class for Super Spineboy
-- Enemy-specific character logic

local Character = require("character")

local Enemy = setmetatable({}, {__index = Character})
Enemy.__index = Enemy

-- Constants
Enemy.heightSource = 398
Enemy.width = 105 * (1/64)  -- scale applied
Enemy.height = 200 * (1/64) -- scale applied

Enemy.maxVelocityMinX = 4
Enemy.maxVelocityMaxX = 8.5
Enemy.maxVelocityAirX = 19

Enemy.hpWeak = 1
Enemy.hpSmall = 2
Enemy.hpNormal = 3
Enemy.hpStrong = 5
Enemy.hpBecomesBig = 8
Enemy.hpBig = 20

Enemy.corpseTime = 5
Enemy.fadeTime = 3

Enemy.jumpDistanceNormal = 20
Enemy.jumpDelayNormal = 1.6
Enemy.jumpVelocityNormal = 12
Enemy.jumpVelocityBig = 18

Enemy.sizeSmall = 0.5
Enemy.sizeBig = 2.5
Enemy.sizeStrong = 1.3
Enemy.bigDuration = 2
Enemy.smallCount = 14

Enemy.normalKnockbackX = 19
Enemy.normalKnockbackY = 9
Enemy.bigKnockbackX = 12
Enemy.bigKnockbackY = 6

Enemy.collisionDelay = 0.3

function Enemy.new(model, type)
    local self = setmetatable(Character.new(model), Enemy)
    
    self.rect.width = Enemy.width
    self.rect.height = Enemy.height
    
    self.maxVelocityGroundX = math.random() * (Enemy.maxVelocityMaxX - Enemy.maxVelocityMinX) + Enemy.maxVelocityMinX
    self.maxVelocityX = self.maxVelocityGroundX
    self.jumpVelocity = Enemy.jumpVelocityNormal
    self.jumpDelay = Enemy.jumpDelayNormal
    self.jumpDistance = Enemy.jumpDistanceNormal
    
    self.type = type
    self.size = 1
    self.collisionTimer = 0
    self.jumpDelayTimer = math.random() * self.jumpDelay
    self.deathTimer = Enemy.corpseTime
    self.bigTimer = 0
    self.spawnSmallsTimer = 0
    self.move = true
    self.forceJump = false
    self.collisions = 0
    
    self.knockbackX = Enemy.normalKnockbackX
    self.knockbackY = Enemy.normalKnockbackY
    
    if type == "big" then
        self.size = Enemy.sizeBig
        self.rect.width = Enemy.width * self.size * 0.7
        self.rect.height = Enemy.height * self.size * 0.7
        self.hp = Enemy.hpBig
        self.knockbackX = Enemy.normalKnockbackX
        self.knockbackY = Enemy.normalKnockbackY
    elseif type == "small" then
        self.size = Enemy.sizeSmall
        self.rect.width = Enemy.width * self.size
        self.rect.height = Enemy.height * self.size
        self.hp = Enemy.hpSmall
    elseif type == "weak" then
        self.hp = Enemy.hpWeak
    elseif type == "becomesBig" then
        self.hp = Enemy.hpBecomesBig
    elseif type == "strong" then
        self.hp = Enemy.hpStrong
        self.size = Enemy.sizeStrong
        self.jumpVelocity = self.jumpVelocity * 1.5
        self.jumpDistance = self.jumpDistance * 1.4
    else
        self.hp = Enemy.hpNormal
    end
    
    return self
end

function Enemy:update(delta)
    self.stateChanged = false
    
    if self.state == "death" then
        if self.type == "becomesBig" and self.size == 1 then
            self.bigTimer = Enemy.bigDuration
            self.collisionTimer = Enemy.bigDuration
            self.state = "run"
            self.hp = Enemy.hpBig
            self.knockbackX = Enemy.bigKnockbackX
            self.knockbackY = Enemy.bigKnockbackY
            self.type = "big"
            self.jumpVelocity = Enemy.jumpVelocityBig
        elseif self.type == "big" then
            self.spawnSmallsTimer = 0.8333
            self.type = "normal"
        end
    end
    
    -- Enemy grows to a big enemy
    if self.bigTimer > 0 then
        self.bigTimer = self.bigTimer - delta
        self.size = 1 + (Enemy.sizeBig - 1) * (1 - math.max(0, self.bigTimer / Enemy.bigDuration))
        self.rect.width = Enemy.width * self.size * 0.7
        self.rect.height = Enemy.height * self.size * 0.7
    end
    
    -- Big enemy explodes into small ones
    if self.spawnSmallsTimer > 0 then
        self.spawnSmallsTimer = self.spawnSmallsTimer - delta
        if self.spawnSmallsTimer < 0 then
            for i = 1, Enemy.smallCount do
                local small = Enemy.new(self.model, "small")
                small.position.x = self.position.x
                small.position.y = self.position.y + 2
                small.velocity.x = math.random(5, 15) * (math.random() < 0.5 and 1 or -1)
                small.velocity.y = math.random(10, 25)
                small:setGrounded(false)
                table.insert(self.model.enemies, small)
            end
        end
    end
    
    -- Nearly dead enemies jump at the player right away
    if self.hp == 1 and self.type ~= "weak" and self.type ~= "small" then
        self.jumpDelayTimer = 0
    end
    
    -- Kill enemies stuck in the map or those that have somehow fallen out of the map
    if self.state ~= "death" and (self.hp <= 0 or self.position.y < -100 or self.collisions > 100) then
        self.state = "death"
        self.hp = 0
    end
    
    -- Simple enemy AI
    local grounded = self:isGrounded()
    if grounded then self.move = true end
    
    self.collisionTimer = self.collisionTimer - delta
    self.maxVelocityX = self:isGrounded() and self.maxVelocityGroundX or Enemy.maxVelocityAirX
    
    if self.state == "death" then
        self.deathTimer = self.deathTimer - delta
    elseif self.collisionTimer < 0 then
        if self.model.player.hp == 0 then
            -- Enemies win, jump for joy!
            if self:isGrounded() and self.velocity.x == 0 then
                self.jumpVelocity = Enemy.jumpVelocityNormal / 2
                self.dir = -self.dir
                self:jump()
            end
        else
            -- Jump if within range of the player
            if self:isGrounded() and (self.forceJump or math.abs(self.model.player.position.x - self.position.x) < self.jumpDistance) then
                self.jumpDelayTimer = self.jumpDelayTimer - delta
                if self.state ~= "jump" and self.jumpDelayTimer < 0 and self.position.y <= self.model.player.position.y then
                    self:jump()
                    self.jumpDelayTimer = math.random() * self.jumpDelay
                    self.forceJump = false
                end
            end
            
            -- Move toward the player
            if self.move then
                if self.model.player.position.x > self.position.x then
                    if self.velocity.x >= 0 then
                        self:moveRight(delta)
                    end
                else
                    if self.velocity.x <= 0 then
                        self:moveLeft(delta)
                    end
                end
            end
        end
    end
    
    local previousCollision = self.collisions
    Character.update(self, delta)
    
    if not grounded or self.collisions == previousCollision then
        self.collisions = 0
    end
end

function Enemy:collideX()
    local result = Character.collideX(self)
    if result then
        -- If grounded and collided with the map, jump to avoid the obstacle
        if self:isGrounded() then
            self.forceJump = true
        end
        self.collisions = self.collisions + 1
    end
    return result
end

return Enemy
