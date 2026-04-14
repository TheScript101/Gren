local WMacLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Wicikk/WMacLib/main/WMacLib.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = WMacLib:Window({
	Title = "Skywars",
	Subtitle = "MacLib Edition",
	Size = UDim2.fromOffset(520, 320),
	DragStyle = 1,
	Keybind = Enum.KeyCode.RightControl,
	AcrylicBlur = true,
})

--// TABS
local Tabs = Window:TabGroup()
local CombatTab = Tabs:Tab({ Name = "Combat", Image = "lucide/sword" })
local PlayerTab = Tabs:Tab({ Name = "Player", Image = "lucide/user" })
local MiscTab = Tabs:Tab({ Name = "Misc", Image = "lucide/settings" })
local VisualTab = Tabs:Tab({ Name = "Visual", Image = "lucide/eye" })
local FunTab = Tabs:Tab({ Name = "Fun", Image = "lucide/sparkles" })

--// SECTION
local CombatSection = CombatTab:Section({})
local CombatSection2 = CombatTab:Section({})
local CombatSection3 = CombatTab:Section({})
local PlayerSection = PlayerTab:Section({})
local MiscSection = MiscTab:Section({})
local VisualSection = VisualTab:Section({})
local FunSection = FunTab:Section({})

-- // SOME AUTOCLICKER YES
local CoreGui = game:GetService("CoreGui")

local autoclickerLoaded = false

CombatSection:Toggle({
	Name = "Auto Clicker",
	Default = false,
	Callback = function(v)
		if v then
			-- prevent double loading
			if not autoclickerLoaded then
				autoclickerLoaded = true
				
				loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Skyward/Misc/Autoclicker.lua"))()
			end
		else
			-- reset flag
			autoclickerLoaded = false
			
			-- remove the GUI
			local gui = CoreGui:FindFirstChild("Autoclicker")
			if gui then
				gui:Destroy()
			end
		end
	end
})

-- // AUTO CLICKER WITH OUT THE GUI I
-- state
local autoClickEnabled = false
local cps = 50
local autoClickSpeed = 1 / cps

local lockMode = "Toggle" -- default
local Locking = false
local LockedTarget = nil
local camLockEnabled = false
local HighlightHandle = nil

local VirtualInputManager = game:GetService("VirtualInputManager")

-- SHIFT PRESS (runs once on execute)
task.spawn(function()
	task.wait(0.5)
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, nil)
	task.wait(0.1)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, nil)
end)

-- autoclick loop
task.spawn(function()
	while true do
		if autoClickEnabled then
			local character = player.Character
			if character then
				local tool = character:FindFirstChildOfClass("Tool")
				if tool and tool:FindFirstChild("Handle") then
					tool:Activate()
				end
			end
		end

		task.wait(autoClickSpeed)
	end
end)

-- toggle
CombatSection:Toggle({
	Name = "Auto Click (No GUI)",
	Default = false,
	Callback = function(v)
		autoClickEnabled = v
	end
})

-- CPS SLIDER (NEW)
CombatSection:Slider({
	Name = "Auto Click CPS (No GUI)",
	Default = 50,
	Minimum = 1,
	Maximum = 100,
	DisplayMethod = "Value",
	Precision = 0,
	Callback = function(value)
		cps = value
		autoClickSpeed = 1 / cps
	end
})

CombatSection2:Toggle({
	Name = "Hitbox GUI",
	Default = false,
	Callback = function(v)
		if v then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Skyward/Misc/HitboxSlider.lua"))()
		else
			local gui = game:GetService("CoreGui"):FindFirstChild("HitboxSliderGui")
			if gui then
				gui:Destroy()
			end
		end
	end
})

-- // SETTINGS
local hitboxEnabled = false
local hitboxSize = 7

RunService.RenderStepped:Connect(function()
	if not hitboxEnabled then return end

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			local char = plr.Character
			if char then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
					hrp.Transparency = 0.8
					hrp.Color = Color3.fromRGB(0, 50, 150)
					hrp.CanCollide = false
				end
			end
		end
	end
end)

CombatSection2:Toggle({
	Name = "Hitbox Expander (No Gui)",
	Default = false,
	Callback = function(v)
		hitboxEnabled = v

		-- reset when OFF
		if not v then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player then
					local char = plr.Character
					if char then
						local hrp = char:FindFirstChild("HumanoidRootPart")
						if hrp then
							hrp.Size = Vector3.new(2,2,1)
							hrp.Transparency = 1
						end
					end
				end
			end
		end
	end
})

CombatSection2:Slider({
	Name = "Hitbox Size (No Gui)",
	Default = 7,
	Minimum = 1,
	Maximum = 20,
	Precision = 0,
	DisplayMethod = "Number",
	Callback = function(v)
		hitboxSize = v
	end
})

-- // LOCK ON
CombatSection3:Toggle({
	Name = "Lock On GUI",
	Default = false,
	Callback = function(v)
		if v then
			loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Skyward/Misc/Lock.lua"))()
		else
			local gui = game:GetService("CoreGui"):FindFirstChild("LockModeSelectorGui")
			if gui then
				gui:Destroy()
			end
		end
	end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function getNearestPlayer()
	local closest, dist = nil, math.huge
	local myChar = LocalPlayer.Character
	if not myChar then return nil end

	local myHRP = myChar:FindFirstChild("HumanoidRootPart")
	if not myHRP then return nil end

	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= LocalPlayer and pl.Character then
			local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
			local hum = pl.Character:FindFirstChild("Humanoid")
			if hrp and hum and hum.Health > 0 then
				local mag = (myHRP.Position - hrp.Position).Magnitude
				if mag < dist then
					dist = mag
					closest = pl
				end
			end
		end
	end

	return closest
end

local function clearHighlight()
	if HighlightHandle then
		HighlightHandle:Destroy()
		HighlightHandle = nil
	end
end

local function applyHighlight(char)
	clearHighlight()
	if not char then return end

	local HL = Instance.new("Highlight")
	HL.Adornee = char
	HL.FillColor = Color3.fromRGB(255, 40, 40)
	HL.OutlineColor = Color3.fromRGB(255, 255, 255)
	HL.FillTransparency = 0.87
	HL.OutlineTransparency = 0.5
	HL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	HL.Parent = game:GetService("CoreGui")

	HighlightHandle = HL
end

local function rotateTowards(pos)
	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local dir = (Vector3.new(pos.X, hrp.Position.Y, pos.Z) - hrp.Position)
	if dir.Magnitude > 0 then
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + dir.Unit)
	end
end

-- // Main Loop for lock on
RunService.RenderStepped:Connect(function()
	if not Locking then return end

	local validTarget = LockedTarget
		and LockedTarget.Character
		and LockedTarget.Character:FindFirstChild("Humanoid")
		and LockedTarget.Character.Humanoid.Health > 0

	if lockMode == "Always Rotation Lock" or lockMode == "Always Camlock" then
		local nearest = getNearestPlayer()
		if nearest ~= LockedTarget then
			LockedTarget = nearest
			if LockedTarget then
				applyHighlight(LockedTarget.Character)
			else
				clearHighlight()
			end
		end
	else
		if not validTarget then
			LockedTarget = getNearestPlayer()
			if LockedTarget then
				applyHighlight(LockedTarget.Character)
			else
				clearHighlight()
			end
		end
	end

	if LockedTarget and LockedTarget.Character then
		local hrp = LockedTarget.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local pos = hrp.Position
			rotateTowards(pos)

			if camLockEnabled then
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos)
			end
		end
	end
end)

-- // Drop down
CombatSection3:Dropdown({
	Name = "Lock Mode",
	Options = {
		"Rotation Lock",
		"Always Rotation Lock",
		"Camlock",
		"Always Camlock"
	},
	Default = "Rotation Lock",
	Callback = function(v)
		lockMode = v
		
		camLockEnabled = (v == "Camlock" or v == "Always Camlock")
	end
})

-- ACTUAL TOGGLE
CombatSection3:Toggle({
	Name = "Enable Lock",
	Default = false,
	Callback = function(v)
		Locking = v

		if not v then
			LockedTarget = nil
			clearHighlight()

			local cam = workspace.CurrentCamera
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				cam.CameraSubject = hum
				cam.CameraType = Enum.CameraType.Custom
			end
		end
	end
})

--// SENS SYSTEM
local sensitivity = 0.7

local cameraTouch = nil
local lastPos = nil
local connections = {}

-- ENABLE
local function enableSensitivity()
	connections.TouchStarted = UserInputService.TouchStarted:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if not cameraTouch then
			cameraTouch = input
			lastPos = input.Position
		end
	end)

	connections.TouchEnded = UserInputService.TouchEnded:Connect(function(input)
		if input == cameraTouch then
			cameraTouch = nil
			lastPos = nil
		end
	end)

	connections.TouchMoved = UserInputService.TouchMoved:Connect(function(input, gameProcessed)
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
end

-- DISABLE
local function disableSensitivity()
	for _, conn in pairs(connections) do
		if conn then
			conn:Disconnect()
		end
	end
	
	connections = {}
	cameraTouch = nil
	lastPos = nil
end

--// TOGGLE
local sensToggle = PlayerSection:Toggle({
	Name = "Custom Sensitivity",
	Default = false,
	Callback = function(v)
		if v then
			enableSensitivity()
		else
			disableSensitivity()
		end
	end
})

--// SLIDER
PlayerSection:Slider({
	Name = "Sensitivity",
	Default = 70, -- represents 0.7
	Minimum = 1,
	Maximum = 200,
	DisplayMethod = "Percent",
	Precision = 0,
	Callback = function(value)
		sensitivity = value / 100
	end
})

-- // GOD AHHHH TOOL GUI
local CoreGui = game:GetService("CoreGui")

local toolGuiEnabled = false
local cleanupEnabled = false
local cleanupToken = 0

--// TOGGLE 1: TOOL GUI
MiscSection:Toggle({
	Name = "Tool GUI",
	Default = false,
	Callback = function(v)
		toolGuiEnabled = v

		if v then
			loadstring(game:HttpGet(
				"https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Skyward/Misc/ToolGui.lua"
			))()
		else
			local gui = CoreGui:FindFirstChild("ToolToggleGui")
			if gui then
				gui:Destroy()
			end
		end
	end
})

--// SUBLABEL WARNING
MiscSection:SubLabel({
	Text = "If you use tool gui enable delete old tool gui with it",
})

--// TOGGLE 2: CLEANER LOOP
MiscSection:Toggle({
	Name = "Delete Old Tool GUI",
	Default = false,
	Callback = function(v)
		cleanupEnabled = v
		cleanupToken += 1
		local myToken = cleanupToken

		if v then
			task.spawn(function()
				while cleanupEnabled and cleanupToken == myToken do
					task.wait(10)

					local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
					if playerGui then
						local screenGui = playerGui:FindFirstChild("ScreenGui")
						if screenGui then
							local potion = screenGui:FindFirstChild("PotionButton")
							if potion then potion:Destroy() end

							local pickaxe = screenGui:FindFirstChild("PickAxeButton")
							if pickaxe then pickaxe:Destroy() end
						end
					end
				end
			end)
		end
	end
})

------------------------ PLAYER CHAMS ------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ChamsEnabled = false
local connections = {}
local appliedHighlights = {}

local function addHighlightToPart(part)
	if not ChamsEnabled then return end
	if part.Name == "HumanoidRootPart" then return end
	if not part:IsA("BasePart") then return end
	if part:FindFirstChild("Cham") then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "Cham"
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0.15
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = part
	highlight.Parent = part

	table.insert(appliedHighlights, highlight)
end

local function scanCharacter(character)
	for _, obj in ipairs(character:GetDescendants()) do
		addHighlightToPart(obj)
	end
end

local function applyChamsToPlayer(player)
	if player == LocalPlayer then return end

	local function setupCharacter(character)
		task.wait(0.15)

		if not ChamsEnabled then return end

		scanCharacter(character)

		table.insert(connections, character.DescendantAdded:Connect(function(obj)
			if ChamsEnabled then
				addHighlightToPart(obj)
			end
		end))

		table.insert(connections, task.spawn(function()
			while ChamsEnabled and character.Parent do
				scanCharacter(character)
				task.wait(2)
			end
		end))
	end

	player.CharacterAdded:Connect(setupCharacter)

	if player.Character then
		setupCharacter(player.Character)
	end
end

local function enableChams()
	ChamsEnabled = true

	for _, player in ipairs(Players:GetPlayers()) do
		applyChamsToPlayer(player)
	end

	connections[#connections + 1] = Players.PlayerAdded:Connect(applyChamsToPlayer)
end

local function disableChams()
	ChamsEnabled = false

	-- remove highlights
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Highlight") and v.Name == "Cham" then
			v:Destroy()
		end
	end

	-- disconnect events
	for _, c in ipairs(connections) do
		if typeof(c) == "RBXScriptConnection" then
			c:Disconnect()
		end
	end

	table.clear(connections)
	table.clear(appliedHighlights)
end

-- // CHAN'MS TOGGLE YAY
VisualSection:Toggle({
	Name = "Player Chams",
	Default = false,
	Callback = function(v)
		if v then
			enableChams()
		else
			disableChams()
		end
	end
})
