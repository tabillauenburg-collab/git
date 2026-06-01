--// Lion ESP (Box, Name, Skeleton, Line) für Roblox Executor
--// Ausführen mit einem Lua Executor (z.B. Krnl, Fluxus, Delta)

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
    Transparency = 1,  -- 1 = komplett sichtbar, 0 = unsichtbar (vom Executor abhängig)
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
    -- Box (Rechteck)
    local box = Drawing.new("Square")
    box.Color = SETTINGS.BoxColor
    box.Transparency = SETTINGS.Transparency
    box.Thickness = SETTINGS.BoxThickness
    box.Filled = false
    box.Visible = false
    drawings.Box = box

    -- Name
    local nameTag = Drawing.new("Text")
    nameTag.Color = SETTINGS.NameColor
    nameTag.Transparency = SETTINGS.Transparency
    nameTag.Size = SETTINGS.NameSize
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Visible = false
    drawings.NameTag = nameTag

    -- Skeleton Lines: Speichert eine Tabelle von Line-Objekten
    drawings.SkeletonLines = {}

    -- Line vom LocalPlayer zum Ziel
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
        -- Box entfernen
        if drawings.Box then drawings.Box:Remove() end
        -- NameTag entfernen
        if drawings.NameTag then drawings.NameTag:Remove() end
        -- Skeleton Lines entfernen
        if drawings.SkeletonLines then
            for _, line in pairs(drawings.SkeletonLines) do
                line:Remove()
            end
        end
        -- Line entfernen
        if drawings.TargetLine then drawings.TargetLine:Remove() end
        playerESP[player] = nil
    end
end

local function getBonePositions(character)
    -- Gibt die Positionen der wichtigsten Bones als Table zurück
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

        -- Sichtbarkeit zurücksetzen, falls kein gültiger Charakter
        if not character or not humanoid or not rootPart or not head then
            drawings.Box.Visible = false
            drawings.NameTag.Visible = false
            drawings.TargetLine.Visible = false
            for _, line in pairs(drawings.SkeletonLines) do
                line.Visible = false
            end
            continue
        end

        -- Positionen für Box und Name
        local rootPos = rootPart.Position
        local headPos = head.Position
        local height = headPos.Y - rootPos.Y  -- Näherungsweise Höhe
        local topWorld = Vector3.new(rootPos.X, rootPos.Y + height, rootPos.Z)
        local bottomWorld = Vector3.new(rootPos.X, rootPos.Y, rootPos.Z)

        local topScreen, onScreenTop = Camera:WorldToViewportPoint(topWorld)
        local bottomScreen, onScreenBot = Camera:WorldToViewportPoint(bottomWorld)

        if not onScreenTop or not onScreenBot then
            drawings.Box.Visible = false
            drawings.NameTag.Visible = false
        else
            -- Box zeichnen
            local boxHeight = math.abs(topScreen.Y - bottomScreen.Y)
            local boxWidth = boxHeight * 0.45  -- typisches Verhältnis Spielermodell
            local boxX = bottomScreen.X - boxWidth / 2
            local boxY = topScreen.Y

            drawings.Box.Visible = true
            drawings.Box.Position = Vector2.new(boxX, boxY)
            drawings.Box.Size = Vector2.new(boxWidth, boxHeight)

            -- NameTag über dem Kopf
            drawings.NameTag.Visible = true
            drawings.NameTag.Text = player.Name
            drawings.NameTag.Position = Vector2.new(bottomScreen.X, topScreen.Y - 20)  -- etwas über der Box
        end

        -- Line zum LocalPlayer
        if player ~= LocalPlayer then
            local localChar = LocalPlayer.Character
            local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
            if localRoot then
                local localPos = localRoot.Position
                local localScreen, localOn = Camera:WorldToViewportPoint(localPos)
                local targetScreen, targetOn = Camera:WorldToViewportPoint(rootPos)
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

        -- Skeleton (Knochenlinien)
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

        -- Prüfen, ob genügend Linien existieren; sonst neue erstellen
        while #drawings.SkeletonLines < #boneConnections do
            local line = Drawing.new("Line")
            line.Color = SETTINGS.SkeletonColor
            line.Transparency = SETTINGS.Transparency
            line.Thickness = SETTINGS.SkeletonThickness
            line.Visible = false
            table.insert(drawings.SkeletonLines, line)
        end
        -- Überflüssige Linien entfernen (sollte nie passieren)
        while #drawings.SkeletonLines > #boneConnections do
            local line = table.remove(drawings.SkeletonLines)
            line:Remove()
        end

        -- Jede Linie aktualisieren
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
    end
end

-- Neue Spieler hinzufügen
Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

-- Spieler, die das Spiel verlassen, aufräumen
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Alle bereits vorhandenen Spieler initialisieren
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

-- Sogar den eigenen Charakter anzeigen? Kommentar entfernen, falls du dich selbst auch sehen willst:
-- createESP(LocalPlayer)

-- Haupt-Update-Schleife
RunService.RenderStepped:Connect(function()
    updateESP()
end)
