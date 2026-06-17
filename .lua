local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local stage = workspace.Structure.Stage15

hrp.CFrame = stage.Treadmill.CFrame + Vector3.new(0, 3, 0)

repeat
    task.wait()
until stage:FindFirstChild("WinBlock14")

hrp.CFrame = stage.WinBlock14.CFrame + Vector3.new(0, 3, 0)
