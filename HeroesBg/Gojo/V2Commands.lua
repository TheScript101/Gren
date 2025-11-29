-- Commands Frame (executor-friendly, square, centered, searchable, wrapped entries)
-- Paste into your executor (Synapse, Krnl, Delta, etc.)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- safe get parent for executors
local function getGuiParent()
    if type(gethui) == "function" then
        local ok, g = pcall(gethui)
        if ok and g then return g end
    end
    if (typeof(syn) == "table" and type(syn.protect_gui) == "function") then
        return game:GetService("CoreGui")
    end
    return game:GetService("CoreGui")
end

local parent = getGuiParent()

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CommandsFrame_GUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 9999
screenGui.Parent = parent
if (typeof(syn) == "table" and type(syn.protect_gui) == "function") then
    pcall(function() syn.protect_gui(screenGui) end)
end

-- Styling
local BG = Color3.fromRGB(30,30,30)          -- grayish-blackish
local STROKE = Color3.fromRGB(255,255,255)   -- white outline
local TEXT = Color3.fromRGB(240,240,240)

-- Main square frame (centered per your updated position)
local main = Instance.new("Frame")
main.Name = "CommandsMain"
main.Size = UDim2.new(0, 380, 0, 350)              -- height set to 350 as requested
main.Position = UDim2.new(0.5, 0, 0.45, 0)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.Parent = screenGui

local mainStroke = Instance.new("UIStroke")
mainStroke.Parent = main
mainStroke.Color = STROKE
mainStroke.Thickness = 2

-- Title
local title = Instance.new("TextLabel")
title.Parent = main
title.Size = UDim2.new(1, -28, 0, 28)
title.Position = UDim2.new(0,14,0,10)
title.BackgroundTransparency = 1
title.Text = "Commands"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = TEXT
title.TextXAlignment = Enum.TextXAlignment.Left

-- Search box (below title)
local searchBox = Instance.new("TextBox")
searchBox.Parent = main
searchBox.Size = UDim2.new(1, -110, 0, 28)
searchBox.Position = UDim2.new(0,14,0,44)
searchBox.PlaceholderText = "Search commands..."
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.TextColor3 = TEXT
searchBox.BackgroundColor3 = Color3.fromRGB(45,45,47)
searchBox.BorderSizePixel = 0
searchBox.TextXAlignment = Enum.TextXAlignment.Left

local searchClear = Instance.new("TextButton")
searchClear.Parent = main
searchClear.Size = UDim2.new(0, 80, 0, 28)
searchClear.Position = UDim2.new(1, -94, 0, 44)
searchClear.Text = "Clear"
searchClear.Font = Enum.Font.Gotham
searchClear.TextSize = 14
searchClear.TextColor3 = TEXT
searchClear.BackgroundColor3 = Color3.fromRGB(60,60,60)
searchClear.BorderSizePixel = 0

searchClear.MouseButton1Click:Connect(function()
    searchBox.Text = ""
    searchBox:CaptureFocus()
end)

-- Separator line under title/search
local sep = Instance.new("Frame")
sep.Parent = main
sep.Size = UDim2.new(1, -28, 0, 2)
sep.Position = UDim2.new(0,14,0,78)
sep.BackgroundColor3 = Color3.fromRGB(60,60,60)
sep.BorderSizePixel = 0

-- Scrollable area for commands (height adjusted for main height)
local scroll = Instance.new("ScrollingFrame")
scroll.Parent = main
scroll.Size = UDim2.new(1, -28, 0, 220) -- fits inside the 350 height
scroll.Position = UDim2.new(0,14,0,90)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 8

-- Use UIListLayout so entries can auto-size vertically (wrap)
local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scroll
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0,8)

-- Auto-update canvas when list size changes
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    local s = listLayout.AbsoluteContentSize
    scroll.CanvasSize = UDim2.new(0, 0, 0, s.Y + 8)
end)

-- bottom note (positioned near bottom)
local note = Instance.new("TextLabel")
note.Parent = main
note.Size = UDim2.new(1, -28, 0, 20)
note.Position = UDim2.new(0,14,1,-28)
note.BackgroundTransparency = 1
note.Text = "Click a command to copy command only"
note.Font = Enum.Font.Gotham
note.TextSize = 12
note.TextColor3 = Color3.fromRGB(180,180,180)
note.TextXAlignment = Enum.TextXAlignment.Left

-- Close (X) button - destroys GUI (top-right)
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = main
closeBtn.Size = UDim2.new(0, 34, 0, 28)
closeBtn.Position = UDim2.new(1, -48, 0, 10)
closeBtn.AnchorPoint = Vector2.new(0,0)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = STROKE
closeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
closeBtn.BorderSizePixel = 0

closeBtn.MouseButton1Click:Connect(function()
    pcall(function() screenGui:Destroy() end)
end)

-- Helper: extract just the command part (before " - ")
local function extractCommandOnly(fullText)
    if not fullText then return "" end
    local left = fullText:match("^(.-)%s*%-") -- capture up to dash
    if left and left:find("%S") then
        return (left:gsub("^%s*(.-)%s*$", "%1")) -- trim
    end
    -- fallback: first token starting with '/'
    local slash = fullText:match("(/%S+)")
    if slash then return slash end
    -- fallback to full text trimmed
    return (fullText:gsub("^%s*(.-)%s*$", "%1"))
end

-- store entries for searching
local entries = {} -- list of {entry = GuiButton, full = fullText, cmd = commandOnly}

-- Function to create a command entry (now wraps and auto-sizes)
local function addCommand(fullText)
    local entry = Instance.new("TextButton")
    entry.Name = "CommandEntry"
    entry.Size = UDim2.new(1, 0, 0, 0) -- height will be automatic
    entry.BackgroundColor3 = Color3.fromRGB(45,45,47)
    entry.BorderSizePixel = 0
    entry.AutoButtonColor = true
    entry.Font = Enum.Font.Gotham
    entry.TextSize = 15
    entry.TextColor3 = TEXT
    entry.TextXAlignment = Enum.TextXAlignment.Left
    entry.TextYAlignment = Enum.TextYAlignment.Top
    entry.TextWrapped = true
    entry.Text = fullText
    entry.AutomaticSize = Enum.AutomaticSize.Y -- auto-adjust height to wrapped text
    entry.Parent = scroll

    -- padding inside the button so text doesn't touch edges
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.Parent = entry

    -- white outline around label
    local stroke = Instance.new("UIStroke")
    stroke.Parent = entry
    stroke.Color = STROKE
    stroke.Thickness = 0.5

    -- simple hover effect
    entry.MouseEnter:Connect(function()
        pcall(function() entry.BackgroundColor3 = Color3.fromRGB(55,55,58) end)
    end)
    entry.MouseLeave:Connect(function()
        pcall(function() entry.BackgroundColor3 = Color3.fromRGB(45,45,47) end)
    end)

    -- store parsed commandOnly
    local cmdOnly = extractCommandOnly(fullText)
    table.insert(entries, {entry = entry, full = fullText, cmd = cmdOnly})

    -- click copies command only to clipboard
    entry.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(cmdOnly) end)
        -- small feedback: temporary text change
        local old = entry.Text
        entry.Text = "✔ Copied: "..cmdOnly
        task.delay(0.9, function()
            if entry and entry.Parent then
                entry.Text = fullText
            end
        end)
    end)

    return entry
end

-- Commands list (full explanatory lines)
local commandsList = {
    "/e commands - Explains The Commands.",
    "/e stop - Makes The Animation Stop Playing Along With The Floating.",
    "/e height (number) - Makes The Height Change On The Honored One Emote. (Set At 20 On Execute.)",
    "/e speech - I Send Gojo's Speech In The Chat Box That You Can Copy And Paste.",
    "/e speech_mode (mode) - Changes The Mode Of Speech. Modes are chat And bot. (Set As Bot On Execute. )"
}

-- populate
for _, cmd in ipairs(commandsList) do
    addCommand(cmd)
end

-- expose function globally so you can add commands later via console if desired
_G.AddCommandToCommandsFrame = addCommand

-- Search/filter behavior (live)
local function updateFilter(query)
    local q = tostring(query or ""):lower():gsub("^%s*(.-)%s*$","%1")
    for _, info in ipairs(entries) do
        local match = false
        if q == "" then
            match = true
        else
            if tostring(info.cmd):lower():find(q, 1, true) then match = true end
            if not match and tostring(info.full):lower():find(q, 1, true) then match = true end
        end
        info.entry.Visible = match
    end
    -- update scroll canvas from listLayout absolute size
    local s = listLayout.AbsoluteContentSize
    scroll.CanvasSize = UDim2.new(0, 0, 0, s.Y + 8)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    updateFilter(searchBox.Text)
end)

-- pressing Enter in search focuses nothing (keeps text)
searchBox.FocusLost:Connect(function(enter)
    if enter then
        updateFilter(searchBox.Text)
    end
end)

-- ensure GUI centered on different resolutions / re-center if parent size changes
screenGui:GetPropertyChangedSignal("AbsolutePosition"):Connect(function() -- no-op but keeps reactive; safe
end)

-- done
