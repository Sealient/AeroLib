local AeroLib = {}
AeroLib.__index = AeroLib

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- // HIGH-END THEME CONFIG
local THEME = {
	Background = Color3.fromRGB(10, 10, 14),
	Sidebar = Color3.fromRGB(14, 14, 18),
	Accent = Color3.fromRGB(0, 210, 255), 
	Glow = Color3.fromRGB(0, 255, 200),
	Text = Color3.fromRGB(255, 255, 255),
	Secondary = Color3.fromRGB(130, 130, 145),
	Card = Color3.fromRGB(22, 22, 28)
}

function AeroLib.new(clientName)
	local self = setmetatable({}, AeroLib)
	
	self.Open = true
	self.ToggleKey = Enum.KeyCode.RightShift
	self.Pages = {}
	self.Distance = 1.8
	self.SwayIntensity = 1.2

	-- // MAIN NODE (Physical Part)
	local Part = Instance.new("Part")
	Part.Name = "Aero_Final_Node"
	Part.Size = Vector3.new(3.5, 2.0, 0.01)
	Part.Transparency = 1
	Part.CanCollide = false
	Part.Anchored = true
	Part.Parent = workspace
	self.Root = Part

	local SGui = Instance.new("SurfaceGui", Part)
	SGui.Face = Enum.NormalId.Back
	-- Start with a sensible canvas size; we'll keep it synced to the camera viewport
	local Cam = workspace.CurrentCamera
	SGui.CanvasSize = Cam and Cam.ViewportSize or Vector2.new(1920, 1080)
	SGui.AlwaysOnTop = true
	SGui.Brightness = 3
	
	-- // MAIN CONTAINER
	local Main = Instance.new("CanvasGroup", SGui)
	-- make the UI medium-sized (less obtrusive)
	Main.Size = UDim2.new(0.38, 0, 0.6, 0)
	Main.Position = UDim2.new(0.08, 0, 0.14, 0)
	Main.BackgroundColor3 = THEME.Background
	Main.BackgroundTransparency = 0.05
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 45)
	self.MainFrame = Main

	local Header = Instance.new("TextLabel", Main)
	Header.Size = UDim2.new(1, 0, 0, 100)
	Header.Position = UDim2.new(0, 0, 0, 30)
	Header.Text = clientName:upper()
	Header.TextSize = 28
	Header.Font = Enum.Font.GothamBold
	Header.TextColor3 = THEME.Glow
	Header.BackgroundTransparency = 1

	-- // BOTTOM PILL TAB BAR (separate pill below main, like Meta Quest layout)
	local TabBar = Instance.new("Frame", SGui)
	TabBar.Size = UDim2.new(0.42, 0, 0, 70)
	TabBar.Position = UDim2.new(0.29, 0, 0.885, 0)
	TabBar.AnchorPoint = Vector2.new(0, 0)
	TabBar.BackgroundColor3 = THEME.Sidebar
	TabBar.BackgroundTransparency = 0.2
	Instance.new("UICorner", TabBar).CornerRadius = UDim.new(1, 0)
	Instance.new("UIStroke", TabBar).Color = THEME.Accent

	self.TabHolder = Instance.new("Frame", TabBar)
	self.TabHolder.Size = UDim2.new(0.95, 0, 1, 0)
	self.TabHolder.Position = UDim2.new(0.025, 0, 0, 0)
	self.TabHolder.BackgroundTransparency = 1
	
	local Layout = Instance.new("UIListLayout", self.TabHolder)
	Layout.FillDirection = Enum.FillDirection.Horizontal
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Layout.VerticalAlignment = Enum.VerticalAlignment.Center
	Layout.Padding = UDim.new(0, 12)

	-- // CONTENT AREA
	self.PageHolder = Instance.new("Frame", Main)
	self.PageHolder.Size = UDim2.new(0.9, 0, 0.55, 0)
	self.PageHolder.Position = UDim2.new(0.05, 0, 0.2, 0)
	self.PageHolder.BackgroundTransparency = 1

	-- // ROTATION ENGINE
	UserInputService.InputBegan:Connect(function(i, g)
		if not g and i.KeyCode == self.ToggleKey then self:Toggle() end
	end)

	RunService.RenderStepped:Connect(function()
		if not self.Open and Main.GroupTransparency >= 0.99 then return end
		local Cam = workspace.CurrentCamera
		-- keep the SurfaceGui canvas matching current viewport to avoid scaling/pixelation
		if Cam and SGui.CanvasSize ~= Cam.ViewportSize then
			SGui.CanvasSize = Cam.ViewportSize
		end

		local fovAdj = (70 / Cam.FieldOfView)
		local BaseCF = Cam.CFrame * CFrame.new(0, 0, -(self.Distance * fovAdj))
		local LookAt = CFrame.lookAt(BaseCF.Position, Cam.CFrame.Position) * CFrame.Angles(0, math.rad(180), 0)

		local Mouse = LocalPlayer:GetMouse()
		local mX = (Mouse.X - Cam.ViewportSize.X/2) / (2500 / self.SwayIntensity)
		local mY = (Mouse.Y - Cam.ViewportSize.Y/2) / (2500 / self.SwayIntensity)

		Part.CFrame = LookAt * CFrame.Angles(-mY, -mX, 0)
	end)

	return self
end

function AeroLib:Toggle()
	self.Open = not self.Open

	if self.Open then
		self.Root.Parent = workspace
		TweenService:Create(self.MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
			Position = UDim2.new(0.05, 0, 0.1, 0),
			GroupTransparency = 0
		}):Play()
	else
		local t = TweenService:Create(self.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
			Position = UDim2.new(0.05, 0, 0.15, 0),
			GroupTransparency = 1
		})
		t:Play()
		t.Completed:Connect(function()
			if not self.Open then self.Root.Parent = nil end
		end)
	end
end

function AeroLib:AddTab(name)
	local page = Instance.new("ScrollingFrame", self.PageHolder)
	page.Size = UDim2.new(1, 0, 1, 0)
	page.Visible = false
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 0
	page.CanvasSize = UDim2.new(0,0,0,0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local pageLayout = Instance.new("UIListLayout", page)
	pageLayout.Padding = UDim.new(0, 18)
	
	self.Pages[name] = page

	local btn = Instance.new("TextButton", self.TabHolder)
	btn.Size = UDim2.new(0, 160, 0, 50)
	btn.BackgroundColor3 = THEME.Card
	btn.Text = name:upper()
	btn.TextSize = 18
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = THEME.Secondary
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

	btn.MouseButton1Click:Connect(function()
		for _, p in pairs(self.Pages) do p.Visible = false end
		page.Visible = true
		for _, b in pairs(self.TabHolder:GetChildren()) do
			if b:IsA("TextButton") then
				TweenService:Create(b, TweenInfo.new(0.3), {TextColor3 = THEME.Secondary, BackgroundColor3 = THEME.Card}):Play()
			end
		end
		TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = THEME.Accent, BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
	end)

	if #self.TabHolder:GetChildren() <= 2 then -- Accounting for the UIListLayout
		page.Visible = true
		btn.TextColor3 = THEME.Accent
	end
	
	return page
end

function AeroLib:AddToggle(page, name, callback)
	local f = Instance.new("Frame", page)
	f.Size = UDim2.new(0.98, 0, 0, 72)
	f.BackgroundColor3 = THEME.Card
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 15)

	local l = Instance.new("TextLabel", f)
	l.Size = UDim2.new(0.6, 0, 1, 0)
	l.Position = UDim2.new(0.05, 0, 0, 0)
	l.Text = name
	l.TextSize = 20
	l.TextColor3 = THEME.Text
	l.Font = Enum.Font.GothamBold
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left

	local b = Instance.new("TextButton", f)
	b.Size = UDim2.new(0, 80, 0, 36)
	b.Position = UDim2.new(0.82, 0, 0.5, -18)
	b.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
	b.Text = ""
	Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

	local dot = Instance.new("Frame", b)
	dot.Size = UDim2.new(0, 26, 0, 26)
	dot.Position = UDim2.new(0, 6, 0.5, -13)
	dot.BackgroundColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

	local on = false
	b.MouseButton1Click:Connect(function()
		on = not on
		TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = on and THEME.Accent or Color3.fromRGB(45, 45, 52)}):Play()
		TweenService:Create(dot, TweenInfo.new(0.2), {Position = on and UDim2.new(1, -30, 0.5, -13) or UDim2.new(0, 6, 0.5, -13)}):Play()
		callback(on)
	end)
end

function AeroLib:AddSlider(page, name, min, max, default, callback)
	local f = Instance.new("Frame", page)
	f.Size = UDim2.new(0.98, 0, 0, 96)
	f.BackgroundColor3 = THEME.Card
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 15)

	local l = Instance.new("TextLabel", f)
	l.Size = UDim2.new(0.5, 0, 0, 60)
	l.Position = UDim2.new(0.05, 0, 0, 6)
	l.Text = name
	l.TextSize = 18
	l.Font = Enum.Font.GothamBold
	l.TextColor3 = THEME.Text
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left

	local valLabel = Instance.new("TextLabel", f)
	valLabel.Size = UDim2.new(0.4, 0, 0, 60)
	valLabel.Position = UDim2.new(0.55, 0, 0, 6)
	valLabel.Text = tostring(default)
	valLabel.TextColor3 = THEME.Accent
	valLabel.TextSize = 16
	valLabel.Font = Enum.Font.Code
	valLabel.BackgroundTransparency = 1
	valLabel.TextXAlignment = Enum.TextXAlignment.Right

	local sBack = Instance.new("TextButton", f)
	sBack.Size = UDim2.new(0.9, 0, 0, 10)
	sBack.Position = UDim2.new(0.05, 0, 0.78, 0)
	sBack.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
	sBack.Text = ""
	sBack.AutoButtonColor = false
	Instance.new("UICorner", sBack)

	local fill = Instance.new("Frame", sBack)
	local initialPct = math.clamp((default - min) / (max - min), 0, 1)
	fill.Size = UDim2.new(initialPct, 0, 1, 0)
	fill.BackgroundColor3 = THEME.Accent
	Instance.new("UICorner", fill)

	local dragging = false
	local dragConn
	local prevVal = nil
	local function updateFromMouse()
		local cam = workspace.CurrentCamera
		local canvasX = (cam and cam.ViewportSize.X) or (sBack.AbsoluteSize.X)
		local mouseLoc = UserInputService:GetMouseLocation()
		local mouseX = math.clamp(mouseLoc.X, 0, canvasX)
		local pos = mouseX - sBack.AbsolutePosition.X
		local width = math.max(1, sBack.AbsoluteSize.X)
		local pct = math.clamp(pos / width, 0, 1)
		fill.Size = UDim2.new(pct, 0, 1, 0)
		local val = math.floor(min + (max - min) * pct + 0.5)
		if val ~= prevVal then
			prevVal = val
			valLabel.Text = tostring(val)
			callback(val)
		end
	end

	sBack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateFromMouse()
			if dragConn then dragConn:Disconnect() end
			dragConn = RunService.RenderStepped:Connect(function()
				if dragging then updateFromMouse() end
			end)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			if dragConn then dragConn:Disconnect() dragConn = nil end
		end
	end)
end

function AeroLib:AddButton(page, name, callback)
	local b = Instance.new("TextButton", page)
	b.Size = UDim2.new(0.98, 0, 0, 90)
	b.BackgroundColor3 = THEME.Card
	b.Text = name
	b.TextColor3 = THEME.Text
	b.TextSize = 30
	b.Font = Enum.Font.GothamBold
	b.AutoButtonColor = false
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 15)

	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = THEME.Secondary}):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = THEME.Card}):Play()
	end)
	b.MouseButton1Click:Connect(callback)
end

function AeroLib:AddDropdown(page, name, options, callback)
	local dropped = false
	local f = Instance.new("Frame", page)
	f.Size = UDim2.new(0.98, 0, 0, 110)
	f.BackgroundColor3 = THEME.Card
	f.ClipsDescendants = true
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 15)

	local b = Instance.new("TextButton", f)
	b.Size = UDim2.new(1, 0, 0, 110)
	b.BackgroundTransparency = 1
	b.Text = "  " .. name .. " : Select..."
	b.TextColor3 = THEME.Text
	b.TextSize = 32
	b.Font = Enum.Font.GothamBold
	b.TextXAlignment = Enum.TextXAlignment.Left

	local optHolder = Instance.new("Frame", f)
	optHolder.Position = UDim2.new(0, 0, 0, 110)
	optHolder.Size = UDim2.new(1, 0, 0, #options * 80)
	optHolder.BackgroundTransparency = 1
	Instance.new("UIListLayout", optHolder)

	for _, opt in pairs(options) do
		local o = Instance.new("TextButton", optHolder)
		o.Size = UDim2.new(1, 0, 0, 80)
		o.BackgroundColor3 = THEME.Sidebar
		o.BorderSizePixel = 0
		o.Text = "      " .. opt
		o.TextColor3 = THEME.Secondary
		o.TextSize = 28
		o.Font = Enum.Font.Gotham
		o.TextXAlignment = Enum.TextXAlignment.Left

		o.MouseButton1Click:Connect(function()
			dropped = false
			f:TweenSize(UDim2.new(0.98, 0, 0, 110), "Out", "Quart", 0.3, true)
			b.Text = "  " .. name .. " : " .. opt
			callback(opt)
		end)
	end

	b.MouseButton1Click:Connect(function()
		dropped = not dropped
		local targetSize = dropped and UDim2.new(0.98, 0, 0, 110 + (#options * 80)) or UDim2.new(0.98, 0, 0, 110)
		f:TweenSize(targetSize, "Out", "Quart", 0.3, true)
	end)
end

function AeroLib:AddKeybind(page, name, default, callback)
	local f = Instance.new("Frame", page)
	f.Size = UDim2.new(0.98, 0, 0, 100)
	f.BackgroundColor3 = THEME.Card
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 15)

	local l = Instance.new("TextLabel", f)
	l.Size = UDim2.new(0.6, 0, 1, 0)
	l.Position = UDim2.new(0.05, 0, 0, 0)
	l.Text = name
	l.TextColor3 = THEME.Text
	l.TextSize = 30
	l.Font = Enum.Font.GothamBold
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left

	local b = Instance.new("TextButton", f)
	b.Size = UDim2.new(0, 200, 0, 60)
	b.Position = UDim2.new(0.72, 0, 0.5, -30)
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	b.Text = default.Name
	b.TextColor3 = THEME.Accent
	b.TextSize = 25
	b.Font = Enum.Font.GothamBold
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

	b.MouseButton1Click:Connect(function()
		b.Text = "..."
		local connection
		connection = UserInputService.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Keyboard then
				b.Text = i.KeyCode.Name
				callback(i.KeyCode)
				connection:Disconnect()
			end
		end)
	end)
end

function AeroLib:AddTextbox(page, name, placeholder, callback)
	local f = Instance.new("Frame", page)
	f.Size = UDim2.new(0.98, 0, 0, 140)
	f.BackgroundColor3 = THEME.Card
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 15)

	local l = Instance.new("TextLabel", f)
	l.Size = UDim2.new(0.9, 0, 0, 50)
	l.Position = UDim2.new(0.05, 0, 0.1, 0)
	l.Text = name
	l.TextColor3 = THEME.Text
	l.TextSize = 28
	l.Font = Enum.Font.GothamBold
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left

	local t = Instance.new("TextBox", f)
	t.Size = UDim2.new(0.9, 0, 0, 55)
	t.Position = UDim2.new(0.05, 0, 0.55, 0)
	t.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	t.Text = ""
	t.PlaceholderText = placeholder
	t.TextColor3 = Color3.new(1,1,1)
	t.TextSize = 25
	t.Font = Enum.Font.Gotham
	Instance.new("UICorner", t).CornerRadius = UDim.new(0, 10)

	t.FocusLost:Connect(function(enter)
		if enter then callback(t.Text) end
	end)
end

function AeroLib:AddSection(page, name)
	local l = Instance.new("TextLabel", page)
	l.Size = UDim2.new(0.98, 0, 0, 60)
	l.BackgroundTransparency = 1
	l.Text = name:upper()
	l.TextColor3 = THEME.Accent
	l.TextSize = 24
	l.Font = Enum.Font.GothamBold
	l.TextXAlignment = Enum.TextXAlignment.Left
end

function AeroLib:CreateProfile()
	local Profile = Instance.new("CanvasGroup", self.MainFrame.Parent) 
	Profile.Name = "UserProfile"
	Profile.Size = UDim2.new(0.25, 0, 0.8, 0)
	Profile.Position = UDim2.new(0.72, 0, 0.1, 0)
	Profile.BackgroundColor3 = THEME.Sidebar
	Profile.BackgroundTransparency = 0.1
	Instance.new("UICorner", Profile).CornerRadius = UDim.new(0, 45)
	
	local Stroke = Instance.new("UIStroke", Profile)
	Stroke.Thickness = 5
	Stroke.Color = THEME.Accent
	Stroke.Transparency = 0.5

	local Avatar = Instance.new("ImageLabel", Profile)
	Avatar.Size = UDim2.new(0, 380, 0, 380)
	Avatar.Position = UDim2.new(0.5, -190, 0.08, 0)
	Avatar.BackgroundColor3 = THEME.Card
	Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
	Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
	Instance.new("UIStroke", Avatar).Thickness = 5

	local Name = Instance.new("TextLabel", Profile)
	Name.Size = UDim2.new(1, 0, 0, 80)
	Name.Position = UDim2.new(0, 0, 0.38, 0)
	Name.Text = LocalPlayer.DisplayName
	Name.TextColor3 = THEME.Text
	Name.TextSize = 52
	Name.Font = Enum.Font.GothamBold
	Name.BackgroundTransparency = 1

	local Sub = Instance.new("TextLabel", Profile)
	Sub.Size = UDim2.new(1, 0, 0, 40)
	Sub.Position = UDim2.new(0, 0, 0.44, 0)
	Sub.Text = "@" .. LocalPlayer.Name
	Sub.TextColor3 = THEME.Secondary
	Sub.TextSize = 30
	Sub.Font = Enum.Font.Gotham
	Sub.BackgroundTransparency = 1

	local Stats = Instance.new("TextLabel", Profile)
	Stats.Size = UDim2.new(0.85, 0, 0.4, 0)
	Stats.Position = UDim2.new(0.075, 0, 0.55, 0)
	Stats.BackgroundTransparency = 1
	Stats.TextColor3 = THEME.Text
	Stats.TextSize = 34
	Stats.Font = Enum.Font.Code
	Stats.TextXAlignment = Enum.TextXAlignment.Left
	Stats.TextYAlignment = Enum.TextYAlignment.Top

	local start = tick()
	RunService.RenderStepped:Connect(function()
		Profile.GroupTransparency = self.MainFrame.GroupTransparency
		if self.Open then
			local fps = math.floor(workspace:GetRealPhysicsFPS())
			local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
			local up = math.floor(tick() - start)
			Stats.Text = string.format(
				"SYSTEM STATUS:\n\nFPS: %d\nPING: %dms\nUPTIME: %ds\nSTATUS: Active",
				fps, ping, up
			)
		end
	end)
end

return AeroLib
