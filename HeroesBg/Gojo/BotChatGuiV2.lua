-- Full updated script (paste into your executor)
-- Adds: /play, better normalization (no slash, missing 'e', underscore fixes),
-- fuzzy suggestion with "yes" confirmation, speech_speed, speech_mode, etc.
-- + Hollow Purple system (red/blue alts, automatic/manual, activate/release)

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local TextChatService = pcall(function() return game:GetService("TextChatService") end) and game:GetService("TextChatService") or nil
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Player & Character Setup
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Float Animation Setup
local FLOAT_ANIM_ID = "rbxassetid://18526556487"
local INTERRUPT_ANIMS = {
    ["rbxassetid://13917336710"] = true,
    ["rbxassetid://122773650110975"] = true,
    ["rbxassetid://100087324592640"] = true,
    ["rbxassetid://101843860692381"] = true,
}

local isFloating, bodyPos, currentFloatTrack = false, nil, nil
local floatHeight = 20

-- store previous jump UI states so we can restore them
local storedJumpStates = {}

-- Speech mode & speed
local speechMode = "Bot"   -- "Bot" or "Chat"
local speechSpeed = "Fast" -- "Fast" or "Slow"

-- Pending confirmation state for fuzzy suggestions
-- {cmd = "speech_mode", needsArg = true}
local pendingConfirmation = nil
local pendingOriginal = nil

-- Hollow Purple state
local redAltName = nil
local blueAltName = nil
local hollow_state = "none" -- "none", "ready", "activated", "combined"
local hollow_auto_running = false
local followHandles = {} -- to store follow coroutines per alt (so we can stop)
local hollow_combined_pos = nil
local hollow_combined_part = nil

-- Direct getter for the specific JumpButton path
local function getJumpButton()
    local ok, touchGui = pcall(function() return PlayerGui:FindFirstChild("TouchGui") end)
    if not ok or not touchGui then return nil end
    local ok2, touchFrame = pcall(function() return touchGui:FindFirstChild("TouchControlFrame") end)
    if not ok2 or not touchFrame then return nil end
    local ok3, jumpBtn = pcall(function() return touchFrame:FindFirstChild("JumpButton") end)
    if ok3 and jumpBtn then return jumpBtn end
    return nil
end

-- Hide jump button by adjusting ImageTransparency etc.
local function hideJumpButtons()
    local jb = getJumpButton()
    if not jb then return end
    pcall(function()
        local prev = {}
        local ok, val
        ok, val = pcall(function() return jb.ImageTransparency end)
        if ok then prev.ImageTransparency = val end
        ok, val = pcall(function() return jb.Active end)
        if ok then prev.Active = val end
        ok, val = pcall(function() return jb.Selectable end)
        if ok then prev.Selectable = val end
        ok, val = pcall(function() return jb.AutoButtonColor end)
        if ok then prev.AutoButtonColor = val end
        storedJumpStates[jb] = prev
        pcall(function() if jb.ImageTransparency ~= nil then jb.ImageTransparency = 1 end end)
        pcall(function() if jb.Active ~= nil then jb.Active = false end end)
        pcall(function() if jb.Selectable ~= nil then jb.Selectable = false end end)
        pcall(function() if jb.AutoButtonColor ~= nil then jb.AutoButtonColor = false end end)
    end)
end

local function showJumpButtons()
    for btn, state in pairs(storedJumpStates) do
        if btn and btn.Parent then
            pcall(function()
                if state.ImageTransparency ~= nil and btn.ImageTransparency ~= nil then
                    btn.ImageTransparency = state.ImageTransparency
                elseif btn.ImageTransparency ~= nil then
                    btn.ImageTransparency = 0
                end
                if state.Active ~= nil and btn.Active ~= nil then
                    btn.Active = state.Active
                elseif btn.Active ~= nil then
                    btn.Active = true
                end
                if state.Selectable ~= nil and btn.Selectable ~= nil then
                    btn.Selectable = state.Selectable
                elseif btn.Selectable ~= nil then
                    btn.Selectable = true
                end
                if state.AutoButtonColor ~= nil and btn.AutoButtonColor ~= nil then
                    btn.AutoButtonColor = state.AutoButtonColor
                elseif btn.AutoButtonColor ~= nil then
                    btn.AutoButtonColor = true
                end
            end)
        end
    end
    storedJumpStates = {}
end

-- Helper: stop all playing animations
local function stopAllAnimations()
    animator = humanoid and humanoid:FindFirstChildOfClass("Animator") or animator
    if animator then
        for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
            pcall(function() t:Stop() end)
        end
    end
end

-- Improved cancelFloat: unanchor, remove BodyPosition, stop anims (optionally) and restore jump UI
local function cancelFloat(stopAnims)
    isFloating = false
    pcall(showJumpButtons)
    pcall(function() if rootPart then rootPart.Anchored = false end end)
    if bodyPos then
        pcall(function() bodyPos:Destroy() end)
        bodyPos = nil
    end
    if currentFloatTrack then
        pcall(function() currentFloatTrack:AdjustSpeed(1) end)
        pcall(function() currentFloatTrack:Stop() end)
        currentFloatTrack = nil
    end
    if stopAnims then
        stopAllAnimations()
    end
end

-- Send chat message to RBXGeneral channel (wrapped safely)
local function sendChatMessage(message)
    if not TextChatService then
        return false, "TextChatService not available"
    end
    local success, err = pcall(function()
        local channels = TextChatService:FindFirstChild("TextChannels")
        if not channels then error("TextChannels missing") end
        local defaultChannel = channels:FindFirstChild("RBXGeneral")
        if not defaultChannel then error("RBXGeneral channel not found") end
        defaultChannel:SendAsync(message)
    end)
    if success then return true end
    return false, err
end

-- Convenience wrapper to add messages to your GUI and also attempt TextChatService (safe/polite)
local function announce(msg)
    pcall(function() addMessage(msg, false) end)
end

-- Speech sequences
local function runSpeechSequence(asChat)
    local fastSequence = {
        {"Sorry, Amanai..", 2},
        {"I'm not even angry over you right now..", 1.5},
        {"I bear no grudge against anyone..", 2},
        {"It's just that the world feels so, so wonderful right now...", 1.5},
        {"Throughout Heaven and Earth,", 1},
        {"I alone am the honored one..", 0}
    }

    local slowSequence = {
        {"Sorry, Amanai..", 2.5},
        {"I'm not even angry over you right now..", 3},
        {"I bear no grudge against anyone..", 4},
        {"It's just that the world feels so, so wonderful right now...", 3},
        {"Throughout Heaven and Earth,", 3},
        {"I alone am the honored one..", 0}
    }

    local seq = (speechSpeed and tostring(speechSpeed):lower() == "slow") and slowSequence or fastSequence

    if asChat then
        for _, item in ipairs(seq) do
            local line, waitTime = item[1], item[2]
            pcall(function() sendChatMessage(line) end)
            if waitTime and waitTime > 0 then task.wait(waitTime) end
        end
    else
        for _, item in ipairs(seq) do
            local line, waitTime = item[1], item[2]
            addMessage(line, false)
            if waitTime and waitTime > 0 then task.wait(waitTime) end
        end
    end
end

-- GUI Setup (kept same as yours)
local gui = Instance.new("ScreenGui", game.CoreGui)
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 120, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "Toggle Chat"
toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 350, 0, 350)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 6)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

toggleBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

mainFrame.Visible = true

local msgFrame = Instance.new("ScrollingFrame", mainFrame)
msgFrame.Size = UDim2.new(1, -20, 1, -100)
msgFrame.Position = UDim2.new(0, 10, 0, 40)
msgFrame.BackgroundTransparency = 1
msgFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
msgFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
msgFrame.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", msgFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

-- Input UI
local inputBox = Instance.new("TextBox", mainFrame)
inputBox.Size = UDim2.new(1, -100, 0, 30)
inputBox.Position = UDim2.new(0, 10, 1, -40)
inputBox.PlaceholderText = "Enter command..."
inputBox.Text = ""
inputBox.ClearTextOnFocus = true
inputBox.TextColor3 = Color3.new(1, 1, 1)
inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 16
inputBox.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)

local enterBtn = Instance.new("TextButton", mainFrame)
enterBtn.Size = UDim2.new(0, 70, 0, 30)
enterBtn.Position = UDim2.new(1, -80, 1, -40)
enterBtn.Text = "Enter"
enterBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
enterBtn.TextColor3 = Color3.new(1, 1, 1)
enterBtn.Font = Enum.Font.GothamBold
enterBtn.TextSize = 16
Instance.new("UICorner", enterBtn).CornerRadius = UDim.new(0, 6)

-- Message UI function
function addMessage(text, isUser)
    local msgHolder = Instance.new("Frame")
    msgHolder.Size = UDim2.new(1, 0, 0, 0)
    msgHolder.BackgroundTransparency = 1
    msgHolder.AutomaticSize = Enum.AutomaticSize.Y

    local msgBubble = Instance.new("TextLabel", msgHolder)
    msgBubble.BackgroundColor3 = isUser and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(80, 80, 120)
    msgBubble.TextColor3 = Color3.new(1, 1, 1)
    msgBubble.Text = text
    msgBubble.Font = Enum.Font.Gotham
    msgBubble.TextSize = 18
    msgBubble.TextWrapped = true
    msgBubble.TextXAlignment = Enum.TextXAlignment.Left
    msgBubble.Position = UDim2.new(isUser and 0.3 or 0, 0, 0, 0)
    msgBubble.Size = UDim2.new(0.7, -30, 0, 0)
    msgBubble.AutomaticSize = Enum.AutomaticSize.Y
    Instance.new("UICorner", msgBubble).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", msgBubble).Color = Color3.fromRGB(100, 100, 100)

    if not isUser then
        local copyBtn = Instance.new("TextButton", msgBubble)
        copyBtn.Text = "🔗"
        copyBtn.Size = UDim2.new(0, 24, 0, 24)
        copyBtn.Position = UDim2.new(1, -26, 1, -26)
        copyBtn.BackgroundTransparency = 1
        copyBtn.TextColor3 = Color3.new(1, 1, 1)
        copyBtn.Font = Enum.Font.Gotham
        copyBtn.TextSize = 16
        copyBtn.MouseButton1Click:Connect(function()
            pcall(function() setclipboard(text) end)
        end)
    end

    msgHolder.Parent = msgFrame
end

-- COMMAND HELPERS & FUZZY MATCHING --

-- known commands (keys are canonical names)
local knownCommands = {
    commands = {needsArg = false},
    stop = {needsArg = false},
    height = {needsArg = true},
    speech = {needsArg = false},
    speech_mode = {needsArg = true},
    speech_speed = {needsArg = true},
    play = {needsArg = false},

    -- Hollow Purple related
    red = {needsArg = true},
    blue = {needsArg = true},
    hollow_purple = {needsArg = false},
    automatic_hollow_purple = {needsArg = false},
    activate = {needsArg = false},
    release = {needsArg = false},
    automatic = {needsArg = false} -- to support "/e automatic hollow purple"
}

-- simple Levenshtein distance
local function levenshtein(a, b)
    a = tostring(a or ""):lower()
    b = tostring(b or ""):lower()
    local la, lb = #a, #b
    if la == 0 then return lb end
    if lb == 0 then return la end
    local matrix = {}
    for i = 0, la do
        matrix[i] = {}
        matrix[i][0] = i
    end
    for j = 0, lb do matrix[0][j] = j end
    for i = 1, la do
        for j = 1, lb do
            local cost = (a:sub(i,i) == b:sub(j,j)) and 0 or 1
            matrix[i][j] = math.min(
                matrix[i-1][j] + 1,
                matrix[i][j-1] + 1,
                matrix[i-1][j-1] + cost
            )
        end
    end
    return matrix[la][lb]
end

-- attempt to canonicalize tokens like "speech mode" or "speechmode" -> "speech_mode"
local function canonicalizeToken(tok)
    if not tok then return tok end
    local s = tok:lower()
    s = s:gsub("%s+", "") -- remove spaces for comparison
    if s == "speechmode" or s == "speechmode" then return "speech_mode" end
    if s == "speechspeed" or s == "speechspeed" then return "speech_speed" end
    return tok:gsub("%s+", "_")
end

-- normalize user input so many variants map to "/e <command> <args>"
local function normalizeCommand(raw)
    if not raw then return "" end
    local msg = tostring(raw)
    msg = msg:gsub("^%s+", ""):gsub("%s+$", "")
    if msg == "" then return "" end

    -- If input does not start with slash, allow "height 25" or "speech mode slow" etc.
    local startsWithSlash = (msg:sub(1,1) == "/")
    local body
    if startsWithSlash then
        body = msg:sub(2)
    else
        body = msg
    end
    body = body:gsub("^%s+", "")

    -- split first token and rest
    local firstToken, rest = body:match("^(%S+)%s*(.*)$")
    if not firstToken then return msg end
    firstToken = firstToken:lower()

    -- if firstToken is 'e' then the rest is the real command
    if firstToken == "e" then
        -- make sure there is a space after e; rest might be "commands" or "commands something"
        rest = rest or ""
        rest = rest:gsub("^%s+", "")
        -- handle the case "/ecommands" (no space) where body is like "ecommands"
        if rest == "" and body:len() > 1 then
            -- body might be "ecommands" -> take from 2nd char onward
            local possible = body:sub(2)
            possible = possible:gsub("^%s+", "")
            if possible ~= "" then
                -- reconstruct
                rest = possible
            end
        end
        -- if rest starts with combined words like "speechmode" or "speech mode", canonicalize
        -- split command token and arguments
        local cmdTok, args = rest:match("^(%S+)%s*(.*)$")
        if not cmdTok then cmdTok = rest; args = "" end
        cmdTok = canonicalizeToken(cmdTok)
        if args and args ~= "" then
            return "/e " .. cmdTok .. " " .. args
        else
            return "/e " .. cmdTok
        end
    end

    -- firstToken is not 'e' -> treat as direct command (user forgot slash or forgot e)
    -- canonicalize multi-word token (e.g., "speech mode", "speechmode")
    -- check if the body begins with any of the multiword commands
    local loweredBody = body:lower()

    -- attempt to find if the body already begins with a known command (with optional underscores/spaces)
    for cmdName, _ in pairs(knownCommands) do
        -- try variants: exact, spaces instead of underscore, no underscore
        local unders = cmdName
        local spaced = cmdName:gsub("_", " ")
        local nospace = cmdName:gsub("_", "")
        if loweredBody:sub(1, #unders) == unders
           or loweredBody:sub(1, #spaced) == spaced
           or loweredBody:sub(1, #nospace) == nospace
        then
            -- found a starting command
            local after = body:sub(1 + math.max(#unders, #spaced, #nospace))
            after = after:gsub("^%s+", "")
            return "/e " .. cmdName .. (after ~= "" and (" " .. after) or "")
        end
    end

    -- fallback: just insert /e before body and then try to canonicalize first token
    local cmdTok, args = body:match("^(%S+)%s*(.*)$")
    if not cmdTok then cmdTok = body; args = "" end
    cmdTok = canonicalizeToken(cmdTok)
    if args and args ~= "" then
        return "/e " .. cmdTok .. " " .. args
    else
        return "/e " .. cmdTok
    end
end

-- find best known command match for a token (returns name, distance)
local function findBestMatch(token)
    token = tostring(token or ""):lower()
    local best, bestDist = nil, math.huge
    for name, _ in pairs(knownCommands) do
        local d = levenshtein(token, name)
        if d < bestDist then
            bestDist = d
            best = name
        end
    end
    return best, bestDist
end

-- setupAnimation will post the "Started Honored One Animation." message when float animation begins
local function setupAnimation()
    animator = humanoid and humanoid:FindFirstChildOfClass("Animator") or animator
    if animator then
        animator.AnimationPlayed:Connect(function(track)
            local ok, id = pcall(function() return track.Animation and track.Animation.AnimationId end)
            if not ok or not id then return end
            if id == FLOAT_ANIM_ID then
                if isFloating then return end
                isFloating = true
                currentFloatTrack = track
                -- announce start
                pcall(function() addMessage("Started Honored One Animation.", false) end)
                -- hide jump
                pcall(hideJumpButtons)
                task.delay(0.8, function()
                    if isFloating and track.IsPlaying then
                        pcall(function() track:AdjustSpeed(0.5) end)
                        if bodyPos then pcall(function() bodyPos:Destroy() end) end
                        bodyPos = Instance.new("BodyPosition", rootPart)
                        bodyPos.Name = "FloatUpBP"
                        bodyPos.MaxForce = Vector3.new(0, math.huge, 0)
                        bodyPos.P = 10000
                        bodyPos.D = 1000
                        bodyPos.Position = rootPart.Position + Vector3.new(0, floatHeight, 0)
                        task.delay(1, function()
                            if isFloating then
                                pcall(function() track:AdjustSpeed(1) end)
                                rootPart.Anchored = true
                            end
                        end)
                    end
                end)
            elseif INTERRUPT_ANIMS[id] then
                cancelFloat(false)
            end
        end)
    end

    if humanoid then
        humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            if isFloating and humanoid.MoveDirection.Magnitude > 0 then
                cancelFloat(false)
            end
        end)
    end
end

-- UTIL: find player by name (case-insensitive search fallback)
local function findPlayerByName(name)
    if not name or name == "" then return nil end
    local direct = Players:FindFirstChild(name)
    if direct then return direct end
    local lname = name:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower() == lname then return p end
        if p.DisplayName and p.DisplayName:lower() == lname then return p end
    end
    return nil
end

-- UTIL: get HumanoidRootPart for player's character safely
local function getHRPForPlayer(p)
    if not p or not p.Character then return nil end
    return p.Character:FindFirstChild("HumanoidRootPart")
end

-- UTIL: safe tween of a part to target CFrame
local function tweenPartTo(part, targetCFrame, duration, easingStyle, easingDirection)
    if not part or not part:IsA("BasePart") then return false end
    duration = duration or 0.5
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    local ok, tween = pcall(function()
        return TweenService:Create(part, TweenInfo.new(duration, easingStyle, easingDirection), {CFrame = targetCFrame})
    end)
    if not ok or not tween then
        pcall(function() part.CFrame = targetCFrame end)
        return false
    end
    local suc = pcall(function() tween:Play() end)
    if not suc then
        pcall(function() part.CFrame = targetCFrame end)
        return false
    end
    return tween
end

-- Follow coroutine: keeps an alt at an offset relative to main for a duration (updates every frame)
local function startFollowAlt(altPlayer, offsetVector)
    if not altPlayer or not offsetVector then return nil end
    local id = altPlayer.UserId .. "_" .. tostring(offsetVector)
    if followHandles[id] then return id end
    local running = true
    followHandles[id] = {running = true}
    spawn(function()
        local startT = tick()
        while followHandles[id] and followHandles[id].running do
            local hrp = getHRPForPlayer(altPlayer)
            if hrp and rootPart and rootPart.Parent then
                local rootC = rootPart.CFrame
                local targetPos = rootC.Position + (rootC.RightVector * offsetVector.X) + Vector3.new(0, offsetVector.Y, 0) + (rootC.LookVector * offsetVector.Z)
                local lookAt = rootC.Position
                local targetCFrame = CFrame.new(targetPos, lookAt)
                pcall(function()
                    hrp.CFrame = targetCFrame
                    hrp.Anchored = true
                end)
            end
            task.wait(0.03)
        end
        -- cleanup anchored hold if possible
        local hrp2 = getHRPForPlayer(altPlayer)
        if hrp2 then
            pcall(function() hrp2.Anchored = false end)
        end
        followHandles[id] = nil
    end)
    return id
end

local function stopFollowAltById(id)
    if not id then return end
    if followHandles[id] then
        followHandles[id].running = false
        followHandles[id] = nil
    end
end

local function stopAllFollows()
    for id, _ in pairs(followHandles) do
        stopFollowAltById(id)
    end
    followHandles = {}
end

-- Play animation on a player's humanoid (best-effort)
local function playAnimationOnPlayer(p, animId, loop, stopAfter)
    pcall(function()
        if not p or not p.Character then return end
        local hum = p.Character:FindFirstChild("Humanoid")
        if not hum then return end
        local anim = Instance.new("Animation")
        anim.AnimationId = animId
        local track
        local ok, err = pcall(function()
            local a = hum:FindFirstChildOfClass("Animator")
            if a then
                track = a:LoadAnimation(anim)
            else
                track = hum:LoadAnimation(anim)
            end
        end)
        if track then
            track.Looped = (loop == true)
            track:Play()
            if stopAfter and stopAfter > 0 then
                task.delay(stopAfter, function()
                    pcall(function() track:Stop() end)
                end)
            end
            return track
        end
    end)
    return nil
end

-- HANDLE HOLLOW PURPLE SEQUENCES --

-- Helper to verify both alt players exist
local function getAlts()
    local r = redAltName and findPlayerByName(redAltName) or nil
    local b = blueAltName and findPlayerByName(blueAltName) or nil
    return r, b
end

local function haveBothAlts()
    local r, b = getAlts()
    return (r ~= nil) and (b ~= nil)
end

-- Automatic full sequence
local function runAutomaticHollowPurple()
    if hollow_auto_running then
        announce("Hollow Purple already running.")
        return
    end

    local r, b = getAlts()
    if not r or not b then
        announce("No Red Or Blue! Can't create Hollow Purple.")
        return
    end

    hollow_auto_running = true
    hollow_state = "none"
    announce("Creating Hollow Purple..")

    -- play the fusion animation on main for 3 seconds
    local fusionAnimId = "rbxassetid://48138189"
    local releaseAnimId = "rbxassetid://193307200"
    local fusionTrack = nil
    pcall(function() fusionTrack = playAnimationOnPlayer(player, fusionAnimId, false, 4) end)

    -- initial positioning: 5 studs behind main, then left 10 and right 10
    if not rootPart then
        rootPart = character:FindFirstChild("HumanoidRootPart")
    end
    local rootC = rootPart and rootPart.CFrame or CFrame.new(0,0,0)
    local behindOffset = -rootC.LookVector * 5
    local leftOffset = behindOffset + (-rootC.RightVector) * 10
    local rightOffset = behindOffset + (rootC.RightVector) * 10

    -- start follow anchors (so they rotate with you) using offsetVector as Vector3 (X=right, Y=up, Z=forward)
    -- We'll pass Vector3(rightOffsetX, 0, -5) etc, but our follow uses right/look vectors; easiest is compute offsets in local coordinate form
    local leftLocal = Vector3.new(-10, 0, 5) -- right:-10, forward:5 (behind positive Z in our follow logic)
    local rightLocal = Vector3.new(10, 0, 5) -- right:10, forward:5

    -- stop any previous follows
    stopAllFollows()
    local leftFollowId, rightFollowId
    leftFollowId = startFollowAlt(r, leftLocal)
    rightFollowId = startFollowAlt(b, rightLocal)

    -- Wait 3 seconds anchored following
    task.wait(3)

    -- Slowly move towards center near each other (we'll tween their HRPs to near-center positions)
    -- Center offsets (closer together)
    local centerOffsetLeft = Vector3.new(-1.5, 0, 3) -- small left, a bit behind/in front depending on orientation
    local centerOffsetRight = Vector3.new(1.5, 0, 3)

    -- Stop follow so tweening can take over
    stopFollowAltById(leftFollowId)
    stopFollowAltById(rightFollowId)

    -- Tween to center positions relative to root
    local rhrp = getHRPForPlayer(r)
    local bhrp = getHRPForPlayer(b)
    if rhrp and bhrp and rootPart then
        local rootC2 = rootPart.CFrame
        local targetLeftPos = rootC2.Position + rootC2.RightVector * centerOffsetLeft.X + (rootC2.UpVector * centerOffsetLeft.Y) + rootC2.LookVector * centerOffsetLeft.Z
        local targetRightPos = rootC2.Position + rootC2.RightVector * centerOffsetRight.X + (rootC2.UpVector * centerOffsetRight.Y) + rootC2.LookVector * centerOffsetRight.Z
        local leftCF = CFrame.new(targetLeftPos, rootC2.Position)
        local rightCF = CFrame.new(targetRightPos, rootC2.Position)
        -- unanchor and tween
        pcall(function() rhrp.Anchored = false end)
        pcall(function() bhrp.Anchored = false end)
        local tw1 = tweenPartTo(rhrp, leftCF, 1.5)
        local tw2 = tweenPartTo(bhrp, rightCF, 1.5)
        task.wait(1.6)
    end

    -- Combine: teleport both to 5 studs in front of you (combined position)
    local combinedPos
    if rootPart then
        combinedPos = rootPart.CFrame.Position + rootPart.CFrame.LookVector * 5
    else
        combinedPos = Vector3.new(0,5,0)
    end
    hollow_combined_pos = combinedPos
    local combinedCF = CFrame.new(combinedPos, combinedPos + (rootPart and rootPart.CFrame.LookVector or Vector3.new(0,0,1)))

    -- Teleport both instantly to the combinedCF and anchor
    if rhrp then
        pcall(function() rhrp.CFrame = combinedCF; rhrp.Anchored = true end)
    end
    if bhrp then
        pcall(function() bhrp.CFrame = combinedCF; bhrp.Anchored = true end)
    end

    hollow_state = "combined"

    -- Wait 4 seconds before release
    task.wait(4)

    -- Play release animation on main
    pcall(function() playAnimationOnPlayer(player, releaseAnimId, false, 2) end)

    -- Release: move both forward fast (use large forward delta)
    local forwardDelta = (rootPart and rootPart.CFrame.LookVector or Vector3.new(0,0,1)) * 300
    local releaseTarget = combinedPos + forwardDelta
    local fakePart = Instance.new("Part")
    fakePart.Anchored = true
    fakePart.CanCollide = false
    fakePart.Transparency = 1
    fakePart.CFrame = CFrame.new(releaseTarget)
    -- Tween combined HRPs to forward quickly
    if rhrp then
        pcall(function() rhrp.Anchored = false end)
        tweenPartTo(rhrp, CFrame.new(releaseTarget, releaseTarget + (rootPart and rootPart.CFrame.LookVector or Vector3.new(0,0,1))), 0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
    end
    if bhrp then
        pcall(function() bhrp.Anchored = false end)
        tweenPartTo(bhrp, CFrame.new(releaseTarget, releaseTarget + (rootPart and rootPart.CFrame.LookVector or Vector3.new(0,0,1))), 0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
    end

    task.wait(0.7)
    -- cleanup
    pcall(function() if fakePart and fakePart.Parent then fakePart:Destroy() end end)
    hollow_state = "none"
    hollow_auto_running = false
    announce("Hollow Purple finished.")
end

-- Manual prepare (/e hollow_purple)
local function prepareHollowPurpleManual()
    if not haveBothAlts() then
        announce("No Red Or Blue! Can't create Hollow Purple.")
        return
    end
    announce("Creating Hollow Purple.. (Your Commands: /e activate - make alts combine, /e release - release after activate)")

    stopAllFollows()
    hollow_state = "ready"

    -- Place them in initial anchored positions and start follow so they rotate with you for the waiting period
    local r, b = getAlts()
    if not rootPart then rootPart = character:FindFirstChild("HumanoidRootPart") end
    local rootC = rootPart and rootPart.CFrame or CFrame.new(0,0,0)
    local leftLocal = Vector3.new(-10, 0, 5)
    local rightLocal = Vector3.new(10, 0, 5)
    startFollowAlt(r, leftLocal)
    startFollowAlt(b, rightLocal)

    -- Play the fusion animation on main while waiting for activation (stop after 6s just in case)
    pcall(function() playAnimationOnPlayer(player, "rbxassetid://48138189", false, 6) end)
end

-- Manual activate: move alts to each other (combine position 5 studs in front)
local function activateHollowManual()
    if hollow_state ~= "ready" then
        if hollow_state == "none" then
            announce("Use /e hollow_purple to be able to use these commands.")
            return
        elseif hollow_state == "activated" or hollow_state == "combined" then
            announce("Already activated.")
            return
        else
            announce("Not Ready. Use /e hollow_purple first.")
            return
        end
    end

    -- Stop follow anchors
    stopAllFollows()

    local r, b = getAlts()
    if not r or not b then
        announce("No Red Or Blue! Can't activate.")
        hollow_state = "none"
        return
    end

    -- compute combined position and tween both to that combined position (5 studs in front)
    if not rootPart then rootPart = character:FindFirstChild("HumanoidRootPart") end
    local combinedPos = rootPart.CFrame.Position + rootPart.CFrame.LookVector * 5
    hollow_combined_pos = combinedPos
    local combinedCF = CFrame.new(combinedPos, combinedPos + rootPart.CFrame.LookVector)

    -- Tween both towards each other then teleport to combined and anchor
    local rhrp = getHRPForPlayer(r)
    local bhrp = getHRPForPlayer(b)
    if rhrp and bhrp then
        -- Do small tween to center over 1.2s
        pcall(function() rhrp.Anchored = false end)
        pcall(function() bhrp.Anchored = false end)
        tweenPartTo(rhrp, combinedCF * CFrame.new(-1,0,0), 1.2)
        tweenPartTo(bhrp, combinedCF * CFrame.new(1,0,0), 1.2)
        task.wait(1.25)
        -- Teleport both to exact same combined spot and anchor (visual combine)
        pcall(function() rhrp.CFrame = combinedCF; rhrp.Anchored = true end)
        pcall(function() bhrp.CFrame = combinedCF; bhrp.Anchored = true end)
    end

    hollow_state = "combined"
    announce("Alts combined. Use /e release to release the Hollow Purple.")
end

-- Manual release: after activated/combined
local function releaseHollowManual()
    if hollow_state ~= "combined" then
        if hollow_state == "ready" then
            announce("Not Yet! Type /e activate to make your alts go inside each other.")
            return
        else
            announce("Use /e hollow_purple to be able to use these commands.")
            return
        end
    end

    -- perform release: play animation and move them forward fast
    local releaseAnimId = "rbxassetid://193307200"
    pcall(function() playAnimationOnPlayer(player, releaseAnimId, false, 2) end)

    if not hollow_combined_pos then
        hollow_combined_pos = (rootPart and rootPart.CFrame.Position + rootPart.CFrame.LookVector * 5) or Vector3.new(0,0,0)
    end
    local forwardDelta = (rootPart and rootPart.CFrame.LookVector or Vector3.new(0,0,1)) * 300
    local releaseTarget = hollow_combined_pos + forwardDelta

    local r, b = getAlts()
    local rhrp = getHRPForPlayer(r)
    local bhrp = getHRPForPlayer(b)

    if rhrp then
        pcall(function() rhrp.Anchored = false end)
        tweenPartTo(rhrp, CFrame.new(releaseTarget, releaseTarget + (rootPart and rootPart.CFrame.LookVector or Vector3.new(0,0,1))), 0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
    end
    if bhrp then
        pcall(function() bhrp.Anchored = false end)
        tweenPartTo(bhrp, CFrame.new(releaseTarget, releaseTarget + (rootPart and rootPart.CFrame.LookVector or Vector3.new(0,0,1))), 0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
    end

    task.wait(0.7)
    hollow_state = "none"
    announce("Released Hollow Purple.")
end

-- HANDLE COMMANDS w/ normalization, fuzzy suggest + yes confirmation, and /play
local function executeCommandByName(cmdName, arg)
    cmdName = tostring(cmdName or ""):lower()

    -- Hollow Purple branches
    if cmdName == "red" then
        if not arg or arg == "" then
            addMessage("Usage: /e red <username>", false)
            return
        end
        redAltName = arg:gsub("^%s+", ""):gsub("%s+$", "")
        addMessage("Red set to " .. redAltName, false)
        return
    elseif cmdName == "blue" then
        if not arg or arg == "" then
            addMessage("Usage: /e blue <username>", false)
            return
        end
        blueAltName = arg:gsub("^%s+", ""):gsub("%s+$", "")
        addMessage("Blue set to " .. blueAltName, false)
        return
    elseif cmdName == "automatic_hollow_purple" or (cmdName == "automatic" and arg and arg:lower():match("hollow")) then
        -- run automatic sequence async
        spawn(function()
            runAutomaticHollowPurple()
        end)
        return
    elseif cmdName == "hollow_purple" then
        prepareHollowPurpleManual()
        return
    elseif cmdName == "activate" then
        activateHollowManual()
        return
    elseif cmdName == "release" then
        releaseHollowManual()
        return
    end

    -- Existing built-in commands
    if cmdName == "commands" then
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/HeroesBg/Gojo/V2Commands.lua"))()
        end)
        addMessage("Command Gui Loaded.", false)
        return
    elseif cmdName == "stop" then
        if isFloating then
            cancelFloat(true)
            addMessage("Float and animation has been stopped", false)
        else
            addMessage("Your not in the float phase! There's nothing to stop.", false)
        end
        return
    elseif cmdName == "height" then
        local h = tonumber(arg)
        if h then
            floatHeight = h
            addMessage("Height Set To " .. tostring(h), false)
        else
            addMessage("Invalid height. Usage: /e height <number>", false)
        end
        return
    elseif cmdName == "speech_mode" then
        local mode = tostring(arg or ""):lower()
        if mode == "chat" or mode == "bot" then
            speechMode = (mode == "chat") and "Chat" or "Bot"
            addMessage("Speech mode set to " .. speechMode, false)
        else
            addMessage("Invalid speech mode. Use 'chat' or 'bot'.", false)
        end
        return
    elseif cmdName == "speech_speed" then
        local s = tostring(arg or ""):lower()
        if s == "slow" or s == "fast" then
            speechSpeed = (s == "slow") and "Slow" or "Fast"
            addMessage("Speech speed set to " .. speechSpeed, false)
        else
            addMessage("Invalid speech speed. Use 'slow' or 'fast'.", false)
        end
        return
    elseif cmdName == "speech" then
        addMessage("Sending speech!", false)
        if speechMode:lower() == "chat" then
            task.spawn(function() runSpeechSequence(true) end)
        else
            task.spawn(function() runSpeechSequence(false) end)
        end
        return
    elseif cmdName == "play" then
        -- play the float animation directly
        pcall(function()
            local anim = Instance.new("Animation")
            anim.Name = "HonoredOnePlay"
            anim.AnimationId = FLOAT_ANIM_ID
            local track
            if animator then
                track = animator:LoadAnimation(anim)
                track:Play()
            else
                -- fallback: use humanoid:LoadAnimation
                local hAnim = Instance.new("Animation")
                hAnim.AnimationId = FLOAT_ANIM_ID
                local humTrack = humanoid:LoadAnimation(hAnim)
                humTrack:Play()
            end
        end)
        return
    else
        addMessage("Unknown built-in command: "..tostring(cmdName), false)
        return
    end
end

-- the main handler
local function handleCommand(rawMsg)
    -- First, handle pendingConfirmation (user replies "yes" to suggestion)
    local inputRaw = tostring(rawMsg or "")
    local inputTrim = inputRaw:gsub("^%s+", ""):gsub("%s+$", "")
    local lowerTrim = inputTrim:lower()

    if pendingConfirmation then
        -- check if user typed "yes" or "yes <arg>"
        if lowerTrim:match("^yes%s*$") then
            -- confirm without argument
            local cmd = pendingConfirmation.cmd
            local needsArg = pendingConfirmation.needsArg
            if needsArg then
                addMessage("That command needs an argument. Reply with: yes <argument>", false)
                return
            else
                executeCommandByName(cmd, nil)
                pendingConfirmation = nil
                pendingOriginal = nil
                return
            end
        end
        local yarg = lowerTrim:match("^yes%s+(.+)$")
        if yarg then
            local cmd = pendingConfirmation.cmd
            executeCommandByName(cmd, yarg)
            pendingConfirmation = nil
            pendingOriginal = nil
            return
        end
        -- If not a yes, continue to normal processing (they typed something else)
    end

    -- Normalize variants into "/e cmd args"
    local normalized = normalizeCommand(inputTrim)
    local low = (normalized or ""):lower()

    -- Now parse command name and argument
    local cmdTok, arg = low:match("^/e%s*(%S+)%s*(.*)$")
    if not cmdTok then
        addMessage("Unknown command format.", false)
        return
    end

    -- canonicalize underscores/spaces
    cmdTok = canonicalizeToken(cmdTok)

    -- if exact known command -> execute
    if knownCommands[cmdTok] then
        -- direct execution
        if knownCommands[cmdTok].needsArg then
            if arg == "" or arg == nil then
                addMessage("That command needs an argument. Provide one (e.g. '/e "..cmdTok.." <arg>').", false)
                return
            end
            -- For red/blue we want the raw username (case preserved)
            -- Extract original argument preserving case from inputTrim:
            local origArg = inputTrim:match("^/?.*%s+"..cmdTok.."%s+(.+)$") or arg
            -- fallback plain arg
            executeCommandByName(cmdTok, origArg)
            return
        else
            executeCommandByName(cmdTok, arg)
            return
        end
    end

    -- Not an exact match -> attempt fuzzy suggestion on cmdTok
    local best, dist = findBestMatch(cmdTok)
    -- threshold: allow suggestions up to distance 3 or <= 40% of length
    local threshold = math.max(3, math.floor(#cmdTok * 0.4))
    if best and dist <= threshold then
        -- suggest
        local needsArg = knownCommands[best] and knownCommands[best].needsArg or false
        addMessage(('Unknown Command. Did You Mean "%s"? If So, Say "yes" and if needed, add the argument (e.g. `yes 20` or `yes slow`). Otherwise ignore.'):format(best), false)
        pendingConfirmation = {cmd = best, needsArg = needsArg}
        pendingOriginal = inputTrim
        return
    end

    -- no suggestion found
    addMessage("Unknown command!", false)
end

-- connect input submit
enterBtn.MouseButton1Click:Connect(function()
    local msg = inputBox.Text
    if msg ~= "" then
        addMessage("You: " .. msg, true)
        handleCommand(msg)
        inputBox.Text = ""
    end
end)
inputBox.FocusLost:Connect(function(enter)
    if enter then enterBtn:MouseButton1Click() end
end)

-- Starter message
local function getStarterMessage()
    return "Say /e commands For A List Of Commands."
end
addMessage(getStarterMessage(), false)

-- Connect CharacterAdded for animation re-setup
player.CharacterAdded:Connect(function()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    animator = humanoid:FindFirstChildOfClass("Animator")
    rootPart = character:WaitForChild("HumanoidRootPart")
    isFloating = false
    bodyPos = nil
    currentFloatTrack = nil
    storedJumpStates = {}
    setupAnimation()
end)

-- initial setup call
setupAnimation()
