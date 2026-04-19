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
local idleTrack, walkTrack, runTrack, blockTrack

local function setupChar(char)
	local hum = char:WaitForChild("Humanoid")
	local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)

	hum.WalkSpeed = WalkSpeed

	-- disable default animate script
	local animate = char:FindFirstChild("Animate")
	if animate then animate.Disabled = true end

	--// REMOVE SPECIFIC ANIMATIONS
local bannedAnims = {
	["rbxassetid://913376220"] = true,
	["rbxassetid://913402848"] = true,
	["rbxassetid://14366558676"] = true
}

-- stop + delete if detected
local function purgeAnimations(humanoid)
	-- stop already playing
	for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
		local id = track.Animation and track.Animation.AnimationId
		if id and bannedAnims[id] then
			track:Stop()
			track:Destroy()
		end
	end

	-- detect future ones
	humanoid.AnimationPlayed:Connect(function(track)
		local id = track.Animation and track.Animation.AnimationId
		if id and bannedAnims[id] then
			track:Stop()
			track:Destroy()
		end
	end)
end

purgeAnimations(hum)

--// DISABLE JUMP COMPLETELY
hum.JumpPower = 0
hum.UseJumpPower = true
hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)

-- prevent jump input
hum:GetPropertyChangedSignal("Jump"):Connect(function()
	hum.Jump = false
end)

--// REMOVE MOBILE JUMP BUTTON
task.spawn(function()
	local playerGui = player:WaitForChild("PlayerGui")

	local function removeJump()
		local touchGui = playerGui:FindFirstChild("TouchGui")
		if touchGui then
			local frame = touchGui:FindFirstChild("TouchControlFrame")
			if frame then
				local jump = frame:FindFirstChild("JumpButton")
				if jump then
					jump:Destroy()
				end
			end
		end
	end

	-- run multiple times to make sure it's gone
	for i = 1,5 do
		removeJump()
		task.wait(0.5)
	end
end)

	-- load anims
	local function load(id)
		local anim = Instance.new("Animation")
		anim.AnimationId = id
		return animator:LoadAnimation(anim)
	end

	idleTrack = load(IdleAnim)
	walkTrack = load(WalkAnim)
	runTrack = load(RunAnim)
	blockTrack = load(BlockAnim)

	idleTrack.Looped = true
	walkTrack.Looped = true
	runTrack.Looped = true

	-- MOVEMENT HANDLER
	hum.Running:Connect(function(speed)
		if blocking then return end

		if speed > 0 then
			idleTrack:Stop()

			if running then
				if not runTrack.IsPlaying then
					walkTrack:Stop()
					runTrack:Play()
					runTrack:AdjustSpeed(3)
				end
			else
				if not walkTrack.IsPlaying then
					runTrack:Stop()
					walkTrack:Play()
					walkTrack:AdjustSpeed(3)
				end
			end
		else
			walkTrack:Stop()
			runTrack:Stop()

			if not idleTrack.IsPlaying then
				idleTrack:Play()
			end
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

			idleTrack:Stop()
			walkTrack:Stop()
			runTrack:Stop()

			blockTrack:Play()

			task.delay(0.9, function()
				if blocking then
					blockTrack:AdjustSpeed(0)
				end
			end)

			blockBtn.Text = "Unblock"
		else
			blockTrack:Stop()
			hum.WalkSpeed = WalkSpeed
			blockBtn.Text = "Block"
		end
	end)

	-- START WITH IDLE
	idleTrack:Play()
end

-- INIT
if player.Character then
	setupChar(player.Character)
end
player.CharacterAdded:Connect(setupChar)
