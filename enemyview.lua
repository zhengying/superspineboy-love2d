-- EnemyView class for Super Spineboy
-- Handles enemy-specific Spine animation and rendering

local CharacterView = require("character_view")

local EnemyView = setmetatable({}, {__index = CharacterView})
EnemyView.__index = EnemyView
EnemyView.fadeTime = 3

function EnemyView.new(view, enemy)
    local self = setmetatable(CharacterView.new(view, view.assets.enemySkeletonData, view.assets.enemyAnimationData), EnemyView)
    
    self.enemy = enemy
    
    -- Get head slot and attachments for visual variations
    self.headSlot = self.skeleton:findSlot("head")
    self.burstHeadAttachment = self.skeleton:getAttachment("head", "burst01")
    self.hitAnimation = self.skeleton.data and self.skeleton.data:findAnimation("hit") or nil
    
    -- Set up squish sound event listener
    local squishEvent = view.assets.enemySkeletonData:findEvent("squish")
    if squishEvent then
        self.animationState:addListener({
            event = function(trackIndex, event)
                if event.data == squishEvent then
                    view.assets:playSound("squish")
                end
            end
        })
    end
    
    -- Set head color based on enemy type
    self.headColor = { r = 1, g = 1, b = 1, a = 1 }
    if enemy.type == "strong" then
        self.headColor = { r = 1, g = 0.6, b = 1, a = 1 }
    else
        self.headColor = {
            r = 0.8 + math.random() * 0.2,
            g = 0.8 + math.random() * 0.2,
            b = 0.8 + math.random() * 0.2,
            a = 1
        }
    end
    
    if self.headSlot and self.headSlot.color then
        self.headSlot.color.r = self.headColor.r
        self.headSlot.color.g = self.headColor.g
        self.headSlot.color.b = self.headColor.b
        self.headSlot.color.a = self.headColor.a
    end
    
    return self
end

function EnemyView:update(delta)
    -- Change head attachment for enemies that are about to die
    if self.enemy.hp == 1 and self.enemy.type ~= "weak" and self.burstHeadAttachment then
        self.headSlot.attachment = self.burstHeadAttachment
    end
    
    -- Change color for big enemies
    if self.enemy.type == "big" then
        local t = 1 - math.max(0, self.enemy.bigTimer / EnemyView.fadeTime)
        local r = self.headColor.r * (1 - t) + t * 0
        local g = self.headColor.g * (1 - t) + t * 1
        local b = self.headColor.b * (1 - t) + t * 1
        if self.headSlot and self.headSlot.color then
            self.headSlot.color.r = r
            self.headSlot.color.g = g
            self.headSlot.color.b = b
            self.headSlot.color.a = 1
        end
    end
    
    -- Update skeleton position
    self.skeleton.x = self.enemy.position.x + EnemyView.width / 2
    self.skeleton.y = self.enemy.position.y
    
    -- Set animation
    if not self:setAnimation(self.view.assets.enemyStates[self.enemy.state], self.enemy.stateChanged) then
        self.animationState:update(delta)
    end
    
    -- Apply animation
    self.animationState:apply(self.skeleton)
    
    -- Apply direction
    self.skeleton.flipX = (self.enemy.dir < 0)
    
    -- Apply size scaling
    local root = self.skeleton.rootBone or self.skeleton.bones[1]
    if root then
        root.scaleX = root.data.scaleX * self.enemy.size
        root.scaleY = root.data.scaleY * self.enemy.size
    end
    
    -- Update transform
    self.skeleton:updateWorldTransform()
end

function EnemyView:draw()
    self.view.assets.renderer:draw(self.skeleton)
end

-- Constants
EnemyView.width = 105 * (1/64)

return EnemyView
