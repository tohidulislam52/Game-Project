--[[
	BT Tools Event: HUD (ModuleScript, ক্লায়েন্ট)

	- ওপরে ছোট কাউন্টার: "📦 17/20  ⏱ 4:32" (R12)। ইভেন্ট না চললে লুকানো।
	- ব্যানার: ইভেন্ট শুরু, কেউ জিতলে, ইভেন্ট শেষ।
	- ফলাফল কার্ড: বক্স খোলার পরে কী পেলেন।
	- ছোট মেসেজ (toast): সতর্কবার্তা ইত্যাদি।
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

local C = UI.Colors

local HUD = {}

local gui: ScreenGui
local pill: Frame
local countLabel: TextLabel
local timeLabel: TextLabel
local pillScale: UIScale

local bannerQueue: { { title: string, body: string, color: Color3 } } = {}
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
	countLabel.Text = `📦 {opened}/{total}`
end

local function refreshTimer()
	local endsAt = Shared:GetAttribute("EndsAt")
	if type(endsAt) == "number" and pill.Visible then
		local left = endsAt - Workspace:GetServerTimeNow()
		timeLabel.Text = "⏱ " .. formatTime(left)
		timeLabel.TextColor3 = if left <= 30 then C.Red else C.Text
	end
end

local function pulse()
	pillScale.Scale = 1.15
	TweenService:Create(pillScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

local function buildCounter()
	pill = UI.New("Frame", {
		Name = "Counter",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 6),
		Size = UDim2.fromOffset(0, 34),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = C.Panel,
		BackgroundTransparency = 0.15,
		Visible = false,
		Parent = gui,
	}, {
		UI.Corner(17),
		UI.Stroke(C.Gold, 1.5),
		UI.New("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }),
		UI.New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 14),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	pillScale = UI.New("UIScale", { Parent = pill })
	countLabel = UI.Label({
		Name = "Count",
		LayoutOrder = 1,
		Size = UDim2.fromOffset(0, 34),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = UI.Fonts.Bold,
		TextSize = 17,
		TextWrapped = false,
		Parent = pill,
	})
	timeLabel = UI.Label({
		Name = "Time",
		LayoutOrder = 2,
		Size = UDim2.fromOffset(0, 34),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = UI.Fonts.Bold,
		TextSize = 17,
		TextWrapped = false,
		Parent = pill,
	})

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
local function showBanner(title: string, body: string, color: Color3)
	local card = UI.New("Frame", {
		Name = "Banner",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, -120),
		Size = UDim2.new(0.92, 0, 0, 78),
		BackgroundColor3 = C.Panel,
		BackgroundTransparency = 0.05,
		Parent = gui,
	}, {
		UI.Corner(16),
		UI.Stroke(color, 2),
		UI.New("UISizeConstraint", { MaxSize = Vector2.new(540, 78) }),
		UI.Label({
			Name = "Title",
			Position = UDim2.new(0, 14, 0, 8),
			Size = UDim2.new(1, -28, 0, 28),
			Font = UI.Fonts.Title,
			TextScaled = true,
			Text = title,
			TextColor3 = color,
		}),
		UI.Label({
			Name = "Body",
			Position = UDim2.new(0, 14, 0, 38),
			Size = UDim2.new(1, -28, 0, 32),
			TextScaled = true,
			Text = body,
			TextColor3 = C.Text,
		}),
	})
	local inTween = TweenService:Create(
		card,
		TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, 0, 0, 48) }
	)
	inTween:Play()
	inTween.Completed:Wait()
	task.wait(4.5)
	local outTween = TweenService:Create(
		card,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Position = UDim2.new(0.5, 0, 0, -120) }
	)
	outTween:Play()
	outTween.Completed:Wait()
	card:Destroy()
end

-- ব্যানার একটার পর একটা দেখায়, একসাথে দুটো না।
function HUD.Banner(title: string, body: string, color: Color3?)
	table.insert(bannerQueue, { title = title, body = body, color = color or C.Gold })
	if bannerRunning then
		return
	end
	bannerRunning = true
	task.spawn(function()
		while #bannerQueue > 0 do
			local item = table.remove(bannerQueue, 1)
			if item then
				showBanner(item.title, item.body, item.color)
			end
		end
		bannerRunning = false
	end)
end

----------------------------------------------------------------------
-- ছোট মেসেজ আর ফলাফল কার্ড
----------------------------------------------------------------------
local toastLabel: TextLabel
local toastToken = 0

function HUD.Toast(text: string, color: Color3?)
	toastToken += 1
	local token = toastToken
	toastLabel.Text = text
	toastLabel.TextColor3 = color or C.Text
	toastLabel.Visible = true
	task.delay(2.5, function()
		if toastToken == token then
			toastLabel.Visible = false
		end
	end)
end

local resultCard: Frame
local resultTitle: TextLabel
local resultBody: TextLabel
local resultStroke: UIStroke
local resultScale: UIScale
local resultToken = 0

function HUD.ShowResult(title: string, body: string, color: Color3)
	resultToken += 1
	local token = resultToken
	resultTitle.Text = title
	resultTitle.TextColor3 = color
	resultBody.Text = body
	resultStroke.Color = color
	resultCard.Visible = true
	resultScale.Scale = 0.4
	TweenService:Create(resultScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	task.delay(4, function()
		if resultToken == token then
			resultCard.Visible = false
		end
	end)
end

local function buildCards()
	toastLabel = UI.Label({
		Name = "Toast",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.22),
		Size = UDim2.new(0.9, 0, 0, 40),
		BackgroundColor3 = C.Panel,
		BackgroundTransparency = 0.15,
		Font = UI.Fonts.Bold,
		TextSize = 17,
		Visible = false,
		Parent = gui,
	})
	UI.Corner(12).Parent = toastLabel
	UI.New("UISizeConstraint", { MaxSize = Vector2.new(420, 40), Parent = toastLabel })

	resultCard = UI.New("Frame", {
		Name = "Result",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.4),
		Size = UDim2.new(0.86, 0, 0, 110),
		BackgroundColor3 = C.Panel,
		BackgroundTransparency = 0.05,
		Visible = false,
		Parent = gui,
	}, {
		UI.Corner(18),
		UI.New("UISizeConstraint", { MaxSize = Vector2.new(440, 110) }),
	})
	resultStroke = UI.Stroke(C.Gold, 3)
	resultStroke.Parent = resultCard
	resultScale = UI.New("UIScale", { Parent = resultCard })
	resultTitle = UI.Label({
		Name = "Title",
		Position = UDim2.new(0, 16, 0, 12),
		Size = UDim2.new(1, -32, 0, 44),
		Font = UI.Fonts.Title,
		TextScaled = true,
		Parent = resultCard,
	})
	resultBody = UI.Label({
		Name = "Body",
		Position = UDim2.new(0, 16, 0, 60),
		Size = UDim2.new(1, -32, 0, 36),
		TextScaled = true,
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
	time = "সময় শেষ!",
	all = "সব বক্স খোলা হয়েছে!",
	admin = "অ্যাডমিন ইভেন্ট বন্ধ করেছেন।",
}

local function onAnnounce(kind: string, data: any)
	if type(data) ~= "table" then
		return
	end
	if kind == "Start" then
		Sounds.Play("EventStart")
		HUD.Banner("🎁 TREASURE HUNT শুরু! 🎁", `ম্যাপে {data.total} টা উপহার বক্স লুকানো আছে, দ্রুত খুঁজে বের করুন!`, C.Gold)
	elseif kind == "Winner" then
		HUD.Banner("🏆 আমাদের বিজয়ী!", `{data.name} জিতে নিয়েছেন {data.tool}!`, C.Gold)
		systemChat(`🏆 {data.name} উপহার বক্স খুলে পার্মানেন্ট {data.tool} জিতে নিয়েছেন!`)
	elseif kind == "End" then
		Sounds.Play("EventEnd")
		local names = {}
		for _, winner in data.winners or {} do
			table.insert(names, `{winner.name} ({winner.tool})`)
		end
		local body = if #names > 0 then "বিজয়ী: " .. table.concat(names, ", ") else "এবার কেউ টুল পায়নি।"
		HUD.Banner("⏹ ইভেন্ট শেষ! " .. (END_REASONS[data.reason] or ""), body, C.Blue)
	end
end

local function onNotify(kind: string, data: any)
	if type(data) ~= "table" then
		return
	end
	if kind == "Warn" then
		HUD.Toast(data.text or "", C.Gold)
	elseif kind == "Pickup" then
		Sounds.Play("Pickup")
	elseif kind == "OpenFailed" then
		HUD.Toast(data.text or "", C.Red)
	elseif kind == "Result" then
		Sounds.Play("Unbox")
		task.delay(0.3, function()
			if data.reward == "Tool" then
				Sounds.Play("ToolWin")
				HUD.ShowResult("🎉 অভিনন্দন! 🎉", `আপনি পার্মানেন্ট {data.tool} জিতেছেন!`, C.Gold)
			else
				Sounds.Play("Coin")
				HUD.ShowResult(`🪙 +{data.amount} {data.currency}`, "এই বক্সে টুল ছিল না, পরেরটায় চেষ্টা করুন!", C.Green)
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
