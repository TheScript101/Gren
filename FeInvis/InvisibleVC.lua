-- Cleanup previous instances if re-executed
if _G.a then 
    for _, conn in pairs(_G.a) do 
        if conn then conn:Disconnect() end 
    end 
    _G.a = nil 
end

repeat task.wait() until game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local _LocalPlayer = Players.LocalPlayer
local character, humanoid, rootPart
local isInvis = false
local charParts = {}

-- Character Setup Function
local function setupCharacter()
    character = _LocalPlayer.Character or _LocalPlayer.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    charParts = {}

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(charParts, part)
        end
    end
end

-- Function to Reset Character State back to normal
local function resetCharacterState()
    for _, part in ipairs(charParts) do
        if part and part.Parent then
            part.CanCollide = true
            if part.Name ~= "HumanoidRootPart" then
                part.LocalTransparencyModifier = 0
            end
        end
    end
    if humanoid then
        humanoid.CameraOffset = Vector3.new(0, 0, 0)
    end
end

-- Create GUI
local function createGui()
    local screenGui = Instance.new("ScreenGui")
    local textButton = Instance.new("TextButton")

    screenGui.Name = "RilixInvisGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = _LocalPlayer:WaitForChild("PlayerGui")

    textButton.Size = UDim2.new(0, 100, 0, 50)
    textButton.Position = UDim2.new(0.5, -50, 0.1, 0)
    textButton.Text = "Invisible (VC Works)"
    textButton.BackgroundColor3 = Color3.fromHex("#ff00c8")
    textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    textButton.Parent = screenGui

    -- Dragging Logic
    local dragging = false
    local dragStart, startPos

    textButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = textButton.Position
        end
    end)

    textButton.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            textButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    textButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Toggle Callback
    textButton.MouseButton1Click:Connect(function()
        isInvis = not isInvis
        if not isInvis then
            resetCharacterState()
        end
    end)
end

setupCharacter()
createGui()

-- Connections Storage
local connections = {}

-- Keybind 'G' Toggle
connections[1] = _LocalPlayer:GetMouse().KeyDown:Connect(function(key)
    if key:lower() == "g" then
        isInvis = not isInvis
        if not isInvis then
            resetCharacterState()
        end
    end
end)

-- Underground Loop + Noclip + Transparency
connections[2] = RunService.Heartbeat:Connect(function()
    if isInvis and rootPart and humanoid then
        -- Apply Noclip and 0.6 Transparency
        for _, part in ipairs(charParts) do
            if part and part.Parent then
                part.CanCollide = false
                if part.Name ~= "HumanoidRootPart" then
                    part.LocalTransparencyModifier = 0.6
                end
            end
        end

        -- Frame CFrame manipulation (20 studs underground with compensated camera offset)
        local currentCFrame = rootPart.CFrame
        local originalCameraOffset = humanoid.CameraOffset
        local undergroundCFrame = currentCFrame * CFrame.new(0, -20, 0)
        local relativeOffset = undergroundCFrame:ToObjectSpace(CFrame.new(currentCFrame.Position)).Position

        rootPart.CFrame = undergroundCFrame
        humanoid.CameraOffset = relativeOffset

        RunService.RenderStepped:Wait()

        rootPart.CFrame = currentCFrame
        humanoid.CameraOffset = originalCameraOffset
    end
end)

-- Reset on Character Respawn
_LocalPlayer.CharacterAdded:Connect(function()
    isInvis = false
    setupCharacter()
end)

_G.a = connections
