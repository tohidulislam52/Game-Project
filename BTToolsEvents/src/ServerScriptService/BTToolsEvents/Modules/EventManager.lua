--[[
	BT Tools Event: EventManager (ModuleScript, সার্ভার)

	ইভেন্টের পুরো কাজ: বক্স স্পন, তোলা, খোলা, টাইমার আর শেষ।

	কোন বক্সে টুল আসবে (R14):
	- টুল আগে থেকে কোনো বক্সে রাখা থাকে না। বক্স খোলার মুহূর্তে সার্ভার ঠিক করে।
	- প্রথম TOOL_SAFE_PERCENT % খোলায় কখনো টুল আসে না।
	- তারপর প্রতিটা খোলায় সুযোগ = বাকি টুল ÷ বাকি বক্স।
	- একটা টুল পাওয়ার পর পরের TOOL_GAP টা খোলায় টুল আসে না।
	- বাকি বক্স = বাকি টুল হলে অবশ্যই টুল আসে (গ্যারান্টি)।
	- যে খুলছে তার কাছে টুলটা আগে থেকেই থাকলে তাকে টাকা দেওয়া হয়, টুলটা পরের বক্সের জন্য থাকে।
	  গ্যারান্টির ক্ষেত্রে (শেষ বক্স) তাকেই দেওয়া হয়, কিন্তু ডাবল কপি যায় না (R5.3)।
]]

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("BTToolsEvents")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = Shared:WaitForChild("Remotes")
local OpenBoxRemote = Remotes:WaitForChild("OpenBox") :: RemoteEvent
local NotifyRemote = Remotes:WaitForChild("Notify") :: RemoteEvent
local AnnounceRemote = Remotes:WaitForChild("Announce") :: RemoteEvent

local Modules = script.Parent
local Util = require(Modules:WaitForChild("Util"))
local ToolData = require(Modules:WaitForChild("ToolData"))
local BoxSpawner = require(Modules:WaitForChild("BoxSpawner"))
local Showcase = require(Modules:WaitForChild("Showcase"))

local BOX_ATTRIBUTE = "BTBoxId"

type BoxRecord = {
	id: number,
	state: "ground" | "held" | "opened",
	position: Vector3,
	model: Model?,
	holder: Player?,
	tool: Tool?,
	heldSince: number,
	connections: { RBXScriptConnection },
}

type EventState = {
	total: number,
	opened: number,
	safeCount: number,
	gap: number,
	gapLeft: number,
	tools: { [string]: number },
	boxes: { [number]: BoxRecord },
	endsAt: number,
	winners: { { userId: number, name: string, tool: string } },
}

export type StartParams = {
	totalBoxes: number,
	minutes: number,
	radius: number,
	safePercent: number,
	gap: number,
	tools: { [string]: number },
}

local EventManager = {}

local rng = Random.new()
local boxesFolder: Folder
local current: EventState? = nil
local nextBoxId = 0

local pickupLimiter = Util.RateLimiter(0.3)
local openLimiter = Util.RateLimiter(0.5)

----------------------------------------------------------------------
-- সবার জন্য ইভেন্টের অবস্থা (HUD এটা পড়ে)
----------------------------------------------------------------------
local function publishState()
	local ev = current
	Shared:SetAttribute("Active", ev ~= nil)
	Shared:SetAttribute("Total", if ev then ev.total else 0)
	Shared:SetAttribute("Opened", if ev then ev.opened else 0)
	Shared:SetAttribute("EndsAt", if ev then ev.endsAt else 0)
end

local function notify(player: Player, kind: string, data: { [string]: any })
	NotifyRemote:FireClient(player, kind, data)
end

----------------------------------------------------------------------
-- বক্সের মডেল
----------------------------------------------------------------------
local function getBoxTemplate(): Tool?
	local folder = ServerStorage:FindFirstChild("BTToolsEvents")
	local template = folder and folder:FindFirstChild("GiftBoxTool")
	if template and template:IsA("Tool") then
		return template
	end
	return nil
end

local function stripScripts(root: Instance)
	for _, d in root:GetDescendants() do
		if d:IsA("LuaSourceContainer") then
			d:Destroy()
		end
	end
end

-- টেমপ্লেট না থাকলে সাধারণ একটা লাল-সোনালি বক্স।
local function makeFallbackVisual(): Model
	local visual = Instance.new("Model")
	local box = Instance.new("Part")
	box.Name = "Handle"
	box.Size = Vector3.new(2.4, 2.4, 2.4)
	box.Color = Color3.fromRGB(170, 25, 35)
	box.Material = Enum.Material.SmoothPlastic
	box.Parent = visual
	for _, size in { Vector3.new(2.5, 2.5, 0.5), Vector3.new(0.5, 2.5, 2.5) } do
		local ribbon = Instance.new("Part")
		ribbon.Name = "Ribbon"
		ribbon.Size = size
		ribbon.Color = Color3.fromRGB(255, 205, 60)
		ribbon.Material = Enum.Material.SmoothPlastic
		ribbon.CFrame = box.CFrame
		ribbon.Parent = visual
	end
	visual.PrimaryPart = box
	return visual
end

local function buildGroundModel(record: BoxRecord): Model
	local model = Instance.new("Model")
	model.Name = "GiftBox_" .. record.id
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent

	-- স্থির, অদৃশ্য Root। Prompt এর Attachment এর সাথেই থাকে, তাই কখনো গায়েব হয় না (R8)।
	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = Vector3.new(3, 3, 3)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CanTouch = false
	root.CanQuery = false
	root.CFrame = CFrame.new(record.position)
	root.Parent = model
	model.PrimaryPart = root

	local attachment = Instance.new("Attachment")
	attachment.Name = "PromptAttachment"
	attachment.Parent = root

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "তুলুন"
	prompt.ObjectText = "🎁 উপহার বক্স"
	prompt.HoldDuration = Config.BOX_PROMPT_HOLD_DURATION
	prompt.MaxActivationDistance = Config.BOX_PROMPT_DISTANCE
	prompt.RequiresLineOfSight = false
	prompt.Parent = attachment

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 215, 120)
	light.Brightness = 1.5
	light.Range = 12
	light.Parent = root

	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 235, 150))
	sparkle.Size = NumberSequence.new(0.35, 0)
	sparkle.Lifetime = NumberRange.new(0.8, 1.4)
	sparkle.Rate = 4
	sparkle.Speed = NumberRange.new(0.5, 1.5)
	sparkle.SpreadAngle = Vector2.new(180, 180)
	sparkle.LightEmission = 1
	sparkle.Parent = attachment

	-- দেখার অংশ। ক্লায়েন্ট এটাকে ঘোরায় আর ভাসায় (BoxVisuals)।
	local visual: Model
	local template = getBoxTemplate()
	if template then
		local clone = template:Clone()
		stripScripts(clone)
		visual = Instance.new("Model")
		for _, child in clone:GetChildren() do
			if child:IsA("BasePart") then
				child.Parent = visual
			end
		end
		clone:Destroy()
		local handle = visual:FindFirstChild("Handle")
		visual.PrimaryPart = if handle and handle:IsA("BasePart") then handle else visual:FindFirstChildWhichIsA("BasePart")
	else
		visual = makeFallbackVisual()
	end
	visual.Name = "Visual"
	for _, d in visual:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
			d.CanTouch = false
			d.CanQuery = false
		elseif d:IsA("JointInstance") or d:IsA("WeldConstraint") then
			d:Destroy()
		end
	end
	visual:PivotTo(CFrame.new(record.position))
	visual.Parent = model

	prompt.Triggered:Connect(function(player)
		EventManager._OnPickup(record, player)
	end)

	model.Parent = boxesFolder
	return model
end

local function makeBoxTool(record: BoxRecord): Tool
	local tool: Tool
	local template = getBoxTemplate()
	if template then
		tool = template:Clone()
		stripScripts(tool)
	else
		tool = Instance.new("Tool")
		local visual = makeFallbackVisual()
		for _, part in visual:GetChildren() do
			part.Parent = tool
			if part.Name ~= "Handle" then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = tool:FindFirstChild("Handle") :: BasePart
				weld.Part1 = part :: BasePart
				weld.Parent = part
			end
		end
		visual:Destroy()
	end
	tool.Name = "🎁 Gift Box"
	tool.ToolTip = "খুলতে ক্লিক করুন"
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool:SetAttribute(BOX_ATTRIBUTE, record.id)
	for _, d in tool:GetDescendants() do
		if d:IsA("BasePart") then
			d.Anchored = false
			d.CanCollide = false
			d.Massless = true
		end
	end
	return tool
end

local function popEffect(position: Vector3)
	local part = Instance.new("Part")
	part.Name = "BTUnboxPop"
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(1.5, 1.5, 1.5)
	part.CFrame = CFrame.new(position)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 215, 0)
	part.Transparency = 0.2
	part.Parent = boxesFolder

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0), Color3.fromRGB(255, 255, 255))
	emitter.Size = NumberSequence.new(0.6, 0)
	emitter.Lifetime = NumberRange.new(0.5, 0.9)
	emitter.Speed = NumberRange.new(10, 18)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Rate = 0
	emitter.Parent = part
	emitter:Emit(45)

	TweenService:Create(part, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(5, 5, 5),
		Transparency = 1,
	}):Play()
	Debris:AddItem(part, 1.2)
end

----------------------------------------------------------------------
-- বক্সের অবস্থা
----------------------------------------------------------------------
local function disconnectAll(record: BoxRecord)
	for _, conn in record.connections do
		conn:Disconnect()
	end
	table.clear(record.connections)
end

local function findHeldBox(ev: EventState, player: Player): BoxRecord?
	for _, record in ev.boxes do
		if record.state == "held" and record.holder == player then
			return record
		end
	end
	return nil
end

-- হাতে থাকা বক্স মাটিতে আগের জায়গায় ফেরত (মারা গেলে বা চলে গেলে, I4)।
local function returnToMap(record: BoxRecord)
	if record.state ~= "held" then
		return
	end
	record.state = "ground"
	disconnectAll(record)
	local tool = record.tool
	record.tool = nil
	record.holder = nil
	if tool and tool.Parent then
		tool:Destroy()
	end
	if current and current.boxes[record.id] == record then
		record.model = buildGroundModel(record)
	end
end

function EventManager._OnPickup(record: BoxRecord, player: Player)
	local ev = current
	if not ev or ev.boxes[record.id] ~= record or record.state ~= "ground" then
		return
	end
	if not pickupLimiter(player) then
		return
	end
	local character, humanoid, root = Util.GetLiveCharacter(player)
	if not character or not humanoid or not root then
		return
	end
	if (root.Position - record.position).Magnitude > Config.BOX_PROMPT_DISTANCE + 8 then
		return
	end
	if findHeldBox(ev, player) then
		notify(player, "Warn", { text = "⚠️ আগের বক্সটা আগে খুলুন!" })
		return
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then
		return
	end

	record.state = "held"
	record.holder = player
	record.heldSince = os.clock()
	if record.model then
		record.model:Destroy()
		record.model = nil
	end

	local tool = makeBoxTool(record)
	record.tool = tool
	tool.Parent = backpack
	-- R9: তোলার সাথে সাথে হাতে।
	humanoid:EquipTool(tool)

	table.insert(
		record.connections,
		tool.AncestryChanged:Connect(function()
			-- state অন্য কোথাও বদলাতে পারে, তাই টাইপ narrowing এড়াতে string হিসেবে পড়া।
			local state: string = record.state
			if state ~= "held" or record.tool ~= tool then
				return
			end
			local parent = tool.Parent
			local liveBackpack = player:FindFirstChildOfClass("Backpack")
			if not tool:IsDescendantOf(game) or (parent ~= liveBackpack and parent ~= player.Character) then
				returnToMap(record)
			end
		end)
	)
	table.insert(
		record.connections,
		humanoid.Died:Connect(function()
			returnToMap(record)
		end)
	)

	notify(player, "Pickup", { boxId = record.id, minOpenTime = Config.MIN_OPEN_TIME })
end

----------------------------------------------------------------------
-- টুল আসবে কিনা (R14)
----------------------------------------------------------------------
local function weightedPick(names: { string }, counts: { [string]: number }): string
	local total = 0
	for _, name in names do
		total += counts[name]
	end
	local roll = rng:NextNumber() * total
	for _, name in names do
		roll -= counts[name]
		if roll <= 0 then
			return name
		end
	end
	return names[#names]
end

local function decideTool(ev: EventState, player: Player, openedBefore: number): string?
	local toolsLeft = 0
	local candidates = {}
	for name, count in ev.tools do
		if count > 0 then
			toolsLeft += count
			table.insert(candidates, name)
		end
	end
	if toolsLeft == 0 then
		return nil
	end
	table.sort(candidates)

	local boxesLeft = ev.total - openedBefore -- এই বক্সসহ
	local forced = toolsLeft >= boxesLeft
	if not forced then
		if openedBefore < ev.safeCount then
			return nil
		end
		if ev.gapLeft > 0 then
			ev.gapLeft -= 1
			return nil
		end
		if rng:NextNumber() >= toolsLeft / boxesLeft then
			return nil
		end
	end

	local notOwned = {}
	for _, name in candidates do
		if not ToolData.PlayerOwns(player, name) then
			table.insert(notOwned, name)
		end
	end
	if #notOwned > 0 then
		return weightedPick(notOwned, ev.tools)
	end
	if forced then
		return weightedPick(candidates, ev.tools)
	end
	-- তার কাছে সব টুল আগেই আছে: টুলটা পরের বক্সের জন্য থাকবে।
	return nil
end

local function giveCoins(player: Player): number
	local low = math.min(Config.COIN_REWARD_MIN, Config.COIN_REWARD_MAX)
	local high = math.max(Config.COIN_REWARD_MIN, Config.COIN_REWARD_MAX)
	local amount = rng:NextInteger(low, high)
	local stats = player:FindFirstChild("leaderstats")
	local currency = stats and stats:FindFirstChild(Config.CURRENCY_NAME)
	if currency and (currency:IsA("IntValue") or currency:IsA("NumberValue")) then
		currency.Value += amount
	else
		warn(`[BTToolsEvents] {player.Name} এর leaderstats এ '{Config.CURRENCY_NAME}' ভ্যালু নেই, টাকা যোগ হয়নি।`)
	end
	return amount
end

----------------------------------------------------------------------
-- বক্স খোলা
----------------------------------------------------------------------
local function onOpenRequest(player: Player, boxId: any)
	if type(boxId) ~= "number" or not openLimiter(player) then
		return
	end
	local ev = current
	if not ev then
		notify(player, "OpenFailed", { text = "ইভেন্ট শেষ হয়ে গেছে।" })
		return
	end
	local record = ev.boxes[boxId]
	if not record or record.state ~= "held" or record.holder ~= player then
		return
	end
	local tool = record.tool
	if not tool or tool.Parent ~= player.Character then
		notify(player, "OpenFailed", { text = "বক্সটা হাতে নিন।" })
		return
	end
	if os.clock() - record.heldSince < Config.MIN_OPEN_TIME then
		notify(player, "OpenFailed", { text = "একটু অপেক্ষা করুন..." })
		return
	end

	record.state = "opened"
	disconnectAll(record)
	local handle = tool:FindFirstChild("Handle")
	if handle and handle:IsA("BasePart") then
		popEffect(handle.Position)
	end
	record.tool = nil
	record.holder = nil
	tool:Destroy()

	local openedBefore = ev.opened
	ev.opened += 1
	publishState()

	local toolName = decideTool(ev, player, openedBefore)
	if toolName then
		ev.tools[toolName] -= 1
		ev.gapLeft = ev.gap
		ToolData.Award(player, toolName)
		ToolData.AppendHistory(player.UserId, player.Name, toolName, "win")
		table.insert(ev.winners, { userId = player.UserId, name = player.DisplayName, tool = toolName })
		notify(player, "Result", { reward = "Tool", tool = toolName })
		AnnounceRemote:FireAllClients("Winner", {
			userId = player.UserId,
			name = player.DisplayName,
			tool = toolName,
		})
		Showcase.Show(player, toolName)
		Showcase.TagPlayer(player, toolName)
	else
		local amount = giveCoins(player)
		notify(player, "Result", { reward = "Coin", amount = amount, currency = Config.CURRENCY_NAME })
	end

	if ev.opened >= ev.total then
		EventManager.Stop("all")
	end
end

----------------------------------------------------------------------
-- ইভেন্ট শুরু আর শেষ
----------------------------------------------------------------------
function EventManager.IsActive(): boolean
	return current ~= nil
end

function EventManager.Start(admin: Player, params: StartParams): (boolean, string)
	if current then
		return false, "একটা ইভেন্ট এখন চলছে। আগে STOP চাপুন।"
	end

	local toolTotal = 0
	for name, count in params.tools do
		if not ToolData.FindTool(name) then
			return false, `'{name}' টুলটা ServerStorage > {Config.TOOLS_FOLDER_NAME} এ নেই।`
		end
		toolTotal += count
	end
	if toolTotal < 1 then
		return false, "অন্তত একটা টুল বেছে নিন।"
	end
	if toolTotal > params.totalBoxes then
		return false, "টুল বক্সের সংখ্যা মোট বক্সের চেয়ে বেশি।"
	end

	local _, _, root = Util.GetLiveCharacter(admin)
	local center = if root then root.Position else nil
	local positions, mode = BoxSpawner.FindPositions(
		params.totalBoxes,
		center,
		params.radius,
		{ boxesFolder, Showcase.GetFolder() }
	)
	if mode == "none" then
		return false, "কোনো স্পন জোন নেই, আর আপনার ক্যারেক্টারও পাওয়া যায়নি।"
	end
	if #positions == 0 then
		return false, "বক্স রাখার মতো কোনো জায়গা পাওয়া যায়নি।"
	end
	if #positions < toolTotal then
		return false, `জায়গা কম: মাত্র {#positions} টা বক্স রাখা গেছে, কিন্তু টুল বক্স {toolTotal} টা। জোন বড় করুন।`
	end

	local total = #positions
	local ev: EventState = {
		total = total,
		opened = 0,
		safeCount = math.floor(total * params.safePercent / 100),
		gap = params.gap,
		gapLeft = 0,
		tools = table.clone(params.tools),
		boxes = {},
		endsAt = Workspace:GetServerTimeNow() + params.minutes * 60,
		winners = {},
	}
	current = ev

	for _, position in positions do
		nextBoxId += 1
		local record: BoxRecord = {
			id = nextBoxId,
			state = "ground",
			position = position,
			model = nil,
			holder = nil,
			tool = nil,
			heldSince = 0,
			connections = {},
		}
		ev.boxes[record.id] = record
		record.model = buildGroundModel(record)
	end

	publishState()
	AnnounceRemote:FireAllClients("Start", { total = total, endsAt = ev.endsAt })

	task.delay(params.minutes * 60, function()
		if current == ev then
			EventManager.Stop("time")
		end
	end)

	local where = if mode == "zones" then "স্পন জোনে" else "আপনার চারপাশে"
	local message = `✅ {where} {total} টা বক্স স্পন হয়েছে!`
	if total < params.totalBoxes then
		message ..= ` ({params.totalBoxes} টা চেয়েছিলেন, জায়গা কম ছিল)`
	end
	return true, message
end

-- reason: "time" | "all" | "admin"
function EventManager.Stop(reason: string): boolean
	local ev = current
	if not ev then
		return false
	end
	current = nil
	for _, record in ev.boxes do
		disconnectAll(record)
		if record.model then
			record.model:Destroy()
			record.model = nil
		end
		if record.tool then
			record.tool:Destroy()
			record.tool = nil
		end
		record.state = "opened"
	end
	publishState()
	Showcase.ClearPlayerTags()
	AnnounceRemote:FireAllClients("End", { reason = reason, winners = ev.winners })
	return true
end

function EventManager.Init()
	local existing = Workspace:FindFirstChild("BTToolsEvents_Boxes")
	if existing then
		existing:Destroy()
	end
	boxesFolder = Instance.new("Folder")
	boxesFolder.Name = "BTToolsEvents_Boxes"
	boxesFolder.Parent = Workspace

	if not getBoxTemplate() then
		warn("[BTToolsEvents] ServerStorage > BTToolsEvents > GiftBoxTool নেই, সাধারণ বক্স ব্যবহার হবে।")
	end

	publishState()
	OpenBoxRemote.OnServerEvent:Connect(onOpenRequest)

	Players.PlayerRemoving:Connect(function(player)
		local ev = current
		local record = ev and findHeldBox(ev, player)
		if record then
			returnToMap(record)
		end
	end)
end

return EventManager
