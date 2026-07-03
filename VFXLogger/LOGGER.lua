--// VFX Logger Explorer GUI
-- Place as a LocalScript (e.g. StarterPlayerScripts or executor)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer

--////////////////////////////////////////////////////
-- Utility
--////////////////////////////////////////////////////

local function getCharacter()
    return localPlayer.Character or localPlayer.CharacterAdded:Wait()
end

local function getHRP(char)
    return char:FindFirstChild("HumanoidRootPart")
end

local function isVFXInstance(inst)
    -- You can expand this list
    local class = inst.ClassName
    if class == "ParticleEmitter" or class == "Trail" or class == "Beam" or class == "Attachment" then
        return true
    end
    return false
end

local function findAttachmentForVFX(inst)
    if inst:IsA("Attachment") then
        return inst
    end
    local attachment = inst:FindFirstAncestorWhichIsA("Attachment")
    return attachment
end

local function getPlayerFromCharacter(char)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == char then
            return plr
        end
    end
    return nil
end

--////////////////////////////////////////////////////
-- GUI Creation
--////////////////////////////////////////////////////

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VFX_Logger"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.DisplayOrder = 99999 -- overlap others
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Toggle button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 100, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
toggleButton.Text = "Toggle GUI"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = screenGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 600, 0, 350)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(0, 200, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
itleLabel.Text = "VFX Logger"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

local settingsButton = Instance.new("TextButton")
settingsButton.Name = "SettingsButton"
settingsButton.Size = UDim2.new(0, 80, 1, 0)
settingsButton.Position = UDim2.new(1, -88, 0, 0)
settingsButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
settingsButton.Text = "Settings"
settingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsButton.Font = Enum.Font.Gotham
settingsButton.TextSize = 14
settingsButton.Parent = topBar

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 6)
settingsCorner.Parent = settingsButton

-- Left: Explorer
local explorerFrame = Instance.new("Frame")
explorerFrame.Name = "ExplorerFrame"
explorerFrame.Size = UDim2.new(0.45, 0, 1, -30)
explorerFrame.Position = UDim2.new(0, 0, 0, 30)
explorerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
explorerFrame.BorderSizePixel = 0
explorerFrame.Parent = mainFrame

local explorerLabel = Instance.new("TextLabel")
explorerLabel.Name = "ExplorerLabel"
explorerLabel.Size = UDim2.new(1, 0, 0, 20)
explorerLabel.Position = UDim2.new(0, 0, 0, 0)
explorerLabel.BackgroundTransparency = 1
explorerLabel.Text = "VFX Explorer"
explorerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
explorerLabel.Font = Enum.Font.GothamBold
explorerLabel.TextSize = 14
explorerLabel.TextXAlignment = Enum.TextXAlignment.Left
explorerLabel.Parent = explorerFrame

local explorerScroll = Instance.new("ScrollingFrame")
explorerScroll.Name = "ExplorerScroll"
explorerScroll.Size = UDim2.new(1, -4, 1, -24)
explorerScroll.Position = UDim2.new(0, 2, 0, 22)
explorerScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
explorerScroll.BorderSizePixel = 0
explorerScroll.ScrollBarThickness = 6
explorerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
explorerScroll.Parent = explorerFrame

local explorerLayout = Instance.new("UIListLayout")
explorerLayout.SortOrder = Enum.SortOrder.LayoutOrder
explorerLayout.Parent = explorerScroll

-- Right: Properties
local propertiesFrame = Instance.new("Frame")
propertiesFrame.Name = "PropertiesFrame"
propertiesFrame.Size = UDim2.new(0.55, 0, 1, -30)
propertiesFrame.Position = UDim2.new(0.45, 0, 0, 30)
propertiesFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
propertiesFrame.BorderSizePixel = 0
propertiesFrame.Parent = mainFrame

local propertiesLabel = Instance.new("TextLabel")
propertiesLabel.Name = "PropertiesLabel"
propertiesLabel.Size = UDim2.new(1, 0, 0, 20)
propertiesLabel.Position = UDim2.new(0, 0, 0, 0)
propertiesLabel.BackgroundTransparency = 1
propertiesLabel.Text = "Properties"
propertiesLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
propertiesLabel.Font = Enum.Font.GothamBold
propertiesLabel.TextSize = 14
propertiesLabel.TextXAlignment = Enum.TextXAlignment.Left
propertiesLabel.Parent = propertiesFrame

local propertiesScroll = Instance.new("ScrollingFrame")
propertiesScroll.Name = "PropertiesScroll"
propertiesScroll.Size = UDim2.new(1, -4, 1, -60)
propertiesScroll.Position = UDim2.new(0, 2, 0, 22)
propertiesScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
propertiesScroll.BorderSizePixel = 0
propertiesScroll.ScrollBarThickness = 6
propertiesScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
propertiesScroll.Parent = propertiesFrame

local propertiesLayout = Instance.new("UIListLayout")
propertiesLayout.SortOrder = Enum.SortOrder.LayoutOrder
propertiesLayout.Parent = propertiesScroll

local playButton = Instance.new("TextButton")
playButton.Name = "PlayButton"
playButton.Size = UDim2.new(0, 80, 0, 24)
playButton.Position = UDim2.new(0, 8, 1, -28)
playButton.BackgroundColor3 = Color3.fromRGB(60, 180, 75)
playButton.Text = "Play"
playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playButton.Font = Enum.Font.GothamBold
playButton.TextSize = 14
playButton.Parent = propertiesFrame

local playCorner = Instance.new("UICorner")
playCorner.CornerRadius = UDim.new(0, 6)
playCorner.Parent = playButton

local stopButton = Instance.new("TextButton")
stopButton.Name = "StopButton"
stopButton.Size = UDim2.new(0, 80, 0, 24)
stopButton.Position = UDim2.new(0, 96, 1, -28)
stopButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
stopButton.Text = "Stop"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 14
stopButton.Parent = propertiesFrame

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 6)
stopCorner.Parent = stopButton

-- Settings panel
local settingsFrame = Instance.new("Frame")
settingsFrame.Name = "SettingsFrame"
settingsFrame.Size = UDim2.new(0, 200, 0, 140)
settingsFrame.Position = UDim2.new(1, -210, 0, 34)
settingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
settingsFrame.BorderSizePixel = 0
settingsFrame.Visible = false
settingsFrame.Parent = mainFrame

local settingsCorner2 = Instance.new("UICorner")
settingsCorner2.CornerRadius = UDim.new(0, 8)
settingsCorner2.Parent = settingsFrame

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Name = "SettingsTitle"
settingsTitle.Size = UDim2.new(1, 0, 0, 20)
settingsTitle.Position = UDim2.new(0, 0, 0, 0)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "Settings"
settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 14
settingsTitle.TextXAlignment = Enum.TextXAlignment.Center
settingsTitle.Parent = settingsFrame

local clearButton = Instance.new("TextButton")
clearButton.Name = "ClearButton"
clearButton.Size = UDim2.new(1, -16, 0, 24)
clearButton.Position = UDim2.new(0, 8, 0, 26)
clearButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
clearButton.Text = "Clear All Logs"
clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearButton.Font = Enum.Font.Gotham
clearButton.TextSize = 14
clearButton.Parent = settingsFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 6)
clearCorner.Parent = clearButton

local stopLoggingButton = Instance.new("TextButton")
stopLoggingButton.Name = "StopLoggingButton"
stopLoggingButton.Size = UDim2.new(1, -16, 0, 24)
stopLoggingButton.Position = UDim2.new(0, 8, 0, 56)
stopLoggingButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
stopLoggingButton.Text = "Stop Logging: OFF"
stopLoggingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopLoggingButton.Font = Enum.Font.Gotham
stopLoggingButton.TextSize = 14
stopLoggingButton.Parent = settingsFrame

local stopLoggingCorner = Instance.new("UICorner")
stopLoggingCorner.CornerRadius = UDim.new(0, 6)
stopLoggingCorner.Parent = stopLoggingButton

local logNPCButton = Instance.new("TextButton")
logNPCButton.Name = "LogNPCButton"
logNPCButton.Size = UDim2.new(1, -16, 0, 24)
logNPCButton.Position = UDim2.new(0, 8, 0, 86)
logNPCButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
logNPCButton.Text = "Log NPCs/Players: OFF"
logNPCButton.TextColor3 = Color3.fromRGB(255, 255, 255)
logNPCButton.Font = Enum.Font.Gotham
logNPCButton.TextSize = 14
logNPCButton.Parent = settingsFrame

local logNPCCorner = Instance.new("UICorner")
logNPCCorner.CornerRadius = UDim.new(0, 6)
logNPCCorner.Parent = logNPCButton

--////////////////////////////////////////////////////
-- State
--////////////////////////////////////////////////////

local loggedAttachments = {}      -- [Attachment] = true
local explorerItems = {}          -- [Instance] = {Button=..., ChildrenButtons={...}, Expanded=false}
local selectedInstance = nil
local stopLogging = false
local logOthers = false

local activePlayPart = nil
local activePlayCloneRoot = nil

--////////////////////////////////////////////////////
-- Explorer item creation
--////////////////////////////////////////////////////

local DOUBLE_CLICK_TIME = 0.25

local function createExplorerItem(inst, depth)
    local itemFrame = Instance.new("TextButton")
    itemFrame.Name = "Item_" .. inst:GetDebugId()
    itemFrame.Size = UDim2.new(1, -4, 0, 20)
    itemFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    itemFrame.TextColor3 = Color3.fromRGB(220, 220, 220)
    itemFrame.Font = Enum.Font.Gotham
    itemFrame.TextSize = 13
    itemFrame.TextXAlignment = Enum.TextXAlignment.Left
    itemFrame.Text = string.rep("   ", depth) .. inst.Name .. " [" .. inst.ClassName .. "]"
    itemFrame.Parent = explorerScroll

    local lastClickTime = 0
    local clickCount = 0

    explorerItems[inst] = explorerItems[inst] or {
        Button = itemFrame,
        ChildrenButtons = {},
        Expanded = false,
        Depth = depth
    }

    local function toggleExpand()
        local info = explorerItems[inst]
        if not info then return end
        info.Expanded = not info.Expanded

        if info.Expanded then
            -- Show children
            for _, child in ipairs(inst:GetChildren()) do
                local childButton = createExplorerItem(child, depth + 1)
                table.insert(info.ChildrenButtons, childButton)
            end
        else
            -- Hide children
            for _, btn in ipairs(info.ChildrenButtons) do
                btn:Destroy()
            end
            info.ChildrenButtons = {}
        end
    end

    local function showProperties()
        selectedInstance = inst

        for _, child in ipairs(propertiesScroll:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end

        local function addPropLine(text)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -4, 0, 18)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.Font = Enum.Font.Gotham
            label.TextSize = 12
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = text
            label.Parent = propertiesScroll
        end

        addPropLine("Name: " .. inst.Name)
        addPropLine("Class: " .. inst.ClassName)
        if inst.Parent then
            addPropLine("Parent: " .. inst.Parent:GetFullName())
        else
            addPropLine("Parent: nil")
        end

        -- Basic properties dump (safe ones)
        pcall(function()
            for _, prop in ipairs(inst:GetAttributes()) do
                local val = inst:GetAttribute(prop)
                addPropLine("Attr " .. prop .. ": " .. tostring(val))
            end
        end)

        -- Some common properties
        pcall(function()
            if inst:IsA("ParticleEmitter") then
                addPropLine("Enabled: " .. tostring(inst.Enabled))
                addPropLine("Rate: " .. tostring(inst.Rate))
                addPropLine("Lifetime: " .. tostring(inst.Lifetime))
            elseif inst:IsA("Trail") then
                addPropLine("Enabled: " .. tostring(inst.Enabled))
                addPropLine("Lifetime: " .. tostring(inst.Lifetime))
            elseif inst:IsA("Beam") then
                addPropLine("Enabled: " .. tostring(inst.Enabled))
                addPropLine("Brightness: " .. tostring(inst.Brightness))
            elseif inst:IsA("Attachment") then
                addPropLine("Position: " .. tostring(inst.Position))
                addPropLine("WorldPosition: " .. tostring(inst.WorldPosition))
            end
        end)

        propertiesScroll.CanvasSize = UDim2.new(0, 0, 0, propertiesLayout.AbsoluteContentSize.Y)
    end

    itemFrame.MouseButton1Click:Connect(function()
        local now = tick()
        if now - lastClickTime <= DOUBLE_CLICK_TIME then
            clickCount = clickCount + 1
        else
            clickCount = 1
        end
        lastClickTime = now

        if clickCount >= 2 then
            -- Double click: expand/collapse
            toggleExpand()
            clickCount = 0
        else
            -- Single click: show properties
            showProperties()
        end
    end)

    explorerScroll.CanvasSize = UDim2.new(0, 0, 0, explorerLayout.AbsoluteContentSize.Y)
    return itemFrame
end

--////////////////////////////////////////////////////
-- Logging VFX
--////////////////////////////////////////////////////

local function logAttachment(att)
    if loggedAttachments[att] then return end
    loggedAttachments[att] = true

    -- Root entry: the attachment itself
    createExplorerItem(att, 0)
end

local function shouldLogInstance(inst)
    local char = inst:FindFirstAncestorWhichIsA("Model")
    if not char then return false end

    local plr = getPlayerFromCharacter(char)
    if plr == localPlayer then
        return true
    end

    if logOthers then
        return true
    end

    return false
end

local function processNewInstance(inst)
    if not isVFXInstance(inst) then return end
    if not shouldLogInstance(inst) then return end

    local attachment = findAttachmentForVFX(inst)
    if attachment then
        logAttachment(attachment)
    end
end

local function hookCharacter(char)
    -- Log existing VFX in character
    for _, desc in ipairs(char:GetDescendants()) do
        processNewInstance(desc)
    end

    char.DescendantAdded:Connect(function(desc)
        if stopLogging then return end
        processNewInstance(desc)
    end)
end

local function hookWorkspaceForOthers()
    Workspace.DescendantAdded:Connect(function(desc)
        if stopLogging then return end
        if not logOthers then return end
        processNewInstance(desc)
    end)
end

--////////////////////////////////////////////////////
-- Play / Stop VFX
--////////////////////////////////////////////////////

local function clearPlayPart()
    if activePlayCloneRoot then
        activePlayCloneRoot:Destroy()
        activePlayCloneRoot = nil
    end
    if activePlayPart then
        activePlayPart:Destroy()
        activePlayPart = nil
    end
end

local function playSelected()
    if not selectedInstance then return end

    clearPlayPart()

    local char = getCharacter()
    local hrp = getHRP(char)
    if not hrp then return end

    local forward = hrp.CFrame.LookVector
    local spawnPos = hrp.Position + forward * 5

    local part = Instance.new("Part")
    part.Name = "VFXLoggerPlayPart"
    part.Size = Vector3.new(1, 1, 1)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.CFrame = CFrame.new(spawnPos)
    part.Parent = Workspace

    activePlayPart = part

    local attachmentToUse = nil
    if selectedInstance:IsA("Attachment") then
        attachmentToUse = selectedInstance
    else
        attachmentToUse = findAttachmentForVFX(selectedInstance)
    end

    if not attachmentToUse then
        -- Just attach a blank attachment and clone children if any
        local att = Instance.new("Attachment")
        att.Name = "VFXLoggerAttachment"
        att.Parent = part
        attachmentToUse = att
    else
        -- Clone attachment and its children to the part
        local clonedAttachment = attachmentToUse:Clone()
        clonedAttachment.Parent = part
        attachmentToUse = clonedAttachment
    end

    activePlayCloneRoot = attachmentToUse

    -- Enable any VFX children
    for _, child in ipairs(attachmentToUse:GetDescendants()) do
        if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("Beam") then
            pcall(function()
                child.Enabled = true
            end)
        end
    end
end

local function stopSelected()
    if activePlayCloneRoot then
        for _, child in ipairs(activePlayCloneRoot:GetDescendants()) do
            if child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("Beam") then
                pcall(function()
                    child.Enabled = false
                end)
            end
        end
    end
    clearPlayPart()
end

playButton.MouseButton1Click:Connect(playSelected)
stopButton.MouseButton1Click:Connect(stopSelected)

--////////////////////////////////////////////////////
-- Settings behavior
--////////////////////////////////////////////////////

settingsButton.MouseButton1Click:Connect(function()
    settingsFrame.Visible = not settingsFrame.Visible
end)

clearButton.MouseButton1Click:Connect(function()
    -- Clear explorer and logs
    loggedAttachments = {}
    explorerItems = {}
    selectedInstance = nil

    for _, child in ipairs(explorerScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, child in ipairs(propertiesScroll:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    clearPlayPart()
end)

stopLoggingButton.MouseButton1Click:Connect(function()
    stopLogging = not stopLogging
    if stopLogging then
        stopLoggingButton.Text = "Stop Logging: ON"
        stopLoggingButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    else
        stopLoggingButton.Text = "Stop Logging: OFF"
        stopLoggingButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

logNPCButton.MouseButton1Click:Connect(function()
    logOthers = not logOthers
    if logOthers then
        logNPCButton.Text = "Log NPCs/Players: ON"
        logNPCButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    else
        logNPCButton.Text = "Log NPCs/Players: OFF"
        logNPCButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

--////////////////////////////////////////////////////
-- Init
--////////////////////////////////////////////////////

local function init()
    local char = getCharacter()
    hookCharacter(char)

    localPlayer.CharacterAdded:Connect(function(newChar)
        hookCharacter(newChar)
    end)

    hookWorkspaceForOthers()
end

init()
