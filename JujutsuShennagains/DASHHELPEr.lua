-- Auto Dash on Animation Detection (with configurable delays & dash distance per animation)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Global Settings
local defaultDashDistance = 6
local dashTime = 0.125
local dashDelay = 0.56

-- Dash animations (HP-based)
local dashAnimOver50 = ""
local dashAnimUnder50 = ""

-- Animation IDs with per-animation settings
local targetAnims = {
    -- Shedletsky
    ["rbxassetid://110978068388232"] = { 0.05= dashDelay, dashDistance = 6.7},
    --more if need
}

-- Get animation config
local function getAnimConfig(animId)
    local cfg = targetAnims[animId]
    if cfg then
        return {
            dashDelay = cfg.dashDelay or dashDelay,
            dashDistance = cfg.dashDistance or defaultDashDistance
        }
    end
    return nil
end

-- Dash function (adds HP animation alongside trigger anim)
local function dash(distance)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Choose dash animation based on HP
    local hpRatio = humanoid.Health / humanoid.MaxHealth
    local dashAnimId = hpRatio > 0.5 and dashAnimOver50 or dashAnimUnder50
    local anim = Instance.new("Animation")
    anim.AnimationId = dashAnimId
    local dashTrack = humanoid:LoadAnimation(anim)

    -- Override other animations and play faster
    dashTrack.Priority = Enum.AnimationPriority.Action4 -- Highest priority so it overrides everything
    dashTrack:Play()
    dashTrack:AdjustSpeed(2)

    -- Apply dash velocity
    local root = char.HumanoidRootPart
    local direction = root.CFrame.LookVector
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = direction * distance * 10
    bv.MaxForce = Vector3.new(1e5, 0, 1e5)
    bv.Parent = root

    task.delay(dashTime, function()
        bv:Destroy()
        dashTrack:Stop() -- Stop HP dash anim, allowing other anims to resume
    end)
end

-- Detect animation playing
local function setupAnimDetection(char)
    local humanoid = char:WaitForChild("Humanoid")

    humanoid.AnimationPlayed:Connect(function(track)
        local animId = track.Animation.AnimationId
        local cfg = getAnimConfig(animId)
        if cfg then
            -- Keep trigger anim playing, add dash + HP anim after delay
            task.delay(cfg.dashDelay, function()
                dash(cfg.dashDistance)
            end)
        end
    end)
end

-- Initial setup
if LocalPlayer.Character then
    setupAnimDetection(LocalPlayer.Character)
end

-- Reconnect on respawn
LocalPlayer.CharacterAdded:Connect(setupAnimDetection)
