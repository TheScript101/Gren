-- Audio Logger — final update
-- LocalScript (StarterGui / executor)
-- Logs Sounds when they start playing, keeps entries, blocks duplicates by id, settings accessible via icon next to title.

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Player
local player = Players.LocalPlayer

-- State
local loggedEntries = {}      -- [idKey] = { btn = TextButton, sound = Sound or nil, status = "Playing"/"Ended"/"Removed", time = os.time() }
local blockedIds = {}         -- [idKey] = true (prevents re-logging until clear)
local selectedSound = nil

-- Settings (defaults ON)
local settings = {
    logPlayer = true,
    logWorkspace = true,
    logOther = true,
}

-- UI ----------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "LowTaperAudioLoggerGUI"
ScreenGui.ResetOnSpawn = false

-- Toggle Button (top-right icon)
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(1, -60, 0, 10)
ToggleButton.Image = "rbxthumb://type=Asset&id=103609514655874&w=420&h=420"
ToggleButton.BackgroundTransparency = 0.2
ToggleButton.BorderSizePixel = 2
ToggleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 360, 0, 420)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Visible = false
MainFrame.BorderSizePixel = 0
local UICorner = Instance.new("UICorner", MainFrame); UICorner.CornerRadius = UDim.new(0, 10)

-- Title + settings icon on the right of title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -36, 0, 40)
Title.Position = UDim2.new(0, 8, 0, 4)
Title.BackgroundTransparency = 1
Title.Text = "Audio Logger"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local TitleSettingsButton = Instance.new("ImageButton", MainFrame)
TitleSettingsButton.Size = UDim2.new(0, 28, 0, 28)
TitleSettingsButton.Position = UDim2.new(1, -38, 0, 8)
TitleSettingsButton.Image = "rbxthumb://type=Asset&id=6720824672&w=420&h=420"
TitleSettingsButton.BackgroundTransparency = 1
TitleSettingsButton.ZIndex = 5

-- Scrolling Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = MainFrame
ScrollFrame.Size = UDim2.new(1, -20, 1, -110)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.BackgroundTransparency = 1
local UIListLayout = Instance.new("UIListLayout", ScrollFrame); UIListLayout.Padding = UDim.new(0, 6)

-- Footer with Clear All (right)
local Footer = Instance.new("Frame", MainFrame)
Footer.Size = UDim2.new(1, -20, 0, 44)
Footer.Position = UDim2.new(0, 10, 1, -54)
Footer.BackgroundTransparency = 1

-- Pick GUI (Play / Copy)
local PickFrame = Instance.new("Frame")
PickFrame.Parent = ScreenGui
PickFrame.Size = UDim2.new(0, 260, 0, 120)
PickFrame.Position = UDim2.new(0.5, 180, 0.5, -220)
PickFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PickFrame.Visible = false
local PickUICorner = Instance.new("UICorner", PickFrame); PickUICorner.CornerRadius = UDim.new(0, 10)

local PickText = Instance.new("TextLabel", PickFrame)
PickText.Size = UDim2.new(1, 0, 0, 30)
PickText.Position = UDim2.new(0, 0, 0, 4)
PickText.BackgroundTransparency = 1
PickText.Text = "Selected Sound"
PickText.TextColor3 = Color3.fromRGB(255, 255, 255)
PickText.TextSize = 16
PickText.Font = Enum.Font.GothamBold

local PlayButton = Instance.new("TextButton", PickFrame)
PlayButton.Size = UDim2.new(1, -10, 0, 34)
PlayButton.Position = UDim2.new(0, 5, 0, 36)
PlayButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PlayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayButton.Text = "Play Sound"
PlayButton.Font = Enum.Font.Gotham
PlayButton.TextSize = 14
local PlayUICorner = Instance.new("UICorner", PlayButton); PlayUICorner.CornerRadius = UDim.new(0, 8)

local CopyButton = Instance.new("TextButton", PickFrame)
CopyButton.Size = UDim2.new(1, -10, 0, 34)
CopyButton.Position = UDim2.new(0, 5, 0, 76)
CopyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.Text = "Copy SoundId"
CopyButton.Font = Enum.Font.Gotham
CopyButton.TextSize = 14
local CopyUICorner = Instance.new("UICorner", CopyButton); CopyUICorner.CornerRadius = UDim.new(0, 8)

-- Settings Frame (toggleable via TitleSettingsButton)
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Parent = ScreenGui
SettingsFrame.Size = UDim2.new(0, 260, 0, 220)
SettingsFrame.Position = UDim2.new(0.5, 180, 0.5, -220)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsFrame.Visible = false
local SettingsCorner = Instance.new("UICorner", SettingsFrame); SettingsCorner.CornerRadius = UDim.new(0, 10)

local SettingsTitle = Instance.new("TextLabel", SettingsFrame)
SettingsTitle.Size = UDim2.new(1, 0, 0, 30)
SettingsTitle.Position = UDim2.new(0, 0, 0, 6)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "Settings"
SettingsTitle.Font = Enum.Font.GothamSemibold
SettingsTitle.TextSize = 18
SettingsTitle.TextColor3 = Color3.new(1,1,1)

local ClearAllButton = Instance.new("TextButton")
ClearAllButton.Size = UDim2.new(1, -20, 0, 34)
ClearAllButton.Position = UDim2.new(0, 10, 0, 166)
ClearAllButton.AnchorPoint = Vector2.new(1,0)
ClearAllButton.Text = "Clear All Logged Audios"
ClearAllButton.Font = Enum.Font.Gotham
ClearAllButton.TextSize = 14
ClearAllButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
ClearAllButton.TextColor3 = Color3.fromRGB(255,255,255)
ClearAllButton.Parent = SettingsFrame
ClearAllButton.Visible = false
local ClearCorner = Instance.new("UICorner", ClearAllButton); ClearCorner.CornerRadius = UDim.new(0,8)

local function makeToggle(parent, text, y, initial)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 34)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = text .. ": " .. (initial and "ON" or "OFF")
    local corner = Instance.new("UICorner", btn); corner.CornerRadius = UDim.new(0,8)
    return btn
end

local btnLogPlayer = makeToggle(SettingsFrame, "Log Player Audios", 46, settings.logPlayer)
local btnLogWorkspace = makeToggle(SettingsFrame, "Log Workspace Audios", 86, settings.logWorkspace)
local btnLogOther = makeToggle(SettingsFrame, "Log Other Audios", 126, settings.logOther)

-- Utility ----------------------------------------------------
local function updateCanvas()
    local total = 0
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then total = total + 1 end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, total * 46 + 8)
end

local function getIdKeyForSound(sound)
    -- prefer a canonical SoundId string; fallback to full name
    local sid = ""
    pcall(function() sid = tostring(sound.SoundId or "") end)
    if sid ~= "" and sid ~= "nil" then
        return sid
    end
    local ok, fullname = pcall(function() return sound:GetFullName() end)
    if ok and fullname then return "FULLNAME:" .. fullname end
    return "INSTANCE:" .. tostring(sound)
end

local function isSoundAllowed(sound)
    if not sound then return false end
    local ok, parent = pcall(function() return sound.Parent end)
    if not ok or not parent then return false end
    -- check if inside a player's character
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and parent:IsDescendantOf(plr.Character) then
            return settings.logPlayer
        end
    end
    -- inside workspace?
    if parent:IsDescendantOf(workspace) then
        return settings.logWorkspace
    end
    -- otherwise "other"
    return settings.logOther
end

-- Logging ----------------------------------------------------
local function createLabelForSound(sound, idKey)
    local sid = tostring(sound.SoundId or "")
    local name = sound.Name or "Sound"
    local labelText = name .. " — " .. (sid ~= "" and sid or "no id") .. "  [PLAYING]"
    local btn = Instance.new("TextButton")
    btn.Parent = ScrollFrame
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = labelText
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    local corner = Instance.new("UICorner", btn); corner.CornerRadius = UDim.new(0,8)
    btn.MouseButton1Click:Connect(function()
        selectedSound = sound
        PickText.Text = ("Selected: %s"):format(sound.Name or "Sound")
        PickFrame.Visible = true
    end)
    return btn
end

local function logSound(sound)
    if not sound or not sound:IsA("Sound") then return end
    if not isSoundAllowed(sound) then return end

    local idKey = getIdKeyForSound(sound)
    if blockedIds[idKey] then
        -- already blocked (we logged it before), do nothing
        return
    end

    -- block future logs for this id to prevent duplicates
    blockedIds[idKey] = true

    -- create UI entry and keep it persistent even after sound ends/removed
    local btn = createLabelForSound(sound, idKey)
    loggedEntries[idKey] = {
        btn = btn,
        sound = sound,
        status = "Playing",
        firstSeen = os.time(),
    }

    soundButtons = soundButtons or {}
    soundButtons[idKey] = btn

    updateCanvas()

    -- update when sound ends
    local endedConn
    endedConn = sound.Ended:Connect(function()
        local entry = loggedEntries[idKey]
        if entry and entry.btn then
            entry.status = "Ended"
            -- append status to the text safely
            local base = (sound.Name or "Sound") .. " — " .. (tostring(sound.SoundId or "") ~= "" and tostring(sound.SoundId or "") or "no id")
            pcall(function()
                entry.btn.Text = base .. "  [ENDED]"
            end)
        end
        if endedConn then pcall(function() endedConn:Disconnect() end) end
    end)

    -- mark removed if ancestry changed (but keep entry)
    sound.AncestryChanged:Connect(function(_, parent)
        local entry = loggedEntries[idKey]
        if not entry then return end
        entry.sound = parent and sound or nil
        if not parent then
            entry.status = "Removed"
            pcall(function()
                entry.btn.Text = (sound.Name or "Sound") .. " — " .. (tostring(sound.SoundId or "") ~= "" and tostring(sound.SoundId or "") or "no id") .. "  [REMOVED]"
            end)
        end
    end)
end

-- Play selected sound by cloning for client (more reliable)
PlayButton.MouseButton1Click:Connect(function()
    if selectedSound and selectedSound:IsA("Sound") then
        local ok, err = pcall(function()
            local clone = selectedSound:Clone()
            local parent = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) or workspace.CurrentCamera or workspace
            clone.Parent = parent
            clone.Volume = selectedSound.Volume or 1
            if selectedSound.PlaybackSpeed then clone.PlaybackSpeed = selectedSound.PlaybackSpeed end
            clone.Looped = false
            clone.RollOffMode = selectedSound.RollOffMode or Enum.RollOffMode.InverseTapered
            clone:Play()
            delay((clone.TimeLength or 5) + 1, function()
                pcall(function() clone:Destroy() end)
            end)
        end)
        if not ok then
            warn("PlaySound failed:", err)
        end
    end
    PickFrame.Visible = false
end)

-- Copy SoundId
CopyButton.MouseButton1Click:Connect(function()
    if selectedSound and selectedSound:IsA("Sound") then
        local sid = selectedSound.SoundId or ""
        pcall(function() setclipboard(sid) end)
    end
    PickFrame.Visible = false
end)

-- Watchers ----------------------------------------------------
local function attachToSound(sound)
    if not sound or not sound:IsA("Sound") then return end

    -- If sound is already playing and allowed, log (will block future duplicates)
    local ok, playing = pcall(function() return sound.Playing end)
    if ok and playing and isSoundAllowed(sound) then
        logSound(sound)
    end

    -- Listen for playing property becoming true
    local propConn
    propConn = sound:GetPropertyChangedSignal("Playing"):Connect(function()
        local suc, val = pcall(function() return sound.Playing end)
        if suc and val and isSoundAllowed(sound) then
            logSound(sound)
        end
    end)

    -- No UI destruction on ancestry removal — we mark removed instead
    sound.AncestryChanged:Connect(function(_, parent)
        if not parent and propConn then
            pcall(function() propConn:Disconnect() end)
        end
    end)
end

local function watchModelForSounds(model)
    if not model then return end
    for _, s in ipairs(model:GetDescendants()) do
        if s:IsA("Sound") then
            attachToSound(s)
        end
    end
    model.DescendantAdded:Connect(function(desc)
        if desc:IsA("Sound") then
            attachToSound(desc)
        end
    end)
end

-- Start watchers: workspace, players' characters, and global DescendantAdded
watchModelForSounds(workspace)
for _, plr in ipairs(Players:GetPlayers()) do
    if plr.Character then watchModelForSounds(plr.Character) end
    plr.CharacterAdded:Connect(function(char) watchModelForSounds(char) end)
end
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char) watchModelForSounds(char) end)
end)
game.DescendantAdded:Connect(function(desc)
    if desc:IsA("Sound") then
        attachToSound(desc)
    end
end)

-- Settings interactions -----------------------------------
local function updateSettingButtons()
    btnLogPlayer.Text = "Log Player Audios: " .. (settings.logPlayer and "ON" or "OFF")
    btnLogWorkspace.Text = "Log Workspace Audios: " .. (settings.logWorkspace and "ON" or "OFF")
    btnLogOther.Text = "Log Other Audios: " .. (settings.logOther and "ON" or "OFF")
end
updateSettingButtons()

local function refreshLoggedSounds()
    -- remove entries that are no longer allowed by settings (destroy their UI and un-log them)
    for idKey, entry in pairs(loggedEntries) do
        local s = entry.sound
        if s and not isSoundAllowed(s) then
            -- remove UI and un-log
            pcall(function() if entry.btn then entry.btn:Destroy() end end)
            loggedEntries[idKey] = nil
            blockedIds[idKey] = nil -- allow logging in future if settings change back
        end
    end

    -- also scan currently playing sounds to add newly allowed ones (if not blocked)
    for _, s in ipairs(workspace:GetDescendants()) do
        if s:IsA("Sound") then
            local ok, playing = pcall(function() return s.Playing end)
            if ok and playing then
                if isSoundAllowed(s) then
                    logSound(s)
                end
            end
        end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            for _, s in ipairs(plr.Character:GetDescendants()) do
                if s:IsA("Sound") then
                    local ok, playing = pcall(function() return s.Playing end)
                    if ok and playing then
                        if isSoundAllowed(s) then
                            logSound(s)
                        end
                    end
                end
            end
        end
    end
    updateCanvas()
end

btnLogPlayer.MouseButton1Click:Connect(function()
    settings.logPlayer = not settings.logPlayer
    updateSettingButtons()
    refreshLoggedSounds()
end)
btnLogWorkspace.MouseButton1Click:Connect(function()
    settings.logWorkspace = not settings.logWorkspace
    updateSettingButtons()
    refreshLoggedSounds()
end)
btnLogOther.MouseButton1Click:Connect(function()
    settings.logOther = not settings.logOther
    updateSettingButtons()
    refreshLoggedSounds()
end)

-- Clear All: removes UI entries and UNBLOCKS ids
ClearAllButton.MouseButton1Click:Connect(function()
    for idKey, entry in pairs(loggedEntries) do
        pcall(function() if entry.btn then entry.btn:Destroy() end end)
        loggedEntries[idKey] = nil
    end
    blockedIds = {}
    updateCanvas()
end)

-- Settings button (top-right of title)
local isSettingsOpen = false
TitleSettingsButton.MouseButton1Click:Connect(function()
    isSettingsOpen = not isSettingsOpen
    SettingsFrame.Visible = isSettingsOpen
end)

-- Toggle UI Visibility (main icon)
local isOpen = false
ToggleButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    MainFrame.Visible = isOpen
    if isOpen then
        -- quick scan to add currently playing allowed sounds (if not already blocked)
        for _, s in ipairs(workspace:GetDescendants()) do
            if s:IsA("Sound") then
                local ok, playing = pcall(function() return s.Playing end)
                if ok and playing and isSoundAllowed(s) then logSound(s) end
            end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                for _, s in ipairs(plr.Character:GetDescendants()) do
                    if s:IsA("Sound") then
                        local ok, playing = pcall(function() return s.Playing end)
                        if ok and playing and isSoundAllowed(s) then logSound(s) end
                    end
                end
            end
        end
    end
end)

-- small polling fallback to catch missed events (1s)
spawn(function()
    while true do
        for _, s in ipairs(workspace:GetDescendants()) do
            if s:IsA("Sound") then
                local ok, playing = pcall(function() return s.Playing end)
                if ok and playing and isSoundAllowed(s) then logSound(s) end
            end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                for _, s in ipairs(plr.Character:GetDescendants()) do
                    if s:IsA("Sound") then
                        local ok, playing = pcall(function() return s.Playing end)
                        if ok and playing and isSoundAllowed(s) then logSound(s) end
                    end
                end
            end
        end
        wait(1)
    end
end)
