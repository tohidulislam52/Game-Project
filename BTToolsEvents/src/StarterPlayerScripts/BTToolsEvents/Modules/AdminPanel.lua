--[[
	BT Tools Event: AdminPanel (ModuleScript, ক্লায়েন্ট)

	শুধু অ্যাডমিনের স্ক্রিনে বাঁ পাশে একটা 🎁 বাটন দেখায়। চাপলে প্যানেল খোলে, তিনটা ট্যাব:
	- 🎁 ইভেন্ট: মোট বক্স, সময়, টুল আর কয়টা বক্সে দেবেন, শুরুর নিরাপদ %, ফাঁক → START / STOP
	- 👤 প্লেয়ার: UserId দিয়ে টুল দেওয়া, সরানো, সেভ করা টুল দেখা (অফলাইন প্লেয়ারও)
	- 📜 ইতিহাস: শেষ ৩০ জন বিজয়ী
	এই বাটন লুকানো থাকলেও আসল নিরাপত্তা সার্ভারে, অ্যাডমিন না হলে সার্ভার কিছুই করবে না।
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("BTToolsEvents")
local Config = require(Shared:WaitForChild("Config"))
local AdminRemote = Shared:WaitForChild("Remotes"):WaitForChild("AdminRequest") :: RemoteFunction

local Modules = script.Parent
local UI = require(Modules:WaitForChild("UI"))

local C = UI.Colors
local player = Players.LocalPlayer

local AdminPanel = {}

local panel: Frame
local pages: { [string]: ScrollingFrame } = {}
local tabButtons: { [string]: TextButton } = {}
local info: any = nil

local function call(action: string, payload: any?): { ok: boolean, message: string?, data: any? }
	local ok, result = pcall(function()
		return AdminRemote:InvokeServer(action, payload)
	end)
	if ok and type(result) == "table" then
		return result
	end
	return { ok = false, message = "সার্ভারের সাথে যোগাযোগ হয়নি।" }
end

----------------------------------------------------------------------
-- ছোট UI অংশ
----------------------------------------------------------------------
local function page(name: string): ScrollingFrame
	local scroll = UI.New("ScrollingFrame", {
		Name = name,
		Position = UDim2.new(0, 0, 0, 92),
		Size = UDim2.new(1, 0, 1, -92),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = C.Gold,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = panel,
	}, {
		UI.New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
		UI.New("UIPadding", {
			PaddingLeft = UDim.new(0, 14),
			PaddingRight = UDim.new(0, 14),
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 14),
		}),
	})
	pages[name] = scroll
	return scroll
end

local order = 0
local function nextOrder(): number
	order += 1
	return order
end

local function section(parent: Instance, text: string): TextLabel
	return UI.Label({
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, 22),
		Font = UI.Fonts.Bold,
		TextSize = 15,
		TextColor3 = C.Gold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = text,
		Parent = parent,
	})
end

local function note(parent: Instance, text: string): TextLabel
	return UI.Label({
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextSize = 14,
		TextColor3 = C.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = text,
		Parent = parent,
	})
end

local function input(parent: Instance, labelText: string, default: string): TextBox
	local row = UI.New("Frame", {
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = C.Row,
		Parent = parent,
	}, { UI.Corner(8) })
	UI.Label({
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(0.62, -12, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = labelText,
		Parent = row,
	})
	local box = UI.New("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0.38, -8, 0, 28),
		BackgroundColor3 = C.Panel,
		ClearTextOnFocus = false,
		Font = UI.Fonts.Bold,
		TextSize = 16,
		TextColor3 = C.Text,
		PlaceholderColor3 = C.SubText,
		Text = default,
		Parent = row,
	}, { UI.Corner(6), UI.Stroke(C.Stroke, 1) })
	return box
end

local function readInt(box: TextBox): number?
	local value = tonumber(box.Text)
	if value and value % 1 == 0 then
		return value
	end
	return nil
end

local function setStatus(label: TextLabel, text: string, ok: boolean?)
	label.Text = text
	label.TextColor3 = if ok == nil then C.SubText elseif ok then C.Green else C.Red
end

----------------------------------------------------------------------
-- 🎁 ইভেন্ট ট্যাব
----------------------------------------------------------------------
local toolCounts: { [string]: number } = {}

local function buildEventPage()
	local p = page("Event")
	local defaults = info.defaults
	local infoLabel = note(p, "")
	local zoneText = if info.zoneCount > 0
		then `📍 স্পন জোন: {info.zoneCount} টা পার্ট পাওয়া গেছে।`
		else "📍 কোনো স্পন জোন নেই, আপনার চারপাশে radius এর মধ্যে বক্স পড়বে।"
	local showcaseText = if info.hasShowcase then "🏆 শোকেস পার্ট পাওয়া গেছে।" else "⚠️ WinnerShowcase পার্ট নেই, শোকেস দেখাবে না।"
	infoLabel.Text = zoneText .. "\n" .. showcaseText

	section(p, "⚙️ ইভেন্টের সেটিং")
	local totalBox = input(p, "মোট বক্স", tostring(defaults.totalBoxes))
	local minutesBox = input(p, "সময় (মিনিট)", tostring(defaults.minutes))
	local safeBox = input(p, "শুরুতে টুল নেই (%)", tostring(defaults.safePercent))
	local gapBox = input(p, "দুই টুলের মাঝে ফাঁক (বক্স)", tostring(defaults.gap))
	local radiusBox = input(p, "Radius (জোন না থাকলে)", tostring(defaults.radius))

	section(p, "🧰 কোন টুল কয়টা বক্সে দেবেন")
	if #info.tools == 0 then
		note(p, "ServerStorage > Tools ফোল্ডারে কোনো টুল নেই।")
	end
	for _, toolName in info.tools do
		toolCounts[toolName] = toolCounts[toolName] or 0
		local row = UI.New("Frame", {
			LayoutOrder = nextOrder(),
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = C.Row,
			Parent = p,
		}, { UI.Corner(8) })
		UI.Label({
			Position = UDim2.new(0, 12, 0, 0),
			Size = UDim2.new(1, -140, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrapped = false,
			Text = toolName,
			Parent = row,
		})
		local countLabel = UI.Label({
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -44, 0.5, 0),
			Size = UDim2.fromOffset(44, 28),
			Font = UI.Fonts.Bold,
			TextSize = 18,
			Text = tostring(toolCounts[toolName]),
			Parent = row,
		})
		local function refresh()
			local count = toolCounts[toolName]
			countLabel.Text = tostring(count)
			countLabel.TextColor3 = if count > 0 then C.Gold else C.SubText
			row.BackgroundColor3 = if count > 0 then C.Row:Lerp(C.Gold, 0.15) else C.Row
		end
		local minus = UI.Button({
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -92, 0.5, 0),
			Size = UDim2.fromOffset(32, 28),
			BackgroundColor3 = C.Panel,
			Text = "−",
			TextSize = 20,
			Parent = row,
		})
		local plus = UI.Button({
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			Size = UDim2.fromOffset(32, 28),
			BackgroundColor3 = C.Panel,
			Text = "+",
			TextSize = 20,
			Parent = row,
		})
		minus.Activated:Connect(function()
			toolCounts[toolName] = math.max(0, toolCounts[toolName] - 1)
			refresh()
		end)
		plus.Activated:Connect(function()
			toolCounts[toolName] = math.min(info.limits.maxBoxes, toolCounts[toolName] + 1)
			refresh()
		end)
		refresh()
	end

	local status = note(p, "")
	setStatus(status, if info.active then "🟢 এখন একটা ইভেন্ট চলছে।" else "টুল বেছে নিয়ে START চাপুন।", nil)

	local buttons = UI.New("Frame", {
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		Parent = p,
	})
	local startButton = UI.Button({
		Size = UDim2.new(0.62, -4, 1, 0),
		BackgroundColor3 = C.Green,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 18,
		Text = "▶ START EVENT",
		Parent = buttons,
	})
	local stopButton = UI.Button({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0.38, -4, 1, 0),
		BackgroundColor3 = C.Red,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 18,
		Text = "⏹ STOP",
		Parent = buttons,
	})

	local busy = false
	startButton.Activated:Connect(function()
		if busy then
			return
		end
		local payload = {
			totalBoxes = readInt(totalBox),
			minutes = readInt(minutesBox),
			radius = readInt(radiusBox),
			safePercent = readInt(safeBox),
			gap = readInt(gapBox),
			tools = toolCounts,
		}
		if not (payload.totalBoxes and payload.minutes and payload.radius and payload.safePercent and payload.gap) then
			setStatus(status, "সব ঘরে পূর্ণ সংখ্যা লিখুন।", false)
			return
		end
		busy = true
		startButton.Text = "⏳ বক্স স্পন হচ্ছে..."
		local response = call("Start", payload)
		setStatus(status, response.message or (if response.ok then "শুরু হয়েছে।" else "ব্যর্থ।"), response.ok)
		startButton.Text = "▶ START EVENT"
		busy = false
	end)
	stopButton.Activated:Connect(function()
		if busy then
			return
		end
		busy = true
		local response = call("Stop")
		setStatus(status, response.message or "", response.ok)
		busy = false
	end)
end

----------------------------------------------------------------------
-- 👤 প্লেয়ার ট্যাব
----------------------------------------------------------------------
local function buildPlayersPage()
	local p = page("Players")

	section(p, "👥 অনলাইন প্লেয়ার (চাপলে UserId বসবে)")
	local onlineList = UI.New("Frame", {
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = p,
	}, {
		UI.New("UIGridLayout", {
			CellSize = UDim2.new(0.5, -4, 0, 32),
			CellPadding = UDim2.fromOffset(8, 6),
			SortOrder = Enum.SortOrder.Name,
		}),
	})

	section(p, "🔢 UserId")
	local userIdBox = input(p, "UserId", "")
	userIdBox.PlaceholderText = "যেমন 7864126209"

	local function refreshOnline()
		for _, child in onlineList:GetChildren() do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		for _, other in Players:GetPlayers() do
			local button = UI.Button({
				Name = other.Name,
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Text = other.DisplayName,
				Parent = onlineList,
			})
			button.Activated:Connect(function()
				userIdBox.Text = tostring(other.UserId)
			end)
		end
	end
	refreshOnline()
	Players.PlayerAdded:Connect(refreshOnline)
	Players.PlayerRemoving:Connect(function()
		task.defer(refreshOnline)
	end)

	section(p, "🧰 টুল")
	local selectedTool: string? = nil
	local toolButtons: { TextButton } = {}
	for _, toolName in info.tools do
		local button = UI.Button({
			LayoutOrder = nextOrder(),
			Size = UDim2.new(1, 0, 0, 32),
			TextSize = 14,
			Text = toolName,
			Parent = p,
		})
		button.Activated:Connect(function()
			selectedTool = toolName
			for _, other in toolButtons do
				other.BackgroundColor3 = C.Row
				other.TextColor3 = C.Text
			end
			button.BackgroundColor3 = C.Gold
			button.TextColor3 = Color3.fromRGB(30, 22, 5)
		end)
		table.insert(toolButtons, button)
	end

	local status = note(p, "")
	local actions = UI.New("Frame", {
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		Parent = p,
	}, {
		UI.New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
		}),
	})
	local function actionButton(text: string, color: Color3): TextButton
		return UI.Button({
			Size = UDim2.new(1 / 3, -4, 1, 0),
			BackgroundColor3 = color,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 14,
			Text = text,
			Parent = actions,
		})
	end
	local giveButton = actionButton("✅ টুল দিন", C.Green)
	local removeButton = actionButton("🗑 সরান", C.Red)
	local viewButton = actionButton("📋 দেখুন", C.Blue)

	local function readUserId(): number?
		local userId = readInt(userIdBox)
		if not userId or userId < 1 then
			setStatus(status, "সঠিক UserId লিখুন।", false)
			return nil
		end
		return userId
	end

	local busy = false
	local function run(fn: () -> ())
		if busy then
			return
		end
		busy = true
		fn()
		busy = false
	end

	giveButton.Activated:Connect(function()
		run(function()
			local userId = readUserId()
			if not userId then
				return
			end
			if not selectedTool then
				setStatus(status, "একটা টুল বেছে নিন।", false)
				return
			end
			local response = call("GiveTool", { userId = userId, tool = selectedTool })
			setStatus(status, response.message or "", response.ok)
		end)
	end)
	removeButton.Activated:Connect(function()
		run(function()
			local userId = readUserId()
			if not userId then
				return
			end
			if not selectedTool then
				setStatus(status, "একটা টুল বেছে নিন।", false)
				return
			end
			local response = call("RemoveTool", { userId = userId, tool = selectedTool })
			setStatus(status, response.message or "", response.ok)
		end)
	end)
	viewButton.Activated:Connect(function()
		run(function()
			local userId = readUserId()
			if not userId then
				return
			end
			local response = call("GetPlayerTools", { userId = userId })
			if response.ok and type(response.data) == "table" then
				local list = if #response.data > 0 then table.concat(response.data, ", ") else "কোনো টুল নেই"
				setStatus(status, `{userId} এর সেভ করা টুল: {list}`, true)
			else
				setStatus(status, response.message or "পড়া যায়নি।", false)
			end
		end)
	end)
end

----------------------------------------------------------------------
-- 📜 ইতিহাস ট্যাব
----------------------------------------------------------------------
local function buildHistoryPage()
	local p = page("History")
	local refreshButton = UI.Button({
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = C.Blue,
		TextColor3 = Color3.new(1, 1, 1),
		Text = "🔄 ইতিহাস লোড করুন",
		Parent = p,
	})
	local list = UI.New("Frame", {
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = p,
	}, {
		UI.New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})

	local busy = false
	refreshButton.Activated:Connect(function()
		if busy then
			return
		end
		busy = true
		refreshButton.Text = "⏳ লোড হচ্ছে..."
		for _, child in list:GetChildren() do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		local response = call("GetHistory")
		if response.ok and type(response.data) == "table" then
			if #response.data == 0 then
				note(list, "এখনো কেউ জেতেনি।")
			end
			for i, entry in response.data do
				local when = if type(entry.at) == "number" then os.date("%d/%m/%Y %H:%M", entry.at) else "?"
				local row = UI.New("Frame", {
					LayoutOrder = i,
					Size = UDim2.new(1, 0, 0, 46),
					BackgroundColor3 = C.Row,
					Parent = list,
				}, { UI.Corner(8) })
				UI.Label({
					Position = UDim2.new(0, 10, 0, 4),
					Size = UDim2.new(1, -20, 0, 20),
					Font = UI.Fonts.Bold,
					TextXAlignment = Enum.TextXAlignment.Left,
					Text = `🏆 {entry.n} → {entry.t}`,
					Parent = row,
				})
				UI.Label({
					Position = UDim2.new(0, 10, 0, 24),
					Size = UDim2.new(1, -20, 0, 18),
					TextSize = 13,
					TextColor3 = C.SubText,
					TextXAlignment = Enum.TextXAlignment.Left,
					Text = `UserId {entry.u} · {when}`,
					Parent = row,
				})
			end
		else
			note(list, response.message or "ইতিহাস পড়া যায়নি।")
		end
		refreshButton.Text = "🔄 ইতিহাস লোড করুন"
		busy = false
	end)
end

----------------------------------------------------------------------
-- প্যানেল
----------------------------------------------------------------------
local function showTab(name: string)
	for tabName, scroll in pages do
		scroll.Visible = tabName == name
	end
	for tabName, button in tabButtons do
		local active = tabName == name
		button.BackgroundColor3 = if active then C.Gold else C.Row
		button.TextColor3 = if active then Color3.fromRGB(30, 22, 5) else C.Text
	end
end

local function buildPanel(gui: ScreenGui): Frame
	panel = UI.New("Frame", {
		Name = "AdminPanel",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.94, 0.84),
		BackgroundColor3 = C.Panel,
		Visible = false,
		Parent = gui,
	}, {
		UI.Corner(16),
		UI.Stroke(C.Gold, 2),
		UI.New("UISizeConstraint", { MaxSize = Vector2.new(440, 580) }),
	})

	local titleLabel = UI.Label({
		Position = UDim2.new(0, 16, 0, 10),
		Size = UDim2.new(1, -70, 0, 32),
		Font = UI.Fonts.Title,
		TextSize = 24,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "🎁 BT Tools Event",
		Parent = panel,
	})
	UI.GoldGradient(90).Parent = titleLabel

	local close = UI.Button({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 10),
		Size = UDim2.fromOffset(32, 32),
		BackgroundColor3 = C.Row,
		Text = "✕",
		Parent = panel,
	})
	close.Activated:Connect(function()
		panel.Visible = false
	end)

	local tabs = UI.New("Frame", {
		Position = UDim2.new(0, 14, 0, 50),
		Size = UDim2.new(1, -28, 0, 34),
		BackgroundTransparency = 1,
		Parent = panel,
	}, {
		UI.New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	for i, tab in { { "Event", "🎁 ইভেন্ট" }, { "Players", "👤 প্লেয়ার" }, { "History", "📜 ইতিহাস" } } do
		local button = UI.Button({
			LayoutOrder = i,
			Size = UDim2.new(1 / 3, -4, 1, 0),
			TextSize = 14,
			Text = tab[2],
			Parent = tabs,
		})
		button.Activated:Connect(function()
			showTab(tab[1])
		end)
		tabButtons[tab[1]] = button
	end

	buildEventPage()
	buildPlayersPage()
	buildHistoryPage()
	showTab("Event")
	return panel
end

function AdminPanel.Init()
	if not Config.IsAdmin(player) then
		return
	end
	local gui = UI.ScreenGui("BTToolsEventsAdmin", 10)

	local toggle = UI.Button({
		Name = "Toggle",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(52, 52),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Text = "🎁",
		TextSize = 28,
		Parent = gui,
	})
	local corner = toggle:FindFirstChildOfClass("UICorner")
	if corner then
		corner.CornerRadius = UDim.new(1, 0)
	end
	UI.GoldGradient(45).Parent = toggle
	UI.Stroke(Color3.fromRGB(120, 80, 10), 2).Parent = toggle

	local loading = false
	toggle.Activated:Connect(function()
		if panel then
			panel.Visible = not panel.Visible
			return
		end
		if loading then
			return
		end
		loading = true
		local response = call("GetInfo")
		loading = false
		if not response.ok or type(response.data) ~= "table" then
			warn("[BTToolsEvents] অ্যাডমিন প্যানেল খোলা যায়নি: " .. tostring(response.message))
			return
		end
		info = response.data
		buildPanel(gui).Visible = true
	end)
end

return AdminPanel
