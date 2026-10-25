--[[
	BT Tools Event: UI (ModuleScript, ক্লায়েন্ট)
	সব UI এর রং, ফন্ট আর ছোট সাহায্যকারী ফাংশন।
]]

local Players = game:GetService("Players")

local UI = {}

UI.Colors = {
	Panel = Color3.fromRGB(18, 20, 30),
	PanelLight = Color3.fromRGB(28, 31, 46),
	Row = Color3.fromRGB(34, 38, 56),
	Stroke = Color3.fromRGB(60, 66, 92),
	Text = Color3.fromRGB(235, 238, 250),
	SubText = Color3.fromRGB(160, 168, 195),
	Gold = Color3.fromRGB(255, 205, 60),
	GoldLight = Color3.fromRGB(255, 240, 170),
	GoldDeep = Color3.fromRGB(214, 140, 20),
	Green = Color3.fromRGB(60, 200, 120),
	Red = Color3.fromRGB(235, 80, 80),
	Blue = Color3.fromRGB(70, 140, 255),
}

UI.Fonts = {
	Title = Enum.Font.FredokaOne,
	Bold = Enum.Font.GothamBold,
	Body = Enum.Font.GothamMedium,
}

-- Instance বানিয়ে props বসায় আর children যোগ করে।
function UI.New(className: string, props: { [string]: any }?, children: { Instance }?): any
	local inst = Instance.new(className)
	if props then
		for key, value in props do
			if key ~= "Parent" then
				(inst :: any)[key] = value
			end
		end
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

function UI.Corner(radius: number?): UICorner
	return UI.New("UICorner", { CornerRadius = UDim.new(0, radius or 10) })
end

function UI.Stroke(color: Color3?, thickness: number?): UIStroke
	return UI.New("UIStroke", {
		Color = color or UI.Colors.Stroke,
		Thickness = thickness or 1.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

function UI.GoldGradient(rotation: number?): UIGradient
	return UI.New("UIGradient", {
		Rotation = rotation or 90,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, UI.Colors.GoldLight),
			ColorSequenceKeypoint.new(0.5, UI.Colors.Gold),
			ColorSequenceKeypoint.new(1, UI.Colors.GoldDeep),
		}),
	})
end

function UI.Label(props: { [string]: any }): TextLabel
	local defaults = {
		BackgroundTransparency = 1,
		Font = UI.Fonts.Body,
		TextColor3 = UI.Colors.Text,
		TextSize = 15,
		TextWrapped = true,
	}
	for key, value in props do
		defaults[key] = value
	end
	return UI.New("TextLabel", defaults)
end

function UI.Button(props: { [string]: any }): TextButton
	local defaults = {
		BackgroundColor3 = UI.Colors.Row,
		AutoButtonColor = true,
		Font = UI.Fonts.Bold,
		TextColor3 = UI.Colors.Text,
		TextSize = 15,
	}
	for key, value in props do
		defaults[key] = value
	end
	local button = UI.New("TextButton", defaults)
	UI.Corner(8).Parent = button
	return button
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
