local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

wait(0.5)
game:GetService("StarterGui"):SetCore("SendNotification", {
	Title = "Loaded",
	Text = "Choose Your Options",
	Duration = 2.5
})

local function createPrompt(guiName, promptTitle, promptInfo, yesText, noText, yesCallback, noCallback, nextStep)
	local old = guiParent:FindFirstChild(guiName)
	if old then
		old:Destroy()
	end

	function(choice)
	if choice == "Killer" then
		role = "Killer"
	else
		role = "Guest"
	end

	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Role Selected",
		Text = role,
		Duration = 1
	})
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = guiName
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = guiParent

	local shadow = Instance.new("Frame")
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.Position = UDim2.new(0.5, 6, 0.5, 8)
	shadow.Size = UDim2.new(0, 380, 0, 230)
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.4
	shadow.Parent = gui
	Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 22)

	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.Size = UDim2.new(0, 380, 0, 230)
	frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	frame.Parent = gui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 22)

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = Color3.fromRGB(80, 80, 90)
	stroke.Transparency = 0.25
	stroke.Parent = frame

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 38)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 22))
	}
	gradient.Parent = frame

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 16, 0, 10)
	title.Size = UDim2.new(1, -32, 0, 52)
	title.Font = Enum.Font.GothamBold
	title.Text = promptTitle
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 20
	title.Parent = frame

	local line1 = Instance.new("TextLabel")
	line1.BackgroundTransparency = 1
	line1.Position = UDim2.new(0, 10, 0, 0)
	line1.Size = UDim2.new(1, -20, 0, 18)
	line1.Font = Enum.Font.Gotham
	line1.Text = "---------------------------------------------------------"
	line1.TextColor3 = Color3.fromRGB(120, 120, 130)
	line1.TextSize = 14
	line1.Parent = frame

	local line2 = Instance.new("TextLabel")
	line2.BackgroundTransparency = 1
	line2.Position = UDim2.new(0, 10, 0, 48)
	line2.Size = UDim2.new(1, -20, 0, 18)
	line2.Font = Enum.Font.Gotham
	line2.Text = "---------------------------------------------------------"
	line2.TextColor3 = Color3.fromRGB(120, 120, 130)
	line2.TextSize = 14
	line2.Parent = frame

	local info = Instance.new("TextLabel")
	info.BackgroundTransparency = 1
	info.Position = UDim2.new(0, 18, 0, 78)
	info.Size = UDim2.new(1, -36, 0, 28)
	info.Font = Enum.Font.Gotham
	info.Text = promptInfo
	info.TextColor3 = Color3.fromRGB(205, 205, 215)
	info.TextSize = 15
	info.Parent = frame

	local function makeButton(text, pos, accent)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 160, 0, 50)
		btn.Position = pos
		btn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
		btn.Text = text
		btn.Font = Enum.Font.GothamSemibold
		btn.TextSize = 18
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.AutoButtonColor = false
		btn.Parent = frame
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)

		local btnStroke = Instance.new("UIStroke")
		btnStroke.Thickness = 1
		btnStroke.Color = Color3.fromRGB(85, 85, 95)
		btnStroke.Transparency = 0.25
		btnStroke.Parent = btn

		local bar = Instance.new("Frame")
		bar.BackgroundColor3 = accent
		bar.BorderSizePixel = 0
		bar.Position = UDim2.new(0, 0, 1, -4)
		bar.Size = UDim2.new(1, 0, 0, 4)
		bar.Parent = btn
		Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 14)

		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(42, 42, 50)}):Play()
		end)

		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(32, 32, 38)}):Play()
		end)

		return btn
	end

	local yes = makeButton(yesText, UDim2.new(0, 20, 0, 132), Color3.fromRGB(70, 170, 90))
	local no = makeButton(noText, UDim2.new(1, -180, 0, 132), Color3.fromRGB(170, 70, 70))

	do
		local dragging = false
		local dragStart
		local startPos

		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		frame.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				if dragging then
					local delta = input.Position - dragStart
					frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
					shadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + 6, startPos.Y.Scale, startPos.Y.Offset + delta.Y + 8)
				end
			end
		end)
	end

	yes.MouseButton1Click:Connect(function()
		if yesCallback then
			yesCallback()
		end
		gui:Destroy()
		if nextStep then
			wait(1)
			nextStep()
		end
	end)

	no.MouseButton1Click:Connect(function()
		if noCallback then
			noCallback()
		end
		gui:Destroy()
		if nextStep then
			wait(1)
			nextStep()
		end
	end)
end

local role = "Guest" -- default

createPrompt(
	"1_GUI",
	"Guest or Killer?",
	"Pick a option.",
	"Guest",
	"Killer",
	function(choice)
		if choice == "Killer" then
			role = "Killer"
		else
			role = "Guest"
		end

		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Role Selected",
			Text = role,
			Duration = 1
		})
	end
)

--// CONFIG
local IdleAnim = "rbxassetid://98946450554814"
local InjuredIdleAnim = "rbxassetid://73905365652295"
local InjuredWalkAnim = "rbxassetid://85811471336028" -- FIX (added)
local WalkAnim = "rbxassetid://119545916455209"
local RunAnim = "rbxassetid://102622695004986"
local BlockAnim = "rbxassetid://105310177683245"
local PunchAnim = "rbxassetid://87725149616750"
local DeathAnim = "rbxassetid://76861507413325"

local WalkSpeed = 10
local RunSpeed = 21
local noWindup = false -- SETTINGS TOGGLE

--// SERVICES
local Players = game:GetService("Players")
local player = Players.LocalPlayer

--// GUI
local gui = player.PlayerGui:FindFirstChild("MoveGui") or Instance.new("ScreenGui")
gui.Name = "MoveGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = player.PlayerGui.MoveGui:FindFirstChild("MainFrame") or Instance.new("Frame", gui)
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 220, 0, 305)
frame.Position = UDim2.new(0.5, -110, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local stroke = frame:FindFirstChild("Stroke") or Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(70, 110, 60)
stroke.Thickness = 2.75

--// ACCESS CHECK
local REQUIRED_USER_ID = 10598122115

local Players = game:GetService("Players")
local found = false

for _, plr in ipairs(Players:GetPlayers()) do
	if plr.UserId == REQUIRED_USER_ID then
		found = true
		break
	end
end

-- also check future joins (in case script runs early)
if not found then
	local conn
	conn = Players.PlayerAdded:Connect(function(plr)
		if plr.UserId == REQUIRED_USER_ID then
			found = true
			conn:Disconnect()
		end
	end)

	task.wait(2) -- small wait to allow joins

	if not found then
		warn("Nah; YOU HAVE TO HAVE ME IN GAME")
		return -- STOPS ENTIRE SCRIPT
	end
end

local title = frame:FindFirstChild("Title") or Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "Guest 1337"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- SETTINGS BUTTON (top-left)
local settingsBtn = Instance.new("TextButton", frame)
settingsBtn.Size = UDim2.new(0, 25, 0, 25)
settingsBtn.Position = UDim2.new(0, 5, 0, 0)
settingsBtn.Text = "⚙"
settingsBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
settingsBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", settingsBtn)

-- SETTINGS PANEL
local settingsPanel = Instance.new("Frame", frame)
settingsPanel.Size = UDim2.new(0, 180, 1, 0)
settingsPanel.Position = UDim2.new(1, 5, 0, 0) -- sits to the right
settingsPanel.BackgroundColor3 = Color3.fromRGB(25,25,25)
settingsPanel.Visible = false
Instance.new("UICorner", settingsPanel)

local panelStroke = Instance.new("UIStroke", settingsPanel)
panelStroke.Color = Color3.fromRGB(70,110,60)
panelStroke.Thickness = 2

-- TITLE
local settingsTitle = Instance.new("TextLabel", settingsPanel)
settingsTitle.Size = UDim2.new(1, 0, 0, 25)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "Settings"
settingsTitle.TextColor3 = Color3.new(1,1,1)
settingsTitle.Font = Enum.Font.SourceSansBold
settingsTitle.TextSize = 18

-- TOGGLE BUTTON
local windupToggle = Instance.new("TextButton", settingsPanel)
windupToggle.Size = UDim2.new(1, -10, 0, 40)
windupToggle.Position = UDim2.new(0, 5, 0, 35)
windupToggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
windupToggle.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", windupToggle)

local function updateToggle()
	if noWindup then
		windupToggle.Text = "No Punch Wind-Up: ON"
	else
		windupToggle.Text = "No Punch Wind-Up: OFF"
	end
end

updateToggle()

windupToggle.MouseButton1Click:Connect(function()
	noWindup = not noWindup
	updateToggle()
end)

settingsBtn.MouseButton1Click:Connect(function()
	settingsPanel.Visible = not settingsPanel.Visible
end)

local scroll = frame:FindFirstChild("Scroll") or Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -10, 1, -35)
scroll.Position = UDim2.new(0, 5, 0, 30)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 4
scroll.BackgroundTransparency = 1

local layout = scroll:FindFirstChild("Layout") or Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 5)

local function makeBtn(name, text, color)
	local b = scroll:FindFirstChild(name) or Instance.new("TextButton", scroll)
	b.Name = name
	b.Size = UDim2.new(1, -5, 0, 40)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", b)
	return b
end

local runBtn = makeBtn("Run", "Run", Color3.fromRGB(70,130,90))
local blockBtn = makeBtn("Block", "Block", Color3.fromRGB(80,80,120))
local punchBtn = makeBtn("Punch", "Punch", Color3.fromRGB(140,70,70))
local injuredBtn = makeBtn("Injured", "Injured", Color3.fromRGB(120,90,40))
local deathBtn = makeBtn("Death", "Death", Color3.fromRGB(90,40,40))
-- NEW:
local parryBtn  = makeBtn("Parry",  "Parry",  Color3.fromRGB(100,150,180))

--// STATE
local running = false
local blocking = false
local injured = false
local deadLoop = false
local punching = false

local currentConnections = {}

local function disconnectAll()
	for _, c in pairs(currentConnections) do
		pcall(function() c:Disconnect() end)
	end
	currentConnections = {}
end

--// MAIN
local function setupChar(char)
	disconnectAll()

	local hum = char:WaitForChild("Humanoid")
	local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)

	-- FIX: disable default animate (prevents blending)
	local animate = char:FindFirstChild("Animate")
	if animate then animate.Disabled = true end

	hum.WalkSpeed = WalkSpeed


	-- disable jump safely
	hum.JumpPower = 0
	hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

	table.insert(currentConnections,
		hum:GetPropertyChangedSignal("Jump"):Connect(function()
			hum.Jump = false
		end)
	)

	-- remove mobile jump (wait properly)
	task.spawn(function()
		local pg = player:WaitForChild("PlayerGui")
		local touch = pg:WaitForChild("TouchGui", 5)
		if touch then
			local frame = touch:WaitForChild("TouchControlFrame", 5)
			if frame then
				local jump = frame:FindFirstChild("JumpButton")
				if jump then jump:Destroy() end
			end
		end
	end)

	-- FIX: load with priority
	local function load(id, priority)
		local a = Instance.new("Animation")
		a.AnimationId = id
		local track = animator:LoadAnimation(a)
		if priority then track.Priority = priority end
		return track
	end

local idle = load(IdleAnim, Enum.AnimationPriority.Idle)
local walk = load(WalkAnim, Enum.AnimationPriority.Movement)

-- injured overlays MUST be Action priority
local injuredIdle = load(InjuredIdleAnim, Enum.AnimationPriority.Action)
local injuredWalk = load(InjuredWalkAnim, Enum.AnimationPriority.Action)

local run = load(RunAnim, Enum.AnimationPriority.Action)
	local block = load(BlockAnim, Enum.AnimationPriority.Action)
	local punch = load(PunchAnim, Enum.AnimationPriority.Action4)
	local death = load(DeathAnim, Enum.AnimationPriority.Action)

	idle.Looped = true
	injuredIdle.Looped = true
	walk.Looped = true
	run.Looped = true
	death.Looped = true

	local function stopMovementAnims()
		idle:Stop()
		injuredIdle:Stop()
		walk:Stop()
		run:Stop()
	end

table.insert(currentConnections,
    game:GetService("RunService").RenderStepped:Connect(function()
        if not hum or not hum.Parent then return end
        if blocking or deadLoop or punching then return end

        local moving = hum.MoveDirection.Magnitude > 0

        -- RUN MODE (highest priority)
        if running and moving and not injured then
            hum.WalkSpeed = RunSpeed

            -- stop all lower layers
            if walk.IsPlaying then walk:Stop() end
            if injuredWalk.IsPlaying then injuredWalk:Stop() end
            if injuredIdle.IsPlaying then injuredIdle:Stop() end

            -- play run
            if not run.IsPlaying then
                run:Play()
                run:AdjustWeight(1.5)
				run:AdjustSpeed(4)
            end

            return -- IMPORTANT: prevents walk/idle logic from overriding run
        end

-- STOP RUN WHEN NOT MOVING
if running and not moving then
    if run.IsPlaying then
        run:Stop()
    end
end


-- INJURED MOVEMENT SYSTEM
-- INJURED MOVEMENT SYSTEM
if injured then
    hum.WalkSpeed = 7

    -- ALWAYS PLAY IDLE (BASE LAYER)
    if not idle.IsPlaying then
        idle:Play()
    end
    idle:AdjustWeight(3) -- your request

    -- ALWAYS PLAY INJURED IDLE OVERLAY
    if not injuredIdle.IsPlaying then
        injuredIdle:Play()
    end
    injuredIdle:AdjustWeight(1.2)

    if moving then
        -- WALKING INJURED

        -- walk layer
        if not walk.IsPlaying then
            walk:Play()
        end
        walk:AdjustWeight(0.7)

        -- injured walk overlay
        if not injuredWalk.IsPlaying then
            injuredWalk:Play()
        end
        injuredWalk:AdjustWeight(1.0)

    else
        -- IDLE INJURED

        -- stop walk layers ONLY
        if walk.IsPlaying then walk:Stop() end
        if injuredWalk.IsPlaying then injuredWalk:Stop() end
    end

else
    -- NORMAL MODE
    injuredIdle:Stop()
    injuredWalk:Stop()

    if moving then
        if not walk.IsPlaying then walk:Play() end
        idle:Stop()
    else
        walk:Stop()
        if not idle.IsPlaying then idle:Play() end
    end
end
    end)
)


table.insert(currentConnections,
    parryBtn.MouseButton1Click:Connect(function()
        if deadLoop then return end

        -- cancel block if active
        if blocking then
            blocking = false
            block:Stop()
            hum.WalkSpeed = WalkSpeed
            blockBtn.Text = "Block"
        end

        -- do a fast punch (parry)
        punching = true
        running = false
        hum.WalkSpeed = 0

        -- stop movement anims + any other tracks
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
            track:Stop()
        end

        punch:Play()

if noWindup then
	punch.TimePosition = 0.98
end

punch:AdjustSpeed(2)

        task.delay((punch.Length > 0 and punch.Length or 0.6) / 2, function()
            punching = false
            hum.WalkSpeed = running and RunSpeed or WalkSpeed
        end)
    end)
)



-- RUN
table.insert(currentConnections,
	runBtn.MouseButton1Click:Connect(function()
		if blocking or deadLoop or punching then return end

		-- PREVENT RUN WHILE INJURED
		if injured then
			runBtn.Text = "Become Uninjured To Run"
			task.delay(0.5, function()
				if not running then
					runBtn.Text = "Run"
				end
			end)
			return
		end

		running = not running

		if running then
			hum.WalkSpeed = RunSpeed
			runBtn.Text = "Walk"
		else
			hum.WalkSpeed = WalkSpeed
			runBtn.Text = "Run"

			-- 🔥 FIX: force stop run animation immediately
			if run.IsPlaying then
				run:Stop()
			end
		end
	end)
	)

	-- BLOCK
	table.insert(currentConnections,
		blockBtn.MouseButton1Click:Connect(function()
			if deadLoop or punching then return end

			blocking = not blocking

			if blocking then
				running = false
				hum.WalkSpeed = 0
				stopMovementAnims()
				block:Play()

				task.delay(0.9, function()
					if blocking then
						block:AdjustSpeed(0)
					end
				end)

				blockBtn.Text = "Unblock"
			else
				block:Stop()
				hum.WalkSpeed = WalkSpeed
				blockBtn.Text = "Block"
			end
		end)
	)

-- INJURED
table.insert(currentConnections,
injuredBtn.MouseButton1Click:Connect(function()
    if deadLoop or punching then return end

    injured = not injured

    if injured then
        hum.WalkSpeed = 7
        injuredBtn.Text = "Normal"

        -- force injured overlay ON
        if not injuredIdle.IsPlaying then
            injuredIdle:Play()
            injuredIdle:AdjustWeight(1.1)
        end

        -- force injured walk ON
        if not injuredWalk.IsPlaying then
            injuredWalk:Play()
            injuredWalk:AdjustWeight(1.0)
        end

    else
        -- leaving injured mode
        hum.WalkSpeed = WalkSpeed
        injuredBtn.Text = "Injured"

        injuredIdle:Stop()
        injuredWalk:Stop()
    end
end)
)


	-- PUNCH (FULL FIX)
	table.insert(currentConnections,
		punchBtn.MouseButton1Click:Connect(function()
			if deadLoop or punching then return end

			punching = true
			running = false
			blocking = false
			hum.WalkSpeed = 0

			stopMovementAnims()

			for _, track in pairs(animator:GetPlayingAnimationTracks()) do
				track:Stop()
			end

			punch:Play()

if noWindup then
	punch.TimePosition = 1.2
				end

			task.delay(punch.Length > 0 and punch.Length or 0.6, function()
				punching = false
				hum.WalkSpeed = running and RunSpeed or WalkSpeed
			end)
		end)
	)

-- DEATH
table.insert(currentConnections,
    deathBtn.MouseButton1Click:Connect(function()
        deadLoop = not deadLoop

        if deadLoop then
            -- hard override all states
            running = false
            blocking = false
            injured = false
            punching = false

            hum.WalkSpeed = 0

            -- stop everything
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                track:Stop()
            end

            -- make sure injured visuals are gone
            injuredIdle:Stop()
            injuredWalk:Stop()
            injuredBtn.Text = "Injured"

            -- play only death
            death:Play()
        else
            -- leaving death
            death:Stop()
            hum.WalkSpeed = WalkSpeed

            -- restart base idle
            if not idle.IsPlaying then
                idle:Play()
            end
        end
    end)
)


idle:Play()
end -- closes setupChar()


-- INIT
if player.Character then
	setupChar(player.Character)
end

player.CharacterAdded:Connect(setupChar)
