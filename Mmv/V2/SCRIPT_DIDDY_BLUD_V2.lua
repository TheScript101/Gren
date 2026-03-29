--// SERVICES
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

--// PLAYER
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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

--// GUI
local gui = Instance.new("ScreenGui", playerGui)
gui.Name = "MMVGui"
gui.ResetOnSpawn = false

--// TOGGLE BUTTON
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,40,0,100)
toggleBtn.Position = UDim2.new(0,0,0.4,0)
toggleBtn.Text = "MMV"
toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn)

--// MAIN FRAME
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,240,0,300)
frame.Position = UDim2.new(0,50,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Parent = gui
Instance.new("UICorner", frame)

--// TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "mmv script"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

--// LAYOUT
local layout = Instance.new("UIListLayout", frame)
layout.Padding = UDim.new(0,6)

--// STATE
local selectedMurder = player.Name
local selectedSheriff = player.Name
local selectedMap = "Random"

local murderEnabled = false
local sheriffEnabled = false
local mapEnabled = false

--// FUNCTION TO SEND ALL
local function executeCommands()
	if murderEnabled then
		SendChatMessage("/murderer " .. selectedMurder)
		task.wait(0.8)
	end

	if sheriffEnabled then
		SendChatMessage("/sheriff " .. selectedSheriff)
		task.wait(0.8)
	end

	if mapEnabled then
		local maps = {
			"hotel","milbase","beachresort","yacht","farmhouse",
			"mineshaft","vampirescastle","workshop",
			"trainstation","icecastle","christmasinitaly"
		}

		local chosen = selectedMap == "Random" and maps[math.random(1,#maps)] or selectedMap
		SendChatMessage("/map " .. chosen)
	end
end

--// CREATE SECTION
local function createSection(name, isMap)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1,0,0,40)
	section.BackgroundTransparency = 1
	section.Parent = frame

	local secLayout = Instance.new("UIListLayout", section)
	secLayout.Padding = UDim.new(0,3)

	-- top bar
	local top = Instance.new("Frame")
	top.Size = UDim2.new(1,0,0,30)
	top.BackgroundColor3 = Color3.fromRGB(35,35,35)
	top.Parent = section
	Instance.new("UICorner", top)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = top

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0.4,0,1,0)
	toggle.Position = UDim2.new(0.6,0,0,0)
	toggle.Text = "OFF"
	toggle.BackgroundColor3 = Color3.fromRGB(50,50,50)
	toggle.TextColor3 = Color3.new(1,1,1)
	toggle.Parent = top
	Instance.new("UICorner", toggle)

	local enabled = false

	toggle.MouseButton1Click:Connect(function()
		enabled = not enabled
		toggle.Text = enabled and "ON" or "OFF"

		if name == "Pick Murder" then murderEnabled = enabled end
		if name == "Pick Sheriff" then sheriffEnabled = enabled end
		if name == "Pick Map" then mapEnabled = enabled end

		executeCommands()
	end)

	-- dropdown button
	local dropBtn = Instance.new("TextButton")
	dropBtn.Size = UDim2.new(1,0,0,25)
	dropBtn.Text = "Select"
	dropBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
	dropBtn.TextColor3 = Color3.new(1,1,1)
	dropBtn.Parent = section
	Instance.new("UICorner", dropBtn)

	local dropFrame = Instance.new("Frame")
	dropFrame.Size = UDim2.new(1,0,0,0)
	dropFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
	dropFrame.ClipsDescendants = true
	dropFrame.Parent = section
	Instance.new("UICorner", dropFrame)

	local list = Instance.new("UIListLayout", dropFrame)

	local open = false

	local function addOption(text)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,0,0,25)
		btn.Text = text
		btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
		btn.TextColor3 = Color3.new(1,1,1)
		btn.Parent = dropFrame

		btn.MouseButton1Click:Connect(function()
			dropBtn.Text = text

			if name == "Pick Murder" then
				selectedMurder = (text == "Me") and player.Name or text
			elseif name == "Pick Sheriff" then
				selectedSheriff = (text == "Me") and player.Name or text
			elseif name == "Pick Map" then
				selectedMap = text
			end
		end)
	end

	-- AUTO REFRESH PLAYERS
	local function refreshPlayers()
		for _,v in pairs(dropFrame:GetChildren()) do
			if v:IsA("TextButton") then v:Destroy() end
		end

		if isMap then
			addOption("Random")
			local maps = {
				"hotel","milbase","beachresort","yacht","farmhouse",
				"mineshaft","vampirescastle","workshop",
				"trainstation","icecastle","christmasinitaly"
			}
			for _,m in pairs(maps) do addOption(m) end
		else
			addOption("Me")
			for _,plr in pairs(Players:GetPlayers()) do
				addOption(plr.Name)
			end
		end
	end

	refreshPlayers()
	Players.PlayerAdded:Connect(refreshPlayers)
	Players.PlayerRemoving:Connect(refreshPlayers)

	dropBtn.MouseButton1Click:Connect(function()
		open = not open
		dropFrame.Size = open and UDim2.new(1,0,0,#dropFrame:GetChildren()*25) or UDim2.new(1,0,0,0)
	end)
end

--// CREATE SECTIONS
createSection("Pick Murder", false)
createSection("Pick Sheriff", false)
createSection("Pick Map", true)

--// TOGGLE GUI
toggleBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
end)
