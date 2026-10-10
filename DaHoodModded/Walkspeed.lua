
--// Macro Speed Toggle
--// LocalScript inside StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TARGET_SPEED = 300
local enabled = false
local originalSpeed = nil
local humanoid = nil
local speedConnection = nil
local characterConnection = nil

local ON_COLOR = Color3.fromRGB(35, 145, 70)
local OFF_COLOR = Color3.fromRGB(45, 45, 45)

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MacroSpeedGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local button = Instance.new("TextButton")
button.Name = "MacroToggle"
button.Size = UDim2.fromOffset(115, 35)
button.Position = UDim2.new(0.5, -57, 0.5, -17)
button.BackgroundColor3 = OFF_COLOR
button.TextColor3 = Color3.new(1, 1, 1)
button.Text = "Macro: OFF"
button.TextSize = 14
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.Active = true
button.AutoButtonColor = true
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

--// Draggable button (mouse + touch)
local dragging = false
local dragStart
local startPosition
local dragInput
local moved = false

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        moved = false
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

        if delta.Magnitude > 5 then
            moved = true
        end

        button.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

--// Disconnect speed listener
local function disconnectSpeedListener()
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
end

--// Keep speed at 300 while enabled
local function connectSpeedListener()
    disconnectSpeedListener()

    if not humanoid then
        return
    end

    speedConnection =
        humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if enabled and humanoid and humanoid.Parent
                and humanoid.WalkSpeed ~= TARGET_SPEED then
                humanoid.WalkSpeed = TARGET_SPEED
            end
        end)
end

--// Enable macro
local function enableMacro()
    local character = player.Character
    local currentHumanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if not currentHumanoid then
        return
    end

    humanoid = currentHumanoid
    originalSpeed = humanoid.WalkSpeed
    enabled = true

    button.Text = "Macro: ON"
    button.BackgroundColor3 = ON_COLOR

    connectSpeedListener()
    humanoid.WalkSpeed = TARGET_SPEED
end

--// Disable macro and restore saved speed once
local function disableMacro()
    enabled = false
    disconnectSpeedListener()

    if humanoid and humanoid.Parent and originalSpeed ~= nil then
        humanoid.WalkSpeed = originalSpeed
    end

    originalSpeed = nil
    button.Text = "Macro: OFF"
    button.BackgroundColor3 = OFF_COLOR
end

--// Button toggle
button.Activated:Connect(function()
    -- Ignore clicks that were actually drags
    if moved then
        moved = false
        return
    end

    if enabled then
        disableMacro()
    else
        enableMacro()
    end
end)

--// Respawn handling
characterConnection = player.CharacterAdded:Connect(function(character)
    humanoid = character:WaitForChild("Humanoid")

    if enabled then
        -- Save the new character's normal speed for when macro is disabled
        originalSpeed = humanoid.WalkSpeed

        connectSpeedListener()
        humanoid.WalkSpeed = TARGET_SPEED
    end
end)

--// Clean up if this GUI is removed
gui.Destroying:Connect(function()
    enabled = false
    disconnectSpeedListener()

    if characterConnection then
        characterConnection:Disconnect()
        characterConnection = nil
    end
end)
