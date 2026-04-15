--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

----------------------------------------------------------------------
-- [[ SCRIPT 1: ADVANCED MOVEMENT (NO SHIFT LOCK GUI) ]]
----------------------------------------------------------------------
task.spawn(function()

	local function initializeTilt(character)
		local camera = workspace.CurrentCamera
		local humanoid = character:WaitForChild("Humanoid")
		local rootPart = character:WaitForChild("HumanoidRootPart")

		-- 🔥 ONLY R6
		if humanoid.RigType ~= Enum.HumanoidRigType.R6 then
			return
		end

		local attachment = Instance.new("Attachment")
		attachment.Name = "RotationAttachment"
		attachment.Parent = rootPart

		local align = Instance.new("AlignOrientation")
		align.Name = "RotationWeld"
		align.Mode = Enum.OrientationAlignmentMode.OneAttachment
		align.Attachment0 = attachment
		align.MaxTorque = math.huge
		align.Responsiveness = 55
		align.Parent = rootPart

		humanoid.AutoRotate = false

		local maxTilt = 35
		local fadeSpeed = 10
		local tiltMultiplier = 1.1

		local currentTiltX = 0
		local currentTiltZ = 0

RunService.RenderStepped:Connect(function(dt)
	if not character.Parent or humanoid.Health <= 0 then return end

	local moveDir = humanoid.MoveDirection
	local velocity = rootPart.AssemblyLinearVelocity.Magnitude

	-- face movement direction (or keep current if idle)
	local lookTarget = rootPart.CFrame
	if moveDir.Magnitude > 0.05 then
		lookTarget = CFrame.lookAt(rootPart.Position, rootPart.Position + moveDir)
	end

	-- DEFAULT = no tilt
	local targetTiltX = 0
	local targetTiltZ = 0

	-- ONLY APPLY WHEN MOVING
	if moveDir.Magnitude > 0.05 and velocity > 0.1 then
		targetTiltX = math.clamp(
			-moveDir:Dot(rootPart.CFrame.LookVector) * tiltMultiplier * velocity,
			-maxTilt,
			maxTilt
		)

		targetTiltZ = math.clamp(
			-moveDir:Dot(rootPart.CFrame.RightVector) * tiltMultiplier * velocity,
			-maxTilt,
			maxTilt
		)
	end

	-- 🔥 IMPORTANT: force smooth return to 0 when idle
	if moveDir.Magnitude <= 0.05 then
		targetTiltX = 0
		targetTiltZ = 0
	end

	-- smooth interpolation back to neutral
	currentTiltX += (targetTiltX - currentTiltX) * dt * fadeSpeed
	currentTiltZ += (targetTiltZ - currentTiltZ) * dt * fadeSpeed

	align.CFrame =
		CFrame.new(rootPart.Position)
		* (lookTarget - lookTarget.Position)
		* CFrame.Angles(math.rad(currentTiltX), 0, math.rad(currentTiltZ))
end)

	player.CharacterAdded:Connect(initializeTilt)
	if player.Character then initializeTilt(player.Character) end
end

----------------------------------------------------------------------
-- [[ SCRIPT 2: R6 ANIMATIONS ONLY ]]
----------------------------------------------------------------------
task.spawn(function()

	local function setupCharacter(char)
		local humanoid = char:WaitForChild("Humanoid")

		-- 🔥 ONLY R6
		if humanoid.RigType ~= Enum.HumanoidRigType.R6 then
			return
		end

		-- load your R6 anim script
		loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Skyward/Gui/Misc/R6CustomAnim.lua"))()
	end

	player.CharacterAdded:Connect(setupCharacter)
	if player.Character then setupCharacter(player.Character) end
end)
