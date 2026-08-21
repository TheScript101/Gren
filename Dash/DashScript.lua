--// Remove old dash UI if exists
if game.CoreGui:FindFirstChild("DashUI") then
    game.CoreGui.DashUI:Destroy()
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- function to get fresh character + humanoid after respawn
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    return char, hum
end

local char, hum = getChar()

-- reload animation every time character respawns
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = newChar:WaitForChild("Humanoid")

    dashTrack = hum:LoadAnimation(dashAnim)
    dashTrack.Priority = Enum.AnimationPriority.Action
    dashTrack:AdjustSpeed(2.5)
end)

-- Load dash animation (speed x2.5)
local dashAnim = Instance.new("Animation")
dashAnim.AnimationId = "rbxassetid://46196309"
local dashTrack = hum:LoadAnimation(dashAnim)
dashTrack.Priority = Enum.AnimationPriority.Action
dashTrack:AdjustSpeed(2.5)

--// UI
local gui = Instance.new("ScreenGui")
gui.Name = "DashUI"
gui.Parent = CoreGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 120, 0, 45)
button.Position = UDim2.new(1, -140, 0.25, 0) -- NEW POSITION
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.Text = "DASH"
button.TextSize = 20
button.Font = Enum.Font.GothamBold
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Parent = gui

local corner = Instance.new("UICorner", button)
corner.CornerRadius = UDim.new(0, 8)

--// DASH FUNCTION
local dashing = false

local function dash()
    if dashing then return end
    dashing = true

    -- refresh character + humanoid in case of death
    char, hum = getChar()

    -- reload animation on new humanoid
    dashTrack = hum:LoadAnimation(dashAnim)
    dashTrack.Priority = Enum.AnimationPriority.Action
    dashTrack:AdjustSpeed(2.5)

    dashTrack:Play()

    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        for i = 1, 12 do
            root.CFrame = root.CFrame + (root.CFrame.LookVector * 2.5)
            task.wait(0.02)
        end
    end

    dashTrack:Stop()
    dashing = false
end

button.MouseButton1Click:Connect(dash)
