local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExecutorModelSpawnerUI"
ScreenGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")

-- Main Frame (Bigger)
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 400, 0, 360)  -- Increased size
Frame.Position = UDim2.new(0.5, -200, 0.5, -205)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 2
Frame.Visible = true
Frame.Parent = ScreenGui

-- Toggle Button (Now at Top Right of Screen)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)  -- Bigger size
ToggleButton.Position = UDim2.new(1, -60, 0, 10)  -- Top-right of screen
ToggleButton.Text = "☰"
ToggleButton.TextSize = 30
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.Parent = ScreenGui

-- Title Label
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, -10, 0, 40)  -- Larger
Title.Position = UDim2.new(0, 5, 0, 5)
Title.Text = "Executor Model Spawner"
Title.TextSize = 15
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Parent = Frame

-- TextBox for Model ID
local ModelBox = Instance.new("TextBox")
ModelBox.Size = UDim2.new(0.65, -5, 0, 40)  -- Larger
ModelBox.Position = UDim2.new(0, 10, 0, 50)
ModelBox.Text = "Enter Model ID"
ModelBox.TextSize = 20
ModelBox.TextColor3 = Color3.new(1, 1, 1)
ModelBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ModelBox.Parent = Frame

-- ====== ADDED: Size Multiplier TextBox (starts at 1) ======
local SizeMultiplierBox = Instance.new("TextBox")
SizeMultiplierBox.Size = UDim2.new(0.3, 0, 0, 30)
SizeMultiplierBox.Position = UDim2.new(0.7, 0, 0, 10) -- above the spawn button area
SizeMultiplierBox.PlaceholderText = "Size Multiplier"
SizeMultiplierBox.Text = "1"
SizeMultiplierBox.TextSize = 16
SizeMultiplierBox.TextColor3 = Color3.new(1, 1, 1)
SizeMultiplierBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SizeMultiplierBox.Parent = Frame
-- ============================================================

-- Spawn Button
local SpawnButton = Instance.new("TextButton")
SpawnButton.Size = UDim2.new(0.3, 0, 0, 40)  -- Bigger
SpawnButton.Position = UDim2.new(0.7, 0, 0, 50)
SpawnButton.Text = "Spawn"
SpawnButton.TextSize = 20
SpawnButton.TextColor3 = Color3.new(1, 1, 1)
SpawnButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpawnButton.Parent = Frame

-- Thumbnail Preview (Bigger)
local Thumbnail = Instance.new("ImageLabel")
Thumbnail.Size = UDim2.new(1, -20, 0, 250) -- Larger image preview
Thumbnail.Position = UDim2.new(0, 10, 0, 100)
Thumbnail.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Thumbnail.Image = ""
Thumbnail.Parent = Frame

-- Toggle GUI Visibility (Hides EVERYTHING now)
local isVisible = true
ToggleButton.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    Frame.Visible = isVisible
end)

-- Update Preview Thumbnail
ModelBox:GetPropertyChangedSignal("Text"):Connect(function()
    local assetId = tonumber(ModelBox.Text)
    if assetId then
        Thumbnail.Image = "rbxthumb://type=Asset&id=" .. assetId .. "&w=420&h=420"
    else
        Thumbnail.Image = ""
    end
end)

-- ====== REPLACED scaleModel: Use official Model:ScaleTo() API ======
local function scaleModel(model, multiplier)
    -- if multiplier is 1 or model missing, nothing to do
    if not model or not multiplier or multiplier == 1 then
        return
    end

    -- Ensure multiplier is a number
    multiplier = tonumber(multiplier) or 1
    if multiplier == 1 then return end

    -- Try to call the new ScaleTo API. Use pcall to avoid runtime errors.
    local ok, err = pcall(function()
        -- Some models may require that they are parented to Workspace and have a proper pivot.
        -- ScaleTo will scale around the model pivot.
        model:ScaleTo(multiplier)
    end)

    if not ok then
        -- If ScaleTo does not exist or fails, warn so you can debug.
        warn("Model:ScaleTo failed or is not available for this model:", err)
    end
end
-- ============================================================

-- Spawn Model (Executor Method)
SpawnButton.MouseButton1Click:Connect(function()
    local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local assetId = tonumber(ModelBox.Text)
    if assetId then
        local success, model = pcall(function()
            return game:GetObjects("rbxassetid://" .. assetId)[1]
        end)

        if success and model then
            -- Remove Humanoids and unwanted scripts first
            for _, desc in ipairs(model:GetDescendants()) do
                if desc:IsA("Humanoid") or desc:IsA("Script") or desc:IsA("ModuleScript") then
                    wait(0.01)
                end
            end

            -- ✅ Anchor ALL parts before parenting (so it never drops)
            for _, desc in ipairs(model:GetDescendants()) do
                if desc:IsA("BasePart") then
                    desc.Anchored = true
                    desc.CanCollide = false
                    desc.CastShadow = false
                end
            end

            -- Parent AFTER anchoring
            model.Parent = workspace

            -- Find a valid primary part or fallback
            local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChildOfClass("MeshPart")

            -- Spawn 15 studs in front of player
            local spawnPosition = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 15

            if primaryPart then
                model:SetPrimaryPartCFrame(CFrame.new(spawnPosition))
            else
                model:MoveTo(spawnPosition)
            end

            -- ====== ADDED: Read multiplier and scale the model using ScaleTo() ======
            local multiplier = tonumber(SizeMultiplierBox.Text)
            if not multiplier or type(multiplier) ~= "number" then
                multiplier = 1
            end

            if multiplier and multiplier ~= 1 then
                local ok, errmsg = pcall(function()
                    scaleModel(model, multiplier)
                end)
                if not ok then
                    warn("Scaling failed: ", errmsg)
                end
            end
            -- ============================================================
        end
    end
end)
