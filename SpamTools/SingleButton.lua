--// SETTINGS
getgenv().spamTools = false
local spamInterval = 0.01

--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Remove old GUI if exists
pcall(function()
    if CoreGui:FindFirstChild("SpamMainGUI") then
        CoreGui.SpamMainGUI:Destroy()
    end
end)

--// ROOT GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SpamMainGUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

---------------------------------------------------------
-- MAIN SPAM BUTTON (kept exactly where yours was)
---------------------------------------------------------
local spamButton = Instance.new("TextButton")
spamButton.Size = UDim2.new(0, 200, 0, 50)
spamButton.Position = UDim2.new(0.5, -100, 0, 10) -- your original position
spamButton.Text = "Start Spamming Tools"
spamButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
spamButton.TextScaled = true
spamButton.Visible = true
spamButton.Parent = gui

Instance.new("UICorner", spamButton).CornerRadius = UDim.new(0, 8)

---------------------------------------------------------
-- TOP-LEFT TOGGLE BUTTON (controls visibility)
---------------------------------------------------------
local toggleVisibility = Instance.new("TextButton")
toggleVisibility.Size = UDim2.new(0, 60, 0, 35)
toggleVisibility.Position = UDim2.new(0, 10, 0, 10) -- top-left near Roblox UI
toggleVisibility.Text = "Show"
toggleVisibility.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
toggleVisibility.TextColor3 = Color3.new(1, 1, 1)
toggleVisibility.Font = Enum.Font.GothamBold
toggleVisibility.TextSize = 14
toggleVisibility.Parent = gui

Instance.new("UICorner", toggleVisibility).CornerRadius = UDim.new(0, 8)

---------------------------------------------------------
-- VISIBILITY TOGGLE LOGIC
---------------------------------------------------------
toggleVisibility.MouseButton1Click:Connect(function()
    spamButton.Visible = not spamButton.Visible

    if spamButton.Visible then
        toggleVisibility.Text = "Hide"
        toggleVisibility.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
    else
        toggleVisibility.Text = "Show"
        toggleVisibility.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    end
end)

---------------------------------------------------------
-- SPAM FUNCTION (one-by-one rapid cycle)
---------------------------------------------------------
local function spamToolsFunction()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    -- auto-stop if humanoid dies
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Died:Connect(function()
            getgenv().spamTools = false
            spamButton.Text = "Start Spamming Tools"
            spamButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end)
    end

    while getgenv().spamTools do
        local backpack = LocalPlayer.Backpack
        if not backpack then task.wait(0.01) continue end

        for _, tool in ipairs(backpack:GetChildren()) do
            if not getgenv().spamTools then break end
            if tool:IsA("Tool") then
                -- Equip
                tool.Parent = character
                task.wait(0.01)

                -- Hold equipped briefly
                task.wait(0.05)

                -- Use/activate
                if tool:FindFirstChild("Remote") then
                    pcall(function() tool.Remote:FireServer() end)
                else
                    pcall(function() tool:Activate() end)
                end

                -- Small delay before next tool
                task.wait(0.02)

                -- Unequip back to backpack
                tool.Parent = backpack
            end
        end
    end
end

---------------------------------------------------------
-- MAIN SPAM BUTTON LOGIC
---------------------------------------------------------
spamButton.MouseButton1Click:Connect(function()
    getgenv().spamTools = not getgenv().spamTools

    if getgenv().spamTools then
        spamButton.Text = "Stop Spamming Tools"
        spamButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        spawn(spamToolsFunction)
    else
        spamButton.Text = "Start Spamming Tools"
        spamButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    end
end)
