-- // SERVICES
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- // STATE
local toggles = {
	Axe = false,
	Heal = false,
	Speed = false,
	Shield = false,
	HighJump = false,
}

-- // GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ToolToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- MAIN FRAME (for layout)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 120)
mainFrame.Position = UDim2.new(0.7800000014, 0, 0.1100000016, 0)
mainFrame.BackgroundTransparency = 0.8
mainFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = mainFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(0, 0, 0)
	stroke.Thickness = 0.8
	stroke.Parent = mainFrame

-- GRID LAYOUT (🔥 THIS FIXES EVERYTHING)
local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.new(0, 50, 0, 50)
layout.CellPadding = UDim2.new(0, 8, 0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = mainFrame

-- // CREATE BUTTON FUNCTION
local function createToolButton(toolName, imageId)
	local btn = Instance.new("ImageButton")
	btn.Name = toolName
	btn.Parent = mainFrame

	btn.Size = UDim2.new(0, 20, 0, 20)
	btn.BackgroundColor3 = Color3.new(1, 1, 1)
	btn.BackgroundTransparency = 0.4
	btn.Image = "rbxassetid://" .. imageId
	btn.AutoButtonColor = false
	btn.Visible = false

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(0, 0, 0)
	stroke.Thickness = 1
	stroke.Parent = btn

	return btn
end

-- // CREATE BUTTONS (NO POSITIONS ANYMORE)
local healBtn   = createToolButton("Heal", "1843006229")
local speedBtn  = createToolButton("Speed", "1843072067")
local jumpBtn   = createToolButton("HighJump", "1843065736")
local shieldBtn = createToolButton("Shield", "1843056725")
local axeBtn    = createToolButton("Axe", "399887168")

-- // MAP
local buttons = {
	Heal = healBtn,
	Axe = axeBtn,
	HighJump = jumpBtn,
	Speed = speedBtn,
	Shield = shieldBtn,
}

-- // VISUAL UPDATE
local function updateButtonAppearance(tool)
	local btn = buttons[tool]
	if btn then
		btn.BackgroundColor3 = toggles[tool] and Color3.fromRGB(0, 255, 255)
			or Color3.fromRGB(255, 255, 255)
	end
end

-- // VISIBILITY (AUTO FILL FIX)
local function updateButtonVisibility(tool)
	local hasTool = player.Backpack:FindFirstChild(tool) or character:FindFirstChild(tool)
	local btn = buttons[tool]

	if btn then
		btn.Visible = hasTool and true or false
	end
end

-- // EQUIP
local function equipTool(tool)
	local found = player.Backpack:FindFirstChild(tool) or character:FindFirstChild(tool)
	if found then
		humanoid:EquipTool(found)
	end
end

-- // UNEQUIP
local function unequipTool()
	humanoid:UnequipTools()
end

-- // CLICK SYSTEM
for toolName, btn in pairs(buttons) do
	btn.MouseButton1Click:Connect(function()
		toggles[toolName] = not toggles[toolName]

		if toggles[toolName] then
			equipTool(toolName)
		else
			unequipTool()
		end

		updateButtonAppearance(toolName)
	end)
end

-- // TOOL TRACKING
local function monitor()
	local function updateAll()
		for name in pairs(buttons) do
			updateButtonVisibility(name)
		end
	end

	character.ChildAdded:Connect(function(child)
		if buttons[child.Name] then
			updateButtonVisibility(child.Name)
		end
	end)

	character.ChildRemoved:Connect(function(child)
		if buttons[child.Name] then
			updateButtonVisibility(child.Name)
		end
	end)

	player.Backpack.ChildAdded:Connect(updateAll)
	player.Backpack.ChildRemoved:Connect(updateAll)
end

-- // RESET SUPPORT
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")

	for tool in pairs(toggles) do
		toggles[tool] = false
		updateButtonAppearance(tool)
		updateButtonVisibility(tool)
	end

	monitor()
end)

-- // INIT
for tool in pairs(toggles) do
	updateButtonAppearance(tool)
	updateButtonVisibility(tool)
end

monitor()
