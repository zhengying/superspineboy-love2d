-- Assets class for Super Spineboy
-- Handles loading and management of all game assets

package.path = package.path .. ";spine-love2d/?.lua;spine-love2d/?/?.lua;spine-love2d/?/init.lua"
local spine_load_success, spine = pcall(require, "spine-love2d")
if not spine_load_success then
    package.path = package.path .. ";../spine-love2d/?.lua;../spine-love2d/?/?.lua;../spine-love2d/?/init.lua;../../spine-love2d/?.lua;../../spine-love2d/?/?.lua;../../spine-love2d/?/init.lua"
    spine = require("spine-love2d")
end

local Assets = {}
Assets.__index = Assets

-- Scale factor
Assets.scale = 1/64

function Assets.new()
    local self = setmetatable({}, Assets)
    self:load()
    return self
end

function Assets:load()
    -- Load texture regions
    self.bulletImage = love.graphics.newImage("assets/bullet.png")
    self.hitImage = love.graphics.newImage("assets/bullet-hit.png")
    self.crosshairImage = love.graphics.newImage("assets/crosshair.png")
    self.titleImage = love.graphics.newImage("assets/title.png")
    self.gameOverImage = love.graphics.newImage("assets/gameOver.png")
    self.youLoseImage = love.graphics.newImage("assets/youLose.png")
    self.youWinImage = love.graphics.newImage("assets/youWin.png")
    self.startImage = love.graphics.newImage("assets/start.png")
    
    -- Set texture filters
    for _, img in pairs({self.bulletImage, self.hitImage, self.crosshairImage, 
                        self.titleImage, self.gameOverImage, self.youLoseImage,
                        self.youWinImage, self.startImage}) do
        img:setFilter("nearest", "linear")
    end
    
    -- Load spine assets for player
    self:loadPlayerAssets()
    
    -- Load spine assets for enemies
    self:loadEnemyAssets()

    -- Create shared skeleton renderer
    self.renderer = spine.SkeletonRenderer.new()
    
    -- Load sounds
    self.sounds = {}
    self.sounds.shoot = love.audio.newSource("assets/sounds/shoot.ogg", "static")
    self.sounds.hit = love.audio.newSource("assets/sounds/hit.ogg", "static")
    self.sounds.footstep1 = love.audio.newSource("assets/sounds/footstep1.ogg", "static")
    self.sounds.footstep2 = love.audio.newSource("assets/sounds/footstep2.ogg", "static")
    self.sounds.squish = love.audio.newSource("assets/sounds/squish.ogg", "static")
    self.sounds.hurtPlayer = love.audio.newSource("assets/sounds/hurt-player.ogg", "static")
    self.sounds.hurtAlien = love.audio.newSource("assets/sounds/hurt-alien.ogg", "static")
    
    -- Set sound volumes
    self.sounds.squish:setVolume(0.6)
    self.sounds.hurtAlien:setVolume(0.5)
end

function Assets:loadPlayerAssets()
    -- Load atlas
    local atlasText = love.filesystem.read("assets/spineboy/spineboy.atlas")
    self.playerAtlas = spine.atlas.Atlas.new()
    self.playerAtlas:loadAtlasFile(atlasText, "assets/spineboy")
    
    -- Load skeleton data
    local attachmentLoader = spine.atlas.AtlasAttachmentLoader.new(self.playerAtlas)
    local skeletonJson = love.filesystem.read("assets/spineboy/spineboy.json")
    local jsonTable = spine.utils.jsonDecode(skeletonJson)
    
    self.playerSkeletonData = spine.SkeletonData.new()
    -- Calculate scale based on Java version (Player.height / Player.heightSource)
    local playerHeightSource = 625
    local playerHeight = 285 * Assets.scale
    self.playerSkeletonData.scale = playerHeight / playerHeightSource
    self.playerSkeletonData:loadFromJson(jsonTable, attachmentLoader)
    
    -- Create animation state data
    self.playerAnimationData = spine.AnimationStateData.new(self.playerSkeletonData)
    self.playerAnimationData:setDefaultMix(0.2)
    
    -- Set up specific mixes
    self:setMix(self.playerAnimationData, "idle", "run", 0.3)
    self:setMix(self.playerAnimationData, "run", "idle", 0.1)
    self:setMix(self.playerAnimationData, "shoot", "shoot", 0)
    
    -- Set up state views
    self.playerStates = {}
    self:setupState(self.playerStates, self.playerSkeletonData, "death", "death", false)
    self:setupState(self.playerStates, self.playerSkeletonData, "idle", "idle", true)
    self:setupState(self.playerStates, self.playerSkeletonData, "jump", "jump", false)
    self:setupState(self.playerStates, self.playerSkeletonData, "run", "run", true)
    self:setupState(self.playerStates, self.playerSkeletonData, "fall", "jump", false)
end

function Assets:loadEnemyAssets()
    -- Load atlas
    local atlasText = love.filesystem.read("assets/alien/alien.atlas")
    self.enemyAtlas = spine.atlas.Atlas.new()
    self.enemyAtlas:loadAtlasFile(atlasText, "assets/alien")
    
    -- Load skeleton data
    local attachmentLoader = spine.atlas.AtlasAttachmentLoader.new(self.enemyAtlas)
    local skeletonJson = love.filesystem.read("assets/alien/alien.json")
    local jsonTable = spine.utils.jsonDecode(skeletonJson)
    
    self.enemySkeletonData = spine.SkeletonData.new()
    -- Calculate scale based on Java version (Enemy.height / Enemy.heightSource)
    local enemyHeightSource = 398
    local enemyHeight = 200 * Assets.scale
    self.enemySkeletonData.scale = enemyHeight / enemyHeightSource
    self.enemySkeletonData:loadFromJson(jsonTable, attachmentLoader)
    
    -- Create animation state data
    self.enemyAnimationData = spine.AnimationStateData.new(self.enemySkeletonData)
    self.enemyAnimationData:setDefaultMix(0.1)
    
    -- Set up state views
    self.enemyStates = {}
    self:setupState(self.enemyStates, self.enemySkeletonData, "idle", "run", true)
    self:setupState(self.enemyStates, self.enemySkeletonData, "jump", "jump", true)
    self:setupState(self.enemyStates, self.enemySkeletonData, "run", "run", true)
    self:setupState(self.enemyStates, self.enemySkeletonData, "death", "death", false)
    self:setupState(self.enemyStates, self.enemySkeletonData, "fall", "run", false)
end

function Assets:setMix(animationData, from, to, mixTime)
    local fromAnim = animationData.skeletonData:findAnimation(from)
    local toAnim = animationData.skeletonData:findAnimation(to)
    if fromAnim and toAnim then
        animationData:setMix(fromAnim, toAnim, mixTime)
    end
end

function Assets:setupState(statesTable, skeletonData, stateKey, animationName, loop)
    local stateView = {
        animation = nil,
        loop = loop,
        startTimes = {},
        defaultStartTime = 0
    }
    
    local anim = skeletonData:findAnimation(animationName)
    
    stateView.animation = anim
    statesTable[stateKey] = stateView
    
    return stateView
end

function Assets:playSound(soundName)
    if self.sounds[soundName] then
        self.sounds[soundName]:clone():play()
    end
end

function Assets:dispose()
    -- Cleanup resources if needed
end

-- Constructor wrapper
return setmetatable(Assets, {
    __call = function(cls)
        return cls.new()
    end
})
