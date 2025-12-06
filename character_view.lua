-- Base CharacterView class for Super Spineboy
-- Handles Spine animation rendering for characters

package.path = package.path .. ";spine-love2d/?.lua;spine-love2d/?/?.lua;spine-love2d/?/init.lua"
local spine_load_success, spine = pcall(require, "spine-love2d")
if not spine_load_success then
    package.path = package.path .. ";../spine-love2d/?.lua;../spine-love2d/?/?.lua;../spine-love2d/?/init.lua;../../spine-love2d/?.lua;../../spine-love2d/?/?.lua;../../spine-love2d/?/init.lua"
    spine = require("spine-love2d")
end
local CharacterView = {}
CharacterView.__index = CharacterView

function CharacterView.new(view, skeletonData, animationData)
    local self = setmetatable({}, CharacterView)
    self.view = view
    self.model = view.model
    
    self.skeleton = spine.Skeleton.new(skeletonData)
    self.animationState = spine.AnimationState.new(animationData)
    self.skeleton:setToSetupPose()
    self.skeleton:updateWorldTransform()
    
    return self
end

function CharacterView:setAnimation(stateView, force)
    -- Changes the current animation on track 0 of the AnimationState, if needed
    local animation = stateView.animation
    local current = self.animationState:getCurrent(0)
    local oldAnimation = current and current.animation or nil
    
    -- Check if we are trying to set the same animation that was last played, 
    -- even if it finished and was removed from the track (so current is nil).
    -- This prevents non-looping animations (like death) from restarting.
    if not force and self.lastAnimation == animation then
        return false
    end
    
    if force or oldAnimation ~= animation then
        if not animation then 
            self.lastAnimation = nil
            return true 
        end
        
        self.lastAnimation = animation
        
        local entry = self.animationState:setAnimation(0, animation, stateView.loop)
        
        if oldAnimation and stateView.startTimes then
            local startTime = stateView.startTimes[oldAnimation] or stateView.defaultStartTime
            entry:setTrackTime(startTime)
        end
        
        if not stateView.loop then
            entry:setTrackEnd(1000000) -- Large number instead of Float.MAX_VALUE
        end
        
        return true
    end
    
    return false
end

function CharacterView:update(delta)
    self.animationState:update(delta)
end

function CharacterView:draw()
    -- Override in subclasses
end

return CharacterView
