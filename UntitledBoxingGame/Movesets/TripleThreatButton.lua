--// Triple Threat Ability (3 Dodges for Last Breath Sans)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

--==================================================
-- ANIMATION IDS
--==================================================

local PUNCH_ANIMS = {
    ["16040690802"] = true,
    ["16040900599"] = true,
    ["16038856772"] = true,
}

local NPC_PUNCH_ANIM = "102297407557660"

--// Dodge Animation + Configurations

local DEFAULT_START_TIME = 0
local DEFAULT_END_TIME = 10
local DEFAULT_SPEED = 1

--// Dodge Animation + Configurations
--// Format:
--// { AnimationId, StartTime, EndTime, Speed }

local DODGE_ANIMS = {

    -- Anim 2 = BACK
    Back = {
        "rbxassetid://95396574958565",
        0.25, -- Start time
        10,   -- Maximum end time
        1.5   -- Speed
    },

    -- Anim 3 = LEFT
    Left = {
        "rbxassetid://118107094802513",
        0.5, -- Start time
        10,  -- Maximum end time
        2    -- Speed
    },

    -- Anim 4 = RIGHT
    Right = {
        "rbxassetid://110118007517198",
        0,    -- Start time
        1.55, -- Maximum end time
        1.8   -- Speed
    }
}

--==================================================
-- SETTINGS
--==================================================

local MAX_DODGES = 3
local DETECTION_DISTANCE = 10
local DODGE_DISTANCE = 10
local DODGE_TIME = 0.20
local COOLDOWN_TIME = 5

--==================================================
-- STATE
--==================================================

local cooldown = false
local dodgesLeft = 0

-- Prevent the same animation track from triggering repeatedly
local processedTracks = {}

-- Prevent two animation events arriving on the same frame
local dodging = false

--==================================================
-- UI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "AbilityUI"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local button = Instance.new("ImageButton")
button.Name = "TripleThreatButton"
button.Size = UDim2.new(0, 120, 0, 120)
button.Position = UDim2.new(1, -130, 0, 10)
button.BackgroundTransparency = 1
button.ImageTransparency = 0.5
button.Image = "rbxassetid://126074334556709"
button.ImageColor3 = Color3.fromRGB(255, 255, 255)
button.Parent = gui

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1, 0, 1, 0)
text.BackgroundTransparency = 1
text.Text = "Triple Threat"
text.TextColor3 = Color3.fromRGB(255, 255, 255)
text.Font = Enum.Font.GothamBold
text.TextScaled = false
text.TextSize = 18
text.TextStrokeTransparency = 0
text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
text.Parent = button

--==================================================
-- ANIMATION ID NORMALIZER
--==================================================

local function getAnimationId(animation)
    if not animation then
        return nil
    end

    local id = animation.AnimationId

    if not id or id == "" then
        return nil
    end

    -- Extract only the numeric asset ID.
    local number = string.match(id, "%d+")

    return number
end

--==================================================
-- DODGE ANIMATION
--==================================================

local function playDodgeAnimation(humanoid, config)
    if not humanoid or not config then
        return nil
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")

    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    local animId = config[1]
    local startTime = tonumber(config[2]) or 0
    local endTime = tonumber(config[3]) or 10
    local speed = tonumber(config[4]) or 1

    local animation = Instance.new("Animation")
    animation.AnimationId = animId

    local success, track = pcall(function()
        return animator:LoadAnimation(animation)
    end)

    if not success or not track then
        animation:Destroy()
        return nil
    end

    -- Never allow the dodge animation to loop.
    track.Looped = false

    -- Highest normal animation priority.
    track.Priority = Enum.AnimationPriority.Action4

    -- Play the animation first so Roblox loads its length.
    track:Play(0, 1, speed)

    -- Wait for Roblox to know the animation's length.
    local timeout = os.clock() + 2

    while track.Length <= 0 and os.clock() < timeout do
        task.wait()
    end

    -- Make sure the animation hasn't already stopped.
    if not track.IsPlaying then
        track:Stop(0)
        animation:Destroy()
        return nil
    end

    -- Clamp the starting position to the actual animation length.
    if track.Length > 0 then
        startTime = math.clamp(startTime, 0, math.max(0, track.Length - 0.01))
    end

    -- Set the requested starting point.
    track.TimePosition = startTime

    -- Re-apply speed after changing TimePosition.
    track:AdjustSpeed(speed)

    -- Watch the animation and stop it at the configured maximum.
    task.spawn(function()
        while track and track.IsPlaying do

            -- If the animation naturally reaches its end,
            -- let it end normally.
            if track.Length > 0 and track.TimePosition >= track.Length - 0.03 then
                break
            end

            -- If the configured maximum is reached,
            -- force the animation to end.
            if track.TimePosition >= endTime then
                break
            end

            task.wait()
        end

        if track then
            pcall(function()
                if track.IsPlaying then
                    track:Stop(0)
                end
            end)
        end
    end)

    -- Cleanup.
    task.delay(12, function()
        pcall(function()
            track:Stop(0)
        end)

        animation:Destroy()
    end)

    return track
end
--==================================================
-- RAYCAST HELPERS
--==================================================

local function makeRayParams(character)
    local params = RaycastParams.new()

    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        character
    }

    params.IgnoreWater = true

    return params
end

local function isDirectionClear(root, character, direction)
    local params = makeRayParams(character)

    local origin = root.Position

    local result = workspace:Raycast(
        origin,
        direction.Unit * DODGE_DISTANCE,
        params
    )

    return result == nil
end

--==================================================
-- FIND DODGE DIRECTION
--==================================================

local function getDodgeDirection(root, character)
    local right = root.CFrame.RightVector
    local left = -root.CFrame.RightVector
    local back = -root.CFrame.LookVector

    local directions = {
        {
            name = "Left",
            vector = left
        },

        {
            name = "Right",
            vector = right
        },

        {
            name = "Back",
            vector = back
        }
    }

    local available = {}

    for _, option in ipairs(directions) do
        if isDirectionClear(root, character, option.vector) then
            table.insert(available, option)
        end
    end

    -- Nothing is available.
    -- Do NOT dodge.
    if #available == 0 then
        return nil, nil
    end

    -- Randomly choose from EVERY direction that is available.
    local selected = available[math.random(1, #available)]

    return selected.vector, selected.name
end

--==================================================
-- PERFORM DODGE
--==================================================

local function performDodge(character)
    if dodging then
        return false
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then
        return false
    end

    local direction, dodgeType = getDodgeDirection(root, character)

    -- Completely trapped.
    if not direction or not dodgeType then
        return false
    end

    local animationConfig = DODGE_ANIMS[dodgeType]

    if not animationConfig then
        return false
    end

    dodging = true

    --==================================================
    -- 0.5 SECOND STUN
    --==================================================

    local oldWalkSpeed = humanoid.WalkSpeed
    local oldJumpPower = humanoid.JumpPower
    local oldAutoRotate = humanoid.AutoRotate

    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    humanoid.AutoRotate = false

    --==================================================
    -- PLAY DIRECTION-SPECIFIC DODGE ANIMATION
    --==================================================

    playDodgeAnimation(humanoid, animationConfig)

    --==================================================
    -- DODGE MOVEMENT
    --==================================================

    local destination = root.Position + direction * DODGE_DISTANCE

    local tween = TweenService:Create(
        root,
        TweenInfo.new(
            DODGE_TIME,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            CFrame = CFrame.new(
                destination,
                destination + root.CFrame.LookVector
            )
        }
    )

    tween:Play()

    --==================================================
    -- END STUN AFTER 0.5 SECONDS
    --==================================================

    task.delay(0.5, function()
        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = oldWalkSpeed
            humanoid.JumpPower = oldJumpPower
            humanoid.AutoRotate = oldAutoRotate
        end
    end)

    -- Prevent another dodge during this dodge.
    task.delay(0.5, function()
        dodging = false
    end)

    return true
end
--==================================================
-- ACTIVATE / COOLDOWN
--==================================================

local function startCooldown()
    cooldown = true
    dodgesLeft = 0

    button.ImageColor3 = Color3.fromRGB(0, 0, 0)
    text.Text = "Cooldown..."

    task.delay(COOLDOWN_TIME, function()
        cooldown = false
        dodgesLeft = 0

        button.ImageColor3 = Color3.fromRGB(255, 255, 255)
        text.Text = "Triple Threat"
    end)
end

local function useDodge()
    if cooldown then
        return
    end

    if dodgesLeft <= 0 then
        return
    end

    local character = lp.Character

    if not character then
        return
    end

    local success = performDodge(character)

    if not success then
        return
    end

    dodgesLeft -= 1

    if dodgesLeft <= 0 then
        startCooldown()
    end
end

--==================================================
-- CHECK WHETHER ANIMATION IS A PUNCH
--==================================================

local function isPunchAnimation(track)
    if not track then
        return false
    end

    local animation = track.Animation

    if not animation then
        return false
    end

    local id = getAnimationId(animation)

    if not id then
        return false
    end

    if PUNCH_ANIMS[id] then
        return true
    end

    if id == NPC_PUNCH_ANIM then
        return true
    end

    return false
end

--==================================================
-- HANDLE ATTACKER ANIMATION
--==================================================

local function handleAnimation(otherCharacter, track)
    if cooldown then
        return
    end

    if dodgesLeft <= 0 then
        return
    end

    if not otherCharacter then
        return
    end

    if not isPunchAnimation(track) then
        return
    end

    -- Make sure this exact animation track hasn't
    -- already triggered a dodge.
    if processedTracks[track] then
        return
    end

    processedTracks[track] = true

    task.delay(2, function()
        processedTracks[track] = nil
    end)

    local myCharacter = lp.Character

    if not myCharacter then
        return
    end

    local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
    local attackerRoot = otherCharacter:FindFirstChild("HumanoidRootPart")

    if not myRoot or not attackerRoot then
        return
    end

    -- Check distance at the moment the punch animation starts.
    local distance = (attackerRoot.Position - myRoot.Position).Magnitude

    if distance > DETECTION_DISTANCE then
        return
    end

    -- Punch detected + attacker close enough.
    useDodge()
end

--==================================================
-- HOOK ANIMATOR
--==================================================

local hookedAnimators = {}

local function hookAnimator(character)
    if not character then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid then
        return
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")

    if not animator then
        -- Give Roblox a moment to create it.
        task.spawn(function()
            for _ = 1, 20 do
                animator = humanoid:FindFirstChildOfClass("Animator")

                if animator then
                    break
                end

                task.wait(0.1)
            end

            if animator then
                hookAnimator(character)
            end
        end)

        return
    end

    if hookedAnimators[animator] then
        return
    end

    hookedAnimators[animator] = true

    animator.AnimationPlayed:Connect(function(track)
        handleAnimation(character, track)
    end)
end

--==================================================
-- HOOK CHARACTER
--==================================================

local function hookCharacter(character)
    if not character then
        return
    end

    hookAnimator(character)

    -- Animator can sometimes be created after the character.
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.ChildAdded:Connect(function(child)
            if child:IsA("Animator") then
                hookAnimator(character)
            end
        end)
    end
end

--==================================================
-- EXISTING PLAYER CHARACTERS
--==================================================

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= lp then
        if player.Character then
            hookCharacter(player.Character)
        end

        player.CharacterAdded:Connect(function(character)
            task.wait(0.1)
            hookCharacter(character)
        end)
    end
end

--==================================================
-- NEW PLAYERS
--==================================================

Players.PlayerAdded:Connect(function(player)
    if player == lp then
        return
    end

    player.CharacterAdded:Connect(function(character)
        task.wait(0.1)
        hookCharacter(character)
    end)
end)

--==================================================
-- FIND ALL EXISTING NPCS
--==================================================

for _, descendant in ipairs(workspace:GetDescendants()) do
    if descendant:IsA("Humanoid") then
        local character = descendant.Parent

        if character and not Players:GetPlayerFromCharacter(character) then
            hookCharacter(character)
        end
    end
end

--==================================================
-- DETECT NEW NPC HUMANOIDS
--==================================================

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Humanoid") then
        local character = obj.Parent

        if character and not Players:GetPlayerFromCharacter(character) then
            task.wait()
            hookCharacter(character)
        end
    end
end)

--==================================================
-- BUTTON
--==================================================

button.MouseButton1Click:Connect(function()
    if cooldown then
        return
    end

    -- Already activated.
    if dodgesLeft > 0 then
        return
    end

    dodgesLeft = MAX_DODGES

    button.ImageColor3 = Color3.fromRGB(255, 0, 0)
    text.Text = "Dodging..."
end)
