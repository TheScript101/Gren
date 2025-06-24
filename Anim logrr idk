-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Variables
local player = Players.LocalPlayer
local animationsLogged = {}

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
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

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Visible = false
MainFrame.BorderSizePixel = 0

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

-- Scrolling Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = MainFrame
ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 5, 0)
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.Padding = UDim.new(0, 5)

-- Pick GUI
local PickFrame = Instance.new("Frame")
PickFrame.Parent = ScreenGui
PickFrame.Size = UDim2.new(0, 200, 0, 120)
PickFrame.Position = UDim2.new(0.5, 155, 0.5, -200)
PickFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PickFrame.Visible = false

local PickUICorner = Instance.new("UICorner", PickFrame)
PickUICorner.CornerRadius = UDim.new(0, 10)

local PickText = Instance.new("TextLabel")
PickText.Parent = PickFrame
PickText.Size = UDim2.new(1, 0, 0, 30)
PickText.BackgroundTransparency = 1
PickText.Text = "Pick an option"
PickText.TextColor3 = Color3.fromRGB(255, 255, 255)
PickText.TextSize = 16
PickText.Font = Enum.Font.GothamBold

-- Play Button
local PlayButton = Instance.new("TextButton")
PlayButton.Parent = PickFrame
PlayButton.Size = UDim2.new(1, -10, 0, 30)
PlayButton.Position = UDim2.new(0, 5, 0, 35)
PlayButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PlayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayButton.Text = "Play Anim"
PlayButton.Font = Enum.Font.Gotham
PlayButton.TextSize = 14

local PlayUICorner = Instance.new("UICorner", PlayButton)
PlayUICorner.CornerRadius = UDim.new(0, 8)

-- Copy Button
local CopyButton = Instance.new("TextButton")
CopyButton.Parent = PickFrame
CopyButton.Size = UDim2.new(1, -10, 0, 30)
CopyButton.Position = UDim2.new(0, 5, 0, 70)
CopyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.Text = "Copy ID"
CopyButton.Font = Enum.Font.Gotham
CopyButton.TextSize = 14

local CopyUICorner = Instance.new("UICorner", CopyButton)
CopyUICorner.CornerRadius = UDim.new(0, 8)

local selectedAnimId = nil

-- Function to Log Animations
local function logAnimation(animId)
    if animationsLogged[animId] then return end  -- Prevent duplicate logs
    animationsLogged[animId] = true

    local AnimButton = Instance.new("TextButton")
    AnimButton.Parent = ScrollFrame
    AnimButton.Size = UDim2.new(1, -10, 0, 40)
    AnimButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    AnimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AnimButton.Text = "Animation: " .. animId
    AnimButton.Font = Enum.Font.Gotham
    AnimButton.TextSize = 14

    local UICornerButton = Instance.new("UICorner", AnimButton)
    UICornerButton.CornerRadius = UDim.new(0, 8)

    AnimButton.MouseButton1Click:Connect(function()
        selectedAnimId = animId
        PickFrame.Visible = true
    end)
end

-- Play Animation
PlayButton.MouseButton1Click:Connect(function()
    if selectedAnimId and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            local anim = Instance.new("Animation")
            anim.AnimationId = selectedAnimId
            local animTrack = humanoid:LoadAnimation(anim)
            animTrack:Play()
        end
    end
    PickFrame.Visible = false
end)

-- Copy Animation ID
CopyButton.MouseButton1Click:Connect(function()
    if selectedAnimId then
        setclipboard(selectedAnimId)
    end
    PickFrame.Visible = false
end)

-- Detect Animations
local function detectAnimations()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
            if track.Animation then
                logAnimation(track.Animation.AnimationId)
            end
        end
    end

    if #ScrollFrame:GetChildren() == 1 then
        local noAnimLabel = Instance.new("TextLabel")
        noAnimLabel.Parent = ScrollFrame
        noAnimLabel.Size = UDim2.new(1, -10, 0, 40)
        noAnimLabel.BackgroundTransparency = 1
        noAnimLabel.Text = "No Animations :("
        noAnimLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        noAnimLabel.TextSize = 14
        noAnimLabel.Font = Enum.Font.Gotham
    end
end

-- Settings Button
local SettingsButton = Instance.new("ImageButton")
SettingsButton.Parent = MainFrame
SettingsButton.Size = UDim2.new(0, 30, 0, 30)
SettingsButton.Position = UDim2.new(0, 10, 0, 5)
SettingsButton.Image = "rbxthumb://type=Asset&id=6720824672&w=420&h=420"
SettingsButton.BackgroundTransparency = 1

-- Settings GUI
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Parent = ScreenGui
SettingsFrame.Size = UDim2.new(0, 200, 0, 190)
SettingsFrame.Position = UDim2.new(0.5, -355, 0.5, -200)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsFrame.Visible = false

local SettingsUICorner = Instance.new("UICorner", SettingsFrame)
SettingsUICorner.CornerRadius = UDim.new(0, 10)

local SettingsText = Instance.new("TextLabel")
SettingsText.Parent = SettingsFrame
SettingsText.Size = UDim2.new(1, 0, 0, 30)
SettingsText.BackgroundTransparency = 1
SettingsText.Text = "Settings"
SettingsText.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsText.TextSize = 16
SettingsText.Font = Enum.Font.GothamBold

-- Clear All Button
local ClearAllButton = Instance.new("TextButton")
ClearAllButton.Parent = SettingsFrame
ClearAllButton.Size = UDim2.new(1, -10, 0, 30)
ClearAllButton.Position = UDim2.new(0, 5, 0, 40)
ClearAllButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ClearAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearAllButton.Text = "Clear All Animations"
ClearAllButton.Font = Enum.Font.Gotham
ClearAllButton.TextSize = 14

local ClearAllUICorner = Instance.new("UICorner", ClearAllButton)
ClearAllUICorner.CornerRadius = UDim.new(0, 8)

-- Clear All Function
ClearAllButton.MouseButton1Click:Connect(function()
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    animationsLogged = {} -- Reset the logged animations table
end)

-- Log All Animations Toggle
local logAllAnimations = false  -- Default: logs only player's animations

local LogAllButton = Instance.new("TextButton")
LogAllButton.Parent = SettingsFrame
LogAllButton.Size = UDim2.new(1, -10, 0, 30)
LogAllButton.Position = UDim2.new(0, 5, 0, 80)
LogAllButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
LogAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LogAllButton.Text = "Log All Animations: OFF"
LogAllButton.Font = Enum.Font.Gotham
LogAllButton.TextSize = 14

local LogAllUICorner = Instance.new("UICorner", LogAllButton)
LogAllUICorner.CornerRadius = UDim.new(0, 8)

-- Toggle Function
LogAllButton.MouseButton1Click:Connect(function()
    logAllAnimations = not logAllAnimations
    LogAllButton.Text = "Log All Animations: " .. (logAllAnimations and "ON" or "OFF")
end)

-- Updated Detect Animations Function
local function detectAnimations()
    local function logFromCharacter(character)
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                if track.Animation then
                    logAnimation(track.Animation.AnimationId)
                end
            end
        end
    end

    if logAllAnimations then
        -- Log animations from all players and NPCs
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then logFromCharacter(plr.Character) end
        end
        for _, npc in ipairs(workspace:GetDescendants()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
                logFromCharacter(npc)
            end
        end
    else
        -- Log only the local player's animations
        if player.Character then logFromCharacter(player.Character) end
    end
end



-- Toggle Settings UI
local isSettingsOpen = false
SettingsButton.MouseButton1Click:Connect(function()
    isSettingsOpen = not isSettingsOpen
    SettingsFrame.Visible = isSettingsOpen
end)



-- Toggle UI Visibility
local isOpen = false
ToggleButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    MainFrame.Visible = isOpen
    if isOpen then
        detectAnimations()
    end
end)

-- Monitor for New Animations
while true do
    detectAnimations()
    wait(0.5)
end

-- Toggle UI Visibility
local isOpen = false
ToggleButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    MainFrame.Visible = isOpen
end)
