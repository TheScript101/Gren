------------------------ PLAYER CHAMS ------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function addHighlights(character)
	for _, obj in ipairs(character:GetChildren()) do
		if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
			if not obj:FindFirstChild("Cham") then
				local highlight = Instance.new("Highlight")
				highlight.Name = "Cham"
				highlight.FillColor = Color3.fromRGB(255, 0, 0)
				highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
				highlight.FillTransparency = 0.5 -- ✅ your value
				highlight.OutlineTransparency = 0
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Adornee = obj
				highlight.Parent = obj
			end
		end
	end
end

function applyChamsToPlayer(player)
	if player ~= LocalPlayer then
		player.CharacterAdded:Connect(function(character)
			addHighlights(character)

			-- also handle new parts added later (accessories, etc.)
			character.ChildAdded:Connect(function(child)
				if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
					task.wait()
					addHighlights(character)
				end
			end)
		end)

		-- Apply immediately if already spawned
		if player.Character then
			addHighlights(player.Character)
		end
	end
end

-- Apply to all current players
for _, player in pairs(Players:GetPlayers()) do
	applyChamsToPlayer(player)
end

-- Apply to new players
Players.PlayerAdded:Connect(function(player)
	applyChamsToPlayer(player)
end)
