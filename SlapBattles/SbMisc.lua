-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-------------------------------------------------
-- RAYFIELD
-------------------------------------------------
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "SLAP BATTLES MISC",
    LoadingTitle = "SLAP BATTLES MISC",
    LoadingSubtitle = "Ping Pong Tools",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-------------------------------------------------
-- PING PONG TAB (existing)
-------------------------------------------------
local PingPongTab = Window:CreateTab("Ping Pong", 0)

-- PING PONG VARIABLES
local autoHit = false
local showRadius = false
local hitRadius = 10

-- scanning frequency (seconds)
local pingScanInterval = 0.20
local pingScanAccumulator = 0

-- cooldowns for ping animation only
local lastAnimTime = 0
local animationCooldown = 1 -- seconds (for ping-pong animation only)

-- RADIUS VISUAL (ping pong)
local radiusPart = Instance.new("Part")
radiusPart.Name = "PingPongRadius"
radiusPart.Anchored = true
radiusPart.CanCollide = false
radiusPart.Transparency = 0.6
radiusPart.Color = Color3.fromRGB(0, 255, 0)
radiusPart.Material = Enum.Material.Neon
radiusPart.Shape = Enum.PartType.Cylinder
radiusPart.Size = Vector3.new(0.2, hitRadius * 2, hitRadius * 2)
radiusPart.CFrame = CFrame.new(9e9, 9e9, 9e9)
radiusPart.Parent = nil

-- ANIMATION (ping pong)
local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://13526154547"
local animTrack = humanoid:LoadAnimation(anim)

-- PING PONG UI
PingPongTab:CreateToggle({
    Name = "Auto Hit Ping Pong",
    CurrentValue = false,
    Flag = "AutoHitPingPong",
    Callback = function(v)
        autoHit = v
    end
})

PingPongTab:CreateParagraph({
    Title = "Info",
    Content = "Automatically hits nearby ping pong balls (yours or other players')."
})

PingPongTab:CreateToggle({
    Name = "Show Radius",
    CurrentValue = false,
    Flag = "ShowRadius",
    Callback = function(v)
        showRadius = v
        if v then
            radiusPart.Parent = workspace
            if root and root.Position then
                radiusPart.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, 0, math.rad(90))
            end
        else
            radiusPart.CFrame = CFrame.new(9e9, 9e9, 9e9)
            radiusPart.Parent = nil
        end
    end
})

PingPongTab:CreateSlider({
    Name = "Auto Hit Radius",
    Range = {1, 30},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 20,
    Flag = "HitRadius",
    Callback = function(v)
        hitRadius = v
        radiusPart.Size = Vector3.new(0.2, hitRadius * 2, hitRadius * 2)
    end
})

PingPongTab:CreateParagraph({
    Title = "Tip",
    Content = "Recommended radius is 20 studs. - Lower/Higher Can = Not Accurate Hit. "
})

-------------------------------------------------
-- COUNTER TAB (new)
-------------------------------------------------
local CounterTab = Window:CreateTab("Counter", 0)

-- COUNTER VARIABLES
local autoCounter = false
local showCounterRadius = false
local counterRadius = 9 -- default changed to 9 as requested
local counterScanInterval = 0.12 -- slightly faster scan for quick detection
local counterScanAccumulator = 0

local lastCounterTime = 0
local counterCooldown = 6.2 -- default seconds cooldown (applies when button pressed)

-- staging value for slider (user changes this; it only applies when pressing button)
local stagedCounterCooldown = counterCooldown

-- SLAP animation id to detect
local SLAP_ANIM_ID = "rbxassetid://13526154547" -- exactly as requested

-- RADIUS VISUAL (counter)
local counterRadiusPart = Instance.new("Part")
counterRadiusPart.Name = "CounterRadius"
counterRadiusPart.Anchored = true
counterRadiusPart.CanCollide = false
counterRadiusPart.Transparency = 0.5
counterRadiusPart.Color = Color3.fromRGB(255, 0, 0)
counterRadiusPart.Material = Enum.Material.Neon
counterRadiusPart.Shape = Enum.PartType.Cylinder
counterRadiusPart.Size = Vector3.new(0.2, counterRadius * 2, counterRadius * 2)
counterRadiusPart.CFrame = CFrame.new(9e9, 9e9, 9e9)
counterRadiusPart.Parent = nil

-- COUNTER UI
CounterTab:CreateToggle({
    Name = "Auto Counter",
    CurrentValue = false,
    Flag = "AutoCounter",
    Callback = function(v)
        autoCounter = v
    end
})

CounterTab:CreateParagraph({
    Title = "Counters",
    Content = "Counters The Player's attacks\nAuto Counter Player's Slaps"
})

CounterTab:CreateToggle({
    Name = "Show Radius",
    CurrentValue = false,
    Flag = "ShowCounterRadius",
    Callback = function(v)
        showCounterRadius = v
        if v then
            counterRadiusPart.Parent = workspace
            if root and root.Position then
                counterRadiusPart.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, 0, math.rad(90))
            end
        else
            counterRadiusPart.CFrame = CFrame.new(9e9, 9e9, 9e9)
            counterRadiusPart.Parent = nil
        end
    end
})

-- radius slider: changed max to 15, default 9
CounterTab:CreateSlider({
    Name = "Auto Counter Radius",
    Range = {1, 15},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = counterRadius, -- default 9
    Flag = "CounterRadius",
    Callback = function(v)
        counterRadius = v
        counterRadiusPart.Size = Vector3.new(0.2, counterRadius * 2, counterRadius * 2)
    end
})

-- NEW: Adjust Cooldown slider (staged) 6 → 15 with 0.1 increments
CounterTab:CreateSlider({
    Name = "Adjust Cooldown (staged)",
    Range = {6, 15},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = stagedCounterCooldown,
    Flag = "AdjustCounterCooldownStaged",
    Callback = function(v)
        -- only change staged value; actual cooldown applies when button pressed
        stagedCounterCooldown = tonumber(string.format("%.1f", v)) or v
    end
})

-- Button to apply the staged cooldown
CounterTab:CreateButton({
    Name = "Change Cool Down Time",
    Callback = function()
        -- apply staged value to actual cooldown
        counterCooldown = stagedCounterCooldown
        -- no visible text; the HUD will show only when cooldown starts
    end
})

CounterTab:CreateParagraph({
    Title = "Tip",
    Content = "Recommended radius is 9 studs for counters."
})

-- =========================
-- NO TP BACK (RAGDOLL FIX)
-- =========================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local NoTpBack = false
local handling = false

-- tuning values
local STABLE_VELOCITY = 1
local STABLE_TIME = 0.25
local ANCHOR_TIME = 1

-- helper to anchor / unanchor
local function setAnchored(char, state)
	for _, part in ipairs(char:GetChildren()) do
		if part:IsA("BasePart") then
			part.Anchored = state
		end
	end
end

-- rebind on respawn
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")
	handling = false
end)

-- ORION TOGGLE
CounterTab:CreateToggle({
	Name = "No Tp Back",
	Default = false,
	Callback = function(v)
		NoTpBack = v
	end
})

-- main logic (single heartbeat, safe)
RunService.Heartbeat:Connect(function()
	if not NoTpBack then return end
	if handling then return end
	if not character or not humanoid or not root then return end

	local ragdolled =
		humanoid.PlatformStand
		or humanoid:GetState() == Enum.HumanoidStateType.Physics
		or humanoid:GetState() == Enum.HumanoidStateType.Ragdoll

	if not ragdolled then return end

	handling = true

	task.spawn(function()
		local stableTimer = 0

		while NoTpBack and humanoid and root do
			local velocity = root.AssemblyLinearVelocity.Magnitude

			if velocity <= STABLE_VELOCITY then
				stableTimer += RunService.Heartbeat:Wait()
				if stableTimer >= STABLE_TIME then
					break
				end
			else
				stableTimer = 0
				RunService.Heartbeat:Wait()
			end
		end

		if not NoTpBack or not character then
			handling = false
			return
		end

		-- anchor once fully stabilized
		setAnchored(character, true)
		task.wait(ANCHOR_TIME)
		setAnchored(character, false)

		handling = false
	end)
end)


-------------------------------------------------
-- HELPERS & RESPAWN REBIND
-------------------------------------------------
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")
    -- reload ping-pong animation
    animTrack = humanoid:LoadAnimation(anim)
end)

local function isPingPongBall(part)
    if not part then return false end
    if not part:IsA("BasePart") then return false end
    return string.find(part.Name, "PingPongBall") ~= nil
end

local function isPlayerInRange(targetRoot, range)
    if not targetRoot or not root then return false end
    local ok, pos = pcall(function() return targetRoot.Position end)
    if not ok or not pos then return false end
    return (pos - root.Position).Magnitude <= range
end

-------------------------------------------------
-- COOLDOWN HUD (top of screen, z-index 200)
-- Only visible while at least one cooldown is active
-------------------------------------------------
-- Create ScreenGui
local cooldownGui = Instance.new("ScreenGui")
cooldownGui.Name = "CooldownHUD"
cooldownGui.ResetOnSpawn = false
cooldownGui.DisplayOrder = 200
cooldownGui.Parent = playerGui

-- background/frame
local bg = Instance.new("Frame")
bg.Name = "CooldownBackground"
bg.AnchorPoint = Vector2.new(0.5, 0)
bg.Position = UDim2.new(0.5, 0, 0, 8) -- top center with small offset
bg.Size = UDim2.new(0, 380, 0, 36)
bg.BackgroundTransparency = 0.3
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.BorderSizePixel = 0
bg.ZIndex = 200
bg.Parent = cooldownGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = bg

-- text label
local cdLabel = Instance.new("TextLabel")
cdLabel.Name = "CooldownLabel"
cdLabel.AnchorPoint = Vector2.new(0.5, 0)
cdLabel.Position = UDim2.new(0.5, 0, 0, 4)
cdLabel.Size = UDim2.new(1, -12, 1, -8)
cdLabel.BackgroundTransparency = 1
cdLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
cdLabel.TextStrokeTransparency = 0.6
cdLabel.TextScaled = false
cdLabel.Font = Enum.Font.GothamBold -- nice clean font
cdLabel.TextSize = 20
cdLabel.Text = ""
cdLabel.ZIndex = 200
cdLabel.Parent = bg

-- optional small stroke for readability
local stroke = Instance.new("UIStroke")
stroke.Parent = bg
stroke.Transparency = 0.7
stroke.Thickness = 1
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- function to format seconds with 1 decimal (shows e.g. 6.1)
local function fmtSeconds(s)
    if s <= 0 then return "0.0" end
    return string.format("%.1f", s)
end

-- UI update loop (RenderStepped for smooth decimals)
RunService.RenderStepped:Connect(function(dt)
    local now = tick()
    local animRemaining = math.max(0, animationCooldown - (now - lastAnimTime))
    local counterRemaining = math.max(0, counterCooldown - (now - lastCounterTime))

    -- decide what to show; only show when at least one cooldown is active
    if animRemaining > 0 or counterRemaining > 0 then
        local parts = {}
        if animRemaining > 0 then
            table.insert(parts, ("Ping Pong CD: %ss"):format(fmtSeconds(animRemaining)))
        end
        if counterRemaining > 0 then
            table.insert(parts, ("Counter CD: %ss"):format(fmtSeconds(counterRemaining)))
        end
        cdLabel.Text = table.concat(parts, "   |   ")
        bg.Visible = true
    else
        bg.Visible = false
    end
end)

-------------------------------------------------
-- MAIN HEARTBEAT: handles both ping-pong and counter scans
-------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
    -- update visuals every frame for smoothness
    if showRadius and radiusPart.Parent and root then
        radiusPart.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, 0, math.rad(90))
    end
    if showCounterRadius and counterRadiusPart.Parent and root then
        counterRadiusPart.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, 0, math.rad(90))
    end

    ----------------------
    -- PING PONG SCAN
    ----------------------
    if autoHit and root then
        pingScanAccumulator = pingScanAccumulator + dt
        if pingScanAccumulator >= pingScanInterval then
            pingScanAccumulator = 0

            local now = tick()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if isPingPongBall(obj) then
                    local ok, pos = pcall(function() return obj.Position end)
                    if ok and pos and (pos - root.Position).Magnitude <= hitRadius then
                        -- Fire remote (ping pong) once per scan (no remote cooldown)
                        pcall(function()
                            local evt = ReplicatedStorage:FindFirstChild("PingPongEvent")
                            if evt and evt.FireServer then
                                evt:FireServer()
                            end
                        end)
                        -- play animation controlled by animation cooldown only
                        if animTrack and (now - lastAnimTime >= animationCooldown) then
                            if not animTrack.IsPlaying then
                                animTrack:Play()
                            end
                            lastAnimTime = now
                        end
                        break -- stop after first found (to reduce spamming)
                    end
                end
            end
        end
    end

    ----------------------
    -- COUNTER SCAN
    ----------------------
    if autoCounter and root then
        counterScanAccumulator = counterScanAccumulator + dt
        if counterScanAccumulator >= counterScanInterval then
            counterScanAccumulator = 0
            local now = tick()

            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character.Parent then
                    local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    if targetRoot and targetHumanoid and isPlayerInRange(targetRoot, counterRadius) then
                        local ok, tracks = pcall(function()
                            return targetHumanoid:GetPlayingAnimationTracks()
                        end)
                        if ok and tracks then
                            for _, track in ipairs(tracks) do
                                local animInst = track.Animation
                                if animInst and animInst.AnimationId and tostring(animInst.AnimationId) == SLAP_ANIM_ID then
                                    -- Found the slap animation playing from this player
                                    if now - lastCounterTime >= counterCooldown then
                                        pcall(function()
                                            local rem = ReplicatedStorage:FindFirstChild("Counter")
                                            if rem and rem.FireServer then
                                                rem:FireServer()
                                            end
                                        end)

                                        -- SAFETY: unanchor all BasePart children of the local player's character
                                        pcall(function()
                                            local char = character or player.Character
                                            if not char then return end
                                            for _, part in ipairs(char:GetChildren()) do
                                                if part and part:IsA("BasePart") then
                                                            wait(0.4)
                                                    part.Anchored = false
                                                end
                                            end
                                        end)

                                        lastCounterTime = now
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
