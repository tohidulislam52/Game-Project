--[[
	BT Tools Event: ToolData (ModuleScript, সার্ভার)

	কে কোন টুল পার্মানেন্ট পেয়েছে সেটা ডেটাস্টোরে রাখে, আর প্লেয়ারকে টুল দেয়।

	ডেটা সেভের নিয়ম:
	- প্রতি প্লেয়ারের একটা key: "u_<UserId>"।
	  মান: { Version, UserId, Name, Tools = { "Handcuffs", ... }, UpdatedAt }
	- প্রতিটা পরিবর্তন (টুল যোগ বা সরানো) UpdateAsync দিয়ে হয়। স্টোরে যা আছে তার সাথে
	  মিলিয়ে লেখা হয়, পুরো লিস্ট কখনো ওভাররাইট হয় না। তাই লোড ফেল করলেও পুরনো টুল মুছবে না।
	- লেখা ফেল করলে পরিবর্তনটা queue তে থাকে, পরে আবার চেষ্টা হয়, সার্ভার বন্ধের সময়ও (BindToClose)।

	টুল দেওয়ার নিয়ম (ডাবল টুল কখনো না):
	- GiveCopy একমাত্র ফাংশন যেটা টুল দেয়। দেওয়ার আগে Backpack / Character / StarterGear চেক করে,
	  টুলটা থাকলে আর দেয় না।
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("BTToolsEvents")
local Config = require(Shared:WaitForChild("Config"))
local Util = require(script.Parent:WaitForChild("Util"))

local SCHEMA_VERSION = 1
local HISTORY_KEY = "Log"
local SAVE_ATTEMPTS = 5

type Change = { op: "add" | "remove", tool: string, name: string? }
type Entry = { loaded: boolean, tools: { [string]: boolean } }

local ToolData = {}

local store: DataStore? = nil
local historyStore: DataStore? = nil
local dataStoreDisabled = false

local cache: { [Player]: Entry } = {}
-- ফেল হওয়া পরিবর্তন: userId -> পরিবর্তনের লিস্ট (ক্রম অনুযায়ী)
local pending: { [number]: { Change } } = {}

----------------------------------------------------------------------
-- ডেটাস্টোর
----------------------------------------------------------------------
local function isFatalStoreError(message: string): boolean
	-- Studio তে API Services বন্ধ থাকলে আবার চেষ্টা করে লাভ নেই।
	if string.find(message, "StudioAccessToApisNotAllowed", 1, true) or string.find(message, "403", 1, true) then
		if not dataStoreDisabled then
			dataStoreDisabled = true
			warn(
				"[BTToolsEvents] ডেটাস্টোর কাজ করছে না। Studio তে টেস্ট করলে Game Settings > Security > "
					.. "'Enable Studio Access to API Services' চালু করুন। এখন টুল শুধু এই সেশনের জন্য থাকবে।"
			)
		end
		return true
	end
	return false
end

local function keyFor(userId: number): string
	return "u_" .. tostring(userId)
end

local function toolSetFromData(data: any): { [string]: boolean }
	local set = {}
	if type(data) == "table" and type(data.Tools) == "table" then
		for _, name in data.Tools do
			if type(name) == "string" then
				set[name] = true
			end
		end
	end
	return set
end

local function sortedList(set: { [string]: boolean }): { string }
	local list = {}
	for name in set do
		table.insert(list, name)
	end
	table.sort(list)
	return list
end

-- স্টোরে থাকা পুরনো মানের সাথে একটা পরিবর্তন মিলিয়ে নতুন মান বানায় (yield করে না)।
local function applyChanges(old: any, userId: number, changes: { Change }): any
	local set = toolSetFromData(old)
	local name = if type(old) == "table" and type(old.Name) == "string" then old.Name else nil
	for _, change in changes do
		if change.op == "add" then
			set[change.tool] = true
		else
			set[change.tool] = nil
		end
		name = change.name or name
	end
	return {
		Version = SCHEMA_VERSION,
		UserId = userId,
		Name = name,
		Tools = sortedList(set),
		UpdatedAt = os.time(),
	}
end

local function writeChanges(userId: number, changes: { Change }): boolean
	if dataStoreDisabled or not store then
		return false
	end
	local activeStore = store
	local ok = Util.Retry("টুল সেভ", SAVE_ATTEMPTS, function()
		activeStore:UpdateAsync(keyFor(userId), function(old)
			return applyChanges(old, userId, changes)
		end)
	end, isFatalStoreError)
	return ok
end

-- লেখার চেষ্টা করে, ফেল করলে queue তে রাখে।
local function commitChange(userId: number, change: Change)
	local queue = pending[userId]
	if queue then
		-- আগের পরিবর্তন এখনো বাকি, ক্রম ঠিক রাখতে এটাও পেছনে যোগ হবে।
		table.insert(queue, change)
		return
	end
	if not writeChanges(userId, { change }) then
		pending[userId] = { change }
	end
end

local function flushPending()
	for userId, queue in pending do
		pending[userId] = nil
		if not writeChanges(userId, queue) then
			-- এর মধ্যে নতুন পরিবর্তন এসে থাকলে সেগুলো পেছনে থাকবে।
			local newer = pending[userId]
			if newer then
				for _, change in newer do
					table.insert(queue, change)
				end
			end
			pending[userId] = queue
		end
	end
end

local function loadTools(userId: number): { [string]: boolean }?
	if dataStoreDisabled or not store then
		return nil
	end
	local activeStore = store
	local ok, data = Util.Retry("টুল লোড", SAVE_ATTEMPTS, function()
		return activeStore:GetAsync(keyFor(userId))
	end, isFatalStoreError)
	if not ok then
		return nil
	end
	local set = toolSetFromData(data)
	-- এই সার্ভারে এখনো লেখা বাকি এমন পরিবর্তনগুলোও হিসাবে ধরা।
	local queue = pending[userId]
	if queue then
		for _, change in queue do
			set[change.tool] = if change.op == "add" then true else nil
		end
	end
	return set
end

----------------------------------------------------------------------
-- টুল আর ইনভেন্টরি
----------------------------------------------------------------------
function ToolData.GetToolsFolder(): Folder?
	local folder = ServerStorage:FindFirstChild(Config.TOOLS_FOLDER_NAME)
	if folder and folder:IsA("Folder") then
		return folder
	end
	return nil
end

function ToolData.FindTool(toolName: string): Tool?
	local folder = ToolData.GetToolsFolder()
	local tool = folder and folder:FindFirstChild(toolName)
	if tool and tool:IsA("Tool") then
		return tool
	end
	return nil
end

function ToolData.ListToolNames(): { string }
	local names = {}
	local folder = ToolData.GetToolsFolder()
	if folder then
		for _, child in folder:GetChildren() do
			if child:IsA("Tool") then
				table.insert(names, child.Name)
			end
		end
	end
	table.sort(names)
	return names
end

local function containersOf(player: Player): { Instance }
	local list = {}
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		table.insert(list, backpack)
	end
	if player.Character then
		table.insert(list, player.Character)
	end
	local starterGear = player:FindFirstChild("StarterGear")
	if starterGear then
		table.insert(list, starterGear)
	end
	return list
end

-- টুলটা প্লেয়ারের Backpack / হাতে / StarterGear এ আছে কিনা।
function ToolData.HasInInventory(player: Player, toolName: string): boolean
	for _, container in containersOf(player) do
		local found = container:FindFirstChild(toolName)
		if found and found:IsA("Tool") then
			return true
		end
	end
	return false
end

-- টুলটা প্লেয়ারের কাছে আছে কিনা (ইনভেন্টরিতে, অথবা সেভ করা লিস্টে)।
function ToolData.PlayerOwns(player: Player, toolName: string): boolean
	if ToolData.HasInInventory(player, toolName) then
		return true
	end
	local entry = cache[player]
	return entry ~= nil and entry.tools[toolName] == true
end

-- একমাত্র ফাংশন যেটা টুল দেয়। আগে থেকে থাকলে দেয় না। দিলে true ফেরত দেয়।
function ToolData.GiveCopy(player: Player, toolName: string): boolean
	if ToolData.HasInInventory(player, toolName) then
		return false
	end
	local source = ToolData.FindTool(toolName)
	if not source then
		warn(`[BTToolsEvents] '{toolName}' টুলটা ServerStorage > {Config.TOOLS_FOLDER_NAME} এ পাওয়া যায়নি।`)
		return false
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then
		return false
	end
	source:Clone().Parent = backpack
	-- StarterGear এ রাখলে respawn এর পরে Roblox নিজেই টুলটা আবার দেবে।
	local starterGear = player:FindFirstChild("StarterGear")
	if starterGear then
		source:Clone().Parent = starterGear
	end
	return true
end

function ToolData.RemoveCopies(player: Player, toolName: string)
	for _, container in containersOf(player) do
		for _, child in container:GetChildren() do
			if child:IsA("Tool") and child.Name == toolName then
				child:Destroy()
			end
		end
	end
end

----------------------------------------------------------------------
-- জেতা আর অ্যাডমিনের কাজ
----------------------------------------------------------------------
-- ইভেন্টে জিতলে: সেভ করে আর (না থাকলে) টুল দেয়।
function ToolData.Award(player: Player, toolName: string)
	local entry = cache[player]
	if entry then
		entry.tools[toolName] = true
	end
	ToolData.GiveCopy(player, toolName)
	local userId, name = player.UserId, player.Name
	task.spawn(commitChange, userId, { op = "add", tool = toolName, name = name } :: Change)
end

-- অ্যাডমিন UserId দিয়ে টুল দেয় বা সরায় (প্লেয়ার অফলাইন হলেও)। ডেটাস্টোরে লেখা হলে true দেয়।
function ToolData.AdminSetOwned(userId: number, toolName: string, owned: boolean): (boolean, string)
	local player = Players:GetPlayerByUserId(userId)
	local change: Change = { op = if owned then "add" else "remove", tool = toolName, name = player and player.Name }

	if player then
		local entry = cache[player]
		if entry then
			entry.tools[toolName] = if owned then true else nil
		end
		if owned then
			ToolData.GiveCopy(player, toolName)
		else
			ToolData.RemoveCopies(player, toolName)
		end
	end

	if pending[userId] then
		table.insert(pending[userId], change)
		return false, "ডেটাস্টোর এখন ব্যস্ত, পরিবর্তনটা পরে সেভ হবে।"
	end
	if writeChanges(userId, { change }) then
		return true, "সেভ হয়েছে।"
	end
	if dataStoreDisabled then
		return false, "ডেটাস্টোর বন্ধ (Studio API Access চালু করুন)।"
	end
	pending[userId] = { change }
	return false, "এখন সেভ করা যায়নি, পরে আবার চেষ্টা হবে।"
end

-- একজন প্লেয়ারের সেভ করা টুলের লিস্ট (অ্যাডমিন প্যানেলের জন্য)।
function ToolData.GetSavedTools(userId: number): { string }?
	local player = Players:GetPlayerByUserId(userId)
	local entry = player and cache[player]
	if entry and entry.loaded then
		return sortedList(entry.tools)
	end
	local set = loadTools(userId)
	return set and sortedList(set)
end

----------------------------------------------------------------------
-- ইতিহাস (R16): একটা key, ভেতরে UserId অনুযায়ী ভাগ করা, তাই একজনের সব তথ্য এক জায়গায়।
-- { Version = 2, Users = { ["<UserId>"] = { n = নাম, last = সময়, r = { { t, k, at, by } } } } }
-- k: "win" (ইভেন্টে জেতা) | "gift" (অ্যাডমিন দিয়েছেন) | "remove" (অ্যাডমিন সরিয়েছেন)
----------------------------------------------------------------------
export type HistoryKind = "win" | "gift" | "remove"

local HISTORY_VERSION = 2

-- পুরনো লাইন-লাইন ফরম্যাট ({ {u, n, t, at}, ... }) থাকলে নতুন ফরম্যাটে নিয়ে নেয়, কিছু হারায় না।
local function normalizeHistory(old: any): { Version: number, Users: { [string]: any } }
	if type(old) == "table" and old.Version == HISTORY_VERSION and type(old.Users) == "table" then
		return old
	end
	local users: { [string]: any } = {}
	if type(old) == "table" then
		for _, entry in ipairs(old) do
			if type(entry) == "table" and type(entry.u) == "number" then
				local key = tostring(entry.u)
				local user = users[key] or { n = entry.n, last = 0, r = {} }
				users[key] = user
				table.insert(user.r, { t = entry.t, k = "win", at = entry.at })
				user.last = math.max(user.last, tonumber(entry.at) or 0)
				user.n = entry.n or user.n
			end
		end
	end
	return { Version = HISTORY_VERSION, Users = users }
end

local function addHistoryRecord(old: any, userId: number, playerName: string?, toolName: string, kind: HistoryKind, by: string?): any
	local data = normalizeHistory(old)
	local key = tostring(userId)
	local now = os.time()
	local user = data.Users[key] or { n = playerName, last = now, r = {} }
	data.Users[key] = user
	user.n = playerName or user.n
	user.last = now
	table.insert(user.r, { t = toolName, k = kind, at = now, by = by })
	while #user.r > Config.HISTORY_MAX_RECORDS_PER_USER do
		table.remove(user.r, 1)
	end

	-- সীমার বেশি প্লেয়ার হলে যার শেষ রেকর্ড সবচেয়ে পুরনো সে বাদ।
	local count = 0
	for _ in data.Users do
		count += 1
	end
	while count > Config.HISTORY_MAX_USERS do
		local oldestKey, oldestTime = nil, math.huge
		for userKey, info in data.Users do
			local last = tonumber(info.last) or 0
			if last < oldestTime then
				oldestKey, oldestTime = userKey, last
			end
		end
		if not oldestKey then
			break
		end
		data.Users[oldestKey] = nil
		count -= 1
	end
	return data
end

function ToolData.AppendHistory(userId: number, playerName: string?, toolName: string, kind: HistoryKind, by: string?)
	if dataStoreDisabled or not historyStore then
		return
	end
	local activeStore = historyStore
	task.spawn(function()
		Util.Retry("ইতিহাস সেভ", 3, function()
			activeStore:UpdateAsync(HISTORY_KEY, function(old)
				return addHistoryRecord(old, userId, playerName, toolName, kind, by)
			end)
		end, isFatalStoreError)
	end)
end

-- সবচেয়ে সাম্প্রতিক limit জন প্লেয়ার। onlyUserId দিলে শুধু সেই প্লেয়ার।
-- ফেরত: { { u = UserId, n = নাম, last = সময়, r = রেকর্ড (নতুনটা আগে) } }
function ToolData.GetHistory(limit: number, onlyUserId: number?): { any }?
	if dataStoreDisabled or not historyStore then
		return nil
	end
	local activeStore = historyStore
	local ok, raw = Util.Retry("ইতিহাস লোড", 3, function()
		return activeStore:GetAsync(HISTORY_KEY)
	end, isFatalStoreError)
	if not ok then
		return nil
	end
	local data = normalizeHistory(raw)
	local result = {}
	for key, info in data.Users do
		local userId = tonumber(key)
		if userId and (not onlyUserId or onlyUserId == userId) and type(info) == "table" then
			local records = {}
			if type(info.r) == "table" then
				for i = #info.r, 1, -1 do
					table.insert(records, info.r[i])
				end
			end
			table.insert(result, { u = userId, n = info.n, last = tonumber(info.last) or 0, r = records })
		end
	end
	table.sort(result, function(a, b)
		return a.last > b.last
	end)
	while #result > limit do
		table.remove(result)
	end
	return result
end

----------------------------------------------------------------------
-- গেমে ঢোকা আর বের হওয়া
----------------------------------------------------------------------
local function grantSavedTools(player: Player, entry: Entry)
	-- ক্যারেক্টার আর Backpack তৈরি হওয়া পর্যন্ত অপেক্ষা (সর্বোচ্চ ৩০ সেকেন্ড)।
	local deadline = os.clock() + 30
	while player.Parent and not (player.Character and player:FindFirstChildOfClass("Backpack")) do
		if os.clock() > deadline then
			return
		end
		task.wait(0.5)
	end
	if not player.Parent then
		return
	end
	for toolName in entry.tools do
		ToolData.GiveCopy(player, toolName)
	end
end

local function onPlayerAdded(player: Player)
	local joinedAt = os.clock()
	local entry: Entry = { loaded = false, tools = {} }
	cache[player] = entry

	local loaded = loadTools(player.UserId)
	-- লোড ফেল করলে ব্যাকগ্রাউন্ডে আবার চেষ্টা (প্লেয়ার গেমে থাকা পর্যন্ত)।
	while not loaded and player.Parent and not dataStoreDisabled do
		task.wait(15)
		loaded = loadTools(player.UserId)
	end
	if not player.Parent or cache[player] ~= entry then
		return
	end
	if loaded then
		-- লোডের সময় যদি এই সেশনে নতুন টুল জিতে থাকে, সেগুলোও থাকবে।
		for toolName in loaded do
			entry.tools[toolName] = true
		end
	end
	entry.loaded = true

	-- R6: গেমে ঢোকার কিছুক্ষণ পরে দেওয়া, যাতে গেমের অন্য সিস্টেম আগে নিজের টুল দিতে পারে।
	local remaining = Config.JOIN_GRANT_DELAY - (os.clock() - joinedAt)
	if remaining > 0 then
		task.wait(remaining)
	end
	grantSavedTools(player, entry)
end

function ToolData.Init()
	local ok, err = pcall(function()
		store = DataStoreService:GetDataStore(Config.DATASTORE_NAME)
		historyStore = DataStoreService:GetDataStore(Config.HISTORY_DATASTORE_NAME)
	end)
	if not ok then
		isFatalStoreError(tostring(err))
		if not dataStoreDisabled then
			warn(`[BTToolsEvents] ডেটাস্টোর চালু করা যায়নি: {err}`)
			dataStoreDisabled = true
		end
	end

	if not ToolData.GetToolsFolder() then
		warn(`[BTToolsEvents] ServerStorage এ '{Config.TOOLS_FOLDER_NAME}' ফোল্ডার নেই। পুরস্কারের টুলগুলো সেখানে রাখুন।`)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
	Players.PlayerRemoving:Connect(function(player)
		cache[player] = nil
	end)

	-- বাকি থাকা সেভগুলো প্রতি ৩০ সেকেন্ডে আবার চেষ্টা।
	task.spawn(function()
		while true do
			task.wait(30)
			if next(pending) then
				flushPending()
			end
		end
	end)

	game:BindToClose(function()
		if not next(pending) or RunService:IsStudio() then
			return
		end
		local running = 0
		for userId, queue in pending do
			pending[userId] = nil
			running += 1
			task.spawn(function()
				writeChanges(userId, queue)
				running -= 1
			end)
		end
		local deadline = os.clock() + 25
		while running > 0 and os.clock() < deadline do
			task.wait(0.2)
		end
	end)
end

return ToolData
