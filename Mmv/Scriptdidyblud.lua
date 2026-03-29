--[[
	made by thescripy101
]]

--// SERVICES
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// PLAYER
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// CREATE GUI
local screenGui = playerGui:FindFirstChild("AutoRoundGui") or Instance.new("ScreenGui")
screenGui.Name = "AutoRoundGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

--// FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 70)
frame.Position = UDim2.new(0.5, -80, 0.5, -35)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

--// TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundTransparency = 1
title.Text = "Round Picker"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

--// BUTTON
local button = Instance.new("TextButton")
button.Size = UDim2.new(0.9, 0, 0, 30)
button.Position = UDim2.new(0.05, 0, 0.5, -10)
button.Text = "Start"
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.Parent = frame

Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

--// DRAG SYSTEM
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

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
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

--// CHAT FUNCTION
local function SendChatMessage(message)
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		local textChannel = TextChatService.TextChannels:WaitForChild("RBXGeneral")
		textChannel:SendAsync(message)
	else
		game:GetService("ReplicatedStorage")
			:WaitForChild("DefaultChatSystemChatEvents")
			:WaitForChild("SayMessageRequest")
			:FireServer(message, "All")
	end
end

--// MAPS
local maps = {
	"hotel","milbase","beachresort","yacht","farmhouse",
	"mineshaft","vampirecastle","workshop",
	"station","icecastle","christmasitaly"
}

--// COOLDOWN SYSTEM
local cooldown = false
local cooldownTime = 5 -- seconds

local function startCooldown()
	cooldown = true
	button.AutoButtonColor = false
	button.BackgroundColor3 = Color3.fromRGB(30,30,30)

	local startTime = tick()

	local connection
	connection = RunService.RenderStepped:Connect(function()
		local elapsed = tick() - startTime
		local remaining = math.max(0, cooldownTime - elapsed)

		button.Text = string.format("%.2f", remaining)

		if remaining <= 0 then
			connection:Disconnect()
			button.Text = "Start"
			button.BackgroundColor3 = Color3.fromRGB(40,40,40)
			button.AutoButtonColor = true
			cooldown = false
		end
	end)
end

--// BUTTON CLICK
button.MouseButton1Click:Connect(function()
	if cooldown then return end

	local chosenMap = maps[math.random(1, #maps)]

	SendChatMessage("/murderer 360iytt")
	task.wait(0.25)

	SendChatMessage("/sheriff wrinkledcomp0sure")
	task.wait(0.25)

	SendChatMessage("/map " .. chosenMap)

	startCooldown()
end)
