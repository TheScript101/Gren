local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- config
local MODE_CLICK_DELAY = 1.5
local AUTO_START_AFTER_MODE_CLICK = true

-- state
local mode = "Toggle"
local Locking = false
local LockedTarget = nil
local HighlightHandle = nil
local camLockEnabled = false

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LockModeSelectorGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

local panel = Instance.new("Frame", screenGui)
panel.Size = UDim2.new(0, 500, 0, 180)
panel.Position = UDim2.new(0.02, 169, 0.05, 92)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
panel.BorderSizePixel = 0
panel.Active = true

local panelCorner = Instance.new("UICorner", panel)
panelCorner.CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1, -20, 0, 36)
title.Position = UDim2.new(0, 10, 0, 10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(230, 230, 230)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Which Lock Do You Want?"

local buttonsFrame = Instance.new("Frame", panel)
buttonsFrame.Size = UDim2.new(1, -20, 0, 140)
buttonsFrame.Position = UDim2.new(0, 10, 0, 54)
buttonsFrame.BackgroundTransparency = 1

local function makeModeButton(parent, xOffset, yOffset, text)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(0, 230, 0, 40)
    btn.Position = UDim2.new(0, xOffset, 0, yOffset)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.BorderSizePixel = 0
    return btn
end

local alwaysBtn = makeModeButton(buttonsFrame, 0, 0, "Always Nearest")
local toggleBtn = makeModeButton(buttonsFrame, 240, 0, "Toggle Nearest")
local alwaysCamBtn = makeModeButton(buttonsFrame, 0, 50, "Always CamLock")
local toggleCamBtn = makeModeButton(buttonsFrame, 240, 50, "Toggle CamLock")

local statusLabel = Instance.new("TextLabel", panel)
statusLabel.Size = UDim2.new(1, -20, 0, 18)
statusLabel.Position = UDim2.new(0, 10, 1, -26)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "Mode: Toggle | Lock: OFF"

local lockToggle = Instance.new("TextButton", screenGui)
lockToggle.Name = "LockToggleBtn"
lockToggle.Size = UDim2.new(0, 80, 0, 40)
lockToggle.Position = UDim2.new(0.5, 163, 0.850000024, -339)
lockToggle.AnchorPoint = Vector2.new(0.5, 0)
lockToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
lockToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
lockToggle.Font = Enum.Font.GothamBold
lockToggle.TextSize = 16
lockToggle.Text = "🔒 OFF"
lockToggle.Active = true

local function getNearestPlayer()
    local closest, dist = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar then return nil end

    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
            local hum = pl.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local mag = (myHRP.Position - hrp.Position).Magnitude
                if mag < dist then
                    dist = mag
                    closest = pl
                end
            end
        end
    end

    return closest
end

local function clearHighlight()
    if HighlightHandle then
        pcall(function()
            HighlightHandle:Destroy()
        end)
        HighlightHandle = nil
    end
end

local function applyHighlightToCharacter(char)
    clearHighlight()
    if not char then return end

    local HL = Instance.new("Highlight")
    HL.Adornee = char
    HL.FillColor = Color3.fromRGB(255, 40, 40)
    HL.OutlineColor = Color3.fromRGB(255, 255, 255)
    HL.FillTransparency = 0.25
    HL.OutlineTransparency = 0
    HL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    HL.Parent = game:GetService("CoreGui")
    HighlightHandle = HL
end

local function rotateTowards(pos)
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local dir = (Vector3.new(pos.X, hrp.Position.Y, pos.Z) - hrp.Position)
    if dir.Magnitude > 0 then
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir.Unit)
    end
end

RunService.RenderStepped:Connect(function()
    if not Locking then return end

    local validTarget = LockedTarget
        and LockedTarget.Character
        and LockedTarget.Character:FindFirstChild("Humanoid")
        and LockedTarget.Character.Humanoid.Health > 0

    if mode == "Always" or mode == "AlwaysCam" then
        local nearest = getNearestPlayer()
        if nearest ~= LockedTarget then
            LockedTarget = nearest
            if LockedTarget then
                applyHighlightToCharacter(LockedTarget.Character)
            else
                clearHighlight()
            end
        end
    elseif mode == "Toggle" or mode == "ToggleCam" then
        if not validTarget then
            LockedTarget = getNearestPlayer()
            if LockedTarget then
                applyHighlightToCharacter(LockedTarget.Character)
            else
                clearHighlight()
            end
        end
    end

    if LockedTarget and LockedTarget.Character then
        local targetPart = LockedTarget.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            local targetPos = targetPart.Position
            rotateTowards(targetPos)

            if camLockEnabled then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            end

            statusLabel.Text = ("Mode: %s | Lock: ON -> %s"):format(mode, LockedTarget.Name or "Unknown")
        end
    else
        statusLabel.Text = ("Mode: %s | Lock: ON (no target)"):format(mode)
    end
end)

local function setLocking(on)
    Locking = on

    if not on then
        LockedTarget = nil
        clearHighlight()
        lockToggle.Text = "🔒 OFF"
        lockToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        statusLabel.Text = ("Mode: %s | Lock: OFF"):format(mode)

        local cam = workspace.CurrentCamera
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            cam.CameraSubject = hum
            cam.CameraType = Enum.CameraType.Custom
        end
    else
        LockedTarget = getNearestPlayer()
        if LockedTarget then
            applyHighlightToCharacter(LockedTarget.Character)
        end
        lockToggle.Text = "🔒 ON"
        lockToggle.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
    end
end

local function setMode(m)
    mode = m
    camLockEnabled = (m == "AlwaysCam" or m == "ToggleCam")

    alwaysBtn.BackgroundColor3 = (m == "Always") and Color3.fromRGB(70, 70, 80) or Color3.fromRGB(40, 40, 50)
    toggleBtn.BackgroundColor3 = (m == "Toggle") and Color3.fromRGB(70, 70, 80) or Color3.fromRGB(40, 40, 50)
    alwaysCamBtn.BackgroundColor3 = (m == "AlwaysCam") and Color3.fromRGB(70, 70, 80) or Color3.fromRGB(40, 40, 50)
    toggleCamBtn.BackgroundColor3 = (m == "ToggleCam") and Color3.fromRGB(70, 70, 80) or Color3.fromRGB(40, 40, 50)

    if AUTO_START_AFTER_MODE_CLICK then
        task.delay(MODE_CLICK_DELAY, function()
            setLocking(true)
        end)
    end
end

alwaysBtn.MouseButton1Click:Connect(function() setMode("Always") end)
toggleBtn.MouseButton1Click:Connect(function() setMode("Toggle") end)
alwaysCamBtn.MouseButton1Click:Connect(function() setMode("AlwaysCam") end)
toggleCamBtn.MouseButton1Click:Connect(function() setMode("ToggleCam") end)
lockToggle.MouseButton1Click:Connect(function() setLocking(not Locking) end)

Players.PlayerRemoving:Connect(function(p)
    if LockedTarget == p then
        LockedTarget = nil
        clearHighlight()
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    clearHighlight()
    LockedTarget = nil
end)

local pickLockToggle = Instance.new("TextButton", screenGui)
pickLockToggle.Name = "PickLockToggleBtn"
pickLockToggle.Size = UDim2.new(0, 40, 0, 40)
pickLockToggle.Position = UDim2.new(1, -227, 0.358799934, -136)
pickLockToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
pickLockToggle.Text = "⚙️"
pickLockToggle.Font = Enum.Font.GothamBold
pickLockToggle.TextSize = 20
pickLockToggle.TextColor3 = Color3.fromRGB(255, 255, 255)

local panelVisible = true
pickLockToggle.MouseButton1Click:Connect(function()
    panelVisible = not panelVisible
    panel.Visible = panelVisible
end)
