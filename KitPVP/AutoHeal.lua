local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = newChar:WaitForChild("Humanoid")
end)

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoAppleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 160, 0, 45)
toggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "Auto Apple: OFF"
toggleButton.Parent = screenGui

-- Corner rounding for a neat look
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = toggleButton

-- Subtle border stroke
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(60, 60, 60)
uiStroke.Thickness = 1.5
uiStroke.Parent = toggleButton

-- State variables
local isEnabled = false
local isDragging = false
local dragInput, mousePos, framePos

-- Draggable Logic
toggleButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = true
		mousePos = input.Position
		framePos = toggleButton.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				isDragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - mousePos
		toggleButton.Position = UDim2.new(
			framePos.X.Scale, 
			framePos.X.Offset + delta.X, 
			framePos.Y.Scale, 
			framePos.Y.Offset + delta.Y
		)
	end
end)

-- Toggle & Animation Logic
toggleButton.MouseButton1Click:Connect(function()
	isEnabled = not isEnabled
	
	if isEnabled then
		toggleButton.Text = "Auto Apple: ON"
		TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(46, 139, 87)}):Play()
		uiStroke.Color = Color3.fromRGB(60, 179, 113)
	else
		toggleButton.Text = "Auto Apple: OFF"
		TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
		uiStroke.Color = Color3.fromRGB(60, 60, 60)
	end
end)

-- Background Loop (Runs every 1 second when active)
task.spawn(function()
	while true do
		task.wait(0.5)
		if isEnabled and humanoid and humanoid.Health > 0 and humanoid.Health < 100 then
			local args = {
				[1] = "enchanted_golden_apple"
			}
			
			local success, err = pcall(function()
				ReplicatedStorage.EatItem:FireServer(unpack(args))
			end)
			
			if not success then
				warn("Failed to fire EatItem: " .. tostring(err))
			end
		end
	end
end)
