local WMacLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Wicikk/WMacLib/main/WMacLib.lua"))()

local Window = WMacLib:Window({
	Title = "Maclib Demo",
	Subtitle = "This is a subtitle.",
	Size = UDim2.fromOffset(568, 350),
	DragStyle = 1,
	DisabledWindowControls = {},
	ShowUserInfo = true,
	Keybind = Enum.KeyCode.RightControl,
	AcrylicBlur = true,
})

local globalSettings = {
	UIBlurToggle = Window:GlobalSetting({
		Name = "UI Blur",
		Default = Window:GetAcrylicBlurState(),
		Callback = function(bool)
			Window:SetAcrylicBlurState(bool)
			Window:Notify({
				Title = Window.Settings.Title,
				Description = (bool and "Enabled" or "Disabled") .. " UI Blur",
				Lifetime = 5
			})
		end,
	}),
	NotificationToggler = Window:GlobalSetting({
		Name = "Notifications",
		Default = Window:GetNotificationsState(),
		Callback = function(bool)
			Window:SetNotificationsState(bool)
			Window:Notify({
				Title = Window.Settings.Title,
				Description = (bool and "Enabled" or "Disabled") .. " Notifications",
				Lifetime = 5
			})
		end,
	}),
	ShowUserInfo = Window:GlobalSetting({
		Name = "Show User Info",
		Default = Window:GetUserInfoState(),
		Callback = function(bool)
			Window:SetUserInfoState(bool)
			Window:Notify({
				Title = Window.Settings.Title,
				Description = (bool and "Showing" or "Redacted") .. " User Info",
				Lifetime = 5
			})
		end,
	})
}

local tabGroups = {
	TabGroup1 = Window:TabGroup()
}

local tabs = {
	Main = tabGroups.TabGroup1:Tab({ Name = "Demo", Image = "lucide/layout-dashboard" }),
}
tabGroups.TabGroup1:Divider()
tabs.Misc = tabGroups.TabGroup1:Tab({ Name = "Misc", Image = "lucide/settings" })
tabs.Settings = tabGroups.TabGroup1:Tab({ Name = "Config", Image = "lucide/sliders-horizontal" })

local sections = {
	MainSection1 = tabs.Main:Section({}),
	MainSection2 = tabs.Main:Section({ Side = "Right" }),
}

sections.MainSection1:Header({
	Name = WMacLib:Gradient("Header #1", Color3.fromRGB(255, 180, 50), Color3.fromRGB(255, 80, 80))
})

sections.MainSection1:Button({
	Name = "Button",
	Callback = function()
		Window:Dialog({
			Title = Window.Settings.Title,
			Description = "Maclib Demo",
			Buttons = {
				{
					Name = "Confirm",
					Callback = function()
						print("Confirmed!")
					end,
				},
				{
					Name = "Cancel"
				}
			}
		})
	end,
})

sections.MainSection1:Input({
	Name = "Input",
	Placeholder = "Input",
	AcceptedCharacters = "All",
	Callback = function(input)
		Window:Notify({
			Title = Window.Settings.Title,
			Description = "Successfully set input to " .. input
		})
	end,
	onChanged = function(input)
		print("Input is now " .. input)
	end,
}, "Input")

local DemoSlider = sections.MainSection1:Slider({
	Name = "Slider",
	Default = 50,
	Minimum = 0,
	Maximum = 100,
	DisplayMethod = "Percent",
	Precision = 0,
	Callback = function(Value)
		print("Changed to ".. Value)
	end
}, "Slider")

sections.MainSection1:Toggle({
	Name = "Toggle",
	Default = false,
	Callback = function(value)
		Window:Notify({
			Title = Window.Settings.Title,
			Description = (value and "Enabled " or "Disabled ") .. "Toggle"
		})
	end,
}, "Toggle")

sections.MainSection1:Toggle({
	Name = '<font color="rgb(73, 230, 133)">Show Slider</font>',
	Default = true,
	Callback = function(value)
		DemoSlider:SetVisibility(value)
	end,
})

sections.MainSection1:Button({
	Name = "Bold Button",
	Bold = true,
	Callback = function() end,
})

sections.MainSection1:Toggle({
	Name = "Bold Toggle",
	Bold = true,
	Default = false,
	Callback = function() end,
})

sections.MainSection1:Label({
	Text = "Bold Label",
	Bold = true,
})

sections.MainSection1:Keybind({
	Name = "Keybind",
	Blacklist = false,
	Callback = function(binded)
		Window:Notify({
			Title = "Demo Window",
			Description = "Pressed keybind - "..tostring(binded.Name),
			Lifetime = 3
		})
	end,
	onBinded = function(bind)
		Window:Notify({
			Title = "Demo Window",
			Description = "Successfully Binded Keybind to - "..tostring(bind.Name),
			Lifetime = 3
		})
	end,
}, "Keybind")

sections.MainSection1:Colorpicker({
	Name = "Colorpicker",
	Default = Color3.fromRGB(0, 255, 255),
	Callback = function(color)
		print("Color: ", color)
	end,
}, "Colorpicker")

local alphaColorPicker = sections.MainSection1:Colorpicker({
	Name = "Transparency Colorpicker",
	Default = Color3.fromRGB(255,0,0),
	Alpha = 0,
	Callback = function(color, alpha)
		print("Color: ", color, " Alpha: ", alpha)
	end,
}, "TransparencyColorpicker")

local rainbowActive
local rainbowConnection
local hue = 0

sections.MainSection1:Toggle({
	Name = "Rainbow",
	Default = false,
	Callback = function(value)
		rainbowActive = value

		if rainbowActive then
			rainbowConnection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
				hue = (hue + deltaTime * 0.1) % 1
				alphaColorPicker:SetColor(Color3.fromHSV(hue, 1, 1))
			end)
		elseif rainbowConnection then
			rainbowConnection:Disconnect()
			rainbowConnection = nil
		end
	end,
}, "RainbowToggle")

local optionTable = {
	"Apple",
	"Banana",
	"Orange",
	"Grapes",
	"Pineapple",
	"Mango",
	"Strawberry",
	"Blueberry",
	"Watermelon",
	"Peach"
}

local Dropdown = sections.MainSection1:Dropdown({
	Name = "Dropdown",
	Multi = false,
	Required = true,
	Options = optionTable,
	Default = 1,
	Callback = function(Value)
		print("Dropdown changed: ".. Value)
	end,
}, "Dropdown")

local MultiDropdown = sections.MainSection1:Dropdown({
	Name = "Multi Dropdown",
	Search = true,
	Multi = true,
	Required = false,
	Options = optionTable,
	Default = {"Apple", "Orange"},
	Callback = function(Value)
		local Values = {}
		for Value, State in next, Value do
			table.insert(Values, Value)
		end
		print("Mutlidropdown changed:", table.concat(Values, ", "))
	end,
}, "MultiDropdown")

sections.MainSection1:Button({
	Name = "Update Selection",
	Callback = function()
		Dropdown:UpdateSelection("Grapes")
		MultiDropdown:UpdateSelection({"Banana", "Pineapple"})
	end,
})

sections.MainSection1:Header({
	Text = "Header #2"
})

sections.MainSection1:Paragraph({
	Header = "Paragraph",
	Body = "Paragraph body"
})

sections.MainSection1:SubLabel({
	Text = "Sub-Label"
})

local DemoLabel = sections.MainSection1:Label({
	Text = '<font color="rgb(73, 230, 133)">Label</font>'
})

sections.MainSection2:Header({
	Text = "Right Section"
})

sections.MainSection2:Toggle({
	Name = "Option A",
	Default = false,
	Callback = function(value) end,
})

sections.MainSection2:Toggle({
	Name = "Option B",
	Default = true,
	Callback = function(value) end,
})

sections.MainSection2:Slider({
	Name = "Value",
	Default = 50,
	Minimum = 0,
	Maximum = 100,
	DisplayMethod = "Percent",
	Precision = 0,
	Callback = function(value) end,
})

sections.MainSection2:Button({
	Name = "Right Button",
	Callback = function() end,
})

WMacLib:SetFolder("Maclib")

local watermark = WMacLib:Watermark({ Name = "Maclib Demo", Version = "v1.0.0" })

local fpsCount, elapsed = 0, 0
RunService.RenderStepped:Connect(function(dt)
	fpsCount += 1
	elapsed += dt
	if elapsed >= 0.5 then
		watermark:Set("FPS", math.round(fpsCount / elapsed) .. " fps")
		fpsCount = 0
		elapsed = 0
	end
end)

task.spawn(function()
	local subtitleText = "This is a subtitle."
	while not unloaded do
		for i = 1, #subtitleText do
			if unloaded then break end
			Window:SetSubtitle(WMacLib:Gradient(subtitleText:sub(1, i), {Color3.fromRGB(73, 230, 133), Color3.fromRGB(100, 150, 255), Color3.fromRGB(255, 100, 180)}))
			task.wait(0.08)
		end
		task.wait(1.5)
		for i = #subtitleText, 0, -1 do
			if unloaded then break end
			Window:SetSubtitle(WMacLib:Gradient(subtitleText:sub(1, i), {Color3.fromRGB(73, 230, 133), Color3.fromRGB(100, 150, 255), Color3.fromRGB(255, 100, 180)}))
			task.wait(0.04)
		end
		task.wait(0.5)
	end
end)

local miscSection = tabs.Misc:Section({})

miscSection:Dropdown({
	Name = "Theme",
	Options = WMacLib:GetThemes(),
	Callback = function(value)
		WMacLib:SetTheme(value)
	end,
})

miscSection:Slider({
	Name = "Window Size",
	Default = 50,
	Minimum = 0,
	Maximum = 100,
	DisplayMethod = "Percent",
	Precision = 0,
	Callback = function(value)
		local t = value / 100
		Window:SetSize(UDim2.fromOffset(400 + (1000 - 400) * t, 250 + (800 - 250) * t))
	end,
})

miscSection:Toggle({
	Name = "Lock Slider",
	Default = false,
	Callback = function(value)
		if value then
			DemoSlider:Lock()
		else
			DemoSlider:Unlock()
		end
	end,
})

miscSection:Toggle({
	Name = "User Info",
	Default = true,
	Callback = function(value)
		Window:SetUserInfoState(value)
	end,
})

miscSection:Toggle({
	Name = "Watermark",
	Default = true,
	Callback = function(value)
		watermark:SetVisible(value)
	end,
})

miscSection:Button({
	Name = "Destroy Watermark",
	Callback = function()
		watermark:Destroy()
	end,
})

miscSection:Button({
	Name = "Destroy Label",
	Callback = function()
		DemoLabel:Destroy()
	end,
})

miscSection:Input({
	Name = "Rename Label",
	Placeholder = "New label text...",
	AcceptedCharacters = "All",
	Callback = function(text)
		if text ~= "" then
			DemoLabel:SetName(text)
		end
	end,
})

miscSection:Button({
	Name = "Unload",
	Callback = function()
		Window:Unload()
	end,
})

tabs.Settings:InsertConfigSection()

Window.onUnloaded(function()
	print("Unloaded!")
end)

tabs.Main:Select()
WMacLib:LoadAutoLoadConfig()
