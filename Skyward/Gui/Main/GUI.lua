local VLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/vep1032/VepStuff/main/VL"))()

local Window = VLib:Window("VEP HUB", "My Script", "G")

local MainTab = Window:Tab("Main")

-- Button
MainTab:Button("Print Hello", function()
	print("Hello!")
end)

-- Toggle
MainTab:Toggle("Auto Farm", function(state)
	print("Auto Farm:", state)
end)

-- Slider
MainTab:Slider("WalkSpeed", 0, 100, 16, function(value)
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

-- Dropdown
MainTab:Dropdown("Select Mode", {"Easy", "Medium", "Hard"}, function(choice)
	print("Mode:", choice)
end)

-- Color Picker
MainTab:Colorpicker("ESP Color", Color3.fromRGB(255,0,0), function(color)
	print("Picked:", color)
end)

-- Textbox
MainTab:Textbox("Enter Name", true, function(text)
	print("You typed:", text)
end)

-- Label
MainTab:Label("Made by you 🔥")

-- Second tab
Window:Tab("Other")
