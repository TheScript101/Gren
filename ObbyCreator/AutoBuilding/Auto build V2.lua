--========================================================--
-- AUTO BUILDER PRO - FULL REWRITE
--========================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

local Events = ReplicatedStorage:WaitForChild("Events")
local AddObjectRemote = Events:WaitForChild("AddObject")
local MoveObjectRemote = Events:WaitForChild("MoveObject")

local cancelBuild = false
local cancelLoad = false
local savedBuild = nil

-- selection state
local selectedParts = {}      -- [BasePart] = true
local highlights = {}         -- [BasePart] = Highlight
local multiSelectEnabled = false
local selectionBoxMode = false

-- long press
local multiSelectPressStart = nil
local LONG_PRESS_TIME = 5

-- retry load
local failedIndices = {}

--========================================================--
-- SPECIAL PARTS / TYPE DETECTION
--========================================================--

local specialFunctional = {
    ["Lava"] = true,
    ["Checkpoint"] = true,
    ["Conveyor"] = true,
    ["Fading Part"] = true,
    ["Trip Part"] = true,
    ["Timed Part"] = true,
    ["Timed Lava"] = true,
    ["Speed Pad"] = true,
    ["Seat"] = true,
    ["Respawn Part"] = true,
    ["Reset Part"] = true,
    ["Quiz Part"] = true,
    ["Teleport Pad"] = true,
    ["Jump Pad"] = true,
    ["Heal Part"] = true,
    ["Global Properties Part"] = true,

    ["Gear Part"] = true,
    ["Gear Remover"] = true,
    ["Pressure Plate"] = true,
    ["Button"] = true,
    ["Button Deactivator"] = true,

    ["Push Block"] = true,
    ["Lava Push Block"] = true,

    ["Moving Conveyor"] = true,
    ["Moving Fading Part"] = true,
    ["Moving Lava"] = true,
    ["Moving Timed Part"] = true,
    ["Moving Trip Part"] = true,
    ["Moving Part"] = true,

    ["Mannequin"] = true,
    ["Character Model"] = true,

    ["Spin Conveyor"] = true,
    ["Spin Fading Part"] = true,
    ["Spin Lava"] = true,
    ["Spin Part"] = true,
    ["Spin Timed Part"] = true,
    ["Spin Trip Part"] = true
}

local function detectRealPushShape(part)
    local size = part.Size

    if math.abs(size.X - size.Y) < 0.01 and math.abs(size.Y - size.Z) < 0.01 then
        return "Push Ball"
    end

    if math.abs(size.X - size.Z) < 0.01 and math.abs(size.Y - size.X) > 0.01 then
        return "Push Cylinder"
    end

    if part:IsA("WedgePart") then
        return "Push Wedge"
    end

    if part:IsA("CornerWedgePart") then
        return "Push Corner Wedge"
    end

    return "Push Block"
end

local function detectPartType(part)
    local name = part.Name

    local specialShapes = {
        ["3 Point Pyramid"] = true,
        ["Cone"] = true,
        ["Half Ball"] = true,
        ["Half Cylinder"] = true,
        ["Half Hollow Cylinder"] = true,
        ["Head"] = true,
        ["Hole"] = true,
        ["Hollow Cylinder"] = true,
        ["Pyramid"] = true,
        ["Ramp"] = true,
        ["Star"] = true,
        ["Torus"] = true
    }

    if specialShapes[name] then
        return name
    end

    if name == "Push Block" then
        return detectRealPushShape(part)
    end

    if specialFunctional[name] then
        return name
    end

    if part:IsA("Part") then
        if part.Shape == Enum.PartType.Ball then return "Ball" end
        if part.Shape == Enum.PartType.Cylinder then return "Cylinder" end
        if part.Shape == Enum.PartType.Wedge then return "Wedge" end
        return "Part"
    end

    return "Part"
end

local function extractBehaviors(part)
    local behaviors = {}
    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("BoolValue") or child:IsA("NumberValue") or child:IsA("StringValue") or child:IsA("Vector3Value") then
            behaviors[child.Name] = child.Value
        end
    end
    return behaviors
end

--========================================================--
-- PLAYER ITEMS / EXCLUSIONS
--========================================================--

local function getItemsFolder()
    local obbies = workspace:FindFirstChild("Obbies")
    if not obbies then return nil end

    local playerFolder = obbies:FindFirstChild(LocalPlayer.Name)
    if not playerFolder then return nil end

    return playerFolder:FindFirstChild("Items")
end

local function isInMusicZones(part)
    local parent = part.Parent
    while parent do
        if parent.Name == "Music Zones" then
            return true
        end
        parent = parent.Parent
    end
    return false
end

local function isExcludedPart(part)
    if isInMusicZones(part) then
        return true
    end

    local n = part.Name
    if n == "Music Zone" or n == "Advanced Tools Part" or n == "Music Part" then
        return true
    end

    return false
end

local function isValidItemPart(part)
    if not part:IsA("BasePart") then return false end
    if isExcludedPart(part) then return false end

    local items = getItemsFolder()
    if not items then return false end

    local parent = part.Parent
    while parent do
        if parent == items then
            return true
        end
        parent = parent.Parent
    end

    return false
end

--========================================================--
-- GHOST PREVIEW
--========================================================--

local ghostModel = nil
local ghostConnection = nil
local previewEnabled = false
local ghostOffsetCF = CFrame.new(0, 0, -5)

local function destroyGhost()
    if ghostConnection then
        ghostConnection:Disconnect()
        ghostConnection = nil
    end
    if ghostModel then
        ghostModel:Destroy()
        ghostModel = nil
    end
end

local function startGhostFollow()
    if ghostConnection then
        ghostConnection:Disconnect()
        ghostConnection = nil
    end

    ghostConnection = RunService.RenderStepped:Connect(function()
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        if hrp and ghostModel and ghostModel.PrimaryPart then
            ghostModel:SetPrimaryPartCFrame(hrp.CFrame * ghostOffsetCF)
        end
    end)
end

local function createGhost(model)
    destroyGhost()

    ghostModel = model:Clone()
    ghostModel.Parent = workspace

    for _, p in ipairs(ghostModel:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Transparency = 0.4
            p.Material = Enum.Material.Plastic
            p.CanCollide = false
            p.Anchored = true
            p:SetAttribute("IsGhost", true)
        end
    end

    ghostOffsetCF = CFrame.new(0, 0, -5)
    startGhostFollow()
    return ghostModel
end

--========================================================--
-- GUI SETUP
--========================================================--

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoBuilderUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 280)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextColor3 = Color3.fromRGB(240,240,240)
title.Text = "Auto Builder Pro"

local tabScroll = Instance.new("ScrollingFrame", mainFrame)
tabScroll.Size = UDim2.new(1, -20, 0, 36)
tabScroll.Position = UDim2.new(0, 10, 0, 48)
tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
tabScroll.ScrollBarThickness = 4
tabScroll.BackgroundTransparency = 1

local tabLayout = Instance.new("UIListLayout", tabScroll)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Text = name
    btn.Parent = tabScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local buildTabBtn = createTabButton("Build")
local previewTabBtn = createTabButton("Preview")
local loadingTabBtn = createTabButton("Loading")

tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    tabScroll.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X + 10, 0, 0)
end)

local function createTabPage()
    local page = Instance.new("Frame", mainFrame)
    page.Size = UDim2.new(1, -20, 1, -100)
    page.Position = UDim2.new(0, 10, 0, 90)
    page.BackgroundTransparency = 1
    page.Visible = false
    return page
end

local buildPage = createTabPage()
local previewPage = createTabPage()
local loadingPage = createTabPage()

local function showTab(tab)
    buildPage.Visible = false
    previewPage.Visible = false
    loadingPage.Visible = false
    tab.Visible = true
end

buildTabBtn.MouseButton1Click:Connect(function() showTab(buildPage) end)
previewTabBtn.MouseButton1Click:Connect(function() showTab(previewPage) end)
loadingTabBtn.MouseButton1Click:Connect(function() showTab(loadingPage) end)

showTab(buildPage)

--========================================================--
-- BUILD TAB
--========================================================--

local idLabel = Instance.new("TextLabel", buildPage)
idLabel.Size = UDim2.new(1, -20, 0, 20)
idLabel.Position = UDim2.new(0, 10, 0, 0)
idLabel.BackgroundTransparency = 1
idLabel.Font = Enum.Font.Gotham
idLabel.TextSize = 14
idLabel.TextColor3 = Color3.fromRGB(200,200,200)
idLabel.Text = "Model ID:"

local idBox = Instance.new("TextBox", buildPage)
idBox.Size = UDim2.new(1, -20, 0, 32)
idBox.Position = UDim2.new(0, 10, 0, 24)
idBox.PlaceholderText = "Enter Model ID"
idBox.Font = Enum.Font.Gotham
idBox.TextSize = 14
idBox.TextColor3 = Color3.fromRGB(240,240,240)
idBox.BackgroundColor3 = Color3.fromRGB(40,40,45)
Instance.new("UICorner", idBox).CornerRadius = UDim.new(0, 6)

local buildBtn = Instance.new("TextButton", buildPage)
buildBtn.Size = UDim2.new(0.48, -10, 0, 36)
buildBtn.Position = UDim2.new(0, 10, 0, 70)
buildBtn.Text = "Build"
buildBtn.Font = Enum.Font.GothamBold
buildBtn.TextSize = 15
buildBtn.BackgroundColor3 = Color3.fromRGB(60,160,70)
buildBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", buildBtn).CornerRadius = UDim.new(0, 6)

local cancelBtn = Instance.new("TextButton", buildPage)
cancelBtn.Size = UDim2.new(0.48, -10, 0, 36)
cancelBtn.Position = UDim2.new(0.52, 0, 0, 70)
cancelBtn.Text = "Cancel"
cancelBtn.Font = Enum.Font.GothamBold
cancelBtn.TextSize = 15
cancelBtn.BackgroundColor3 = Color3.fromRGB(180,60,60)
cancelBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel", buildPage)
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 120)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13
statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
statusLabel.Text = "Waiting..."

--========================================================--
-- PREVIEW TAB
--========================================================--

local previewLabel = Instance.new("TextLabel", previewPage)
previewLabel.Size = UDim2.new(1, -20, 0, 20)
previewLabel.Position = UDim2.new(0, 10, 0, 0)
previewLabel.BackgroundTransparency = 1
previewLabel.Font = Enum.Font.GothamBold
previewLabel.TextSize = 15
previewLabel.TextColor3 = Color3.fromRGB(220,220,220)
previewLabel.Text = "Ghost Preview"

local previewToggle = Instance.new("TextButton", previewPage)
previewToggle.Size = UDim2.new(0, 140, 0, 32)
previewToggle.Position = UDim2.new(0, 10, 0, 30)
previewToggle.BackgroundColor3 = Color3.fromRGB(45,45,50)
previewToggle.TextColor3 = Color3.fromRGB(230,230,230)
previewToggle.Font = Enum.Font.GothamBold
previewToggle.TextSize = 14
previewToggle.Text = "Preview: OFF"
previewToggle.AutoButtonColor = false
Instance.new("UICorner", previewToggle).CornerRadius = UDim.new(0, 8)

local previewInfo = Instance.new("TextLabel", previewPage)
previewInfo.Size = UDim2.new(1, -20, 0, 20)
previewInfo.Position = UDim2.new(0, 10, 0, 70)
previewInfo.BackgroundTransparency = 1
previewInfo.Font = Enum.Font.Gotham
previewInfo.TextSize = 13
previewInfo.TextColor3 = Color3.fromRGB(180,180,180)
previewInfo.Text = "Enter model ID to enable preview"

local previewScroll = Instance.new("ScrollingFrame", previewPage)
previewScroll.Size = UDim2.new(1, -20, 1, -110)
previewScroll.Position = UDim2.new(0, 10, 0, 100)
previewScroll.CanvasSize = UDim2.new(0, 0, 0, 900)
previewScroll.ScrollBarThickness = 6
previewScroll.BackgroundTransparency = 1

local previewLayout = Instance.new("UIListLayout", previewScroll)
previewLayout.Padding = UDim.new(0, 10)
previewLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function makeButton(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 120, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(45,45,50)
    b.TextColor3 = Color3.fromRGB(230,230,230)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = text
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local moveTitle = Instance.new("TextLabel", previewScroll)
moveTitle.Size = UDim2.new(1, 0, 0, 20)
moveTitle.BackgroundTransparency = 1
moveTitle.Font = Enum.Font.GothamBold
moveTitle.TextSize = 15
moveTitle.TextColor3 = Color3.fromRGB(220,220,220)
moveTitle.Text = "Move Controls"

local moveIncBox = Instance.new("TextBox", previewScroll)
moveIncBox.Size = UDim2.new(0, 120, 0, 28)
moveIncBox.PlaceholderText = "Move Increment"
moveIncBox.Text = "5"
moveIncBox.Font = Enum.Font.Gotham
moveIncBox.TextSize = 14
moveIncBox.BackgroundColor3 = Color3.fromRGB(40,40,45)
moveIncBox.TextColor3 = Color3.fromRGB(240,240,240)
Instance.new("UICorner", moveIncBox).CornerRadius = UDim.new(0, 6)

local moveX = makeButton("Move X"); moveX.Parent = previewScroll
local moveY = makeButton("Move Y"); moveY.Parent = previewScroll
local moveZ = makeButton("Move Z"); moveZ.Parent = previewScroll

local rotTitle = Instance.new("TextLabel", previewScroll)
rotTitle.Size = UDim2.new(1, 0, 0, 20)
rotTitle.BackgroundTransparency = 1
rotTitle.Font = Enum.Font.GothamBold
rotTitle.TextSize = 15
rotTitle.TextColor3 = Color3.fromRGB(220,220,220)
rotTitle.Text = "Rotation Controls"

local rotIncBox = Instance.new("TextBox", previewScroll)
rotIncBox.Size = UDim2.new(0, 120, 0, 28)
rotIncBox.PlaceholderText = "Rotation Increment"
rotIncBox.Text = "5"
rotIncBox.Font = Enum.Font.Gotham
rotIncBox.TextSize = 14
rotIncBox.BackgroundColor3 = Color3.fromRGB(40,40,45)
rotIncBox.TextColor3 = Color3.fromRGB(240,240,240)
Instance.new("UICorner", rotIncBox).CornerRadius = UDim.new(0, 6)

local rotX = makeButton("Rotate X"); rotX.Parent = previewScroll
local rotY = makeButton("Rotate Y"); rotY.Parent = previewScroll
local rotZ = makeButton("Rotate Z"); rotZ.Parent = previewScroll

local sizeTitle = Instance.new("TextLabel", previewScroll)
sizeTitle.Size = UDim2.new(1, 0, 0, 20)
sizeTitle.BackgroundTransparency = 1
sizeTitle.Font = Enum.Font.GothamBold
sizeTitle.TextSize = 15
sizeTitle.TextColor3 = Color3.fromRGB(220,220,220)
sizeTitle.Text = "Size Controls (Buggy)"

local sizeIncBox = Instance.new("TextBox", previewScroll)
sizeIncBox.Size = UDim2.new(0, 120, 0, 28)
sizeIncBox.PlaceholderText = "Scale Increment"
sizeIncBox.Text = "1"
sizeIncBox.Font = Enum.Font.Gotham
sizeIncBox.TextSize = 14
sizeIncBox.BackgroundColor3 = Color3.fromRGB(40,40,45)
sizeIncBox.TextColor3 = Color3.fromRGB(240,240,240)
Instance.new("UICorner", sizeIncBox).CornerRadius = UDim.new(0, 6)

local sizeBtn = makeButton("Scale Model")
sizeBtn.Parent = previewScroll

local function getRotInc()
    return tonumber(rotIncBox.Text) or 5
end

local function getMoveInc()
    return tonumber(moveIncBox.Text) or 5
end

local function getScaleInc()
    return tonumber(sizeIncBox.Text) or 1
end

local function rotateGhost(axis)
    if not ghostModel or not ghostModel.PrimaryPart then return end
    local inc = math.rad(getRotInc())

    if axis == "X" then
        ghostOffsetCF = ghostOffsetCF * CFrame.Angles(inc, 0, 0)
    elseif axis == "Y" then
        ghostOffsetCF = ghostOffsetCF * CFrame.Angles(0, inc, 0)
    elseif axis == "Z" then
        ghostOffsetCF = ghostOffsetCF * CFrame.Angles(0, 0, inc)
    end
end

rotX.MouseButton1Click:Connect(function() rotateGhost("X") end)
rotY.MouseButton1Click:Connect(function() rotateGhost("Y") end)
rotZ.MouseButton1Click:Connect(function() rotateGhost("Z") end)

local function moveGhost(axis)
    if not ghostModel or not ghostModel.PrimaryPart then return end
    local inc = getMoveInc()

    if axis == "X" then
        ghostOffsetCF = ghostOffsetCF * CFrame.new(inc, 0, 0)
    elseif axis == "Y" then
        ghostOffsetCF = ghostOffsetCF * CFrame.new(0, inc, 0)
    elseif axis == "Z" then
        ghostOffsetCF = ghostOffsetCF * CFrame.new(0, 0, inc)
    end
end

moveX.MouseButton1Click:Connect(function() moveGhost("X") end)
moveY.MouseButton1Click:Connect(function() moveGhost("Y") end)
moveZ.MouseButton1Click:Connect(function() moveGhost("Z") end)

local function scaleGhost()
    if not ghostModel then return end
    local inc = getScaleInc()

    for _, p in ipairs(ghostModel:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Size = p.Size + Vector3.new(inc, inc, inc)
        end
    end
end

sizeBtn.MouseButton1Click:Connect(scaleGhost)

local function refreshPreviewUI()
    if not tonumber(idBox.Text) then
        previewToggle.BackgroundColor3 = Color3.fromRGB(45,45,50)
        previewToggle.Text = "Preview: OFF"
        previewInfo.Text = "Enter model ID to enable preview"
        previewEnabled = false
        destroyGhost()
        return
    end

    previewInfo.Text = ""

    if previewEnabled then
        previewToggle.BackgroundColor3 = Color3.fromRGB(60,160,70)
        previewToggle.Text = "Preview: ON"
    else
        previewToggle.BackgroundColor3 = Color3.fromRGB(45,45,50)
        previewToggle.Text = "Preview: OFF"
    end
end

refreshPreviewUI()

previewToggle.MouseButton1Click:Connect(function()
    if not tonumber(idBox.Text) then
        previewEnabled = false
        refreshPreviewUI()
        return
    end

    previewEnabled = not previewEnabled
    if not previewEnabled then
        destroyGhost()
    end
    refreshPreviewUI()
end)

--========================================================--
-- LOADING TAB + MULTI-SELECT UI
--========================================================--

local loadingLabel = Instance.new("TextLabel", loadingPage)
loadingLabel.Size = UDim2.new(1, -20, 0, 20)
loadingLabel.Position = UDim2.new(0, 10, 0, 0)
loadingLabel.BackgroundTransparency = 1
loadingLabel.Font = Enum.Font.GothamBold
loadingLabel.TextSize = 15
loadingLabel.TextColor3 = Color3.fromRGB(220,220,220)
loadingLabel.Text = "Save / Load Your Build"

local loadStatus = Instance.new("TextLabel", loadingPage)
loadStatus.Size = UDim2.new(1, -20, 0, 20)
loadStatus.Position = UDim2.new(0, 10, 0, 20)
loadStatus.BackgroundTransparency = 1
loadStatus.Font = Enum.Font.Gotham
loadStatus.TextSize = 13
loadStatus.TextColor3 = Color3.fromRGB(180,180,180)
loadStatus.Text = ""

local saveBtn = Instance.new("TextButton", loadingPage)
saveBtn.Size = UDim2.new(1, -20, 0, 32)
saveBtn.Position = UDim2.new(0, 10, 0, 40)
saveBtn.BackgroundColor3 = Color3.fromRGB(60,160,70)
saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 15
saveBtn.Text = "Save (Selection / All)"
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)

local loadBtn = Instance.new("TextButton", loadingPage)
loadBtn.Size = UDim2.new(1, -20, 0, 32)
loadBtn.Position = UDim2.new(0, 10, 0, 80)
loadBtn.BackgroundColor3 = Color3.fromRGB(45,45,50)
loadBtn.TextColor3 = Color3.fromRGB(255,255,255)
loadBtn.Font = Enum.Font.GothamBold
loadBtn.TextSize = 15
loadBtn.Text = "Load Saved Build"
Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 6)

local cancelLoadBtn = Instance.new("TextButton", loadingPage)
cancelLoadBtn.Size = UDim2.new(1, -20, 0, 32)
cancelLoadBtn.Position = UDim2.new(0, 10, 0, 120)
cancelLoadBtn.BackgroundColor3 = Color3.fromRGB(180,60,60)
cancelLoadBtn.TextColor3 = Color3.fromRGB(255,255,255)
cancelLoadBtn.Font = Enum.Font.GothamBold
cancelLoadBtn.TextSize = 15
cancelLoadBtn.Text = "Cancel Loading"
Instance.new("UICorner", cancelLoadBtn).CornerRadius = UDim.new(0, 6)

local multiSelectToggle = Instance.new("TextButton", loadingPage)
multiSelectToggle.Size = UDim2.new(0.48, -10, 0, 32)
multiSelectToggle.Position = UDim2.new(0, 10, 0, 160)
multiSelectToggle.BackgroundColor3 = Color3.fromRGB(220, 180, 40) -- yellow
multiSelectToggle.TextColor3 = Color3.fromRGB(30,30,30)
multiSelectToggle.Font = Enum.Font.GothamBold
multiSelectToggle.TextSize = 14
multiSelectToggle.Text = "Multi-Select"
multiSelectToggle.AutoButtonColor = false
Instance.new("UICorner", multiSelectToggle).CornerRadius = UDim.new(0, 6)

local selectAllBtn = Instance.new("TextButton", loadingPage)
selectAllBtn.Size = UDim2.new(0.48, -10, 0, 32)
selectAllBtn.Position = UDim2.new(0.52, 0, 0, 160)
selectAllBtn.BackgroundColor3 = Color3.fromRGB(45,45,50)
selectAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
selectAllBtn.Font = Enum.Font.GothamBold
selectAllBtn.TextSize = 14
selectAllBtn.Text = "Select All"
Instance.new("UICorner", selectAllBtn).CornerRadius = UDim.new(0, 6)

--========================================================--
-- HIGHLIGHT / SELECTION HELPERS
--========================================================--

local function clearHighlights()
    for part, hl in pairs(highlights) do
        if hl and hl.Parent then
            hl:Destroy()
        end
    end
    highlights = {}
end

local function clearSelection()
    selectedParts = {}
    clearHighlights()
end

local function addHighlight(part)
    if highlights[part] then return end
    local hl = Instance.new("Highlight")
    hl.Adornee = part
    hl.FillColor = Color3.fromRGB(80, 150, 255)
    hl.FillTransparency = 0.6
    hl.OutlineColor = Color3.fromRGB(80, 150, 255)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = screenGui
    highlights[part] = hl
end

local function removeHighlight(part)
    local hl = highlights[part]
    if hl then
        hl:Destroy()
        highlights[part] = nil
    end
end

local function togglePartSelection(part)
    if not isValidItemPart(part) then return end

    if selectedParts[part] then
        selectedParts[part] = nil
        removeHighlight(part)
    else
        selectedParts[part] = true
        addHighlight(part)
    end
end

--========================================================--
-- MULTI-SELECT INPUT (CLICK + BOX)
--========================================================--

local selectionBoxFrame = Instance.new("Frame")
selectionBoxFrame.BackgroundColor3 = Color3.fromRGB(120,120,120)
selectionBoxFrame.BackgroundTransparency = 0.7
selectionBoxFrame.BorderSizePixel = 1
selectionBoxFrame.BorderColor3 = Color3.fromRGB(180,180,180)
selectionBoxFrame.Visible = false
selectionBoxFrame.ZIndex = 10
selectionBoxFrame.Parent = screenGui

local boxStartPos = nil

local function setMultiSelectVisual()
    if selectionBoxMode then
        multiSelectToggle.BackgroundColor3 = Color3.fromRGB(255, 140, 0) -- orange
        multiSelectToggle.TextColor3 = Color3.fromRGB(30,30,30)
        multiSelectToggle.Text = "Selection-Box"
    elseif multiSelectEnabled then
        multiSelectToggle.BackgroundColor3 = Color3.fromRGB(220, 180, 40) -- yellow
        multiSelectToggle.TextColor3 = Color3.fromRGB(30,30,30)
        multiSelectToggle.Text = "Multi-Select"
    else
        multiSelectToggle.BackgroundColor3 = Color3.fromRGB(80,80,80)
        multiSelectToggle.TextColor3 = Color3.fromRGB(230,230,230)
        multiSelectToggle.Text = "Multi-Select"
    end
end

setMultiSelectVisual()

multiSelectToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        multiSelectPressStart = tick()
    end
end)

multiSelectToggle.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    if not multiSelectPressStart then return end
    local held = tick() - multiSelectPressStart
    multiSelectPressStart = nil

    if held >= LONG_PRESS_TIME then
        selectionBoxMode = not selectionBoxMode
        multiSelectEnabled = selectionBoxMode or multiSelectEnabled
    else
        if selectionBoxMode then
            selectionBoxMode = false
        else
            multiSelectEnabled = not multiSelectEnabled
        end
    end

    setMultiSelectVisual()
end)

local function screenToWorldRay(x, y)
    local unitRay = Camera:ScreenPointToRay(x, y)
    return Ray.new(unitRay.Origin, unitRay.Direction * 1000)
end

local function selectPartsInScreenBox(p1, p2)
    local minX = math.min(p1.X, p2.X)
    local maxX = math.max(p1.X, p2.X)
    local minY = math.min(p1.Y, p2.Y)
    local maxY = math.max(p1.Y, p2.Y)

    local items = getItemsFolder()
    if not items then return end

    for _, obj in ipairs(items:GetDescendants()) do
        if obj:IsA("BasePart") and isValidItemPart(obj) then
            local screenPos, onScreen = Camera:WorldToViewportPoint(obj.Position)
            if onScreen then
                if screenPos.X >= minX and screenPos.X <= maxX and screenPos.Y >= minY and screenPos.Y <= maxY then
                    selectedParts[obj] = true
                    addHighlight(obj)
                end
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not multiSelectEnabled then return end

    if selectionBoxMode then
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            boxStartPos = UserInputService:GetMouseLocation()
            selectionBoxFrame.Visible = true
            selectionBoxFrame.Position = UDim2.fromOffset(boxStartPos.X, boxStartPos.Y)
            selectionBoxFrame.Size = UDim2.new(0, 0, 0, 0)
        end
    else
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            local ray = screenToWorldRay(pos.X, pos.Y)
            local hitPart = workspace:FindPartOnRay(ray, LocalPlayer.Character, false, true)
            if hitPart then
                togglePartSelection(hitPart)
            end
        end
    end
end)

UserInputService.InputChanged:Connect(function(input, gp)
    if gp then return end
    if not selectionBoxMode or not boxStartPos then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local currentPos = UserInputService:GetMouseLocation()
        local x = math.min(boxStartPos.X, currentPos.X)
        local y = math.min(boxStartPos.Y, currentPos.Y)
        local w = math.abs(boxStartPos.X - currentPos.X)
        local h = math.abs(boxStartPos.Y - currentPos.Y)
        selectionBoxFrame.Position = UDim2.fromOffset(x, y)
        selectionBoxFrame.Size = UDim2.fromOffset(w, h)
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if not selectionBoxMode or not boxStartPos then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local endPos = UserInputService:GetMouseLocation()
        selectionBoxFrame.Visible = false
        selectionBoxFrame.Size = UDim2.fromOffset(0, 0)

        selectPartsInScreenBox(boxStartPos, endPos)

        boxStartPos = nil
        selectionBoxMode = false
        setMultiSelectVisual()
    end
end)

selectAllBtn.MouseButton1Click:Connect(function()
    clearSelection()
    local items = getItemsFolder()
    if not items then return end

    for _, obj in ipairs(items:GetDescendants()) do
        if obj:IsA("BasePart") and isValidItemPart(obj) then
            selectedParts[obj] = true
            addHighlight(obj)
        end
    end
end)

--========================================================--
-- SAVE LOGIC (SELECTION / ALL)
--========================================================--

saveBtn.MouseButton1Click:Connect(function()
    local items = getItemsFolder()
    if not items then
        statusLabel.Text = "Your plot not found"
        return
    end

    savedBuild = {}

    local function addPart(part)
        table.insert(savedBuild, {
            Type = detectPartType(part),
            Size = part.Size,
            CFrame = part.CFrame,
            Color = part.Color,
            Material = part.Material.Name,
            Behaviors = extractBehaviors(part)
        })
    end

    local anySelected = false
    for p in pairs(selectedParts) do
        if p:IsA("BasePart") and isValidItemPart(p) then
            anySelected = true
            addPart(p)
        end
    end

    if not anySelected then
        for _, obj in ipairs(items:GetDescendants()) do
            if obj:IsA("BasePart") and isValidItemPart(obj) then
                addPart(obj)
            end
        end
    end

    statusLabel.Text = "Build Saved! (" .. tostring(#savedBuild) .. " parts)"
end)

--========================================================--
-- LOAD LOGIC + RETRY LOOP
--========================================================--

cancelLoadBtn.MouseButton1Click:Connect(function()
    cancelLoad = true
    statusLabel.Text = "Cancelling load..."
end)

local buildLast = {
    ["Pressure Plate"] = true,
    ["Button"] = true,
    ["Button Deactivator"] = true
}

local function getAllPartsSnapshot()
    local items = getItemsFolder()
    local all = {}
    if not items then return all end

    for _, obj in ipairs(items:GetDescendants()) do
        if obj:IsA("BasePart") then
            all[obj] = true
        end
    end
    return all
end

local function findNewPart(before)
    local items = getItemsFolder()
    if not items then return nil end

    for _, obj in ipairs(items:GetDescendants()) do
        if obj:IsA("BasePart") and not before[obj] then
            return obj
        end
    end
    return nil
end

local function buildOnePart(index, data, totalParts, loadedCountRef)
    if cancelLoad then return false end

    local shape = data.Type or "Part"
    local cf = data.CFrame
    local size = data.Size
    local color = data.Color
    local materialName = data.Material
    local behaviors = data.Behaviors or {}

    local before = getAllPartsSnapshot()

    local okAdd = pcall(function()
        AddObjectRemote:InvokeServer(shape, cf)
    end)

    if not okAdd then
        warn("AddObject failed for index", index, "shape:", shape)
        return false
    end

    local newPart = nil
    local timeout = os.clock() + 2.0

    repeat
        task.wait(0.02)
        newPart = findNewPart(before)
    until newPart or os.clock() > timeout or cancelLoad

    if cancelLoad then return false end

    if not newPart then
        warn("Skipping part index", index, "— server did not spawn it in time")
        return false
    end

    pcall(function()
        MoveObjectRemote:InvokeServer({{newPart, cf, size}})
    end)

    pcall(function()
        Events.PaintObject:InvokeServer({newPart}, "Color", color)
    end)

    local materialEnum = Enum.Material[materialName] or Enum.Material.Plastic
    pcall(function()
        Events.PaintObject:InvokeServer({newPart}, "Material", materialEnum)
    end)

    for key, value in pairs(behaviors) do
        pcall(function()
            Events.BehaviourObject:InvokeServer({newPart}, key, value)
        end)
    end

    loadedCountRef.value += 1
    loadStatus.Text = string.format("Built %d/%d", loadedCountRef.value, totalParts)

    task.wait(1.05)
    return true
end

loadBtn.MouseButton1Click:Connect(function()
    if not savedBuild or #savedBuild == 0 then
        statusLabel.Text = "No saved build"
        return
    end

    local items = getItemsFolder()
    if not items then
        statusLabel.Text = "Your plot not found"
        return
    end

    cancelLoad = false
    failedIndices = {}
    statusLabel.Text = "Loading saved build..."

    local totalParts = #savedBuild
    local loadedCountRef = { value = 0 }
    loadStatus.Text = "Built 0/" .. totalParts

    task.spawn(function()
        for index, data in ipairs(savedBuild) do
            if cancelLoad then
                statusLabel.Text = "Load Cancelled"
                return
            end

            if not buildLast[data.Type] then
                local ok = buildOnePart(index, data, totalParts, loadedCountRef)
                if not ok then
                    table.insert(failedIndices, index)
                end
            end
        end

        if cancelLoad then
            statusLabel.Text = "Load Cancelled"
            return
        end

        for index, data in ipairs(savedBuild) do
            if cancelLoad then
                statusLabel.Text = "Load Cancelled"
                return
            end

            if buildLast[data.Type] then
                local ok = buildOnePart(index, data, totalParts, loadedCountRef)
                if not ok then
                    table.insert(failedIndices, index)
                end
            end
        end

        if cancelLoad then
            statusLabel.Text = "Load Cancelled"
            return
        end

        if #failedIndices > 0 then
            statusLabel.Text = "Retrying missing parts..."
            while #failedIndices > 0 and not cancelLoad do
                local remaining = {}
                for _, idx in ipairs(failedIndices) do
                    if cancelLoad then break end
                    local data = savedBuild[idx]
                    loadStatus.Text = string.format("Retry loop: %d missing, built %d/%d", #failedIndices, loadedCountRef.value, totalParts)
                    local ok = buildOnePart(idx, data, totalParts, loadedCountRef)
                    if not ok then
                        table.insert(remaining, idx)
                    end
                end
                failedIndices = remaining
                if #failedIndices == 0 or cancelLoad then
                    break
                end
            end
        end

        if cancelLoad then
            statusLabel.Text = "Load Cancelled"
        else
            statusLabel.Text = "Build Loaded! (" .. tostring(loadedCountRef.value) .. "/" .. tostring(totalParts) .. ")"
        end
    end)
end)

--========================================================--
-- BUILD BUTTON (STUB - YOU CAN HOOK YOUR MODEL SYSTEM)
--========================================================--

local function getBuildOriginCFrame()
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return CFrame.new() end
    return hrp.CFrame * CFrame.new(0, 0, -5)
end

buildBtn.MouseButton1Click:Connect(function()
    statusLabel.Text = "Build logic not wired to model ID yet."
end)

cancelBtn.MouseButton1Click:Connect(function()
    cancelBuild = true
    statusLabel.Text = "Build cancelled."
end)
