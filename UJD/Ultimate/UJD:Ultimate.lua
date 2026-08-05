--// UJD: Ultimate (Rayfield Version with Player Tab + GodMode)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

-- Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "UJD: Ultimate",
    LoadingTitle = "UJD",
    LoadingSubtitle = "Ultimate",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UJDUltimate"
    }
})

-----------------------------------------------------------
--// COMBAT TAB
-----------------------------------------------------------
local CombatTab = Window:CreateTab("Combat")

-- Hitbox
local HitboxEnabled = false
local HitboxSize = 2

CombatTab:CreateToggle({
    Name = "Enable Hitbox For Sans",
    CurrentValue = false,
    Callback = function(v)
        HitboxEnabled = v
    end
})

CombatTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 2,
    Callback = function(v)
        HitboxSize = v
    end
})

task.spawn(function()
    while task.wait(0.1) do
        if HitboxEnabled then
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    -- ✅ Check if workspace.<username>.Sans exists
                    local playerFolder = Workspace:FindFirstChild(plr.Name)
                    if playerFolder and playerFolder:FindFirstChild("Sans") then
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
    end
end)

-----------------------------------------------------------
-- Tool Spammer GUI
-----------------------------------------------------------
CombatTab:CreateToggle({
    Name = "Tool Spammer GUI",
    CurrentValue = false,
    Callback = function(v)
        if v then
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/SpamTools/SingleButton.lua"))()
            end)
        else
            local gui = CoreGui:FindFirstChild("SpamMainGUI")
            if gui then gui:Destroy() end
        end
    end
})

-----------------------------------------------------------
-- Lock On GUI
-----------------------------------------------------------
CombatTab:CreateToggle({
    Name = "Lock On GUI",
    CurrentValue = false,
    Callback = function(v)
        if v then
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/Can%20lock/Camlock(Multi-Features).lua"))()
            end)
        else
            local gui = CoreGui:FindFirstChild("LockModeSelectorGui")
            if gui then gui:Destroy() end
        end
    end
})

-----------------------------------------------------------
-- GodMode
-----------------------------------------------------------
local GodModeEnabled = false
local GodModeConn

-- excluded zones
local excludedZones = {
    {pos = Vector3.new(484.341796875, 50.34758758544922, 966.0596923828125), size = Vector3.new(578, 66, 366)},
    {pos = Vector3.new(-120.24063110351562, 106.90727233886719, 2798.85546875), size = Vector3.new(431, 145, 121)}
}

local function inExcludedZone(part)
    for _,zone in ipairs(excludedZones) do
        local min = zone.pos - (zone.size/2)
        local max = zone.pos + (zone.size/2)
        local p = part.Position
        if p.X >= min.X and p.X <= max.X and
           p.Y >= min.Y and p.Y <= max.Y and
           p.Z >= min.Z and p.Z <= max.Z then
            return true
        end
    end
    return false
end

CombatTab:CreateToggle({
    Name = "GodMode",
    CurrentValue = false,
    Callback = function(v)
        GodModeEnabled = v
        if GodModeEnabled then
            GodModeConn = RunService.Stepped:Connect(function()
                for _,v in pairs(lp.Character:GetChildren()) do
                    if v:IsA("BasePart") and not inExcludedZone(v) then
                        v.CanTouch = false
                    end
                end
                lp.SimulationRadius = -100
            end)
        else
            -- ✅ Disconnect and reset
            if GodModeConn then GodModeConn:Disconnect() GodModeConn = nil end
            for _,v in pairs(lp.Character:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CanTouch = true
                end
            end
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanTouch = true
                end
            end
        end
    end
})

-----------------------------------------------------------
-- GodMode (Less Blatant)
-----------------------------------------------------------
local LessBlatantEnabled = false
local protectedParts = {}

-- helper: weighted random delay
local function weightedDelay()
    local roll = math.random(1,4)
    if roll <= 2 then
        return 0 -- 2/4 chance full godmode instantly
    elseif roll == 3 then
        return 0.25 -- 1/4 chance
    else
        return 0.5 -- 1/4 chance
    end
end

local function protectPart(part)
    if not part:IsA("BasePart") then return end
    if inExcludedZone(part) then return end
    if protectedParts[part] then return end

    local delayTime = weightedDelay()
    task.delay(delayTime, function()
        if LessBlatantEnabled and part.Parent and part:IsDescendantOf(Workspace) then
            part.CanTouch = false
            protectedParts[part] = true
        end
    end)
end

CombatTab:CreateToggle({
    Name = "GodMode (Less Blatant)",
    CurrentValue = false,
    Callback = function(v)
        LessBlatantEnabled = v
        if LessBlatantEnabled then
            -- existing parts
            for _,v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and v:FindFirstChildWhichIsA("TouchInterest") then
                    protectPart(v)
                end
            end
            -- new parts
            Workspace.DescendantAdded:Connect(function(descendant)
                if LessBlatantEnabled and descendant:IsA("TouchInterest") then
                    local parent = descendant.Parent
                    if parent and parent:IsA("BasePart") then
                        protectPart(parent)
                    end
                end
            end)
        else
            -- ✅ Reset all parts
            for part,_ in pairs(protectedParts) do
                if part and part:IsA("BasePart") then
                    part.CanTouch = true
                end
            end
            protectedParts = {}
        end
    end
})

-----------------------------------------------------------
--// PLAYER TAB
-----------------------------------------------------------
local PlayerTab = Window:CreateTab("Player")

-- No Jump Cooldown
local NoJumpCooldown = false

PlayerTab:CreateToggle({
    Name = "No Jump Cooldown",
    CurrentValue = false,
    Callback = function(v)
        NoJumpCooldown = v
    end
})

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

if lp.Character then setupChar(lp.Character) end
lp.CharacterAdded:Connect(setupChar)

-- WalkSpeed
local WalkSpeedValue = 16
local WalkSpeedLoop = false
local WalkSpeedAdvanced = false

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        WalkSpeedValue = v
    end
})

PlayerTab:CreateToggle({
    Name = "Walk Speed",
    CurrentValue = false,
    Callback = function(v)
        WalkSpeedLoop = v
    end
})

PlayerTab:CreateToggle({
    Name = "Walk Speed (Advanced)",
    CurrentValue = false,
    Callback = function(v)
        WalkSpeedAdvanced = v
    end
})

task.spawn(function()
    while task.wait(0.05) do
        if hum then
            if WalkSpeedLoop then
                hum.WalkSpeed = WalkSpeedValue
            end
            if WalkSpeedAdvanced then
                if hum.WalkSpeed < WalkSpeedValue then
                    hum.WalkSpeed = WalkSpeedValue
                end
            end
        end
    end
end)
