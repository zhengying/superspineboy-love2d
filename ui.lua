-- UI class for Super Spineboy
-- Handles user interface rendering and interaction

local UI = {}
UI.__index = UI

function UI.new(view)
    local self = setmetatable({}, UI)
    self.view = view
    self.model = view.model
    self.showingGameOver = false
    self.gameOverAlpha = 0
    
    self.showingStart = true
    self.startTimer = 0
    
    self.menuVisible = false
    self.buttons = {}
    
    self:createButtons()
    
    return self
end

function UI:createButtons()
    self.buttons = {}
    
    local btnWidth = 100
    local btnHeight = 30
    local padding = 5
    local startX = 10
    local startY = 50
    
    -- Menu Toggle Button
    table.insert(self.buttons, {
        text = "Menu",
        x = 10,
        y = 10,
        width = 80,
        height = 30,
        toggle = true,
        isChecked = function() return self.menuVisible end,
        action = function() self.menuVisible = not self.menuVisible end
    })
    
    -- Menu Panel Buttons
    local speeds = {
        { text = "200%", speed = 2.0 },
        { text = "150%", speed = 1.5 },
        { text = "100%", speed = 1.0 },
        { text = "33%", speed = 0.33 },
        { text = "15%", speed = 0.15 },
        { text = "3%", speed = 0.03 },
        { text = "Pause", speed = 0.0 }
    }
    
    for i, s in ipairs(speeds) do
        table.insert(self.buttons, {
            text = s.text,
            x = startX,
            y = startY + (i-1) * (btnHeight + padding),
            width = btnWidth,
            height = btnHeight,
            menuItem = true,
            toggle = true,
            isChecked = function() return math.abs(self.model.timeScale - s.speed) < 0.01 end,
            action = function() self.model.timeScale = s.speed end
        })
    end
    
    local otherStartY = startY + #speeds * (btnHeight + padding) + 10
    
    -- Debug
    table.insert(self.buttons, {
        text = "Debug",
        x = startX,
        y = otherStartY,
        width = btnWidth,
        height = btnHeight,
        menuItem = true,
        toggle = true,
        isChecked = function() return self.view.debug end,
        action = function() self.view.debug = not self.view.debug end
    })
    
    -- Zoom
    table.insert(self.buttons, {
        text = "Zoom",
        x = startX,
        y = otherStartY + (btnHeight + padding),
        width = btnWidth,
        height = btnHeight,
        menuItem = true,
        toggle = true,
        isChecked = function() return self.view.targetZoom ~= 1 end,
        action = function() 
            if self.view.targetZoom == 1 then
                self.view.targetZoom = 0.4 -- Zoom out
            else
                self.view.targetZoom = 1
            end
        end
    })
    
    -- Background
    table.insert(self.buttons, {
        text = "Background",
        x = startX,
        y = otherStartY + 2 * (btnHeight + padding),
        width = btnWidth,
        height = btnHeight,
        menuItem = true,
        toggle = true,
        isChecked = function() return self.view.drawBackground end,
        action = function() self.view.drawBackground = not self.view.drawBackground end
    })
    
    -- Fullscreen
    table.insert(self.buttons, {
        text = "Fullscreen",
        x = startX,
        y = otherStartY + 3 * (btnHeight + padding),
        width = btnWidth,
        height = btnHeight,
        menuItem = true,
        toggle = false,
        isChecked = function() return love.window.getFullscreen() end,
        action = function() love.window.setFullscreen(not love.window.getFullscreen()) end
    })
    
    -- Restart
    table.insert(self.buttons, {
        text = "Restart",
        x = startX,
        y = otherStartY + 4 * (btnHeight + padding),
        width = btnWidth,
        height = btnHeight,
        menuItem = true,
        toggle = false,
        isChecked = function() return false end,
        action = function() 
            self.model:restart() 
            self.view:restart()
        end
    })
end

function UI:update(dt)
    -- Handle hover effects if needed
    local mx, my = love.mouse.getPosition()
    for _, btn in ipairs(self.buttons) do
        if (not btn.menuItem or self.menuVisible) then
            btn.hover = mx >= btn.x and mx <= btn.x + btn.width and
                        my >= btn.y and my <= btn.y + btn.height
        end
    end
end

function UI:draw()
    -- Draw health bar
    self:drawHealthBar()
    
    -- Draw buttons
    self:drawButtons()
    
    -- Draw game over screen if needed
    if self.showingGameOver then
        self:drawGameOver()
    end
    
    -- Draw start screen if needed
    if self.showingStart then
        self:drawStart()
    end
    
    -- Draw FPS
    if self.menuVisible then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 25)
    end
end

function UI:drawButtons()
    for _, btn in ipairs(self.buttons) do
        if not btn.menuItem or self.menuVisible then
            -- Background
            if btn.isChecked() then
                love.graphics.setColor(0.3, 0.5, 0.8, 0.8) -- Checked (Blueish)
            elseif btn.hover then
                love.graphics.setColor(0.4, 0.4, 0.4, 0.8) -- Hover (Grayish)
            else
                love.graphics.setColor(0.2, 0.2, 0.2, 0.8) -- Normal (Dark)
            end
            
            love.graphics.rectangle("fill", btn.x, btn.y, btn.width, btn.height)
            
            -- Border
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", btn.x, btn.y, btn.width, btn.height)
            
            -- Text
            love.graphics.setColor(1, 1, 1)
            local font = love.graphics.getFont()
            local textWidth = font:getWidth(btn.text)
            local textHeight = font:getHeight()
            love.graphics.print(btn.text, 
                btn.x + (btn.width - textWidth) / 2, 
                btn.y + (btn.height - textHeight) / 2)
        end
    end
end

function UI:drawHealthBar()
    local barWidth = 200
    local barHeight = 20
    local x = love.graphics.getWidth() - barWidth - 10 -- Top right
    local y = 10
    
    -- Background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", x, y, barWidth, barHeight)
    
    -- Health fill
    local healthPercent = math.max(0, self.model.player.hp / 4)
    love.graphics.setColor(1, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", x, y, barWidth * healthPercent, barHeight)
    
    -- Border
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, barWidth, barHeight)
    
    -- Health text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("HP: %d/4", self.model.player.hp), x - 60, y + 2)
    
    -- Enemies remaining
    local aliveEnemies = 0
    for _, enemy in ipairs(self.model.enemies) do
        if enemy.hp > 0 then
            aliveEnemies = aliveEnemies + 1
        end
    end
    
    love.graphics.print(string.format("Enemies: %d", aliveEnemies), x, y + 25)
end

function UI:showGameOver(win)
    self.showingGameOver = true
    self.gameOverAlpha = 0
    self.gameOverTimer = 0
    self.win = win
end

function UI:drawGameOver()
    -- Fade in
    if self.gameOverAlpha < 1 then
        self.gameOverAlpha = self.gameOverAlpha + 0.02
    end
    self.gameOverTimer = self.gameOverTimer + love.timer.getDelta()
    
    -- Dark background
    love.graphics.setColor(0, 0, 0, 0.7 * self.gameOverAlpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    local gameOverImg = self.view.assets.gameOverImage
    local subImg = self.win and self.view.assets.youWinImage or self.view.assets.youLoseImage
    
    if gameOverImg and subImg then
        -- Calculate scales and positions
        -- Game Over Image
        local imgW = gameOverImg:getWidth()
        local imgH = gameOverImg:getHeight()
        local scale1 = math.min((screenW * 0.8) / imgW, 1)
        
        local w1 = imgW * scale1
        local h1 = imgH * scale1
        
        -- Sub Image
        local subW = subImg:getWidth()
        local subH = subImg:getHeight()
        local scale2 = math.min((screenW * 0.6) / subW, 1)
        
        local w2 = subW * scale2
        local h2 = subH * scale2
        
        -- Text
        local font = love.graphics.getFont()
        local text = "CLICK TO TRY AGAIN"
        local textW = font:getWidth(text)
        local textH = font:getHeight()
        
        -- Total height for centering
        local spacing = 20
        local totalH = h1 + spacing + h2 + spacing + textH
        
        local startY = (screenH - totalH) / 2
        
        -- Draw Game Over
        love.graphics.setColor(1, 1, 1, self.gameOverAlpha)
        love.graphics.draw(gameOverImg, (screenW - w1) / 2, startY, 0, scale1, scale1)
        
        -- Draw Sub Image with pulse
        local pulseAlpha = (math.sin(self.gameOverTimer * 5) + 1) / 2 * 0.5 + 0.5
        love.graphics.setColor(1, 1, 1, self.gameOverAlpha * pulseAlpha)
        local y2 = startY + h1 + spacing
        love.graphics.draw(subImg, (screenW - w2) / 2, y2, 0, scale2, scale2)
        
        -- Draw Text
        love.graphics.setColor(1, 1, 1, self.gameOverAlpha)
        local y3 = y2 + h2 + spacing
        love.graphics.print(text, (screenW - textW) / 2, y3)
    end
end

function UI:showStart()
    self.showingStart = true
    self.startTimer = 0
end

function UI:hideStart()
    self.showingStart = false
end

function UI:drawStart()
    -- Draw title image
    local title = self.view.assets.titleImage
    local start = self.view.assets.startImage
    
    if title and start then
        local screenW = love.graphics.getWidth()
        local screenH = love.graphics.getHeight()
        local imgW = title:getWidth()
        local imgH = title:getHeight()
        
        -- Calculate scale to fit within 80% of screen width and 60% of height (leaving room for start text)
        local scaleX = (screenW * 0.8) / imgW
        local scaleY = (screenH * 0.6) / imgH
        local scale = math.min(scaleX, scaleY, 1) -- Don't scale up if image is smaller, but scale down if needed
        
        local w = imgW * scale
        local h = imgH * scale
        local x = (screenW - w) / 2
        local y = (screenH - h) / 2 - 50 * scale
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(title, x, y, 0, scale, scale)
        
        -- Draw start text with pulsing effect
        self.startTimer = self.startTimer + love.timer.getDelta()
        local alpha = (math.sin(self.startTimer * 5) + 1) / 2 * 0.5 + 0.5
        
        local startW = start:getWidth()
        local startH = start:getHeight()
        -- Scale start text relative to title scale
        local startScale = scale 
        
        local sw = startW * startScale
        local sh = startH * startScale
        local sx = (screenW - sw) / 2
        local sy = y + h + 20 * scale
        
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.draw(start, sx, sy, 0, startScale, startScale)
    end
end

function UI:mousePressed(x, y, button)
    if self.showingStart then
        self:hideStart()
        return true
    end

    if button == 1 then
        for _, btn in ipairs(self.buttons) do
            if (not btn.menuItem or self.menuVisible) and btn.hover then
                btn.action()
                return true -- Consumed
            end
        end
    end
    
    if self.showingGameOver then
        self.model:restart()
        self.view:restart()
        return true
    end
    
    return false
end

function UI:keyPressed(key)
    if key == "1" then self.model.timeScale = 0.03
    elseif key == "2" then self.model.timeScale = 0.15
    elseif key == "3" then self.model.timeScale = 0.33
    elseif key == "4" then self.model.timeScale = 1.0
    elseif key == "5" then self.model.timeScale = 1.5
    elseif key == "6" then self.model.timeScale = 2.0
    elseif key == "p" or key == "`" then 
        if self.model.timeScale == 0 then self.model.timeScale = 1.0 else self.model.timeScale = 0 end
    elseif key == "b" then self.view.drawBackground = not self.view.drawBackground
    elseif key == "z" then 
        if self.view.targetZoom == 1 then self.view.targetZoom = 0.4 else self.view.targetZoom = 1 end
    elseif key == "i" then self.view.debug = not self.view.debug
    elseif key == "t" then 
        -- Reload assets not implemented easily in Love2D without clearing everything
    elseif key == "escape" then
        if love.window.getFullscreen() then
            love.window.setFullscreen(false)
        else
            love.event.quit()
        end
    elseif key == "return" and (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) then
        love.window.setFullscreen(not love.window.getFullscreen())
    end
end

return UI
