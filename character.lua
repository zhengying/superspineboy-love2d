-- Character base class for Super Spineboy
-- Base class for Player and Enemy

local Character = {}
Character.__index = Character

-- Constants
Character.minVelocityX = 0.001
Character.maxVelocityY = 20
Character.groundedTime = 0.15
Character.dampingGroundX = 36
Character.dampingAirX = 15
Character.collideDampingX = 0.7
Character.runGroundX = 80
Character.runAirSame = 45
Character.runAirOpposite = 45

function Character.new(model)
    local self = setmetatable({}, Character)
    self.model = model
    self.position = {x = 0, y = 0}
    self.velocity = {x = 0, y = 0}
    self.state = "idle"
    self.stateTime = 0
    self.dir = 1
    self.airTime = Character.groundedTime
    self.rect = {x = 0, y = 0, width = 0, height = 0}
    self.stateChanged = false
    self.hp = 0
    self.maxVelocityX = 0
    self.collisionOffsetY = 0
    self.jumpVelocity = 0
    
    return self
end

function Character:setState(newState)
    if (self.state == newState and newState ~= "fall") or self.state == "death" then
        return
    end
    self.state = newState
    self.stateTime = 0
    self.stateChanged = true
end

function Character:update(delta)
    if delta == 0 then return end

    self.stateTime = self.stateTime + delta
    
    -- If moving downward, change state to fall
    if self.velocity.y < 0 and self.state ~= "jump" and self.state ~= "fall" then
        self:setState("fall")
        self:setGrounded(false)
    end
    
    -- Apply gravity
    self.velocity.y = self.velocity.y - self.model.gravity * delta
    if self.velocity.y < -self.maxVelocityY then
        self.velocity.y = -self.maxVelocityY
    end
    
    -- Apply damping
    local damping = (self:isGrounded() and Character.dampingGroundX or Character.dampingAirX) * delta
    if self.velocity.x > 0 then
        self.velocity.x = math.max(0, self.velocity.x - damping)
    else
        self.velocity.x = math.min(0, self.velocity.x + damping)
    end
    
    if math.abs(self.velocity.x) < Character.minVelocityX and self:isGrounded() then
        self.velocity.x = 0
        self:setState("idle")
    end
    
    -- Update position with collision detection
    self.velocity.x = self.velocity.x * delta
    self.velocity.y = self.velocity.y * delta
    
    self:collideX()
    self:collideY()
    
    self.position.x = self.position.x + self.velocity.x
    self.position.y = self.position.y + self.velocity.y
    
    self.velocity.x = self.velocity.x / delta
    self.velocity.y = self.velocity.y / delta
end

function Character:isGrounded()
    return self.airTime < Character.groundedTime
end

function Character:setGrounded(grounded)
    self.airTime = grounded and 0 or Character.groundedTime
end

function Character:collideX()
    self.rect.x = self.position.x + self.velocity.x
    self.rect.y = self.position.y + self.collisionOffsetY
    
    local x
    if self.velocity.x >= 0 then
        x = math.floor(self.rect.x + self.rect.width)
    else
        x = math.floor(self.rect.x)
    end
    
    local startY = math.floor(self.rect.y)
    local endY = math.floor(self.rect.y + self.rect.height)
    
    local tiles = self.model:getCollisionTiles(x, startY, x, endY)
    for _, tile in ipairs(tiles) do
        if self:rectOverlaps(self.rect, tile) then
            if self.velocity.x >= 0 then
                self.position.x = tile.x - self.rect.width
            else
                self.position.x = tile.x + tile.width
            end
            self.velocity.x = self.velocity.x * Character.collideDampingX
            return true
        end
    end
    return false
end

function Character:collideY()
    self.rect.x = self.position.x
    self.rect.y = self.position.y + self.velocity.y + self.collisionOffsetY
    
    local y
    if self.velocity.y > 0 then
        y = math.floor(self.rect.y + self.rect.height)
    else
        y = math.floor(self.rect.y)
    end
    
    local startX = math.floor(self.rect.x)
    local endX = math.floor(self.rect.x + self.rect.width)
    
    local tiles = self.model:getCollisionTiles(startX, y, endX, y)
    for _, tile in ipairs(tiles) do
        if self:rectOverlaps(self.rect, tile) then
            if self.velocity.y > 0 then
                self.position.y = tile.y - self.rect.height
            else
                self.position.y = tile.y + tile.height
                if self.state == "jump" then
                    self:setState("idle")
                end
                self:setGrounded(true)
            end
            self.velocity.y = 0
            return true
        end
    end
    return false
end

function Character:moveLeft(delta)
    local adjust
    if self:isGrounded() then
        adjust = Character.runGroundX
        self:setState("run")
    else
        adjust = self.velocity.x <= 0 and Character.runAirSame or Character.runAirOpposite
    end
    
    if self.velocity.x > -self.maxVelocityX then
        self.velocity.x = math.max(self.velocity.x - adjust * delta, -self.maxVelocityX)
    end
    self.dir = -1
end

function Character:moveRight(delta)
    local adjust
    if self:isGrounded() then
        adjust = Character.runGroundX
        self:setState("run")
    else
        adjust = self.velocity.x >= 0 and Character.runAirSame or Character.runAirOpposite
    end
    
    if self.velocity.x < self.maxVelocityX then
        self.velocity.x = math.min(self.velocity.x + adjust * delta, self.maxVelocityX)
    end
    self.dir = 1
end

function Character:jump()
    self.velocity.y = self.velocity.y + self.jumpVelocity
    self:setState("jump")
    self:setGrounded(false)
end

function Character:rectOverlaps(rect1, rect2)
    return rect1.x < rect2.x + rect2.width and
           rect1.x + rect1.width > rect2.x and
           rect1.y < rect2.y + rect2.height and
           rect1.y + rect1.height > rect2.y
end

return Character