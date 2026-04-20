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
frame.Size = UDim2.new(0, 220, 0, 260)
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
				run:AdjustSpeed(3.2)
            end

            return -- IMPORTANT: prevents walk/idle logic from overriding run
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
            hum.WalkSpeed = 0
            stopMovementAnims()
            death:Play()
        else
            death:Stop() -- FIX
            hum.WalkSpeed = WalkSpeed

            injuredIdle:Stop()
            idle:Stop()
            idle:Play()
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
