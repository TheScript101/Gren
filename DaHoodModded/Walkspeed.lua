--// Macro Speed Toggle
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local enabled = false
local originalSpeed = nil
local speedConnection = nil

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MacroSpeedGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local button = Instance.new("TextButton")
button.Name = "MacroToggle"
button.Size = UDim2.new(0, 115, 0, 35)
button.Position = UDim2.new(0.5, -57, 0.5, -17)
button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
button.TextColor3 = Color3.new(1, 1, 1)
button.Text = "Macro: OFF"
button.TextSize = 14
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.Active = true
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

--// Dragging (mouse + touch)
local dragging = false
local dragStart
local startPosition
local dragInput

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = button.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input == dragInput
    ) then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

--// Character helpers
local function getHumanoid()
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function stopMacro()
    enabled = false

    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end

    local humanoid = getHumanoid()
    if humanoid and originalSpeed ~= nil then
        humanoid.WalkSpeed = originalSpeed
    end

    originalSpeed = nil
    button.Text = "Macro: OFF"
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
end

local function startMacro()
    local humanoid = getHumanoid()
    if not humanoid then return end

    -- Save the speed only when first enabling
    originalSpeed = humanoid.WalkSpeed
    enabled = true

    button.Text = "Macro: ON"
    button.BackgroundColor3 = Color3.fromRGB(30, 145, 70)

    -- Keep speed at 300 while enabled
    speedConnection = RunService.Heartbeat:Connect(function()
        local currentHumanoid = getHumanoid()
        if enabled and currentHumanoid then
            currentHumanoid.WalkSpeed = 300
        end
    end)
end

button.Activated:Connect(function()
    if enabled then
        stopMacro()
    else
        startMacro()
    end
end)

--// Respawn handling
player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")

    if enabled then
        originalSpeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = 300
    end
end)
