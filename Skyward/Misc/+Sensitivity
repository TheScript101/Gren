local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--// SENSITIVITY
local sensitivity = 0.7

--// TRACK ONE FINGER ONLY
local cameraTouch = nil
local lastPos = nil

UserInputService.TouchStarted:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- only assign if no camera finger yet
	if not cameraTouch then
		cameraTouch = input
		lastPos = input.Position
	end
end)

UserInputService.TouchEnded:Connect(function(input)
	if input == cameraTouch then
		cameraTouch = nil
		lastPos = nil
	end
end)

UserInputService.TouchMoved:Connect(function(input, gameProcessed)
	if input ~= cameraTouch then return end
	if gameProcessed then return end
	
	if lastPos then
		local delta = (input.Position - lastPos) * sensitivity
		
		camera.CFrame = camera.CFrame
			* CFrame.Angles(0, -math.rad(delta.X * 0.2), 0)
			* CFrame.Angles(-math.rad(delta.Y * 0.2), 0, 0)
		
		lastPos = input.Position
	end
end)
