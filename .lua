local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local stage = workspace.Structure.Stage15

-- Erst zur Treadmill
hrp.CFrame = stage.Treadmill.CFrame + Vector3.new(0, 3, 0)

-- Warten, bis der Block geladen/erstellt wurde
local win = stage:WaitForChild("WinBlock14", 10)

if win then
    hrp.CFrame = win.CFrame + Vector3.new(0, 3, 0)
end
