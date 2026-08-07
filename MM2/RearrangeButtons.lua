local p = game:GetService("Players").LocalPlayer
local gui = p:WaitForChild("PlayerGui")
local topbar = gui:WaitForChild("GameTopbar")
local container = topbar:WaitForChild("Container")

----------------------------------------------------------------
-- FORCE TOPBAR ABOVE ALL OTHER GUI
----------------------------------------------------------------
topbar.DisplayOrder = 9999999
topbar.IgnoreGuiInset = true  -- optional but helps keep it above core UI

----------------------------------------------------------------
-- MUTE
----------------------------------------------------------------
local mute = container:WaitForChild("Mute"):WaitForChild("Container")
mute.Position = UDim2.new(0, 50, 0, 0)

----------------------------------------------------------------
-- EMOTES
----------------------------------------------------------------
local emotes = container:WaitForChild("Emotes"):WaitForChild("Container")
emotes.Position = UDim2.new(0, -50, 0, 0)
emotes.Size = UDim2.new(1, 100, 1, 0)

----------------------------------------------------------------
-- SHIFTLOCK (MouseLock)
----------------------------------------------------------------
local mouseLock = container:WaitForChild("MouseLock"):WaitForChild("Container")
mouseLock.Position = UDim2.new(0, 508, 0, 305)
mouseLock.Size = UDim2.new(1, 25, 1, 25)

-- Optional: also force shiftlock itself above siblings
mouseLock.ZIndex = 9999999
for _, v in ipairs(mouseLock:GetDescendants()) do
    if v:IsA("GuiObject") then
        v.ZIndex = 9999999
    end
end
