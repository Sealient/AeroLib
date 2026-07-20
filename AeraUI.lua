--!strict
local UILibrary = {}
UILibrary.__index = UILibrary

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
-- CoreGui Target Acquisition for Notifications
local CoreGui = game:GetService("CoreGui")


-- Configuration / Sleek Cyber Obsidian Theme
local THEME = {
	Background = Color3.fromRGB(10, 10, 12),       -- True flat obsidian black
	Sidebar = Color3.fromRGB(15, 15, 18),          -- Deep matte charcoal
	Surface = Color3.fromRGB(22, 22, 26),          -- Interactive surfaces (buttons)
	SurfaceHover = Color3.fromRGB(28, 28, 34),     -- Hover state for surfaces
	TabActive = Color3.fromRGB(124, 58, 237),      -- Deep royal violet
	TextColor = Color3.fromRGB(243, 244, 246),     -- Crisp off-white
	TextMuted = Color3.fromRGB(139, 139, 150),     -- Soft steel-grey
	Accent = Color3.fromRGB(168, 85, 247),         -- Electric neon purple highlight
	Border = Color3.fromRGB(28, 28, 32),           -- Ultra-thin, low-contrast border
	Font = Enum.Font.GothamMedium,
}

-- Global Notification Queue Tracker
local ActiveNotifications = {}
local NOTIFICATION_WIDTH = 280
local NOTIFICATION_HEIGHT = 48

-- Premium Design Configuration Archetypes
local NOTIFICATION_TYPES = {
	Success = {
		Icon = "✓",
		Accent = Color3.fromRGB(46, 213, 115),
		Title = "Success"
	},
	Error = {
		Icon = "✕",
		Accent = Color3.fromRGB(255, 71, 87),
		Title = "System Failure"
	},
	Info = {
		Icon = "ℹ",
		Accent = Color3.fromRGB(30, 144, 255),
		Title = "Notice"
	},
	Warning = {
		Icon = "⚠",
		Accent = Color3.fromRGB(255, 165, 2),
		Title = "Alert"
	},
	Premium = {
		Icon = "✦",
		Accent = Color3.fromRGB(168, 85, 247),
		Title = "Premium Unlock"
	},
	-- NEW ARCHETYPE CONFIGURATION:
	Native = {
		Title = "Roblox System Notice",
		Icon = "rbxassetid://0" -- You can replace this with a valid asset ID image if you want one!
	}
}

local function getNotificationScreen()
	local screenGui = CoreGui:FindFirstChild("UILibrary_Notifications")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "UILibrary_Notifications"
		screenGui.DisplayOrder = 999999
		screenGui.ResetOnSpawn = false -- Keeps notifications alive through character resets
		screenGui.Parent = CoreGui
	end
	return screenGui
end

-- Positional Layout Recalculation Engine
local function repositionNotifications()
	for index, notificationFrame in ipairs(ActiveNotifications) do
		-- Safe padding offsets: 60px up from bottom, 24px from right
		local targetY = -60 - ((index - 1) * (NOTIFICATION_HEIGHT + 10))
		TweenService:Create(notificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -NOTIFICATION_WIDTH - 24, 1, targetY)
		}):Play()
	end
end

local function addCorner(parent: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function addStroke(parent: Instance, color: Color3, thickness: number, transparency: number)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

-- =======================================================================
-- UILIBRARY.NEW CONSTRUCTOR FRAMEWORK (COMPLETE MINIMALIST INTEGRATION)
-- =======================================================================
function UILibrary.new(titleText: string)
	local self = setmetatable({}, UILibrary)
	self.Tabs = {}
	self.TabCount = 0

	-- =======================================================
	-- PRODUCTION RE-ANCHOR: COREGUI ARCHITECTURE
	-- =======================================================
	-- 1. Root ScreenGui Layer (Live Environment Optimization)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PremiumUILibrary"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true 
	screenGui.ClipToDeviceSafeArea = false 

	-- CRITICAL BLUR BUSTERS FOR LIVE ROBLOX:
	screenGui.SelectionGroup = true -- Forces individual layer culling optimization
	screenGui.AutoLocalize = false   -- Prevents localized system fonts from rewriting/smudging text glyphs

	screenGui.Parent = CoreGui
	self.ScreenGui = screenGui

	-- 2. Main Window Shell (Crisp Sub-Pixel Alignment)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"

	-- Even-numbered sizes aligned perfectly to the center monitor coordinates
	mainFrame.Size = UDim2.new(0, 600, 0, 380)
	mainFrame.Position = UDim2.new(0.5, -300, 0.5, -190) 

	mainFrame.BackgroundColor3 = THEME.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.Visible = false
	mainFrame.Parent = screenGui

	addCorner(mainFrame, 10)
	addStroke(mainFrame, THEME.Border, 1)

	-- =======================================================
	-- FIXED: SMOOTH TOP BAR DRAG MECHANICS (NO SNAP / TELEPORT)
	-- =======================================================
	local topDragBar = Instance.new("Frame")
	topDragBar.Name = "TopDragBar"
	topDragBar.Size = UDim2.new(1, 0, 0, 35) -- Taller visual grab threshold
	topDragBar.Position = UDim2.new(0, 0, 0, 0)
	topDragBar.BackgroundTransparency = 1 
	topDragBar.Active = true
	topDragBar.Parent = mainFrame

	local dragging = false
	local dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X, 
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
	end

	topDragBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topDragBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)

	-- 3. Sidebar Layout Setup
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 170, 1, 0)
	sidebar.BackgroundColor3 = THEME.Sidebar
	sidebar.BorderSizePixel = 0
	sidebar.Parent = mainFrame
	addCorner(sidebar, 10)

	local sidebarCover = Instance.new("Frame")
	sidebarCover.Name = "SidebarCover"
	sidebarCover.Size = UDim2.new(0, 12, 1, 0)
	sidebarCover.Position = UDim2.new(1, -12, 0, 0)
	sidebarCover.BackgroundColor3 = THEME.Sidebar
	sidebarCover.BorderSizePixel = 0
	sidebarCover.Parent = sidebar

	-- 4. Premium Header Title Branding
	local headerFrame = Instance.new("Frame")
	headerFrame.Name = "HeaderFrame"
	headerFrame.Size = UDim2.new(1, 0, 0, 55)
	headerFrame.BackgroundTransparency = 1
	headerFrame.Parent = sidebar

	local physicalGlow = Instance.new("ImageLabel")
	physicalGlow.Name = "PhysicalGlow"
	physicalGlow.Size = UDim2.new(0, 150, 0, 150)
	physicalGlow.Position = UDim2.new(0, -30, 0, -50)
	physicalGlow.BackgroundTransparency = 1
	physicalGlow.Image = "rbxassetid://13809059810"
	physicalGlow.ImageColor3 = THEME.Accent
	physicalGlow.ImageTransparency = 1
	physicalGlow.ZIndex = 1
	physicalGlow.Parent = headerFrame

	local glowLabel = Instance.new("TextLabel")
	glowLabel.Name = "TitleGlow"
	glowLabel.Size = UDim2.new(1, -32, 1, 0)
	glowLabel.Position = UDim2.new(0, 16, 0, 1)
	glowLabel.BackgroundTransparency = 1
	glowLabel.Text = titleText:upper()
	glowLabel.TextColor3 = THEME.Accent
	glowLabel.TextSize = 13.5
	glowLabel.Font = Enum.Font.GothamBold
	glowLabel.TextXAlignment = Enum.TextXAlignment.Left
	glowLabel.TextTransparency = 0.65
	glowLabel.MaxVisibleGraphemes = 0
	glowLabel.ZIndex = 1
	glowLabel.Parent = headerFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleText"
	titleLabel.Size = UDim2.new(1, -32, 1, 0)
	titleLabel.Position = UDim2.new(0, 16, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = titleText:upper()
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 13
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.MaxVisibleGraphemes = 0
	titleLabel.ZIndex = 2
	titleLabel.Parent = headerFrame

	local titleGradient = Instance.new("UIGradient")
	titleGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, THEME.Accent),
		ColorSequenceKeypoint.new(0.4, THEME.Accent),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	})
	titleGradient.Parent = titleLabel

	task.spawn(function()
		task.wait(0.2)
		TweenService:Create(physicalGlow, TweenInfo.new(0.6), { ImageTransparency = 0.75 }):Play()
		local totalCharacters = utf8.len(titleText) or #titleText
		for i = 1, totalCharacters do
			glowLabel.MaxVisibleGraphemes = i
			titleLabel.MaxVisibleGraphemes = i
			task.wait(0.06)
		end
	end)

	-- 5. Navigation & Canvas Mapping
	local tabList = Instance.new("ScrollingFrame")
	tabList.Name = "TabNavigation"
	tabList.Size = UDim2.new(1, 0, 1, -65)
	tabList.Position = UDim2.new(0, 0, 0, 55)
	tabList.BackgroundTransparency = 1
	tabList.BorderSizePixel = 0
	tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabList.ScrollBarThickness = 0
	tabList.Parent = sidebar

	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingLeft = UDim.new(0, 12)
	listPadding.PaddingRight = UDim.new(0, 12)
	listPadding.PaddingTop = UDim.new(0, 1)
	listPadding.Parent = tabList

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.Padding = UDim.new(0, 4)
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabListLayout.Parent = tabList

	local displayArea = Instance.new("Frame")
	displayArea.Name = "ContentArea"
	displayArea.Size = UDim2.new(1, -170, 1, -40)
	displayArea.Position = UDim2.new(0, 170, 0, 20)
	displayArea.BackgroundTransparency = 1
	displayArea.Parent = mainFrame

	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingLeft = UDim.new(0, 24)
	contentPadding.PaddingRight = UDim.new(0, 24)
	contentPadding.PaddingTop = UDim.new(0, 12)
	contentPadding.PaddingBottom = UDim.new(0, 12)
	contentPadding.Parent = displayArea

	self.DisplayArea = displayArea
	self.TabList = tabList
	self.Tabs = {}
	self.ActiveTab = nil

	-- =======================================================
	-- ANIMATION ENGINE: POSITION-AWARE DISPLAY TOGGLE
	-- =======================================================
	local UI_Visible = true
	local isAnimating = false
	local MenuBind = Enum.KeyCode.RightControl

	-- Lighting Blur Reference
	local menuBlur = game:GetService("Lighting"):FindFirstChild("AeraUI_MenuBlur")
	if not menuBlur then
		menuBlur = Instance.new("BlurEffect")
		menuBlur.Name = "AeraUI_MenuBlur"
		menuBlur.Size = 0
		menuBlur.Parent = game:GetService("Lighting")
	end

	local function toggleUI(show: boolean)
		if isAnimating then return end
		isAnimating = true

		-- Read wherever the player currently dragged the window
		local currentPos = mainFrame.Position
		local offsetPos  = UDim2.new(
			currentPos.X.Scale, 
			currentPos.X.Offset, 
			currentPos.Y.Scale, 
			currentPos.Y.Offset + 14 -- Subtle 14px downward offset for smooth slide
		)

		if show then
			UI_Visible = true
			mainFrame.Visible = true

			-- Start 14px down & transparent from current dragged position
			mainFrame.Position = offsetPos
			if mainFrame:IsA("CanvasGroup") then
				mainFrame.GroupTransparency = 1
			end

			-- Blur Fade In
			menuBlur.Enabled = true
			TweenService:Create(menuBlur, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = 8
			}):Play()

			-- Window Slide Up + Canvas Fade In
			if mainFrame:IsA("CanvasGroup") then
				TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					GroupTransparency = 0
				}):Play()
			end

			local openTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Position = currentPos
			})

			openTween:Play()
			openTween.Completed:Wait()
			isAnimating = false
		else
			UI_Visible = false

			-- Blur Fade Out
			TweenService:Create(menuBlur, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = 0
			}):Play()

			-- Window Slide Down + Canvas Fade Out
			if mainFrame:IsA("CanvasGroup") then
				TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					GroupTransparency = 1
				}):Play()
			end

			local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = offsetPos
			})

			closeTween:Play()
			closeTween.Completed:Wait()

			-- Restore exact dragged position before hiding frame
			mainFrame.Position = currentPos
			mainFrame.Visible = false
			menuBlur.Enabled = false
			isAnimating = false
		end
	end

	-- Keybind Listener
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == MenuBind then
			toggleUI(not UI_Visible)
		end
	end)

	-- 1. Settings Tab Profile
	local settingsTab = self:CreateTab("Settings")
	if self.Tabs["Settings"] and self.Tabs["Settings"].Button then
		self.Tabs["Settings"].Button.LayoutOrder = 9998 -- Pinned near bottom
	end

	settingsTab:AddKeybind("Toggle UI Menu Visibility", MenuBind, function(chosenKey)
		MenuBind = chosenKey
		self:Notification("Info", "Menu visibility keybind updated to: " .. chosenKey.Name, 3)
	end)

	settingsTab:AddButton("Unload UI Framework Instance", function()
		self:Popup({
			Title = "Dismantle UI Engine?",
			Description = "This action will completely terminate running loops, clean up internal structural connections, and destroy the screen canvas.",
			Options = {
				{ Title = "Cancel", Type = "Secondary" },
				{
					Title = "Unload Framework",
					Type = "Danger",
					Callback = function() self:Destroy() end
				}
			}
		})
	end)

	-- 2. Credits Tab Profile
	local creditsTab = self:CreateTab("Credits")
	if self.Tabs["Credits"] and self.Tabs["Credits"].Button then
		self.Tabs["Credits"].Button.LayoutOrder = 9999 -- Pinned at absolute bottom
	end

	creditsTab:AddLabel("✨ ─── AERAMONT ARCHITECTURE ─── ✨")
	creditsTab:AddLabel("» Project Canvas: AeraUI")
	creditsTab:AddLabel("» Engineering: seally ♡")
	creditsTab:AddLabel("» Status: Made with absolute love.")
	creditsTab:AddLabel("────────────────────────────────────────")

	creditsTab:AddLabel("") 
	creditsTab:AddLabel("🌐 ─── SOCIAL DIRECTORY ─── 🌐")
	creditsTab:AddLabel("» Discord Handler: sealrl_")
	creditsTab:AddLabel("» TikTok Profile: @sealient")
	creditsTab:AddLabel("» Instagram Feed: @sealient_")
	creditsTab:AddLabel("» Digital Domain: sealient.github.io")
	creditsTab:AddLabel("────────────────────────────────────────")

	creditsTab:AddLabel("") 
	creditsTab:AddLabel("📦 ─── BUILD SPECIFICATIONS ─── 📦")
	creditsTab:AddLabel("» System Release: Luna Core [v1.0.0]")
	creditsTab:AddLabel("────────────────────────────────────────")

	creditsTab:AddButton("View Patch Notes", function()
		local patchNotesText = "couldnt pull"

		-- Safe wrapper that works in both Studio and Executors
		local success, response = pcall(function()
			if game:GetService("RunService"):IsStudio() then
				-- Roblox Studio method (Requires "Allow HTTP Requests" in Game Settings)
				return game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/Sealient/AeroLib/refs/heads/main/patchnotes.txt")
			else
				-- Executor method
				return game:HttpGet("https://raw.githubusercontent.com/Sealient/AeroLib/refs/heads/main/patchnotes.txt")
			end
		end)

		if success and response and #response > 0 then
			patchNotesText = response
		end

		self:Popup({
			Title = "Patch Notes",
			Description = patchNotesText,
			Options = {
				{ Title = "Close", Type = "Primary" }
			}
		})
	end)

	-- =======================================================
	-- CINEMATIC LOADING INTERACTIVE LAYER (MINIMALIST WIRE)
	-- =======================================================
	local loadingCanvas = Instance.new("Frame")
	loadingCanvas.Name = "LoadingCanvas"
	loadingCanvas.Size = UDim2.new(1, 0, 1, 0)
	loadingCanvas.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	loadingCanvas.BorderSizePixel = 0
	loadingCanvas.ZIndex = 500
	loadingCanvas.Parent = screenGui

	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Size = 0
	blurEffect.Parent = game:GetService("Lighting")
	TweenService:Create(blurEffect, TweenInfo.new(0.3), {Size = 8}):Play()

	local loadGroup = Instance.new("CanvasGroup")
	loadGroup.Size = UDim2.new(1, 0, 1, 0)
	loadGroup.BackgroundTransparency = 1
	loadGroup.Parent = loadingCanvas

	local logoLabel = Instance.new("TextLabel")
	logoLabel.Name = "LogoLabel"
	logoLabel.Size = UDim2.new(0, 300, 0, 30)
	logoLabel.Position = UDim2.new(0.5, -150, 0.5, -35)
	logoLabel.BackgroundTransparency = 1
	logoLabel.Text = "A E R A U I"
	logoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	logoLabel.TextSize = 16
	logoLabel.Font = Enum.Font.GothamBold
	logoLabel.Parent = loadGroup

	local barBackground = Instance.new("Frame")
	barBackground.Name = "BarBackground"
	barBackground.Size = UDim2.new(0, 180, 0, 2)
	barBackground.Position = UDim2.new(0.5, -90, 0.5, 5)
	barBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	barBackground.BorderSizePixel = 0
	barBackground.Parent = loadGroup
	addCorner(barBackground, 1)

	local barFill = Instance.new("Frame")
	barFill.Name = "BarFill"
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.BackgroundColor3 = THEME.Accent
	barFill.BorderSizePixel = 0
	barFill.Parent = barBackground
	addCorner(barFill, 1)

	local barGlow = Instance.new("ImageLabel")
	barGlow.Name = "BarGlow"
	barGlow.Size = UDim2.new(1, 40, 0, 20)
	barGlow.Position = UDim2.new(0, -20, 0, -9)
	barGlow.BackgroundTransparency = 1
	barGlow.Image = "rbxassetid://13809059810"
	barGlow.ImageColor3 = THEME.Accent
	barGlow.ImageTransparency = 0.6
	barGlow.ZIndex = barFill.ZIndex - 1
	barGlow.Parent = barFill

	local percentLabel = Instance.new("TextLabel")
	percentLabel.Name = "PercentTracker"
	percentLabel.Size = UDim2.new(0, 40, 0, 20)
	percentLabel.Position = UDim2.new(0.5, 95, 0.5, -4)
	percentLabel.BackgroundTransparency = 1
	percentLabel.Text = "0%"
	percentLabel.TextColor3 = Color3.fromRGB(150, 150, 155)
	percentLabel.TextSize = 10
	percentLabel.Font = Enum.Font.GothamSemibold
	percentLabel.TextXAlignment = Enum.TextXAlignment.Left
	percentLabel.Parent = loadGroup

	-- =======================================================
	-- CORE SEQUENCE EXECUTION & INTRO REVEAL
	-- =======================================================
	task.spawn(function()
		task.wait(0.1)

		for i = 0, 100 do
			percentLabel.Text = tostring(i) .. "%"

			TweenService:Create(barFill, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(i / 100, 0, 1, 0)
			}):Play()

			task.wait(math.random(1, 2) / 100)
		end

		task.wait(0.2)

		local fadeOut = TweenService:Create(loadGroup, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 1})
		fadeOut:Play()
		fadeOut.Completed:Wait()

		loadingCanvas:Destroy()
		TweenService:Create(blurEffect, TweenInfo.new(0.4), {Size = 0}):Play()

		-- Smooth structural scaling pop-up animation open
		mainFrame.Visible = true
		mainFrame.Size = UDim2.new(0, 560, 0, 360)

		-- FIX: We only tween the physical Size vector now. 
		-- Removing GroupTransparency calls stops Roblox from rendering a blurry texture cache.
		TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 600, 0, 380)
		}):Play()

		task.wait(0.4)
		blurEffect:Destroy()
	end)

	return self
end

-- Premium Tab Creator (Fully Updated with Black Backplate, Neon-Purple Outline & Fixed Layering)
function UILibrary:CreateTab(tabName: string)
	local tabData = {}
	tabData.Active = false -- Track this tab's active state inside its own metadata

	-- Increments tab count for sequential layout ordering
	self.TabCount = (self.TabCount or 0) + 1
	local currentOrder = self.TabCount

	-- Count existing tabs to calculate the delayed stagger sequence
	local tabCount = 0
	for _ in pairs(self.Tabs) do
		tabCount = tabCount + 1
	end
	local staggerDelay = tabCount * .5 -- 0.5s delay step per tab

	-- Rectangular Tab Navigation Button (Starts fully invisible)
	local tabButton = Instance.new("TextButton")
	tabButton.Name = tabName .. "_Button"
	tabButton.Size = UDim2.new(1, 0, 0, 34)
	tabButton.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
	tabButton.BackgroundTransparency = 1 -- Start hidden
	tabButton.BorderSizePixel = 0
	tabButton.Text = "     " .. tabName
	tabButton.TextColor3 = THEME.TextMuted
	tabButton.TextTransparency = 1 -- Start hidden
	tabButton.TextSize = 13
	tabButton.Font = THEME.Font
	tabButton.TextXAlignment = Enum.TextXAlignment.Left
	tabButton.Parent = self.TabList
	tabButton.LayoutOrder = currentOrder
	tabButton.ZIndex = 2 -- FIX: Forces tab buttons to stay layered above background panels
	addCorner(tabButton, 4)

	-- Outer Edge Border Stroke (Starts hidden)
	local buttonStroke = addStroke(tabButton, Color3.fromRGB(38, 38, 44), 1)
	buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	buttonStroke.Transparency = 1 -- Start hidden

	-- Sequential Fade-In Animation
	task.delay(staggerDelay, function()
		-- Smoothly transition button, text, and stroke to visible
		TweenService:Create(tabButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0,
			TextTransparency = 0
		}):Play()

		TweenService:Create(buttonStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0
		}):Play()
	end)

	-- Dynamic Content Page Container
	local pageContainer = Instance.new("ScrollingFrame")
	pageContainer.Name = tabName .. "_Page"
	pageContainer.Size = UDim2.new(1, 0, 1, 0)
	pageContainer.BackgroundTransparency = 1
	pageContainer.BorderSizePixel = 0
	pageContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	pageContainer.ScrollBarThickness = 0
	pageContainer.Visible = false
	pageContainer.Parent = self.DisplayArea
	pageContainer.ZIndex = 1 -- FIX: Keeps scrolling content layered cleanly beneath navigation overlays

	-- EXACT CUSTOM PADDING ADJUSTMENT: 3px Left, 1px Right
	local pagePadding = Instance.new("UIPadding")
	pagePadding.PaddingLeft = UDim.new(0, 1)
	pagePadding.PaddingRight = UDim.new(0, 3)
	pagePadding.PaddingTop = UDim.new(0, 2)
	pagePadding.PaddingBottom = UDim.new(0, 2)
	pagePadding.Parent = pageContainer

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.Padding = UDim.new(0, 10)
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Parent = pageContainer

	pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		pageContainer.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 10)
	end)

	-- Cache references for centralized tracking
	tabData.Button = tabButton
	tabData.Page = pageContainer
	tabData.Stroke = buttonStroke

	self.Tabs[tabName] = tabData

	-- Deactivate function (Restores neutral state, hides page elements)
	local function deactivate()
		if not tabData.Active then return end
		tabData.Active = false

		if pageContainer then
			pageContainer.Visible = false
		end

		if tabButton then
			TweenService:Create(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.fromRGB(12, 12, 14),
				TextColor3 = THEME.TextMuted
			}):Play()
		end

		if buttonStroke then
			TweenService:Create(buttonStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = Color3.fromRGB(38, 38, 44)
			}):Play()
		end
	end

	-- Activate function (Highlights selection, triggers staggered page content fade-in)
	local function activate()
		-- 1. Double-activation Guard
		if tabData.Active then return end
		tabData.Active = true
		self.ActiveTab = tabName

		-- 2. Safely Animate Tab Button States (Only if they exist)
		if tabButton then
			TweenService:Create(tabButton, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = THEME.SurfaceHover,
				TextColor3 = THEME.TextColor
			}):Play()
		end

		if buttonStroke then
			TweenService:Create(buttonStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = THEME.Accent or Color3.fromRGB(168, 85, 247) -- Swaps outline to purple theme accent
			}):Play()
		end

		-- 3. Safely Show Page Container
		if not pageContainer then return end
		pageContainer.Visible = true

		-- 4. Gather Visual Elements for Staggered Fade-in
		local visualElements = {}
		for _, row in ipairs(pageContainer:GetChildren()) do
			if row:IsA("Frame") and string.find(row.Name, "GridRow_") then
				for _, child in ipairs(row:GetChildren()) do
					if child:IsA("TextButton") or child:IsA("TextLabel") or child:IsA("Frame") then
						table.insert(visualElements, child)
					end
				end
			elseif row:IsA("TextLabel") or row:IsA("TextButton") then
				table.insert(visualElements, row)
			elseif row:IsA("Frame") and string.find(row.Name, "_SliderRow") then
				table.insert(visualElements, row)
			elseif row:IsA("Frame") and string.find(row.Name, "_DropdownRow") then
				table.insert(visualElements, row)
			elseif row:IsA("Frame") and string.find(row.Name, "_PickerRow") then
				table.insert(visualElements, row)
			end
		end

		-- 5. Execute Staggered Animations
		for elementIndex, element in ipairs(visualElements) do
			local delayTime = (elementIndex - 1) * 0.07

			if element:IsA("TextButton") then
				local isToggle = string.find(element.Name, "_Toggle") ~= nil

				if isToggle then
					element.BackgroundTransparency = 1 

					local textBg = element:FindFirstChild("TextBackground")
					local box = element:FindFirstChild("Box")

					if textBg then
						textBg.BackgroundTransparency = 1
						local label = textBg:FindFirstChild("Label")
						if label then label.TextTransparency = 1 end

						local textStroke = textBg:FindFirstChildWhichIsA("UIStroke")
						if textStroke then textStroke.Transparency = 1 end

						local checkmark = box and box:FindFirstChild("Checkmark")
						local boxStroke = box and box:FindFirstChildWhichIsA("UIStroke")

						local isCurrentlyToggled = false
						if checkmark and checkmark.TextTransparency < 0.5 then
							isCurrentlyToggled = true
						end

						if box then box.BackgroundTransparency = 1 end
						if boxStroke then boxStroke.Transparency = 1 end
						if checkmark then checkmark.TextTransparency = 1 end

						task.delay(delayTime, function()
							TweenService:Create(textBg, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
							if label then
								TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
							end
							if textStroke then
								TweenService:Create(textStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0}):Play()
							end

							if box then
								TweenService:Create(box, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
								if boxStroke then
									TweenService:Create(boxStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0}):Play()
								end
								if checkmark and isCurrentlyToggled then
									TweenService:Create(checkmark, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
								end
							end
						end)
					end
				else
					element.BackgroundTransparency = 1
					element.TextTransparency = 1

					local elementStroke = element:FindFirstChildWhichIsA("UIStroke")
					if elementStroke then elementStroke.Transparency = 1 end

					task.delay(delayTime, function()
						TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							BackgroundTransparency = 0,
							TextTransparency = 0
						}):Play()

						if elementStroke then
							TweenService:Create(elementStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								Transparency = 0
							}):Play()
						end
					end)
				end

			elseif element:IsA("TextLabel") then
				element.TextTransparency = 1
				task.delay(delayTime, function()
					TweenService:Create(element, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TextTransparency = 0
					}):Play()
				end)

			elseif element:IsA("Frame") and string.find(element.Name, "_SliderRow") then
				local title = element:FindFirstChild("Title")
				local ic = element:FindFirstChild("InteractContainer")
				local currentVal = ic and ic:FindFirstChild("CurrentValue")
				local maxVal = ic and ic:FindFirstChild("MaxValue")
				local trk = ic and ic:FindFirstChild("Track")
				local fl = trk and trk:FindFirstChild("Fill")
				local strk = trk and trk:FindFirstChildWhichIsA("UIStroke")

				if title then title.TextTransparency = 1 end
				if currentVal then currentVal.TextTransparency = 1 end
				if maxVal then maxVal.TextTransparency = 1 end
				if trk then trk.BackgroundTransparency = 1 end
				if fl then fl.BackgroundTransparency = 1 end
				if strk then strk.Transparency = 1 end

				task.delay(delayTime, function()
					if title then TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play() end
					if currentVal then TweenService:Create(currentVal, TweenInfo.new(0.3), {TextTransparency = 0}):Play() end
					if maxVal then TweenService:Create(maxVal, TweenInfo.new(0.3), {TextTransparency = 0}):Play() end
					if trk then TweenService:Create(trk, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play() end
					if fl then TweenService:Create(fl, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play() end
					if strk then TweenService:Create(strk, TweenInfo.new(0.3), {Transparency = 0}):Play() end
				end)

			elseif element:IsA("Frame") and string.find(element.Name, "_DropdownRow") then
				local hdr = element:FindFirstChild("Header")
				local title = hdr and hdr:FindFirstChild("Title")
				local valDisp = hdr and hdr:FindFirstChild("ValueDisplay")
				local chv = hdr and hdr:FindFirstChild("Chevron")
				local hStroke = hdr and hdr:FindFirstChildWhichIsA("UIStroke")

				if hdr then hdr.BackgroundTransparency = 1 end
				if title then title.TextTransparency = 1 end
				if valDisp then valDisp.TextTransparency = 1 end
				if chv then chv.TextTransparency = 1 end
				if hStroke then hStroke.Transparency = 1 end

				task.delay(delayTime, function()
					if hdr then TweenService:Create(hdr, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play() end
					if title then TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play() end
					if valDisp then TweenService:Create(valDisp, TweenInfo.new(0.3), {TextTransparency = 0}):Play() end
					if chv then TweenService:Create(chv, TweenInfo.new(0.3), {TextTransparency = 0}):Play() end
					if hStroke then TweenService:Create(hStroke, TweenInfo.new(0.3), {Transparency = 0}):Play() end
				end)

			elseif element:IsA("Frame") and string.find(element.Name, "_PickerRow") then
				local hdr = element:FindFirstChild("Header")
				local title = hdr and hdr:FindFirstChild("Title")
				local info = hdr and hdr:FindFirstChild("InfoDisplay")
				local indicator = hdr and hdr:FindFirstChild("ColorIndicator")
				local indStroke = indicator and indicator:FindFirstChildWhichIsA("UIStroke")
				local hStroke = hdr and hdr:FindFirstChildWhichIsA("UIStroke")

				if hdr then hdr.BackgroundTransparency = 1 end
				if title then title.TextTransparency = 1 end
				if info then info.TextTransparency = 1 end
				if indicator then indicator.BackgroundTransparency = 1 end
				if indStroke then indStroke.Transparency = 1 end
				if hStroke then hStroke.Transparency = 1 end

				task.delay(delayTime, function()
					if hdr then TweenService:Create(hdr, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play() end
					if title then TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play() end
					if info then TweenService:Create(info, TweenInfo.new(0.3), {TextTransparency = 0}):Play() end
					if indicator then TweenService:Create(indicator, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play() end
					if indStroke then TweenService:Create(indStroke, TweenInfo.new(0.3), {Transparency = 0}):Play() end
					if hStroke then TweenService:Create(hStroke, TweenInfo.new(0.3), {Transparency = 0}):Play() end
				end)
			end
		end
	end

	-- Expose activations inside Tab metadata
	tabData.Activate = activate
	tabData.Deactivate = deactivate

	-- Tab Connection Handler
	tabButton.MouseButton1Click:Connect(function()
		for otherTabName, otherTabData in pairs(self.Tabs) do
			if otherTabName ~= tabName then
				otherTabData.Deactivate()
			end
		end
		activate()
	end)

	-- Mouse Hover Effects
	tabButton.MouseEnter:Connect(function()
		if self.ActiveTab ~= tabName then
			TweenService:Create(tabButton, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(18, 18, 22),
				TextColor3 = THEME.TextColor
			}):Play()

			TweenService:Create(buttonStroke, TweenInfo.new(0.15), {
				Color = Color3.fromRGB(65, 65, 75)
			}):Play()
		end
	end)

	tabButton.MouseLeave:Connect(function()
		if self.ActiveTab ~= tabName then
			TweenService:Create(tabButton, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(12, 12, 14),
				TextColor3 = THEME.TextMuted
			}):Play()

			TweenService:Create(buttonStroke, TweenInfo.new(0.15), {
				Color = Color3.fromRGB(38, 38, 44)
			}):Play()
		end
	end)

	-- Automatically activate the first tab created
	if not self.ActiveTab then
		activate()
	end

	local tabMethods = {}
	local elementCount = 0
	local currentGridRow: Frame? = nil

	-- Helper function to generate a clean, horizontal 2-column row container
	local function createNewGridRow()
		elementCount = elementCount + 1

		local rowFrame = Instance.new("Frame")
		rowFrame.Name = "GridRow_" .. elementCount
		rowFrame.Size = UDim2.new(1, 0, 0, 38)
		rowFrame.BackgroundTransparency = 1
		rowFrame.BorderSizePixel = 0
		rowFrame.LayoutOrder = elementCount
		rowFrame.Parent = pageContainer
		rowFrame.ZIndex = 2 -- FIX: Restricts grid row elements from overlapping parent frame boundaries

		local rowLayout = Instance.new("UIListLayout")
		rowLayout.FillDirection = Enum.FillDirection.Horizontal
		rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
		rowLayout.Padding = UDim.new(0, 10)
		rowLayout.Parent = rowFrame

		currentGridRow = rowFrame
		return rowFrame
	end

	-- Content Page Buttons (Matte baseline with Interactive Accent Hovers)
	function tabMethods:AddButton(text: string, callback: () -> ())
		if not currentGridRow or #currentGridRow:GetChildren() >= 3 then
			createNewGridRow()
		end

		currentGridRow.Size = UDim2.new(1, 0, 0, 34)

		local buttonFrame = Instance.new("TextButton")
		buttonFrame.Name = text .. "_Interactive"
		buttonFrame.Size = UDim2.new(0.5, -5, 1, 0) 
		buttonFrame.BackgroundColor3 = THEME.Surface
		buttonFrame.BorderSizePixel = 0
		buttonFrame.Text = text
		buttonFrame.TextColor3 = THEME.TextMuted
		buttonFrame.TextSize = 12
		buttonFrame.Font = THEME.Font
		buttonFrame.LayoutOrder = #currentGridRow:GetChildren()
		buttonFrame.Parent = currentGridRow
		addCorner(buttonFrame, 5)

		-- Always visible baseline outline (Deep, clean matte charcoal outline)
		local stroke = addStroke(buttonFrame, Color3.fromRGB(0, 0, 0), 1, 0)

		-- Interactive Hover Animations
		buttonFrame.MouseEnter:Connect(function()
			TweenService:Create(buttonFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = THEME.SurfaceHover,
				TextColor3 = THEME.TextColor,
				Size = UDim2.new(0.5, -3, 1, 2),
				Position = UDim2.new(0, -1, 0, -1)
			}):Play()

			-- Outline shifts to the vibrant purple theme accent on hover
			TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = THEME.Accent
			}):Play()
		end)

		buttonFrame.MouseLeave:Connect(function()
			TweenService:Create(buttonFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = THEME.Surface,
				TextColor3 = THEME.TextMuted,
				Size = UDim2.new(0.5, -5, 1, 0),
				Position = UDim2.new(0, 0, 0, 0)
			}):Play()

			-- Stroke reverts back to its clean resting matte color
			TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = Color3.fromRGB(0, 0, 0)
			}):Play()
		end)

		-- Tactile Click Animations
		buttonFrame.MouseButton1Down:Connect(function()
			TweenService:Create(buttonFrame, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0.5, -7, 1, -2),
				Position = UDim2.new(0, 1, 0, 1),
				BackgroundColor3 = THEME.Background
			}):Play()
		end)

		buttonFrame.MouseButton1Up:Connect(function()
			TweenService:Create(buttonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				Size = UDim2.new(0.5, -3, 1, 2),
				Position = UDim2.new(0, -1, 0, -1),
				BackgroundColor3 = THEME.SurfaceHover
			}):Play()

			task.spawn(callback)
		end)
	end

	-- Content Page Labels (Always full-width rows)
	function tabMethods:AddLabel(text: string)
		-- Break the grid chain so the label gets its own clean line below
		currentGridRow = nil 

		elementCount = elementCount + 1
		local label = Instance.new("TextLabel")
		label.Name = "DescriptionLabel"
		label.Size = UDim2.new(1, 0, 0, 24)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = THEME.TextMuted
		label.TextSize = 13
		label.Font = THEME.Font
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.LayoutOrder = elementCount
		label.Parent = pageContainer
	end

	-- Content Page Toggles (Stealth standalone checkbox with background only behind the text)
	function tabMethods:AddToggle(text: string, default: boolean, callback: (boolean) -> ())
		local toggled = default or false

		-- Auto-grid routing system (fits 2 items per row, height 38)
		if not currentGridRow or #currentGridRow:GetChildren() >= 3 then
			createNewGridRow()
		end

		-- Background Click-Catcher (Invisible wrapper for the row half)
		local toggleFrame = Instance.new("TextButton")
		toggleFrame.Name = text .. "_Toggle"
		toggleFrame.Size = UDim2.new(0.5, -5, 1, 0)
		toggleFrame.BackgroundTransparency = 1 -- Completely invisible wrapper
		toggleFrame.BorderSizePixel = 0
		toggleFrame.Text = "" 
		toggleFrame.LayoutOrder = #currentGridRow:GetChildren()
		toggleFrame.Parent = currentGridRow

		-- 1. Standalone Checkbox (Positioned on the far left, completely floating)
		local box = Instance.new("Frame")
		box.Name = "Box"
		box.Size = UDim2.new(0, 18, 0, 18)
		box.Position = UDim2.new(0, 2, 0.5, -9) -- Aligned to the left edge
		box.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
		box.BorderSizePixel = 0
		box.Parent = toggleFrame
		addCorner(box, 4)

		local boxStroke = addStroke(box, Color3.fromRGB(45, 45, 52), 1, 0)

		-- Sharp Text-Based Checkmark
		local check = Instance.new("TextLabel")
		check.Name = "Checkmark"
		check.Size = UDim2.new(1, 0, 1, 0)
		check.BackgroundTransparency = 1
		check.Text = "✓"
		check.TextColor3 = Color3.fromRGB(255, 255, 255)
		check.TextSize = 14
		check.Font = Enum.Font.GothamBold
		check.TextTransparency = 1
		check.Parent = box

		-- 2. Text Background Panel (Only wraps behind the text label)
		local textBg = Instance.new("Frame")
		textBg.Name = "TextBackground"
		textBg.Size = UDim2.new(1, -28, 1, 0) -- Takes up remaining space after checkbox
		textBg.Position = UDim2.new(0, 28, 0, 0) -- Shifted right to leave room for checkbox
		textBg.BackgroundColor3 = THEME.Surface
		textBg.BorderSizePixel = 0
		textBg.Parent = toggleFrame
		addCorner(textBg, 5)

		-- Deep pure black outline strictly around the text background
		local stroke = addStroke(textBg, Color3.fromRGB(0, 0, 0), 1, 0)

		-- Toggle Label Text (Centered nicely inside the text background)
		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.new(1, -20, 1, 0)
		label.Position = UDim2.new(0, 10, 0, 0) -- Padding inside the text card
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = THEME.TextMuted
		label.TextSize = 12
		label.Font = THEME.Font
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = textBg

		-- Internal Toggle State Visual Updater
		local function updateVisuals(instant: boolean)
			local duration = instant and 0 or 0.15
			local ease = Enum.EasingStyle.Quad

			if toggled then
				-- Checked: Fill box with Accent Purple & show checkmark
				TweenService:Create(box, TweenInfo.new(duration, ease), {
					BackgroundColor3 = THEME.Accent
				}):Play()
				TweenService:Create(boxStroke, TweenInfo.new(duration, ease), {
					Color = THEME.Accent
				}):Play()
				TweenService:Create(check, TweenInfo.new(duration, ease), {
					TextTransparency = 0
				}):Play()
			else
				-- Unchecked: Back to dark hollow box
				TweenService:Create(box, TweenInfo.new(duration, ease), {
					BackgroundColor3 = Color3.fromRGB(12, 12, 14)
				}):Play()
				TweenService:Create(boxStroke, TweenInfo.new(duration, ease), {
					Color = Color3.fromRGB(45, 45, 52)
				}):Play()
				TweenService:Create(check, TweenInfo.new(duration, ease), {
					TextTransparency = 1
				}):Play()
			end
		end

		-- Set initial state
		updateVisuals(true)

		-- Clean Hover states (Only affects the text background panel and text colors)
		toggleFrame.MouseEnter:Connect(function()
			TweenService:Create(textBg, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				BackgroundColor3 = THEME.SurfaceHover
			}):Play()
			TweenService:Create(stroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Color = THEME.Accent -- Transitions outline of text box to purple
			}):Play()
			TweenService:Create(label, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				TextColor3 = THEME.TextColor
			}):Play()
		end)

		toggleFrame.MouseLeave:Connect(function()
			TweenService:Create(textBg, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				BackgroundColor3 = THEME.Surface
			}):Play()
			TweenService:Create(stroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Color = Color3.fromRGB(0, 0, 0) -- Reverts back to deep pure black
			}):Play()
			TweenService:Create(label, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				TextColor3 = THEME.TextMuted
			}):Play()
		end)

		-- Snappy click feedback (only dims the text card background)
		toggleFrame.MouseButton1Down:Connect(function()
			TweenService:Create(textBg, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
				BackgroundColor3 = THEME.Background
			}):Play()
		end)

		toggleFrame.MouseButton1Up:Connect(function()
			toggled = not toggled
			updateVisuals(false)

			TweenService:Create(textBg, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
				BackgroundColor3 = THEME.SurfaceHover
			}):Play()

			task.spawn(callback, toggled)
		end)
	end

	-- Content Page Sliders (Full-width row, left-aligned text, right-aligned slider with values)
	function tabMethods:AddSlider(text: string, min: number, max: number, default: number, callback: (number) -> ())
		-- Break the grid chain so the slider occupies a clean full-row slot
		currentGridRow = nil 
		elementCount = elementCount + 1

		local currentValue = math.clamp(default or min, min, max)

		-- Main row wrapper frame
		local sliderFrame = Instance.new("Frame")
		sliderFrame.Name = text .. "_SliderRow"
		sliderFrame.Size = UDim2.new(1, 0, 0, 34)
		sliderFrame.BackgroundTransparency = 1
		sliderFrame.BorderSizePixel = 0
		sliderFrame.LayoutOrder = elementCount
		sliderFrame.Parent = pageContainer

		-- Left-aligned Slider Title Text
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "Title"
		titleLabel.Size = UDim2.new(0.4, 0, 1, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = text
		titleLabel.TextColor3 = THEME.TextMuted
		titleLabel.TextSize = 13
		titleLabel.Font = THEME.Font
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.TextYAlignment = Enum.TextYAlignment.Center
		titleLabel.TextTransparency = 1 -- Start hidden for tab fade-in animation
		titleLabel.Parent = sliderFrame

		-- Right-aligned Interaction Assembly (Values + Bar)
		local interactContainer = Instance.new("Frame")
		interactContainer.Name = "InteractContainer"
		interactContainer.Size = UDim2.new(0.6, 0, 1, 0)
		interactContainer.Position = UDim2.new(0.4, 0, 0, 0)
		interactContainer.BackgroundTransparency = 1
		interactContainer.Parent = sliderFrame

		-- Current Value Text (Left side of the slider)
		local currentLabel = Instance.new("TextLabel")
		currentLabel.Name = "CurrentValue"
		currentLabel.Size = UDim2.new(0, 35, 1, 0)
		currentLabel.Position = UDim2.new(0, 0, 0, 0)
		currentLabel.BackgroundTransparency = 1
		currentLabel.Text = tostring(currentValue)
		currentLabel.TextColor3 = THEME.TextColor
		currentLabel.TextSize = 12
		currentLabel.Font = THEME.Font
		currentLabel.TextXAlignment = Enum.TextXAlignment.Left
		currentLabel.TextYAlignment = Enum.TextYAlignment.Center
		currentLabel.TextTransparency = 1 -- Start hidden for tab fade-in animation
		currentLabel.Parent = interactContainer

		-- Max Value Text (Right side of the slider)
		local maxLabel = Instance.new("TextLabel")
		maxLabel.Name = "MaxValue"
		maxLabel.Size = UDim2.new(0, 35, 1, 0)
		maxLabel.Position = UDim2.new(1, -35, 0, 0)
		maxLabel.BackgroundTransparency = 1
		maxLabel.Text = tostring(max)
		maxLabel.TextColor3 = THEME.TextMuted
		maxLabel.TextSize = 12
		maxLabel.Font = THEME.Font
		maxLabel.TextXAlignment = Enum.TextXAlignment.Right
		maxLabel.TextYAlignment = Enum.TextYAlignment.Center
		maxLabel.TextTransparency = 1 -- Start hidden for tab fade-in animation
		maxLabel.Parent = interactContainer

		-- Slider Dark Hollow Track Background (Turned into an ImageButton so it captures clicks anywhere on it)
		local track = Instance.new("ImageButton")
		track.Name = "Track"
		track.Size = UDim2.new(1, -90, 0, 6)
		track.Position = UDim2.new(0, 45, 0.5, -3)
		track.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		track.BackgroundTransparency = 1 -- Controlled by the stagger animation
		track.BorderSizePixel = 0
		track.Image = ""
		track.AutoButtonColor = false
		track.Parent = interactContainer
		addCorner(track, 3)
		local trackStroke = addStroke(track, Color3.fromRGB(35, 35, 42), 1)
		trackStroke.Transparency = 1 -- Start hidden for tab fade-in animation

		-- Dynamic Purple Fill Bar
		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = THEME.Accent
		fill.BackgroundTransparency = 1 -- Controlled by the stagger animation
		fill.BorderSizePixel = 0
		fill.Parent = track
		addCorner(fill, 3)

		-- Invisible Hitbox Knob for easy tracking/dragging
		local knob = Instance.new("ImageButton")
		knob.Name = "InvisibleKnob"
		knob.Size = UDim2.new(0, 24, 0, 24)
		knob.Position = UDim2.new(fill.Size.X.Scale, -12, 0.5, -12)
		knob.BackgroundTransparency = 1
		knob.Image = ""
		knob.Parent = track

		-- Dragging state variables
		local isDragging = false
		local UserInputService = game:GetService("UserInputService")

		local function updateSlider(input: InputObject)
			local trackWidth = track.AbsoluteSize.X
			if trackWidth <= 0 then return end

			local mouseX = input.Position.X
			local relativeX = math.clamp(mouseX - track.AbsolutePosition.X, 0, trackWidth)
			local percentage = relativeX / trackWidth

			currentValue = math.round(min + (percentage * (max - min)))
			currentLabel.Text = tostring(currentValue)

			-- Smooth visual feedback updates
			TweenService:Create(fill, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
				Size = UDim2.new(percentage, 0, 1, 0)
			}):Play()

			TweenService:Create(knob, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
				Position = UDim2.new(percentage, -12, 0.5, -12)
			}):Play()

			task.spawn(callback, currentValue)
		end

		-- Direct click-anywhere tracking logic on the background track
		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isDragging = true
				TweenService:Create(trackStroke, TweenInfo.new(0.15), {Color = THEME.Accent}):Play()
				TweenService:Create(titleLabel, TweenInfo.new(0.15), {TextColor3 = THEME.TextColor}):Play()
				updateSlider(input)
			end
		end)

		-- Knob drag tracking connections
		knob.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isDragging = true
				TweenService:Create(trackStroke, TweenInfo.new(0.15), {Color = THEME.Accent}):Play()
				TweenService:Create(titleLabel, TweenInfo.new(0.15), {TextColor3 = THEME.TextColor}):Play()
				updateSlider(input)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateSlider(input)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if isDragging then
					isDragging = false
					TweenService:Create(trackStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(35, 35, 42)}):Play()
					TweenService:Create(titleLabel, TweenInfo.new(0.15), {TextColor3 = THEME.TextMuted}):Play()
				end
			end
		end)

		-- Hover effects for the active line track
		sliderFrame.MouseEnter:Connect(function()
			if not isDragging then
				TweenService:Create(trackStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(65, 65, 75)}):Play()
				TweenService:Create(titleLabel, TweenInfo.new(0.15), {TextColor3 = THEME.TextColor}):Play()
			end
		end)

		sliderFrame.MouseLeave:Connect(function()
			if not isDragging then
				TweenService:Create(trackStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(35, 35, 42)}):Play()
				TweenService:Create(titleLabel, TweenInfo.new(0.15), {TextColor3 = THEME.TextMuted}):Play()
			end
		end)
	end

	-- Content Page Dropdowns (Full-width row, smoothly expanding selection list)
	function tabMethods:AddDropdown(text: string, options: {string}, default: string?, callback: (string) -> ())
		-- Break the grid chain so the dropdown occupies a clean full-row slot
		currentGridRow = nil 
		elementCount = elementCount + 1

		local selectedValue = default or options[1] or ""
		local isOpen = false
		local optionButtons = {}

		-- Main container for the dropdown row layout
		local dropdownContainer = Instance.new("Frame")
		dropdownContainer.Name = text .. "_DropdownRow"
		dropdownContainer.Size = UDim2.new(1, 0, 0, 34) -- Matches default button height when closed
		dropdownContainer.BackgroundTransparency = 1
		dropdownContainer.BorderSizePixel = 0
		dropdownContainer.ClipsDescendants = true -- Crucial for clipping the expanding options list
		dropdownContainer.LayoutOrder = elementCount
		dropdownContainer.Parent = pageContainer

		local containerLayout = Instance.new("UIListLayout")
		containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
		containerLayout.Padding = UDim.new(0, 4)
		containerLayout.Parent = dropdownContainer

		-- 1. Main Header Card (The clickable button)
		local header = Instance.new("TextButton")
		header.Name = "Header"
		header.Size = UDim2.new(1, 0, 0, 34)
		header.BackgroundColor3 = THEME.Surface
		header.BorderSizePixel = 0
		header.BackgroundTransparency = 0
		header.Text = ""
		header.AutoButtonColor = false
		header.LayoutOrder = 1
		header.Parent = dropdownContainer
		addCorner(header, 5)
		local headerStroke = addStroke(header, Color3.fromRGB(0, 0, 0), 1)

		-- Header Title / Label
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "Title"
		titleLabel.Size = UDim2.new(0.5, -15, 1, 0)
		titleLabel.Position = UDim2.new(0, 12, 0, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = text .. ": "
		titleLabel.TextColor3 = THEME.TextMuted
		titleLabel.TextSize = 12
		titleLabel.Font = THEME.Font
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.TextTransparency = 0 -- Initialized to standard visibility; controlled by tab switcher
		titleLabel.Parent = header

		-- Selected Value Display
		local valueLabel = Instance.new("TextLabel")
		valueLabel.Name = "ValueDisplay"
		valueLabel.Size = UDim2.new(0.5, -25, 1, 0)
		valueLabel.Position = UDim2.new(0.5, -10, 0, 0)
		valueLabel.BackgroundTransparency = 1
		valueLabel.Text = selectedValue
		valueLabel.TextColor3 = THEME.TextColor
		valueLabel.TextSize = 12
		valueLabel.Font = THEME.Font
		valueLabel.TextXAlignment = Enum.TextXAlignment.Right
		valueLabel.TextTransparency = 0 -- Initialized to standard visibility; controlled by tab switcher
		valueLabel.Parent = header

		-- Animated Chevron Arrow Indicator
		local chevron = Instance.new("TextLabel")
		chevron.Name = "Chevron"
		chevron.Size = UDim2.new(0, 24, 0, 24)
		chevron.Position = UDim2.new(1, -30, 0.5, -12)
		chevron.BackgroundTransparency = 1
		chevron.Text = "▼"
		chevron.TextColor3 = THEME.TextMuted
		chevron.TextSize = 10
		chevron.Font = Enum.Font.GothamBold
		chevron.TextTransparency = 0 -- Initialized to standard visibility; controlled by tab switcher
		chevron.Parent = header

		-- 2. Scrolling Panel for Options
		local optionsList = Instance.new("Frame")
		optionsList.Name = "OptionsList"
		optionsList.Size = UDim2.new(1, 0, 0, 0) -- Starts at 0 height collapsed
		optionsList.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
		optionsList.BorderSizePixel = 0
		optionsList.LayoutOrder = 2
		optionsList.Parent = dropdownContainer
		addCorner(optionsList, 5)
		local listStroke = addStroke(optionsList, Color3.fromRGB(35, 35, 42), 1)
		listStroke.Transparency = 1

		local listLayout = Instance.new("UIListLayout")
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding = UDim.new(0, 2)
		listLayout.Parent = optionsList

		local listPadding = Instance.new("UIPadding")
		listPadding.PaddingLeft = UDim.new(0, 4)
		listPadding.PaddingRight = UDim.new(0, 4)
		listPadding.PaddingTop = UDim.new(0, 4)
		listPadding.PaddingBottom = UDim.new(0, 4)
		listPadding.Parent = optionsList

		-- Populate options dynamically
		for i, optionName in ipairs(options) do
			local optButton = Instance.new("TextButton")
			optButton.Name = optionName .. "_Option"
			optButton.Size = UDim2.new(1, 0, 0, 28)
			optButton.BackgroundColor3 = (optionName == selectedValue) and THEME.SurfaceHover or Color3.fromRGB(16, 16, 20)
			optButton.BackgroundTransparency = 1 -- Controlled by dropdown expand animation dynamically
			optButton.BorderSizePixel = 0
			optButton.Text = "   " .. optionName
			optButton.TextColor3 = (optionName == selectedValue) and THEME.TextColor or THEME.TextMuted
			optButton.TextTransparency = 1 -- Controlled by dropdown expand animation dynamically
			optButton.TextSize = 11
			optButton.Font = THEME.Font
			optButton.TextXAlignment = Enum.TextXAlignment.Left
			optButton.LayoutOrder = i
			optButton.Parent = optionsList
			addCorner(optButton, 4)

			table.insert(optionButtons, optButton)

			-- Option Interaction Event Handlers
			optButton.MouseEnter:Connect(function()
				if selectedValue ~= optionName then
					TweenService:Create(optButton, TweenInfo.new(0.12), {
						BackgroundColor3 = Color3.fromRGB(24, 24, 30),
						TextColor3 = THEME.TextColor
					}):Play()
				end
			end)

			optButton.MouseLeave:Connect(function()
				if selectedValue ~= optionName then
					TweenService:Create(optButton, TweenInfo.new(0.12), {
						BackgroundColor3 = Color3.fromRGB(16, 16, 20),
						TextColor3 = THEME.TextMuted
					}):Play()
				end
			end)

			optButton.MouseButton1Click:Connect(function()
				-- Guard clause: ignore selection logic if menu is closing or closed
				if not isOpen then return end 

				selectedValue = optionName
				valueLabel.Text = selectedValue

				-- Clean up visual selection states across elements
				for _, btn in ipairs(optionButtons) do
					local match = (btn.Name == selectedValue .. "_Option")
					TweenService:Create(btn, TweenInfo.new(0.12), {
						BackgroundColor3 = match and THEME.SurfaceHover or Color3.fromRGB(16, 16, 20),
						TextColor3 = match and THEME.TextColor or THEME.TextMuted
					}):Play()
				end

				-- Flip open state flag immediately to block spam clicking
				isOpen = false
				task.wait(0.1)

				-- Smooth Collapse Tweens
				TweenService:Create(chevron, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Rotation = 0}):Play()
				TweenService:Create(optionsList, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 0)}):Play()
				TweenService:Create(listStroke, TweenInfo.new(0.15), {Transparency = 1}):Play()

				for _, btn in ipairs(optionButtons) do
					TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
				end

				TweenService:Create(dropdownContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, 34)}):Play()

				task.spawn(callback, selectedValue)
			end)
		end

		-- Dynamic size calculations based on number of items loaded
		local expandedListHeight = (#options * 30) + 6

		-- Open / Close Main Menu Click Event Controller
		header.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			local easeStyle = Enum.EasingStyle.Quad

			if isOpen then
				-- Expand Sequence
				TweenService:Create(chevron, TweenInfo.new(0.25, easeStyle), {Rotation = -180}):Play()
				TweenService:Create(optionsList, TweenInfo.new(0.25, easeStyle), {Size = UDim2.new(1, 0, 0, expandedListHeight)}):Play()
				TweenService:Create(listStroke, TweenInfo.new(0.25), {Transparency = 0}):Play()

				local fullContainerHeight = 34 + 4 + expandedListHeight
				TweenService:Create(dropdownContainer, TweenInfo.new(0.25, easeStyle), {Size = UDim2.new(1, 0, 0, fullContainerHeight)}):Play()

				-- Staggered cell text fade reveal playback loop
				for index, btn in ipairs(optionButtons) do
					task.delay((index - 1) * 0.03, function()
						if isOpen then
							TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
						end
					end)
				end
			else
				-- Collapse Sequence
				TweenService:Create(chevron, TweenInfo.new(0.25, easeStyle), {Rotation = 0}):Play()
				TweenService:Create(optionsList, TweenInfo.new(0.25, easeStyle), {Size = UDim2.new(1, 0, 0, 0)}):Play()
				TweenService:Create(listStroke, TweenInfo.new(0.15), {Transparency = 1}):Play()

				for _, btn in ipairs(optionButtons) do
					TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
				end

				TweenService:Create(dropdownContainer, TweenInfo.new(0.25, easeStyle), {Size = UDim2.new(1, 0, 0, 34)}):Play()
			end
		end)

		-- Aesthetic Menu Header Hover Animations
		header.MouseEnter:Connect(function()
			TweenService:Create(header, TweenInfo.new(0.15), {BackgroundColor3 = THEME.SurfaceHover}):Play()
			TweenService:Create(headerStroke, TweenInfo.new(0.15), {Color = THEME.Accent}):Play()
			TweenService:Create(titleLabel, TweenInfo.new(0.15), {TextColor3 = THEME.TextColor}):Play()
			TweenService:Create(chevron, TweenInfo.new(0.15), {TextColor3 = THEME.TextColor}):Play()
		end)

		header.MouseLeave:Connect(function()
			TweenService:Create(header, TweenInfo.new(0.15), {BackgroundColor3 = THEME.Surface}):Play()
			TweenService:Create(headerStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(0, 0, 0)}):Play()
			TweenService:Create(titleLabel, TweenInfo.new(0.15), {TextColor3 = THEME.TextMuted}):Play()
			TweenService:Create(chevron, TweenInfo.new(0.15), {TextColor3 = THEME.TextMuted}):Play()
		end)
	end

	-- Content Page Color Pickers (Premium design, multi-readout, native rainbow spectrum)
	function tabMethods:AddColorPicker(text: string, defaultColor: Color3, callback: (Color3) -> ())
		currentGridRow = nil 
		elementCount = elementCount + 1

		local selectedColor = defaultColor or Color3.fromRGB(255, 255, 255)
		local currentH, currentS, currentV = selectedColor:ToHSV()
		local isOpen = false

		-- Main row layout wrapper
		local pickerContainer = Instance.new("Frame")
		pickerContainer.Name = text .. "_PickerRow"
		pickerContainer.Size = UDim2.new(1, 0, 0, 34)
		pickerContainer.BackgroundTransparency = 1
		pickerContainer.BorderSizePixel = 0
		pickerContainer.ClipsDescendants = true
		pickerContainer.LayoutOrder = elementCount
		pickerContainer.Parent = pageContainer

		local containerLayout = Instance.new("UIListLayout")
		containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
		containerLayout.Padding = UDim.new(0, 6)
		containerLayout.Parent = pickerContainer

		-- ==========================================
		-- 1. HEADER TRIGGER (The main control card)
		-- ==========================================
		local header = Instance.new("TextButton")
		header.Name = "Header"
		header.Size = UDim2.new(1, 0, 0, 34)
		header.BackgroundColor3 = THEME.Surface
		header.BackgroundTransparency = 0
		header.BorderSizePixel = 0
		header.Text = ""
		header.AutoButtonColor = false
		header.LayoutOrder = 1
		header.Parent = pickerContainer
		addCorner(header, 5)
		local headerStroke = addStroke(header, Color3.fromRGB(0, 0, 0), 1)

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "Title"
		titleLabel.Size = UDim2.new(0.4, 0, 1, 0)
		titleLabel.Position = UDim2.new(0, 12, 0, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = text
		titleLabel.TextColor3 = THEME.TextMuted
		titleLabel.TextSize = 12
		titleLabel.Font = THEME.Font
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Parent = header

		-- Minimalist live display (HEX format)
		local infoLabel = Instance.new("TextLabel")
		infoLabel.Name = "InfoDisplay"
		infoLabel.Size = UDim2.new(0.4, 0, 1, 0)
		infoLabel.Position = UDim2.new(0.6, -42, 0, 0)
		infoLabel.BackgroundTransparency = 1
		infoLabel.Text = string.format("#%02X%02X%02X", selectedColor.R*255, selectedColor.G*255, selectedColor.B*255)
		infoLabel.TextColor3 = THEME.TextMuted
		infoLabel.TextSize = 11
		infoLabel.Font = THEME.Font
		infoLabel.TextXAlignment = Enum.TextXAlignment.Right
		infoLabel.Parent = header

		-- Color Preview Pill Indicator
		local colorIndicator = Instance.new("Frame")
		colorIndicator.Name = "ColorIndicator"
		colorIndicator.Size = UDim2.new(0, 24, 0, 16)
		colorIndicator.Position = UDim2.new(1, -36, 0.5, -8)
		colorIndicator.BackgroundColor3 = selectedColor
		colorIndicator.BorderSizePixel = 0
		colorIndicator.Parent = header
		addCorner(colorIndicator, 4)
		addStroke(colorIndicator, Color3.fromRGB(0, 0, 0), 1)

		-- ==========================================
		-- 2. EXPANDED PALETTE DOCK
		-- ==========================================
		local canvasPanel = Instance.new("Frame")
		canvasPanel.Name = "CanvasPanel"
		canvasPanel.Size = UDim2.new(1, 0, 0, 0)
		canvasPanel.BackgroundColor3 = Color3.fromRGB(11, 11, 13)
		canvasPanel.BorderSizePixel = 0
		canvasPanel.LayoutOrder = 2
		canvasPanel.Parent = pickerContainer
		addCorner(canvasPanel, 6)
		local canvasStroke = addStroke(canvasPanel, Color3.fromRGB(32, 32, 38), 1)
		canvasStroke.Transparency = 1

		-- Saturation / Value Main Canvas Window
		local svCanvas = Instance.new("ImageButton")
		svCanvas.Name = "SVCanvas"
		svCanvas.Size = UDim2.new(1, -154, 0, 116) -- Leaves room on right side for the input readings
		svCanvas.Position = UDim2.new(0, 12, 0, 12)
		svCanvas.Image = "rbxassetid://4155801252"
		svCanvas.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
		svCanvas.AutoButtonColor = false
		svCanvas.BorderSizePixel = 0
		svCanvas.Parent = canvasPanel
		addCorner(svCanvas, 4)
		addStroke(svCanvas, Color3.fromRGB(24, 24, 28), 1)

		-- Crosshair Target Pin
		local crosshair = Instance.new("Frame")
		crosshair.Name = "Crosshair"
		crosshair.Size = UDim2.new(0, 10, 0, 10)
		crosshair.Position = UDim2.new(currentS, -5, 1 - currentV, -5)
		crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		crosshair.BorderSizePixel = 0
		crosshair.Parent = svCanvas
		addCorner(crosshair, 5)
		addStroke(crosshair, Color3.fromRGB(0, 0, 0), 1.5)

		-- ==========================================
		-- SIDE METRIC DATA READOUTS (RGB Boxes)
		-- ==========================================
		local metricsFrame = Instance.new("Frame")
		metricsFrame.Name = "Metrics"
		metricsFrame.Size = UDim2.new(0, 118, 0, 116)
		metricsFrame.Position = UDim2.new(1, -130, 0, 12)
		metricsFrame.BackgroundTransparency = 1
		metricsFrame.Parent = canvasPanel

		local metricsLayout = Instance.new("UIListLayout")
		metricsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		metricsLayout.Padding = UDim.new(0, 4)
		metricsLayout.Parent = metricsFrame

		local function createMetricRow(labelName, initValue)
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 36)
			row.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
			row.BorderSizePixel = 0
			row.Parent = metricsFrame
			addCorner(row, 4)
			addStroke(row, Color3.fromRGB(24, 24, 28), 1)

			local tag = Instance.new("TextLabel")
			tag.Size = UDim2.new(0, 24, 1, 0)
			tag.Position = UDim2.new(0, 10, 0, 0)
			tag.BackgroundTransparency = 1
			tag.Text = labelName
			tag.TextColor3 = THEME.TextMuted
			tag.TextSize = 11
			tag.Font = THEME.Font
			tag.TextXAlignment = Enum.TextXAlignment.Left
			tag.Parent = row

			local val = Instance.new("TextLabel")
			val.Name = "Value"
			val.Size = UDim2.new(1, -44, 1, 0)
			val.Position = UDim2.new(0, 34, 0, 0)
			val.BackgroundTransparency = 1
			val.Text = tostring(initValue)
			val.TextColor3 = THEME.TextColor
			val.TextSize = 11
			val.Font = THEME.Font
			val.TextXAlignment = Enum.TextXAlignment.Right
			val.Parent = row

			return val
		end

		local rText = createMetricRow("R", math.round(selectedColor.R * 255))
		local gText = createMetricRow("G", math.round(selectedColor.G * 255))
		local bText = createMetricRow("B", math.round(selectedColor.B * 255))

		-- ==========================================
		-- NATIVE CRUNCHY RAINBOW HUE SLIDER
		-- ==========================================
		local hueSlider = Instance.new("ImageButton")
		hueSlider.Name = "HueSlider"
		hueSlider.Size = UDim2.new(1, -24, 0, 14)
		hueSlider.Position = UDim2.new(0, 12, 0, 142)
		hueSlider.AutoButtonColor = false
		hueSlider.BorderSizePixel = 0
		hueSlider.Parent = canvasPanel
		addCorner(hueSlider, 4)
		addStroke(hueSlider, Color3.fromRGB(24, 24, 28), 1)

		-- Crisp mathematically exact 7-point gradient mapping override
		local rainbowGradient = Instance.new("UIGradient")
		rainbowGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),     -- Red
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),   -- Yellow
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),     -- Green
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),   -- Cyan
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),     -- Blue
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),   -- Magenta
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))      -- Back to Red loop
		})
		rainbowGradient.Parent = hueSlider

		-- Slidemarker Ring Pin Indicator
		local hueMarker = Instance.new("Frame")
		hueMarker.Name = "Marker"
		hueMarker.Size = UDim2.new(0, 6, 1, 4)
		hueMarker.Position = UDim2.new(currentH, -3, 0, -2)
		hueMarker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		hueMarker.BorderSizePixel = 0
		hueMarker.Parent = hueSlider
		addCorner(hueMarker, 2)
		addStroke(hueMarker, Color3.fromRGB(0, 0, 0), 1.5)

		-- ==========================================
		-- LOGIC AND CALCULATIONS
		-- ==========================================
		local UserInputService = game:GetService("UserInputService")
		local svDragging = false
		local hDragging = false

		local function updateColor()
			selectedColor = Color3.fromHSV(currentH, currentS, currentV)
			colorIndicator.BackgroundColor3 = selectedColor
			svCanvas.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)

			-- Update Text Readouts
			infoLabel.Text = string.format("#%02X%02X%02X", math.round(selectedColor.R*255), math.round(selectedColor.G*255), math.round(selectedColor.B*255))
			rText.Text = tostring(math.round(selectedColor.R * 255))
			gText.Text = tostring(math.round(selectedColor.G * 255))
			bText.Text = tostring(math.round(selectedColor.B * 255))

			task.spawn(callback, selectedColor)
		end

		local function updateSV(input)
			local sizeX, sizeY = svCanvas.AbsoluteSize.X, svCanvas.AbsoluteSize.Y
			local posX = math.clamp(input.Position.X - svCanvas.AbsolutePosition.X, 0, sizeX)
			local posY = math.clamp(input.Position.Y - svCanvas.AbsolutePosition.Y, 0, sizeY)

			currentS = posX / sizeX
			currentV = 1 - (posY / sizeY)

			crosshair.Position = UDim2.new(currentS, -5, 1 - currentV, -5)
			updateColor()
		end

		local function updateH(input)
			local sizeX = hueSlider.AbsoluteSize.X
			local posX = math.clamp(input.Position.X - hueSlider.AbsolutePosition.X, 0, sizeX)

			currentH = posX / sizeX
			hueMarker.Position = UDim2.new(currentH, -3, 0, -2)
			updateColor()
		end

		svCanvas.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				svDragging = true
				updateSV(input)
			end
		end)

		hueSlider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				hDragging = true
				updateH(input)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				if svDragging then updateSV(input) end
				if hDragging then updateH(input) end
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				svDragging = false
				hDragging = false
			end
		end)

		-- Open/Close Dropdown Event Controller
		header.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			local targetHeight = isOpen and 204 or 34   -- Expanded bounds safely clearing components
			local canvasTargetHeight = isOpen and 168 or 0
			local transTarget = isOpen and 0 or 1

			TweenService:Create(pickerContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
			TweenService:Create(canvasPanel, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(1, 0, 0, canvasTargetHeight)}):Play()
			TweenService:Create(canvasStroke, TweenInfo.new(0.15), {Transparency = transTarget}):Play()
		end)

		-- Aesthetic Menu Header Hover Animations
		header.MouseEnter:Connect(function()
			TweenService:Create(header, TweenInfo.new(0.15), {BackgroundColor3 = THEME.SurfaceHover}):Play()
			TweenService:Create(headerStroke, TweenInfo.new(0.15), {Color = THEME.Accent}):Play()
			TweenService:Create(titleLabel, TweenInfo.new(0.15), {TextColor3 = THEME.TextColor}):Play()
			TweenService:Create(infoLabel, TweenInfo.new(0.15), {TextColor3 = THEME.TextColor}):Play()
		end)

		header.MouseLeave:Connect(function()
			TweenService:Create(header, TweenInfo.new(0.15), {BackgroundColor3 = THEME.Surface}):Play()
			TweenService:Create(headerStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(0, 0, 0)}):Play()
			TweenService:Create(titleLabel, TweenInfo.new(0.15), {TextColor3 = THEME.TextMuted}):Play()
			TweenService:Create(infoLabel, TweenInfo.new(0.15), {TextColor3 = THEME.TextMuted}):Play()
		end)
	end

	-- Add Interactive Keybind Component to tabMethods
	function tabMethods:AddKeybind(text: string, defaultKey: Enum.KeyCode | Enum.UserInputType, callback: (Enum.KeyCode | Enum.UserInputType) -> ())
		local currentKey = defaultKey or Enum.KeyCode.Unknown
		local isBinding = false

		-- 1. Resolve Target Page Container
		local targetPage = pageContainer

		-- 2. Main Component Container Row
		local keybindRow = Instance.new("Frame")
		keybindRow.Name = text .. "_KeybindContainer"
		keybindRow.Size = UDim2.new(1, 0, 0, 38)
		keybindRow.BackgroundColor3 = THEME.Surface or Color3.fromRGB(18, 18, 22)
		keybindRow.BorderSizePixel = 0
		keybindRow.Parent = targetPage
		addCorner(keybindRow, 5)

		local cardStroke = addStroke(keybindRow, Color3.fromRGB(0, 0, 0), 1)

		-- Component Label
		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.new(1, -120, 1, 0)
		label.Position = UDim2.new(0, 12, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = THEME.TextMuted or Color3.fromRGB(140, 140, 150)
		label.TextSize = 12
		label.Font = THEME.Font or Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = keybindRow

		-- 3. Interactive Keybind Trigger Button
		local bindBtn = Instance.new("TextButton")
		bindBtn.Name = "BindButton"
		bindBtn.Size = UDim2.new(0, 80, 0, 24)
		bindBtn.Position = UDim2.new(1, -12, 0.5, 0)
		bindBtn.AnchorPoint = Vector2.new(1, 0.5)
		bindBtn.BackgroundColor3 = THEME.Background or Color3.fromRGB(13, 13, 16)
		bindBtn.TextColor3 = THEME.Accent or Color3.fromRGB(168, 85, 247) 
		bindBtn.TextSize = 11
		bindBtn.Font = Enum.Font.GothamBold
		bindBtn.AutoButtonColor = false
		bindBtn.Parent = keybindRow
		addCorner(bindBtn, 4)

		local btnStroke = addStroke(bindBtn, Color3.fromRGB(35, 35, 40), 1)

		-- 4. Helper Function: Convert Enum to Readable Short Name
		local function getKeyName(key: Enum.KeyCode | Enum.UserInputType): string
			if not key or key == Enum.KeyCode.Unknown then
				return "None"
			end

			local name = key.Name
			local aliases = {
				["MouseButton1"] = "MB1",
				["MouseButton2"] = "MB2",
				["MouseButton3"] = "MB3",
				["RightControl"] = "R-Ctrl",
				["LeftControl"]  = "L-Ctrl",
				["RightShift"]   = "R-Shift",
				["LeftShift"]    = "L-Shift",
				["RightAlt"]     = "R-Alt",
				["LeftAlt"]      = "L-Alt"
			}

			return aliases[name] or name
		end

		-- 5. Dynamic Sizing & State Handler
		local function updateDisplay(binding: boolean)
			isBinding = binding

			local displayText = isBinding and "..." or getKeyName(currentKey)
			bindBtn.Text = displayText

			-- Calculate dynamic button width based on text length (Min 64px, padded)
			local textService = game:GetService("TextService")
			local textSize = textService:GetTextSize(displayText, 11, Enum.Font.GothamBold, Vector2.new(1000, 24))
			local newWidth = math.max(64, textSize.X + 20)

			TweenService:Create(bindBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, newWidth, 0, 24)
			}):Play()

			if isBinding then
				TweenService:Create(bindBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.SurfaceHover or Color3.fromRGB(32, 32, 38)}):Play()
				TweenService:Create(btnStroke, TweenInfo.new(0.15), {Color = THEME.Accent or Color3.fromRGB(168, 85, 247)}):Play()
			else
				TweenService:Create(bindBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.Background or Color3.fromRGB(13, 13, 16)}):Play()
				TweenService:Create(btnStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(35, 35, 40)}):Play()
			end
		end

		-- Initial display configuration
		updateDisplay(false)

		-- Interactive Hover States
		keybindRow.MouseEnter:Connect(function()
			TweenService:Create(keybindRow, TweenInfo.new(0.2), {BackgroundColor3 = THEME.SurfaceHover or Color3.fromRGB(24, 24, 30)}):Play()
			TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = THEME.TextColor or Color3.fromRGB(255, 255, 255)}):Play()
			TweenService:Create(cardStroke, TweenInfo.new(0.2), {Color = THEME.Accent or Color3.fromRGB(168, 85, 247)}):Play()
		end)

		keybindRow.MouseLeave:Connect(function()
			TweenService:Create(keybindRow, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Surface or Color3.fromRGB(18, 18, 22)}):Play()
			TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = THEME.TextMuted or Color3.fromRGB(140, 140, 150)}):Play()
			TweenService:Create(cardStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(0, 0, 0)}):Play()
		end)

		bindBtn.MouseButton1Click:Connect(function()
			if isBinding then return end
			updateDisplay(true)
		end)

		-- 6. Central Input Listener
		local inputConnection
		inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not isBinding then return end

			-- Allow unbinding / cancelling on Escape, Backspace, or Delete
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape then
					updateDisplay(false)
					return
				elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
					currentKey = Enum.KeyCode.Unknown
					updateDisplay(false)
					if callback then task.spawn(callback, currentKey) end
					return
				end
			end

			-- Capture Keyboard or Mouse Button inputs (Filtering out Mouse Movement/Wheel)
			local newKey = nil
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
				newKey = input.KeyCode
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 
				or input.UserInputType == Enum.UserInputType.MouseButton2 
				or input.UserInputType == Enum.UserInputType.MouseButton3 then
				newKey = input.UserInputType
			end

			if newKey then
				currentKey = newKey
				updateDisplay(false)
				if callback then
					task.spawn(callback, currentKey)
				end
			end
		end)

		-- Auto-cancel binding mode if user clicks into a Chat/TextBox
		local focusConnection
		focusConnection = UserInputService.TextBoxFocused:Connect(function()
			if isBinding then
				updateDisplay(false)
			end
		end)

		-- Garbage Collection Cleanup
		keybindRow.Destroying:Connect(function()
			if inputConnection then inputConnection:Disconnect() end
			if focusConnection then focusConnection:Disconnect() end
		end)

		-- 7. External API Controls
		local keybindActions = {}

		function keybindActions:SetKey(newKey: Enum.KeyCode | Enum.UserInputType)
			currentKey = newKey or Enum.KeyCode.Unknown
			updateDisplay(false)
			if callback then task.spawn(callback, currentKey) end
		end

		function keybindActions:GetKey()
			return currentKey
		end

		return keybindActions
	end

	return tabMethods
end

-- Global Hybrid Notification Interface (Custom UI + Native Engine Retrofit)
function UILibrary:Notification(type: string, description: string, duration: number?)
	local lifeTime = duration or 4

	-- ==========================================
	-- NATIVE ROBLOX SETCORE ROUTE
	-- ==========================================
	if type == "Native" then
		local config = NOTIFICATION_TYPES.Native
		task.spawn(function()
			local success = false
			while not success do
				success = pcall(function()
					StarterGui:SetCore("SendNotification", {
						Title = config.Title,
						Text = description,
						Duration = lifeTime,
						Icon = config.Icon
					})
				end)
				if not success then task.wait(0.1) end
			end
		end)
		return -- Terminate script execution thread so it skips building custom UI objects
	end

	-- ==========================================
	-- CUSTOM HIGH-FIDELITY OBSIDIAN UI ROUTE
	-- ==========================================
	local config = NOTIFICATION_TYPES[type] or NOTIFICATION_TYPES.Info
	local ScreenGui = getNotificationScreen()

	-- Create Main Alert Card Frame Container
	local card = Instance.new("Frame")
	card.Name = "Notification_Card"
	card.Size = UDim2.new(0, NOTIFICATION_WIDTH, 0, NOTIFICATION_HEIGHT)
	card.Position = UDim2.new(1, 40, 1, -NOTIFICATION_HEIGHT - 60)
	card.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
	card.BorderSizePixel = 0
	card.ClipsDescendants = true
	card.Parent = ScreenGui

	addCorner(card, 6)
	local cardStroke = addStroke(card, config.Accent, 1)
	cardStroke.Transparency = 0.65

	-- Premium Ambient Status Ring Container
	local ring = Instance.new("Frame")
	ring.Name = "StatusRing"
	ring.Size = UDim2.new(0, 20, 0, 20)
	ring.Position = UDim2.new(0, 12, 0.5, -10)
	ring.BackgroundColor3 = config.Accent
	ring.BackgroundTransparency = 0.88
	ring.BorderSizePixel = 0
	ring.Parent = card
	addCorner(ring, 10)
	addStroke(ring, config.Accent, 1).Transparency = 0.3

	-- High-Contrast Status Symbol Glyph
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "Icon"
	iconLabel.Size = UDim2.new(1, 0, 1, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = config.Icon
	iconLabel.TextColor3 = config.Accent
	iconLabel.TextSize = type == "Premium" and 11 or 10
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = ring

	-- Status Context Header Title Label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -74, 0, 14)
	titleLabel.Position = UDim2.new(0, 42, 0, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = config.Title
	titleLabel.TextColor3 = Color3.fromRGB(245, 245, 247)
	titleLabel.TextSize = 11
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = card

	-- Context Subtext Description
	local bodyLabel = Instance.new("TextLabel")
	bodyLabel.Name = "Description"
	bodyLabel.Size = UDim2.new(1, -74, 0, 14)
	bodyLabel.Position = UDim2.new(0, 42, 0, 23)
	bodyLabel.BackgroundTransparency = 1
	bodyLabel.Text = description
	bodyLabel.TextColor3 = THEME.TextMuted or Color3.fromRGB(140, 140, 150)
	bodyLabel.TextSize = 10
	bodyLabel.Font = THEME.Font or Enum.Font.Gotham
	bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
	bodyLabel.TextTruncate = Enum.TextTruncate.AtEnd
	bodyLabel.Parent = card

	-- Dismiss Manual Exit Trigger Button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 16, 0, 16)
	closeBtn.Position = UDim2.new(1, -22, 0.5, -8)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Color3.fromRGB(80, 80, 90)
	closeBtn.TextSize = 14
	closeBtn.Font = Enum.Font.Gotham
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = card

	-- Minimalist Bottom Progress Micro-Bar
	local countdownTrack = Instance.new("Frame")
	countdownTrack.Name = "TimelineTrack"
	countdownTrack.Size = UDim2.new(1, 0, 0, 1.5)
	countdownTrack.Position = UDim2.new(0, 0, 1, -1.5)
	countdownTrack.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	countdownTrack.BorderSizePixel = 0
	countdownTrack.Parent = card

	local countdownFill = Instance.new("Frame")
	countdownFill.Name = "TimelineFill"
	countdownFill.Size = UDim2.new(1, 0, 1, 0)
	countdownFill.BackgroundColor3 = config.Accent
	countdownFill.BackgroundTransparency = 0.3
	countdownFill.BorderSizePixel = 0
	countdownFill.Parent = countdownTrack

	-- Push into active stack tracking arrays
	table.insert(ActiveNotifications, 1, card)
	repositionNotifications()

	-- Clean Sweep Closure Cleanup Handler
	local isClosing = false
	local function dismissCard()
		if isClosing then return end
		isClosing = true

		local searchIdx = table.find(ActiveNotifications, card)
		if searchIdx then
			table.remove(ActiveNotifications, searchIdx)
		end
		repositionNotifications()

		local exitTween = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 40, card.Position.Y.Scale, card.Position.Y.Offset),
			BackgroundTransparency = 1
		})

		TweenService:Create(cardStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
		TweenService:Create(titleLabel, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
		TweenService:Create(bodyLabel, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
		TweenService:Create(ring, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
		TweenService:Create(iconLabel, TweenInfo.new(0.2), {TextTransparency = 1}):Play()

		exitTween:Play()
		exitTween.Completed:Connect(function()
			card:Destroy()
		end)
	end

	-- Connect Interaction Hooks
	closeBtn.MouseButton1Click:Connect(dismissCard)

	closeBtn.MouseEnter:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(200, 200, 210)}):Play()
	end)
	closeBtn.MouseLeave:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(80, 80, 90)}):Play()
	end)

	-- Play timeline runtime decay animation
	TweenService:Create(countdownFill, TweenInfo.new(lifeTime, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()

	task.delay(lifeTime, function()
		if card and card.Parent then
			dismissCard()
		end
	end)
end

-- Global Cinematic Popup / Modal Dialog Engine
function UILibrary:Popup(config)
	local ScreenGui = getNotificationScreen()

	-- Fallbacks for missing config data
	local titleText = config.Title or "System Prompt"
	local descText = config.Description or "Are you sure you want to proceed?"
	local options = config.Options or { { Title = "OK", Type = "Primary", Callback = function() end } }

	-- 1. Fullscreen Intercept Backdrop (Dims the screen and blocks clicks)
	local backdrop = Instance.new("TextButton") -- TextButton used intentionally to block underlying clicks
	backdrop.Name = "Popup_Backdrop"
	backdrop.Size = UDim2.new(1, 0, 1, 0)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 1
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.ZIndex = 100 -- Sits below notifications but above normal UI
	backdrop.Parent = ScreenGui

	-- 2. The Main Modal Card (Auto-scales height based on content)
	local modal = Instance.new("Frame")
	modal.Name = "Popup_Modal"
	modal.Size = UDim2.new(0, 340, 0, 0)
	modal.Position = UDim2.new(0.5, 0, 0.5, 0)
	modal.AnchorPoint = Vector2.new(0.5, 0.5)
	modal.BackgroundColor3 = THEME.Surface or Color3.fromRGB(18, 18, 22)
	modal.BorderSizePixel = 0
	modal.AutomaticSize = Enum.AutomaticSize.Y -- Magic property: scales height automatically
	modal.ZIndex = 105
	modal.Parent = backdrop
	addCorner(modal, 8)
	addStroke(modal, Color3.fromRGB(35, 35, 42), 1)

	-- Modal Internal Layout Structure
	local modalLayout = Instance.new("UIListLayout")
	modalLayout.SortOrder = Enum.SortOrder.LayoutOrder
	modalLayout.Padding = UDim.new(0, 16)
	modalLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	modalLayout.Parent = modal

	local modalPadding = Instance.new("UIPadding")
	modalPadding.PaddingTop = UDim.new(0, 20)
	modalPadding.PaddingBottom = UDim.new(0, 20)
	modalPadding.PaddingLeft = UDim.new(0, 24)
	modalPadding.PaddingRight = UDim.new(0, 24)
	modalPadding.Parent = modal

	-- 3. Header & Text Content
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 20)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = Color3.fromRGB(245, 245, 250)
	title.TextSize = 16
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.LayoutOrder = 1
	title.ZIndex = 106
	title.Parent = modal

	local description = Instance.new("TextLabel")
	description.Name = "Description"
	description.Size = UDim2.new(1, 0, 0, 0)
	description.BackgroundTransparency = 1
	description.Text = descText
	description.TextColor3 = THEME.TextMuted or Color3.fromRGB(140, 140, 150)
	description.TextSize = 12
	description.Font = THEME.Font or Enum.Font.Gotham
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.TextYAlignment = Enum.TextYAlignment.Top
	description.TextWrapped = true
	description.AutomaticSize = Enum.AutomaticSize.Y
	description.LayoutOrder = 2
	description.ZIndex = 106
	description.Parent = modal

	-- 4. Footer Action Buttons Container
	local actionRow = Instance.new("Frame")
	actionRow.Name = "ActionRow"
	actionRow.Size = UDim2.new(1, 0, 0, 36)
	actionRow.BackgroundTransparency = 1
	actionRow.LayoutOrder = 3
	actionRow.ZIndex = 106
	actionRow.Parent = modal

	local actionLayout = Instance.new("UIListLayout")
	actionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	actionLayout.FillDirection = Enum.FillDirection.Horizontal
	actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	actionLayout.Padding = UDim.new(0, 10)
	actionLayout.Parent = actionRow

	-- Closure Engine
	local isClosing = false
	local function closePopup()
		if isClosing then return end
		isClosing = true

		local exitTweenTime = 0.25
		TweenService:Create(backdrop, TweenInfo.new(exitTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		TweenService:Create(modal:FindFirstChild("UIScale"), TweenInfo.new(exitTweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0.8}):Play()
		TweenService:Create(modal, TweenInfo.new(exitTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()

		-- Dim all text/buttons out
		for _, descendant in ipairs(modal:GetDescendants()) do
			if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
				TweenService:Create(descendant, TweenInfo.new(exitTweenTime), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
			elseif descendant:IsA("UIStroke") then
				TweenService:Create(descendant, TweenInfo.new(exitTweenTime), {Transparency = 1}):Play()
			end
		end

		task.delay(exitTweenTime, function()
			backdrop:Destroy()
		end)
	end

	-- 5. Button Generation Loop
	for index, btnConfig in ipairs(options) do
		local btnType = btnConfig.Type or "Secondary"

		-- Color Profiling
		local bgTarget, textTarget, strokeTarget
		if btnType == "Primary" then
			bgTarget = THEME.Accent or Color3.fromRGB(168, 85, 247)
			textTarget = Color3.fromRGB(255, 255, 255)
			strokeTarget = bgTarget
		elseif btnType == "Danger" then
			bgTarget = Color3.fromRGB(239, 68, 68)
			textTarget = Color3.fromRGB(255, 255, 255)
			strokeTarget = bgTarget
		else -- Secondary / Default
			bgTarget = Color3.fromRGB(24, 24, 28)
			textTarget = THEME.TextColor or Color3.fromRGB(200, 200, 200)
			strokeTarget = Color3.fromRGB(45, 45, 52)
		end

		local btn = Instance.new("TextButton")
		btn.Name = "Button_" .. btnConfig.Title
		btn.Size = UDim2.new(0, 0, 1, 0)
		btn.AutomaticSize = Enum.AutomaticSize.X -- Dynamically sizes width based on text length
		btn.BackgroundColor3 = bgTarget
		btn.Text = btnConfig.Title
		btn.TextColor3 = textTarget
		btn.TextSize = 12
		btn.Font = Enum.Font.GothamBold
		btn.AutoButtonColor = false
		btn.LayoutOrder = index
		btn.ZIndex = 107
		btn.Parent = actionRow
		addCorner(btn, 5)
		local btnStroke = addStroke(btn, strokeTarget, 1)

		-- Elegant Padding for the auto-sizing
		local btnPadding = Instance.new("UIPadding")
		btnPadding.PaddingLeft = UDim.new(0, 16)
		btnPadding.PaddingRight = UDim.new(0, 16)
		btnPadding.Parent = btn

		-- Hover Animations
		btn.MouseEnter:Connect(function()
			local hoverShift = (btnType == "Secondary") and Color3.fromRGB(32, 32, 38) or bgTarget:Lerp(Color3.fromRGB(255, 255, 255), 0.15)
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverShift}):Play()
		end)

		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = bgTarget}):Play()
		end)

		-- Execution Click
		btn.MouseButton1Click:Connect(function()
			if btnConfig.Callback then
				task.spawn(btnConfig.Callback)
			end
			closePopup()
		end)
	end

	-- 6. Entrance Animations (Using UIScale for that premium "pop" effect)
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 0.8
	uiScale.Parent = modal

	TweenService:Create(backdrop, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.4}):Play()
	TweenService:Create(uiScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end

-- Safely dismantle UI on game end or library close
function UILibrary:Destroy()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

return UILibrary
