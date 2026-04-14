-- // SERVICES
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- // PATHS
local function getGui()
	return player:FindFirstChild("PlayerGui")
		and player.PlayerGui:FindFirstChild("ScreenGui")
end

-- // Good shi
while true do
	task.wait(10)

	local gui = getGui()
	if gui then
		local potion = gui:FindFirstChild("PotionButton")
		if potion then
			potion:Destroy()
		end

		local pickaxe = gui:FindFirstChild("PickAxeButton")
		if pickaxe then
			pickaxe:Destroy()
		end
	end
end
