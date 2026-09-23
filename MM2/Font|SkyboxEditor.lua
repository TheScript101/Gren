--// MM2 Luckiest Guy + Night Sky
--// Client-side / Delta

local Lighting = game:GetService("Lighting")

Lighting.ClockTime = 0.5
Lighting.Brightness = 1
Lighting.Ambient = Color3.fromRGB(10, 12, 30)
Lighting.OutdoorAmbient = Color3.fromRGB(20, 25, 50)

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- NIGHT SKY
--------------------------------------------------

-- Remove existing Sky objects
for _, object in ipairs(Lighting:GetChildren()) do
    if object:IsA("Sky") then
        object:Destroy()
    end
end

-- Create sky
local Sky = Instance.new("Sky")
Sky.Name = "MM2NightSky"

Sky.CelestialBodiesShown = true
Sky.StarCount = 3000
Sky.MoonAngularSize = 12
Sky.SunAngularSize = 0

-- IMPORTANT:
-- No ClockTime, Brightness, Ambient, or OutdoorAmbient changes.
-- This keeps the map's existing lighting unchanged.

Sky.Parent = Lighting

--------------------------------------------------
-- LUCKIEST GUY FONT
--------------------------------------------------

local LuckiestGuy = Font.new(
    "rbxasset://fonts/families/LuckiestGuy.json",
    Enum.FontWeight.Regular,
    Enum.FontStyle.Normal
)

local function applyFont(object)
    if object:IsA("TextLabel")
        or object:IsA("TextButton")
        or object:IsA("TextBox") then

        pcall(function()
            object.FontFace = LuckiestGuy
        end)
    end
end

-- Change existing UI
for _, object in ipairs(playerGui:GetDescendants()) do
    applyFont(object)
end

-- Change UI created afterward
playerGui.DescendantAdded:Connect(function(object)
    task.defer(function()
        applyFont(object)
    end)
end)

print("MM2 Night Sky + Luckiest Guy loaded!")
