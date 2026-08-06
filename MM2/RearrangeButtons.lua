local p = game:GetService("Players").LocalPlayer
local gui = p:WaitForChild("PlayerGui")
local topbar = gui:WaitForChild("GameTopbar")
local container = topbar:WaitForChild("Container")

-- MUTE
local mute = container:WaitForChild("Mute"):WaitForChild("Container")
mute.Position = UDim2.new(0, 50, 0, 0)

-- EMOTES
local emotes = container:WaitForChild("Emotes"):WaitForChild("Container")
emotes.Position = UDim2.new(0, -50, 0, 0)
emotes.Size = UDim2.new(1, 100, 1, 0)

-- SHIFTLOCK (MouseLock)
local mouseLock = container:WaitForChild("MouseLock"):WaitForChild("Container")
mouseLock.Position = UDim2.new(0, 508, 0, 305)
mouseLock.Size = UDim2.new(1, 25, 1, 25)
