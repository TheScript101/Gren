--// Mesh Logger - LocalScript
--// Place in StarterPlayerScripts

local EffectsFolder = workspace:WaitForChild("Effects")

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeshLogger"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Main Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.Text = "Mesh Logger"
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = ScreenGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0, 10, 0, 60)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Mesh Logger"
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = MainFrame

-- Settings Button
local SettingsButton = Instance.new("TextButton")
SettingsButton.Size = UDim2.new(0, 80, 0, 30)
SettingsButton.Position = UDim2.new(1, -90, 0, 5)
SettingsButton.Text = "Settings"
SettingsButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
SettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsButton.Parent = MainFrame

-- Scroll List
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.Padding = UDim.new(0, 5)

-- Side Panel
local SidePanel = Instance.new("Frame")
SidePanel.Size = UDim2.new(0, 250, 0, 300)
SidePanel.Position = UDim2.new(0, 320, 0, 60)
SidePanel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SidePanel.Visible = false
SidePanel.Parent = ScreenGui

local CloseSide = Instance.new("TextButton")
CloseSide.Size = UDim2.new(0, 30, 0, 30)
CloseSide.Position = UDim2.new(1, -35, 0, 5)
CloseSide.Text = "X"
CloseSide.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
CloseSide.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseSide.Parent = SidePanel

local SideContent = Instance.new("TextLabel")
SideContent.Size = UDim2.new(1, -10, 1, -40)
SideContent.Position = UDim2.new(0, 5, 0, 40)
SideContent.TextColor3 = Color3.fromRGB(255, 255, 255)
SideContent.BackgroundTransparency = 1
SideContent.TextXAlignment = Enum.TextXAlignment.Left
SideContent.TextYAlignment = Enum.TextYAlignment.Top
SideContent.TextWrapped = true
SideContent.Parent = SidePanel

-- Settings Panel
local SettingsPanel = Instance.new("Frame")
SettingsPanel.Size = UDim2.new(0, 200, 0, 150)
SettingsPanel.Position = UDim2.new(0, 320, 0, 60)
SettingsPanel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SettingsPanel.Visible = false
SettingsPanel.Parent = ScreenGui

local ClearButton = Instance.new("TextButton")
ClearButton.Size = UDim2.new(1, -20, 0, 40)
ClearButton.Position = UDim2.new(0, 10, 0, 10)
ClearButton.Text = "Clear Logged"
ClearButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.Parent = SettingsPanel

local StopToggle = Instance.new("TextButton")
StopToggle.Size = UDim2.new(1, -20, 0, 40)
StopToggle.Position = UDim2.new(0, 10, 0, 60)
StopToggle.Text = "Stop Logging: OFF"
StopToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
StopToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
StopToggle.Parent = SettingsPanel

-- Logging System
local logged = {}
local stopLogging = false

-- Log all existing meshes already in workspace.Effects
for _, child in ipairs(EffectsFolder:GetChildren()) do
    if child:IsA("BasePart") then
        local mesh = child:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            logMesh(child)
        end
    end
end

local function logMesh(meshPart)
    if logged[meshPart] then return end
    logged[meshPart] = true

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 40)
    button.Text = meshPart.Parent.Name
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = ScrollFrame

    button.MouseButton1Click:Connect(function()
        SidePanel.Visible = true

        local weldName = "None"
        for _, child in ipairs(meshPart.Parent:GetChildren()) do
            if child:IsA("Weld") or child:IsA("Motor6D") then
                weldName = child.Part0 and child.Part0.Name or "Unknown"
            end
        end

        local mesh = meshPart:FindFirstChildOfClass("SpecialMesh")

        SideContent.Text =
            "Name: " .. meshPart.Parent.Name .. "\n" ..
            "Rotation: " .. tostring(meshPart.Rotation) .. "\n" ..
            "Welded To: " .. weldName .. "\n" ..
            "Size: " .. tostring(meshPart.Size) .. "\n" ..
            "Mesh ID: " .. (mesh and mesh.MeshId or "None") .. "\n" ..
            "Texture ID: " .. (mesh and mesh.TextureId or "None")
    end)

    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

EffectsFolder.ChildAdded:Connect(function(child)
    if stopLogging then return end

    if child:IsA("BasePart") then
        local mesh = child:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            logMesh(child)
        end
    end
end)

-- Buttons
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

SettingsButton.MouseButton1Click:Connect(function()
    SettingsPanel.Visible = not SettingsPanel.Visible
end)

ClearButton.MouseButton1Click:Connect(function()
    logged = {}
    for _, obj in ipairs(ScrollFrame:GetChildren()) do
        if obj:IsA("TextButton") then obj:Destroy() end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

StopToggle.MouseButton1Click:Connect(function()
    stopLogging = not stopLogging
    StopToggle.Text = "Stop Logging: " .. (stopLogging and "ON" or "OFF")
end)

CloseSide.MouseButton1Click:Connect(function()
    SidePanel.Visible = false
end)
