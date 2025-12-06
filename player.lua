-- Player class for Super Spineboy
-- Player-specific character logic

local Character = require("character")

local Player = setmetatable({}, {__index = Character})
Player.__index = Player

-- Constants
Player.heightSource = 625
Player.width = 67 * (1/64)  -- scale applied
Player.height = 285 * (1/64) -- scale applied
Player.hpStart = 4
Player.hpDuration = 15

Player.maxVelocityGroundX = 12.5
Player.maxVelocityAirX = 13.5
Player.playerJumpVelocity = 22
Player.jumpDamping = 0.5
Player.jumpOffsetVelocity = 10
Player.jumpOffsetY = 120 * (1/64)
Player.airJumpTime = 0.1

Player.shootDelay = 0.1
Player.shootOffsetX = 160
Player.shootOffsetY = 11
Player.bulletSpeed = 34
Player.bulletInheritVelocity = 0.4
Player.burstDuration = 0.18

Player.kickbackShots = 33
Player.kickbackAngle = 30
Player.kickbackVarianceShots = 11
Player.kickbackVariance = 6
Player.kickback = 1.6

Player.knockbackX = 14
Player.knockbackY = 5
Player.collisionDelay = 2.5
Player.flashTime = 0.07
Player.headBounceX = 12
Player.headBounceY = 20

function Player.new(model)
    local self = setmetatable(Character.new(model), Player)
    
    self.rect.width = Player.width
    self.rect.height = Player.height
    self.hp = Player.hpStart
    self.jumpVelocity = Player.playerJumpVelocity
    
    self.shootTimer = 0
    self.collisionTimer = 0
    self.hpTimer = 0
    
    return self
end

function Player:update(delta)
    self.stateChanged = false
    
    self.shootTimer = self.shootTimer - delta
    
    if self.hp > 0 then
        self.hpTimer = self.hpTimer - delta
        if self.hpTimer < 0 then
            self.hpTimer = Player.hpDuration
            if self.hp < Player.hpStart then
                self.hp = self.hp + 1
            end
        end
    end
    
    self.collisionTimer = self.collisionTimer - delta
    
    self.rect.height = Player.height - self.collisionOffsetY
    self.maxVelocityX = self:isGrounded() and Player.maxVelocityGroundX or Player.maxVelocityAirX
    
    Character.update(self, delta)
end

return Player