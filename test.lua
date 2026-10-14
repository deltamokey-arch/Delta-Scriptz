--!strict
-- Paxz Scriptz — Cosmic Edition
-- Original Roblox Luau UI library with a Rayfield-inspired builder API.
-- Place this ModuleScript somewhere accessible to a LocalScript and require it on the client.
-- This library builds UI only; add your own game logic through callbacks.

local Paxz = {}
Paxz.__index = Paxz

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local COLORS = {
	Background = Color3.fromRGB(3, 2, 8),
	Panel = Color3.fromRGB(10, 7, 19),
	Card = Color3.fromRGB(14, 10, 25),
	CardHover = Color3.fromRGB(24, 15, 41),
	Purple = Color3.fromRGB(157, 78, 221),
	Violet = Color3.fromRGB(199, 125, 255),
	DeepPurple = Color3.fromRGB(114, 9, 183),
	White = Color3.fromRGB(248, 246, 255),
	Muted = Color3.fromRGB(153, 148, 173),
	Line = Color3.fromRGB(62, 38, 88),
	Mint = Color3.fromRGB(108, 255, 204),
	Discord = Color3.fromRGB(88, 101, 242),
	Red = Color3.fromRGB(255, 99, 129),
}

local function create(className, parent, properties)
	local instance = Instance.new(className)
	for key, value in pairs(properties or {}) do
		instance[key] = value
	end
	instance.Parent = parent
	return instance
end

local function corner(parent, radius)
	return create("UICorner", parent, { CornerRadius = UDim.new(0, radius or 10) })
end

local function outline(parent, color, transparency, thickness)
	return create("UIStroke", parent, {
		Color = color or COLORS.Line,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
	})
end

local function textLabel(parent, text, size, color, font, properties)
	local base = {
		BackgroundTransparency = 1,
		Text = text or "",
		TextColor3 = color or COLORS.White,
		TextSize = size or 14,
		Font = font or Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextWrapped = false,
		BorderSizePixel = 0,
	}
	for key, value in pairs(properties or {}) do
		base[key] = value
	end
	return create("TextLabel", parent, base)
end

local function tween(instance, duration, properties, style, direction)
	local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
	local animation = TweenService:Create(instance, info, properties)
	animation:Play()
	return animation
end

local function callSafely(callback, ...)
	if type(callback) ~= "function" then
		return
	end
	local args = table.pack(...)
	task.spawn(function()
		local ok, err = pcall(function()
			callback(table.unpack(args, 1, args.n))
		end)
		if not ok then
			warn("[Paxz Cosmic] Callback error: " .. tostring(err))
		end
	end)
end

local function addHover(button, primary)
	local scale = create("UIScale", button, { Scale = 1 })
	button.AutoButtonColor = false
	button.MouseEnter:Connect(function()
		tween(scale, 0.18, { Scale = primary and 1.035 or 1.02 })
		if not primary then
			tween(button, 0.18, { BackgroundColor3 = COLORS.CardHover })
		end
	end)
	button.MouseLeave:Connect(function()
		tween(scale, 0.2, { Scale = 1 })
		if not primary then
			tween(button, 0.2, { BackgroundColor3 = COLORS.Card })
		end
	end)

	if primary then
		local shine = create("Frame", button, {
			Name = "Shine",
			BackgroundColor3 = COLORS.White,
			BackgroundTransparency = 0.78,
			BorderSizePixel = 0,
			Rotation = 18,
			Position = UDim2.new(0, -55, -0.4, 0),
			Size = UDim2.new(0, 32, 1.8, 0),
			ZIndex = button.ZIndex + 1,
		})
		shine.Active = false
		corner(shine, 12)
		button.MouseEnter:Connect(function()
			shine.Position = UDim2.new(0, -55, -0.4, 0)
			tween(shine, 0.62, { Position = UDim2.new(1, 40, -0.4, 0) }, Enum.EasingStyle.Sine)
		end)
	end
end

local function makeCard(parent, height)
	local card = create("Frame", parent, {
		BackgroundColor3 = COLORS.Card,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height or 68),
		ZIndex = 5,
		ClipsDescendants = true,
	})
	corner(card, 11)
	outline(card, COLORS.Line, 0.52, 1)
	return card
end

local function addStarfield(parent, count)
	local layer = create("Frame", parent, {
		Name = "CosmicStarfield",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
	})

	-- Soft, drifting purple nebulae, built from translucent circles (no external assets).
	local function nebula(x, y, width, height, color, duration, endX, endY)
		local haze = create("Frame", layer, {
			BackgroundColor3 = color,
			BackgroundTransparency = 0.955,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(x, y),
			Size = UDim2.fromOffset(width, height),
			ZIndex = 1,
		})
		corner(haze, 999)
		local inner = create("Frame", haze, {
			BackgroundColor3 = color,
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.18, 0.18),
			Size = UDim2.fromScale(0.64, 0.64),
			ZIndex = 1,
		})
		corner(inner, 999)
		TweenService:Create(haze, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			Position = UDim2.fromScale(endX, endY),
		}):Play()
	end

	nebula(0.02, 0.12, 370, 260, COLORS.DeepPurple, 19, 0.10, 0.2)
	nebula(0.60, 0.48, 330, 250, COLORS.Purple, 23, 0.54, 0.36)

	local starColors = { COLORS.White, COLORS.White, COLORS.Violet, COLORS.Purple, COLORS.Mint }
	for index = 1, math.clamp(tonumber(count) or 180, 0, 260) do
		local size = math.random(1, 3)
		local x = math.random(2, 98) / 100
		local y = math.random(2, 98) / 100
		local dx = math.random(-350, 350) / 10000
		local dy = math.random(-260, 260) / 10000
		local star = create("Frame", layer, {
			Name = "Star",
			BackgroundColor3 = starColors[math.random(1, #starColors)],
			BackgroundTransparency = math.random(18, 65) / 100,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(x, y),
			Size = UDim2.fromOffset(size, size),
			ZIndex = 2,
		})
		corner(star, 99)
		local targetX = math.clamp(x + dx, 0.01, 0.99)
		local targetY = math.clamp(y + dy, 0.01, 0.99)
		local duration = math.random(7, 18)
		local animation = TweenService:Create(star, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			Position = UDim2.fromScale(targetX, targetY),
			BackgroundTransparency = math.random(5, 35) / 100,
		})
		animation:Play()
	end
	return layer
end

local function makePill(parent, text, color, width)
	local pill = create("Frame", parent, {
		BackgroundColor3 = color,
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(width or 120, 26),
		ZIndex = 8,
	})
	corner(pill, 99)
	outline(pill, color, 0.42, 1)
	textLabel(pill, text, 10, color, Enum.Font.GothamBold, {
		Position = UDim2.fromOffset(9, 0),
		Size = UDim2.new(1, -18, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 9,
	})
	return pill
end

function Paxz:CreateWindow(configuration)
	configuration = configuration or {}
	local player = Players.LocalPlayer
	assert(player, "Paxz Cosmic must be required from a LocalScript on the client.")

	local playerGui = player:WaitForChild("PlayerGui")
	local gui = create("ScreenGui", playerGui, {
		Name = configuration.Name or "PaxzCosmicUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 30,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	local main = create("Frame", gui, {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(configuration.Width or 850, configuration.Height or 550),
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 1,
	})
	corner(main, 16)
	outline(main, COLORS.Purple, 0.28, 1.25)

	local shadow = create("Frame", main, {
		Name = "AmbientGlow",
		BackgroundColor3 = COLORS.DeepPurple,
		BackgroundTransparency = 0.965,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.new(1, -6, 1, -6),
		ZIndex = 1,
	})
	corner(shadow, 16)
	addStarfield(main, configuration.StarCount or 180)

	local uiScale = create("UIScale", main, { Scale = 1 })
	local function updateScale()
		local camera = workspace.CurrentCamera
		if not camera then return end
		uiScale.Scale = math.clamp(math.min(camera.ViewportSize.X / 980, camera.ViewportSize.Y / 680), 0.68, 1)
	end
	updateScale()
	local cameraConnection
	if workspace.CurrentCamera then
		cameraConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	end

	local header = create("Frame", main, {
		Name = "Header",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 56),
		ZIndex = 6,
	})

	local meteor = textLabel(header, "☄", 25, COLORS.Violet, Enum.Font.GothamBlack, {
		Position = UDim2.fromOffset(19, 9),
		Size = UDim2.fromOffset(32, 34),
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 8,
	})
	TweenService:Create(meteor, TweenInfo.new(16, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false), {
		Rotation = 360,
	}):Play()
	TweenService:Create(meteor, TweenInfo.new(2.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		TextColor3 = COLORS.Purple,
	}):Play()

	textLabel(header, configuration.Brand or "Paxz", 19, COLORS.White, Enum.Font.GothamBlack, {
		Position = UDim2.fromOffset(55, 8), Size = UDim2.fromOffset(58, 35), ZIndex = 8,
	})
	textLabel(header, configuration.BrandAccent or "Scriptz", 19, COLORS.Violet, Enum.Font.GothamBlack, {
		Position = UDim2.fromOffset(112, 8), Size = UDim2.fromOffset(93, 35), ZIndex = 8,
	})
	textLabel(header, "COSMIC EDITION", 8, COLORS.Muted, Enum.Font.GothamBold, {
		Position = UDim2.fromOffset(58, 33), Size = UDim2.fromOffset(130, 13), ZIndex = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local status = create("Frame", header, {
		BackgroundColor3 = COLORS.Mint,
		BackgroundTransparency = 0.92,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -102, 0.5, 0),
		Size = UDim2.fromOffset(112, 26),
		ZIndex = 8,
	})
	corner(status, 99)
	outline(status, COLORS.Mint, 0.7, 1)
	local statusDot = create("Frame", status, {
		BackgroundColor3 = COLORS.Mint,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(10, 9),
		Size = UDim2.fromOffset(7, 7),
		ZIndex = 9,
	})
	corner(statusDot, 99)
	TweenService:Create(statusDot, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		BackgroundTransparency = 0.75,
	}):Play()
	textLabel(status, "SYSTEM ONLINE", 9, COLORS.Mint, Enum.Font.GothamBold, {
		Position = UDim2.fromOffset(23, 0), Size = UDim2.new(1, -27, 1, 0), ZIndex = 9,
	})

	local minimizeButton = create("TextButton", header, {
		Name = "Minimize",
		Text = "−",
		TextColor3 = COLORS.Muted,
		TextSize = 22,
		Font = Enum.Font.Gotham,
		BackgroundColor3 = COLORS.Card,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -56, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		ZIndex = 10,
	})
	corner(minimizeButton, 99)
	addHover(minimizeButton, false)

	local closeButton = create("TextButton", header, {
		Name = "Hide",
		Text = "×",
		TextColor3 = COLORS.Muted,
		TextSize = 18,
		Font = Enum.Font.Gotham,
		BackgroundColor3 = COLORS.Card,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -18, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		ZIndex = 10,
	})
	corner(closeButton, 99)
	addHover(closeButton, false)

	local headerLine = create("Frame", main, {
		BackgroundColor3 = COLORS.Purple,
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 55),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 6,
	})

	local contentHost = create("Frame", main, {
		Name = "ContentHost",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 57),
		Size = UDim2.new(1, 0, 1, -57),
		ZIndex = 4,
	})

	local tabNav = create("ScrollingFrame", contentHost, {
		Name = "TabNavigation",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(15, 6),
		Size = UDim2.new(1, -30, 0, 40),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 0,
		ZIndex = 6,
	})
	local navLayout = create("UIListLayout", tabNav, {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
	})
	create("UIPadding", tabNav, { PaddingRight = UDim.new(0, 4) })

	local pagesHost = create("Frame", contentHost, {
		Name = "Pages",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(15, 50),
		Size = UDim2.new(1, -30, 1, -58),
		ZIndex = 4,
	})

	local toastLayer = create("Frame", gui, {
		Name = "Notifications",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 18),
		Size = UDim2.fromOffset(320, 380),
		ZIndex = 50,
	})
	create("UIListLayout", toastLayer, {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 9),
	})

	local window = {
		Gui = gui,
		Main = main,
		Configuration = configuration,
		Tabs = {},
		TabOrder = {},
		Connections = {},
		Keybinds = {},
		Minimized = false,
		Visible = true,
		Destroyed = false,
	}

	local function track(connection)
		table.insert(window.Connections, connection)
		return connection
	end

	local function refreshActiveTab(activeTab)
		for _, tab in ipairs(window.TabOrder) do
			local active = tab == activeTab
			tab.Page.Visible = active
			if active then
				tween(tab.Button, 0.18, { BackgroundColor3 = COLORS.DeepPurple, BackgroundTransparency = 0.22 })
				tab.Button.TextColor3 = COLORS.White
				local tabStroke = tab.Button:FindFirstChildOfClass("UIStroke")
				if tabStroke then tween(tabStroke, 0.18, { Transparency = 0.25, Color = COLORS.Violet }) end
			else
				tween(tab.Button, 0.18, { BackgroundColor3 = COLORS.Card, BackgroundTransparency = 0.12 })
				tab.Button.TextColor3 = COLORS.Muted
				local tabStroke = tab.Button:FindFirstChildOfClass("UIStroke")
				if tabStroke then tween(tabStroke, 0.18, { Transparency = 0.8, Color = COLORS.Line }) end
			end
		end
		window.ActiveTab = activeTab
	end

	local function makePage(tabName)
		local page = create("ScrollingFrame", pagesHost, {
			Name = tabName .. "Page",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = COLORS.Purple,
			ScrollBarImageTransparency = 0.25,
			Visible = false,
			ZIndex = 5,
		})
		create("UIPadding", page, {
			PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 6),
		})
		create("UIListLayout", page, {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 9),
		})
		return page
	end

	local function createSectionHeader(page, name)
		local holder = create("Frame", page, {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 27),
			ZIndex = 5,
		})
		textLabel(holder, string.upper(name or "SECTION"), 10, COLORS.Violet, Enum.Font.GothamBold, {
			Position = UDim2.fromOffset(4, 0),
			Size = UDim2.new(0, 190, 1, 0),
			ZIndex = 6,
		})
		create("Frame", holder, {
			BackgroundColor3 = COLORS.Line,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 150, 0.5, 0),
			Size = UDim2.new(1, -158, 0, 1),
			ZIndex = 5,
		})
		return holder
	end

	local function updateToggleVisual(trackFrame, knob, value)
		tween(trackFrame, 0.18, { BackgroundColor3 = value and COLORS.Purple or COLORS.Line })
		tween(knob, 0.18, { Position = value and UDim2.new(1, -19, 0, 3) or UDim2.fromOffset(3, 3), BackgroundColor3 = value and COLORS.White or COLORS.Muted })
	end

	function window:CreateTab(name, icon)
		name = tostring(name or ("Tab " .. tostring(#self.TabOrder + 1)))
		if self.Tabs[name] then
			return self.Tabs[name]
		end

		local button = create("TextButton", tabNav, {
			Name = name .. "TabButton",
			Text = (icon and (tostring(icon) .. "   ") or "") .. name,
			TextColor3 = COLORS.Muted,
			TextSize = 11,
			Font = Enum.Font.GothamBold,
			BackgroundColor3 = COLORS.Card,
			BackgroundTransparency = 0.12,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(math.max(95, math.min(160, 36 + #name * 7)), 31),
			ZIndex = 7,
			LayoutOrder = #self.TabOrder + 1,
		})
		corner(button, 99)
		outline(button, COLORS.Line, 0.8, 1)
		addHover(button, false)

		local page = makePage(name)
		local tab = { Name = name, Button = button, Page = page, Window = self }
		self.Tabs[name] = tab
		table.insert(self.TabOrder, tab)

		local function refreshCanvas()
			-- AutomaticCanvasSize is used; this connection keeps the page responsive in older clients too.
			local layout = page:FindFirstChildOfClass("UIListLayout")
			if layout and not page.AutomaticCanvasSize then
				page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
			end
		end
		local layout = page:FindFirstChildOfClass("UIListLayout")
		if layout then
			track(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshCanvas))
		end

		function tab:CreateSection(sectionName)
			createSectionHeader(self.Page, sectionName)
			local sectionApi = { Tab = self }
			local delegates = {
				"CreateButton", "CreateToggle", "CreateSlider", "CreateDropdown",
				"CreateInput", "CreateKeybind", "CreateLabel", "CreateParagraph", "CreateDivider",
			}
			for _, methodName in ipairs(delegates) do
				sectionApi[methodName] = function(_, config)
					return self[methodName](self, config)
				end
			end
			return sectionApi
		end

		function tab:CreateDivider()
			local divider = create("Frame", self.Page, {
				BackgroundColor3 = COLORS.Line,
				BackgroundTransparency = 0.35,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 1),
				ZIndex = 5,
			})
			return divider
		end

		function tab:CreateLabel(config)
			config = type(config) == "table" and config or { Name = tostring(config or "Label") }
			local card = makeCard(self.Page, 42)
			local label = textLabel(card, config.Name or config.Text or "Label", 12, config.Color or COLORS.Muted, Enum.Font.GothamMedium, {
				Position = UDim2.fromOffset(13, 0), Size = UDim2.new(1, -26, 1, 0), ZIndex = 6,
			})
			local object = {}
			function object:Set(value) label.Text = tostring(value) end
			function object:Get() return label.Text end
			return object
		end

		function tab:CreateParagraph(config)
			config = config or {}
			local card = makeCard(self.Page, config.Height or 94)
			textLabel(card, config.Title or "Information", 13, COLORS.White, Enum.Font.GothamBold, {
				Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 21), ZIndex = 6,
			})
			textLabel(card, config.Content or "Add your own description here.", 11, COLORS.Muted, Enum.Font.Gotham, {
				Position = UDim2.fromOffset(14, 31), Size = UDim2.new(1, -28, 1, -38),
				TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 6,
			})
			return card
		end

		function tab:CreateButton(config)
			config = config or {}
			local card = makeCard(self.Page, config.Height or 68)
			textLabel(card, config.Name or "Button", 12, COLORS.White, Enum.Font.GothamBold, {
				Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -177, 0, 22), ZIndex = 6,
			})
			textLabel(card, config.Description or "Run the action linked to this control.", 10, COLORS.Muted, Enum.Font.Gotham, {
				Position = UDim2.fromOffset(14, 31), Size = UDim2.new(1, -177, 0, 20), ZIndex = 6,
			})
			local button = create("TextButton", card, {
				Text = config.ButtonText or "Run",
				TextColor3 = COLORS.White,
				TextSize = 11,
				Font = Enum.Font.GothamBold,
				BackgroundColor3 = COLORS.Purple,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.fromOffset(config.ButtonWidth or 112, 34),
				ZIndex = 7,
			})
			corner(button, 9)
			create("UIGradient", button, {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, COLORS.DeepPurple),
					ColorSequenceKeypoint.new(0.55, COLORS.Purple),
					ColorSequenceKeypoint.new(1, COLORS.Violet),
				}),
				Rotation = 0,
			})
			addHover(button, true)
			track(button.Activated:Connect(function() callSafely(config.Callback) end))
			return { Button = button, Card = card }
		end

		function tab:CreateToggle(config)
			config = config or {}
			local state = config.CurrentValue == true or config.Default == true
			local card = makeCard(self.Page, 66)
			textLabel(card, config.Name or "Toggle", 12, COLORS.White, Enum.Font.GothamBold, {
				Position = UDim2.fromOffset(14, 7), Size = UDim2.new(1, -86, 0, 23), ZIndex = 6,
			})
			textLabel(card, config.Description or "Enable or disable this option.", 10, COLORS.Muted, Enum.Font.Gotham, {
				Position = UDim2.fromOffset(14, 31), Size = UDim2.new(1, -86, 0, 20), ZIndex = 6,
			})
			local switch = create("TextButton", card, {
				Text = "", AutoButtonColor = false,
				BackgroundColor3 = state and COLORS.Purple or COLORS.Line,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.fromOffset(43, 25), ZIndex = 7,
			})
			corner(switch, 99)
			local knob = create("Frame", switch, {
				BackgroundColor3 = state and COLORS.White or COLORS.Muted,
				BorderSizePixel = 0,
				Position = state and UDim2.new(1, -19, 0, 3) or UDim2.fromOffset(3, 3),
				Size = UDim2.fromOffset(19, 19), ZIndex = 8,
			})
			corner(knob, 99)
			local function set(value, fire)
				state = value == true
				updateToggleVisual(switch, knob, state)
				if fire ~= false then callSafely(config.Callback, state) end
			end
			track(switch.Activated:Connect(function() set(not state, true) end))
			return { Set = function(_, value) set(value, true) end, Get = function() return state end, Changed = function(_, value) set(value, true) end }
		end

		function tab:CreateSlider(config)
			config = config or {}
			local range = config.Range or { 0, 100 }
			local minimum, maximum = tonumber(range[1]) or 0, tonumber(range[2]) or 100
			if maximum < minimum then minimum, maximum = maximum, minimum end
			local increment = math.max(tonumber(config.Increment) or 1, 0.000001)
			local current = math.clamp(tonumber(config.CurrentValue) or minimum, minimum, maximum)
			local card = makeCard(self.Page, 82)
			local title = textLabel(card, config.Name or "Slider", 12, COLORS.White, Enum.Font.GothamBold, {
				Position = UDim2.fromOffset(14, 7), Size = UDim2.new(1, -130, 0, 22), ZIndex = 6,
			})
			local valueLabel = textLabel(card, "", 11, COLORS.Violet, Enum.Font.GothamBold, {
				AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 7), Size = UDim2.fromOffset(110, 22),
				TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 6,
			})
			local trackFrame = create("Frame", card, {
				BackgroundColor3 = COLORS.Line, BorderSizePixel = 0,
				Position = UDim2.fromOffset(14, 52), Size = UDim2.new(1, -28, 0, 6), ZIndex = 6,
			})
			corner(trackFrame, 99)
			local fill = create("Frame", trackFrame, {
				BackgroundColor3 = COLORS.Purple, BorderSizePixel = 0,
				Size = UDim2.new(0, 0, 1, 0), ZIndex = 7,
			})
			corner(fill, 99)
			local knob = create("Frame", trackFrame, {
				BackgroundColor3 = COLORS.White, BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.fromOffset(14, 14), ZIndex = 8,
			})
			corner(knob, 99)
			outline(knob, COLORS.Violet, 0.1, 1)
			local dragging = false
			local function formatValue(value)
				if value % 1 == 0 then return tostring(math.floor(value)) end
				return tostring(math.floor(value * 1000 + 0.5) / 1000)
			end
			local function set(value, fire)
				value = math.clamp(tonumber(value) or minimum, minimum, maximum)
				value = minimum + math.floor(((value - minimum) / increment) + 0.5) * increment
				value = math.clamp(value, minimum, maximum)
				current = value
				local alpha = maximum == minimum and 0 or (current - minimum) / (maximum - minimum)
				fill.Size = UDim2.new(alpha, 0, 1, 0)
				knob.Position = UDim2.new(alpha, 0, 0.5, 0)
				valueLabel.Text = formatValue(current) .. tostring(config.Suffix or "")
				if fire ~= false then callSafely(config.Callback, current) end
			end
			local function setFromX(x)
				local width = trackFrame.AbsoluteSize.X
				if width <= 0 then return end
				local alpha = math.clamp((x - trackFrame.AbsolutePosition.X) / width, 0, 1)
				set(minimum + (maximum - minimum) * alpha, true)
			end
			track(trackFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					setFromX(input.Position.X)
				end
			end))
			track(UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					setFromX(input.Position.X)
				end
			end))
			track(UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
			end))
			set(current, false)
			return { Set = function(_, value) set(value, true) end, Get = function() return current end }
		end

		function tab:CreateDropdown(config)
			config = config or {}
			local options = config.Options or {}
			local multiple = config.MultipleOptions == true
			local selected = {}
			local initial = config.CurrentOption
			if type(initial) == "table" then
				for _, option in ipairs(initial) do selected[tostring(option)] = true end
			elseif initial ~= nil then
				selected[tostring(initial)] = true
		elseif #options > 0 and not multiple then
				selected[tostring(options[1])] = true
			end
			local card = makeCard(self.Page, 73)
			textLabel(card, config.Name or "Dropdown", 12, COLORS.White, Enum.Font.GothamBold, {
				Position = UDim2.fromOffset(14, 5), Size = UDim2.new(1, -28, 0, 22), ZIndex = 6,
			})
			local choice = create("TextButton", card, {
				Text = "", TextColor3 = COLORS.Muted, TextSize = 10, Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
				BackgroundColor3 = COLORS.Background, BorderSizePixel = 0,
				Position = UDim2.fromOffset(12, 32), Size = UDim2.new(1, -24, 0, 29), ZIndex = 7,
			})
			corner(choice, 7)
			outline(choice, COLORS.Line, 0.35, 1)
			local optionsArrow = textLabel(choice, "⌄", 16, COLORS.Violet, Enum.Font.GothamBold, {
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -9, 0.5, 0),
				Size = UDim2.fromOffset(20, 24), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 8,
			})
			local listHeight = math.min(math.max(#options, 1), 4) * 27
			local optionsFrame = create("ScrollingFrame", card, {
				BackgroundTransparency = 1, BorderSizePixel = 0,
				Position = UDim2.fromOffset(12, 66), Size = UDim2.new(1, -24, 0, listHeight),
				CanvasSize = UDim2.new(0, 0, 0, #options * 27), ScrollBarThickness = 3,
				ScrollBarImageColor3 = COLORS.Purple, Visible = false, ZIndex = 8,
			})
			create("UIListLayout", optionsFrame, { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) })
			local open = false
			local function selectedText()
				local result = {}
				for _, option in ipairs(options) do
					if selected[tostring(option)] then table.insert(result, tostring(option)) end
				end
				if #result == 0 then return config.Placeholder or "Select an option..." end
				return table.concat(result, multiple and ", " or "")
			end
			local function getValue()
				local result = {}
				for _, option in ipairs(options) do
					if selected[tostring(option)] then table.insert(result, tostring(option)) end
				end
				if multiple then return result end
				return result[1]
			end
			local function renderSelected(fire)
				choice.Text = "   " .. selectedText()
				if fire then callSafely(config.Callback, getValue()) end
			end
			for index, option in ipairs(options) do
				local optionButton = create("TextButton", optionsFrame, {
					Text = tostring(option), TextColor3 = COLORS.Muted, TextSize = 10, Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
					BackgroundColor3 = COLORS.Card, BorderSizePixel = 0,
					Size = UDim2.new(1, -4, 0, 25), LayoutOrder = index, ZIndex = 9,
				})
				corner(optionButton, 6)
				optionButton.Activated:Connect(function()
					local key = tostring(option)
					if multiple then
						selected[key] = not selected[key]
					else
						table.clear(selected)
						selected[key] = true
					end
					for _, child in ipairs(optionsFrame:GetChildren()) do
						if child:IsA("TextButton") then
							local cleanName = child.Text:gsub("^✦  ", ""):gsub("^   ", "")
							local isSelected = selected[cleanName] == true
							child.TextColor3 = isSelected and COLORS.Violet or COLORS.Muted
							child.BackgroundColor3 = isSelected and COLORS.CardHover or COLORS.Card
							child.Text = (isSelected and "✦  " or "   ") .. cleanName
						end
					end
					renderSelected(true)
					if not multiple then
						open = false
						optionsFrame.Visible = false
						card.Size = UDim2.new(1, 0, 0, 73)
						optionsArrow.Text = "⌄"
					end
				end)
			end
			local function set(value, fire)
				table.clear(selected)
				if type(value) == "table" then
					for _, option in ipairs(value) do selected[tostring(option)] = true end
				elseif value ~= nil then selected[tostring(value)] = true end
				renderSelected(fire ~= false)
				for _, child in ipairs(optionsFrame:GetChildren()) do
					if child:IsA("TextButton") then
						local cleanName = child.Text:gsub("^✦  ", ""):gsub("^   ", "")
						local isSelected = selected[cleanName] == true
						child.Text = (isSelected and "✦  " or "   ") .. cleanName
						child.TextColor3 = isSelected and COLORS.Violet or COLORS.Muted
					end
				end
			end
			choice.Activated:Connect(function()
				open = not open
				optionsFrame.Visible = open
				optionsArrow.Text = open and "⌃" or "⌄"
				card.Size = UDim2.new(1, 0, 0, open and (73 + listHeight) or 73)
			end)
			renderSelected(false)
			return { Set = function(_, value) set(value, true) end, Get = getValue }
		end

		function tab:CreateInput(config)
			config = config or {}
			local card = makeCard(self.Page, 73)
			textLabel(card, config.Name or "Input", 12, COLORS.White, Enum.Font.GothamBold, {
				Position = UDim2.fromOffset(14, 5), Size = UDim2.new(1, -28, 0, 22), ZIndex = 6,
			})
			local box = create("TextBox", card, {
				Text = tostring(config.CurrentValue or ""), PlaceholderText = config.PlaceholderText or "Type something...",
				PlaceholderColor3 = COLORS.Muted, ClearTextOnFocus = false,
				TextColor3 = COLORS.White, TextSize = 11, Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundColor3 = COLORS.Background, BorderSizePixel = 0,
				Position = UDim2.fromOffset(12, 32), Size = UDim2.new(1, -24, 0, 29), ZIndex = 7,
			})
			corner(box, 7)
			outline(box, COLORS.Line, 0.35, 1)
			create("UIPadding", box, { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9) })
			track(box.FocusLost:Connect(function(enterPressed)
				callSafely(config.Callback, box.Text, enterPressed)
				if config.RemoveTextAfterFocusLost then box.Text = "" end
			end))
			return { Set = function(_, value) box.Text = tostring(value) end, Get = function() return box.Text end, TextBox = box }
		end

		function tab:CreateKeybind(config)
			config = config or {}
			local keyName = tostring(config.CurrentKeybind or config.Keybind or "E")
			local hold = config.HoldToInteract == true
			local listening = false
			local card = makeCard(self.Page, 66)
			textLabel(card, config.Name or "Keybind", 12, COLORS.White, Enum.Font.GothamBold, {
				Position = UDim2.fromOffset(14, 7), Size = UDim2.new(1, -120, 0, 23), ZIndex = 6,
			})
			textLabel(card, config.Description or "Click the key capsule to change the bind.", 10, COLORS.Muted, Enum.Font.Gotham, {
				Position = UDim2.fromOffset(14, 31), Size = UDim2.new(1, -120, 0, 19), ZIndex = 6,
			})
			local keyButton = create("TextButton", card, {
				Text = keyName, TextColor3 = COLORS.Violet, TextSize = 11, Font = Enum.Font.GothamBold,
				BackgroundColor3 = COLORS.Background, BorderSizePixel = 0,
				AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -13, 0.5, 0),
				Size = UDim2.fromOffset(75, 30), ZIndex = 7,
			})
			corner(keyButton, 8)
			outline(keyButton, COLORS.Purple, 0.5, 1)
			local bind = { KeyName = keyName, Callback = config.Callback, Hold = hold, Listening = false, Down = false, Button = keyButton }
			table.insert(window.Keybinds, bind)
			track(keyButton.Activated:Connect(function()
				listening = true
				bind.Listening = true
				keyButton.Text = "..."
				keyButton.TextColor3 = COLORS.Mint
			end))
			return {
				Set = function(_, key)
					keyName = tostring(key)
					bind.KeyName = keyName
					bind.Listening = false
					listening = false
					keyButton.Text = keyName
				end,
				Get = function() return keyName end,
				Button = keyButton,
			}
		end

		track(button.Activated:Connect(function() refreshActiveTab(tab) end))
		if not self.ActiveTab then refreshActiveTab(tab) end
		return tab
	end

	-- Built-in landing tabs requested in the Paxz Scriptz brief. They remain ordinary tabs
	-- and can be populated or reused through window:CreateTab("Home"), etc.
	local home = window:CreateTab("Home", "✦")
	local scripts = window:CreateTab("Scripts", "⌘")
	local executors = window:CreateTab("Executors", "◇")

	home:CreateParagraph({
		Title = "Welcome to Paxz Scriptz",
		Content = "Cosmic Edition is online. Create your own controls with sections, sliders, toggles, dropdowns and callbacks. This is a UI template; connect each control to your own experience logic.",
		Height = 98,
	})
	home:CreateSection("Quick overview")
	home:CreateLabel({ Name = "✦   Cosmic dark mode enabled", Color = COLORS.Violet })
	home:CreateLabel({ Name = "●   UI ready — waiting for your actions", Color = COLORS.Mint })
	scripts:CreateParagraph({
		Title = "Script Library",
		Content = "Put your own script categories and actions on this page. Add a section, then call section:CreateButton(...) or section:CreateToggle(...).",
		Height = 91,
	})
	scripts:CreateSection("Your scripts")
	executors:CreateParagraph({
		Title = "Executor panel template",
		Content = "This page is a visual placeholder for status, configuration, or tools in your own Roblox experience. No external executor or exploit functionality is included.",
		Height = 91,
	})
	executors:CreateSection("Status")
	executors:CreateLabel({ Name = "UI layer active — connect your own safe callbacks", Color = COLORS.Mint })

	local function handleInputBegan(input, gameProcessed)
		if gameProcessed or UserInputService:GetFocusedTextBox() then return end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		for _, bind in ipairs(window.Keybinds) do
			if bind.Listening then
				if input.KeyCode == Enum.KeyCode.Escape then
					bind.Listening = false
					bind.Button.Text = bind.KeyName
					bind.Button.TextColor3 = COLORS.Violet
				else
					bind.KeyName = input.KeyCode.Name
					bind.Listening = false
					bind.Button.Text = bind.KeyName
					bind.Button.TextColor3 = COLORS.Violet
				end
			elseif bind.KeyName == input.KeyCode.Name then
				if bind.Hold then
					bind.Down = true
					callSafely(bind.Callback, true)
				else
					callSafely(bind.Callback)
				end
			end
		end
	end
	track(UserInputService.InputBegan:Connect(handleInputBegan))
	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		for _, bind in ipairs(window.Keybinds) do
			if bind.Hold and bind.Down and bind.KeyName == input.KeyCode.Name then
				bind.Down = false
				callSafely(bind.Callback, false)
			end
		end
	end))

	local dragging = false
	local dragStart, startPosition
	track(header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = main.Position
		end
	end))
	track(UserInputService.InputChanged:Connect(function(input)
		if dragging and dragStart and startPosition and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		end
	end))
	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end))

	local normalSize = main.Size
	track(minimizeButton.Activated:Connect(function()
		window.Minimized = not window.Minimized
		if window.Minimized then
			contentHost.Visible = false
			tween(main, 0.22, { Size = UDim2.fromOffset(normalSize.X.Offset, 56) })
			minimizeButton.Text = "+"
		else
			contentHost.Visible = true
			tween(main, 0.22, { Size = normalSize })
			minimizeButton.Text = "−"
		end
	end))
	track(closeButton.Activated:Connect(function()
		main.Visible = false
		window.Visible = false
	end))

	function window:SetVisibility(value)
		self.Visible = value == true
		main.Visible = self.Visible
	end
	function window:ToggleVisibility()
		self:SetVisibility(not self.Visible)
	end
	function window:Notify(config)
		config = config or {}
		local toast = create("Frame", toastLayer, {
			BackgroundColor3 = COLORS.Panel,
			BackgroundTransparency = 0.04,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 78),
			ZIndex = 51,
		})
		corner(toast, 12)
		outline(toast, COLORS.Purple, 0.35, 1)
		local accent = create("Frame", toast, {
			BackgroundColor3 = COLORS.Violet, BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 12), Size = UDim2.new(0, 3, 1, -24), ZIndex = 52,
		})
		corner(accent, 99)
		textLabel(toast, config.Title or "Paxz Scriptz", 12, COLORS.White, Enum.Font.GothamBold, {
			Position = UDim2.fromOffset(14, 10), Size = UDim2.new(1, -26, 0, 21), ZIndex = 52,
		})
		textLabel(toast, config.Content or config.Message or "Action completed.", 10, COLORS.Muted, Enum.Font.Gotham, {
			Position = UDim2.fromOffset(14, 32), Size = UDim2.new(1, -26, 0, 34),
			TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 52,
		})
		local scale = create("UIScale", toast, { Scale = 0.92 })
		tween(scale, 0.18, { Scale = 1 })
		task.delay(math.max(tonumber(config.Duration) or 4, 0.5), function()
			if toast.Parent then
				tween(toast, 0.18, { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0) })
				task.delay(0.2, function() if toast.Parent then toast:Destroy() end end)
			end
		end)
		return toast
	end
	function window:Destroy()
		if self.Destroyed then return end
		self.Destroyed = true
		for _, connection in ipairs(self.Connections) do
			pcall(function() connection:Disconnect() end)
		end
		if cameraConnection then pcall(function() cameraConnection:Disconnect() end) end
		if gui.Parent then gui:Destroy() end
	end

	-- Appear with a short fade-and-scale intro.
	main.BackgroundTransparency = 1
	local openingScale = create("UIScale", main, { Scale = 0.96 })
	tween(main, 0.32, { BackgroundTransparency = 0 })	tween(openingScale, 0.38, { Scale = 1 })

	return window
end

return setmetatable(Paxz, { __index = Paxz })
