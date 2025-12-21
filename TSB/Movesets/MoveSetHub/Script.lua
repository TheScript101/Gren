-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "TSB Movesets",
    LoadingTitle = "TSB Movesets",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Create Saitama Tab with Image Icon
local SaitamaTab = Window:CreateTab("Saitama", 17761220757)

-- Example Button
SaitamaTab:CreateButton({
    Name = "Kars Moveset",
    Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/TSB/Movesets/Kars.txt"))()
      wait(1)
        Rayfield:Notify({
            Title = "Button Pressed",
            Content = "Executed! (TEMPORARY — dying disables the moveset. Re-execute to enable again.)",
            Duration = 5
        })
    end
})
