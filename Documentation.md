# Dox Library [V5]
This is a UI library for Roblox Hubs, it was developed in the LUA language.

## Name of Icons
You can see the name of each item in the [icon file](https://raw.githubusercontent.com/knownjs7/DoxLibV5/main/icons.lua).

## Booting the Library
```lua
local DoxLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/knownjs7/DoxLibV5/main/source.lua"))()
```

## Creating a Window
```lua
local Window = DoxLib:MakeWindow({
    Title = "DoxHub",
    SubTitle = "Thank you for using our Hub!",
    SaveFolder = "doxhub.lua"
})

--[[
Title = <string> - The title of the UI.
SubTitle = <string> - The secondary title of the UI.
SaveFolder = <string> - The secondary title of the UI. (You need the ".lua" at the end)
]]
```

## Creating a Tab
```lua
local Tab = Window:MakeTab({
    Title = "Main",
    Icon = "lucide-home"
})

--[[
Title = <string> - The title of the tab.
Icon = <string> - The icon of the tab.
]]
```

### Making an existing Tab invisible or visible
```lua
Tab:Visible(false) -- Invisible
Tab:Visible(true) -- Visible
```

## Creating a Section
```lua
local Section = Tab:AddSection({
    Name = "Section"
})

--[[
Title = <string> - The name of the section.
]]
```

### Changing the name of an existing section
```lua
Section:Set("New Section Text")
```

## Creating a Button
```lua
local Button = Tab:AddButton({
    Name = "Button",
    Callback = function()
      	print("Button pressed!")
    end
})

--[[
Name = <string> - The name of the button.
Callback = <function> - The function of the button.
]]
```

### Deleting an existing Button
```lua
Button:Destroy()
```

### Changing the callback of an existing Button
```lua
Button:Callback(function()) -- function
```

### Making an existing Button invisible or visible
```lua
Button:Visible(false) -- Invisible
Button:Visible(true) -- Visible
```

## Creating a Toggle
```lua
local Toggle = Tab:AddToggle({
    Name = "Toggle",
    Default = false,
    Callback = function(Value)
    	print(Value)
    end    
})

--[[
Name = <string> - The name of the toggle.
Default = <bool> - The default value of the toggle.
Callback = <function> - The function of the toggle.
]]
```

### Changing the value of an existing Toggle
```lua
Toggle:Set(true)
```

### Changing the callback of an existing Toggle
```lua
Toggle:Callback(function()) -- function
```

### Deleting an existing Toggle
```lua
Toggle:Destroy()
```

### Making an existing Toggle invisible or visible
```lua
Toggle:Visible(false) -- Invisible
Toggle:Visible(true) -- Visible
```

## Creating a Slider
```lua
Tab:AddSlider({
    Name = "Slider",
    Min = 1,
    Max = 10,
    Increase = 1,
    Default = 5,
    Callback = function(Value)
	    print(Value)
    end
})

--[[
Name = <string> - The name of the slider.
Min = <number> - The minimal value of the slider.
Max = <number> - The maxium value of the slider.
Increase = <number> - How much the slider will change value when dragging.
Default = <number> - The default value of the slider.
Callback = <function> - The function of the slider.
]]
```

## Creating a Paragraph
```lua
local Paragraph = Tab:AddParagraph({
    Title = "Paragraph",
    Text = "This is a paragraph"
})

--[[
Title = <string> - The title of the paragraph.
Text = <string> - The secondary text of the paragraph.
]]
```

### Changing an existing paragraph
```lua
Paragraph:Set({Title = "Edited Paragraph", Text = "This is a edited paragraph"}) -- title + text (optional)
```

## Creating an Adaptive Input
```lua
Tab:AddTextbox({
    Name = "Textbox",
    Description = "This is a Textbox",
    Default = "default box input",
    PlaceholderText = "Insert here",
    ClearText = false,
    Callback = function(Value)
    	print(Value)
    end
})

--[[
Name = <string> - The name of the textbox.
Description = <string> - The description of the textbox.
Default = <string> - The default value of the textbox.
PlaceholderText = <string> - The placeholder of the textbox.
ClearText = <string> - Makes the text disappear in the textbox after losing focus.
Callback = <function> - The function of the textbox.
]]
```

## Creating a Dropdown menu
```lua
local Dropdown = Tab:AddDropdown({
    Name = "Dropdown",
    Description = "This is a Dropdown",
    Options = {"Option 1", "Option 2"},
    Default = "Option 1",
    Callback = function(Value)
    	print(Value)
    end    
})

--[[
Name = <string> - The name of the dropdown.
Description = <string> - The description of the dropdown.
Options = <table> - The options in the dropdown.
Default = <string> - The default value of the dropdown.
Callback = <function> - The function of the dropdown.
]]
```

### Making an existing dropdown menu invisible or visible
```lua
Dropdown:Visible(false) -- Invisible
Dropdown:Visible(true) -- Visible
```

### Deleting an existing dropdown menu
```lua
Dropdown:Destroy()
```

### Adding a set of new Dropdown buttons to an existing dropdown menu
```lua
Dropdown:Add({"Option 3", "Option 4"})
```

### Removing an option by name from an existing dropdown menu
```lua
Dropdown:Remove("Option 4")
```

### Selecting an option by name from an existing dropdown menu
```lua
Dropdown:Select("Option 4")
```

### Changing the value of an existing dropdown menu
```lua
Dropdown:Set("Option 4")
```

## Creating a Discord Invite
```lua
Tab:AddDiscordInvite({
    Name = "Piratas Community",
    Description = "This is the community discord",
    Logo = "rbxassetid://17736869189",
    Invite = "https://discord.gg/RDNmeeYvGb"  
})

--[[
Name = <string> - The name of the discord.
Description = <string> - The description of the discord.
Logo = <string> - The icon ID of the discord.
Invite = <string> - The invite URL of the discord.
]]
```

## 🔌 Project Credits
This UI library (apparently, as I couldn't find sources), was developed by programmer [REDzHUB](https://github.com/REDzHUB/).

## 📚 Documentation Credits
Documentation entirely created by [KnowNjs](https://github.com/knownjs7).
