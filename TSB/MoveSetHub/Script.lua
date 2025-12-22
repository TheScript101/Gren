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

-- Beerus Button
SaitamaTab:CreateButton({
    Name = "Beerus Moveset",
    Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/TSB/ConfigLoadstrings/GojoConfig"))()
      wait(1)
        Rayfield:Notify({
            Title = "Button Pressed",
            Content = "Executed! (TEMPORARY — dying disables the moveset. Re-execute to enable again.)",
            Duration = 5
        })
    end
})

-- Gojo Button
SaitamaTab:CreateButton({
    Name = "Gojo Moveset",
    Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/TSB/ConfigLoadstrings/GojoConfig"))()
      wait(1)
        Rayfield:Notify({
            Title = "Button Pressed",
            Content = "Executed! (TEMPORARY — dying disables the moveset. Re-execute to enable again.)",
            Duration = 5
        })
    end
})

-- Gojo Button
SaitamaTab:CreateButton({
    Name = "Goldenhead Moveset",
    Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/TSB/ConfigLoadstrings/GoldenHeadConfig"))()
      wait(1)
        Rayfield:Notify({
            Title = "Button Pressed",
            Content = "Executed! (TEMPORARY — dying disables the moveset. Re-execute to enable again.)",
            Duration = 5
        })
    end
})

-- Kars Button
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

-- Mafioso Button
SaitamaTab:CreateButton({
    Name = "Mafioso Moveset",
    Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/TSB/Movesets/Mafioso.txt"))()
      wait(1)
        Rayfield:Notify({
            Title = "Button Pressed",
            Content = "Executed! (TEMPORARY — dying disables the moveset. Re-execute to enable again.)",
            Duration = 5
        })
    end
})

-- Sukuna Button
SaitamaTab:CreateButton({
    Name = "Sukuna Moveset",
    Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/TSB/Movesets/Sukuna.txt"))()
      wait(1)
        Rayfield:Notify({
            Title = "Button Pressed",
            Content = "Executed! (TEMPORARY — dying disables the moveset. Re-execute to enable again.)",
            Duration = 5
        })
    end
})

-- Create Garou Tab with Image Icon
local GarouTab = Window:CreateTab("Garou", 17761223310)

-- Okarun Button
GarouTab:CreateButton({
    Name = "Okarun Moveset",
    Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/TSB/Movesets/Okarun.txt"))()
      wait(1)
        Rayfield:Notify({
            Title = "Button Pressed",
            Content = "Executed! (TEMPORARY — dying disables the moveset. Re-execute to enable again.)",
            Duration = 5
        })
    end
})

-- Sonic.Exe Button
GarouTab:CreateButton({
    Name = "Sonic.Exe Moveset",
    Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/TheScript101/Gren/refs/heads/main/TSB/Movesets/SonicEXE.txt"))()
      wait(1)
        Rayfield:Notify({
            Title = "Button Pressed",
            Content = "Executed! (TEMPORARY — dying disables the moveset. Re-execute to enable again.)",
            Duration = 5
        })
    end
})
