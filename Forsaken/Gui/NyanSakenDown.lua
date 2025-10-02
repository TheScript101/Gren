-- Combined Script Loader
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create ScreenGui for loading overlay
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingCamlockGui"
loadingGui.Parent = PlayerGui
loadingGui.ResetOnSpawn = false

-- Black semi-transparent full screen background
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BackgroundTransparency = 0.6
bg.Parent = loadingGui

-- Big centered text label
local label = Instance.new("TextLabel")
label.Parent = bg
label.Size = UDim2.new(1, 0, 0, 100)
label.Position = UDim2.new(0, 0, 0.5, -50) -- center vertically
label.BackgroundTransparency = 1
label.Text = "Loading Camlock..."
label.Font = Enum.Font.Roboto
label.TextSize = 48
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextStrokeTransparency = 0.7
label.TextWrapped = true
label.TextScaled = true

-- After 2 seconds, fade out and destroy the GUI
task.delay(2, function()
    for i = 0, 1, 0.05 do
        bg.BackgroundTransparency = 0.6 + i * 0.4 -- fade from 0.6 to 1
        label.TextTransparency = i
        task.wait(0.03)
    end
    loadingGui:Destroy()
end)

wait(2)

-- Camlock/Aimlock
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Forsaken/CamlockRedid"))()
end)

-- autoblock
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/u8324080211-art/Auto-Block-99-/refs/heads/main/Auto%20Block"))()
end)

-- TwoTimeAndShedAndNoobThing
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Forsaken/Gui/TwoTime%2BShed%2BNoob"))()
end)

-- 007n7
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Forsaken/Gui/007n7.lua"))()
end)


------------------------------------------------------------------------
wait(0.5)
local CoreGui = game:GetService("CoreGui")

local function repositionCamlock()
    local camlock = CoreGui:FindFirstChild("Camlock")
    if camlock then
        local frame = camlock:FindFirstChild("Frame")
        if frame then
       frame.Position = UDim2.new(0.5, 168, 0.5, -203)
        end
    end
end

-- Try to reposition immediately if it exists
repositionCamlock()

-- Also listen for Camlock being added later
CoreGui.ChildAdded:Connect(function(child)
    if child.Name == "Camlock" then
        child.ChildAdded:Connect(function(subChild)
            if subChild.Name == "Frame" then
                subChild.Position = UDim2.new(0.5, 168, 0.5, -203)
            end
        end)
        -- In case Frame already exists
        local frame = child:FindFirstChild("Frame")
        if frame then
            frame.Position = UDim2.new(0.5, 168, 0.5, -203)
        end
    end
end)
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
wait(0.5)
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create ScreenGui for loading overlay
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingCamlockGui4"
loadingGui.Parent = PlayerGui
loadingGui.ResetOnSpawn = false

-- Black semi-transparent full screen background
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BackgroundTransparency = 0.6
bg.Parent = loadingGui

-- Big centered text label
local label = Instance.new("TextLabel")
label.Parent = bg
label.Size = UDim2.new(1, 0, 0, 100)
label.Position = UDim2.new(0, 0, 0.5, -50) -- center vertically
label.BackgroundTransparency = 1
label.Text = "Loading Antilag, Full bright, Etc..."
label.Font = Enum.Font.Roboto
label.TextSize = 48
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextStrokeTransparency = 0.7
label.TextWrapped = true
label.TextScaled = true

-- After 2 seconds, fade out and destroy the GUI
task.delay(2, function()
    for i = 0, 1, 0.05 do
        bg.BackgroundTransparency = 0.6 + i * 0.4 -- fade from 0.6 to 1
        label.TextTransparency = i
        task.wait(0.03)
    end
    loadingGui:Destroy()
end)
wait(2)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Function to create UI elements quickly
local function create(className, props)
    local obj = Instance.new(className)
    for k,v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

-- Create the main ScreenGui
local screenGui = create("ScreenGui", {
    Name = "FeatureToggleGui",
    Parent = PlayerGui,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Global
})

-- Create a semi-transparent dark background
local background = create("Frame", {
    Parent = screenGui,
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BackgroundTransparency = 0.15,
    Size = UDim2.new(1, 0, 1, 0),
})

-- Center frame for the popup window
local popup = create("Frame", {
    Parent = background,
    Size = UDim2.new(0, 350, 0, 250),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
    ClipsDescendants = true,
})
-- Rounded corners
local corner = create("UICorner", {
    Parent = popup,
    CornerRadius = UDim.new(0, 15)
})

-- Title text
local title = create("TextLabel", {
    Parent = popup,
    Size = UDim2.new(1, -40, 0, 50),
    Position = UDim2.new(0, 20, 0, 20),
    BackgroundTransparency = 1,
    Text = "Do you want to enable the following features?",
    Font = Enum.Font.Roboto,
    TextSize = 20,
    TextColor3 = Color3.fromRGB(230, 230, 230),
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
})

-- Feature list container
local featuresFrame = create("Frame", {
    Parent = popup,
    Size = UDim2.new(1, -40, 0, 110),
    Position = UDim2.new(0, 20, 0, 80),
    BackgroundTransparency = 1,
})

local features = {"Anti Lag", "Full Bright", "No Fog", "No Global Shadows"}

for i, feature in ipairs(features) do
    local featureText = create("TextLabel", {
        Parent = featuresFrame,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, (i-1)*28),
        BackgroundTransparency = 1,
        Text = "• "..feature,
        Font = Enum.Font.Roboto,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    })
end

-- Buttons container
local buttonsFrame = create("Frame", {
    Parent = popup,
    Size = UDim2.new(1, -40, 0, 50),
    Position = UDim2.new(0, 20, 1, -70),
    BackgroundTransparency = 1,
})

-- Helper to create buttons
local function createButton(text, position)
    local btn = create("TextButton", {
        Parent = buttonsFrame,
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = position,
        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
        Text = text,
        Font = Enum.Font.Roboto,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(230, 230, 230),
        AutoButtonColor = false,
        ClipsDescendants = true,
    })
    create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 12)})
    return btn
end

local yesButton = createButton("Yes", UDim2.new(0, 0, 0, 0))
local noButton = createButton("No", UDim2.new(0.55, 0, 0, 0))

-- Hover effects for buttons
for _, btn in pairs({yesButton, noButton}) do
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
end

-- The function to enable all features (the combined script from before)
local function enableFeatures()
    -- Terrain water setup
    local Terrain = Workspace:FindFirstChildOfClass("Terrain")
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
    end

    Lighting.GlobalShadows = false
    Lighting.FogStart = 9e9
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)

    settings().Rendering.QualityLevel = 1

-- Remove Atmosphere and disable PostEffects
for _, v in pairs(Lighting:GetDescendants()) do
    if v:IsA("Atmosphere") then
        v:Destroy()
    elseif v:IsA("PostEffect") then
        v.Enabled = false
    end
end

-- Loop No Fog
task.spawn(function()
    while true do
        Lighting.FogStart = 9e9
        Lighting.FogEnd = 9e9
        wait(1)
    end
end)

-- Optimize parts, decals, particles, and trails
for _, v in pairs(game:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Material = Enum.Material.Plastic
        v.Reflectance = 0
        v.BackSurface = Enum.SurfaceType.SmoothNoOutlines
        v.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
        v.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
        v.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
        v.RightSurface = Enum.SurfaceType.SmoothNoOutlines
        v.TopSurface = Enum.SurfaceType.SmoothNoOutlines
    elseif v:IsA("Decal") then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    end
end


    -- Remove effects on spawn for antlag
    Workspace.DescendantAdded:Connect(function(child)
        if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
            RunService.Heartbeat:Wait()
            if child and child.Parent then
                child:Destroy()
            end
        end
    end)

    -- Keep lighting bright every frame
    local brightLoop
    if brightLoop then brightLoop:Disconnect() end
    brightLoop = RunService.RenderStepped:Connect(function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 9e9
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end)
end

-- Yes button click
yesButton.MouseButton1Click:Connect(function()
    enableFeatures()
    screenGui:Destroy()
end)

-- No button click
noButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
wait(1)
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create ScreenGui for loading overlay
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingCamlockGui7"
loadingGui.Parent = PlayerGui
loadingGui.ResetOnSpawn = false

-- Black semi-transparent full screen background
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BackgroundTransparency = 0.6
bg.Parent = loadingGui

-- Big centered text label
local label = Instance.new("TextLabel")
label.Parent = bg
label.Size = UDim2.new(1, 0, 0, 100)
label.Position = UDim2.new(0, 0, 0.5, -50) -- center vertically
label.BackgroundTransparency = 1
label.Text = "Finalising..."
label.Font = Enum.Font.Roboto
label.TextSize = 48
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextStrokeTransparency = 0.7
label.TextWrapped = true
label.TextScaled = true

-- After 1 seconds, fade out and destroy the GUI
task.delay(1, function()
    for i = 0, 1, 0.05 do
        bg.BackgroundTransparency = 0.6 + i * 0.4 -- fade from 0.6 to 1
        label.TextTransparency = i
        task.wait(0.03)
    end
    loadingGui:Destroy()
end)
wait(1)
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function reposition()
    -- Camlock.Frame
    local camlock = CoreGui:FindFirstChild("Camlock")
    if camlock then
        local frame = camlock:FindFirstChild("Frame")
        if frame then
            frame.Position = UDim2.new(0.5, 174, 0.5, -198)
        end
        local fovCircle = camlock:FindFirstChild("FOVCircle")
        if fovCircle then
            fovCircle.Size = UDim2.new(0, 25, 0, 25)
            fovCircle.Position = UDim2.new(0.5, 0, 0.416998416, 0)
        end
    end

    -- GhostFollowerGui.TextButton
    local ghostGui = CoreGui:FindFirstChild("GhostFollowerGui")
    if ghostGui then
        local btn = ghostGui:FindFirstChildWhichIsA("TextButton") or ghostGui:FindFirstChild("TextButton")
        if btn then
            btn.Position = UDim2.new(0, 710, 0, -55)
        end
    end

    -- HurtAnim.TextButton (UPDATED POSITION)
    local hurtAnim = CoreGui:FindFirstChild("HurtAnim")
    if hurtAnim then
        local btn = hurtAnim:FindFirstChildWhichIsA("TextButton") or hurtAnim:FindFirstChild("TextButton")
        if btn then
            btn.Position = UDim2.new(0, 710, 0, -11)
        end
    end

    -- PlayerListHolder.Close
    local closeBtn = player.PlayerGui:FindFirstChild("MainUI") and player.PlayerGui.MainUI:FindFirstChild("PlayerListHolder") and player.PlayerGui.MainUI.PlayerListHolder:FindFirstChild("Close")
    if closeBtn then
        closeBtn.Position = UDim2.new(0, 0, 0, 25)
    end

    -- Objectives
    local objectives = player.PlayerGui:FindFirstChild("MainUI") and player.PlayerGui.MainUI:FindFirstChild("Objectives")
    if objectives then
        objectives.Position = UDim2.new(0.389999986, 0, 0, 35)
    end
end

-- Initial reposition if they already exist
reposition()

-- Listen for new children added to CoreGui, reposition when they appear
CoreGui.ChildAdded:Connect(function(child)
    if child.Name == "Camlock" then
        child.ChildAdded:Connect(function(sub)
            if sub.Name == "Frame" then
                sub.Position = UDim2.new(0.5, 174, 0.5, -198)
            elseif sub.Name == "FOVCircle" then
                sub.Size = UDim2.new(0, 25, 0, 25)
                sub.Position = UDim2.new(0.5, 0, 0.416998416, 0)
            end
        end)
    elseif child.Name == "GhostFollowerGui" then
        child.ChildAdded:Connect(function(sub)
            if sub:IsA("TextButton") then
                sub.Position = UDim2.new(0, 710, 0, -55)
            end
        end)
    elseif child.Name == "HurtAnim" then
        child.ChildAdded:Connect(function(sub)
            if sub:IsA("TextButton") then
                sub.Position = UDim2.new(0, 710, 0, -11) -- updated
            end
        end)
    end
end)

-- Listen for MainUI elements being added
player.PlayerGui.ChildAdded:Connect(function(guiChild)
    if guiChild.Name == "MainUI" then
        guiChild.ChildAdded:Connect(function(mainChild)
            if mainChild.Name == "PlayerListHolder" then
                local closeBtn = mainChild:FindFirstChild("Close")
                if closeBtn then
                    closeBtn.Position = UDim2.new(0, 0, 0, 25)
                end
            elseif mainChild.Name == "Objectives" then
                mainChild.Position = UDim2.new(0.389999986, 0, 0, 35)
            end
        end)
    end
end)

--------------------------------------------------------------------------------------------------------------------
wait(1)
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create ScreenGui for loading overlay
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingCamlockGui677"
loadingGui.Parent = PlayerGui
loadingGui.ResetOnSpawn = false

-- Black semi-transparent full screen background
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BackgroundTransparency = 0.6
bg.Parent = loadingGui

-- Big centered text label
local label = Instance.new("TextLabel")
label.Parent = bg
label.Size = UDim2.new(1, 0, 0, 100)
label.Position = UDim2.new(0, 0, 0.5, -50) -- center vertically
label.BackgroundTransparency = 1
label.Text = "Loading Speed Advantages..."
label.Font = Enum.Font.Roboto
label.TextSize = 48
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextStrokeTransparency = 0.7
label.TextWrapped = true
label.TextScaled = true

-- After 1 seconds, fade out and destroy the GUI
task.delay(1, function()
    for i = 0, 1, 0.05 do
        bg.BackgroundTransparency = 0.6 + i * 0.4 -- fade from 0.6 to 1
        label.TextTransparency = i
        task.wait(0.03)
    end
    loadingGui:Destroy()
end)
wait(1)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function applySettings()
    local Sprinting = game:GetService("ReplicatedStorage").Systems.Character.Game.Sprinting
    local stamina = require(Sprinting)

    stamina.MaxStamina = 100
    stamina.MinStamina = -5
    stamina.StaminaGain = 35
    stamina.StaminaLoss = 8.5
    stamina.SprintSpeed = 27
    stamina.StaminaLossDisabled = false
end

-- Run once
applySettings()

-- Re-run after every respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1) -- small delay so modules load fully
    applySettings()
end)
--------------------------------------------------------------------------------------------------------------------
wait(1)
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Create ScreenGui for loading overlay
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingCamlockGui5"
loadingGui.Parent = PlayerGui
loadingGui.ResetOnSpawn = false

-- Black semi-transparent full screen background
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BackgroundTransparency = 0.6
bg.Parent = loadingGui

-- Big centered text label
local label = Instance.new("TextLabel")
label.Parent = bg
label.Size = UDim2.new(1, 0, 0, 100)
label.Position = UDim2.new(0, 0, 0.5, -50) -- center vertically
label.BackgroundTransparency = 1
label.Text = "Loading ESP..."
label.Font = Enum.Font.Roboto
label.TextSize = 48
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextStrokeTransparency = 0.7
label.TextWrapped = true
label.TextScaled = true

-- After 1 seconds, fade out and destroy the GUI
task.delay(1, function()
    for i = 0, 1, 0.05 do
        bg.BackgroundTransparency = 0.6 + i * 0.4 -- fade from 0.6 to 1
        label.TextTransparency = i
        task.wait(0.03)
    end
    loadingGui:Destroy()
end)
wait(1)
--------------------------------------------------------------------------------------------------------------------
-- Forsaken ESP Fix
-- generator esp + auto-repair with map presence detection (keeps your original logic intact)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local workspacePlayers = Workspace:WaitForChild("Players")
local killersFolder = workspacePlayers:WaitForChild("Killers")

local TARGET_ANIMATION_ID = "rbxassetid://82691533602949"

-- NOTE: ingameMapFolder will be assigned dynamically when a map appears.
-- This replaces a blocking WaitForChild so the script can detect map presence/absence.
local ingameMapFolder = nil

local REPEAT_DELAY = 6.5
local CHECK_INTERVAL = 1

-- Create countdown TextLabel
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Wait for the LocalPlayer to exist if this runs very early
while not player do
    wait()
    player = Players.LocalPlayer
end

-- Wait for PlayerGui to exist
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RepairTimerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Create TextLabel
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0, 192, 0, 70)
timerLabel.Position = UDim2.new(0.5, 5, 0.5, 135)
timerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
timerLabel.Text = tostring(REPEAT_DELAY)
timerLabel.Font = Enum.Font.GothamBlack
timerLabel.TextSize = 48
timerLabel.TextColor3 = Color3.new(1,1,1)
timerLabel.TextStrokeTransparency = 0
timerLabel.TextStrokeColor3 = Color3.new(0,0,0)
timerLabel.BackgroundTransparency = 1
timerLabel.Visible = true
timerLabel.Parent = screenGui

local function updateTimerLabel(count)
    timerLabel.Text = string.format("%.1f", count)
end

local function addGeneratorHighlight(gen, colorInside, colorOutline)
    for _, child in ipairs(gen:GetChildren()) do
        if child:IsA("Highlight") then
            child:Destroy()
        end
    end

    local hl = Instance.new("Highlight")
    hl.FillColor = colorInside
    hl.OutlineColor = colorOutline
    hl.FillTransparency = 0.85
    hl.OutlineTransparency = 0.6
    pcall(function()
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end)
    hl.Parent = gen
end

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Gen Esp"; Text = "Esp for Generators LOADED!"; Duration = 2})

local function removeHighlight(gen)
    local hl = gen:FindFirstChildWhichIsA("Highlight")
    if hl then hl:Destroy() end
end

local function updateGeneratorHighlight(gen)
    if not gen or not gen.Parent then return end
    if gen.Name == "Generator" then
        local progressValue = gen:FindFirstChild("Progress")
        if progressValue then
            if progressValue.Value < 100 then
                addGeneratorHighlight(gen, Color3.fromRGB(255, 255, 200), Color3.fromRGB(255, 255, 100))
            else
                addGeneratorHighlight(gen, Color3.fromRGB(180, 255, 180), Color3.fromRGB(100, 255, 100))
            end
        else
            addGeneratorHighlight(gen, Color3.fromRGB(255, 255, 200), Color3.fromRGB(255, 255, 100))
        end
    elseif gen.Name == "FakeGenerator" then
        local noli = killersFolder:FindFirstChild("Noli")
        if noli then
            addGeneratorHighlight(gen, Color3.fromRGB(255, 180, 180), Color3.fromRGB(255, 0, 0))
        else
            removeHighlight(gen)
        end
    else
        removeHighlight(gen)
    end
end

local function setupGeneratorListeners(gen)
    if gen.Name == "Generator" then
        local progressValue = gen:FindFirstChild("Progress")
        if progressValue then
            updateGeneratorHighlight(gen)
            progressValue:GetPropertyChangedSignal("Value"):Connect(function()
                updateGeneratorHighlight(gen)
            end)
        else
            updateGeneratorHighlight(gen)
        end
    elseif gen.Name == "FakeGenerator" then
        updateGeneratorHighlight(gen)
    end
end

local function onGeneratorAdded(gen)
    if gen.Name == "Generator" or gen.Name == "FakeGenerator" then
        setupGeneratorListeners(gen)
    end
end

local function checkSpecialHighlight()
    if not ingameMapFolder then return end
    local noli = killersFolder:FindFirstChild("Noli")
    local fakeGen = ingameMapFolder:FindFirstChild("FakeGenerator")
    if noli and fakeGen then
        addGeneratorHighlight(fakeGen, Color3.fromRGB(255, 180, 180), Color3.fromRGB(255, 0, 0))
    elseif fakeGen then
        removeHighlight(fakeGen)
    end
end

-- repair logic based on animation instead of distance
local repairingGenerators = {}
local timerActive = false
local currentTimer = REPEAT_DELAY

local function startRepairLoop(gen)
    if repairingGenerators[gen] then return end
    repairingGenerators[gen] = true

    task.spawn(function()
        timerActive = true
        timerLabel.Visible = true -- show label when timer starts
        currentTimer = REPEAT_DELAY
        while repairingGenerators[gen] and gen.Parent and gen:FindFirstChild("Progress") and gen.Progress.Value < 100 do
            local startTime = tick()
            while tick() - startTime < REPEAT_DELAY do
                if not repairingGenerators[gen] then break end
                currentTimer = REPEAT_DELAY - (tick() - startTime)
                updateTimerLabel(currentTimer)
                wait(0.1)
            end
            if repairingGenerators[gen] then
                gen.Remotes.RE:FireServer()
            end
        end
        timerActive = true
        timerLabel.Visible = true -- hide label when timer ends
        updateTimerLabel(REPEAT_DELAY)
        repairingGenerators[gen] = nil
    end)
end

local function stopRepairLoop(gen)
    repairingGenerators[gen] = nil
    if not next(repairingGenerators) then
        timerActive = true
        timerLabel.Visible = true -- hide label if no active timers
        updateTimerLabel(REPEAT_DELAY)
    end
end

-- monitor animation to trigger repair loop
local function monitorAnimations()
    humanoid.AnimationPlayed:Connect(function(track)
        local id = track.Animation and track.Animation.AnimationId
        if id == TARGET_ANIMATION_ID then
            if ingameMapFolder then
                for _, gen in ipairs(ingameMapFolder:GetChildren()) do
                    if gen.Name == "Generator" and gen:FindFirstChild("Progress") and gen.Progress.Value < 100 and gen:FindFirstChild("Remotes") and gen.Remotes:FindFirstChild("RE") then
                        startRepairLoop(gen)
                    end
                end
            end

            track.Stopped:Connect(function()
                for gen in pairs(repairingGenerators) do
                    stopRepairLoop(gen)
                end
            end)
        end
    end)
end

monitorAnimations()

-- iterate through generators only when ingameMapFolder exists
local function generatorLoop()
    while true do
        if not character or not character.Parent then
            character = player.Character or player.CharacterAdded:Wait()
            humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            humanoid = character:WaitForChild("Humanoid")
            monitorAnimations() -- reconnect animation listener if new character
        end

        if ingameMapFolder and ingameMapFolder.Parent then
            for _, gen in ipairs(ingameMapFolder:GetChildren()) do
                if gen.Name == "Generator" or gen.Name == "FakeGenerator" then
                    updateGeneratorHighlight(gen)
                end
            end
            checkSpecialHighlight()
        end

        wait(CHECK_INTERVAL)
    end
end

-- Keeps track of the current childadded connection so we can disconnect on map removal
local mapChildConn = nil

-- Remove highlights from all known generators when map ends
local function clearAllGeneratorHighlights()
    if ingameMapFolder and ingameMapFolder.Parent then
        for _, g in ipairs(ingameMapFolder:GetChildren()) do
            removeHighlight(g)
        end
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "Generator" or obj.Name == "FakeGenerator" then
            removeHighlight(obj)
        end
    end

    repairingGenerators = {}
end

-- Setup generators currently present in the ingameMapFolder
setupAllGenerators = function()
    if not ingameMapFolder then return end
    for _, gen in ipairs(ingameMapFolder:GetChildren()) do
        if gen.Name == "Generator" or gen.Name == "FakeGenerator" then
            setupGeneratorListeners(gen)
        end
    end
end

-- Map presence watcher: detects when Workspace.Map.Ingame.Map appears/disappears.
task.spawn(function()
    local hadMap = false
    while true do
        local mapRoot = Workspace:FindFirstChild("Map")
        local foundMap = nil
        if mapRoot then
            local ingame = mapRoot:FindFirstChild("Ingame")
            if ingame then
                foundMap = ingame:FindFirstChild("Map")
            end
        end

        if foundMap and not hadMap then
            ingameMapFolder = foundMap
            hadMap = true
            wait(2)
            setupAllGenerators()

            if ingameMapFolder and ingameMapFolder.Parent then
                mapChildConn = ingameMapFolder.ChildAdded:Connect(function(child)
                    onGeneratorAdded(child)
                end)
            end
        elseif not foundMap and hadMap then
            hadMap = false
            if mapChildConn then
                pcall(function() mapChildConn:Disconnect() end)
                mapChildConn = nil
            end
            clearAllGeneratorHighlights()
            ingameMapFolder = nil
        end

        wait(CHECK_INTERVAL)
    end
end)

task.spawn(generatorLoop)

--------------------------------------------------------------------------------------------------------------------
