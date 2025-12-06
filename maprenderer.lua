local STI = require "libs.sti"

local MapRenderer = {}
MapRenderer.__index = MapRenderer

function MapRenderer.new(mapPath)
    local self = setmetatable({}, MapRenderer)
    self.mapPath = mapPath
    self.map = STI("assets/map/map.lua")
    if self.map.layers["Collisions"] then
        self.map.layers["Collisions"].visible = false
    end
    if self.map.layers["Foreground Tint"] then
        self.map.layers["Foreground Tint"].visible = false
    end
    if self.map.layers["Foreground Tint2"] then
        self.map.layers["Foreground Tint2"].visible = false
    end
    self.tileWidth = self.map.tilewidth
    self.tileHeight = self.map.tileheight
    self.mapWidth = self.map.width
    self.mapHeight = self.map.height

    -- Precompute collision data with flipped y
    self.collisionData = {}
    local layer = self.map.layers["Collisions"]
    if layer then
        for row = 1, self.mapHeight do
            for col = 1, self.mapWidth do
                local gid = layer.data[row][col] and layer.data[row][col].gid or 0
                local flipped_row = self.mapHeight - row + 1
                local index = (flipped_row - 1) * self.mapWidth + col
                self.collisionData[index] = gid
            end
        end
    end

    -- Optimize map rendering with chunks
    self:optimize()

    return self
end

function MapRenderer:optimize()
    local chunkWidth = 16
    local chunkHeight = 16
    
    -- Reset tile instances as we will rebuild batches to support animations
    -- We need to be careful not to break other things relying on tileInstances if any
    self.map.tileInstances = {}
    
    for _, layer in ipairs(self.map.layers) do
        if layer.type == "tilelayer" then
            -- Create chunks
            layer.chunks = {}
            local cols = math.ceil(layer.width / chunkWidth)
            local rows = math.ceil(layer.height / chunkHeight)
            
            for y = 1, rows do
                layer.chunks[y] = {}
                for x = 1, cols do
                    layer.chunks[y][x] = {
                        x = (x-1) * chunkWidth, -- in tiles
                        y = (y-1) * chunkHeight,
                        width = chunkWidth,
                        height = chunkHeight,
                        batches = {}
                    }
                end
            end
            
            -- Clear existing batches from STI to prevent double drawing
            if layer.batches then
                for _, batch in pairs(layer.batches) do
                    self.map.freeBatchSprites[batch] = nil
                end
            end
            layer.batches = {}
            
            -- Populate chunks
            for y = 1, layer.height do
                for x = 1, layer.width do
                    local tile = layer.data[y][x]
                    if tile then
                        local cx = math.floor((x-1) / chunkWidth) + 1
                        local cy = math.floor((y-1) / chunkHeight) + 1
                        local chunk = layer.chunks[cy][cx]
                        
                        self:addTileToChunk(layer, chunk, tile, x, y)
                    end
                end
            end
            
            -- Override draw function
            layer.draw = function() self:drawChunkedLayer(layer) end
        end
    end
end

function MapRenderer:addTileToChunk(layer, chunk, tile, x, y)
    local batches = chunk.batches
    local tileset = tile.tileset
    local batch = batches[tileset]
    
    if not batch then
        local image = self.map.tilesets[tileset].image
        -- Estimate size: chunk area.
        batch = love.graphics.newSpriteBatch(image, chunk.width * chunk.height)
        batches[tileset] = batch
    end
    
    local tileX, tileY = self.map:getLayerTilePosition(layer, tile, x, y)
    local id = batch:add(tile.quad, tileX, tileY, tile.r, tile.sx, tile.sy)
    
    -- Update instances for animation
    local gid = tile.gid
    if not self.map.tileInstances[gid] then
        self.map.tileInstances[gid] = {}
    end
    
    table.insert(self.map.tileInstances[gid], {
        layer = layer,
        batch = batch,
        id = id,
        x = tileX,
        y = tileY,
        r = tile.r,
        oy = 0
    })
end

function MapRenderer:drawChunkedLayer(layer)
    local camera = self.currentCamera
    
    if not camera then 
        -- Fallback if no camera
        for y, row in pairs(layer.chunks) do
            for x, chunk in pairs(row) do
                for _, batch in pairs(chunk.batches) do
                    love.graphics.draw(batch, math.floor(layer.x), math.floor(layer.y))
                end
            end
        end
        return 
    end
    
    -- Calculate visible range in meters
    local halfW = self:getCameraWidth() / 2
    local halfH = self:getCameraHeight() / 2
    local minX = camera.x - halfW
    local maxX = camera.x + halfW
    local minY = camera.y - halfH
    local maxY = camera.y + halfH
    
    -- Convert to Tile Coordinates
    -- X is direct (0 to MapWidth)
    local startCol = math.floor(minX)
    local endCol = math.ceil(maxX)
    
    -- Y is inverted (0 is bottom, MapHeight is top)
    -- Row 1 is Top (MapHeight), Row MapHeight is Bottom (1)
    local startRow = math.floor(self.mapHeight - maxY)
    local endRow = math.ceil(self.mapHeight - minY)
    
    -- Swap if needed because Y axis inversion
    if startRow > endRow then startRow, endRow = endRow, startRow end
    
    -- Clamp
    startCol = math.max(1, startCol)
    endCol = math.min(self.mapWidth, endCol)
    startRow = math.max(1, startRow)
    endRow = math.min(self.mapHeight, endRow)
    
    -- Determine Chunks
    local chunkW = 16
    local chunkH = 16
    local startChunkX = math.floor((startCol-1)/chunkW) + 1
    local endChunkX = math.floor((endCol-1)/chunkW) + 1
    local startChunkY = math.floor((startRow-1)/chunkH) + 1
    local endChunkY = math.floor((endRow-1)/chunkH) + 1
    
    -- Iterate Visible Chunks
    for cy = startChunkY, endChunkY do
        if layer.chunks[cy] then
            for cx = startChunkX, endChunkX do
                local chunk = layer.chunks[cy][cx]
                if chunk then
                    for _, batch in pairs(chunk.batches) do
                        love.graphics.draw(batch, math.floor(layer.x), math.floor(layer.y))
                    end
                end
            end
        end
    end
end

function MapRenderer:draw(camera)
    self.currentCamera = camera
    love.graphics.push()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.scale(1/64, -1/64)
    love.graphics.translate(0, -self.mapHeight * self.tileHeight)
    for _, layer in ipairs(self.map.layers) do
        if layer.visible and layer.opacity > 0 then
            self.map:drawLayer(layer)
        end
    end
    love.graphics.pop()
    self.currentCamera = nil
end

function MapRenderer:isTileSolid(x, y)
    local index = y * self.mapWidth + x + 1
    local tileId = self.collisionData[index]
    return tileId and tileId > 0
end

function MapRenderer:getCameraWidth()
    return love.graphics.getWidth() / love.graphics.getHeight() * self:getCameraHeight()
end

function MapRenderer:getCameraHeight()
    return 24
end

return MapRenderer
