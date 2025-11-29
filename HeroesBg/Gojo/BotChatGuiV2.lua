-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local TextChatService = pcall(function() return game:GetService("TextChatService") end) and game:GetService("TextChatService") or nil

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
-- keys: jumpButtonInstance -> { ImageTransparency = num, Active = bool|nil, Selectable = bool|nil, AutoButtonColor = bool|nil }
local storedJumpStates = {}

-- Speech mode: "Bot" (default) or "Chat"
local speechMode = "Bot"

-- Direct getter for the specific JumpButton path you gave
local function getJumpButton()
    local ok, touchGui = pcall(function() return PlayerGui:FindFirstChild("TouchGui") end)
    if not ok or not touchGui then return nil end
    local ok2, touchFrame = pcall(function() return touchGui:FindFirstChild("TouchControlFrame") end)
    if not ok2 or not touchFrame then return nil end
    local ok3, jumpBtn = pcall(function() return touchFrame:FindFirstChild("JumpButton") end)
    if ok3 and jumpBtn then return jumpBtn end
    return nil
end

-- Hide the jump button by setting ImageTransparency = 1 and disabling interaction
local function hideJumpButtons()
    local jb = getJumpButton()
    if not jb then return end
    pcall(function()
        -- store prior states (only if properties exist)
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

        -- record saved state
        storedJumpStates[jb] = prev

        -- apply "hidden + non-interactable" state
        pcall(function() if jb.ImageTransparency ~= nil then jb.ImageTransparency = 1 end end)
        pcall(function() if jb.Active ~= nil then jb.Active = false end end)
        pcall(function() if jb.Selectable ~= nil then jb.Selectable = false end end)
        pcall(function() if jb.AutoButtonColor ~= nil then jb.AutoButtonColor = false end end)
    end)
end

-- Restore the jump button to its previous interactive state
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

-- Helper: stop all playing animations (any animation playing via animator)
local function stopAllAnimations()
    animator = humanoid and humanoid:FindFirstChildOfClass("Animator") or animator
    if animator then
        for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
            pcall(function() t:Stop() end)
        end
    end
end

-- Improved cancelFloat: force-unanchor, destroy BodyPosition, stop/restore animation safely
-- Also restore jump buttons when float stops
local function cancelFloat(stopAnims)
    -- mark not floating
    isFloating = false

    -- restore mobile jump UI (first thing so player regains control quickly)
    pcall(showJumpButtons)

    -- unanchor safely
    pcall(function()
        if rootPart then
            rootPart.Anchored = false
        end
    end)

    -- destroy BodyPosition if present
    if bodyPos then
        pcall(function()
            bodyPos:Destroy()
        end)
        bodyPos = nil
    end

    -- restore animation speed / clear current track reference and stop it
    if currentFloatTrack then
        pcall(function()
            currentFloatTrack:AdjustSpeed(1)
            currentFloatTrack:Stop()
        end)
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

-- Helper to run speech sequence either in private bot chat (GUI) or send to general chat
local function runSpeechSequence(asChat)
    if asChat then
        -- send lines to in-game chat
        pcall(function() sendChatMessage("Sorry, Amanai..") end)
        task.wait(2)
        pcall(function() sendChatMessage("I'm not even angry over you right now..") end)
        task.wait(1.5)
        pcall(function() sendChatMessage("I bear no grudge against anyone..") end)
        task.wait(2)
        pcall(function() sendChatMessage("It's just that the world feels so, so wonderful right now...") end)
        task.wait(1.5)
        pcall(function() sendChatMessage("Throughout Heaven and Earth,") end)
        task.wait(1)
        pcall(function() sendChatMessage("I alone am the honored one..") end)
    else
        -- show in private GUI chat (bot mode)
        addMessage("Sorry, Amanai..", false)
        task.wait(2)
        addMessage("I'm not even angry over you right now..", false)
        task.wait(1.5)
        addMessage("I bear no grudge against anyone..", false)
        task.wait(2)
        addMessage("It's just that the world feels so, so wonderful right now...", false)
        task.wait(1.5)
        addMessage("Throughout Heaven and Earth,", false)
        task.wait(1)
        addMessage("I alone am the honored one..", false)
    end
end

-- setupAnimation function (declared later; needs addMessage defined to use runSpeechSequence)
local function setupAnimation() end

-- GUI Setup (kept exactly as you had it)
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

-- Message UI function (added earlier reference used by runSpeechSequence)
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

-- Handler for commands (updated with /e commands and /e speech_mode)
local function getStarterMessage()
    return "Say /e commands For A List Of Commands.")
end

local function handleCommand(msg)
    local low = msg:lower()

-- /e commands -> Commands
if low == "/e commands" then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/HeroesBg/Gojo/V2Commands.lua"))()
    return
end


    -- /e stop
    if low == "/e stop" then
        if isFloating then
            cancelFloat(true) -- stop animations too
            addMessage("Float and animation has been stopped", false)
        else
            addMessage("Your not in the float phase! There's nothing to stop.", false)
        end
        return
    end

    -- /e height <number>
    local hmatch = low:match("^/e%s*height%s*(%d+)$")
    if hmatch then
        local h = tonumber(hmatch)
        if h then
            floatHeight = h
            addMessage("Height Set To " .. tostring(h), false)
        end
        return
    end

    -- /e speech_mode <mode>
    local smatch = low:match("^/e%s*speech_mode%s*(%w+)$")
    if smatch then
        local mode = smatch:lower()
        if mode == "chat" or mode == "bot" then
            -- normalize display
            speechMode = (mode == "chat") and "Chat" or "Bot"
            addMessage("Speech mode set to " .. speechMode, false)
        else
            addMessage("Invalid speech mode. Use 'chat' or 'bot'.", false)
        end
        return
    end

    -- /e speech (Gojo speech)
    if low == "/e speech" then
        addMessage("Sending speech!", false)
        if speechMode:lower() == "chat" then
            -- send to chat
            task.spawn(function()
                runSpeechSequence(true)
            end)
        else
            -- bot/private GUI
            task.spawn(function()
                runSpeechSequence(false)
            end)
        end
        return
    end

    addMessage("Unknown command!", false)
end

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

-- Starter message replaced with the exact text you requested (shows current mode)
addMessage(getStarterMessage(), false)

-- Keep GUI autoscroll behavior
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    msgFrame.CanvasPosition = Vector2.new(0, layout.AbsoluteContentSize.Y)
end)

-- Now that addMessage exists, define setupAnimation (uses addMessage/runSpeechSequence)
setupAnimation = function()
    -- refresh references
    animator = humanoid and humanoid:FindFirstChildOfClass("Animator") or animator

    -- only connect if animator exists
    if animator then
        animator.AnimationPlayed:Connect(function(track)
            local ok, id = pcall(function() return track.Animation and track.Animation.AnimationId end)
            if not ok or not id then return end

            if id == FLOAT_ANIM_ID then
                if isFloating then return end
                isFloating = true
                currentFloatTrack = track

                -- hide the exact JumpButton path as soon as float starts
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
                -- interrupts should cancel float but not necessarily stop ALL animations
                cancelFloat(false)
            end
        end)
    end

    -- MoveDirection cancels float (existing)
    if humanoid then
        humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
            if isFloating and humanoid.MoveDirection.Magnitude > 0 then
                cancelFloat(false)
            end
        end)

        -- NOTE: Jump detection removed per request.
        -- We do NOT listen to humanoid.Jumping or humanoid.StateChanged anymore.
    end
end

-- Finalize: connect CharacterAdded to resetup on respawn
player.CharacterAdded:Connect(function()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    animator = humanoid:FindFirstChildOfClass("Animator")
    rootPart = character:WaitForChild("HumanoidRootPart")
    -- reset float vars to be safe
    isFloating = false
    bodyPos = nil
    currentFloatTrack = nil
    storedJumpStates = {}
    setupAnimation()
end)

-- initial setup call
setupAnimation()
