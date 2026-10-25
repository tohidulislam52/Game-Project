--[[
	BT Tools Event: HUD (ModuleScript, ক্লায়েন্ট)

	- ওপরে ছোট কাচের কাউন্টার: [ 17/20 খোলা | 4:32 বাকি ] (R12)। ইভেন্ট না চললে লুকানো।
	- ব্যানার: ইভেন্ট শুরু, কেউ জিতলে, ইভেন্ট শেষ। বাঁ পাশে রঙিন দাগ।
	- ফলাফল কার্ড: বক্স খোলার পরে কী পেলেন।
	- ছোট মেসেজ (toast)।
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("BTToolsEvents")
local Remotes = Shared:WaitForChild("Remotes")

local Modules = script.Parent
local UI = require(Modules:WaitForChild("UI"))
local Sounds = require(Modules:WaitForChild("Sounds"))

local R = UI.Role

local HUD = {}

local gui: ScreenGui
local pill: Frame
local countLabel: TextLabel
local timeLabel: TextLabel
local pillScale: UIScale

local bannerQueue: { { title: string, body: string, role: string } } = {}
local bannerRunning = false

----------------------------------------------------------------------
-- কাউন্টার
----------------------------------------------------------------------
local function formatTime(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", seconds // 60, seconds % 60)
end

local function refreshCounter()
	local active = Shared:GetAttribute("Active") == true
	pill.Visible = active
	if not active then
		return
	end
	local total = Shared:GetAttribute("Total") or 0
	local opened = Shared:GetAttribute("Opened") or 0
	countLabel.Text = `{opened}/{total}`
end

local function refreshTimer()
	local endsAt = Shared:GetAttribute("EndsAt")
	if type(endsAt) == "number" and pill.Visible then
		local left = endsAt - Workspace:GetServerTimeNow()
		timeLabel.Text = formatTime(left)
		UI.Apply(timeLabel, { TextColor3 = R(if left <= 30 then "Danger" else "Text") })
	end
end

local function pulse()
	pillScale.Scale = 1.12
	TweenService:Create(pillScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

-- কাউন্টারের এক ভাগ: বড় সংখ্যা আর তার পাশে ছোট লেখা।
local function segment(order: number, caption: string): TextLabel
	local holder = UI.New("Frame", {
		LayoutOrder = order,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(0, 32),
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = pill,
	}, { UI.List(Enum.FillDirection.Horizontal, 5) })
	local value = UI.Label({
		LayoutOrder = 1,
		Size = UDim2.fromOffset(0, 32),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = UI.Fonts.Display,
		TextSize = 18,
		TextWrapped = false,
		Parent = holder,
	})
	UI.Label({
		LayoutOrder = 2,
		Size = UDim2.fromOffset(0, 32),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = UI.Fonts.Medium,
		TextSize = 13,
		TextColor3 = R("SubText"),
		TextWrapped = false,
		Text = caption,
		Parent = holder,
	})
	return value
end

local function buildCounter()
	pill = UI.Card({
		Name = "Counter",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 8),
		Size = UDim2.fromOffset(0, 32),
		AutomaticSize = Enum.AutomaticSize.X,
		Visible = false,
		Parent = gui,
	}, {
		UI.New("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }),
		UI.List(Enum.FillDirection.Horizontal, 12),
	})
	UI.Round(pill)
	pillScale = UI.New("UIScale", { Parent = pill })

	-- বাঁ পাশে accent রঙের ছোট বিন্দু, ইভেন্ট চলছে বোঝাতে।
	UI.New("Frame", {
		LayoutOrder = 0,
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = R("Accent"),
		BorderSizePixel = 0,
		Parent = pill,
	}, { UI.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	countLabel = segment(1, "খোলা")
	UI.New("Frame", {
		LayoutOrder = 2,
		Size = UDim2.fromOffset(1, 16),
		BackgroundColor3 = R("Stroke"),
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		Parent = pill,
	})
	timeLabel = segment(3, "বাকি")

	local lastOpened = Shared:GetAttribute("Opened")
	for _, attribute in { "Active", "Total", "Opened", "EndsAt" } do
		Shared:GetAttributeChangedSignal(attribute):Connect(function()
			refreshCounter()
			refreshTimer()
			local opened = Shared:GetAttribute("Opened")
			if attribute == "Opened" and opened ~= lastOpened and (opened or 0) > 0 then
				pulse()
			end
			lastOpened = opened
		end)
	end
	refreshCounter()
	refreshTimer()
	task.spawn(function()
		while true do
			task.wait(0.25)
			refreshTimer()
		end
	end)
end

----------------------------------------------------------------------
-- ব্যানার
----------------------------------------------------------------------
local BANNER_HIDDEN = UDim2.new(0.5, 0, 0, -110)
local BANNER_SHOWN = UDim2.new(0.5, 0, 0, 50)

local function showBanner(title: string, body: string, role: string)
	local card = UI.Card({
		Name = "Banner",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = BANNER_HIDDEN,
		Size = UDim2.new(0.92, 0, 0, 72),
		Parent = gui,
	}, {
		UI.New("UISizeConstraint", { MaxSize = Vector2.new(500, 72) }),
		UI.New("Frame", {
			Name = "AccentBar",
			Position = UDim2.new(0, 12, 0, 14),
			Size = UDim2.new(0, 4, 1, -28),
			BackgroundColor3 = R(role),
			BorderSizePixel = 0,
		}, { UI.New("UICorner", { CornerRadius = UDim.new(1, 0) }) }),
		UI.Label({
			Name = "Title",
			Position = UDim2.new(0, 28, 0, 12),
			Size = UDim2.new(1, -44, 0, 24),
			Font = UI.Fonts.Display,
			TextSize = 19,
			TextColor3 = R(role),
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrapped = false,
			Text = title,
		}),
		UI.Label({
			Name = "Body",
			Position = UDim2.new(0, 28, 0, 38),
			Size = UDim2.new(1, -44, 0, 22),
			TextSize = 14,
			TextColor3 = R("SubText"),
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrapped = false,
			Text = body,
		}),
	})
	local inTween = TweenService:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = BANNER_SHOWN,
	})
	inTween:Play()
	inTween.Completed:Wait()
	task.wait(4.5)
	local outTween = TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = BANNER_HIDDEN,
	})
	outTween:Play()
	outTween.Completed:Wait()
	card:Destroy()
end

-- ব্যানার একটার পর একটা দেখায়, একসাথে দুটো না। role = থিমের রং ("Accent", "Info" ...)।
function HUD.Banner(title: string, body: string, role: string?)
	table.insert(bannerQueue, { title = title, body = body, role = role or "Accent" })
	if bannerRunning then
		return
	end
	bannerRunning = true
	task.spawn(function()
		while #bannerQueue > 0 do
			local item = table.remove(bannerQueue, 1)
			if item then
				showBanner(item.title, item.body, item.role)
			end
		end
		bannerRunning = false
	end)
end

----------------------------------------------------------------------
-- ছোট মেসেজ আর ফলাফল কার্ড
----------------------------------------------------------------------
local toast: Frame
local toastDot: Frame
local toastLabel: TextLabel
local toastToken = 0

function HUD.Toast(text: string, role: string?)
	toastToken += 1
	local token = toastToken
	toastLabel.Text = text
	UI.Apply(toastDot, { BackgroundColor3 = R(role or "Accent") })
	toast.Visible = true
	task.delay(2.5, function()
		if toastToken == token then
			toast.Visible = false
		end
	end)
end

local resultCard: Frame
local resultCaption: TextLabel
local resultTitle: TextLabel
local resultBody: TextLabel
local resultBar: Frame
local resultScale: UIScale
local resultToken = 0

function HUD.ShowResult(caption: string, title: string, body: string, role: string)
	resultToken += 1
	local token = resultToken
	resultCaption.Text = caption
	resultTitle.Text = title
	resultBody.Text = body
	UI.Apply(resultTitle, { TextColor3 = R(role) })
	UI.Apply(resultBar, { BackgroundColor3 = R(role) })
	resultCard.Visible = true
	resultScale.Scale = 0.85
	TweenService:Create(resultScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	task.delay(4, function()
		if resultToken == token then
			resultCard.Visible = false
		end
	end)
end

local function buildCards()
	toast = UI.Card({
		Name = "Toast",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.2),
		Size = UDim2.fromOffset(0, 38),
		AutomaticSize = Enum.AutomaticSize.X,
		Visible = false,
		Parent = gui,
	}, {
		UI.New("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 16) }),
		UI.List(Enum.FillDirection.Horizontal, 10),
	})
	UI.Round(toast)
	toastDot = UI.New("Frame", {
		LayoutOrder = 1,
		Size = UDim2.fromOffset(8, 8),
		BorderSizePixel = 0,
		Parent = toast,
	}, { UI.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	toastLabel = UI.Label({
		LayoutOrder = 2,
		Size = UDim2.fromOffset(0, 38),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = UI.Fonts.Bold,
		TextSize = 15,
		TextWrapped = false,
		Parent = toast,
	})

	resultCard = UI.Card({
		Name = "Result",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.38),
		Size = UDim2.new(0.86, 0, 0, 118),
		Visible = false,
		Parent = gui,
	}, {
		UI.New("UISizeConstraint", { MaxSize = Vector2.new(380, 118) }),
	})
	resultScale = UI.New("UIScale", { Parent = resultCard })
	resultBar = UI.New("Frame", {
		Name = "TopBar",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Size = UDim2.new(0.4, 0, 0, 3),
		BorderSizePixel = 0,
		Parent = resultCard,
	}, { UI.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	resultCaption = UI.Caption({
		Position = UDim2.new(0, 0, 0, 16),
		Size = UDim2.new(1, 0, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = resultCard,
	})
	resultTitle = UI.Label({
		Position = UDim2.new(0, 16, 0, 36),
		Size = UDim2.new(1, -32, 0, 38),
		Font = UI.Fonts.Display,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = resultCard,
	})
	UI.New("UITextSizeConstraint", { MaxTextSize = 32, Parent = resultTitle })
	resultBody = UI.Label({
		Position = UDim2.new(0, 16, 0, 80),
		Size = UDim2.new(1, -32, 0, 22),
		TextSize = 14,
		TextColor3 = R("SubText"),
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = resultCard,
	})
end

----------------------------------------------------------------------
-- সার্ভারের মেসেজ
----------------------------------------------------------------------
local function systemChat(text: string)
	pcall(function()
		local channels = TextChatService:FindFirstChild("TextChannels")
		local general = channels and channels:FindFirstChild("RBXGeneral")
		if general and general:IsA("TextChannel") then
			general:DisplaySystemMessage(text)
		end
	end)
end

local END_REASONS = {
	time = "সময় শেষ",
	all = "সব বক্স খোলা হয়েছে",
	admin = "অ্যাডমিন বন্ধ করেছেন",
}

local function onAnnounce(kind: string, data: any)
	if type(data) ~= "table" then
		return
	end
	if kind == "Start" then
		Sounds.Play("EventStart")
		HUD.Banner("🎁 Treasure Hunt শুরু", `ম্যাপে {data.total} টা উপহার বক্স লুকানো আছে, খুঁজে বের করুন!`, "Accent")
	elseif kind == "Winner" then
		HUD.Banner(`🏆 {data.name} জিতেছেন`, `পার্মানেন্ট {data.tool} এখন তার!`, "Accent")
		systemChat(`🏆 {data.name} উপহার বক্স খুলে পার্মানেন্ট {data.tool} জিতে নিয়েছেন!`)
	elseif kind == "End" then
		Sounds.Play("EventEnd")
		local names = {}
		for _, winner in data.winners or {} do
			table.insert(names, `{winner.name} ({winner.tool})`)
		end
		local body = if #names > 0 then "বিজয়ী: " .. table.concat(names, ", ") else "এবার কেউ টুল পায়নি।"
		HUD.Banner("ইভেন্ট শেষ · " .. (END_REASONS[data.reason] or ""), body, "Info")
	end
end

local function onNotify(kind: string, data: any)
	if type(data) ~= "table" then
		return
	end
	if kind == "Warn" then
		HUD.Toast(data.text or "", "Accent")
	elseif kind == "Pickup" then
		Sounds.Play("Pickup")
	elseif kind == "OpenFailed" then
		HUD.Toast(data.text or "", "Danger")
	elseif kind == "Result" then
		Sounds.Play("Unbox")
		task.delay(0.3, function()
			if data.reward == "Tool" then
				Sounds.Play("ToolWin")
				HUD.ShowResult("অভিনন্দন · নতুন পার্মানেন্ট টুল", data.tool, "এখন থেকে প্রতিবার গেমে ঢুকলেই পাবেন", "Accent")
			else
				Sounds.Play("Coin")
				HUD.ShowResult("পুরস্কার", `+{data.amount} {data.currency}`, "এই বক্সে টুল ছিল না, পরেরটায় চেষ্টা করুন", "Success")
			end
		end)
	end
end

function HUD.Init()
	gui = UI.ScreenGui("BTToolsEventsHUD", 5)
	buildCounter()
	buildCards()
	local announceRemote = Remotes:WaitForChild("Announce") :: RemoteEvent
	local notifyRemote = Remotes:WaitForChild("Notify") :: RemoteEvent
	announceRemote.OnClientEvent:Connect(onAnnounce)
	notifyRemote.OnClientEvent:Connect(onNotify)
end

return HUD
