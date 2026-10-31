-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remotes
local BuildRemote = ReplicatedStorage:WaitForChild("buildRequest")
local ChangeBuildEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ChangeBuildEvent")

-- State Variables
local isBuilding = false
local isPaused = false
local currentBuildTask = nil
local selectedQueue = {}

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoBuildGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 480)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Rounded corners for clean look
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Top Bar / Title
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "  ⚡ Auto Build Pro"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Helper function to style buttons nicely
local function createButton(name, text, color, position, size, parent)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.Position = position
    btn.Size = size
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

-- Control Buttons (Start Green, Pause Yellow, Stop Red)
local StartBtn = createButton("StartBtn", "▶ Auto Build", Color3.fromRGB(46, 204, 113), UDim2.new(0.05, 0, 0.13, 0), UDim2.new(0.9, 0, 0, 38), MainFrame)
local PauseBtn = createButton("PauseBtn", "⏸ Pause", Color3.fromRGB(241, 196, 15), UDim2.new(0.05, 0, 0.235, 0), UDim2.new(0.425, 0, 0, 35), MainFrame)
local StopBtn = createButton("StopBtn", "⏹ Stop", Color3.fromRGB(231, 76, 60), UDim2.new(0.525, 0, 0.235, 0), UDim2.new(0.425, 0, 0, 35), MainFrame)

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 25)
StatusLabel.Position = UDim2.new(0.05, 0, 0.335, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle (No Preset Selected)"
StatusLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 13
StatusLabel.Parent = MainFrame

-- Presets Header
local PresetHeader = Instance.new("TextLabel")
PresetHeader.Size = UDim2.new(0.9, 0, 0, 25)
PresetHeader.Position = UDim2.new(0.05, 0, 0.395, 0)
PresetHeader.BackgroundTransparency = 1
PresetHeader.Text = "Select Build Preset:"
PresetHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
PresetHeader.Font = Enum.Font.GothamBold
PresetHeader.TextSize = 14
PresetHeader.TextXAlignment = Enum.TextXAlignment.Left
PresetHeader.Parent = MainFrame

-- Scrollable Dropdown Container for Presets
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(0.9, 0, 0, 220)
ScrollContainer.Position = UDim2.new(0.05, 0, 0.46, 0)
ScrollContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
ScrollContainer.BorderSizePixel = 0
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 240)
ScrollContainer.ScrollBarThickness = 6
ScrollContainer.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 6)
ScrollCorner.Parent = ScrollContainer

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollContainer

-- Ground Detection Function
local function getGroundPosition()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return Vector3.new(0, 10, 0) end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local raycastResult = workspace:Raycast(rootPart.Position, Vector3.new(0, -100, 0), raycastParams)
    
    if raycastResult then
        return raycastResult.Position + Vector3.new(0, 4, 0)
    else
        return rootPart.Position + Vector3.new(0, 4, 0)
    end
end

-- Remote Wrapper
local function placeBlock(material, position)
    ChangeBuildEvent:FireServer("ChangeBlock", material)
    
    local targetParent = workspace.Map:FindFirstChild("Map") 
        and workspace.Map.Map:FindFirstChild("Terrain8") 
        and workspace.Map.Map.Terrain8:FindFirstChild("Top") 
        or workspace.Terrain

    local args = {
        [1] = "Place",
        [2] = {
            [1] = material,
            [2] = position,
            [3] = targetParent,
            [4] = 0
        }
    }
    BuildRemote:InvokeServer(unpack(args))
end

-- PRESET GENERATORS
local function generateHouse(startPos)
    local queue = {}
    local spacing = 4
    for y = 0, 2 do
        for x = 0, 3 do
            for z = 0, 3 do
                local isWall = (x == 0 or x == 3 or z == 0 or z == 3)
                local isDoor = (x == 1 and z == 0 and (y == 0 or y == 1))
                local isWindow = (y == 1 and (x == 1 or z == 1) and isWall)

                if isWall and not isDoor then
                    table.insert(queue, {material = isWindow and "glass" or "wooden_plank", pos = startPos + Vector3.new(x*spacing, y*spacing, z*spacing)})
                end
            end
        end
    end
    for x = 0, 3 do
        for z = 0, 3 do
            table.insert(queue, {material = "cobblestone", pos = startPos + Vector3.new(x*spacing, 3*spacing, z*spacing)})
        end
    end
    return queue
end

-- CUSTOM MANSION PRESET USING EXACT SPECIFIED BLOCK LIMITS
local function generateMansion(startPos)
    local queue = {}
    local s = 4 -- 4 stud grid spacing

    -- 1. Cobblestone Foundation / Floor Base (Approx 50 blocks)
    for x = 0, 6 do
        for z = 0, 6 do
            table.insert(queue, {material = "cobblestone", pos = startPos + Vector3.new(x*s, 0, z*s)})
        end
    end

    -- 2. Oak Log Pillars / Framework (~48 blocks)
    for y = 1, 4 do
        for _, pos in ipairs({
            Vector3.new(0, y*s, 0), Vector3.new(0, y*s, 6*s),
            Vector3.new(6*s, y*s, 0), Vector3.new(6*s, y*s, 6*s),
            Vector3.new(3*s, y*s, 0), Vector3.new(0, y*s, 3*s)
        }) do
            table.insert(queue, {material = "oak_log", pos = startPos + pos})
        end
    end

    -- 3. Wooden Planks Walls & Rooms (~150 blocks)
    for y = 1, 3 do
        for x = 0, 6 do
            for z = 0, 6 do
                local isOuter = (x == 0 or x == 6 or z == 0 or z == 6)
                if isOuter and y <= 3 then
                    table.insert(queue, {material = "wooden_plank", pos = startPos + Vector3.new(x*s, y*s, z*s)})
                end
            end
        end
    end

    -- 4. Iron Accents & Trim (~20 blocks)
    for x = 1, 5 do
        table.insert(queue, {material = "iron_block", pos = startPos + Vector3.new(x*s, 4*s, 0)})
        table.insert(queue, {material = "iron_block", pos = startPos + Vector3.new(x*s, 4*s, 6*s)})
    end

    -- 5. Glass Windows (~20 blocks)
    for _, p in ipairs({
        Vector3.new(2*s, 2*s, 0), Vector3.new(4*s, 2*s, 0),
        Vector3.new(0, 2*s, 2*s), Vector3.new(0, 2*s, 4*s),
        Vector3.new(6*s, 2*s, 2*s), Vector3.new(6*s, 2*s, 4*s),
        Vector3.new(2*s, 3*s, 0), Vector3.new(4*s, 3*s, 0)
    }) do
        table.insert(queue, {material = "glass", pos = startPos + p})
    end

    -- 6. Ice Features (~28 blocks)
    for x = 1, 3 do
        table.insert(queue, {material = "ice", pos = startPos + Vector3.new(x*s, 1*s, 2*s)})
        table.insert(queue, {material = "ice", pos = startPos + Vector3.new(x*s, 2*s, 2*s)})
    end

    -- 7. Scaffolds (~24 blocks)
    for y = 0, 5 do
        table.insert(queue, {material = "scaffold", pos = startPos + Vector3.new(6*s, y*s, 3*s)})
    end

    -- 8. Obsidian Security Pillars (~15 blocks)
    for y = 1, 3 do
        table.insert(queue, {material = "obsidian", pos = startPos + Vector3.new(3*s, y*s, 3*s)})
    end

    -- 9. Glowstone Lighting (~10 blocks)
    for _, p in ipairs({
        Vector3.new(2*s, 3*s, 2*s), Vector3.new(4*s, 3*s, 4*s),
        Vector3.new(2*s, 3*s, 4*s), Vector3.new(4*s, 3*s, 2*s)
    }) do
        table.insert(queue, {material = "glowstone", pos = startPos + p})
    end

    -- 10. Slime Blocks (~6 blocks)
    for x = 1, 2 do
        table.insert(queue, {material = "slime_block", pos = startPos + Vector3.new(x*s, 0, 3*s)})
    end

    -- 11. Cobwebs (~25 blocks)
    for x = 1, 5 do
        table.insert(queue, {material = "cobweb", pos = startPos + Vector3.new(x*s, 3*s, 1*s)})
    end

    -- 12. Doors (~2 blocks)
    table.insert(queue, {material = "door", pos = startPos + Vector3.new(3*s, 1*s, 0)})
    table.insert(queue, {material = "door", pos = startPos + Vector3.new(3*s, 2*s, 0)})

    return queue
end

local function generateTower(startPos)
    local queue = {}
    local spacing = 4
    for y = 0, 5 do
        for x = 0, 2 do
            for z = 0, 2 do
                local isWall = (x == 0 or x == 2 or z == 0 or z == 2)
                local isWindow = (y >= 1 and y <= 4 and (x == 1 or z == 1) and isWall)
                if isWall then
                    table.insert(queue, {material = isWindow and "glass" or "oak_log", pos = startPos + Vector3.new(x*spacing, y*spacing, z*spacing)})
                end
            end
        end
    end
    return queue
end

local function generatePyramid(startPos)
    local queue = {}
    local spacing = 4
    local size = 5
    for y = 0, size - 1 do
        local layerSize = size - y
        for x = 0, layerSize - 1 do
            for z = 0, layerSize - 1 do
                table.insert(queue, {material = "cobblestone", pos = startPos + Vector3.new(x*spacing, y*spacing, z*spacing)})
            end
        end
    end
    return queue
end

local function generateBridge(startPos)
    local queue = {}
    local spacing = 4
    for x = 0, 5 do
        for z = 0, 1 do
            table.insert(queue, {material = "wooden_plank", pos = startPos + Vector3.new(x*spacing, 0, z*spacing)})
        end
    end
    return queue
end

-- Add Presets to Scroll Container Dropdown (Including Mansion!)
local presets = {
    {name = "🏰 Grand Mansion", func = generateMansion},
    {name = "🏠 Simple House", func = generateHouse},
    {name = "🗼 Watchtower", func = generateTower},
    {name = "🔺 Pyramid", func = generatePyramid},
    {name = "🌉 Small Bridge", func = generateBridge},
}

for _, preset in ipairs(presets) do
    local pBtn = createButton(preset.name, "  " .. preset.name, Color3.fromRGB(45, 45, 55), UDim2.new(0, 0, 0, 0), UDim2.new(0.95, 0, 0, 36), ScrollContainer)
    pBtn.TextXAlignment = Enum.TextXAlignment.Left
    
    pBtn.MouseButton1Click:Connect(function()
        local groundPos = getGroundPosition()
        selectedQueue = preset.func(groundPos)
        StatusLabel.Text = "Loaded: " .. preset.name .. " (" .. #selectedQueue .. " blocks)"
        StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
    end)
end

-- Resize scrolling frame canvas based on items
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, (#presets * 44))

-- Button Interactions
StartBtn.MouseButton1Click:Connect(function()
    if isBuilding then return end
    if #selectedQueue == 0 then
        StatusLabel.Text = "⚠️ Please select a preset first!"
        StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        return
    end

    isBuilding = true
    isPaused = false
    StatusLabel.TextColor3 = Color3.fromRGB(241, 196, 15)

    currentBuildTask = task.spawn(function()
        for i, blockData in ipairs(selectedQueue) do
            while isPaused do
                task.wait(0.1)
            end

            if not isBuilding then break end

            placeBlock(blockData.material, blockData.pos)
            StatusLabel.Text = "Building... (" .. i .. "/" .. #selectedQueue .. ")"
            task.wait(0.25) -- 0.25 seconds interval
        end

        if isBuilding then
            StatusLabel.Text = "✅ Build Complete!"
            StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
        end
        isBuilding = false
    end)
end)

PauseBtn.MouseButton1Click:Connect(function()
    if not isBuilding then return end
    isPaused = not isPaused
    if isPaused then
        StatusLabel.Text = "⏸ Status: Paused"
        PauseBtn.Text = "▶ Resume"
    else
        StatusLabel.Text = "Status: Building..."
        PauseBtn.Text = "⏸ Pause"
    end
end)

StopBtn.MouseButton1Click:Connect(function()
    isBuilding = false
    isPaused = false
    PauseBtn.Text = "⏸ Pause"
    StatusLabel.Text = "⏹ Status: Stopped"
    StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
    if currentBuildTask then
        task.cancel(currentBuildTask)
        currentBuildTask = nil
    end
end)
