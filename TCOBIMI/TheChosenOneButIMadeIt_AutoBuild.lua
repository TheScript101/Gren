--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

--// CONFIGURATION
local BUILD_DELAY = 0.25 -- Updated per your request

--// RELIABLE SYNCAPI DETECTION
local function getSync()
    local char = LocalPlayer.Character
    if not char then return nil end

    for _, item in ipairs(char:GetChildren()) do
        if item:FindFirstChild("SyncAPI") and item.SyncAPI:FindFirstChild("ServerEndpoint") then
            return item.SyncAPI.ServerEndpoint
        end
    end

    warn("SyncAPI not found in character.")
    return nil
end

local function fireSync(name, payload)
    local ep = getSync()
    if not ep then return end
    ep:InvokeServer(name, payload)
end

local function createPart(shape, cf, parent)
    local ep = getSync()
    if not ep then return nil end
    return ep:InvokeServer("CreatePart", shape, cf, parent)
end

--// SHAPE DETECTION
local function detectShape(part)
    if part:IsA("Part") then
        if part.Shape == Enum.PartType.Ball then return "Ball" end
        if part.Shape == Enum.PartType.Cylinder then return "Cylinder" end
        return "Normal"
    elseif part:IsA("WedgePart") then return "Wedge"
    elseif part:IsA("CornerWedgePart") then return "Corner"
    elseif part:IsA("TrussPart") then return "Truss"
    elseif part:IsA("Seat") then return "Seat"
    elseif part:IsA("VehicleSeat") then return "VehicleSeat"
    elseif part:IsA("SpawnLocation") then return "Spawn"
    end
    return "Normal"
end

--// BUILD FUNCTION
local stopBuild = false
local function buildModel(model, counterLabel)
    stopBuild = false

    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Cleanup scripts
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
            desc:Destroy()
        end
    end

    -- Ghost preview
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            local ghost = part:Clone()
            ghost.Anchored = true
            ghost.CanCollide = false
            ghost.Transparency = 0.7
            ghost.Parent = workspace
            game:GetService("Debris"):AddItem(ghost, 5)
        end
    end

    -- Spawn position
    local spawnPos = hrp.Position + hrp.CFrame.LookVector * 15

    -- Move model
    if model:IsA("Model") and model.PrimaryPart then
        model:SetPrimaryPartCFrame(CFrame.new(spawnPos))
    else
        local min = Vector3.new(math.huge, math.huge, math.huge)
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                min = Vector3.new(
                    math.min(min.X, p.Position.X),
                    math.min(min.Y, p.Position.Y),
                    math.min(min.Z, p.Position.Z)
                )
            end
        end

        if min.X ~= math.huge then
            local offset = spawnPos - min
            for _, p in ipairs(model:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CFrame = p.CFrame + offset
                end
            end
        end
    end

    -- Build parts
    local parts = {}
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then table.insert(parts, p) end
    end

    local total = #parts
    local built = 0

    local shape = detectShape(part)
    local newPart = createPart(shape, part.CFrame, workspace)

        for _, part in ipairs(parts) do
        if stopBuild then break end

        local shape = detectShape(part)
        local newPart = createPart(shape, part.CFrame, workspace)

        if newPart then
            fireSync("SyncResize", { { Part = newPart, CFrame = part.CFrame, Size = part.Size } })
            fireSync("SyncMove", { { Part = newPart, CFrame = part.CFrame } })
            fireSync("SyncRotate", { { Part = newPart, CFrame = part.CFrame } })
            fireSync("SyncMaterial", { { Part = newPart, Material = part.Material } })
            fireSync("SyncColor", { { Part = newPart, Color = part.Color } })
            fireSync("SyncMaterial", { { Part = newPart, Transparency = part.Transparency } })
            fireSync("SyncSurface", { { Part = newPart, Surfaces = {
                Top = part.TopSurface, Bottom = part.BottomSurface,
                Front = part.FrontSurface, Back = part.BackSurface,
                Left = part.LeftSurface, Right = part.RightSurface
            }}})
            fireSync("SyncShadow", { { Part = newPart, CastShadow = false } })
            fireSync("SyncCollision", { { Part = newPart, CanCollide = part.CanCollide } })
        end

        built += 1
        counterLabel.Text = built .. "/" .. total
        task.wait(BUILD_DELAY)
    end

    model:Destroy()
end
    
        built += 1
        counterLabel.Text = built .. "/" .. total

        task.wait(BUILD_DELAY)
    end

    model:Destroy()
end

--// GUI FIXED
local gui = Instance.new("ScreenGui")
gui.Name = "ExecutorAutoBuilder"
gui.IgnoreGuiInset = true -- ensures it doesn’t get hidden behind Roblox top bar
gui.ResetOnSpawn = false  -- keeps GUI after respawn
gui.Parent = game:GetService("CoreGui") -- ✅ use CoreGui for executors

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 200)
frame.Position = UDim2.new(0.5, -200, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Auto Builder (Executor)"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local idBox = Instance.new("TextBox")
idBox.Size = UDim2.new(1, -20, 0, 30)
idBox.Position = UDim2.new(0, 10, 0, 35)
idBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
idBox.TextColor3 = Color3.new(1,1,1)
idBox.Font = Enum.Font.Gotham
idBox.TextSize = 14
idBox.PlaceholderText = "Enter Model ID"
idBox.Parent = frame
Instance.new("UICorner", idBox).CornerRadius = UDim.new(0, 6)

local buildBtn = Instance.new("TextButton")
buildBtn.Size = UDim2.new(0.45, -10, 0, 30)
buildBtn.Position = UDim2.new(0, 10, 0, 75)
buildBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
buildBtn.TextColor3 = Color3.new(1,1,1)
buildBtn.Font = Enum.Font.GothamBold
buildBtn.TextSize = 14
buildBtn.Text = "Build"
buildBtn.Parent = frame
Instance.new("UICorner", buildBtn).CornerRadius = UDim.new(0, 6)

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.45, -10, 0, 30)
stopBtn.Position = UDim2.new(0.55, 0, 0, 75)
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 14
stopBtn.Text = "Stop"
stopBtn.Parent = frame
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 6)

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1, -20, 0, 30)
counterLabel.Position = UDim2.new(0, 10, 0, 120)
counterLabel.BackgroundTransparency = 1
counterLabel.Text = "0/0"
counterLabel.TextColor3 = Color3.new(1,1,1)
counterLabel.Font = Enum.Font.Gotham
counterLabel.TextSize = 14
counterLabel.Parent = frame

-- Toggle GUI
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(1, -60, 0, 10)
toggleBtn.Text = "☰"
toggleBtn.TextSize = 30
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.Parent = gui

local isVisible = true
toggleBtn.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    frame.Visible = isVisible
end)

-- BUTTONS
buildBtn.MouseButton1Click:Connect(function()
    local assetId = tonumber(idBox.Text)
    if not assetId then 
        counterLabel.Text = "Invalid Asset ID"
        return 
    end
    
    counterLabel.Text = "Loading Model..."
    
    local success, objects = pcall(function()
        return game:GetObjects("rbxassetid://" .. assetId)
    end)
    
    if success and objects and #objects > 0 then
        local wrapper = Instance.new("Folder")
        wrapper.Name = "TempBuildWrapper"
        
        for _, obj in ipairs(objects) do
            obj.Parent = wrapper
        end
        
        task.spawn(function()
            buildModel(wrapper, counterLabel)
        end)
    else
        counterLabel.Text = "Failed to load Asset"
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    stopBuild = true
    counterLabel.Text = "Stopped"
end)
