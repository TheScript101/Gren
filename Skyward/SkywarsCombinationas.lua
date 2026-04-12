local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "1_GUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = guiParent

local shadow = Instance.new("Frame")
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.new(0.5, 6, 0.5, 8)
shadow.Size = UDim2.new(0, 380, 0, 230)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.4
shadow.Parent = gui
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 22)

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0, 380, 0, 230)
frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 22)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(80, 80, 90)
stroke.Transparency = 0.25
stroke.Parent = frame

local gradient = Instance.new("UIGradient")
gradient.Rotation = 90
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 38)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 22))
}
gradient.Parent = frame

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 16, 0, 10)
title.Size = UDim2.new(1, -32, 0, 52)
title.Font = Enum.Font.GothamBold
title.Text = "Load Autoclicker?"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Parent = frame

local line1 = Instance.new("TextLabel")
line1.BackgroundTransparency = 1
line1.Position = UDim2.new(0, 10, 0, 0)
line1.Size = UDim2.new(1, -20, 0, 18)
line1.Font = Enum.Font.Gotham
line1.Text = "---------------------------------------------------------"
line1.TextColor3 = Color3.fromRGB(120, 120, 130)
line1.TextSize = 14
line1.Parent = frame

local line2 = Instance.new("TextLabel")
line2.BackgroundTransparency = 1
line2.Position = UDim2.new(0, 10, 0, 48)
line2.Size = UDim2.new(1, -20, 0, 18)
line2.Font = Enum.Font.Gotham
line2.Text = "---------------------------------------------------------"
line2.TextColor3 = Color3.fromRGB(120, 120, 130)
line2.TextSize = 14
line2.Parent = frame

local info = Instance.new("TextLabel")
info.BackgroundTransparency = 1
info.Position = UDim2.new(0, 18, 0, 78)
info.Size = UDim2.new(1, -36, 0, 28)
info.Font = Enum.Font.Gotham
info.Text = "Pick a option."
info.TextColor3 = Color3.fromRGB(205, 205, 215)
info.TextSize = 15
info.Parent = frame

local function makeButton(text, pos, accent)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 160, 0, 50)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
	btn.Text = text
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 18
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.AutoButtonColor = false
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)

	local btnStroke = Instance.new("UIStroke")
	btnStroke.Thickness = 1
	btnStroke.Color = Color3.fromRGB(85, 85, 95)
	btnStroke.Transparency = 0.25
	btnStroke.Parent = btn

	local bar = Instance.new("Frame")
	bar.BackgroundColor3 = accent
	bar.BorderSizePixel = 0
	bar.Position = UDim2.new(0, 0, 1, -4)
	bar.Size = UDim2.new(1, 0, 0, 4)
	bar.Parent = btn
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 14)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(42, 42, 50)}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(32, 32, 38)}):Play()
	end)

	return btn
end

local yes = makeButton("Yes", UDim2.new(0, 20, 0, 132), Color3.fromRGB(70, 170, 90))
local no = makeButton("No", UDim2.new(1, -180, 0, 132), Color3.fromRGB(170, 70, 70))

do
	local dragging = false
	local dragStart
	local startPos

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
			if dragging then
				local delta = input.Position - dragStart
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				shadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + 6, startPos.Y.Scale, startPos.Y.Offset + delta.Y + 8)
			end
		end
	end)
end

yes.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Skyward/Autoclicker.lua"))()
	wait(0.1)
	gui:Destroy()
	wait(1)
end)

no.MouseButton1Click:Connect(function()
	gui:Destroy()
	wait(1)
end)

------------------------ Gui 2 ------------------------------

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "2_GUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = guiParent

local shadow = Instance.new("Frame")
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.new(0.5, 6, 0.5, 8)
shadow.Size = UDim2.new(0, 380, 0, 230)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.4
shadow.Parent = gui
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 22)

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0, 380, 0, 230)
frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 22)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(80, 80, 90)
stroke.Transparency = 0.25
stroke.Parent = frame

local gradient = Instance.new("UIGradient")
gradient.Rotation = 90
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 38)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 22))
}
gradient.Parent = frame

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 16, 0, 10)
title.Size = UDim2.new(1, -32, 0, 52)
title.Font = Enum.Font.GothamBold
title.Text = "Load More Sensitivity?"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Parent = frame

local line1 = Instance.new("TextLabel")
line1.BackgroundTransparency = 1
line1.Position = UDim2.new(0, 10, 0, 0)
line1.Size = UDim2.new(1, -20, 0, 18)
line1.Font = Enum.Font.Gotham
line1.Text = "---------------------------------------------------------"
line1.TextColor3 = Color3.fromRGB(120, 120, 130)
line1.TextSize = 14
line1.Parent = frame

local line2 = Instance.new("TextLabel")
line2.BackgroundTransparency = 1
line2.Position = UDim2.new(0, 10, 0, 48)
line2.Size = UDim2.new(1, -20, 0, 18)
line2.Font = Enum.Font.Gotham
line2.Text = "---------------------------------------------------------"
line2.TextColor3 = Color3.fromRGB(120, 120, 130)
line2.TextSize = 14
line2.Parent = frame

local info = Instance.new("TextLabel")
info.BackgroundTransparency = 1
info.Position = UDim2.new(0, 18, 0, 78)
info.Size = UDim2.new(1, -36, 0, 28)
info.Font = Enum.Font.Gotham
info.Text = "Pick a option."
info.TextColor3 = Color3.fromRGB(205, 205, 215)
info.TextSize = 15
info.Parent = frame

local function makeButton(text, pos, accent)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 160, 0, 50)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
	btn.Text = text
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 18
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.AutoButtonColor = false
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)

	local btnStroke = Instance.new("UIStroke")
	btnStroke.Thickness = 1
	btnStroke.Color = Color3.fromRGB(85, 85, 95)
	btnStroke.Transparency = 0.25
	btnStroke.Parent = btn

	local bar = Instance.new("Frame")
	bar.BackgroundColor3 = accent
	bar.BorderSizePixel = 0
	bar.Position = UDim2.new(0, 0, 1, -4)
	bar.Size = UDim2.new(1, 0, 0, 4)
	bar.Parent = btn
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 14)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(42, 42, 50)}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(32, 32, 38)}):Play()
	end)

	return btn
end

local yes = makeButton("Yes", UDim2.new(0, 20, 0, 132), Color3.fromRGB(70, 170, 90))
local no = makeButton("No", UDim2.new(1, -180, 0, 132), Color3.fromRGB(170, 70, 70))

do
	local dragging = false
	local dragStart
	local startPos

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
			if dragging then
				local delta = input.Position - dragStart
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				shadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + 6, startPos.Y.Scale, startPos.Y.Offset + delta.Y + 8)
			end
		end
	end)
end

yes.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Skyward/Misc/%2BSensitivity.lua"))()
	wait(0.1)
	gui:Destroy()
	wait(1)
end)

no.MouseButton1Click:Connect(function()
	gui:Destroy()
	wait(1)
end)
