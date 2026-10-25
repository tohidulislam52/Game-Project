--[[
	BT Tools Event: AdminPanel (ModuleScript, ক্লায়েন্ট)

	- গেম শুরুতে অ্যাডমিন বাটন লুকানো থাকে। চ্যাটে Config.ADMIN_COMMAND (/bttools) লিখলে
	  বাঁ পাশে 🎁 বাটন আসে, আবার লিখলে চলে যায় (R15)।
	- প্যানেলে চারটা ট্যাব:
	  ইভেন্ট   মোট বক্স, সময়, কোন টুল কয়টা বক্সে, শুরুর নিরাপদ %, ফাঁক → START / STOP
	  প্লেয়ার  UserId দিয়ে টুল দেওয়া, সরানো, সেভ করা টুল দেখা (অফলাইন প্লেয়ারও)
	  ইতিহাস  প্লেয়ার অনুযায়ী জেতা / গিফট / সরানো, UserId দিয়ে খোঁজা (R16)
	  থিম     তিনটা থিম নিজের স্ক্রিনে আগে দেখে নেওয়া
	বাটন লুকানো থাকলেও আসল নিরাপত্তা সার্ভারে। অ্যাডমিন না হলে সার্ভার কিছুই করবে না।
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("BTToolsEvents")
local Config = require(Shared:WaitForChild("Config"))
local AdminRemote = Shared:WaitForChild("Remotes"):WaitForChild("AdminRequest") :: RemoteFunction

local Modules = script.Parent
local UI = require(Modules:WaitForChild("UI"))
local HUD = require(Modules:WaitForChild("HUD"))

local R = UI.Role
local player = Players.LocalPlayer

local THEME_DESCRIPTIONS = {
	Midnight = "গাঢ় নীল কাচ, সোনালি রং",
	Frost = "হালকা সাদা কাচ, নীল রং",
	Ember = "কয়লা-কালো কাচ, কমলা রং",
}

local KIND_INFO = {
	win = { text = "জিতেছে", role = "Accent" },
	gift = { text = "গিফট", role = "Info" },
	remove = { text = "সরানো", role = "Danger" },
}

local AdminPanel = {}

local panel: Frame? = nil
local pages: { [string]: ScrollingFrame } = {}
local tabButtons: { [string]: TextButton } = {}
local info: any = nil
local refreshEventStatus: (() -> ())? = nil

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
local order = 0
local function nextOrder(): number
	order += 1
	return order
end

local function page(parent: Frame, name: string): ScrollingFrame
	local scroll = UI.New("ScrollingFrame", {
		Name = name,
		Position = UDim2.new(0, 0, 0, 104),
		Size = UDim2.new(1, 0, 1, -104),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = R("SubText"),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = parent,
	}, {
		UI.List(Enum.FillDirection.Vertical, 8),
		UI.New("UIPadding", {
			PaddingLeft = UDim.new(0, 18),
			PaddingRight = UDim.new(0, 18),
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 18),
		}),
	})
	pages[name] = scroll
	return scroll
end

local function caption(parent: Instance, text: string)
	UI.Caption({
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, 26),
		TextYAlignment = Enum.TextYAlignment.Bottom,
		Text = text,
		Parent = parent,
	})
end

local function note(parent: Instance, text: string, role: string?): TextLabel
	return UI.Label({
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextSize = 13,
		TextColor3 = R(role or "SubText"),
		Text = text,
		Parent = parent,
	})
end

local function row(parent: Instance, height: number?): Frame
	return UI.New("Frame", {
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, height or 42),
		BackgroundColor3 = R("Surface"),
		BorderSizePixel = 0,
		Parent = parent,
	}, { UI.Corner(10) })
end

local function textBox(props: { [string]: any }): TextBox
	local defaults: { [string]: any } = {
		BackgroundColor3 = R("Background"),
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = UI.Fonts.Bold,
		TextSize = 15,
		TextColor3 = R("Text"),
		PlaceholderColor3 = R("SubText"),
	}
	for key, value in props do
		defaults[key] = value
	end
	return UI.New("TextBox", defaults, { UI.Corner(8), UI.Stroke() })
end

local function input(parent: Instance, labelText: string, default: string, placeholder: string?): TextBox
	local r = row(parent)
	UI.Label({
		Position = UDim2.new(0, 14, 0, 0),
		Size = UDim2.new(0.62, -14, 1, 0),
		TextSize = 14,
		Text = labelText,
		Parent = r,
	})
	return textBox({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -7, 0.5, 0),
		Size = UDim2.new(0.38, -7, 0, 30),
		Text = default,
		PlaceholderText = placeholder or "",
		Parent = r,
	})
end

local function readInt(box: TextBox): number?
	local value = tonumber(box.Text)
	if value and value % 1 == 0 then
		return value
	end
	return nil
end

-- রঙিন বিন্দুসহ অবস্থা-লাইন।
local function statusLine(parent: Instance): (string, string?) -> ()
	local holder = UI.New("Frame", {
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = parent,
	})
	local dot = UI.New("Frame", {
		Position = UDim2.new(0, 2, 0, 5),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = R("SubText"),
		BorderSizePixel = 0,
		Parent = holder,
	}, { UI.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	local label = UI.Label({
		Position = UDim2.new(0, 18, 0, 0),
		Size = UDim2.new(1, -18, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextSize = 14,
		Parent = holder,
	})
	return function(text: string, role: string?)
		label.Text = text
		UI.Apply(dot, { BackgroundColor3 = R(role or "SubText") })
		UI.Apply(label, { TextColor3 = R(if role then role else "SubText") })
	end
end

local function buttonRow(parent: Instance, height: number): Frame
	return UI.New("Frame", {
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
		Parent = parent,
	}, { UI.List(Enum.FillDirection.Horizontal, 8) })
end

----------------------------------------------------------------------
-- ইভেন্ট ট্যাব
----------------------------------------------------------------------
local toolCounts: { [string]: number } = {}

local function buildEventPage(root: Frame)
	local p = page(root, "Event")
	local defaults = info.defaults

	local infoRow = row(p, 0)
	infoRow.AutomaticSize = Enum.AutomaticSize.Y
	UI.Padding(14, 10).Parent = infoRow
	UI.List(Enum.FillDirection.Vertical, 4).Parent = infoRow
	local setZone = statusLine(infoRow)
	local setShowcase = statusLine(infoRow)
	if info.zoneCount > 0 then
		setZone(`স্পন জোন: {info.zoneCount} টা পার্ট পাওয়া গেছে`, "Success")
	else
		setZone("কোনো স্পন জোন নেই, আপনার চারপাশে radius এর মধ্যে বক্স পড়বে", "Accent")
	end
	if info.hasShowcase then
		setShowcase("শোকেস পার্ট পাওয়া গেছে", "Success")
	else
		setShowcase("WinnerShowcase পার্ট নেই, শোকেস দেখাবে না", "Danger")
	end

	caption(p, "ইভেন্টের সেটিং")
	local totalBox = input(p, "মোট বক্স", tostring(defaults.totalBoxes))
	local minutesBox = input(p, "সময় (মিনিট)", tostring(defaults.minutes))
	local safeBox = input(p, "শুরুতে টুল নেই (%)", tostring(defaults.safePercent))
	local gapBox = input(p, "দুই টুলের মাঝে ফাঁক", tostring(defaults.gap))
	local radiusBox = input(p, "Radius (জোন না থাকলে)", tostring(defaults.radius))

	caption(p, "কোন টুল কয়টা বক্সে")
	if #info.tools == 0 then
		note(p, "ServerStorage > Tools ফোল্ডারে কোনো টুল নেই।", "Danger")
	end
	for _, toolName in info.tools do
		toolCounts[toolName] = toolCounts[toolName] or 0
		local r = row(p)
		UI.Label({
			Position = UDim2.new(0, 14, 0, 0),
			Size = UDim2.new(1, -140, 1, 0),
			TextSize = 14,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrapped = false,
			Text = toolName,
			Parent = r,
		})
		local countLabel = UI.Label({
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -44, 0.5, 0),
			Size = UDim2.fromOffset(40, 28),
			Font = UI.Fonts.Display,
			TextSize = 17,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = r,
		})
		local function refresh()
			local count = toolCounts[toolName]
			countLabel.Text = tostring(count)
			UI.Apply(countLabel, { TextColor3 = R(if count > 0 then "Accent" else "SubText") })
		end
		local minus = UI.Button({
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -86, 0.5, 0),
			Size = UDim2.fromOffset(30, 28),
			BackgroundColor3 = R("Background"),
			Text = "−",
			TextSize = 18,
			Parent = r,
		})
		local plus = UI.Button({
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			Size = UDim2.fromOffset(30, 28),
			BackgroundColor3 = R("Background"),
			Text = "+",
			TextSize = 18,
			Parent = r,
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

	caption(p, "")
	local setStatus = statusLine(p)
	refreshEventStatus = function()
		task.spawn(function()
			local response = call("GetInfo")
			if response.ok and type(response.data) == "table" then
				if response.data.active then
					setStatus("এখন একটা ইভেন্ট চলছে", "Success")
				else
					setStatus("টুল বেছে নিয়ে START চাপুন", nil)
				end
			end
		end)
	end
	setStatus(if info.active then "এখন একটা ইভেন্ট চলছে" else "টুল বেছে নিয়ে START চাপুন", if info.active then "Success" else nil)

	local buttons = buttonRow(p, 44)
	local startButton = UI.Button({
		LayoutOrder = 1,
		Size = UDim2.new(0.65, -4, 1, 0),
		TextSize = 16,
		Text = "START EVENT",
		Parent = buttons,
	}, "primary")
	local stopButton = UI.Button({
		LayoutOrder = 2,
		Size = UDim2.new(0.35, -4, 1, 0),
		TextSize = 16,
		Text = "STOP",
		Parent = buttons,
	}, "danger")

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
			setStatus("সব ঘরে পূর্ণ সংখ্যা লিখুন", "Danger")
			return
		end
		busy = true
		startButton.Text = "বক্স স্পন হচ্ছে…"
		local response = call("Start", payload)
		setStatus(response.message or (if response.ok then "শুরু হয়েছে" else "ব্যর্থ"), if response.ok then "Success" else "Danger")
		startButton.Text = "START EVENT"
		busy = false
	end)
	stopButton.Activated:Connect(function()
		if busy then
			return
		end
		busy = true
		local response = call("Stop")
		setStatus(response.message or "", if response.ok then "Success" else "Danger")
		busy = false
	end)
end

----------------------------------------------------------------------
-- প্লেয়ার ট্যাব
----------------------------------------------------------------------
local function buildPlayersPage(root: Frame)
	local p = page(root, "Players")

	caption(p, "অনলাইন প্লেয়ার · চাপলে UserId বসবে")
	local onlineList = UI.New("Frame", {
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = p,
	}, {
		UI.New("UIGridLayout", {
			CellSize = UDim2.new(0.5, -4, 0, 34),
			CellPadding = UDim2.fromOffset(8, 8),
			SortOrder = Enum.SortOrder.Name,
		}),
	})

	caption(p, "প্লেয়ার")
	local userIdBox = input(p, "UserId", "", "যেমন 7864126209")

	local function refreshOnline()
		for _, child in onlineList:GetChildren() do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		for _, other in Players:GetPlayers() do
			local button = UI.Button({
				Name = other.Name,
				Font = UI.Fonts.Medium,
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

	caption(p, "টুল")
	local selectedTool: string? = nil
	local toolButtons: { TextButton } = {}
	for _, toolName in info.tools do
		local button = UI.Button({
			LayoutOrder = nextOrder(),
			Size = UDim2.new(1, 0, 0, 36),
			Font = UI.Fonts.Medium,
			TextSize = 14,
			Text = toolName,
			Parent = p,
		})
		button.Activated:Connect(function()
			selectedTool = toolName
			for _, other in toolButtons do
				UI.SetButtonStyle(other, "ghost")
			end
			UI.SetButtonStyle(button, "primary")
		end)
		table.insert(toolButtons, button)
	end

	caption(p, "")
	local setStatus = statusLine(p)
	setStatus("UserId আর টুল বেছে নিন", nil)
	local actions = buttonRow(p, 42)
	local function actionButton(order: number, text: string, style: string): TextButton
		return UI.Button({
			LayoutOrder = order,
			Size = UDim2.new(1 / 3, -6, 1, 0),
			TextSize = 14,
			Text = text,
			Parent = actions,
		}, style)
	end
	local giveButton = actionButton(1, "টুল দিন", "success")
	local removeButton = actionButton(2, "সরান", "danger")
	local viewButton = actionButton(3, "দেখুন", "info")

	local function readUserId(): number?
		local userId = readInt(userIdBox)
		if not userId or userId < 1 then
			setStatus("সঠিক UserId লিখুন", "Danger")
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

	local function changeTool(action: string)
		run(function()
			local userId = readUserId()
			if not userId then
				return
			end
			if not selectedTool then
				setStatus("একটা টুল বেছে নিন", "Danger")
				return
			end
			local response = call(action, { userId = userId, tool = selectedTool })
			setStatus(response.message or "", if response.ok then "Success" else "Danger")
		end)
	end
	giveButton.Activated:Connect(function()
		changeTool("GiveTool")
	end)
	removeButton.Activated:Connect(function()
		changeTool("RemoveTool")
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
				setStatus(`{userId} এর সেভ করা টুল: {list}`, "Info")
			else
				setStatus(response.message or "পড়া যায়নি", "Danger")
			end
		end)
	end)
end

----------------------------------------------------------------------
-- ইতিহাস ট্যাব
----------------------------------------------------------------------
local function historyCard(parent: Instance, index: number, entry: any)
	local card = UI.New("Frame", {
		LayoutOrder = index,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = R("Surface"),
		BorderSizePixel = 0,
		Parent = parent,
	}, {
		UI.Corner(12),
		UI.Padding(14, 12),
		UI.List(Enum.FillDirection.Vertical, 6),
	})
	local header = UI.New("Frame", {
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Parent = card,
	})
	UI.Label({
		Size = UDim2.new(0.6, 0, 1, 0),
		Font = UI.Fonts.Bold,
		TextSize = 15,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextWrapped = false,
		Text = tostring(entry.n or "?"),
		Parent = header,
	})
	UI.Label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0.4, 0, 1, 0),
		TextSize = 12,
		TextColor3 = R("SubText"),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextWrapped = false,
		Text = `UserId {entry.u}`,
		Parent = header,
	})
	for i, record in entry.r or {} do
		local kind = KIND_INFO[record.k] or KIND_INFO.win
		local line = UI.New("Frame", {
			LayoutOrder = i,
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			Parent = card,
		})
		local badge = UI.Label({
			Size = UDim2.fromOffset(62, 20),
			BackgroundColor3 = R(kind.role),
			BackgroundTransparency = 0.82,
			Font = UI.Fonts.Bold,
			TextSize = 12,
			TextColor3 = R(kind.role),
			TextXAlignment = Enum.TextXAlignment.Center,
			Text = kind.text,
			Parent = line,
		})
		UI.Corner(6).Parent = badge
		local when = if type(record.at) == "number" then os.date("%d/%m %H:%M", record.at) else "?"
		local by = if type(record.by) == "string" then ` · {record.by}` else ""
		UI.Label({
			Position = UDim2.new(0, 72, 0, 0),
			Size = UDim2.new(1, -72, 1, 0),
			TextSize = 14,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrapped = false,
			RichText = true,
			Text = `{record.t}  <font transparency="0.45">{when}{by}</font>`,
			Parent = line,
		})
	end
end

local function buildHistoryPage(root: Frame)
	local p = page(root, "History")

	caption(p, "খুঁজুন")
	local search = row(p, 44)
	local searchBox = textBox({
		Position = UDim2.new(0, 6, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(1, -150, 0, 32),
		PlaceholderText = "UserId (খালি = সবাই)",
		Text = "",
		Parent = search,
	})
	local findButton = UI.Button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		Size = UDim2.fromOffset(132, 32),
		TextSize = 14,
		Text = "লোড করুন",
		Parent = search,
	}, "primary")

	local setStatus = statusLine(p)
	setStatus("সবচেয়ে সাম্প্রতিক প্লেয়ার আগে দেখাবে", nil)

	local list = UI.New("Frame", {
		LayoutOrder = nextOrder(),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = p,
	}, { UI.List(Enum.FillDirection.Vertical, 8) })

	local busy = false
	findButton.Activated:Connect(function()
		if busy then
			return
		end
		local payload = nil
		if searchBox.Text ~= "" then
			local userId = readInt(searchBox)
			if not userId or userId < 1 then
				setStatus("সঠিক UserId লিখুন", "Danger")
				return
			end
			payload = { userId = userId }
		end
		busy = true
		findButton.Text = "লোড হচ্ছে…"
		for _, child in list:GetChildren() do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		local response = call("GetHistory", payload)
		if response.ok and type(response.data) == "table" then
			if #response.data == 0 then
				setStatus(if payload then "এই UserId এর কোনো ইতিহাস নেই" else "এখনো কোনো ইতিহাস নেই", nil)
			else
				setStatus(`{#response.data} জন প্লেয়ার`, "Info")
			end
			for i, entry in response.data do
				historyCard(list, i, entry)
			end
		else
			setStatus(response.message or "ইতিহাস পড়া যায়নি", "Danger")
		end
		findButton.Text = "লোড করুন"
		busy = false
	end)
end

----------------------------------------------------------------------
-- থিম ট্যাব
----------------------------------------------------------------------
local function buildThemePage(root: Frame)
	local p = page(root, "Theme")
	note(
		p,
		"এখানে থিম বদলালে শুধু আপনার স্ক্রিনে দেখাবে। সবার জন্য রাখতে ReplicatedStorage > BTToolsEvents > Config এ THEME = \"নাম\" লিখুন।"
	)
	caption(p, "থিম")

	local names = {}
	for name in Config.THEMES do
		table.insert(names, name)
	end
	table.sort(names)

	local refreshers: { () -> () } = {}
	for _, name in names do
		local theme = Config.THEMES[name]
		local r = row(p, 64)
		local swatches = UI.New("Frame", {
			Position = UDim2.new(0, 14, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromOffset(70, 26),
			BackgroundTransparency = 1,
			Parent = r,
		}, { UI.List(Enum.FillDirection.Horizontal, -6) })
		for i, colorKey in { "Background", "Surface", "Accent" } do
			UI.New("Frame", {
				LayoutOrder = i,
				Size = UDim2.fromOffset(26, 26),
				BackgroundColor3 = theme[colorKey],
				BorderSizePixel = 0,
				Parent = swatches,
			}, {
				UI.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
				UI.New("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = 0.7, Thickness = 1.5 }),
			})
		end
		UI.Label({
			Position = UDim2.new(0, 96, 0, 12),
			Size = UDim2.new(1, -200, 0, 20),
			Font = UI.Fonts.Bold,
			TextSize = 15,
			TextWrapped = false,
			Text = name,
			Parent = r,
		})
		local sub = UI.Label({
			Position = UDim2.new(0, 96, 0, 32),
			Size = UDim2.new(1, -200, 0, 18),
			TextSize = 12,
			TextColor3 = R("SubText"),
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrapped = false,
			Parent = r,
		})
		local button = UI.Button({
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(84, 32),
			TextSize = 14,
			Parent = r,
		})
		local function refresh()
			local active = UI.ThemeName() == name
			sub.Text = (THEME_DESCRIPTIONS[name] or "") .. (if name == Config.THEME then " · সবার জন্য চালু" else "")
			button.Text = if active then "চলছে" else "দেখুন"
			UI.SetButtonStyle(button, if active then "primary" else "ghost")
		end
		button.Activated:Connect(function()
			UI.SetTheme(name)
			for _, fn in refreshers do
				fn()
			end
		end)
		table.insert(refreshers, refresh)
		refresh()
	end
end

----------------------------------------------------------------------
-- প্যানেল
----------------------------------------------------------------------
local function showTab(name: string)
	for tabName, scroll in pages do
		scroll.Visible = tabName == name
	end
	for tabName, button in tabButtons do
		UI.SetButtonStyle(button, if tabName == name then "primary" else "ghost")
	end
end

local function buildPanel(gui: ScreenGui): Frame
	local root = UI.Card({
		Name = "AdminPanel",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.94, 0.86),
		Visible = false,
		Parent = gui,
	}, {
		UI.New("UISizeConstraint", { MaxSize = Vector2.new(440, 600) }),
	})

	UI.Label({
		Position = UDim2.new(0, 18, 0, 14),
		Size = UDim2.new(1, -80, 0, 26),
		Font = UI.Fonts.Display,
		TextSize = 22,
		TextWrapped = false,
		Text = "BT Tools Event",
		Parent = root,
	})
	UI.Label({
		Position = UDim2.new(0, 18, 0, 40),
		Size = UDim2.new(1, -80, 0, 16),
		TextSize = 13,
		TextColor3 = R("SubText"),
		TextWrapped = false,
		Text = "অ্যাডমিন প্যানেল",
		Parent = root,
	})

	local close = UI.Button({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 14),
		Size = UDim2.fromOffset(32, 32),
		Font = UI.Fonts.Bold,
		TextSize = 14,
		Text = "✕",
		Parent = root,
	})
	close.Activated:Connect(function()
		root.Visible = false
	end)

	local tabs = UI.New("Frame", {
		Position = UDim2.new(0, 18, 0, 64),
		Size = UDim2.new(1, -36, 0, 32),
		BackgroundTransparency = 1,
		Parent = root,
	}, { UI.List(Enum.FillDirection.Horizontal, 6) })
	for i, tab in { { "Event", "ইভেন্ট" }, { "Players", "প্লেয়ার" }, { "History", "ইতিহাস" }, { "Theme", "থিম" } } do
		local button = UI.Button({
			LayoutOrder = i,
			Size = UDim2.new(0.25, -5, 1, 0),
			TextSize = 14,
			Text = tab[2],
			Parent = tabs,
		})
		button.Activated:Connect(function()
			showTab(tab[1])
		end)
		tabButtons[tab[1]] = button
	end

	buildEventPage(root)
	buildPlayersPage(root)
	buildHistoryPage(root)
	buildThemePage(root)
	showTab("Event")
	return root
end

----------------------------------------------------------------------
-- চ্যাট কমান্ড
----------------------------------------------------------------------
local function listenForCommand(onCommand: () -> ())
	local command = string.lower(Config.ADMIN_COMMAND)
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		-- এভাবে বানানো কমান্ড চ্যাটে অন্য কেউ দেখে না।
		local chatCommand = Instance.new("TextChatCommand")
		chatCommand.Name = "BTToolsAdminCommand"
		chatCommand.PrimaryAlias = Config.ADMIN_COMMAND
		chatCommand.Triggered:Connect(function(source: TextSource)
			if source.UserId == player.UserId then
				onCommand()
			end
		end)
		chatCommand.Parent = TextChatService
	else
		player.Chatted:Connect(function(message)
			local trimmed = string.gsub(message, "^%s*(.-)%s*$", "%1")
			if string.lower(trimmed) == command then
				onCommand()
			end
		end)
	end
end

function AdminPanel.Init()
	if not Config.IsAdmin(player) then
		return
	end
	local gui = UI.ScreenGui("BTToolsEventsAdmin", 10)

	local toggle = UI.Button({
		Name = "Toggle",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 14, 0.5, 0),
		Size = UDim2.fromOffset(50, 50),
		BackgroundColor3 = R("Background"),
		BackgroundTransparency = UI.GlassTransparency,
		Text = "🎁",
		TextSize = 24,
		Visible = false,
		Parent = gui,
	})
	UI.Round(toggle)
	UI.Stroke("Accent", 0.2).Parent = toggle
	local toggleScale = toggle:FindFirstChildOfClass("UIScale")

	local loading = false
	toggle.Activated:Connect(function()
		if panel then
			panel.Visible = not panel.Visible
			if panel.Visible and refreshEventStatus then
				refreshEventStatus()
			end
			return
		end
		if loading then
			return
		end
		loading = true
		local response = call("GetInfo")
		loading = false
		if not response.ok or type(response.data) ~= "table" then
			HUD.Toast(response.message or "অ্যাডমিন প্যানেল খোলা যায়নি", "Danger")
			return
		end
		info = response.data
		local built = buildPanel(gui)
		panel = built
		built.Visible = true
	end)

	listenForCommand(function()
		toggle.Visible = not toggle.Visible
		if toggle.Visible then
			HUD.Toast("অ্যাডমিন বাটন চালু", "Success")
			if toggleScale then
				toggleScale.Scale = 0.5
				TweenService:Create(toggleScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			end
		else
			HUD.Toast("অ্যাডমিন বাটন বন্ধ", nil)
			if panel then
				panel.Visible = false
			end
		end
	end)
end

return AdminPanel
