--// Custom Idle + Run/Walk + Jump/Fall Replacement (Respawn Safe + Airborne Fix)

local RUN_ANIM_ID = "rbxassetid://122734100571248"
local NEW_IDLE    = "rbxassetid://77136815653085"

local JUMP_ANIM   = "rbxassetid://96498187156602"
local FALL_ANIM   = "rbxassetid://74393790540096"

-- Roblox default jump/fall anims to replace
local DEFAULT_JUMP_IDS = {
    ["rbxassetid://507765000"] = true,
    ["http://www.roblox.com/asset/?id=507765000"] = true,
}

local DEFAULT_FALL_IDS = {
    ["rbxassetid://507767968"] = true,
    ["http://www.roblox.com/asset/?id=507767968"] = true,
}

local OLD_IDS = {
    ["rbxassetid://108553454326495"] = true,
    ["http://www.roblox.com/asset/?id=108553454326495"] = true,

    ["rbxassetid://507766388"] = true,
    ["http://www.roblox.com/asset/?id=507766388"] = true,

    ["rbxassetid://102439035841579"] = true,
    ["http://www.roblox.com/asset/?id=102439035841579"] = true,

    ["rbxassetid://507766666"] = true,
    ["http://www.roblox.com/asset/?id=507766666"] = true,
}

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local function patchIdleAnimations(idleFolder)
    for _, anim in ipairs(idleFolder:GetChildren()) do
        if anim:IsA("Animation") and OLD_IDS[anim.AnimationId] then
            anim.AnimationId = NEW_IDLE
        end
    end
end

local function patchJumpFall(animate)
    local jump = animate:FindFirstChild("jump")
    if jump then
        for _, anim in ipairs(jump:GetChildren()) do
            if anim:IsA("Animation") and DEFAULT_JUMP_IDS[anim.AnimationId] then
                anim.AnimationId = JUMP_ANIM
            end
        end
    end

    local fall = animate:FindFirstChild("fall")
    if fall then
        for _, anim in ipairs(fall:GetChildren()) do
            if anim:IsA("Animation") and DEFAULT_FALL_IDS[anim.AnimationId] then
                anim.AnimationId = FALL_ANIM
            end
        end
    end
end

local function setup(char)
    local humanoid = char:WaitForChild("Humanoid", 10)
    if not humanoid then return end

    local animate = char:FindFirstChild("Animate")
    if animate then
        -- Fix idle
        local idle = animate:FindFirstChild("idle")
        if idle then
            patchIdleAnimations(idle)
        end

        -- Replace jump + fall
        patchJumpFall(animate)
    end

    -- Fix idle priority after respawn
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            local anim = track.Animation
            if anim and anim.AnimationId == NEW_IDLE then
                track.Priority = Enum.AnimationPriority.Action
            end
        end
    end

    -- Custom run/walk with speed scaling
    local runAnim = Instance.new("Animation")
    runAnim.AnimationId = RUN_ANIM_ID

    local runTrack = humanoid:LoadAnimation(runAnim)
    runTrack.Priority = Enum.AnimationPriority.Movement
    runTrack.Looped = true

    local moving = false

    -- Airborne detection
    local function isAirborne(hum)
        local state = hum:GetState()
        return state == Enum.HumanoidStateType.Jumping
            or state == Enum.HumanoidStateType.Freefall
    end

    humanoid.StateChanged:Connect(function(old, new)
        if new == Enum.HumanoidStateType.Jumping then
            runTrack:Stop()
        elseif new == Enum.HumanoidStateType.Freefall then
            runTrack:Stop()
        elseif new == Enum.HumanoidStateType.Landed then
            if moving then
                runTrack:Play()
            end
        end
    end)

    humanoid.Running:Connect(function(speed)
        if isAirborne(humanoid) then
            runTrack:Stop()
            return
        end

        if speed > 0 then
            local speedScale = (speed - 1) * 0.2
            if speedScale < 0 then speedScale = 0 end
            runTrack:AdjustSpeed(speedScale)

            if not moving then
                moving = true
                runTrack:Play()
            end
        else
            if moving then
                moving = false
                runTrack:Stop()
            end
        end
    end)
end

if lp.Character then
    setup(lp.Character)
end

lp.CharacterAdded:Connect(setup)

wait(1) 

loadstring(game:HttpGet('https://raw.githubusercontent.com/pid4k/scripts/refs/heads/main/untitledboxinggame.lua', true))()
