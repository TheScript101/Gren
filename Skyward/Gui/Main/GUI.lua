local WMacLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Wicikk/WMacLib/main/WMacLib.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

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

--// SECTION
local CombatSection = CombatTab:Section({})
local PlayerSection = PlayerTab:Section({})
local MiscSection = MiscTab:Section({})

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

-- // Label for auto clicker
--// LABEL
-- label goes here
-- label (correct MacLib usage)
MiscSection:Label({
    Text = "Autoclicker",
    Bold = true,
}, "AutoClickLabel")

-- // SOME AUTOCLICKER YES
local CoreGui = game:GetService("CoreGui")

local autoclickerLoaded = false

MiscTab:Section({}):Toggle({
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
local autoClickSpeed = 1 / 50 -- 50 CPS

-- loop (runs once, controlled by toggle)
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

-- toggle in your GUI (put this in your section)
MiscTab:Section({}):Toggle({
	Name = "Auto Click (No GUI)",
	Default = false,
	Callback = function(v)
		autoClickEnabled = v
	end
})

-- DEFAULT TAB
CombatTab:Select()
