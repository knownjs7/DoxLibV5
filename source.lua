local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerMouse = Player:GetMouse()

local doxlib = {
  Themes = {
    Darker = {
      ["Color Hub 1"] = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(25, 25, 25)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(32.5, 32.5, 32.5)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(25, 25, 25))
      }),
      ["Color Hub 2"] = Color3.fromRGB(30, 30, 30),
      ["Color Stroke"] = Color3.fromRGB(40, 40, 40),
      ["Color Theme"] = Color3.fromRGB(88, 101, 242),
      ["Color Text"] = Color3.fromRGB(243, 243, 243),
      ["Color Dark Text"] = Color3.fromRGB(180, 180, 180)
    },
    Dark = {
      ["Color Hub 1"] = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 40)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(47.5, 47.5, 47.5)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(40, 40, 40))
      }),
      ["Color Hub 2"] = Color3.fromRGB(45, 45, 45),
      ["Color Stroke"] = Color3.fromRGB(65, 65, 65),
      ["Color Theme"] = Color3.fromRGB(65, 150, 255),
      ["Color Text"] = Color3.fromRGB(245, 245, 245),
      ["Color Dark Text"] = Color3.fromRGB(190, 190, 190)
    },
    Purple = {
      ["Color Hub 1"] = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(27.5, 25, 30)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(32.5, 32.5, 32.5)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(27.5, 25, 30))
      }),
      ["Color Hub 2"] = Color3.fromRGB(30, 30, 30),
      ["Color Stroke"] = Color3.fromRGB(40, 40, 40),
      ["Color Theme"] = Color3.fromRGB(150, 0, 255),
      ["Color Text"] = Color3.fromRGB(240, 240, 240),
      ["Color Dark Text"] = Color3.fromRGB(180, 180, 180)
    }
  },
  Info = {
    Version = "1.0.2",
    PlaceName = MarketplaceService:GetProductInfo(game.PlaceId).Name
  },
  Save = {
    UISize = {550, 380},
    TabSize = 160,
    Theme = "Darker"
  },
  Instances = {},
  Elements = {},
  Options = {},
  Flags = {},
  Tabs = {},
  Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/knownjs7/DoxLibV5/main/icons.lua"))()
}

local ViewportSize = workspace.CurrentCamera.ViewportSize
local UIScale = ViewportSize.Y / 450

local SetProps, SetChildren, InsertTheme, Create do
  InsertTheme = function(Instance, Type)
    table.insert(doxlib.Instances, {
      Instance = Instance,
      Type = Type
    })
    return Instance
  end
  
  SetChildren = function(Instance, Children)
    if Children then
      table.foreach(Children, function(_,Child)
        Child.Parent = Instance
      end)
    end
    return Instance
  end
  
  SetProps = function(Instance, Props)
    if Props then
      table.foreach(Props, function(prop, value)
        Instance[prop] = value
      end)
    end
    return Instance
  end
  
  Create = function(...)
    local args = {...}
    if type(args) ~= "table" then return end
    local new = Instance.new(args[1])
    local Children = {}
    
    if type(args[2]) == "table" then
      SetProps(new, args[2])
      SetChildren(new, args[3])
      Children = args[3] or {}
    elseif typeof(args[2]) == "Instance" then
      new.Parent = args[2]
      SetProps(new, args[3])
      SetChildren(new, args[4])
      Children = args[4] or {}
    end
    return new
  end
  
  local function Save(file)
    if readfile and isfile and isfile(file) then
      local decode = HttpService:JSONDecode(readfile(file))
      
      if type(decode) == "table" then
        if rawget(decode, "UISize") then doxlib.Save["UISize"] = decode["UISize"] end
        if rawget(decode, "TabSize") then doxlib.Save["TabSize"] = decode["TabSize"] end
        if rawget(decode, "Theme") and VerifyTheme(decode["Theme"]) then doxlib.Save["Theme"] = decode["Theme"] end
      end
    end
  end
  
  local success, debug = pcall(Save, "dox library V5.lua")
  
  if not success then
    warn(debug)
  end
end

local ScreenGui = Create("ScreenGui", CoreGui, {
  Name = "dox Library V5",
}, {
  Create("UIScale", {
    Scale = UIScale,
    Name = "Scale"
  })
})

local ScreenFind = CoreGui:FindFirstChild(ScreenGui.Name)
if ScreenFind and ScreenFind ~= ScreenGui then
  ScreenFind:Destroy()
end

local function ConnectSave(Instance, func)
  Instance.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
      while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
      end
    end
    func()
  end)
end

local function CreateTween(Configs)
  local Instance = Configs[1] or Configs.Instance
  local Prop = Configs[2] or Configs.Prop
  local NewVal = Configs[3] or Configs.NewVal
  local Time = Configs[4] or Configs.Time or 0.5
  local TweenWait = Configs[5] or Configs.wait or false
  local TweenInfo = TweenInfo.new(Time, Enum.EasingStyle.Quint)
  
  local Tween = TweenService:Create(Instance, TweenInfo, {[Prop] = NewVal})
  Tween:Play()
  if TweenWait then
    Tween.Completed:Wait()
  end
  return Tween
end

local function MakeDrag(Instance)
  task.spawn(function()
    SetProps(Instance, {
      Active = true,
      AutoButtonColor = false
    })
    
		local DragStart, StartPos, InputOn
		
		local function Update(Input)
			local delta = Input.Position - DragStart
			local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X / UIScale, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y / UIScale)
			-- Instance.Position = Position
			CreateTween({Instance, "Position", Position, 0.35})
		end
		
		Instance.MouseButton1Down:Connect(function()
		  InputOn = true
		end)
		
    Instance.InputBegan:Connect(function(Input)
      if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        StartPos = Instance.Position
        DragStart = Input.Position
        
        while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do RunService.Heartbeat:Wait()
          if InputOn then
            Update(Input)
          end
        end
        InputOn = false
      end
    end)
	end)
	return Instance
end

local function VerifyTheme(Theme)
  for name,_ in pairs(doxlib.Themes) do
    if name == Theme then
      return true
    end
  end
end

local function SaveJson(FileName, save)
  if writefile then
    local json = HttpService:JSONEncode(save)
    writefile(FileName, json)
  end
end

local Theme = doxlib.Themes[doxlib.Save.Theme]

local function AddEle(Name, Func)
  doxlib.Elements[Name] = Func
end

local function Make(Ele, Instance, props, ...)
  local Element = doxlib.Elements[Ele](Instance, props, ...)
  return Element
end

AddEle("Corner", function(parent, CornerRadius)
  local New = SetProps(Create("UICorner", parent, {
    CornerRadius = CornerRadius or UDim.new(0, 7)
  }), props)
  return New
end)

AddEle("Stroke", function(parent, props, ...)
  local args = {...}
  local New = InsertTheme(SetProps(Create("UIStroke", parent, {
    Color = args[1] or Theme["Color Stroke"],
    Thickness = args[2] or 1,
    ApplyStrokeMode = "Border"
  }), props), "Stroke")
  return New
end)

AddEle("Button", function(parent, props, ...)
  local args = {...}
  local New = InsertTheme(SetProps(Create("TextButton", parent, {
    Text = "",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Theme["Color Hub 2"],
    AutoButtonColor = false
  }), props), "Frame")
  
  New.MouseEnter:Connect(function()
    New.BackgroundTransparency = 0.4
  end)
  New.MouseLeave:Connect(function()
    New.BackgroundTransparency = 0
  end)
  if args[1] then
    New.Activated:Connect(args[1])
  end
  return New
end)

AddEle("Gradient", function(parent, props, ...)
  local args = {...}
  local New = InsertTheme(SetProps(Create("UIGradient", parent, {
    Color = Theme["Color Hub 1"]
  }), props), "Gradient")
  return New
end)

local function ButtonFrame(Instance, Title, Description, HolderSize)
  local TitleL = InsertTheme(Create("TextLabel", {
    Font = Enum.Font.GothamMedium,
    TextColor3 = Theme["Color Text"],
    Size = UDim2.new(1, -20),
    AutomaticSize = "Y",
    Position = UDim2.new(0, 0, 0.5),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1,
    TextTruncate = "AtEnd",
    TextSize = 10,
    TextXAlignment = "Left",
    Text = "",
    RichText = true
  }), "Text")
  
  local DescL = InsertTheme(Create("TextLabel", {
    Font = Enum.Font.Gotham,
    TextColor3 = Theme["Color Dark Text"],
    Size = UDim2.new(1, -20),
    AutomaticSize = "Y",
    Position = UDim2.new(0, 12, 0, 15),
    BackgroundTransparency = 1,
    TextWrapped = true,
    TextSize = 8,
    TextXAlignment = "Left",
    Text = "",
    RichText = true
  }), "DarkText")

  local Frame = Make("Button", Instance, {
    Size = UDim2.new(1, 0, 0, 25),
    AutomaticSize = "Y",
    Name = "Option"
  })Make("Corner", Frame, UDim.new(0, 6))
  
	LabelHolder = Create("Frame", Frame, {
		AutomaticSize = "Y",
		BackgroundTransparency = 1,
		Size = HolderSize,
		Position = UDim2.new(0, 10, 0),
		AnchorPoint = Vector2.new(0, 0)
	}, {
		Create("UIListLayout", {
			SortOrder = "LayoutOrder",
			VerticalAlignment = "Center",
			Padding = UDim.new(0, 2)
		}),
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 5)
		}),
		TitleL,
		DescL,
	})
  
  local Label = {}
  function Label:SetTitle(NewTitle)
    if type(NewTitle) == "string" and NewTitle:gsub(" ", ""):len() > 0 then
      TitleL.Text = NewTitle
    end
  end
  function Label:SetDesc(NewDesc)
    if type(NewDesc) == "string" and NewDesc:gsub(" ", ""):len() > 0 then
      DescL.Visible = true
      DescL.Text = NewDesc
      LabelHolder.Position = UDim2.new(0, 10, 0)
      LabelHolder.AnchorPoint = Vector2.new(0, 0)
    else
      DescL.Visible = false
      DescL.Text = ""
      LabelHolder.Position = UDim2.new(0, 10, 0.5)
      LabelHolder.AnchorPoint = Vector2.new(0, 0.5)
    end
  end
  
  Label:SetTitle(Title)
  Label:SetDesc(Description)
  return Frame, Label
end

local function GetColor(Instance)
  if Instance:IsA("Frame") then
    return "BackgroundColor3"
  elseif Instance:IsA("ImageLabel") then
    return "ImageColor3"
  elseif Instance:IsA("TextLabel") then
    return "TextColor3"
  elseif Instance:IsA("ScrollingFrame") then
    return "ScrollBarImageColor3"
  elseif Instance:IsA("UIStroke") then
    return "Color"
  end
  return ""
end

-- /////////// --
function doxlib:GetIcon(IconName)
  if IconName:find("rbxassetid://") or IconName:len() < 1 then return IconName end
  IconName = IconName:lower():gsub("lucide", ""):gsub("-", "")
  
  for Name, Icon in pairs(doxlib.Icons) do
    Name = Name:gsub("lucide", ""):gsub("-", "")
    if Name == IconName then
      return Icon
    end
  end
  for Name, Icon in pairs(doxlib.Icons) do
    Name = Name:gsub("lucide", ""):gsub("-", "")
    if Name:find(IconName) then
      return Icon
    end
  end
  return IconName
end

function doxlib:SetTheme(NewTheme)
  if not VerifyTheme(NewTheme) then return end
  
  doxlib.Save.Theme = NewTheme
  SaveJson("dox library V5.lua", doxlib.Save)
  Theme = doxlib.Themes[NewTheme]
  
  table.foreach(doxlib.Instances, function(_,Val)
    if Val.Type == "Gradient" then
      Val.Instance.Color = Theme["Color Hub 1"]
    elseif Val.Type == "Frame" then
      Val.Instance.BackgroundColor3 = Theme["Color Hub 2"]
    elseif Val.Type == "Stroke" then
      Val.Instance[GetColor(Val.Instance)] = Theme["Color Stroke"]
    elseif Val.Type == "Theme" then
      Val.Instance[GetColor(Val.Instance)] = Theme["Color Theme"]
    elseif Val.Type == "Text" then
      Val.Instance[GetColor(Val.Instance)] = Theme["Color Text"]
    elseif Val.Type == "DarkText" then
      Val.Instance[GetColor(Val.Instance)] = Theme["Color Dark Text"]
    elseif Val.Type == "ScrollBar" then
      Val.Instance[GetColor(Val.Instance)] = Theme["Color Theme"]
    end
  end)
end

function doxlib:SetScale(NewScale)
  NewScale = ViewportSize.Y / math.clamp(NewScale, 300, 2000)
  UIScale, ScreenGui.Scale.Scale = NewScale, NewScale
end

function doxlib:MakeWindow(Configs)
  local WTitle = Configs[1] or Configs.Name or Configs.Title or "dox Library V5"
  local WMiniText = Configs[2] or Configs.SubTitle or "by : known.js"
  local SaveCfg = Configs[3] or Configs.SaveFolder or false
  local SaveRejoin = Configs[4] or Configs.SaveRejoin or false
  local Flags = doxlib.Flags
  
  if SaveCfg and type(SaveCfg) == "string" then SaveCfg = string.gsub(SaveCfg, "/", "|")end
  
  local LastTick = tick()
  local function SaveFile(Name, Value)
    if writefile then
      if SaveCfg and type(SaveCfg) == "string" then
        Flags[Name] = Value
        
        local encode = HttpService:JSONEncode(Flags)
        
        pcall(writefile, SaveCfg, encode)
      end
    end
  end
  
  local function LoadFile()
    if SaveCfg and type(SaveCfg) == "string" then
      if readfile and isfile and isfile(SaveCfg) then
        local success, Src = pcall(readfile, SaveCfg)
        
        if success and type(Src) == "string" then
          Src = HttpService:JSONDecode(Src)
          
          if type(Src) == "table" then
            Flags = Src
          end
        end
      end
    end
  end;LoadFile()
  
  local UISizeX, UISizeY = unpack(doxlib.Save.UISize)
  local MainFrame = InsertTheme(Create("ImageButton", ScreenGui, {
    Size = UDim2.fromOffset(UISizeX, UISizeY),
    Position = UDim2.new(0.5, -UISizeX/2, 0.5, -UISizeY/2),
    BackgroundTransparency = 0.03,
    Name = "Hub"
  }), "Main")Make("Gradient", MainFrame, {
    Rotation = 45
  })MakeDrag(MainFrame)
  
  local MainCorner = Make("Corner", MainFrame)
  
  local Components = Create("Folder", MainFrame, {
    Name = "Components"
  })
  
  local DropdownHolder = Create("Folder", ScreenGui, {
    Name = "Dropdown"
  })
  
  local TopBar = Create("Frame", Components, {
    Size = UDim2.new(1, 0, 0, 28),
    BackgroundTransparency = 1,
    Name = "Top Bar"
  })
  
  local Title = InsertTheme(Create("TextLabel", TopBar, {
    Position = UDim2.new(0, 15, 0.5),
    AnchorPoint = Vector2.new(0, 0.5),
    AutomaticSize = "XY",
    Text = WTitle,
    TextXAlignment = "Left",
    TextSize = 12,
    TextColor3 = Theme["Color Text"],
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamMedium,
    Name = "Title"
  }, {
    InsertTheme(Create("TextLabel", {
      Size = UDim2.fromScale(0, 1),
      AutomaticSize = "X",
      AnchorPoint = Vector2.new(0, 1),
      Position = UDim2.new(1, 5, 0.9),
      Text = WMiniText,
      TextColor3 = Theme["Color Dark Text"],
      BackgroundTransparency = 1,
      TextXAlignment = "Left",
      TextYAlignment = "Bottom",
      TextSize = 8,
      Font = Enum.Font.Gotham,
      Name = "SubTitle"
    }), "DarkText")
  }), "Text")
  
  local MainScroll = InsertTheme(Create("ScrollingFrame", Components, {
    Size = UDim2.new(0, doxlib.Save.TabSize, 1, -TopBar.Size.Y.Offset),
    ScrollBarImageColor3 = Theme["Color Theme"],
    Position = UDim2.new(0, 0, 1, 0),
    AnchorPoint = Vector2.new(0, 1),
    ScrollBarThickness = 1.5,
    BackgroundTransparency = 1,
    ScrollBarImageTransparency = 0.2,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = "Y",
    ScrollingDirection = "Y",
    BorderSizePixel = 0,
    Name = "Tab Scroll"
  }, {
    Create("UIPadding", {
      PaddingLeft = UDim.new(0, 10),
      PaddingRight = UDim.new(0, 10),
      PaddingTop = UDim.new(0, 10),
      PaddingBottom = UDim.new(0, 10)
    }), Create("UIListLayout", {
      Padding = UDim.new(0, 5)
    })
  }), "ScrollBar")
  
  local Containers = Create("Frame", Components, {
    Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset),
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Name = "Containers"
  })
  
  local ControlSize1, ControlSize2 = MakeDrag(Create("ImageButton", MainFrame, {
    Size = UDim2.new(0, 35, 0, 35),
    Position = MainFrame.Size,
    Active = true,
    AnchorPoint = Vector2.new(0.8, 0.8),
    BackgroundTransparency = 1,
    Name = "Control Hub Size"
  })), MakeDrag(Create("ImageButton", MainFrame, {
    Size = UDim2.new(0, 20, 1, -30),
    Position = UDim2.new(0, MainScroll.Size.X.Offset, 1, 0),
    AnchorPoint = Vector2.new(0.5, 1),
    Active = true,
    BackgroundTransparency = 1,
    Name = "Control Tab Size"
  }))
  
  local function ControlSize()
    local Pos1, Pos2 = ControlSize1.Position, ControlSize2.Position
    ControlSize1.Position = UDim2.fromOffset(math.clamp(Pos1.X.Offset, 430, 1000), math.clamp(Pos1.Y.Offset, 200, 500))
    ControlSize2.Position = UDim2.new(0, math.clamp(Pos2.X.Offset, 135, 250), 1, 0)
    
    MainScroll.Size = UDim2.new(0, ControlSize2.Position.X.Offset, 1, -TopBar.Size.Y.Offset)
    Containers.Size = UDim2.new(1, -MainScroll.Size.X.Offset, 1, -TopBar.Size.Y.Offset)
    MainFrame.Size = ControlSize1.Position
  end
  
  ControlSize1:GetPropertyChangedSignal("Position"):Connect(ControlSize)
  ControlSize2:GetPropertyChangedSignal("Position"):Connect(ControlSize)
  
  ConnectSave(ControlSize1, function()
    if not Minimized then
      doxlib.Save.UISize = {MainFrame.Size.X.Offset, MainFrame.Size.Y.Offset}
      SaveJson("dox library V5.lua", doxlib.Save)
    end
  end)
  
  ConnectSave(ControlSize2, function()
    doxlib.Save.TabSize = MainScroll.Size.X.Offset
    SaveJson("dox library V5.lua", doxlib.Save)
  end)
  
  local ButtonsFolder = Create("Folder", TopBar, {
    Name = "Buttons"
  })
  
  local CloseButton = Create("ImageButton", {
    Size = UDim2.new(0, 14, 0, 14),
    Position = UDim2.new(1, -10, 0.5),
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundTransparency = 1,
    Image = "rbxassetid://10747384394",
    AutoButtonColor = false,
    Name = "Close"
  })
  
  local MinimizeButton = SetProps(CloseButton:Clone(), {
    Position = UDim2.new(1, -35, 0.5),
    Image = "rbxassetid://10734896206",
    Name = "Minimize"
  })
  
  SetChildren(ButtonsFolder, {
    CloseButton,
    MinimizeButton
  })
  
  local Minimized, SaveSize, WaitClick
  local Window, FirstTab = {}, false
  function Window:CloseBtn()
    local Dialog = Window:Dialog({
      Title = "Close",
      Text = "Are you sure you want to close this script??",
      Options = {
        {"Confirm", function()
          ScreenGui:Destroy()
        end},
        {"Cancel"}
      }
    })
  end
  function Window:MinimizeBtn()
    if WaitClick then return end
    WaitClick = true
    
    if Minimized then
      MinimizeButton.Image = "rbxassetid://10734896206"
      CreateTween({MainFrame, "Size", SaveSize, 0.25, true})
      ControlSize1.Visible = true
      ControlSize2.Visible = true
      Minimized = false
    else
      MinimizeButton.Image = "rbxassetid://10734924532"
      SaveSize = MainFrame.Size
      ControlSize1.Visible = false
      ControlSize2.Visible = false
      CreateTween({MainFrame, "Size", UDim2.fromOffset(MainFrame.Size.X.Offset, 28), 0.25, true})
      Minimized = true
    end
    
    WaitClick = false
  end
  function Window:Minimize()
    MainFrame.Visible = not MainFrame.Visible
  end
  function Window:AddMinimizeButton(Configs)
    local Button = MakeDrag(Create("ImageButton", ScreenGui, {
      Size = UDim2.fromOffset(35, 35),
      Position = UDim2.fromScale(0.15, 0.15),
      BackgroundTransparency = 1,
      BackgroundColor3 = Theme["Color Hub 2"],
      AutoButtonColor = false
    }))
    
    local Stroke, Corner
    if Configs.Corner then
      Corner = Make("Corner", Button)
      SetProps(Corner, Configs.Corner)
    end
    if Configs.Stroke then
      Stroke = Make("Stroke", Button)
      SetProps(Stroke, Configs.Corner)
    end
    
    SetProps(Button, Configs.Button)
    Button.Activated:Connect(Window.Minimize)
    
    return {
      Stroke = Stroke,
      Corner = Corner,
      Button = Button
    }
  end
  function Window:Set(Val1, Val2)
    if type(Val1) == "string" and type(Val2) == "string" then
      Title.Text = Val1
      Title.SubTitle.Text = Val2
    elseif type(Val1) == "string" then
      Title.Text = Val1
    end
  end
  function Window:Dialog(Configs)
    if MainFrame:FindFirstChild("Dialog") then return end
    if Minimized then
      Window:MinimizeBtn()
    end
    
    local DTitle = Configs[1] or Configs.Title or "Dialog"
    local DText = Configs[2] or Configs.Text or "This is a Dialog"
    local DOptions = Configs[3] or Configs.Options or {}
    
    local Frame = Create("Frame", {
      Active = true,
      Size = UDim2.fromOffset(250 * 1.08, 150 * 1.08),
      Position = UDim2.fromScale(0.5, 0.5),
      AnchorPoint = Vector2.new(0.5, 0.5)
    }, {
      InsertTheme(Create("TextLabel", {
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(1, 0, 0, 20),
        Text = DTitle,
        TextXAlignment = "Left",
        TextColor3 = Theme["Color Text"],
        TextSize = 15,
        Position = UDim2.fromOffset(15, 5),
        BackgroundTransparency = 1
      }), "Text"),
      InsertTheme(Create("TextLabel", {
        Font = Enum.Font.GothamMedium,
        Size = UDim2.new(1, -25),
        AutomaticSize = "Y",
        Text = DText,
        TextXAlignment = "Left",
        TextColor3 = Theme["Color Dark Text"],
        TextSize = 12,
        Position = UDim2.fromOffset(15, 25),
        BackgroundTransparency = 1,
        TextWrapped = true
      }), "DarkText")
    })Make("Gradient", Frame, {Rotation = 270})Make("Corner", Frame)
    
    local ButtonsHolder = Create("Frame", Frame, {
      Size = UDim2.fromScale(1, 0.35),
      Position = UDim2.fromScale(0, 1),
      AnchorPoint = Vector2.new(0, 1),
      BackgroundColor3 = Theme["Color Hub 2"],
      BackgroundTransparency = 1
    }, {
      Create("UIListLayout", {
        Padding = UDim.new(0, 10),
			  VerticalAlignment = "Center",
			  FillDirection = "Horizontal",
			  HorizontalAlignment = "Center"
      })
    })
    
    local Screen = InsertTheme(Create("Frame", MainFrame, {
      BackgroundTransparency = 0.6,
      Active = true,
      BackgroundColor3 = Theme["Color Hub 2"],
      Size = UDim2.new(1, 0, 1, 0),
      BackgroundColor3 = Theme["Color Stroke"],
      Name = "Dialog"
    }), "Stroke")
    
    MainCorner:Clone().Parent = Screen
    Frame.Parent = Screen
    CreateTween({Frame, "Size", UDim2.fromOffset(250, 150), 0.2})
    CreateTween({Frame, "Transparency", 0, 0.15})
    CreateTween({Screen, "Transparency", 0.3, 0.15})
    
    local ButtonCount, Dialog = 1, {}
    function Dialog:Button(Configs)
      local Name = Configs[1] or Configs.Name or Configs.Title or ""
      local Callback = Configs[2] or Configs.Callback or function()end
      
      ButtonCount = ButtonCount + 1
      local Button = Make("Button", ButtonsHolder)
      Make("Corner", Button)
      SetProps(Button, {
        Text = Name,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme["Color Text"],
        TextSize = 12
      })
      
      for _,Button in pairs(ButtonsHolder:GetChildren()) do
        if Button:IsA("TextButton") then
          Button.Size = UDim2.new(1 / ButtonCount, -(((ButtonCount - 1) * 20) / ButtonCount), 0, 32) -- Fluent Library :)
        end
      end
      Button.Activated:Connect(Dialog.Close)
      Button.Activated:Connect(Callback)
    end
    function Dialog:Close()
      CreateTween({Frame, "Size", UDim2.fromOffset(250 * 1.08, 150 * 1.08), 0.2})
      CreateTween({Screen, "Transparency", 1, 0.15})
      CreateTween({Frame, "Transparency", 1, 0.15, true})
      Screen:Destroy()
    end
    table.foreach(DOptions, function(_,Button)
      Dialog:Button(Button)
    end)
    return Dialog
  end
  function Window:SelectTab(TabSelect)
    if type(TabSelect) == "number" then
      doxlib.Tabs[TabSelect].func:Enable()
    else
      for _,Tab in pairs(doxlib.Tabs) do
        if Tab.Cont == TabSelect.Cont then
          Tab.func:Enable()
        end
      end
    end
  end
  function Window:MakeTab(paste, Configs)
    if type(paste) == "table" then Configs = paste end
    local TName = Configs[1] or Configs.Title or "Tab!"
    local TIcon = Configs[2] or Configs.Icon or ""
    
    TIcon = doxlib:GetIcon(TIcon)
    if not TIcon:find("rbxassetid://") or TIcon:gsub("rbxassetid://", ""):len() < 6 then
      TIcon = false
    end
    
    local TabSelect = Make("Button", MainScroll, {
      Size = UDim2.new(1, 0, 0, 24)
    })Make("Corner", TabSelect)
    
    local LabelTitle = InsertTheme(Create("TextLabel", TabSelect, {
      Size = UDim2.new(1, TIcon and -25 or -15, 1),
      Position = UDim2.fromOffset(TIcon and 25 or 15),
      BackgroundTransparency = 1,
      Font = Enum.Font.GothamMedium,
      Text = TName,
      TextColor3 = Theme["Color Text"],
      TextSize = 10,
      TextXAlignment = Enum.TextXAlignment.Left,
      TextTransparency = (FirstTab and 0.3) or 0,
      TextTruncate = "AtEnd"
    }), "Text")
    
    local LabelIcon = InsertTheme(Create("ImageLabel", TabSelect, {
      Position = UDim2.new(0, 8, 0.5),
      Size = UDim2.new(0, 13, 0, 13),
      AnchorPoint = Vector2.new(0, 0.5),
      Image = TIcon or "",
      BackgroundTransparency = 1,
      ImageTransparency = (FirstTab and 0.3) or 0
    }), "Text")
    
    local Selected = InsertTheme(Create("Frame", TabSelect, {
      Size = FirstTab and UDim2.new(0, 4, 0, 4) or UDim2.new(0, 4, 0, 13),
      Position = UDim2.new(0, 1, 0.5),
      AnchorPoint = Vector2.new(0, 0.5),
      BackgroundColor3 = Theme["Color Theme"],
      BackgroundTransparency = FirstTab and 1 or 0
    }), "Theme")Make("Corner", Selected, UDim.new(0.5, 0))
    
    local Container = InsertTheme(Create("ScrollingFrame", Containers, {
      Size = UDim2.new(1, 0, 1, 0),
      Position = UDim2.new(0, 0, 1),
      AnchorPoint = Vector2.new(0, 1),
      ScrollBarThickness = 1.5,
      BackgroundTransparency = 1,
      ScrollBarImageTransparency = 0.2,
      ScrollBarImageColor3 = Theme["Color Theme"],
      AutomaticCanvasSize = "Y",
      ScrollingDirection = "Y",
      BorderSizePixel = 0,
      CanvasSize = UDim2.new(),
      Visible = not FirstTab,
      Name = "Container"
    }, {
      Create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
      }), Create("UIListLayout", {
        Padding = UDim.new(0, 5)
      })
    }), "ScrollBar")
    
    local function Tabs()
      if Container.Visible then return end
      for _,Frame in pairs(Containers:GetChildren()) do
        if Frame:IsA("ScrollingFrame") and Frame ~= Container then
          Frame.Visible = false
        end
      end
      Container.Size = UDim2.new(1, 0, 1, 150)
      Container.Visible = true
      table.foreach(doxlib.Tabs, function(_,Tab)
        if Tab.Cont ~= Container then
          Tab.func:Disable()
        end
      end)
      CreateTween({Container, "Size", UDim2.new(1, 0, 1, 0), 0.3})
      CreateTween({LabelTitle, "TextTransparency", 0, 0.35})
      CreateTween({LabelIcon, "ImageTransparency", 0, 0.35})
      CreateTween({Selected, "Size", UDim2.new(0, 4, 0, 13), 0.35})
      CreateTween({Selected, "BackgroundTransparency", 0, 0.35})
    end
    TabSelect.Activated:Connect(Tabs)
    
    FirstTab = true
    local Tab = {}
    table.insert(doxlib.Tabs, {TabInfo = {Name = TName, Icon = TIcon}, func = Tab, Cont = Container})
    Tab.Cont = Container
    
    function Tab:Disable()
      Container.Visible = false
      CreateTween({LabelTitle, "TextTransparency", 0.3, 0.35})
      CreateTween({LabelIcon, "ImageTransparency", 0.3, 0.35})
      CreateTween({Selected, "Size", UDim2.new(0, 4, 0, 4), 0.35})
      CreateTween({Selected, "BackgroundTransparency", 1, 0.35})
    end
    function Tab:Enable()
      Tabs()
    end
    function Tab:Visible(Bool)
      if Bool == nil then Container.Visible = not Container.Visible TabSelect.Visible = not TabSelect.Visible return end
      Container.Visible = Bool
      TabSelect.Visible = Bool
    end
    function Tab:Destroy()
      TabSelect:Destroy()
      Container:Destroy()
    end
    
    function Tab:AddSection(Configs)
      local SectionName = type(Configs) == "string" and Configs or Configs[1] or Configs.Name or Configs.Title or Configs.Section
      
      local SectionFrame = Create("Frame", Container, {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Name = "Option"
      })
      
      local SectionLabel = InsertTheme(Create("TextLabel", SectionFrame, {
        Font = Enum.Font.GothamBold,
        Text = SectionName,
        TextColor3 = Theme["Color Text"],
        Size = UDim2.new(1, -25, 1, 0),
        Position = UDim2.new(0, 5),
        BackgroundTransparency = 1,
        TextTruncate = "AtEnd",
        TextSize = 14,
        TextXAlignment = "Left"
      }), "Text")
      
      local Section = {}
      table.insert(doxlib.Options, {type = "Section", Name = SectionName, func = Section})
      function Section:Visible(Bool)
        if Bool == nil then SectionFrame.Visible = not SectionFrame.Visible return end
        SectionFrame.Visible = Bool
      end
      function Section:Destroy()
        SectionFrame:Destroy()
      end
      function Section:Set(NewName)
        if type(NewName) ~= "string" then return end
        SectionLabel.Text = NewName
      end
      return Section
    end
    function Tab:AddParagraph(Configs)
      local PName = Configs[1] or Configs.Title or "Paragraph"
      local PDesc = Configs[2] or Configs.Text or ""
      
      local Frame, LabelFunc = ButtonFrame(Container, PName, PDesc, UDim2.new(1, -20))
      
      local Paragraph = {}
      function Paragraph:SetTitle(Val)
        LabelFunc:SetTitle(Val)
      end
      function Paragraph:SetDesc(Val)
        LabelFunc:SetDesc(Val)
      end
      function Paragraph:Set(Val1, Val2)
        if type(Val1) == "string" and type(Val2) == "string" then
          LabelFunc:SetTitle(Val1)
          LabelFunc:SetDesc(Val2)
        else
          LabelFunc:SetDesc(Val1)
        end
      end
      function Paragraph:Visible(Bool)
        if Bool == nil then Frame.Visible = not Frame.Visible return end
        Frame.Visible = Bool
      end
      function Paragraph:Destroy()
        Frame:Destroy()
      end
      return Paragraph
    end
    function Tab:AddButton(Configs)
      local BName = Configs[1] or Configs.Name or Configs.Title or "Button!"
      local BDescription = Configs.Desc or Configs.Description or ""
      local Callback = Configs[2] or Configs.Callback or function()end
      local MultCallback = {}
      
      local Button, LabelFunc = ButtonFrame(Container, BName, BDescription, UDim2.new(1, -20))
      
      local ButtonIcon = Create("ImageLabel", Button, {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -10, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10709791437"
      })
      
      Button.Activated:Connect(function()task.spawn(Callback, "Click")
        table.foreach(MultCallback, function(_,Callback)
          if type(Callback) == "function" then
            task.spawn(Callback, "Click")
          end
        end)
      end)
      
      local Button = {}
      table.insert(doxlib.Options, {type = "Button", Name = BName, func = Button})
      function Button:Callback(func)
        table.insert(MultCallback, func)
      end
      function Button:Set(Val1, Val2)
        if type(Val1) == "string" and type(Val2) == "string" then
          LabelFunc:SetTitle(Val1)
          LabelFunc:SetDesc(Val2)
        elseif type(Val1) == "string" then
          LabelFunc:SetTitle(Val1)
        elseif type(Val1) == "function" then
          Callback = Val1
        end
      end
      function Button:Destroy()
        Button:Destroy()
      end
      function Button:Visible(Bool)
        if Bool == nil then Button.Visible = not Button.Visible return end
        Button.Visible = Bool
      end
      return Button
    end
    function Tab:AddToggle(Configs)
      local TName = Configs[1] or Configs.Name or Configs.Title or "Toggle"
      local TDesc = Configs.Desc or Configs.Description or ""
      local Default = Configs[2] or Configs.Default or false
      local Callback = Configs[3] or Configs.Callback or function()end
      local Flag = Configs[4] or Configs.Flag or false
      local MultCallback = {}
      
      local Button, LabelFunc = ButtonFrame(Container, TName, TDesc, UDim2.new(1, -38))
      
      local ToggleHolder = InsertTheme(Create("Frame", Button, {
        Size = UDim2.new(0, 35, 0, 18),
        Position = UDim2.new(1, -10, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme["Color Stroke"]
      }), "Stroke")Make("Corner", ToggleHolder, UDim.new(0.5, 0))
      
      local Slider = Create("Frame", ToggleHolder, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.8, 0, 0.8, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5)
      })
      
      local Toggle = InsertTheme(Create("Frame", Slider, {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 0, 0.5),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme["Color Theme"]
      }), "Theme")Make("Corner", Toggle, UDim.new(0.5, 0))
      
      if Flag and type(Flag) == "string" and rawget(Flags, Flag) then
        Default = Flags[Flag]
      end
      
      local function CallbackFunc()
        if Flag and typeof(Flag) == "string" then
          SaveFile(Flag, Default)
        end
        task.spawn(Callback, Default)
        table.foreach(MultCallback, function(_,Val)
          if type(Val) == "function" then
            task.spawn(Val, Default)
          end
        end)
      end
      
      local WaitClick
      local function SetToggle(Val)
        if WaitClick then return end
        
        WaitClick, Default = true, Val
        CallbackFunc()
        if Default then
          CreateTween({Toggle, "Position", UDim2.new(1, 0, 0.5), 0.25})
          CreateTween({Toggle, "BackgroundTransparency", 0, 0.25})
          CreateTween({Toggle, "AnchorPoint", Vector2.new(1, 0.5), 0.25, Wait or false})
        else
          CreateTween({Toggle, "Position", UDim2.new(0, 0, 0.5), 0.25})
          CreateTween({Toggle, "BackgroundTransparency", 0.8, 0.25})
          CreateTween({Toggle, "AnchorPoint", Vector2.new(0, 0.5), 0.25, Wait or false})
        end
        WaitClick = false
      end;task.spawn(SetToggle, Default)
      
      Button.Activated:Connect(function()
        SetToggle(not Default)
      end)
      
      local Toggle = {}
      table.insert(doxlib.Options, {type = "Toggle", Name = TName, func = Toggle})
      function Toggle:Callback(func)
        table.insert(MultCallback, func)
        task.spawn(func, Default)
      end
      function Toggle:Set(Val1, Val2)
        if type(Val1) == "string" and type(Val2) == "string" then
          LabelFunc:SetTitle(Val1)
          LabelFunc:SetDesc(Val2)
        elseif type(Val1) == "string" then
          LabelFunc:SetTitle(Val1, false, true)
        elseif type(Val1) == "boolean" then
          if WaitClick and Val2 then
            repeat task.wait() until not WaitClick
          end
          task.spawn(SetToggle, Val1)
        elseif type(Val1) == "function" then
          Callback = Val1
        end
      end
      function Toggle:Destroy()
        Button:Destroy()
      end
      function Toggle:Visible(Bool)
        if Bool == nil then Button.Visible = not Button.Visible return end
        Button.Visible = Bool
      end
      return Toggle
    end
    function Tab:AddDropdown(Configs)
      local DName = Configs[1] or Configs.Name or "Dropdown"
      local Options = Configs[2] or Configs.Options or {"1", "2", "3"}
      local Default = Configs[3] or Configs.Default or {"2"}
      local MultSelect = Configs[4] or Configs.MultSelect or false
      local Callback = Configs[5] or Configs.Callback or function()end
      local Save = Configs[6] or Configs.Flag or false
      
      if Save and typeof(Save) == "string" and FindTable(Flags, Save) then
        Default = Flags[Save]
      end
      local Frame = Button(Container, {Size = UDim2.new(1, 0, 0, 25)}, {Corner()})
      local MainContainer = Create("Frame", Frame, {
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1
      })
      local Text = insertTheme(Create("TextLabel", MainContainer, {
        Font = Theme["Font"][2],
        Text = DName,
        TextSize = 13,
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme["Color Text"],
        TextXAlignment = "Left",
        TextTruncate = "AtEnd"
      }), "Text")
      local TextLabel2 = insertTheme(Create("TextLabel", MainContainer, {
        Size = UDim2.new(0.45, -18, 0, 20),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        BackgroundTransparency = 0.8,
        TextColor3 = Theme["Color Text"],
        Font = Theme["Font"][2],
        TextScaled = true,
        Text = "..."
      }, {Corner()}), "Text")
      local Arrow = insertTheme(Create("ImageLabel", TextLabel2, {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, -5, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        Image = "rbxassetid://15637313297",
        BackgroundTransparency = 1,
        Rotation = 180,
        ImageColor3 = Theme["Color Stroke"]
      }), "Stroke")
      local ContainerList = Create("ScrollingFrame", Frame, {
        Size = UDim2.new(1, 0, 1, -25),
        Position = UDim2.new(0, 0, 0, 25),
        ScrollBarThickness = 2,
        ScrollingDirection = "Y",
        AutomaticCanvasSize = "Y",
        CanvasSize = UDim2.new(),
        BackgroundTransparency = 1
      }, {
        Create("UIPadding", {
          PaddingLeft = UDim.new(0, 10),
          PaddingRight = UDim.new(0, 10),
          PaddingTop = UDim.new(0, 10),
          PaddingBottom = UDim.new(0, 10)
        }), Create("UIListLayout", {
          Padding = UDim.new(0, 4)
        })
      })
      
      local OptionsC, SelectedOption, SelectedOptionT = {}, "", {}
      
      local function SaveDropdown()
        if Save and typeof(Save) == "string" then
          if MultSelect then
            SaveFile(Save, {SelectedOptionT})
          else
            SaveFile(Save, {SelectedOption})
          end
        end
      end
      local function Void()
        table.foreach(ContainerList:GetChildren(), function(a, b)
          if b:IsA("TextButton") then
            b:Destroy()
          end
        end)
        TextLabel2.Text = "..."
        SelectedOptionT = {}
        OptionsC = {}
      end
      local function SetLabelTable()
        local str, first = ""
        table.foreach(SelectedOptionT, function(a, b)
          if first then
            str = str .. ", "
          end
          str = str .. b
          first = true
        end)
        TextLabel2.Text = str
      end
      local function RemoveOption(name)
        local Option = ContainerList:FindFirstChild(name)
        if Option then
          Option:Destroy()
          table.foreach(OptionsC, function(a, b)
            if b == name then
              table.remove(OptionsC, a)
            end
          end)
        end
      end
      local function AddOption(val, void)
        local function CreateButton(name)
          table.insert(OptionsC, name)
          local Frame = Create("TextButton", ContainerList, {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 0.9,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            AutoButtonColor = false,
            Text = ""
          }, {
            Corner()
          })
          
          local TextLabel = insertTheme(Create("TextLabel", Frame, {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 20, 0, 0),
            Text = name,
            TextColor3 = Theme["Color Text"],
            TextTransparency = 0.4,
            Font = Theme["Font"][3],
            TextSize = 14,
            BackgroundTransparency = 1,
            TextXAlignment = "Left"
          }), "Text")
          
          local Selected = insertTheme(Create("Frame", Frame, {
            Size = UDim2.new(0, 5, 0, 10),
            Position = UDim2.new(0, 10, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 0.8,
            BackgroundColor3 = Theme["Color Theme"]
          }, {
            Corner(Selected)
          }), "Theme")
          
          if typeof(Default) == "table" and Default[1] == name or Default == name and name == SelectedOption then
            CreateTween({Selected, "BackgroundTransparency", 0, 0.2})
            CreateTween({TextLabel, "TextTransparency", 0, 0.2})
            CreateTween({Frame, "BackgroundTransparency", 0.7, 0.2})
            SelectedOption = name
            TextLabel2.Text = name
            task.spawn(Callback, name)
          end
          
          Frame.Activated:Connect(function()
            for _,option in pairs(ContainerList:GetChildren()) do
              if option ~= Frame and option:IsA("TextButton") then
                CreateTween({option.Frame, "BackgroundTransparency", 0.8, 0.2})
                CreateTween({option.TextLabel, "TextTransparency", 0.4, 0.2})
                CreateTween({option, "BackgroundTransparency", 0.9, 0.2})
              end
            end
            CreateTween({Selected, "BackgroundTransparency", 0, 0.2})
            CreateTween({TextLabel, "TextTransparency", 0, 0.2})
            CreateTween({Frame, "BackgroundTransparency", 0.7, 0.2})
            SelectedOption = name
            TextLabel2.Text = name
            task.spawn(Callback, name)
            SaveDropdown()
          end)
        end
        local function CreateToggle(name)
          table.insert(OptionsC, name)
          local Frame = Create("TextButton", ContainerList, {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 0.9,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            AutoButtonColor = false,
            Text = ""
          }, {
            Corner()
          })
          
          local TextLabel = insertTheme(Create("TextLabel", Frame, {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 20, 0, 0),
            Text = name,
            TextColor3 = Theme["Color Dark Text"],
            Font = Theme["Font"][3],
            TextSize = 14,
            BackgroundTransparency = 1,
            TextXAlignment = "Left"
          }), "DarkText")
          
          local Selected = insertTheme(Create("Frame", Frame, {
            Size = UDim2.new(0, 5, 0, 10),
            Position = UDim2.new(0, 10, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 0.8,
            BackgroundColor3 = Theme["Color Theme"]
          }, {
            Corner()
          }), "Theme")
          
          local OnOff
          if table.find(Default, name) or table.find(SelectedOptionT, name) then
            CreateTween({Selected, "BackgroundTransparency", 0, 0.2})
            CreateTween({TextLabel, "TextColor3", Theme["Color Text"], 0.2})
            CreateTween({Frame, "BackgroundTransparency", 0.7, 0.2})
            if not table.find(SelectedOptionT, name) then
              table.insert(SelectedOptionT, name)
            end
            task.spawn(Callback, name, true)
            OnOff = true
            SetLabelTable()
          end
          
          Frame.Activated:Connect(function()
            OnOff = not OnOff
            if OnOff then
              CreateTween({Selected, "BackgroundTransparency", 0, 0.2})
              CreateTween({TextLabel, "TextColor3", Theme["Color Text"], 0.2})
              CreateTween({Frame, "BackgroundTransparency", 0.7, 0.2})
              if not table.find(SelectedOptionT, name) then
                table.insert(SelectedOptionT, name)
              end
              task.spawn(Callback, name, true)
              SetLabelTable()
            else
              CreateTween({Selected, "BackgroundTransparency", 0.8, 0.2})
              CreateTween({TextLabel, "TextColor3", Theme["Color Dark Text"], 0.2})
              CreateTween({Frame, "BackgroundTransparency", 0.9, 0.2})
              table.foreach(SelectedOptionT, function(a, b)
                if b == name then
                  table.remove(SelectedOptionT, a)
                end
              end)
              task.spawn(Callback, name, false)
              SetLabelTable()
            end
            SaveDropdown()
          end)
        end
        
        if typeof(val) == "table" then
          if void then
            Void()
          end
          
          table.foreach(val, function(a, b)
            if not table.find(OptionsC, b) then
              if MultSelect then
                CreateToggle(b)
              else
                CreateButton(b)
              end
            end
          end)
        end
      end;AddOption(Options, true)
      
      local function GetNumber()
        local counter = 0
        for _,v in pairs(ContainerList:GetChildren()) do
          if v:IsA("TextButton") then
            counter = counter + 1
          end
        end
        return counter
      end
      
      local Minimized, WaitPress
      Frame.Activated:Connect(function()
        if not WaitPress then
          local SizeY
          if GetNumber() >= 1 then
            SizeY = (35 + math.clamp(GetNumber(), 1, 5) * 20)
          else
            SizeY = 25
          end
          
          WaitPress = true
          if not Minimized then
            CreateTween({Arrow, "Rotation", 0, 0.3})
            CreateTween({Arrow, "ImageColor3", Theme["Color Theme"], 0.3})
            CreateTween({Frame, "Size", UDim2.new(1, 0, 0, SizeY), 0.3, true})
          else
            CreateTween({Arrow, "Rotation", 180, 0.3})
            CreateTween({Arrow, "ImageColor3", Theme["Color Stroke"], 0.3})
            CreateTween({Frame, "Size", UDim2.new(1, 0, 0, 25), 0.3, true})
          end
          Minimized = not Minimized
          WaitPress = false
        end
      end)
      
      local DropdownF = {}
      
      function DropdownF:Void()
        Void()
      end
      
      function DropdownF:Set(val1, val2)
        if val1 and typeof(val1) == "string" then Text.Text = val1
        elseif val1 and typeof(val1) == "function" then Callback = val1
        elseif val1 and val2 and typeof(val1) == "table" then AddOption(val1, val2) end
      end
      function DropdownF:Visible(Bool)Frame.Visible = Bool end
      function DropdownF:Destroy()Frame:Destroy()end
      return DropdownF
    end
    function Tab:AddSlider(Configs)
      local SName = Configs[1] or Configs.Name or Configs.Title or "Slider!"
      local SDesc = Configs.Desc or Configs.Description or ""
      local Min = Configs[2] or Configs.MinValue or Configs.Min or 10
      local Max = Configs[3] or Configs.MaxValue or Configs.Max or 100
      local Increase = Configs[4] or Configs.Increase or 1
      local Default = Configs[5] or Configs.Default or 25
      local Callback = Configs[6] or Configs.Callback or function()end
      local Flag = Configs[7] or Configs.Flag or false
      local MultCallback = {}
      Min, Max = Min / Increase, Max / Increase
      
      if Flag and type(Flag) == "string" and rawget(Flags, Flag) then
        Default = Flags[Flag]
      end
      
      local Button, LabelFunc = ButtonFrame(Container, SName, SDesc, UDim2.new(1, -180))
      
      local SliderHolder = Create("TextButton", Button, {
        Size = UDim2.new(0.45, 0, 1),
        Position = UDim2.new(1),
        AnchorPoint = Vector2.new(1, 0),
        AutoButtonColor = false,
        Text = "",
        BackgroundTransparency = 1
      })
      
      local SliderBar = InsertTheme(Create("Frame", SliderHolder, {
        BackgroundColor3 = Theme["Color Stroke"],
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0.5, 0, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5)
      }), "Stroke")Make("Corner", SliderBar)
      
      local Indicator = InsertTheme(Create("Frame", SliderBar, {
        BackgroundColor3 = Theme["Color Theme"],
        Size = UDim2.fromScale(0.3, 1),
        BorderSizePixel = 0
      }), "Theme")Make("Corner", Indicator)
      
      local SliderIcon = Create("Frame", SliderBar, {
        Size = UDim2.new(0, 6, 0, 12),
        BackgroundColor3 = Color3.fromRGB(220, 220, 220),
        Position = UDim2.fromScale(0.3, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0.2
      })Make("Corner", SliderIcon)
      
      local LabelVal = InsertTheme(Create("TextLabel", SliderHolder, {
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(0, 0, 0.5),
        BackgroundTransparency = 1,
        TextColor3 = Theme["Color Text"],
        Font = Enum.Font.FredokaOne,
        TextSize = 12
      }), "Text")
      
      local UIScale = Create("UIScale", LabelVal)
      
      local BaseMousePos = Create("Frame", SliderBar, {
        Position = UDim2.new(0, 0, 0.5, 0),
        Visible = false
      })
      
      local function SaveSlider()
        if Flag and typeof(Flag) == "string" then
          SaveFile(Flag, Default)
        end
      end
      
      local function UpdateLabel(NewValue)
        local Number = tonumber(NewValue * Increase)
        Number = math.floor(Number * 100) / 100
        
        Default, LabelVal.Text = Number, tostring(Number)
        task.spawn(Callback, Default)
      end
      
      local function ControlPos()
        local MousePos = Player:GetMouse()
        local APos = MousePos.X - BaseMousePos.AbsolutePosition.X
        local ConfigureDpiPos = APos / SliderBar.AbsoluteSize.X
        
        SliderIcon.Position = UDim2.new(math.clamp(ConfigureDpiPos, 0, 1), 0, 0.5, 0)
      end
      
      SliderHolder.MouseButton1Down:Connect(function()
        CreateTween({SliderIcon, "Transparency", 0, 0.3})
        Container.ScrollingEnabled = false
        while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
          ControlPos()
        end
        table.foreach(MultCallback, function(_,func)
          if type(func) == "function" then
            task.spawn(func, Default)
          end
        end)
        CreateTween({SliderIcon, "Transparency", 0.2, 0.3})
        Container.ScrollingEnabled = true
        SaveSlider()
      end)
      
      LabelVal:GetPropertyChangedSignal("Text"):Connect(function()
        UIScale.Scale = 0.3
        CreateTween({UIScale, "Scale", 1.2, 0.1})
        CreateTween({LabelVal, "Rotation", math.random(-1, 1) * 5, 0.15, true})
        CreateTween({UIScale, "Scale", 1, 0.2})
        CreateTween({LabelVal, "Rotation", 0, 0.1})
      end)
      
      SliderIcon:GetPropertyChangedSignal("Position"):Connect(function()
        Indicator.Size = UDim2.new(SliderIcon.Position.X.Scale, 0, 1, 0)
        local SliderPos = SliderIcon.Position.X.Scale
        local NewValue = math.floor(((SliderPos * Max) / Max) * (Max - Min) + Min)
        UpdateLabel(NewValue)
      end)
      
			function SetSlider(NewValue)
        local Min, Max = Min * Increase, Max * Increase
        
        local SliderPos = (NewValue - Min) / (Max - Min)
        
        CreateTween({SliderIcon, "Position", UDim2.fromScale(math.clamp(SliderPos, 0, 1), 0.5), 0.3, true})
        SaveSlider()
			end;SetSlider(Default)
			
			local Slider = {}
			table.insert(doxlib.Options, {type = "Slider", Name = SName, func = Slider})
      function Slider:Set(NewVal1, NewVal2)
        if NewVal1 and NewVal2 then
          LabelFunc:SetTitle(NewVal1)
          LabelFunc:SetDesc(NewVal2)
        elseif type(NewVal1) == "string" then
          LabelFunc:SetTitle(NewVal1)
        elseif type(NewVal1) == "function" then
          Callback = NewVal1
        elseif type(NewVal1) == "number" then
          SetSlider(NewVal1)
        end
      end
      function Slider:Callback(func)
        table.insert(MultCallback, func)
      end
      function Slider:Destroy()
        Button:Destroy()
      end
      function Slider:Visible(Bool)
        if Bool == nil then Button.Visible = not Button.Visible return end
        Button.Visible = Bool
      end
			return Slider
    end
    function Tab:AddTextBox(Configs)
      local TName = Configs[1] or Configs.Name or Configs.Title or "Text Box"
      local TDesc = Configs.Desc or Configs.Description or ""
      local TDefault = Configs[2] or Configs.Default or ""
      local TPlaceholderText = Configs.PlaceholderText or "Input"
      local TClearText = Configs[3] or Configs.ClearText or false
      local Callback = Configs[2] or Configs.Callback or function()end
      local MultCallback = {}
      
      if type(TDefault) ~= "string" or TDefault:gsub(" ", ""):len() < 1 then
        TDefault = false
      end
      
      local Button, LabelFunc = ButtonFrame(Container, TName, TDesc, UDim2.new(1, -38))
      
      local SelectedFrame = InsertTheme(Create("Frame", Button, {
        Size = UDim2.new(0, 150, 0, 18),
        Position = UDim2.new(1, -10, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Theme["Color Stroke"]
      }), "Stroke")Make("Corner", SelectedFrame, UDim.new(0, 4))
      
      local TextBoxInput = InsertTheme(Create("TextBox", SelectedFrame, {
        Size = UDim2.new(0.85, 0, 0.85, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextScaled = true,
        TextColor3 = Theme["Color Text"],
        ClearTextOnFocus = TClearText,
        Text = ""
      }), "Text")
      
      local Pencil = Create("ImageLabel", SelectedFrame, {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, -5, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        Image = "rbxassetid://15637081879",
        BackgroundTransparency = 1
      })
      
      local function Input()
        local Text = TextBoxInput.Text
        if Text:gsub(" ", ""):len() < 1 then return end
        
        task.spawn(Callback, Text)
        table.foreach(MultCallback, function(func)
          if type(func) == "function" then
            task.spawn(func, Text)
          end
        end)
      end
      
      TextBoxInput.FocusLost:Connect(Input)
      
      TextBoxInput.FocusLost:Connect(function()
        CreateTween({Pencil, "ImageColor3", Color3.fromRGB(255, 255, 255), 0.2})
      end)
      TextBoxInput.Focused:Connect(function()
        CreateTween({Pencil, "ImageColor3", Theme["Color Theme"], 0.2})
      end)
      
      local TextBox = {}
      function TextBox:Destroy()
        Button:Destroy()
      end
      function TextBox:Visible(Bool)
        if Bool == nil then Button.Visible = not Button.Visible return end
        Button.Visible = Bool
      end
      return TextBox
    end
    function Tab:AddDiscordInvite(Configs)
      local Title = Configs[1] or Configs.Name or Configs.Title or "Discord"
      local Desc = Configs.Desc or Configs.Description or ""
      local Logo = Configs[2] or Configs.Logo hor ""
      local Invite = Configs[3] or Configs.Invite or ""
      
      local InviteHolder = Create("Frame", Container, {
        Size = UDim2.new(1, 0, 0, 80),
        Name = "Option",
        BackgroundTransparency = 1
      })
      
      local InviteLabel = Create("TextLabel", InviteHolder, {
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 5),
        TextColor3 = Color3.fromRGB(40, 150, 255),
        Font = Enum.Font.GothamBold,
        TextXAlignment = "Left",
        BackgroundTransparency = 1,
        TextSize = 10,
        Text = Invite
      })
      
      local FrameHolder = InsertTheme(Create("Frame", InviteHolder, {
        Size = UDim2.new(1, 0, 0, 65),
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1),
        BackgroundColor3 = Theme["Color Hub 2"]
      }), "Frame")Make("Corner", FrameHolder)
      
      local ImageLabel = Create("ImageLabel", FrameHolder, {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 7, 0, 7),
        Image = Logo,
        BackgroundTransparency = 1
      })Make("Corner", ImageLabel, UDim.new(0, 4))Make("Stroke", ImageLabel)
      
      local LTitle = InsertTheme(Create("TextLabel", FrameHolder, {
        Size = UDim2.new(1, -52, 0, 15),
        Position = UDim2.new(0, 44, 0, 7),
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme["Color Text"],
        TextXAlignment = "Left",
        BackgroundTransparency = 1,
        TextSize = 10,
        Text = Title
      }), "Text")
      
      local LDesc = InsertTheme(Create("TextLabel", FrameHolder, {
        Size = UDim2.new(1, -52, 0, 0),
        Position = UDim2.new(0, 44, 0, 22),
        TextWrapped = "Y",
        AutomaticSize = "Y",
        Font = Enum.Font.Gotham,
        TextColor3 = Theme["Color Dark Text"],
        TextXAlignment = "Left",
        BackgroundTransparency = 1,
        TextSize = 8,
        Text = Desc
      }), "DarkText")
      
      local JoinButton = Create("TextButton", FrameHolder, {
        Size = UDim2.new(1, -14, 0, 16),
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -7),
        Text = "Join",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        BackgroundColor3 = Color3.fromRGB(50, 150, 50)
      })Make("Corner", JoinButton, UDim.new(0, 5))
      
      local ClickDelay
      JoinButton.Activated:Connect(function()
        setclipboard(Invite)
        if ClickDelay then return end
        
        ClickDelay = true
        SetProps(JoinButton, {
          Text = "Copied to Clipboard",
          BackgroundColor3 = Color3.fromRGB(100, 100, 100),
          TextColor3 = Color3.fromRGB(150, 150, 150)
        })task.wait(5)
        SetProps(JoinButton, {
          Text = "Join",
          BackgroundColor3 = Color3.fromRGB(50, 150, 50),
          TextColor3 = Color3.fromRGB(220, 220, 220)
        })ClickDelay = false
      end)
      
      local DiscordInvite = {}
      function DiscordInvite:Destroy()
        InviteHolder:Destroy()
      end
      function DiscordInvite:Visible(Bool)
        if Bool == nil then InviteHolder.Visible = not InviteHolder.Visible return end
        InviteHolder.Visible = Bool
      end
      return DiscordInvite
    end
    return Tab
  end
  
  CloseButton.Activated:Connect(Window.CloseBtn)
  MinimizeButton.Activated:Connect(Window.MinimizeBtn)
  return Window
end

return doxlib
