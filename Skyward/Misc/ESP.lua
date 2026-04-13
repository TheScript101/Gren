------------------------ PLAYER CHAMS ------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function addHighlightToPart(part)
	if part.Name == "HumanoidRootPart" then return end
	if not part:IsA("BasePart") then return end
	if part:FindFirstChild("Cham") then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "Cham"
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0.15
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = part
	highlight.Parent = part
end

local function scanCharacter(character)
	for _, obj in ipairs(character:GetDescendants()) do -- 🔥 FIX: Descendants (gets accessories too)
		addHighlightToPart(obj)
	end
end

function applyChamsToPlayer(player)
	if player == LocalPlayer then return end

	local function setupCharacter(character)
		task.wait(0.15) -- 🔥 FIX: wait for full load
		scanCharacter(character)

		-- 🔥 FIX: detect new parts (accessories, etc.)
		character.DescendantAdded:Connect(function(obj)
			addHighlightToPart(obj)
		end)

		-- 🔥 FIX: safety loop (ensures nothing is missed)
		task.spawn(function()
			while character.Parent do
				scanCharacter(character)
				task.wait(2)
			end
		end)
	end

	-- Character spawn
	player.CharacterAdded:Connect(setupCharacter)

	-- Already spawned
	if player.Character then
		setupCharacter(player.Character)
	end
end

-- Existing players
for _, player in ipairs(Players:GetPlayers()) do
	applyChamsToPlayer(player)
end

-- New players
Players.PlayerAdded:Connect(applyChamsToPlayer)
