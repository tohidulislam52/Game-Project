--[[
    ███████╗██████╗ ███████╗    ███████╗ ██████╗ ███╗   ██╗███████╗
    ██╔════╝██╔══██╗██╔════╝    ╚══███╔╝██╔═══██╗████╗  ██║██╔════╝
    █████╗  ██████╔╝███████╗      ███╔╝ ██║   ██║██╔██╗ ██║█████╗
    ██╔══╝  ██╔═══╝ ╚════██║     ███╔╝  ██║   ██║██║╚██╗██║██╔══╝
    ██║     ██║     ███████║    ███████╗╚██████╔╝██║ ╚████║███████╗
    ╚═╝     ╚═╝     ╚══════╝    ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
Created By FPS Zone
Script Name: Zone Panel V8.0 [Pro]
Version: V8.0 [Pro]
Discord Server: discord.gg/Ysc2H8dHdN
[Paid] Script
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")
local MessagingService = game:GetService("MessagingService")
local TextChatService = game:GetService("TextChatService")
local LocalizationService = game:GetService("LocalizationService")
local GroupService = game:GetService("GroupService")

SCRIPT_VERSION = "8.0"

ZONE_LICENSE = {
	hubId = "6a6e3f9255122a6e768fcd9a",
	productId = "fwfd0vxun4tkli83nsp73xjtk3w1",
	moduleId = 9428572121,
	ownerUserId = 0,
	allowOnError = true,
}

local function zoneLicenseHttpOn()
	local ok, enabled = pcall(function()
		return HttpService.HttpEnabled
	end)
	return ok and enabled == true
end

local function zoneLicenseCheck()
	if not zoneLicenseHttpOn() then
		return false, "http"
	end
	if ZONE_LICENSE.hubId == "" or ZONE_LICENSE.productId == "" then
		return false, "config"
	end
	local ok, result = pcall(function()
		local Parcel = require(ZONE_LICENSE.moduleId)
		if ZONE_LICENSE.ownerUserId > 0 then
			return Parcel:Whitelist(ZONE_LICENSE.hubId, ZONE_LICENSE.productId, ZONE_LICENSE.ownerUserId)
		end
		return Parcel:Whitelist(ZONE_LICENSE.hubId, ZONE_LICENSE.productId)
	end)
	if not ok then
		warn("[Zone Panel] License check could not run:", result)
		if ZONE_LICENSE.allowOnError == true then
			return true, nil
		end
		return false, "error"
	end
	if result == true then
		return true, nil
	end
	return false, "license"
end

local function zoneLicenseOwnerId()
	if game.CreatorType == Enum.CreatorType.Group then
		local ok, info = pcall(function()
			return GroupService:GetGroupInfoAsync(game.CreatorId)
		end)
		if ok and type(info) == "table" and type(info.Owner) == "table" then
			return tonumber(info.Owner.Id) or 0
		end
		return 0
	end
	return tonumber(game.CreatorId) or 0
end

ZONE_LICENSE_OK, ZONE_LICENSE_REASON = zoneLicenseCheck()

if not ZONE_LICENSE_OK then
	local alert = Instance.new("RemoteEvent")
	alert.Name = "ZoneLicenseAlert"
	alert.Parent = ReplicatedStorage

	local ownerId = zoneLicenseOwnerId()
	local messages = {
		http = "Turn ON HTTP Requests to verify. Game Settings > Security > Allow HTTP Requests, then restart the server.",
		config = "Hub ID or Product ID is missing in the script. Fill in ZONE_LICENSE at the top of the ServerScript.",
		license = "This place is not licensed to run Zone Panel V8.0 [Pro].",
		error = "The license server could not be reached. Try again later.",
	}
	local payload = {
		image = 11745872910,
		title = "Verification failed",
		message = messages[tostring(ZONE_LICENSE_REASON or "license")] or messages.license,
		discord = "discord.gg/Ysc2H8dHdN",
	}

	local function tellOwner(player)
		if ownerId > 0 and player.UserId ~= ownerId then
			return
		end
		task.delay(4, function()
			if player.Parent then
				alert:FireClient(player, payload)
			end
		end)
	end

	for _, player in ipairs(Players:GetPlayers()) do
		tellOwner(player)
	end
	Players.PlayerAdded:Connect(tellOwner)

	warn("[Zone Panel] License verification failed (" .. tostring(ZONE_LICENSE_REASON) .. ") - the panel is disabled for everyone.")
	error("[Zone Panel] " .. payload.message, 0)
end

------------------------------------------------------------
-- ZONE PANEL CUSTOM SETTINGS (edit these values)
------------------------------------------------------------
-- Discord webhook. Paste a NEW webhook URL here (delete the old leaked one in Discord).
-- Every admin command is sent here. Admins cannot change or turn this off from the panel.
WEBHOOK_URL = ""
WEBHOOK_SEND_INTERVAL = 2.5 -- seconds between webhook sends (Discord rate limit friendly)

-- How long a normal announcement stays on screen when no time is typed in the panel.
ANNOUNCE_DISPLAY_SECONDS = 15
ANNOUNCE_DISPLAY_MIN_SECONDS = 3
ANNOUNCE_DISPLAY_MAX_SECONDS = 120

-- Offline warnings are shown this many seconds after the player joins.
PENDING_WARNING_DELAY_SECONDS = 120

-- Auto timeout for admins who ban too many players too fast (Owners are never affected).
BAN_SPAM_LIMIT = 5 -- bans
BAN_SPAM_WINDOW_SECONDS = 120 -- within this many seconds
BAN_SPAM_TIMEOUT_MINUTES = 30 -- timeout length

-- Admin timeout (Owner only command).
ADMIN_TIMEOUT_MAX_MINUTES = 1440
ADMIN_TIMEOUT_STORE_NAME = "AdminPanelTimeouts_v1"
------------------------------------------------------------

VERSION_CHECK_URL = "https://raw.githubusercontent.com/Mar39ci/zone-panel/main/version-pro.txt"

function normalizeAccentHex(value)
	local clean = tostring(value or ""):gsub("#", ""):gsub("%s", ""):upper()
	if #clean == 6 and not clean:match("[^0-9A-F]") then
		return clean
	end
	return "00DCFF"
end

function normalizeLanguageCode(value)
	return "en"
end

function normalizeBgStyleCode(value)
	local code = tostring(value or "stripes"):lower()
	if code == "orbs" or code == "bubbles" or code == "sparkles" or code == "rain" then
		return code
	end
	return "stripes"
end

LATEST_VERSION_AVAILABLE = ""
NEWS_TITLE = ""
NEWS_DESCRIPTION = ""
NEWS_IMAGE = ""
NEWS_ANNOUNCE = false
NEWS_ANNOUNCE_TITLE = ""
NEWS_ANNOUNCE_DESCRIPTION = ""
PANEL_NEWS_LAST_FETCH_TIME = 0
PANEL_NEWS_FETCH_OK_LOGGED = false

function panelVersionIsNewer(latest, current)
	local a = {}
	for part in tostring(latest or ""):gmatch("%d+") do
		table.insert(a, tonumber(part) or 0)
	end
	local b = {}
	for part in tostring(current or ""):gmatch("%d+") do
		table.insert(b, tonumber(part) or 0)
	end
	if #a == 0 or #b == 0 then
		return false
	end
	for i = 1, math.max(#a, #b) do
		local x = a[i] or 0
		local y = b[i] or 0
		if x ~= y then
			return x > y
		end
	end
	return false
end

function fetchPanelNews()
	PANEL_NEWS_LAST_FETCH_TIME = os.time()
	local ok, raw = pcall(function()
		return HttpService:GetAsync(VERSION_CHECK_URL, true)
	end)
	if not ok then
		warn(("[Zone Panel] Version check failed (HTTP disabled in Game Settings > Security, or GitHub unreachable): %s"):format(tostring(raw)))
		return
	end
	if type(raw) ~= "string" or raw == "" then
		warn("[Zone Panel] Version check failed: version-pro.txt is missing or empty in your GitHub repo.")
		return
	end
	local news = {}
	for line in raw:gmatch("[^\r\n]+") do
		local key, value = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
		if key and value and #key <= 24 then
			news[key:lower()] = value
		end
	end
	NEWS_TITLE = tostring(news.title or ""):sub(1, 80)
	NEWS_DESCRIPTION = tostring(news.description or ""):sub(1, 400)
	local img = tostring(news.image or ""):match("%d+")
	NEWS_IMAGE = ""
	if img then
		local imgOk = pcall(function()
			return game:GetService("MarketplaceService"):GetProductInfo(tonumber(img))
		end)
		if imgOk then
			NEWS_IMAGE = "rbxassetid://" .. img
		end
	end
	NEWS_ANNOUNCE = tostring(news.announce or ""):lower():gsub("%s+", "") == "true"
	NEWS_ANNOUNCE_TITLE = tostring(news.announcetitle or ""):sub(1, 80)
	NEWS_ANNOUNCE_DESCRIPTION = tostring(news.announcedescription or ""):sub(1, 400)
	local latest = tostring(news.version or ""):gsub("%s+", "")
	if PANEL_NEWS_FETCH_OK_LOGGED ~= true then
		PANEL_NEWS_FETCH_OK_LOGGED = true
		if latest ~= "" then
			print(("[Zone Panel] Version check OK. Running: v%s | Latest on GitHub: v%s"):format(SCRIPT_VERSION, latest))
		else
			warn('[Zone Panel] Version check: no "Version = ..." line found in version-pro.txt')
		end
	end
	if latest ~= "" and panelVersionIsNewer(latest, SCRIPT_VERSION) then
		if LATEST_VERSION_AVAILABLE ~= latest then
			LATEST_VERSION_AVAILABLE = latest
			warn(("[Zone Panel] New version available: %s (currently running: %s). Replace your scripts with the latest version to update."):format(latest, SCRIPT_VERSION))
		end
	else
		LATEST_VERSION_AVAILABLE = ""
	end
end

task.spawn(function()
	fetchPanelNews()
end)

REMOTE_EVENT_NAME = "AdminPanelRemote"
AUTH_RF_NAME = "AdminPanelAuth"
RESOLVE_RF_NAME = "AdminPanelResolveTarget"
ADMIN_LIST_RF_NAME = "AdminPanelAdminList"
BAN_LIST_RF_NAME = "AdminPanelBanList"

PRESENCE_MAP_NAME = "AdminPanelPresence_v5"
TOPIC_NAME = "AdminPanelRelay_v5"
INVENTORY_REQUEST_TOPIC = "AdminPanelInventoryRequest_v1"
INVENTORY_RESPONSE_TOPIC = "AdminPanelInventoryResponse_v1"
ACTION_REQUEST_TOPIC = "AdminPanelActionRequest_v1"
ACTION_RESPONSE_TOPIC = "AdminPanelActionResponse_v1"
SERVER_DATA_RF_NAME = "AdminPanelServerData"
SETTINGS_RF_NAME = "AdminPanelSettings"

STATS_RF_NAME = "AdminPanelStats"
CREDITS_RF_NAME = "AdminPanelCredits"
BAN_REGISTRY_STORE_NAME = "AdminPanelBanRegistry_v1"
CHAT_HISTORY_STORE_NAME = "AdminPanelChatHistory_v1"
CHAT_TOPIC_NAME = "AdminPanelChatRelay_v1"

ANNOUNCE_TOPIC = "AdminPanelAnnouncements_v1"
ANNOUNCE_NOTIFY_REMOTE = "AdminPanelNotify"
ANNOUNCE_VOTE_REMOTE = "AdminPanelVoteAction"
ANNOUNCE_TIMER_STORE_NAME = "AdminPanelAnnounceTimer_v1"
ANNOUNCE_TIMER_STORE_KEY = "CurrentTimer"
ANNOUNCE_VOTE_DURATION = 15

HISTORY_RF_NAME = "AdminPanelHistory"
HISTORY_STORE_NAME = "AdminPanelHistory_v1"
HISTORY_STORE_KEY = "GlobalHistory"
HISTORY_LIMIT = 200

----------------Settings--------------------

local AUTO_OWNER_USER_ID = nil
local AUTO_OWNER_SOURCE = "Unknown"
local AUTO_OWNER_GROUP_ID = nil
local AUTO_OWNER_RESOLVED = false
local AUTO_OWNER_LAST_REFRESH = 0

local function isValidUserId(userId)
	userId = tonumber(userId)
	return userId ~= nil and userId > 0
end

local function safeOwnerUserId(value)
	if type(value) == "number" then
		value = math.floor(value + 0.5)
		if value > 0 then
			return value
		end
		return nil
	end
	if type(value) == "table" then
		return safeOwnerUserId(
			value.Id
				or value.id
				or value.UserId
				or value.userId
				or value.OwnerId
				or value.ownerId
				or value.OwnerUserId
				or value.ownerUserId
				or (value.Owner and (value.Owner.UserId or value.Owner.userId or value.Owner.Id or value.Owner.id))
				or value.Value
				or value.value
		)
	end
	return nil
end

local function refreshAutoOwner()
	local currentClock = os.clock()
	if currentClock - (AUTO_OWNER_LAST_REFRESH or 0) < 0.25 then
		return
	end
	AUTO_OWNER_LAST_REFRESH = currentClock
	AUTO_OWNER_USER_ID = nil
	AUTO_OWNER_SOURCE = "Unknown"
	AUTO_OWNER_GROUP_ID = nil
	AUTO_OWNER_RESOLVED = false

	if game.CreatorType == Enum.CreatorType.User then
		local ownerId = tonumber(game.CreatorId) or 0
		if ownerId > 0 then
			AUTO_OWNER_USER_ID = ownerId
			AUTO_OWNER_SOURCE = "Game owner"
			AUTO_OWNER_RESOLVED = true
		end
		return
	end

	if game.CreatorType == Enum.CreatorType.Group then
		local groupId = tonumber(game.CreatorId) or 0
		if groupId > 0 then
			AUTO_OWNER_GROUP_ID = groupId
			local ok, info = pcall(function()
				return GroupService:GetGroupInfoAsync(groupId)
			end)
			if ok and type(info) == "table" then
				local owner = info.Owner or info.owner or info.GroupOwner or info.groupOwner
				local ownerId = safeOwnerUserId(owner)
				if ownerId then
					AUTO_OWNER_USER_ID = ownerId
					AUTO_OWNER_SOURCE = "Group owner"
					AUTO_OWNER_RESOLVED = true
				end
			end
		end
	end
end

local function isAutoOwnerUserId(userId)
	userId = tonumber(userId)
	if not userId or userId <= 0 then
		return false
	end
	if not AUTO_OWNER_RESOLVED and (os.clock() - (AUTO_OWNER_LAST_REFRESH or 0) > 2) then
		refreshAutoOwner()
	end
	return AUTO_OWNER_USER_ID ~= nil and userId == AUTO_OWNER_USER_ID
end

local function autoOwnerSourceText()
	if AUTO_OWNER_USER_ID and AUTO_OWNER_USER_ID > 0 then
		return AUTO_OWNER_SOURCE
	end
	return ""
end

GROUP_ID = 0

SETTINGS_STORE_NAME = "AdminPanelSettings_v1"
local DEFAULT_SETTINGS = {
	webhookUrl = "",
	webhookEnabled = true,
	animationOn = true,
	openInStart = true,
	rememberLastTab = true,
	streamerMode = false,
	blurBackground = false,
	theme = "Dark",
	customAccent = "00DCFF",
	globalCommands = false,
	autoTranslateChat = false,
	language = "en",
	backgroundStyle = "stripes",
	seenNewsVersion = "",
	panelPin = "",
	setupDone = false,
	saveSidebarOrder = true,
	confirmActions = true,
	backgroundImage = false,
	chatPopups = true,
	animatedBackground = false,
	mobileButton = true,
	glowEffect = true,
	glowStrength = 40,
	sidebarOrder = {},
	sidebarOrderText = "",
	openKeys = { "LeftAlt" },
	lastTab = "home",
}

local RANK_ORDER = {
	Helper = 10,
	Moderator = 50,
	Admin = 80,
	Owner = 100,
}

ZONE_ROLES = {}
ZONE_ROLE_MAX = 10
ZONE_ROLE_TABS = { "actions", "server", "ban", "chat", "announce", "moderation" }

function zoneRankKnown(name)
	name = tostring(name or "")
	return RANK_ORDER[name] ~= nil or ZONE_ROLES[name] ~= nil
end

function zoneRoleAllows(rankName, action)
	local def = ZONE_ROLES[tostring(rankName or "")]
	if not def then
		return nil
	end
	return def.actions and def.actions[action] == true
end

local DEFAULT_ADMIN_RANKS = {
	[0000000000] = "Owner",
}

local DEFAULT_ADMIN_USER_IDS = {
	[0000000000] = true,
}

CREDITS_GROUP_ID = 405991221

SERVER_START_CLOCK = os.clock()

COMMAND_PREFIX = ":"

COMMAND_ALIASES = {
	kick = "Kick",
	["goto"] = "Goto",
	tpto = "TpTo",
	send = "TpTo",
	refresh = "Refresh",
	re2 = "Refresh",
	sit = "Sit",
	undo = "Undo",
	timer = "Timer",
	time = "Time",
	daytime = "Time",
	gravity = "Gravity",
	grav = "Gravity",
	rejoinplayer = "Rejoin",
	reconnect = "Rejoin",
	abusetimer = "Timer",
	to = "Goto",
	tp = "Goto",
	spectate = "Spectate",
	spec = "Spectate",
	unspectate = "Unspectate",
	unspec = "Unspectate",
	kill = "Kill",
	jail = "Jail",
	unjail = "Unjail",
	god = "God",
	ungod = "Ungod",
	warn = "Warn",
	ban = "Ban",
	unban = "Unban",
	mute = "Mute",
	tempmute = "TempMute",
	unmute = "Unmute",
	freeze = "Freeze",
	unfreeze = "Unfreeze",
	heal = "Heal",
	respawn = "Respawn",
	re = "Respawn",
	bring = "Bring",
	speed = "SuperSpeed",
	ws = "SuperSpeed",
	jump = "SuperJump",
	jp = "SuperJump",
	invisible = "Invisible",
	invis = "Invisible",
	visible = "Visible",
	vis = "Visible",
	noclip = "Noclip",
	fly = "Fly",
	unfly = "Unfly",
	note = "AddNote",
	rank = "SetRank",
	unrank = "RemoveRank",
	bringall = "BringAll",
	healall = "HealAll",
	killall = "KillAll",
	respawnall = "RespawnAll",
	announce = "Announce",
	lock = "PanicLock",
	unlock = "PanicUnlock",
	shutdown = "ServerShutdown",
	rejoin = "ServerRejoin",
	ultimatesecurity = "UltimateSecurity",
	usec = "UltimateSecurity",
	unultimatesecurity = "UnUltimateSecurity",
	unusec = "UnUltimateSecurity",
	vmute = "VoiceMute",
	voicemute = "VoiceMute",
	vunmute = "VoiceUnmute",
	voiceunmute = "VoiceUnmute",
	timeout = "Timeout",
	untimeout = "Untimeout",
}

local ACTION_RULES = {
	AddNote = "Helper",
	Note = "Helper",

	Kick = "Moderator",
	Goto = "Moderator",
	TpTo = "Moderator",
	Refresh = "Moderator",
	Sit = "Moderator",
	Undo = "Moderator",
	Timer = "Admin",
	Time = "Admin",
	Gravity = "Moderator",
	Rejoin = "Admin",
	Esp = "Moderator",
	Spectate = "Moderator",
	Unspectate = "Moderator",
	Kill = "Moderator",
	Jail = "Moderator",
	Unjail = "Moderator",
	God = "Admin",
	Ungod = "Admin",
	Warn = "Admin",
	SuperSpeed = "Moderator",
	SuperJump = "Moderator",
	Heal = "Moderator",
	Respawn = "Moderator",
	Bring = "Moderator",
	ServerBring = "Moderator",
	Invisible = "Moderator",
	Visible = "Moderator",
	Noclip = "Moderator",
	Fly = "Moderator",
	Unfly = "Moderator",
	Mute = "Moderator",
	TempMute = "Moderator",
	Unmute = "Moderator",
	VoiceMute = "Moderator",
	VoiceUnmute = "Moderator",

	Freeze = "Admin",
	Unfreeze = "Admin",
	Ban = "Admin",
	Unban = "Admin",
	BringAll = "Admin",
	HealAll = "Admin",
	KillAll = "Admin",
	RespawnAll = "Admin",

	Announce = "Admin",
	StartVote = "Admin",
	StartAbuseTimer = "Admin",
	StopAbuseTimer = "Admin",

	PanicLock = "Admin",
	PanicUnlock = "Admin",

	ServerShutdown = "Owner",
	ShutdownServer = "Owner",
	ServerRejoin = "Owner",
	RejoinServer = "Owner",
	SetRank = "Owner",
	RemoveRank = "Owner",
	UltimateSecurity = "Owner",
	UnUltimateSecurity = "Owner",
	Timeout = "Owner",
	Untimeout = "Owner",

	Age = "Helper",
	BigHead = "Helper",
	Blind = "Moderator",
	Confuse = "Moderator",
	Damage = "Moderator",
	Disco = "Moderator",
	Dwarf = "Helper",
	Explode = "Moderator",
	Fat = "Helper",
	Fire = "Helper",
	Fling = "Moderator",
	ForceField = "Moderator",
	Ghost = "Helper",
	Giant = "Helper",
	Glass = "Helper",
	Grav = "Moderator",
	HideName = "Moderator",
	Launch = "Moderator",
	LoopKill = "Admin",
	NoGravity = "Moderator",
	NormalHead = "Helper",
	NormalSize = "Helper",
	Paint = "Helper",
	Ping = "Helper",
	Punish = "Admin",
	Ragdoll = "Moderator",
	Restart = "Owner",
	ServerRestart = "Owner",
	ServerUpdateAll = "Owner",
	SetHealth = "Moderator",
	ShowName = "Moderator",
	Size = "Moderator",
	SmallHead = "Helper",
	Smoke = "Helper",
	Sparkles = "Helper",
	Spin = "Moderator",
	Squash = "Helper",
	StopLoop = "Moderator",
	Thin = "Helper",
	Trip = "Moderator",
	UnDisco = "Moderator",
	UnFF = "Moderator",
	UnGhost = "Helper",
	Unfire = "Helper",
	Unpunish = "Moderator",
	Unragdoll = "Moderator",
	Unsmoke = "Helper",
	Unsparkles = "Helper",
	Unspin = "Moderator",
}
------------------------------------

local CREDITS_DATA = {
	ok = true,
	groupId = CREDITS_GROUP_ID,
	groupName = "FPS Zone",
	groupImage = ("rbxthumb://type=GroupIcon&id=%d&w=150&h=150"):format(CREDITS_GROUP_ID),
	tabIcon = 76311199408449,
	creator = {
		userId = 7864126209,
		role = "Creator",
		displayName = "Tajim",
	},
	helpers = {
		{
			userId = 9526941658,
			role = "Helper",
			displayName = "Rojin",
		},
		{
			userId = 7075384238,
			role = "Helper",
			displayName = "Hydra_Shahriar9994",
		},
		{
			userId = 7898381722,
			role = "Helper",
			displayName = "imSpidey",
		},
	},
	followText = "Follow us for more panels and updates!",
	groupUrl = ("https://www.roblox.com/groups/%d"):format(CREDITS_GROUP_ID),
}

local NotesStore = DataStoreService:GetDataStore("AdminPanelNotes_v5")
WarningStore = DataStoreService:GetDataStore("AdminPanelWarnings_v1")
ProfileStore = DataStoreService:GetDataStore("AdminPanelProfiles_v1")
local AdminListStore = DataStoreService:GetDataStore("AdminPanelAdmins_v5")
local MuteStore = DataStoreService:GetDataStore("AdminPanelMutes_v5")
local ChatHistoryStore = DataStoreService:GetDataStore(CHAT_HISTORY_STORE_NAME)
local BanRegistryStore = DataStoreService:GetDataStore(BAN_REGISTRY_STORE_NAME)
local SettingsStore = DataStoreService:GetDataStore(SETTINGS_STORE_NAME)
local PresenceMap = MemoryStoreService:GetSortedMap(PRESENCE_MAP_NAME)

local ADMIN_RANKS = {}
local MUTED_USERS = {}
local CHAT_HISTORY = {}
local CHAT_SEEN_IDS = {}
local CHAT_TYPING = {}
CHAT_TYPING_TIMEOUT = 4
local SETTINGS_CACHE = {}
PROFILE_CACHE = {}

local function cloneDefaultSettings()
	local copy = table.clone(DEFAULT_SETTINGS)
	copy.sidebarOrder = {}
	copy.openKeys = table.clone(DEFAULT_SETTINGS.openKeys)
	return copy
end

local function settingsKeyForUserId(userId)
	return ("%s:%s"):format(SETTINGS_STORE_NAME, tostring(tonumber(userId) or 0))
end

VALID_THEME_NAMES = {
	Dark = true,
	Light = true,
	Neon = true,
	Midnight = true,
	Ocean = true,
	Forest = true,
	Crimson = true,
	Purple = true,
	Custom = true,
}
DEFAULT_THEME_NAME = "Dark"

function normalizeThemeName(value)
	local name = tostring(value or "")
	if VALID_THEME_NAMES[name] then
		return name
	end
	local lowered = name:lower()
	for key in pairs(VALID_THEME_NAMES) do
		if key:lower() == lowered then
			return key
		end
	end
	return DEFAULT_THEME_NAME
end


local function normalizeSettingsPayload(data)
	local settings = cloneDefaultSettings()
	if type(data) ~= "table" then
		return settings
	end

	for key, defaultValue in pairs(DEFAULT_SETTINGS) do
		if key ~= "openKeys" and key ~= "sidebarOrder" and data[key] ~= nil then
			if type(defaultValue) == "boolean" then
				settings[key] = data[key] == true
			elseif type(defaultValue) == "number" then
				settings[key] = tonumber(data[key]) or defaultValue
			else
				settings[key] = tostring(data[key] or "")
			end
		end
	end

	if type(data.sidebarOrder) == "table" then
		local order = {}
		for key, value in pairs(data.sidebarOrder) do
			local slot = tonumber(value)
			if type(key) == "string" and slot then
				order[key] = math.clamp(math.floor(slot), 0, 99)
			end
		end
		settings.sidebarOrder = order
	end

	settings.openKeys = cloneDefaultSettings().openKeys

	settings.theme = normalizeThemeName(settings.theme)
	settings.customAccent = normalizeAccentHex(settings.customAccent)
	settings.globalCommands = settings.globalCommands == true
	settings.autoTranslateChat = settings.autoTranslateChat == true
	settings.language = normalizeLanguageCode(settings.language)
	settings.backgroundStyle = normalizeBgStyleCode(settings.backgroundStyle)
	settings.seenNewsVersion = tostring(settings.seenNewsVersion or "")
	settings.glowStrength = 40

	return settings
end

local function getPlayerSettings(player)
	local userId = tonumber(player and player.UserId) or 0
	local cacheKey = tostring(userId)
	if SETTINGS_CACHE[cacheKey] then
		return SETTINGS_CACHE[cacheKey]
	end

	local settings = cloneDefaultSettings()
	if userId > 0 then
		local ok, data = pcall(function()
			return SettingsStore:GetAsync(settingsKeyForUserId(userId))
		end)
		if ok and type(data) == "table" then
			settings = normalizeSettingsPayload(data)
		end
	end

	SETTINGS_CACHE[cacheKey] = settings
	return settings
end






local function applySettingsPatch(settings, payload)
	settings = normalizeSettingsPayload(settings)
	if type(payload) ~= "table" then
		return settings
	end
	local function cleanText(value)
		return (tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", ""))
	end

	if payload.animationOn ~= nil then settings.animationOn = payload.animationOn == true end
	if payload.openInStart ~= nil then settings.openInStart = payload.openInStart == true end
	if payload.rememberLastTab ~= nil then settings.rememberLastTab = payload.rememberLastTab == true end
	if payload.streamerMode ~= nil then settings.streamerMode = payload.streamerMode == true end
	if payload.blurBackground ~= nil then settings.blurBackground = payload.blurBackground == true end
	if payload.theme ~= nil then settings.theme = normalizeThemeName(payload.theme) end
	if payload.customAccent ~= nil then settings.customAccent = normalizeAccentHex(payload.customAccent) end
	if payload.globalCommands ~= nil then settings.globalCommands = payload.globalCommands == true end

	if payload.backgroundStyle ~= nil then settings.backgroundStyle = normalizeBgStyleCode(payload.backgroundStyle) end
	if payload.seenNewsVersion ~= nil then settings.seenNewsVersion = tostring(payload.seenNewsVersion or "") end
	if payload.lastTab ~= nil then settings.lastTab = tostring(payload.lastTab or "home") end
	if payload.setupDone ~= nil then settings.setupDone = payload.setupDone == true end
	if payload.saveSidebarOrder ~= nil then settings.saveSidebarOrder = payload.saveSidebarOrder == true end
	if payload.confirmActions ~= nil then settings.confirmActions = payload.confirmActions == true end
	if payload.chatPopups ~= nil then settings.chatPopups = payload.chatPopups == true end
	if payload.animatedBackground ~= nil then settings.animatedBackground = payload.animatedBackground == true end
	if payload.mobileButton ~= nil then settings.mobileButton = payload.mobileButton == true end
	if payload.glowEffect ~= nil then settings.glowEffect = payload.glowEffect == true end
	if payload.glowStrength ~= nil then settings.glowStrength = 40 end

	if payload.backgroundImage ~= nil then settings.backgroundImage = payload.backgroundImage == true end
	if payload.sidebarOrderText ~= nil then
		local clean = {}
		for part in tostring(payload.sidebarOrderText):gmatch("[^,]+") do
			local name = cleanText(part)
			if name ~= "" and #name <= 32 and not name:match("[^%w_]") then
				table.insert(clean, name)
			end
			if #clean >= 40 then break end
		end
		settings.sidebarOrderText = table.concat(clean, ",")
	end
	if type(payload.sidebarOrder) == "table" then
		local order = {}
		for key, value in pairs(payload.sidebarOrder) do
			local slot = tonumber(value)
			if type(key) == "string" and slot then
				order[key] = math.clamp(math.floor(slot), 0, 99)
			end
		end
		settings.sidebarOrder = order
	end
	if payload.clearPanelPin == true then
		settings.panelPin = ""
	elseif payload.panelPin ~= nil then
		settings.panelPin = cleanText(payload.panelPin)
	end
	return normalizeSettingsPayload(settings)
end

local function savePlayerSettings(player, payload)
	local userId = tonumber(player and player.UserId) or 0
	if userId <= 0 then
		return false, "invalid_user"
	end
	local savedData = nil
	local savedErr = nil
	for attempt = 1, 3 do
		local callOk, result = pcall(function()
			return SettingsStore:UpdateAsync(settingsKeyForUserId(userId), function(oldData)
				return applySettingsPatch(oldData, payload)
			end)
		end)
		if callOk and type(result) == "table" then
			savedData = normalizeSettingsPayload(result)
			break
		end
		savedErr = callOk and "UpdateAsync returned no settings table" or result
		if attempt < 3 then task.wait(attempt * 0.5) end
	end
	if not savedData then
		warn("[Zone Panel] Settings UpdateAsync failed for userId", userId, "-", tostring(savedErr))
		return false, tostring(savedErr or "settings_save_failed")
	end
	SETTINGS_CACHE[tostring(userId)] = savedData
	return true, savedData
end

local function publicSettingsFromTable(settings)
	settings = normalizeSettingsPayload(settings)
	return {
		ok = true,
		animationOn = settings.animationOn ~= false,
		openInStart = settings.openInStart ~= false,
		rememberLastTab = settings.rememberLastTab ~= false,
		streamerMode = settings.streamerMode == true,
		blurBackground = settings.blurBackground == true,
		theme = normalizeThemeName(settings.theme),
		customAccent = normalizeAccentHex(settings.customAccent),
		globalCommands = settings.globalCommands == true,
		autoTranslateChat = false,
		translationAvailable = false,
		language = "en",
		backgroundStyle = normalizeBgStyleCode(settings.backgroundStyle),
		seenNewsVersion = tostring(settings.seenNewsVersion or ""),
		scriptVersion = SCRIPT_VERSION,
		latestVersion = (LATEST_VERSION_AVAILABLE ~= "" and LATEST_VERSION_AVAILABLE or SCRIPT_VERSION),
		updateAvailable = (LATEST_VERSION_AVAILABLE ~= "" and LATEST_VERSION_AVAILABLE ~= SCRIPT_VERSION),
		newsTitle = NEWS_TITLE,
		newsDescription = NEWS_DESCRIPTION,
		newsImageId = NEWS_IMAGE,
		announceEnabled = NEWS_ANNOUNCE,
		announceTitle = NEWS_ANNOUNCE_TITLE,
		announceDescription = NEWS_ANNOUNCE_DESCRIPTION,
		lastTab = tostring(settings.lastTab or "home"),
		webhookEnabled = tostring(WEBHOOK_URL or "") ~= "",
		webhookUrlSet = tostring(WEBHOOK_URL or "") ~= "",
		panelPinSet = tostring(settings.panelPin or "") ~= "",
		setupDone = settings.setupDone == true,
		saveSidebarOrder = settings.saveSidebarOrder ~= false,
		confirmActions = settings.confirmActions ~= false,
		chatPopups = settings.chatPopups ~= false,
		animatedBackground = settings.animatedBackground == true,
		mobileButton = settings.mobileButton ~= false,
		glowEffect = settings.glowEffect ~= false,
		glowStrength = 40,
		backgroundImage = settings.backgroundImage == true,
		sidebarOrder = settings.sidebarOrder or {},
		sidebarOrderText = tostring(settings.sidebarOrderText or ""),
		commandPrefix = tostring(COMMAND_PREFIX or ":"),
		commandAliases = COMMAND_ALIASES,
		commandSelfDefault = COMMAND_SELF_DEFAULT,
		ownerSource = autoOwnerSourceText(),
		openKeys = settings.openKeys or cloneDefaultSettings().openKeys,
		announceDisplaySeconds = ANNOUNCE_DISPLAY_SECONDS,
		announceDisplayMin = ANNOUNCE_DISPLAY_MIN_SECONDS,
		announceDisplayMax = ANNOUNCE_DISPLAY_MAX_SECONDS,
	}
end

local function now()
	return os.time()
end

local function trim(s)
	return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function clampText(value, limit)
	value = tostring(value or "")
	limit = tonumber(limit) or 900
	if #value > limit then
		return value:sub(1, math.max(0, limit - 3)) .. "..."
	end
	return value
end

local function webhookTimestamp()
	return os.date("!%Y-%m-%dT%H:%M:%SZ", now())
end

local function makeWebhookField(name, value, inline)
	return {
		name = tostring(name or "Field"),
		value = clampText(value, 1024),
		inline = inline == true,
	}
end

local function parseIsoTimestamp(isoText)
	isoText = tostring(isoText or "")
	if isoText == "" then
		return nil
	end
	local ok, unix = pcall(function()
		return DateTime.fromIsoDate(isoText).UnixTimestamp
	end)
	if ok and type(unix) == "number" then
		return unix
	end
	local y, mo, d, h, mi, s = isoText:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)Z$")
	if y then
		local ok2, ts = pcall(function()
			return os.time({
				year = tonumber(y),
				month = tonumber(mo),
				day = tonumber(d),
				hour = tonumber(h),
				min = tonumber(mi),
				sec = tonumber(s),
			})
		end)
		if ok2 and type(ts) == "number" then
			return ts
		end
	end
	return nil
end

ZONE_BAN_CACHE = { at = 0, data = nil }
ZONE_BAN_CACHE_SECONDS = 60

function zoneBanRegistryRead(force)
	local age = os.clock() - (tonumber(ZONE_BAN_CACHE.at) or 0)
	if force ~= true and type(ZONE_BAN_CACHE.data) == "table" and age < ZONE_BAN_CACHE_SECONDS then
		return ZONE_BAN_CACHE.data
	end
	local ok, registry = pcall(function()
		return BanRegistryStore:GetAsync("registry")
	end)
	if ok and type(registry) == "table" then
		ZONE_BAN_CACHE.data = registry
		ZONE_BAN_CACHE.at = os.clock()
		return registry
	end
	if type(ZONE_BAN_CACHE.data) == "table" then
		return ZONE_BAN_CACHE.data
	end
	return nil
end

function zoneBanRegistryTouch(userId, payload)
	if type(ZONE_BAN_CACHE.data) ~= "table" then
		return
	end
	userId = tonumber(userId)
	if not userId or userId <= 0 then
		ZONE_BAN_CACHE.at = 0
		return
	end
	ZONE_BAN_CACHE.data[tostring(userId)] = payload
end

function zoneBanActiveFromRegistry(registry, userId)
	if type(registry) ~= "table" then
		return false
	end
	userId = tonumber(userId) or 0
	local raw = registry[tostring(userId)] or registry[userId]
	if type(raw) ~= "table" then
		return false
	end
	local active = raw.Active
	if active == nil then
		active = true
	end
	local bannedAt = tonumber(raw.BannedAt or raw.bannedAt) or 0
	local duration = tonumber(raw.Duration or raw.duration) or -1
	local expiresAt = tonumber(raw.ExpiresAt or raw.expiresAt) or nil
	if not expiresAt and duration and duration > 0 and bannedAt > 0 then
		expiresAt = bannedAt + duration
	end
	if expiresAt and expiresAt <= os.time() then
		return false
	end
	return active == true
end

local function getLatestRobloxBanRecord(userId)
	userId = tonumber(userId)
	if not userId then
		return nil
	end

	local registry = zoneBanRegistryRead(false)
	if type(registry) ~= "table" then
		return nil
	end

	local raw = registry[tostring(userId)] or registry[userId]
	if type(raw) ~= "table" then
		return {
			active = false,
			banned = false,
			reason = "",
			displayReason = "",
			privateReason = "",
			duration = -1,
			startTime = "",
			startTimeUnix = nil,
			expiresAt = nil,
			entries = {},
		}
	end

	local bannedAt = tonumber(raw.BannedAt or raw.bannedAt or raw.Timestamp or raw.timestamp) or 0
	local duration = tonumber(raw.Duration or raw.duration) or -1
	local expiresAt = tonumber(raw.ExpiresAt or raw.expiresAt) or nil
	if not expiresAt and duration and duration > 0 and bannedAt > 0 then
		expiresAt = bannedAt + duration
	end

	local active = raw.Active
	if active == nil then
		active = true
	end
	if expiresAt and expiresAt <= now() then
		active = false
	end

	local reason = tostring(raw.Reason or raw.reason or "")
	local privateReason = tostring(raw.PrivateReason or raw.privateReason or reason)
	local name = tostring(raw.Name or raw.name or ("UserId_" .. tostring(userId)))
	local displayName = tostring(raw.DisplayName or raw.displayName or name)
	local entry = {
		UserId = userId,
		Name = name,
		DisplayName = displayName,
		Reason = reason,
		PrivateReason = privateReason,
		ModeratorUserId = tonumber(raw.ModeratorUserId or raw.moderatorUserId or raw.Moderator or raw.moderator) or 0,
		ModeratorName = tostring(raw.ModeratorName or raw.moderatorName or ""),
		BannedAt = bannedAt,
		Duration = duration,
		ExpiresAt = expiresAt,
		Active = active == true,
	}

	return {
		active = active == true,
		banned = active == true,
		reason = reason,
		displayReason = reason,
		privateReason = privateReason,
		duration = duration,
		startTime = bannedAt > 0 and os.date("!%Y-%m-%dT%H:%M:%SZ", bannedAt) or "",
		startTimeUnix = bannedAt > 0 and bannedAt or nil,
		expiresAt = expiresAt,
		entries = { entry },
	}
end

local function applyRobloxBan(userId, reason, privateReason, durationSeconds)
	userId = tonumber(userId)
	if not userId then
		return false, "invalid_user"
	end

	-- nil or -1 = permanent; otherwise it must be a real number of seconds > 0.
	durationSeconds = tonumber(durationSeconds)
	if durationSeconds == nil or durationSeconds == -1 then
		durationSeconds = -1
	elseif durationSeconds ~= durationSeconds or durationSeconds <= 0 or durationSeconds == math.huge then
		return false, "invalid_duration"
	else
		durationSeconds = math.floor(durationSeconds)
	end

	-- Permanent ban -> official Roblox ban (BanAsync, alt accounts too).
	-- Timed ban -> panel registry only, exactly as before.
	-- If BanAsync is not available (Studio, API off) we fall back to a
	-- normal permanent registry ban and tell the caller.
	local robloxBan = false
	local robloxErr = nil
	if durationSeconds == -1 then
		local okBan, errBan = pcall(function()
			Players:BanAsync({
				UserIds = { userId },
				ApplyToUniverse = true,
				Duration = -1,
				DisplayReason = clampText(reason or "Banned by an admin.", 400),
				PrivateReason = clampText(privateReason or reason or "Banned by an admin.", 1000),
				ExcludeAltAccounts = false,
			})
		end)
		robloxBan = okBan == true
		if not okBan then
			robloxErr = tostring(errBan)
			warn("[Zone Panel] Roblox BanAsync failed, using panel ban instead:", robloxErr)
		end
	else
		-- A timed ban replaces an older permanent Roblox ban.
		pcall(function()
			Players:UnbanAsync({ UserIds = { userId }, ApplyToUniverse = true })
		end)
	end

	local bannedAt = now()
	local displayName = "UserId_" .. tostring(userId)
	local payload = {
		UserId = userId,
		Name = displayName,
		DisplayName = displayName,
		Reason = clampText(reason or "Banned by an admin.", 400),
		PrivateReason = clampText(privateReason or reason or "Banned by an admin.", 1000),
		ModeratorUserId = 0,
		ModeratorName = "System",
		BannedAt = bannedAt,
		Duration = durationSeconds or -1,
		ExpiresAt = (durationSeconds and durationSeconds > 0) and (bannedAt + durationSeconds) or nil,
		Active = true,
		RobloxBan = robloxBan,
	}

	local ok = pcall(function()
		BanRegistryStore:UpdateAsync("registry", function(old)
			old = (type(old) == "table" and old) or {}
			old[tostring(userId)] = payload
			return old
		end)
	end)
	if not ok and not robloxBan then
		return false, "ban_failed"
	end
	zoneBanRegistryTouch(userId, payload)
	return true, nil, robloxBan, (durationSeconds == -1 and not robloxBan) and robloxErr or nil
end

local function applyRobloxUnban(userId)
	userId = tonumber(userId)
	if not userId then
		return false, "invalid_user"
	end

	-- Lift a Roblox ban too (harmless when there is none).
	pcall(function()
		Players:UnbanAsync({
			UserIds = { userId },
			ApplyToUniverse = true,
		})
	end)

	local ok = pcall(function()
		BanRegistryStore:UpdateAsync("registry", function(old)
			old = (type(old) == "table" and old) or {}
			old[tostring(userId)] = nil
			return old
		end)
	end)
	if not ok then
		return false, "unban_failed"
	end
	zoneBanRegistryTouch(userId, nil)
	return true
end

WEBHOOK_QUEUE = {}
WEBHOOK_QUEUE_MAX = 300
WEBHOOK_WAIT_UNTIL = 0
WEBHOOK_FAIL_WARNED = false

local function postWebhook(player, title, color, fields)
	if tostring(WEBHOOK_URL or "") == "" then
		return
	end
	if #WEBHOOK_QUEUE >= WEBHOOK_QUEUE_MAX then
		table.remove(WEBHOOK_QUEUE, 1)
	end
	table.insert(WEBHOOK_QUEUE, {
		title = clampText(title or "Admin action", 250),
		color = tonumber(color) or 5793266,
		fields = fields or {},
		footer = { text = "AdminPanel Logs" },
		timestamp = webhookTimestamp(),
	})
end

function webhookFlushOnce()
	local url = tostring(WEBHOOK_URL or "")
	if url == "" or #WEBHOOK_QUEUE == 0 then
		return
	end
	if os.clock() < WEBHOOK_WAIT_UNTIL then
		return
	end
	local batch = {}
	for index = 1, math.min(10, #WEBHOOK_QUEUE) do
		table.insert(batch, WEBHOOK_QUEUE[index])
	end
	local body = HttpService:JSONEncode({ username = "Zone Panel Logger", embeds = batch })
	while #body > 5500 and #batch > 1 do
		table.remove(batch)
		body = HttpService:JSONEncode({ username = "Zone Panel Logger", embeds = batch })
	end
	local ok, res = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = body,
		})
	end)
	if ok and type(res) == "table" and res.Success == true then
		for _ = 1, #batch do
			table.remove(WEBHOOK_QUEUE, 1)
		end
		WEBHOOK_FAIL_WARNED = false
		return
	end
	if ok and type(res) == "table" and res.StatusCode == 429 then
		local retryAfter = 2
		local decodeOk, decoded = pcall(function()
			return HttpService:JSONDecode(res.Body)
		end)
		if decodeOk and type(decoded) == "table" and tonumber(decoded.retry_after) then
			retryAfter = tonumber(decoded.retry_after)
		end
		WEBHOOK_WAIT_UNTIL = os.clock() + math.clamp(retryAfter, 0.5, 60) + 0.25
		return
	end
	if ok and type(res) == "table" and res.StatusCode >= 400 and res.StatusCode < 500 then
		for _ = 1, #batch do
			table.remove(WEBHOOK_QUEUE, 1)
		end
		warn(("[Zone Panel] Webhook rejected the message (HTTP %s). Check WEBHOOK_URL."):format(tostring(res.StatusCode)))
		return
	end
	WEBHOOK_WAIT_UNTIL = os.clock() + 5
	if not WEBHOOK_FAIL_WARNED then
		WEBHOOK_FAIL_WARNED = true
		warn("[Zone Panel] Webhook send failed, will retry:", ok and tostring(res and res.StatusCode) or tostring(res))
	end
end

task.spawn(function()
	while true do
		task.wait(WEBHOOK_SEND_INTERVAL)
		webhookFlushOnce()
	end
end)

game:BindToClose(function()
	local deadline = os.clock() + 20
	while #WEBHOOK_QUEUE > 0 and os.clock() < deadline and tostring(WEBHOOK_URL or "") ~= "" do
		WEBHOOK_WAIT_UNTIL = math.min(WEBHOOK_WAIT_UNTIL, os.clock() + 2)
		webhookFlushOnce()
		task.wait(1)
	end
end)

local function buildActorText(player)
	if not player then
		return "N/A"
	end
	return string.format("%s (@%s) | UserId: %d", player.DisplayName or player.Name or "N/A", player.Name or "N/A", player.UserId or 0)
end

local function buildTargetText(userId, name, displayName)
	userId = tonumber(userId) or 0
	name = tostring(name or "N/A")
	displayName = tostring(displayName or name)
	return string.format("%s (@%s) | UserId: %d", displayName, name, userId)
end

HISTORY_ENTRIES = {}
HISTORY_DIRTY = false
HISTORY_SAVE_QUEUED = false
HISTORY_DEBUG = false
HISTORY_URGENT_ACTIONS = {
	Ban = true,
	Kick = true,
	KillAll = true,
	PanicLock = true,
	ServerShutdown = true,
	ShutdownServer = true,
	ServerRejoin = true,
	RejoinServer = true,
}

historyStore = DataStoreService:GetDataStore(HISTORY_STORE_NAME)

function historyLoad()
	local ok, data = pcall(function()
		return historyStore:GetAsync(HISTORY_STORE_KEY)
	end)
	if not ok then
		warn("[Zone Panel] history load failed:", data)
		return
	end
	if type(data) == "table" then
		HISTORY_ENTRIES = data
	end
end

function historySanitize(list)
	local out = {}
	for i, e in ipairs(list) do
		if i > HISTORY_LIMIT then
			break
		end
		if type(e) == "table" then
			table.insert(out, {
				id = tostring(e.id or ""),
				action = tostring(e.action or ""),
				moderator = tostring(e.moderator or ""),
				moderatorName = tostring(e.moderatorName or ""),
				moderatorDisplayName = tostring(e.moderatorDisplayName or ""),
				moderatorUserId = tonumber(e.moderatorUserId) or 0,
				target = tostring(e.target or ""),
				targetName = tostring(e.targetName or ""),
				targetDisplayName = tostring(e.targetDisplayName or ""),
				targetUserId = tonumber(e.targetUserId) or 0,
				reason = tostring(e.reason or ""),
				message = e.message ~= nil and tostring(e.message) or nil,
				timestamp = tonumber(e.timestamp) or 0,
				serverPlaceId = tostring(e.serverPlaceId or ""),
				serverJobId = tostring(e.serverJobId or ""),
			})
		end
	end
	return out
end

HISTORY_LAST_SAVE = 0
HISTORY_SAVE_PENDING = false
HISTORY_SAVE_MIN_GAP = 20

function historySave(force)
	if not HISTORY_DIRTY then
		return
	end
	if force ~= true then
		local wait = HISTORY_SAVE_MIN_GAP - (os.clock() - HISTORY_LAST_SAVE)
		if wait > 0 then
			if not HISTORY_SAVE_PENDING then
				HISTORY_SAVE_PENDING = true
				task.delay(wait, function()
					HISTORY_SAVE_PENDING = false
					historySave()
				end)
			end
			return
		end
	end
	HISTORY_LAST_SAVE = os.clock()
	local snapshot = historySanitize(HISTORY_ENTRIES)
	local ok, err = pcall(function()
		historyStore:UpdateAsync(HISTORY_STORE_KEY, function(old)
			if type(old) ~= "table" then
				return snapshot
			end
			local merged = {}
			local seen = {}
			local function push(e)
				if type(e) ~= "table" then
					return
				end
				local key = tostring(e.id or "")
				if key == "" then
					key = tostring(e.timestamp or 0) .. "|" .. tostring(e.action or "")
						.. "|" .. tostring(e.moderatorUserId or 0) .. "|" .. tostring(e.targetUserId or 0)
						.. "|" .. tostring(e.reason or "")
				end
				if seen[key] then
					return
				end
				seen[key] = true
				table.insert(merged, e)
			end
			for _, e in ipairs(snapshot) do push(e) end
			for _, e in ipairs(old) do push(e) end
			table.sort(merged, function(a, b)
				local ta, tb = tonumber(a.timestamp) or 0, tonumber(b.timestamp) or 0
				if ta ~= tb then
					return ta > tb
				end
				return tostring(a.id or "") > tostring(b.id or "")
			end)
			while #merged > HISTORY_LIMIT do
				table.remove(merged)
			end
			return merged
		end)
	end)
	if ok then
		HISTORY_DIRTY = false
		if HISTORY_DEBUG then
			print(("[Zone Panel] history saved: %d entries"):format(#snapshot))
		end
	else
		warn("[Zone Panel] history save FAILED:", err)
		warn("[Zone Panel] If this says 'not allowed', enable Studio Access to API Services in Game Settings > Security.")
	end
end

HISTORY_SEQ = 0

function recordHistory(action, requester, targetUserId, targetName, targetDisplayName, reason, extra)
	HISTORY_SEQ = HISTORY_SEQ + 1
	local entry = {
		id = tostring(game.JobId) .. "-" .. tostring(os.time()) .. "-" .. tostring(HISTORY_SEQ),
		action = tostring(action or "Unknown"),
		moderator = requester and requester.Name or "System",
		moderatorName = requester and requester.Name or "System",
		moderatorDisplayName = requester and (requester.DisplayName or requester.Name) or "System",
		moderatorUserId = requester and requester.UserId or 0,
		target = targetName and tostring(targetName) or "N/A",
		targetName = targetName and tostring(targetName) or "N/A",
		targetDisplayName = targetDisplayName and tostring(targetDisplayName) or (targetName and tostring(targetName) or "N/A"),
		targetUserId = tonumber(targetUserId) or 0,
		reason = reason ~= nil and tostring(reason) or "",
		timestamp = os.time(),
		serverPlaceId = tostring(game.PlaceId),
		serverJobId = tostring(game.JobId),
	}
	if type(extra) == "table" then
		local bits = {}
		for _, field in ipairs(extra) do
			if type(field) == "table" and field.name and field.value ~= nil then
				table.insert(bits, tostring(field.name) .. ": " .. tostring(field.value))
			end
		end
		if #bits > 0 then
			entry.message = table.concat(bits, " | ")
		end
	end

	table.insert(HISTORY_ENTRIES, 1, entry)
	while #HISTORY_ENTRIES > HISTORY_LIMIT do
		table.remove(HISTORY_ENTRIES)
	end
	HISTORY_DIRTY = true

	local urgent = HISTORY_URGENT_ACTIONS[entry.action] == true
	if urgent then
		task.spawn(historySave)
		return
	end

	if not HISTORY_SAVE_QUEUED then
		HISTORY_SAVE_QUEUED = true
		task.delay(3, function()
			HISTORY_SAVE_QUEUED = false
			historySave()
		end)
	end
end

historyLoad()

task.spawn(function()
	while true do
		task.wait(30)
		historySave()
	end
end)

game:BindToClose(function()
	HISTORY_DIRTY = true
	historySave(true)
	task.wait(1)
end)

local function logModerationAction(action, requester, targetUserId, targetName, targetDisplayName, reason, extraFields, color)
	local running = coroutine.running()
	if running and ZONE_LOGGED_CO then
		ZONE_LOGGED_CO[running] = true
	end
	recordHistory(action, requester, targetUserId, targetName, targetDisplayName, reason, extraFields)
	local fields = {
		makeWebhookField("Action", tostring(action or "Unknown"), true),
		makeWebhookField("Moderator", buildActorText(requester), false),
		makeWebhookField("Target", buildTargetText(targetUserId, targetName, targetDisplayName), false),
		makeWebhookField("Reason", reason ~= nil and tostring(reason) or "N/A", false),
		makeWebhookField("Server", string.format("PlaceId: %s | JobId: %s", tostring(game.PlaceId), tostring(game.JobId)), false),
	}
	if type(extraFields) == "table" then
		for _, field in ipairs(extraFields) do
			if type(field) == "table" and field.name and field.value ~= nil then
				table.insert(fields, makeWebhookField(field.name, field.value, field.inline))
			end
		end
	end
	postWebhook(requester, ("Admin action: %s"):format(tostring(action or "Unknown")), color or 5793266, fields)
	if action == "Ban" and requester and zoneBanSpamRecord then
		task.spawn(zoneBanSpamRecord, requester)
	end
end


CHAT_HISTORY_LIMIT = 100

local isAdmin
local RemoteEvent

local function normalizeChatEntry(entry)
	if type(entry) ~= "table" then
		return nil
	end

	local message = clampText(entry.message or entry.text or "", 300)
	if trim(message) == "" then
		return nil
	end

	local id = tostring(entry.id or entry.messageId or "")
	if id == "" then
		id = HttpService:GenerateGUID(false)
	end

	return {
		id = id,
		timestamp = tonumber(entry.timestamp or entry.time or now()) or now(),
		senderUserId = tonumber(entry.senderUserId or entry.userId or 0) or 0,
		senderName = tostring(entry.senderName or entry.name or "Admin"),
		senderDisplayName = tostring(entry.senderDisplayName or entry.displayName or entry.senderName or entry.name or "Admin"),
		message = message,
		jobId = tostring(entry.jobId or game.JobId),
		placeId = tonumber(entry.placeId) or game.PlaceId,
	}
end

local function rememberChatEntry(entry)
	if type(entry) ~= "table" or tostring(entry.id or "") == "" then
		return false
	end
	CHAT_SEEN_IDS[tostring(entry.id)] = true
	return true
end

local function sortChatHistory()
	table.sort(CHAT_HISTORY, function(a, b)
		local ta = tonumber(a and a.timestamp) or 0
		local tb = tonumber(b and b.timestamp) or 0
		if ta == tb then
			return tostring(a and a.id or "") < tostring(b and b.id or "")
		end
		return ta < tb
	end)
	while #CHAT_HISTORY > CHAT_HISTORY_LIMIT do
		local removed = table.remove(CHAT_HISTORY, 1)
		if removed and removed.id then
			CHAT_SEEN_IDS[tostring(removed.id)] = nil
		end
	end
end

local function loadChatHistory()
	local ok, data = pcall(function()
		return ChatHistoryStore:GetAsync("messages")
	end)

	CHAT_HISTORY = {}
	table.clear(CHAT_SEEN_IDS)

	if ok and type(data) == "table" then
		for _, entry in ipairs(data) do
			local normalized = normalizeChatEntry(entry)
			if normalized and not CHAT_SEEN_IDS[normalized.id] then
				table.insert(CHAT_HISTORY, normalized)
				rememberChatEntry(normalized)
			end
		end
	end

	sortChatHistory()
end

local function saveChatHistory()
	sortChatHistory()

	local payload = {}
	for i, entry in ipairs(CHAT_HISTORY) do
		payload[i] = entry
	end

	pcall(function()
		ChatHistoryStore:SetAsync("messages", payload)
	end)
end

local function appendChatEntry(entry, saveHistory)
	entry = normalizeChatEntry(entry)
	if not entry then
		return nil
	end

	if CHAT_SEEN_IDS[entry.id] then
		return entry
	end

	rememberChatEntry(entry)
	table.insert(CHAT_HISTORY, entry)
	sortChatHistory()
	if saveHistory == true then
		saveChatHistory()
	end
	return entry
end

local function getTypingPayload()
	local out = {}
	local current = now()

	for userId, info in pairs(CHAT_TYPING) do
		if type(info) == "table" then
			local expiresAt = tonumber(info.expiresAt) or 0
			if expiresAt > current then
				table.insert(out, {
					userId = tonumber(userId) or tonumber(info.userId) or 0,
					name = tostring(info.name or info.senderName or "Player"),
					displayName = tostring(info.displayName or info.senderDisplayName or info.name or info.senderName or "Player"),
				})
			end
		end
	end

	table.sort(out, function(a, b)
		return tostring(a.displayName) < tostring(b.displayName)
	end)

	return out
end

local function broadcastTypingState()
	local payload = getTypingPayload()
	for _, plr in ipairs(Players:GetPlayers()) do
		if isAdmin(plr) then
			RemoteEvent:FireClient(plr, "ChatTypingState", payload)
		end
	end
end

local function setPlayerTyping(player, typing)
	if not player or not isAdmin(player) then
		return
	end

	local key = tostring(player.UserId or 0)
	if typing == true then
		local existing = CHAT_TYPING[key]
		if existing then
			existing.expiresAt = now() + CHAT_TYPING_TIMEOUT
			existing.name = player.Name
			existing.displayName = player.DisplayName
			return
		end
		CHAT_TYPING[key] = {
			userId = player.UserId,
			name = player.Name,
			displayName = player.DisplayName,
			expiresAt = now() + CHAT_TYPING_TIMEOUT,
		}
		broadcastTypingState()
	else
		if CHAT_TYPING[key] ~= nil then
			CHAT_TYPING[key] = nil
			broadcastTypingState()
		end
	end
end

task.spawn(function()
	while true do
		task.wait(1)
		local changed = false
		local current = now()
		for userId, info in pairs(CHAT_TYPING) do
			if type(info) ~= "table" or tonumber(info.expiresAt) <= current then
				CHAT_TYPING[userId] = nil
				changed = true
			end
		end
		if changed then
			broadcastTypingState()
		end
	end
end)

local function broadcastChatEntry(entry, excludePlayer)
	for _, plr in ipairs(Players:GetPlayers()) do
		if isAdmin(plr) and plr ~= excludePlayer then
			RemoteEvent:FireClient(plr, "ChatMessage", entry)
		end
	end
end

local function sendChatHistory(player)
	if not player or not isAdmin(player) then
		return false
	end

	RemoteEvent:FireClient(player, "ChatHistory", CHAT_HISTORY)
	RemoteEvent:FireClient(player, "ChatTypingState", getTypingPayload())
	return true
end

local function handleChatSend(player, value)
	if not player or not isAdmin(player) then
		return false
	end

	local text = ""
	if type(value) == "table" then
		text = tostring(value.message or value.text or "")
	elseif type(value) == "string" then
		text = value
	end

	text = clampText(trim(text), 300)
	if text == "" then
		return false
	end

	local filteredText = nil
	local filterOk, filterResult = pcall(function()
		return game:GetService("TextService"):FilterStringAsync(text, player.UserId)
	end)
	if filterOk and filterResult then
		local broadcastOk, broadcastText = pcall(function()
			return filterResult:GetNonChatStringForBroadcastAsync()
		end)
		if broadcastOk and type(broadcastText) == "string" then
			filteredText = broadcastText
		end
	end
	if filteredText == nil then
		return false, "Chat filtering is unavailable right now. Please try again."
	end
	if filteredText == "" then
		filteredText = "####"
	end
	text = filteredText

	local providedId = nil
	if type(value) == "table" then
		providedId = tostring(value.id or value.clientId or "")
	end

	local entry = {
		id = providedId ~= "" and providedId or HttpService:GenerateGUID(false),
		timestamp = now(),
		senderUserId = player.UserId,
		senderName = player.Name,
		senderDisplayName = player.DisplayName,
		message = text,
		jobId = game.JobId,
		placeId = game.PlaceId,
	}

	local published = false
	local publishError = nil
	for attempt = 1, 3 do
		local ok, err = pcall(function()
			MessagingService:PublishAsync(CHAT_TOPIC_NAME, entry)
		end)
		if ok then
			published = true
			break
		end
		publishError = err
		if attempt < 3 then
			task.wait(0.6 * attempt)
		end
	end
	if not published then
		warn("[Zone Panel] Global chat publish failed:", publishError)
		return false, "The global chat message could not be delivered. Please try again."
	end

	appendChatEntry(entry, true)
	setPlayerTyping(player, false)
	broadcastChatEntry(entry)
	return true, "Global chat message sent."
end

local function handleChatRequest(player)
	return sendChatHistory(player)
end

loadChatHistory()
local function safeCall(fn)
	local ok, result = pcall(fn)
	if ok then
		return result
	end
	return nil
end

local function ensureRemote(className, name)
	local existing = ReplicatedStorage:FindFirstChild(name)
	if existing then
		return existing
	end
	local obj = Instance.new(className)
	obj.Name = name
	obj.Parent = ReplicatedStorage
	return obj
end

RemoteEvent = ensureRemote("RemoteEvent", REMOTE_EVENT_NAME)
local AuthRF = ensureRemote("RemoteFunction", AUTH_RF_NAME)
local ResolveRF = ensureRemote("RemoteFunction", RESOLVE_RF_NAME)
local AdminListRF = ensureRemote("RemoteFunction", ADMIN_LIST_RF_NAME)
local BanListRF = ensureRemote("RemoteFunction", BAN_LIST_RF_NAME)
local SettingsRF = ensureRemote("RemoteFunction", SETTINGS_RF_NAME)
local StatsRF = ensureRemote("RemoteFunction", STATS_RF_NAME)
AnnounceNotifyRE = ensureRemote("RemoteEvent", ANNOUNCE_NOTIFY_REMOTE)
AnnounceVoteRE = ensureRemote("RemoteEvent", ANNOUNCE_VOTE_REMOTE)
local CreditsRF = ensureRemote("RemoteFunction", CREDITS_RF_NAME)
local ServerDataRF = ensureRemote("RemoteFunction", SERVER_DATA_RF_NAME)
HistoryRF = ensureRemote("RemoteFunction", HISTORY_RF_NAME)

local function syncDefaults()
	for userId, enabled in pairs(DEFAULT_ADMIN_USER_IDS) do
		userId = tonumber(userId)
		if enabled and userId and userId > 0 then
			ADMIN_RANKS[userId] = "Owner"
		end
	end
	for userId, rank in pairs(DEFAULT_ADMIN_RANKS) do
		userId = tonumber(userId)
		if userId and userId > 0 then
			ADMIN_RANKS[userId] = tostring(rank or "Owner")
		end
	end
end

function zoneRolesSanitizeName(name)
	name = tostring(name or "")
	name = string.gsub(name, "[^%w %-_]", "")
	name = string.gsub(name, "^%s+", "")
	name = string.gsub(name, "%s+$", "")
	if #name < 3 or #name > 18 then
		return nil
	end
	if RANK_ORDER[name] then
		return nil
	end
	return name
end

function zoneRolesLevelFor(actions)
	local level = 10
	for actionName, on in pairs(actions or {}) do
		if on == true then
			local req = RANK_ORDER[ACTION_RULES[actionName]] or 0
			if req > level then
				level = req
			end
		end
	end
	if level > 79 then
		level = 79
	end
	return level
end

ZONE_ROLES_LOADED = false

function zoneRolesLoad()
	local ok, data
	for attempt = 1, 3 do
		ok, data = pcall(function()
			return AdminListStore:GetAsync("customroles")
		end)
		if ok then
			break
		end
		task.wait(attempt * 0.6)
	end
	if not ok then
		warn("[Zone Panel] custom ranks load FAILED, keeping existing list.")
		return
	end
	ZONE_ROLES_LOADED = true
	table.clear(ZONE_ROLES)
	if type(data) ~= "table" then
		return
	end
	for _, entry in ipairs(data) do
		if type(entry) == "table" then
			local name = zoneRolesSanitizeName(entry.name)
			if name and not ZONE_ROLES[name] then
				local actions = {}
				if type(entry.actions) == "table" then
					for actionName, on in pairs(entry.actions) do
						if on == true and ACTION_RULES[actionName] and ACTION_RULES[actionName] ~= "Owner" then
							actions[actionName] = true
						end
					end
				end
				local tabs = {}
				if type(entry.tabs) == "table" then
					for _, tabId in ipairs(ZONE_ROLE_TABS) do
						if entry.tabs[tabId] == true then
							tabs[tabId] = true
						end
					end
				end
				ZONE_ROLES[name] = {
					name = name,
					color = tostring(entry.color or "#5aa9ff"),
					actions = actions,
					tabs = tabs,
					level = zoneRolesLevelFor(actions),
				}
			end
		end
	end
end

function zoneRolesSave()
	local payload = {}
	for _, def in pairs(ZONE_ROLES) do
		table.insert(payload, {
			name = def.name,
			color = def.color,
			actions = def.actions,
			tabs = def.tabs,
		})
	end
	local ok, err
	for attempt = 1, 4 do
		ok, err = pcall(function()
			AdminListStore:SetAsync("customroles", payload)
		end)
		if ok then
			return true
		end
		task.wait(attempt * 0.6)
	end
	warn("[Zone Panel] custom ranks save FAILED:", tostring(err))
	warn("[Zone Panel] Enable Game Settings > Security > Enable Studio Access to API Services.")
	return false
end

function zoneRolesPublic()
	local list = {}
	for _, def in pairs(ZONE_ROLES) do
		table.insert(list, {
			name = def.name,
			color = def.color,
			level = def.level,
			actions = def.actions,
			tabs = def.tabs,
		})
	end
	table.sort(list, function(a, b)
		return a.name < b.name
	end)
	return list
end

function zoneRolesBroadcast()
	local list = zoneRolesPublic()
	for _, plr in ipairs(Players:GetPlayers()) do
		if isAdmin(plr) then
			pcall(function()
				RemoteEvent:FireClient(plr, "RolesData", { ok = true, roles = list })
			end)
		end
	end
end

local function loadAdmins()
	table.clear(ADMIN_RANKS)
	syncDefaults()
	local ok, data = pcall(function()
		return AdminListStore:GetAsync("admins")
	end)
	if ok and type(data) == "table" then
		for key, value in pairs(data) do
			local userId = tonumber(key)
			if userId and type(value) == "string" and value ~= "" then
				ADMIN_RANKS[userId] = value
			elseif userId and value == true then
				ADMIN_RANKS[userId] = "Moderator"
			end
		end
	end
end

local function saveAdmins()
	local payload = {}
	for userId, rank in pairs(ADMIN_RANKS) do
		if type(rank) == "string" and rank ~= "" then
			payload[tostring(userId)] = rank
		end
	end
	local ok, err
	for attempt = 1, 4 do
		ok, err = pcall(function()
			AdminListStore:SetAsync("admins", payload)
		end)
		if ok then
			return true
		end
		task.wait(attempt * 0.6)
	end
	warn("[Zone Panel] admin list save FAILED:", tostring(err))
	return false
end

zoneRolesLoad()
loadAdmins()
refreshAutoOwner()

task.spawn(function()
	local attempts = 0
	while not AUTO_OWNER_RESOLVED and attempts < 12 do
		attempts += 1
		task.wait(1)
		refreshAutoOwner()
	end
end)

local function getRank(userId)
	userId = tonumber(userId)
	if isAutoOwnerUserId(userId) then
		return "Owner"
	end
	return ADMIN_RANKS[userId] or nil
end

local function rankValue(rank)
	local name = tostring(rank or "")
	if RANK_ORDER[name] then
		return RANK_ORDER[name]
	end
	local def = ZONE_ROLES[name]
	if def then
		return tonumber(def.level) or 10
	end
	return 0
end

isAdmin = function(player)
	if not player then
		return false
	end
	if isAutoOwnerUserId(player.UserId) then
		return true
	end
	return rankValue(getRank(player.UserId)) > 0 or player:GetAttribute("AdminPanelAccess") == true
end

function zoneActionBlocked(userId, action)
	userId = tonumber(userId) or 0
	if userId <= 0 then
		return false
	end
	if isAutoOwnerUserId(userId) then
		return false
	end
	local rankName = getRank(userId)
	if not rankName then
		return false
	end
	local def = ZONE_ROLES[tostring(rankName)]
	if not def then
		return false
	end
	return not (def.actions and def.actions[action] == true)
end

function zoneRoleTabBlocked(userId, tabId)
	userId = tonumber(userId) or 0
	if userId <= 0 then
		return false
	end
	if isAutoOwnerUserId(userId) then
		return false
	end
	local rankName = getRank(userId)
	if not rankName then
		return false
	end
	local def = ZONE_ROLES[tostring(rankName)]
	if not def then
		return false
	end
	return not (def.tabs and def.tabs[tabId] == true)
end

function zoneCanUseAction(userId, action)
	userId = tonumber(userId) or 0
	if userId <= 0 then
		return false
	end
	if isAutoOwnerUserId(userId) then
		return true
	end
	local rankName = getRank(userId)
	if not rankName then
		local plr = Players:GetPlayerByUserId(userId)
		if plr and plr:GetAttribute("AdminPanelAccess") == true then
			return true
		end
		return false
	end
	local roleAnswer = zoneRoleAllows(rankName, action)
	if roleAnswer ~= nil then
		return roleAnswer
	end
	local requiredRank = ACTION_RULES[action]
	if not requiredRank then
		return true
	end
	return rankValue(rankName) >= rankValue(requiredRank)
end

local function canTarget(requester, targetPlayer, action)
	if not requester or not targetPlayer then
		return false
	end
	if requester:GetAttribute("AdminPanelAccess") ~= true and rankValue(getRank(requester.UserId)) <= 0 then
		return false
	end
	return canTargetUserId(requester.UserId, targetPlayer.UserId, action)
end

PROTECTED_ACTIONS = {
	Ban = true,
	Kick = true,
	Mute = true,
	TempMute = true,
	SetRank = true,
	RemoveRank = true,
}

-- [userId] = true while the player is under Ultimate Security (not saved).
ZONE_ULTIMATE_SECURITY = ZONE_ULTIMATE_SECURITY or {}

RANK_PROTECTED_ACTIONS = {
	VoiceMute = true,
	Ban = true,
	Mute = true,
	TempMute = true,
	SetRank = true,
	RemoveRank = true,
}

function canTargetUserId(requesterUserId, targetUserId, action)
	requesterUserId = tonumber(requesterUserId) or 0
	targetUserId = tonumber(targetUserId) or 0
	if requesterUserId <= 0 or targetUserId <= 0 then
		return false, "invalid_target"
	end
	if requesterUserId == targetUserId then
		if action and PROTECTED_ACTIONS[action] then
			return false, "cannot_target_self"
		end
		return true
	end

	-- The real game owner can never be targeted, by anyone, with anything.
	if isAutoOwnerUserId(targetUserId) then
		return false, "owner_protected"
	end
	-- Owner-rank players can only be targeted by the real game owner.
	if getRank(targetUserId) == "Owner" and not isAutoOwnerUserId(requesterUserId) then
		return false, "owner_rank_protected"
	end
	-- Ultimate Security: only Owners can target this player.
	if ZONE_ULTIMATE_SECURITY[targetUserId] == true and not zoneIsOwnerUser(requesterUserId) then
		return false, "ultimate_protected"
	end

	if action and RANK_PROTECTED_ACTIONS[action] then
		local requesterRank = rankValue(getRank(requesterUserId))
		local targetRank = rankValue(getRank(targetUserId))
		if targetRank > 0 and isAutoOwnerUserId(requesterUserId) ~= true and requesterRank <= targetRank then
			return false, "staff_protected"
		end
	end
	return true
end

PROTECTION_REASONS = {
	owner_protected = true,
	owner_rank_protected = true,
	ultimate_protected = true,
	staff_protected = true,
	cannot_target_self = true,
	timed_out = true,
}

function protectionMessage(reason, targetLabel)
	targetLabel = tostring(targetLabel or "that player")
	if reason == "owner_protected" then
		return "The game owner cannot be targeted."
	end
	if reason == "owner_rank_protected" then
		return ("%s has the Owner rank and cannot be targeted."):format(targetLabel)
	end
	if reason == "ultimate_protected" then
		return ("%s is under Ultimate Security."):format(targetLabel)
	end
	if reason == "timed_out" then
		return "You are timed out and cannot use the panel right now."
	end
	if reason == "staff_protected" then
		return ("%s is staff with an equal or higher rank."):format(targetLabel)
	end
	if reason == "cannot_target_self" then
		return "You cannot use that on yourself."
	end
	return ("You cannot target %s."):format(targetLabel)
end

local function getAdminList()
	local byUserId = {}

	local function upsert(userId, rank, protected, autoOwner, ownerSource)
		userId = tonumber(userId)
		if not userId or userId <= 0 then
			return
		end
		if not zoneRankKnown(rank) then
			return
		end

		local entry = byUserId[userId]
		if not entry then
			entry = {
				UserId = userId,
				Name = safeCall(function()
					return Players:GetNameFromUserIdAsync(userId)
				end) or ("UserId_" .. tostring(userId)),
				Rank = rank,
				Protected = protected == true,
				AutoOwner = autoOwner == true,
				OwnerSource = tostring(ownerSource or ""),
			}
			byUserId[userId] = entry
			return
		end

		if rankValue(rank) > rankValue(entry.Rank) then
			entry.Rank = rank
		end
		if protected == true then
			entry.Protected = true
		end
		if autoOwner == true then
			entry.AutoOwner = true
		end
		if ownerSource and ownerSource ~= "" then
			entry.OwnerSource = tostring(ownerSource)
		end
	end

	for userId, rank in pairs(ADMIN_RANKS) do
		upsert(userId, rank, DEFAULT_ADMIN_RANKS[userId] ~= nil or DEFAULT_ADMIN_USER_IDS[userId] == true, false, "")
	end

	if AUTO_OWNER_USER_ID and AUTO_OWNER_USER_ID > 0 then
		upsert(AUTO_OWNER_USER_ID, "Owner", true, true, autoOwnerSourceText())
	end

	local list = {}
	local banRegistrySnapshot = zoneBanRegistryRead(false)
	for _, entry in pairs(byUserId) do
		local live = Players:GetPlayerByUserId(entry.UserId)
		if live then
			entry.Online = true
			entry.HereNow = true
			entry.PlaceId = game.PlaceId
			entry.JobId = game.JobId
			entry.DisplayName = live.DisplayName
		else
			entry.Online = false
			entry.HereNow = false
			local presence = getPresence(entry.UserId)
			if type(presence) == "table" then
				local seen = tonumber(presence.lastSeen) or 0
				local placeId = tonumber(presence.placeId) or 0
				local jobId = tostring(presence.jobId or "")
				if placeId == game.PlaceId and jobId ~= "" and jobId ~= game.JobId and (now() - seen) < 90 then
					entry.Online = true
					entry.PlaceId = placeId
					entry.JobId = jobId
					entry.DisplayName = tostring(presence.displayName or entry.Name)
				end
			end
		end

		entry.Banned = zoneBanActiveFromRegistry(banRegistrySnapshot, entry.UserId)

		table.insert(list, entry)
	end

	table.sort(list, function(a, b)
		local av = rankValue(a.Rank)
		local bv = rankValue(b.Rank)
		if av == bv then
			return tostring(a.Name) < tostring(b.Name)
		end
		return av > bv
	end)
	return list
end

local function setAdminRank(userId, rank)
	userId = tonumber(userId)
	rank = tostring(rank or "")
	if not userId or userId <= 0 or not zoneRankKnown(rank) then
		return false, "invalid"
	end
	if isAutoOwnerUserId(userId) then
		return false, "protected"
	end
	ADMIN_RANKS[userId] = rank
	saveAdmins()
	local plr = Players:GetPlayerByUserId(userId)
	if plr then
		plr:SetAttribute("AdminPanelAccess", true)
		plr:SetAttribute("AdminPanelRank", rank)
		plr:SetAttribute("AdminPanelAutoOwner", false)
		plr:SetAttribute("AdminPanelOwnerSource", "")
		RemoteEvent:FireClient(plr, "AdminGranted", rank)
	end
	return true
end

local function removeAdminRank(userId)
	userId = tonumber(userId)
	if not userId or userId <= 0 then
		return false, "invalid"
	end
	if DEFAULT_ADMIN_RANKS[userId] or DEFAULT_ADMIN_USER_IDS[userId] or isAutoOwnerUserId(userId) then
		return false, "protected"
	end
	ADMIN_RANKS[userId] = nil
	saveAdmins()
	local plr = Players:GetPlayerByUserId(userId)
	if plr then
		plr:SetAttribute("AdminPanelAccess", false)
		plr:SetAttribute("AdminPanelRank", "")
		plr:SetAttribute("AdminPanelAutoOwner", false)
		plr:SetAttribute("AdminPanelOwnerSource", "")
	end
	return true
end

local function getHumanoid(character)
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRoot(character)
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function setAttrIfMissing(inst, key, value)
	if inst and inst:GetAttribute(key) == nil then
		inst:SetAttribute(key, value)
	end
end

local function popAttr(inst, key)
	if inst and inst:GetAttribute(key) ~= nil then
		local value = inst:GetAttribute(key)
		inst:SetAttribute(key, nil)
		return value
	end
	return nil
end

local function setCharacterVisible(character, visible)
	if not character then return end
	for _, inst in ipairs(character:GetDescendants()) do
		if inst:IsA("BasePart") then
			if visible then
				local original = popAttr(inst, "__AdminOrigTransparency")
				if typeof(original) == "number" then inst.Transparency = original end
			else
				setAttrIfMissing(inst, "__AdminOrigTransparency", inst.Transparency)
				inst.Transparency = 1
			end
		elseif inst:IsA("Decal") or inst:IsA("Texture") then
			if visible then
				local original = popAttr(inst, "__AdminOrigTransparency")
				if typeof(original) == "number" then inst.Transparency = original end
			else
				setAttrIfMissing(inst, "__AdminOrigTransparency", inst.Transparency)
				inst.Transparency = 1
			end
		elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") or inst:IsA("Highlight") then
			if visible then
				local original = popAttr(inst, "__AdminOrigEnabled")
				if typeof(original) == "boolean" then inst.Enabled = original end
			else
				setAttrIfMissing(inst, "__AdminOrigEnabled", inst.Enabled)
				inst.Enabled = false
			end
		elseif inst:IsA("BillboardGui") or inst:IsA("SurfaceGui")
			or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles")
			or inst:IsA("Light") then
			-- Only the ones that were on get switched off and remembered,
			-- so Visible turns back on exactly those and nothing else.
			if visible then
				local original = popAttr(inst, "__AdminOrigEnabled")
				if original == true then inst.Enabled = true end
			elseif inst.Enabled == true then
				setAttrIfMissing(inst, "__AdminOrigEnabled", true)
				inst.Enabled = false
			end
		elseif inst:IsA("Humanoid") then
			if visible then
				local original = popAttr(inst, "__AdminOrigNameDisplay")
				if type(original) == "string" then
					pcall(function()
						inst.DisplayDistanceType = Enum.HumanoidDisplayDistanceType[original]
					end)
				end
			elseif inst.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then
				setAttrIfMissing(inst, "__AdminOrigNameDisplay", inst.DisplayDistanceType.Name)
				inst.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			end
		end
	end
end

local function muteStoreKey(userId)
	return tostring(tonumber(userId) or 0)
end

local function isMuteActive(record)
	if type(record) ~= "table" or record.muted ~= true then
		return false
	end
	local expiresAt = tonumber(record.expiresAt)
	if expiresAt and expiresAt <= now() then
		return false
	end
	return true
end

local function clearMuteRecord(userId)
	pcall(function()
		MuteStore:RemoveAsync(muteStoreKey(userId))
	end)
end

local function getMuteRecord(userId)
	local ok, data = pcall(function()
		return MuteStore:GetAsync(muteStoreKey(userId))
	end)
	if ok and type(data) == "table" then
		if data.muted and data.expiresAt and tonumber(data.expiresAt) <= now() then
			clearMuteRecord(userId)
			return nil
		end
		return data
	end
	return nil
end

local scheduleMuteExpiry

local function loadMuteStateForPlayer(player)
	if not player then
		return
	end
	local record = getMuteRecord(player.UserId)
	if record and isMuteActive(record) then
		MUTED_USERS[player.UserId] = record
		player:SetAttribute("AdminMuted", true)
		player:SetAttribute("AdminMutedUntil", record.expiresAt or nil)
		RemoteEvent:FireClient(player, "AdminMuteState", true, record.expiresAt or nil)
		if record.expiresAt then
			scheduleMuteExpiry(player.UserId, record.expiresAt)
		end
	else
		MUTED_USERS[player.UserId] = nil
		player:SetAttribute("AdminMuted", false)
		player:SetAttribute("AdminMutedUntil", nil)
	end
end

scheduleMuteExpiry = function(userId, expiresAt)
	expiresAt = tonumber(expiresAt)
	if not expiresAt then
		return
	end
	task.delay(math.max(0, expiresAt - now()), function()
		local current = MUTED_USERS[tonumber(userId)]
		if type(current) == "table" and tonumber(current.expiresAt) == expiresAt and isMuteActive(current) == false then
			MUTED_USERS[tonumber(userId)] = nil
			clearMuteRecord(userId)
			local plr = Players:GetPlayerByUserId(tonumber(userId))
			if plr then
				plr:SetAttribute("AdminMuted", false)
				plr:SetAttribute("AdminMutedUntil", nil)
				RemoteEvent:FireClient(plr, "AdminMuteState", false)
			end
		end
	end)
end

local function applyMuteState(targetPlayer, muted, durationSeconds, reason, moderatorUserId)
	if not targetPlayer then
		return false
	end
	local userId = targetPlayer.UserId
	if muted then
		durationSeconds = tonumber(durationSeconds)
		local record = {
			muted = true,
			reason = reason or "",
			moderatorUserId = tonumber(moderatorUserId) or 0,
			timestamp = now(),
			expiresAt = (durationSeconds and durationSeconds > 0) and (now() + durationSeconds) or nil,
		}
		MUTED_USERS[userId] = record
		pcall(function()
			MuteStore:SetAsync(muteStoreKey(userId), record)
		end)
		targetPlayer:SetAttribute("AdminMuted", true)
		targetPlayer:SetAttribute("AdminMutedUntil", record.expiresAt or nil)
		RemoteEvent:FireClient(targetPlayer, "AdminMuteState", true, record.expiresAt or nil)
		if record.expiresAt then
			scheduleMuteExpiry(userId, record.expiresAt)
		end
		return true
	else
		MUTED_USERS[userId] = nil
		clearMuteRecord(userId)
		targetPlayer:SetAttribute("AdminMuted", false)
		targetPlayer:SetAttribute("AdminMutedUntil", nil)
		RemoteEvent:FireClient(targetPlayer, "AdminMuteState", false)
		return true
	end
end

local function muteUserChat(targetPlayer, muted, durationSeconds, reason, moderatorUserId)
	return applyMuteState(targetPlayer, muted, durationSeconds, reason, moderatorUserId)
end

-- Filters text that every player will see (announcements, votes, timers,
-- restart messages). Returns nil + message when Roblox filtering fails so
-- the caller can refuse to send unfiltered text.
function zoneFilterBroadcast(text, fromUserId)
	text = tostring(text or "")
	if text == "" then
		return ""
	end
	local okFilter, filterResult = pcall(function()
		return game:GetService("TextService"):FilterStringAsync(text, tonumber(fromUserId) or 0)
	end)
	if not okFilter or not filterResult then
		return nil, "Text filtering is unavailable right now. Please try again."
	end
	local okText, filtered = pcall(function()
		return filterResult:GetNonChatStringForBroadcastAsync()
	end)
	if not okText or type(filtered) ~= "string" then
		return nil, "Text filtering is unavailable right now. Please try again."
	end
	return filtered
end

function zoneAnnounceSeconds(value)
	local n = tonumber(value)
	if not n or n ~= n or n <= 0 or n == math.huge then
		return ANNOUNCE_DISPLAY_SECONDS
	end
	return math.clamp(math.floor(n), ANNOUNCE_DISPLAY_MIN_SECONDS, ANNOUNCE_DISPLAY_MAX_SECONDS)
end

ZONE_RESTART = ZONE_RESTART or { busy = false }
ZONE_RESTART_DEFAULT = 15
ZONE_UPDATE_TOPIC = "ZonePanelServerUpdate"

function zoneUpdateParse(value)
	local seconds = ZONE_RESTART_DEFAULT
	local text = nil
	local raw = value
	if type(raw) == "table" then
		raw = raw.reason or raw.text or raw.value
	end
	if type(raw) == "number" then
		seconds = raw
	elseif type(raw) == "string" then
		local clean = trim(raw)
		if clean ~= "" then
			local lead = clean:match("^(%d+)%s*(.*)$")
			if lead then
				seconds = tonumber(lead) or ZONE_RESTART_DEFAULT
				local rest = clean:match("^%d+%s*(.*)$")
				if rest and trim(rest) ~= "" then
					text = trim(rest)
				end
			else
				text = clean
			end
		end
	end
	return math.clamp(math.floor(seconds), 0, 300), text
end

function zoneSoftRestart(requester, seconds, customText)
	if ZONE_RESTART.busy then
		return false, "A restart is already running."
	end
	seconds = math.clamp(tonumber(seconds) or ZONE_RESTART_DEFAULT, 0, 300)
	ZONE_RESTART.busy = true

	local text = trim(tostring(customText or ""))
	if text == "" then
		text = "Updating"
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		pcall(function()
			RemoteEvent:FireClient(plr, "ZoneRestartNotice", { message = text, seconds = seconds })
		end)
	end

	task.spawn(function()
		if seconds > 0 then
			task.wait(seconds)
		end

		local players = Players:GetPlayers()
		if #players == 0 then
			ZONE_RESTART.busy = false
			return
		end

		local ok, code = pcall(function()
			return TeleportService:ReserveServer(game.PlaceId)
		end)

		if ok and type(code) == "string" and code ~= "" then
			local opts = Instance.new("TeleportOptions")
			opts.ReservedServerAccessCode = code
			local sent = pcall(function()
				TeleportService:TeleportAsync(game.PlaceId, players, opts)
			end)
			if sent then
				task.wait(6)
			end
		end

		for _, plr in ipairs(Players:GetPlayers()) do
			pcall(function()
				plr:Kick("Server is restarting. Please rejoin.")
			end)
		end
		ZONE_RESTART.busy = false
	end)

	return true
end

ZONE_DISCO = ZONE_DISCO or { active = false }

function zoneDisco(on)
	local Lighting = game:GetService("Lighting")
	if not on then
		ZONE_DISCO.active = false
		if ZONE_DISCO.ambient then
			Lighting.Ambient = ZONE_DISCO.ambient
			Lighting.OutdoorAmbient = ZONE_DISCO.outdoor
			ZONE_DISCO.ambient = nil
			ZONE_DISCO.outdoor = nil
		end
		RemoteEvent:FireAllClients("ZoneDisco", { active = false })
		return true
	end
	if ZONE_DISCO.active then
		return true
	end
	ZONE_DISCO.active = true
	ZONE_DISCO.ambient = Lighting.Ambient
	ZONE_DISCO.outdoor = Lighting.OutdoorAmbient
	RemoteEvent:FireAllClients("ZoneDisco", { active = true })
	task.spawn(function()
		while ZONE_DISCO.active do
			local tint = Color3.fromHSV(math.random(), 0.85, 0.6)
			Lighting.Ambient = tint
			Lighting.OutdoorAmbient = tint
			task.wait(0.45)
		end
	end)
	return true
end



task.spawn(function()
	pcall(function()
		MessagingService:SubscribeAsync(ZONE_UPDATE_TOPIC, function(message)
			local payload = message and message.Data
			if type(payload) ~= "table" then
				return
			end
			if tostring(payload.j or "") == tostring(game.JobId) then
				return
			end
			zoneSoftRestart(nil, tonumber(payload.s) or ZONE_RESTART_DEFAULT, payload.t)
		end)
	end)
end)

local function addNote(userId, note, moderatorUserId)
	note = trim(note)
	if note == "" then
		return false
	end
	local entry = { note = note, moderatorUserId = moderatorUserId or 0, timestamp = now() }
	pcall(function()
		NotesStore:UpdateAsync(tostring(userId), function(old)
			old = (type(old) == "table" and old) or {}
			table.insert(old, 1, entry)
			while #old > 50 do
				table.remove(old)
			end
			return old
		end)
	end)
	return true
end

local function getEntries(store, userId, limit)
	limit = math.clamp(tonumber(limit) or 20, 1, 50)
	local ok, data = pcall(function()
		return store:GetAsync(tostring(userId))
	end)
	if ok and type(data) == "table" then
		local out = {}
		for i = 1, math.min(limit, #data) do
			out[i] = data[i]
		end
		return out
	end
	return {}
end

local function safeNameFromUserId(userId)
	local ok, result = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)
	if ok and type(result) == "string" and result ~= "" then
		return result
	end
	return "UserId_" .. tostring(userId)
end

local function normalizeBanRegistryEntry(entry, userIdFallback)
	if type(entry) ~= "table" then
		return nil
	end
	local userId = tonumber(entry.UserId or entry.userId or userIdFallback)
	if not userId or userId <= 0 then
		return nil
	end
	local bannedAt = tonumber(entry.BannedAt or entry.bannedAt or entry.StartTimeUnix or entry.startTimeUnix or entry.Timestamp or entry.timestamp) or 0
	local duration = tonumber(entry.Duration or entry.duration) or -1
	local expiresAt = tonumber(entry.ExpiresAt or entry.expiresAt) or nil
	if not expiresAt and duration and duration > 0 and bannedAt > 0 then
		expiresAt = bannedAt + duration
	end
	local active = entry.Active
	if active == nil then
		active = true
	end
	if expiresAt and expiresAt <= now() then
		active = false
	end
	return {
		UserId = userId,
		Name = tostring(entry.Name or entry.name or safeNameFromUserId(userId)),
		DisplayName = tostring(entry.DisplayName or entry.displayName or entry.Name or entry.name or safeNameFromUserId(userId)),
		Reason = tostring(entry.Reason or entry.reason or ""),
		PrivateReason = tostring(entry.PrivateReason or entry.privateReason or ""),
		ModeratorUserId = tonumber(entry.ModeratorUserId or entry.moderatorUserId or entry.Moderator or entry.moderator) or 0,
		ModeratorName = tostring(entry.ModeratorName or entry.moderatorName or ""),
		BannedAt = bannedAt,
		Duration = duration,
		ExpiresAt = expiresAt,
		Active = active == true,
		RobloxBan = entry.RobloxBan == true,
		BanType = (entry.RobloxBan == true) and "roblox" or (expiresAt and "timed" or "permanent"),
	}
end

local function getBanRegistry()
	local data = zoneBanRegistryRead(false)
	if type(data) == "table" then
		return data
	end
	return {}
end

local function setBanRegistryEntry(userId, payload)
	userId = tonumber(userId)
	if not userId or userId <= 0 then
		return false
	end
	payload = normalizeBanRegistryEntry(payload, userId)
	if not payload then
		return false
	end
	local ok = pcall(function()
		BanRegistryStore:UpdateAsync("registry", function(old)
			old = (type(old) == "table" and old) or {}
			old[tostring(userId)] = payload
			return old
		end)
	end)
	if ok then
		zoneBanRegistryTouch(userId, payload)
	end
	return ok
end

local function clearBanRegistryEntry(userId)
	userId = tonumber(userId)
	if not userId or userId <= 0 then
		return false
	end
	local ok = pcall(function()
		BanRegistryStore:UpdateAsync("registry", function(old)
			old = (type(old) == "table" and old) or {}
			old[tostring(userId)] = nil
			return old
		end)
	end)
	if ok then
		zoneBanRegistryTouch(userId, nil)
	end
	return ok
end

local function getBanRegistryList()
	local raw = getBanRegistry()
	local out = {}
	local current = now()
	for key, entry in pairs(raw) do
		local normalized = normalizeBanRegistryEntry(entry, key)
		if normalized and normalized.Active and (not normalized.ExpiresAt or normalized.ExpiresAt > current) then
			table.insert(out, normalized)
		end
	end
	table.sort(out, function(a, b)
		local at = tonumber(a.BannedAt) or 0
		local bt = tonumber(b.BannedAt) or 0
		if at == bt then
			return tostring(a.DisplayName or a.Name or "") < tostring(b.DisplayName or b.Name or "")
		end
		return at > bt
	end)
	return out
end

local function safeUserIdFromName(name)
	local ok, result = pcall(function()
		return Players:GetUserIdFromNameAsync(name)
	end)
	if ok and type(result) == "number" then
		return result
	end
	return nil
end

local function parseJoinDate(accountAge)
	accountAge = tonumber(accountAge) or 0
	return os.date("%Y-%m-%d", now() - (accountAge * 86400))
end

local function getClientInfo(player)
	return {
		Ping = player:GetAttribute("AdminClientPing"),
		FPS = player:GetAttribute("AdminClientFPS"),
		DeviceType = player:GetAttribute("AdminClientDeviceType"),
		ViewportX = player:GetAttribute("AdminClientViewportX"),
		ViewportY = player:GetAttribute("AdminClientViewportY"),
		Platform = player:GetAttribute("AdminClientPlatform"),
	}
end

local function serverTypeText()
	if game.PrivateServerId ~= "" then
		if tonumber(game.PrivateServerOwnerId) and tonumber(game.PrivateServerOwnerId) ~= 0 then
			return "Private Server"
		end
		return "Reserved Server"
	end
	return "Public Server"
end

local function serverHealthText(playerCount, maxPlayers)
	playerCount = tonumber(playerCount) or 0
	maxPlayers = tonumber(maxPlayers) or 0
	if maxPlayers <= 0 then
		return "Unknown"
	end
	local ratio = playerCount / maxPlayers
	if ratio >= 0.95 then
		return "Full"
	elseif ratio >= 0.75 then
		return "Busy"
	elseif ratio >= 0.35 then
		return "Active"
	end
	return "Light"
end

local function safeCountryRegionForPlayer(player)
	if not player then
		return nil
	end
	local ok, result = pcall(function()
		return LocalizationService:GetCountryRegionForPlayerAsync(player)
	end)
	if ok and type(result) == "string" and result ~= "" then
		return result
	end
	return nil
end

local function getServerData(requester)
	local players = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		table.insert(players, {
			UserId = plr.UserId,
			Name = plr.Name,
			DisplayName = plr.DisplayName,
			AccountAge = plr.AccountAge,
			CountryRegion = safeCountryRegionForPlayer(plr),
			Rank = getRank(plr.UserId) or "Player",
			IsLocal = requester and plr.UserId == requester.UserId or false,
		})
	end
	table.sort(players, function(a, b)
		local ar = rankValue(a.Rank)
		local br = rankValue(b.Rank)
		if ar == br then
			return tostring(a.Name) < tostring(b.Name)
		end
		return ar > br
	end)
	local playerCount = #players
	local maxPlayers = Players.MaxPlayers
	local uptime = math.floor(os.clock() - SERVER_START_CLOCK)
	local health = serverHealthText(playerCount, maxPlayers)
	return {
		ok = true,
		PlaceId = game.PlaceId,
		JobId = game.JobId,
		PlaceName = game.Name,
		PlayerCount = playerCount,
		MaxPlayers = maxPlayers,
		Uptime = uptime,
		SessionAgeText = string.format("%02d:%02d:%02d", math.floor(uptime / 3600), math.floor((uptime % 3600) / 60), math.floor(uptime % 60)),
		ServerType = serverTypeText(),
		HealthState = health,
		SummaryText = string.format("%s • %d/%d players • %s", serverTypeText(), playerCount, maxPlayers, health),
		PrivateServerId = game.PrivateServerId,
		PrivateServerOwnerId = game.PrivateServerOwnerId,
		IsPrivateServer = game.PrivateServerId ~= "",
		IsReservedServer = game.PrivateServerId ~= "" and (tonumber(game.PrivateServerOwnerId) or 0) == 0,
		RequestingPlayerRegion = requester and safeCountryRegionForPlayer(requester) or nil,
		Players = players,
	}
end

local function collectInventorySnapshot(player)
	local function scanContainer(container, location)
		local items = {}
		if not container then
			return items
		end
		for _, child in ipairs(container:GetChildren()) do
			if child:IsA("Tool") then
				table.insert(items, {
					name = child.Name,
					className = child.ClassName,
					location = location,
					parent = child.Parent and child.Parent.Name or location,
				})
			end
		end
		table.sort(items, function(a, b)
			return tostring(a.name) < tostring(b.name)
		end)
		return items
	end

	local backpack = scanContainer(player and player:FindFirstChildOfClass("Backpack"), "Backpack")
	local character = scanContainer(player and player.Character, "Character")
	return {
		backpack = backpack,
		character = character,
		total = #backpack + #character,
	}
end

local function formatInventoryText(snapshot)
	if type(snapshot) ~= "table" then
		return "Inventory unavailable."
	end
	local lines = {}
	local total = tonumber(snapshot.total) or ((snapshot.backpack and #snapshot.backpack or 0) + (snapshot.character and #snapshot.character or 0))
	table.insert(lines, ("Inventory items: %d"):format(total))
	local function addSection(label, list)
		table.insert(lines, "")
		table.insert(lines, label .. ":")
		if type(list) ~= "table" or #list == 0 then
			table.insert(lines, "  (empty)")
			return
		end
		for _, item in ipairs(list) do
			local name = tostring(item.name or item.Name or "Unknown")
			local className = tostring(item.className or item.ClassName or "Item")
			table.insert(lines, ("  - %s [%s]"):format(name, className))
		end
	end
	addSection("Backpack", snapshot.backpack or snapshot.Backpack or {})
	addSection("Character", snapshot.character or snapshot.Character or {})
	return table.concat(lines, "\n")
end

local function presenceKey(userId)
	return tostring(tonumber(userId) or 0)
end

local function upsertPresence(player)
	local info = getClientInfo(player)
	local payload = {
		userId = player.UserId,
		name = player.Name,
		displayName = player.DisplayName,
		placeId = game.PlaceId,
		jobId = game.JobId,
		lastSeen = now(),
		accountAge = player.AccountAge,
		joinDate = parseJoinDate(player.AccountAge),
		groupRank = (GROUP_ID ~= 0) and player:GetRankInGroup(GROUP_ID) or nil,
		groupRole = (GROUP_ID ~= 0) and player:GetRoleInGroup(GROUP_ID) or nil,
		client = info,
	}
	pcall(function()
		PresenceMap:SetAsync(presenceKey(player.UserId), payload, 1200)
	end)
end

function saveProfileSnapshot(player)
	if not player then
		return
	end
	local userId = tonumber(player.UserId) or 0
	if userId <= 0 then
		return
	end
	local payload = {
		userId = userId,
		name = player.Name,
		displayName = player.DisplayName,
		accountAge = player.AccountAge,
		joinDate = parseJoinDate(player.AccountAge),
		savedAt = now(),
	}
	PROFILE_CACHE[userId] = payload
	task.spawn(function()
		pcall(function()
			ProfileStore:SetAsync(tostring(userId), payload)
		end)
	end)
end

function getProfileSnapshot(userId)
	userId = tonumber(userId) or 0
	if userId <= 0 then
		return nil
	end
	if PROFILE_CACHE[userId] then
		return PROFILE_CACHE[userId]
	end
	local data = nil
	local ok = pcall(function()
		data = ProfileStore:GetAsync(tostring(userId))
	end)
	if ok and type(data) == "table" then
		PROFILE_CACHE[userId] = data
		return data
	end
	return nil
end

function getPresence(userId)
	local ok, data = pcall(function()
		return PresenceMap:GetAsync(presenceKey(userId))
	end)
	if ok and type(data) == "table" then
		return data
	end
	return nil
end

function clearJailFor(userId)
	userId = tonumber(userId) or 0
	local jailState = ZONE_JAIL_STATE and ZONE_JAIL_STATE[userId] or nil
	local savedModel = jailState and jailState.model or nil
	if jailState then
		for _, key in ipairs({ "guardConn", "characterConn" }) do
			local conn = jailState[key]
			if conn then
				pcall(function() conn:Disconnect() end)
				jailState[key] = nil
			end
		end
		if savedModel and savedModel.Parent then
			savedModel:Destroy()
		end
		if ZONE_JAIL_STATE then
			ZONE_JAIL_STATE[userId] = nil
		end
	end
	local folder = workspace:FindFirstChild("AdminPanelJails")
	local cell = folder and folder:FindFirstChild("Jail_" .. tostring(userId)) or nil
	if cell and cell ~= savedModel then
		cell:Destroy()
	end
end

local function deletePresence(userId)
	pcall(function()
		PresenceMap:RemoveAsync(presenceKey(userId))
	end)
end

local function resolveUserId(query)
	if type(query) == "number" then
		return query
	end
	if type(query) == "string" then
		local trimmed = trim(query)
		if trimmed == "" then
			return nil
		end
		local n = tonumber(trimmed)
		if n then
			return n
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if string.lower(plr.Name) == string.lower(trimmed) or string.lower(plr.DisplayName) == string.lower(trimmed) then
				return plr.UserId
			end
		end
		local uid = safeUserIdFromName(trimmed)
		if uid then
			return uid
		end
	elseif type(query) == "table" then
		local uid = tonumber(query.UserId or query.userId or query.targetUserId or query.resolvedTargetUserId or query.targetId)
		if uid then
			return uid
		end
		local name = query.Name or query.name or query.DisplayName or query.displayName or query.targetQuery or query.query
		if name then
			return resolveUserId(name)
		end
	end
	return nil
end

local function resolveCurrentPlayer(userId)
	userId = tonumber(userId)
	if not userId then
		return nil
	end
	return Players:GetPlayerByUserId(userId)
end

local function buildTargetRecord(query)
	local userId = resolveUserId(query)
	if not userId then
		return {
			ok = false,
			error = "not_found",
			message = "Target not found.",
		}
	end

	local live = resolveCurrentPlayer(userId)
	local presence = getPresence(userId)
	local profile = getProfileSnapshot(userId)
	local name = live and live.Name or (presence and presence.name) or (profile and profile.name) or safeNameFromUserId(userId)
	local displayName = live and live.DisplayName or (presence and presence.displayName) or (profile and profile.displayName) or name
	local accountAge = live and live.AccountAge or (presence and presence.accountAge) or (profile and profile.accountAge) or nil
	local joinDate = accountAge and parseJoinDate(accountAge) or (presence and presence.joinDate) or (profile and profile.joinDate) or nil
	local groupRank = nil
	local groupRole = nil
	if GROUP_ID ~= 0 then
		if live then
			groupRank = live:GetRankInGroup(GROUP_ID)
			groupRole = live:GetRoleInGroup(GROUP_ID)
		elseif presence then
			groupRank = presence.groupRank
			groupRole = presence.groupRole
		end
	end

	local client = nil
	if live then
		client = getClientInfo(live)
	elseif presence then
		client = presence.client
	end

	local notes = getEntries(NotesStore, userId, 30)
	local ban = getLatestRobloxBanRecord(userId)
	local muteRecord = MUTED_USERS[userId]
	if not muteRecord then
		muteRecord = getMuteRecord(userId)
		if muteRecord and isMuteActive(muteRecord) then
			MUTED_USERS[userId] = muteRecord
		end
	end
	local liveMuted = live and live:GetAttribute("AdminMuted") == true
	local muted = liveMuted or isMuteActive(muteRecord)

	return {
		ok = true,
		UserId = userId,
		Name = name,
		DisplayName = displayName,
		Online = live ~= nil,
		InCurrentServer = live ~= nil,
		Source = live and "server" or (presence and "presence") or "global",
		AccountAge = accountAge,
		JoinDate = joinDate,
		PlaceId = (presence and presence.placeId) or (live and game.PlaceId) or nil,
		JobId = (presence and presence.jobId) or (live and game.JobId) or nil,
		GroupRank = groupRank,
		GroupRole = groupRole,
		Rank = getRank(userId) or "",
		AdminPanelRank = getRank(userId) or "",
		AutoOwner = isAutoOwnerUserId(userId),
		OwnerSource = isAutoOwnerUserId(userId) and autoOwnerSourceText() or "",
		AdminPanelAccess = isAdmin(live or { UserId = userId, GetAttribute = function() return false end }),
		NotesCount = #notes,
		Notes = notes,
		Ban = ban,
		Banned = ban ~= nil and ban.active == true,
		Muted = muted,
		MuteExpiresAt = muted and tonumber((muteRecord and muteRecord.expiresAt) or (live and live:GetAttribute("AdminMutedUntil")) or nil) or nil,
		ClientInfo = client or {},
		CurrentServer = {
			PlaceId = game.PlaceId,
			JobId = game.JobId,
		},
	}
end

function queuePendingWarning(userId, reason, moderatorUserId)
	userId = tonumber(userId) or 0
	if userId <= 0 then
		return false
	end
	local entry = {
		reason = tostring(reason or ""),
		moderatorUserId = tonumber(moderatorUserId) or 0,
		timestamp = now(),
	}
	local ok = pcall(function()
		WarningStore:UpdateAsync(tostring(userId), function(old)
			old = (type(old) == "table" and old) or {}
			table.insert(old, entry)
			while #old > 10 do
				table.remove(old, 1)
			end
			return old
		end)
	end)
	return ok
end

function deliverPendingWarnings(player)
	if not player then
		return
	end
	local userId = player.UserId
	-- Wait until the player is past the loading screen, then read the queue.
	-- Entries are removed only after they were actually shown, so a player
	-- who leaves early still gets them on the next join.
	task.delay(PENDING_WARNING_DELAY_SECONDS, function()
		if not player.Parent then
			return
		end
		local pending = nil
		local ok = pcall(function()
			pending = WarningStore:GetAsync(tostring(userId))
		end)
		if not ok or type(pending) ~= "table" or #pending == 0 then
			return
		end
		local delivered = {}
		for _, entry in ipairs(pending) do
			if not player.Parent then
				break
			end
			if type(entry) == "table" then
				if tostring(entry.reason or "") ~= "" then
					RemoteEvent:FireClient(player, "AdminWarning", {
						reason = tostring(entry.reason),
					})
					task.wait(1)
				end
				delivered[tostring(entry.timestamp or "") .. "|" .. tostring(entry.reason or "")] = true
			end
		end
		if next(delivered) == nil then
			return
		end
		pcall(function()
			WarningStore:UpdateAsync(tostring(userId), function(old)
				if type(old) ~= "table" then
					return nil
				end
				local keep = {}
				for _, entry in ipairs(old) do
					local key = type(entry) == "table" and (tostring(entry.timestamp or "") .. "|" .. tostring(entry.reason or "")) or ""
					if not delivered[key] then
						table.insert(keep, entry)
					end
				end
				return keep
			end)
		end)
	end)
end

function buildPresenceBatch(userIds)
	local result = {}
	if type(userIds) ~= "table" then
		return { ok = true, states = result }
	end
	local banRegistrySnapshot = zoneBanRegistryRead(false)
	for _, raw in ipairs(userIds) do
		local userId = tonumber(raw) or 0
		if userId > 0 then
			local state = "offline"
			local jobId = nil
			if Players:GetPlayerByUserId(userId) then
				state = "here"
				jobId = game.JobId
			else
				local presence = getPresence(userId)
				if type(presence) == "table" then
					local seen = tonumber(presence.lastSeen) or 0
					local placeId = tonumber(presence.placeId) or 0
					local pJob = tostring(presence.jobId or "")
					if placeId == game.PlaceId and pJob ~= "" and (now() - seen) < 90 then
						state = "elsewhere"
						jobId = pJob
					end
				end
			end
			if zoneBanActiveFromRegistry(banRegistrySnapshot, userId) then
				state = "banned"
			end
			result[tostring(userId)] = { state = state, jobId = jobId }
		end
	end
	return { ok = true, states = result }
end

local function pendingInventoryKey(requestId)
	return tostring(requestId or "")
end

local PENDING_INVENTORY_REQUESTS = {}
local PENDING_ACTION_REQUESTS = {}

local actionOnPlayer

local function clearPendingInventoryRequest(requestId)
	PENDING_INVENTORY_REQUESTS[pendingInventoryKey(requestId)] = nil
end

local function pendingActionKey(requestId)
	return tostring(requestId or "")
end

local function clearPendingActionRequest(requestId)
	PENDING_ACTION_REQUESTS[pendingActionKey(requestId)] = nil
end

local function fireInventoryResultToRequester(payload)
	if type(payload) ~= "table" then
		return
	end
	local requesterJobId = tostring(payload.requesterJobId or "")
	if requesterJobId ~= tostring(game.JobId) then
		return
	end
	local requesterUserId = tonumber(payload.requesterUserId)
	if not requesterUserId then
		return
	end
	local expectedUserId = PENDING_INVENTORY_REQUESTS[pendingInventoryKey(payload.requestId)]
	if expectedUserId and expectedUserId ~= requesterUserId then
		return
	end
	local requester = Players:GetPlayerByUserId(requesterUserId)
	if requester then
		RemoteEvent:FireClient(requester, "InventoryResult", payload)
	end
	clearPendingInventoryRequest(payload.requestId)
end

local function fireActionResultToRequester(payload)
	if type(payload) ~= "table" then
		return
	end
	local requesterJobId = tostring(payload.requesterJobId or "")
	if requesterJobId ~= tostring(game.JobId) then
		return
	end
	local requesterUserId = tonumber(payload.requesterUserId)
	if not requesterUserId then
		return
	end
	local expectedUserId = PENDING_ACTION_REQUESTS[pendingActionKey(payload.requestId)]
	if expectedUserId and expectedUserId ~= requesterUserId then
		return
	end
	local requester = Players:GetPlayerByUserId(requesterUserId)
	if requester then
		RemoteEvent:FireClient(requester, "ActionResult", payload)
	end
	clearPendingActionRequest(payload.requestId)
end

local function respondToInventoryRequest(payload)
	if type(payload) ~= "table" then
		return
	end
	local targetUserId = tonumber(payload.targetUserId)
	if not targetUserId then
		return
	end
	local targetPlayer = Players:GetPlayerByUserId(targetUserId)
	if not targetPlayer then
		return
	end
	local snapshot = collectInventorySnapshot(targetPlayer)
	local response = {
		ok = true,
		requestId = payload.requestId,
		requesterUserId = tonumber(payload.requesterUserId) or 0,
		requesterJobId = tostring(payload.requesterJobId or ""),
		requesterPlaceId = tonumber(payload.requesterPlaceId) or 0,
		targetUserId = targetPlayer.UserId,
		targetName = targetPlayer.Name,
		targetDisplayName = targetPlayer.DisplayName,
		sourcePlaceId = game.PlaceId,
		sourceJobId = game.JobId,
		source = "server",
		inventory = snapshot,
	}
	pcall(function()
		MessagingService:PublishAsync(INVENTORY_RESPONSE_TOPIC, response)
	end)
end

local function publishInventoryTimeout(requester, requestId, targetUserId, message, errorCode)
	task.delay(8, function()
		if PENDING_INVENTORY_REQUESTS[pendingInventoryKey(requestId)] ~= requester.UserId then
			return
		end
		clearPendingInventoryRequest(requestId)
		if requester and requester.Parent == Players then
			RemoteEvent:FireClient(requester, "InventoryResult", {
				ok = false,
				requestId = requestId,
				requesterUserId = requester.UserId,
				targetUserId = targetUserId,
				message = message or "Inventory request timed out.",
				error = errorCode or "timeout",
			})
		end
	end)
end

local function publishActionTimeout(requester, requestId, targetUserId, actionName, message, errorCode)
	task.delay(8, function()
		if PENDING_ACTION_REQUESTS[pendingActionKey(requestId)] ~= requester.UserId then
			return
		end
		clearPendingActionRequest(requestId)
		if requester and requester.Parent == Players then
			RemoteEvent:FireClient(requester, "ActionResult", {
				ok = false,
				requestId = requestId,
				requesterUserId = requester.UserId,
				targetUserId = targetUserId,
				action = actionName,
				message = message or "Remote action request timed out.",
				error = errorCode or "timeout",
			})
		end
	end)
end

local function buildRequesterStub(payload)
	local requesterUserId = tonumber(payload and payload.requesterUserId) or 0
	local requesterName = safeNameFromUserId(requesterUserId)
	return {
		UserId = requesterUserId,
		Name = requesterName,
		DisplayName = requesterName,
	}
end

local function canRelayPlayerAction(action)
	return action == "Kick"
		or action == "Bring"
		or action == "ServerBring"
		or action == "Heal"
		or action == "Respawn"
		or action == "Invisible"
		or action == "Visible"
		or action == "Noclip"
		or action == "Fly"
		or action == "Unfly"
		or action == "Mute"
		or action == "TempMute"
		or action == "Freeze"
		or action == "Unfreeze"
		or action == "Ban"
end

local function requestInventoryForRequester(requester, targetUserId, presence)
	local requestId = HttpService:GenerateGUID(false)
	PENDING_INVENTORY_REQUESTS[pendingInventoryKey(requestId)] = requester.UserId
	local directTarget = Players:GetPlayerByUserId(targetUserId)
	if directTarget then
		if not canTarget(requester, directTarget) then
			clearPendingInventoryRequest(requestId)
			RemoteEvent:FireClient(requester, "InventoryResult", {
				ok = false,
				requestId = requestId,
				requesterUserId = requester.UserId,
				targetUserId = targetUserId,
				message = "You cannot inspect that player.",
				error = "forbidden",
			})
			return false
		end
		local snapshot = collectInventorySnapshot(directTarget)
		RemoteEvent:FireClient(requester, "InventoryResult", {
			ok = true,
			requestId = requestId,
			requesterUserId = requester.UserId,
			requesterJobId = game.JobId,
			requesterPlaceId = game.PlaceId,
			targetUserId = directTarget.UserId,
			targetName = directTarget.Name,
			targetDisplayName = directTarget.DisplayName,
			sourcePlaceId = game.PlaceId,
			sourceJobId = game.JobId,
			source = "current_server",
			inventory = snapshot,
		})
		clearPendingInventoryRequest(requestId)
		return true
	end
	if type(presence) ~= "table" then
		local inferredPresence = getPresence(targetUserId)
		if type(inferredPresence) == "table" then
			presence = inferredPresence
		end
	end
	if type(presence) ~= "table" then
		clearPendingInventoryRequest(requestId)
		RemoteEvent:FireClient(requester, "InventoryResult", {
			ok = false,
			requestId = requestId,
			requesterUserId = requester.UserId,
			targetUserId = targetUserId,
			message = "Inventory unavailable for that player.",
			error = "not_available",
		})
		return false
	end
	local payload = {
		requestId = requestId,
		requesterUserId = requester.UserId,
		requesterJobId = game.JobId,
		requesterPlaceId = game.PlaceId,
		targetUserId = targetUserId,
		targetPlaceId = presence.placeId,
		targetJobId = presence.jobId,
		timestamp = now(),
	}
	pcall(function()
		MessagingService:PublishAsync(INVENTORY_REQUEST_TOPIC, payload)
	end)
	publishInventoryTimeout(requester, requestId, targetUserId, "Inventory request timed out.", "timeout")
	return true
end

local function requestRemoteAction(requester, action, targetQuery, value, targetUserId, presence)
	local requestId = HttpService:GenerateGUID(false)
	PENDING_ACTION_REQUESTS[pendingActionKey(requestId)] = requester.UserId
	local payload = {
		requestId = requestId,
		requesterUserId = requester.UserId,
		requesterName = requester.Name,
		requesterDisplayName = requester.DisplayName,
		requesterRank = getRank(requester.UserId),
		requesterJobId = game.JobId,
		requesterPlaceId = game.PlaceId,
		targetUserId = targetUserId,
		targetQuery = targetQuery,
		value = value,
		action = action,
		targetPlaceId = presence and presence.placeId or nil,
		targetJobId = presence and presence.jobId or nil,
		timestamp = now(),
	}
	pcall(function()
		MessagingService:PublishAsync(ACTION_REQUEST_TOPIC, payload)
	end)
	publishActionTimeout(requester, requestId, targetUserId, action, "Remote action request timed out.", "timeout")
	return true
end

local function publishActionResponse(payload)
	pcall(function()
		MessagingService:PublishAsync(ACTION_RESPONSE_TOPIC, payload)
	end)
end

local function bringTargetToRequesterServer(targetPlayer, requesterPlaceId, requesterJobId)
	requesterPlaceId = tonumber(requesterPlaceId) or game.PlaceId
	requesterJobId = tostring(requesterJobId or "")
	if not targetPlayer or requesterPlaceId ~= game.PlaceId or requesterJobId == "" then
		return false, "missing_request"
	end
	local ok = pcall(function()
		TeleportService:TeleportToPlaceInstance(requesterPlaceId, requesterJobId, targetPlayer)
	end)
	if ok then
		return true, "teleported"
	end
	return false, "teleport_failed"
end

local function handleRemoteActionRequest(payload)
	if type(payload) ~= "table" then
		return
	end
	local targetUserId = tonumber(payload.targetUserId)
	if not targetUserId then
		return
	end
	if payload.targetJobId and tostring(payload.targetJobId) ~= "" and tostring(payload.targetJobId) ~= tostring(game.JobId) then
		return
	end
	local targetPlayer = Players:GetPlayerByUserId(targetUserId)
	local requester = buildRequesterStub(payload)
	local action = tostring(payload.action or "")
	local resultOk, resultMessage = false, "unsupported"
	if action == "Bring" or action == "ServerBring" then
		if not targetPlayer then
			return
		end
		resultOk, resultMessage = bringTargetToRequesterServer(targetPlayer, payload.requesterPlaceId, payload.requesterJobId)
	elseif action == "Ban" or action == "Unban" then
		resultOk, resultMessage = actionOnPlayer(action, requester, targetPlayer, payload.value)
	elseif action == "Mute" or action == "TempMute" or action == "Kick" or action == "Heal" or action == "Respawn" or action == "Invisible" or action == "Visible" or action == "Noclip" or action == "Fly" or action == "Unfly" or action == "Freeze" or action == "Unfreeze" then
		if not targetPlayer then
			return
		end
		resultOk, resultMessage = actionOnPlayer(action, requester, targetPlayer, payload.value)
	else
		resultOk, resultMessage = false, "unsupported"
	end
	publishActionResponse({
		ok = resultOk == true,
		requestId = payload.requestId,
		requesterUserId = tonumber(payload.requesterUserId) or 0,
		requesterJobId = tostring(payload.requesterJobId or ""),
		requesterPlaceId = tonumber(payload.requesterPlaceId) or 0,
		targetUserId = targetUserId,
		targetName = targetPlayer and targetPlayer.Name or safeNameFromUserId(targetUserId),
		targetDisplayName = targetPlayer and targetPlayer.DisplayName or safeNameFromUserId(targetUserId),
		action = action,
		message = resultOk == true and ("Executed " .. action) or tostring(resultMessage or "failed"),
		sourcePlaceId = game.PlaceId,
		sourceJobId = game.JobId,
	})
end

pcall(function()
	MessagingService:SubscribeAsync(INVENTORY_REQUEST_TOPIC, function(message)
		respondToInventoryRequest(message.Data)
	end)
end)

pcall(function()
	MessagingService:SubscribeAsync(INVENTORY_RESPONSE_TOPIC, function(message)
		fireInventoryResultToRequester(message.Data)
	end)
end)

pcall(function()
	MessagingService:SubscribeAsync(ACTION_REQUEST_TOPIC, function(message)
		handleRemoteActionRequest(message.Data)
	end)
end)

pcall(function()
	MessagingService:SubscribeAsync(ACTION_RESPONSE_TOPIC, function(message)
		fireActionResultToRequester(message.Data)
	end)
end)

pcall(function()
	MessagingService:SubscribeAsync(CHAT_TOPIC_NAME, function(message)
		local payload = message and message.Data
		local entry = normalizeChatEntry(payload)
		if not entry then
			return
		end
		if CHAT_SEEN_IDS[entry.id] then
			return
		end
		appendChatEntry(entry, false)
		broadcastChatEntry(entry)
	end)
end)

ZONE_BAN_DEFAULT_TEXT = "You Get Banned By Moderator."

function zoneBanKickText(reason, expiresAt)
	reason = tostring(reason or "")
	local clean = reason
	clean = string.gsub(clean, "^%s+", "")
	clean = string.gsub(clean, "%s+$", "")
	local hasReason = clean ~= "" and clean ~= "No reason provided."
	expiresAt = tonumber(expiresAt)
	if expiresAt then
		if hasReason then
			return ("Temp banned until %s: %s"):format(os.date("%Y-%m-%d %H:%M:%S", expiresAt), clean)
		end
		return ("%s Until %s"):format(ZONE_BAN_DEFAULT_TEXT, os.date("%Y-%m-%d %H:%M:%S", expiresAt))
	end
	if hasReason then
		return "Banned: " .. clean
	end
	return ZONE_BAN_DEFAULT_TEXT
end

local function formatReason(value)
	value = trim(value)
	if value == "" then
		return "No reason provided."
	end
	return clampText(value, 300)
end

------------------------------------------------------------
-- OWNER PROTECTION / ULTIMATE SECURITY / ADMIN TIMEOUT / VOICE MUTE
------------------------------------------------------------
ZONE_LOGGED_CO = setmetatable({}, { __mode = "k" })

-- Real game owner, or anyone holding the built-in "Owner" rank.
function zoneIsOwnerUser(userId)
	userId = tonumber(userId) or 0
	if userId <= 0 then
		return false
	end
	return isAutoOwnerUserId(userId) or getRank(userId) == "Owner"
end

function zoneOwnersInServer()
	local list = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if zoneIsOwnerUser(plr.UserId) then
			table.insert(list, plr)
		end
	end
	return list
end

function zoneNotifyOwners(message)
	for _, owner in ipairs(zoneOwnersInServer()) do
		pcall(function()
			RemoteEvent:FireClient(owner, "CommandResult", { ok = false, message = tostring(message or "") })
		end)
	end
end

-- Ultimate Security (memory only, ends when the player leaves) ----------
function zoneSetUltimateSecurity(requester, targetPlayer, on)
	if not targetPlayer then
		return false, "missing_target"
	end
	if requester and not zoneIsOwnerUser(requester.UserId) then
		return false, "owner_only"
	end
	local uid = tonumber(targetPlayer.UserId) or 0
	if on then
		ZONE_ULTIMATE_SECURITY[uid] = true
		targetPlayer:SetAttribute("ZoneUltimateSecurity", true)
	else
		ZONE_ULTIMATE_SECURITY[uid] = nil
		targetPlayer:SetAttribute("ZoneUltimateSecurity", nil)
	end
	return true
end

-- Admin timeout (saved in AdminPanelTimeouts_v1, works across servers) --
ZONE_TIMEOUT_STORE = DataStoreService:GetDataStore(ADMIN_TIMEOUT_STORE_NAME)
ZONE_TIMEOUT_TOPIC = "ZonePanelAdminTimeout_v1"
ZONE_TIMEOUTS = {}
ZONE_TIMEOUT_ALLOWED = {
	ClientPing = true,
	ClientInfo = true,
	ZonePingQuery = true,
}

function zoneTimeoutApplyLocal(userId, untilTime, byName)
	userId = tonumber(userId) or 0
	untilTime = tonumber(untilTime) or 0
	local plr = Players:GetPlayerByUserId(userId)
	if untilTime > now() then
		ZONE_TIMEOUTS[userId] = { untilTime = untilTime, by = tostring(byName or "") }
		if plr then
			plr:SetAttribute("ZoneAdminTimeoutUntil", untilTime)
		end
		task.delay(math.max(0, untilTime - now()) + 0.5, function()
			local current = ZONE_TIMEOUTS[userId]
			if current and current.untilTime == untilTime then
				zoneTimeoutApplyLocal(userId, 0)
			end
		end)
	else
		ZONE_TIMEOUTS[userId] = nil
		if plr then
			plr:SetAttribute("ZoneAdminTimeoutUntil", nil)
		end
	end
end

function zoneIsTimedOut(userId)
	userId = tonumber(userId) or 0
	local entry = ZONE_TIMEOUTS[userId]
	if not entry then
		return false
	end
	if (tonumber(entry.untilTime) or 0) <= now() then
		zoneTimeoutApplyLocal(userId, 0)
		return false
	end
	return true
end

function zoneTimeoutLoad(player)
	if not player then
		return
	end
	local uid = player.UserId
	local ok, data
	for attempt = 1, 4 do
		ok, data = pcall(function()
			return ZONE_TIMEOUT_STORE:GetAsync(tostring(uid))
		end)
		if ok then
			break
		end
		task.wait(attempt * 2)
	end
	if not ok or type(data) ~= "table" then
		return
	end
	local untilTime = tonumber(data.untilTime) or 0
	if untilTime > now() then
		zoneTimeoutApplyLocal(uid, untilTime, data.by)
	else
		pcall(function()
			ZONE_TIMEOUT_STORE:RemoveAsync(tostring(uid))
		end)
	end
end

function zoneTimeoutSave(userId, untilTime, record)
	local ok = pcall(function()
		if untilTime > 0 then
			ZONE_TIMEOUT_STORE:SetAsync(tostring(userId), record)
		else
			ZONE_TIMEOUT_STORE:RemoveAsync(tostring(userId))
		end
	end)
	zoneTimeoutApplyLocal(userId, untilTime, record and record.by)
	pcall(function()
		MessagingService:PublishAsync(ZONE_TIMEOUT_TOPIC, { u = userId, t = untilTime, b = record and record.by or "", j = game.JobId })
	end)
	return ok
end

-- requester = nil means the system (ban spam protection).
function zoneTimeoutCommand(requester, targetUserId, action, value)
	targetUserId = tonumber(targetUserId) or 0
	if targetUserId <= 0 then
		return false, "Could not find that player."
	end
	if requester and not zoneIsOwnerUser(requester.UserId) then
		return false, "Only the Owner can use timeouts."
	end
	if requester then
		local allowed, why = canTargetUserId(requester.UserId, targetUserId, action)
		if not allowed then
			return false, protectionMessage(why, safeNameFromUserId(targetUserId))
		end
		if requester.UserId == targetUserId then
			return false, "You cannot time out yourself."
		end
	end
	local targetLabel = safeNameFromUserId(targetUserId)
	if action == "Untimeout" then
		zoneTimeoutSave(targetUserId, 0, nil)
		logModerationAction("Untimeout", requester, targetUserId, targetLabel, targetLabel, "", nil, 3066993)
		return true, ("%s is no longer timed out."):format(targetLabel)
	end
	local raw = value
	local reason = ""
	if type(raw) == "table" then
		reason = tostring(raw.reason or "")
		raw = raw.minutes or raw.value or raw.reason
	end
	local rawText = tostring(raw or "")
	local minutesText, rest = rawText:match("^%s*(%d+)%s+(.*)$")
	if not minutesText then
		minutesText = rawText:match("^%s*(%d+)%s*$")
		rest = ""
	end
	local minutes = tonumber(minutesText)
	if not minutes or minutes < 1 then
		return false, "Timeout needs minutes, for example: timeout name 30"
	end
	if reason == "" then
		reason = trim(rest or "")
	end
	minutes = math.clamp(math.floor(minutes), 1, ADMIN_TIMEOUT_MAX_MINUTES)
	local untilTime = now() + minutes * 60
	local byName = requester and tostring(requester.Name or "Owner") or "System"
	local saved = zoneTimeoutSave(targetUserId, untilTime, {
		untilTime = untilTime,
		by = byName,
		byUserId = requester and requester.UserId or 0,
		reason = clampText(reason, 200),
		minutes = minutes,
	})
	logModerationAction("Timeout", requester, targetUserId, targetLabel, targetLabel,
		reason ~= "" and reason or ("%d minute(s)"):format(minutes), {
			{ name = "Minutes", value = tostring(minutes), inline = true },
		}, 15105570)
	if not saved then
		return true, ("%s is timed out for %d minute(s) here, but saving failed."):format(targetLabel, minutes)
	end
	return true, ("%s is timed out for %d minute(s)."):format(targetLabel, minutes)
end

task.spawn(function()
	pcall(function()
		MessagingService:SubscribeAsync(ZONE_TIMEOUT_TOPIC, function(message)
			local data = message and message.Data
			if type(data) ~= "table" or tostring(data.j or "") == tostring(game.JobId) then
				return
			end
			zoneTimeoutApplyLocal(tonumber(data.u) or 0, tonumber(data.t) or 0, data.b)
		end)
	end)
end)

-- Ban spam protection: too many bans in a short time = auto timeout ------
ZONE_BAN_SPAM = {}

function zoneBanSpamRecord(requester)
	local uid = tonumber(requester and requester.UserId) or 0
	if uid <= 0 or zoneIsOwnerUser(uid) then
		return
	end
	local list = ZONE_BAN_SPAM[uid] or {}
	local t = now()
	local fresh = {}
	for _, stamp in ipairs(list) do
		if t - stamp < BAN_SPAM_WINDOW_SECONDS then
			table.insert(fresh, stamp)
		end
	end
	table.insert(fresh, t)
	ZONE_BAN_SPAM[uid] = fresh
	if #fresh < BAN_SPAM_LIMIT or zoneIsTimedOut(uid) then
		return
	end
	ZONE_BAN_SPAM[uid] = {}
	local name = tostring(requester.Name or safeNameFromUserId(uid))
	local why = ("Ban spam: %d bans in %d seconds"):format(#fresh, BAN_SPAM_WINDOW_SECONDS)
	zoneTimeoutCommand(nil, uid, "Timeout", { minutes = BAN_SPAM_TIMEOUT_MINUTES, reason = why })
	zoneNotifyOwners(("%s was timed out for %d minutes (%s)."):format(name, BAN_SPAM_TIMEOUT_MINUTES, why))
	postWebhook(requester, "Ban spam protection", 15158332, {
		makeWebhookField("Admin", buildActorText(requester), false),
		makeWebhookField("Bans", ("%d in %d seconds"):format(#fresh, BAN_SPAM_WINDOW_SECONDS), true),
		makeWebhookField("Timeout", ("%d minutes"):format(BAN_SPAM_TIMEOUT_MINUTES), true),
	})
end

-- Voice mute (Audio API). Nobody hears the player, they still hear others.
ZONE_VOICE_MUTED = {}

function zoneVoiceDevice(plr)
	if not plr then
		return nil
	end
	return plr:FindFirstChildWhichIsA("AudioDeviceInput", true)
end

function zoneVoiceApply(plr, device)
	if not plr or not device then
		return false
	end
	local ok = pcall(function()
		if ZONE_VOICE_MUTED[plr.UserId] then
			device.AccessType = Enum.AccessModifierType.Allow
			device:SetUserIdAccessList({})
		else
			device.AccessType = Enum.AccessModifierType.Deny
			device:SetUserIdAccessList({})
		end
	end)
	return ok
end

function zoneVoiceMute(plr, on)
	if not plr then
		return false, "missing_target"
	end
	ZONE_VOICE_MUTED[plr.UserId] = on and true or nil
	plr:SetAttribute("ZoneVoiceMuted", on and true or nil)
	local device = zoneVoiceDevice(plr)
	if not device then
		-- Applied as soon as the voice input appears (see DescendantAdded below).
		return true
	end
	return zoneVoiceApply(plr, device)
end

function zoneVoiceWatch(plr)
	plr.DescendantAdded:Connect(function(child)
		if child:IsA("AudioDeviceInput") and ZONE_VOICE_MUTED[plr.UserId] then
			task.defer(zoneVoiceApply, plr, child)
		end
	end)
end

Players.PlayerAdded:Connect(function(plr)
	zoneVoiceWatch(plr)
	task.spawn(zoneTimeoutLoad, plr)
end)
for _, plr in ipairs(Players:GetPlayers()) do
	zoneVoiceWatch(plr)
	task.spawn(zoneTimeoutLoad, plr)
end

Players.PlayerRemoving:Connect(function(plr)
	-- Timeouts and the ban-spam counter are kept on purpose, so leaving and
	-- rejoining does not reset them.
	local uid = plr.UserId
	ZONE_ULTIMATE_SECURITY[uid] = nil
	ZONE_VOICE_MUTED[uid] = nil
end)

local function getRootAndHumanoid(player)
	local character = player and player.Character
	if not character then
		return nil, nil, nil
	end
	return character, getRoot(character), getHumanoid(character)
end

local function restoreMovement(humanoid)
	if not humanoid then
		return
	end
	local ws = humanoid:GetAttribute("__AdminOrigWalkSpeed")
	local jp = humanoid:GetAttribute("__AdminOrigJumpPower")
	local jh = humanoid:GetAttribute("__AdminOrigJumpHeight")
	local ar = humanoid:GetAttribute("__AdminOrigAutoRotate")
	local ps = humanoid:GetAttribute("__AdminOrigPlatformStand")
	if typeof(ws) == "number" then humanoid.WalkSpeed = ws end
	if typeof(jp) == "number" then humanoid.JumpPower = jp end
	if typeof(jh) == "number" then humanoid.JumpHeight = jh end
	if typeof(ar) == "boolean" then humanoid.AutoRotate = ar end
	if typeof(ps) == "boolean" then humanoid.PlatformStand = ps end
	humanoid:SetAttribute("__AdminOrigWalkSpeed", nil)
	humanoid:SetAttribute("__AdminOrigJumpPower", nil)
	humanoid:SetAttribute("__AdminOrigJumpHeight", nil)
	humanoid:SetAttribute("__AdminOrigAutoRotate", nil)
	humanoid:SetAttribute("__AdminOrigPlatformStand", nil)
end

local function freezeCharacter(player, frozen)
	local character, root, humanoid = getRootAndHumanoid(player)
	if not character or not humanoid then
		return false
	end
	if frozen then
		if root then
			if root:GetAttribute("__AdminOrigAnchored") == nil then
				root:SetAttribute("__AdminOrigAnchored", root.Anchored)
			end
			root.Anchored = true
		end
		if humanoid:GetAttribute("__AdminOrigWalkSpeed") == nil then
			humanoid:SetAttribute("__AdminOrigWalkSpeed", humanoid.WalkSpeed)
		end
		if humanoid:GetAttribute("__AdminOrigJumpPower") == nil then
			humanoid:SetAttribute("__AdminOrigJumpPower", humanoid.JumpPower)
		end
		if humanoid:GetAttribute("__AdminOrigJumpHeight") == nil then
			humanoid:SetAttribute("__AdminOrigJumpHeight", humanoid.JumpHeight)
		end
		if humanoid:GetAttribute("__AdminOrigAutoRotate") == nil then
			humanoid:SetAttribute("__AdminOrigAutoRotate", humanoid.AutoRotate)
		end
		if humanoid:GetAttribute("__AdminOrigPlatformStand") == nil then
			humanoid:SetAttribute("__AdminOrigPlatformStand", humanoid.PlatformStand)
		end
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0
		humanoid.AutoRotate = false
		humanoid.PlatformStand = true
	else
		if root and root:GetAttribute("__AdminOrigAnchored") ~= nil then
			root.Anchored = root:GetAttribute("__AdminOrigAnchored") == true
			root:SetAttribute("__AdminOrigAnchored", nil)
		end
		restoreMovement(humanoid)
		humanoid.PlatformStand = false
	end
	return true
end

local function setNoclip(player, enabled)
	if enabled and player and player:GetAttribute("AdminPanelJailed") == true then
		return false, "target_jailed"
	end
	local character = player and player.Character
	if not character then
		return false
	end
	for _, inst in ipairs(character:GetDescendants()) do
		if inst:IsA("BasePart") then
			if enabled then
				setAttrIfMissing(inst, "__AdminOrigCanCollide", inst.CanCollide)
				setAttrIfMissing(inst, "__AdminOrigCanTouch", inst.CanTouch)
				setAttrIfMissing(inst, "__AdminOrigCanQuery", inst.CanQuery)
				inst.CanCollide = false
				inst.CanTouch = false
				inst.CanQuery = false
			else
				local cc = popAttr(inst, "__AdminOrigCanCollide")
				local ct = popAttr(inst, "__AdminOrigCanTouch")
				local cq = popAttr(inst, "__AdminOrigCanQuery")
				if typeof(cc) == "boolean" then inst.CanCollide = cc end
				if typeof(ct) == "boolean" then inst.CanTouch = ct end
				if typeof(cq) == "boolean" then inst.CanQuery = cq end
			end
		end
	end
	return true
end

local function setVisibility(player, visible)
	local character = player and player.Character
	if not character then
		return false
	end
	setCharacterVisible(character, visible)
	return true
end

local function setSpeed(player, speed)
	local _, _, humanoid = getRootAndHumanoid(player)
	if not humanoid then
		return false
	end
	speed = math.clamp(tonumber(speed) or 24, 0, 250)
	if humanoid:GetAttribute("__AdminOrigWalkSpeed") == nil then
		humanoid:SetAttribute("__AdminOrigWalkSpeed", humanoid.WalkSpeed)
	end
	humanoid.WalkSpeed = speed
	return true
end

local function setJump(player, jump)
	local _, _, humanoid = getRootAndHumanoid(player)
	if not humanoid then
		return false
	end
	jump = math.clamp(tonumber(jump) or 50, 0, 200)
	if humanoid.UseJumpPower then
		if humanoid:GetAttribute("__AdminOrigJumpPower") == nil then
			humanoid:SetAttribute("__AdminOrigJumpPower", humanoid.JumpPower)
		end
		humanoid.JumpPower = jump
	else
		if humanoid:GetAttribute("__AdminOrigJumpHeight") == nil then
			humanoid:SetAttribute("__AdminOrigJumpHeight", humanoid.JumpHeight)
		end
		humanoid.JumpHeight = jump
	end
	return true
end

local function bringPlayer(target, requester)
	if target and target:GetAttribute("AdminPanelJailed") == true then
		return false
	end
	local tChar, tRoot = getRootAndHumanoid(target)
	local rChar, rRoot = getRootAndHumanoid(requester)
	if not tChar or not tRoot or not rChar or not rRoot then
		return false
	end
	tRoot.CFrame = rRoot.CFrame * CFrame.new(2, 0, 2)
	return true
end

UNDO_STACKS = {}

UNDO_REVERSE = {
	Fly = "Unfly",
	Unfly = "Fly",
	Freeze = "Unfreeze",
	Unfreeze = "Freeze",
	Mute = "Unmute",
	TempMute = "Unmute",
	Unmute = "Mute",
	Jail = "Unjail",
	Unjail = "Jail",
	God = "Ungod",
	Ungod = "God",
	Invisible = "Visible",
	Visible = "Invisible",
	Ban = "Unban",
	Unban = "Ban",
}

function pushUndo(requester, action, targetUserId, targetName)
	if not requester or not UNDO_REVERSE[action] then
		return
	end
	local key = tostring(requester.UserId)
	UNDO_STACKS[key] = UNDO_STACKS[key] or {}
	table.insert(UNDO_STACKS[key], {
		action = action,
		reverse = UNDO_REVERSE[action],
		targetUserId = tonumber(targetUserId) or 0,
		targetName = tostring(targetName or ""),
		at = now(),
	})
	while #UNDO_STACKS[key] > 10 do
		table.remove(UNDO_STACKS[key], 1)
	end
end

function popUndo(requester)
	if not requester then
		return nil
	end
	local key = tostring(requester.UserId)
	local stack = UNDO_STACKS[key]
	if type(stack) ~= "table" or #stack == 0 then
		return nil
	end
	return table.remove(stack)
end

function refreshCharacter(target)
	local character = target and target.Character
	if not character then
		return false
	end
	local root = getRoot(character)
	if not root then
		return false
	end
	local savedCFrame = root.CFrame
	target:LoadCharacter()
	task.spawn(function()
		local newChar = target.Character or target.CharacterAdded:Wait()
		local newRoot = newChar and newChar:WaitForChild("HumanoidRootPart", 5)
		if newRoot then
			task.wait(0.1)
			newRoot.CFrame = savedCFrame
		end
	end)
	return true
end

function setPlayerGravity(target, value)
	local character, root, humanoid = getRootAndHumanoid(target)
	if not character or not root then
		return false
	end

	local existing = root:FindFirstChild("AdminPanelGravity")
	local gravity = math.clamp(tonumber(value) or 196, 0, 500)
	local defaultGravity = workspace.Gravity

	if math.abs(gravity - defaultGravity) < 0.5 then
		if existing then
			existing:Destroy()
		end
		target:SetAttribute("AdminPanelGravity", nil)
		return true
	end

	local force = existing
	if not force then
		force = Instance.new("BodyForce")
		force.Name = "AdminPanelGravity"
		force.Parent = root
	end

	local mass = 0
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			mass = mass + part:GetMass()
		end
	end

	force.Force = Vector3.new(0, mass * (defaultGravity - gravity), 0)
	target:SetAttribute("AdminPanelGravity", gravity)
	return true
end

function sitPlayer(target)
	local character, root, humanoid = getRootAndHumanoid(target)
	if not humanoid then
		return false
	end
	humanoid.Sit = true
	return true
end

function teleportPlayerTo(mover, destination)
	if mover and mover:GetAttribute("AdminPanelJailed") == true then
		return false
	end
	local mChar, mRoot = getRootAndHumanoid(mover)
	local dChar, dRoot = getRootAndHumanoid(destination)
	if not mChar or not mRoot or not dChar or not dRoot then
		return false
	end
	mRoot.CFrame = dRoot.CFrame * CFrame.new(2, 0, 2)
	return true
end

function gotoPlayer(requester, target)
	if requester and requester:GetAttribute("AdminPanelJailed") == true then
		return false
	end
	local tChar, tRoot = getRootAndHumanoid(target)
	local rChar, rRoot = getRootAndHumanoid(requester)
	if not tChar or not tRoot or not rChar or not rRoot then
		return false
	end
	rRoot.CFrame = tRoot.CFrame * CFrame.new(2, 0, 2)
	return true
end

function killPlayer(target)
	local character, root, humanoid = getRootAndHumanoid(target)
	if not humanoid then
		return false
	end
	humanoid.Health = 0
	return true
end

function setGodState(target, enabled)
	local character, root, humanoid = getRootAndHumanoid(target)
	if not humanoid then
		return false
	end
	if enabled then
		if humanoid:GetAttribute("__AdminOrigMaxHealth") == nil then
			humanoid:SetAttribute("__AdminOrigMaxHealth", humanoid.MaxHealth)
		end
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
		target:SetAttribute("AdminPanelGod", true)
	else
		local original = humanoid:GetAttribute("__AdminOrigMaxHealth")
		humanoid.MaxHealth = typeof(original) == "number" and original or 100
		humanoid.Health = humanoid.MaxHealth
		humanoid:SetAttribute("__AdminOrigMaxHealth", nil)
		target:SetAttribute("AdminPanelGod", false)
	end
	return true
end

function ensureJailFolder()
	local folder = workspace:FindFirstChild("AdminPanelJails")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "AdminPanelJails"
		folder.Parent = workspace
	end
	return folder
end

function setJailState(target, enabled)
	if not target then
		return false
	end
	local userId = tonumber(target.UserId) or 0
	if not enabled then
		clearJailFor(userId)
		target:SetAttribute("AdminPanelJailed", false)
		return true
	end

	local character, root = getRootAndHumanoid(target)
	if not character or not root then
		return false
	end
	ZONE_JAIL_STATE = ZONE_JAIL_STATE or {}
	local jailState = ZONE_JAIL_STATE[userId]
	if not jailState or typeof(jailState.origin) ~= "CFrame" then
		jailState = { origin = root.CFrame, character = character }
		ZONE_JAIL_STATE[userId] = jailState
	end

	local folder = ensureJailFolder()
	local cellName = "Jail_" .. tostring(userId)
	local existing = folder:FindFirstChild(cellName)
	if not jailState.model or not jailState.model.Parent then
		if existing then
			existing:Destroy()
		end
		local model = Instance.new("Model")
		model.Name = cellName
		local sides = {
			{ Vector3.new(12, 0.6, 12), CFrame.new(0, 6, 0) },
			{ Vector3.new(12, 0.6, 12), CFrame.new(0, -3.5, 0) },
			{ Vector3.new(0.6, 10, 12), CFrame.new(6, 1, 0) },
			{ Vector3.new(0.6, 10, 12), CFrame.new(-6, 1, 0) },
			{ Vector3.new(12, 10, 0.6), CFrame.new(0, 1, 6) },
			{ Vector3.new(12, 10, 0.6), CFrame.new(0, 1, -6) },
		}
		for _, side in ipairs(sides) do
			local part = Instance.new("Part")
			part.Size = side[1]
			part.CFrame = jailState.origin * side[2]
			part.Anchored = true
			part.CanCollide = true
			part.Transparency = 0.55
			part.Material = Enum.Material.ForceField
			part.Color = Color3.fromRGB(60, 140, 255)
			part.Parent = model
		end
		model.Parent = folder
		jailState.model = model
	elseif existing and existing ~= jailState.model then
		existing:Destroy()
	end

	target:SetAttribute("AdminPanelJailed", true)

	local function stopFlyAndNoclip()
		if type(ZONE_StopFlyNoclipLoop) == "function" then
			pcall(ZONE_StopFlyNoclipLoop, userId)
		end
		pcall(setNoclip, target, false)
		FLY_NOCLIP_OWNED = FLY_NOCLIP_OWNED or {}
		FLY_NOCLIP_OWNED[userId] = nil
		local liveCharacter = target.Character
		local liveRoot = liveCharacter and liveCharacter:FindFirstChild("HumanoidRootPart")
		if liveRoot then
			local force = liveRoot:FindFirstChild("AdminPanelFlyForce")
			local gyro = liveRoot:FindFirstChild("AdminPanelFlyGyro")
			if force then force:Destroy() end
			if gyro then gyro:Destroy() end
		end
		target:SetAttribute("AdminPanelFlying", false)
		pcall(function()
			RemoteEvent:FireClient(target, "AdminFly", false)
		end)
	end

	local function moveCharacterIntoCell(characterToMove)
		if not characterToMove or not target.Parent or target:GetAttribute("AdminPanelJailed") ~= true
			or ZONE_JAIL_STATE[userId] ~= jailState then
			return false
		end
		local jailRoot = characterToMove:FindFirstChild("HumanoidRootPart")
		if not jailRoot then
			return false
		end
		stopFlyAndNoclip()
		jailRoot.CFrame = jailState.origin
		jailRoot.AssemblyLinearVelocity = Vector3.zero
		jailRoot.AssemblyAngularVelocity = Vector3.zero
		jailState.character = characterToMove
		return true
	end

	moveCharacterIntoCell(character)
	if not jailState.characterConn then
		jailState.characterConn = target.CharacterAdded:Connect(function(newCharacter)
			task.spawn(function()
				local newRoot = newCharacter:WaitForChild("HumanoidRootPart", 12)
				if not newRoot then
					return
				end
				moveCharacterIntoCell(newCharacter)
			end)
		end)
	end
	if not jailState.guardConn then
		jailState.guardConn = game:GetService("RunService").Heartbeat:Connect(function()
			if not target.Parent or target:GetAttribute("AdminPanelJailed") ~= true
				or ZONE_JAIL_STATE[userId] ~= jailState then
				local conn = jailState.guardConn
				jailState.guardConn = nil
				if conn then pcall(function() conn:Disconnect() end) end
				return
			end
			local liveCharacter = target.Character
			local liveRoot = liveCharacter and liveCharacter:FindFirstChild("HumanoidRootPart")
			if not liveRoot then
				return
			end
			if jailState.character ~= liveCharacter then
				moveCharacterIntoCell(liveCharacter)
				return
			end
			if target:GetAttribute("AdminPanelFlying") == true then
				stopFlyAndNoclip()
			end
			local localPosition = jailState.origin:PointToObjectSpace(liveRoot.Position)
			if math.abs(localPosition.X) > 4.8 or math.abs(localPosition.Z) > 4.8
				or localPosition.Y < -2 or localPosition.Y > 3 then
				moveCharacterIntoCell(liveCharacter)
			end
		end)
	end
	return true
end

ZONE_FLY_NOCLIP_LOOPS = ZONE_FLY_NOCLIP_LOOPS or {}

function ZONE_StopFlyNoclipLoop(userId)
	local conn = ZONE_FLY_NOCLIP_LOOPS[userId]
	if conn then
		pcall(function()
			conn:Disconnect()
		end)
		ZONE_FLY_NOCLIP_LOOPS[userId] = nil
	end
end

function ZONE_StartFlyNoclipLoop(player)
	ZONE_StopFlyNoclipLoop(player.UserId)
	local runService = game:GetService("RunService")
	ZONE_FLY_NOCLIP_LOOPS[player.UserId] = runService.Heartbeat:Connect(function()
		if not player or not player.Parent then
			ZONE_StopFlyNoclipLoop(player.UserId)
			return
		end
		if player:GetAttribute("AdminPanelJailed") == true then
			pcall(setNoclip, player, false)
			ZONE_StopFlyNoclipLoop(player.UserId)
			return
		end
		pcall(setNoclip, player, true)
	end)
end
local function setFlyState(target, enabled)
	if not target then
		return false, "missing_target"
	end
	if enabled and target:GetAttribute("AdminPanelJailed") == true then
		target:SetAttribute("AdminPanelFlying", false)
		pcall(function() RemoteEvent:FireClient(target, "AdminFly", false) end)
		return false, "target_jailed"
	end
	local character, root = getRootAndHumanoid(target)
	if not character or not root then
		return false, "missing_character"
	end
	if enabled then
		FLY_NOCLIP_OWNED = FLY_NOCLIP_OWNED or {}
		if FLY_NOCLIP_OWNED[target.UserId] == nil then
			FLY_NOCLIP_OWNED[target.UserId] = root:GetAttribute("__AdminOrigCanCollide") == nil
		end
		setNoclip(target, true)
		ZONE_StartFlyNoclipLoop(target)
		target:SetAttribute("AdminPanelFlying", true)
		RemoteEvent:FireClient(target, "AdminFly", true)
		local hum = character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Physics)
		end
	else
		ZONE_StopFlyNoclipLoop(target.UserId)
		FLY_NOCLIP_OWNED = FLY_NOCLIP_OWNED or {}
		if FLY_NOCLIP_OWNED[target.UserId] == true then
			setNoclip(target, false)
		end
		FLY_NOCLIP_OWNED[target.UserId] = nil
		target:SetAttribute("AdminPanelFlying", false)
		local existingBV = root:FindFirstChild("AdminPanelFlyForce")
		local existingBG = root:FindFirstChild("AdminPanelFlyGyro")
		if existingBV then existingBV:Destroy() end
		if existingBG then existingBG:Destroy() end
		RemoteEvent:FireClient(target, "AdminFly", false)
		local hum = character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
	return true
end

local function isUserMuted(userId)
	local key = tonumber(userId) or 0
	local record = MUTED_USERS[key]
	if isMuteActive(record) then
		return true
	end
	if record ~= nil then
		MUTED_USERS[key] = nil
	end
	return false
end

local muteHookOk = pcall(function()
	local allChannels = TextChatService:FindFirstChild("TextChannels")
	local function hookChannel(channel)
		if not channel:IsA("TextChannel") then return end
		channel.ShouldDeliverCallback = function(message, textSource)
			if message and message.TextSource and isUserMuted(message.TextSource.UserId) then
				return false
			end
			return true
		end
	end
	if allChannels then
		for _, ch in ipairs(allChannels:GetChildren()) do
			hookChannel(ch)
		end
		allChannels.ChildAdded:Connect(hookChannel)
	end

	pcall(function()
		TextChatService.OnIncomingMessage = function(message)
			local props = Instance.new("TextChatMessageProperties")
			local source = message.TextSource
			if source and isUserMuted(source.UserId) then
				props.Text = ""
				return props
			end
			return props
		end
	end)
end)
if not muteHookOk then
	warn("[Zone Panel]: Failed to initialize mute support. This experience must use TextChatService. Enable it in Game Settings → Chat → Chat Version")
end

local function muteUserChat(targetPlayer, muted, durationSeconds, reason, moderatorUserId)
	return applyMuteState(targetPlayer, muted, durationSeconds, reason, moderatorUserId)
end

ZONE_EXTRA_ACTIONS = {
	Fling = true, Trip = true, Spin = true, Unspin = true,
	Ragdoll = true, Unragdoll = true, NoGravity = true, Grav = true, Launch = true,
	Fire = true, Unfire = true, Smoke = true, Unsmoke = true,
	Sparkles = true, Unsparkles = true, ForceField = true, UnFF = true, Explode = true,
	BigHead = true, SmallHead = true, NormalHead = true,
	Fat = true, Thin = true, Squash = true, Dwarf = true, Giant = true, NormalSize = true,
	Size = true, HideName = true, ShowName = true,
	Ghost = true, Glass = true, UnGhost = true, Paint = true,
	Damage = true, SetHealth = true, LoopKill = true, StopLoop = true,
	Punish = true, Unpunish = true, Blind = true, Confuse = true,
	Age = true, Ping = true,
}

ZONE_LOOP_STATE = ZONE_LOOP_STATE or {}

function zoneRoot(plr)
	local char = plr and plr.Character
	return char and char:FindFirstChild("HumanoidRootPart") or nil
end

function zoneHum(plr)
	local char = plr and plr.Character
	return char and char:FindFirstChildOfClass("Humanoid") or nil
end

function zoneFling(plr, power)
	local root = zoneRoot(plr)
	if not root then
		return false
	end
	power = math.clamp(tonumber(power) or 420, 60, 1500)
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1, 1, 1) * 1e6
	bv.Velocity = Vector3.new(
		math.random(-power, power),
		power * 0.85,
		math.random(-power, power)
	)
	bv.Parent = root
	game:GetService("Debris"):AddItem(bv, 0.6)
	local av = Instance.new("BodyAngularVelocity")
	av.MaxTorque = Vector3.new(1, 1, 1) * 1e5
	av.AngularVelocity = Vector3.new(math.random(-30, 30), math.random(-30, 30), math.random(-30, 30))
	av.Parent = root
	game:GetService("Debris"):AddItem(av, 0.35)
	return true
end

function zoneTrip(plr)
	local hum = zoneHum(plr)
	if not hum then
		return false
	end
	hum.PlatformStand = true
	task.delay(1.6, function()
		if hum and hum.Parent then
			hum.PlatformStand = false
		end
	end)
	return true
end

function zoneSpin(plr, on)
	local root = zoneRoot(plr)
	if not root then
		return false
	end
	local existing = root:FindFirstChild("ZoneSpin")
	if existing then
		existing:Destroy()
	end
	if not on then
		return true
	end
	local av = Instance.new("BodyAngularVelocity")
	av.Name = "ZoneSpin"
	av.MaxTorque = Vector3.new(0, 1e5, 0)
	av.AngularVelocity = Vector3.new(0, 22, 0)
	av.Parent = root
	return true
end

function zoneRagdoll(plr, on)
	local hum = zoneHum(plr)
	if not hum then
		return false
	end
	if on then
		hum.PlatformStand = true
		hum:ChangeState(Enum.HumanoidStateType.Physics)
	else
		hum.PlatformStand = false
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
	return true
end


function zoneNoGravity(plr, on)
	local root = zoneRoot(plr)
	if not root then
		return false
	end
	local existing = root:FindFirstChild("ZoneNoGrav")
	if existing then
		existing:Destroy()
	end
	if not on then
		return true
	end
	local force = Instance.new("BodyForce")
	force.Name = "ZoneNoGrav"
	local mass = 0
	for _, part in ipairs(plr.Character:GetDescendants()) do
		if part:IsA("BasePart") then
			mass = mass + part:GetMass()
		end
	end
	force.Force = Vector3.new(0, mass * workspace.Gravity, 0)
	force.Parent = root
	return true
end

function zoneLaunch(plr, power)
	local root = zoneRoot(plr)
	if not root then
		return false
	end
	power = math.clamp(tonumber(power) or 90, 30, 200)
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(0, 1e5, 0)
	bv.Velocity = Vector3.new(0, power, 0)
	bv.Parent = root
	game:GetService("Debris"):AddItem(bv, 0.25)
	zoneSoftLanding(plr)
	return true
end


function zoneSoftLanding(plr)
	local hum = zoneHum(plr)
	if not hum then
		return
	end
	local before = hum:GetAttribute("ZoneFallGuard")
	if before then
		return
	end
	hum:SetAttribute("ZoneFallGuard", true)
	local conn
	conn = hum.StateChanged:Connect(function(_, newState)
		if newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Running then
			if conn then
				conn:Disconnect()
			end
			if hum and hum.Parent then
				hum:SetAttribute("ZoneFallGuard", nil)
			end
		end
	end)
	task.delay(8, function()
		if conn then
			conn:Disconnect()
		end
		if hum and hum.Parent then
			hum:SetAttribute("ZoneFallGuard", nil)
		end
	end)
end

function zoneScaleValue(plr, scaleName, amount)
	local hum = zoneHum(plr)
	if not hum then
		return false
	end
	local node = hum:FindFirstChild(scaleName)
	if not node then
		return false
	end
	node.Value = math.clamp(tonumber(amount) or 1, 0.2, 6)
	return true
end

function zoneHeadSize(plr, amount)
	local ok = zoneScaleValue(plr, "HeadScale", amount)
	if ok then
		return true
	end
	local char = plr and plr.Character
	local head = char and char:FindFirstChild("Head")
	if not head then
		return false
	end
	local mesh = head:FindFirstChildOfClass("SpecialMesh")
	if not mesh then
		return false
	end
	local n = math.clamp(tonumber(amount) or 1, 0.2, 6)
	mesh.Scale = Vector3.new(1.25, 1.25, 1.25) * n
	return true
end

function zoneBodyShape(plr, kind)
	local hum = zoneHum(plr)
	if not hum then
		return false
	end
	local width = hum:FindFirstChild("BodyWidthScale")
	local depth = hum:FindFirstChild("BodyDepthScale")
	local height = hum:FindFirstChild("BodyHeightScale")
	local head = hum:FindFirstChild("HeadScale")
	if not width or not depth or not height then
		return false
	end
	if kind == "Fat" then
		width.Value = 1.9
		depth.Value = 1.9
		height.Value = 1
	elseif kind == "Thin" then
		width.Value = 0.45
		depth.Value = 0.45
		height.Value = 1
	elseif kind == "Squash" then
		width.Value = 1.6
		depth.Value = 1.6
		height.Value = 0.45
	elseif kind == "Dwarf" then
		width.Value = 1
		depth.Value = 1
		height.Value = 0.5
		if head then head.Value = 1 end
	elseif kind == "Giant" then
		width.Value = 2.2
		depth.Value = 2.2
		height.Value = 2.2
		if head then head.Value = 2 end
	else
		width.Value = 1
		depth.Value = 1
		height.Value = 1
		if head then head.Value = 1 end
	end
	return true
end

function zoneSetSize(plr, amount)
	local hum = zoneHum(plr)
	if not hum then
		return false
	end
	local n = math.clamp(tonumber(amount) or 1, 0.3, 4)
	for _, name in ipairs({ "BodyWidthScale", "BodyDepthScale", "BodyHeightScale", "HeadScale" }) do
		local node = hum:FindFirstChild(name)
		if node then
			node.Value = n
		end
	end
	return true
end

function zoneHideName(plr, hidden)
	local hum = zoneHum(plr)
	if not hum then
		return false
	end
	hum.DisplayDistanceType = hidden and Enum.HumanoidDisplayDistanceType.None
		or Enum.HumanoidDisplayDistanceType.Viewer
	return true
end

function zoneMaterial(plr, kind)
	if not plr then
		return false
	end
	ZONE_MATERIAL_STATE = ZONE_MATERIAL_STATE or {}
	local userId = plr.UserId
	local saved = ZONE_MATERIAL_STATE[userId]

	if kind == "Reset" then
		if saved and type(saved.parts) == "table" then
			for part, original in pairs(saved.parts) do
				if part and part.Parent and type(original) == "table" then
					pcall(function()
						part.Material = original.Material
						part.Transparency = original.Transparency
						part.Reflectance = original.Reflectance
					end)
				end
			end
		end
		ZONE_MATERIAL_STATE[userId] = nil
		return true
	end

	if kind ~= "Ghost" and kind ~= "Glass" then
		return false
	end
	local character = plr.Character
	if not character then
		return false
	end
	if not saved or saved.character ~= character then
		saved = { character = character, parts = {} }
		ZONE_MATERIAL_STATE[userId] = saved
	end

	for _, item in ipairs(character:GetDescendants()) do
		if item:IsA("BasePart") and item.Name ~= "HumanoidRootPart" then
			local original = saved.parts[item]
			if not original then
				original = {
					Material = item.Material,
					Transparency = item.Transparency,
					Reflectance = item.Reflectance,
				}
				saved.parts[item] = original
			end
			if kind == "Ghost" then
				item.Material = original.Material
				item.Transparency = math.max(original.Transparency, 0.35)
				item.Reflectance = original.Reflectance
			else
				item.Material = Enum.Material.Glass
				item.Transparency = math.max(original.Transparency, 0.3)
				item.Reflectance = math.max(original.Reflectance, 0.1)
			end
		end
	end
	return true
end

function zonePaint(plr, colorText)
	local char = plr and plr.Character
	if not char then
		return false
	end
	local tint = Color3.fromRGB(255, 80, 80)
	local clean = string.lower(trim(tostring(colorText or "")))
	local presets = {
		red = Color3.fromRGB(255, 60, 60),
		blue = Color3.fromRGB(70, 130, 255),
		green = Color3.fromRGB(80, 220, 120),
		yellow = Color3.fromRGB(255, 220, 80),
		purple = Color3.fromRGB(180, 110, 255),
		pink = Color3.fromRGB(255, 130, 200),
		black = Color3.fromRGB(30, 30, 34),
		white = Color3.fromRGB(245, 245, 245),
		orange = Color3.fromRGB(255, 150, 60),
	}
	if presets[clean] then
		tint = presets[clean]
	end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			part.Color = tint
		end
	end
	return true
end

function zoneDamage(plr, amount)
	local hum = zoneHum(plr)
	if not hum then
		return false
	end
	hum:TakeDamage(math.clamp(tonumber(amount) or 25, 1, 1000))
	return true
end

function zoneSetHealth(plr, amount)
	local hum = zoneHum(plr)
	if not hum then
		return false
	end
	local n = math.clamp(tonumber(amount) or 100, 1, 10000)
	hum.MaxHealth = math.max(hum.MaxHealth, n)
	hum.Health = n
	return true
end

function zoneLoopKill(plr, on)
	local key = "loopkill_" .. tostring(plr and plr.UserId or 0)
	if not on then
		ZONE_LOOP_STATE[key] = nil
		return true
	end
	if ZONE_LOOP_STATE[key] then
		return true
	end
	ZONE_LOOP_STATE[key] = true
	task.spawn(function()
		while ZONE_LOOP_STATE[key] do
			local hum = zoneHum(plr)
			if not plr or not plr.Parent then
				ZONE_LOOP_STATE[key] = nil
				break
			end
			if hum and hum.Health > 0 then
				hum.Health = 0
			end
			task.wait(1.5)
		end
	end)
	return true
end

function zonePunish(plr, on)
	if not plr then
		return false
	end
	if on then
		local char = plr.Character
		if char then
			plr:SetAttribute("ZonePunished", true)
			char.Parent = game:GetService("ReplicatedStorage")
			plr.Character = char
		end
		return true
	end
	plr:SetAttribute("ZonePunished", nil)
	plr:LoadCharacter()
	return true
end

function zoneEffect(plr, kind, on)
	local char = plr and plr.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end
	local name = "Zone" .. kind
	local existing = root:FindFirstChild(name)
	if existing then
		existing:Destroy()
	end
	if not on then
		return true
	end
	local inst = nil
	if kind == "Fire" then
		inst = Instance.new("Fire")
		inst.Heat = 12
		inst.Size = 8
	elseif kind == "Smoke" then
		inst = Instance.new("Smoke")
		inst.Size = 3
		inst.RiseVelocity = 6
	elseif kind == "Sparkles" then
		inst = Instance.new("Sparkles")
	end
	if not inst then
		return false
	end
	inst.Name = name
	inst.Parent = root
	return true
end

function zoneForceField(plr, on)
	local char = plr and plr.Character
	if not char then
		return false
	end
	local existing = char:FindFirstChildOfClass("ForceField")
	if existing then
		existing:Destroy()
	end
	if not on then
		return true
	end
	local ff = Instance.new("ForceField")
	ff.Visible = true
	ff.Parent = char
	return true
end

function zoneExplode(plr)
	local root = zoneRoot(plr)
	if not root then
		return false
	end
	local blast = Instance.new("Explosion")
	blast.Position = root.Position
	blast.BlastRadius = 12
	blast.BlastPressure = 0
	blast.Parent = workspace
	local hum = zoneHum(plr)
	if hum then
		hum.Health = 0
	end
	return true
end

zoneActionOnPlayerCore = function(action, requester, targetPlayer, value)
	if not requester then
		return false, "missing_target"
	end

	local reason = formatReason("")
	if type(value) == "string" then
		reason = formatReason(value)
	elseif type(value) == "table" then
		reason = formatReason(value.reason or value.text or "")
	end
	local userId = targetPlayer and targetPlayer.UserId or nil
	local targetName = targetPlayer and targetPlayer.Name or nil
	local targetDisplayName = targetPlayer and targetPlayer.DisplayName or nil
	if targetPlayer and targetPlayer:GetAttribute("AdminPanelJailed") == true
		and (action == "Bring" or action == "ServerBring" or action == "TpTo" or action == "Rejoin") then
		return false, "target_jailed"
	end

	if action == "UltimateSecurity" or action == "UnUltimateSecurity" then
		local ok, err = zoneSetUltimateSecurity(requester, targetPlayer, action == "UltimateSecurity")
		if ok then
			logModerationAction(action, requester, userId, targetName, targetDisplayName,
				action == "UltimateSecurity" and "Protected until they leave" or "Protection removed", nil, 10181046)
		end
		return ok, err

	elseif action == "VoiceMute" or action == "VoiceUnmute" then
		local ok, err = zoneVoiceMute(targetPlayer, action == "VoiceMute")
		if ok then
			logModerationAction(action, requester, userId, targetName, targetDisplayName, reason, nil, 15105570)
		end
		return ok, err

	elseif action == "Timeout" or action == "Untimeout" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local ok, message = zoneTimeoutCommand(requester, targetPlayer.UserId, action, value)
		return ok, message

	elseif action == "Kick" then
		if not targetPlayer then
			return false, "missing_target"
		end
		targetPlayer:Kick(reason)
		logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		return true

	elseif action == "Ban" then
		if targetPlayer then
			userId = targetPlayer.UserId
			targetName = targetPlayer.Name
			targetDisplayName = targetPlayer.DisplayName
		end
		if not userId then
			return false, "missing_target"
		end
		if userId == tonumber(requester.UserId) or rankValue(getRank(userId)) > 0 or (targetPlayer and isAdmin(targetPlayer)) then
			return false, "protected_admin_target"
		end
		local duration = nil
		if type(value) == "table" then
			duration = tonumber(value.duration or value.seconds or value.durationSeconds)
			reason = formatReason(value.reason or "")
		end
		local privateReason = string.format("ModeratorUserId=%s | Moderator=%s (@%s) | %s", tostring(requester.UserId or 0), tostring(requester.DisplayName or requester.Name or "N/A"), tostring(requester.Name or "N/A"), reason)
		local ok, err, robloxBan, robloxErr = applyRobloxBan(userId, reason, privateReason, duration)
		if not ok then
			return false, err or "ban_failed"
		end
		if robloxErr then
			pcall(function()
				RemoteEvent:FireClient(requester, "CommandResult", { ok = false, message = "Roblox ban unavailable here, saved as a panel ban instead." })
			end)
		end
		local bannedAt = now()
		setBanRegistryEntry(userId, {
			RobloxBan = robloxBan == true,
			UserId = userId,
			Name = targetName or safeNameFromUserId(userId),
			DisplayName = targetDisplayName or targetName or safeNameFromUserId(userId),
			Reason = reason,
			ModeratorUserId = requester.UserId or 0,
			ModeratorName = requester.DisplayName or requester.Name or "N/A",
			BannedAt = bannedAt,
			Duration = duration or -1,
			ExpiresAt = (duration and duration > 0) and (bannedAt + duration) or nil,
			Active = true,
		})
		logModerationAction(action, requester, userId, targetName or safeNameFromUserId(userId), targetDisplayName or safeNameFromUserId(userId), reason, duration and {
			{ name = "Expires in", value = tostring(duration) .. "s", inline = true },
		} or nil, 16724787)
		if targetPlayer then
			targetPlayer:Kick(zoneBanKickText(reason, (duration and duration > 0) and (bannedAt + duration) or nil))
		end
		return true

	elseif action == "Unban" then
		if targetPlayer then
			userId = targetPlayer.UserId
			targetName = targetPlayer.Name
			targetDisplayName = targetPlayer.DisplayName
		end
		if not userId then
			return false, "missing_target"
		end
		local ok, err = applyRobloxUnban(userId)
		if not ok then
			return false, err or "unban_failed"
		end
		clearBanRegistryEntry(userId)
		logModerationAction(action, requester, userId, targetName or safeNameFromUserId(userId), targetDisplayName or safeNameFromUserId(userId), reason)
		return true

	elseif action == "AddNote" or action == "Note" then
		if not targetPlayer then
			return false, "missing_target"
		end
		addNote(userId, tostring(value or reason), requester.UserId)
		logModerationAction(action, requester, userId, targetName, targetDisplayName, tostring(value or reason))
		return true

	elseif action == "TempMute" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local duration = nil
		if type(value) == "table" then
			duration = tonumber(value.duration or value.seconds or value.durationSeconds)
			reason = formatReason(value.reason or "")
		else
			duration = tonumber(value)
		end
		if not duration or duration <= 0 then
			return false, "invalid_duration"
		end
		applyMuteState(targetPlayer, true, duration, reason, requester.UserId)
		logModerationAction(action, requester, userId, targetName, targetDisplayName, reason, {
			{ name = "Duration", value = tostring(duration) .. "s", inline = true },
		}, 16753920)
		return true

	elseif action == "Heal" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local _, _, humanoid = getRootAndHumanoid(targetPlayer)
		if humanoid then
			humanoid.Health = humanoid.MaxHealth
		end
		logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		return true

	elseif action == "Respawn" then
		if not targetPlayer then
			return false, "missing_target"
		end
		targetPlayer:LoadCharacter()
		logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		return true

	elseif action == "Bring" or action == "ServerBring" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local ok = bringPlayer(targetPlayer, requester)
		if ok then
			logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		end
		return ok

	elseif action == "Gravity" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local gravity = tonumber(value)
		if not gravity then
			return false, "missing_value"
		end
		local ok = setPlayerGravity(targetPlayer, gravity)
		if ok then
			logModerationAction(action, requester, userId, targetName, targetDisplayName, ("Gravity set to %d"):format(math.floor(gravity)), {
				{ name = "Gravity", value = tostring(math.floor(gravity)), inline = true },
			})
		end
		return ok

	elseif action == "Rejoin" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local ok = pcall(function()
			TeleportService:Teleport(game.PlaceId, targetPlayer)
		end)
		if ok then
			logModerationAction(action, requester, userId, targetName, targetDisplayName, reason, nil, 5793266)
		end
		return ok

	elseif action == "Refresh" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local ok = refreshCharacter(targetPlayer)
		if ok then
			logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		end
		return ok

	elseif ZONE_EXTRA_ACTIONS[action] then
		if not targetPlayer then
			return false, "missing_target"
		end
		local ok = false
		if action == "Fling" then
			ok = zoneFling(targetPlayer, value)
		elseif action == "Trip" then
			ok = zoneTrip(targetPlayer)
		elseif action == "Spin" then
			ok = zoneSpin(targetPlayer, true)
		elseif action == "Unspin" then
			ok = zoneSpin(targetPlayer, false)
		elseif action == "Ragdoll" then
			ok = zoneRagdoll(targetPlayer, true)
		elseif action == "Unragdoll" then
			ok = zoneRagdoll(targetPlayer, false)
		elseif action == "NoGravity" then
			ok = zoneNoGravity(targetPlayer, true)
		elseif action == "Grav" then
			ok = zoneNoGravity(targetPlayer, false)
		elseif action == "Launch" then
			ok = zoneLaunch(targetPlayer, value)
		elseif action == "Fire" then
			ok = zoneEffect(targetPlayer, "Fire", true)
		elseif action == "Unfire" then
			ok = zoneEffect(targetPlayer, "Fire", false)
		elseif action == "Smoke" then
			ok = zoneEffect(targetPlayer, "Smoke", true)
		elseif action == "Unsmoke" then
			ok = zoneEffect(targetPlayer, "Smoke", false)
		elseif action == "Sparkles" then
			ok = zoneEffect(targetPlayer, "Sparkles", true)
		elseif action == "Unsparkles" then
			ok = zoneEffect(targetPlayer, "Sparkles", false)
		elseif action == "ForceField" then
			ok = zoneForceField(targetPlayer, true)
		elseif action == "UnFF" then
			ok = zoneForceField(targetPlayer, false)
		elseif action == "Explode" then
			ok = zoneExplode(targetPlayer)
		elseif action == "BigHead" then
			ok = zoneHeadSize(targetPlayer, 2.6)
		elseif action == "SmallHead" then
			ok = zoneHeadSize(targetPlayer, 0.45)
		elseif action == "NormalHead" then
			ok = zoneHeadSize(targetPlayer, 1)
		elseif action == "Fat" or action == "Thin" or action == "Squash"
			or action == "Dwarf" or action == "Giant" then
			ok = zoneBodyShape(targetPlayer, action)
		elseif action == "NormalSize" then
			ok = zoneBodyShape(targetPlayer, "Reset")
		elseif action == "Size" then
			ok = zoneSetSize(targetPlayer, value)
		elseif action == "HideName" then
			ok = zoneHideName(targetPlayer, true)
		elseif action == "ShowName" then
			ok = zoneHideName(targetPlayer, false)
		elseif action == "Ghost" or action == "Glass" then
			ok = zoneMaterial(targetPlayer, action)
		elseif action == "UnGhost" then
			ok = zoneMaterial(targetPlayer, "Reset")
		elseif action == "Paint" then
			ok = zonePaint(targetPlayer, type(value) == "table" and value.reason or value)
		elseif action == "Damage" then
			ok = zoneDamage(targetPlayer, value)
		elseif action == "SetHealth" then
			ok = zoneSetHealth(targetPlayer, value)
		elseif action == "LoopKill" then
			ok = zoneLoopKill(targetPlayer, true)
		elseif action == "StopLoop" then
			ok = zoneLoopKill(targetPlayer, false)
		elseif action == "Punish" then
			ok = zonePunish(targetPlayer, true)
		elseif action == "Unpunish" then
			ok = zonePunish(targetPlayer, false)
		elseif action == "Blind" then
			RemoteEvent:FireClient(targetPlayer, "ZoneBlind", { seconds = tonumber(value) or 5 })
			ok = true
		elseif action == "Confuse" then
			RemoteEvent:FireClient(targetPlayer, "ZoneConfuse", { seconds = tonumber(value) or 10 })
			ok = true
		elseif action == "Age" then
			local days = tonumber(targetPlayer.AccountAge) or 0
			RemoteEvent:FireClient(requester, "CommandResult", {
				ok = true,
				message = ("%s account age: %d day(s)"):format(targetPlayer.Name, days),
			})
			ok = true
		elseif action == "Ping" then
			local ms = 0
			pcall(function()
				ms = math.floor(targetPlayer:GetNetworkPing() * 1000 + 0.5)
			end)
			RemoteEvent:FireClient(requester, "CommandResult", {
				ok = true,
				message = ("%s ping: %d ms"):format(targetPlayer.Name, ms),
			})
			ok = true
		end
		if ok then
			pushUndo(requester, action, userId, targetName)
			logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		end
		return ok

	elseif action == "Sit" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local ok = sitPlayer(targetPlayer)
		if ok then
			logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		end
		return ok

	elseif action == "TpTo" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local destination = nil
		if type(value) == "string" and trim(value) ~= "" then
			local destId = resolveUserId(trim(value))
			destination = destId and Players:GetPlayerByUserId(destId) or nil
		end
		if not destination then
			return false, "missing_destination"
		end
		local ok = teleportPlayerTo(targetPlayer, destination)
		if ok then
			logModerationAction(action, requester, userId, targetName, targetDisplayName, ("to %s"):format(destination.Name))
		end
		return ok

	elseif action == "Goto" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local ok = gotoPlayer(requester, targetPlayer)
		if ok then
			logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		end
		return ok

	elseif action == "Kill" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local ok = killPlayer(targetPlayer)
		if ok then
			logModerationAction(action, requester, userId, targetName, targetDisplayName, reason, nil, 16724787)
		end
		return ok

	elseif action == "God" or action == "Ungod" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local ok = setGodState(targetPlayer, action == "God")
		if ok then
			logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		end
		return ok

	elseif action == "Jail" or action == "Unjail" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local ok = setJailState(targetPlayer, action == "Jail")
		if ok then
			logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		end
		return ok

	elseif action == "Spectate" or action == "Unspectate" then
		if action == "Spectate" and not targetPlayer then
			return false, "missing_target"
		end
		RemoteEvent:FireClient(requester, "AdminSpectate", {
			active = action == "Spectate",
			userId = targetPlayer and targetPlayer.UserId or nil,
			name = targetPlayer and targetPlayer.Name or nil,
			displayName = targetPlayer and targetPlayer.DisplayName or nil,
		})
		return true

	elseif action == "Warn" then
		if not targetPlayer then
			return false, "missing_target"
		end
		if reason == "" or reason == "No reason provided." then
			return false, "missing_reason"
		end
		RemoteEvent:FireClient(targetPlayer, "AdminWarning", {
			reason = reason,
		})
		addNote(userId, ("[Warning] %s"):format(reason), requester.UserId)
		logModerationAction(action, requester, userId, targetName, targetDisplayName, reason, nil, 16763904)
		return true

	elseif action == "Freeze" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local ok = freezeCharacter(targetPlayer, true)
		logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		return ok

	elseif action == "Unfreeze" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local ok = freezeCharacter(targetPlayer, false)
		logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		return ok

	elseif action == "SuperSpeed" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local speed = tonumber(value) or 40
		setSpeed(targetPlayer, speed)
		logModerationAction(action, requester, userId, targetName, targetDisplayName, "Speed set to " .. tostring(speed), {
			{ name = "WalkSpeed", value = tostring(speed), inline = true },
		})
		return true

	elseif action == "SuperJump" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local jump = tonumber(value) or 80
		setJump(targetPlayer, jump)
		logModerationAction(action, requester, userId, targetName, targetDisplayName, "Jump set to " .. tostring(jump), {
			{ name = "Jump", value = tostring(jump), inline = true },
		})
		return true

	elseif action == "Invisible" then
		if not targetPlayer then
			return false, "missing_target"
		end
		setVisibility(targetPlayer, false)
		logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		return true

	elseif action == "Visible" then
		if not targetPlayer then
			return false, "missing_target"
		end
		setVisibility(targetPlayer, true)
		logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		return true

	elseif action == "Noclip" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local enabled = not not value
		local noclipOk, noclipErr = setNoclip(targetPlayer, enabled)
		if noclipOk then
			logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		end
		return noclipOk, noclipErr

	elseif action == "Fly" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local flyOk, flyErr = setFlyState(targetPlayer, true)
		if flyOk then
			logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		end
		return flyOk, flyErr

	elseif action == "Unfly" then
		if not targetPlayer then
			return false, "missing_target"
		end
		local flyOk, flyErr = setFlyState(targetPlayer, false)
		if flyOk then
			logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		end
		return flyOk, flyErr

	elseif action == "Mute" then
		if not targetPlayer then
			return false, "missing_target"
		end
		muteUserChat(targetPlayer, true, nil, reason, requester.UserId)
		logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		return true

	elseif action == "Unmute" then
		if not targetPlayer then
			return false, "missing_target"
		end
		muteUserChat(targetPlayer, false)
		logModerationAction(action, requester, userId, targetName, targetDisplayName, reason)
		return true

	end

	return false, "unsupported"
end

PANIC_LOCK = {
	active = false,
	by = "",
	byUserId = 0,
	at = 0,
	reason = "",
}

function isPanicLocked()
	return PANIC_LOCK.active == true
end

function panicKickMessage()
	local reason = tostring(PANIC_LOCK.reason or "")
	if reason ~= "" then
		return "This server is locked by an admin.\nReason: " .. reason
	end
	return "This server is locked by an admin. Please try another server."
end

function panicIsExempt(player)
	if not player then
		return false
	end
	if player:GetAttribute("AdminPanelAccess") == true then
		return true
	end
	return rankValue(getRank(player.UserId)) > 0
end

function panicEnforce()
	if not isPanicLocked() then
		return 0
	end
	local kicked = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if not panicIsExempt(plr) then
			kicked = kicked + 1
			pcall(function()
				plr:Kick(panicKickMessage())
			end)
		end
	end
	return kicked
end

function setPanicLock(active, requester, reason)
	PANIC_LOCK.active = active == true
	PANIC_LOCK.reason = tostring(reason or "")
	if PANIC_LOCK.active then
		PANIC_LOCK.by = requester and requester.Name or "System"
		PANIC_LOCK.byUserId = requester and requester.UserId or 0
		PANIC_LOCK.at = os.time()
	else
		PANIC_LOCK.by = ""
		PANIC_LOCK.byUserId = 0
		PANIC_LOCK.at = 0
	end
	pcall(function()
		RemoteEvent:FireAllClients("PanicState", {
			active = PANIC_LOCK.active,
			by = PANIC_LOCK.by,
			reason = PANIC_LOCK.reason,
		})
	end)
end

Players.PlayerRemoving:Connect(function(leaving)
	if not isPanicLocked() then
		return
	end
	task.defer(function()
		if not isPanicLocked() then
			return
		end
		local remaining = 0
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= leaving and plr.Parent then
				remaining = remaining + 1
			end
		end
		if remaining <= 0 then
			setPanicLock(false, nil, "")
			logModerationAction("PanicUnlock", nil, 0, "All Players", "All Players",
				"Auto-unlocked: server is empty", nil, 3066993)
		end
	end)
end)

Players.PlayerAdded:Connect(function(plr)
	if not isPanicLocked() then
		return
	end
	task.defer(function()
		if not plr or not plr.Parent then
			return
		end
		local deadline = os.clock() + 3
		while os.clock() < deadline do
			if panicIsExempt(plr) then
				return
			end
			task.wait(0.2)
		end
		if isPanicLocked() and not panicIsExempt(plr) then
			pcall(function()
				plr:Kick(panicKickMessage())
			end)
		end
	end)
end)

-- Every player action goes through here: blocks timed-out admins, applies
-- owner / Ultimate Security protection on every path (panel, chat, command
-- bar, all/others/global, cross-server relay) and makes sure each command
-- reaches the history + webhook even when the action itself did not log.
actionOnPlayer = function(action, requester, targetPlayer, value)
	if requester and zoneIsTimedOut(requester.UserId) then
		return false, "timed_out"
	end
	if requester and targetPlayer then
		local allowed, why = canTargetUserId(requester.UserId, targetPlayer.UserId, action)
		if not allowed then
			return false, why
		end
	end
	local running = coroutine.running()
	ZONE_LOGGED_CO[running] = nil
	local ok, err = zoneActionOnPlayerCore(action, requester, targetPlayer, value)
	if ok and not ZONE_LOGGED_CO[running] then
		local reasonText = ""
		if type(value) == "string" or type(value) == "number" then
			reasonText = tostring(value)
		elseif type(value) == "table" then
			reasonText = tostring(value.reason or value.text or value.value or "")
		end
		logModerationAction(action, requester,
			targetPlayer and targetPlayer.UserId or nil,
			targetPlayer and targetPlayer.Name or nil,
			targetPlayer and targetPlayer.DisplayName or nil,
			reasonText)
	end
	ZONE_LOGGED_CO[running] = nil
	return ok, err
end

local function actionOnServer(action, requester, value)
	if requester and zoneIsTimedOut(requester.UserId) then
		return false, "timed_out"
	end
	if action == "BringAll" then
		local count = 0
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= requester and canTarget(requester, plr) then
				if bringPlayer(plr, requester) then
					count += 1
				end
			end
		end
		logModerationAction("BringAll", requester, 0, "All Players", "All Players", "", { { name = "Count", value = tostring(count), inline = true } }, 5793266)
		return true, count
	elseif action == "HealAll" then
		for _, plr in ipairs(Players:GetPlayers()) do
			local _, _, hum = getRootAndHumanoid(plr)
			if hum then hum.Health = hum.MaxHealth end
		end
		logModerationAction("HealAll", requester, 0, "All Players", "All Players", "", nil, 5793266)
		return true
	elseif action == "KillAll" then
		for _, plr in ipairs(Players:GetPlayers()) do
			local _, _, hum = getRootAndHumanoid(plr)
			if hum then hum.Health = 0 end
		end
		logModerationAction("KillAll", requester, 0, "All Players", "All Players", "", nil, 5793266)
		return true
	elseif action == "RespawnAll" then
		for _, plr in ipairs(Players:GetPlayers()) do
			plr:LoadCharacter()
		end
		logModerationAction("RespawnAll", requester, 0, "All Players", "All Players", "", nil, 5793266)
		return true
	elseif action == "PanicLock" then
		local reason = ""
		if type(value) == "table" then
			reason = trim(value.reason or "")
		end
		setPanicLock(true, requester, reason)
		local kicked = panicEnforce()
		logModerationAction("PanicLock", requester, 0, "All Players", "All Players",
			reason ~= "" and reason or "Server locked",
			{ { name = "Kicked", value = tostring(kicked), inline = true } }, 15158332)
		RemoteEvent:FireClient(requester, "ActionResult", {
			ok = true, action = action,
			message = ("Server LOCKED. %d player(s) removed."):format(kicked),
		})
		return true
	elseif action == "PanicUnlock" then
		setPanicLock(false, requester, "")
		logModerationAction("PanicUnlock", requester, 0, "All Players", "All Players", "Server unlocked", nil, 3066993)
		RemoteEvent:FireClient(requester, "ActionResult", {
			ok = true, action = action, message = "Server unlocked. Players can join again.",
		})
		return true
	elseif action == "ServerShutdown" or action == "ShutdownServer" then
		for _, plr in ipairs(Players:GetPlayers()) do
			plr:Kick("Server shutdown by admin.")
		end
		logModerationAction(action, requester, 0, "All Players", "All Players", "Server shutdown", nil, 16753920)
		return true
	elseif action == "ServerRejoin" or action == "RejoinServer" then
		pcall(function()
			TeleportService:Teleport(game.PlaceId, requester)
		end)
		logModerationAction(action, requester, requester and requester.UserId or 0, requester and requester.Name or "N/A", requester and requester.DisplayName or "N/A", "Rejoin current server", nil, 5793266)
		return true
	elseif action == "ServerUpdateAll" then
		local seconds, text = zoneUpdateParse(value)
		if text and requester then
			local filtered, filterErr = zoneFilterBroadcast(text, requester.UserId)
			if not filtered then
				RemoteEvent:FireClient(requester, "ActionResult", { ok = false, action = action, message = filterErr })
				return false
			end
			text = filtered
		end
		pcall(function()
			MessagingService:PublishAsync(ZONE_UPDATE_TOPIC, { s = seconds, t = text, j = game.JobId })
		end)
		local ok = zoneSoftRestart(requester, seconds, text)
		if ok then
			logModerationAction("ServerUpdateAll", requester, 0, "All Servers", "All Servers",
				("%s in %d s"):format(text or "Updating", seconds), nil, 16753920)
		end
		return ok

	elseif action == "ServerRestart" or action == "Restart" then
		local seconds = ZONE_RESTART_DEFAULT
		local text = nil
		local raw = value
		if type(raw) == "table" then
			raw = raw.reason or raw.text or raw.value
		end
		if type(raw) == "number" then
			seconds = raw
		elseif type(raw) == "string" then
			local clean = trim(raw)
			if clean ~= "" then
				local lead = clean:match("^(%d+)%s*(.*)$")
				if lead then
					seconds = tonumber(lead) or ZONE_RESTART_DEFAULT
					local rest = clean:match("^%d+%s*(.*)$")
					if rest and trim(rest) ~= "" then
						text = trim(rest)
					end
				else
					text = clean
				end
			end
		end
		if text and requester then
			local filtered, filterErr = zoneFilterBroadcast(text, requester.UserId)
			if not filtered then
				RemoteEvent:FireClient(requester, "ActionResult", { ok = false, action = action, message = filterErr })
				return false
			end
			text = filtered
		end
		local ok = zoneSoftRestart(requester, seconds, text)
		if ok then
			logModerationAction("ServerRestart", requester, 0, "All Players", "All Players",
				("%s in %d s"):format(text or "Updating", math.clamp(seconds, 0, 300)), nil, 16753920)
		end
		return ok

	elseif action == "SetRank" then
		if type(value) == "table" then
			local uid = value.UserId or value.userId
			local rank = value.Rank or value.rank
			if requester and not canTargetUserId(requester.UserId, uid, "SetRank") then
				return false, "protected_admin_target"
			end
			if requester and not isAutoOwnerUserId(requester.UserId) then
				if rankValue(rank) >= rankValue(getRank(requester.UserId)) then
					return false, "rank_too_high"
				end
			end
			local ok = setAdminRank(uid, rank)
			if ok then
				logModerationAction("SetRank", requester, uid, safeNameFromUserId(uid), safeNameFromUserId(uid), tostring(rank or ""), { { name = "Rank", value = tostring(rank or ""), inline = true } }, 5793266)
			end
			return ok
		end
	elseif action == "RemoveRank" then
		if type(value) == "table" then
			local uid = value.UserId or value.userId
			if requester and not canTargetUserId(requester.UserId, uid, "RemoveRank") then
				return false, "protected_admin_target"
			end
			local ok = removeAdminRank(uid)
			if ok then
				logModerationAction("RemoveRank", requester, uid, safeNameFromUserId(uid), safeNameFromUserId(uid), "", nil, 5793266)
			end
			return ok
		end
	end
	return false, "unsupported"
end

local function updateAdminAttributes(player)
	local rank = getRank(player.UserId)
	local autoOwner = isAutoOwnerUserId(player.UserId)
	local access = autoOwner or rankValue(rank) > 0
	player:SetAttribute("AdminPanelAccess", access)
	player:SetAttribute("AdminPanelRank", rank or "")
	player:SetAttribute("AdminPanelAutoOwner", autoOwner)
	player:SetAttribute("AdminPanelOwnerSource", autoOwner and autoOwnerSourceText() or "")
end

local function checkBansOnJoin(player)
	local ban = getLatestRobloxBanRecord(player.UserId)
	if ban and ban.active then
		local reason = tostring(ban.displayReason or ban.reason or "No reason provided.")
		player:Kick(zoneBanKickText(reason, ban.expiresAt))
		return
	end
end

local function resolveClientInfoFromPayload(player, payload)
	if type(payload) ~= "table" then
		return
	end
	local deviceType = payload.DeviceType or payload.deviceType
	local fps = tonumber(payload.FPS or payload.fps)
	local ping = tonumber(payload.Ping or payload.ping)
	local viewportX = tonumber(payload.ViewportX or payload.viewportX)
	local viewportY = tonumber(payload.ViewportY or payload.viewportY)
	local platform = payload.Platform or payload.platform

	if deviceType ~= nil then player:SetAttribute("AdminClientDeviceType", tostring(deviceType)) end
	if fps ~= nil then player:SetAttribute("AdminClientFPS", math.floor(fps + 0.5)) end
	if ping ~= nil then player:SetAttribute("AdminClientPing", math.max(0, math.floor(ping + 0.5))) end
	if viewportX ~= nil then player:SetAttribute("AdminClientViewportX", math.floor(viewportX + 0.5)) end
	if viewportY ~= nil then player:SetAttribute("AdminClientViewportY", math.floor(viewportY + 0.5)) end
	if platform ~= nil then player:SetAttribute("AdminClientPlatform", tostring(platform)) end

	upsertPresence(player)
end

Players.PlayerAdded:Connect(function(player)
	updateAdminAttributes(player)
	task.spawn(function()
		task.wait(1)
		if player.Parent and isAdmin(player) then
			pcall(function()
				RemoteEvent:FireClient(player, "RolesData", { ok = true, roles = zoneRolesPublic() })
			end)
		end
	end)
	checkBansOnJoin(player)
	upsertPresence(player)
	saveProfileSnapshot(player)
	task.spawn(function()
		deliverPendingWarnings(player)
	end)
	task.spawn(function()
		loadMuteStateForPlayer(player)
	end)
	task.defer(function()
		if player.Parent then
			resolveClientInfoFromPayload(player, {
				DeviceType = player:GetAttribute("AdminClientDeviceType"),
				FPS = player:GetAttribute("AdminClientFPS"),
				Ping = player:GetAttribute("AdminClientPing"),
				ViewportX = player:GetAttribute("AdminClientViewportX"),
				ViewportY = player:GetAttribute("AdminClientViewportY"),
				Platform = player:GetAttribute("AdminClientPlatform"),
			})
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	deletePresence(player.UserId)
	clearJailFor(player.UserId)
end)

for _, player in ipairs(Players:GetPlayers()) do
	updateAdminAttributes(player)
	upsertPresence(player)
	task.spawn(function()
		loadMuteStateForPlayer(player)
	end)
end

task.spawn(function()
	local attempts = 0
	while attempts < 12 do
		attempts += 1
		task.wait(1)
		if AUTO_OWNER_RESOLVED then
			break
		end
		refreshAutoOwner()
		for _, player in ipairs(Players:GetPlayers()) do
			updateAdminAttributes(player)
		end
	end
end)

task.spawn(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			upsertPresence(player)
		end
		task.wait(45)
	end
end)

AuthRF.OnServerInvoke = function(player)
	return isAdmin(player) == true
end

AdminListRF.OnServerInvoke = function(player)
	if not isAdmin(player) then
		return {}
	end
	return getAdminList()
end

BanListRF.OnServerInvoke = function(player)
	if not isAdmin(player) then
		return {}
	end
	return getBanRegistryList()
end

ResolveRF.OnServerInvoke = function(player, query)
	if not isAdmin(player) then
		return { ok = false, error = "not_authorized" }
	end
	if type(query) == "table" and query.mode == "presence" then
		return buildPresenceBatch(query.userIds)
	end
	local data = buildTargetRecord(query)
	return data
end

CreditsRF.OnServerInvoke = function(player)
	return CREDITS_DATA
end

local function handleSettingsRF(player, mode, payload)
	if mode == "set" and player and zoneIsTimedOut(player.UserId) then
		return { ok = false, error = "timed_out" }
	end
	if mode == "set" then
		if type(payload) ~= "table" then
			return { ok = false, error = "invalid_settings_payload" }
		end
		local ok, saved = savePlayerSettings(player, payload)
		if not ok then
			return { ok = false, error = tostring(saved or "settings_save_failed") }
		end
		local result = publicSettingsFromTable(saved)
		result.closePanel = true
		return result
	end
	local settings = getPlayerSettings(player)
	if mode == "get" then
		return publicSettingsFromTable(settings)
	end
	if mode == "checkPin" and type(payload) == "table" then
		local expected = tostring(settings.panelPin or "")
		local entered = trim(payload.pin or payload.code or payload.value or "")
		return { ok = true, valid = (expected ~= "" and entered == expected) or (expected == "" and entered == "") }
	end
	return publicSettingsFromTable(settings)
end

SettingsRF.OnServerInvoke = function(player, mode, payload)
	SETTINGS_REQUEST_LOCK = SETTINGS_REQUEST_LOCK or {}
	local userId = tonumber(player and player.UserId) or 0
	local cacheKey = tostring(userId)
	while SETTINGS_REQUEST_LOCK[cacheKey] == true do
		task.wait(0.05)
	end
	SETTINGS_REQUEST_LOCK[cacheKey] = true
	local callOk, result = pcall(handleSettingsRF, player, mode, payload)
	SETTINGS_REQUEST_LOCK[cacheKey] = nil
	if not callOk then
		warn("[Zone Panel] Settings request failed for userId", userId, "-", tostring(result))
		return { ok = false, error = tostring(result or "settings_request_failed") }
	end
	return result
end


function initAnnouncementSystem()
	local announceTimerStore = DataStoreService:GetDataStore(ANNOUNCE_TIMER_STORE_NAME)
	local CurrentVote = nil
	local CurrentAbuseTimer = nil

	local function announcePublish(payload)
		payload = payload or {}
		payload.SourceJobId = payload.SourceJobId or game.JobId
		pcall(function()
			MessagingService:PublishAsync(ANNOUNCE_TOPIC, payload)
		end)
	end

	local function announceFireLocal(payload)
		AnnounceNotifyRE:FireAllClients(payload)
	end

	local function saveAbuseTimerState(timerData)
		if timerData then
			local payload = {
				TimerId = tostring(timerData.TimerId or HttpService:GenerateGUID(false)),
				Title = tostring(timerData.Title or "Admin Abuse"),
				EndsAt = tonumber(timerData.EndsAt) or 0,
				Duration = tonumber(timerData.Duration) or 0,
				StartedBy = tostring(timerData.StartedBy or "System"),
				StartedByUserId = tonumber(timerData.StartedByUserId) or 0,
				SourceJobId = tostring(timerData.SourceJobId or game.JobId),
				UpdatedAt = os.time(),
			}
			pcall(function()
				announceTimerStore:SetAsync(ANNOUNCE_TIMER_STORE_KEY, payload)
			end)
			return payload
		end
		pcall(function()
			announceTimerStore:RemoveAsync(ANNOUNCE_TIMER_STORE_KEY)
		end)
		return nil
	end

	local function loadAbuseTimerState()
		local ok, result = pcall(function()
			return announceTimerStore:GetAsync(ANNOUNCE_TIMER_STORE_KEY)
		end)
		if not ok or type(result) ~= "table" then
			return nil
		end
		local endsAt = tonumber(result.EndsAt)
		if not endsAt or endsAt <= os.time() then
			saveAbuseTimerState(nil)
			return nil
		end
		return {
			TimerId = tostring(result.TimerId or HttpService:GenerateGUID(false)),
			Title = tostring(result.Title or "Admin Abuse"),
			EndsAt = endsAt,
			Duration = tonumber(result.Duration) or math.max(0, endsAt - os.time()),
			StartedBy = tostring(result.StartedBy or "System"),
			StartedByUserId = tonumber(result.StartedByUserId) or 0,
			SourceJobId = tostring(result.SourceJobId or game.JobId),
		}
	end

	local function buildVoteStartPayload(voteData)
		return {
			Kind = "VoteStart",
			VoteId = voteData.VoteId,
			Sender = voteData.Starter,
			SenderUserId = voteData.StarterUserId,
			Question = voteData.Question,
			Options = { voteData.Options[1], voteData.Options[2] },
			Counts = { voteData.Counts[1], voteData.Counts[2] },
			Duration = ANNOUNCE_VOTE_DURATION,
			EndsAt = voteData.EndsAt,
			SourceJobId = voteData.SourceJobId or game.JobId,
		}
	end

	local function buildVoteUpdatePayload(voteData)
		return {
			Kind = "VoteUpdate",
			VoteId = voteData.VoteId,
			Sender = voteData.Starter,
			SenderUserId = voteData.StarterUserId,
			Question = voteData.Question,
			Options = { voteData.Options[1], voteData.Options[2] },
			Counts = { voteData.Counts[1], voteData.Counts[2] },
			EndsAt = voteData.EndsAt,
			SourceJobId = voteData.SourceJobId or game.JobId,
		}
	end

	local function buildVoteEndPayload(voteData)
		local a = tonumber(voteData.Counts and voteData.Counts[1]) or 0
		local b = tonumber(voteData.Counts and voteData.Counts[2]) or 0
		local winner = "Draw"
		if a > b then
			winner = voteData.Options[1]
		elseif b > a then
			winner = voteData.Options[2]
		end
		return {
			Kind = "VoteEnd",
			VoteId = voteData.VoteId,
			Sender = voteData.Starter,
			SenderUserId = voteData.StarterUserId,
			Question = voteData.Question,
			Options = { voteData.Options[1], voteData.Options[2] },
			Counts = { a, b },
			Winner = winner,
			DisplaySeconds = ANNOUNCE_DISPLAY_SECONDS,
			EndsAt = voteData.EndsAt,
			SourceJobId = voteData.SourceJobId or game.JobId,
		}
	end

	local function scheduleVoteEnd(voteId, endsAt)
		task.delay(math.max(0, (tonumber(endsAt) or os.time()) - os.time()), function()
			if not CurrentVote or CurrentVote.VoteId ~= voteId then
				return
			end
			announceFireLocal(buildVoteEndPayload(CurrentVote))
			CurrentVote = nil
		end)
	end

	local function applyVoteStart(voteData)
		if type(voteData) ~= "table" then
			return
		end
		local voteId = tostring(voteData.VoteId or "")
		if voteId == "" then
			return
		end
		if CurrentVote and CurrentVote.VoteId == voteId then
			return
		end
		CurrentVote = {
			VoteId = voteId,
			Question = tostring(voteData.Question or "Vote"),
			Options = {
				tostring((voteData.Options and voteData.Options[1]) or "Option A"),
				tostring((voteData.Options and voteData.Options[2]) or "Option B"),
			},
			Counts = {
				tonumber(voteData.Counts and voteData.Counts[1]) or 0,
				tonumber(voteData.Counts and voteData.Counts[2]) or 0,
			},
			UserVotes = {},
			EndsAt = tonumber(voteData.EndsAt) or (os.time() + ANNOUNCE_VOTE_DURATION),
			Starter = tostring(voteData.Sender or voteData.Starter or "System"),
			StarterUserId = tonumber(voteData.SenderUserId or voteData.StarterUserId) or 0,
			SourceJobId = tostring(voteData.SourceJobId or game.JobId),
		}
		announceFireLocal(buildVoteStartPayload(CurrentVote))
		scheduleVoteEnd(CurrentVote.VoteId, CurrentVote.EndsAt)
	end

	local function applyVoteCast(voteCast)
		if not CurrentVote or type(voteCast) ~= "table" then
			return
		end
		local voteId = tostring(voteCast.VoteId or "")
		if voteId == "" or CurrentVote.VoteId ~= voteId then
			return
		end
		local userId = tonumber(voteCast.UserId)
		local optionIndex = math.floor(tonumber(voteCast.OptionIndex) or 0)
		if not userId or optionIndex < 1 or optionIndex > 2 then
			return
		end
		local previousVote = CurrentVote.UserVotes[userId]
		if previousVote == optionIndex then
			return
		end
		if previousVote and CurrentVote.Counts[previousVote] then
			CurrentVote.Counts[previousVote] = math.max(0, (CurrentVote.Counts[previousVote] or 0) - 1)
		end
		CurrentVote.UserVotes[userId] = optionIndex
		CurrentVote.Counts[optionIndex] = (CurrentVote.Counts[optionIndex] or 0) + 1
		announceFireLocal(buildVoteUpdatePayload(CurrentVote))
	end

	local function buildAbuseTimerStartPayload(timerData)
		return {
			Kind = "AdminAbuseTimerStart",
			TimerId = timerData.TimerId,
			Title = timerData.Title or "Admin Abuse",
			EndsAt = timerData.EndsAt,
			Duration = timerData.Duration,
			StartedBy = timerData.StartedBy,
			StartedByUserId = timerData.StartedByUserId,
			SourceJobId = timerData.SourceJobId or game.JobId,
		}
	end

	local function buildAbuseTimerStopPayload(timerData, reason)
		return {
			Kind = "AdminAbuseTimerStop",
			TimerId = timerData and timerData.TimerId or nil,
			Title = timerData and (timerData.Title or "Admin Abuse") or "Admin Abuse",
			Reason = reason or "stopped",
			SourceJobId = game.JobId,
		}
	end

	local function clearAbuseTimer(reason, publishToo)
		if not CurrentAbuseTimer then
			return
		end
		local timerData = CurrentAbuseTimer
		CurrentAbuseTimer = nil
		saveAbuseTimerState(nil)
		local payload = buildAbuseTimerStopPayload(timerData, reason)
		announceFireLocal(payload)
		if publishToo ~= false then
			announcePublish(payload)
		end
	end

	local function applyAbuseTimerStart(timerData, publishToo)
		if type(timerData) ~= "table" then
			return
		end
		local endsAt = tonumber(timerData.EndsAt)
		if not endsAt then
			return
		end
		local remaining = math.max(0, math.floor(endsAt - os.time()))
		if remaining <= 0 then
			saveAbuseTimerState(nil)
			return
		end
		local timerId = tostring(timerData.TimerId or HttpService:GenerateGUID(false))
		CurrentAbuseTimer = {
			TimerId = timerId,
			Title = tostring(timerData.Title or "Admin Abuse"),
			EndsAt = endsAt,
			Duration = tonumber(timerData.Duration) or remaining,
			StartedBy = tostring(timerData.StartedBy or "System"),
			StartedByUserId = tonumber(timerData.StartedByUserId) or 0,
			SourceJobId = tostring(timerData.SourceJobId or game.JobId),
		}
		if publishToo == true then
			saveAbuseTimerState(CurrentAbuseTimer)
		end
		local payload = buildAbuseTimerStartPayload(CurrentAbuseTimer)
		announceFireLocal(payload)
		if publishToo == true then
			announcePublish(payload)
		end
		task.delay(remaining, function()
			if CurrentAbuseTimer and CurrentAbuseTimer.TimerId == timerId then
				clearAbuseTimer("expired", true)
			end
		end)
	end

	local function sendCurrentAbuseTimer(player)
		if not CurrentAbuseTimer then
			return
		end
		local remaining = math.max(0, math.floor((tonumber(CurrentAbuseTimer.EndsAt) or os.time()) - os.time()))
		if remaining <= 0 then
			CurrentAbuseTimer = nil
			return
		end
		AnnounceNotifyRE:FireClient(player, buildAbuseTimerStartPayload(CurrentAbuseTimer))
	end

	function handleAnnounceAction(player, action, payload)
		payload = type(payload) == "table" and payload or {}

		if ACTION_RULES[action] and not zoneCanUseAction(player.UserId, action) then
			RemoteEvent:FireClient(player, "ActionResult", { ok = false, action = action, message = "You do not have permission for that." })
			return
		end

		if action == "Announce" then
			local text = trim(payload.text or "")
			if text == "" then
				RemoteEvent:FireClient(player, "ActionResult", { ok = false, action = action, message = "Message is empty." })
				return
			end
			local filtered, filterErr = zoneFilterBroadcast(text, player.UserId)
			if not filtered then
				RemoteEvent:FireClient(player, "ActionResult", { ok = false, action = action, message = filterErr })
				return
			end
			local isGlobal = string.lower(tostring(payload.scope or "server")) == "global"
			local data = {
				Kind = "Announcement",
				Sender = player.Name,
				SenderUserId = player.UserId,
				Message = filtered,
				DisplaySeconds = zoneAnnounceSeconds(payload.seconds),
				SourceJobId = game.JobId,
			}
			announceFireLocal(data)
			if isGlobal then
				announcePublish(data)
			end
			logModerationAction("Announce", player, nil, nil, nil,
				("[%s] %s"):format(isGlobal and "Global" or "This server", text), nil, 3447003)
			RemoteEvent:FireClient(player, "ActionResult", {
				ok = true,
				action = action,
				message = isGlobal and "Announcement sent to every server." or "Announcement sent to this server.",
			})
			return
		end

		if action == "StartVote" then
			local question = trim(payload.question or "")
			local option1 = trim(payload.option1 or "")
			local option2 = trim(payload.option2 or "")
			if question == "" or option1 == "" or option2 == "" then
				RemoteEvent:FireClient(player, "ActionResult", { ok = false, action = action, message = "Question and both options are required." })
				return
			end
			local filterErr
			question, filterErr = zoneFilterBroadcast(question, player.UserId)
			if question then
				option1, filterErr = zoneFilterBroadcast(option1, player.UserId)
			end
			if question and option1 then
				option2, filterErr = zoneFilterBroadcast(option2, player.UserId)
			end
			if not question or not option1 or not option2 then
				RemoteEvent:FireClient(player, "ActionResult", { ok = false, action = action, message = filterErr })
				return
			end
			local voteData = {
				VoteId = HttpService:GenerateGUID(false),
				Question = question,
				Options = { option1, option2 },
				Counts = { 0, 0 },
				UserVotes = {},
				EndsAt = os.time() + ANNOUNCE_VOTE_DURATION,
				Starter = player.Name,
				StarterUserId = player.UserId,
				SourceJobId = game.JobId,
			}
			applyVoteStart(voteData)
			announcePublish(buildVoteStartPayload(voteData))
			logModerationAction("StartVote", player, nil, nil, nil, voteData.Question, nil, 10181046)
			RemoteEvent:FireClient(player, "ActionResult", { ok = true, action = action, message = "Vote started." })
			return
		end

		if action == "StartAbuseTimer" then
			local minutes = math.floor(tonumber(payload.minutes) or 0)
			if minutes < 1 then
				RemoteEvent:FireClient(player, "ActionResult", { ok = false, action = action, message = "Enter a valid number of minutes." })
				return
			end
			local duration = minutes * 60
			local title = trim(payload.title or "")
			if title ~= "" then
				local filterErr
				title, filterErr = zoneFilterBroadcast(title, player.UserId)
				if not title then
					RemoteEvent:FireClient(player, "ActionResult", { ok = false, action = action, message = filterErr })
					return
				end
			end
			applyAbuseTimerStart({
				TimerId = HttpService:GenerateGUID(false),
				Title = title ~= "" and title or "Admin Abuse",
				EndsAt = os.time() + duration,
				Duration = duration,
				StartedBy = player.Name,
				StartedByUserId = player.UserId,
				SourceJobId = game.JobId,
			}, true)
			logModerationAction("StartAbuseTimer", player, nil, nil, nil, minutes .. " minutes", nil, 15105570)
			RemoteEvent:FireClient(player, "ActionResult", { ok = true, action = action, message = ("Timer started for %d minute(s)."):format(minutes) })
			return
		end

		if action == "StopAbuseTimer" then
			clearAbuseTimer("manual_stop", true)
			logModerationAction("StopAbuseTimer", player, nil, nil, nil, "Manual stop", nil, 15158332)
			RemoteEvent:FireClient(player, "ActionResult", { ok = true, action = action, message = "Timer stopped." })
			return
		end
	end

	AnnounceVoteRE.OnServerEvent:Connect(function(player, voteId, optionIndex)
		if type(voteId) ~= "string" or type(optionIndex) ~= "number" then
			return
		end
		if not CurrentVote or CurrentVote.VoteId ~= voteId then
			return
		end
		optionIndex = math.floor(optionIndex)
		if optionIndex < 1 or optionIndex > 2 then
			return
		end
		local previousVote = CurrentVote.UserVotes[player.UserId]
		if previousVote == optionIndex then
			return
		end
		if previousVote and CurrentVote.Counts[previousVote] then
			CurrentVote.Counts[previousVote] = math.max(0, (CurrentVote.Counts[previousVote] or 0) - 1)
		end
		CurrentVote.UserVotes[player.UserId] = optionIndex
		CurrentVote.Counts[optionIndex] = (CurrentVote.Counts[optionIndex] or 0) + 1
		announceFireLocal(buildVoteUpdatePayload(CurrentVote))
		announcePublish({
			Kind = "VoteCast",
			VoteId = CurrentVote.VoteId,
			UserId = player.UserId,
			Username = player.Name,
			OptionIndex = optionIndex,
			SourceJobId = game.JobId,
		})
	end)

	pcall(function()
		MessagingService:SubscribeAsync(ANNOUNCE_TOPIC, function(response)
			local data = response.Data
			if type(data) ~= "table" then
				return
			end
			if data.SourceJobId == game.JobId then
				return
			end
			local kind = tostring(data.Kind or "Announcement")
			if kind == "VoteStart" then
				applyVoteStart(data)
				return
			end
			if kind == "VoteCast" then
				applyVoteCast(data)
				return
			end
			if kind == "AdminAbuseTimerStart" then
				applyAbuseTimerStart(data, false)
				return
			end
			if kind == "AdminAbuseTimerStop" then
				CurrentAbuseTimer = nil
				saveAbuseTimerState(nil)
				announceFireLocal(data)
				return
			end
			announceFireLocal(data)
		end)
	end)

	do
		local persisted = loadAbuseTimerState()
		if persisted then
			applyAbuseTimerStart(persisted, false)
		end
	end

	Players.PlayerAdded:Connect(function(plr)
		task.defer(function()
			sendCurrentAbuseTimer(plr)
		end)
	end)

	for _, existing in ipairs(Players:GetPlayers()) do
		task.defer(function()
			sendCurrentAbuseTimer(existing)
		end)
	end

end

initAnnouncementSystem()

local function initializeAdminPanelStats()
	local StatsStore = DataStoreService:GetDataStore("AdminPanelStats_v1")
	local LivePresenceMap = MemoryStoreService:GetSortedMap("AdminPanelLivePresence_v1")

	local STATS_SERIES = {}
	local STATS_SEEN_TODAY = {}
	local STATS_SEEN_EVER = {}
	local STATS_LOOP_STARTED = false
	local STATS_HOURS = {}
	local STATS_HISTORY_CACHE = nil
	local STATS_HISTORY_LAST_FLUSH = 0
	local STATS_PEAK_CACHE = {}
	local STATS_PEAK_PENDING = {}
	local STATS_PEAK_LAST_WRITE = {}

	local function statsDayKey()
		return os.date("!%Y-%m-%d")
	end

	local function statsIncrement(key, delta)
		pcall(function()
			StatsStore:UpdateAsync(key, function(old)
				return (tonumber(old) or 0) + delta
			end)
		end)
	end

	local function statsMax(key, value)
		value = tonumber(value) or 0
		local cached = STATS_PEAK_CACHE[key]
		if cached == nil then
			local ok, stored = pcall(function()
				return StatsStore:GetAsync(key)
			end)
			cached = ok and (tonumber(stored) or 0) or 0
			STATS_PEAK_CACHE[key] = cached
		end
		local desired = math.max(value, tonumber(STATS_PEAK_PENDING[key]) or 0)
		if desired <= cached then
			STATS_PEAK_PENDING[key] = nil
			return
		end
		local now = os.clock()
		if now - (STATS_PEAK_LAST_WRITE[key] or -math.huge) < 180 then
			STATS_PEAK_PENDING[key] = desired
			return
		end
		STATS_PEAK_LAST_WRITE[key] = now
		STATS_PEAK_PENDING[key] = nil
		STATS_PEAK_CACHE[key] = desired
		local ok, stored = pcall(function()
			return StatsStore:UpdateAsync(key, function(old)
				return math.max(tonumber(old) or 0, desired)
			end)
		end)
		if ok then
			STATS_PEAK_CACHE[key] = math.max(desired, tonumber(stored) or 0)
		else
			STATS_PEAK_CACHE[key] = cached
			STATS_PEAK_PENDING[key] = desired
		end
	end

	local function statsGet(key)
		local cached = STATS_PEAK_CACHE[key]
		if cached ~= nil then
			return tonumber(cached) or 0
		end
		local ok, value = pcall(function()
			return StatsStore:GetAsync(key)
		end)
		if ok then
			return tonumber(value) or 0
		end
		return 0
	end

	local function statsHistoryGet()
		if STATS_HISTORY_CACHE == nil then
			local ok, value = pcall(function()
				return StatsStore:GetAsync("stats:history")
			end)
			if ok and type(value) == "table" then
				STATS_HISTORY_CACHE = value
			else
				STATS_HISTORY_CACHE = {}
			end
		end
		return STATS_HISTORY_CACHE
	end

	local function statsFlushHistory()
		local now = os.time()
		if now - STATS_HISTORY_LAST_FLUSH < 240 then
			return
		end
		STATS_HISTORY_LAST_FLUSH = now
		local day = statsDayKey()
		local todayUnique = statsGet("day:" .. day)
		local peakDay = statsGet("peak:day:" .. day)
		local ok, value = pcall(function()
			return StatsStore:UpdateAsync("stats:history", function(old)
				if type(old) ~= "table" then
					old = {}
				end
				local found = false
				for _, item in ipairs(old) do
					if tostring(item.d) == day then
						item.u = math.max(tonumber(item.u) or 0, todayUnique)
						item.p = math.max(tonumber(item.p) or 0, peakDay)
						found = true
						break
					end
				end
				if not found then
					table.insert(old, { d = day, u = todayUnique, p = peakDay })
				end
				table.sort(old, function(a, b)
					return tostring(a.d) < tostring(b.d)
				end)
				while #old > 1095 do
					table.remove(old, 1)
				end
				return old
			end)
		end)
		if ok and type(value) == "table" then
			STATS_HISTORY_CACHE = value
		end
	end

	local function statsSample()
		local count = #Players:GetPlayers()
		table.insert(STATS_SERIES, { t = os.time(), c = count })
		if #STATS_SERIES > 60 then
			table.remove(STATS_SERIES, 1)
		end
		local day = statsDayKey()
		statsMax("peak:day:" .. day, count)
		statsMax("peak:all", count)
		pcall(function()
			LivePresenceMap:SetAsync("srv:" .. tostring(game.JobId), count, 150)
		end)
		local hourKey = os.date("!%Y-%m-%d %H")
		local lastHour = STATS_HOURS[#STATS_HOURS]
		if lastHour and lastHour.h == hourKey then
			if count > lastHour.v then
				lastHour.v = count
			end
		else
			table.insert(STATS_HOURS, { h = hourKey, v = count })
			if #STATS_HOURS > 24 then
				table.remove(STATS_HOURS, 1)
			end
		end
		statsFlushHistory()
	end

	local function statsTotalLive()
		local total = #Players:GetPlayers()
		local ok, items = pcall(function()
			return LivePresenceMap:GetRangeAsync(Enum.SortDirection.Ascending, 100)
		end)
		if ok and type(items) == "table" then
			total = 0
			for _, kv in ipairs(items) do
				if tostring(kv.key):sub(1, 4) == "srv:" then
					total = total + (tonumber(kv.value) or 0)
				end
			end
			if total <= 0 then
				total = #Players:GetPlayers()
			end
		end
		return total
	end

	local function statsTrackPlayer(player)
		local uid = tonumber(player.UserId) or 0
		if uid <= 0 then
			return
		end
		local day = statsDayKey()
		if STATS_SEEN_TODAY[uid] ~= day then
			STATS_SEEN_TODAY[uid] = day
			task.spawn(function()
				local memKey = "seen:" .. day .. ":" .. uid
				local ok, seen = pcall(function()
					return LivePresenceMap:GetAsync(memKey)
				end)
				if ok and seen == nil then
					pcall(function()
						LivePresenceMap:SetAsync(memKey, 1, 40 * 3600)
					end)
					statsIncrement("day:" .. day, 1)
				end
			end)
		end
		if STATS_SEEN_EVER[uid] ~= true then
			STATS_SEEN_EVER[uid] = true
			task.spawn(function()
				local ok, seen = pcall(function()
					return StatsStore:GetAsync("seen:u:" .. uid)
				end)
				if ok and seen ~= true then
					pcall(function()
						StatsStore:SetAsync("seen:u:" .. uid, true)
					end)
					statsIncrement("total:unique", 1)
				end
			end)
		end
	end

	Players.PlayerAdded:Connect(function(player)
		statsTrackPlayer(player)
	end)
	for _, existingPlayer in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			statsTrackPlayer(existingPlayer)
		end)
	end

	local function startStatsSampler()
		if STATS_LOOP_STARTED then
			return
		end
		STATS_LOOP_STARTED = true
		statsSample()
		task.spawn(function()
			while true do
				task.wait(60)
				statsSample()
			end
		end)
	end
	startStatsSampler()

	StatsRF.OnServerInvoke = function(player, mode)
		if not isAdmin(player) then
			return { ok = false }
		end
		startStatsSampler()
		task.spawn(function()
			statsFlushHistory()
		end)
		local day = statsDayKey()
		local playedToday = statsGet("day:" .. day)
		local peakToday = statsGet("peak:day:" .. day)
		local series = {}
		for _, point in ipairs(STATS_SERIES) do
			table.insert(series, { t = point.t, c = point.c })
		end
		local hours = {}
		for _, item in ipairs(STATS_HOURS) do
			table.insert(hours, { h = item.h, v = item.v })
		end
		local days = {}
		local updatedToday = false
		for _, item in ipairs(statsHistoryGet()) do
			local entry = { d = tostring(item.d), u = tonumber(item.u) or 0, p = tonumber(item.p) or 0 }
			if entry.d == day then
				entry.u = math.max(entry.u, playedToday)
				entry.p = math.max(entry.p, peakToday)
				updatedToday = true
			end
			table.insert(days, entry)
		end
		if not updatedToday then
			table.insert(days, { d = day, u = playedToday, p = peakToday })
		end
		return {
			ok = true,
			serverNow = #Players:GetPlayers(),
			totalLive = statsTotalLive(),
			playedToday = playedToday,
			totalUnique = statsGet("total:unique"),
			peakToday = peakToday,
			peakAll = statsGet("peak:all"),
			series = series,
			hours = hours,
			days = days,
		}
	end
end
initializeAdminPanelStats()

HistoryRF.OnServerInvoke = function(player, mode)
	if not isAdmin(player) then
		return { ok = false, error = "not_authorized" }
	end
	if mode == "clear" then
		if rankValue(getRank(player.UserId)) < rankValue("Admin") then
			return { ok = false, error = "not_authorized" }
		end
		HISTORY_ENTRIES = {}
		HISTORY_DIRTY = true
		historySave()
		return { ok = true, entries = {} }
	end
	return { ok = true, entries = HISTORY_ENTRIES }
end

ServerDataRF.OnServerInvoke = function(player)
	if not isAdmin(player) then
		return { ok = false, error = "not_authorized" }
	end
	return getServerData(player)
end


function commandLookupAction(word)
	word = string.lower(trim(word or ""))
	if word == "" then
		return nil
	end
	if COMMAND_ALIASES[word] then
		return COMMAND_ALIASES[word]
	end
	for actionName in pairs(ACTION_RULES) do
		if string.lower(actionName) == word then
			return actionName
		end
	end

	local best = nil
	for alias, actionName in pairs(COMMAND_ALIASES) do
		if string.sub(alias, 1, #word) == word then
			if best == nil or alias < best then
				best = alias
			end
		end
	end
	if best then
		return COMMAND_ALIASES[best]
	end

	local bestAction = nil
	for actionName in pairs(ACTION_RULES) do
		if string.sub(string.lower(actionName), 1, #word) == word then
			if bestAction == nil or actionName < bestAction then
				bestAction = actionName
			end
		end
	end
	return bestAction
end

-- "5 reason" -> "5", "reason"; "5" -> "5", ""; "3rd strike" -> nil (no minutes)
function commandMinutesSplit(text)
	text = tostring(text or "")
	local minutesText, rest = string.match(text, "^(%d+)%s+(.*)$")
	if minutesText then
		return minutesText, rest
	end
	minutesText = string.match(text, "^(%d+)$")
	if minutesText then
		return minutesText, ""
	end
	return nil, nil
end

function commandSplit(text)
	local parts = {}
	for word in string.gmatch(tostring(text or ""), "%S+") do
		table.insert(parts, word)
	end
	return parts
end

function commandJoinFrom(parts, startIndex)
	local out = {}
	for i = startIndex, #parts do
		table.insert(out, parts[i])
	end
	return trim(table.concat(out, " "))
end

COMMAND_SELF_DEFAULT = {
	Gravity = true,
	Refresh = true,
	Sit = true,
	God = true,
	Ungod = true,
	Fly = true,
	Unfly = true,
	Noclip = true,
	Invisible = true,
	Visible = true,
	SuperSpeed = true,
	SuperJump = true,
	Heal = true,
	Respawn = true,
	Freeze = true,
	Unfreeze = true,
	Kill = true,
	Jail = true,
	Unjail = true,
	Unspectate = true,
	Age = true,
	BigHead = true,
	Blind = true,
	Confuse = true,
	Damage = true,
	Dwarf = true,
	Explode = true,
	Fat = true,
	Fire = true,
	Fling = true,
	ForceField = true,
	Ghost = true,
	Giant = true,
	Glass = true,
	Grav = true,
	HideName = true,
	Launch = true,
	NoGravity = true,
	NormalHead = true,
	NormalSize = true,
	Paint = true,
	Ping = true,
	Ragdoll = true,
	SetHealth = true,
	ShowName = true,
	Size = true,
	SmallHead = true,
	Smoke = true,
	Sparkles = true,
	Spin = true,
	Squash = true,
	Thin = true,
	Trip = true,
	UnGhost = true,
	Unfire = true,
	Unpunish = true,
	Unragdoll = true,
	Unsmoke = true,
	Unsparkles = true,
	Unspin = true,
	Bring = false,
}

COMMAND_BLOCK_ALL = {
	Rejoin = true,
	Goto = true,
	Spectate = true,
	Unspectate = true,
	Ban = true,
	Unban = true,
	SetRank = true,
	RemoveRank = true,
	AddNote = true,
	Note = true,
	UltimateSecurity = true,
	UnUltimateSecurity = true,
	Timeout = true,
	Untimeout = true,
}

function commandIsSelfWord(word)
	word = string.lower(trim(word or ""))
	return word == "me" or word == "myself" or word == "self"
end

function commandIsAllWord(word)
	word = string.lower(trim(word or ""))
	return word == "all" or word == "everyone" or word == "others"
end

function commandIsGlobalWord(word)
	word = string.lower(trim(word or ""))
	return word == "global" or word == "allservers" or word == "everywhere"
end

ZONE_GLOBAL_TOPIC = "ZonePanelGlobalCommand"

ZONE_GLOBAL_BLOCK = {
	SetRank = true,
	RemoveRank = true,
	Ban = true,
	Unban = true,
	PanicLock = true,
	PanicUnlock = true,
	Undo = true,
	Age = true,
	Ping = true,
	Esp = true,
	Spectate = true,
	Unspectate = true,
	Goto = true,
	TpTo = true,
	Bring = true,
	UltimateSecurity = true,
	UnUltimateSecurity = true,
	Timeout = true,
	Untimeout = true,
}

function zoneGlobalProxyRequester(payload)
	local userId = tonumber(payload and payload.byUserId) or 0
	if userId <= 0 then
		return nil
	end
	local live = Players:GetPlayerByUserId(userId)
	if live then
		return live
	end
	local name = tostring((payload and payload.by) or "")
	if name == "" then
		name = "Global"
	end
	return {
		UserId = userId,
		Name = name,
		DisplayName = name,
	}
end

function zoneApplyGlobalPayload(payload)
	if type(payload) ~= "table" then
		return
	end
	if tostring(payload.SourceJobId or "") == tostring(game.JobId) then
		return
	end
	local action = tostring(payload.action or "")
	if action == "" or ZONE_GLOBAL_BLOCK[action] then
		return
	end
	local requester = zoneGlobalProxyRequester(payload)
	if not requester then
		return
	end
	if rankValue(getRank(requester.UserId)) < rankValue("Admin") then
		return
	end
	local value = payload.value
	for _, target in ipairs(Players:GetPlayers()) do
		if canTargetUserId(requester.UserId, target.UserId, action) then
			pcall(function()
				actionOnPlayer(action, requester, target, value ~= "" and value or nil)
			end)
		end
	end
end

task.spawn(function()
	pcall(function()
		MessagingService:SubscribeAsync(ZONE_GLOBAL_TOPIC, function(message)
			zoneApplyGlobalPayload(message and message.Data)
		end)
	end)
end)

function commandRunOnAll(player, action, value, othersOnly)
	local done, failed = 0, 0
	for _, target in ipairs(Players:GetPlayers()) do
		local skip = othersOnly and target.UserId == player.UserId
		if not skip and canTarget(player, target, action) then
			local ok = pcall(function()
				return actionOnPlayer(action, player, target, value ~= "" and value or nil)
			end)
			if ok then
				done = done + 1
			else
				failed = failed + 1
			end
		end
	end
	if done == 0 then
		return false, ("%s could not be applied to anyone."):format(action)
	end
	return true, ("%s applied to %d player(s)."):format(action, done)
end

function commandRunGlobal(player, action, value)
	if ZONE_GLOBAL_BLOCK[action] then
		return false, ("%s cannot be used globally."):format(action)
	end
	if zoneActionBlocked(player.UserId, action) then
		return false, ("Your rank cannot use %s."):format(action)
	end
	if rankValue(getRank(player.UserId)) < rankValue("Admin") and not isAutoOwnerUserId(player.UserId) then
		return false, "Global commands need Admin rank."
	end
	local settings = getPlayerSettings(player)
	if type(settings) ~= "table" or settings.globalCommands ~= true then
		return false, "Global commands are disabled. Enable them in Settings."
	end

	local payload = {
		action = action,
		value = value,
		by = player.Name,
		byUserId = player.UserId,
		SourceJobId = game.JobId,
	}
	pcall(function()
		MessagingService:PublishAsync(ZONE_GLOBAL_TOPIC, payload)
	end)

	commandRunOnAll(player, action, value, false)
	return true, ("%s sent to every server."):format(action)
end

function commandNoTargetAction(action)
	if action == "Disco" or action == "UnDisco" then
		return true
	end
	if action == "ServerRestart" or action == "Restart" or action == "ServerUpdateAll" then
		return true
	end
	return action == "Esp" or action == "Timer" or action == "Undo" or action == "Time"
		or action == "BringAll" or action == "HealAll" or action == "KillAll"
		or action == "RespawnAll" or action == "ServerShutdown" or action == "ShutdownServer" or action == "ServerUpdateAll"
		or action == "ServerRejoin" or action == "RejoinServer" or action == "PanicLock"
		or action == "PanicUnlock" or action == "Announce"
end

PANEL_OPEN_WORDS = {
	panel = true,
	adminpanel = true,
	menu = true,
	cmds = true,
	commands = true,
}

function commandRunFor(player, rawText)
	local text = trim(rawText or "")
	if text == "" then
		return false, "Empty command."
	end
	local firstChar = string.sub(text, 1, 1)
	if firstChar == ";" or firstChar == COMMAND_PREFIX then
		text = trim(string.sub(text, 2))
	end

	local parts = commandSplit(text)
	if #parts == 0 then
		return false, "Empty command."
	end

	if PANEL_OPEN_WORDS[string.lower(trim(parts[1] or ""))] then
		RemoteEvent:FireClient(player, "OpenCommandBar")
		return true, ""
	end

	local action = commandLookupAction(parts[1])
	if not action then
		return false, ("Unknown command: %s"):format(tostring(parts[1]))
	end

	if zoneIsTimedOut(player.UserId) then
		return false, protectionMessage("timed_out")
	end

	if ACTION_RULES[action] and not zoneCanUseAction(player.UserId, action) then
		return false, ("Your rank does not allow %s."):format(action)
	end

	if commandNoTargetAction(action) then
		if action == "Disco" or action == "UnDisco" then
			zoneDisco(action == "Disco")
			logModerationAction(action, player, nil, nil, nil, nil)
			return true, (action == "Disco") and "Disco on." or "Disco off."
		end
		if action == "Esp" then
			RemoteEvent:FireClient(player, "ToggleEsp")
			logModerationAction("Esp", player, nil, nil, nil, "Toggled")
			return true, "ESP toggled."
		end
		if action == "Announce" then
			local message = commandJoinFrom(parts, 2)
			if message == "" then
				return false, "Announce needs a message."
			end
			handleAnnounceAction(player, action, { text = message, scope = "global" })
			return true, "Announcement sent."
		end

		if action == "Time" then
			local raw = trim(parts[2] or "")
			if raw == "" then
				return false, "Time needs an hour, for example 14 or 14:30."
			end
			local hour, minute = raw:match("^(%d+):(%d+)$")
			local clockValue
			if hour then
				clockValue = ("%02d:%02d:00"):format(math.clamp(tonumber(hour), 0, 23), math.clamp(tonumber(minute), 0, 59))
			else
				local justHour = tonumber(raw)
				if not justHour then
					return false, "Time needs a number, for example 14 or 14:30."
				end
				clockValue = ("%02d:00:00"):format(math.clamp(math.floor(justHour), 0, 23))
			end
			local applied = pcall(function()
				game:GetService("Lighting").TimeOfDay = clockValue
			end)
			if not applied then
				return false, "Could not change the time."
			end
			logModerationAction("Time", player, nil, nil, nil, clockValue, {
				{ name = "TimeOfDay", value = clockValue, inline = true },
			}, 3447003)
			return true, ("Server time set to %s."):format(clockValue)
		end

		if action == "Timer" then
			local minutes = tonumber(parts[2])
			if not minutes or minutes < 1 then
				return false, "Timer needs a number of minutes."
			end
			handleAnnounceAction(player, "StartAbuseTimer", { minutes = math.floor(minutes) })
			return true, ("Timer started for %d minute(s)."):format(math.floor(minutes))
		end

		if action == "Undo" then
			local entry = popUndo(player)
			if not entry then
				return false, "Nothing to undo."
			end
			local undoTarget = Players:GetPlayerByUserId(entry.targetUserId)
			if undoTarget then
				local ok = actionOnPlayer(entry.reverse, player, undoTarget, nil)
				if ok then
					return true, ("Undid %s on %s."):format(entry.action, undoTarget.Name)
				end
				return false, ("Could not undo %s."):format(entry.action)
			end
			if entry.reverse == "Unban" then
				local unbanOk = applyRobloxUnban(entry.targetUserId)
				if unbanOk then
					clearBanRegistryEntry(entry.targetUserId)
					logModerationAction("Unban", player, entry.targetUserId, entry.targetName, entry.targetName, "Undo", nil, 3066993)
					return true, ("Undid Ban on %s."):format(entry.targetName)
				end
			end
			return false, ("%s is no longer in this server."):format(entry.targetName)
		end
		actionOnServer(action, player, commandJoinFrom(parts, 2))
		return true, ("%s executed."):format(action)
	end

	local targetWord = parts[2]

	if targetWord == nil then
		if COMMAND_SELF_DEFAULT[action] == nil or COMMAND_SELF_DEFAULT[action] == false then
			return false, ("%s needs a target."):format(action)
		end
		targetWord = player.Name
	end

	if commandIsGlobalWord(targetWord) then
		return commandRunGlobal(player, action, commandJoinFrom(parts, 3))
	end

	if commandIsAllWord(targetWord) then
		if COMMAND_BLOCK_ALL[action] then
			return false, ("%s cannot be used on everyone."):format(action)
		end
		local othersOnly = string.lower(trim(targetWord)) == "others"
		return commandRunOnAll(player, action, commandJoinFrom(parts, 3), othersOnly)
	end

	if commandIsSelfWord(targetWord) then
		targetWord = player.Name
	end

	local targetUserId = resolveUserId(targetWord)
	if not targetUserId then
		return false, ("Could not find player: %s"):format(tostring(targetWord))
	end

	local targetPlayer = Players:GetPlayerByUserId(targetUserId)
	local value = commandJoinFrom(parts, 3)

	local allowed, why = canTargetUserId(player.UserId, targetUserId, action)
	if not allowed then
		return false, protectionMessage(why, targetPlayer and targetPlayer.Name or safeNameFromUserId(targetUserId))
	end

	if action == "Timeout" or action == "Untimeout" then
		return zoneTimeoutCommand(player, targetUserId, action, value)
	end

	-- ban <player> <minutes> <reason>  (no minutes = permanent)
	local commandValue = value ~= "" and value or nil
	if action == "Ban" then
		local minutesText, restText = commandMinutesSplit(value)
		if minutesText and tonumber(minutesText) and tonumber(minutesText) > 0 then
			commandValue = { duration = tonumber(minutesText) * 60, reason = restText }
		else
			commandValue = { reason = value }
		end
	elseif action == "TempMute" then
		-- tempmute <player> <minutes> <reason>
		local minutesText, restText = commandMinutesSplit(value)
		if minutesText and tonumber(minutesText) and tonumber(minutesText) > 0 then
			commandValue = { duration = tonumber(minutesText) * 60, reason = restText }
		end
	end

	if targetPlayer then
		local ok, actionErr = actionOnPlayer(action, player, targetPlayer, commandValue)
		if ok then
			pushUndo(player, action, targetPlayer.UserId, targetPlayer.Name)
			return true, ("%s -> %s"):format(action, targetPlayer.Name)
		end
		if PROTECTION_REASONS[tostring(actionErr or "")] then
			return false, protectionMessage(actionErr, targetPlayer.Name)
		end
		return false, ("%s failed."):format(action)
	end

	if action == "Warn" then
		local warnReason = formatReason(value)
		if warnReason == "" or warnReason == "No reason provided." then
			return false, "Warn needs a reason."
		end
		local queued = queuePendingWarning(targetUserId, warnReason, player.UserId)
		local targetLabel = safeNameFromUserId(targetUserId)
		if not queued then
			return false, "Could not save the warning."
		end
		addNote(targetUserId, ("[Warning] %s"):format(warnReason), player.UserId)
		logModerationAction(action, player, targetUserId, targetLabel, targetLabel, warnReason, {
			{ name = "Delivery", value = "On next join", inline = true },
		}, 16763904)
		return true, ("%s is offline. Warning saved for their next join."):format(targetLabel)
	end

	local ok = actionOnServer(action, player, {
		userId = targetUserId,
		target = targetWord,
		value = value ~= "" and value or nil,
	})
	if ok then
		return true, ("%s -> %s"):format(action, tostring(targetWord))
	end
	return false, ("Player is not in this server: %s"):format(tostring(targetWord))
end

RemoteEvent.OnServerEvent:Connect(function(player, action, targetQuery, value)
	if not isAdmin(player) then
		return
	end
	if type(action) ~= "string" then
		return
	end

	if zoneIsTimedOut(player.UserId) and not ZONE_TIMEOUT_ALLOWED[action] then
		RemoteEvent:FireClient(player, "ActionResult", {
			ok = false,
			action = action,
			message = protectionMessage("timed_out"),
			error = "timed_out",
		})
		return
	end

	if action == "ZonePingQuery" then
		local uid = tonumber(targetQuery) or 0
		if uid <= 0 then return end
		local other = Players:GetPlayerByUserId(uid)
		local ms = 0
		if other then pcall(function() ms = math.floor(other:GetNetworkPing() * 1000 + 0.5) end) end
		RemoteEvent:FireClient(player, "ZonePingResult", { userId = uid, ping = ms })
		return
	end
	-- Rank check for every ranked action (built-in ranks and custom ranks).
	if ACTION_RULES[action] and (zoneActionBlocked(player.UserId, action) or not zoneCanUseAction(player.UserId, action)) then
		RemoteEvent:FireClient(player, "ActionResult", {
			ok = false,
			action = action,
			message = "You do not have permission for that.",
		})
		return
	end

	local targetMissing = targetQuery == nil
	if type(targetQuery) == "string" then
		targetMissing = trim(targetQuery) == ""
	elseif type(targetQuery) == "number" then
		targetMissing = targetQuery <= 0
	end
	if targetMissing and type(action) == "string" and COMMAND_SELF_DEFAULT[action] == true then
		targetQuery = player.UserId
	end

	if action == "RoleList" then
		RemoteEvent:FireClient(player, "RolesData", { ok = true, roles = zoneRolesPublic() })
		return
	end

	if action == "RoleCreate" then
		if getRank(player.UserId) ~= "Owner" then
			RemoteEvent:FireClient(player, "RoleResult", { ok = false, message = "Only the owner can create ranks." })
			return
		end
		local payload = type(targetQuery) == "table" and targetQuery or value
		if type(payload) ~= "table" then
			RemoteEvent:FireClient(player, "RoleResult", { ok = false, message = "Bad request." })
			return
		end
		local name = zoneRolesSanitizeName(payload.name)
		if not name then
			RemoteEvent:FireClient(player, "RoleResult", { ok = false, message = "Name must be 3-18 letters and not a built-in rank." })
			return
		end
		if ZONE_ROLES[name] then
			RemoteEvent:FireClient(player, "RoleResult", { ok = false, message = "A rank with that name already exists." })
			return
		end
		local count = 0
		for _ in pairs(ZONE_ROLES) do
			count = count + 1
		end
		if count >= ZONE_ROLE_MAX then
			RemoteEvent:FireClient(player, "RoleResult", { ok = false, message = ("You can have %d custom ranks at most."):format(ZONE_ROLE_MAX) })
			return
		end
		local actions = {}
		local picked = 0
		if type(payload.actions) == "table" then
			for actionName, on in pairs(payload.actions) do
				if on == true and ACTION_RULES[actionName] and ACTION_RULES[actionName] ~= "Owner" then
					actions[actionName] = true
					picked = picked + 1
				end
			end
		end
		local tabs = {}
		if type(payload.tabs) == "table" then
			for _, tabId in ipairs(ZONE_ROLE_TABS) do
				if payload.tabs[tabId] == true then
					tabs[tabId] = true
				end
			end
		end
		local color = tostring(payload.color or "#5aa9ff")
		if not string.match(color, "^#%x%x%x%x%x%x$") then
			color = "#5aa9ff"
		end
		ZONE_ROLES[name] = {
			name = name,
			color = color,
			actions = actions,
			tabs = tabs,
			level = zoneRolesLevelFor(actions),
		}
		local stored = zoneRolesSave()
		zoneRolesBroadcast()
		logModerationAction("RankCreate", player, 0, name, name, ("%d permissions"):format(picked), nil, 5793266)
		if not stored then
			RemoteEvent:FireClient(player, "RoleResult", { ok = true, message = ("Rank %s created, but saving failed. Enable Studio Access to API Services."):format(name) })
			return
		end
		RemoteEvent:FireClient(player, "RoleResult", { ok = true, message = ("Rank %s created with %d permissions."):format(name, picked) })
		return
	end

	if action == "RoleDelete" then
		if getRank(player.UserId) ~= "Owner" then
			RemoteEvent:FireClient(player, "RoleResult", { ok = false, message = "Only the owner can delete ranks." })
			return
		end
		local payload = type(targetQuery) == "table" and targetQuery or value
		local name = type(payload) == "table" and tostring(payload.name or "") or tostring(payload or "")
		if not ZONE_ROLES[name] then
			RemoteEvent:FireClient(player, "RoleResult", { ok = false, message = "That rank does not exist." })
			return
		end
		ZONE_ROLES[name] = nil
		local cleared = 0
		for userId, rank in pairs(ADMIN_RANKS) do
			if rank == name then
				ADMIN_RANKS[userId] = nil
				cleared = cleared + 1
				local plr = Players:GetPlayerByUserId(userId)
				if plr then
					plr:SetAttribute("AdminPanelAccess", false)
					plr:SetAttribute("AdminPanelRank", "")
				end
			end
		end
		local removed = zoneRolesSave()
		saveAdmins()
		zoneRolesBroadcast()
		if not removed then
			RemoteEvent:FireClient(player, "RoleResult", { ok = true, message = ("Rank %s deleted, but saving failed. Enable Studio Access to API Services."):format(name) })
			return
		end
		logModerationAction("RankDelete", player, 0, name, name, ("%d admins cleared"):format(cleared), nil, 5793266)
		RemoteEvent:FireClient(player, "RoleResult", { ok = true, message = ("Rank %s deleted (%d admins cleared)."):format(name, cleared) })
		return
	end

	if action == "ClientInfo" then
		resolveClientInfoFromPayload(player, value)
		return
	end

	if action == "RunCommand" then
		if zoneRoleTabBlocked(player.UserId, "actions") then
			RemoteEvent:FireClient(player, "CommandResult", {
				ok = false,
				message = "Your rank cannot use commands.",
			})
			return
		end
		local commandText = targetQuery
		if type(commandText) ~= "string" then
			commandText = value
		end
		local ok, message = commandRunFor(player, commandText)
		RemoteEvent:FireClient(player, "CommandResult", {
			ok = ok == true,
			message = tostring(message or ""),
		})
		return
	end

	if action == "PanicQuery" then
		RemoteEvent:FireClient(player, "PanicState", {
			active = isPanicLocked(),
			by = PANIC_LOCK.by,
			reason = PANIC_LOCK.reason,
		})
		return
	end

	if action == "Announce" or action == "StartVote" or action == "StartAbuseTimer" or action == "StopAbuseTimer" then
		handleAnnounceAction(player, action, value)
		return
	end

	if action == "ChatGetHistory" then
		handleChatRequest(player)
		return
	end

	if action == "ChatTyping" then
		local chatTypingPayload = targetQuery
		if type(chatTypingPayload) ~= "table" then
			chatTypingPayload = value
		end
		if type(chatTypingPayload) == "table" then
			setPlayerTyping(player, chatTypingPayload.typing == true)
		end
		return
	end

	if action == "ChatSendMessage" then
		local chatPayload = targetQuery
		if type(chatPayload) ~= "table" and type(chatPayload) ~= "string" then
			chatPayload = value
		end
		local ok, message = handleChatSend(player, chatPayload)
		if ok then
			RemoteEvent:FireClient(player, "ChatSendAck", {
				ok = true,
				message = tostring(message or "Global chat message sent."),
			})
		else
			RemoteEvent:FireClient(player, "ChatSendFailed", {
				ok = false,
				message = tostring(message or "Global chat message could not be sent."),
				id = (type(chatPayload) == "table" and tostring(chatPayload.id or chatPayload.clientId or "") or ""),
			})
		end
		return
	end

	if action == "ClientPing" then
		RemoteEvent:FireClient(player, "ClientPingAck", targetQuery, os.clock())
		return
	end

	if action == "GetAdminList" then
		RemoteEvent:FireClient(player, "AdminListResult", getAdminList())
		return
	end

	if action == "SetRank" or action == "RemoveRank" then
		local ok = actionOnServer(action, player, targetQuery)
		if ok and action == "SetRank" and type(targetQuery) == "table" then
			RemoteEvent:FireClient(player, "ActionResult", action, true, targetQuery)
		elseif ok and action == "RemoveRank" and type(targetQuery) == "table" then
			RemoteEvent:FireClient(player, "ActionResult", action, true, targetQuery)
		end
		return
	end

	if action == "PanicLock" or action == "PanicUnlock" then
		if not zoneCanUseAction(player.UserId, action) then
			RemoteEvent:FireClient(player, "ActionResult", { ok = false, action = action, message = "You do not have permission for that." })
			return
		end
		actionOnServer(action, player, value)
		return
	end

	if action == "Disco" or action == "UnDisco" then
		zoneDisco(action == "Disco")
		logModerationAction(action, player, nil, nil, nil, nil)
		RemoteEvent:FireClient(player, "ActionResult", {
			ok = true,
			action = action,
			message = (action == "Disco") and "Disco on." or "Disco off.",
		})
		return
	end

	if action == "BringAll" or action == "HealAll" or action == "KillAll" or action == "RespawnAll" or action == "ServerShutdown" or action == "ShutdownServer" or action == "ServerRejoin" or action == "RejoinServer" or action == "ServerRestart" or action == "Restart" or action == "ServerUpdateAll" then
		actionOnServer(action, player, targetQuery)
		return
	end

	if action == "Unspectate" and (targetQuery == nil or tostring(targetQuery) == "") then
		RemoteEvent:FireClient(player, "AdminSpectate", { active = false })
		return
	end

	local targetUserId = resolveUserId(targetQuery)
	local targetPlayer = targetUserId and Players:GetPlayerByUserId(targetUserId) or nil

	if action == "Timeout" or action == "Untimeout" then
		local ok, message = zoneTimeoutCommand(player, targetUserId, action, value)
		RemoteEvent:FireClient(player, "ActionResult", {
			ok = ok == true,
			action = action,
			targetUserId = targetUserId or 0,
			message = tostring(message or ""),
		})
		return
	end

	if targetPlayer then
		local allowed, why = canTarget(player, targetPlayer, action)
		if not allowed then
			RemoteEvent:FireClient(player, "ActionResult", {
				ok = false,
				action = action,
				targetUserId = targetPlayer.UserId,
				message = protectionMessage(why, targetPlayer.Name),
				error = "protected_admin_target",
			})
			return
		end
	end

	if targetPlayer then
		local ok, actionErr = actionOnPlayer(action, player, targetPlayer, value)
		if ok then
			RemoteEvent:FireClient(player, "ActionResult", {
				ok = true,
				action = action,
				targetUserId = targetPlayer.UserId,
				targetName = targetPlayer.Name,
				targetDisplayName = targetPlayer.DisplayName,
				message = ("%s executed."):format(action),
			})
		else
			RemoteEvent:FireClient(player, "ActionResult", {
				ok = false,
				action = action,
				targetUserId = targetPlayer.UserId,
				targetName = targetPlayer.Name,
				message = tostring(actionErr or "") == "target_jailed" and "This player is jailed. Unjail them before using Fly or teleport actions."
					or (PROTECTION_REASONS[tostring(actionErr or "")] and protectionMessage(actionErr, targetPlayer.Name))
					or (("%s failed."):format(action)),
				error = tostring(actionErr or "failed"),
			})
		end
	else
		local presence = targetUserId and getPresence(targetUserId) or nil
		if targetUserId and type(presence) == "table" and tostring(presence.jobId or "") ~= "" and tostring(presence.jobId) ~= tostring(game.JobId) and canRelayPlayerAction(action) then
			requestRemoteAction(player, action, targetQuery, value, targetUserId, presence)
			return
		end
		if action == "Warn" then
			local uid = targetUserId or resolveUserId(targetQuery)
			local warnReason = formatReason(type(value) == "table" and (value.reason or value.text) or value or "")
			if not uid then
				RemoteEvent:FireClient(player, "ActionResult", {
					ok = false,
					action = action,
					message = "Could not find that player.",
					error = "not_found",
				})
				return
			end
			if warnReason == "" or warnReason == "No reason provided." then
				RemoteEvent:FireClient(player, "ActionResult", {
					ok = false,
					action = action,
					targetUserId = uid,
					message = "Enter a warning reason.",
					error = "missing_reason",
				})
				return
			end
			local warnAllowed, warnWhy = canTargetUserId(player.UserId, uid, "Warn")
			if not warnAllowed then
				RemoteEvent:FireClient(player, "ActionResult", {
					ok = false,
					action = action,
					targetUserId = uid,
					message = protectionMessage(warnWhy, safeNameFromUserId(uid)),
					error = "protected_admin_target",
				})
				return
			end
			local queued = queuePendingWarning(uid, warnReason, player.UserId)
			local targetLabel = safeNameFromUserId(uid)
			if queued then
				addNote(uid, ("[Warning] %s"):format(warnReason), player.UserId)
				logModerationAction(action, player, uid, targetLabel, targetLabel, warnReason, {
					{ name = "Delivery", value = "On next join", inline = true },
				}, 16763904)
			end
			RemoteEvent:FireClient(player, "ActionResult", {
				ok = queued,
				action = action,
				targetUserId = uid,
				message = queued
					and ("%s is offline. The warning will show when they next join."):format(targetLabel)
					or "Could not save the warning.",
			})
			return
		end

		if action == "Ban" or action == "Unban" or action == "AddNote" or action == "Note" then
			local uid = targetUserId or resolveUserId(targetQuery)
			if uid then
				if action == "Ban" then
					local allowed, why = canTargetUserId(player.UserId, uid, "Ban")
					if not allowed then
						RemoteEvent:FireClient(player, "ActionResult", {
							ok = false,
							action = action,
							targetUserId = uid,
							message = protectionMessage(why, safeNameFromUserId(uid)),
							error = "protected_admin_target",
						})
						return
					end
					local duration = nil
					local reason = formatReason("")
					local privateReason = reason
					if type(value) == "table" then
						duration = tonumber(value.duration or value.seconds or value.durationSeconds)
						reason = formatReason(value.reason or "")
						privateReason = formatReason(value.privateReason or value.private_reason or value.internalReason or value.reason or reason)
					elseif type(value) == "string" then
						reason = formatReason(value)
						privateReason = reason
					end
					local banOk, banErr, robloxBan, robloxErr = applyRobloxBan(uid, reason, privateReason, duration)
					if banOk and robloxErr then
						RemoteEvent:FireClient(player, "CommandResult", { ok = false, message = "Roblox ban unavailable here, saved as a panel ban instead." })
					end
					if not banOk then
						RemoteEvent:FireClient(player, "ActionResult", {
							ok = false,
							action = action,
							targetUserId = uid,
							message = "Ban failed.",
							error = tostring(banErr or "ban_failed"),
						})
						return
					end
					setBanRegistryEntry(uid, {
						RobloxBan = robloxBan == true,
						UserId = uid,
						Name = safeNameFromUserId(uid),
						DisplayName = safeNameFromUserId(uid),
						Reason = reason,
						ModeratorUserId = player.UserId,
						ModeratorName = player.DisplayName or player.Name or "N/A",
						BannedAt = now(),
						Duration = duration or -1,
						ExpiresAt = (duration and duration > 0) and (now() + duration) or nil,
						Active = true,
					})
					logModerationAction("Ban", player, uid, safeNameFromUserId(uid), safeNameFromUserId(uid), reason, duration and {
						{ name = "Expires in", value = tostring(duration) .. "s", inline = true },
					} or nil, 16724787)
				elseif action == "Unban" then
					local unbanOk, unbanErr = applyRobloxUnban(uid)
					if not unbanOk then
						RemoteEvent:FireClient(player, "ActionResult", {
							ok = false,
							action = action,
							targetUserId = uid,
							message = "Unban failed.",
							error = tostring(unbanErr or "unban_failed"),
						})
						return
					end
					clearBanRegistryEntry(uid)
					logModerationAction("Unban", player, uid, safeNameFromUserId(uid), safeNameFromUserId(uid), "", nil, 3066993)
				elseif action == "AddNote" or action == "Note" then
					addNote(uid, tostring(value or ""), player.UserId)
					logModerationAction("AddNote", player, uid, safeNameFromUserId(uid), safeNameFromUserId(uid), tostring(value or ""), nil, 5793266)
				end
			end
			RemoteEvent:FireClient(player, "ActionResult", {
				ok = true,
				action = action,
				targetUserId = uid,
				message = ("%s executed."):format(action),
			})
			return
		end
		if targetQuery == nil or tostring(targetQuery) == "" then
			return
		end
		RemoteEvent:FireClient(player, "ActionResult", {
			ok = false,
			action = action,
			targetUserId = targetUserId or 0,
			message = "Target not found on this server.",
			error = "not_found",
		})
	end
end)

task.spawn(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			upsertPresence(player)
		end
		task.wait(30)
	end
end)

local function runServerChatAdminCommand(requester, message)
	message = tostring(message or "")
	local prefix = string.sub(message, 1, 1)
	if prefix ~= ";" and prefix ~= COMMAND_PREFIX then
		return false
	end
	if not isAdmin(requester) then
		return false
	end
	if zoneRoleTabBlocked(requester.UserId, "actions") then
		RemoteEvent:FireClient(requester, "CommandResult", {
			ok = false,
			message = "Your rank cannot use commands.",
		})
		return true
	end

	local body = trim(string.sub(message, 2))
	if body == "" then
		return false
	end

	local lowered = string.lower(body)
	if lowered == "cmds" or lowered == "cmd" or lowered == "commands" then
		RemoteEvent:FireClient(requester, "OpenCommandBar", true)
		return true
	end

	local ok, resultMessage = commandRunFor(requester, body)
	RemoteEvent:FireClient(requester, "CommandResult", {
		ok = ok == true,
		message = tostring(resultMessage or ""),
	})
	return true
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		runServerChatAdminCommand(player, message)
	end)
end)
for _, player in ipairs(Players:GetPlayers()) do
	player.Chatted:Connect(function(message)
		runServerChatAdminCommand(player, message)
	end)
end

pcall(function()
	local aliases = {
		"fly", "unfly", "heal", "respawn", "bring", "kick", "mute", "unmute", "tempmute",
		"freeze", "unfreeze", "ban", "unban", "speed", "jump", "noclip", "invisible", "visible", "note",
		"bringall", "healall", "killall", "respawnall", "shutdown", "rejoin", "setrank", "removerank",
		"usec", "unusec", "vmute", "vunmute", "timeout", "untimeout",
	}
	for _, alias in ipairs(aliases) do
		local name = "AdminSemicolonCommand_" .. alias
		local commandObject = TextChatService:FindFirstChild(name)
		if not commandObject then
			commandObject = Instance.new("TextChatCommand")
			commandObject.Name = name
			commandObject.PrimaryAlias = ";" .. alias
			commandObject.AutocompleteVisible = false
			commandObject.Parent = TextChatService
		end
		if commandObject:IsA("TextChatCommand") then
			commandObject.Triggered:Connect(function(textSource, unfilteredText)
				local player = textSource and Players:GetPlayerByUserId(textSource.UserId)
				if not player then return end
				local commandText = tostring(unfilteredText or "")
				if commandText:sub(1, 1) ~= ";" then
					commandText = ";" .. alias .. (commandText ~= "" and (" " .. commandText) or "")
				end
				runServerChatAdminCommand(player, commandText)
			end)
		end
	end
end)
