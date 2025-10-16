-- Auto Dash on Animation Detection (executor-friendly, override any dash, distance = 8)
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
    warn("[AutoDash] LocalPlayer not found; aborting.")
    return
end

-- Settings
local defaultDashDistance = 8       -- default distance (you asked for 8)
local dashTime = 0.125              -- how long the dash force lasts
local dashDelay = 0.156             -- default trigger delay if not set per animation

-- Animation IDs with per-animation settings (set distance to 8 here)
local targetAnims = {
    -- Dashes
    ["rbxassetid://110978068388232"] = { dashDelay = dashDelay, dashDistance = 8.5, Direction = "front" },
    ["rbxassetid://140597320237985"] = { dashDelay = dashDelay, dashDistance = 8.5, Direction = "front" },
    ["rbxassetid://130284226842903"] = { dashDelay = dashDelay, dashDistance = 8.5, Direction = "front" },
    ["rbxassetid://132855702748568"] = { dashDelay = dashDelay, dashDistance = 8.5, Direction = "front" },
    ["rbxassetid://99451940496871"] = { dashDelay = dashDelay, dashDistance = 8.5, Direction = "front" },
    ["rbxassetid://134581973800784"] = { dashDelay = dashDelay, dashDistance = 6, Direction = "back" },
    ["rbxassetid://117223862448096"] = { dashDelay = dashDelay, dashDistance = 6, Direction = "right" },
    ["rbxassetid://75203303352791"]  = { dashDelay = dashDelay, dashDistance = 6, Direction = "left" },
    -- add other anim mappings here as needed
}

-- getAnimConfig now returns Direction (default "front")
local function getAnimConfig(animId)
    local cfg = targetAnims[animId]
    if cfg then
        return {
            dashDelay = cfg.dashDelay or dashDelay,
            dashDistance = cfg.dashDistance or defaultDashDistance,
            Direction = cfg.Direction or "front"
        }
    end
    return nil
end

-- DASH IMPLEMENTATION (LinearVelocity preferred, always overrides any running dash)
local currentDash = nil -- reference to current LinearVelocity (or BodyVelocity) instance
local isDashing = false
local attachName = "__dash_attach"

local function clearCurrentDash()
    if currentDash then
        pcall(function()
            if currentDash.Destroy then currentDash:Destroy() end
        end)
    end
    currentDash = nil
    isDashing = false
end

local function createLinearVelocity(hrp, vec)
    local ok, lv = pcall(function()
        local attach = hrp:FindFirstChild(attachName)
        if not attach then
            attach = Instance.new("Attachment")
            attach.Name = attachName
            attach.Parent = hrp
        end

        local lv = Instance.new("LinearVelocity")
        lv.Attachment0 = attach
        -- world-relative velocity so we use absolute vector
        lv.RelativeTo = Enum.ActuatorRelativeTo.World
        lv.MaxForce = math.huge
        lv.VectorVelocity = vec
        lv.Parent = hrp
        return lv
    end)

    if ok and lv then
        return lv
    end
    return nil
end

local function createBodyVelocityFallback(hrp, vec)
    local ok, bv = pcall(function()
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = vec
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5) -- stronger fallback (affect Y too)
        bv.P = 1250
        bv.Parent = hrp
        return bv
    end)
    if ok and bv then return bv end
    return nil
end

-- distance is in studs; override parameter forces the new dash even if one is active
local function dash(distance, override, dir)
    distance = distance or defaultDashDistance
    -- if dash running and not override, skip
    if isDashing and not override then return end
    -- if override, clear existing dash first
    if isDashing and override then
        clearCurrentDash()
    end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    isDashing = true

    -- decide direction vector based on dir (defaults to front)
    local d = (dir and tostring(dir):lower()) or "front"
    local dirVec = hrp.CFrame.LookVector
    if d == "back" then
        dirVec = -hrp.CFrame.LookVector
    elseif d == "left" then
        dirVec = hrp.CFrame.RightVector
    elseif d == "right" then
        dirVec = -hrp.CFrame.RightVector
    else
        dirVec = hrp.CFrame.LookVector
    end

    -- compute velocity vector. Multiplier controls "strength" feel; adjust if needed.
    local strengthMultiplier = 12
    local vec = dirVec * (distance * strengthMultiplier)

    -- try LinearVelocity first
    local lv = createLinearVelocity(hrp, vec)
    if lv then
        currentDash = lv
    else
        -- fallback to BodyVelocity if LinearVelocity unavailable
        local bv = createBodyVelocityFallback(hrp, vec)
        currentDash = bv
    end

    -- cleanup after dashTime
    task.delay(dashTime or 0.125, function()
        pcall(function()
            if currentDash and currentDash.Parent then currentDash:Destroy() end
        end)
        -- small extra delay to ensure state resets after any external interference
        task.delay(0.03, clearCurrentDash)
    end)
end

-- Animation detection hookup (safe checks + immediate/ delayed trigger)
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
                pcall(function() dash(cfg.dashDistance, true, cfg.Direction) end) -- force override with direction
            end)
        else
            pcall(function() dash(cfg.dashDistance, true, cfg.Direction) end) -- immediate override with direction
        end
    end)
end

-- Hook current character + future respawns
if LocalPlayer.Character then
    setupAnimDetection(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(setupAnimDetection)

-- Optional: expose a global function so other local/button code can force the same dash
-- usage: _G.ForceDash(distance, direction) or _G.ForceDash() for default
_G.ForceDash = function(distance, direction)
    dash(distance or defaultDashDistance, true, direction or "front")
end

-- tiny debug print
print("[AutoDash] loaded — default distance:", defaultDashDistance)
