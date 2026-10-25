--[[
	BT Tools Event: Minigame (ModuleScript, ক্লায়েন্ট)

	বক্স খোলার টাইমিং বার (R10, Option A):
	  🔒 🔒 🔒
	  [░░░░░▓▓▓░░░░░░]   ← কাঁটা এদিক-ওদিক চলে, সোনালি জোনে থাকলে ক্লিক বা TAP।
	- সঠিক ক্লিক (HIT): একটা তালা খোলে, Hit সাউন্ড (প্রতিবার সুর একটু উঁচু),
	  পরের রাউন্ডে জোন ছোট হয় আর কাঁটা দ্রুত চলে।
	- ভুল ক্লিক (MISS): বার লাল হয়ে কাঁপে, Miss সাউন্ড, MISS_STUN সেকেন্ড অপেক্ষা।
	  খোলা তালা আবার বন্ধ হয় না।
	- সব তালা খুললে সার্ভারকে বক্স খুলতে বলা হয়। কী পাবেন সেটা সার্ভার ঠিক করে।
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

local C = UI.Colors
local M = Config.Minigame
local BOX_ATTRIBUTE = "BTBoxId"
local TOLERANCE = 0.012
local CONTAINER_POSITION = UDim2.new(0.5, 0, 1, -110)

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
local title: TextLabel
local locks: { TextLabel } = {}
local bar: Frame
local barStroke: UIStroke
local zone: Frame
local needle: Frame

----------------------------------------------------------------------
-- UI
----------------------------------------------------------------------
local function buildUI()
	gui = UI.ScreenGui("BTBoxMinigame", 6)
	container = UI.New("Frame", {
		Name = "Container",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = CONTAINER_POSITION,
		Size = UDim2.new(0.92, 0, 0, 160),
		BackgroundColor3 = C.Panel,
		BackgroundTransparency = 0.08,
		Visible = false,
		Parent = gui,
	}, {
		UI.Corner(16),
		UI.Stroke(C.Gold, 2),
		UI.New("UISizeConstraint", { MaxSize = Vector2.new(460, 160) }),
	})

	title = UI.Label({
		Name = "Title",
		Position = UDim2.new(0, 12, 0, 6),
		Size = UDim2.new(1, -24, 0, 22),
		Font = UI.Fonts.Bold,
		TextScaled = true,
		Text = "🎁 কাঁটা সোনালি জায়গায় এলে ক্লিক করুন!",
		Parent = container,
	})

	local lockRow = UI.New("Frame", {
		Name = "Locks",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 30),
		Size = UDim2.new(1, 0, 0, 34),
		Parent = container,
	}, {
		UI.New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 12),
		}),
	})
	for i = 1, M.HITS_REQUIRED do
		local lock = UI.Label({
			Name = "Lock" .. i,
			LayoutOrder = i,
			Size = UDim2.fromOffset(34, 34),
			TextSize = 28,
			Text = "🔒",
			Parent = lockRow,
		})
		UI.New("UIScale", { Parent = lock })
		table.insert(locks, lock)
	end

	bar = UI.New("Frame", {
		Name = "Bar",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 72),
		Size = UDim2.new(1, -32, 0, 26),
		BackgroundColor3 = Color3.fromRGB(40, 44, 62),
		ClipsDescendants = false,
		Parent = container,
	}, { UI.Corner(8) })
	barStroke = UI.Stroke(C.Stroke, 2)
	barStroke.Parent = bar

	zone = UI.New("Frame", {
		Name = "Zone",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.2, 1),
		Parent = bar,
	}, { UI.Corner(6), UI.GoldGradient(0) })

	needle = UI.New("Frame", {
		Name = "Needle",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(0, 5, 1, 14),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = bar,
	}, { UI.Corner(3), UI.Stroke(Color3.new(0, 0, 0), 1) })

	local tap = UI.Button({
		Name = "Tap",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 110),
		Size = UDim2.fromOffset(170, 40),
		BackgroundColor3 = C.Gold,
		TextColor3 = Color3.fromRGB(30, 22, 5),
		Font = UI.Fonts.Title,
		TextSize = 22,
		Text = "👆 TAP!",
		Parent = container,
	})
	tap.Activated:Connect(function()
		Minigame._Attempt()
	end)
end

local function setLocks(hits: number)
	for i, lock in locks do
		lock.Text = if i <= hits then "🔓" else "🔒"
	end
end

local function popLock(index: number)
	local lock = locks[index]
	local scale = lock and lock:FindFirstChildOfClass("UIScale")
	if scale then
		scale.Scale = 1.6
		TweenService:Create(scale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	end
end

local function flashBar(color: Color3)
	barStroke.Color = color
	bar.BackgroundColor3 = color:Lerp(Color3.fromRGB(40, 44, 62), 0.6)
	task.delay(0.25, function()
		barStroke.Color = C.Stroke
		bar.BackgroundColor3 = Color3.fromRGB(40, 44, 62)
	end)
end

local function shake()
	task.spawn(function()
		for _, dx in { -10, 10, -7, 7, -3, 0 } do
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
	setLocks(0)
	title.Text = "🎁 কাঁটা সোনালি জায়গায় এলে ক্লিক করুন!"
	title.TextColor3 = C.Text
	placeZone(s)
end

local function sendOpen(s: Session)
	s.state = "sending"
	title.Text = "✨ বক্স খুলছে..."
	title.TextColor3 = C.Gold
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
		setLocks(s.hits)
		popLock(s.hits)
		flashBar(C.Gold)
		Sounds.Play("Hit", 1 + 0.2 * (s.hits - 1))
		if s.hits >= M.HITS_REQUIRED then
			sendOpen(s)
			return
		end
		s.zoneSize = math.max(M.ZONE_SIZE_MIN, M.ZONE_SIZE_START - M.ZONE_SHRINK * s.hits)
		s.speed = M.NEEDLE_SPEED_START + M.NEEDLE_SPEED_UP * s.hits
		placeZone(s)
	else
		-- MISS: অপেক্ষা, কিন্তু খোলা তালা বন্ধ হবে না।
		s.state = "stun"
		flashBar(C.Red)
		shake()
		Sounds.Play("Miss")
		title.Text = "❌ মিস! একটু অপেক্ষা..."
		title.TextColor3 = C.Red
		task.delay(M.MISS_STUN, function()
			if session == s and s.state == "stun" then
				s.state = "play"
				title.Text = "🎁 কাঁটা সোনালি জায়গায় এলে ক্লিক করুন!"
				title.TextColor3 = C.Text
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
