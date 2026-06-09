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
screenGui.Name = "SimpleAutoBuilder"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 320, 0, 180)
frame.Position = UDim2.new(0.5, -160, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -20, 0, 28)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(235,235,235)
title.Text = "Auto Build (Simple)"

local idBox = Instance.new("TextBox", frame)
idBox.Size = UDim2.new(1, -20, 0, 30)
idBox.Position = UDim2.new(0, 10, 0, 42)
idBox.PlaceholderText = "Insert Model Id (Numbers Only)"
idBox.ClearTextOnFocus = false
idBox.Text = ""

local buildBtn = Instance.new("TextButton", frame)
buildBtn.Size = UDim2.new(0.48, -10, 0, 34)
buildBtn.Position = UDim2.new(0, 10, 0, 80)
buildBtn.Text = "Build"
buildBtn.Font = Enum.Font.GothamBold
buildBtn.TextSize = 15
buildBtn.BackgroundColor3 = Color3.fromRGB(60,160,70)
buildBtn.TextColor3 = Color3.fromRGB(255,255,255)

local cancelBtn = Instance.new("TextButton", frame)
cancelBtn.Size = UDim2.new(0.48, -10, 0, 34)
cancelBtn.Position = UDim2.new(0.52, 0, 0, 80)
cancelBtn.Text = "Cancel"
cancelBtn.Font = Enum.Font.GothamBold
cancelBtn.TextSize = 15
cancelBtn.BackgroundColor3 = Color3.fromRGB(180,60,60)
cancelBtn.TextColor3 = Color3.fromRGB(255,255,255)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 124)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13
statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
statusLabel.Text = "Waiting"

local toggleGuiBtn = Instance.new("TextButton", screenGui)
toggleGuiBtn.Size = UDim2.new(0, 38, 0, 38)
toggleGuiBtn.Position = UDim2.new(1, -60, 0.35, 0)
toggleGuiBtn.Text = "⚙️"
toggleGuiBtn.Font = Enum.Font.Gotham
toggleGuiBtn.TextSize = 20
toggleGuiBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
toggleGuiBtn.TextColor3 = Color3.fromRGB(255,255,255)

toggleGuiBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

cancelBtn.MouseButton1Click:Connect(function()
    cancelBuild = true
    statusLabel.Text = "Cancelling..."
end)

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
-- BUILD LOGIC (ONE PASS, IMMEDIATE MOVE)
--========================================================--

local function buildModelSimple(assetId)
    cancelBuild = false
    statusLabel.Text = "Loading asset..."

    local ok, arr = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(assetId))
    end)
    if not ok or not arr or #arr == 0 then
        statusLabel.Text = "Failed to load asset."
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
    -- 1) Built‑in Ball
    if part:IsA("Ball") or (part:IsA("Part") and part.Shape == Enum.PartType.Ball) then
        return "Ball"
    end

    -- 2) Built‑in Cylinder
    if part:IsA("Part") and part.Shape == Enum.PartType.Cylinder then
        return "Cylinder"
    end

    -- 3) Built‑in Wedge
    if part:IsA("WedgePart") then
        return "Wedge"
    end

    -- 4) Built‑in Corner Wedge
    if part:IsA("CornerWedgePart") then
        return "CornerWedge"
    end

    -- 5) Built‑in Truss
    if part:IsA("TrussPart") then
        return "Truss"
    end

    -- 6) MeshPart shape detection
    if part:IsA("MeshPart") then
        local meshType = part.MeshType

        if meshType == Enum.MeshType.Wedge then
            return "Wedge"
        elseif meshType == Enum.MeshType.Sphere then
            return "Ball"
        elseif meshType == Enum.MeshType.Cylinder then
            return "Cylinder"
        end

        -- FileMesh or custom mesh → fallback to name detection
        local name = part.Name:lower()
        if name:find("wedge") or name:find("triangle") or name:find("slope") then
            return "Wedge"
        elseif name:find("cyl") or name:find("tube") then
            return "Cylinder"
        elseif name:find("ball") or name:find("sphere") then
            return "Ball"
        end
    end

    -- 7) UnionOperation wedge detection
    if part:IsA("UnionOperation") then
        local name = part.Name:lower()
        if name:find("wedge") or name:find("triangle") or name:find("slope") then
            return "Wedge"
        end
    end

    -- 8) Default fallback
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
    end)
end)
