--// Custom Move (Executor Safe, Timestamp + Anchor Fix)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local function getChar()
    local char = player.Character
    if not char or not char.Parent then
        char = player.CharacterAdded:Wait()
    end
    return char
end

local char = getChar()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- Target animations to detect
local TARGET_IDS = {
    ["rbxassetid://116040503139675"] = true,
    ["rbxassetid://91074768993486"] = true,
    ["rbxassetid://131358603583212"] = true,
    ["rbxassetid://100532748201417"] = true,
}

-- Skill animations
local INVIS = "rbxassetid://89041939287063"
local FLOAT = "rbxassetid://131826588098422"
local LAND  = "rbxassetid://78540995456941"

local function loadAnim(id)
    local a = Instance.new("Animation")
    a.AnimationId = id
    return hum:LoadAnimation(a)
end

local invisTrack, floatTrack, landTrack
local function reloadTracks()
    invisTrack = loadAnim(INVIS)
    floatTrack = loadAnim(FLOAT)
    landTrack  = loadAnim(LAND)
end
reloadTracks()

-----------------------------------------------------------
-- Noclip System
-----------------------------------------------------------

local Clip = true
local stored = {}
local noclipConn

local function applyNoclip()
    if not Clip and char then
        for _, part in char:QueryDescendants("BasePart") do
            if part:IsA("BasePart") then
                if stored[part] == nil then
                    stored[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end
end

local function enableNoclip()
    Clip = false
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.PreSimulation:Connect(applyNoclip)
end

local function disableNoclip()
    Clip = true
    if noclipConn then noclipConn:Disconnect() end
    for part, can in stored do
        if typeof(part) == "Instance" and part.Parent and part:IsA("BasePart") then
            part.CanCollide = can
        end
        stored[part] = nil
    end
end

-----------------------------------------------------------
-- Anchor / Freeze System
-----------------------------------------------------------

local function freezeChar()
    for _, x in pairs(char:GetDescendants()) do
        if x:IsA("BasePart") then
            x.Anchored = true
        end
    end
end

local function unfreezeChar()
    for _, x in pairs(char:GetDescendants()) do
        if x:IsA("BasePart") then
            x.Anchored = false
        end
    end
end

-----------------------------------------------------------
-- Teleport Down (raycast)
-----------------------------------------------------------

local function teleportDown(maxDist)
    maxDist = maxDist or 50
    local origin = root.Position
    local direction = Vector3.new(0, -maxDist, 0)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}

    local result = Workspace:Raycast(origin, direction, params)
    if result then
        root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
    else
        root.CFrame = root.CFrame + direction
    end
end

-----------------------------------------------------------
-- Animation Segment Helper
-----------------------------------------------------------

local function playAnimationSegment(track, startTime, endTime)
    track:Play()
    track.TimePosition = startTime
    track:AdjustSpeed(1)
    local duration = endTime - startTime
    task.delay(duration, function()
        if track.IsPlaying then
            track:Stop()
        end
    end)
end

-----------------------------------------------------------
-- Skill Logic
-----------------------------------------------------------

local running = false

local function runSkill(triggerId)
    if running then return end
    running = true

    char = getChar()
    hum = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    reloadTracks()

    enableNoclip()

-- 1) Startup invis
invisTrack:Play()
invisTrack:AdjustSpeed(1)

-- Let it play until the freeze frame
task.wait(0.1) -- 0.10 - 0

-- Freeze at 0.10 seconds
invisTrack.TimePosition = 0.10
invisTrack:AdjustSpeed(0)

local startupDelay = 0.5

if triggerId == "rbxassetid://100532748201417" then
    startupDelay = 2
end

task.wait(startupDelay)

-- Stop it before starting the float
invisTrack:Stop()

    -- 2) Float animation
    floatTrack:Play()
    floatTrack.TimePosition = 3.64
    floatTrack:AdjustSpeed(1)

    local bvUp = Instance.new("BodyVelocity")
    bvUp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bvUp.Velocity = Vector3.new(0, 25, 0)
    bvUp.Parent = root

    -- Wait until just before the hover pose
    task.wait(0.76)

    -- Freeze at the hover frame
    floatTrack.TimePosition = 4.40
    floatTrack:AdjustSpeed(0)

    -- Remove the upward force
    bvUp:Destroy()

    -- 3) Stay floating while anchored
    freezeChar()
    task.wait(0.5)
    unfreezeChar()

    -- Stop the float animation
    floatTrack:Stop()

    -- 4) Teleport down
    teleportDown(50)

    -- 5) Landing animation (0.07 → 0.8)
    playAnimationSegment(landTrack, 0.07, 0.8)

    disableNoclip()
    running = false
end

-----------------------------------------------------------
-- Animation Detector
-----------------------------------------------------------

local function connectDetector(h)
    h.AnimationPlayed:Connect(function(track)
        local anim = track.Animation
        local id = anim and anim.AnimationId
        if id and TARGET_IDS[id] then
            runSkill(id)
        end
    end)
end

connectDetector(hum)

player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
    reloadTracks()
    connectDetector(hum)
end)
