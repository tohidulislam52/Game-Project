--[[
	BT Tools Event: AdminService (ModuleScript, সার্ভার)

	অ্যাডমিন প্যানেলের সব অনুরোধ এখানে আসে (RemoteFunction: AdminRequest)।
	প্রতিটা অনুরোধে সার্ভার নিজে UserId দিয়ে অ্যাডমিন কিনা চেক করে,
	আর ক্লায়েন্টের পাঠানো প্রতিটা মান যাচাই করে। ক্লায়েন্টের কথা বিশ্বাস করা হয় না।
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("BTToolsEvents")
local Config = require(Shared:WaitForChild("Config"))
local AdminRemote = Shared:WaitForChild("Remotes"):WaitForChild("AdminRequest") :: RemoteFunction

local Modules = script.Parent
local Util = require(Modules:WaitForChild("Util"))
local ToolData = require(Modules:WaitForChild("ToolData"))
local BoxSpawner = require(Modules:WaitForChild("BoxSpawner"))
local Showcase = require(Modules:WaitForChild("Showcase"))
local EventManager = require(Modules:WaitForChild("EventManager"))

local AdminService = {}

local limiter = Util.RateLimiter(0.4)

type Response = { ok: boolean, message: string?, data: any? }

local function fail(message: string): Response
	return { ok = false, message = message }
end

local function getInfo(): Response
	return {
		ok = true,
		data = {
			tools = ToolData.ListToolNames(),
			active = EventManager.IsActive(),
			zoneCount = BoxSpawner.CountZones(),
			hasShowcase = Showcase.HasShowcasePart(),
			defaults = {
				totalBoxes = Config.DEFAULT_TOTAL_BOXES,
				minutes = Config.DEFAULT_EVENT_MINUTES,
				radius = Config.DEFAULT_SPAWN_RADIUS,
				safePercent = Config.DEFAULT_TOOL_SAFE_PERCENT,
				gap = Config.DEFAULT_TOOL_GAP,
			},
			limits = {
				maxBoxes = Config.MAX_TOTAL_BOXES,
				maxMinutes = Config.MAX_EVENT_MINUTES,
				maxRadius = Config.MAX_SPAWN_RADIUS,
			},
		},
	}
end

local function start(player: Player, payload: any): Response
	if type(payload) ~= "table" then
		return fail("ভুল তথ্য।")
	end
	local totalBoxes, minutes, radius = payload.totalBoxes, payload.minutes, payload.radius
	local safePercent, gap, tools = payload.safePercent, payload.gap, payload.tools
	if not Util.IsInteger(totalBoxes, 1, Config.MAX_TOTAL_BOXES) then
		return fail(`মোট বক্স 1 থেকে {Config.MAX_TOTAL_BOXES} এর মধ্যে দিন।`)
	end
	if not Util.IsInteger(minutes, 1, Config.MAX_EVENT_MINUTES) then
		return fail(`সময় 1 থেকে {Config.MAX_EVENT_MINUTES} মিনিটের মধ্যে দিন।`)
	end
	if not Util.IsInteger(radius, 10, Config.MAX_SPAWN_RADIUS) then
		return fail(`Radius 10 থেকে {Config.MAX_SPAWN_RADIUS} এর মধ্যে দিন।`)
	end
	if not Util.IsInteger(safePercent, 0, 90) then
		return fail("শুরুর নিরাপদ % 0 থেকে 90 এর মধ্যে দিন।")
	end
	if not Util.IsInteger(gap, 0, 20) then
		return fail("টুলের মাঝের ফাঁক 0 থেকে 20 এর মধ্যে দিন।")
	end
	if type(tools) ~= "table" then
		return fail("টুল বেছে নিন।")
	end
	local cleanTools: { [string]: number } = {}
	local kinds = 0
	for name, count in tools do
		if type(name) ~= "string" or #name > 100 or not Util.IsInteger(count, 0, Config.MAX_TOTAL_BOXES) then
			return fail("টুলের তথ্য ভুল।")
		end
		if count > 0 then
			kinds += 1
			if kinds > 50 then
				return fail("টুলের তথ্য ভুল।")
			end
			cleanTools[name] = count
		end
	end

	local ok, message = EventManager.Start(player, {
		totalBoxes = totalBoxes,
		minutes = minutes,
		radius = radius,
		safePercent = safePercent,
		gap = gap,
		tools = cleanTools,
	})
	return { ok = ok, message = message }
end

local function readUserAndTool(payload: any, needTool: boolean): (number?, string?, string?)
	if type(payload) ~= "table" then
		return nil, nil, "ভুল তথ্য।"
	end
	local userId = payload.userId
	if not Util.IsInteger(userId, 1, 2 ^ 53) then
		return nil, nil, "সঠিক UserId দিন।"
	end
	if not needTool then
		return userId, nil, nil
	end
	local toolName = payload.tool
	if type(toolName) ~= "string" or not ToolData.FindTool(toolName) then
		return nil, nil, "লিস্ট থেকে একটা টুল বেছে নিন।"
	end
	return userId, toolName, nil
end

local function handle(player: Player, action: any, payload: any): Response
	if not Config.IsAdmin(player) then
		return fail("অনুমতি নেই, আপনি অ্যাডমিন নন।")
	end
	if not limiter(player) then
		return fail("একটু ধীরে...")
	end

	if action == "GetInfo" then
		return getInfo()
	elseif action == "Start" then
		return start(player, payload)
	elseif action == "Stop" then
		if EventManager.Stop("admin") then
			return { ok = true, message = "⏹ ইভেন্ট বন্ধ হয়েছে।" }
		end
		return fail("কোনো ইভেন্ট চলছে না।")
	elseif action == "GiveTool" or action == "RemoveTool" then
		local userId, toolName, err = readUserAndTool(payload, true)
		if not userId or not toolName then
			return fail(err or "ভুল তথ্য।")
		end
		local owned = action == "GiveTool"
		local saved, message = ToolData.AdminSetOwned(userId, toolName, owned)
		local verb = if owned then "দেওয়া" else "সরানো"
		return { ok = saved, message = `{toolName} {verb} হয়েছে: {message}` }
	elseif action == "GetPlayerTools" then
		local userId, _, err = readUserAndTool(payload, false)
		if not userId then
			return fail(err or "ভুল তথ্য।")
		end
		local tools = ToolData.GetSavedTools(userId)
		if not tools then
			return fail("ডেটাস্টোর থেকে পড়া যায়নি।")
		end
		return { ok = true, data = tools }
	elseif action == "GetHistory" then
		local history = ToolData.GetHistory(30)
		if not history then
			return fail("ইতিহাস পড়া যায়নি।")
		end
		return { ok = true, data = history }
	end
	return fail("অজানা কাজ।")
end

function AdminService.Init()
	AdminRemote.OnServerInvoke = function(player: Player, action: any, payload: any)
		local ok, result = pcall(handle, player, action, payload)
		if ok then
			return result
		end
		warn(`[BTToolsEvents] অ্যাডমিন অনুরোধে সমস্যা: {result}`)
		return fail("সার্ভারে সমস্যা হয়েছে।")
	end
end

return AdminService
