local Players = game:GetService("Players")

print("[DEBUG] Script gestartet")

local player = Players.LocalPlayer
print("[DEBUG] Player:", player)

local character = player.Character or player.CharacterAdded:Wait()
print("[DEBUG] Character gefunden:", character)

local hrp = character:WaitForChild("HumanoidRootPart")
print("[DEBUG] HRP gefunden:", hrp)

local structure = workspace:FindFirstChild("Structure")
print("[DEBUG] Structure:", structure)

local stage = structure and structure:FindFirstChild("Stage15")
print("[DEBUG] Stage15:", stage)

if not stage then
    warn("[DEBUG] Stage15 nicht gefunden!")
    return
end

local treadmill = stage:FindFirstChild("Treadmill")
print("[DEBUG] Treadmill:", treadmill)

if not treadmill then
    warn("[DEBUG] Treadmill nicht gefunden!")
    return
end

print("[DEBUG] Teleportiere zur Treadmill...")
hrp.CFrame = treadmill.CFrame + Vector3.new(0, 5, 0)

task.wait(2)

print("[DEBUG] Suche WinBlock14...")

local win = stage:FindFirstChild("WinBlock14")

local startTime = tick()
while not win and tick() - startTime < 15 do
    task.wait(0.25)
    win = stage:FindFirstChild("WinBlock14")
    print("[DEBUG] Warte auf WinBlock14...")
end

print("[DEBUG] WinBlock14:", win)

if not win then
    warn("[DEBUG] WinBlock14 wurde nicht gefunden!")
    return
end

print("[DEBUG] Teleportiere zu WinBlock14...")
hrp.CFrame = win.CFrame + Vector3.new(0, 5, 0)

print("[DEBUG] Fertig!")
