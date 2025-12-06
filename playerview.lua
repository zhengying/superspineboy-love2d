-- PlayerView class for Super Spineboy
-- Handles player-specific Spine animation and rendering

local CharacterView = require("character_view")
local Player = require("player")

local PlayerView = setmetatable({}, {__index = CharacterView})
PlayerView.__index = PlayerView

function PlayerView.new(view)
    local self = setmetatable(CharacterView.new(view, view.assets.playerSkeletonData, view.assets.playerAnimationData), PlayerView)
    
    self.player = view.player
    
    -- Get bones for aiming
    self.rearUpperArmBone = self.skeleton:findBone("rear_upper_arm")
    self.rearBracerBone = self.skeleton:findBone("rear_bracer")
    self.gunBone = self.skeleton:findBone("gun")
    self.headBone = self.skeleton:findBone("head")
    self.torsoBone = self.skeleton:findBone("torso")
    self.frontUpperArmBone = self.skeleton:findBone("front_upper_arm")
    
    self.shootAnimation = view.assets.playerSkeletonData:findAnimation("shoot")
    self.hitAnimation = view.assets.playerSkeletonData:findAnimation("hit")
    
    self.canShoot = false
    self.burstShots = 0
    self.burstTimer = 0
    
    -- Set up footstep event listener
    local footstepEvent = view.assets.playerSkeletonData:findEvent("footstep")
    if footstepEvent then
        self.animationState:addListener({
            event = function(trackIndex, event)
                if event.data == footstepEvent then
                    if event.intValue == 1 then
                        view.assets:playSound("footstep1")
                    else
                        view.assets:playSound("footstep2")
                    end
                end
            end
        })
    end
    
    return self
end

function PlayerView:update(delta)
    -- When not shooting, reset the number of burst shots
    if not self.view.touched and self.burstTimer > 0 then
        self.burstTimer = self.burstTimer - delta
        if self.burstTimer < 0 then
            self.burstShots = 0
        end
    end
    
    -- Update skeleton position
    self.skeleton.x = self.player.position.x + PlayerView.width / 2
    self.skeleton.y = self.player.position.y
    
    -- Set animation
    if not self:setAnimation(self.view.assets.playerStates[self.player.state], self.player.stateChanged) then
        self.animationState:update(delta)
    end
    
    -- Reset bones that are procedurally modified to prevent rotation accumulation
    if self.headBone then self.headBone.rotation = self.headBone.data.rotation end
    if self.torsoBone then self.torsoBone.rotation = self.torsoBone.data.rotation end
    if self.frontUpperArmBone then self.frontUpperArmBone.rotation = self.frontUpperArmBone.data.rotation end

    -- Apply animation
    self.animationState:apply(self.skeleton)

    -- Ensure muzzle flash doesn't persist after shoot animation ends
    if not self.animationState:getCurrent(1) then
        local muzzleSlot = self.skeleton:findSlot("muzzle")
        if muzzleSlot then muzzleSlot:setAttachment(nil) end
    end
    
    -- Handle aiming
    local mx, my = love.mouse.getPosition()
    local cameraWidth = self.view:getCameraWidth()
    if cameraWidth > 0 then
        local scale = love.graphics.getWidth() / cameraWidth
        if scale > 0 then
            mx = mx / scale + self.view.camera.x - love.graphics.getWidth() / scale / 2
            my = (love.graphics.getHeight() - my) / scale + self.view.camera.y - love.graphics.getHeight() / scale / 2
            
            self:updateAiming(mx, my)
        end
    end
    
    -- Update skeleton transform
    self.skeleton.flipX = (self.player.dir < 0)
    self.skeleton:updateWorldTransform()
end

function PlayerView:updateAiming(mx, my)
    self.canShoot = false
    
    -- Check if we have all the necessary bones
    if not self.rearUpperArmBone or not self.rearBracerBone or not self.gunBone then
        self.canShoot = true
        return
    end
    
    -- Check if mouse is far enough from player
    if math.abs(self.skeleton.y - my) <= 2.7 and math.abs(self.skeleton.x - mx) <= 0.75 then
        return
    end
    
    -- Store bone rotations from the animation
    local rearUpperArmRotation = self.rearUpperArmBone.rotation
    local rearBracerRotation = self.rearBracerBone.rotation
    local gunRotation = self.gunBone.rotation
    
    -- Straighten the arm for easier aiming
    self.rearUpperArmBone.rotation = 0
    local shootRotation = 11
    
    if not self.animationState:getCurrent(1) then
        self.rearBracerBone.rotation = 0
        self.gunBone.rotation = 0
    else
        shootRotation = shootRotation + 25
    end
    
    self.skeleton.flipX = (self.player.dir < 0)
    self.skeleton:updateWorldTransform()
    
    -- Calculate angle to mouse
    local dx = self.rearUpperArmBone.worldX - mx
    local dy = self.rearUpperArmBone.worldY - my
    local angle = math.deg(math.atan2(dy, dx))
    
    -- NaN check
    if angle ~= angle then return end
    
    if angle < 0 then angle = angle + 360 end
    
    local behind = (angle < 90 or angle > 270) and -1 or 1
    if behind == -1 then angle = -angle end
    
    if self.player.state == "idle" or (self.view.touched and (self.player.state == "jump" or self.player.state == "fall")) then
        self.player.dir = behind
    end
    
    if behind ~= self.player.dir then
        angle = -angle
    end
    
    if self.player.state ~= "idle" and behind ~= self.player.dir then
        -- Don't allow shooting behind unless idle
        self.rearBracerBone.rotation = rearBracerRotation
        self.rearUpperArmBone.rotation = rearUpperArmRotation
        self.gunBone.rotation = gunRotation
    else
        if behind == 1 then angle = angle + 180 end
        
        -- Apply kickback based on burst shots
        local kickbackFactor = math.min(1, self.burstShots / Player.kickbackShots) * (self.burstTimer / Player.burstDuration)
        angle = angle + Player.kickbackAngle * kickbackFactor
        
        local gunArmAngle = angle - shootRotation
        
        -- Compute head, torso and front arm angles
        local headAngle
        if self.player.dir == -1 then
            angle = angle + 360
            if angle < 180 then
                local t = math.max(0, math.min(1, angle / 50))
                headAngle = 25 * t * t
            else
                local t = math.max(0, 1 - math.max(0, (angle - 310) / 50))
                headAngle = -15 * t * t
            end
        else
            if angle < 360 then
                local t = math.max(0, 1 - math.max(0, ((angle - 310) / 50)))
                headAngle = -15 * t * t
            else
                local t = math.max(0, 1 - math.max(0, ((410 - angle) / 50)))
                headAngle = 25 * t * t
            end
        end
        
        local torsoAngle = headAngle * 0.75
        
        if self.headBone then self.headBone.rotation = self.headBone.rotation + headAngle end
        if self.torsoBone then self.torsoBone.rotation = self.torsoBone.rotation + torsoAngle end
        if self.frontUpperArmBone then self.frontUpperArmBone.rotation = self.frontUpperArmBone.rotation - headAngle * 1.4 end
        
        self.rearUpperArmBone.rotation = gunArmAngle - torsoAngle - (self.rearUpperArmBone.worldRotation or 0)
        self.canShoot = true
    end
end

function PlayerView:jump()
    self.view.jumpPressed = false
    self.player:jump()
    self:setAnimation(self.view.assets.playerStates["jump"], true)
end

function PlayerView:shoot(mx, my)
    if not self.canShoot or self.player.shootTimer >= 0 then return end
    if mx == nil or my == nil then
        local sx, sy = love.mouse.getPosition()
        local cameraWidth = self.view:getCameraWidth()
        if cameraWidth <= 0 then return end
        local scale = love.graphics.getWidth() / cameraWidth
        if scale <= 0 then return end
        
        mx = (mx or sx) / scale + self.view.camera.x - love.graphics.getWidth() / scale / 2
        my = (love.graphics.getHeight() - (my or sy)) / scale + self.view.camera.y - love.graphics.getHeight() / scale / 2
    end
    
    self.player.shootTimer = Player.shootDelay
    self.burstTimer = Player.burstDuration
    
    -- Calculate bullet position and velocity
    local x, y = 0, 0
    if self.rearUpperArmBone and self.rearBracerBone and self.gunBone then
        x = self.rearUpperArmBone.worldX
        y = self.rearUpperArmBone.worldY
    else
        x = PlayerView.width / 2
        y = PlayerView.height / 2
    end
    
    local dx = mx - x
    local dy = my - y
    local angle = math.deg(math.atan2(dy, dx))
    
    local kickbackFactor = math.min(1, self.burstShots / Player.kickbackShots)
    angle = angle + Player.kickbackAngle * kickbackFactor * self.player.dir
    
    local variance = Player.kickbackVariance * math.min(1, self.burstShots / Player.kickbackVarianceShots)
    angle = angle + (math.random() * 2 - 1) * variance
    
    local vx = math.cos(math.rad(angle)) * Player.bulletSpeed + self.player.velocity.x * Player.bulletInheritVelocity
    local vy = math.sin(math.rad(angle)) * Player.bulletSpeed + self.player.velocity.y * Player.bulletInheritVelocity
    
    if self.rearUpperArmBone and self.rearBracerBone and self.gunBone then
        x = self.gunBone.worldX
        y = self.gunBone.worldY + Player.shootOffsetY * self.view.assets.scale
        x = x + math.cos(math.rad(angle)) * Player.shootOffsetX * self.view.assets.scale
        y = y + math.sin(math.rad(angle)) * Player.shootOffsetX * self.view.assets.scale
    end
    
    self.model:addBullet(x, y, vx, vy, math.deg(math.atan2(vy, vx)))
    
    if self.shootAnimation then
        self.animationState:setAnimation(1, self.shootAnimation, false)
    end
    
    -- Apply camera shake
    local cameraShake = 6 * self.view.assets.scale
    self.view.shakeX = self.view.shakeX + cameraShake * (math.random() < 0.5 and 1 or -1)
    self.view.shakeY = self.view.shakeY + cameraShake * (math.random() < 0.5 and 1 or -1)
    
    -- Apply kickback
    self.player.velocity.x = self.player.velocity.x - Player.kickback * self.player.dir
    
    self.view.assets:playSound("shoot")
    
    self.burstShots = math.min(Player.kickbackShots, self.burstShots + 1)
end

function PlayerView:draw()
    self.view.assets.renderer:draw(self.skeleton)
end

-- Constants
PlayerView.width = 67 * (1/64)
PlayerView.height = 285 * (1/64)
PlayerView.flashTime = 0.07

return PlayerView
