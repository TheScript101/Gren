-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Variables
local player = Players.LocalPlayer
local animationsLogged = {}
local animationData = {}        -- [animId] = { startPos, endPos, speed, loop, length, lastSeen }
local animationButtons = {}     -- [animId] = TextButton
local selectedAnimId = nil
local logAllAnimations = false

local IgnoredAnimations = {
    ["rbxassetid://138196552148011"] = true,
    ["rbxassetid://120133391090244"] = true,
    ["http://www.roblox.com/asset/?id=117941450906936"] = true,
    ["http://www.roblox.com/asset/?id=140491244934559"] = true,
    ["rbxassetid://96489184596023"] = true,
}

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LowTaperAnimLogger"
ScreenGui.Parent = CoreGui

-- Toggle Button
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(1, -60, 0, 10)
ToggleButton.Image = "rbxthumb://type=Asset&id=103609514655874&w=420&h=420"
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.BorderSizePixel = 2
ToggleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Name = "ToggleButton"

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 320, 0, 350)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Visible = false
MainFrame.BorderSizePixel = 0
MainFrame.Name = "MainFrame"

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "LowTaper's Anim Logger"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold

-- Scrolling Frame (list of animations on left)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = MainFrame
ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 5, 0)
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.Name = "ScrollFrame"

local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.Padding = UDim.new(0, 5)

-- Pick Frame (side panel with actions)
local PickFrame = Instance.new("Frame")
PickFrame.Parent = ScreenGui
PickFrame.Size = UDim2.new(0, 260, 0, 140)
PickFrame.Position = UDim2.new(0.5, 170, 0.5, -200)
PickFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PickFrame.Visible = false
PickFrame.Name = "PickFrame"

local PickUICorner = Instance.new("UICorner", PickFrame)
PickUICorner.CornerRadius = UDim.new(0, 10)

local PickText = Instance.new("TextLabel")
PickText.Parent = PickFrame
PickText.Size = UDim2.new(1, -10, 0, 70)
PickText.Position = UDim2.new(0, 5, 0, 5)
PickText.BackgroundTransparency = 1
PickText.TextColor3 = Color3.fromRGB(255, 255, 255)
PickText.TextSize = 13
PickText.Font = Enum.Font.Gotham
PickText.TextXAlignment = Enum.TextXAlignment.Left
PickText.TextYAlignment = Enum.TextYAlignment.Top
PickText.Text = "Select an animation from the list."

-- Play Normally Button
local PlayNormalButton = Instance.new("TextButton")
PlayNormalButton.Parent = PickFrame
PlayNormalButton.Size = UDim2.new(1, -10, 0, 30)
PlayNormalButton.Position = UDim2.new(0, 5, 0, 80)
PlayNormalButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PlayNormalButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayNormalButton.Text = "Play Normally"
PlayNormalButton.Font = Enum.Font.Gotham
PlayNormalButton.TextSize = 14
PlayNormalButton.Name = "PlayNormalButton"
Instance.new("UICorner", PlayNormalButton).CornerRadius = UDim.new(0, 8)

-- Copy ID Button
local CopyButton = Instance.new("TextButton")
CopyButton.Parent = PickFrame
CopyButton.Size = UDim2.new(1, -10, 0, 30)
CopyButton.Position = UDim2.new(0, 5, 0, 145)
CopyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.Text = "Copy ID"
CopyButton.Font = Enum.Font.Gotham
CopyButton.TextSize = 14
CopyButton.Name = "CopyButton"
Instance.new("UICorner", CopyButton).CornerRadius = UDim.new(0, 8)

-- Settings UI (compact)
local SettingsButton = Instance.new("ImageButton")
SettingsButton.Parent = MainFrame
SettingsButton.Size = UDim2.new(0, 30, 0, 30)
SettingsButton.Position = UDim2.new(0, 10, 0, 5)
SettingsButton.Image = "rbxthumb://type=Asset&id=6720824672&w=420&h=420"
SettingsButton.BackgroundTransparency = 1

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Parent = ScreenGui
SettingsFrame.Size = UDim2.new(0, 200, 0, 120)
SettingsFrame.Position = UDim2.new(0.5, -355, 0.5, -200)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsFrame.Visible = false

Instance.new("UICorner", SettingsFrame).CornerRadius = UDim.new(0, 10)

local SettingsText = Instance.new("TextLabel")
SettingsText.Parent = SettingsFrame
SettingsText.Size = UDim2.new(1, 0, 0, 30)
SettingsText.BackgroundTransparency = 1
SettingsText.Text = "Settings"
SettingsText.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsText.TextSize = 16
SettingsText.Font = Enum.Font.GothamBold

local ClearAllButton = Instance.new("TextButton")
ClearAllButton.Parent = SettingsFrame
ClearAllButton.Size = UDim2.new(1, -10, 0, 30)
ClearAllButton.Position = UDim2.new(0, 5, 0, 40)
ClearAllButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ClearAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearAllButton.Text = "Clear All Animations"
ClearAllButton.Font = Enum.Font.Gotham
ClearAllButton.TextSize = 14
Instance.new("UICorner", ClearAllButton).CornerRadius = UDim.new(0, 8)

local LogAllButton = Instance.new("TextButton")
LogAllButton.Parent = SettingsFrame
LogAllButton.Size = UDim2.new(1, -10, 0, 30)
LogAllButton.Position = UDim2.new(0, 5, 0, 80)
LogAllButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
LogAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LogAllButton.Text = "Log All Animations: OFF"
LogAllButton.Font = Enum.Font.Gotham
LogAllButton.TextSize = 14
Instance.new("UICorner", LogAllButton).CornerRadius = UDim.new(0, 8)

-- Helpers ------------------------------------------------------------

local function formatNum(n)
    return string.format("%.2f", tonumber(n) or 0)
end

local function makeAnimButton(animId)
    local btn = Instance.new("TextButton")
    btn.Parent = ScrollFrame
    btn.Size = UDim2.new(1, -10, 0, 65)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    animationButtons[animId] = btn
    return btn
end

local function refreshAnimButton(animId)
    local btn = animationButtons[animId]
    if not btn then return end
    local data = animationData[animId]
    local startStr = data and data.startPos and formatNum(data.startPos) or "?"
    local endStr = data and data.endPos and formatNum(data.endPos) or (data and data.length and formatNum(data.length) or "?")
    local speedStr = data and tostring(data.speed) or "?"
    local loopStr = (data and data.loop) ~= nil and tostring(data.loop) or "?"
    local lengthStr = data and data.length and formatNum(data.length) or "?"
    btn.Text = "Animation ID\n" .. animId
end

local function ensureButtonFor(animId)
    if not animationButtons[animId] then
        local btn = makeAnimButton(animId)
        btn.MouseButton1Click:Connect(function()
            selectedAnimId = animId
            PickFrame.Visible = true
            local data = animationData[animId]
            if data then
                local startStr = data.startPos and formatNum(data.startPos) or "?"
                local endStr = data.endPos and formatNum(data.endPos) or (data.length and formatNum(data.length) or "?")
                local lengthStr = data.length and formatNum(data.length) or "?"
                PickText.Text =
                    "ID: " .. animId ..
                    "\nStart: " .. startStr .. "s | End: " .. endStr .. "s" ..
                    "\nSpeed: " .. tostring(data.speed) .. " | Loop: " .. tostring(data.loop) ..
                    "\nLength: " .. lengthStr .. "s"
            else
                PickText.Text = "ID: " .. animId .. "\nNo advanced data yet."
            end
        end)
    end
    refreshAnimButton(animId)
end

-- Logging logic ------------------------------------------------------

local function captureStartIfNeeded(track)
    local id = track.Animation and track.Animation.AnimationId
    if not id or IgnoredAnimations[id] then
    return
  end
    local data = animationData[id]
    if not data then
        animationData[id] = {
            startPos = track.TimePosition or 0,
            endPos = nil,
            speed = track.Speed or 1,
            loop = track.Looped or false,
            length = track.Length or 0,
            lastSeen = tick()
        }
    else
        -- update dynamic properties
        data.speed = track.Speed or data.speed
        data.loop = track.Looped or data.loop
        data.length = track.Length or data.length
        data.lastSeen = tick()
        -- if startPos is nil, set it to current TimePosition
        if data.startPos == nil then
            data.startPos = track.TimePosition or 0
        end
    end

    -- ensure we update the UI button
    ensureButtonFor(id)

    -- connect stopped to capture endPos (only once)
    if not data._stoppedConnected then
        data._stoppedConnected = true
        track.Stopped:Connect(function()
            local d = animationData[id]
            if d then
                d.endPos = track.TimePosition or d.endPos or d.length
                ensureButtonFor(id)
            end
        end)
    end
end

-- Called periodically to scan playing tracks and update data
local function detectAnimations()
    local function logFromCharacter(character)
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                if track and track.Animation then
                    captureStartIfNeeded(track)
                end
            end
        end
    end

    if logAllAnimations then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                logFromCharacter(plr.Character)
            end
        end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                logFromCharacter(obj)
            end
        end
    else
        if player and player.Character then
            logFromCharacter(player.Character)
        end
    end
end

-- Play functions ----------------------------------------------------

local function playNormally(animId)
    if not animId or not player.Character then return end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    local track = humanoid:LoadAnimation(anim)
    track:Play()
    return track
end

    local segStart = data.startPos or 0
    local segEnd = data.endPos or data.length or segStart

    -- clamp
    segStart = math.clamp(segStart, 0, data.length or math.huge)
    segEnd = math.clamp(segEnd, 0, data.length or math.huge)

    -- apply properties
    track.Looped = data.loop or false
    track.Speed = data.speed or 1

    -- set time and play
    -- Some animations may not accept TimePosition until played once; play then set TimePosition immediately
    track:Play()
    -- small delay to ensure TimePosition can be set (use Heartbeat for immediate)
    local setOnce
    setOnce = RunService.Heartbeat:Connect(function()
        if track.IsPlaying then
            track.TimePosition = segStart
            setOnce:Disconnect()
        end
    end)

    -- monitor and stop when reaching segEnd
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not track.IsPlaying then
            if conn then conn:Disconnect() end
            return
        end
        -- If looped, we still want to stop after reaching segEnd once
        if track.TimePosition >= segEnd - 1e-4 then
            track:Stop()
            if conn then conn:Disconnect() end
        end
    end)

    return track
end

-- UI button handlers ------------------------------------------------

PlayNormalButton.MouseButton1Click:Connect(function()
    if selectedAnimId then
        playNormally(selectedAnimId)
    end
end)

CopyButton.MouseButton1Click:Connect(function()
    if selectedAnimId then
        pcall(function() setclipboard(selectedAnimId) end)
    end
end)

-- Settings handlers -------------------------------------------------

LogAllButton.MouseButton1Click:Connect(function()
    logAllAnimations = not logAllAnimations
    LogAllButton.Text = "Log All Animations: " .. (logAllAnimations and "ON" or "OFF")
end)

ClearAllButton.MouseButton1Click:Connect(function()
    for id, btn in pairs(animationButtons) do
        if btn and btn.Parent then btn:Destroy() end
    end
    animationsLogged = {}
    animationData = {}
    animationButtons = {}
    selectedAnimId = nil
    PickFrame.Visible = false
    PickText.Text = "Select an animation from the list."
end)

SettingsButton.MouseButton1Click:Connect(function()
    SettingsFrame.Visible = not SettingsFrame.Visible
end)

-- Toggle main UI ---------------------------------------------------

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        detectAnimations()
    end
end)

-- Periodic detection and UI refresh -------------------------------

-- Refresh button texts periodically so updated endPos/speed/loop show up
spawn(function()
    while true do
        detectAnimations()
        for animId, _ in pairs(animationButtons) do
            refreshAnimButton(animId)
        end
        wait(0.35)
    end
end)

-- Also update when new players join (to capture their animations if logAllAnimations)
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        -- small delay to allow animations to start
        wait(0.2)
        detectAnimations()
    end)
end)

-- Ensure local player's character changes are tracked
player.CharacterAdded:Connect(function()
    wait(0.2)
    detectAnimations()
end)

-- When an animation is first detected, create its button and mark logged
-- This helper is used by detectAnimations via captureStartIfNeeded -> ensureButtonFor
-- Mark as logged when button is created
local function markLogged(animId)
    if not animationsLogged[animId] then
        animationsLogged[animId] = true
    end
end

-- Hook ensureButtonFor to mark logged
local oldEnsure = ensureButtonFor
ensureButtonFor = function(animId)
    oldEnsure(animId)
    markLogged(animId)
end

-- End of script
