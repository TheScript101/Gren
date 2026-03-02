--[[ -----------------------------------------------------------------------------------------
    ---------  DA JEEP MODIFIER GUI (Single LocalScript)  -----------------------------------
    Paste into a LocalScript (PlayerScripts / StarterGui) or into your executor.
    I only add big comment headers when a new feature block begins so you can find things easily.
-------------------------------------------------------------------------------------------]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui") or nil

if not PlayerGui then
    warn("PlayerGui not found. Make sure this runs as a LocalScript or in an environment with a LocalPlayer.")
    return
end

-- small util: create instances quickly
local function I(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do obj[k] = v end
    end
    return obj
end

-- style colors
local BG_COLOR = Color3.fromRGB(38,38,40)         -- blackish gray background
local ELEMENT_COLOR = Color3.fromRGB(50,50,50)    -- slightly lighter for buttons
local ON_COLOR = Color3.fromRGB(70,150,70)        -- modern green for ON
local OFF_COLOR = ELEMENT_COLOR
local TEXT_COLOR = Color3.fromRGB(240,240,240)
local SEPARATOR_COLOR = Color3.fromRGB(80,80,80)

-- convenience: make a separator under titles
local function addSeparator(parent, yOffset)
    local sep = I("Frame", {
        Size = UDim2.new(1, -20, 0, 2),
        Position = UDim2.new(0, 10, 0, yOffset or 0),
        BackgroundColor3 = SEPARATOR_COLOR,
        AnchorPoint = Vector2.new(0,0),
        Parent = parent
    })
    return sep
end

-- helper: make UICorner
local function cornerize(obj, radius)
    local c = I("UICorner", {CornerRadius = UDim.new(0, radius or 8)})
    c.Parent = obj
    return c
end

-- helper: dragger for GUI elements (mouse & touch)
local function makeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            dragInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- big container
local screenGui = I("ScreenGui", {
    Name = "DaJeepModifierGUI_v1",
    ResetOnSpawn = false,
    Parent = PlayerGui
})

--[[ -----------------------------------------------------------------------------------------
    ---------  TUTORIAL POP-UP  ---------------------------------------------------------------
-------------------------------------------------------------------------------------------]]
-- large comment header - easy to find
-- TUTORIAL POP-UP
local tutorialMain = I("Frame", {
    Name = "TutorialMain",
    Size = UDim2.new(0, 420, 0, 250),
    Position = UDim2.new(0.5, -210, 0.35, -125),
    BackgroundColor3 = BG_COLOR,
    Parent = screenGui
})
cornerize(tutorialMain, 12)

-- Title
local tTitle = I("TextLabel", {
    Parent = tutorialMain,
    Size = UDim2.new(1, -20, 0, 40),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "Tutorial Needed?",
    TextColor3 = TEXT_COLOR,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left
})
addSeparator(tutorialMain, 50) -- visual separator under title

-- Body text
local tBody = I("TextLabel", {
    Parent = tutorialMain,
    Size = UDim2.new(1, -20, 0, 60),
    Position = UDim2.new(0, 10, 0, 62),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Do you want the tutorial",
    TextColor3 = TEXT_COLOR,
    TextSize = 16,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Buttons container
local tButtons = I("Frame", {
    Parent = tutorialMain,
    Size = UDim2.new(1, -20, 0, 60),
    Position = UDim2.new(0, 10, 1, -70),
    BackgroundTransparency = 1
})
local yesBtn = I("TextButton", {
    Parent = tButtons,
    Size = UDim2.new(0.48, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(55,120,55),
    Font = Enum.Font.GothamBold,
    Text = "Yes",
    TextColor3 = TEXT_COLOR,
    TextScaled = true,
})
cornerize(yesBtn, 10)
local noBtn = I("TextButton", {
    Parent = tButtons,
    Size = UDim2.new(0.48, 0, 1, 0),
    Position = UDim2.new(0.52, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(120,55,55),
    Font = Enum.Font.GothamBold,
    Text = "No",
    TextColor3 = TEXT_COLOR,
    TextScaled = true,
})
cornerize(noBtn, 10)

-- Tutorial detail frame (hidden initially)
local tutorialFrame = I("Frame", {
    Name = "TutorialFrame",
    Size = UDim2.new(0, 420, 0, 300),
    Position = UDim2.new(0.5, -210, 0.35, -150),
    BackgroundColor3 = BG_COLOR,
    Visible = false,
    Parent = screenGui
})
cornerize(tutorialFrame, 12)

local tutTitle = I("TextLabel", {
    Parent = tutorialFrame,
    Size = UDim2.new(1, -20, 0, 40),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "Tutorial",
    TextColor3 = TEXT_COLOR,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left
})
addSeparator(tutorialFrame, 50)

-- image under title - using given asset id
local tutImage = I("ImageLabel", {
    Parent = tutorialFrame,
    Size = UDim2.new(0, 120, 0, 120),
    Position = UDim2.new(0, 10, 0, 62),
    BackgroundTransparency = 1,
    Image = "rbxthumb://type=Asset&id=129018416400347&w=420&h=420",
    ScaleType = Enum.ScaleType.Fit
})
-- text under image
local tutText = I("TextLabel", {
    Parent = tutorialFrame,
    Size = UDim2.new(1, -150, 0, 120),
    Position = UDim2.new(0, 140, 0, 62),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = 'Obtain the "Jeep" emote and place it in this emote slot.',
    TextColor3 = TEXT_COLOR,
    TextSize = 16,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left
})
-- confirm button
local confirmBtn = I("TextButton", {
    Parent = tutorialFrame,
    Size = UDim2.new(0.4, 0, 0, 36),
    Position = UDim2.new(0.5, -((0.4*420)/2), 1, -46),
    BackgroundColor3 = ELEMENT_COLOR,
    Font = Enum.Font.GothamBold,
    Text = "Confirm",
    TextColor3 = TEXT_COLOR
})
cornerize(confirmBtn, 10)

-- Button behavior
yesBtn.MouseButton1Click:Connect(function()
    tutorialMain.Visible = false
    tutorialFrame.Visible = true
end)
noBtn.MouseButton1Click:Connect(function()
    tutorialMain:Destroy() -- remove tutorial pop-up
    -- proceed to main GUI (it will be below)
end)
confirmBtn.MouseButton1Click:Connect(function()
    tutorialFrame:Destroy()
end)

--[[ -----------------------------------------------------------------------------------------
    ---------  MAIN FRAME: DA JEEP MODIFIER  --------------------------------------------------
-------------------------------------------------------------------------------------------]]
-- large comment header - main gui
local mainFrame = I("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 420, 0, 360),
    Position = UDim2.new(0.5, -210, 0.5, -180),
    BackgroundColor3 = BG_COLOR,
    Visible = false,
    Parent = screenGui
})
cornerize(mainFrame, 12)

-- Title
local mainTitle = I("TextLabel", {
    Parent = mainFrame,
    Size = UDim2.new(1, -20, 0, 40),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "DA JEEP MODIFIER",
    TextColor3 = TEXT_COLOR,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left
})
addSeparator(mainFrame, 50)

-- Scrollable features area
local featuresScroll = I("ScrollingFrame", {
    Parent = mainFrame,
    Size = UDim2.new(1, -20, 1, -80),
    Position = UDim2.new(0, 10, 0, 62),
    CanvasSize = UDim2.new(0,0,1,0),
    BackgroundTransparency = 1,
    ScrollBarThickness = 8
})
local uiList = I("UIListLayout", {Parent = featuresScroll, Padding = UDim.new(0,10)})
uiList.FillDirection = Enum.FillDirection.Vertical
uiList.SortOrder = Enum.SortOrder.LayoutOrder

-- helper to update CanvasSize
local function updateCanvas()
    featuresScroll.CanvasSize = UDim2.new(0,0,0, uiList.AbsoluteContentSize.Y + 12)
end
uiList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

-- feature item constructor
local function makeFeature(title)
    local f = I("Frame", {
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundTransparency = 1,
        Parent = featuresScroll
    })
    local ttl = I("TextLabel", {
        Parent = f,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 6),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = TEXT_COLOR,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    addSeparator(f, 28)
    return f
end

--[[ --------- FEATURE 1: Spawn Jeep Button --------------------------------------------------]]
local spawnFeature = makeFeature("Spawn Jeep")
-- Spawn button
local spawnBtn = I("TextButton", {
    Parent = spawnFeature,
    Size = UDim2.new(0.6, 0, 0, 36),
    Position = UDim2.new(0.850000024, -32, 0.400000006, -135),
    BackgroundColor3 = ELEMENT_COLOR,
    Text = "Spawn Jeep",
    Font = Enum.Font.GothamBold,
    TextColor3 = TEXT_COLOR
})
cornerize(spawnBtn, 8)

-- mini version spawn (long hold)
local spawnMiniImageId = "rbxthumb://type=Asset&id=14850118545&w=420&h=420"
local spawnMiniBtn -- store ref to avoid duplicates
local spawnHoldStart = 0
local SPAWN_HOLD_TIME = 0.6

-- spawn Jeep remote action
local function doSpawnJeep()
    local ok, err = pcall(function()
        local args = {[1] = 1}
        -- remote path exactly as requested
        local rem = ReplicatedStorage:FindFirstChild("Knit") and ReplicatedStorage.Knit:FindFirstChild("Knit") or ReplicatedStorage
        -- try to get the remote robustly
        local successRemote = ReplicatedStorage
        -- direct path:
        local maybe = ReplicatedStorage
        if maybe:FindFirstChild("Knit") and maybe.Knit:FindFirstChild("Knit") then
            -- sometimes knit loaded in nested; try exact remote
            local r = maybe.Knit:FindFirstChild("Knit")
            if r and r.Services and r.Services.EmoteService and r.Services.EmoteService.RE and r.Services.EmoteService.RE:FindFirstChild("Emote") == nil then
                -- no inner Emote child; fallback
            end
        end
        -- try exact known path used in your request (safe pcall)
        local targetRemote = nil
        -- attempt numerous safe lookups
        local tryPaths = {
            {"Knit","Knit","Services","EmoteService","RE","Emote"},
            {"Knit","Knit","Services","EmoteService","RE"},
            {"Knit","Services","EmoteService","RE","Emote"},
            {"Knit","Services","EmoteService","RE"}
        }
        for _, pathParts in ipairs(tryPaths) do
            local current = ReplicatedStorage
            local ok2 = true
            for _, name in ipairs(pathParts) do
                if current:FindFirstChild(name) then
                    current = current[name]
                else
                    ok2 = false; break
                end
            end
            if ok2 and current then
                targetRemote = current
                break
            end
        end
        -- fallback: try to find a RemoteEvent named "Emote" somewhere under ReplicatedStorage
        if not targetRemote then
            targetRemote = ReplicatedStorage:FindFirstChild("Emote", true) or ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent", true)
        end
        if targetRemote and targetRemote.FireServer then
            targetRemote:FireServer(unpack(args))
        else
            -- last resort: try the exact path you gave as a string (pcall to avoid errors)
            local success = pcall(function()
                ReplicatedStorage.Knit.Knit.Services.EmoteService.RE.Emote:FireServer(unpack(args))
            end)
            if not success then
                -- warn but keep script running
                warn("Couldn't find target remote for Spawn Jeep. Remote path may differ in this game.")
            end
        end
    end)
    if not ok then warn("Error firing Spawn Jeep:", err) end
end

-- click handler
spawnBtn.MouseButton1Click:Connect(doSpawnJeep)

-- long press detection for spawnBtn to create mini button
spawnBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        spawnHoldStart = tick()
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                conn:Disconnect()
                local held = (tick() - spawnHoldStart) >= SPAWN_HOLD_TIME
                if held and not spawnMiniBtn then
                    -- create mini draggable image button
                    spawnMiniBtn = I("ImageButton", {
                        Parent = screenGui,
                        Size = UDim2.new(0, 48, 0, 48),
                        Position = UDim2.new(0.85, 0, 0.4, 0),
                        BackgroundColor3 = BG_COLOR,
                        Image = spawnMiniImageId,
                        AutoButtonColor = true
                    })
                    cornerize(spawnMiniBtn, 10)
                    -- click on mini triggers spawn
                    spawnMiniBtn.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            doSpawnJeep()
                        end
                    end)
                    makeDraggable(spawnMiniBtn)
                end
            end
        end)
    end
end)

--[[ --------- FEATURE 4: Nuh Uh Emote Button --------------------------------------------------]]

local nuhFeature = makeFeature("Nuh Uh Emote")

-- Main button
local nuhBtn = I("TextButton", {
    Parent = nuhFeature,
    Size = UDim2.new(0.6, 0, 0, 36),
    Position = UDim2.new(0, 10, 0, 36),
    BackgroundColor3 = ELEMENT_COLOR,
    Text = "Play Nuh Uh",
    Font = Enum.Font.GothamBold,
    TextColor3 = TEXT_COLOR
})
cornerize(nuhBtn, 8)

-- Mini image id (rbxthumb 420x420)
local nuhMiniImageId = "rbxthumb://type=Asset&id=16697537181&w=420&h=420"

local nuhMiniBtn
local nuhHoldStart = 0

-- Nuh Uh emote remote action (emote slot 2)
local function doNuhEmote()
    local ok, err = pcall(function()
        local args = {[1] = 2} -- play emote slot 2
        -- same robust remote lookup as Spawn Jeep
        local targetRemote = nil
        local tryPaths = {
            {"Knit","Knit","Services","EmoteService","RE","Emote"},
            {"Knit","Knit","Services","EmoteService","RE"},
            {"Knit","Services","EmoteService","RE","Emote"},
            {"Knit","Services","EmoteService","RE"}
        }
        for _, pathParts in ipairs(tryPaths) do
            local current = ReplicatedStorage
            local ok2 = true
            for _, name in ipairs(pathParts) do
                if current:FindFirstChild(name) then
                    current = current[name]
                else
                    ok2 = false; break
                end
            end
            if ok2 and current then
                targetRemote = current
                break
            end
        end
        if not targetRemote then
            targetRemote = ReplicatedStorage:FindFirstChild("Emote", true) or ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent", true)
        end
        if targetRemote and targetRemote.FireServer then
            targetRemote:FireServer(unpack(args))
        else
            local success = pcall(function()
                ReplicatedStorage.Knit.Knit.Services.EmoteService.RE.Emote:FireServer(unpack(args))
            end)
            if not success then
                warn("Couldn't find target remote for Nuh Uh Emote. Remote path may differ in this game.")
            end
        end
    end)
    if not ok then warn("Error firing Nuh Uh Emote:", err) end
end

-- click handler
nuhBtn.MouseButton1Click:Connect(doNuhEmote)

-- long press detection for nuhBtn to create mini button
nuhBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        nuhHoldStart = tick()
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                conn:Disconnect()
                local held = (tick() - nuhHoldStart) >= SPAWN_HOLD_TIME
                if held and not nuhMiniBtn then
                    -- create mini draggable image button for Nuh Uh Emote
                    nuhMiniBtn = I("ImageButton", {
                        Parent = screenGui,
                        Size = UDim2.new(0, 48, 0, 48),
                        Position = UDim2.new(0.85, 0, 0.32, 0),
                        BackgroundColor3 = BG_COLOR,
                        Image = nuhMiniImageId,
                        AutoButtonColor = true
                    })
                    cornerize(nuhMiniBtn, 10)
                    -- click on mini triggers Nuh Uh
                    nuhMiniBtn.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            doNuhEmote()
                        end
                    end)
                    makeDraggable(nuhMiniBtn)
                end
            end
        end)
    end
end)

--[[ --------- FEATURE 2: Speed Modifier (textbox) ------------------------------------------]]
local speedFeature = makeFeature("Speed Modifier")
-- textbox field
local speedBox = I("TextBox", {
    Parent = speedFeature,
    Size = UDim2.new(0.6, 0, 0, 36),
    Position = UDim2.new(0, 10, 0, 36),
    BackgroundColor3 = ELEMENT_COLOR,
    Text = "500",
    Font = Enum.Font.Gotham,
    TextColor3 = TEXT_COLOR,
    ClearTextOnFocus = false,
    PlaceholderText = "Enter desired speed"
})
cornerize(speedBox, 8)
-- recommended label under that feature
local recLabel = I("TextLabel", {
    Parent = speedFeature,
    Size = UDim2.new(0.6, 0, 0, 20),
    Position = UDim2.new(0, 10, 0, 74),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "*Recommended 500",
    TextColor3 = Color3.fromRGB(180,180,180),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- No mini spawn for this as requested

--[[ --------- FEATURE 3: Toggle Speed -----------------------------------------------------]]
local toggleFeature = makeFeature("Toggle Speed")
-- toggle visual
local toggleBtn = I("TextButton", {
    Parent = toggleFeature,
    Size = UDim2.new(0.2, 0, 0, 36),
    Position = UDim2.new(0, 10, 0, 36),
    BackgroundColor3 = OFF_COLOR,
    Font = Enum.Font.GothamBold,
    Text = "OFF",
    TextColor3 = TEXT_COLOR
})
cornerize(toggleBtn, 8)

-- mini toggle image id
local toggleMiniImageId = "rbxthumb://type=Asset&id=92681645288864&w=420&h=420"
local toggleMiniContainer -- container frame for mini toggle (so we can change its bg color)
local toggleMiniBtnImage -- the image button inside the container
local toggleHoldStart = 0

-- vehicle loop control
local vehicleLoopConnection = nil
local vSpeedOn = false

local function disconnectVehicleLoop()
    if vehicleLoopConnection then
        vehicleLoopConnection:Disconnect()
        vehicleLoopConnection = nil
    end
end

local function applyVehicleImpulse(intens)
    -- disconnect first to avoid double connects
    disconnectVehicleLoop()
    vehicleLoopConnection = RunService.Stepped:Connect(function()
        local subject = workspace.CurrentCamera and workspace.CurrentCamera.CameraSubject
        if subject and subject:IsA("Humanoid") and subject.SeatPart then
            local seat = subject.SeatPart
            -- Apply small impulse each stepped call; this mirrors the nameless admin approach
            seat:ApplyImpulse(seat.CFrame.LookVector * Vector3.new(intens, 0, intens))
        elseif subject and subject:IsA("BasePart") then
            subject:ApplyImpulse(subject.CFrame.LookVector * Vector3.new(intens, 0, intens))
        end
    end)
end

local function setToggleState(on)
    vSpeedOn = on
    if on then
        toggleBtn.BackgroundColor3 = ON_COLOR
        toggleBtn.Text = "ON"
        local intens = tonumber(speedBox.Text) or 500
        -- use the intensity as a scalar for impulse
        applyVehicleImpulse(intens)
    else
        toggleBtn.BackgroundColor3 = OFF_COLOR
        toggleBtn.Text = "OFF"
        disconnectVehicleLoop()
        -- try to reduce velocity of subject smoothly
        local subject = workspace.CurrentCamera and workspace.CurrentCamera.CameraSubject
        if subject then
            local root
            if subject:IsA("Humanoid") and subject.SeatPart then
                root = subject.SeatPart
            elseif subject:IsA("BasePart") then
                root = subject
            end
            if root then
                spawn(function()
                    for i=1,10 do
                        if root and root:IsDescendantOf(game) then
                            root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.8
                            root.AssemblyAngularVelocity = root.AssemblyAngularVelocity * 0.8
                            wait(0.05)
                        end
                    end
                end)
            end
        end
    end

    -- *** NEW/UPDATED: update mini toggle container color to reflect state ***
    if toggleMiniContainer and toggleMiniContainer.Parent then
        toggleMiniContainer.BackgroundColor3 = vSpeedOn and ON_COLOR or BG_COLOR
    end
end

-- basic click toggles
toggleBtn.MouseButton1Click:Connect(function()
    setToggleState(not vSpeedOn)
end)

-- long hold spawn mini toggle
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleHoldStart = tick()
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                conn:Disconnect()
                local held = (tick() - toggleHoldStart) >= SPAWN_HOLD_TIME
                if held and not toggleMiniContainer then
                    -- Create a container frame so we can change background color when toggle is on/off
                    toggleMiniContainer = I("Frame", {
                        Parent = screenGui,
                        Size = UDim2.new(0, 48, 0, 48),
                        Position = UDim2.new(0.85, 30, 0.5, -150),
                        BackgroundColor3 = vSpeedOn and ON_COLOR or BG_COLOR,
                        ZIndex = 1
                    })
                    cornerize(toggleMiniContainer, 10)
                    -- image button inside (transparent background so container bg shows)
                    toggleMiniBtnImage = I("ImageButton", {
                        Parent = toggleMiniContainer,
                        Size = UDim2.new(1, 0, 1, 0),
                        Position = UDim2.new(0,0,0,0),
                        BackgroundTransparency = 1,
                        Image = toggleMiniImageId,
                        AutoButtonColor = true,
                        ZIndex = 2
                    })
                    -- clicking mini toggles the speed (on/off)
                    toggleMiniBtnImage.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            setToggleState(not vSpeedOn)
                        end
                    end)
                    makeDraggable(toggleMiniContainer)
                end
            end
        end)
    end
end)

-- when speed input changes and toggle is ON, update intensity
speedBox.FocusLost:Connect(function(enterPressed)
    if vSpeedOn then
        local newInt = tonumber(speedBox.Text) or 500
        applyVehicleImpulse(newInt)
    end
end)

-- finalize main frame visibility after tutorial handled
-- If the tutorial pop-up was closed with No/Confirm (destroyed), show main frame
-- We'll monitor the tutorial frames and show main when both are gone or hidden
local function showMainIfReady()
    if (not tutorialMain:IsDescendantOf(game) or not tutorialMain.Visible) and (not tutorialFrame:IsDescendantOf(game)) then
        mainFrame.Visible = true
    end
end

-- monitor removals
tutorialMain.AncestryChanged:Connect(showMainIfReady)
tutorialFrame.AncestryChanged:Connect(showMainIfReady)
confirmBtn.MouseButton1Click:Connect(function() mainFrame.Visible = true end)
noBtn.MouseButton1Click:Connect(function() mainFrame.Visible = true end)

-- initial canvas update
updateCanvas()

--[[ -----------------------------------------------------------------------------------------
    ---------  OPTIONAL: Nice small UX touches (drag window, close hotkey) -------------------
-------------------------------------------------------------------------------------------]]
makeDraggable(mainFrame)
makeDraggable(tutorialMain)
makeDraggable(tutorialFrame)

-- Optional: hotkey to close GUI (press RightShift)
local UserInput = game:GetService("UserInputService")
UserInput.InputBegan:Connect(function(inp, gameProcessed)
    if gameProcessed then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

----------------------------------------------------------------
---------------------- MAIN FRAME TOGGLE -----------------------
----------------------------------------------------------------

local MainFrameOpen = true

local OpenCloseButton = Instance.new("TextButton")
OpenCloseButton.Parent = ScreenGui
OpenCloseButton.Size = UDim2.new(0, 45, 0, 45)
OpenCloseButton.Position = UDim2.new(0, 10, 0.5, -22)
OpenCloseButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
OpenCloseButton.Text = "≡"
OpenCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenCloseButton.Font = Enum.Font.GothamBold
OpenCloseButton.TextScaled = true
OpenCloseButton.AutoButtonColor = false
OpenCloseButton.Visible = true

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(1, 0)
SideCorner.Parent = OpenCloseButton

-- toggle logic
OpenCloseButton.MouseButton1Click:Connect(function()

    MainFrameOpen = not MainFrameOpen
    MainFrame.Visible = MainFrameOpen

    if MainFrameOpen then
        OpenCloseButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    else
        OpenCloseButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    end

end)

----------------------------------------------------------------
---------------------- DRAGGABLE BUTTON ------------------------
----------------------------------------------------------------

local dragging = false
local dragInput, dragStart, startPos

OpenCloseButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = OpenCloseButton.Position
    end
end)

OpenCloseButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        OpenCloseButton.Position =
            UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
--[[ -----------------------------------------------------------------------------------------
    ---------  DONE - USAGE NOTES ------------------------------------------------------------
    - Long-press spawn/toggle buttons to create mini draggable buttons.
    - Mini buttons persist until you manually destroy them (re-run script to reset).
    - Speed toggle uses the CameraSubject method similar to nameless admin's vehicle speed loop.
    - Spawn Jeep tries to robustly find and fire the remote; some games have different remote structures.
-------------------------------------------------------------------------------------------]]
