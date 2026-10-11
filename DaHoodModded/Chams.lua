--// CHAMS TOGGLE
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local chamsEnabled = false
local highlights = {}

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ChamsGui"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

--// BUTTON
local button = Instance.new("TextButton")
button.Name = "ChamsButton"
button.Size = UDim2.new(0, 130, 0, 36)
button.Position = UDim2.new(0, 20, 0, 220)
button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "Chams: OFF"
button.TextSize = 14
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

--// CHAMS
local function removeChams(player)
    local highlight = highlights[player]
    if highlight then
        highlight:Destroy()
        highlights[player] = nil
    end
end

local function addChams(player)
    if not chamsEnabled or player == LocalPlayer then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    removeChams(player)

    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerChams"
    highlight.Adornee = character
    highlight.FillColor = Color3.new(1, 1, 1)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    highlights[player] = highlight
end

local function updateChams()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if chamsEnabled then
                addChams(player)
            else
                removeChams(player)
            end
        end
    end

    button.Text = chamsEnabled and "Chams: ON" or "Chams: OFF"
end

--// TOGGLE
button.Activated:Connect(function()
    chamsEnabled = not chamsEnabled
    updateChams()
end)

--// PLAYER / RESPAWN SUPPORT
local function setupPlayer(player)
    if player == LocalPlayer then
        return
    end

    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if chamsEnabled then
            addChams(player)
        end
    end)

    if chamsEnabled then
        addChams(player)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(player)
    removeChams(player)
end)
