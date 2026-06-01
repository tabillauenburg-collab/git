--// LION ESP ULTIMATE + MODERNES GUI //--
--// 100% funktionierend | Universal | R6/R15

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// STANDARD-EINSTELLUNGEN //--
local Settings = {
    Enabled = true,
    Box = true,
    Name = true,
    HealthBar = true,
    Skeleton = true,
    Traceline = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    TracelineColor = Color3.fromRGB(255, 0, 0),
    HealthBarWidth = 40,
    HealthBarHeight = 4,
    HealthBarPosition = "Right",
    Transparency = 1,
    BoxThickness = 1,
    NameSize = 14,
    SkeletonThickness = 1,
    TracelineThickness = 1
}

--// SPEICHER //--
local espObjects = {}
local menuOpen = false

--// HILFSFUNKTIONEN //--
local function getPlayerTopAndBottom(character)
    local head = character:FindFirstChild("Head")
    if not head then return nil, nil end
    
    local highestY = head.Position.Y + (head.Size.Y / 2)
    local lowestY = head.Position.Y - (head.Size.Y / 2)
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local partTop = part.Position.Y + (part.Size.Y / 2)
            local partBottom = part.Position.Y - (part.Size.Y / 2)
            if partTop > highestY then highestY = partTop end
            if partBottom < lowestY then lowestY = partBottom end
        end
    end
    
    return highestY, lowestY
end

local function getHealthColor(health, maxHealth)
    local percent = health / maxHealth
    if percent <= 0.3 then
        return Color3.fromRGB(255, 0, 0)
    elseif percent <= 0.7 then
        local t = (percent - 0.3) / 0.4
        return Color3.fromRGB(255, 255 * t, 0)
    else
        local t = (percent - 0.7) / 0.3
        return Color3.fromRGB(255 * (1 - t), 255, 0)
    end
end

--// ESP OBJEKTE //--
local function addPlayer(player)
    if player == LocalPlayer then return end
    
    local drawings = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        HealthBg = Drawing.new("Line"),
        Traceline = Drawing.new("Line"),
        Skeleton = {}
    }
    
    drawings.Box.Color = Settings.BoxColor
    drawings.Box.Thickness = Settings.BoxThickness
    drawings.Box.Filled = false
    drawings.Box.Transparency = Settings.Transparency
    drawings.Box.Visible = false
    
    drawings.Name.Color = Settings.NameColor
    drawings.Name.Size = Settings.NameSize
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Transparency = Settings.Transparency
    drawings.Name.Visible = false
    
    drawings.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    drawings.HealthBar.Thickness = Settings.HealthBarHeight
    drawings.HealthBar.Transparency = Settings.Transparency
    drawings.HealthBar.Visible = false
    
    drawings.HealthBg.Color = Color3.fromRGB(50, 50, 50)
    drawings.HealthBg.Thickness = Settings.HealthBarHeight
    drawings.HealthBg.Transparency = Settings.Transparency
    drawings.HealthBg.Visible = false
    
    drawings.Traceline.Color = Settings.TracelineColor
    drawings.Traceline.Thickness = Settings.TracelineThickness
    drawings.Traceline.Transparency = Settings.Transparency
    drawings.Traceline.Visible = false
    
    espObjects[player] = drawings
end

local function removePlayer(player)
    local drawings = espObjects[player]
    if drawings then
        drawings.Box:Remove()
        drawings.Name:Remove()
        drawings.HealthBar:Remove()
        drawings.HealthBg:Remove()
        drawings.Traceline:Remove()
        for _, line in pairs(drawings.Skeleton) do
            line:Remove()
        end
        espObjects[player] = nil
    end
end

--// SKELETON (R6/R15) //--
local function getSkeletonBones(character)
    local bones = {}
    local head = character:FindFirstChild("Head")
    if head then bones.Head = head.Position end
    
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if torso then bones.Torso = torso.Position end
    
    local lowerTorso = character:FindFirstChild("LowerTorso")
    if lowerTorso then bones.LowerTorso = lowerTorso.Position end
    
    local leftArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")
    local rightArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
    if leftArm then bones.LeftArm = leftArm.Position end
    if rightArm then bones.RightArm = rightArm.Position end
    
    local leftForearm = character:FindFirstChild("LeftLowerArm")
    local rightForearm = character:FindFirstChild("RightLowerArm")
    if leftForearm then bones.LeftForearm = leftForearm.Position end
    if rightForearm then bones.RightForearm = rightForearm.Position end
    
    local leftHand = character:FindFirstChild("LeftHand")
    local rightHand = character:FindFirstChild("RightHand")
    if leftHand then bones.LeftHand = leftHand.Position end
    if rightHand then bones.RightHand = rightHand.Position end
    
    local leftLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg")
    local rightLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg")
    if leftLeg then bones.LeftLeg = leftLeg.Position end
    if rightLeg then bones.RightLeg = rightLeg.Position end
    
    local leftLowerLeg = character:FindFirstChild("LeftLowerLeg")
    local rightLowerLeg = character:FindFirstChild("RightLowerLeg")
    if leftLowerLeg then bones.LeftLowerLeg = leftLowerLeg.Position end
    if rightLowerLeg then bones.RightLowerLeg = rightLowerLeg.Position end
    
    local leftFoot = character:FindFirstChild("LeftFoot")
    local rightFoot = character:FindFirstChild("RightFoot")
    if leftFoot then bones.LeftFoot = leftFoot.Position end
    if rightFoot then bones.RightFoot = rightFoot.Position end
    
    return bones
end

local function getSkeletonConnections(bones)
    local conns = {}
    if bones.Head and bones.Torso then table.insert(conns, {bones.Head, bones.Torso}) end
    if bones.Torso and bones.LeftArm then table.insert(conns, {bones.Torso, bones.LeftArm}) end
    if bones.Torso and bones.RightArm then table.insert(conns, {bones.Torso, bones.RightArm}) end
    if bones.LeftArm and bones.LeftForearm then table.insert(conns, {bones.LeftArm, bones.LeftForearm}) end
    if bones.RightArm and bones.RightForearm then table.insert(conns, {bones.RightArm, bones.RightForearm}) end
    if bones.LeftForearm and bones.LeftHand then table.insert(conns, {bones.LeftForearm, bones.LeftHand}) end
    if bones.RightForearm and bones.RightHand then table.insert(conns, {bones.RightForearm, bones.RightHand}) end
    if bones.Torso and bones.LowerTorso then table.insert(conns, {bones.Torso, bones.LowerTorso}) end
    if bones.LowerTorso then
        if bones.LeftLeg then table.insert(conns, {bones.LowerTorso, bones.LeftLeg}) end
        if bones.RightLeg then table.insert(conns, {bones.LowerTorso, bones.RightLeg}) end
    elseif bones.Torso then
        if bones.LeftLeg then table.insert(conns, {bones.Torso, bones.LeftLeg}) end
        if bones.RightLeg then table.insert(conns, {bones.Torso, bones.RightLeg}) end
    end
    if bones.LeftLeg and bones.LeftLowerLeg then table.insert(conns, {bones.LeftLeg, bones.LeftLowerLeg}) end
    if bones.RightLeg and bones.RightLowerLeg then table.insert(conns, {bones.RightLeg, bones.RightLowerLeg}) end
    if bones.LeftLowerLeg and bones.LeftFoot then table.insert(conns, {bones.LeftLowerLeg, bones.LeftFoot})
    elseif bones.LeftLeg and bones.LeftFoot then table.insert(conns, {bones.LeftLeg, bones.LeftFoot}) end
    if bones.RightLowerLeg and bones.RightFoot then table.insert(conns, {bones.RightLowerLeg, bones.RightFoot})
    elseif bones.RightLeg and bones.RightFoot then table.insert(conns, {bones.RightLeg, bones.RightFoot}) end
    return conns
end

--// UPDATE //--
local function updateESP()
    if not Settings.Enabled then
        for _, drawings in pairs(espObjects) do
            drawings.Box.Visible = false
            drawings.Name.Visible = false
            drawings.HealthBar.Visible = false
            drawings.HealthBg.Visible = false
            drawings.Traceline.Visible = false
            for _, line in pairs(drawings.Skeleton) do
                line.Visible = false
            end
        end
        return
    end
    
    for player, drawings in pairs(espObjects) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if not character or not humanoid or not rootPart or humanoid.Health <= 0 then
            drawings.Box.Visible = false
            drawings.Name.Visible = false
            drawings.HealthBar.Visible = false
            drawings.HealthBg.Visible = false
            drawings.Traceline.Visible = false
            for _, line in pairs(drawings.Skeleton) do
                line.Visible = false
            end
            goto nextPlayer
        end
        
        local topY, bottomY = getPlayerTopAndBottom(character)
        if not topY or not bottomY then
            drawings.Box.Visible = false
            goto nextPlayer
        end
        
        local headPos = character.Head.Position
        local topWorld = Vector3.new(headPos.X, topY, headPos.Z)
        local bottomWorld = Vector3.new(headPos.X, bottomY, headPos.Z)
        local topScreen, topVis = Camera:WorldToViewportPoint(topWorld)
        local bottomScreen, bottomVis = Camera:WorldToViewportPoint(bottomWorld)
        
        if not topVis or not bottomVis then
            drawings.Box.Visible = false
            drawings.Name.Visible = false
            drawings.HealthBar.Visible = false
            drawings.HealthBg.Visible = false
            goto nextPlayer
        end
        
        local boxHeight = math.abs(topScreen.Y - bottomScreen.Y)
        local boxWidth = boxHeight * 0.55
        local boxX = bottomScreen.X - boxWidth / 2
        local boxY = topScreen.Y
        
        -- BOX
        if Settings.Box then
            drawings.Box.Visible = true
            drawings.Box.Position = Vector2.new(boxX, boxY)
            drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
        else
            drawings.Box.Visible = false
        end
        
        -- NAME
        if Settings.Name then
            drawings.Name.Visible = true
            drawings.Name.Text = player.Name
            drawings.Name.Position = Vector2.new(bottomScreen.X, topScreen.Y - 18)
        else
            drawings.Name.Visible = false
        end
        
        -- HEALTHBAR
        if Settings.HealthBar then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barX = (Settings.HealthBarPosition == "Right") and (boxX + boxWidth + 5) or (boxX - Settings.HealthBarWidth - 5)
            local barY = boxY + boxHeight - (boxHeight * healthPercent)
            
            drawings.HealthBg.Visible = true
            drawings.HealthBg.From = Vector2.new(barX, boxY)
            drawings.HealthBg.To = Vector2.new(barX + Settings.HealthBarWidth, boxY + boxHeight)
            
            drawings.HealthBar.Visible = true
            drawings.HealthBar.From = Vector2.new(barX, barY)
            drawings.HealthBar.To = Vector2.new(barX + Settings.HealthBarWidth, boxY + boxHeight)
            drawings.HealthBar.Color = getHealthColor(humanoid.Health, humanoid.MaxHealth)
        else
            drawings.HealthBar.Visible = false
            drawings.HealthBg.Visible = false
        end
        
        -- TRACELINE
        if Settings.Traceline then
            local localChar = LocalPlayer.Character
            local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
            if localRoot then
                local localScreen, localVis = Camera:WorldToViewportPoint(localRoot.Position)
                if localVis then
                    drawings.Traceline.Visible = true
                    drawings.Traceline.From = Vector2.new(localScreen.X, localScreen.Y)
                    drawings.Traceline.To = Vector2.new(bottomScreen.X, bottomScreen.Y)
                else
                    drawings.Traceline.Visible = false
                end
            else
                drawings.Traceline.Visible = false
            end
        else
            drawings.Traceline.Visible = false
        end
        
        -- SKELETON
        if Settings.Skeleton then
            local bones = getSkeletonBones(character)
            local connections = getSkeletonConnections(bones)
            
            while #drawings.Skeleton < #connections do
                local line = Drawing.new("Line")
                line.Color = Settings.SkeletonColor
                line.Thickness = Settings.SkeletonThickness
                line.Transparency = Settings.Transparency
                line.Visible = false
                table.insert(drawings.Skeleton, line)
            end
            
            for i = #drawings.Skeleton, #connections + 1, -1 do
                drawings.Skeleton[i]:Remove()
                table.remove(drawings.Skeleton, i)
            end
            
            for i, conn in ipairs(connections) do
                local screen1, vis1 = Camera:WorldToViewportPoint(conn[1])
                local screen2, vis2 = Camera:WorldToViewportPoint(conn[2])
                local line = drawings.Skeleton[i]
                if vis1 and vis2 then
                    line.Visible = true
                    line.From = Vector2.new(screen1.X, screen1.Y)
                    line.To = Vector2.new(screen2.X, screen2.Y)
                else
                    line.Visible = false
                end
            end
        else
            for _, line in pairs(drawings.Skeleton) do
                line.Visible = false
            end
        end
        
        ::nextPlayer::
    end
end

--// MODERNES GUI MENÜ //--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LionESP"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 450)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Blur-Effekt (optional)
local blur = Instance.new("BlurEffect")
blur.Size = 8
blur.Parent = mainFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
titleBar.BackgroundTransparency = 0.1
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "LION ESP v3.0"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.BackgroundTransparency = 0.3
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -45)
scrollFrame.Position = UDim2.new(0, 0, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
scrollFrame.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 10)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = scrollFrame

local function createSection(text)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, -20, 0, 30)
    section.Position = UDim2.new(0, 10, 0, 0)
    section.BackgroundTransparency = 1
    section.Text = text
    section.TextColor3 = Color3.fromRGB(150, 150, 200)
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.TextSize = 14
    section.Font = Enum.Font.GothamSemibold
    section.Parent = scrollFrame
    return section
end

local function createToggle(text, settingKey, defaultValue)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -20, 0, 40)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    toggleFrame.BackgroundTransparency = 0.3
    toggleFrame.Parent = scrollFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.Parent = toggleFrame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 25)
    toggleBtn.Position = UDim2.new(1, -50, 0.5, -12.5)
    toggleBtn.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 120)
    toggleBtn.Text = defaultValue and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 11
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = toggleFrame
    
    local toggleCornerBtn = Instance.new("UICorner")
    toggleCornerBtn.CornerRadius = UDim.new(0, 12)
    toggleCornerBtn.Parent = toggleBtn
    
    Settings[settingKey] = defaultValue
    
    toggleBtn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        toggleBtn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 120)
        toggleBtn.Text = Settings[settingKey] and "ON" or "OFF"
    end)
    
    return toggleBtn
end

local function createColorButton(text, settingKey, defaultColor)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(1, -20, 0, 40)
    colorFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    colorFrame.BackgroundTransparency = 0.3
    colorFrame.Parent = scrollFrame
    
    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 8)
    colorCorner.Parent = colorFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.Parent = colorFrame
    
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(0, 50, 0, 30)
    colorBtn.Position = UDim2.new(1, -60, 0.5, -15)
    colorBtn.BackgroundColor3 = defaultColor
    colorBtn.Text = ""
    colorBtn.Parent = colorFrame
    
    local colorCornerBtn = Instance.new("UICorner")
    colorCornerBtn.CornerRadius = UDim.new(0, 6)
    colorCornerBtn.Parent = colorBtn
    
    local colors = {
        {Name = "Weiß", Color = Color3.fromRGB(255,255,255)},
        {Name = "Rot", Color = Color3.fromRGB(255,0,0)},
        {Name = "Grün", Color = Color3.fromRGB(0,255,0)},
        {Name = "Blau", Color = Color3.fromRGB(0,0,255)},
        {Name = "Gelb", Color = Color3.fromRGB(255,255,0)},
        {Name = "Pink", Color = Color3.fromRGB(255,0,255)},
        {Name = "Cyan", Color = Color3.fromRGB(0,255,255)},
        {Name = "Orange", Color = Color3.fromRGB(255,128,0)}
    }
    
    colorBtn.MouseButton1Click:Connect(function()
        local colorMenu = Instance.new("Frame")
        colorMenu.Size = UDim2.new(0, 180, 0, 200)
        colorMenu.Position = UDim2.new(0.5, -90, 0.5, -100)
        colorMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        colorMenu.BackgroundTransparency = 0.1
        colorMenu.Parent = mainFrame
        
        local colorCornerMenu = Instance.new("UICorner")
        colorCornerMenu.CornerRadius = UDim.new(0, 10)
        colorCornerMenu.Parent = colorMenu
        
        local colorList = Instance.new("UIListLayout")
        colorList.Padding = UDim.new(0, 5)
        colorList.Parent = colorMenu
        
        for _, c in ipairs(colors) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -20, 0, 30)
            btn.Position = UDim2.new(0, 10, 0, 0)
            btn.BackgroundColor3 = c.Color
            btn.Text = c.Name
            btn.TextColor3 = Color3.fromRGB(0, 0, 0)
            btn.TextSize = 12
            btn.Font = Enum.Font.GothamBold
            btn.Parent = colorMenu
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                Settings[settingKey] = c.Color
                colorBtn.BackgroundColor3 = c.Color
                colorMenu:Destroy()
                
                -- Farben in ESP aktualisieren
                if settingKey == "BoxColor" then
                    for _, drawings in pairs(espObjects) do
                        drawings.Box.Color = c.Color
                    end
                elseif settingKey == "NameColor" then
                    for _, drawings in pairs(espObjects) do
                        drawings.Name.Color = c.Color
                    end
                elseif settingKey == "SkeletonColor" then
                    for _, drawings in pairs(espObjects) do
                        for _, line in pairs(drawings.Skeleton) do
                            line.Color = c.Color
                        end
                    end
                elseif settingKey == "TracelineColor" then
                    for _, drawings in pairs(espObjects) do
                        drawings.Traceline.Color = c.Color
                    end
                end
            end)
        end
        
        colorMenu.Changed:Connect(function()
            if colorMenu.Parent == nil then
                colorMenu:Destroy()
            end
        end)
    end)
end

-- GUI ELEMENTE ERSTELLEN
createSection("┌─▶ VISUELLE FEATURES")
createToggle("ESP aktivieren", "Enabled", true)
createToggle("Box ESP", "Box", true)
createToggle("Namensanzeige", "Name", true)
createToggle("Gesundheitsbalken", "HealthBar", true)
createToggle("Skeleton ESP", "Skeleton", true)
createToggle("Traceline", "Traceline", true)

createSection("┌─▶ FARBEN")
createColorButton("Box Farbe", "BoxColor", Color3.fromRGB(255, 255, 255))
createColorButton("Name Farbe", "NameColor", Color3.fromRGB(255, 255, 255))
createColorButton("Skeleton Farbe", "SkeletonColor", Color3.fromRGB(255, 255, 255))
createColorButton("Traceline Farbe", "TracelineColor", Color3.fromRGB(255, 0, 0))

createSection("┌─▶ INFO")
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 60)
infoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
infoLabel.BackgroundTransparency = 0.3
infoLabel.Text = "LION ESP v3.0\nDrücke [INSERT] zum Öffnen/Schließen\n100% Universal | R6/R15 Support"
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
infoLabel.TextSize = 11
infoLabel.TextWrapped = true
infoLabel.Font = Enum.Font.Gotham
infoLabel.Parent = scrollFrame

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoLabel

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    menuOpen = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        menuOpen = not menuOpen
        mainFrame.Visible = menuOpen
    end
end)

-- DRAGBAR FUNKTION
local dragging = false
local dragStartX, dragStartY, startPosX, startPosY

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartX = input.Position.X
        dragStartY = input.Position.Y
        startPosX = mainFrame.Position.X.Offset
        startPosY = mainFrame.Position.Y.Offset
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local deltaX = input.Position.X - dragStartX
        local deltaY = input.Position.Y - dragStartY
        mainFrame.Position = UDim2.new(0, startPosX + deltaX, 0, startPosY + deltaY)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--// EVENT HANDLER //--
Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(removePlayer)

for _, player in ipairs(Players:GetPlayers()) do
    addPlayer(player)
end

RunService.RenderStepped:Connect(updateESP)

print("✅ LION ESP ULTIMATE geladen - Drücke [INSERT] für Menü")
