--// Lion ESP (Box, Name, Skeleton, Line) für Roblox Executor
--// FIXED: Box-Höhe jetzt korrekt (Kopf bis Füße)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Einstellungen (optional anpassbar)
local SETTINGS = {
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    LineColor = Color3.fromRGB(255, 0, 0),
    Transparency = 1,
    Thickness = 1,
    NameSize = 13,
    BoxThickness = 1,
    SkeletonThickness = 1,
    LineThickness = 1
}

-- Container für alle Zeichnungen pro Spieler
local playerESP = {}

local function createESP(player)
    local drawings = {}
    local box = Drawing.new("Square")
    box.Color = SETTINGS.BoxColor
    box.Transparency = SETTINGS.Transparency
    box.Thickness = SETTINGS.BoxThickness
    box.Filled = false
    box.Visible = false
    drawings.Box = box

    local nameTag = Drawing.new("Text")
    nameTag.Color = SETTINGS.NameColor
    nameTag.Transparency = SETTINGS.Transparency
    nameTag.Size = SETTINGS.NameSize
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Visible = false
    drawings.NameTag = nameTag

    drawings.SkeletonLines = {}

    local targetLine = Drawing.new("Line")
    targetLine.Color = SETTINGS.LineColor
    targetLine.Transparency = SETTINGS.Transparency
    targetLine.Thickness = SETTINGS.LineThickness
    targetLine.Visible = false
    drawings.TargetLine = targetLine

    playerESP[player] = drawings
end

local function removeESP(player)
    local drawings = playerESP[player]
    if drawings then
        if drawings.Box then drawings.Box:Remove() end
        if drawings.NameTag then drawings.NameTag:Remove() end
        if drawings.SkeletonLines then
            for _, line in pairs(drawings.SkeletonLines) do
                line:Remove()
            end
        end
        if drawings.TargetLine then drawings.TargetLine:Remove() end
        playerESP[player] = nil
    end
end

-- 🟢 NEU: Ermittelt die tatsächliche Höhe des Spielers (Kopf bis tiefster Fuß)
local function getPlayerHeight(character)
    local head = character:FindFirstChild("Head")
    if not head then return nil end
    
    local highestY = head.Position.Y
    local lowestY = head.Position.Y  -- Startwert
    
    -- Alle Teile des Charakters durchsuchen
    local parts = character:GetDescendants()
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") then
            local partMinY = part.Position.Y - (part.Size.Y / 2)
            local partMaxY = part.Position.Y + (part.Size.Y / 2)
            if partMaxY > highestY then highestY = partMaxY end
            if partMinY < lowestY then lowestY = partMinY end
        end
    end
    
    return highestY - lowestY, highestY, lowestY
end

local function getBonePositions(character)
    local head = character:FindFirstChild("Head")
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local lowerTorso = character:FindFirstChild("LowerTorso")
    local leftShoulder = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")
    local leftElbow = character:FindFirstChild("LeftLowerArm")
    local leftHand = character:FindFirstChild("LeftHand")
    local rightShoulder = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
    local rightElbow = character:FindFirstChild("RightLowerArm")
    local rightHand = character:FindFirstChild("RightHand")
    local leftHip = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg")
    local leftKnee = character:FindFirstChild("LeftLowerLeg")
    local leftFoot = character:FindFirstChild("LeftFoot")
    local rightHip = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg")
    local rightKnee = character:FindFirstChild("RightLowerLeg")
    local rightFoot = character:FindFirstChild("RightFoot")

    return {
        Head = head and head.Position,
        Torso = torso and torso.Position,
        LowerTorso = lowerTorso and lowerTorso.Position,
        LeftShoulder = leftShoulder and leftShoulder.Position,
        LeftElbow = leftElbow and leftElbow.Position,
        LeftHand = leftHand and leftHand.Position,
        RightShoulder = rightShoulder and rightShoulder.Position,
        RightElbow = rightElbow and rightElbow.Position,
        RightHand = rightHand and rightHand.Position,
        LeftHip = leftHip and leftHip.Position,
        LeftKnee = leftKnee and leftKnee.Position,
        LeftFoot = leftFoot and leftFoot.Position,
        RightHip = rightHip and rightHip.Position,
        RightKnee = rightKnee and rightKnee.Position,
        RightFoot = rightFoot and rightFoot.Position
    }
end

local function updateESP()
    for player, drawings in pairs(playerESP) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")

        if not character or not humanoid or not rootPart or not head then
            drawings.Box.Visible = false
            drawings.NameTag.Visible = false
            drawings.TargetLine.Visible = false
            for _, line in pairs(drawings.SkeletonLines) do
                line.Visible = false
            end
            goto continue
        end

        -- 🟢 NEUE Box-Berechnung mit korrekter Höhe
        local height, topY, bottomY = getPlayerHeight(character)
        if height and topY and bottomY then
            -- Höhe auf Bildschirm projizieren
            local topWorld = Vector3.new(rootPart.Position.X, topY, rootPart.Position.Z)
            local bottomWorld = Vector3.new(rootPart.Position.X, bottomY, rootPart.Position.Z)
            
            local topScreen, onScreenTop = Camera:WorldToViewportPoint(topWorld)
            local bottomScreen, onScreenBot = Camera:WorldToViewportPoint(bottomWorld)
            
            if onScreenTop and onScreenBot then
                local boxHeight = math.abs(topScreen.Y - bottomScreen.Y)
                local boxWidth = boxHeight * 0.55  -- etwas breiter für realistischere Box
                local boxX = bottomScreen.X - boxWidth / 2
                local boxY = topScreen.Y
                
                drawings.Box.Visible = true
                drawings.Box.Position = Vector2.new(boxX, boxY)
                drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
                
                -- Namenslabel über dem Kopf
                drawings.NameTag.Visible = true
                drawings.NameTag.Text = player.Name
                drawings.NameTag.Position = Vector2.new(bottomScreen.X, topScreen.Y - 20)
            else
                drawings.Box.Visible = false
                drawings.NameTag.Visible = false
            end
        else
            drawings.Box.Visible = false
            drawings.NameTag.Visible = false
        end

        -- Line zum LocalPlayer (bleibt gleich)
        if player ~= LocalPlayer then
            local localChar = LocalPlayer.Character
            local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
            if localRoot then
                local localPos = localRoot.Position
                local localScreen, localOn = Camera:WorldToViewportPoint(localPos)
                local targetScreen, targetOn = Camera:WorldToViewportPoint(rootPart.Position)
                if localOn and targetOn then
                    drawings.TargetLine.Visible = true
                    drawings.TargetLine.From = Vector2.new(localScreen.X, localScreen.Y)
                    drawings.TargetLine.To = Vector2.new(targetScreen.X, targetScreen.Y)
                else
                    drawings.TargetLine.Visible = false
                end
            else
                drawings.TargetLine.Visible = false
            end
        else
            drawings.TargetLine.Visible = false
        end

        -- Skeleton (gleich wie bisher)
        local bones = getBonePositions(character)
        local boneConnections = {
            {"Head", "Torso"},
            {"Torso", "LeftShoulder"},
            {"LeftShoulder", "LeftElbow"},
            {"LeftElbow", "LeftHand"},
            {"Torso", "RightShoulder"},
            {"RightShoulder", "RightElbow"},
            {"RightElbow", "RightHand"},
            {"Torso", "LowerTorso"},
            {"LowerTorso", "LeftHip"},
            {"LeftHip", "LeftKnee"},
            {"LeftKnee", "LeftFoot"},
            {"LowerTorso", "RightHip"},
            {"RightHip", "RightKnee"},
            {"RightKnee", "RightFoot"}
        }

        while #drawings.SkeletonLines < #boneConnections do
            local line = Drawing.new("Line")
            line.Color = SETTINGS.SkeletonColor
            line.Transparency = SETTINGS.Transparency
            line.Thickness = SETTINGS.SkeletonThickness
            line.Visible = false
            table.insert(drawings.SkeletonLines, line)
        end
        while #drawings.SkeletonLines > #boneConnections do
            local line = table.remove(drawings.SkeletonLines)
            line:Remove()
        end

        for i, connection in ipairs(boneConnections) do
            local bone1, bone2 = connection[1], connection[2]
            local pos1 = bones[bone1]
            local pos2 = bones[bone2]
            local line = drawings.SkeletonLines[i]
            if pos1 and pos2 then
                local screen1, on1 = Camera:WorldToViewportPoint(pos1)
                local screen2, on2 = Camera:WorldToViewportPoint(pos2)
                if on1 and on2 then
                    line.Visible = true
                    line.From = Vector2.new(screen1.X, screen1.Y)
                    line.To = Vector2.new(screen2.X, screen2.Y)
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
        
        ::continue::
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

RunService.RenderStepped:Connect(function()
    updateESP()
end)
