--// CONFIG
local WalkAnim = "rbxassetid://103118629044297"
local RunAnim = "rbxassetid://102622695004986"
local BlockAnim = "rbxassetid://105310177683245"

local WalkSpeed = 6
local RunSpeed = 28

--// SERVICES
local Players = game:GetService("Players")
local player = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,180,0,110)
frame.Position = UDim2.new(0.5,-90,0.5,-55)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local blockBtn = Instance.new("TextButton", frame)
blockBtn.Size = UDim2.new(0.9,0,0,40)
blockBtn.Position = UDim2.new(0.05,0,0.05,0)
blockBtn.Text = "Block"
blockBtn.BackgroundColor3 = Color3.fromRGB(80,80,120)
blockBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", blockBtn)

local runBtn = Instance.new("TextButton", frame)
runBtn.Size = UDim2.new(0.9,0,0,40)
runBtn.Position = UDim2.new(0.05,0,0.55,0)
runBtn.Text = "Run"
runBtn.BackgroundColor3 = Color3.fromRGB(70,130,90)
runBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", runBtn)

--// STATE
local running = false
local blocking = false
local walkTrack, runTrack, blockTrack

local function setupChar(char)
	local hum = char:WaitForChild("Humanoid")
	local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)

	hum.WalkSpeed = WalkSpeed

	-- disable default animate script (fixes stacking)
	local animate = char:FindFirstChild("Animate")
	if animate then animate.Disabled = true end

	-- load animations
	local function load(id)
		local anim = Instance.new("Animation")
		anim.AnimationId = id
		return animator:LoadAnimation(anim)
	end

	walkTrack = load(WalkAnim)
	runTrack = load(RunAnim)
	blockTrack = load(BlockAnim)

	walkTrack.Looped = true
	runTrack.Looped = true

	-- movement handling (FIX idle issues)
	hum.Running:Connect(function(speed)
		if blocking then return end

		if speed > 0 then
			if running then
				if not runTrack.IsPlaying then
					walkTrack:Stop()
					runTrack:Play()
					runTrack:AdjustSpeed(3) -- 3x speed
				end
			else
				if not walkTrack.IsPlaying then
					runTrack:Stop()
					walkTrack:Play()
					walkTrack:AdjustSpeed(3) -- 3x speed
				end
			end
		else
			walkTrack:Stop()
			runTrack:Stop()
		end
	end)

	-- RUN TOGGLE
	runBtn.MouseButton1Click:Connect(function()
		if blocking then return end
		running = not running

		if running then
			hum.WalkSpeed = RunSpeed
			runBtn.Text = "Walk"
		else
			hum.WalkSpeed = WalkSpeed
			runBtn.Text = "Run"
		end
	end)

	-- BLOCK TOGGLE
	blockBtn.MouseButton1Click:Connect(function()
		blocking = not blocking

		if blocking then
			running = false
			hum.WalkSpeed = 0

			walkTrack:Stop()
			runTrack:Stop()

			blockTrack:Play()

			task.delay(0.9, function()
				if blocking then
					blockTrack:AdjustSpeed(0) -- freeze at 0.9
				end
			end)

			blockBtn.Text = "Unblock"
		else
			blockTrack:Stop()
			hum.WalkSpeed = WalkSpeed
			blockBtn.Text = "Block"
		end
	end)
end

-- INIT
if player.Character then
	setupChar(player.Character)
end
player.CharacterAdded:Connect(setupChar)
