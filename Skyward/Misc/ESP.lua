------------------------ PLAYER CHAMS ------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function applyChamsToPlayer(player)
	if player ~= LocalPlayer then
		player.CharacterAdded:Connect(function(character)
			local highlight = Instance.new("Highlight")
			highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red fill
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White outline
			highlight.OutlineTransparency = 0 -- Solid outline
			highlight.FillTransparency = 0.3 -- Slight transparency
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Name = "Cham"
			highlight.Parent = character
			highlight.Adornee = character
		end)

		-- Apply immediately if already spawned
		if player.Character then
			local existing = player.Character:FindFirstChild("Cham")
			if not existing then
				local highlight = Instance.new("Highlight")
				highlight.FillColor = Color3.fromRGB(255, 0, 0)
				highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
				highlight.OutlineTransparency = 0
				highlight.FillTransparency = 0.3
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Name = "Cham"
				highlight.Adornee = player.Character
				highlight.Parent = player.Character
			end
		end
	end
end

-- Apply chams to all current players
for _, player in pairs(Players:GetPlayers()) do
	applyChamsToPlayer(player)
end

-- Apply chams to new players joining
Players.PlayerAdded:Connect(function(player)
	applyChamsToPlayer(player)
end)
