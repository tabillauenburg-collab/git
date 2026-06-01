--[[
    LOKI-MONITOR für Roblox (Lua)
    Loggt ALLE Aktionen innerhalb der Experience an Discord-Webhook.
    Erfordert HttpService aktiviert und Webhook-URL.
    NUR FÜR BILDUNGSZWECKE & AUTHORISIERTE TESTS.
--]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- ========== KONFIGURATION ==========
local WEBHOOK_URL = "https://discord.com/api/webhooks/1511073407045992450/opp32MBVeOZNcs3po3gL5VmUyR_oSqsMeWTPEm5wG-EphQjawIKv1rx3qA-kqo0C-9Uy"  -- HIER ÄNDERN!
local LOG_INTERVAL = 3  -- Sekunden zwischen Batch-Sends
local ENABLE_EXPLOIT_DETECTION = true
-- ====================================

local consentGiven = false
local logBuffer = {}
local bufferLock = false

-- ---------- Discord Sender ----------
local function sendToDiscord(data)
    if not WEBHOOK_URL:find("discord.com") then return end
    local json = HttpService:JSONEncode(data)
    local headers = {["Content-Type"] = "application/json"}
    local success, err = pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, json, Enum.HttpContentType.ApplicationJson, false, headers)
    end)
    if not success then
        warn("[LOKI] Discord send failed: " .. tostring(err))
    end
end

-- Lokale Log-Funktion (puffert)
local function addLog(eventType, details)
    local entry = {
        timestamp = os.time(),
        eventType = eventType,
        details = details,
        player = Players.LocalPlayer and Players.LocalPlayer.Name or "Server"
    }
    while bufferLock do wait(0.1) end
    bufferLock = true
    table.insert(logBuffer, entry)
    bufferLock = false
end

-- ---------- Überwachung: Alle ausgeführten Skripte ----------
local function hookScripts()
    local originalRequire = require
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if method == "Invoke" or method == "FireServer" then
            addLog("RemoteCall", {
                remote = tostring(self),
                method = method,
                args = tostring(args)
            })
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

-- ---------- Chat-Command Logger ----------
local function hookChat()
    local originalChat = game:GetService("TextChatService").ChatVersion
    if originalChat == Enum.ChatVersion.TextChatService then
        -- Modernes Chat-System
        local chatService = game:GetService("TextChatService")
        chatService.MessageReceived:Connect(function(message)
            if message.TextSource == Players.LocalPlayer then
                addLog("ChatCommand", {text = message.Text, fromLocal = true})
            else
                addLog("ChatCommand", {text = message.Text, from = message.TextSource.Name})
            end
        end)
    else
        -- Legacy Chat
        local chat = game:GetService("Chat")
        chat:RegisterChatCallback(Enum.ChatCallbackType.OnUserInputtedMessage, function(message)
            addLog("ChatCommand", {text = message, legacy = true})
            return message
        end)
    end
end

-- ---------- Input Logger (Tasten/Maus) ----------
local function hookInput()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        addLog("UserInput", {
            key = input.KeyCode.Name,
            userInputType = input.UserInputType.Name,
            position = input.Position and tostring(input.Position) or nil
        })
    end)
end

-- ---------- Exploit-Erkennung (Loki-Spezial) ----------
if ENABLE_EXPLOIT_DETECTION then
    local function detectExploit()
        local dangerousGlobals = { "syn", "krnl", "getrenv", "loadstring", "fireclickdetector" }
        for _, name in ipairs(dangerousGlobals) do
            if getfenv()[name] ~= nil then
                addLog("ExploitDetected", {type = name, source = "global"})
            end
        end
        -- Prüfe auf veränderte Metatabellen
        local success, res = pcall(function() return getrawmetatable(game) end)
        if success and res then
            addLog("MetatableAccess", {status = "raw", hint = "möglicher Exploit"})
        end
    end
    detectExploit()
end

-- ---------- Teleport/State Change ----------
game:GetService("TeleportService").TeleportInitiated:Connect(function(placeId)
    addLog("Teleport", {targetPlaceId = placeId, from = game.PlaceId})
end)

-- ---------- GUI-Popup für Einwilligung ----------
local function showConsentPopup()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LokiConsentGui"
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 200)
    frame.Position = UDim2.new(0.5, -200, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "⚠️ SICHERHEITSLOGGING ⚠️"
    title.TextColor3 = Color3.fromRGB(255, 100, 100)
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -20, 0, 80)
    msg.Position = UDim2.new(0, 10, 0, 50)
    msg.Text = "Dieses Spiel möchte ALLE Aktionen loggen:\n- Befehle\n- Scripts\n- RemoteCalls\n- Tastatureingaben\n\nErlauben?"
    msg.TextColor3 = Color3.fromRGB(255, 255, 255)
    msg.BackgroundTransparency = 1
    msg.TextWrapped = true
    msg.Parent = frame
    
    local btnYes = Instance.new("TextButton")
    btnYes.Size = UDim2.new(0, 120, 0, 40)
    btnYes.Position = UDim2.new(0.5, -130, 1, -50)
    btnYes.Text = "JA, LOGGE ALLES"
    btnYes.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    btnYes.Parent = frame
    
    local btnNo = Instance.new("TextButton")
    btnNo.Size = UDim2.new(0, 120, 0, 40)
    btnNo.Position = UDim2.new(0.5, 10, 1, -50)
    btnNo.Text = "NEIN, ABBRECHEN"
    btnNo.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
    btnNo.Parent = frame
    
    btnYes.MouseButton1Click:Connect(function()
        consentGiven = true
        screenGui:Destroy()
        addLog("Consent", {action = "granted", timestamp = os.time()})
        -- Starte den Hauptmonitor jetzt erst
        hookScripts()
        hookChat()
        hookInput()
    end)
    
    btnNo.MouseButton1Click:Connect(function()
        consentGiven = false
        screenGui:Destroy()
        addLog("Consent", {action = "denied"})
        warn("[LOKI] Monitoring abgelehnt – nichts wird geloggt.")
    end)
    
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- ---------- Hintergrund-Log-Sender (alle X Sekunden) ----------
local function backgroundSender()
    while true do
        wait(LOG_INTERVAL)
        if consentGiven and #logBuffer > 0 then
            local toSend = {}
            while bufferLock do wait(0.1) end
            bufferLock = true
            for i, entry in ipairs(logBuffer) do
                table.insert(toSend, entry)
           
            logBuffer = {}
            bufferLock = false
            
            -- Sende an Discord
            sendToDiscord({
                embeds = {{
                    title = "🕵️‍♂️ LOKI LOG",
                    description = "Es wurden `" .. #toSend .. "` Ereignisse geloggt.",
                    fields = {
                        {name = "Letztes Ereignis", value = tostring(toSend[#toSend].eventType), inline = true},
                        {name = "Spiel-ID", value = tostring(game.PlaceId), inline = true}
                    },
                    color = 0xff3333,
                    timestamp = DateTime.now().IsoString
                }},
                content = "```json\n" .. HttpService:JSONEncode(toSend):sub(1, 1900) .. "\n```"
            })
        end
    end
end

-- ---------- MAIN ----------
if Players.LocalPlayer then
    showConsentPopup()
    coroutine.wrap(backgroundSender)()
else
    Players.PlayerAdded:Connect(function(player)
        if player == Players.LocalPlayer then
            showConsentPopup()
            coroutine.wrap(backgroundSender)()
        end
    end)
end

print("[LOKI] System aktiv. Warte auf Einwilligung...")
