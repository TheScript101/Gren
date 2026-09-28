--[[
    MOBILE EFFECT EXPLORER - PERSISTENT LOGGER
    ============================================

    Client-side / mobile-friendly

    Watches:
        workspace.Effects

    Ignores:
        Crows
        CamIgnore
        Bolt
        Blood

    Features:
        • Persistent object log
        • Destroyed objects remain in the log
        • Automatically captures newly-created objects
        • Recursive hierarchy
        • Mobile tap controls
        • Expand / collapse
        • Search
        • Scrollable explorer
        • Scrollable information panel
        • Spawn selected object 5 studs in front
        • SpecialMesh information
        • Beam information
        • Trail information
        • ParticleEmitter information
        • Lights
        • MeshParts
        • Attachments
        • Models / Folders / Parts
--]]

------------------------------------------------------------
-- SERVICES
------------------------------------------------------------

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

if not player then
    warn("[Effect Explorer] LocalPlayer not found.")
    return
end

local playerGui = player:WaitForChild("PlayerGui")

------------------------------------------------------------
-- CHARACTER
------------------------------------------------------------

local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter

    task.spawn(function()
        hrp = newCharacter:WaitForChild("HumanoidRootPart")
    end)
end)

------------------------------------------------------------
-- EFFECTS FOLDER
------------------------------------------------------------

local effectsFolder = workspace:FindFirstChild("Effects")

if not effectsFolder then
    warn("[Effect Explorer] workspace.Effects was not found.")
    return
end

------------------------------------------------------------
-- IGNORED OBJECTS
------------------------------------------------------------

local ignoredNames = {
    Crows = true,
    CamIgnore = true,
    Bolt = true,
    Blood = true
}

local function isIgnored(obj)

    local current = obj

    while current and current ~= effectsFolder do

        if ignoredNames[current.Name] then
            return true
        end

        current = current.Parent
    end

    return false
end

------------------------------------------------------------
-- REMOVE OLD GUI
------------------------------------------------------------

pcall(function()

    local old = playerGui:FindFirstChild("MobileEffectExplorer")

    if old then
        old:Destroy()
    end

end)

------------------------------------------------------------
-- GUI
------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "MobileEffectExplorer"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    gui.DisplayOrder = 999999
end)

gui.Parent = playerGui

------------------------------------------------------------
-- MAIN WINDOW
------------------------------------------------------------

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0.94, 0, 0.88, 0)
main.Position = UDim2.new(0.03, 0, 0.06, 0)
main.BackgroundColor3 = Color3.fromRGB(27, 27, 31)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

------------------------------------------------------------
-- HEADER
------------------------------------------------------------

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 46)
header.BackgroundColor3 = Color3.fromRGB(46, 46, 53)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -115, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Effect Logger"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

------------------------------------------------------------
-- CLOSE
------------------------------------------------------------

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 40, 0, 34)
closeButton.Position = UDim2.new(1, -46, 0, 6)
closeButton.BackgroundColor3 = Color3.fromRGB(145, 55, 55)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 17
closeButton.BorderSizePixel = 0
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = closeButton

closeButton.Activated:Connect(function()
    gui:Destroy()
end)

------------------------------------------------------------
-- SEARCH
------------------------------------------------------------

local search = Instance.new("TextBox")
search.Size = UDim2.new(1, -120, 0, 38)
search.Position = UDim2.new(0, 10, 0, 55)
search.BackgroundColor3 = Color3.fromRGB(44, 44, 49)
search.BorderSizePixel = 0
search.Text = ""
search.PlaceholderText = "Search logged objects..."
search.PlaceholderColor3 = Color3.fromRGB(145, 145, 145)
search.TextColor3 = Color3.new(1, 1, 1)
search.TextSize = 15
search.Font = Enum.Font.Gotham
search.ClearTextOnFocus = false
search.Parent = main

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 7)
searchCorner.Parent = search

------------------------------------------------------------
-- REFRESH
------------------------------------------------------------

local refresh = Instance.new("TextButton")
refresh.Size = UDim2.new(0, 90, 0, 38)
refresh.Position = UDim2.new(1, -100, 0, 55)
refresh.BackgroundColor3 = Color3.fromRGB(65, 90, 125)
refresh.Text = "Refresh"
refresh.TextColor3 = Color3.new(1, 1, 1)
refresh.TextSize = 14
refresh.Font = Enum.Font.GothamBold
refresh.BorderSizePixel = 0
refresh.Parent = main

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 7)
refreshCorner.Parent = refresh

------------------------------------------------------------
-- LOGGER COUNT
------------------------------------------------------------

local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -20, 0, 25)
countLabel.Position = UDim2.new(0, 10, 0, 97)
countLabel.BackgroundTransparency = 1
countLabel.Text = "Logged: 0"
countLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
countLabel.TextSize = 13
countLabel.Font = Enum.Font.Gotham
countLabel.TextXAlignment = Enum.TextXAlignment.Left
countLabel.Parent = main

------------------------------------------------------------
-- EXPLORER
------------------------------------------------------------

local explorer = Instance.new("ScrollingFrame")
explorer.Name = "Explorer"
explorer.Size = UDim2.new(1, -20, 0.53, 0)
explorer.Position = UDim2.new(0, 10, 0, 125)
explorer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
explorer.BorderSizePixel = 0
explorer.ScrollBarThickness = 7
explorer.ScrollingDirection = Enum.ScrollingDirection.Y
explorer.AutomaticCanvasSize = Enum.AutomaticSize.Y
explorer.CanvasSize = UDim2.new(0, 0, 0, 0)
explorer.Parent = main

local explorerCorner = Instance.new("UICorner")
explorerCorner.CornerRadius = UDim.new(0, 7)
explorerCorner.Parent = explorer

local explorerList = Instance.new("UIListLayout")
explorerList.SortOrder = Enum.SortOrder.LayoutOrder
explorerList.Padding = UDim.new(0, 2)
explorerList.Parent = explorer

------------------------------------------------------------
-- INFO TITLE
------------------------------------------------------------

local infoTitle = Instance.new("TextLabel")
infoTitle.Size = UDim2.new(1, -20, 0, 28)
infoTitle.Position = UDim2.new(0, 10, 0.685, 0)
infoTitle.BackgroundTransparency = 1
infoTitle.Text = "Object Information"
infoTitle.TextColor3 = Color3.new(1, 1, 1)
infoTitle.Font = Enum.Font.GothamBold
infoTitle.TextSize = 16
infoTitle.TextXAlignment = Enum.TextXAlignment.Left
infoTitle.Parent = main

------------------------------------------------------------
-- INFO SCROLL
------------------------------------------------------------

local infoScroll = Instance.new("ScrollingFrame")
infoScroll.Name = "InfoScroll"
infoScroll.Size = UDim2.new(1, -20, 0.20, 0)
infoScroll.Position = UDim2.new(0, 10, 0.72, 0)
infoScroll.BackgroundColor3 = Color3.fromRGB(38, 38, 43)
infoScroll.BorderSizePixel = 0
infoScroll.ScrollBarThickness = 6
infoScroll.ScrollingDirection = Enum.ScrollingDirection.Y
infoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
infoScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
infoScroll.Parent = main

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 7)
infoCorner.Parent = infoScroll

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -14, 0, 0)
infoText.Position = UDim2.new(0, 7, 0, 7)
infoText.AutomaticSize = Enum.AutomaticSize.Y
infoText.BackgroundTransparency = 1
infoText.Text = "Tap an object to inspect it."
infoText.TextColor3 = Color3.new(1, 1, 1)
infoText.Font = Enum.Font.Code
infoText.TextSize = 14
infoText.TextWrapped = true
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = infoScroll

------------------------------------------------------------
-- SPAWN BUTTON
------------------------------------------------------------

local spawnButton = Instance.new("TextButton")
spawnButton.Name = "SpawnButton"
spawnButton.Size = UDim2.new(1, -20, 0, 40)
spawnButton.Position = UDim2.new(0, 10, 0.93, 0)
spawnButton.BackgroundColor3 = Color3.fromRGB(65, 115, 75)
spawnButton.Text = "Spawn Selected 5 Studs In Front"
spawnButton.TextColor3 = Color3.new(1, 1, 1)
spawnButton.Font = Enum.Font.GothamBold
spawnButton.TextSize = 14
spawnButton.BorderSizePixel = 0
spawnButton.Parent = main

local spawnCorner = Instance.new("UICorner")
spawnCorner.CornerRadius = UDim.new(0, 7)
spawnCorner.Parent = spawnButton

------------------------------------------------------------
-- DATA
------------------------------------------------------------

local loggedObjects = {}
local expanded = {}
local rows = {}

local selectedEntry = nil

------------------------------------------------------------
-- SNAPSHOT HELPERS
------------------------------------------------------------

local function safeValue(callback)

    local success, result = pcall(callback)

    if success then
        return result
    end

    return nil
end

local function vectorString(value)

    if value == nil then
        return "N/A"
    end

    return tostring(value)
end

------------------------------------------------------------
-- CAPTURE SNAPSHOT
------------------------------------------------------------

local function capture(obj)

    if not obj then
        return nil
    end

    if isIgnored(obj) then
        return nil
    end

    local snapshot = {
        name = obj.Name,
        className = obj.ClassName,
        fullName = safeValue(function()
            return obj:GetFullName()
        end) or obj.Name,

        parentName = obj.Parent and obj.Parent.Name or "nil",

        original = obj,

        destroyed = false,

        properties = {}
    }

    local p = snapshot.properties

------------------------------------------------------------
-- REBUILD EXPLORER
------------------------------------------------------------

    local function rebuildExplorer()
    -- Clear old rows
    for _, row in pairs(rows) do
        row:Destroy()
    end
    rows = {}

    local entries = getEntries()
    local searchText = string.lower(search.Text)

    countLabel.Text = "Logged: " .. tostring(#entries)

    for _, snapshot in ipairs(entries) do
        if isEntryVisible(snapshot) then
            if searchText == "" or string.find(string.lower(snapshot.fullName), searchText) then
                
                local depth = getDepth(snapshot)

                local row = Instance.new("TextButton")
                row.Size = UDim2.new(1, -4, 0, 24)
                row.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                row.TextColor3 = Color3.new(1, 1, 1)
                row.Font = Enum.Font.Gotham
                row.TextSize = 13
                row.TextXAlignment = Enum.TextXAlignment.Left
                row.Text = string.rep("   ", depth) .. snapshot.fullName
                row.Parent = explorer

                rows[snapshot] = row

                row.Activated:Connect(function()
                    displaySnapshot(snapshot)
                end)
            end
        end
    end
end


    --------------------------------------------------------
    -- COMMON
    --------------------------------------------------------

    p.Children = #obj:GetChildren()

    --------------------------------------------------------
    -- BASE PART
    --------------------------------------------------------

    if obj:IsA("BasePart") then

        p.Size = vectorString(
            safeValue(function()
                return obj.Size
            end)
        )

        p.Position = vectorString(
            safeValue(function()
                return obj.Position
            end)
        )

        p.Color = vectorString(
            safeValue(function()
                return obj.Color
            end)
        )

        p.Material = tostring(
            safeValue(function()
                return obj.Material
            end)
            or "N/A"
        )

        p.Transparency = tostring(
            safeValue(function()
                return obj.Transparency
            end)
            or "N/A"
        )

        p.Anchored = tostring(
            safeValue(function()
                return obj.Anchored
            end)
            or "N/A"
        )

    end

    --------------------------------------------------------
    -- MESH PART
    --------------------------------------------------------

    if obj:IsA("MeshPart") then

        p.MeshId = tostring(
            safeValue(function()
                return obj.MeshId
            end)
            or "N/A"
        )

        p.TextureID = tostring(
            safeValue(function()
                return obj.TextureID
            end)
            or "N/A"
        )

    end

    --------------------------------------------------------
    -- SPECIAL MESH
    --------------------------------------------------------

    if obj:IsA("SpecialMesh") then

        p.MeshType = tostring(
            safeValue(function()
                return obj.MeshType
            end)
            or "N/A"
        )

        p.MeshId = tostring(
            safeValue(function()
                return obj.MeshId
            end)
            or "N/A"
        )

        p.TextureId = tostring(
            safeValue(function()
                return obj.TextureId
            end)
            or "N/A"
        )

        p.Scale = vectorString(
            safeValue(function()
                return obj.Scale
            end)
        )

        p.Offset = vectorString(
            safeValue(function()
                return obj.Offset
            end)
        )

        p.VertexColor = vectorString(
            safeValue(function()
                return obj.VertexColor
            end)
        )

    end

    --------------------------------------------------------
    -- PARTICLE
    --------------------------------------------------------

    if obj:IsA("ParticleEmitter") then

        p.Enabled = tostring(obj.Enabled)
        p.Texture = tostring(obj.Texture)
        p.Rate = tostring(obj.Rate)
        p.Lifetime = tostring(obj.Lifetime)
        p.Speed = tostring(obj.Speed)
        p.SpreadAngle = tostring(obj.SpreadAngle)
        p.LightEmission = tostring(obj.LightEmission)
        p.LightInfluence = tostring(obj.LightInfluence)
        p.ZOffset = tostring(obj.ZOffset)

    end

    --------------------------------------------------------
    -- BEAM
    --------------------------------------------------------

    if obj:IsA("Beam") then

        p.Enabled = tostring(obj.Enabled)
        p.Texture = tostring(obj.Texture)
        p.Width0 = tostring(obj.Width0)
        p.Width1 = tostring(obj.Width1)
        p.Segments = tostring(obj.Segments)
        p.TextureLength = tostring(obj.TextureLength)
        p.TextureSpeed = tostring(obj.TextureSpeed)

        p.Attachment0 = obj.Attachment0
            and obj.Attachment0:GetFullName()
            or "None"

        p.Attachment1 = obj.Attachment1
            and obj.Attachment1:GetFullName()
            or "None"

    end

    --------------------------------------------------------
    -- TRAIL
    --------------------------------------------------------

    if obj:IsA("Trail") then

        p.Enabled = tostring(obj.Enabled)
        p.Texture = tostring(obj.Texture)
        p.Lifetime = tostring(obj.Lifetime)
        p.MinLength = tostring(obj.MinLength)

        p.Attachment0 = obj.Attachment0
            and obj.Attachment0:GetFullName()
            or "None"

        p.Attachment1 = obj.Attachment1
            and obj.Attachment1:GetFullName()
            or "None"

    end

    --------------------------------------------------------
    -- LIGHT
    --------------------------------------------------------

    if obj:IsA("Light") then

        p.Enabled = tostring(obj.Enabled)
        p.Brightness = tostring(obj.Brightness)
        p.Range = tostring(obj.Range)
        p.Color = tostring(obj.Color)
        p.Shadows = tostring(obj.Shadows)

    end

    --------------------------------------------------------
    -- HIGHLIGHT
    --------------------------------------------------------

    if obj:IsA("Highlight") then

        p.Enabled = tostring(obj.Enabled)
        p.FillColor = tostring(obj.FillColor)
        p.FillTransparency = tostring(obj.FillTransparency)
        p.OutlineColor = tostring(obj.OutlineColor)
        p.OutlineTransparency = tostring(obj.OutlineTransparency)

    end

    --------------------------------------------------------
    -- DECAL / TEXTURE
    --------------------------------------------------------

    if obj:IsA("Decal") or obj:IsA("Texture") then

        p.Texture = tostring(obj.Texture)
        p.Transparency = tostring(obj.Transparency)

    end

    --------------------------------------------------------
    -- FIRE / SMOKE / SPARKLES
    --------------------------------------------------------

    if obj:IsA("Fire") then

        p.Enabled = tostring(obj.Enabled)
        p.Heat = tostring(obj.Heat)
        p.Size = tostring(obj.Size)
        p.Color = tostring(obj.Color)
        p.SecondaryColor = tostring(obj.SecondaryColor)

    elseif obj:IsA("Smoke") then

        p.Enabled = tostring(obj.Enabled)
        p.Opacity = tostring(obj.Opacity)
        p.Size = tostring(obj.Size)
        p.Color = tostring(obj.Color)

    elseif obj:IsA("Sparkles") then

        p.Enabled = tostring(obj.Enabled)
        p.SparkleColor = tostring(obj.SparkleColor)

    end

    --------------------------------------------------------
    -- MODEL
    --------------------------------------------------------

    if obj:IsA("Model") then

        if obj.PrimaryPart then
            p.PrimaryPart = obj.PrimaryPart.Name
        else
            p.PrimaryPart = "None"
        end

    end

    return snapshot

end

------------------------------------------------------------
-- LOG OBJECT
------------------------------------------------------------

local function logObject(obj)

    if not obj then
        return
    end

    if isIgnored(obj) then
        return
    end

    if loggedObjects[obj] then
        return
    end

    local snapshot = capture(obj)

    if not snapshot then
        return
    end

    loggedObjects[obj] = snapshot

    --------------------------------------------------------
    -- KEEP SNAPSHOT AFTER DESTRUCTION
    --------------------------------------------------------

    obj.AncestryChanged:Connect(function(_, parent)

        if not parent then
            snapshot.destroyed = true
        end

    end)

end

------------------------------------------------------------
-- INITIAL SCAN
------------------------------------------------------------

for _, obj in ipairs(effectsFolder:GetDescendants()) do
    logObject(obj)
end

------------------------------------------------------------
-- CONTINUOUS CAPTURE
------------------------------------------------------------

effectsFolder.DescendantAdded:Connect(function(obj)

    if not isIgnored(obj) then
        logObject(obj)
    end

end)

------------------------------------------------------------
-- ALL LOGGED ENTRIES
------------------------------------------------------------

local function getEntries()

    local entries = {}

    for _, snapshot in pairs(loggedObjects) do

        if snapshot then
            table.insert(entries, snapshot)
        end

    end

    table.sort(entries, function(a, b)

        return a.fullName < b.fullName

    end)

    return entries

end

------------------------------------------------------------
-- VISIBILITY
------------------------------------------------------------

local function isEntryVisible(snapshot)

    local obj = snapshot.original

    --------------------------------------------------------
    -- If object still exists, use live hierarchy
    --------------------------------------------------------

    if obj and obj.Parent then

        local parent = obj.Parent

        while parent and parent ~= effectsFolder do

            if expanded[parent] == false then
                return false
            end

            parent = parent.Parent

        end

        return true

    end

    --------------------------------------------------------
    -- Destroyed objects remain visible.
    -- Their last known hierarchy is represented by their path.
    --------------------------------------------------------

    return true

end

------------------------------------------------------------
-- DEPTH
------------------------------------------------------------

local function getDepth(snapshot)

    local obj = snapshot.original

    if obj and obj.Parent then

        local depth = 0
        local parent = obj.Parent

        while parent and parent ~= effectsFolder do

            depth += 1
            parent = parent.Parent

        end

        return depth

    end

    --------------------------------------------------------
    -- Estimate depth from stored path
    --------------------------------------------------------

    local path = snapshot.fullName

    local count = 0

    for _ in string.gmatch(path, "%.") do
        count += 1
    end

    return math.max(0, count - 1)

end

------------------------------------------------------------
-- INFO DISPLAY
------------------------------------------------------------

local function displaySnapshot(snapshot)

    selectedEntry = snapshot

    if not snapshot then
        infoText.Text = "Nothing selected."
        return
    end

    local lines = {}

    table.insert(lines, "NAME: " .. snapshot.name)
    table.insert(lines, "TYPE: " .. snapshot.className)
    table.insert(lines, "")

    table.insert(lines, "PATH:")
    table.insert(lines, snapshot.fullName)

    table.insert(lines, "")

    if snapshot.destroyed then
        table.insert(lines, "STATUS: DESTROYED")
        table.insert(lines, "This is a stored snapshot.")
    else
        table.insert(lines, "STATUS: EXISTS")
    end

    table.insert(lines, "")
    table.insert(lines, "CHILDREN WHEN LOGGED: " ..
        tostring(snapshot.properties.Children or 0)
    )

    table.insert(lines, "")

    --------------------------------------------------------
    -- PROPERTIES
    --------------------------------------------------------

    for key, value in pairs(snapshot.properties) do

        if key ~= "Children" then

            table.insert(
                lines,
                tostring(key) .. ": " .. tostring(value)
            )

        end

    end

    infoText.Text = table.concat(lines, "\n")

    task.defer(function()

        infoScroll.CanvasPosition = Vector2.new(0, 0)

    end)

end

------------------------------------------------------------
-- SPAWN SPECIAL MESH
------------------------------------------------------------

local function spawnSpecialMesh(snapshot)

    local meshId = snapshot.properties.MeshId
    local textureId = snapshot.properties.TextureId

    local part = Instance.new("Part")

    part.Name = "LoggedMeshPreview"
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false

    part.Size = Vector3.new(4, 4, 4)

    --------------------------------------------------------
    -- COPY COLOR IF AVAILABLE
    --------------------------------------------------------

    if snapshot.properties.VertexColor then

        -- VertexColor is stored as a Vector3.
        -- Roblox SpecialMesh uses this as a multiplier.

    end

    --------------------------------------------------------
    -- POSITION
    --------------------------------------------------------

    if hrp then

        part.CFrame =
            hrp.CFrame * CFrame.new(0, 0, -5)

    end

    part.Parent = workspace

    --------------------------------------------------------
    -- SPECIAL MESH
    --------------------------------------------------------

    local mesh = Instance.new("SpecialMesh")

    if meshId and meshId ~= "N/A" then
        pcall(function()
            mesh.MeshId = meshId
        end)
    end

    if textureId and textureId ~= "N/A" then
        pcall(function()
            mesh.TextureId = textureId
        end)
    end

    if snapshot.properties.Scale then

        local scaleText = snapshot.properties.Scale

        local x, y, z = string.match(
            scaleText,
            "([%-%d%.]+),?%s*([%-%d%.]+),?%s*([%-%d%.]+)"
        )

        if x and y and z then

            mesh.Scale = Vector3.new(
                tonumber(x),
                tonumber(y),
                tonumber(z)
            )

        end

    end

    mesh.Parent = part

    task.delay(8, function()

        if part and part.Parent then
            part:Destroy()
        end

    end)

end

------------------------------------------------------------
-- SPAWN SELECTED
------------------------------------------------------------

spawnButton.Activated:Connect(function()

    if not selectedEntry then

        infoText.Text =
            "Nothing selected.\n\nTap an object first."

        return

    end

    --------------------------------------------------------
    -- SPECIAL MESH
    --------------------------------------------------------

    if selectedEntry.className == "SpecialMesh" then

        spawnSpecialMesh(selectedEntry)

        return

    end

    --------------------------------------------------------
    -- ORIGINAL OBJECT STILL EXISTS
    --------------------------------------------------------

    local obj = selectedEntry.original

    if not obj or not obj.Parent then

        infoText.Text =
            "This object has already been destroyed.\n\n" ..
            "Its information remains stored in the log, " ..
            "but the original instance no longer exists to clone."

        return

    end

    if not hrp then
        return
    end

    local spawnCFrame =
        hrp.CFrame * CFrame.new(0, 0, -5)

    --------------------------------------------------------
    -- PARTICLE EMITTER
    --------------------------------------------------------

    if obj:IsA("ParticleEmitter") then

        local part = Instance.new("Part")

        part.Name = "LoggedParticlePreview"
        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Transparency = 1
        part.Size = Vector3.new(1, 1, 1)
        part.CFrame = spawnCFrame
        part.Parent = workspace

        local attachment = Instance.new("Attachment")
        attachment.Parent = part

        local clone = obj:Clone()
        clone.Parent = attachment
        clone.Enabled = true

        task.delay(8, function()

            if part and part.Parent then
                part:Destroy()
            end

        end)

    --------------------------------------------------------
    -- BEAM
    --------------------------------------------------------

    elseif obj:IsA("Beam") then

        local part0 = Instance.new("Part")
        part0.Name = "BeamPreview0"
        part0.Anchored = true
        part0.CanCollide = false
        part0.Transparency = 1
        part0.Size = Vector3.new(1, 1, 1)
        part0.CFrame = spawnCFrame
        part0.Parent = workspace

        local part1 = Instance.new("Part")
        part1.Name = "BeamPreview1"
        part1.Anchored = true
        part1.CanCollide = false
        part1.Transparency = 1
        part1.Size = Vector3.new(1, 1, 1)
        part1.CFrame =
            spawnCFrame * CFrame.new(0, 0, -10)
        part1.Parent = workspace

        local a0 = Instance.new("Attachment")
        a0.Parent = part0

        local a1 = Instance.new("Attachment")
        a1.Parent = part1

        local clone = obj:Clone()

        clone.Attachment0 = a0
        clone.Attachment1 = a1
        clone.Parent = part0
        clone.Enabled = true

        task.delay(8, function()

            if part0 then
                part0:Destroy()
            end

            if part1 then
                part1:Destroy()
            end

        end)

    --------------------------------------------------------
    -- TRAIL
    --------------------------------------------------------

    elseif obj:IsA("Trail") then

        local part0 = Instance.new("Part")
        part0.Anchored = true
        part0.CanCollide = false
        part0.Transparency = 1
        part0.Size = Vector3.new(1, 1, 1)
        part0.CFrame = spawnCFrame
        part0.Parent = workspace

        local part1 = Instance.new("Part")
        part1.Anchored = true
        part1.CanCollide = false
        part1.Transparency = 1
        part1.Size = Vector3.new(1, 1, 1)
        part1.CFrame =
            spawnCFrame * CFrame.new(0, 0, -3)
        part1.Parent = workspace

        local a0 = Instance.new("Attachment")
        a0.Parent = part0

        local a1 = Instance.new("Attachment")
        a1.Parent = part1

        local clone = obj:Clone()

        clone.Attachment0 = a0
        clone.Attachment1 = a1
        clone.Parent = part0
        clone.Enabled = true

        task.delay(8, function()

            part0:Destroy()
            part1:Destroy()

        end)

    --------------------------------------------------------
    -- MESH PART
    --------------------------------------------------------

    elseif obj:IsA("MeshPart") then

        local clone = obj:Clone()

        clone.Anchored = true
        clone.CanCollide = false
        clone.CFrame = spawnCFrame
        clone.Parent = workspace

        task.delay(8, function()

            if clone and clone.Parent then
                clone:Destroy()
            end

        end)

    --------------------------------------------------------
    -- LIGHT
    --------------------------------------------------------

    elseif obj:IsA("PointLight")
        or obj:IsA("SpotLight")
        or obj:IsA("SurfaceLight") then

        local part = Instance.new("Part")

        part.Name = "LoggedLightPreview"
        part.Anchored = true
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
        part.Transparency = 1
        part.Size = Vector3.new(1, 1, 1)
        part.CFrame = spawnCFrame
        part.Parent = workspace

        local clone = obj:Clone()
        clone.Parent = part
        clone.Enabled = true

        task.delay(8, function()
            part:Destroy()
        end)

    --------------------------------------------------------
    -- HIGHLIGHT
    --------------------------------------------------------

    elseif obj:IsA("Highlight") then

        local part = Instance.new("Part")

        part.Name = "HighlightPreview"
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.5
        part.Size = Vector3.new(3, 3, 3)
        part.CFrame = spawnCFrame
        part.Parent = workspace

        local clone = obj:Clone()
        clone.Adornee = part
        clone.Parent = part

        task.delay(8, function()
            part:Destroy()
        end)

    --------------------------------------------------------
    -- FIRE / SMOKE / SPARKLES
    --------------------------------------------------------

    elseif obj:IsA("Fire")
        or obj:IsA("Smoke")
        or obj:IsA("Sparkles") then

        local part = Instance.new("Part")

        part.Name = "LoggedEffectPreview"
        part.Anchored = true
        part.CanCollide = false
        part.Size = Vector3.new(2, 2, 2)
        part.CFrame = spawnCFrame
        part.Parent = workspace

        local clone = obj:Clone()
        clone.Parent = part

        task.delay(8, function()
            part:Destroy()
        end)

    --------------------------------------------------------
    -- MODEL
    --------------------------------------------------------

    elseif obj:IsA("Model") then

        local clone = obj:Clone()

        if clone:IsA("Model") then

            pcall(function()
                clone:PivotTo(spawnCFrame)
            end)

        end

        clone.Parent = workspace

        task.delay(8, function()

            if clone and clone.Parent then
                clone:Destroy()
            end

        end)

    --------------------------------------------------------
    -- BASE PART
    --------------------------------------------------------

    elseif obj:IsA("BasePart") then

        local clone = obj:Clone()

        clone.Anchored = true
        clone.CanCollide = false
        clone.CFrame = spawnCFrame
        clone.Parent = workspace

        task.delay(8, function()

            if clone and clone.Parent then
                clone:Destroy()
            end

        end)

    else

        infoText.Text =
            infoText.Text ..
            "\n\nNo spawn implementation for " ..
            obj.ClassName .. "."

    end

end)

------------------------------------------------------------
-- BUILD LOGGER
------------------------------------------------------------

function rebuild()

    for _, child in ipairs(explorer:GetChildren()) do

        if child:IsA("Frame") then
            child:Destroy()
        end

    end

    rows = {}

    local query =
        string.lower(search.Text or "")

    local entries = getEntries()

    local order = 0

    for _, snapshot in ipairs(entries) do

        if not isIgnored(snapshot.original)
            or snapshot.destroyed then

            local matches = true

            if query ~= "" then

                local name =
                    string.lower(snapshot.name)

                local className =
                    string.lower(snapshot.className)

                local path =
                    string.lower(snapshot.fullName)

                matches =
                    string.find(name, query, 1, true) ~= nil
                    or string.find(className, query, 1, true) ~= nil
                    or string.find(path, query, 1, true) ~= nil

            end

            if matches and isEntryVisible(snapshot) then

                order += 1

                local row =
                    Instance.new("Frame")

                row.Size =
                    UDim2.new(1, -8, 0, 42)

                row.BackgroundColor3 =
                    Color3.fromRGB(55, 55, 61)

                row.BorderSizePixel = 0
                row.LayoutOrder = order
                row.Parent = explorer

                ------------------------------------------------
                -- DEPTH
                ------------------------------------------------

                local depth =
                    getDepth(snapshot)

                ------------------------------------------------
                -- EXPAND
                ------------------------------------------------

                local expand =
                    Instance.new("TextButton")

                expand.Size =
                    UDim2.new(0, 35, 1, 0)

                expand.Position =
                    UDim2.new(
                        0,
                        depth * 16,
                        0,
                        0
                    )

                expand.BackgroundTransparency = 1
                expand.TextColor3 =
                    Color3.new(1, 1, 1)

                expand.TextSize = 16
                expand.Font =
                    Enum.Font.GothamBold

                expand.Parent = row

                local original =
                    snapshot.original

                local canExpand =
                    original
                    and (
                        original:IsA("Model")
                        or original:IsA("Folder")
                        or original:IsA("BasePart")
                        or original:IsA("Attachment")
                    )
                    and #original:GetChildren() > 0

                if canExpand then

                    if expanded[original] then
                        expand.Text = "▼"
                    else
                        expand.Text = "▶"
                    end

                    expand.Activated:Connect(function()

                        expanded[original] =
                            not expanded[original]

                        rebuild()

                    end)

                else

                    expand.Text = "•"

                end

                ------------------------------------------------
                -- OBJECT BUTTON
                ------------------------------------------------

                local button =
                    Instance.new("TextButton")

                button.Size =
                    UDim2.new(
                        1,
                        -(45 + depth * 16),
                        1,
                        0
                    )

                button.Position =
                    UDim2.new(
                        0,
                        40 + depth * 16,
                        0,
                        0
                    )

                button.BackgroundTransparency = 1

                button.TextColor3 =
                    Color3.new(1, 1, 1)

                button.TextSize = 14
                button.Font = Enum.Font.Gotham

                button.TextXAlignment =
                    Enum.TextXAlignment.Left

                local suffix = ""

                if isVFX(original) then

                    suffix =
                        "  [" ..
                        snapshot.className ..
                        "]"

                else

                    suffix =
                        "  (" ..
                        snapshot.className ..
                        ")"

                end

                if snapshot.destroyed then

                    suffix =
                        suffix ..
                        "  [DESTROYED]"

                end

                button.Text =
                    snapshot.name ..
                    suffix

                button.Parent = row

                ------------------------------------------------
                -- SELECT
                ------------------------------------------------

                button.Activated:Connect(function()

                    selectedEntry =
                        snapshot

                    displaySnapshot(snapshot)

                    for _, existingRow in pairs(rows) do

                        if existingRow
                            and existingRow.Parent then

                            existingRow.BackgroundColor3 =
                                Color3.fromRGB(
                                    55,
                                    55,
                                    61
                                )

                        end

                    end

                    row.BackgroundColor3 =
                        Color3.fromRGB(
                            70,
                            95,
                            130
                        )

                end)

                table.insert(rows, row)

            end

        end

    end

    countLabel.Text =
        "Logged: " ..
        tostring(#entries) ..
        " objects"

end

------------------------------------------------------------
-- SEARCH
------------------------------------------------------------

search:GetPropertyChangedSignal("Text"):Connect(function()

    rebuild()

end)

------------------------------------------------------------
-- REFRESH
------------------------------------------------------------

refresh.Activated:Connect(function()

    --------------------------------------------------------
    -- Capture anything that appeared since the last build
    --------------------------------------------------------

    for _, obj in ipairs(effectsFolder:GetDescendants()) do

        if not isIgnored(obj) then
            logObject(obj)
        end

    end

    rebuild()

end)

------------------------------------------------------------
-- CONTINUOUS LOGGER
------------------------------------------------------------

task.spawn(function()

    while gui.Parent do

        ----------------------------------------------------
        -- Periodically scan everything
        ----------------------------------------------------

        for _, obj in ipairs(effectsFolder:GetDescendants()) do

            if not isIgnored(obj) then
                logObject(obj)
            end

        end

        task.wait(0.5)

    end

end)

------------------------------------------------------------
-- DRAG WINDOW ON MOBILE
------------------------------------------------------------

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true

        dragStart = input.Position
        startPosition = main.Position

    end

end)

header.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = false

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement then

        local delta =
            input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,

            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )

    end

end)

------------------------------------------------------------
-- INITIAL BUILD
------------------------------------------------------------

rebuild()

print("========================================")
print(" Mobile Effect Explorer")
print(" Persistent Logger Loaded")
print(" Folder:", effectsFolder:GetFullName())
print(" Ignored: Crows, CamIgnore, Bolt, Blood")
print("========================================")
