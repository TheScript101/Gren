-- Executor-ready: guaranteed 2 clicks per round; resets to 0 when player is in intermission box (dead)
-- Cancels only if player dies (enters box) or unequips 007n7 during waits.

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- CONFIG
local PRE_WAIT = 7            -- seconds before first click after conditions met
local DOUBLE_CHECK_TIME = 5   -- second to re-check conditions
local BETWEEN_WAIT = 1        -- seconds between first and second click
local CHECK_INTERVAL = 0.12
local INDICATOR_COUNT = 5
local INDICATOR_SPACING = 2
local INDICATOR_SHOW_TIME = 2
local FIXED_POS = Vector3.new(-3498.32, 31.77, 200.75)
local FIXED_SIZE = Vector3.new(316, 95, 288)

-- Internal state
local intermissionPart = nil
local isEquipped007 = false

-- Helper: robust HRP getter
local function getHRP()
    if not player then return nil end
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

-- Spawn visual indicators in front of player (quick preview)
local function spawnIndicators()
    local hrp = getHRP()
    local basePos, look
    if hrp and hrp.Parent then
        basePos = hrp.Position
        look = hrp.CFrame.LookVector
    else
        basePos = FIXED_POS
        look = Vector3.new(0,0,-1)
    end

    local indicators = {}
    for i = 1, INDICATOR_COUNT do
        local p = Instance.new("Part")
        p.Name = "IntermissionIndicator_" .. tostring(i)
        p.Size = Vector3.new(2,2,2)
        p.Anchored = true
        p.CanCollide = false
        p.Transparency = 0.35
        p.Material = Enum.Material.Neon
        p.Parent = workspace
        local dist = 3 + (i - 1) * INDICATOR_SPACING
        p.CFrame = CFrame.new(basePos + look * dist)
        table.insert(indicators, p)
    end

    task.wait(INDICATOR_SHOW_TIME)

    for _, v in ipairs(indicators) do
        if v and v.Parent then
            v:Destroy()
        end
    end
end

-- Create the real IntermissionChecker at the fixed coords
local function createIntermissionPartAtFixed()
    if intermissionPart and intermissionPart.Parent then
        intermissionPart:Destroy()
        intermissionPart = nil
    end
    local p = Instance.new("Part")
    p.Name = "IntermissionChecker"
    p.Size = FIXED_SIZE
    p.CFrame = CFrame.new(FIXED_POS)
    p.Anchored = true
    p.CanCollide = false
    p.Transparency = 1
    p.Locked = true
    p.Parent = workspace
    intermissionPart = p
    return p
end

-- Ensure intermission part exists: show indicators then create fixed part
local function ensureIntermissionPart()
    if intermissionPart and intermissionPart.Parent then
        return intermissionPart
    end
    -- show indicators in front of player so you can confirm placement
    spawnIndicators()
    -- after indicators, create the real part at fixed location
    return createIntermissionPartAtFixed()
end

-- Check if player HRP is inside the intermissionPart (AABB in part local space)
local function isPlayerInBox()
    if not player or not player.Character then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
               or player.Character:FindFirstChild("Torso")
               or player.Character:FindFirstChild("UpperTorso")
    if not hrp then return false end
    if not intermissionPart or not intermissionPart.Parent then
        return false
    end
    local relative = intermissionPart.CFrame:PointToObjectSpace(hrp.Position)
    local half = intermissionPart.Size * 0.5
    return math.abs(relative.X) <= half.X and math.abs(relative.Y) <= half.Y and math.abs(relative.Z) <= half.Z
end

-- Map exists check
local function mapExists()
    local mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return false end
    local ingame = mapFolder:FindFirstChild("Ingame")
    if not ingame then return false end
    return ingame:FindFirstChild("Map") ~= nil
end

-- Get Inject ImageButton safely
local function getInjectButton()
    local ok, gui = pcall(function() return player:WaitForChild("PlayerGui", 5) end)
    if not ok or not gui then return nil end
    local main = gui:FindFirstChild("MainUI")
    if not main then return nil end
    local cont = main:FindFirstChild("AbilityContainer")
    if not cont then return nil end
    local btn = cont:FindFirstChild("Inject")
    return btn
end

-- Click Inject imagebutton by firing its connected handlers (getconnections) or fallbacks
local function clickInjectButton()
    local btn = getInjectButton()
    if not btn then
        warn("Inject button not found")
        return false
    end

    local fired = false

    if typeof(getconnections) == "function" then
        local suc, conns = pcall(function() return getconnections(btn.MouseButton1Click) end)
        if suc and conns then
            for _, conn in pairs(conns) do
                pcall(function() conn:Fire() end)
            end
            fired = true
        end
    end

    if not fired then
        -- fallbacks: Activated handlers, :Activate, direct event fire
        pcall(function()
            if btn.Activated and typeof(getconnections) == "function" then
                local ok2, cs = pcall(function() return getconnections(btn.Activated) end)
                if ok2 and cs then
                    for _, c in pairs(cs) do pcall(function() c:Fire() end) end
                end
            end
        end)
        pcall(function() if btn.Activate then btn:Activate() end end)
        pcall(function() if btn.MouseButton1Click then btn.MouseButton1Click:Fire() end end)
        fired = true
    end

    return fired
end

-- Attempt to locate the Survivor value instance
local function tryGetSurvivorInstance()
    if not player then return nil end
    local pd = player:FindFirstChild("PlayerData") or player:FindFirstChild("playerdata")
    if not pd then
        local ok, inst = pcall(function() return player:WaitForChild("PlayerData", 6) end)
        if ok then pd = inst end
    end
    if not pd then return nil end
    local equipped = pd:FindFirstChild("Equipped") or pd:FindFirstChild("equipped")
    if not equipped then
        local ok, inst = pcall(function() return pd:WaitForChild("Equipped", 6) end)
        if ok then equipped = inst end
    end
    if not equipped then return nil end
    local surv = equipped:FindFirstChild("Survivor") or equipped:FindFirstChild("survivor")
    if not surv then
        local ok, inst = pcall(function() return equipped:WaitForChild("Survivor", 6) end)
        if ok then surv = inst end
    end
    return surv
end

-- Attach Changed listener for Survivor value (if exists), else fallback to polling
task.spawn(function()
    while true do
        local surv = tryGetSurvivorInstance()
        if surv then
            pcall(function() isEquipped007 = (surv.Value == "007n7") end)
            if surv.Changed then
                surv.Changed:Connect(function()
                    pcall(function() isEquipped007 = (surv.Value == "007n7") end)
                end)
                break
            end
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        local ok, val = pcall(function()
            local pd = player:FindFirstChild("PlayerData")
            if not pd then return nil end
            local equipped = pd:FindFirstChild("Equipped")
            if not equipped then return nil end
            local surv = equipped:FindFirstChild("Survivor")
            if not surv then return nil end
            return surv.Value
        end)
        if ok and val then
            isEquipped007 = (val == "007n7")
        else
            isEquipped007 = false
        end
        task.wait(0.8)
    end
end)

-- MAIN: create part with preview then loop checks
ensureIntermissionPart() -- shows indicators, then spawns real part at FIXED_POS

local firedThisRound = 0
local routineRunning = false

while true do
    task.wait(CHECK_INTERVAL)

    -- ensure part exists
    if not intermissionPart or not intermissionPart.Parent then
        createIntermissionPartAtFixed()
    end

    -- ALWAYS reset firedThisRound to 0 when player is inside the intermission box (death reset)
    if isPlayerInBox() then
        firedThisRound = 0
        routineRunning = false
    else
        -- Only proceed when equipped
        if not isEquipped007 then
            firedThisRound = 0
            routineRunning = false
        else
            local hasMap = mapExists()
            local inRound = hasMap and (not isPlayerInBox())

            -- start routine only once per round
            if inRound and firedThisRound == 0 and not routineRunning then
                routineRunning = true
                firedThisRound = 1 -- reserve

                task.spawn(function()
                    -- PRE_WAIT: wait 7 seconds, re-check at 5th second
                    local elapsed = 0
                    while elapsed < PRE_WAIT do
                        task.wait(0.1)
                        elapsed = elapsed + 0.1

                        if elapsed >= DOUBLE_CHECK_TIME then
                            -- recheck conditions at 5th second
                            if isPlayerInBox() or not isEquipped007 or not mapExists() then
                                firedThisRound = 0
                                routineRunning = false
                                return
                            end
                        end

                        if isPlayerInBox() or not isEquipped007 then
                            firedThisRound = 0
                            routineRunning = false
                            return
                        end
                    end

                    -- First click
                    pcall(clickInjectButton)

                    -- BETWEEN_WAIT
                    local e2 = 0
                    while e2 < BETWEEN_WAIT do
                        task.wait(0.1)
                        e2 = e2 + 0.1
                        if isPlayerInBox() or not isEquipped007 then
                            firedThisRound = 0
                            routineRunning = false
                            return
                        end
                    end

                    -- Second click
                    if not isPlayerInBox() and isEquipped007 then
                        pcall(clickInjectButton)
                        firedThisRound = 2
                    else
                        firedThisRound = 0
                    end

                    routineRunning = false
                end)
            end
        end
    end
end
