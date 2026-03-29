--// SERVICES
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")

--// PLAYER
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// MAPS
local MAPS = {
	"hotel",
	"milbase",
	"beachresort",
	"yacht",
	"farmhouse",
	"mineshaft",
	"vampirescastle",
	"workshop",
	"trainstation",
	"icecastle",
	"christmasinitaly",
}

--// CHAT FUNCTION
local function SendChatMessage(message)
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		local channels = TextChatService:WaitForChild("TextChannels")
		local textChannel = channels:WaitForChild("RBXGeneral")
		textChannel:SendAsync(message)
	else
		game:GetService("ReplicatedStorage")
			:WaitForChild("DefaultChatSystemChatEvents")
			:WaitForChild("SayMessageRequest")
			:FireServer(message, "All")
	end
end

--// CLEANUP OLD GUI
local old = playerGui:FindFirstChild("MMVGui")
if old then
	old:Destroy()
end

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MMVGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

--// SIDE TOGGLE BUTTON
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "SideToggle"
toggleBtn.Size = UDim2.new(0, 42, 0, 92)
toggleBtn.Position = UDim2.new(0, 8, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Text = "MMV"
toggleBtn.AutoButtonColor = true
toggleBtn.Parent = gui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 10)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Thickness = 1
toggleStroke.Color = Color3.fromRGB(65, 65, 75)
toggleStroke.Transparency = 0.25
toggleStroke.Parent = toggleBtn

--// MAIN WINDOW
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 280, 0, 330)
frame.Position = UDim2.new(0, 58, 0.28, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 1
frameStroke.Color = Color3.fromRGB(70, 70, 82)
frameStroke.Transparency = 0.2
frameStroke.Parent = frame

--// HEADER (DRAG AREA)
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
header.BorderSizePixel = 0
header.Parent = frame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

local headerMask = Instance.new("Frame")
headerMask.Size = UDim2.new(1, 0, 0, 14)
headerMask.Position = UDim2.new(0, 0, 1, -14)
headerMask.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
headerMask.BorderSizePixel = 0
headerMask.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "mmv script"
title.TextColor3 = Color3.fromRGB(245, 245, 245)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 22)
closeBtn.Position = UDim2.new(1, -36, 0, 7)
closeBtn.BackgroundColor3 = Color3.fromRGB(44, 44, 52)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Text = "–"
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = closeBtn

--// CONTENT AREA
local content = Instance.new("ScrollingFrame")
content.Name = "Content"
content.Size = UDim2.new(1, -14, 1, -46)
content.Position = UDim2.new(0, 7, 0, 40)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 135)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.Parent = frame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = content

--// DRAGGING
local dragging = false
local dragInput
local dragStart
local startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

header.InputBegan:Connect(function(input)
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

header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updateDrag(input)
	end
end)

--// SIDEBAR SHOW/HIDE
toggleBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

--// STATE
local selectedMurder = player.Name
local selectedSheriff = player.Name
local selectedMap = "Random"

--// HELPERS
local function makeCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function makeStroke(parent, transparency)
	local s = Instance.new("UIStroke")
	s.Thickness = 1
	s.Color = Color3.fromRGB(85, 85, 98)
	s.Transparency = transparency or 0.35
	s.Parent = parent
	return s
end

local function sortPlayers(list)
	table.sort(list, function(a, b)
		return string.lower(a.Name) < string.lower(b.Name)
	end)
end

local function sendSelected(kind)
	if kind == "Pick Murder" then
		SendChatMessage("/murderer " .. selectedMurder)
	elseif kind == "Pick Sheriff" then
		SendChatMessage("/sheriff " .. selectedSheriff)
	elseif kind == "Pick Map" then
		local chosen = selectedMap
		if chosen == "Random" then
			chosen = MAPS[math.random(1, #MAPS)]
		end
		SendChatMessage("/map " .. chosen)
	end
end

--// CREATE SECTION
local function createSection(sectionName, isMap)
	local section = Instance.new("Frame")
	section.Name = sectionName:gsub("%s+", "")
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = Color3.fromRGB(24, 24, 29)
	section.BorderSizePixel = 0
	section.Parent = content
	makeCorner(section, 12)
	makeStroke(section, 0.4)

	local innerPadding = Instance.new("UIPadding")
	innerPadding.PaddingTop = UDim.new(0, 8)
	innerPadding.PaddingBottom = UDim.new(0, 8)
	innerPadding.PaddingLeft = UDim.new(0, 8)
	innerPadding.PaddingRight = UDim.new(0, 8)
	innerPadding.Parent = section

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = section

	local topRow = Instance.new("Frame")
	topRow.Size = UDim2.new(1, 0, 0, 30)
	topRow.BackgroundTransparency = 1
	topRow.Parent = section

	local topLayout = Instance.new("UIListLayout")
	topLayout.FillDirection = Enum.FillDirection.Horizontal
	topLayout.SortOrder = Enum.SortOrder.LayoutOrder
	topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	topLayout.Padding = UDim.new(0, 6)
	topLayout.Parent = topRow

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -80, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = sectionName
	label.TextColor3 = Color3.fromRGB(245, 245, 245)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = topRow

	local setBtn = Instance.new("TextButton")
	setBtn.Size = UDim2.new(0, 70, 0, 28)
	setBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 82)
	setBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	setBtn.Font = Enum.Font.GothamBold
	setBtn.TextSize = 13
	setBtn.Text = "SET"
	setBtn.Parent = topRow
	makeCorner(setBtn, 8)

	local selectBtn = Instance.new("TextButton")
	selectBtn.Size = UDim2.new(1, 0, 0, 28)
	selectBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 41)
	selectBtn.TextColor3 = Color3.fromRGB(235, 235, 235)
	selectBtn.Font = Enum.Font.Gotham
	selectBtn.TextSize = 13
	selectBtn.Text = "Select"
	selectBtn.Parent = section
	makeCorner(selectBtn, 8)
	makeStroke(selectBtn, 0.55)

	local dropdown = Instance.new("Frame")
	dropdown.Size = UDim2.new(1, 0, 0, 0)
	dropdown.BackgroundTransparency = 1
	dropdown.BorderSizePixel = 0
	dropdown.Visible = false
	dropdown.ClipsDescendants = true
	dropdown.Parent = section

	local dropLayout = Instance.new("UIListLayout")
	dropLayout.Padding = UDim.new(0, 4)
	dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
	dropLayout.Parent = dropdown

	local dropPadding = Instance.new("UIPadding")
	dropPadding.PaddingTop = UDim.new(0, 2)
	dropPadding.Parent = dropdown

	local open = false
	local items = {}

	local function clearOptions()
		for _, child in ipairs(items) do
			if child and child.Parent then
				child:Destroy()
			end
		end
		table.clear(items)
	end

	local function addOption(text)
		local option = Instance.new("TextButton")
		option.Size = UDim2.new(1, 0, 0, 24)
		option.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		option.TextColor3 = Color3.fromRGB(255, 255, 255)
		option.Font = Enum.Font.Gotham
		option.TextSize = 13
		option.Text = text
		option.Parent = dropdown
		makeCorner(option, 7)

		local optStroke = Instance.new("UIStroke")
		optStroke.Thickness = 1
		optStroke.Color = Color3.fromRGB(90, 90, 102)
		optStroke.Transparency = 0.55
		optStroke.Parent = option

		table.insert(items, option)

		option.MouseButton1Click:Connect(function()
			selectBtn.Text = text
			if sectionName == "Pick Murder" then
				selectedMurder = (text == "Me") and player.Name or text
			elseif sectionName == "Pick Sheriff" then
				selectedSheriff = (text == "Me") and player.Name or text
			elseif sectionName == "Pick Map" then
				selectedMap = text
			end
		end)
	end

	local function refreshDropdown()
		clearOptions()

		if isMap then
			addOption("Random")
			for _, mapName in ipairs(MAPS) do
				addOption(mapName)
			end
		else
			addOption("Me")
			local list = Players:GetPlayers()
			sortPlayers(list)
			for _, plr in ipairs(list) do
				addOption(plr.Name)
			end

			if sectionName == "Pick Murder" and selectedMurder ~= player.Name then
				local stillThere = false
				for _, plr in ipairs(list) do
					if plr.Name == selectedMurder then
						stillThere = true
						break
					end
				end
				if not stillThere then
					selectedMurder = player.Name
					if selectBtn.Text ~= "Me" then
						selectBtn.Text = "Me"
					end
				end
			end

			if sectionName == "Pick Sheriff" and selectedSheriff ~= player.Name then
				local stillThere = false
				for _, plr in ipairs(list) do
					if plr.Name == selectedSheriff then
						stillThere = true
						break
					end
				end
				if not stillThere then
					selectedSheriff = player.Name
					if selectBtn.Text ~= "Me" then
						selectBtn.Text = "Me"
					end
				end
			end
		end

		local optionCount = #items
		dropdown.Size = open and UDim2.new(1, 0, 0, optionCount * 28 + math.max(0, optionCount - 1) * 4 + 2) or UDim2.new(1, 0, 0, 0)
		dropdown.Visible = open
	end

	selectBtn.MouseButton1Click:Connect(function()
		open = not open
		refreshDropdown()
	end)

	setBtn.MouseButton1Click:Connect(function()
		sendSelected(sectionName)
	end)

	refreshDropdown()

	if not isMap then
		Players.PlayerAdded:Connect(function()
			refreshDropdown()
		end)
		Players.PlayerRemoving:Connect(function()
			refreshDropdown()
		end)
	end

	return {
		Refresh = refreshDropdown,
		SetText = function(text)
			selectBtn.Text = text
		end,
	}
end

--// SECTIONS
local murderSection = createSection("Pick Murder", false)
local sheriffSection = createSection("Pick Sheriff", false)
local mapSection = createSection("Pick Map", true)

-- keep layout fresh when content changes
task.spawn(function()
	while gui.Parent do
		task.wait(0.15)
		content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 6)
	end
end)
