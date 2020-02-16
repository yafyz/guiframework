local RS = game:GetService('RunService')
local UIP = game:GetService('UserInputService')
local mouse = game.Players.LocalPlayer:GetMouse()
Gui = {}
Gui.__index = Gui

function Gui.new(parent, name)
    local newGui = {}
    setmetatable(newGui, Gui)
	newGui.GuiInst = Instance.new("ScreenGui")
	newGui.GuiInst.Parent = parent
	newGui.GuiInst.Name = name
	newGui.gui = {}
	newGui.gui.Tabs = {}
	newGui.gui.color = Color3.fromRGB(255, 200, 0)
	UIP.InputBegan:Connect(function(input)
	    if input.KeyCode == Enum.KeyCode.RightShift then
			newGui.GuiInst.Enabled = not newGui.GuiInst.Enabled
	    end
	end)
    return newGui
end

function Gui:SetColor(color)
	self.gui.color = color
end

function Gui:AddGradient(inst, opt, trp, preset)
	local presets = {
		{
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 181, 7)), 
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,35,68))
			})
		}
	}
	if presets[preset] then
		opt = presets[preset]
	end
	if trp then
		inst[trp[2]] = trp[1]
		inst[trp[3]] = Color3.new(1,1,1)
	end
	local grd = Instance.new('UIGradient', inst)
	for i,v in next, opt do
		grd[i] = v
	end
end

function Gui:CreateTab(name, grad)
	if self.gui.Tabs[name] then
		warn('Tab already exists')
		return
	end
	local offset = 0
	for i,v in next, self.gui.Tabs do offset = offset + 1 end
	self.gui.Tabs[name] = {}
	self.gui.Tabs[name].Children = {}
	self.gui.Tabs[name].frame = Instance.new("Frame", self.GuiInst)
	self.gui.Tabs[name].frame.Name = name
	self.gui.Tabs[name].frame.BorderSizePixel = 0
	self.gui.Tabs[name].frame.BackgroundColor3 = self.gui.color
	self.gui.Tabs[name].frame.Size = UDim2.new(0, 140, 0, 22)
	self.gui.Tabs[name].frame.Position = UDim2.new(0, 10 + (offset * 160), 0, 60)
	
	self.gui.Tabs[name].Children.Title = Instance.new("TextButton", self.gui.Tabs[name].frame)
	self.gui.Tabs[name].Children.Title.Name = "title"
	self.gui.Tabs[name].Children.Title.Text = name
	self.gui.Tabs[name].Children.Title.BackgroundTransparency = 1
	self.gui.Tabs[name].Children.Title.Size = UDim2.new(0, 140, 0, 22)
	self.gui.Tabs[name].Children.Title.TextSize = 8
	
	if grad then
		Gui:AddGradient(self.gui.Tabs[name].frame, unpack(grad))
	end
	
	--Drag script stolen from https://devforum.roblox.com/t/draggable-property-is-hidden-on-gui-objects/107689/5
	local dragging
	local dragInput
	local dragStart
	local startPos
	local toggle
	self.gui.Tabs[name].Children.Title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = self.gui.Tabs[name].frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			for i,v in next, self.gui.Tabs[name] do
				if not (i == "frame" or i == "Children") then
					v.frame.Visible = toggle
				end
			end
			toggle = not toggle
		end
	end)
	self.gui.Tabs[name].Children.Title.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UIP.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			self.gui.Tabs[name].frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	
	return self.gui.Tabs[name]
end

function Gui:CreateButtonUnderTab(tabname, btname, bttext)
	if not self.gui.Tabs[tabname] then
		warn('No tab exist with this name')
		return
	elseif self.gui.Tabs[tabname][btname] then
		warn('Label or tab', btname, 'already exist under', tabname)
		return
	end
	self.gui.Tabs[tabname][btname] = {}
	local offset = -2
	for i,v in next, self.gui.Tabs[tabname] do offset = offset + 1 end
	
	self.gui.Tabs[tabname][btname].frame = Instance.new('TextButton', self.gui.Tabs[tabname].frame)
	self.gui.Tabs[tabname][btname].frame.Name = btname
	self.gui.Tabs[tabname][btname].frame.Position = UDim2.new(0,0,0,22 * offset)
	self.gui.Tabs[tabname][btname].frame.Size = UDim2.new(0, 140, 0, 22)
	self.gui.Tabs[tabname][btname].frame.BackgroundTransparency = .4
	self.gui.Tabs[tabname][btname].frame.Text = bttext
	self.gui.Tabs[tabname][btname].frame.BorderSizePixel = 0
	self.gui.Tabs[tabname][btname].frame.BackgroundColor3 = Color3.new(1,1,1)
	self.gui.Tabs[tabname][btname].frame.TextColor3 = Color3.new(0,0,0)
	
	self.gui.Tabs[tabname][btname].arrowframe = Instance.new('TextLabel', self.gui.Tabs[tabname][btname].frame)
	self.gui.Tabs[tabname][btname].arrowframe.Size = UDim2.new(0,24,0,24)
	self.gui.Tabs[tabname][btname].arrowframe.BackgroundTransparency = 1
	self.gui.Tabs[tabname][btname].arrowframe.Text = '>'
	self.gui.Tabs[tabname][btname].arrowframe.TextColor3 = Color3.new(0,0,0)
	self.gui.Tabs[tabname][btname].arrowframe.TextSize = 10
	return self.gui.Tabs[tabname][btname]
end

function Gui:CreateLabelUnderTab(tabname, labelname, labeltext, xalign)
	if not self.gui.Tabs[tabname] then
		warn('No tab exist with this name')
		return
	elseif self.gui.Tabs[tabname][labelname] then
		warn('Label or tab', labelname, 'already exist under', tabname)
		return
	end
	xalign = xalign or 'Center'
	self.gui.Tabs[tabname][labelname] = {}
	local offset = -2
	for i,v in next, self.gui.Tabs[tabname] do offset = offset + 1 end
	
	self.gui.Tabs[tabname][labelname].frame = Instance.new('TextLabel', self.gui.Tabs[tabname].frame)
	self.gui.Tabs[tabname][labelname].frame.Name = labelname
	self.gui.Tabs[tabname][labelname].frame.Position = UDim2.new(0,0,0,22 * offset)
	self.gui.Tabs[tabname][labelname].frame.Size = UDim2.new(0, 140, 0, 22)
	self.gui.Tabs[tabname][labelname].frame.BackgroundTransparency = .4
	self.gui.Tabs[tabname][labelname].frame.Text = labeltext
	self.gui.Tabs[tabname][labelname].frame.TextSize = 7
	self.gui.Tabs[tabname][labelname].frame.BorderSizePixel = 0
	self.gui.Tabs[tabname][labelname].frame.BackgroundColor3 = Color3.new(1,1,1)
	self.gui.Tabs[tabname][labelname].frame.TextColor3 = Color3.new(0,0,0)
	self.gui.Tabs[tabname][labelname].frame.TextXAlignment = xalign
	return self.gui.Tabs[tabname][labelname]
end

function Gui:CreateTextBoxUnderTab(tabname, boxname, boxtext, xalign)
	if not self.gui.Tabs[tabname] then
		warn('No tab exist with this name')
		return
	elseif self.gui.Tabs[tabname][boxname] then
		warn('Label or tab', boxname, 'already exist under', tabname)
		return
	end
	boxtext = boxtext or ''
	xalign = xalign or 'Center'
	self.gui.Tabs[tabname][boxname] = {}
	local offset = -2
	for i,v in next, self.gui.Tabs[tabname] do offset = offset + 1 end
	
	self.gui.Tabs[tabname][boxname].frame = Instance.new('TextBox', self.gui.Tabs[tabname].frame)
	self.gui.Tabs[tabname][boxname].frame.Name = boxname
	self.gui.Tabs[tabname][boxname].frame.Position = UDim2.new(0,0,0,22 * offset)
	self.gui.Tabs[tabname][boxname].frame.Size = UDim2.new(0, 140, 0, 22)
	self.gui.Tabs[tabname][boxname].frame.BackgroundTransparency = .4
	self.gui.Tabs[tabname][boxname].frame.Text = ""
	self.gui.Tabs[tabname][boxname].frame.TextSize = 7
	self.gui.Tabs[tabname][boxname].frame.PlaceholderText = boxtext
	self.gui.Tabs[tabname][boxname].frame.BorderSizePixel = 0
	self.gui.Tabs[tabname][boxname].frame.BackgroundColor3 = Color3.new(1,1,1)
	self.gui.Tabs[tabname][boxname].frame.TextColor3 = Color3.new(0,0,0)
	self.gui.Tabs[tabname][boxname].frame.TextXAlignment = xalign
	return self.gui.Tabs[tabname][boxname]
end

function Gui:SetTitle(name, ver)
	self.gui.Title = {}
	self.gui.Title.frame = Instance.new("Frame", self.GuiInst)
	self.gui.Title.frame.Transparency = 1
	self.gui.Title.frame.Name = "title"
	
	self.gui.Title.title = Instance.new("TextLabel", self.gui.Title.frame)
	self.gui.Title.title.Name = "title"
	self.gui.Title.title.Text = name
	self.gui.Title.title.TextSize = 20
	self.gui.Title.title.BackgroundTransparency = 1
	self.gui.Title.title.Size = UDim2.new(1,200,1,40)
	self.gui.Title.title.Position = UDim2.new(0,20,0,10)
	self.gui.Title.title.TextXAlignment = "Left"
	self.gui.Title.title.TextColor3 = self.gui.color
	self.gui.Title.title.TextStrokeTransparency = 0.75
	
	self.gui.Title.version = Instance.new("TextLabel", self.gui.Title.frame)
	self.gui.Title.version.Name = "ver"
	self.gui.Title.version.Text = "v" .. ver
	self.gui.Title.version.BackgroundTransparency = 1
	self.gui.Title.version.TextSize = 10
	self.gui.Title.version.Size = UDim2.new(1,10,1,10)
	self.gui.Title.version.Position = UDim2.new(0,5,0,5)
	self.gui.Title.version.TextXAlignment = "Left"
	self.gui.Title.version.TextColor3 = self.gui.color
	self.gui.Title.version.TextStrokeTransparency = 0.75
	
	return self.gui.Title
end

return Gui
