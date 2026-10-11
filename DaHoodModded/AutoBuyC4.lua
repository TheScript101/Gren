--// AUTO C4 BUTTON
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local enabled = false

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoC4Gui"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

--// BUTTON
local button = Instance.new("TextButton")
button.Name = "AutoC4Button"
button.Size = UDim2.new(0, 130, 0, 36)
button.Position = UDim2.new(0, 20, 0, 260)
button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
button.TextColor3 = Color3.new(1, 1, 1)
button.Text = "Auto C4: OFF"
button.TextSize = 14
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

--// DRAGGABLE BUTTON (PC + MOBILE)
local UserInputService = game:GetService("UserInputService")

local dragging = false
local dragInput
local dragStart
local startPosition

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

--// INVENTORY SAFETY CHECK
local function hasC4()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local character = LocalPlayer.Character

    if backpack and backpack:FindFirstChild("[C4]") then
        return true
    end

    if character and character:FindFirstChild("[C4]") then
        return true
    end

    return false
end

--// TOGGLE
button.Activated:Connect(function()
    enabled = not enabled
    button.Text = enabled and "Auto C4: ON" or "Auto C4: OFF"
end)

--// SAFE STATUS CHECK
task.spawn(function()
    while gui.Parent do
        if enabled then
            if hasC4() then
                button.Text = "Auto C4: ON (Have C4)"
            else
                button.Text = "Auto C4: ON (No C4)"
                -- Put your authorized purchase interaction here.
            end
        end

        task.wait(0.5)
    end
end)
