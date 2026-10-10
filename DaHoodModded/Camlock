-- LocalScript inside StarterGui
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- State
local mode = "Toggle"
local Locking = false
local LockedTarget = nil
local HighlightHandle = nil
local aimHeadEnabled = false
local aimBasedEnabled = false

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LockModeSelectorGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 500, 0, 225)
panel.Position = UDim2.new(0.02, 169, 0.05, 55)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = screenGui
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 14)
panelCorner.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 36)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(230, 230, 230)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Which Lock Do You Want?"
title.Parent = panel

local buttonsFrame = Instance.new("Frame")
buttonsFrame.Size = UDim2.new(1, -20, 0, 140)
buttonsFrame.Position = UDim2.new(0, 10, 0, 54)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = panel

local function makeModeButton(parent, xOffset, yOffset, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 230, 0, 40)
    btn.Position = UDim2.new(0, xOffset, 0, yOffset)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.BorderSizePixel = 0
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    return btn
end

-- The first four mode buttons
local alwaysBtn = makeModeButton(buttonsFrame, 0, 0, "Always Nearest")
local toggleBtn = makeModeButton(buttonsFrame, 240, 0, "Toggle Nearest")
local alwaysCamBtn = makeModeButton(buttonsFrame, 0, 50, "Always CamLock")
local toggleCamBtn = makeModeButton(buttonsFrame, 240, 50, "Toggle CamLock")

-- Requested aim options
local aimHeadBtn = makeModeButton(buttonsFrame, 0, 100, "AimHead: OFF")
local aimBasedBtn = makeModeButton(buttonsFrame, 240, 100, "Aim Based: OFF")

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 18)
statusLabel.Position = UDim2.new(0, 10, 1, -26)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "Mode: Toggle | Lock: OFF"
statusLabel.Parent = panel

local lockToggle = Instance.new("TextButton")
lockToggle.Name = "LockToggleBtn"
lockToggle.Size = UDim2.new(0, 80, 0, 40)
lockToggle.Position = UDim2.new(0.5, 163, 0.85, -339)
lockToggle.AnchorPoint = Vector2.new(0.5, 0)
lockToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
lockToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
lockToggle.Font = Enum.Font.GothamBold
lockToggle.TextSize = 16
lockToggle.Text = "ðŸ”’ OFF"
lockToggle.Active = true
lockToggle.Parent = screenGui

local function clearHighlight()
    if HighlightHandle then
        pcall(function() HighlightHandle:Destroy() end)
        HighlightHandle = nil
    end
end

local function applyHighlightToCharacter(char)
    clearHighlight()
    if not char then return end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.FillColor = Color3.fromRGB(255, 40, 40)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.25
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = screenGui
    HighlightHandle = highlight
end

local function getPlayerFromCameraAim()
    Camera = workspace.CurrentCamera
    if not Camera then return nil end
    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
    local maxRadius = 80
    local bestPlayer, bestDistance = nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local part = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health >= 2 and part then
                local point = Camera:WorldToViewportPoint(part.Position)
                if point.Z > 0 then
                    local distance = (Vector2.new(point.X, point.Y) - center).Magnitude
                    if distance <= maxRadius and distance < bestDistance then
                        bestDistance = distance
                        bestPlayer = player
                    end
                end
            end
        end
    end
    return bestPlayer
end

local function getNearestPlayer()
    if aimBasedEnabled and (mode == "Toggle" or mode == "ToggleCam") then
        local aimed = getPlayerFromCameraAim()
        if aimed then return aimed end
    end

    local myCharacter = LocalPlayer.Character
    local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local closest, closestDistance = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health >= 2 and root then
                local distance = (myRoot.Position - root.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closest = player
                end
            end
        end
    end
    return closest
end

local function rotateTowards(position)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local direction = Vector3.new(position.X, root.Position.Y, position.Z) - root.Position
    if direction.Magnitude > 0 then
        root.CFrame = CFrame.new(root.Position, root.Position + direction.Unit)
    end
end

local function setLocking(on)
    Locking = on
    if not on then
        LockedTarget = nil
        clearHighlight()
        lockToggle.Text = "ðŸ”’ OFF"
        lockToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        statusLabel.Text = ("Mode: %s | Lock: OFF"):format(mode)
        local camera = workspace.CurrentCamera
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if camera and humanoid then
            camera.CameraSubject = humanoid
            camera.CameraType = Enum.CameraType.Custom
        end
        return
    end

    LockedTarget = getNearestPlayer()
    if LockedTarget then applyHighlightToCharacter(LockedTarget.Character) end
    lockToggle.Text = "ðŸ”’ ON"
    lockToggle.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
end

local function setMode(newMode)
    mode = newMode
    alwaysBtn.BackgroundColor3 = (mode == "Always") and Color3.fromRGB(70, 70, 80) or Color3.fromRGB(40, 40, 50)
    toggleBtn.BackgroundColor3 = (mode == "Toggle") and Color3.fromRGB(70, 70, 80) or Color3.fromRGB(40, 40, 50)
    alwaysCamBtn.BackgroundColor3 = (mode == "AlwaysCam") and Color3.fromRGB(70, 70, 80) or Color3.fromRGB(40, 40, 50)
    toggleCamBtn.BackgroundColor3 = (mode == "ToggleCam") and Color3.fromRGB(70, 70, 80) or Color3.fromRGB(40, 40, 50)
    if mode == "Always" or mode == "AlwaysCam" then
        setLocking(true)
    else
        setLocking(false)
    end
end

alwaysBtn.MouseButton1Click:Connect(function() setMode("Always") end)
toggleBtn.MouseButton1Click:Connect(function() setMode("Toggle") end)
alwaysCamBtn.MouseButton1Click:Connect(function() setMode("AlwaysCam") end)
toggleCamBtn.MouseButton1Click:Connect(function() setMode("ToggleCam") end)
lockToggle.MouseButton1Click:Connect(function() setLocking(not Locking) end)

aimHeadBtn.MouseButton1Click:Connect(function()
    aimHeadEnabled = not aimHeadEnabled
    aimHeadBtn.Text = "AimHead: " .. (aimHeadEnabled and "ON" or "OFF")
    aimHeadBtn.BackgroundColor3 = aimHeadEnabled and Color3.fromRGB(70, 70, 80) or Color3.fromRGB(40, 40, 50)
end)

aimBasedBtn.MouseButton1Click:Connect(function()
    aimBasedEnabled = not aimBasedEnabled
    aimBasedBtn.Text = "Aim Based: " .. (aimBasedEnabled and "ON" or "OFF")
    aimBasedBtn.BackgroundColor3 = aimBasedEnabled and Color3.fromRGB(70, 70, 80) or Color3.fromRGB(40, 40, 50)
end)

-- Main lock loop. A target below 2 HP immediately unlocks and turns the lock button off.
RunService.RenderStepped:Connect(function()
    if not Locking then return end

    if LockedTarget then
        local character = LockedTarget.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health < 2 then
            setLocking(false)
            return
        end
    end

    if mode == "Always" or mode == "AlwaysCam" then
        local nearest = getNearestPlayer()
        if nearest ~= LockedTarget then
            LockedTarget = nearest
            if LockedTarget then applyHighlightToCharacter(LockedTarget.Character) else clearHighlight() end
        end
    elseif not LockedTarget then
        LockedTarget = getNearestPlayer()
        if LockedTarget then applyHighlightToCharacter(LockedTarget.Character) end
    end

    if not LockedTarget or not LockedTarget.Character then
        statusLabel.Text = ("Mode: %s | Lock: ON (no target)"):format(mode)
        return
    end

    local character = LockedTarget.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health < 2 then
        setLocking(false)
        return
    end

    local targetPart = (aimHeadEnabled and character:FindFirstChild("Head")) or character:FindFirstChild("HumanoidRootPart")
    if not targetPart then return end

    rotateTowards(targetPart.Position)

    if mode == "AlwaysCam" or mode == "ToggleCam" then
        Camera = workspace.CurrentCamera
        if Camera then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        end
    end

    statusLabel.Text = ("Mode: %s | Lock: ON -> %s"):format(mode, LockedTarget.Name)
end)

Players.PlayerRemoving:Connect(function(player)
    if LockedTarget == player then
        setLocking(false)
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    clearHighlight()
    LockedTarget = nil
end)

-- Small gear button to show/hide the panel
local pickLockToggle = Instance.new("TextButton")
pickLockToggle.Name = "PickLockToggleBtn"
pickLockToggle.Size = UDim2.new(0, 40, 0, 40)
pickLockToggle.Position = UDim2.new(1, -100, 0.3588, 0)
pickLockToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
pickLockToggle.Text = "âš™ï¸"
pickLockToggle.Font = Enum.Font.GothamBold
pickLockToggle.TextSize = 20
pickLockToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
pickLockToggle.Parent = screenGui

local panelVisible = true
pickLockToggle.MouseButton1Click:Connect(function()
    panelVisible = not panelVisible
    panel.Visible = panelVisible
end)
