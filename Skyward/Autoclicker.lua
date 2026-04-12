local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local autoClickSpeed = 1 / 50
local autoClickEnabled = true
local shiftPressed = false
local notifications = {}
local BASE_Y = 0.75
local Keybind = Enum.KeyCode.Q

local ScreenGui = Instance.new("ScreenGui")

task.spawn(function()
    task.wait(0.5)
    if not shiftPressed then
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, nil)
        task.wait(0.1)
        vim:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, nil)
        shiftPressed = true
    end
end)

local function startRainbowText(textObject, speed)
    speed = speed or 0.6

    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 127, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(139, 0, 255)
    }

    task.spawn(function()
        local i = 1
        while textObject and textObject.Parent do
            local tween = TweenService:Create(
                textObject,
                TweenInfo.new(speed, Enum.EasingStyle.Linear),
                { TextColor3 = colors[i] }
            )
            tween:Play()
            tween.Completed:Wait()
            i += 1
            if i > #colors then i = 1 end
        end
    end)
end

local function autoClickLoop()
    while true do
        if autoClickEnabled then
            local character = player.Character
            if character then
                local tool = character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    tool:Activate()
                end
            end
        end
        task.wait(autoClickSpeed)
    end
end

local function updateNotificationPositions()
    for i, notif in ipairs(notifications) do
        local targetPos = UDim2.new(1, -280, BASE_Y - ((i - 1) * 0.12), 0)
        TweenService:Create(
            notif,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Position = targetPos }
        ):Play()
    end
end

local function createNotification(title, text, duration)
    duration = duration or 4

    local notif = Instance.new("Frame")
    notif.Parent = ScreenGui
    notif.Size = UDim2.new(0, 260, 0, 80)
    notif.Position = UDim2.new(1, 20, BASE_Y, 0) -- start offscreen
    notif.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    notif.ZIndex = 20

    local corner = Instance.new("UICorner", notif)
    corner.CornerRadius = UDim.new(0, 10)

    local titleLabel = Instance.new("TextLabel", notif)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
    titleLabel.Size = UDim2.new(0.9, 0, 0.35, 0)
    titleLabel.Font = Enum.Font.Arcade
    titleLabel.Text = title
    titleLabel.TextScaled = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    startRainbowText(titleLabel, 0.4)

    local body = Instance.new("TextLabel", notif)
    body.BackgroundTransparency = 1
    body.Position = UDim2.new(0.05, 0, 0.5, 0)
    body.Size = UDim2.new(0.9, 0, 0.4, 0)
    body.Font = Enum.Font.Arcade
    body.Text = text
    body.TextScaled = true
    body.TextWrapped = true
    body.TextColor3 = Color3.fromRGB(255, 255, 255)
    body.TextXAlignment = Enum.TextXAlignment.Left

    table.insert(notifications, notif)

    -- move everything into correct positions at once
    updateNotificationPositions()

    -- remove after duration
    task.delay(duration, function()
        local out = TweenService:Create(
            notif,
            TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            { Position = UDim2.new(1, 20, notif.Position.Y.Scale, 0) }
        )
        out:Play()
        out.Completed:Wait()

        for i, n in ipairs(notifications) do
            if n == notif then
                table.remove(notifications, i)
                break
            end
        end

        notif:Destroy()
        updateNotificationPositions()
    end)
end

for _, gui in ipairs(game.CoreGui:GetChildren()) do
    if gui ~= ScreenGui and gui:IsA("ScreenGui") and gui.Name == "Autoclicker" then
        gui:Destroy()
        createNotification("Instance Deleted", "Found another Autoclicker instance and deleted it. Your auto clicker may be faster tho.", 5)
    end
end

local OpenButton = Instance.new("TextButton")
local MainFrame = Instance.new("Frame")
local UICornerFrame = Instance.new("UICorner")
local CloseButton = Instance.new("TextButton")
local SpeedBox = Instance.new("TextBox")
local UICornerSpeedBox = Instance.new("UICorner")
local ApplyButton = Instance.new("TextButton")
local UICornerApplyButton = Instance.new("UICorner")
local TitleLabel = Instance.new("TextLabel")
local SpeedLabel = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local UICornerToggle = Instance.new("UICorner")
local VersionLabel = Instance.new("TextLabel")
local KeybindButton = Instance.new("TextButton")
local UICornerKeybind = Instance.new("UICorner")
local KeybindFrame = Instance.new("Frame")
local UICornerKeybindFrame = Instance.new("UICorner")
local KeybindClose = Instance.new("TextButton")
local UICornerKeybindClose = Instance.new("UICorner")
local KeybindFrameButton = Instance.new("TextButton")
local UICornerKeybindFrameButton = Instance.new("UICorner")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "Autoclicker"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

OpenButton.Parent = ScreenGui
OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenButton.Position = UDim2.new(0, 10, 0.5, 0)
OpenButton.Size = UDim2.new(0, 120, 0, 50)
OpenButton.Font = Enum.Font.Arcade
OpenButton.Text = "Autoclicker MODDED"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextScaled = true
OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
end)

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 375, 0, 300)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

UICornerFrame.Parent = MainFrame
UICornerFrame.CornerRadius = UDim.new(0, 10)

CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Position = UDim2.new(0.88, 0, 0.05, 0)
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Font = Enum.Font.Arcade
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextScaled = true
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(0, 200, 0, 30)
TitleLabel.Font = Enum.Font.Arcade
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "Settings"
TitleLabel.TextScaled = true

VersionLabel.Parent = MainFrame
VersionLabel.BackgroundTransparency = 1
VersionLabel.Position = UDim2.new(0.45, 0, 0, 0)
VersionLabel.Size = UDim2.new(0.4, 0, 0, 30)
VersionLabel.Font = Enum.Font.Arcade
VersionLabel.Text = "v1.0.2"
VersionLabel.TextScaled = true
VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
startRainbowText(VersionLabel, 0.5)

SpeedBox.Parent = MainFrame
SpeedBox.ClearTextOnFocus = false
SpeedBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedBox.Position = UDim2.new(0.1, 0, 0.22, 0)
SpeedBox.Size = UDim2.new(0, 200, 0, 30)
SpeedBox.Font = Enum.Font.Arcade
SpeedBox.Text = "50"
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.TextScaled = true
UICornerSpeedBox.Parent = SpeedBox
UICornerSpeedBox.CornerRadius = UDim.new(0, 8)

ApplyButton.Parent = MainFrame
ApplyButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
ApplyButton.Position = UDim2.new(0.1, 0, 0.45, 0)
ApplyButton.Size = UDim2.new(0, 200, 0, 30)
ApplyButton.Font = Enum.Font.Arcade
ApplyButton.Text = "Apply Speed"
ApplyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ApplyButton.TextScaled = true
UICornerApplyButton.Parent = ApplyButton
UICornerApplyButton.CornerRadius = UDim.new(0, 8)

ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
ToggleButton.Position = UDim2.new(0.1, 0, 0.7, 0)
ToggleButton.Size = UDim2.new(0, 200, 0, 30)
ToggleButton.Font = Enum.Font.Arcade
ToggleButton.Text = "Autoclick: ON"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
UICornerToggle.Parent = ToggleButton
UICornerToggle.CornerRadius = UDim.new(0, 8)

SpeedLabel.Parent = MainFrame
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0.1, 0, 0.89, 0)
SpeedLabel.Size = UDim2.new(0, 200, 0, 20)
SpeedLabel.Font = Enum.Font.Arcade
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Text = "Current speed: 50"
SpeedLabel.TextScaled = true

KeybindButton.Parent = MainFrame
KeybindButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
KeybindButton.Position = UDim2.new(0.65, 0, 0.22, 0)
KeybindButton.Size = UDim2.new(0, 100, 0, 30)
KeybindButton.Font = Enum.Font.Arcade
KeybindButton.Text = "Keybind: Q"
KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
KeybindButton.TextScaled = true
KeybindButton.Visible = UserInputService.KeyboardEnabled == true
UICornerKeybind.Parent = KeybindButton
UICornerKeybind.CornerRadius = UDim.new(0, 8)

KeybindFrame.Parent = MainFrame
KeybindFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
KeybindFrame.Position = UDim2.new(0.65, 0, 0.45, 0)
KeybindFrame.Size = UDim2.new(0, 195, 0, 60)
KeybindFrame.Visible = false
KeybindFrame.Active = true
KeybindFrame.Draggable = true
UICornerKeybindFrame.Parent = KeybindFrame
UICornerKeybindFrame.CornerRadius = UDim.new(0, 8)

KeybindClose.Parent = KeybindFrame
KeybindClose.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
KeybindClose.Position = UDim2.new(0.75, 0, 0, 0)
KeybindClose.Size = UDim2.new(0, 25, 0, 25)
KeybindClose.Font = Enum.Font.Arcade
KeybindClose.Text = "X"
KeybindClose.TextColor3 = Color3.fromRGB(255, 255, 255)
KeybindClose.TextScaled = true
KeybindClose.MouseButton1Click:Connect(function()
    KeybindFrame.Visible = false
end)
UICornerKeybindClose.Parent = KeybindClose
UICornerKeybindClose.CornerRadius = UDim.new(0, 8)

KeybindFrameButton.Parent = KeybindFrame
KeybindFrameButton.AnchorPoint = Vector2.new(0.5, 0.5)
KeybindFrameButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
KeybindFrameButton.Position = UDim2.new(0.5, 0, 0.5, 0)
KeybindFrameButton.Size = UDim2.new(0, 100, 0, 30)
KeybindFrameButton.Font = Enum.Font.Arcade
KeybindFrameButton.Text = "Q"
KeybindFrameButton.TextColor3 = Color3.fromRGB(255, 255, 255)
KeybindFrameButton.TextScaled = true
UICornerKeybindFrameButton.Parent = KeybindFrameButton
UICornerKeybindFrameButton.CornerRadius = UDim.new(0, 8)

task.spawn(autoClickLoop)

ApplyButton.MouseButton1Click:Connect(function()
    local newSpeed = tonumber(SpeedBox.Text)
    if newSpeed and newSpeed > 0 then
        autoClickSpeed = 1 / newSpeed
        SpeedLabel.Text = "Current speed: " .. newSpeed
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    autoClickEnabled = not autoClickEnabled
    ToggleButton.Text = autoClickEnabled and "Autoclick: ON" or "Autoclick: OFF"
    if autoClickEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(208, 0, 0)
    end
end)
KeybindButton.MouseButton1Click:Connect(function()
    KeybindFrame.Visible = true
end)

KeybindFrameButton.MouseButton1Click:Connect(function()
    KeybindFrameButton.Text = "Press a Key"
    local inputEvent
    inputEvent = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
            Keybind = input.KeyCode
            KeybindFrameButton.Text = Keybind.Name
            KeybindButton.Text = "Keybind: " .. Keybind.Name
            Keybind = input.KeyCode
            KeybindFrameButton.Text = Keybind.Name
            KeybindButton.Text = "Keybind: " .. Keybind.Name
            inputEvent:Disconnect()
        end
    end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    if input.KeyCode == Keybind then
        autoClickEnabled = not autoClickEnabled
        ToggleButton.Text = autoClickEnabled and "Autoclick: ON" or "Autoclick: OFF"
        ToggleButton.BackgroundColor3 = autoClickEnabled and Color3.fromRGB(70, 130, 180) or Color3.fromRGB(208, 0, 0)
    end
end)

player.CharacterAdded:Connect(function()
    autoClickEnabled = true
end)

if player.UserId ~= 2234103132 or player.Name ~= "littledgarjr1" or player.Name == "himegoodandipoop5" or player.Name == "Funniguyforyou" then
    createNotification("Script Loaded", "Made by Felipe, Modded by Hime!", 5)
elseif player.UserId == 2234103132 then
    createNotification("Script Loaded", "Hello, Creator. Have fun using your script!", 5)
else
    createNotification("Script Loaded", "Hello, Developer! Enjoy using this script!", 5)
end
createNotification("Tips", "Speed 50 is best for not getting detected, 100 is for tryharding.", 5.2)
