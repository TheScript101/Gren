--========================================================--
-- SIMPLE AUTO BUILDER (AddObject + MoveObject only)
-- Builds the model 5 studs in front of your character
--========================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Events = ReplicatedStorage:WaitForChild("Events")
local AddObjectRemote = Events:WaitForChild("AddObject")
local MoveObjectRemote = Events:WaitForChild("MoveObject")

local cancelBuild = false

--========================================================--
-- GHOST PREVIEW SYSTEM
--========================================================--

local ghostModel = nil
local ghostConnection = nil
local previewEnabled = false -- controlled by the toggle

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

--========================================================--
-- GUI (PROFESSIONAL TAB UI)
--========================================================--

--========================================================--
-- GUI (MODERN, CENTERED, DRAGGABLE, SCROLLABLE TABS)
--========================================================--

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoBuilderUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- MAIN WINDOW
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 280)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- PERFECT CENTER
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
local settingsTabBtn = createTabButton("Settings")

-- Auto‑resize scroll area
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
local settingsPage = createTabPage()

local function showTab(tab)
    buildPage.Visible = false
    previewPage.Visible = false
    settingsPage.Visible = false
    tab.Visible = true
end

buildTabBtn.MouseButton1Click:Connect(function() showTab(buildPage) end)
previewTabBtn.MouseButton1Click:Connect(function() showTab(previewPage) end)
settingsTabBtn.MouseButton1Click:Connect(function() showTab(settingsPage) end)

showTab(buildPage) -- default


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

local function createGhost(model)
    destroyGhost()

    ghostModel = model:Clone()
    ghostModel.Parent = workspace

    -- Make ghost transparent + anchored
    for _, p in ipairs(ghostModel:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Transparency = 0.6
            p.Color = Color3.fromRGB(120, 200, 255)
            p.Material = Enum.Material.ForceField
            p.CanCollide = false
            p.Anchored = true
        end
    end

    return ghostModel
end

local function updateGhost()
    if ghostConnection then
        ghostConnection:Disconnect()
    end

    ghostConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not ghostModel or not ghostModel.PrimaryPart then return end
        local origin = getBuildOriginCFrame()
        ghostModel:SetPrimaryPartCFrame(origin)
    end)
end
--========================================================--
-- PREVIEW TAB CONTENT (CLEAN + WORKING)
--========================================================--

local previewLabel = Instance.new("TextLabel", previewPage)
previewLabel.Size = UDim2.new(1, -20, 0, 20)
previewLabel.Position = UDim2.new(0, 10, 0, 0)
previewLabel.BackgroundTransparency = 1
previewLabel.Font = Enum.Font.GothamBold
previewLabel.TextSize = 15
previewLabel.TextColor3 = Color3.fromRGB(220,220,220)
previewLabel.Text = "Ghost Preview"

-- SIMPLE TOGGLE BUTTON
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

-- INFO LABEL
local previewInfo = Instance.new("TextLabel", previewPage)
previewInfo.Size = UDim2.new(1, -20, 0, 20)
previewInfo.Position = UDim2.new(0, 10, 0, 70)
previewInfo.BackgroundTransparency = 1
previewInfo.Font = Enum.Font.Gotham
previewInfo.TextSize = 13
previewInfo.TextColor3 = Color3.fromRGB(180,180,180)
previewInfo.Text = "Enter model ID to enable preview"

-- UPDATE UI
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

-- TOGGLE CLICK
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

    if not tonumber(idBox.Text) then return end
    if not previewEnabled then return end

    -- Load model
    local ok, arr = pcall(function()
        return game:GetObjects("rbxassetid://" .. idBox.Text)
    end)

    if not ok or not arr or #arr == 0 then
        previewInfo.Text = "Invalid ID"
        return
    end

    previewModel = arr[1]

    -- Ensure PrimaryPart exists
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

    -- Create ghost
    createGhost(previewModel)
    updateGhost()
end

-- When toggle changes
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

-- When ID changes
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
end)

--e 

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


    if not model.PrimaryPart then
        for _, v in ipairs(model:GetDescendants()) do
            if v:IsA("BasePart") then
                model.PrimaryPart = v
                break
            end
        end
        if not model.PrimaryPart then
            statusLabel.Text = "Model has no parts."
            model:Destroy()
            return
        end
    end

    local partsFolder = getPartsFolder()
    if not partsFolder then
        statusLabel.Text = "Parts folder not found."
        model:Destroy()
        return
    end
    
local function detectShape(part)
    -- Ignore ghost parts
    if part.Material == Enum.Material.ForceField then
        return nil
    end

    -- 1) Primary Part.Shape
    if part:IsA("Part") then
        local shape = part.Shape
        if shape == Enum.PartType.Ball then return "Ball" end
        if shape == Enum.PartType.Cylinder then return "Cylinder" end
        if shape == Enum.PartType.Wedge then return "Wedge" end
        return "Part"
    end

    -- 2) Special parts
    if part:IsA("WedgePart") then return "Wedge" end
    if part:IsA("CornerWedgePart") then return "CornerWedge" end
    if part:IsA("TrussPart") then return "Truss" end

    -- 3) MeshPart shapes
    if part:IsA("MeshPart") then
        local meshType = part.MeshType
        if meshType == Enum.MeshType.Wedge then return "Wedge" end
        if meshType == Enum.MeshType.Sphere then return "Ball" end
        if meshType == Enum.MeshType.Cylinder then return "Cylinder" end
    end

    -- 4) MeshId fallback
    if part:IsA("MeshPart") then
        local id = part.MeshId:lower()
        if id:find("wedge") or id:find("tri") or id:find("slope") then return "Wedge" end
        if id:find("cyl") or id:find("tube") then return "Cylinder" end
        if id:find("ball") or id:find("sphere") then return "Ball" end
    end

    -- 5) Name fallback
    local name = part.Name:lower()
    if name:find("wedge") or name:find("tri") or name:find("slope") then return "Wedge" end
    if name:find("cyl") or name:find("tube") then return "Cylinder" end
    if name:find("ball") or name:find("sphere") then return "Ball" end

    -- 6) Union fallback
    if part:IsA("UnionOperation") then
        if name:find("wedge") or name:find("tri") or name:find("slope") then return "Wedge" end
    end

    return "Part"
end


    local buildOriginCF = getBuildOriginCFrame()
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

    statusLabel.Text = "Building.."

    local placedCount = 0

for _, src in ipairs(sourceParts) do
    if cancelBuild then
        statusLabel.Text = "Cancelled"
        break
    end

    -- Show REAL progress
    statusLabel.Text = string.format("Building.. %d/%d", placedCount, total)

    local targetCF = computeTargetCFrame(primaryCF, buildOriginCF, src.CFrame)

    -- Count parts before placing
    local beforeList = partsFolder:GetChildren()
    local beforeCount = #beforeList
    local shape = detectShape(src)

    -- Request server to create the part
    pcall(function()
    if AddObjectRemote.ClassName == "RemoteEvent" then
        AddObjectRemote:FireServer(shape, targetCF)
    else
        AddObjectRemote:InvokeServer(shape, targetCF)
    end
end)


    -- Wait for the new part to appear (server rate limit = 1 second)
    local newPart = nil
    local timeout = 2 -- 2 seconds is safe for 1/sec rate limit
    local start = os.clock()

    repeat
        task.wait(0.05)
        local current = partsFolder:GetChildren()

        if #current > beforeCount then
            -- Find the new part
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
        -- Server rejected this placement due to rate limit
        -- DO NOT increment placedCount
        continue
    end

    -- We actually got a part -> count it
    placedCount += 1
    statusLabel.Text = string.format("Building.. %d/%d", placedCount, total)

    -- Move/resize the part
    local argsMove = {
        {
            {
                newPart,
                targetCF,
                src.Size
            }
        }
    }

    pcall(function()
        MoveObjectRemote:InvokeServer(unpack(argsMove))
    end)

        -- AUTO COLOR
pcall(function()
    Events.PaintObject:InvokeServer(
        { newPart },      -- array of parts
        "Color",          -- property
        src.Color         -- original color
    )
end)


    -- IMPORTANT: wait for the rate limit
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
    if cancelBuild then cancelBuild = false end

    local id = tonumber(idBox.Text)
    if not id then
        statusLabel.Text = "ID must be numbers only"
        return
    end

    statusLabel.Text = "Starting..."
    task.spawn(function()
        buildModelSimple(id)
        if previewEnabled then destroyGhost() end
    end)
end)
