
--// CHAMS TOGGLE

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local chamsEnabled = false
local chamsHighlights = {}

--// Button
local chamsButton = Instance.new("TextButton")
chamsButton.Name = "ChamsToggle"
chamsButton.Size = UDim2.fromOffset(115, 35)
chamsButton.Position = UDim2.new(0.5, 65, 0.5, -17)
chamsButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
chamsButton.TextColor3 = Color3.new(1, 1, 1)
chamsButton.Text = "Chams: OFF"
chamsButton.TextSize = 14
chamsButton.Font = Enum.Font.GothamBold
chamsButton.BorderSizePixel = 0
chamsButton.Active = true
chamsButton.Parent = gui -- Uses the existing ScreenGui

local chamsCorner = Instance.new("UICorner")
chamsCorner.CornerRadius = UDim.new(0, 8)
chamsCorner.Parent = chamsButton

local function removeChams(player)
    local highlight = chamsHighlights[player]
    if highlight then
        highlight:Destroy()
        chamsHighlights[player] = nil
    end
end

local function applyChams(player)
    if not chamsEnabled or player == LocalPlayer then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    removeChams(player)

    local highlight = Instance.new("Highlight")
    highlight.Name = "SimpleWhiteChams"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = gui

    chamsHighlights[player] = highlight
end

local function setChams(state)
    chamsEnabled = state

    chamsButton.Text = "Chams: " .. (state and "ON" or "OFF")
    chamsButton.BackgroundColor3 = state
        and Color3.fromRGB(35, 145, 70)
        or Color3.fromRGB(45, 45, 45)

    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            applyChams(player)
        end
    else
        for player in pairs(chamsHighlights) do
            removeChams(player)
        end
    end
end

chamsButton.Activated:Connect(function()
    setChams(not chamsEnabled)
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if chamsEnabled then
            task.wait(0.2)
            applyChams(player)
        end
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            if chamsEnabled then
                task.wait(0.2)
                applyChams(player)
            end
        end)
    end
end

Players.PlayerRemoving:Connect(function(player)
    removeChams(player)
end)
