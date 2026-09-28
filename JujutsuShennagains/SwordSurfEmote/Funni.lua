local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. UI CREATION & DRAGGING LOGIC
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SurfGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local surfButton = Instance.new("TextButton")
surfButton.Name = "SurfButton"
surfButton.Size = UDim2.new(0, 150, 0, 50)
surfButton.Position = UDim2.new(0.05, 0, 0.4, 0)
surfButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
surfButton.TextColor3 = Color3.fromRGB(255, 255, 255)
surfButton.Text = "Surf"
surfButton.Font = Enum.Font.SourceSansBold
surfButton.TextSize = 20
surfButton.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = surfButton

-- Make the button draggable
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    surfButton.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X, 
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

surfButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = surfButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

surfButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Emote activation on click
surfButton.MouseButton1Click:Connect(function()
    local args = {
        [1] = 4
    }
    
    local emoteRemote = ReplicatedStorage:WaitForChild("Knit")
        :WaitForChild("Knit")
        :WaitForChild("Services")
        :WaitForChild("EmoteService")
        :WaitForChild("RE")
        :WaitForChild("Emote")
        
    emoteRemote:FireServer(unpack(args))
end)

-- ==========================================
-- 2. SWORD CHECK, TPWALK & GRAVITY
-- ==========================================
local tpwalkConnection = nil
local tpwalkSpeed = 0.9
local targetGravity = 72
local isBuffActive = false

local function startTpWalk()
    if tpwalkConnection then 
        tpwalkConnection:Disconnect() 
    end

    tpwalkConnection = RunService.Heartbeat:Connect(function(delta)
        local character = LocalPlayer.Character
        if not character then return end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.MoveDirection.Magnitude > 0 then
            character:TranslateBy(humanoid.MoveDirection * tpwalkSpeed * delta * 10)
        end
    end)
end

local function stopTpWalk()
    if tpwalkConnection then
        tpwalkConnection:Disconnect()
        tpwalkConnection = nil
    end
    Workspace.Gravity = 196.2
end

task.spawn(function()
    while task.wait(0.2) do
        local charFolder = Workspace:FindFirstChild("Characters")
        local myChar = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
        
        local hasSword = myChar and myChar:FindFirstChild("Sword") ~= nil

        if hasSword then
            if not isBuffActive then
                isBuffActive = true
                Workspace.Gravity = targetGravity
                startTpWalk()
            end
        else
            if isBuffActive then
                isBuffActive = false
                stopTpWalk()
            end
        end
    end
end)
