local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

print("[DEBUG] ========================================")
print("[DEBUG] Skript gestartet!")
print("[DEBUG] Spieler:", player.Name)
print("[DEBUG] Charakter:", character and character.Name or "Nicht gefunden")
print("[DEBUG] HRP:", hrp and "Gefunden" or "Nicht gefunden")
print("[DEBUG] ========================================")

-- Alle Stages finden
local stages = {}
local structure = Workspace:FindFirstChild("Structure")

print("[DEBUG] Suche nach 'Structure' in Workspace...")
if structure then
    print("[DEBUG] 'Structure' gefunden!")
    print("[DEBUG] Durchsuche Stages...")
    
    for i = 1, 30 do
        local stageName = "Stage" .. i
        print("[DEBUG] Prüfe:", stageName)
        local stage = structure:FindFirstChild(stageName)
        if stage then
            print("[DEBUG] ✅", stageName, "gefunden!")
            table.insert(stages, stage)
        else
            print("[DEBUG] ❌", stageName, "nicht gefunden, breche ab")
            break
        end
    end
else
    print("[DEBUG] ❌ 'Structure' NICHT gefunden in Workspace!")
    print("[DEBUG] Suche stattdessen direkt nach Stages...")
    
    -- Fallback: Direkt nach Stages suchen
    for i = 1, 30 do
        local stageName = "Stage" .. i
        local stage = Workspace:FindFirstChild(stageName)
        if stage then
            print("[DEBUG] ✅", stageName, "gefunden in Workspace!")
            table.insert(stages, stage)
        else
            break
        end
    end
end

print("[DEBUG] ========================================")
print("[DEBUG] Insgesamt gefundene Stages:", #stages)
for i, stage in ipairs(stages) do
    print("[DEBUG]   " .. i .. ".", stage.Name)
end
print("[DEBUG] ========================================")

if #stages == 0 then
    print("[DEBUG] ❌ Keine Stages gefunden! Skript wird beendet.")
    return
end

-- Funktion zum Teleportieren
local function teleportTo(part, partName)
    print("[DEBUG]   Teleportiere zu:", partName or (part and part.Name or "UNBEKANNT"))
    
    if not part then
        print("[DEBUG]   ❌ Teil ist nil!")
        return false
    end
    
    if not hrp then
        print("[DEBUG]   ❌ HRP ist nil!")
        return false
    end
    
    print("[DEBUG]   Teil-Typ:", typeof(part))
    print("[DEBUG]   Ist Model?", part:IsA("Model"))
    print("[DEBUG]   Ist BasePart?", part:IsA("BasePart"))
    
    local success, err = pcall(function()
        if part:IsA("Model") then
            local pivot = part:GetPivot()
            print("[DEBUG]   Pivot:", pivot)
            hrp.CFrame = pivot + Vector3.new(0, 5, 0)
        elseif part:IsA("BasePart") then
            print("[DEBUG]   CFrame:", part.CFrame)
            hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
        else
            print("[DEBUG]   ❌ Teil ist weder Model noch BasePart!")
            return false
        end
    end)
    
    if success then
        print("[DEBUG]   ✅ Teleport erfolgreich!")
        return true
    else
        print("[DEBUG]   ❌ Teleport fehlgeschlagen:", err)
        return false
    end
end

-- Durch alle Stages gehen
for stageIndex, stage in ipairs(stages) do
    print("[DEBUG] ========================================")
    print("[DEBUG] ===== STAGE", stageIndex .. "/" .. #stages, ":", stage.Name, "=====")
    print("[DEBUG] ========================================")
    print("[DEBUG] Stage-Pfad:", stage:GetFullName())
    print("[DEBUG] Children in Stage:", #stage:GetChildren())
    
    -- Alle Children auflisten
    print("[DEBUG] Alle Kinder von", stage.Name .. ":")
    for _, child in ipairs(stage:GetChildren()) do
        print("[DEBUG]   -", child.Name, "(" .. child.ClassName .. ")")
    end
    
    -- 1. Zur Treadmill teleportieren
    print("[DEBUG] Suche nach 'Treadmill' in", stage.Name, "...")
    local treadmill = stage:FindFirstChild("Treadmill")
    
    if treadmill then
        print("[DEBUG] ✅ 'Treadmill' gefunden!")
        print("[DEBUG] Treadmill-Typ:", typeof(treadmill))
        print("[DEBUG] Treadmill-Pfad:", treadmill:GetFullName())
        
        print("[DEBUG] --- Teleportiere zur Treadmill ---")
        local success = teleportTo(treadmill, "Treadmill")
        
        if success then
            print("[DEBUG] ✅ Erfolgreich zur Treadmill teleportiert!")
        else
            print("[DEBUG] ❌ Teleport zur Treadmill fehlgeschlagen!")
        end
        
        -- WICHTIG: Warten bis WinBlocks laden/erscheinen
        print("[DEBUG] Warte 3 Sekunden bis WinBlocks laden...")
        print("[DEBUG] Countdown: 3...")
        task.wait(1)
        print("[DEBUG] Countdown: 2...")
        task.wait(1)
        print("[DEBUG] Countdown: 1...")
        task.wait(1)
        print("[DEBUG] ✅ Wartezeit abgeschlossen!")
        
        -- 2. Jetzt nach WinBlocks suchen (sie sollten jetzt sichtbar sein)
        print("[DEBUG] Suche nach WinBlocks in", stage.Name, "...")
        local winBlocks = {}
        
        -- Alle Children nochmal durchgehen
        print("[DEBUG] Durchsuche alle Kinder von", stage.Name, "nach WinBlocks...")
        for _, child in ipairs(stage:GetChildren()) do
            print("[DEBUG]   Prüfe:", child.Name)
            if string.match(child.Name, "^WinBlock%d+$") then
                print("[DEBUG]   ✅ WinBlock gefunden:", child.Name)
                table.insert(winBlocks, child)
            else
                print("[DEBUG]   ❌ Kein WinBlock:", child.Name)
            end
        end
        
        print("[DEBUG] Gefundene WinBlocks (unsortiert):", #winBlocks)
        for i, block in ipairs(winBlocks) do
            print("[DEBUG]   " .. i .. ".", block.Name)
        end
        
        -- WinBlocks sortieren
        print("[DEBUG] Sortiere WinBlocks nach Nummer...")
        table.sort(winBlocks, function(a, b)
            local numA = tonumber(string.match(a.Name, "%d+")) or 0
            local numB = tonumber(string.match(b.Name, "%d+")) or 0
            print("[DEBUG]   Vergleiche:", a.Name, "("..numA..")", "vs", b.Name, "("..numB..")")
            return numA < numB
        end)
        
        print("[DEBUG] Gefundene WinBlocks (sortiert):", #winBlocks)
        for i, block in ipairs(winBlocks) do
            print("[DEBUG]   " .. i .. ".", block.Name)
        end
        
        -- 3. Zu jedem WinBlock teleportieren
        if #winBlocks > 0 then
            print("[DEBUG] --- Beginne mit WinBlocks ---")
            for blockIndex, block in ipairs(winBlocks) do
                print("[DEBUG]   ===== WinBlock", blockIndex .. "/" .. #winBlocks, ":", block.Name, "=====")
                print("[DEBUG]   Block-Typ:", typeof(block))
                print("[DEBUG]   Block-Pfad:", block:GetFullName())
                
                print("[DEBUG]   --- Teleportiere zu", block.Name, "---")
                local success = teleportTo(block, block.Name)
                
                if success then
                    print("[DEBUG]   ✅ Erfolgreich zu", block.Name, "teleportiert!")
                else
                    print("[DEBUG]   ❌ Teleport zu", block.Name, "fehlgeschlagen!")
                end
                
                print("[DEBUG]   Warte 0.5 Sekunden...")
                task.wait(0.5)
                print("[DEBUG]   ✅ Fertig mit", block.Name)
            end
            print("[DEBUG] --- Alle WinBlocks abgeschlossen ---")
        else
            print("[DEBUG] ⚠️ KEINE WinBlocks gefunden in", stage.Name)
            print("[DEBUG] Versuche erneut zu warten und zu suchen...")
            
            -- Falls keine WinBlocks gefunden, nochmal warten und suchen
            print("[DEBUG] Warte weitere 3 Sekunden...")
            task.wait(3)
            print("[DEBUG] ✅ Zweite Wartezeit abgeschlossen!")
            
            print("[DEBUG] Zweite Suche nach WinBlocks...")
            for _, child in ipairs(stage:GetChildren()) do
                if string.match(child.Name, "^WinBlock%d+$") then
                    print("[DEBUG] ✅ WinBlock gefunden (2. Versuch):", child.Name)
                    table.insert(winBlocks, child)
                end
            end
            
            if #winBlocks > 0 then
                print("[DEBUG] ✅ Jetzt gefunden!", #winBlocks, "WinBlocks")
                for _, block in ipairs(winBlocks) do
                    print("[DEBUG] Teleportiere zu", block.Name)
                    teleportTo(block, block.Name)
                    task.wait(0.5)
                end
            else
                print("[DEBUG] ❌ Auch beim 2. Versuch keine WinBlocks gefunden!")
                print("[DEBUG] Mögliche Gründe:")
                print("[DEBUG]   - WinBlocks sind nicht in dieser Stage")
                print("[DEBUG]   - WinBlocks werden anders benannt (z.B. 'WinBlock_1')")
                print("[DEBUG]   - WinBlocks werden erst später aktiviert")
                
                -- Zeige alle Kinder nochmal
                print("[DEBUG] Alle Kinder von", stage.Name, "(erneut):")
                for _, child in ipairs(stage:GetChildren()) do
                    print("[DEBUG]   -", child.Name, "(" .. child.ClassName .. ")")
                end
            end
        end
    else
        print("[DEBUG] ❌ 'Treadmill' NICHT gefunden in", stage.Name)
        print("[DEBUG] Suche nach alternativen Namen...")
        
        -- Nach alternativen Namen suchen
        local possibleNames = {"Treadmill", "treadmill", "TreadMill", "Laufband"}
        for _, name in ipairs(possibleNames) do
            local found = stage:FindFirstChild(name)
            if found then
                print("[DEBUG] ✅ Gefunden unter:", name)
                treadmill = found
                break
            end
        end
        
        if not treadmill then
            print("[DEBUG] ❌ Keine Treadmill in", stage.Name, "gefunden!")
            print("[DEBUG] Überspringe diese Stage...")
        end
    end
    
    print("[DEBUG] Warte 1 Sekunde zwischen Stages...")
    task.wait(1)
    print("[DEBUG] ✅ Fertig mit", stage.Name)
end

print("[DEBUG] ========================================")
print("[DEBUG] ===== ALLE STAGES DURCHLAUFEN! =====")
print("[DEBUG] ========================================")
print("[DEBUG] Anzahl verarbeiteter Stages:", #stages)
print("[DEBUG] Skript erfolgreich beendet!")
print("[DEBUG] ========================================")
