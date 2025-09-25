-- LocalScript: Clean "Selection" UI (exact replica-ish to your sketch)
-- - Only contains the 007n7 entry (rbxthumb format)
-- - Left preview has Select button above image, two separators (above image & above name)
-- - The 007n7 card in the grid has a resized "Select" button (top-left) and same look
-- Paste into StarterPlayerScripts or run from an executor.

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clean up any old UI
local old = playerGui:FindFirstChild("SelectionUI")
if old then old:Destroy() end

-- helper constructor
local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            obj[k] = v
        end
    end
    return obj
end

-- rbxthumb image (requested format)
local THUMB = "rbxthumb://type=Asset&id=121597096026340&w=420&h=420"

-- Root
local screenGui = new("ScreenGui", {
    Name = "SelectionUI",
    Parent = playerGui,
    ResetOnSpawn = false,
})
pcall(function() screenGui.IgnoreGuiInset = true end)

-- Main rounded frame (single UICorner)
local main = new("Frame", {
    Parent = screenGui,
    Name = "MainFrame",
    AnchorPoint = Vector2.new(0.5,0.5),
    Position = UDim2.new(0.5,0,0.5,0),
    Size = UDim2.new(0.84,0,0.74,0),
    BackgroundColor3 = Color3.fromRGB(30,30,32),
    BorderSizePixel = 0,
})
new("UICorner", { Parent = main, CornerRadius = UDim.new(0,22) })
new("UIStroke", { Parent = main, Color = Color3.fromRGB(255,255,255), Thickness = 3, Transparency = 0.9 })

-- Title + note
local title = new("TextLabel", {
    Parent = main,
    Name = "Title",
    BackgroundTransparency = 1,
    Text = "SELECTION",
    Font = Enum.Font.SourceSansBold,
    TextSize = 36,
    TextColor3 = Color3.fromRGB(255,255,255),
    AnchorPoint = Vector2.new(0.5,0),
    Position = UDim2.new(0.5,0,0.01,0),
    Size = UDim2.new(0.6,0,0.12,0),
    TextScaled = true,
    TextXAlignment = Enum.TextXAlignment.Center,
})
local note = new("TextLabel", {
    Parent = main,
    Name = "Note",
    BackgroundTransparency = 1,
    Text = "Select What You Are Using",
    Font = Enum.Font.SourceSans,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(220,220,220),
    AnchorPoint = Vector2.new(0.5,0),
    Position = UDim2.new(0.5,0,0.12,0),
    Size = UDim2.new(0.6,0,0.06,0),
    TextScaled = true,
    TextXAlignment = Enum.TextXAlignment.Center,
})

-- big separator line under title area
local sepTop = new("Frame", {
    Parent = main,
    BackgroundColor3 = Color3.fromRGB(140,140,140),
    BackgroundTransparency = 0.85,
    Size = UDim2.new(0.94,0,0,2),
    Position = UDim2.new(0.03,0,0.20,0),
})

-- LEFT: preview card (single rounded + outline)
local leftContainer = new("Frame", {
    Parent = main,
    BackgroundTransparency = 1,
    Size = UDim2.new(0.26,0,0.68,0),
    Position = UDim2.new(0.03,0,0.22,0),
})
local leftCard = new("Frame", {
    Parent = leftContainer,
    Name = "LeftCard",
    Size = UDim2.new(1,0,0.95,0),
    BackgroundColor3 = Color3.fromRGB(22,22,24),
})
new("UICorner", { Parent = leftCard, CornerRadius = UDim.new(0,12) })
new("UIStroke", { Parent = leftCard, Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.9 })


-- Select button ABOVE the image (resizable)
local selectBtn = new("TextButton", {
    Parent = leftCard,
    Name = "SelectBtn",
    Text = "Select",
    Font = Enum.Font.SourceSansBold,
    TextSize = 16,
    BackgroundColor3 = Color3.fromRGB(70,70,75),
    TextColor3 = Color3.fromRGB(255,255,255),
    Size = UDim2.new(0.85,0,0.11,0),
    Position = UDim2.new(0.06,0,0.04,0),
    AutoButtonColor = true,
})
new("UICorner", { Parent = selectBtn, CornerRadius = UDim.new(0,8) })
selectBtn.MouseButton1Click:Connect(function()
-- Destroy the GUI first
local playerd = game:GetService("Players").LocalPlayer
for _, gui in pairs(playerd.PlayerGui:GetChildren()) do
    if gui.Name == "SelectionUI" then
        gui:Destroy()
                    end
                end

-- Then safely run the loadstring
local ok, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Forsaken/Gui/007n7.lua"))()
end)

-- Warn if it failed
if not ok then
    warn("Loadstring failed:", err)
                end


            
-- small thin separator under the Select button (inside leftCard)
local sepUnderSelect = new("Frame", {
    Parent = leftCard,
    BackgroundColor3 = Color3.fromRGB(110,110,110),
    Size = UDim2.new(0.9,0,0,2),
    Position = UDim2.new(0.05,0,0.16,0),
    BackgroundTransparency = 0.6,
})

-- Character image (between separators)
local leftImage = new("ImageLabel", {
    Parent = leftCard,
    Name = "CharacterImage",
    BackgroundTransparency = 1,
    Size = UDim2.new(0.9,0,0.6,0),
    Position = UDim2.new(0.05,0,0.18,0),
    ScaleType = Enum.ScaleType.Fit,
    Image = THUMB,
})
new("UICorner", { Parent = leftImage, CornerRadius = UDim.new(0,10) })

-- separation line above the name (so image is between two separators)
local sepAboveName = new("Frame", {
    Parent = leftCard,
    BackgroundColor3 = Color3.fromRGB(110,110,110),
    Size = UDim2.new(0.9,0,0,2),
    Position = UDim2.new(0.05,0,0.80,0),
    BackgroundTransparency = 0.6,
})

-- Name label under the lower separator (no ID text as requested)
local leftName = new("TextLabel", {
    Parent = leftCard,
    Name = "LeftName",
    Text = "007n7",
    Font = Enum.Font.SourceSansBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(255,255,255),
    BackgroundTransparency = 1,
    Position = UDim2.new(0.05,0,0.82,0),
    Size = UDim2.new(0.9,0,0.12,0),
    TextScaled = true,
    TextXAlignment = Enum.TextXAlignment.Center,
})

-- RIGHT: scroll area with single 007n7 card
local rightContainer = new("Frame", {
    Parent = main,
    BackgroundTransparency = 1,
    Size = UDim2.new(0.66,0,0.68,0),
    Position = UDim2.new(0.31,0,0.22,0),
})
local scroll = new("ScrollingFrame", {
    Parent = rightContainer,
    Name = "ScrollArea",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -8, 1, 0),
    CanvasSize = UDim2.new(0,0,0,0),
    ScrollBarThickness = 10,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    VerticalScrollBarInset = Enum.ScrollBarInset.Always,
})
local grid = new("UIGridLayout", {
    Parent = scroll,
    CellSize = UDim2.new(0, 150, 0, 160),
    CellPadding = UDim2.new(0, 12, 0, 12),
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Top,
})
grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    local abs = grid.AbsoluteContentSize
    scroll.CanvasSize = UDim2.new(0, 0, 0, abs.Y + 20)
end)

-- Create single 007n7 card manually with a resized Select button
local function create007Card()
    local item = { Name = "007n7", Image = THUMB }

    local card = new("Frame", {
        Parent = scroll,
        BackgroundColor3 = Color3.fromRGB(20,20,22),
        Size = UDim2.new(0,150,0,160),
        BorderSizePixel = 0,
    })
    new("UICorner", { Parent = card, CornerRadius = UDim.new(0,10) })
    new("UIStroke", { Parent = card, Color = Color3.fromRGB(255,255,255), Thickness = 1, Transparency = 0.9 })

    -- Select button (resized for this card — smaller width but same visual)
    local cardSelect = new("TextButton", {
        Parent = card,
        Name = "CardSelect",
        Text = "Select",
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        BackgroundColor3 = Color3.fromRGB(70,70,75),
        TextColor3 = Color3.fromRGB(255,255,255),
        Size = UDim2.new(0.32,0,0.10,0),
        Position = UDim2.new(0.06,0,0.04,0),
        AutoButtonColor = true,
    })
    new("UICorner", { Parent = cardSelect, CornerRadius = UDim.new(0,6) })

    local img = new("ImageLabel", {
        Parent = card,
        Size = UDim2.new(0.86,0,0.6,0),
        Position = UDim2.new(0.07,0,0.16,0), -- moved down a little to fit top select button
        BackgroundTransparency = 1,
        Image = item.Image,
        ScaleType = Enum.ScaleType.Fit,
    })
    new("UICorner", { Parent = img, CornerRadius = UDim.new(0,8) })

    -- separator line above name (so image is between top select and bottom line)
    local innerSep = new("Frame", {
        Parent = card,
        BackgroundColor3 = Color3.fromRGB(110,110,110),
        Size = UDim2.new(0.9,0,0,2),
        Position = UDim2.new(0.05,0,0.78,0),
        BackgroundTransparency = 0.6,
    })

    local nameLabel = new("TextLabel", {
        Parent = card,
        Text = item.Name,
        Font = Enum.Font.SourceSansBold,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.05,0,0.80,0),
        Size = UDim2.new(0.9,0,0.14,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextScaled = true,
    })

    local btn = new("TextButton", {
        Parent = card,
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1,0,1,0),
        AutoButtonColor = true,
    })

    -- hook card select button
    local function doSelect()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Forsaken/Gui/007n7.lua"))()
        end)
        if not ok then
            warn("Loadstring failed:", err)
        end
        local gui = card:FindFirstAncestorOfClass("ScreenGui")
        if gui then
            gui:Destroy()
        end
    end

    cardSelect.MouseButton1Click:Connect(doSelect)
    btn.MouseButton1Click:Connect(doSelect)
end  -- ✅ closes create007Card

            
-- Set left preview to 007n7
leftImage.Image = THUMB
leftName.Text = "007n7"
