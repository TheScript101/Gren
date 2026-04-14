local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Disable default animations
if character:FindFirstChild("t4t_animateR6") then
    character.t4t_animateR6.Enabled = false
elseif character:FindFirstChild("Animate") then
    character.Animate.Enabled = false
end

-- Stop all current animations
local animator = humanoid:FindFirstChild("Animator")
if animator then
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end
end

-- Emote Animations Setup
local emotes = {
    ["/e dance1"] = {id = "rbxassetid://35654637", looped = false},
    ["/e slingshot"] = {id = "rbxassetid://33248324", looped = false},
    ["/e laugh"] = {id = "rbxassetid://129423131", looped = false},
    ["/e wave"] = {id = "rbxassetid://128777973", looped = false},
	["/e drink"] = {id = "rbxassetid://29517689", looped = false}
}

local currentEmote = nil
local isEmoting = false

player.Chatted:Connect(function(msg)
    msg = msg:lower()
    if emotes[msg] then
        if currentEmote and currentEmote.IsPlaying then
            currentEmote:Stop()
        end

        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            track:Stop()
        end

        local emoteData = emotes[msg]
        local emoteAnimation = Instance.new("Animation")
        emoteAnimation.AnimationId = emoteData.id
        currentEmote = humanoid:LoadAnimation(emoteAnimation)
        currentEmote.Looped = emoteData.looped
        currentEmote:Play()
        isEmoting = true
    end
end)

-- Stop emote if the player moves (excluding rotation)
game:GetService("RunService").RenderStepped:Connect(function()
    if isEmoting and humanoid.MoveDirection.Magnitude > 0 then
        if currentEmote and currentEmote.IsPlaying then
            currentEmote:Stop()
        end
        isEmoting = false
    end
end)

-- Jump Animation Setup
local jumpAnimation = Instance.new("Animation")
jumpAnimation.AnimationId = "rbxassetid://97170520"
local jumpTrack = humanoid:LoadAnimation(jumpAnimation)
jumpTrack.Looped = false

-- Walk Animation Setup
local walkAnimation = Instance.new("Animation")
walkAnimation.AnimationId = "rbxassetid://214748382"
local walkTrack = humanoid:LoadAnimation(walkAnimation)
walkTrack.Looped = true

-- Jump Animation Trigger
humanoid.StateChanged:Connect(function(_, newState)
    if newState == Enum.HumanoidStateType.Jumping then
        jumpTrack:Play()
        jumpTrack:AdjustSpeed(1)
        jumpTrack.TimePosition = 0.2  -- Delay adjustment for better timing
    elseif newState == Enum.HumanoidStateType.Landed then
        jumpTrack:Stop()
    end
end)

-- Walk Animation Trigger using MoveDirection
game:GetService("RunService").RenderStepped:Connect(function()
    if humanoid.MoveDirection.Magnitude > 0 and humanoid.FloorMaterial ~= Enum.Material.Air then
        if not walkTrack.IsPlaying then
            walkTrack:Play()
        end
    else
        if walkTrack.IsPlaying then
            walkTrack:Stop()
        end
    end
end)
