--[[
	BT Tools Event: Showcase (ModuleScript, সার্ভার)

	বিজয়ীর বড় অবতার যেটা নাচে আর হাতে জেতা টুল ধরে থাকে (R13)।
	- জায়গা: Workspace > WinnerShowcase পার্ট। পার্টের সামনের দিকে মুখ করে দাঁড়ায়।
	- পাশাপাশি সর্বোচ্চ ৩টা জায়গা: মাঝে, ডানে, বামে।
	- SHOWCASE_DURATION সেকেন্ড পরে ছোট হয়ে মিলিয়ে যায়।
	- মাথার ওপরে "👑 WINNER" ট্যাগ থাকে, countdown বারসহ। রং Config.THEME অনুযায়ী।
	  বারটা ক্লায়েন্টে চলে (WinnerTags মডিউল), তাই সার্ভারের ওপর কোনো চাপ নেই।
	আসল বিজয়ীর মাথার ওপরের ছোট ট্যাগও এখানে তৈরি হয়।
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("BTToolsEvents")
local Config = require(Shared:WaitForChild("Config"))
local ToolData = require(script.Parent:WaitForChild("ToolData"))

local TAG_NAME = "BTWinnerTag"
local SLOT_ORDER = { 0, 1, -1, 2, -2, 3, -3 }


type Slot = {
	userId: number,
	index: number,
	model: Model?,
	tag: BillboardGui?,
	tools: { string },
	displayName: string,
	token: number,
	removed: boolean,
	createdAt: number,
}

local Showcase = {}

local folder: Folder
local slots: { [number]: Slot } = {}
local byUser: { [number]: Slot } = {}
local playerTags: { [Player]: { conn: RBXScriptConnection, tools: { string } } } = {}
local nextToken = 0

----------------------------------------------------------------------
-- ট্যাগের ডিজাইন
----------------------------------------------------------------------
local function new(className: string, props: { [string]: any }, children: { Instance }?): any
	local inst = Instance.new(className)
	for key, value in props do
		(inst :: any)[key] = value
	end
	if children then
		for _, child in children do
			child.Parent = inst
		end
	end
	return inst
end

-- থিমের accent দিয়ে gradient (Config.THEME অনুযায়ী)।
local function accentGradient(rotation: number): UIGradient
	local theme = Config.GetTheme()
	return new("UIGradient", {
		Rotation = rotation,
		Color = ColorSequence.new(theme.Accent, theme.AccentDeep),
	})
end

local function textLabel(name: string, text: string, posY: number, height: number, color: Color3, font: Enum.Font): TextLabel
	return new("TextLabel", {
		Name = name,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, posY),
		Size = UDim2.fromScale(0.86, height),
		Font = font,
		Text = text,
		TextColor3 = color,
		TextScaled = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
end

local function toolsText(tools: { string }): string
	return "জিতেছে · " .. table.concat(tools, ", ")
end

-- big = শোকেসের ডামি (countdown সহ), না হলে প্লেয়ারের মাথার ছোট ট্যাগ।
-- রং আসে Config.THEME থেকে, তাই UI এর সাথে মিলে যায়।
local function buildTag(displayName: string, tools: { string }, big: boolean): BillboardGui
	local theme = Config.GetTheme()
	local width, height = if big then 13 else 6, if big then 5.6 else 2.4

	local title = textLabel("Title", "👑  WINNER", 0.1, if big then 0.17 else 0.26, Color3.new(1, 1, 1), Enum.Font.BuilderSansExtraBold)
	accentGradient(0).Parent = title

	local card = new("Frame", {
		Name = "Card",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.Background,
		BackgroundTransparency = math.min(0.4, theme.Glass + 0.06),
		BorderSizePixel = 0,
	}, {
		new("UICorner", { CornerRadius = UDim.new(0.16, 0) }),
		new("UIStroke", { Color = theme.Accent, Thickness = 2, Transparency = 0.25 }),
		title,
		textLabel(
			"PlayerName",
			displayName,
			if big then 0.3 else 0.4,
			if big then 0.24 else 0.32,
			theme.Text,
			Enum.Font.BuilderSansBold
		),
		textLabel(
			"ToolText",
			toolsText(tools),
			if big then 0.56 else 0.74,
			if big then 0.13 else 0.18,
			theme.SubText,
			Enum.Font.BuilderSansMedium
		),
	})

	if big then
		local barBack = new("Frame", {
			Name = "BarBack",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.07, 0.83),
			Size = UDim2.fromScale(0.7, 0.06),
			BackgroundColor3 = theme.Surface,
			BorderSizePixel = 0,
		}, { new("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		local fill = new("Frame", {
			Name = "BarFill",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
		}, { new("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		accentGradient(0).Parent = fill
		fill.Parent = barBack
		barBack.Parent = card
		local timeText = textLabel("TimeText", `{Config.SHOWCASE_DURATION}s`, 0, 0.14, theme.SubText, Enum.Font.BuilderSansBold)
		timeText.AnchorPoint = Vector2.new(0, 0.5)
		timeText.Position = UDim2.fromScale(0.8, 0.83)
		timeText.Size = UDim2.fromScale(0.13, 0.14)
		timeText.TextXAlignment = Enum.TextXAlignment.Right
		timeText.Parent = card
	end

	local billboard = new("BillboardGui", {
		Name = "BTWinnerTag",
		Size = UDim2.fromScale(width, height),
		-- ট্যাগের নিচের কিনারা মাথার একটু ওপরে থাকবে।
		StudsOffset = Vector3.new(0, height / 2 + (if big then 2 else 1), 0),
		AlwaysOnTop = true,
		LightInfluence = 0,
		MaxDistance = if big then 400 else 150,
		ResetOnSpawn = false,
	}, { card })
	CollectionService:AddTag(billboard, TAG_NAME)
	return billboard
end

local function updateTagText(tag: BillboardGui?, tools: { string })
	local card = tag and tag:FindFirstChild("Card")
	local label = card and card:FindFirstChild("ToolText")
	if label and label:IsA("TextLabel") then
		label.Text = toolsText(tools)
	end
end

----------------------------------------------------------------------
-- আসল প্লেয়ারের মাথার ট্যাগ (S6)
----------------------------------------------------------------------
local function attachPlayerTag(player: Player, tools: { string })
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	if not head then
		return
	end
	local old = head:FindFirstChild("BTWinnerTag")
	if old then
		old:Destroy()
	end
	local tag = buildTag(player.DisplayName, tools, false)
	tag.Adornee = head
	tag.Parent = head
end

function Showcase.TagPlayer(player: Player, toolName: string)
	if not Config.WINNER_TAG_ON_PLAYER then
		return
	end
	local info = playerTags[player]
	if info then
		table.insert(info.tools, toolName)
	else
		local tools = { toolName }
		local conn = player.CharacterAdded:Connect(function(character)
			character:WaitForChild("Head", 10)
			attachPlayerTag(player, tools)
		end)
		info = { conn = conn, tools = tools }
		playerTags[player] = info
	end
	attachPlayerTag(player, info.tools)
end

function Showcase.ClearPlayerTags()
	for player, info in playerTags do
		info.conn:Disconnect()
		local head = player.Character and player.Character:FindFirstChild("Head")
		local tag = head and head:FindFirstChild("BTWinnerTag")
		if tag then
			tag:Destroy()
		end
	end
	table.clear(playerTags)
end

----------------------------------------------------------------------
-- শোকেসের ডামি
----------------------------------------------------------------------
local function getShowcasePart(): BasePart?
	local part = Workspace:FindFirstChild(Config.SHOWCASE_PART_NAME, true)
	if part and part:IsA("BasePart") then
		return part
	end
	return nil
end

local function slotCFrame(part: BasePart, index: number): CFrame
	local offset = SLOT_ORDER[index] * Config.SLOT_SPACING
	local top = part.CFrame * CFrame.new(offset, part.Size.Y / 2, 0)
	local look = part.CFrame.LookVector
	local flatLook = Vector3.new(look.X, 0, look.Z)
	if flatLook.Magnitude < 0.01 then
		flatLook = Vector3.new(0, 0, -1)
	end
	return CFrame.lookAt(top.Position, top.Position + flatLook.Unit)
end

local function getDescription(player: Player?, userId: number): HumanoidDescription
	local ok, description = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(userId)
	end)
	if ok and description then
		return description
	end
	local humanoid = player and player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local ok2, applied = pcall(function()
			return humanoid:GetAppliedDescription()
		end)
		if ok2 and applied then
			return applied
		end
	end
	return Instance.new("HumanoidDescription")
end

-- টুলের একটা শুধু-দেখার কপি ডামির ডান হাতে লাগায় (S1)। স্ক্রিপ্ট আর রিমোট মুছে ফেলা হয়।
local function attachDisplayTool(dummy: Model, toolName: string, scale: number)
	local source = ToolData.FindTool(toolName)
	local hand = dummy:FindFirstChild("RightHand")
	if not source or not hand or not hand:IsA("BasePart") then
		return
	end
	local clone = source:Clone()
	local handle = clone:FindFirstChild("Handle")
	if not handle or not handle:IsA("BasePart") then
		clone:Destroy()
		return
	end
	local grip = clone.Grip

	local holder = Instance.new("Model")
	holder.Name = "HeldTool"
	for _, child in clone:GetChildren() do
		child.Parent = holder
	end
	clone:Destroy()

	for _, d in holder:GetDescendants() do
		if
			d:IsA("LuaSourceContainer")
			or d:IsA("RemoteEvent")
			or d:IsA("RemoteFunction")
			or d:IsA("BindableEvent")
			or d:IsA("BindableFunction")
			or d:IsA("ProximityPrompt")
			or d:IsA("ClickDetector")
			or d:IsA("JointInstance")
			or d:IsA("WeldConstraint")
		then
			d:Destroy()
		end
	end
	for _, d in holder:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = false
			d.CanCollide = false
			d.CanTouch = false
			d.CanQuery = false
			d.Massless = true
			if d:IsA("Seat") then
				d.Disabled = true
			end
		end
	end

	holder.PrimaryPart = handle
	holder:ScaleTo(scale)
	local gripAttachment = hand:FindFirstChild("RightGripAttachment")
	local gripOffset = if gripAttachment and gripAttachment:IsA("Attachment")
		then gripAttachment.CFrame
		else CFrame.new(0, -hand.Size.Y / 2, 0)
	local scaledGrip = CFrame.new(grip.Position * scale) * grip.Rotation
	holder:PivotTo(hand.CFrame * gripOffset * scaledGrip:Inverse())

	for _, d in holder:GetDescendants() do
		if d:IsA("BasePart") and d ~= handle then
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = handle
			weld.Part1 = d
			weld.Parent = d
		end
	end
	local handWeld = Instance.new("WeldConstraint")
	handWeld.Part0 = hand
	handWeld.Part1 = handle
	handWeld.Parent = handle
	holder.Parent = dummy
end

local function poof(position: Vector3)
	local part = Instance.new("Part")
	part.Name = "BTPoof"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = Vector3.one
	part.CFrame = CFrame.new(position)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	local theme = Config.GetTheme()
	emitter.Color = ColorSequence.new(theme.Accent, theme.AccentDeep)
	emitter.Size = NumberSequence.new(3, 6)
	emitter.Transparency = NumberSequence.new(0.2, 1)
	emitter.Lifetime = NumberRange.new(0.6, 1)
	emitter.Speed = NumberRange.new(6, 12)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Rate = 0
	emitter.Parent = part
	part.Parent = folder
	emitter:Emit(40)
	task.delay(1.5, function()
		part:Destroy()
	end)
end

-- t সেকেন্ড ধরে প্রতি ফ্রেমে f(alpha) চালায়।
local function animate(duration: number, style: Enum.EasingStyle, direction: Enum.EasingDirection, f: (number) -> ())
	local start = os.clock()
	while true do
		local alpha = math.clamp((os.clock() - start) / duration, 0, 1)
		f(TweenService:GetValue(alpha, style, direction))
		if alpha >= 1 then
			break
		end
		RunService.Heartbeat:Wait()
	end
end

local function removeSlot(slot: Slot, quick: boolean)
	if slot.removed then
		return
	end
	slot.removed = true
	if slots[slot.index] == slot then
		slots[slot.index] = nil
	end
	if byUser[slot.userId] == slot then
		byUser[slot.userId] = nil
	end
	local model = slot.model
	if not model or not model.Parent then
		return
	end
	poof(model:GetPivot().Position)
	if quick then
		model:Destroy()
		return
	end
	task.spawn(function()
		local scale = model:GetScale()
		animate(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In, function(a)
			if model.Parent then
				model:ScaleTo(math.max(scale * (1 - a), 0.05))
			end
		end)
		model:Destroy()
	end)
end

local function scheduleExpiry(slot: Slot)
	nextToken += 1
	local token = nextToken
	slot.token = token
	local expiresAt = Workspace:GetServerTimeNow() + Config.SHOWCASE_DURATION
	if slot.tag then
		slot.tag:SetAttribute("ExpiresAt", expiresAt)
		slot.tag:SetAttribute("Duration", Config.SHOWCASE_DURATION)
	end
	task.delay(Config.SHOWCASE_DURATION, function()
		if slot.token == token then
			removeSlot(slot, false)
		end
	end)
end

local function buildDummy(slot: Slot, player: Player?, part: BasePart)
	local description = getDescription(player, slot.userId)
	local ok, dummy = pcall(function()
		return Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
	end)
	if not ok or not dummy then
		warn(`[BTToolsEvents] শোকেসের অবতার বানানো যায়নি: {dummy}`)
		removeSlot(slot, true)
		return
	end
	if slot.removed then
		dummy:Destroy()
		return
	end

	dummy.Name = "Winner_" .. slot.displayName
	dummy.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	local humanoid = dummy:FindFirstChildOfClass("Humanoid")
	local root = dummy:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root or not root:IsA("BasePart") then
		dummy:Destroy()
		removeSlot(slot, true)
		return
	end
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false
	for _, d in dummy:GetDescendants() do
		if d:IsA("BasePart") then
			d.CanCollide = false
			d.CanTouch = false
			d.CanQuery = false
			d.Anchored = d == root
		end
	end

	local scale = Config.SHOWCASE_SCALE
	dummy:ScaleTo(scale)

	-- পা যেন ঠিক পার্টের ওপরে থাকে।
	local target = slotCFrame(part, slot.index)
	dummy:PivotTo(target)
	local boxCFrame, boxSize = dummy:GetBoundingBox()
	local lift = target.Position.Y - (boxCFrame.Position.Y - boxSize.Y / 2)
	local finalCFrame = target + Vector3.new(0, lift, 0)
	local startCFrame = finalCFrame - Vector3.new(0, boxSize.Y, 0)
	dummy:PivotTo(startCFrame)

	attachDisplayTool(dummy, slot.tools[1], scale)

	local head = dummy:FindFirstChild("Head")
	local tag = buildTag(slot.displayName, slot.tools, true)
	tag.Adornee = if head and head:IsA("BasePart") then head else root
	tag.Parent = dummy
	slot.tag = tag
	slot.model = dummy
	dummy.Parent = folder
	scheduleExpiry(slot)

	-- মাটির নিচ থেকে উঠে আসা।
	animate(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out, function(a)
		if dummy.Parent then
			dummy:PivotTo(startCFrame:Lerp(finalCFrame, a))
		end
	end)

	if not dummy.Parent then
		return
	end
	if Config.IsSoundSet(Config.DANCE_ANIMATION_ID) then
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if not animator then
			animator = Instance.new("Animator")
			animator.Parent = humanoid
		end
		local animation = Instance.new("Animation")
		animation.AnimationId = Config.DANCE_ANIMATION_ID
		local okTrack, track = pcall(function()
			return (animator :: Animator):LoadAnimation(animation)
		end)
		if okTrack and track then
			track.Priority = Enum.AnimationPriority.Action
			track.Looped = true
			track:Play()
		else
			warn(`[BTToolsEvents] নাচের অ্যানিমেশন লোড হয়নি: {track}`)
		end
	else
		warn("[BTToolsEvents] Config.DANCE_ANIMATION_ID দেওয়া হয়নি, অবতার নাচবে না।")
	end
end

function Showcase.Show(player: Player, toolName: string)
	local part = getShowcasePart()
	if not part then
		warn(`[BTToolsEvents] Workspace এ '{Config.SHOWCASE_PART_NAME}' পার্ট নেই, শোকেস দেখানো হবে না।`)
		return
	end

	-- একই প্লেয়ার আবার জিতলে নতুন অবতার না, আগেরটাই রিফ্রেশ।
	local existing = byUser[player.UserId]
	if existing and not existing.removed then
		table.insert(existing.tools, toolName)
		updateTagText(existing.tag, existing.tools)
		if existing.model then
			scheduleExpiry(existing)
		end
		return
	end

	local maxSlots = math.clamp(Config.MAX_SHOWCASE_SLOTS, 1, #SLOT_ORDER)
	local index: number? = nil
	for i = 1, maxSlots do
		if not slots[i] then
			index = i
			break
		end
	end
	if not index then
		-- সব জায়গা ভরা: সবচেয়ে পুরনোটা আগেই বিদায় নেবে।
		local oldest: Slot? = nil
		for _, slot in slots do
			if not oldest or slot.createdAt < oldest.createdAt then
				oldest = slot
			end
		end
		if oldest then
			index = oldest.index
			removeSlot(oldest, true)
		end
	end
	if not index then
		return
	end

	local slot: Slot = {
		userId = player.UserId,
		index = index,
		model = nil,
		tag = nil,
		tools = { toolName },
		displayName = player.DisplayName,
		token = 0,
		removed = false,
		createdAt = os.clock(),
	}
	slots[index] = slot
	byUser[player.UserId] = slot
	task.spawn(buildDummy, slot, player, part)
end

function Showcase.GetFolder(): Folder
	return folder
end

function Showcase.HasShowcasePart(): boolean
	return getShowcasePart() ~= nil
end

function Showcase.Init()
	local existing = Workspace:FindFirstChild("BTToolsEvents_Showcase")
	if existing then
		existing:Destroy()
	end
	folder = Instance.new("Folder")
	folder.Name = "BTToolsEvents_Showcase"
	folder.Parent = Workspace

	local part = getShowcasePart()
	if part then
		part.Anchored = true
		part.Transparency = 1
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
	end

	Players.PlayerRemoving:Connect(function(player)
		local info = playerTags[player]
		if info then
			info.conn:Disconnect()
			playerTags[player] = nil
		end
	end)
end

return Showcase
