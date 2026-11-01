
--==================================================
-- AUTO BUILD PRO - COMBINED EDITION
-- LocalScript
--==================================================

-- SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- SETTINGS
local BUILD_SPEED = 0.001
local GRID = 4
local SAVE_FOLDER = "AutoBuildPro_Saves"
local MAX_RETRY_PASSES = 8
local RETRY_WAIT = 0.1
local SLIDER_RANGE = 25 -- Maximum movement in grid blocks

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

-- Build position is locked when a preset is selected.
local buildAnchor = nil
local previewOffset = Vector3.zero
local previewGui = nil
local previewParts = {}
local previewVisible = false

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

-- Gui Helper
local function createPositionAdjusters(parent, startY, onChanged)
    local offset = Vector3.zero

    local function makeAxis(axis, y)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 35, 0, 28)
        label.Position = UDim2.new(0, 8, 0, y)
        label.BackgroundTransparency = 1
        label.Text = axis
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.Parent = parent

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 55, 0, 28)
        valueLabel.Position = UDim2.new(0, 45, 0, y)
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextColor3 = Color3.fromRGB(190, 190, 200)
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.TextSize = 11
        valueLabel.Parent = parent

        local minus = createButton(
            axis .. "Minus",
            "-4",
            Color3.fromRGB(60, 60, 75),
            UDim2.new(0, 105, 0, y),
            UDim2.new(0, 55, 0, 28),
            parent
        )

        local plus = createButton(
            axis .. "Plus",
            "+4",
            Color3.fromRGB(60, 60, 75),
            UDim2.new(0, 165, 0, y),
            UDim2.new(0, 55, 0, 28),
            parent
        )

        local function update(amount)
            if axis == "X" then
                offset += Vector3.new(amount, 0, 0)
            elseif axis == "Y" then
                offset += Vector3.new(0, amount, 0)
            else
                offset += Vector3.new(0, 0, amount)
            end

            valueLabel.Text = tostring(
                axis == "X" and offset.X
                or axis == "Y" and offset.Y
                or offset.Z
            )

            onChanged(offset)
        end

        minus.MouseButton1Click:Connect(function()
            update(-GRID)
        end)

        plus.MouseButton1Click:Connect(function()
            update(GRID)
        end)
    end

    makeAxis("X", startY)
    makeAxis("Y", startY + 35)
    makeAxis("Z", startY + 70)

    return function()
        return offset
    end
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

-- NEW BUTTONS
local PreviewBtn = createButton(
    "PreviewBtn", "👁 Show Preview",
    Color3.fromRGB(52, 120, 190),
    UDim2.new(0.05, 0, 0.405, 0),
    UDim2.new(0.425, 0, 0, 32),
    MainFrame
)

local ClearAllBtn = createButton(
    "ClearAllBtn", "🗑 Clear All",
    Color3.fromRGB(170, 55, 55),
    UDim2.new(0.525, 0, 0.405, 0),
    UDim2.new(0.425, 0, 0, 32),
    MainFrame
)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 22)
StatusLabel.Position = UDim2.new(0.05, 0, 0.48, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

local PresetHeader = Instance.new("TextLabel")
PresetHeader.Size = UDim2.new(0.9, 0, 0, 22)
PresetHeader.Position = UDim2.new(0.05, 0, 0.535, 0)
PresetHeader.BackgroundTransparency = 1
PresetHeader.Text = "Select Build Preset / My Premades:"
PresetHeader.TextColor3 = Color3.new(1, 1, 1)
PresetHeader.Font = Enum.Font.GothamBold
PresetHeader.TextSize = 12
PresetHeader.TextXAlignment = Enum.TextXAlignment.Left
PresetHeader.Parent = MainFrame

local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(0.9, 0, 0, 165)
ScrollContainer.Position = UDim2.new(0.05, 0, 0.59, 0)
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
local function snapToGrid(position)
    return Vector3.new(
        math.floor(position.X / GRID + 0.5) * GRID,
        math.floor(position.Y / GRID + 0.5) * GRID,
        math.floor(position.Z / GRID + 0.5) * GRID
    )
end

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
-- PREVIEW COLORS
--==================================================

local PreviewColors = {
    oak_log = Color3.fromRGB(105, 70, 40),
    wooden_plank = Color3.fromRGB(181, 139, 91),
    obsidian = Color3.fromRGB(28, 22, 42),
    slime_block = Color3.fromRGB(80, 220, 75),
    cobweb = Color3.fromRGB(180, 180, 185),
    glass = Color3.fromRGB(100, 190, 235),
    cobblestone = Color3.fromRGB(110, 110, 110),
    iron_block = Color3.fromRGB(185, 190, 195),
    ice = Color3.fromRGB(155, 220, 245),
    glowstone = Color3.fromRGB(255, 210, 90),
    scaffold = Color3.fromRGB(190, 155, 90),
    trapdoor = Color3.fromRGB(130, 85, 45),
    door = Color3.fromRGB(130, 85, 45),
}

local function getPreviewColor(material)
    local key = string.lower(tostring(material))
    return PreviewColors[key] or Color3.fromRGB(150, 150, 160)
end

--==================================================
-- PREVIEW PARTS
--==================================================

local function clearPreviewParts()
    for _, part in ipairs(previewParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end

    table.clear(previewParts)
end

local function updatePreviewParts()
    if not previewVisible or not buildAnchor then
        return
    end

    clearPreviewParts()

    for _, blockData in ipairs(selectedQueue) do
        local ghost = Instance.new("Part")
        ghost.Name = "AutoBuild_PreviewBlock"
        ghost.Size = Vector3.new(4, 4, 4)
        ghost.Anchored = true
        ghost.CanCollide = false
        ghost.CanTouch = false
        ghost.CanQuery = false
        ghost.CastShadow = false
        ghost.Material = Enum.Material.SmoothPlastic
        ghost.Transparency = 0.45
        ghost.Color = getPreviewColor(blockData.material)
        ghost.Position = buildAnchor + previewOffset + blockData.pos
        ghost.Parent = workspace

        table.insert(previewParts, ghost)
    end
end

local function closePreview()
    previewVisible = false
    clearPreviewParts()

    if previewGui then
        previewGui:Destroy()
        previewGui = nil
    end

    PreviewBtn.Text = "👁 Show Preview"
end

--==================================================
-- DRAGGABLE AXIS SLIDER
--==================================================

local function createAxisSlider(parent, axisName, yPosition, initialValue, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0.92, 0, 0, 42)
    row.Position = UDim2.new(0.04, 0, 0, yPosition)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local axisLabel = Instance.new("TextLabel")
    axisLabel.Size = UDim2.new(0, 35, 1, 0)
    axisLabel.BackgroundTransparency = 1
    axisLabel.Text = axisName
    axisLabel.TextColor3 = Color3.new(1, 1, 1)
    axisLabel.Font = Enum.Font.GothamBold
    axisLabel.TextSize = 13
    axisLabel.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 48, 1, 0)
    valueLabel.Position = UDim2.new(1, -48, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(190, 190, 200)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 11
    valueLabel.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -95, 0, 8)
    track.Position = UDim2.new(0, 40, 0.5, -4)
    track.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
    track.BorderSizePixel = 0
    track.Active = true
    track.Parent = row

    Instance.new("UICorner", track).CornerRadius =
        UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(16, 16)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Color3.fromRGB(70, 160, 230)
    knob.BorderSizePixel = 0
    knob.Active = true
    knob.Parent = track

    Instance.new("UICorner", knob).CornerRadius =
        UDim.new(1, 0)

    local value = math.clamp(initialValue or 0, -SLIDER_RANGE, SLIDER_RANGE)
    local dragging = false

    local function setValue(newValue)
        value = math.clamp(
            math.floor(newValue + 0.5),
            -SLIDER_RANGE,
            SLIDER_RANGE
        )

        local alpha = (value + SLIDER_RANGE) / (SLIDER_RANGE * 2)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)

        valueLabel.Text = tostring(value * GRID)
        callback(value * GRID)
    end

    local function updateFromInput(input)
        local width = track.AbsoluteSize.X
        if width <= 0 then
            return
        end

        local x = input.Position.X - track.AbsolutePosition.X
        local alpha = math.clamp(x / width, 0, 1)
        local newValue = alpha * (SLIDER_RANGE * 2) - SLIDER_RANGE

        setValue(newValue)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            updateFromInput(input)
        end
    end)

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            updateFromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            updateFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)

    setValue(value)

    return {
        SetValue = setValue
    }
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
-- BUILD OWNERSHIP / CLEAR ALL
--==================================================

local function isOwnedByLocalPlayer(block)
    local creator = block:FindFirstChild("Creator", true)

    if not creator or not creator:IsA("ValueBase") then
        return false
    end

    local creatorValue = tostring(creator.Value)

    return creatorValue == LocalPlayer.Name
        or creatorValue == tostring(LocalPlayer.UserId)
end

ClearAllBtn.MouseButton1Click:Connect(function()
    if isBuilding then
        StatusLabel.Text = "Stop the current build first!"
        StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        return
    end

    local buildingParts = workspace:FindFirstChild("BuildingParts")

    if not buildingParts then
        StatusLabel.Text = "BuildingParts folder not found!"
        StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        return
    end

    local clearing = true

    ClearAllBtn.Text = "🗑 Clearing..."

    task.spawn(function()
        local totalDeleted = 0
        local noProgressPasses = 0

        while clearing do
            local ownedBlocks = {}

            -- Refresh the list each pass.
            for _, block in ipairs(buildingParts:GetChildren()) do
                if isOwnedByLocalPlayer(block) then
                    table.insert(ownedBlocks, block)
                end
            end

            if #ownedBlocks == 0 then
                break
            end

            local beforeCount = #ownedBlocks

            for _, block in ipairs(ownedBlocks) do
                if not clearing then
                    break
                end

                if block and block.Parent then
                    local success, result = pcall(function()
                        return BuildRemote:InvokeServer(
                            "Delete",
                            {block}
                        )
                    end)

                    if success then
                        totalDeleted += 1
                    else
                        warn("Clear All deletion error:", result)
                    end
                end

                StatusLabel.Text =
                    "Clearing... " .. totalDeleted .. " requests sent"

                -- 0.01 second interval between deletion requests.
                task.wait(0.01)
            end

            task.wait(0.15)

            local remaining = 0

            for _, block in ipairs(buildingParts:GetChildren()) do
                if isOwnedByLocalPlayer(block) then
                    remaining += 1
                end
            end

            if remaining == 0 then
                break
            end

            if remaining >= beforeCount then
                noProgressPasses += 1
            else
                noProgressPasses = 0
            end

            -- Avoid an endless loop if the server refuses deletion.
            if noProgressPasses >= 5 then
                break
            end
        end

        ClearAllBtn.Text = "🗑 Clear All"

        local remaining = 0

        for _, block in ipairs(buildingParts:GetChildren()) do
            if isOwnedByLocalPlayer(block) then
                remaining += 1
            end
        end

        if remaining == 0 then
            StatusLabel.Text = "✅ All your builds cleared!"
            StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
        else
            StatusLabel.Text =
                "⚠ " .. remaining .. " blocks could not be deleted"

            StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        end
    end)
end)
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
-- PRESET SELECTION
--==================================================

local function selectPreset(name, func)
    selectedQueue = func()

    -- Lock the location at the moment the preset is selected.
    buildAnchor = snapToGrid(getGroundPosition())
    previewOffset = Vector3.zero

    StatusLabel.Text =
        "Loaded: " .. name ..
        " (" .. #selectedQueue .. " blocks)"

    StatusLabel.TextColor3 =
        Color3.fromRGB(46, 204, 113)

    if previewVisible then
        updatePreviewParts()
    end
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
            selectPreset(name, func)
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
                            selectPreset(fileName, function()
                                return result
                            end)
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
-- REGION SELECTION / DRAGGABLE POSITION CONTROLS
--==================================================

local function openRegionEditor()
    MainFrame.Visible = false

    local char = LocalPlayer.Character
        or LocalPlayer.CharacterAdded:Wait()

    local root = char:FindFirstChild("HumanoidRootPart")

    local spawnPos = root
        and root.Position + Vector3.new(0, 3, 0)
        or Vector3.new(0, 10, 0)

    local regionOffset = Vector3.zero

    local selectPart = Instance.new("Part")
    selectPart.Name = "AutoBuild_SelectionBox"
    selectPart.Size = Vector3.new(12, 12, 12)
    selectPart.Position = spawnPos
    selectPart.Anchored = true
    selectPart.CanCollide = false
    selectPart.CanQuery = false
    selectPart.Transparency = 0.5
    selectPart.Color = Color3.fromRGB(52, 152, 219)
    selectPart.Material = Enum.Material.Neon
    selectPart.Parent = workspace

    local controlGui = Instance.new("ScreenGui")
    controlGui.Name = "SelectionControlGui"
    controlGui.ResetOnSpawn = false
    controlGui.Parent = PlayerGui

    local panel = Instance.new("ScrollingFrame")
    panel.Size = UDim2.new(0, 280, 0, 390)
    panel.Position = UDim2.new(0.5, -140, 0.5, -195)
    panel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    panel.CanvasSize = UDim2.new(0, 0, 0, 430)
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

    local function updateRegionPosition()
        selectPart.Position = spawnPos + regionOffset
    end

local regionOffset = Vector3.zero

local getRegionOffset = createPositionAdjusters(
    panel,
    38,
    function(offset)
        regionOffset = offset
        selectPart.Position = snapToGrid(spawnPos) + regionOffset
    end
    )

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

    -- SIZE X
    local sizeXUp = regionButton(
        "SizeXUp", "Width X +4", 0, 180,
        Color3.fromRGB(70, 50, 90)
    )

    local sizeXDown = regionButton(
        "SizeXDown", "Width X -4", 1, 180,
        Color3.fromRGB(70, 50, 90)
    )

    -- SIZE Y
    local sizeYUp = regionButton(
        "SizeYUp", "Height Y +4", 0, 214,
        Color3.fromRGB(70, 50, 90)
    )

    local sizeYDown = regionButton(
        "SizeYDown", "Height Y -4", 1, 214,
        Color3.fromRGB(70, 50, 90)
    )

    -- SIZE Z
    local sizeZUp = regionButton(
        "SizeZUp", "Depth Z +4", 0, 248,
        Color3.fromRGB(70, 50, 90)
    )

    local sizeZDown = regionButton(
        "SizeZDown", "Depth Z -4", 1, 248,
        Color3.fromRGB(70, 50, 90)
    )

    -- SAVE / CANCEL
    local saveBtn = regionButton(
        "Save", "Save Build", 0, 292,
        Color3.fromRGB(46, 204, 113)
    )

    local backBtn = regionButton(
        "Back", "Cancel", 1, 292,
        Color3.fromRGB(231, 76, 60)
    )

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
-- PREVIEW EDITOR
--==================================================

local function openPreviewEditor()
    if #selectedQueue == 0 or not buildAnchor then
        StatusLabel.Text = "Select a preset first!"
        StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        return
    end

    if previewGui then
        closePreview()
        return
    end

    MainFrame.Visible = false
    previewVisible = true

    previewGui = Instance.new("ScreenGui")
    previewGui.Name = "BuildPreviewControlGui"
    previewGui.ResetOnSpawn = false
    previewGui.Parent = PlayerGui

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 300, 0, 250)
    panel.Position = UDim2.new(0.5, -150, 0.5, -125)
    panel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    panel.BorderSizePixel = 0
    panel.Active = true
    panel.Draggable = true
    panel.Parent = previewGui

    Instance.new("UICorner", panel).CornerRadius =
        UDim.new(0, 8)

    local heading = Instance.new("TextLabel")
    heading.Size = UDim2.new(1, 0, 0, 35)
    heading.BackgroundTransparency = 1
    heading.Text = "👁 Move Build Preview"
    heading.TextColor3 = Color3.new(1, 1, 1)
    heading.Font = Enum.Font.GothamBold
    heading.TextSize = 14
    heading.Parent = panel

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0.9, 0, 0, 25)
    info.Position = UDim2.new(0.05, 0, 0, 32)
    info.BackgroundTransparency = 1
    info.Text = "Drag the sliders to move the build"
    info.TextColor3 = Color3.fromRGB(170, 170, 180)
    info.Font = Enum.Font.Gotham
    info.TextSize = 10
    info.Parent = panel

    createPositionAdjusters(
    panel,
    65,
    function(offset)
        previewOffset = offset
        updatePreviewParts()
    end
    )

    local closeBtn = createButton(
        "ClosePreview",
        "✓ Done",
        Color3.fromRGB(46, 160, 100),
        UDim2.new(0.05, 0, 0, 205),
        UDim2.new(0.9, 0, 0, 32),
        panel
    )

    closeBtn.MouseButton1Click:Connect(function()
        previewGui:Destroy()
        previewGui = nil
        MainFrame.Visible = true
        PreviewBtn.Text = "👁 Show Preview"
    end)

    updatePreviewParts()
    PreviewBtn.Text = "✖ Close Preview"
end

PreviewBtn.MouseButton1Click:Connect(function()
    if previewGui then
        closePreview()
        MainFrame.Visible = true
    else
        openPreviewEditor()
    end
end)

--==================================================
-- FAST BUILD RETRY SYSTEM
--==================================================

local function positionKey(position)
    local x = math.floor(position.X / GRID + 0.5)
    local y = math.floor(position.Y / GRID + 0.5)
    local z = math.floor(position.Z / GRID + 0.5)

    return x .. ":" .. y .. ":" .. z
end

local function getOwnedBuildPositions()
    local occupied = {}

    local buildingParts = workspace:FindFirstChild("BuildingParts")
    if not buildingParts then
        return occupied
    end

    -- Scan the placed build objects once per pass.
    for _, blockObject in ipairs(buildingParts:GetChildren()) do
        if isOwnedByLocalPlayer(blockObject) then
            if blockObject:IsA("BasePart") then
                occupied[positionKey(blockObject.Position)] = true
            end

            for _, descendant in ipairs(blockObject:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    occupied[positionKey(descendant.Position)] = true
                end
            end
        end
    end

    return occupied
end

local function getMissingBlocks(buildQueue)
    local occupied = getOwnedBuildPositions()
    local missing = {}

    for _, blockData in ipairs(buildQueue) do
        if not occupied[positionKey(blockData.pos)] then
            table.insert(missing, blockData)
        end
    end

    return missing
end

local function sortRetryQueue(queue, passNumber)
    local floors = {}

    for _, block in ipairs(queue) do
        local floorY = math.floor(block.pos.Y / GRID + 0.5)

        floors[floorY] = floors[floorY] or {}
        table.insert(floors[floorY], block)
    end

    local floorNumbers = {}

    for floorY in pairs(floors) do
        table.insert(floorNumbers, floorY)
    end

    table.sort(floorNumbers)

    local result = {}

    for _, floorY in ipairs(floorNumbers) do
        local floorBlocks = floors[floorY]

        -- Different random order on every retry.
        for i = #floorBlocks, 2, -1 do
            local j = math.random(1, i)
            floorBlocks[i], floorBlocks[j] =
                floorBlocks[j], floorBlocks[i]
        end

        for _, block in ipairs(floorBlocks) do
            table.insert(result, block)
        end
    end

    for i = 1, #queue do
        queue[i] = result[i]
    end
end

local function waitWhilePaused()
    while isPaused and isBuilding do
        task.wait(0.05)
    end

    return isBuilding
end

local function retryMissingBlocks(finalBuildQueue)
    local noProgressPasses = 0
    local previousMissingCount = #finalBuildQueue

    for pass = 1, MAX_RETRY_PASSES do
        if not waitWhilePaused() then
            return false
        end

        local missing = getMissingBlocks(finalBuildQueue)

        if #missing == 0 then
            return true
        end

        StatusLabel.Text =
            "Retry " .. pass .. " - " ..
            #missing .. " blocks missing..."

        StatusLabel.TextColor3 =
            Color3.fromRGB(241, 196, 15)

        sortRetryQueue(missing, pass)

        -- Retry missing blocks from the bottom floor upward.
        for _, blockData in ipairs(missing) do
            if not waitWhilePaused() then
                return false
            end

            placeBlock(
                blockData.material,
                blockData.pos
            )
        end

        -- Allow server replication before checking the next pass.
        task.wait(RETRY_WAIT)

        local remaining = getMissingBlocks(finalBuildQueue)

        if #remaining == 0 then
            return true
        end

        if #remaining < previousMissingCount then
            noProgressPasses = 0
        else
            noProgressPasses += 1
        end

        previousMissingCount = #remaining

        -- Avoid an endless loop if the server refuses placements.
        if noProgressPasses >= 3 then
            break
        end
    end

    return #getMissingBlocks(finalBuildQueue) == 0
end

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

    if not buildAnchor then
        buildAnchor = snapToGrid(getGroundPosition())
    end

    isBuilding = true
    isPaused = false

    PauseBtn.Text = "⏸ Pause"

    -- Use the locked preview position, not the player's current position.
    local finalBuildQueue = {}

    for _, block in ipairs(selectedQueue) do
        table.insert(finalBuildQueue, {
            material = block.material,
            pos = buildAnchor + previewOffset + block.pos
        })
    end

    StatusLabel.TextColor3 =
        Color3.fromRGB(241, 196, 15)

    currentBuildTask = task.spawn(function()
            -- Sort initial build from bottom to top.
table.sort(finalBuildQueue, function(a, b)
    return a.pos.Y < b.pos.Y
end)

-- Randomize blocks within each floor.
local function randomizeFloors(queue)
    local floors = {}

    for _, block in ipairs(queue) do
        local floorY = math.floor(block.pos.Y / GRID + 0.5)

        floors[floorY] = floors[floorY] or {}
        table.insert(floors[floorY], block)
    end

    local floorNumbers = {}

    for floorY in pairs(floors) do
        table.insert(floorNumbers, floorY)
    end

    table.sort(floorNumbers)

    local result = {}

    for _, floorY in ipairs(floorNumbers) do
        local floorBlocks = floors[floorY]

        -- Shuffle blocks on this floor.
        for i = #floorBlocks, 2, -1 do
            local j = math.random(1, i)
            floorBlocks[i], floorBlocks[j] =
                floorBlocks[j], floorBlocks[i]
        end

        for _, block in ipairs(floorBlocks) do
            table.insert(result, block)
        end
    end

    return result
end

finalBuildQueue = randomizeFloors(finalBuildQueue)
        -- First pass: original queue order and original placement method.
        for i, blockData in ipairs(finalBuildQueue) do
            if not waitWhilePaused() then
                break
            end

            placeBlock(
                blockData.material,
                blockData.pos
            )

            StatusLabel.Text =
                "Building... (" ..
                i .. "/" .. #finalBuildQueue .. ")"

            task.wait(BUILD_SPEED)
        end

        if isBuilding then
            StatusLabel.Text = "Checking for missing blocks..."
            StatusLabel.TextColor3 =
                Color3.fromRGB(241, 196, 15)

            local completed = retryMissingBlocks(finalBuildQueue)

            if isBuilding then
                if completed then
                    StatusLabel.Text = "✅ Build Complete!"
                    StatusLabel.TextColor3 =
                        Color3.fromRGB(46, 204, 113)
                else
                    local remaining = getMissingBlocks(finalBuildQueue)

                    StatusLabel.Text =
                        "⚠ Build finished with " ..
                        #remaining .. " missing blocks"

                    StatusLabel.TextColor3 =
                        Color3.fromRGB(231, 76, 60)
                end
            end
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

    currentBuildTask = nil
end)

print("Auto Build Pro loaded successfully!")
