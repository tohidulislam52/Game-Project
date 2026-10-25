--[[
	BT Tools Event: UI (ModuleScript, ক্লায়েন্ট)

	সব UI এর ডিজাইনের ভিত্তি: থিম, ফন্ট, আর ছোট সাহায্যকারী ফাংশন।

	থিম কীভাবে কাজ করে:
	- রং সরাসরি না লিখে UI.Role("Accent") এর মতো "ভূমিকা" দেওয়া হয়।
	- UI.New সেই ভূমিকা মনে রাখে, তাই UI.SetTheme("Frost") ডাকলে সব UI সাথে সাথে নতুন রঙে বদলে যায়।
	- থিমের রং Config.THEMES এ।
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("BTToolsEvents"):WaitForChild("Config"))

type Theme = { [string]: any }
type Binding = { __btRole: string? , __btFn: ((Theme) -> any)? }

local UI = {}

UI.Fonts = {
	Display = Enum.Font.BuilderSansExtraBold,
	Bold = Enum.Font.BuilderSansBold,
	Medium = Enum.Font.BuilderSansMedium,
	Regular = Enum.Font.BuilderSans,
}

local currentName = Config.THEME
local current: Theme = Config.GetTheme(currentName)

-- instance -> { property -> binding }। weak key, তাই মুছে যাওয়া UI মেমরিতে আটকে থাকে না।
local bindings: { [Instance]: { [string]: Binding } } = setmetatable({}, { __mode = "k" }) :: any
local themeChanged = Instance.new("BindableEvent")
UI.ThemeChanged = themeChanged.Event

----------------------------------------------------------------------
-- থিম
----------------------------------------------------------------------
-- থিমের একটা রং (যেমন UI.Role("Accent"))।
function UI.Role(role: string): Binding
	return { __btRole = role }
end

-- থিম থেকে হিসাব করা মান (যেমন gradient বা transparency)।
function UI.Fn(fn: (Theme) -> any): Binding
	return { __btFn = fn }
end

local function isBinding(value: any): boolean
	return type(value) == "table" and (value.__btRole ~= nil or value.__btFn ~= nil)
end

local function resolve(binding: Binding): any
	if binding.__btFn then
		return binding.__btFn(current)
	end
	return current[binding.__btRole :: string]
end

function UI.Theme(): Theme
	return current
end

function UI.ThemeName(): string
	return currentName
end

function UI.SetTheme(name: string)
	if not Config.THEMES[name] then
		return
	end
	currentName = name
	current = Config.GetTheme(name)
	for inst, props in bindings do
		local target: any = inst
		for key, binding in props do
			target[key] = resolve(binding)
		end
	end
	themeChanged:Fire(name)
end

-- props বসায়। কোনো মান থিমের ভূমিকা হলে সেটা মনে রাখে।
function UI.Apply(inst: Instance, props: { [string]: any })
	for key, value in props do
		if key == "Parent" then
			continue
		end
		if isBinding(value) then
			local map = bindings[inst]
			if not map then
				map = {}
				bindings[inst] = map
			end
			map[key] = value
			local target: any = inst
			target[key] = resolve(value)
		else
			local map = bindings[inst]
			if map then
				map[key] = nil
			end
			local target: any = inst
			target[key] = value
		end
	end
end

function UI.New(className: string, props: { [string]: any }?, children: { Instance }?): any
	local inst = Instance.new(className)
	if props then
		UI.Apply(inst, props)
	end
	if children then
		for _, child in children do
			child.Parent = inst
		end
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

----------------------------------------------------------------------
-- ছোট অংশ
----------------------------------------------------------------------
local R = UI.Role

-- প্যানেলের কাচের মতো হালকা স্বচ্ছ পেছন।
UI.GlassTransparency = UI.Fn(function(theme)
	return theme.Glass
end)

function UI.Corner(radius: number?): UICorner
	return UI.New("UICorner", { CornerRadius = UDim.new(0, radius or 12) })
end

-- কোণা পুরো গোল (pill বা বৃত্ত)।
function UI.Round(inst: Instance)
	local corner = inst:FindFirstChildOfClass("UICorner")
	if corner then
		corner.CornerRadius = UDim.new(1, 0)
	else
		UI.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = inst })
	end
end

-- হালকা চিকন বর্ডার। role দিলে সেই রঙে (যেমন "Accent")।
function UI.Stroke(role: string?, transparency: number?): UIStroke
	return UI.New("UIStroke", {
		Color = R(role or "Stroke"),
		Transparency = if transparency
			then transparency
			else UI.Fn(function(theme)
				return if role then 0.35 else theme.StrokeTransparency
			end),
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function UI.Padding(x: number, y: number?): UIPadding
	return UI.New("UIPadding", {
		PaddingLeft = UDim.new(0, x),
		PaddingRight = UDim.new(0, x),
		PaddingTop = UDim.new(0, y or x),
		PaddingBottom = UDim.new(0, y or x),
	})
end

function UI.AccentGradient(rotation: number?): UIGradient
	return UI.New("UIGradient", {
		Rotation = rotation or 0,
		Color = UI.Fn(function(theme)
			return ColorSequence.new(theme.Accent, theme.AccentDeep)
		end),
	})
end

function UI.List(direction: Enum.FillDirection?, padding: number?, align: Enum.HorizontalAlignment?): UIListLayout
	return UI.New("UIListLayout", {
		FillDirection = direction or Enum.FillDirection.Vertical,
		Padding = UDim.new(0, padding or 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})
end

-- কাচের প্যানেল (Frame)।
function UI.Card(props: { [string]: any }, children: { Instance }?): Frame
	local defaults: { [string]: any } = {
		BackgroundColor3 = R("Background"),
		BackgroundTransparency = UI.GlassTransparency,
		BorderSizePixel = 0,
	}
	for key, value in props do
		defaults[key] = value
	end
	local card = UI.New("Frame", defaults, children)
	UI.Corner(14).Parent = card
	UI.Stroke().Parent = card
	return card
end

function UI.Label(props: { [string]: any }): TextLabel
	local defaults: { [string]: any } = {
		BackgroundTransparency = 1,
		Font = UI.Fonts.Medium,
		TextColor3 = R("Text"),
		TextSize = 15,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	}
	for key, value in props do
		defaults[key] = value
	end
	return UI.New("TextLabel", defaults)
end

-- ছোট বড়-হাতের মতো সেকশন শিরোনাম।
function UI.Caption(props: { [string]: any }): TextLabel
	local defaults: { [string]: any } = {
		Font = UI.Fonts.Bold,
		TextSize = 12,
		TextColor3 = R("SubText"),
		Size = UDim2.new(1, 0, 0, 18),
	}
	for key, value in props do
		defaults[key] = value
	end
	return UI.Label(defaults)
end

local BUTTON_STYLES: { [string]: { bg: string, text: string } } = {
	primary = { bg = "Accent", text = "OnAccent" },
	ghost = { bg = "Surface", text = "Text" },
	success = { bg = "Success", text = "OnAccent" },
	danger = { bg = "Danger", text = "OnAccent" },
	info = { bg = "Info", text = "OnAccent" },
}

-- বাটন: hover এ হালকা উজ্জ্বল, চাপলে একটু ছোট হয়।
function UI.Button(props: { [string]: any }, style: string?): TextButton
	local s = BUTTON_STYLES[style or "ghost"] or BUTTON_STYLES.ghost
	local defaults: { [string]: any } = {
		BackgroundColor3 = R(s.bg),
		TextColor3 = if style == "success" or style == "danger" or style == "info"
			then Color3.new(1, 1, 1)
			else R(s.text),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Font = UI.Fonts.Bold,
		TextSize = 15,
	}
	for key, value in props do
		defaults[key] = value
	end
	local button = UI.New("TextButton", defaults)
	UI.Corner(10).Parent = button
	local scale = UI.New("UIScale", { Parent = button })
	local quick = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	-- hover এর আগের স্বচ্ছতা মনে রাখা, যাতে কাচের বাটন hover এর পরে ভরাট না হয়ে যায়।
	local baseTransparency: number? = nil
	button.MouseEnter:Connect(function()
		baseTransparency = baseTransparency or button.BackgroundTransparency
		local target = math.min(1, (baseTransparency :: number) + 0.12)
		TweenService:Create(button, quick, { BackgroundTransparency = target }):Play()
	end)
	button.MouseLeave:Connect(function()
		if baseTransparency then
			TweenService:Create(button, quick, { BackgroundTransparency = baseTransparency }):Play()
			baseTransparency = nil
		end
		TweenService:Create(scale, quick, { Scale = 1 }):Play()
	end)
	button.MouseButton1Down:Connect(function()
		TweenService:Create(scale, quick, { Scale = 0.96 }):Play()
	end)
	button.MouseButton1Up:Connect(function()
		TweenService:Create(scale, quick, { Scale = 1 }):Play()
	end)
	return button
end

-- বাটনের ধরন বদলানো (যেমন ট্যাব সিলেক্ট হলে)।
function UI.SetButtonStyle(button: TextButton, style: string)
	local s = BUTTON_STYLES[style] or BUTTON_STYLES.ghost
	UI.Apply(button, { BackgroundColor3 = R(s.bg), TextColor3 = R(s.text) })
end

function UI.ScreenGui(name: string, displayOrder: number): ScreenGui
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local old = playerGui:FindFirstChild(name)
	if old then
		old:Destroy()
	end
	return UI.New("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = displayOrder,
		Parent = playerGui,
	})
end

return UI
