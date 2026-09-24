--// Merged Idle + Run/Walk Custom Animation Script (Speed Scaling Fix)

local RUN_ANIM_ID = "rbxassetid://122734100571248"   -- custom run/walk
local NEW_IDLE    = "rbxassetid://77136815653085"    -- custom idle

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

local function setup(char)
    local humanoid = char:WaitForChild("Humanoid", 10)
    if not humanoid then return end

    -- 1) Patch idle
    local animate = char:FindFirstChild("Animate")
    if animate then
        local idle = animate:FindFirstChild("idle")
        if idle then
            patchIdleAnimations(idle)
        end
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            local anim = track.Animation
            if anim and anim.AnimationId == NEW_IDLE then
                track.Priority = Enum.AnimationPriority.Action
            end
        end
    end

    -- 2) Custom run/walk with speed scaling
    local runAnim = Instance.new("Animation")
    runAnim.AnimationId = RUN_ANIM_ID

    local runTrack = humanoid:LoadAnimation(runAnim)
    runTrack.Priority = Enum.AnimationPriority.Movement
    runTrack.Looped = true

    local moving = false

    humanoid.Running:Connect(function(speed)
        if speed > 0 then
            -- scale from actual movement speed
            local speedScale = (speed - 1) * 0.1
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
