
--==================================================
-- AUTO BUILD PRO - COMBINED EDITION
-- LocalScript
--==================================================

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- SETTINGS
local BUILD_SPEED = 0.001
local GRID = 4
local SAVE_FOLDER = "AutoBuildPro_Saves"

-- REMOTES
local BuildRemote = ReplicatedStorage:WaitForChild("buildRequest")
local Events = ReplicatedStorage:WaitForChild("Events")
local ChangeBuildEvent = Events:WaitForChild("ChangeBuildEvent")

-- STATE
local isBuilding = false
local isPaused = false
local currentBuildTask = nil
local selectedQueue = {}
local customPresets = {}

--==================================================
-- OPTIONAL FILE SUPPORT
--==================================================

local function fileSupport()
    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(listfiles) == "function"
        and type(makefolder) == "function"
        and type(isfolder) == "function"
end

if fileSupport() then
    pcall(function()
        if not isfolder(SAVE_FOLDER) then
            makefolder(SAVE_FOLDER)
        end
    end)
end

--==================================================
-- GUI
--==================================================

local oldGui = PlayerGui:FindFirstChild("AutoBuildGui")
if oldGui then
    oldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoBuildGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local ToggleGuiBtn = Instance.new("TextButton")
ToggleGuiBtn.Name = "ToggleGuiBtn"
ToggleGuiBtn.Size = UDim2.fromOffset(42, 42)
ToggleGuiBtn.Position = UDim2.fromOffset(10, 10)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
ToggleGuiBtn.Text = "⚙️"
ToggleGuiBtn.TextSize = 20
ToggleGuiBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleGuiBtn.Parent = ScreenGui

Instance.new("UICorner", ToggleGuiBtn).CornerRadius =
    UDim.new(0, 8)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 480)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius =
    UDim.new(0, 10)

ToggleGuiBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

Instance.new("UICorner", TitleBar).CornerRadius =
    UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "  ⚡ Auto Build Pro"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

--==================================================
-- BUTTON CREATOR
--==================================================

local function createButton(name, text, color, position, size, parent)

    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.Position = position
    btn.Size = size
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = parent

    Instance.new("UICorner", btn).CornerRadius =
        UDim.new(0, 6)

    return btn
end

local StartBtn = createButton(
    "StartBtn", "▶ Auto Build",
    Color3.fromRGB(46, 204, 113),
    UDim2.new(0.05, 0, 0.13, 0),
    UDim2.new(0.9, 0, 0, 38),
    MainFrame
)

local PauseBtn = createButton(
    "PauseBtn", "⏸ Pause",
    Color3.fromRGB(241, 196, 15),
    UDim2.new(0.05, 0, 0.235, 0),
    UDim2.new(0.425, 0, 0, 35),
    MainFrame
)

local StopBtn = createButton(
    "StopBtn", "⏹ Stop",
    Color3.fromRGB(231, 76, 60),
    UDim2.new(0.525, 0, 0.235, 0),
    UDim2.new(0.425, 0, 0, 35),
    MainFrame
)

local SaveBuildBtn = createButton(
    "SaveBuildBtn", "💾 Save New Build (Region)",
    Color3.fromRGB(52, 152, 219),
    UDim2.new(0.05, 0, 0.33, 0),
    UDim2.new(0.9, 0, 0, 35),
    MainFrame
)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 22)
StatusLabel.Position = UDim2.new(0.05, 0, 0.41, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

local PresetHeader = Instance.new("TextLabel")
PresetHeader.Size = UDim2.new(0.9, 0, 0, 22)
PresetHeader.Position = UDim2.new(0.05, 0, 0.465, 0)
PresetHeader.BackgroundTransparency = 1
PresetHeader.Text = "Select Build Preset / My Premades:"
PresetHeader.TextColor3 = Color3.new(1, 1, 1)
PresetHeader.Font = Enum.Font.GothamBold
PresetHeader.TextSize = 12
PresetHeader.TextXAlignment = Enum.TextXAlignment.Left
PresetHeader.Parent = MainFrame

local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(0.9, 0, 0, 190)
ScrollContainer.Position = UDim2.new(0.05, 0, 0.52, 0)
ScrollContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
ScrollContainer.BorderSizePixel = 0
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollContainer.ScrollBarThickness = 6
ScrollContainer.Parent = MainFrame

Instance.new("UICorner", ScrollContainer).CornerRadius =
    UDim.new(0, 6)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollContainer

--==================================================
-- POSITION HELPERS
--==================================================

local function getGroundPosition()

    local char = LocalPlayer.Character
        or LocalPlayer.CharacterAdded:Wait()

    local root = char:FindFirstChild("HumanoidRootPart")

    if not root then
        return Vector3.new(0, 10, 0)
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}

    local result = workspace:Raycast(
        root.Position,
        Vector3.new(0, -100, 0),
        params
    )

    if result then
        return result.Position + Vector3.new(0, 4, 0)
    end

    return root.Position + Vector3.new(0, 4, 0)
end

--==================================================
-- BLOCK PLACEMENT
--==================================================

local function getTargetParent()

    local mapFolder = workspace:FindFirstChild("Map")

    if mapFolder then

        local innerMap = mapFolder:FindFirstChild("Map")

        if innerMap then

            local terrain8 = innerMap:FindFirstChild("Terrain8")

            if terrain8 then

                local top = terrain8:FindFirstChild("Top")

                if top then
                    return top
                end
            end
        end
    end

    return workspace.Terrain
end

local function placeBlock(material, position)

    local targetParent = getTargetParent()

    local success, result = pcall(function()

        ChangeBuildEvent:FireServer(
            "ChangeBlock",
            material
        )

        return BuildRemote:InvokeServer(
            "Place",
            {
                material,
                position,
                targetParent,
                0
            }
        )

    end)

    if not success then
        warn("AutoBuild placement error:", result)
        return false
    end

    return true
end

--==================================================
-- PRESET GENERATORS
-- All preset positions are RELATIVE.
--==================================================

local function generateHouse()

    local queue = {}
    local s = GRID

    for y = 0, 2 do
        for x = 0, 3 do
            for z = 0, 3 do

                local wall =
                    x == 0 or x == 3 or z == 0 or z == 3

                local door =
                    x == 1 and z == 0 and y <= 1

                local window =
                    y == 1 and (x == 1 or z == 1) and wall

                if wall and not door then
                    table.insert(queue, {
                        material = window and "glass"
                            or "wooden_plank",

                        pos = Vector3.new(x*s, y*s, z*s)
                    })
                end
            end
        end
    end

    for x = 0, 3 do
        for z = 0, 3 do
            table.insert(queue, {
                material = "cobblestone",
                pos = Vector3.new(x*s, 3*s, z*s)
            })
        end
    end

    return queue
end

local function generateMansion()

    local queue = {}
    local s = GRID

    -- Foundation
    for x = 0, 6 do
        for z = 0, 6 do
            table.insert(queue, {
                material = "cobblestone",
                pos = Vector3.new(x*s, 0, z*s)
            })
        end
    end

    -- Pillars
    for y = 1, 4 do

        for _, p in ipairs({
            Vector3.new(0, y*s, 0),
            Vector3.new(0, y*s, 6*s),
            Vector3.new(6*s, y*s, 0),
            Vector3.new(6*s, y*s, 6*s),
            Vector3.new(3*s, y*s, 0),
            Vector3.new(0, y*s, 3*s)
        }) do

            table.insert(queue, {
                material = "oak_log",
                pos = p
            })
        end
    end

    -- Walls
    for y = 1, 3 do
        for x = 0, 6 do
            for z = 0, 6 do

                local outer =
                    x == 0 or x == 6 or z == 0 or z == 6

                if outer then
                    table.insert(queue, {
                        material = "wooden_plank",
                        pos = Vector3.new(x*s, y*s, z*s)
                    })
                end
            end
        end
    end

    -- Iron trim
    for x = 1, 5 do

        table.insert(queue, {
            material = "iron_block",
            pos = Vector3.new(x*s, 4*s, 0)
        })

        table.insert(queue, {
            material = "iron_block",
            pos = Vector3.new(x*s, 4*s, 6*s)
        })
    end

    -- Windows
    for _, p in ipairs({
        Vector3.new(2*s, 2*s, 0),
        Vector3.new(4*s, 2*s, 0),
        Vector3.new(0, 2*s, 2*s),
        Vector3.new(0, 2*s, 4*s),
        Vector3.new(6*s, 2*s, 2*s),
        Vector3.new(6*s, 2*s, 4*s),
        Vector3.new(2*s, 3*s, 0),
        Vector3.new(4*s, 3*s, 0)
    }) do

        table.insert(queue, {
            material = "glass",
            pos = p
        })
    end

    -- Ice
    for x = 1, 3 do
        for y = 1, 2 do
            table.insert(queue, {
                material = "ice",
                pos = Vector3.new(x*s, y*s, 2*s)
            })
        end
    end

    -- Scaffolding
    for y = 0, 5 do
        table.insert(queue, {
            material = "scaffold",
            pos = Vector3.new(6*s, y*s, 3*s)
        })
    end

    -- Obsidian
    for y = 1, 3 do
        table.insert(queue, {
            material = "obsidian",
            pos = Vector3.new(3*s, y*s, 3*s)
        })
    end

    -- Glowstone
    for _, p in ipairs({
        Vector3.new(2*s, 3*s, 2*s),
        Vector3.new(4*s, 3*s, 4*s),
        Vector3.new(2*s, 3*s, 4*s),
        Vector3.new(4*s, 3*s, 2*s)
    }) do

        table.insert(queue, {
            material = "glowstone",
            pos = p
        })
    end

    -- Slime
    for x = 1, 2 do
        table.insert(queue, {
            material = "slime_block",
            pos = Vector3.new(x*s, 0, 3*s)
        })
    end

    -- Cobwebs
    for x = 1, 5 do
        table.insert(queue, {
            material = "cobweb",
            pos = Vector3.new(x*s, 3*s, s)
        })
    end

    -- Doors
    for y = 1, 2 do
        table.insert(queue, {
            material = "door",
            pos = Vector3.new(3*s, y*s, 0)
        })
    end

    return queue
end

local function generateTower()

    local queue = {}
    local s = GRID

    for y = 0, 5 do
        for x = 0, 2 do
            for z = 0, 2 do

                local wall =
                    x == 0 or x == 2 or z == 0 or z == 2

                local window =
                    y >= 1 and y <= 4
                    and (x == 1 or z == 1)
                    and wall

                if wall then
                    table.insert(queue, {
                        material = window and "glass"
                            or "oak_log",

                        pos = Vector3.new(x*s, y*s, z*s)
                    })
                end
            end
        end
    end

    return queue
end

local function generatePyramid()

    local queue = {}
    local s = GRID
    local size = 5

    for y = 0, size - 1 do

        local layerSize = size - y

        for x = 0, layerSize - 1 do
            for z = 0, layerSize - 1 do

                table.insert(queue, {
                    material = "cobblestone",
                    pos = Vector3.new(x*s, y*s, z*s)
                })
            end
        end
    end

    return queue
end

local function generateBridge()

    local queue = {}
    local s = GRID

    for x = 0, 5 do
        for z = 0, 1 do

            table.insert(queue, {
                material = "wooden_plank",
                pos = Vector3.new(x*s, 0, z*s)
            })
        end
    end

    return queue
end

--==================================================
-- CUSTOM PRESET SERIALIZATION
--==================================================

local function encodeQueue(queue)

    local data = {}

    for _, block in ipairs(queue) do

        table.insert(data, {
            material = block.material,
            x = block.pos.X,
            y = block.pos.Y,
            z = block.pos.Z
        })
    end

    return data
end

local function decodeQueue(data)

    local queue = {}

    for _, block in ipairs(data) do

        if type(block.material) == "string"
            and type(block.x) == "number"
            and type(block.y) == "number"
            and type(block.z) == "number" then

            table.insert(queue, {
                material = block.material,
                pos = Vector3.new(
                    block.x,
                    block.y,
                    block.z
                )
            })
        end
    end

    return queue
end

--==================================================
-- PRESET LIST
--==================================================

local presets = {
    {
        name = "🏠 Simple House",
        func = generateHouse
    }
}

local function refreshPresetsList()

    for _, child in ipairs(ScrollContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local totalItems = 0

    local function addPreset(name, func, color)

        local btn = createButton(
            name,
            "  " .. name,
            color,
            UDim2.new(),
            UDim2.new(0.95, 0, 0, 36),
            ScrollContainer
        )

        btn.LayoutOrder = totalItems
        btn.TextXAlignment = Enum.TextXAlignment.Left

        btn.MouseButton1Click:Connect(function()

            selectedQueue = func()

            StatusLabel.Text =
                "Loaded: " .. name ..
                " (" .. #selectedQueue .. " blocks)"

            StatusLabel.TextColor3 =
                Color3.fromRGB(46, 204, 113)
        end)

        totalItems += 1
    end

    for _, preset in ipairs(presets) do
        addPreset(
            preset.name,
            preset.func,
            Color3.fromRGB(45, 45, 55)
        )
    end

    -- In-memory custom presets
    for name, queue in pairs(customPresets) do

        addPreset(
            name,
            function()
                return queue
            end,
            Color3.fromRGB(50, 45, 65)
        )
    end

    -- File presets
    if fileSupport() then

        local success, files = pcall(function()
            return listfiles(SAVE_FOLDER)
        end)

        if success then

            for _, filePath in ipairs(files) do

                if filePath:sub(-5) == ".json" then

                    local fileName =
                        filePath:match("([^/\\]+)$")
                        :gsub("%.json$", "")

                    local btn = createButton(
                        fileName,
                        "  📂 " .. fileName,
                        Color3.fromRGB(60, 45, 75),
                        UDim2.new(),
                        UDim2.new(0.95, 0, 0, 36),
                        ScrollContainer
                    )

                    btn.LayoutOrder = totalItems
                    btn.TextXAlignment =
                        Enum.TextXAlignment.Left

                    btn.MouseButton1Click:Connect(function()

                        local ok, result = pcall(function()

                            local data =
                                HttpService:JSONDecode(
                                    readfile(filePath)
                                )

                            return decodeQueue(data)
                        end)

                        if ok and result and #result > 0 then

                            selectedQueue = result

                            StatusLabel.Text =
                                "Loaded: " .. fileName ..
                                " (" .. #result .. " blocks)"

                            StatusLabel.TextColor3 =
                                Color3.fromRGB(46, 204, 113)

                        else

                            StatusLabel.Text =
                                "Failed to load preset!"

                            StatusLabel.TextColor3 =
                                Color3.fromRGB(231, 76, 60)
                        end
                    end)

                    totalItems += 1
                end
            end
        end
    end

    ScrollContainer.CanvasSize =
        UDim2.new(0, 0, 0, totalItems * 44)
end

refreshPresetsList()

--==================================================
-- REGION SELECTION / X Y SIZE CONTROLLER
--==================================================

local function openRegionEditor()

    MainFrame.Visible = false

    local char = LocalPlayer.Character
        or LocalPlayer.CharacterAdded:Wait()

    local root = char:FindFirstChild("HumanoidRootPart")

    local spawnPos = root
        and root.Position + Vector3.new(0, 3, 0)
        or Vector3.new(0, 10, 0)

    local selectPart = Instance.new("Part")
    selectPart.Name = "AutoBuild_SelectionBox"
    selectPart.Size = Vector3.new(12, 12, 12)
    selectPart.Position = spawnPos
    selectPart.Anchored = true
    selectPart.CanCollide = false
    selectPart.Transparency = 0.5
    selectPart.Color = Color3.fromRGB(52, 152, 219)
    selectPart.Material = Enum.Material.Neon
    selectPart.Parent = workspace

    local controlGui = Instance.new("ScreenGui")
    controlGui.Name = "SelectionControlGui"
    controlGui.ResetOnSpawn = false
    controlGui.Parent = PlayerGui

    local panel = Instance.new("ScrollingFrame")
    panel.Size = UDim2.new(0, 280, 0, 280)
    panel.Position = UDim2.new(0.5, -140, 0.5, -140)
    panel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    panel.CanvasSize = UDim2.new(0, 0, 0, 340)
    panel.ScrollBarThickness = 4
    panel.Parent = controlGui

    Instance.new("UICorner", panel).CornerRadius =
        UDim.new(0, 8)

    local pTitle = Instance.new("TextLabel")
    pTitle.Size = UDim2.new(1, 0, 0, 30)
    pTitle.BackgroundTransparency = 1
    pTitle.Text = "📐 Adjust Build Region"
    pTitle.TextColor3 = Color3.new(1, 1, 1)
    pTitle.Font = Enum.Font.GothamBold
    pTitle.TextSize = 13
    pTitle.Parent = panel

    local function regionButton(name, text, x, y, color)

        return createButton(
            name,
            text,
            color or Color3.fromRGB(60, 60, 75),
            UDim2.new(0.05 + x * 0.48, 0, 0, y),
            UDim2.new(0.42, 0, 0, 28),
            panel
        )
    end

    -- POSITION
    local moveUp = regionButton(
        "MoveUp", "Move UP Y+", 0, 38
    )

    local moveDown = regionButton(
        "MoveDown", "Move DOWN Y-", 1, 38
    )

    local moveFwd = regionButton(
        "MoveFwd", "Forward Z+", 0, 72
    )

    local moveBck = regionButton(
        "MoveBck", "Back Z-", 1, 72
    )

    local moveRight = regionButton(
        "MoveRight", "Right X+", 0, 106
    )

    local moveLeft = regionButton(
        "MoveLeft", "Left X-", 1, 106
    )

    -- SIZE X
    local sizeXUp = regionButton(
        "SizeXUp", "Width X +4", 0, 149,
        Color3.fromRGB(70, 50, 90)
    )

    local sizeXDown = regionButton(
        "SizeXDown", "Width X -4", 1, 149,
        Color3.fromRGB(70, 50, 90)
    )

    -- SIZE Y
    local sizeYUp = regionButton(
        "SizeYUp", "Height Y +4", 0, 183,
        Color3.fromRGB(70, 50, 90)
    )

    local sizeYDown = regionButton(
        "SizeYDown", "Height Y -4", 1, 183,
        Color3.fromRGB(70, 50, 90)
    )

    -- SIZE Z
    local sizeZUp = regionButton(
        "SizeZUp", "Depth Z +4", 0, 217,
        Color3.fromRGB(70, 50, 90)
    )

    local sizeZDown = regionButton(
        "SizeZDown", "Depth Z -4", 1, 217,
        Color3.fromRGB(70, 50, 90)
    )

    -- SAVE / CANCEL
    local saveBtn = regionButton(
        "Save", "Save Build", 0, 260,
        Color3.fromRGB(46, 204, 113)
    )

    local backBtn = regionButton(
        "Back", "Cancel", 1, 260,
        Color3.fromRGB(231, 76, 60)
    )

    -- Position controls
    moveUp.MouseButton1Click:Connect(function()
        selectPart.Position += Vector3.new(0, 4, 0)
    end)

    moveDown.MouseButton1Click:Connect(function()
        selectPart.Position -= Vector3.new(0, 4, 0)
    end)

    moveFwd.MouseButton1Click:Connect(function()
        selectPart.Position += Vector3.new(0, 0, 4)
    end)

    moveBck.MouseButton1Click:Connect(function()
        selectPart.Position -= Vector3.new(0, 0, 4)
    end)

    moveRight.MouseButton1Click:Connect(function()
        selectPart.Position += Vector3.new(4, 0, 0)
    end)

    moveLeft.MouseButton1Click:Connect(function()
        selectPart.Position -= Vector3.new(4, 0, 0)
    end)

    -- Independent size controls
    sizeXUp.MouseButton1Click:Connect(function()
        selectPart.Size += Vector3.new(4, 0, 0)
    end)

    sizeXDown.MouseButton1Click:Connect(function()
        if selectPart.Size.X > 4 then
            selectPart.Size -= Vector3.new(4, 0, 0)
        end
    end)

    sizeYUp.MouseButton1Click:Connect(function()
        selectPart.Size += Vector3.new(0, 4, 0)
    end)

    sizeYDown.MouseButton1Click:Connect(function()
        if selectPart.Size.Y > 4 then
            selectPart.Size -= Vector3.new(0, 4, 0)
        end
    end)

    sizeZUp.MouseButton1Click:Connect(function()
        selectPart.Size += Vector3.new(0, 0, 4)
    end)

    sizeZDown.MouseButton1Click:Connect(function()
        if selectPart.Size.Z > 4 then
            selectPart.Size -= Vector3.new(0, 0, 4)
        end
    end)

    local function closeEditor()
        selectPart:Destroy()
        controlGui:Destroy()
        MainFrame.Visible = true
    end

    backBtn.MouseButton1Click:Connect(closeEditor)

    saveBtn.MouseButton1Click:Connect(function()

        local scannedQueue = {}

        local minBound =
            selectPart.Position - selectPart.Size / 2

        local maxBound =
            selectPart.Position + selectPart.Size / 2

        for _, obj in ipairs(workspace:GetDescendants()) do

            if obj:IsA("BasePart") and obj ~= selectPart then

                local pos = obj.Position

                if pos.X >= minBound.X
                    and pos.X <= maxBound.X
                    and pos.Y >= minBound.Y
                    and pos.Y <= maxBound.Y
                    and pos.Z >= minBound.Z
                    and pos.Z <= maxBound.Z then

                    local materialName = "wooden_plank"

                    local realName = obj:FindFirstChild("RealName")

                    if realName and realName:IsA("ValueBase") then
                        materialName = tostring(realName.Value)
                    elseif obj.Name ~= "" then
                        materialName = obj.Name
                    end

                    local relativePos =
                        pos - selectPart.Position

                    table.insert(scannedQueue, {
                        material = materialName,
                        pos = relativePos
                    })
                end
            end
        end

        if #scannedQueue == 0 then

            StatusLabel.Text = "No blocks found in region!"
            StatusLabel.TextColor3 =
                Color3.fromRGB(231, 76, 60)

            return
        end

        local presetName =
            "CustomBuild_" .. tostring(os.time() % 10000)

        customPresets[presetName] = scannedQueue

        local fileSaved = false

        if fileSupport() then

            local success = pcall(function()

                local path =
                    SAVE_FOLDER .. "/" .. presetName .. ".json"

                writefile(
                    path,
                    HttpService:JSONEncode(
                        encodeQueue(scannedQueue)
                    )
                )
            end)

            fileSaved = success
        end

        closeEditor()
        refreshPresetsList()

        StatusLabel.Text =
            "Saved " .. #scannedQueue ..
            " blocks: " .. presetName ..
            (fileSaved and " (File saved)" or " (Session only)")

        StatusLabel.TextColor3 =
            Color3.fromRGB(46, 204, 113)
    end)
end

SaveBuildBtn.MouseButton1Click:Connect(openRegionEditor)

--==================================================
-- AUTO BUILD
--==================================================

StartBtn.MouseButton1Click:Connect(function()

    if isBuilding then
        return
    end

    if #selectedQueue == 0 then

        StatusLabel.Text = "Please select a preset first!"
        StatusLabel.TextColor3 =
            Color3.fromRGB(231, 76, 60)

        return
    end

    isBuilding = true
    isPaused = false

    PauseBtn.Text = "⏸ Pause"

    local groundPos = getGroundPosition()

    -- Convert relative positions to world positions ONCE.
    local finalBuildQueue = {}

    for _, block in ipairs(selectedQueue) do

        table.insert(finalBuildQueue, {
            material = block.material,
            pos = groundPos + block.pos
        })
    end

    StatusLabel.TextColor3 =
        Color3.fromRGB(241, 196, 15)

    currentBuildTask = task.spawn(function()

        for i, blockData in ipairs(finalBuildQueue) do

            while isPaused and isBuilding do
                task.wait(0.05)
            end

            if not isBuilding then
                break
            end

            local success = placeBlock(
                blockData.material,
                blockData.pos
            )

            if not success then

                StatusLabel.Text =
                    "Placement failed at block " .. i

                StatusLabel.TextColor3 =
                    Color3.fromRGB(231, 76, 60)

                break
            end

            StatusLabel.Text =
                "Building... (" ..
                i .. "/" .. #finalBuildQueue .. ")"

            -- Requested build speed
            task.wait(0.001)
        end

        if isBuilding then

            StatusLabel.Text = "✅ Build Complete!"
            StatusLabel.TextColor3 =
                Color3.fromRGB(46, 204, 113)
        end

        isBuilding = false
        isPaused = false
        currentBuildTask = nil

        PauseBtn.Text = "⏸ Pause"
    end)
end)

--==================================================
-- PAUSE / RESUME
--==================================================

PauseBtn.MouseButton1Click:Connect(function()

    if not isBuilding then
        return
    end

    isPaused = not isPaused

    if isPaused then

        StatusLabel.Text = "⏸ Status: Paused"
        PauseBtn.Text = "▶ Resume"

    else

        StatusLabel.Text = "Status: Building..."
        PauseBtn.Text = "⏸ Pause"
    end
end)

--==================================================
-- STOP
--==================================================

StopBtn.MouseButton1Click:Connect(function()

    isBuilding = false
    isPaused = false

    PauseBtn.Text = "⏸ Pause"

    StatusLabel.Text = "⏹ Status: Stopped"
    StatusLabel.TextColor3 =
        Color3.fromRGB(231, 76, 60)

    -- Let the running task exit cleanly.
    currentBuildTask = nil
end)

print("Auto Build Pro loaded successfully!")
