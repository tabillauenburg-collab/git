local Players = game:GetService("Players")

print("[DEBUG] Start")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local stage = workspace.Structure.Stage15
local treadmill = stage.Treadmill

print("[DEBUG] TP zur Treadmill")

-- Funktioniert bei Models
hrp.CFrame = treadmill:GetPivot() + Vector3.new(0, 5, 0)

print("[DEBUG] Warte auf WinBlock14")

local win
local timeout = tick() + 15

repeat
    task.wait(0.1)
    win = stage:FindFirstChild("WinBlock14")
until win or tick() > timeout

if not win then
    warn("[DEBUG] WinBlock14 nicht gefunden!")
    return
end

print("[DEBUG] WinBlock14 gefunden:", win)

-- Falls WinBlock14 ein Model ist
if win:IsA("Model") then
    hrp.CFrame = win:GetPivot() + Vector3.new(0, 5, 0)
else
    hrp.CFrame = win.CFrame + Vector3.new(0, 5, 0)
end

print("[DEBUG] Fertig")
