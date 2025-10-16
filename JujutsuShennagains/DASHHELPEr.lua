-- Linear Auto Dash on Animation Detection (override any dash, default distance = 9)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Robust LocalPlayer resolution (helps with executors)
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]
    local t = 0
    while not LocalPlayer and t < 5 do
        task.wait(0.2)
        LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]
        t = t + 0.2
    end
end
if not LocalPlayer then
    warn("[AutoLinearDash] LocalPlayer not found; aborting.")
    return
end

-- Settings
local defaultDashDistance = 9     -- user requested: normal dash 9
local dashTime = 0.125            -- duration of dash (seconds)
local dashDelay = 0.15           -- default trigger delay if not set per animation

-- Animation -> dash config (user requested entries set to 6)
local targetAnims = {
    ["rbxassetid://110978068388232"] = { dashDelay = dashDelay, dashDistance = 7},
    ["rbxassetid://134581973800784"] = { dashDelay = dashDelay, dashDistance = 6 },
    ["rbxassetid://117223862448096"] = { dashDelay = dashDelay, dashDistance = 6 },
    ["rbxassetid://75203303352791"]  = { dashDelay = dashDelay, dashDistance = 6 },
    -- add other anim mappings here as needed
}

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

-- Linear dash implementation (overrides any running dash)
local isDashing = false
local dashCancel = false
local currentDashThread = nil

local function clearDashState()
    dashCancel = true
    if currentDashThread then
        -- wait a tiny moment to allow thread to finish cleaning up
        task.wait(0.01)
    end
    isDashing = false
    dashCancel = false
    currentDashThread = nil
end

-- Linear dash: moves HRP smoothly from start -> end over duration
local function linearDash(distance, duration, override)
    duration = duration or dashTime
    distance = distance or defaultDashDistance

    if isDashing and not override then
        return
    end
    if isDashing and override then
        -- signal current dash to stop
        dashCancel = true
        -- allow small window for the thread to exit
        task.wait(0.01)
    end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    isDashing = true
    dashCancel = false

    -- snapshot start state
    local startPos = hrp.Position
    local lookVec = hrp.CFrame.LookVector
    local endPos = startPos + lookVec * distance
    local t0 = tick()

    -- try to temporarily disable humanoid controls to avoid input fighting (PlatformStand)
    local prevPlatformStand = nil
    if humanoid then
        prevPlatformStand = humanoid.PlatformStand
        pcall(function() humanoid.PlatformStand = true end)
    end

    -- run dash loop synced to RenderStepped for smoothness
    currentDashThread = task.spawn(function()
        while true do
            if dashCancel then break end
            local elapsed = tick() - t0
            local alpha = math.clamp(elapsed / duration, 0, 1)
            local pos = startPos:Lerp(endPos, alpha)
            -- keep facing the same direction as start (prevent unintended rotation)
            local cf = CFrame.new(pos, pos + lookVec)
            pcall(function() hrp.CFrame = cf end)

            if alpha >= 1 then break end
            RunService.RenderStepped:Wait()
        end

        -- finalize: move to exact end position if not cancelled
        if not dashCancel then
            pcall(function() hrp.CFrame = CFrame.new(endPos, endPos + lookVec) end)
        end

        -- restore humanoid state
        if humanoid then
            pcall(function() humanoid.PlatformStand = prevPlatformStand end)
        end

        -- clear state
        isDashing = false
        dashCancel = false
        currentDashThread = nil
    end)
end

-- Convenience wrapper that forces override behavior
local function dash(distance)
    linearDash(distance, dashTime, true)
end

-- Expose global function so other local code/buttons can call the same dash
_G.ForceLinearDash = function(distance)
    dash(distance or defaultDashDistance)
end

-- Animation detection hookup (safe checks)
local function setupAnimDetection(char)
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    if not humanoid then return end

    humanoid.AnimationPlayed:Connect(function(track)
        if not track then return end
        local animObj = nil
        pcall(function() animObj = track.Animation end)
        if not animObj then return end

        local animId = nil
        pcall(function() animId = tostring(animObj.AnimationId) end)
        if not animId or animId == "" then return end

        local cfg = getAnimConfig(animId)
        if not cfg then return end

        if cfg.dashDelay and cfg.dashDelay > 0 then
            task.delay(cfg.dashDelay, function()
                pcall(function() dash(cfg.dashDistance) end)
            end)
        else
            pcall(function() dash(cfg.dashDistance) end)
        end
    end)
end

-- Hook current character + future respawns
if LocalPlayer.Character then
    setupAnimDetection(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(setupAnimDetection)

-- tiny debug print to confirm script loaded
print("[AutoLinearDash] loaded — default distance:", defaultDashDistance)
