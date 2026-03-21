-- LOADSTRING FIRST
getgenv().morph = false
loadstring(game:HttpGet("https://raw.githubusercontent.com/skibiditoiletfan2007/BaldyToSorcerer/refs/heads/main/LatestV2.lua"))()

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- CREATE TOOL
local tool = Instance.new("Tool")
tool.Name = "Hollow Nuke Wind-up. (ULT)"
tool.RequiresHandle = false
tool.Parent = player.Backpack

-- COOLDOWN
local debounce = false

-- CHAT FUNCTION
local function sendChat(msg)
    local channel = TextChatService.TextChannels:WaitForChild("RBXGeneral",10)
    if channel then
        channel:SendAsync(msg)
    end
end

-- NOTIFICATION
local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "ULT",
            Text = msg,
            Duration = 3
        })
    end)
end

-- AIR WALK
local floatPart, floatConn

local function enableAirWalk(char)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    floatPart = Instance.new("Part")
    floatPart.Size = Vector3.new(2,0.2,1.5)
    floatPart.Transparency = 1
    floatPart.Anchored = true
    floatPart.Parent = char

    floatConn = RunService.Heartbeat:Connect(function()
        if root and floatPart then
            floatPart.CFrame = root.CFrame * CFrame.new(0,-3,0)
        end
    end)
end

local function disableAirWalk()
    if floatConn then floatConn:Disconnect() end
    if floatPart then floatPart:Destroy() end
end

-- GUI PROMPT 1 (CHANTS)
local function askChants()
    local gui = Instance.new("ScreenGui", game.CoreGui)

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,250,0,120)
    frame.Position = UDim2.new(0.5,-125,0.5,-60)
    frame.BackgroundColor3 = Color3.new(0,0,0)

    local text = Instance.new("TextLabel", frame)
    text.Size = UDim2.new(1,0,0.4,0)
    text.Text = "Chants Enabled?"
    text.TextColor3 = Color3.new(1,1,1)
    text.BackgroundTransparency = 1

    local yes = Instance.new("TextButton", frame)
    yes.Size = UDim2.new(0.5,0,0.6,0)
    yes.Position = UDim2.new(0,0,0.4,0)
    yes.Text = "Yes"

    local no = Instance.new("TextButton", frame)
    no.Size = UDim2.new(0.5,0,0.6,0)
    no.Position = UDim2.new(0.5,0,0.4,0)
    no.Text = "No"

    local result = nil

    yes.MouseButton1Click:Connect(function()
        result = true
        gui:Destroy()
    end)

    no.MouseButton1Click:Connect(function()
        result = false
        gui:Destroy()
    end)

    repeat task.wait() until result ~= nil
    return result
end

-- 🔥 GUI PROMPT 2 (AIR OR GROUND)
local function askVariant()
    local gui = Instance.new("ScreenGui", game.CoreGui)

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,250,0,120)
    frame.Position = UDim2.new(0.5,-125,0.5,-60)
    frame.BackgroundColor3 = Color3.new(0,0,0)

    local text = Instance.new("TextLabel", frame)
    text.Size = UDim2.new(1,0,0.4,0)
    text.Text = "Air Variant or Ground?"
    text.TextColor3 = Color3.new(1,1,1)
    text.BackgroundTransparency = 1

    local ground = Instance.new("TextButton", frame)
    ground.Size = UDim2.new(0.5,0,0.6,0)
    ground.Position = UDim2.new(0,0,0.4,0)
    ground.Text = "Ground"

    local air = Instance.new("TextButton", frame)
    air.Size = UDim2.new(0.5,0,0.6,0)
    air.Position = UDim2.new(0.5,0,0.4,0)
    air.Text = "Air"

    local result = nil

    ground.MouseButton1Click:Connect(function()
        result = "Ground"
        gui:Destroy()
    end)

    air.MouseButton1Click:Connect(function()
        result = "Air"
        gui:Destroy()
    end)

    repeat task.wait() until result ~= nil
    return result
end

-- MAIN TOOL LOGIC
tool.Activated:Connect(function()
    if debounce then return end
    debounce = true

    -- CHECK FOR SERIOUS PUNCH FIRST
    local punch = player.Backpack:FindFirstChild("Serious Punch")
    if not punch then
        notify("GAIN ULT AND USE IT")
        debounce = false
        return
    end

    -- ASK CHANTS
    local chantsEnabled = askChants()

    -- 🔥 ASK VARIANT
    local variant = askVariant()

    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    -- LOAD ANIMATION
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://78615192673057"
    local track = hum:LoadAnimation(anim)
    track:Play()

    -- AFTER 1 SECOND FREEZE ANIMATION
    task.wait(1)
    track:AdjustSpeed(0)

    -- HARD FREEZE PLAYER
    root.Anchored = true
    hum.AutoRotate = false

    -- CHANTS
    if chantsEnabled then
        task.spawn(function()
            sendChat("Phase, Twilight")
            task.wait(1.5)
            sendChat("Polarized Light")
            task.wait(1.5)
            sendChat("Crow and Declaration")
            task.wait(1.5)
            sendChat("Between Front and Back.")
            task.wait(2)
            sendChat("Hollow")
            task.wait(2.5)
            sendChat("Purple.")
        end)
    end

    -- TOTAL FREEZE TIME = 2.8s
    task.wait(1.9)

    -- STOP ANIMATION
    track:Stop()

    -- UNFREEZE
    root.Anchored = false
    hum.AutoRotate = true

    -- EQUIP TOOL
    hum:EquipTool(punch)

    -- 🔥 VARIANT EXECUTION
    if variant == "Air" then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.3)
        punch:Activate()
    else
        task.wait(0.2)
        punch:Activate()
    end

    -- DISABLE AIR WALK AFTER 1.5s
    task.wait(1.5)
    disableAirWalk()

    -- COOLDOWN
    task.wait(10)
    debounce = false
end)
