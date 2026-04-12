------------------------ MEGA VIP ENTER TELEPORT ------------------------
local enterDestination = Vector3.new(0, 175, 70)
local enterTeleportsFolder = workspace:WaitForChild("Lobby"):WaitForChild("MegaVIPRoom"):WaitForChild("Teleport"):WaitForChild("Enter")

for _, part in pairs(enterTeleportsFolder:GetChildren()) do
	if part.Name == "Teleporter A" and part:FindFirstChild("TeleportMegaVIPEnter") then
		part.Touched:Connect(function(hit)
			local character = hit.Parent
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				local rootPart = character:FindFirstChild("HumanoidRootPart")
				if rootPart then
					rootPart.CFrame = CFrame.new(enterDestination)

					-- Resize effect for Enter
					local originalSize = part.Size
					part.Size = Vector3.new(8, 0.01, 7)
					task.delay(1, function()
						part.Size = originalSize
					end)
				end
			end
		end)
	end
end

------------------------ MEGA VIP EXIT TELEPORT ------------------------
local exitDestination = Vector3.new(0, 177.1, 6)
local exitTeleportsFolder = workspace:WaitForChild("Lobby"):WaitForChild("MegaVIPRoom"):WaitForChild("Teleport"):WaitForChild("Exit")

for _, part in pairs(exitTeleportsFolder:GetChildren()) do
	if part.Name == "Teleporter A" and part:FindFirstChild("TeleportMegaVIPExit") then
		part.Touched:Connect(function(hit)
			local character = hit.Parent
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				local rootPart = character:FindFirstChild("HumanoidRootPart")
				if rootPart then
					rootPart.CFrame = CFrame.new(exitDestination)

					-- Resize effect for Exit
					local originalSize = part.Size
					part.Size = Vector3.new(4, 0.01, 3)
					task.delay(1, function()
						part.Size = originalSize
					end)
				end
			end
		end)
	end
end
