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
--// Format: { AnimationId, StartTime, EndTime, Speed }

local DODGE_ANIMS = {
    -- Anim 1 removed

    -- Anim 2 = BACKWARDS
    Back = {
        "rbxassetid://95396574958565",
        0.25, -- Start
        10,   -- End
        1.5   -- Speed
    },

    -- Anim 3 = RIGHT
    Right = {
        "rbxassetid://118107094802513",
        0.5, -- Start
        3.8, -- End
        2    -- Speed
    },

    -- Anim 4 = LEFT
    Left = {
        "rbxassetid://110118007517198",
        0,    -- Start
        1.55, -- End
        2     -- Speed
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
button.ImageTransparency = 0.2
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
        return
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
    
    -- Safety
    if startTime < 0 then
        startTime = 0
    end

    if endTime <= startTime then
        endTime = startTime + 0.01
    end

    if speed <= 0 then
        speed = 1
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = animId

    local success, track = pcall(function()
        return animator:LoadAnimation(animation)
    end)

    if not success or not track then
        animation:Destroy()
        return
    end

    -- NEVER loop the dodge animation
    track.Looped = false

    track.Priority = Enum.AnimationPriority.Action

    -- Start playing
    track:Play(0, 1, speed)

    -- Jump to the configured starting position.
    if startTime > 0 then
        pcall(function()
            track.TimePosition = startTime
        end)
    end

    -- Stop at the configured maximum end time.
    task.spawn(function()
        local startClock = os.clock()

        while track.IsPlaying do
            local elapsed = os.clock() - startClock

            -- Animation naturally reached its end.
            if track.Length > 0 and track.TimePosition >= track.Length - 0.03 then
                break
            end

            -- Configured maximum reached.
            if track.TimePosition >= endTime then
                break
            end

            -- Extra safety timeout.
            if elapsed > 15 then
                break
            end

            task.wait()
        end

        if track and track.IsPlaying then
            track:Stop(0)
        end
    end)

    -- Cleanup
    task.delay(16, function()
        if track then
            pcall(function()
                track:Stop(0)
            end)
        end

        if animation then
            animation:Destroy()
        end
    end)
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

    local rightClear = isDirectionClear(root, character, right)
    local leftClear = isDirectionClear(root, character, left)

    -- Both sides available:
    -- randomly choose left/right.
    if rightClear and leftClear then
        if math.random(1, 2) == 1 then
            return left
        else
            return right
        end
    end

    -- Right blocked -> use left.
    if not rightClear and leftClear then
        return left
    end

    -- Left blocked -> use right.
    if rightClear and not leftClear then
        return right
    end

    -- Both sides blocked -> try backwards.
    local backClear = isDirectionClear(root, character, back)

    if backClear then
        return back
    end

    -- Completely trapped.
    return nil
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

    local direction = getDodgeDirection(root, character)

    if not direction then
        return false
    end

    -- Determine which direction was selected.
    local rightDot = direction:Dot(root.CFrame.RightVector)
    local backDot = direction:Dot(-root.CFrame.LookVector)

    local dodgeType

    if backDot > 0.7 then
        -- Backwards dodge
        dodgeType = "Back"

    elseif rightDot > 0 then
        -- Right dodge
        dodgeType = "Right"

    else
        -- Left dodge
        dodgeType = "Left"
    end

    dodging = true

    -- Play the animation corresponding to the dodge direction.
    playDodgeAnimation(humanoid, DODGE_ANIMS[dodgeType])

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

    task.delay(DODGE_TIME + 0.05, function()
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
