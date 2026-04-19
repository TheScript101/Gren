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

--// GUI
local gui = player.PlayerGui:FindFirstChild("MoveGui") or Instance.new("ScreenGui")
gui.Name = "MoveGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = gui:FindFirstChild("MainFrame") or Instance.new("Frame", gui)
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 220, 0, 260)
frame.Position = UDim2.new(0.5, -110, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

-- camo outline
local stroke = frame:FindFirstChild("Stroke") or Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(70, 110, 60)
stroke.Thickness = 2

-- title
local title = frame:FindFirstChild("Title") or Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "Guest 1337"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- scrolling container
local scroll = frame:FindFirstChild("Scroll") or Instance.new("ScrollingFrame", frame)
scroll.Name = "Scroll"
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

local deathBtn = makeBtn("Death", "Death", Color3.fromRGB(90, 40, 40))
local injuredBtn = makeBtn("Injured", "Injured", Color3.fromRGB(120, 90, 40))
local punchBtn = makeBtn("Punch", "Punch", Color3.fromRGB(140, 70, 70))
local blockBtn = makeBtn("Block", "Block", Color3.fromRGB(80, 80, 120))
local runBtn = makeBtn("Run", "Run", Color3.fromRGB(70, 130, 90))

--// STATE
local running = false
local blocking = false
local injured = false
local deadLoop = false

local currentConnections = {}

local function disconnectAll()
	for _, c in pairs(currentConnections) do
		pcall(function() c:Disconnect() end)
	end
	currentConnections = {}
end

--// MAIN SETUP
local function setupChar(char)
	disconnectAll()

	running = false
	blocking = false
	injured = false
	deadLoop = false

	runBtn.Text = "Run"
	blockBtn.Text = "Block"

	local hum = char:WaitForChild("Humanoid")
	local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)

	hum.WalkSpeed = WalkSpeed

	local animate = char:FindFirstChild("Animate")
	if animate then animate.Disabled = true end

	local function load(id)
		local a = Instance.new("Animation")
		a.AnimationId = id
		return animator:LoadAnimation(a)
	end

	local idle = load(IdleAnim)
	local injuredIdle = load(InjuredIdleAnim)
	local walk = load(WalkAnim)
	local run = load(RunAnim)
	local block = load(BlockAnim)
	local punch = load(PunchAnim)
	local death = load(DeathAnim)

	idle.Looped = true
	injuredIdle.Looped = true
	walk.Looped = true
	run.Looped = true
	death.Looped = true

	local RunService = game:GetService("RunService")

	table.insert(currentConnections,
		RunService.RenderStepped:Connect(function()
			if not hum or not hum.Parent then return end
			if blocking or deadLoop then return end

			local moving = hum.MoveDirection.Magnitude > 0

			local currentIdle = injured and injuredIdle or idle

			if moving then
				if currentIdle.IsPlaying then currentIdle:Stop() end

				if running then
					if not run.IsPlaying then
						walk:Stop()
						run:Play()
						run:AdjustSpeed(3)
					end
				else
					if not walk.IsPlaying then
						run:Stop()
						walk:Play()
						walk:AdjustSpeed(1)
					end
				end
			else
				if walk.IsPlaying then walk:Stop() end
				if run.IsPlaying then run:Stop() end

				if not currentIdle.IsPlaying then
					currentIdle:Play()
				end
			end
		end)
	)

	-- RUN
	table.insert(currentConnections,
		runBtn.MouseButton1Click:Connect(function()
			if blocking or deadLoop then return end
			running = not running

			hum.WalkSpeed = running and RunSpeed or WalkSpeed
			runBtn.Text = running and "Walk" or "Run"
		end)
	)

	-- BLOCK
	table.insert(currentConnections,
		blockBtn.MouseButton1Click:Connect(function()
			if deadLoop then return end

			blocking = not blocking

			if blocking then
				running = false
				hum.WalkSpeed = 0

				idle:Stop()
				injuredIdle:Stop()
				walk:Stop()
				run:Stop()

				block:Play()
				blockBtn.Text = "Unblock"
			else
				block:Stop()
				hum.WalkSpeed = WalkSpeed
				blockBtn.Text = "Block"
			end
		end)
	)

	-- INJURED TOGGLE
	table.insert(currentConnections,
		injuredBtn.MouseButton1Click:Connect(function()
			if deadLoop then return end
			injured = not injured
			injuredBtn.Text = injured and "Normal" or "Injured"
		end)
	)

	-- PUNCH
	table.insert(currentConnections,
		punchBtn.MouseButton1Click:Connect(function()
			if deadLoop then return end
			local p = punch:Play()
		end)
	)

	-- DEATH LOOP
	table.insert(currentConnections,
		deathBtn.MouseButton1Click:Connect(function()
			deadLoop = not deadLoop

			if deadLoop then
				running = false
				blocking = false
				hum.WalkSpeed = 0

				idle:Stop()
				injuredIdle:Stop()
				walk:Stop()
				run:Stop()

				death:Play()
				deathBtn.Text = "Stop Death"
			else
				death:Stop()
				hum.WalkSpeed = WalkSpeed
				deathBtn.Text = "Death"
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
