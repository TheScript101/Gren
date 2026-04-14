local WMacLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Wicikk/WMacLib/main/WMacLib.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Window = WMacLib:Window({
	Title = "Skywars Hub",
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

--// PLAYER SECTION
local PlayerSection = PlayerTab:Section({})

--// SENS SYSTEM
local sensitivity = 0.7

local cameraTouch = nil
local lastPos = nil

local sensEnabled = false
local connections = {}

-- FUNCTION TO ENABLE
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

-- FUNCTION TO DISABLE
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
PlayerSection:Toggle({
	Name = "More Sensitivity",
	Default = false,
	Callback = function(v)
		sensEnabled = v
		
		if v then
			enableSensitivity()
		else
			disableSensitivity()
		end
	end
})

-- DEFAULT TAB
CombatTab:Select()
