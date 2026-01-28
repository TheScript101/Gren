-- VFX Model Maker
-- LocalScript (place in StarterGui)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ---------- UI ----------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VFXModelMakerGUI"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Toggle button (top-right)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "VFXToggle"
toggleBtn.Size = UDim2.new(0, 48, 0, 36)
toggleBtn.Position = UDim2.new(1, -60, 0, 8)
toggleBtn.AnchorPoint = Vector2.new(0,0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(36,36,36)
toggleBtn.BorderSizePixel = 1
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.TextSize = 14
toggleBtn.Text = "VFX"
toggleBtn.Parent = screenGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 400, 0, 340)
frame.Position = UDim2.new(0.5, 20, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Visible = false

-- Check button (left of title)
local checkBtn = Instance.new("TextButton", frame)
checkBtn.Name = "CheckBtn"
checkBtn.Size = UDim2.new(0, 52, 0, 28)
checkBtn.Position = UDim2.new(0, 8, 0, 8)
checkBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
checkBtn.BorderSizePixel = 0
checkBtn.Text = "Check"
checkBtn.Font = Enum.Font.Gotham
checkBtn.TextSize = 14
checkBtn.TextColor3 = Color3.new(1,1,1)

-- Title (shifted right so Check fits)
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -96, 0, 34)
title.Position = UDim2.new(0, 72, 0, 8)
title.BackgroundTransparency = 1
title.Text = "VFX Model Maker"
title.TextColor3 = Color3.fromRGB(230,230,230)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

-- settings-like small label area (line separator)
local sep = Instance.new("Frame", frame)
sep.Size = UDim2.new(1, -20, 0, 2)
sep.Position = UDim2.new(0, 10, 0, 44)
sep.BackgroundColor3 = Color3.fromRGB(60,60,60)
sep.BorderSizePixel = 0

-- Preview and Add buttons container
local topBtnContainer = Instance.new("Frame", frame)
topBtnContainer.Size = UDim2.new(1, -20, 0, 36)
topBtnContainer.Position = UDim2.new(0, 10, 0, 50)
topBtnContainer.BackgroundTransparency = 1

local previewBtn = Instance.new("TextButton", topBtnContainer)
previewBtn.Size = UDim2.new(0, 120, 1, 0)
previewBtn.Position = UDim2.new(0, 0, 0, 0)
previewBtn.Text = "Preview"
previewBtn.Font = Enum.Font.Gotham
previewBtn.TextSize = 16
previewBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
previewBtn.TextColor3 = Color3.fromRGB(255,255,255)

local addBtn = Instance.new("TextButton", topBtnContainer)
addBtn.Size = UDim2.new(0, 120, 1, 0)
addBtn.Position = UDim2.new(0, 130, 0, 0)
addBtn.Text = "Add New"
addBtn.Font = Enum.Font.Gotham
addBtn.TextSize = 16
addBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
addBtn.TextColor3 = Color3.fromRGB(255,255,255)

-- Selected item selector
local selectorLabel = Instance.new("TextLabel", topBtnContainer)
selectorLabel.Size = UDim2.new(0, 120, 1, 0)
selectorLabel.Position = UDim2.new(1, -130, 0, 0)
selectorLabel.BackgroundColor3 = Color3.fromRGB(50,50,50)
selectorLabel.Text = "Sphere"
selectorLabel.TextColor3 = Color3.fromRGB(255,255,255)
selectorLabel.Font = Enum.Font.Gotham
selectorLabel.TextSize = 14
selectorLabel.TextWrapped = true

local selectorBtn = Instance.new("TextButton", selectorLabel)
selectorBtn.Size = UDim2.new(1, 0, 1, 0)
selectorBtn.BackgroundTransparency = 1
selectorBtn.Text = ""
selectorBtn.MouseButton1Click:Connect(function()
    if selectorLabel.Text == "Sphere" then selectorLabel.Text = "Cylinder" else selectorLabel.Text = "Sphere" end
end)

-- Scrollable input area
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -20, 1, -110)
scroll.Position = UDim2.new(0, 10, 0, 95)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0, 8)

-- helper: make label + textbox + optional preview square
local function makeField(titleText, placeholder, parent, showColorPreview)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 48)
    holder.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", holder)
    label.Size = UDim2.new(0.45, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = titleText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", holder)
    box.Size = UDim2.new(0.5, -8, 1, 0)
    box.Position = UDim2.new(0.45, 8, 0, 0)
    box.Text = ""
    box.PlaceholderText = placeholder or ""
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.TextColor3 = Color3.fromRGB(230,230,230)
    box.BackgroundColor3 = Color3.fromRGB(48,48,48)
    box.BorderSizePixel = 0

    local preview = nil
    if showColorPreview then
        preview = Instance.new("Frame", holder)
        preview.Size = UDim2.new(0, 34, 0, 34)
        preview.Position = UDim2.new(1, -38, 0, 7)
        preview.BackgroundColor3 = Color3.new(1,1,1)
        preview.BorderSizePixel = 0
    end

    return {holder = holder, label = label, box = box, preview = preview}
end

-- create all fields
local fld_selectedItem = selectorLabel -- reuse

local fld_color = makeField("Color (r,g,b)", "255,255,255", scroll, true)
local fld_altcolor = makeField("Alt Color (r,g,b)", "255,255,255", scroll, true)

local fld_scale = makeField("Scale (uniform)", "1", scroll, false)
local fld_altscale = makeField("Alt Scale (uniform)", "1", scroll, false)

local fld_pos = makeField("Position offset (x,y,z)", "0,0,0", scroll, false)
local fld_altpos = makeField("Alt Position offset (x,y,z)", "0,0,0", scroll, false)

local fld_rot = makeField("Rotation deg (x,y,z)", "0,0,0", scroll, false)
local fld_altrot = makeField("Alt Rotation deg (x,y,z)", "0,0,0", scroll, false)

local fld_trans = makeField("Transparency (0-1)", "0", scroll, false)
local fld_alttrans = makeField("Alt Transparency (0-1)", "0", scroll, false)

local fld_time = makeField("Time (seconds)", "1.5", scroll, false)

-- small helper text label at bottom
local help = Instance.new("TextLabel", frame)
help.Size = UDim2.new(1, -20, 0, 28)
help.Position = UDim2.new(0, 10, 1, -48)
help.BackgroundTransparency = 1
help.TextColor3 = Color3.fromRGB(170,170,170)
help.Text = "ALT means target value. Leave alt as 0,0,0 to skip change (except Alt Transparency). Colors use 0-255."
help.Font = Enum.Font.Gotham
help.TextSize = 12
help.TextXAlignment = Enum.TextXAlignment.Left

-- update scroll CanvasSize automatically
local function updateCanvasSize()
    local contentSize = 0
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("Frame") then
            contentSize = contentSize + child.Size.Y.Offset + listLayout.Padding.Offset
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, contentSize + 16)
end

-- call once now and when fields created
updateCanvasSize()

-- ---------- Parsing helpers ----------
local function parseVector3(str)
    if not str then return nil end
    str = tostring(str)
    local parts = {}
    for s in string.gmatch(str, "[^, ]+") do
        parts[#parts+1] = tonumber(s)
    end
    if #parts == 0 then return nil end
    local x = parts[1] or 0
    local y = parts[2] or x
    local z = parts[3] or x
    return Vector3.new(tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0)
end

local function parseColor(str)
    if not str then return nil end
    str = tostring(str)
    local parts = {}
    for s in string.gmatch(str, "[^, ]+") do
        parts[#parts+1] = tonumber(s)
    end
    if #parts == 0 then return nil end
    local r = (parts[1] or 255)/255
    local g = (parts[2] or r*255)/255
    local b = (parts[3] or r*255)/255
    return Color3.new(math.clamp(r,0,1), math.clamp(g,0,1), math.clamp(b,0,1))
end

local function parseNumber(str, default)
    local n = tonumber(str)
    if not n then return default end
    return n
end

local function vec3Equal(a,b)
    if not a or not b then return false end
    return math.abs(a.X - b.X) < 1e-5 and math.abs(a.Y - b.Y) < 1e-5 and math.abs(a.Z - b.Z) < 1e-5
end

-- update color previews live
local function updateColorPreviews()
    local c = parseColor(fld_color.box.Text) or parseColor(fld_color.box.PlaceholderText)
    local ac = parseColor(fld_altcolor.box.Text) or parseColor(fld_altcolor.box.PlaceholderText)
    if fld_color.preview and c then fld_color.preview.BackgroundColor3 = c end
    if fld_altcolor.preview and ac then fld_altcolor.preview.BackgroundColor3 = ac end
end

fld_color.box.Focused:Connect(updateColorPreviews)
fld_color.box.Changed:Connect(function() updateColorPreviews() end)
fld_altcolor.box.Changed:Connect(updateColorPreviews)

-- ---------- VFX system ----------
local activeVFX = {} -- list of vfx entries { part = Part, hrp = HRP, ... , hidden = bool }

-- Sidebar GUI (hidden by default)
local sidebar = Instance.new("Frame")
sidebar.Name = "VFXSidebar"
sidebar.Size = UDim2.new(0, 220, frame.Size.Y.Scale, frame.Size.Y.Offset) -- match height to main frame
sidebar.AnchorPoint = frame.AnchorPoint
-- position to left of main frame, 10px gap
sidebar.Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset - (220 + 95), frame.Position.Y.Scale, frame.Position.Y.Offset)
sidebar.BackgroundColor3 = Color3.fromRGB(28,28,28)
sidebar.BorderSizePixel = 0
sidebar.Visible = false
sidebar.Parent = screenGui

local sidebarTitle = Instance.new("TextLabel", sidebar)
sidebarTitle.Size = UDim2.new(1, -12, 0, 32)
sidebarTitle.Position = UDim2.new(0, 6, 0, 6)
sidebarTitle.BackgroundTransparency = 1
sidebarTitle.Text = "Created VFX"
sidebarTitle.Font = Enum.Font.GothamBold
sidebarTitle.TextSize = 16
sidebarTitle.TextColor3 = Color3.new(1,1,1)
sidebarTitle.TextXAlignment = Enum.TextXAlignment.Left

local sidebarScroll = Instance.new("ScrollingFrame", sidebar)
sidebarScroll.Size = UDim2.new(1, -12, 1, -56)
sidebarScroll.Position = UDim2.new(0, 6, 0, 40)
sidebarScroll.CanvasSize = UDim2.new(0,0,0,0)
sidebarScroll.BackgroundTransparency = 1
sidebarScroll.BorderSizePixel = 0
sidebarScroll.ScrollBarThickness = 6
local sidebarLayout = Instance.new("UIListLayout", sidebarScroll)
sidebarLayout.Padding = UDim.new(0,6)

-- Helper to create a UI row for each VFX
local function makeSidebarRow(kindText, idx, entry)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = kindText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btnDelete = Instance.new("TextButton", row)
    btnDelete.Size = UDim2.new(0, 36, 0, 28)
    btnDelete.Position = UDim2.new(1, -76, 0, 4)
    btnDelete.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btnDelete.Text = "🗑️"
    btnDelete.Font = Enum.Font.Gotham
    btnDelete.TextSize = 18
    btnDelete.TextColor3 = Color3.new(1,1,1)
    btnDelete.BorderSizePixel = 0

    local btnHide = Instance.new("TextButton", row)
    btnHide.Size = UDim2.new(0, 36, 0, 28)
    btnHide.Position = UDim2.new(1, -36, 0, 4)
    btnHide.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btnHide.Text = (entry.hidden and "👁️" or "👁️")
    btnHide.Font = Enum.Font.Gotham
    btnHide.TextSize = 18
    btnHide.TextColor3 = Color3.new(1,1,1)
    btnHide.BorderSizePixel = 0

    -- connect delete
    btnDelete.MouseButton1Click:Connect(function()
        -- destroy part and remove from activeVFX
        if entry.part and entry.part.Parent then
            pcall(function() entry.part:Destroy() end)
        end
        -- remove from table
        for i = #activeVFX,1,-1 do
            if activeVFX[i].part == entry.part then
                table.remove(activeVFX, i)
            end
        end
        refreshSidebar()
    end)

    -- connect hide/show
    btnHide.MouseButton1Click:Connect(function()
        if not entry.part then return end
        entry.hidden = not entry.hidden
        -- use LocalTransparencyModifier so we can hide client-side without interfering with transparency animations
        pcall(function()
            if entry.hidden then
                entry.part.LocalTransparencyModifier = 1
            else
                entry.part.LocalTransparencyModifier = 0
            end
        end)
        -- text remains same emoji (visual state is via the part)
        refreshSidebar()
    end)

    return row
end

-- rebuild sidebar list
function refreshSidebar()
    -- clear current children (except title)
    for _, child in ipairs(sidebarScroll:GetChildren()) do
        if child ~= sidebarLayout then
            child:Destroy()
        end
    end

    -- build counts so numbering is e.g. Cylinder 1, Sphere 1, Sphere 2
    local counts = {Sphere = 0, Cylinder = 0}
    -- iterate activeVFX in order
    for _, entry in ipairs(activeVFX) do
        if entry and entry.part then
            local kind = (entry.part.Shape == Enum.PartType.Ball) and "Sphere" or "Cylinder"
            counts[kind] = counts[kind] + 1
            local labelText = kind .. " " .. tostring(counts[kind])
            -- create row
            local row = makeSidebarRow(labelText, counts[kind], entry)
            row.Parent = sidebarScroll
        end
    end

    -- update canvas size
    local total = 0
    for _, item in ipairs(sidebarScroll:GetChildren()) do
        if item:IsA("Frame") then total = total + 1 end
    end
    sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, total * 44)
end

-- Helper to ensure sidebar updates when activeVFX changes
local function scheduleSidebarRefresh()
    -- small debounce to avoid many updates
    if scheduleSidebarRefresh._debounce then return end
    scheduleSidebarRefresh._debounce = true
    delay(0.06, function()
        scheduleSidebarRefresh._debounce = nil
        if sidebar and sidebar.Parent and sidebar.Visible then
            refreshSidebar()
        end
    end)
end

-- ---------- Helper to create a part (ball or cylinder) ----------
local function makePart(kind)
    local p = Instance.new("Part")
    p.Size = Vector3.new(1,1,1)
    p.Anchored = true -- we'll manually set CFrame to follow HRP
    p.CanCollide = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    if kind == "Sphere" then
        p.Shape = Enum.PartType.Ball
    else
        p.Shape = Enum.PartType.Cylinder
    end
    p.Parent = workspace
    return p
end

-- interpolate helpers
local function lerp(a,b,t)
    return a + (b - a) * t
end
local function lerpVec3(a,b,t)
    return Vector3.new(lerp(a.X,b.X,t), lerp(a.Y,b.Y,t), lerp(a.Z,b.Z,t))
end
local function lerpColor(a,b,t)
    return Color3.new(lerp(a.R,b.R,t), lerp(a.G,b.G,t), lerp(a.B,b.B,t))
end

-- create VFX entry and start anim
local function createVFX(params)
    -- params:
    -- kind ("Sphere"/"Cylinder"), color, altColor (or nil), scale, altScale (or nil),
    -- posOffset, altPosOffset (or nil), rotDeg, altRotDeg (or nil),
    -- transparency, altTransparency (or nil), time (duration), followCharacter (true)
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local part = makePart(params.kind or "Sphere")
    part.Color = params.color or Color3.new(1,1,1)
    part.Transparency = params.transparency or 0
    part.Size = Vector3.new(1,1,1) * (params.scale or 1)
    part.Parent = workspace

    local startTime = tick()
    local duration = math.max(0.0001, (params.time or 1.5))

    local entry = {
        part = part,
        hrp = hrp,
        startTime = startTime,
        duration = duration,
        fromScale = Vector3.new(1,1,1) * (params.scale or 1),
        toScale = params.altScale and Vector3.new(1,1,1) * params.altScale or nil,
        fromPos = params.posOffset or Vector3.new(0,0,0),
        toPos = params.altPosOffset or nil,
        fromRot = params.rotDeg or Vector3.new(0,0,0),
        toRot = params.altRotDeg or nil,
        fromColor = params.color or Color3.new(1,1,1),
        toColor = params.altColor or nil,
        fromTransparency = params.transparency or 0,
        toTransparency = params.altTransparency or nil,
        keepAfter = true, -- remain after animation
        hidden = false,
    }

    table.insert(activeVFX, entry)
    scheduleSidebarRefresh()
    return part
end

-- Preview helper - creates a temporary vfx then destroys after duration + buffer
local function previewVFX(params)
    local p = createVFX(params)
    if not p then return end
    -- mark temporary: schedule removal after duration + 1.5
    delay((params.time or 1.5) + 1.5, function()
        if p and p.Parent then
            p:Destroy()
        end
        -- remove from activeVFX table where part nil/removed
        for i = #activeVFX,1,-1 do
            if not activeVFX[i].part or not activeVFX[i].part.Parent then
                table.remove(activeVFX, i)
            end
        end
        scheduleSidebarRefresh()
    end)
end

-- main updater (single RenderStepped connection)
local lastTick = tick()
RunService.RenderStepped:Connect(function()
    local now = tick()
    local dt = now - lastTick
    lastTick = now

    for i = #activeVFX,1,-1 do
        local e = activeVFX[i]
        if not e or not e.part then
            table.remove(activeVFX, i)
            scheduleSidebarRefresh()
        else
            local elapsed = now - e.startTime
            local t = math.clamp(elapsed / e.duration, 0, 1)

            -- scale
            local curScale = e.fromScale
            if e.toScale then
                curScale = lerpVec3(e.fromScale, e.toScale, t)
            end
            e.part.Size = curScale

            -- color
            if e.toColor then
                local color = lerpColor(e.fromColor, e.toColor, t)
                pcall(function() e.part.Color = color end)
            else
                pcall(function() e.part.Color = e.fromColor end)
            end

            -- transparency
            if e.toTransparency ~= nil then
                local tr = lerp(e.fromTransparency, e.toTransparency, t)
                e.part.Transparency = tr
            else
                e.part.Transparency = e.fromTransparency or 0
            end

            -- position & rotation relative to HRP using character-facing axis for offsets
            local fromLocal = e.fromPos or Vector3.new(0,0,0)
            local toLocal = e.toPos -- may be nil

            -- helper: convert a local offset (x,y,z where z is "forward from character") into a world offset vector
            local function hrpWorldOffset(localVec, hrpCFrame)
                if not hrpCFrame then
                    return localVec
                end
                -- interpret localVec.Z as forward relative to character (user-facing). Because Roblox's forward is -Z,
                -- invert Z so an input of (0,0,6) becomes forward by 6 studs.
                local hrpLocal = Vector3.new(localVec.X, localVec.Y, -localVec.Z)
                return hrpCFrame:VectorToWorldSpace(hrpLocal)
            end

            local worldOffset
            local hrpCFrame = (e.hrp and e.hrp.CFrame) or CFrame.new()
            if toLocal then
                local worldFrom = hrpWorldOffset(fromLocal, hrpCFrame)
                local worldTo = hrpWorldOffset(toLocal, hrpCFrame)
                worldOffset = lerpVec3(worldFrom, worldTo, t)
            else
                worldOffset = hrpWorldOffset(fromLocal, hrpCFrame)
            end

            local basePos = e.hrp and e.hrp.Position or Vector3.new()
            local targetPos = basePos + worldOffset

            local rot = e.fromRot
            if e.toRot then
                rot = lerpVec3(e.fromRot, e.toRot, t)
            end
            -- convert degrees to radians
            local rx = math.rad(rot.X)
            local ry = math.rad(rot.Y)
            local rz = math.rad(rot.Z)

            local targetCFrame = CFrame.new(targetPos) * CFrame.Angles(rx, ry, rz)
            pcall(function() e.part.CFrame = targetCFrame end)

            -- handle "hidden" visual using LocalTransparencyModifier without disturbing animation
            if e.hidden and e.part then
                pcall(function() e.part.LocalTransparencyModifier = 1 end)
            else
                pcall(function() e.part.LocalTransparencyModifier = 0 end)
            end
        end
    end
end)

-- ---------- Button behaviors ----------
local function collectParamsFromUI()
    local kind = fld_selectedItem.Text or "Sphere"
    local color = parseColor(fld_color.box.Text) or parseColor(fld_color.box.PlaceholderText) or Color3.new(1,1,1)
    local altColor = parseColor(fld_altcolor.box.Text)
    -- scale (uniform)
    local scale = parseNumber(fld_scale.box.Text, tonumber(fld_scale.box.PlaceholderText) or 1)
    local altScale = nil
    local tempAltScale = parseNumber(fld_altscale.box.Text, tonumber(fld_altscale.box.PlaceholderText) or 0)
    if tempAltScale and tempAltScale ~= 0 then altScale = tempAltScale end

    local posOff = parseVector3(fld_pos.box.Text) or parseVector3(fld_pos.box.PlaceholderText) or Vector3.new(0,0,0)
    local altPosOff = parseVector3(fld_altpos.box.Text)
    if altPosOff and vec3Equal(altPosOff, Vector3.new(0,0,0)) then altPosOff = nil end

    local rotDeg = parseVector3(fld_rot.box.Text) or parseVector3(fld_rot.box.PlaceholderText) or Vector3.new(0,0,0)
    local altRotDeg = parseVector3(fld_altrot.box.Text)
    if altRotDeg and vec3Equal(altRotDeg, Vector3.new(0,0,0)) then altRotDeg = nil end

    local trans = parseNumber(fld_trans.box.Text, tonumber(fld_trans.box.PlaceholderText) or 0)
    local altTrans = nil
    local tmpAltT = parseNumber(fld_alttrans.box.Text, tonumber(fld_alttrans.box.PlaceholderText) or 0)
    if fld_alttrans.box.Text ~= "" or tonumber(fld_alttrans.box.PlaceholderText) then
        -- alt transparency should animate if user provided a value even if 0
        if fld_alttrans.box.Text ~= "" then
            altTrans = tmpAltT
        elseif fld_alttrans.box.PlaceholderText ~= "" then
            altTrans = tonumber(fld_alttrans.box.PlaceholderText)
        end
    end

    local time = math.max(0.05, parseNumber(fld_time.box.Text, tonumber(fld_time.box.PlaceholderText) or 1.5))

    return {
        kind = kind,
        color = color,
        altColor = altColor,
        scale = scale,
        altScale = altScale,
        posOffset = posOff,
        altPosOffset = altPosOff,
        rotDeg = rotDeg,
        altRotDeg = altRotDeg,
        transparency = trans,
        altTransparency = altTrans,
        time = time,
    }
end

addBtn.MouseButton1Click:Connect(function()
    local params = collectParamsFromUI()
    createVFX(params)
    scheduleSidebarRefresh()
end)

previewBtn.MouseButton1Click:Connect(function()
    local params = collectParamsFromUI()
    previewVFX(params)
    scheduleSidebarRefresh()
end)

-- Check button toggles sidebar
checkBtn.MouseButton1Click:Connect(function()
    sidebar.Visible = not sidebar.Visible
    if sidebar.Visible then
        refreshSidebar()
    end
end)

-- initial preview color update
updateColorPreviews()

-- toggle visibility
toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- ensure canvas size updates when content changes (fields don't dynamically change count here, but keep robust)
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    -- do nothing, UIListLayout updates CanvasSize automatically in Studio, but some runtimes need manual
    updateCanvasSize()
end)

-- Also update canvas on text changes (just in case)
for _, f in ipairs({fld_color.box, fld_altcolor.box, fld_scale.box, fld_altscale.box, fld_pos.box, fld_altpos.box, fld_rot.box, fld_altrot.box, fld_trans.box, fld_alttrans.box, fld_time.box}) do
    f.Changed:Connect(function()
        updateColorPreviews()
        updateCanvasSize()
    end)
end

-- safety: if player respawns, keep functioning
player.CharacterAdded:Connect(function()
    -- nothing to do explicitly — created VFX will reattach to new hrp on next RenderStepped (if that was desired you'd need to reparent or recreate)
end)

-- ---------- Sidebar Auto Refresh Loop ----------
-- Assumes you already have a function named refreshSidebar()

task.spawn(function()
    while true do
        -- Only refresh if GUI still exists
        if screenGui and screenGui.Parent then
            pcall(function()
                refreshSidebar()
            end)
        end

        -- refresh every 0.5 seconds (safe + responsive)
        task.wait(0.5)
    end
end)

-- Also refresh immediately after respawn
player.CharacterAdded:Connect(function()
    task.wait(0.25)
    pcall(function()
        refreshSidebar()
    end)
end)

-- done
