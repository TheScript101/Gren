-- // SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

wait(0.5)
game:GetService("StarterGui"):SetCore("SendNotification", {
	Title = "Loaded",
	Text = "Choose Your Options",
	Duration = 2.5
})

-- // FUNCTION
local function createPrompt(guiName, promptTitle, promptInfo, yesText, noText, yesCallback, noCallback, nextStep)
	local old = guiParent:FindFirstChild(guiName)
	if old then
		old:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = guiName
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
	title.Text = promptTitle
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 20
	title.Parent = frame

	local info = Instance.new("TextLabel")
	info.BackgroundTransparency = 1
	info.Position = UDim2.new(0, 18, 0, 78)
	info.Size = UDim2.new(1, -36, 0, 28)
	info.Font = Enum.Font.Gotham
	info.Text = promptInfo
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
		btn.Parent = frame
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)

		local bar = Instance.new("Frame")
		bar.BackgroundColor3 = accent
		bar.Position = UDim2.new(0, 0, 1, -4)
		bar.Size = UDim2.new(1, 0, 0, 4)
		bar.Parent = btn
		Instance.new("UICorner", bar)

		return btn
	end

	local yes = makeButton(yesText, UDim2.new(0, 20, 0, 132), Color3.fromRGB(70,170,90))
	local no = makeButton(noText, UDim2.new(1, -180, 0, 132), Color3.fromRGB(170,70,70))

	yes.MouseButton1Click:Connect(function()
		if yesCallback then yesCallback() end
		gui:Destroy()
	end)

	no.MouseButton1Click:Connect(function()
		if noCallback then noCallback() end
		gui:Destroy()
	end)
end

-- // PROMPT
createPrompt(
	"TypeSelectorGui",
	"Which Type?",
	"Choose how you want to run the script.",
	"GUI",
	"Combination",

	-- GUI OPTION
	function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Skyward/Gui/Main/GUI.lua"))()
	end,

	-- COMBINATION OPTION
	function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Skyward/Main/Script_Combination.lua"))()
	end
)
