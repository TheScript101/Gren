-- CAM LOCK BUTTON (DRAGGABLE + INVISIBLE WALL CHECK + TARGET MEMORY + PREDICTION)
-- By Mela

local player = game.Players.LocalPlayer
local cam = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

---------------------------------------------------------------------
-- CREATE DRAGGABLE BUTTON
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MelaCamLock"

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0, 160, 0, 50)
btn.Position = UDim2.new(0.7, 0, 0.7, 0)
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 18
btn.Text = "Cam Lock: OFF"
btn.Active = true
btn.Draggable = true

---------------------------------------------------------------------
-- CAM LOCK LOGIC
---------------------------------------------------------------------
local camlock = false
local target = nil
local prediction = 0.12
local lostBehindWall = false

local function getClosestPlayer()
    local closest = nil
    local closestDist = math.huge
    local myChar = player.Character
    if not myChar then return nil end

    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - myHRP.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = plr
            end
        end
    end

    return closest
end

---------------------------------------------------------------------
-- WALL CHECK (WORKS ON INVISIBLE PARTS)
---------------------------------------------------------------------
local function isVisible(targetPos)
    local origin = cam.CFrame.Position
    local direction = (targetPos - origin)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {player.Character}

    local result = workspace:Raycast(origin, direction, params)

    if result then
        -- If the ray hits ANYTHING before reaching the target → not visible
        local hitPos = result.Position
        local distHit = (hitPos - origin).Magnitude
        local distTarget = (targetPos - origin).Magnitude

        return distHit >= distTarget - 0.1
    end

    return true
end

---------------------------------------------------------------------
-- BUTTON TOGGLE
---------------------------------------------------------------------
btn.MouseButton1Click:Connect(function()
    camlock = not camlock
    btn.Text = camlock and "Cam Lock: ON" or "Cam Lock: OFF"

    if camlock then
        target = getClosestPlayer()
        lostBehindWall = false
    else
        target = nil
        lostBehindWall = false
    end
end)

---------------------------------------------------------------------
-- CAMERA UPDATE LOOP
---------------------------------------------------------------------
RS.RenderStepped:Connect(function()
    if not camlock then return end
    if not target then return end
    if not target.Character then return end

    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Prediction
    local predicted = hrp.Position + hrp.Velocity * prediction

    -- Check visibility
    local visible = isVisible(predicted)

    if visible then
        -- If target becomes visible again, resume lock
        lostBehindWall = false
        cam.CFrame = CFrame.new(cam.CFrame.Position, predicted)
    else
        -- Target is behind a wall
        lostBehindWall = true
        -- Do NOT switch targets
        -- Do NOT aim at the wall
        -- Simply pause camera lock until they reappear
    end
end)
