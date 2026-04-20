--// CONFIG
local IdleAnim = "rbxassetid://98946450554814"
local InjuredIdleAnim = "rbxassetid://73905365652295"
local WalkAnim = "rbxassetid://119545916455209"
local RunAnim = "rbxassetid://102622695004986"
local BlockAnim = "rbxassetid://105310177683245"
local PunchAnim = "rbxassetid://87725149616750"
local DeathAnim = "rbxassetid://76861507413325"

local WalkSpeed = 10
local RunSpeed = 28

--// SERVICES
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function applyFreeze(char)
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	local animator = hum:FindFirstChildOfClass("Animator")

	-- store old speed
	local oldSpeed = hum.WalkSpeed

	-- stop all current animations
	if animator then
		for _, track in pairs(animator:GetPlayingAnimationTracks()) do
			track:Stop()
		end
	end

	-- block new animations during freeze
	local animBlock
	animBlock = hum.AnimationPlayed:Connect(function(track)
		track:Stop()
	end)

	-- freeze player
	hum.WalkSpeed = 0
	root.Anchored = true

	task.wait(1)

	-- restore
	root.Anchored = false
	hum.WalkSpeed = 10

	if animBlock then
		animBlock:Disconnect()
	end
end

-- run now
if player.Character then
	applyFreeze(player.Character)
end

-- run on respawn
player.CharacterAdded:Connect(applyFreeze)

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

	-- FIX: load with priority
	local function load(id, priority)
		local a = Instance.new("Animation")
		a.AnimationId = id
		local track = animator:LoadAnimation(a)
		if priority then track.Priority = priority end
		return track
	end

	local idle = load(IdleAnim, Enum.AnimationPriority.Idle)
	local injuredIdle = load(InjuredIdleAnim, Enum.AnimationPriority.Idle)
	local walk = load(WalkAnim, Enum.AnimationPriority.Movement)
	local run = load(RunAnim, Enum.AnimationPriority.Movement)
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
			local currentIdle = injured and injuredIdle or idle

			if moving then
				if currentIdle.IsPlaying then currentIdle:Stop() end

				if running then
					if not run.IsPlaying then
						walk:Stop()
						run:Play()
						run:AdjustSpeed(3) -- FIX
					end
				else
					if not walk.IsPlaying then
						run:Stop()
						walk:Play()
					end
				end
			else
				if walk.IsPlaying then walk:Stop() end
				if run.IsPlaying then run:Stop() end
				if not currentIdle.IsPlaying then currentIdle:Play() end
			end
		end)
	)

	-- RUN
	table.insert(currentConnections,
		runBtn.MouseButton1Click:Connect(function()
			if blocking or deadLoop or punching then return end
			running = not running
			hum.WalkSpeed = running and RunSpeed or WalkSpeed
			runBtn.Text = running and "Walk" or "Run"
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
				hum.WalkSpeed = 0
				stopMovementAnims()

				task.delay(1, function()
					if injured then
						hum.WalkSpeed = WalkSpeed
					end
				end)

				injuredBtn.Text = "Normal"
			else
				hum.WalkSpeed = WalkSpeed
				injuredBtn.Text = "Injured"
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
				death:Stop()
				hum.WalkSpeed = WalkSpeed
			end
		end)
	)

	idle:Play()
end

-- INIT
if player.Character then
	setupChar(player.Character)
end

player.CharacterAdded:Connect(setupChar)
