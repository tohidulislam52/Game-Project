--[[
	BT Tools Event: Minigame (ModuleScript, ক্লায়েন্ট)

	বক্স খোলার টাইমিং বার (R10, Option A):
	  বক্স খুলুন                     ● ● ○
	  [━━━━━━━▇▇▇━━━━━━━━━━]   ← কাঁটা এদিক-ওদিক চলে, হাইলাইট অংশে এলে ক্লিক বা TAP।
	- সঠিক ক্লিক (HIT): একটা বিন্দু ভরে যায়, Hit সাউন্ড (প্রতিবার সুর একটু উঁচু),
	  পরের রাউন্ডে জোন ছোট হয় আর কাঁটা দ্রুত চলে।
	- ভুল ক্লিক (MISS): বার লাল হয়ে কাঁপে, Miss সাউন্ড, MISS_STUN সেকেন্ড অপেক্ষা।
	  ভরা বিন্দু আবার খালি হয় না।
	- সব বিন্দু ভরলে সার্ভারকে বক্স খুলতে বলা হয়। কী পাবেন সেটা সার্ভার ঠিক করে।
	- বক্স হাত থেকে নামালে মিনি-গেম বন্ধ হয়ে শূন্য থেকে শুরু হয়।
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("BTToolsEvents")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = Shared:WaitForChild("Remotes")
local OpenBoxRemote = Remotes:WaitForChild("OpenBox") :: RemoteEvent
local NotifyRemote = Remotes:WaitForChild("Notify") :: RemoteEvent

local Modules = script.Parent
local UI = require(Modules:WaitForChild("UI"))
local Sounds = require(Modules:WaitForChild("Sounds"))

local R = UI.Role
local M = Config.Minigame
local BOX_ATTRIBUTE = "BTBoxId"
local TOLERANCE = 0.012
local CONTAINER_POSITION = UDim2.new(0.5, 0, 1, -104)
local HINT_TEXT = "কাঁটা হাইলাইট করা অংশে এলে ক্লিক বা TAP করুন"

type Session = {
	tool: Tool,
	boxId: number,
	hits: number,
	zoneStart: number,
	zoneSize: number,
	speed: number,
	pos: number,
	dir: number,
	state: "play" | "stun" | "sending",
	activatedConn: RBXScriptConnection,
}

local Minigame = {}

local player = Players.LocalPlayer
local session: Session? = nil
local pickupTimes: { [number]: number } = {}

local gui: ScreenGui
local container: Frame
local hint: TextLabel
local pips: { Frame } = {}
local track: Frame
local trackStroke: UIStroke
local zone: Frame
local needle: Frame

----------------------------------------------------------------------
-- UI
----------------------------------------------------------------------
local function buildUI()
	gui = UI.ScreenGui("BTBoxMinigame", 6)
	container = UI.Card({
		Name = "Container",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = CONTAINER_POSITION,
		Size = UDim2.new(0.92, 0, 0, 150),
		Visible = false,
		Parent = gui,
	}, {
		UI.New("UISizeConstraint", { MaxSize = Vector2.new(400, 150) }),
	})

	UI.Label({
		Name = "Title",
		Position = UDim2.new(0, 18, 0, 14),
		Size = UDim2.new(1, -120, 0, 22),
		Font = UI.Fonts.Display,
		TextSize = 19,
		TextWrapped = false,
		Text = "🎁 বক্স খুলুন",
		Parent = container,
	})

	local pipRow = UI.New("Frame", {
		Name = "Pips",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 18),
		Size = UDim2.fromOffset(90, 14),
		BackgroundTransparency = 1,
		Parent = container,
	}, {
		UI.New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	for i = 1, M.HITS_REQUIRED do
		local pip = UI.New("Frame", {
			Name = "Pip" .. i,
			LayoutOrder = i,
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = R("Surface"),
			BorderSizePixel = 0,
			Parent = pipRow,
		}, {
			UI.New("UICorner", { CornerRadius = UDim.new(1, 0) }),
			UI.Stroke("Accent", 0.3),
		})
		UI.New("UIScale", { Parent = pip })
		table.insert(pips, pip)
	end

	hint = UI.Label({
		Name = "Hint",
		Position = UDim2.new(0, 18, 0, 38),
		Size = UDim2.new(1, -36, 0, 18),
		TextSize = 13,
		TextColor3 = R("SubText"),
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextWrapped = false,
		Text = HINT_TEXT,
		Parent = container,
	})

	track = UI.New("Frame", {
		Name = "Track",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 68),
		Size = UDim2.new(1, -36, 0, 12),
		BackgroundColor3 = R("Surface"),
		BorderSizePixel = 0,
		Parent = container,
	}, { UI.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
	trackStroke = UI.Stroke()
	trackStroke.Parent = track

	zone = UI.New("Frame", {
		Name = "Zone",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.2, 1),
		Parent = track,
	}, { UI.New("UICorner", { CornerRadius = UDim.new(1, 0) }), UI.AccentGradient(0) })

	needle = UI.New("Frame", {
		Name = "Needle",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(0, 4, 1, 16),
		BackgroundColor3 = R("Text"),
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = track,
	}, { UI.New("UICorner", { CornerRadius = UDim.new(1, 0) }) })

	local tap = UI.Button({
		Name = "Tap",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 96),
		Size = UDim2.new(1, -36, 0, 40),
		Font = UI.Fonts.Display,
		TextSize = 18,
		Text = "TAP",
		Parent = container,
	}, "primary")
	tap.Activated:Connect(function()
		Minigame._Attempt()
	end)
end

local function setPips(hits: number)
	for i, pip in pips do
		UI.Apply(pip, { BackgroundColor3 = R(if i <= hits then "Accent" else "Surface") })
	end
end

local function popPip(index: number)
	local pip = pips[index]
	local scale = pip and pip:FindFirstChildOfClass("UIScale")
	if scale then
		scale.Scale = 1.7
		TweenService:Create(scale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	end
end

local function flashTrack(role: string)
	UI.Apply(trackStroke, { Color = R(role), Transparency = 0 })
	trackStroke.Thickness = 2
	task.delay(0.25, function()
		UI.Apply(trackStroke, {
			Color = R("Stroke"),
			Transparency = UI.Fn(function(theme)
				return theme.StrokeTransparency
			end),
		})
		trackStroke.Thickness = 1
	end)
end

local function setHint(text: string, role: string)
	hint.Text = text
	UI.Apply(hint, { TextColor3 = R(role) })
end

local function shake()
	task.spawn(function()
		for _, dx in { -9, 9, -6, 6, -3, 0 } do
			container.Position = CONTAINER_POSITION + UDim2.fromOffset(dx, 0)
			task.wait(0.03)
		end
		container.Position = CONTAINER_POSITION
	end)
end

local function placeZone(s: Session)
	local size = s.zoneSize
	-- নতুন জোন কাঁটার ঠিক নিচে যেন না পড়ে।
	for _ = 1, 10 do
		s.zoneStart = math.random() * (1 - size)
		local center = s.zoneStart + size / 2
		if math.abs(center - s.pos) > 0.25 then
			break
		end
	end
	zone.Size = UDim2.fromScale(size, 1)
	zone.Position = UDim2.fromScale(s.zoneStart, 0)
end

----------------------------------------------------------------------
-- খেলা
----------------------------------------------------------------------
local function stop()
	local s = session
	if not s then
		return
	end
	s.activatedConn:Disconnect()
	session = nil
	container.Visible = false
end

local function resetRound(s: Session)
	s.hits = 0
	s.zoneSize = M.ZONE_SIZE_START
	s.speed = M.NEEDLE_SPEED_START
	s.state = "play"
	setPips(0)
	setHint(HINT_TEXT, "SubText")
	placeZone(s)
end

local function sendOpen(s: Session)
	s.state = "sending"
	setHint("বক্স খুলছে…", "Accent")
	-- সার্ভার MIN_OPEN_TIME এর আগে বক্স খোলে না, তাই দরকার হলে একটু অপেক্ষা।
	local pickedAt = pickupTimes[s.boxId] or 0
	local waitLeft = pickedAt + Config.MIN_OPEN_TIME + 0.15 - os.clock()
	task.delay(math.max(0, waitLeft), function()
		if session ~= s then
			return
		end
		OpenBoxRemote:FireServer(s.boxId)
		-- উত্তর না এলে আবার চেষ্টা করার সুযোগ।
		task.delay(5, function()
			if session == s and s.state == "sending" then
				resetRound(s)
			end
		end)
	end)
end

function Minigame._Attempt()
	local s = session
	if not s or s.state ~= "play" then
		return
	end
	if s.pos >= s.zoneStart - TOLERANCE and s.pos <= s.zoneStart + s.zoneSize + TOLERANCE then
		s.hits += 1
		setPips(s.hits)
		popPip(s.hits)
		flashTrack("Accent")
		Sounds.Play("Hit", 1 + 0.2 * (s.hits - 1))
		if s.hits >= M.HITS_REQUIRED then
			sendOpen(s)
			return
		end
		s.zoneSize = math.max(M.ZONE_SIZE_MIN, M.ZONE_SIZE_START - M.ZONE_SHRINK * s.hits)
		s.speed = M.NEEDLE_SPEED_START + M.NEEDLE_SPEED_UP * s.hits
		placeZone(s)
	else
		-- MISS: অপেক্ষা, কিন্তু ভরা বিন্দু খালি হবে না।
		s.state = "stun"
		flashTrack("Danger")
		shake()
		Sounds.Play("Miss")
		setHint("মিস! একটু অপেক্ষা…", "Danger")
		task.delay(M.MISS_STUN, function()
			if session == s and s.state == "stun" then
				s.state = "play"
				setHint(HINT_TEXT, "SubText")
			end
		end)
	end
end

local function start(tool: Tool)
	local boxId = tool:GetAttribute(BOX_ATTRIBUTE)
	if type(boxId) ~= "number" then
		return
	end
	stop()
	if not pickupTimes[boxId] then
		pickupTimes[boxId] = os.clock()
	end
	local s: Session = {
		tool = tool,
		boxId = boxId,
		hits = 0,
		zoneStart = 0,
		zoneSize = M.ZONE_SIZE_START,
		speed = M.NEEDLE_SPEED_START,
		pos = 0,
		dir = 1,
		state = "play",
		activatedConn = tool.Activated:Connect(function()
			Minigame._Attempt()
		end),
	}
	session = s
	resetRound(s)
	container.Visible = true
end

local function watchCharacter(character: Model)
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and child:GetAttribute(BOX_ATTRIBUTE) ~= nil then
			start(child)
		end
	end)
	character.ChildRemoved:Connect(function(child)
		if session and session.tool == child then
			stop()
		end
	end)
	for _, child in character:GetChildren() do
		if child:IsA("Tool") and child:GetAttribute(BOX_ATTRIBUTE) ~= nil then
			start(child)
		end
	end
end

function Minigame.Init()
	buildUI()

	NotifyRemote.OnClientEvent:Connect(function(kind: string, data: any)
		if kind == "Pickup" and type(data) == "table" and type(data.boxId) == "number" then
			pickupTimes[data.boxId] = os.clock()
		elseif kind == "OpenFailed" then
			local s = session
			if s and s.state == "sending" then
				task.delay(0.8, function()
					if session == s then
						resetRound(s)
					end
				end)
			end
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		local s = session
		if not s or s.state ~= "play" then
			return
		end
		s.pos += s.dir * s.speed * dt
		if s.pos >= 1 then
			s.pos = 1
			s.dir = -1
		elseif s.pos <= 0 then
			s.pos = 0
			s.dir = 1
		end
		needle.Position = UDim2.fromScale(s.pos, 0.5)
	end)

	player.CharacterAdded:Connect(function(character)
		stop()
		watchCharacter(character)
	end)
	if player.Character then
		watchCharacter(player.Character)
	end
end

return Minigame
