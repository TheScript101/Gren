--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

--// CLEAN OLD GUI
pcall(function()
    if player.PlayerGui:FindFirstChild("ToolSpamGui") then
        player.PlayerGui.ToolSpamGui:Destroy()
    end
end)

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ToolSpamGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--// BUTTON
local spamBtn = Instance.new("TextButton")
spamBtn.Size = UDim2.new(0.2, 0, 0, 50)
spamBtn.Position = UDim2.new(0.4, 0, 0, 50)
spamBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 90)
spamBtn.Text = "SPAM ALL TOOLS"
spamBtn.TextColor3 = Color3.new(1, 1, 1)
spamBtn.Font = Enum.Font.GothamBold
spamBtn.TextSize = 16
spamBtn.Draggable = true
spamBtn.Parent = gui
Instance.new("UICorner", spamBtn)

--// STATE
local spamming = false
local spamConnection

--// SPAM FUNCTION (COOLDOWN-PROOF)
local function startSpamming()
    if spamConnection then spamConnection:Disconnect() end

    spamConnection = RunService.RenderStepped:Connect(function()
        local backpack = player:FindFirstChild("Backpack")
        local char = player.Character

        if not backpack or not char then return end

        -- EQUIP → ACTIVATE → UNEQUIP (instant)
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then

                -- equip tool instantly
                pcall(function()
                    tool.Parent = char
                end)

                -- activate tool instantly
                pcall(function()
                    tool:Activate()
                end)

                -- unequip instantly so next tool can equip
                pcall(function()
                    tool.Parent = backpack
                end)
            end
        end
    end)
end

local function stopSpamming()
    if spamConnection then
        spamConnection:Disconnect()
        spamConnection = nil
    end
end

--// BUTTON LOGIC
spamBtn.MouseButton1Click:Connect(function()
    spamming = not spamming

    if spamming then
        spamBtn.Text = "STOP SPAM"
        spamBtn.BackgroundColor3 = Color3.fromRGB(120, 180, 120)
        startSpamming()
    else
        spamBtn.Text = "SPAM ALL TOOLS"
        spamBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 90)
        stopSpamming()
    end
end)
