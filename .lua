local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local stage = workspace:WaitForChild("Structure"):WaitForChild("Stage15")

local treadmill = stage:WaitForChild("Treadmill")
local win = stage:WaitForChild("WinBlock14")

-- Erst zur Treadmill
hrp.CFrame = treadmill.CFrame + Vector3.new(0, 3, 0)

-- Warten, bis die Umgebung geladen/rendered ist
task.wait(1)

-- Dann zum WinBlock
hrp.CFrame = win.CFrame + Vector3.new(0, 3, 0)
