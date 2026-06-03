local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local emoteGui = playerGui:WaitForChild("Emotes"):WaitForChild("Emote")

local inventory = playerGui:WaitForChild("Menus"):WaitForChild("Group"):WaitForChild("Inventory")
local emotesInventory = inventory:WaitForChild("Items"):WaitForChild("Emotes")
local equipped = emotesInventory:WaitForChild("Equipped")

local function updateVisibility()
	-- Emote menu
	local emoteVisible = emoteGui.Visible

	for _, slotName in ipairs({"5", "6", "7", "8"}) do
		local slot = emoteGui.Page1:FindFirstChild(slotName)
		if slot then
			slot.Visible = emoteVisible
		end
	end

	-- Show Switch button in Emote menu
	local emoteSwitch = emoteGui:FindFirstChild("Switch")
	if emoteSwitch then
		emoteSwitch.Visible = emoteVisible
	end

	-- Page2 slots
	local page2 = emoteGui:FindFirstChild("Page2")
	if page2 then
		local page2Visible = page2.Visible

		for _, slotName in ipairs({"13", "14", "15", "16"}) do
			local slot = page2:FindFirstChild(slotName)
			if slot then
				slot.Visible = page2Visible
			end
		end
	end

	-- Inventory menu
	local inventoryVisible = inventory.Visible and emotesInventory.Visible

	for _, slotName in ipairs({"5", "6", "7", "8"}) do
		local slot = equipped:FindFirstChild(slotName)
		if slot then
			slot.Visible = inventoryVisible
		end
	end

	-- Show Switch button in Equipped menu
	local equippedSwitch = equipped:FindFirstChild("Switch")
	if equippedSwitch then
		equippedSwitch.Visible = inventoryVisible
	end
end

-- Initial update
updateVisibility()

-- Listen for visibility changes
emoteGui:GetPropertyChangedSignal("Visible"):Connect(updateVisibility)

local page2 = emoteGui:FindFirstChild("Page2")
if page2 then
	page2:GetPropertyChangedSignal("Visible"):Connect(updateVisibility)
end

inventory:GetPropertyChangedSignal("Visible"):Connect(updateVisibility)
emotesInventory:GetPropertyChangedSignal("Visible"):Connect(updateVisibility)
