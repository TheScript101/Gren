--// CONFIG
local IdleAnim = "rbxassetid://127972564618207"
local WalkAnim = "rbxassetid://103118629044297"
local RunAnim = "rbxassetid://102622695004986"
local BlockAnim = "rbxassetid://105310177683245"

local WalkSpeed = 6
local RunSpeed = 28

--// SERVICES
local Players = game:GetService("Players")
local player = Players.LocalPlayer

--// GUI (ONLY CREATE ONCE)
local gui = player.PlayerGui:FindFirstChild("MoveGui") or Instance.new("ScreenGui")
gui.Name = "MoveGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = gui:FindFirstChild("MainFrame") or Instance.new("Frame", gui)
frame.Name = "MainFrame"
frame.Size = UDim2.new(0,180,0,110)
frame.Position = UDim2.new(0.5,-90,0.5,-55)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local blockBtn = frame:FindFirstChild("Block") or Instance.new("TextButton", frame)
blockBtn.Name = "Block"
blockBtn.Size = UDim2.new(0.9,0,0,40)
blockBtn.Position = UDim2.new(0.05,0,0.05,0)
blockBtn.Text = "Block"
blockBtn.BackgroundColor3 = Color3.fromRGB(80,80,120)
blockBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", blockBtn)

local runBtn = frame:FindFirstChild("Run") or Instance.new("TextButton", frame)
runBtn.Name = "Run"
runBtn.Size = UDim2.new(0.9,0,0,40)
runBtn.Position = UDim2.new(0.05,0,0.55,0)
runBtn.Text = "Run"
runBtn.BackgroundColor3 = Color3.fromRGB(70,130,90)
runBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", runBtn)

--// STATE
local running = false
local blocking = false

-- connection holders
local currentConnections = {}

local function disconnectAll()
	for _,c in pairs(currentConnections) do
		pcall(function() c:Disconnect() end)
	end
	currentConnections = {}
end

--// MAIN SETUP
local function setupChar(char)
	disconnectAll()

	-- reset state
	running = false
	blocking = false
	runBtn.Text = "Run"
	blockBtn.Text = "Block"

	local hum = char:WaitForChild("Humanoid")
	local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)

	hum.WalkSpeed = WalkSpeed

	-- disable default animate
	local animate = char:FindFirstChild("Animate")
	if animate then animate.Disabled = true end

	-- remove banned anims
	local banned = {
		["rbxassetid://913376220"] = true,
		["rbxassetid://913402848"] = true,
		["rbxassetid://14366558676"] = true
	}

	table.insert(currentConnections,
		hum.AnimationPlayed:Connect(function(track)
			local id = track.Animation and track.Animation.AnimationId
			if id and banned[id] then
				track:Stop()
				track:Destroy()
			end
		end)
	)

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

	-- load animations
	local function load(id)
		local a = Instance.new("Animation")
		a.AnimationId = id
		return animator:LoadAnimation(a)
	end

	local idle = load(IdleAnim)
	local walk = load(WalkAnim)
	local run = load(RunAnim)
	local block = load(BlockAnim)

	idle.Looped = true
	walk.Looped = true
	run.Looped = true


	-- WALK STUFF
local RunService = game:GetService("RunService")

table.insert(currentConnections,
	RunService.RenderStepped:Connect(function()
		if not hum or not hum.Parent then return end
		if blocking then return end

		local moving = hum.MoveDirection.Magnitude > 0

		if moving then
			if idle.IsPlaying then idle:Stop() end

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
					walk:AdjustSpeed(3.5)
				end
			end
		else
			if walk.IsPlaying then walk:Stop() end
			if run.IsPlaying then run:Stop() end

			if not idle.IsPlaying then
				idle:Play()
			end
		end
	end)
)
	
	-- BUTTONS (CONNECTED ONCE PER CHARACTER)
	disconnectAll() -- prevent stacking

	currentConnections[#currentConnections+1] = runBtn.MouseButton1Click:Connect(function()
		if blocking then return end
		running = not running

		hum.WalkSpeed = running and RunSpeed or WalkSpeed
		runBtn.Text = running and "Walk" or "Run"
	end)

	currentConnections[#currentConnections+1] = blockBtn.MouseButton1Click:Connect(function()
		blocking = not blocking

		if blocking then
			running = false
			hum.WalkSpeed = 0

			idle:Stop()
			walk:Stop()
			run:Stop()

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

	idle:Play()
end

-- INIT
if player.Character then
	setupChar(player.Character)
end

player.CharacterAdded:Connect(setupChar)
