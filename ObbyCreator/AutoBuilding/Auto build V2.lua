--========================================================--
-- SIMPLE AUTO BUILDER (AddObject + MoveObject only)
-- Builds the model 5 studs in front of your character
--========================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Events = ReplicatedStorage:WaitForChild("Events")
local AddObjectRemote = Events:WaitForChild("AddObject")
local MoveObjectRemote = Events:WaitForChild("MoveObject")

local cancelBuild = false
local savedBuild = nil
local cancelLoad = false

--========================================================--
-- GHOST PREVIEW SYSTEM
--========================================================--

local ghostModel = nil
local ghostConnection = nil
local previewEnabled = false -- controlled by the toggle
local ghostOffsetCF = CFrame.new(0, 0, -5) -- offset relative to player HRP

-- DETECT SPECIAL SHAPE
local function detectPartType(part)
    local name = part.Name

    -- Special shapes (your original list)
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

    -- Special functional parts
    local functional = {
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
        ["Global Properties Part"] = true
    }

    if functional[name] then
        return name
    end

    -- Normal Roblox shapes
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
-- PLAYER PARTS FOLDER
--========================================================--

local function getPartsFolder()
    local obbies = workspace:FindFirstChild("Obbies")
    if not obbies then return nil end

    local playerFolder = obbies:FindFirstChild(LocalPlayer.Name)
    if not playerFolder then return nil end

    local items = playerFolder:FindFirstChild("Items")
    if not items then return nil end

    local parts = items:FindFirstChild("Parts")
    return parts
end

--========================================================--
-- GUI
--========================================================--

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoBuilderUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- MAIN WINDOW
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 280)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- DRAGGABLE WINDOW
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- TOP BAR
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

--========================================================--
-- SCROLLABLE TAB BAR
--========================================================--

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

--========================================================--
-- TAB PAGES
--========================================================--

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
-- BUILD TAB CONTENT
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
-- HELPERS
--========================================================--

local function getBuildOriginCFrame()
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return CFrame.new() end
    return hrp.CFrame * CFrame.new(0, 0, -5)
end

local function computeTargetCFrame(primaryCF, buildOriginCF, partCF)
    local rel = primaryCF:ToObjectSpace(partCF)
    return buildOriginCF * rel
end

--========================================================--
-- GHOST PREVIEW FUNCTIONS
--========================================================--

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

    ghostOffsetCF = CFrame.new(0, 0, -5) -- reset offset when new ghost is created
    startGhostFollow()
    return ghostModel
end

--========================================================--
-- PREVIEW TAB CONTENT
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

--========================================================--
-- PREVIEW CONTROLS (ROTATE / MOVE / SIZE)
--========================================================--

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

-- MOVE CONTROLS
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

-- ROTATION CONTROLS
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

-- SIZE CONTROLS
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

--========================================================--
-- LOADING TAB CONTENT
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
saveBtn.Size = UDim2.new(1, -20, 0, 36)
saveBtn.Position = UDim2.new(0, 10, 0, 40)
saveBtn.BackgroundColor3 = Color3.fromRGB(60,160,70)
saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 15
saveBtn.Text = "Save Current Build"
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)

local loadBtn = Instance.new("TextButton", loadingPage)
loadBtn.Size = UDim2.new(1, -20, 0, 36)
loadBtn.Position = UDim2.new(0, 10, 0, 90)
loadBtn.BackgroundColor3 = Color3.fromRGB(45,45,50)
loadBtn.TextColor3 = Color3.fromRGB(255,255,255)
loadBtn.Font = Enum.Font.GothamBold
loadBtn.TextSize = 15
loadBtn.Text = "Load Saved Build"
Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 6)

local cancelLoadBtn = Instance.new("TextButton", loadingPage)
cancelLoadBtn.Size = UDim2.new(1, -20, 0, 36)
cancelLoadBtn.Position = UDim2.new(0, 10, 0, 140)
cancelLoadBtn.BackgroundColor3 = Color3.fromRGB(180,60,60)
cancelLoadBtn.TextColor3 = Color3.fromRGB(255,255,255)
cancelLoadBtn.Font = Enum.Font.GothamBold
cancelLoadBtn.TextSize = 15
cancelLoadBtn.Text = "Cancel Loading"
Instance.new("UICorner", cancelLoadBtn).CornerRadius = UDim.new(0, 6)

--========================================================--
-- PREVIEW UI UPDATE
--========================================================--

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

-- FUNCTION TO DETECT SHAPE
    local function detectShape(part)
        if part:GetAttribute("IsGhost") == true then
            return nil
        end

        if part:IsA("Part") then
            local shape = part.Shape
            if shape == Enum.PartType.Ball then return "Ball" end
            if shape == Enum.PartType.Cylinder then return "Cylinder" end
            if shape == Enum.PartType.Wedge then return "Wedge" end
            return "Part"
        end

        if part:IsA("WedgePart") then return "Wedge" end
        if part:IsA("CornerWedgePart") then return "CornerWedge" end
        if part:IsA("TrussPart") then return "Truss" end

        if part:IsA("MeshPart") then
            local meshType = part.MeshType
            if meshType == Enum.MeshType.Wedge then return "Wedge" end
            if meshType == Enum.MeshType.Sphere then return "Ball" end
            if meshType == Enum.MeshType.Cylinder then return "Cylinder" end
        end

        if part:IsA("MeshPart") then
            local id = part.MeshId:lower()
            if id:find("wedge") or id:find("tri") or id:find("slope") then return "Wedge" end
            if id:find("cyl") or id:find("tube") then return "Cylinder" end
            if id:find("ball") or id:find("sphere") then return "Ball" end
        end

        local name = part.Name:lower()
        if name:find("wedge") or name:find("tri") or name:find("slope") then return "Wedge" end
        if name:find("cyl") or name:find("tube") then return "Cylinder" end
        if name:find("ball") or name:find("sphere") then return "Ball" end

        if part:IsA("UnionOperation") then
            if name:find("wedge") or name:find("tri") or name:find("slope") then return "Wedge" end
        end

        return "Part"
    end

--========================================================--
-- ROTATION / MOVE / SCALE LOGIC (OFFSET-BASED)
--========================================================--

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


-- SAVE BUTTON
saveBtn.MouseButton1Click:Connect(function()
    local partsFolder = getPartsFolder()
    if not partsFolder then
        statusLabel.Text = "Your plot not found"
        return
    end

    local parts = partsFolder:GetChildren()
    if #parts == 0 then
        statusLabel.Text = "No parts to save"
        return
    end

    savedBuild = {}

    for _, p in ipairs(parts) do
        if p:IsA("BasePart") then
            table.insert(savedBuild, {
    Type = detectPartType(p),
    Size = p.Size,
    CFrame = p.CFrame,
    Color = p.Color,
    Material = tostring(p.Material),
    Behaviors = extractBehaviors(p)
})
        end
    end

    statusLabel.Text = "Build Saved!"
end)

-- CANCEL BUTTON
cancelLoadBtn.MouseButton1Click:Connect(function()
    cancelLoad = true
    statusLabel.Text = "Cancelling load..."
end)

-- LOAD BUTTON
loadBtn.MouseButton1Click:Connect(function()
    if not savedBuild then
        statusLabel.Text = "No saved build"
        return
    end

    local partsFolder = getPartsFolder()
    if not partsFolder then
        statusLabel.Text = "Your plot not found"
        return
    end

    cancelLoad = false
    statusLabel.Text = "Loading saved build..."

    local totalParts = #savedBuild
    local loadedCount = 0
    loadStatus.Text = "0/" .. totalParts

    task.spawn(function()
        for _, data in ipairs(savedBuild) do
            if cancelLoad then
                statusLabel.Text = "Load Cancelled"
                break
            end

            local shape = data.Shape
            local cf = data.CFrame
            local size = data.Size
            local color = data.Color
            local material = data.Material

            -- BEFORE list
            local before = {}
            for _, p in ipairs(partsFolder:GetChildren()) do
                before[p] = true
            end

            -- Spawn new part (RemoteFunction)
            pcall(function()
                AddObjectRemote:InvokeServer(shape, cf)
            end)

            -- Wait for new part
            local newPart = nil
            local timeout = os.clock() + 1

            repeat
                task.wait(0.02)
                for _, p in ipairs(partsFolder:GetChildren()) do
                    if not before[p] then
                        newPart = p
                        break
                    end
                end
            until newPart or os.clock() > timeout or cancelLoad

            if cancelLoad then break end
            if not newPart then continue end

            -- Move + resize (retry-safe)
            pcall(function()
                for i = 1, 3 do
                    MoveObjectRemote:InvokeServer({{newPart, cf, size}})
                    task.wait(0.05)
                end
            end)

            -- Color (retry-safe)
            pcall(function()
                for i = 1, 2 do
                    Events.PaintObject:InvokeServer({newPart}, "Color", color)
                    task.wait(0.03)
                end
            end)

            -- Material (retry-safe)
            pcall(function()
                for i = 1, 2 do
                    Events.PaintObject:InvokeServer({newPart}, "Material", material)
                    task.wait(0.03)
                end
            end)

                    -- Apply behaviors
for key, value in pairs(data.Behaviors) do
    pcall(function()
        Events.BehaviourObject:InvokeServer({{newPart}}, key, value)
    end)
end

            -- Update progress
            loadedCount += 1
            loadStatus.Text = string.format("%d/%d", loadedCount, totalParts)
        end

        if not cancelLoad then
            statusLabel.Text = "Build Loaded!"
        end
    end)
end)

--========================================================--
-- LIVE PREVIEW MODEL LOADER
--========================================================--

local previewModel = nil

local function loadPreviewModel()
    destroyGhost()

    if previewModel then
        previewModel:Destroy()
        previewModel = nil
    end

    if not tonumber(idBox.Text) then
        return
    end

    if not previewEnabled then
        return
    end

    local ok, arr = pcall(function()
        return game:GetObjects("rbxassetid://" .. idBox.Text)
    end)

    if not ok or not arr or #arr == 0 then
        previewInfo.Text = "Invalid ID"
        return
    end

    previewModel = arr[1]

    if not previewModel:IsA("Model") then
        local newModel = Instance.new("Model")
        newModel.Name = previewModel.Name

        for _, obj in ipairs(previewModel:GetChildren()) do
            obj.Parent = newModel
        end

        previewModel:Destroy()
        previewModel = newModel
    end

    if not previewModel.PrimaryPart then
        for _, v in ipairs(previewModel:GetDescendants()) do
            if v:IsA("BasePart") then
                previewModel.PrimaryPart = v
                break
            end
        end
    end

    if not previewModel.PrimaryPart then
        previewInfo.Text = "Model has no parts"
        return
    end

    createGhost(previewModel)
end

previewToggle.MouseButton1Click:Connect(function()
    if not tonumber(idBox.Text) then
        previewInfo.Text = "Enter model ID to enable preview"
        return
    end

    previewEnabled = not previewEnabled
    refreshPreviewUI()

    if previewEnabled then
        loadPreviewModel()
    else
        destroyGhost()
    end
end)

idBox:GetPropertyChangedSignal("Text"):Connect(function()
    refreshPreviewUI()
    if previewEnabled then
        loadPreviewModel()
    end
end)

--========================================================--
-- SETTINGS TAB CONTENT
--========================================================--

local settingsLabel = Instance.new("TextLabel", settingsPage)
settingsLabel.Size = UDim2.new(1, -20, 0, 20)
settingsLabel.Position = UDim2.new(0, 10, 0, 0)
settingsLabel.BackgroundTransparency = 1
settingsLabel.Font = Enum.Font.Gotham
settingsLabel.TextSize = 14
settingsLabel.TextColor3 = Color3.fromRGB(200,200,200)
settingsLabel.Text = "Settings coming soon..."

local toggleGuiBtn = Instance.new("TextButton", screenGui)
toggleGuiBtn.Size = UDim2.new(0, 38, 0, 38)
toggleGuiBtn.Position = UDim2.new(1, -60, 0.35, 0)
toggleGuiBtn.Text = "⚙️"
toggleGuiBtn.Font = Enum.Font.Gotham
toggleGuiBtn.TextSize = 20
toggleGuiBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
toggleGuiBtn.TextColor3 = Color3.fromRGB(255,255,255)

toggleGuiBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

cancelBtn.MouseButton1Click:Connect(function()
    cancelBuild = true
    statusLabel.Text = "Cancelling..."
    destroyGhost()
    previewEnabled = false
    refreshPreviewUI()
end)

--========================================================--
-- BUILD LOGIC (ONE PASS, IMMEDIATE MOVE)
--========================================================--

local function buildModelSimple(assetId)
    cancelBuild = false
    statusLabel.Text = "Loading asset..."

    local ok, arr = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(assetId))
    end)

    if not ok or not arr or #arr == 0 then
        previewInfo.Text = "Invalid ID"
        return
    end

    local model = arr[1]

    if not model:IsA("Model") then
        local newModel = Instance.new("Model")
        newModel.Name = model.Name

        for _, obj in ipairs(model:GetChildren()) do
            obj.Parent = newModel
        end

        model:Destroy()
        model = newModel
    end

    if not model.PrimaryPart then
        for _, v in ipairs(model:GetDescendants()) do
            if v:IsA("BasePart") then
                model.PrimaryPart = v
                break
            end
        end
    end

    if not model.PrimaryPart then
        statusLabel.Text = "Model has no parts."
        model:Destroy()
        return
    end

    local partsFolder = getPartsFolder()
    if not partsFolder then
        statusLabel.Text = "Parts folder not found."
        model:Destroy()
        return
    end

    -- Build origin: if preview exists, use ghost position; else default
    local buildOriginCF
    if ghostModel and ghostModel.PrimaryPart then
        buildOriginCF = ghostModel.PrimaryPart.CFrame
    else
        buildOriginCF = getBuildOriginCFrame()
    end

    local primaryCF = model.PrimaryPart.CFrame

    local sourceParts = {}
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            table.insert(sourceParts, p)
        end
    end

    local total = #sourceParts
    if total == 0 then
        statusLabel.Text = "No parts to build."
        model:Destroy()
        return
    end

    -- Build preview parts list ONCE (if ghost exists)
    local previewParts = nil
    if ghostModel and ghostModel.PrimaryPart then
        previewParts = {}
        for _, p in ipairs(ghostModel:GetDescendants()) do
            if p:IsA("BasePart") then
                table.insert(previewParts, p)
            end
        end
    end

    statusLabel.Text = "Building.."
    local placedCount = 0

    for i, src in ipairs(sourceParts) do
        if cancelBuild then
            statusLabel.Text = "Cancelled"
            break
        end

        statusLabel.Text = string.format("Building.. %d/%d", placedCount, total)

        local previewPart = previewParts and previewParts[i] or nil

        -- If preview exists, build exactly where the preview part is.
        -- Otherwise, use original relative placement.
        local targetCF
        if previewPart then
            targetCF = previewPart.CFrame
        else
            targetCF = computeTargetCFrame(primaryCF, buildOriginCF, src.CFrame)
        end

        local beforeList = partsFolder:GetChildren()
        local beforeCount = #beforeList
        local shape = detectShape(src)

        pcall(function()
            if AddObjectRemote.ClassName == "RemoteEvent" then
                AddObjectRemote:FireServer(shape, targetCF)
            else
                AddObjectRemote:InvokeServer(shape, targetCF)
            end
        end)

        local newPart = nil
        local timeout = 2
        local start = os.clock()

        repeat
            task.wait(0.05)
            local current = partsFolder:GetChildren()

            if #current > beforeCount then
                local lookup = {}
                for _, p in ipairs(beforeList) do
                    lookup[p] = true
                end
                for _, p in ipairs(current) do
                    if not lookup[p] then
                        newPart = p
                        break
                    end
                end
            end
        until newPart or os.clock() - start > timeout or cancelBuild

        if cancelBuild then
            statusLabel.Text = "Cancelled"
            break
        end

        if not newPart then
            continue
        end

        placedCount += 1
        statusLabel.Text = string.format("Building.. %d/%d", placedCount, total)

        local finalSize = previewPart and previewPart.Size or src.Size

        local argsMove = {
            {
                {
                    newPart,
                    targetCF,
                    finalSize
                }
            }
        }

        pcall(function()
            MoveObjectRemote:InvokeServer(unpack(argsMove))
        end)

        pcall(function()
            Events.PaintObject:InvokeServer(
                { newPart },
                "Color",
                src.Color
            )
        end)

        task.wait(1.05)
    end

    if not cancelBuild then
        statusLabel.Text = string.format("Finished (%d/%d)", placedCount, total)
    end

    model:Destroy()
end


--========================================================--
-- BUTTON BIND
--========================================================--

buildBtn.MouseButton1Click:Connect(function()
    if cancelBuild then
        cancelBuild = false
    end

    local id = tonumber(idBox.Text)
    if not id then
        statusLabel.Text = "ID must be numbers only"
        return
    end

    statusLabel.Text = "Starting..."
    task.spawn(function()
        buildModelSimple(id)
        if previewEnabled then
            destroyGhost()
            previewEnabled = false
            refreshPreviewUI()
        end
    end)
end)
