--// LION ESP ULTIMATE - R6/R15 KOMPATIBEL //--
--// Box, Name, Healthbar, Skeleton, Traceline

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// EINSTELLUNGEN //--
local SETTINGS = {
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 1,
    Transparency = 1,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameSize = 14,
    HealthBarWidth = 40,
    HealthBarHeight = 4,
    HealthBarPosition = "Right", -- "Left" oder "Right"
    LowHealthColor = Color3.fromRGB(255, 0, 0),
    MidHealthColor = Color3.fromRGB(255, 255, 0),
    HighHealthColor = Color3.fromRGB(0, 255, 0),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    SkeletonThickness = 1,
    LineColor = Color3.fromRGB(255, 0, 0),
    LineThickness = 1
}

--// SPEICHER //--
local espObjects = {}

--// HILFSFUNKTION: Höhe des Spielers (Kopf bis Fuß) für JEDES Modell //--
local function getPlayerTopAndBottom(character)
    local head = character:FindFirstChild("Head")
    if not head then return nil, nil end
    
    local highestY = head.Position.Y + (head.Size.Y / 2)
    local lowestY = head.Position.Y - (head.Size.Y / 2)
    
    -- Alle Teile durchgehen für maximale Genauigkeit
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

--// FARBE JE HEALTH //--
local function getHealthColor(health, maxHealth)
    local percent = health / maxHealth
    if percent <= 0.3 then
        return SETTINGS.LowHealthColor
    elseif percent <= 0.7 then
        local t = (percent - 0.3) / 0.4
        return SETTINGS.LowHealthColor:Lerp(SETTINGS.MidHealthColor, t)
    else
        local t = (percent - 0.7) / 0.3
        return SETTINGS.MidHealthColor:Lerp(SETTINGS.HighHealthColor, t)
    end
end

--// NEUER SPIELER //--
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
    
    drawings.Box.Color = SETTINGS.BoxColor
    drawings.Box.Thickness = SETTINGS.BoxThickness
    drawings.Box.Filled = false
    drawings.Box.Transparency = SETTINGS.Transparency
    drawings.Box.Visible = false
    
    drawings.Name.Color = SETTINGS.NameColor
    drawings.Name.Size = SETTINGS.NameSize
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Transparency = SETTINGS.Transparency
    drawings.Name.Visible = false
    
    drawings.HealthBar.Color = SETTINGS.HighHealthColor
    drawings.HealthBar.Thickness = SETTINGS.HealthBarHeight
    drawings.HealthBar.Transparency = SETTINGS.Transparency
    drawings.HealthBar.Visible = false
    
    drawings.HealthBg.Color = Color3.fromRGB(50, 50, 50)
    drawings.HealthBg.Thickness = SETTINGS.HealthBarHeight
    drawings.HealthBg.Transparency = SETTINGS.Transparency
    drawings.HealthBg.Visible = false
    
    drawings.Traceline.Color = SETTINGS.LineColor
    drawings.Traceline.Thickness = SETTINGS.LineThickness
    drawings.Traceline.Transparency = SETTINGS.Transparency
    drawings.Traceline.Visible = false
    
    espObjects[player] = drawings
end

--// SPIELER ENTFERNEN //--
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

--// SKELETON KONFIGURATION (R6 + R15 KOMPATIBEL) //--
local function getSkeletonBones(character)
    local bones = {}
    
    -- Kopf
    local head = character:FindFirstChild("Head")
    if head then bones.Head = head.Position end
    
    -- Rumpf (R15: UpperTorso, R6: Torso)
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if torso then bones.Torso = torso.Position end
    
    -- Unterer Rumpf (nur R15)
    local lowerTorso = character:FindFirstChild("LowerTorso")
    if lowerTorso then bones.LowerTorso = lowerTorso.Position end
    
    -- Arme (R15: LeftUpperArm, RightUpperArm | R6: Left Arm, Right Arm)
    local leftArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")
    local rightArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
    if leftArm then bones.LeftArm = leftArm.Position end
    if rightArm then bones.RightArm = rightArm.Position end
    
    -- Unterarme (nur R15)
    local leftForearm = character:FindFirstChild("LeftLowerArm")
    local rightForearm = character:FindFirstChild("RightLowerArm")
    if leftForearm then bones.LeftForearm = leftForearm.Position end
    if rightForearm then bones.RightForearm = rightForearm.Position end
    
    -- Hände
    local leftHand = character:FindFirstChild("LeftHand")
    local rightHand = character:FindFirstChild("RightHand")
    if leftHand then bones.LeftHand = leftHand.Position end
    if rightHand then bones.RightHand = rightHand.Position end
    
    -- Beine (R15: LeftUpperLeg, RightUpperLeg | R6: Left Leg, Right Leg)
    local leftLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg")
    local rightLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg")
    if leftLeg then bones.LeftLeg = leftLeg.Position end
    if rightLeg then bones.RightLeg = rightLeg.Position end
    
    -- Unterschenkel (nur R15)
    local leftLowerLeg = character:FindFirstChild("LeftLowerLeg")
    local rightLowerLeg = character:FindFirstChild("RightLowerLeg")
    if leftLowerLeg then bones.LeftLowerLeg = leftLowerLeg.Position end
    if rightLowerLeg then bones.RightLowerLeg = rightLowerLeg.Position end
    
    -- Füße
    local leftFoot = character:FindFirstChild("LeftFoot")
    local rightFoot = character:FindFirstChild("RightFoot")
    if leftFoot then bones.LeftFoot = leftFoot.Position end
    if rightFoot then bones.RightFoot = rightFoot.Position end
    
    return bones
end

local function getSkeletonConnections(bones)
    local conns = {}
    
    -- Kopf <-> Rumpf
    if bones.Head and bones.Torso then table.insert(conns, {bones.Head, bones.Torso}) end
    
    -- Rumpf <-> Arme
    if bones.Torso and bones.LeftArm then table.insert(conns, {bones.Torso, bones.LeftArm}) end
    if bones.Torso and bones.RightArm then table.insert(conns, {bones.Torso, bones.RightArm}) end
    
    -- Arme <-> Unterarme (R15)
    if bones.LeftArm and bones.LeftForearm then table.insert(conns, {bones.LeftArm, bones.LeftForearm}) end
    if bones.RightArm and bones.RightForearm then table.insert(conns, {bones.RightArm, bones.RightForearm}) end
    
    -- Unterarme <-> Hände (R15)
    if bones.LeftForearm and bones.LeftHand then table.insert(conns, {bones.LeftForearm, bones.LeftHand}) end
    if bones.RightForearm and bones.RightHand then table.insert(conns, {bones.RightForearm, bones.RightHand}) end
    
    -- Rumpf <-> unterer Rumpf (R15)
    if bones.Torso and bones.LowerTorso then table.insert(conns, {bones.Torso, bones.LowerTorso}) end
    
    -- unterer Rumpf <-> Beine (R15) oder Rumpf <-> Beine (R6)
    if bones.LowerTorso then
        if bones.LeftLeg then table.insert(conns, {bones.LowerTorso, bones.LeftLeg}) end
        if bones.RightLeg then table.insert(conns, {bones.LowerTorso, bones.RightLeg}) end
    elseif bones.Torso then
        if bones.LeftLeg then table.insert(conns, {bones.Torso, bones.LeftLeg}) end
        if bones.RightLeg then table.insert(conns, {bones.Torso, bones.RightLeg}) end
    end
    
    -- Beine <-> Unterschenkel (R15)
    if bones.LeftLeg and bones.LeftLowerLeg then table.insert(conns, {bones.LeftLeg, bones.LeftLowerLeg}) end
    if bones.RightLeg and bones.RightLowerLeg then table.insert(conns, {bones.RightLeg, bones.RightLowerLeg}) end
    
    -- Unterschenkel <-> Füße (R15) oder Beine <-> Füße (R6)
    if bones.LeftLowerLeg and bones.LeftFoot then
        table.insert(conns, {bones.LeftLowerLeg, bones.LeftFoot})
    elseif bones.LeftLeg and bones.LeftFoot then
        table.insert(conns, {bones.LeftLeg, bones.LeftFoot})
    end
    
    if bones.RightLowerLeg and bones.RightFoot then
        table.insert(conns, {bones.RightLowerLeg, bones.RightFoot})
    elseif bones.RightLeg and bones.RightFoot then
        table.insert(conns, {bones.RightLeg, bones.RightFoot})
    end
    
    return conns
end

--// MAIN UPDATE //--
local function updateESP()
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
        
        -- TOP & BOTTOM für Box (WELT -> BILDSCHIRM)
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
        
        -- BOX
        local boxHeight = math.abs(topScreen.Y - bottomScreen.Y)
        local boxWidth = boxHeight * 0.55
        local boxX = bottomScreen.X - boxWidth / 2
        local boxY = topScreen.Y
        
        drawings.Box.Visible = true
        drawings.Box.Position = Vector2.new(boxX, boxY)
        drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
        
        -- NAME (über der Box)
        drawings.Name.Visible = true
        drawings.Name.Text = player.Name
        drawings.Name.Position = Vector2.new(bottomScreen.X, topScreen.Y - 18)
        
        -- HEALTHBAR (links oder rechts neben der Box)
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local barX = (SETTINGS.HealthBarPosition == "Right") and (boxX + boxWidth + 5) or (boxX - SETTINGS.HealthBarWidth - 5)
        local barY = boxY + boxHeight - (boxHeight * healthPercent)
        
        drawings.HealthBg.Visible = true
        drawings.HealthBg.From = Vector2.new(barX, boxY)
        drawings.HealthBg.To = Vector2.new(barX + SETTINGS.HealthBarWidth, boxY + boxHeight)
        
        drawings.HealthBar.Visible = true
        drawings.HealthBar.From = Vector2.new(barX, barY)
        drawings.HealthBar.To = Vector2.new(barX + SETTINGS.HealthBarWidth, boxY + boxHeight)
        drawings.HealthBar.Color = getHealthColor(humanoid.Health, humanoid.MaxHealth)
        
        -- TRACELINE (vom eigenen Charakter)
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
        
        -- SKELETON (dynamische Linienverwaltung)
        local bones = getSkeletonBones(character)
        local connections = getSkeletonConnections(bones)
        
        while #drawings.Skeleton < #connections do
            local line = Drawing.new("Line")
            line.Color = SETTINGS.SkeletonColor
            line.Thickness = SETTINGS.SkeletonThickness
            line.Transparency = SETTINGS.Transparency
            line.Visible = false
            table.insert(drawings.Skeleton, line)
        end
        
        for i = #drawings.Skeleton, #connections + 1, -1 do
            drawings.Skeleton[i]:Remove()
            table.remove(drawings.Skeleton, i)
        end
        
        for i, conn in ipairs(connections) do
            local pos1, pos2 = conn[1], conn[2]
            local screen1, vis1 = Camera:WorldToViewportPoint(pos1)
            local screen2, vis2 = Camera:WorldToViewportPoint(pos2)
            local line = drawings.Skeleton[i]
            
            if vis1 and vis2 then
                line.Visible = true
                line.From = Vector2.new(screen1.X, screen1.Y)
                line.To = Vector2.new(screen2.X, screen2.Y)
            else
                line.Visible = false
            end
        end
        
        ::nextPlayer::
    end
end

--// EVENT HANDLER //--
Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(removePlayer)

for _, player in ipairs(Players:GetPlayers()) do
    addPlayer(player)
end

RunService.RenderStepped:Connect(updateESP)

print("✅ LION ESP ULTIMATE geladen - R6/R15 kompatibel")
