--// UJD: Ultimate
-- Orion UI Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "UJD: Ultimate", HidePremium = false, SaveConfig = true, ConfigFolder = "UJDUltimate"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

-----------------------------------------------------------
--// COMBAT TAB
-----------------------------------------------------------
local CombatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://4483345998"
})

local HitboxEnabled = false
local HitboxSize = 2

CombatTab:AddToggle({
    Name = "Hitbox",
    Default = false,
    Callback = function(v)
        HitboxEnabled = v
    end
})

CombatTab:AddSlider({
    Name = "Hitbox Size",
    Min = 1,
    Max = 50,
    Default = 2,
    Callback = function(v)
        HitboxSize = v
    end
})

-- Hitbox Loop
task.spawn(function()
    while task.wait(0.1) do
        if HitboxEnabled then
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local root = plr.Character.HumanoidRootPart
                    root.CanCollide = false

                    if HitboxSize == 1 then
                        root.Size = Vector3.new(2,1,1)
                        root.Transparency = 0.75
                    else
                        root.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                        root.Transparency = 0.75
                    end
                end
            end
        end
    end
end)

-----------------------------------------------------------
--// PLAYER TAB
-----------------------------------------------------------
local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998"
})

-----------------------------------------------------------
--// NO JUMP COOLDOWN
-----------------------------------------------------------
local NoJumpCooldown = false

PlayerTab:AddToggle({
    Name = "No Jump Cooldown",
    Default = false,
    Callback = function(v)
        NoJumpCooldown = v
    end
})

-- No Jump Cooldown Loop
task.spawn(function()
    while task.wait(0.1) do
        if NoJumpCooldown then
            pcall(function()
                StarterGui:SetCore("JumpButtonEnabled", true)
                StarterGui:SetCore("JumpButtonVisible", true)
            end)
        end
    end
end)

local function setupChar(char)
    local hum = char:WaitForChild("Humanoid")

    RunService.RenderStepped:Connect(function()
        if NoJumpCooldown then
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            hum.AutoJumpEnabled = false
        end
    end)
end

if lp.Character then
    setupChar(lp.Character)
end
lp.CharacterAdded:Connect(setupChar)

-----------------------------------------------------------
--// WALKSPEED SYSTEM
-----------------------------------------------------------
local WalkSpeedValue = 16
local WalkSpeedLoop = false
local WalkSpeedAdvanced = false

PlayerTab:AddSlider({
    Name = "Walk Speed",
    Min = 1,
    Max = 50,
    Default = 16,
    Callback = function(v)
        WalkSpeedValue = v
    end
})

PlayerTab:AddToggle({
    Name = "Walk Speed",
    Default = false,
    Callback = function(v)
        WalkSpeedLoop = v
    end
})

PlayerTab:AddToggle({
    Name = "Walk Speed (Advanced)",
    Default = false,
    Callback = function(v)
        WalkSpeedAdvanced = v
    end
})

-- WalkSpeed Loop
task.spawn(function()
    while task.wait(0.05) do
        if hum then
            if WalkSpeedLoop then
                hum.WalkSpeed = WalkSpeedValue
            end

            if WalkSpeedAdvanced then
                -- If game sets a higher speed, let it stay
                if hum.WalkSpeed < WalkSpeedValue then
                    hum.WalkSpeed = WalkSpeedValue
                end
            end
        end
    end
end)

-----------------------------------------------------------
OrionLib:Init()
