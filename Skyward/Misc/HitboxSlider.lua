-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- // SETTINGS
_G.Body = true
local hitboxSize = 8

-- // GUI
local gui = Instance.new("ScreenGui")
gui.Name = "HitboxSliderGui"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 170, 0, 55)
frame.Position = UDim2.new(0.5, -170, 0, -50)
frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(60,60,70)
stroke.Thickness = 1

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "Hitbox Size"
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

-- VALUE TEXT
local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(1,0,0,20)
valueLabel.Position = UDim2.new(0,0,0,15)
valueLabel.BackgroundTransparency = 1
valueLabel.Text = "Size: 10"
valueLabel.Font = Enum.Font.Gotham
valueLabel.TextSize = 11
valueLabel.TextColor3 = Color3.fromRGB(200,200,200)
valueLabel.Parent = frame

-- SLIDER BAR
local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(1,-20,0,8)
sliderBar.Position = UDim2.new(0,10,0,39)
sliderBar.BackgroundColor3 = Color3.fromRGB(50,50,60)
sliderBar.Parent = frame
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1,0)

-- FILL
local fill = Instance.new("Frame")
fill.Size = UDim2.new(0.5,0,1,0)
fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
fill.Parent = sliderBar
Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

-- KNOB
local knob = Instance.new("Frame")
knob.Size = UDim2.new(0,16,0,16)
knob.Position = UDim2.new(0.5,-8,0.5,-8)
knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
knob.Parent = sliderBar
Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

-- DRAG
local dragging = false

local function updateSlider(inputX)
	local rel = math.clamp((inputX - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
	
	fill.Size = UDim2.new(rel,0,1,0)
	knob.Position = UDim2.new(rel,-8,0.5,-8)

	hitboxSize = math.floor(1 + (19 * rel))
	valueLabel.Text = "Size: " .. hitboxSize
end

sliderBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		updateSlider(input.Position.X)
	end
end)

sliderBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateSlider(input.Position.X)
	end
end)

-- // APPLY HITBOX
RunService.RenderStepped:Connect(function()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			local char = plr.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					if _G.Body then
						hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
						hrp.Transparency = 0.8
						hrp.Color = Color3.fromRGB(0,50,150)
						hrp.CanCollide = false
					else
						hrp.Size = Vector3.new(2,2,1)
						hrp.Transparency = 1
					end
				end
			end
		end
	end
end)
