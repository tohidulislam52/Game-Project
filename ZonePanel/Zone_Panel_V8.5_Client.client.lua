--[[
    ███████╗██████╗ ███████╗    ███████╗ ██████╗ ███╗   ██╗███████╗
    ██╔════╝██╔══██╗██╔════╝    ╚══███╔╝██╔═══██╗████╗  ██║██╔════╝
    █████╗  ██████╔╝███████╗      ███╔╝ ██║   ██║██╔██╗ ██║█████╗
    ██╔══╝  ██╔═══╝ ╚════██║     ███╔╝  ██║   ██║██║╚██╗██║██╔══╝
    ██║     ██║     ███████║    ███████╗╚██████╔╝██║ ╚████║███████╗
    ╚═╝     ╚═╝     ╚══════╝    ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
Created By FPS Zone
Script Name: Zone Panel V8.5 [Pro]
Version: V8.5 [Pro]
Discord Server: discord.gg/Ysc2H8dHdN
[Paid] Script
--]]

local Players = game:GetService("Players")
TeleportService = game:GetService("TeleportService")
ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local LocalizationService = game:GetService("LocalizationService")
local GroupService = game:GetService("GroupService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

------------------------------------------------------------
-- PC key that opens / closes the panel (mobile keeps its button).
-- Change it here, e.g. Enum.KeyCode.RightAlt or Enum.KeyCode.K
------------------------------------------------------------
PANEL_OPEN_KEY = Enum.KeyCode.LeftAlt

ZONE_LICENSE_ALERT_OPEN = false

function showLicenseAlert(payload)
	if ZONE_LICENSE_ALERT_OPEN == true then
		return
	end
	ZONE_LICENSE_ALERT_OPEN = true
	local data = type(payload) == "table" and payload or {}
	local licenseReasonKeys = { http = "license.http", config = "license.config", license = "license.unlicensed", error = "license.error" }
	local function licenseAlertTitle()
		return type(ZoneT) == "function" and ZoneT("license.title") or tostring(data.title or "Verification failed")
	end
	local function licenseAlertBody()
		local key = licenseReasonKeys[tostring(data.reason or "")]
		if key and type(ZoneT) == "function" then return ZoneT(key) end
		return tostring(data.message or "This place is not licensed to run Zone Panel V8.5 [Pro].")
	end

	local holder = Instance.new("ScreenGui")
	holder.Name = "ZoneLicenseGui"
	holder.ResetOnSpawn = false
	holder.IgnoreGuiInset = true
	holder.DisplayOrder = 2000
	holder.Parent = playerGui

	local shade = Instance.new("TextButton")
	shade.Name = "Shade"
	shade.Size = UDim2.fromScale(1, 1)
	shade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shade.BackgroundTransparency = 0.45
	shade.BorderSizePixel = 0
	shade.AutoButtonColor = false
	shade.Text = ""
	shade.Parent = holder

	local card = Instance.new("Frame")
	card.Name = "LicenseCard"
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.fromOffset(400, 320)
	card.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	card.BorderSizePixel = 0
	card.Parent = holder

	local round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(0, 16)
	round.Parent = card

	local edge = Instance.new("UIStroke")
	edge.Color = Color3.fromRGB(255, 92, 92)
	edge.Transparency = 0.4
	edge.Thickness = 2
	edge.Parent = card

	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.AnchorPoint = Vector2.new(0.5, 0)
	icon.Position = UDim2.new(0.5, 0, 0, 24)
	icon.Size = UDim2.fromOffset(84, 84)
	icon.BackgroundTransparency = 1
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Image = "rbxassetid://" .. tostring(tonumber(data.image) or 11745872910)
	icon.Parent = card

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(20, 120)
	title.Size = UDim2.new(1, -40, 0, 28)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Text = licenseAlertTitle()
	title.Parent = card

	local body = Instance.new("TextLabel")
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(24, 156)
	body.Size = UDim2.new(1, -48, 0, 80)
	body.Font = Enum.Font.Gotham
	body.TextSize = 14
	body.TextWrapped = true
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.TextColor3 = Color3.fromRGB(205, 205, 212)
	body.Text = licenseAlertBody()
	body.Parent = card
	if type(registerLangText) == "function" then
		registerLangText(title, licenseAlertTitle)
		registerLangText(body, licenseAlertBody)
	end

	local link = Instance.new("TextLabel")
	link.BackgroundTransparency = 1
	link.Position = UDim2.fromOffset(24, 236)
	link.Size = UDim2.new(1, -48, 0, 22)
	link.Font = Enum.Font.GothamSemibold
	link.TextSize = 14
	link.TextColor3 = Color3.fromRGB(120, 200, 255)
	link.Text = tostring(data.discord or "discord.gg/Ysc2H8dHdN")
	link.Parent = card

	local close = Instance.new("TextButton")
	close.Name = "LicenseCloseBtn"
	close.AnchorPoint = Vector2.new(0.5, 1)
	close.Position = UDim2.new(0.5, 0, 1, -20)
	close.Size = UDim2.fromOffset(160, 38)
	close.BackgroundColor3 = Color3.fromRGB(255, 92, 92)
	close.BorderSizePixel = 0
	close.AutoButtonColor = false
	close.Font = Enum.Font.GothamBold
	close.TextSize = 14
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.Text = (type(ZoneT) == "function") and ZoneT("ui.close") or "Close"
	if type(registerLangText) == "function" then registerLangText(close, "ui.close") end
	close.Parent = card

	local closeRound = Instance.new("UICorner")
	closeRound.CornerRadius = UDim.new(0, 10)
	closeRound.Parent = close

	local scale = Instance.new("UIScale")
	scale.Scale = 0.9
	scale.Parent = card
	TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

	close.MouseButton1Click:Connect(function()
		ZONE_LICENSE_ALERT_OPEN = false
		holder:Destroy()
	end)
end

function connectLicenseAlert()
	task.spawn(function()
		local alert = ReplicatedStorage:WaitForChild("ZoneLicenseAlert", 30)
		if not alert or not alert:IsA("RemoteEvent") then
			return
		end
		alert.OnClientEvent:Connect(function(payload)
			showLicenseAlert(payload)
		end)
	end)
end

connectLicenseAlert()

local RemoteEvent = ReplicatedStorage:WaitForChild("AdminPanelRemote")
local AuthRF = ReplicatedStorage:WaitForChild("AdminPanelAuth")
local ResolveRF = ReplicatedStorage:WaitForChild("AdminPanelResolveTarget")
local AdminListRF = ReplicatedStorage:WaitForChild("AdminPanelAdminList")
local ServerDataRF = ReplicatedStorage:WaitForChild("AdminPanelServerData")
local RemovedLogRemote = nil
local SettingsRF = ReplicatedStorage:WaitForChild("AdminPanelSettings")
local BanListRF = ReplicatedStorage:WaitForChild("AdminPanelBanList")
local CreditsRF = ReplicatedStorage:WaitForChild("AdminPanelCredits")

local CONFIG = {
	panels = {
		main = UDim2.fromOffset(940, 560),
		code = UDim2.fromOffset(520, 340),
		confirm = UDim2.fromOffset(420, 220),
		notes = UDim2.fromOffset(480, 460),
	},
	longPress = 0.45,
	mobileBreakpoint = 900,
	sidebarWide = 186,
	sidebarNarrow = 66,
	sidebarBtnSize = 48,
	sidebarIconSize = 36,
	sidebarReorderHold = 1,
	sidebarReorderDelay = 0.4,
	sidebarIconActiveSize = 44,
}
local THEMES = {
	Dark = {
		bg = Color3.fromRGB(18, 18, 20),
		panel = Color3.fromRGB(28, 28, 30),
		panel2 = Color3.fromRGB(22, 22, 24),
		card = Color3.fromRGB(40, 40, 43),
		text = Color3.fromRGB(245, 245, 245),
		muted = Color3.fromRGB(180, 180, 180),
		accent = Color3.fromRGB(245, 245, 245),
		success = Color3.fromRGB(120, 255, 160),
		warn = Color3.fromRGB(255, 180, 90),
		danger = Color3.fromRGB(255, 100, 100),
		neon = Color3.fromRGB(140, 220, 255),
		onAccent = Color3.fromRGB(22, 22, 22),
		icon = Color3.fromRGB(245, 245, 245),
	},
	Light = {
		bg = Color3.fromRGB(248, 248, 250),
		panel = Color3.fromRGB(238, 238, 242),
		panel2 = Color3.fromRGB(230, 230, 236),
		card = Color3.fromRGB(255, 255, 255),
		text = Color3.fromRGB(24, 24, 28),
		muted = Color3.fromRGB(90, 90, 100),
		accent = Color3.fromRGB(38, 40, 48),
		success = Color3.fromRGB(20, 150, 70),
		warn = Color3.fromRGB(160, 100, 0),
		danger = Color3.fromRGB(190, 30, 30),
		neon = Color3.fromRGB(70, 120, 255),
		onAccent = Color3.fromRGB(250, 250, 252),
		icon = Color3.fromRGB(24, 24, 28),
	},
	Neon = {
		bg = Color3.fromRGB(11, 14, 20),
		panel = Color3.fromRGB(17, 22, 32),
		panel2 = Color3.fromRGB(13, 18, 26),
		card = Color3.fromRGB(24, 31, 44),
		text = Color3.fromRGB(235, 245, 255),
		muted = Color3.fromRGB(140, 160, 180),
		accent = Color3.fromRGB(0, 220, 255),
		success = Color3.fromRGB(90, 255, 170),
		warn = Color3.fromRGB(255, 200, 80),
		danger = Color3.fromRGB(255, 90, 120),
		neon = Color3.fromRGB(0, 220, 255),
		onAccent = Color3.fromRGB(8, 14, 20),
		icon = Color3.fromRGB(235, 245, 255),
	},
	Midnight = {
		bg = Color3.fromRGB(10, 12, 24),
		panel = Color3.fromRGB(18, 21, 40),
		panel2 = Color3.fromRGB(14, 17, 33),
		card = Color3.fromRGB(27, 31, 56),
		text = Color3.fromRGB(232, 236, 255),
		muted = Color3.fromRGB(146, 154, 190),
		accent = Color3.fromRGB(124, 140, 255),
		success = Color3.fromRGB(110, 235, 175),
		warn = Color3.fromRGB(255, 196, 110),
		danger = Color3.fromRGB(255, 105, 135),
		neon = Color3.fromRGB(124, 140, 255),
		onAccent = Color3.fromRGB(12, 14, 28),
		icon = Color3.fromRGB(232, 236, 255),
	},
	Ocean = {
		bg = Color3.fromRGB(8, 22, 30),
		panel = Color3.fromRGB(13, 34, 46),
		panel2 = Color3.fromRGB(10, 28, 38),
		card = Color3.fromRGB(19, 47, 62),
		text = Color3.fromRGB(226, 245, 252),
		muted = Color3.fromRGB(132, 172, 190),
		accent = Color3.fromRGB(64, 200, 214),
		success = Color3.fromRGB(90, 235, 180),
		warn = Color3.fromRGB(250, 200, 110),
		danger = Color3.fromRGB(255, 110, 120),
		neon = Color3.fromRGB(64, 200, 214),
		onAccent = Color3.fromRGB(6, 20, 28),
		icon = Color3.fromRGB(226, 245, 252),
	},
	Forest = {
		bg = Color3.fromRGB(12, 22, 16),
		panel = Color3.fromRGB(19, 34, 25),
		panel2 = Color3.fromRGB(15, 28, 20),
		card = Color3.fromRGB(27, 47, 34),
		text = Color3.fromRGB(232, 248, 236),
		muted = Color3.fromRGB(142, 178, 152),
		accent = Color3.fromRGB(110, 220, 130),
		success = Color3.fromRGB(120, 240, 150),
		warn = Color3.fromRGB(240, 200, 100),
		danger = Color3.fromRGB(245, 110, 105),
		neon = Color3.fromRGB(110, 220, 130),
		onAccent = Color3.fromRGB(10, 20, 14),
		icon = Color3.fromRGB(232, 248, 236),
	},
	Crimson = {
		bg = Color3.fromRGB(22, 11, 13),
		panel = Color3.fromRGB(35, 17, 20),
		panel2 = Color3.fromRGB(28, 14, 16),
		card = Color3.fromRGB(50, 24, 28),
		text = Color3.fromRGB(252, 234, 236),
		muted = Color3.fromRGB(190, 146, 150),
		accent = Color3.fromRGB(255, 92, 108),
		success = Color3.fromRGB(120, 230, 160),
		warn = Color3.fromRGB(255, 190, 100),
		danger = Color3.fromRGB(255, 80, 80),
		neon = Color3.fromRGB(255, 92, 108),
		onAccent = Color3.fromRGB(26, 10, 12),
		icon = Color3.fromRGB(252, 234, 236),
	},
	Purple = {
		bg = Color3.fromRGB(18, 12, 26),
		panel = Color3.fromRGB(29, 20, 42),
		panel2 = Color3.fromRGB(23, 16, 34),
		card = Color3.fromRGB(41, 28, 60),
		text = Color3.fromRGB(240, 234, 255),
		muted = Color3.fromRGB(170, 152, 200),
		accent = Color3.fromRGB(186, 120, 255),
		success = Color3.fromRGB(120, 240, 180),
		warn = Color3.fromRGB(255, 200, 110),
		danger = Color3.fromRGB(255, 100, 130),
		neon = Color3.fromRGB(186, 120, 255),
		onAccent = Color3.fromRGB(18, 10, 26),
		icon = Color3.fromRGB(240, 234, 255),
	},
}


COLOR_WHEEL_IMAGE = "rbxassetid://4882133430"
COLOR_WHEEL_ROTATION = 180
DEFAULT_CUSTOM_ACCENT = Color3.fromRGB(0, 220, 255)
COLOR_PICKER_BASE_W = 360
COLOR_PICKER_BASE_H = 470

THEMES.Custom = {
	bg = Color3.fromRGB(16, 16, 19),
	panel = Color3.fromRGB(25, 25, 29),
	panel2 = Color3.fromRGB(20, 20, 24),
	card = Color3.fromRGB(36, 36, 41),
	text = Color3.fromRGB(245, 245, 245),
	muted = Color3.fromRGB(175, 175, 182),
	accent = Color3.fromRGB(0, 220, 255),
	success = Color3.fromRGB(120, 255, 160),
	warn = Color3.fromRGB(255, 180, 90),
	danger = Color3.fromRGB(255, 100, 100),
	neon = Color3.fromRGB(0, 220, 255),
	onAccent = Color3.fromRGB(18, 18, 20),
	icon = Color3.fromRGB(245, 245, 245),
}

THEME_ORDER = { "Dark", "Light", "Neon", "Midnight", "Ocean", "Forest", "Crimson", "Purple", "Custom" }
ANNOUNCE_TAB_ICON = "rbxassetid://4458859449"
HISTORY_TAB_ICON = "rbxassetid://126804025702964"
BACKGROUND_IMAGE_ID = "rbxassetid://17582945577"
SIDEBAR_MENU_ICON = "rbxassetid://14219516515"
RESIZE_GRIP_ICON = "rbxassetid://114480514408463"
THEME_COLOR_KEYS = { "bg", "panel", "panel2", "card", "text", "muted", "accent", "success", "warn", "danger", "neon", "onAccent", "icon" }
LIGHT_THEME_NAMES = { Light = true }
DEFAULT_THEME_NAME = "Dark"

function isValidThemeName(name)
	name = tostring(name or "")
	return THEMES[name] ~= nil
end

function normalizeThemeName(name)
	name = tostring(name or "")
	if THEMES[name] then
		return name
	end
	local lowered = name:lower()
	for _, key in ipairs(THEME_ORDER) do
		if key:lower() == lowered then
			return key
		end
	end
	return DEFAULT_THEME_NAME
end

local RANK_ORDER = {
	Helper = 10,
	Moderator = 50,
	Admin = 80,
	Owner = 100,
}

local ACTION_RULES = {
	AddNote = "Helper",
	Note = "Helper",

	Kick = "Moderator",
	Goto = "Moderator",
	Spectate = "Moderator",
	Unspectate = "Moderator",
	Kill = "Moderator",
	Jail = "Moderator",
	Unjail = "Moderator",
	TpTo = "Moderator",
	Refresh = "Moderator",
	Sit = "Moderator",
	Undo = "Moderator",
	Gravity = "Moderator",
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
	Unmute = "Moderator",
	TempMute = "Moderator",
	VoiceMute = "Moderator",
	VoiceUnmute = "Moderator",

	Freeze = "Admin",
	Unfreeze = "Admin",
	God = "Admin",
	Ungod = "Admin",
	Warn = "Admin",
	Timer = "Admin",
	Time = "Admin",
	Rejoin = "Admin",
	Esp = "Moderator",
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

local ACTION_META = {
	Kick = { label = "Kick", rank = "Moderator", serious = false, needsReason = true },
	Mute = { label = "Mute", rank = "Moderator", serious = true, needsReason = true },
	TempMute = { label = "Temp Mute", rank = "Moderator", serious = true, needsReason = true, needsValue = true, valueHint = "Minutes" },
	Unmute = { label = "Unmute", rank = "Moderator", serious = false, needsReason = false },
	VoiceMute = { label = "Voice Mute", rank = "Moderator", serious = true, needsReason = false },
	VoiceUnmute = { label = "Voice Unmute", rank = "Moderator", serious = false, needsReason = false },
	UltimateSecurity = { label = "Ultimate Security", rank = "Owner", serious = false, needsReason = false },
	UnUltimateSecurity = { label = "Remove Ultimate Security", rank = "Owner", serious = false, needsReason = false },
	Timeout = { label = "Admin Timeout", rank = "Owner", serious = true, needsReason = true, needsValue = true, valueHint = "Minutes (1-1440)" },
	Untimeout = { label = "Remove Timeout", rank = "Owner", serious = false, needsReason = false },
	Bring = { label = "Bring", rank = "Moderator", serious = false, needsReason = false },
	ServerBring = { label = "Server Bring", rank = "Moderator", serious = false, needsReason = false },
	Heal = { label = "Heal", rank = "Moderator", serious = false, needsReason = false },
	Respawn = { label = "Respawn", rank = "Moderator", serious = false, needsReason = false },
	SuperSpeed = { label = "Speed", rank = "Moderator", serious = false, needsValue = true },
	SuperJump = { label = "Jump", rank = "Moderator", serious = false, needsValue = true },
	Invisible = { label = "Invisible", rank = "Moderator", serious = true, needsReason = false },
	Visible = { label = "Visible", rank = "Moderator", serious = false, needsReason = false },
	Noclip = { label = "Noclip", rank = "Moderator", serious = true, needsValue = true },
	Fly = { label = "Fly", rank = "Moderator", serious = true },
	Unfly = { label = "Unfly", rank = "Moderator", serious = false },
	AddNote = { label = "Add Note", rank = "Helper", serious = false, needsReason = true },

	Freeze = { label = "Freeze", rank = "Admin", serious = true, needsReason = true },
	Unfreeze = { label = "Unfreeze", rank = "Admin", serious = false },
	Ban = { label = "Ban", rank = "Admin", serious = true, needsReason = true, needsValue = true, valueHint = "Minutes (empty = permanent)" },
	Unban = { label = "Unban", rank = "Admin", serious = true, needsReason = false },
	BringAll = { label = "Bring All", rank = "Admin", serious = true },
	HealAll = { label = "Heal All", rank = "Admin", serious = false },
	KillAll = { label = "Kill All", rank = "Admin", serious = true },
	RespawnAll = { label = "Respawn All", rank = "Admin", serious = false },

	Announce = { label = "Announce", rank = "Admin", serious = false, needsReason = false },
	StartVote = { label = "Start Vote", rank = "Admin", serious = false, needsReason = false },
	StartAbuseTimer = { label = "Start Timer", rank = "Admin", serious = false, needsReason = false },
	StopAbuseTimer = { label = "Stop Timer", rank = "Admin", serious = false, needsReason = false },

	PanicLock = { label = "Panic Lock", rank = "Admin", serious = true, needsReason = false },
	PanicUnlock = { label = "Unlock", rank = "Admin", serious = false, needsReason = false },

	ServerShutdown = { label = "Shutdown", rank = "Owner", serious = true, needsReason = true },
	ServerRejoin = { label = "Rejoin Me", rank = "Owner", serious = true },

	Goto = { label = "Goto", rank = "Moderator", serious = false, needsReason = false },
	Kill = { label = "Kill", rank = "Moderator", serious = true, needsReason = false },
	Spectate = { label = "Spectate", rank = "Moderator", serious = false, needsReason = false },
	Unspectate = { label = "Unspectate", rank = "Moderator", serious = false, needsReason = false },
	Jail = { label = "Jail", rank = "Moderator", serious = true, needsReason = false },
	Unjail = { label = "Unjail", rank = "Moderator", serious = false, needsReason = false },
	Sit = { label = "Sit", rank = "Moderator", serious = false, needsReason = false },
	Refresh = { label = "Refresh", rank = "Moderator", serious = false, needsReason = false },
	TpTo = { label = "Teleport To", rank = "Moderator", serious = false, needsReason = false, needsValue = true, valueHint = "Destination player" },
	Gravity = { label = "Gravity", rank = "Moderator", serious = false, needsReason = false, needsValue = true, valueHint = "Gravity" },
	God = { label = "God", rank = "Admin", serious = false, needsReason = false },
	Ungod = { label = "Ungod", rank = "Admin", serious = false, needsReason = false },
	Rejoin = { label = "Rejoin Player", rank = "Admin", serious = true, needsReason = false },
	Esp = { label = "ESP", rank = "Moderator", serious = false, needsReason = false },

	Age = { label = "Account Age", rank = "Helper", serious = false, needsReason = false },
	BigHead = { label = "Big Head", rank = "Helper", serious = false, needsReason = false },
	Blind = { label = "Blind", rank = "Moderator", serious = false, needsReason = false, needsValue = true, valueHint = "Seconds" },
	Confuse = { label = "Confuse", rank = "Moderator", serious = false, needsReason = false, needsValue = true, valueHint = "Seconds" },
	Damage = { label = "Damage", rank = "Moderator", serious = false, needsReason = false, needsValue = true, valueHint = "Amount" },
	Disco = { label = "Disco", rank = "Moderator", serious = false, needsReason = false },
	Dwarf = { label = "Dwarf", rank = "Helper", serious = false, needsReason = false },
	Explode = { label = "Explode", rank = "Moderator", serious = true, needsReason = false },
	Fat = { label = "Fat", rank = "Helper", serious = false, needsReason = false },
	Fire = { label = "Fire", rank = "Helper", serious = false, needsReason = false },
	Fling = { label = "Fling", rank = "Moderator", serious = false, needsReason = false, needsValue = true, valueHint = "Power" },
	ForceField = { label = "Force Field", rank = "Moderator", serious = false, needsReason = false },
	Ghost = { label = "Ghost", rank = "Helper", serious = false, needsReason = false },
	Giant = { label = "Giant", rank = "Helper", serious = false, needsReason = false },
	Glass = { label = "Glass", rank = "Helper", serious = false, needsReason = false },
	Grav = { label = "Restore Gravity", rank = "Moderator", serious = false, needsReason = false },
	HideName = { label = "Hide Name", rank = "Moderator", serious = false, needsReason = false },
	Launch = { label = "Launch", rank = "Moderator", serious = false, needsReason = false, needsValue = true, valueHint = "Power" },
	LoopKill = { label = "Loop Kill", rank = "Admin", serious = true, needsReason = false },
	NoGravity = { label = "No Gravity", rank = "Moderator", serious = false, needsReason = false },
	NormalHead = { label = "Normal Head", rank = "Helper", serious = false, needsReason = false },
	NormalSize = { label = "Normal Size", rank = "Helper", serious = false, needsReason = false },
	Paint = { label = "Paint", rank = "Helper", serious = false, needsReason = true, reasonHint = "Colour name" },
	Ping = { label = "Ping", rank = "Helper", serious = false, needsReason = false },
	Punish = { label = "Punish", rank = "Admin", serious = true, needsReason = false },
	Ragdoll = { label = "Ragdoll", rank = "Moderator", serious = false, needsReason = false },
	Restart = { label = "Restart", rank = "Owner", serious = true, needsReason = true, reasonHint = "Message (default Updating)", needsValue = true, valueHint = "Seconds (default 15)" },
	ServerRestart = { label = "Restart Server", rank = "Owner", serious = true, needsReason = true, reasonHint = "Message (default Updating)", needsValue = true, valueHint = "Seconds (default 15)" },
	SetHealth = { label = "Set Health", rank = "Moderator", serious = false, needsReason = false, needsValue = true, valueHint = "Health" },
	ShowName = { label = "Show Name", rank = "Moderator", serious = false, needsReason = false },
	Size = { label = "Set Size", rank = "Moderator", serious = false, needsReason = false, needsValue = true, valueHint = "Scale 0.3-4" },
	SmallHead = { label = "Small Head", rank = "Helper", serious = false, needsReason = false },
	Smoke = { label = "Smoke", rank = "Helper", serious = false, needsReason = false },
	Sparkles = { label = "Sparkles", rank = "Helper", serious = false, needsReason = false },
	Spin = { label = "Spin", rank = "Moderator", serious = false, needsReason = false },
	Squash = { label = "Squash", rank = "Helper", serious = false, needsReason = false },
	StopLoop = { label = "Stop Loop Kill", rank = "Moderator", serious = false, needsReason = false },
	Thin = { label = "Thin", rank = "Helper", serious = false, needsReason = false },
	Trip = { label = "Trip", rank = "Moderator", serious = false, needsReason = false },
	UnDisco = { label = "Stop Disco", rank = "Moderator", serious = false, needsReason = false },
	UnFF = { label = "Remove Field", rank = "Moderator", serious = false, needsReason = false },
	UnGhost = { label = "Normal Body", rank = "Helper", serious = false, needsReason = false },
	Unfire = { label = "Remove Fire", rank = "Helper", serious = false, needsReason = false },
	Unpunish = { label = "Unpunish", rank = "Moderator", serious = false, needsReason = false },
	Unragdoll = { label = "Unragdoll", rank = "Moderator", serious = false, needsReason = false },
	Unsmoke = { label = "Remove Smoke", rank = "Helper", serious = false, needsReason = false },
	Unsparkles = { label = "Remove Sparkles", rank = "Helper", serious = false, needsReason = false },
	Unspin = { label = "Stop Spin", rank = "Moderator", serious = false, needsReason = false },
}

local state = {
	sidebarExpanded = false,
	sidebarButtons = {},
	sidebarOrder = nil,
	sidebarOrderText = nil,
	sidebarFullOrder = nil,
	sidebarSaving = false,
	sidebarSavePending = false,
	sidebarLastSent = nil,
	sidebarWatcher = nil,
	sidebarDrag = nil,
	themeName = "Dark",
	themeButtons = {},
	panelOpen = false,
	notesModalOpen = false,
	inventoryModalOpen = false,
	currentTarget = nil,
	espActive = false,
	espEntries = nil,
	chatUnread = false,
	chatPopupList = nil,
	mobileButtonPos = nil,
	mobileButtonPositionTouched = false,
	mobileButtonViewportConn = nil,
	targetData = nil,
	resolvedTargetQuery = nil,
	resolvedTargetUserId = nil,
	targetQueryRaw = nil,
	panelSize = CONFIG.panels.main,
	panelPosition = UDim2.fromScale(0.5, 0.5),
	selectedTab = "home",
	lastTab = "home",
	fps = 0,
	fpsSamples = 0,
	fpsClock = 0,
	ping = 0,
	lastPingSent = 0,
	lastPingAck = 0,
	mobile = false,
	actionButtons = {},
	adminsData = {},
	banData = {},
	banSearchQuery = "",
	pinnedActions = {},
	inventoryLoadingToken = nil,
	moderationLogData = {},
	moderationLastRefresh = 0,
	moderationRefreshClock = 0,
	moderationSearchQuery = "",
	moderationFilters = {
		moderator = "",
		target = "",
		action = "",
		reason = "",
	},
	serverLastRefresh = 0,
	aiWelcomeShown = false,
	settingsData = {},
	translationAvailable = false,
	settingsDraft = nil,
	settingsBusy = false,
	settingsDirty = false,
	settingsStatus = "",
	statusVersion = 0,
	accessGranted = false,
	openKeyNames = {},
	chatMessages = {},
	chatLoaded = false,
	chatRenderedIds = {},
	notificationHolder = nil,
	notificationLayout = nil,
}

state.HistoryRF = ReplicatedStorage:WaitForChild("AdminPanelHistory")
state.AnnounceNotifyRE = ReplicatedStorage:WaitForChild("AdminPanelNotify")
state.AnnounceVoteRE = ReplicatedStorage:WaitForChild("AdminPanelVoteAction")


state.chatMessages = state.chatMessages or {}
state.chatRenderedIds = state.chatRenderedIds or {}
state.chatTypingUsers = state.chatTypingUsers or {}
state.chatTypingLocal = state.chatTypingLocal == true
state.chatInputFocused = state.chatInputFocused == true
state.chatPipOpen = false
state.chatPip = {}
state.chatTypingToken = tonumber(state.chatTypingToken) or 0
state.chatTypingLastSentAt = tonumber(state.chatTypingLastSentAt) or 0
state.chatLoaded = state.chatLoaded == true
state.chatHistoryRequested = state.chatHistoryRequested == true

local CHAT_HISTORY_LIMIT = 250

local function normalizeChatEntry(entry)
	if type(entry) ~= "table" then
		return nil
	end
	local message = trim(entry.message or entry.text or "")
	if message == "" then
		return nil
	end
	local id = tostring(entry.id or entry.messageId or "")
	if id == "" then
		id = HttpService:GenerateGUID(false)
	end
	local translationsByLanguage = {}
	if type(entry.translationsByLanguage) == "table" then
		for langCode, translatedValue in pairs(entry.translationsByLanguage) do
			if type(langCode) == "string" and (type(translatedValue) == "string" or translatedValue == false) then
				translationsByLanguage[langCode] = translatedValue
			end
		end
	end
	return {
		id = id,
		timestamp = tonumber(entry.timestamp or entry.time or os.time()) or os.time(),
		senderUserId = tonumber(entry.senderUserId or entry.userId or 0) or 0,
		senderName = tostring(entry.senderName or entry.name or "Admin"),
		senderDisplayName = tostring(entry.senderDisplayName or entry.displayName or entry.senderName or entry.name or "Admin"),
		message = message,
		translationsByLanguage = translationsByLanguage,
		jobId = tostring(entry.jobId or game.JobId),
		placeId = tonumber(entry.placeId) or game.PlaceId,
	}
end

local function ensureChatLayout()
	if not state.chatListHolder then
		return nil
	end
	local layout = state.chatListHolder:FindFirstChildOfClass("UIListLayout")
	if not layout then
		layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = state.chatListHolder
	end
	return layout
end

local function clearChatList()
	if not state.chatListHolder then
		return
	end
	local keep = {}
	local layout = state.chatListHolder:FindFirstChildOfClass("UIListLayout")
	if layout then
		keep[layout] = true
	end
	clearChildrenExcept(state.chatListHolder, keep)
end

local function sortChatMessages()
	table.sort(state.chatMessages, function(a, b)
		local ta = tonumber(a and a.timestamp) or 0
		local tb = tonumber(b and b.timestamp) or 0
		if ta == tb then
			return tostring(a and a.id or "") < tostring(b and b.id or "")
		end
		return ta < tb
	end)
	while #state.chatMessages > CHAT_HISTORY_LIMIT do
		table.remove(state.chatMessages, 1)
	end
end

local function isDuplicateChatEntry(existing, incoming)
	if type(existing) ~= "table" or type(incoming) ~= "table" then
		return false
	end
	if tostring(existing.id or "") ~= "" and tostring(existing.id or "") == tostring(incoming.id or "") then
		return true
	end
	local sameSender = tonumber(existing.senderUserId or 0) == tonumber(incoming.senderUserId or 0)
	local sameMessage = tostring(existing.message or "") == tostring(incoming.message or "")
	local dt = math.abs((tonumber(existing.timestamp) or 0) - (tonumber(incoming.timestamp) or 0))
	if sameSender and sameMessage and dt <= 2 then
		return true
	end
	return false
end

state.syncChatHistory = function(history)
	local mergedById = {}
	local mergedList = {}

	local function addEntry(entry)
		local normalized = normalizeChatEntry(entry)
		if not normalized then
			return
		end
		local existing = mergedById[normalized.id]
		if existing and tostring(existing.message or "") == tostring(normalized.message or "") then
			normalized.translationsByLanguage = existing.translationsByLanguage or normalized.translationsByLanguage
		end
		mergedById[normalized.id] = normalized
	end

	for _, entry in ipairs(state.chatMessages or {}) do
		addEntry(entry)
	end

	if type(history) == "table" then
		for _, entry in ipairs(history) do
			addEntry(entry)
		end
	end

	if state.chatPendingEntries then
		for pendingSyncKey in pairs(state.chatPendingEntries) do
			if mergedById[pendingSyncKey] ~= nil then
				state.chatPendingEntries[pendingSyncKey] = nil
				state.chatConfirmedAnimIds = state.chatConfirmedAnimIds or {}
				state.chatConfirmedAnimIds[pendingSyncKey] = true
			end
		end
	end

	for _, entry in pairs(mergedById) do
		table.insert(mergedList, entry)
	end

	table.sort(mergedList, function(a, b)
		local ta = tonumber(a and a.timestamp) or 0
		local tb = tonumber(b and b.timestamp) or 0
		if ta == tb then
			return tostring(a and a.id or "") < tostring(b and b.id or "")
		end
		return ta < tb
	end)

	state.chatMessages = mergedList
	state.chatRenderedIds = {}
	state.chatLoaded = true
	state.chatHistoryRequested = true
	if state.chatStatusLabel then
		state.chatStatusLabel.Text = "Chat loaded."
	end
	if state.refreshChatPanel then
		state.refreshChatPanel()
	end
	if state.scrollChatToBottom then
		state.scrollChatToBottom()
	end
end

state.pushChatEntry = function(entry)
	local normalized = normalizeChatEntry(entry)
	if not normalized then
		return
	end

	if state.chatPendingEntries then
		local pendingKey = tostring(normalized.id or "")
		if state.chatPendingEntries[pendingKey] ~= nil then
			state.chatPendingEntries[pendingKey] = nil
			state.chatConfirmedAnimIds = state.chatConfirmedAnimIds or {}
			state.chatConfirmedAnimIds[pendingKey] = true
		end
	end

	state.chatMessages = state.chatMessages or {}
	for i, existing in ipairs(state.chatMessages) do
		if isDuplicateChatEntry(existing, normalized) then
			if tostring(existing.message or "") == tostring(normalized.message or "") then
				normalized.translationsByLanguage = existing.translationsByLanguage or normalized.translationsByLanguage
			end
			state.chatMessages[i] = normalized
			sortChatMessages()
			if state.refreshChatPanel then
				state.refreshChatPanel()
			end
			if state.scrollChatToBottom then
				state.scrollChatToBottom()
			end
			return
		end
	end

	table.insert(state.chatMessages, normalized)
	sortChatMessages()

	if state.chatLoaded then
		local senderId = tonumber(normalized.senderUserId) or 0
		if senderId ~= localPlayer.UserId then
			local viewingChat = state.panelOpen == true and state.selectedTab == "chat"
			if not viewingChat then
				setChatUnread(true)
				showChatPopup(normalized)
			end
		end
	end

	if state.refreshChatPanel then
		state.refreshChatPanel()
	end
	if state.scrollChatToBottom then
		state.scrollChatToBottom()
	end
end

state.requestChatHistory = function()
	state.chatHistoryRequested = true
	pcall(function()
		RemoteEvent:FireServer("ChatGetHistory")
	end)
	if state.chatStatusLabel and (state.selectedTab == "chat" or state.chatStatusLabel.Text == "") then
		state.chatStatusLabel.Text = "Loading chat..."
	end
end

state.sendChatMessage = function()
	local inputBox = state.chatInputBox
	local message = trim(inputBox and inputBox.Text or "")
	if message == "" then
		if state.chatStatusLabel then
			state.chatStatusLabel.Text = "Type a message first."
		end
		return false
	end

	state.setChatTyping(false)

	local entry = {
		id = HttpService:GenerateGUID(false),
		timestamp = os.time(),
		senderUserId = localPlayer.UserId,
		senderName = localPlayer.Name,
		senderDisplayName = localPlayer.DisplayName,
		message = message,
		jobId = game.JobId,
		placeId = game.PlaceId,
	}

	if inputBox then
		inputBox.Text = ""
		pcall(function()
			inputBox:ReleaseFocus()
		end)
	end

	if state.chatStatusLabel then
		state.chatStatusLabel.Text = "Sending..."
	end

	local ok, err = pcall(function()
		RemoteEvent:FireServer("ChatSendMessage", {
			id = entry.id,
			clientId = entry.id,
			message = message,
			text = message,
			timestamp = entry.timestamp,
			jobId = entry.jobId,
			placeId = entry.placeId,
		})
	end)

	if not ok then
		if state.chatStatusLabel then
			state.chatStatusLabel.Text = "Failed to send chat message."
		end
		warn("[Zone Panel] Chat send failed:", err)
		return false
	end

	state.chatPendingEntries = state.chatPendingEntries or {}
	state.chatPendingEntries[tostring(entry.id)] = entry

	task.delay(2.5, function()
		pcall(function()
			RemoteEvent:FireServer("ChatGetHistory")
		end)
	end)

	task.delay(10, function()
		local pend = state.chatPendingEntries
		if pend and pend[tostring(entry.id)] ~= nil then
			pend[tostring(entry.id)].failed = true
			if state.chatStatusLabel then
				state.chatStatusLabel.Text = "Message could not be delivered. Try again."
			end
			if state.refreshChatPanel then
				state.refreshChatPanel()
			end
		end
	end)

	task.defer(function()
		if state.selectedTab == "chat" and state.refreshChatPanel then
			state.refreshChatPanel()
			if state.scrollChatToBottom then
				state.scrollChatToBottom()
			end
		end
	end)

	return true
end

state.trySendChatMessage = function()
	local ok, result = pcall(function()
		return state.sendChatMessage()
	end)
	if not ok then
		if state.chatStatusLabel then
			state.chatStatusLabel.Text = "Chat send error."
		end
		warn("[Zone Panel] Chat send error:", result)
		return false
	end
	return result == true
end

local getChatAvatarUrl, refreshChatTypingLabel

state.scrollChatToBottom = function()
	if not state.chatScroll then
		return
	end
	if state.chatPressHold then
		local h = state.chatPressHold
		state.chatPressHold = nil
		for _, f in ipairs(h.frames) do
			if f.conn then
				pcall(function()
					f.conn:Disconnect()
				end)
				f.conn = nil
			end
		end
	end

	local function doScroll()
		if state.chatScroll and state.chatScroll.Parent then
			pcall(function()
				state.chatScroll.CanvasPosition = Vector2.new(0, 999999)
			end)
		end
		if state.chatPip and state.chatPip.mobileScroll and state.chatPip.mobileScroll.Parent then
			pcall(function()
				state.chatPip.mobileScroll.CanvasPosition = Vector2.new(0, 999999)
			end)
		end
		if state.chatMobileScroll and state.chatMobileScroll.Parent then
			pcall(function()
				state.chatMobileScroll.CanvasPosition = Vector2.new(0, 999999)
			end)
		end
	end

	doScroll()
	task.defer(doScroll)
	task.delay(0.03, doScroll)
end

function chatWrapLongWords(text)
	text = tostring(text or "")
	local words = {}
	for w in string.gmatch(text, "%S+") do
		if #w > 20 then
			local pieces = {}
			for i = 1, math.ceil(#w / 18) do
				table.insert(pieces, string.sub(w, (i - 1) * 18 + 1, i * 18))
			end
			table.insert(words, table.concat(pieces, "\226\128\139"))
		else
			table.insert(words, w)
		end
	end
	if #words == 0 then
		return text
	end
	return table.concat(words, " ")
end
local function measureChatBubbleSize(message, padX, holder)
	message = tostring(message or "")
	local sidePad = tonumber(padX) or 52
	local holderWidth = 520
	local ref = holder or state.chatListHolder
	if ref and ref.AbsoluteSize then
		holderWidth = math.max(280, math.floor((ref.AbsoluteSize.X > 0 and ref.AbsoluteSize.X) or holderWidth))
	end

	local maxBubbleWidth = math.max(140, math.min(math.floor(holderWidth * 0.52), 320))
	local maxTextWidth = math.max(70, maxBubbleWidth - sidePad)

	local ok, measured = pcall(function()
		return TextService:GetTextSize(message, 13, Enum.Font.Gotham, Vector2.new(maxTextWidth, 100000))
	end)
	local textWidth = (ok and measured) and math.ceil(measured.X) or 60
	textWidth = math.min(textWidth + 2, maxTextWidth)
	local bubbleWidth = math.clamp(textWidth + sidePad, 140, maxBubbleWidth)
	local contentWidth = math.max(70, bubbleWidth - sidePad)
	local okHeight, measuredHeight = pcall(function()
		return TextService:GetTextSize(message, 13, Enum.Font.Gotham, Vector2.new(contentWidth - 1, 100000))
	end)
	local textHeight = (okHeight and measuredHeight) and math.ceil(measuredHeight.Y) or 16
	textHeight = math.max(15, textHeight) + 1

	return bubbleWidth, textHeight
end

getChatAvatarUrl = function(userId)
	userId = tonumber(userId) or 0
	local key = tostring(userId)
	state.avatarCache = state.avatarCache or {}
	if state.avatarCache[key] then
		return state.avatarCache[key]
	end

	local url = "rbxassetid://0"
	local ok, result = pcall(function()
		return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	if ok and type(result) == "string" and result ~= "" then
		url = result
	end
	state.avatarCache[key] = url
	return url
end

refreshChatTypingLabel = function()
	if not state.chatTypingLabel then
		return
	end

	local typing = {}
	local seen = {}

	for _, info in ipairs(state.chatTypingUsers or {}) do
		if type(info) == "table" then
			local userId = tonumber(info.userId or info.senderUserId or 0) or 0
			if userId ~= 0 and userId ~= tonumber(localPlayer.UserId) and not seen[userId] then
				seen[userId] = true
				table.insert(typing, info)
			end
		end
	end

	local names = {}
	for _, info in ipairs(typing) do
		local name = streamerShortText(tostring(info.displayName or info.senderDisplayName or info.name or info.senderName or "Player"))
		if name ~= "" then
			table.insert(names, name)
		end
	end

	local text = ""
	if #names == 1 then
		text = names[1] .. " is typing..."
	elseif #names == 2 then
		text = names[1] .. " and " .. names[2] .. " are typing..."
	elseif #names > 2 then
		text = names[1] .. " and " .. tostring(#names - 1) .. " others are typing..."
	end

	state.chatTypingLabel.Visible = text ~= ""
	state.chatTypingLabel.Text = text
end

state.updateChatTypingState = function(payload)
	state.chatTypingUsers = {}
	if type(payload) == "table" then
		for _, entry in ipairs(payload) do
			if type(entry) == "table" then
				table.insert(state.chatTypingUsers, entry)
			end
		end
	end
	refreshChatTypingLabel()
end

state.setChatTyping = function(typing)
	typing = typing == true
	if typing then
		state.chatTypingLocal = true
		state.chatTypingLastSentAt = os.clock()
		pcall(function()
			RemoteEvent:FireServer("ChatTyping", { typing = true })
		end)
		return
	end
	if state.chatTypingLocal == false then
		return
	end
	state.chatTypingLocal = false
	pcall(function()
		RemoteEvent:FireServer("ChatTyping", { typing = false })
	end)
end

state.bumpChatTyping = function()
	state.chatTypingToken = (tonumber(state.chatTypingToken) or 0) + 1
	local token = state.chatTypingToken

	if not state.chatInputFocused then
		return
	end

	if (os.clock() - (state.chatTypingLastSentAt or 0)) > 1.25 then
		state.setChatTyping(true)
	end

	task.delay(2, function()
		if state.chatInputFocused and state.chatTypingToken == token then
			state.setChatTyping(false)
		end
	end)
end

CHAT_PENDING_ICON_ID = "rbxassetid://17119858971"
CHAT_FAILED_ICON_ID = "rbxassetid://73054942442557"

function renderChatPendingEntries()
	if not state.chatListHolder then
		return
	end
	local pendingList = {}
	for _, item in pairs(state.chatPendingEntries or {}) do
		if type(item) == "table" then
			table.insert(pendingList, item)
		end
	end
	table.sort(pendingList, function(a, b)
		return (tonumber(a.timestamp) or 0) < (tonumber(b.timestamp) or 0)
	end)
	if #pendingList == 0 then
		return
	end
	local th = theme()
	state.chatSeenPending = state.chatSeenPending or {}
	for _, item in ipairs(pendingList) do
		local isFailed = item.failed == true
		local pendingAnimKey = tostring(item.id or "")
		if pendingAnimKey == "" then
			pendingAnimKey = ("p|%s|%s"):format(tostring(item.message or ""), tostring(tonumber(item.timestamp) or 0))
		end
		local isNewPending = state.chatSeenPending[pendingAnimKey] ~= true
		state.chatSeenPending[pendingAnimKey] = true
		local messageText = chatWrapLongWords(tostring(item.message or ""))
		local bubbleWidth, textHeight = measureChatBubbleSize(messageText, 52, state.chatListHolder)
		local contentHeight = 16 + textHeight
		local bubbleHeight = math.max(contentHeight + 16, 52)

		local wrapper = make("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, bubbleHeight),
			Parent = state.chatListHolder,
		})

		local bubble = make("Frame", {
			BackgroundColor3 = th.panel2,
			BackgroundTransparency = isFailed and 0.45 or 0.3,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, bubbleWidth, 0, bubbleHeight),
			Parent = wrapper,
		})
		corner(bubble, 14)
		stroke(bubble, 0.92)

		local avatar = make("ImageLabel", {
			BackgroundColor3 = th.panel2,
			BackgroundTransparency = 0.08,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(36, 36),
			Position = UDim2.new(1, -40, 0, 8),
			Image = getChatAvatarUrl(localPlayer.UserId),
			ScaleType = Enum.ScaleType.Crop,
			Parent = bubble,
		})
		corner(avatar, 18)
		stroke(avatar, 0.7)
		presenceAttachDot(avatar, localPlayer.UserId, 14)

		local content = make("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(8, 6),
			Size = UDim2.new(1, -52, 0, contentHeight),
			Parent = bubble,
		})

		make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 14),
			Text = os.date("%H:%M", tonumber(item.timestamp) or os.time()),
			Font = Enum.Font.Gotham,
			TextSize = 10,
			TextColor3 = th.muted,
			TextTransparency = 0.35,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Top,
			Parent = content,
		})

		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 16),
			Size = UDim2.new(1, 0, 0, textHeight),
			Text = messageText,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextWrapped = true,
			TextColor3 = isFailed and Color3.fromRGB(235, 87, 87) or th.text,
			TextTransparency = isFailed and 0.35 or 0.45,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Parent = content,
		})

		local iconId = CHAT_PENDING_ICON_ID
		if isFailed then
			iconId = CHAT_FAILED_ICON_ID
		end
		local spinner = make("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -(bubbleWidth + 22), 0.5, 0),
			Size = UDim2.fromOffset(20, 20),
			Image = iconId,
			Parent = wrapper,
		})
		if not isFailed then
			task.spawn(function()
				while spinner and spinner.Parent do
					spinner.Rotation = (spinner.Rotation + 6) % 360
					task.wait(0.03)
				end
			end)
		end
		if isNewPending then
			animateBubbleIn(bubble, { spinner })
		end
	end
end

function collectBubbleFadeTargets(root, extras)
	local targets = {}
	local function addTarget(inst)
		if inst:IsA("GuiObject") then
			if inst.BackgroundTransparency < 1 then
				table.insert(targets, { inst = inst, prop = "BackgroundTransparency", value = inst.BackgroundTransparency })
			end
			if (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) and inst.TextTransparency < 1 then
				table.insert(targets, { inst = inst, prop = "TextTransparency", value = inst.TextTransparency })
			end
			if (inst:IsA("ImageLabel") or inst:IsA("ImageButton")) and inst.ImageTransparency < 1 then
				table.insert(targets, { inst = inst, prop = "ImageTransparency", value = inst.ImageTransparency })
			end
		elseif inst:IsA("UIStroke") then
			if inst.Transparency < 1 then
				table.insert(targets, { inst = inst, prop = "Transparency", value = inst.Transparency })
			end
		end
	end
	if root then
		addTarget(root)
		for _, inst in ipairs(root:GetDescendants()) do
			addTarget(inst)
		end
	end
	for _, inst in ipairs(extras or {}) do
		addTarget(inst)
	end
	return targets
end

function animateBubbleIn(bubble, extras)
	if not bubble or not bubble.Parent then
		return
	end
	local info = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local targets = collectBubbleFadeTargets(bubble, extras)
	for _, item in ipairs(targets) do
		item.inst[item.prop] = 1
	end
	for _, item in ipairs(targets) do
		TweenService:Create(item.inst, info, { [item.prop] = item.value }):Play()
	end
end

function animateBubbleOut(bubble, onDone)
	local function finish()
		if onDone then
			pcall(onDone)
		end
	end
	if not bubble or not bubble.Parent then
		finish()
		return
	end
	local info = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local targets = collectBubbleFadeTargets(bubble, nil)
	for _, item in ipairs(targets) do
		TweenService:Create(item.inst, info, { [item.prop] = 1 }):Play()
	end
	task.delay(0.2, finish)
end

state.refreshChatPanel = function()
	if not state.chatListHolder then
		return
	end

	ensureChatLayout()
	clearChatList()

	local th = theme()
	local list = state.chatMessages or {}
	local unique = {}
	local rendered = {}
	for _, entry in ipairs(list) do
		if type(entry) == "table" then
			local key = tostring(entry.id or "")
			if key == "" then
				key = ("%s|%s|%s"):format(tostring(entry.senderUserId or 0), tostring(entry.message or ""), tostring(tonumber(entry.timestamp) or 0))
			end
			if not unique[key] then
				unique[key] = true
				table.insert(rendered, entry)
			end
		end
	end
	list = rendered

	local pendingCount = 0
	for _ in pairs(state.chatPendingEntries or {}) do
		pendingCount = pendingCount + 1
	end

	if #list == 0 and pendingCount == 0 then
		make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 24),
			Text = "No chat messages yet.",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = state.chatListHolder,
		})
		return
	end

	for _, entry in ipairs(list) do
		if type(entry) == "table" then
			local isSelf = tonumber(entry.senderUserId) == tonumber(localPlayer.UserId)
			local messageText = chatWrapLongWords(tostring(entry.message or ""))
			local bubbleWidth, textHeight = measureChatBubbleSize(messageText, 52, state.chatListHolder)
			local contentHeight = 16 + textHeight
			local bubbleHeight = math.max(contentHeight + 16, 52)
			state.chatSeenBubbles = state.chatSeenBubbles or {}
			state.chatConfirmedAnimIds = state.chatConfirmedAnimIds or {}
			local bubbleKey = tostring(entry.id or "")
			if bubbleKey == "" then
				bubbleKey = ("%s|%s|%s"):format(tostring(entry.senderUserId or 0), tostring(entry.message or ""), tostring(tonumber(entry.timestamp) or 0))
			end
			local isNewBubble = state.chatSeenBubbles[bubbleKey] ~= true and state.chatConfirmedAnimIds[bubbleKey] ~= true
			state.chatSeenBubbles[bubbleKey] = true

			local wrapper = make("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, bubbleHeight),
				Parent = state.chatListHolder,
			})

			local bubble = make("Frame", {
				BackgroundColor3 = isSelf and th.panel2 or th.card,
				BackgroundTransparency = isSelf and 0.02 or 0.08,
				BorderSizePixel = 0,
				AnchorPoint = isSelf and Vector2.new(1, 0) or Vector2.new(0, 0),
				Position = isSelf and UDim2.new(1, 0, 0, 0) or UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(0, bubbleWidth, 0, bubbleHeight),
				Parent = wrapper,
			})
			corner(bubble, 14)
			stroke(bubble, 0.92)

			local avatar = make("ImageLabel", {
				BackgroundColor3 = th.panel2,
				BackgroundTransparency = 0.08,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(36, 36),
				Position = isSelf and UDim2.new(1, -40, 0, 8) or UDim2.fromOffset(8, 8),
				Image = getChatAvatarUrl(entry.senderUserId),
				ScaleType = Enum.ScaleType.Crop,
				Parent = bubble,
			})
			corner(avatar, 18)
			stroke(avatar, 0.7)
			presenceAttachDot(avatar, entry.senderUserId, 14)

			local content = make("Frame", {
				BackgroundTransparency = 1,
				Position = isSelf and UDim2.fromOffset(8, 6) or UDim2.fromOffset(44, 6),
				Size = UDim2.new(1, -52, 0, contentHeight),
				Parent = bubble,
			})

			make("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 14),
				Text = os.date("%H:%M", tonumber(entry.timestamp) or os.time()),
				Font = Enum.Font.Gotham,
				TextSize = 10,
				TextColor3 = th.muted,
				TextXAlignment = isSelf and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left,
				Parent = content,
			})

			local originalMessageLabel = make("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, 16),
				Size = UDim2.new(1, 0, 0, textHeight),
				Text = messageText,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextWrapped = true,
				TextColor3 = th.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				Parent = content,
			})
			originalMessageLabel:SetAttribute("ZoneLangSkip", true)
			if isNewBubble then
				animateBubbleIn(bubble)
			end
		end
	end

	renderChatPendingEntries()

	state.scrollChatToBottom()
end
local gui, main, mobileScroll, mobileInner, mobileHeader, mobileHeaderTitle, mobileHeaderSubtitle, mobileTabScroll, mobileTabHolder, mobileTabButtons, mobileCloseBtn
local topbar, titleLbl, closeBtn, resizeGrip, resizeGripIcon
local codeOverlay, codeFrame, codeTitle, codeText, codeConfirmBtn, codeCancelBtn
local confirmOverlay, confirmFrame, confirmTitle, confirmBody, confirmYes, confirmNo
local notesModalOverlay, notesModalFrame, notesModalTitle, notesModalCloseBtn
local notesModalScroll, notesModalListHolder, notesModalEmptyLabel, notesModalAddBox, notesModalAddBtn
local moderationFilterOverlay, moderationFilterFrame, moderationFilterTitle, moderationFilterCloseBtn
local moderationFilterModeratorBox, moderationFilterTargetBox, moderationFilterActionBox, moderationFilterReasonBox
local moderationFilterApplyBtn, moderationFilterClearBtn, moderationFilterSummaryLabel
local left, right, sidebar
local sidebarHomeBtn, sidebarAdminsBtn, sidebarServerBtn, sidebarBanBtn, sidebarAnnounceBtn
local targetBox, resolveBtn, avatarImage, selectedName, selectedInfo, statusLabel, reasonBox, valueBox, viewNotesBtn
local infoCards = {}
local actionsScroll, pinnedHolder, actionsHolder, adminsScroll, adminsListHolder, adminsEmptyLabel, adminsCountLabel, serverScroll, creditsScroll, banScroll, banListHolder, banEmptyLabel, banCountLabel, banSearchBox, banRefreshLabel, moderationScroll, settingsScroll
local serverTitleLabel, serverRefreshLabel, serverSummaryValue, serverStatusValue, serverRegionValue, serverPlayersHolder
local moderationTitleLabel, moderationRefreshLabel, moderationSearchBox, moderationSearchClearBtn, moderationCountLabel, moderationListHolder, moderationEmptyLabel
local serverRows = {}
local banRows = {}
local mainScale, responsiveScale, rightScale
local adminAddBox, adminAddRankBox, adminAddBtn
local settingsInfoLabel, settingsWebhookBox, settingsWebhookToggle, settingsOpenInStartToggle, settingsRememberLastTabToggle, settingsStreamerModeToggle, settingsBlurToggle, settingsSaveBtn, settingsStatusLabel
local chatTypingLabel = nil
local backdropBlur = nil
local inputBar = nil

local dragState = nil
local resizeState = nil

function theme()
	local name = state and state.themeName or DEFAULT_THEME_NAME
	return THEMES[name] or THEMES[DEFAULT_THEME_NAME]
end

function currentThemeName()
	local name = state and state.themeName or DEFAULT_THEME_NAME
	if THEMES[name] then
		return name
	end
	return DEFAULT_THEME_NAME
end

function clamp01(v)
	if v < 0 then return 0 end
	if v > 1 then return 1 end
	return v
end

function colorToHex(color)
	if typeof(color) ~= "Color3" then
		return "FFFFFF"
	end
	return ("%02X%02X%02X"):format(
		math.floor(clamp01(color.R) * 255 + 0.5),
		math.floor(clamp01(color.G) * 255 + 0.5),
		math.floor(clamp01(color.B) * 255 + 0.5)
	)
end

function hexToColor(text)
	local clean = tostring(text or ""):gsub("#", ""):gsub("%s", "")
	if #clean == 3 then
		clean = clean:sub(1, 1):rep(2) .. clean:sub(2, 2):rep(2) .. clean:sub(3, 3):rep(2)
	end
	if #clean ~= 6 or clean:match("%X") then
		return nil
	end
	local r = tonumber(clean:sub(1, 2), 16)
	local g = tonumber(clean:sub(3, 4), 16)
	local b = tonumber(clean:sub(5, 6), 16)
	if not r or not g or not b then
		return nil
	end
	return Color3.fromRGB(r, g, b)
end

function contrastTextFor(color)
	if typeof(color) ~= "Color3" then
		return Color3.fromRGB(18, 18, 20)
	end
	local luminance = 0.299 * color.R + 0.587 * color.G + 0.114 * color.B
	if luminance > 0.6 then
		return Color3.fromRGB(18, 18, 20)
	end
	return Color3.fromRGB(250, 250, 252)
end

function isLightTheme(name)
	return LIGHT_THEME_NAMES[tostring(name or currentThemeName())] == true
end

function colorKey(color)
	if typeof(color) ~= "Color3" then
		return nil
	end
	return ("%d_%d_%d"):format(
		math.floor(color.R * 255 + 0.5),
		math.floor(color.G * 255 + 0.5),
		math.floor(color.B * 255 + 0.5)
	)
end

function snapshotPalette(palette)
	local copy = {}
	if type(palette) ~= "table" then
		return copy
	end
	for _, key in ipairs(THEME_COLOR_KEYS) do
		if typeof(palette[key]) == "Color3" then
			copy[key] = palette[key]
		end
	end
	return copy
end

function buildPaletteRemap(fromPalette, toPalette)
	local map = {}
	if type(fromPalette) ~= "table" or type(toPalette) ~= "table" then
		return map
	end
	for _, key in ipairs(THEME_COLOR_KEYS) do
		local a = fromPalette[key]
		local b = toPalette[key]
		if typeof(a) == "Color3" and typeof(b) == "Color3" then
			local k = colorKey(a)
			if k and map[k] == nil then
				map[k] = b
			end
		end
	end
	local onAccent = toPalette.onAccent or Color3.fromRGB(22, 22, 22)
	map["22_22_22"] = onAccent
	map["255_255_255"] = map["255_255_255"] or toPalette.text
	return map
end

function remapInstanceColors(inst, map)
	if not inst or type(map) ~= "table" then
		return
	end
	if inst.Name == "Artwork" then
		return
	end
	local props = { "BackgroundColor3", "TextColor3", "PlaceholderColor3", "ImageColor3", "ScrollBarImageColor3", "BorderColor3" }
	for _, prop in ipairs(props) do
		local ok, current = pcall(function()
			return inst[prop]
		end)
		if ok and typeof(current) == "Color3" then
			local k = colorKey(current)
			local replacement = k and map[k]
			if replacement then
				pcall(function()
					inst[prop] = replacement
				end)
			end
		end
	end
	if inst:IsA("UIStroke") then
		local k = colorKey(inst.Color)
		local replacement = k and map[k]
		if replacement then
			pcall(function()
				inst.Color = replacement
			end)
		end
	end
	if inst:IsA("UIGradient") then
		local ok, seq = pcall(function()
			return inst.Color
		end)
		if ok and typeof(seq) == "ColorSequence" then
			local points = {}
			local changed = false
			for _, kp in ipairs(seq.Keypoints) do
				local k = colorKey(kp.Value)
				local replacement = k and map[k]
				if replacement then
					changed = true
					table.insert(points, ColorSequenceKeypoint.new(kp.Time, replacement))
				else
					table.insert(points, kp)
				end
			end
			if changed and #points >= 2 then
				pcall(function()
					inst.Color = ColorSequence.new(points)
				end)
			end
		end
	end
end

function animatedBackgroundEnabled()
	if state and type(state.settingsData) == "table" and state.settingsData.animatedBackground ~= nil then
		return state.settingsData.animatedBackground == true
	end
	return false
end

function backgroundImageEnabled()
	if state and type(state.settingsData) == "table" and state.settingsData.backgroundImage ~= nil then
		return state.settingsData.backgroundImage == true
	end
	return false
end

function updateBackgroundImage()
	if not main or not main.Parent or not gui then
		return
	end
	local img = state.panelBgImage
	if img and img.Parent == main then
		img:Destroy()
		img = nil
		state.panelBgImage = nil
	end
	if not img or not img.Parent then
		img = make("ImageLabel", {
			Name = "PanelBackgroundImage",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = main.Position,
			Size = main.Size,
			BackgroundTransparency = 1,
			Image = BACKGROUND_IMAGE_ID,
			ImageTransparency = 0.35,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ScaleType = Enum.ScaleType.Crop,
			ZIndex = 1,
			Visible = false,
			Parent = gui,
		})
		corner(img, 18)
		state.panelBgImage = img
	end
	local showImg = state.panelOpen == true and backgroundImageEnabled()
	if showImg then
		if main.ZIndex <= 1 then
			main.ZIndex = 2
		end
		local scaleMultiplier = 1
		if responsiveScale then
			scaleMultiplier = scaleMultiplier * responsiveScale.Scale
		end
		if mainScale then
			scaleMultiplier = scaleMultiplier * mainScale.Scale
		end
		img.Position = main.Position
		img.Size = UDim2.new(main.Size.X.Scale * scaleMultiplier, math.floor(main.Size.X.Offset * scaleMultiplier + 0.5), main.Size.Y.Scale * scaleMultiplier, math.floor(main.Size.Y.Offset * scaleMultiplier + 0.5))
	end
	img.Visible = showImg
end

function backgroundGradientColors()
	local th = theme()
	local base = th.bg
	local accent = th.accent or th.neon or base
	if currentThemeName() == "Custom" then
		accent = getCustomAccent()
	end
	local hue, sat, val = Color3.toHSV(accent)
	local _, _, baseVal = Color3.toHSV(base)
	local dark = baseVal < 0.5

	local softSat = math.min(math.max(sat, 0.45), dark and 0.9 or 0.5)
	local softVal = dark and math.clamp(baseVal + 0.42, 0.4, 0.72) or math.clamp(baseVal - 0.2, 0.55, 0.85)

	local a = Color3.fromHSV((hue - 0.07) % 1, softSat * 0.85, softVal * 0.82)
	local b = Color3.fromHSV(hue, softSat, softVal)
	local c = Color3.fromHSV((hue + 0.07) % 1, softSat * 0.85, softVal * 0.82)

	return ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, a),
		ColorSequenceKeypoint.new(0.25, b),
		ColorSequenceKeypoint.new(0.50, c),
		ColorSequenceKeypoint.new(0.75, b),
		ColorSequenceKeypoint.new(1.00, a),
	})
end

function backgroundFadeSequence()
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0.00, 0.75),
		NumberSequenceKeypoint.new(0.20, 0.18),
		NumberSequenceKeypoint.new(0.50, 0),
		NumberSequenceKeypoint.new(0.80, 0.18),
		NumberSequenceKeypoint.new(1.00, 0.75),
	})
end

function ensureBackgroundLayer()
	if not main or not main.Parent then
		return nil
	end
	local layer = state.bgLayer
	if not layer or not layer.Parent then
		layer = make("Frame", {
			Name = "AnimatedBackground",
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.12,
			BorderSizePixel = 0,
			ZIndex = 0,
			Visible = false,
			Parent = main,
		})
		corner(layer, 18)
		state.bgLayer = layer
	end
	local grad = layer:FindFirstChild("BackgroundSweep")
	if not grad then
		grad = Instance.new("UIGradient")
		grad.Name = "BackgroundSweep"
		grad.Parent = layer
		state.bgGradient = grad
	end
	state.bgGradient = grad
	return layer
end

function stopBackgroundAnimation()
	for _, key in ipairs({ "bgDriftTween", "bgSpinTween" }) do
		if state[key] then
			pcall(function()
				state[key]:Cancel()
			end)
			state[key] = nil
		end
	end
end

function startBackgroundAnimation()
	stopBackgroundAnimation()
	local layer = ensureBackgroundLayer()
	if layer and type(ensureBackgroundElementHolder) == "function" and type(buildBackgroundElements) == "function" then
		local holder = ensureBackgroundElementHolder(layer)
		local style = backgroundStyleCode()
		if state.bgElementsStyle ~= style then
			if style == "stripes" then
				if holder then for _, child in ipairs(holder:GetChildren()) do child:Destroy() end end
				state.bgOrbFloatTweens = {}
			else
				buildBackgroundElements(holder, style)
			end
			state.bgElementsStyle = style
		end
		if holder then holder.Visible = style ~= "stripes" end
	end
	if not layer then
		return
	end
	local grad = state.bgGradient
	if not grad then
		return
	end

	if not animatedBackgroundEnabled() then
		layer.Visible = false
		return
	end

	layer.Visible = true
	grad.Color = backgroundGradientColors()
	grad.Transparency = backgroundFadeSequence()
	grad.Offset = Vector2.new(-1, 0)
	grad.Rotation = 25

	state.bgDriftTween = TweenService:Create(
		grad,
		TweenInfo.new(13, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Offset = Vector2.new(1, 0) }
	)
	state.bgDriftTween:Play()

	state.bgSpinTween = TweenService:Create(
		grad,
		TweenInfo.new(19, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Rotation = -25 }
	)
	state.bgSpinTween:Play()
end

function refreshAnimatedBackground()
	if state.bgStartThread then
		task.cancel(state.bgStartThread)
		state.bgStartThread = nil
	end
	if animatedBackgroundEnabled() and state.panelOpen == true then
		startBackgroundAnimation()
	else
		stopBackgroundAnimation()
		if state.bgLayer and state.bgLayer.Parent then
			state.bgLayer.Visible = false
		end
	end
	if state.chatPipOpen == true and animatedBackgroundEnabled() then
		startChatPipBackground()
	else
		stopChatPipBackground()
		if state.chatPip and state.chatPip.bgLayer and state.chatPip.bgLayer.Parent then
			state.chatPip.bgLayer.Visible = false
		end
	end
	updateBackgroundImage()
end

function scheduleAnimatedBackground(delaySeconds)
	if state.bgStartThread then
		task.cancel(state.bgStartThread)
		state.bgStartThread = nil
	end
	if not animatedBackgroundEnabled() then
		stopBackgroundAnimation()
		if state.bgLayer and state.bgLayer.Parent then
			state.bgLayer.Visible = false
		end
		return
	end
	local wait = tonumber(delaySeconds) or 0
	if wait <= 0 then
		if state.panelOpen == true then
			startBackgroundAnimation()
		end
		return
	end
	state.bgStartThread = task.delay(wait, function()
		state.bgStartThread = nil
		if state.panelOpen == true and animatedBackgroundEnabled() then
			startBackgroundAnimation()
		end
	end)
end

function rainbowGradient(parent)
	if not parent then
		return nil
	end
	local existing = parent:FindFirstChild("RainbowGradient")
	if existing then
		return existing
	end
	local grad = Instance.new("UIGradient")
	grad.Name = "RainbowGradient"
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 64, 64)),
		ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 176, 59)),
		ColorSequenceKeypoint.new(0.34, Color3.fromRGB(255, 241, 82)),
		ColorSequenceKeypoint.new(0.51, Color3.fromRGB(86, 226, 120)),
		ColorSequenceKeypoint.new(0.68, Color3.fromRGB(74, 178, 255)),
		ColorSequenceKeypoint.new(0.85, Color3.fromRGB(140, 110, 255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(238, 106, 220)),
	})
	grad.Parent = parent
	return grad
end

function presenceStateColor(stateName)
	if stateName == "banned" then
		return Color3.fromRGB(235, 87, 87)
	end
	if stateName == "here" or stateName == "elsewhere" then
		return Color3.fromRGB(87, 227, 137)
	end
	return Color3.fromRGB(130, 138, 150)
end

function presenceStateText(stateName)
	if stateName == "banned" then
		return "Banned"
	end
	if stateName == "here" then
		return "In this server"
	end
	if stateName == "elsewhere" then
		return "In another server"
	end
	return "Offline"
end

function presenceStateFor(userId)
	userId = tonumber(userId) or 0
	if userId <= 0 then
		return "offline"
	end
	state.presenceCache = state.presenceCache or {}
	local hit = state.presenceCache[tostring(userId)]
	if type(hit) == "table" then
		return tostring(hit.state or "offline"), hit.jobId
	end
	if Players:GetPlayerByUserId(userId) then
		return "here", nil
	end
	return "offline", nil
end

function presenceTrack(userId)
	userId = tonumber(userId) or 0
	if userId <= 0 then
		return
	end
	state.presenceWanted = state.presenceWanted or {}
	state.presenceWanted[userId] = true
end

function presenceAttachDot(parent, userId, size)
	if not parent then
		return nil
	end
	presenceTrack(userId)
	local th = theme()
	local ring = make("Frame", {
		Name = "PresenceRing",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 1, 1, 1),
		Size = UDim2.fromOffset(size or 18, size or 18),
		BackgroundColor3 = th.card,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = parent,
	})
	corner(ring, math.floor((size or 18) / 2))

	local inner = math.max(6, (size or 18) - 6)
	local dot = make("Frame", {
		Name = "PresenceDot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(inner, inner),
		BackgroundColor3 = presenceStateColor(select(1, presenceStateFor(userId))),
		BorderSizePixel = 0,
		ZIndex = 7,
		Parent = ring,
	})
	corner(dot, math.floor(inner / 2))

	state.presenceDots = state.presenceDots or {}
	table.insert(state.presenceDots, { ring = ring, dot = dot, userId = tonumber(userId) or 0 })
	return ring
end

function presenceRepaintDots()
	local th = theme()
	local kept = {}
	for _, item in ipairs(state.presenceDots or {}) do
		if item.dot and item.dot.Parent and item.ring and item.ring.Parent then
			item.ring.BackgroundColor3 = th.card
			item.dot.BackgroundColor3 = presenceStateColor(select(1, presenceStateFor(item.userId)))
			table.insert(kept, item)
		end
	end
	state.presenceDots = kept
end

function presenceRefresh()
	local wanted = state.presenceWanted
	if type(wanted) ~= "table" then
		return
	end
	local ids = {}
	for userId in pairs(wanted) do
		table.insert(ids, userId)
	end
	if #ids == 0 then
		return
	end
	local ok, res = pcall(function()
		return ResolveRF:InvokeServer({ mode = "presence", userIds = ids })
	end)
	if ok and type(res) == "table" and type(res.states) == "table" then
		state.presenceCache = res.states
		presenceRepaintDots()
		if state.selectedTab == "admins" then
			pcall(refreshAdmins)
		end
	end
end

function isInsideThemePicker(inst)
	local grid = state and state.settingsThemeGrid
	local picker = state and state.colorPickerFrame
	local setupGrid = state and state.setupWizard and state.setupWizard.themeGrid
	local node = inst
	while node do
		if grid and node == grid then
			return true
		end
		if picker and node == picker then
			return true
		end
		if setupGrid and node == setupGrid then
			return true
		end
		node = node.Parent
	end
	return false
end

function recolorTree(root, map)
	if not root or type(map) ~= "table" or next(map) == nil then
		return
	end
	remapInstanceColors(root, map)
	local ok, children = pcall(function()
		return root:GetDescendants()
	end)
	if not ok or type(children) ~= "table" then
		return
	end
	for _, child in ipairs(children) do
		if not isInsideThemePicker(child) then
			remapInstanceColors(child, map)
		end
	end
end

function trim(s)
	return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

function now()
	return os.clock()
end

local function notifyNoAccessFallback(message)
	local text = tostring(message or "You do not have access to this panel.")
	warn("[Zone Panel] " .. text)
end

function isStreamerModeEnabled()
	return state.settingsData and state.settingsData.streamerMode == true
end

function streamerShortText(value)
	value = tostring(value or "")
	if value == "" then
		return "Player"
	end
	if isStreamerModeEnabled() then
		if #value <= 3 then
			return value
		end
		return value:sub(1, 3) .. "..."
	end
	return value
end

function visiblePlayerName(record, preferDisplay)
	if type(record) ~= "table" then
		return streamerShortText(record)
	end
	local raw
	if preferDisplay then
		raw = record.DisplayName or record.displayName or record.Name or record.name or "Player"
	else
		raw = record.Name or record.name or record.DisplayName or record.displayName or "Player"
	end
	return streamerShortText(raw)
end

function visibleUserId(userId)
	if isStreamerModeEnabled() then
		return "***"
	end
	local n = tonumber(userId) or 0
	return n > 0 and tostring(n) or "?"
end

function visibleRankText(rank)
	if isStreamerModeEnabled() then
		return "***"
	end
	local text = tostring(rank or "")
	return text ~= "" and text or "Player"
end

function visiblePlayerLabel(record)
	if type(record) ~= "table" then
		return streamerShortText(record)
	end
	return ("%s (@%s)"):format(visiblePlayerName(record, true), visiblePlayerName(record, false))
end

function refreshStreamerDependentUI()
	local targetText = tostring(state.currentTarget or "")
	local maskedTarget = targetText
	if isStreamerModeEnabled() then
		maskedTarget = streamerShortText(targetText)
	end

	if targetBox then
		targetBox.Text = maskedTarget
		targetBox.PlaceholderText = isStreamerModeEnabled() and "Target hidden" or "Username"
	end

	if state.mobileTargetBox then
		state.mobileTargetBox.Text = maskedTarget
		state.mobileTargetBox.PlaceholderText = isStreamerModeEnabled() and "Target hidden" or "Username"
	end

	if state.targetData then
		updateTargetHeader()
	end

	if state.selectedTab == "actions" then
		refreshInfoCards()
	elseif state.selectedTab == "admins" then
		refreshAdmins()
	elseif state.selectedTab == "credits" then
		refreshCreditsPanel()
	elseif state.selectedTab == "server" then
		refreshServerPanel()
	elseif state.selectedTab == "chat" then
		if state.refreshChatPanel then
			state.refreshChatPanel()
		end
	elseif state.selectedTab == "ban" then
		if refreshBanPanel then
			refreshBanPanel()
		end
	elseif state.selectedTab == "moderation" then
		refreshModerationLog()
	elseif state.selectedTab == "settings" then
		refreshSettingsPanel()
	end

end

function make(className, props)
	local obj = Instance.new(className)
	local languageAttributes = {}
	for k, v in pairs(props or {}) do
		if k == "LangKey" or k == "LangPlaceholder" then
			languageAttributes[k] = tostring(v)
		else
			obj[k] = v
		end
	end
	for k, v in pairs(languageAttributes) do
		obj:SetAttribute(k, v)
	end
	return obj
end

function addShadow(parent, blur, transparency, offsetY, spread)
	if not parent then
		return nil
	end
	local existing = parent:FindFirstChildOfClass("UIShadow")
	if existing then
		return existing
	end
	local ok, shadow = pcall(function()
		return Instance.new("UIShadow")
	end)
	if not ok or not shadow then
		return nil
	end
	pcall(function()
		shadow.Name = "PanelShadow"
		shadow.Color = Color3.fromRGB(0, 0, 0)
		shadow.BlurRadius = UDim.new(0, blur or 18)
		shadow.Transparency = transparency or 0.55
		shadow.Offset = UDim2.fromOffset(0, offsetY or 6)
		shadow.Spread = UDim2.fromOffset(spread or 0, spread or 0)
		shadow.Parent = parent
	end)
	if shadow.Parent ~= parent then
		shadow:Destroy()
		return nil
	end
	return shadow
end

function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

function stroke(parent, transparency)
	local s = Instance.new("UIStroke")
	s.Color = theme().text
	s.Transparency = transparency or 0.9
	s.Thickness = 1
	s.Parent = parent
	return s
end

function padding(parent, l, t, r, b)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, l or 0)
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingRight = UDim.new(0, r or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.Parent = parent
	return p
end

local function animationsEnabled()
	if state and type(state.settingsData) == "table" and state.settingsData.animationOn ~= nil then
		return state.settingsData.animationOn == true
	end
	return true
end

function tween(obj, info, props)
	if not animationsEnabled() then
		if type(props) == "table" then
			for k, v in pairs(props) do
				pcall(function()
					obj[k] = v
				end)
			end
		end
		return {
			Completed = {
				Once = function(_, callback)
					if type(callback) == "function" then
						callback()
					end
				end,
			},
		}
	end
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

function isMobileLayout()
	if UserInputService.TouchEnabled then return true end
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	return vp.X < CONFIG.mobileBreakpoint or vp.Y < 600
end

local function clampPanelSizeToViewport(size)
	size = typeof(size) == "UDim2" and size or CONFIG.panels.main
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local desired = Vector2.new(
		tonumber(size.X.Offset) or CONFIG.panels.main.X.Offset,
		tonumber(size.Y.Offset) or CONFIG.panels.main.Y.Offset
	)
	local maxW = math.max(320, vp.X - 24)
	local maxH = math.max(280, vp.Y - 24)
	local minW = math.min(780, maxW)
	local minH = math.min(480, maxH)
	local clamped = Vector2.new(
		math.clamp(desired.X, minW, maxW),
		math.clamp(desired.Y, minH, maxH)
	)
	return UDim2.fromOffset(clamped.X, clamped.Y)
end


local function getResponsivePanelScale()
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local baseW = CONFIG.panels.main.X.Offset > 0 and CONFIG.panels.main.X.Offset or 940
	local baseH = CONFIG.panels.main.Y.Offset > 0 and CONFIG.panels.main.Y.Offset or 560
	local scaleX = (vp.X - 16) / baseW
	local scaleY = (vp.Y - 16) / baseH
	return math.clamp(math.min(scaleX, scaleY), 0.42, 1)
end

ZONE_ROLE_DATA = {}
ZONE_ROLE_TABS = { "actions", "server", "ban", "chat", "announce", "moderation" }

function zoneRoleDef(name)
	return ZONE_ROLE_DATA[tostring(name or "")]
end

function rankValue(rank)
	local name = tostring(rank or "")
	if RANK_ORDER[name] then
		return RANK_ORDER[name]
	end
	local def = ZONE_ROLE_DATA[name]
	if def then
		return tonumber(def.level) or 10
	end
	return 0
end

local function getLocalAdminRank()
	local rank = tostring(localPlayer and localPlayer:GetAttribute("AdminPanelRank") or "")
	if rank ~= "" then
		return rank
	end
	if localPlayer and localPlayer:GetAttribute("AdminPanelAutoOwner") == true then
		return "Owner"
	end
	return ""
end

local function canSeeAdminsTab()
	local rank = getLocalAdminRank()
	return rank == "Owner"
end

function zoneLocalRoleDef()
	return zoneRoleDef(getLocalAdminRank())
end

function zoneLocalRoleTab(tabId)
	local def = zoneLocalRoleDef()
	if not def then
		return nil
	end
	return def.tabs and def.tabs[tabId] == true
end

local function sanitizePreferredTab(tab)
	tab = tostring(tab or "home")
	if tab == "admins" and not canSeeAdminsTab() then
		return "home"
	end
	if tab == "announce" and not canUseAnnounceTab() then
		return "home"
	end
	if tab ~= "home" and tab ~= "actions" and tab ~= "admins" and tab ~= "server" and tab ~= "credits" and tab ~= "ban" and tab ~= "chat" and tab ~= "settings" and tab ~= "moderation" and tab ~= "announce" then
		return "home"
	end
	return tab
end


local TAB_ONLY_ACTIONS = {
	Age = true,
	Warn = true,
	Timer = true,
	Time = true,
	SetRank = true,
	RemoveRank = true,
	Announce = true,
	StartVote = true,
	StartAbuseTimer = true,
	StopAbuseTimer = true,
	PanicLock = true,
	PanicUnlock = true,
	Esp = true,
}

local function canShowAction(action)
	if action == "AddNote" or action == "Note" then
		return false
	end

	if TAB_ONLY_ACTIONS[action] then
		return false
	end

	local requiredRank = ACTION_RULES[action]
	if not requiredRank then
		return false
	end

	local myRank = getLocalAdminRank()
	local def = zoneRoleDef(myRank)
	if def then
		return def.actions and def.actions[action] == true
	end

	local myValue = rankValue(myRank)
	local requiredValue = rankValue(requiredRank)

	return myValue >= requiredValue and myValue > 0
end

function playerRankText(record)
	if not record then
		return "Player"
	end
	local pieces = {}
	local rankText = tostring(record.AdminPanelRank or record.Rank or "")
	if rankText ~= "" then
		table.insert(pieces, rankText)
	end
	if record.AutoOwner == true then
		local ownerText = tostring(record.OwnerSource or "Auto owner")
		table.insert(pieces, ownerText ~= "" and ownerText or "Auto owner")
	end
	if #pieces == 0 then
		return "Player"
	end
	return table.concat(pieces, " • ")
end

function accountJoinText(record)
	local age = tonumber(record and record.AccountAge) or 0
	local joinDate = record and record.JoinDate or "N/A"
	return ("Age: %d days • Join: %s"):format(age, tostring(joinDate))
end


function banStatusText(record)
	local ban = record and record.Ban
	if not ban or not ban.banned then
		return "Not banned"
	end
	if ban.expiresAt then
		return ("Temp banned until %s\n%s"):format(os.date("%Y-%m-%d %H:%M:%S", tonumber(ban.expiresAt)), tostring(ban.reason or ""))
	end
	return ("Permanently banned\n%s"):format(tostring(ban.reason or ""))
end

function muteStatusText(record)
	if record and record.Muted then
		local untilAt = tonumber(record.MuteExpiresAt)
		if untilAt then
			return ("Temp muted until %s"):format(os.date("%Y-%m-%d %H:%M:%S", untilAt))
		end
		return "Muted"
	end
	return "Not muted"
end

function formatInventoryText(result)
	if type(result) ~= "table" then
		return "Inventory unavailable."
	end
	if result.ok == false then
		return tostring(result.message or result.error or "Inventory unavailable.")
	end
	local targetName = tostring(result.targetDisplayName or result.DisplayName or result.targetName or result.Name or "Unknown")
	local targetUser = tostring(result.targetName or result.Name or result.targetUserName or "?")
	local source = tostring(result.source or result.Source or "unknown")
	local snapshot = result.inventory or result.Inventory or {}
	local backpack = snapshot.backpack or snapshot.Backpack or {}
	local character = snapshot.character or snapshot.Character or {}
	local total = tonumber(snapshot.total or snapshot.Total) or (#backpack + #character)
	local lines = {
		("Player: %s (@%s)"):format(targetName, targetUser),
		("Source: %s"):format(source),
		("Items: %d"):format(total),
		"",
		"Backpack:",
	}
	if #backpack == 0 then
		table.insert(lines, "  (empty)")
	else
		for _, item in ipairs(backpack) do
			table.insert(lines, ("  - %s [%s]"):format(tostring(item.name or item.Name or "Unknown"), tostring(item.className or item.ClassName or "Tool")))
		end
	end
	table.insert(lines, "")
	table.insert(lines, "Character:")
	if #character == 0 then
		table.insert(lines, "  (empty)")
	else
		for _, item in ipairs(character) do
			table.insert(lines, ("  - %s [%s]"):format(tostring(item.name or item.Name or "Unknown"), tostring(item.className or item.ClassName or "Tool")))
		end
	end
	return table.concat(lines, "\n")
end

function getTargetLabel()
	local typed = trim(targetBox and targetBox.Text or "")
	local raw = trim(state.targetQueryRaw or state.resolvedTargetQuery or state.currentTarget or "")
	if isStreamerModeEnabled() and raw ~= "" then
		local masked = streamerShortText(raw)
		if typed == masked then
			return raw
		end
	end
	if typed ~= "" then
		return typed
	end
	if raw ~= "" then
		return raw
	end
	return nil
end

local function captureTargetQueryFromBox()
	local typed = trim(targetBox and targetBox.Text or "")
	local cachedRaw = trim(state.targetQueryRaw or state.resolvedTargetQuery or state.currentTarget or "")
	if isStreamerModeEnabled() and cachedRaw ~= "" then
		local masked = streamerShortText(cachedRaw)
		if typed == masked then
			return cachedRaw
		end
	end
	if typed ~= "" then
		return typed
	end
	return cachedRaw ~= "" and cachedRaw or nil
end


function startPingLoop()
	task.spawn(function()
		while gui and gui.Parent do
			local stamp = os.clock()
			state.lastPingSent = stamp
			RemoteEvent:FireServer("ClientPing", stamp)
			task.wait(12)
		end
	end)
end

local flyActive = false
local flyConn = nil
local flyRestoreState = nil
local flyAscendUntil = 0

local function getFlyAnimationController(character, humanoid)
	local animateScript = character and character:FindFirstChild("Animate")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	return animateScript, animator
end

local function stopFlyAnimationTracks(humanoid, animator)
	local tracks = {}
	if animator and animator.GetPlayingAnimationTracks then
		local ok, result = pcall(function()
			return animator:GetPlayingAnimationTracks()
		end)
		if ok and type(result) == "table" then
			tracks = result
		end
	elseif humanoid and humanoid.GetPlayingAnimationTracks then
		local ok, result = pcall(function()
			return humanoid:GetPlayingAnimationTracks()
		end)
		if ok and type(result) == "table" then
			tracks = result
		end
	end
	for _, track in ipairs(tracks) do
		pcall(function()
			if track and track.IsPlaying then
				track:Stop(0)
			else
				track:Stop(0)
			end
		end)
	end
end

local function pauseFlyAnimations(character, humanoid)
	local animateScript, animator = getFlyAnimationController(character, humanoid)
	flyRestoreState = {
		character = character,
		humanoid = humanoid,
		autoRotate = humanoid and humanoid.AutoRotate,
		animateEnabled = animateScript and animateScript.Enabled,
	}
	stopFlyAnimationTracks(humanoid, animator)
	if animateScript then
		pcall(function()
			animateScript.Enabled = false
		end)
	end
	if humanoid then
		pcall(function()
			humanoid.AutoRotate = false
		end)
	end
end

local function restoreFlyAnimations(character, humanoid)
	local restore = flyRestoreState
	flyRestoreState = nil
	if restore and restore.character and restore.character ~= character then
		character = restore.character
	end
	if restore and restore.humanoid and restore.humanoid ~= humanoid then
		humanoid = restore.humanoid
	end
	local animateScript = character and character:FindFirstChild("Animate")
	if animateScript and restore and restore.animateEnabled ~= nil then
		pcall(function()
			animateScript.Enabled = restore.animateEnabled
		end)
	elseif animateScript then
		pcall(function()
			animateScript.Enabled = true
		end)
	end
	if humanoid then
		pcall(function()
			humanoid.AutoRotate = restore and restore.autoRotate ~= nil and restore.autoRotate or true
		end)
		pcall(function()
			if humanoid:GetState() == Enum.HumanoidStateType.Physics then
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end)
	end
end


local function updateFlyVerticalInput()
	if not flyActive then
		return
	end
	flyAscendUntil = os.clock() + 0.35
end



local function getMobileFlyMoveDirection(camera, humanoid)
	if not camera or not humanoid then
		return Vector3.zero
	end

	local input = humanoid.MoveDirection
	if input.Magnitude <= 0 then
		return Vector3.zero
	end

	local look = camera.CFrame.LookVector
	local right = camera.CFrame.RightVector

	local flatLook = Vector3.new(look.X, 0, look.Z)
	local flatRight = Vector3.new(right.X, 0, right.Z)

	if flatLook.Magnitude > 0 then
		flatLook = flatLook.Unit
	end
	if flatRight.Magnitude > 0 then
		flatRight = flatRight.Unit
	end

	local x = input:Dot(flatRight)
	local z = input:Dot(flatLook)

	local projected = (right * x) + (look * z)
	if projected.Magnitude > 0 then
		return projected.Unit
	end
	return Vector3.zero
end

function startClientFly(character)
	if flyActive then return end
	flyActive = true
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local hum = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not hum then flyActive = false return end

	if root:FindFirstChild("AdminPanelFlyForce") then root:FindFirstChild("AdminPanelFlyForce"):Destroy() end
	if root:FindFirstChild("AdminPanelFlyGyro") then root:FindFirstChild("AdminPanelFlyGyro"):Destroy() end

	pauseFlyAnimations(character, hum)

	local bv = Instance.new("BodyVelocity")
	bv.Name = "AdminPanelFlyForce"
	bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bv.P = 5e3
	bv.Velocity = Vector3.zero
	bv.Parent = root

	local bg = Instance.new("BodyGyro")
	bg.Name = "AdminPanelFlyGyro"
	bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	bg.P = 5e3
	bg.CFrame = root.CFrame
	bg.Parent = root

	pcall(function()
		hum:ChangeState(Enum.HumanoidStateType.Physics)
	end)

	flyConn = RunService.RenderStepped:Connect(function(dt)
		if not flyActive then
			if flyConn then
				flyConn:Disconnect()
				flyConn = nil
			end
			return
		end
		if not root or not root.Parent then
			flyActive = false
			return
		end
		local cam = workspace.CurrentCamera
		if not cam then
			return
		end
		local moveDir = Vector3.zero

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

		if UserInputService.TouchEnabled then
			local mobileMove = getMobileFlyMoveDirection(cam, hum)
			if mobileMove.Magnitude > 0 then
				moveDir = moveDir + mobileMove
			end
		end

		if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
		local speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 120 or 60
		if UserInputService.TouchEnabled then
			speed = 60
		end
		bv.Velocity = moveDir * speed
		bg.CFrame = cam.CFrame
	end)
end

function stopClientFly(character)
	flyActive = false
	if flyConn then flyConn:Disconnect() flyConn = nil end
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		if root:FindFirstChild("AdminPanelFlyForce") then root:FindFirstChild("AdminPanelFlyForce"):Destroy() end
		if root:FindFirstChild("AdminPanelFlyGyro") then root:FindFirstChild("AdminPanelFlyGyro"):Destroy() end
	end
	local hum = character and character:FindFirstChildOfClass("Humanoid")
	restoreFlyAnimations(character, hum)
	if hum then
		pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.Running)
		end)
		pcall(function()
			if hum.MoveDirection.Magnitude == 0 then
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end)
	end
end


UserInputService.JumpRequest:Connect(function()
	if flyActive then
		updateFlyVerticalInput()
	end
end)

function applyChatVisibilityForMute(muted)
	local enabled = not muted
	function applyOnce()
		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, enabled)
		end)
		pcall(function()
			local tcs = game:GetService("TextChatService")
			local found = false
			for _, obj in ipairs(tcs:GetDescendants()) do
				if obj:IsA("ChatWindowConfiguration") or obj:IsA("ChatInputBarConfiguration") then
					obj.Enabled = enabled
					found = true
				end
			end
			local window = tcs:FindFirstChild("ChatWindowConfiguration")
			if window and window:IsA("ChatWindowConfiguration") then
				window.Enabled = enabled
				found = true
			end
			local input = tcs:FindFirstChild("ChatInputBarConfiguration")
			if input and input:IsA("ChatInputBarConfiguration") then
				input.Enabled = enabled
				found = true
			end
			if not found then
				task.delay(0.2, function()
					pcall(function()
						for _, obj in ipairs(tcs:GetDescendants()) do
							if obj:IsA("ChatWindowConfiguration") or obj:IsA("ChatInputBarConfiguration") then
								obj.Enabled = enabled
							end
						end
					end)
				end)
			end
		end)
	end
	applyOnce()
	task.delay(0.25, applyOnce)
	task.delay(0.75, applyOnce)
	task.delay(1.5, applyOnce)
end

function connectAdminFlyReceiver()
	if state.adminFlyReceiverConnected == true then
		return
	end
	state.adminFlyReceiverConnected = true

	RemoteEvent.OnClientEvent:Connect(function(action, ...)
		if action ~= "AdminFly" then
			return
		end
		local enabled = ...
		local character = localPlayer.Character
		if enabled == true then
			startClientFly(character)
		else
			stopClientFly(character)
		end
	end)
end

function stopSpectating()
	local cam = workspace.CurrentCamera
	if cam then
		cam.CameraType = Enum.CameraType.Custom
		local char = localPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			cam.CameraSubject = hum
		end
	end
	if state.spectateBar and state.spectateBar.Parent then
		state.spectateBar.Visible = false
	end
	state.spectateTarget = nil
end

function buildSpectateBar()
	if state.spectateBar and state.spectateBar.Parent then
		return state.spectateBar
	end
	if not gui then
		return nil
	end
	local th = theme()

	local bar = make("Frame", {
		Name = "SpectateBar",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 16),
		Size = UDim2.fromOffset(320, 44),
		BackgroundColor3 = th.panel,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 5400,
		Parent = gui,
	})
	corner(bar, 12)
	stroke(bar, 0.6)

	state.spectateLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -110, 1, 0),
		Text = "Spectating",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 5401,
		Parent = bar,
	})

	local stopBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(84, 28),
		BackgroundColor3 = th.danger,
		Text = "Stop",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = 5401,
		Parent = bar,
	})
	corner(stopBtn, 8)
	stopBtn.MouseButton1Click:Connect(function()
		RemoteEvent:FireServer("Unspectate", nil, {})
		stopSpectating()
	end)

	state.spectateBar = bar
	return bar
end

function startSpectating(userId, label)
	local target = Players:GetPlayerByUserId(tonumber(userId) or 0)
	if not target then
		if type(notify) == "function" then
			notify("That player is not in this server.", false, 4)
		end
		return
	end
	local char = target.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then
		if type(notify) == "function" then
			notify("That player has no character right now.", false, 4)
		end
		return
	end
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	buildSpectateBar()
	cam.CameraType = Enum.CameraType.Custom
	cam.CameraSubject = hum
	state.spectateTarget = target.UserId
	if state.spectateBar then
		state.spectateBar.Visible = true
	end
	if state.spectateLabel then
		state.spectateLabel.Text = ("Spectating %s"):format(tostring(label or target.DisplayName))
	end
end

function connectSpectateReceiver()
	if state.spectateReceiverConnected then
		return
	end
	state.spectateReceiverConnected = true
	RemoteEvent.OnClientEvent:Connect(function(action, payload)
		if action ~= "AdminSpectate" or type(payload) ~= "table" then
			return
		end
		if payload.active == true then
			startSpectating(payload.userId, payload.displayName or payload.name)
		else
			stopSpectating()
		end
	end)
end

function connectWarningReceiver()
	if state.warningReceiverConnected then
		return
	end
	state.warningReceiverConnected = true
	RemoteEvent.OnClientEvent:Connect(function(action, payload)
		if action ~= "AdminWarning" or type(payload) ~= "table" then
			return
		end
		showWarningPopup(tostring(payload.reason or ""), tostring(payload.moderator or "Staff"))
	end)
end

function showWarningPopup(reason, moderator)
	if type(announceShowWarning) == "function" then
		announceShowWarning(tostring(reason or ""))
	end
end

function connectPingAck()
	applyChatVisibilityForMute(localPlayer:GetAttribute("AdminMuted") == true)
	localPlayer:GetAttributeChangedSignal("AdminMuted"):Connect(function()
		applyChatVisibilityForMute(localPlayer:GetAttribute("AdminMuted") == true)
	end)
	localPlayer.CharacterAdded:Connect(function()
		task.defer(function()
			applyChatVisibilityForMute(localPlayer:GetAttribute("AdminMuted") == true)
		end)
	end)

	RemoteEvent.OnClientEvent:Connect(function(action, ...)
		if action == "ClientPingAck" then
			local sentStamp = ...
			if typeof(sentStamp) == "number" then
				state.ping = math.max(0, (os.clock() - sentStamp) * 1000)
				state.lastPingAck = os.clock()
			end
			return
		elseif action == "AdminFly" then
			return
		elseif action == "AdminMuteState" then
			local muted = ...
			applyChatVisibilityForMute(muted == true)
			return
		elseif action == "ChatHistory" then
			local history = ...
			state.syncChatHistory(history)
			return
		elseif action == "ChatMessage" then
			local entry = ...
			state.pushChatEntry(entry)
			return
		elseif action == "ChatSendAck" then
			local ack = ...
			if state.chatStatusLabel then
				if type(ack) == "table" and ack.message then
					state.chatStatusLabel.Text = tostring(ack.message)
				else
					state.chatStatusLabel.Text = "Message sent."
				end
			end
			return
		elseif action == "ChatSendFailed" then
			local fail = ...
			if state.chatStatusLabel then
				local msg = "Chat send failed."
				if type(fail) == "table" and fail.message then
					msg = tostring(fail.message)
				end
				state.chatStatusLabel.Text = msg
			end
			local failId = (type(fail) == "table" and tostring(fail.id or "") or "")
			local pendFail = state.chatPendingEntries
			if pendFail then
				if failId ~= "" and pendFail[failId] ~= nil then
					pendFail[failId].failed = true
				elseif failId == "" then
					for _, failedItem in pairs(pendFail) do
						if type(failedItem) == "table" then
							failedItem.failed = true
						end
					end
				end
			end
			if state.refreshChatPanel then
				state.refreshChatPanel()
			end
			return
		elseif action == "ChatTypingState" then
			local payload = ...
			state.updateChatTypingState(payload)
			return
		elseif action == "RolesData" then
			local payload = ...
			if type(payload) == "table" and type(zoneRolesApply) == "function" then
				zoneRolesApply(payload.roles)
			end
			return
		elseif action == "RoleResult" then
			local payload = ...
			state.roleWaitToken = (tonumber(state.roleWaitToken) or 0) + 1
			if type(payload) == "table" then
				if type(zoneRoleSetStatus) == "function" then
					zoneRoleSetStatus(tostring(payload.message or ""), payload.ok == true)
				end
				if payload.ok == true and type(closeRoleEditor) == "function" then
					closeRoleEditor()
				end
				if type(notify) == "function" then
					notify(tostring(payload.message or ""), payload.ok == true, 4)
				end
			end
			return
		elseif action == "PanicState" then
			local payload = ...
			if type(payload) == "table" then
				state.panicActive = payload.active == true
				state.panicBy = tostring(payload.by or "")
				refreshPanicButton()
			end
			return
		elseif action == "ActionResult" then
			local result = ...
			if type(result) == "table" then
				if result.ok == false and tostring(result.error or "") == "not_found" and state.targetData == nil then
					return
				end
				local resultAction = tostring(result.action or "")
				if result.ok == true then
					setStatus(tostring(result.message or (resultAction .. " completed.")), true)
				else
					setStatus(tostring(result.message or (resultAction .. " failed.")), false)
				end
				if (tostring(result.action or "") == "Unban" or tostring(result.action or "") == "Ban") and state.refreshBanPanel then
					task.delay(0.2, function()
						refreshBanPanel()
					end)
				end
				if state.targetData and tonumber(state.targetData.UserId) == tonumber(result.targetUserId or -1) then
					task.delay(0.35, function()
						refreshTargetData()
					end)
				end
			else
				setStatus("Action completed.", true)
			end
			return
		elseif action == "InventoryResult" then
			local result = ...
			state.inventoryLoadingToken = nil
			local payload = result
			if type(payload) ~= "table" then
				payload = { ok = false, message = "Inventory unavailable." }
			end
			if payload.inventory == nil and (payload.Backpack or payload.Character or payload.backpack or payload.character) then
				payload = {
					ok = payload.ok ~= false,
					requestId = payload.requestId,
					targetUserId = payload.targetUserId,
					targetName = payload.targetName or payload.Name,
					targetDisplayName = payload.targetDisplayName or payload.DisplayName,
					source = payload.source,
					inventory = {
						backpack = payload.Backpack or payload.backpack or {},
						character = payload.Character or payload.character or {},
						total = payload.total or payload.Total,
					},
				}
			end
			local title = "Inventory"
			if type(payload) == "table" then
				local name = payload.targetDisplayName or payload.DisplayName or payload.targetName or payload.Name
				if name then
					title = ("Inventory — %s"):format(tostring(name))
				elseif tonumber(payload.targetUserId) then
					title = ("Inventory — UserId %s"):format(tostring(payload.targetUserId))
				end
			end
			openCodeModal(title, formatInventoryText(payload), function()
				closeCodeModal()
			end, "Close")
			return
		end
	end)
end

function clearChildrenExcept(container, keep)
	for _, ch in ipairs(container:GetChildren()) do
		if not keep[ch] and not ch:IsA("UIListLayout") and not ch:IsA("UIGridLayout") and not ch:IsA("UIPadding") then
			ch:Destroy()
		end
	end
end

function makeInfoCard(parent, title, value, sizeY, iconId)
	local th = theme()
	local height = sizeY or 54
	local frame = make("Frame", {
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height),
		Parent = parent,
	})
	corner(frame, 12)
	stroke(frame, 0.92)
	addShadow(frame, 10, 0.78, 3, 0)

	local iconBox = make("Frame", {
		Name = "IconBox",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(44, 44),
		BackgroundColor3 = th.panel2,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		Parent = frame,
	})
	corner(iconBox, 12)

	local glyph = make("ImageLabel", {
		Name = "Icon",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(28, 28),
		BackgroundTransparency = 1,
		Image = iconId or "",
		ImageColor3 = th.icon,
		ScaleType = Enum.ScaleType.Fit,
		Parent = iconBox,
	})

	local titleLbl = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(68, 9),
		Size = UDim2.new(1, -110, 0, 14),
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = title,
		Parent = frame,
	})

	local statusDot = make("Frame", {
		Name = "StatusDot",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 14),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = th.muted,
		BorderSizePixel = 0,
		Visible = false,
		Parent = frame,
	})
	corner(statusDot, 4)

	local valueLbl = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(68, 24),
		Size = UDim2.new(1, -80, 0, math.max(18, height - 30)),
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextWrapped = true,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = value,
		Parent = frame,
	})

	local card = {
		frame = frame,
		title = titleLbl,
		value = valueLbl,
		iconBox = iconBox,
		glyph = glyph,
		dot = statusDot,
	}
	table.insert(infoCards, card)
	return card
end

function setInfoCardTone(card, tone)
	if not card then
		return
	end
	if card.dot then
		card.dot.Visible = true
		card.dot.BackgroundColor3 = tone
	end
	if card.glyph then
		card.glyph.ImageColor3 = tone
	end
end

function refreshInfoCards()
	local th = theme()
	local r = state.targetData

	if not r then
		for index, card in ipairs(infoCards) do
			card.value.Text = index == 1 and "Player" or "No target selected"
			card.value.TextColor3 = th.muted
			if card.dot then
				card.dot.Visible = false
			end
			if card.glyph then
				card.glyph.ImageColor3 = th.icon
			end
		end
		return
	end

	for _, card in ipairs(infoCards) do
		card.value.TextColor3 = th.text
	end

	if infoCards[1] then
		infoCards[1].value.Text = tostring(playerRankText(r))
		local rank = tostring(r.AdminPanelRank or r.Rank or "")
		setInfoCardTone(infoCards[1], rank ~= "" and th.accent or th.muted)
	end

	if infoCards[2] then
		local hide = isStreamerModeEnabled()
		local here = r.InCurrentServer == true
		infoCards[2].value.Text = ("Place %s\nJob %s"):format(
			hide and "***" or tostring(r.PlaceId or "N/A"),
			hide and "***" or tostring(r.JobId or "N/A")
		)
		setInfoCardTone(infoCards[2], here and th.success or th.muted)
	end

	if infoCards[3] then
		local ban = r.Ban
		local banned = ban ~= nil and ban.banned == true
		infoCards[3].value.Text = banStatusText(r)
		infoCards[3].value.TextColor3 = banned and th.danger or th.text
		setInfoCardTone(infoCards[3], banned and th.danger or th.success)
	end

	if infoCards[4] then
		local muted = r.Muted == true
		infoCards[4].value.Text = muteStatusText(r)
		infoCards[4].value.TextColor3 = muted and th.warn or th.text
		setInfoCardTone(infoCards[4], muted and th.warn or th.success)
	end

	if infoCards[5] then
		local days = tonumber(r.AccountAge) or 0
		if days > 0 then
			local years = math.floor(days / 365)
			if years >= 1 then
				infoCards[5].value.Text = ("%d days  -  %d year(s)"):format(days, years)
			else
				infoCards[5].value.Text = ("%d days"):format(days)
			end
			local tone = th.success
			if days < 7 then
				tone = th.danger
			elseif days < 30 then
				tone = th.warn
			end
			infoCards[5].value.TextColor3 = tone
			setInfoCardTone(infoCards[5], tone)
		else
			infoCards[5].value.Text = "Unknown"
			setInfoCardTone(infoCards[5], th.muted)
		end
	end

	if infoCards[6] then
		if r.InCurrentServer ~= true then
			infoCards[6].value.Text = "Not in this server"
			setInfoCardTone(infoCards[6], th.muted)
		else
			local ms = tonumber(state.targetPingMs) or 0
			if ms > 0 then
				infoCards[6].value.Text = ("%d ms"):format(ms)
				local tone = th.success
				if ms >= 250 then tone = th.danger elseif ms >= 120 then tone = th.warn end
				infoCards[6].value.TextColor3 = tone
				setInfoCardTone(infoCards[6], tone)
			else
				infoCards[6].value.Text = "Measuring..."
				setInfoCardTone(infoCards[6], th.muted)
			end
		end
	end
end

function formatDuration(totalSeconds)
	totalSeconds = math.max(0, tonumber(totalSeconds) or 0)
	local h = math.floor(totalSeconds / 3600)
	local m = math.floor((totalSeconds % 3600) / 60)
	local s = math.floor(totalSeconds % 60)
	return ("%02d:%02d:%02d"):format(h, m, s)
end

function getCountryRegionCode(player)
	local target = player or localPlayer
	local ok, result = pcall(function()
		return LocalizationService:GetCountryRegionForPlayerAsync(target)
	end)
	if ok and type(result) == "string" and result ~= "" then
		return result
	end
	return "N/A"
end

local function normalizeServerPlayerRecord(plr)
	if typeof(plr) == "Instance" and plr:IsA("Player") then
		return {
			UserId = plr.UserId,
			Name = plr.Name,
			DisplayName = plr.DisplayName,
			AccountAge = plr.AccountAge,
			CountryRegion = plr:GetAttribute("AdminClientCountryRegion") or plr:GetAttribute("CountryRegion") or "N/A",
			Rank = tostring(plr:GetAttribute("AdminPanelRank") or "Player"),
			IsLocal = plr == localPlayer,
		}
	end
	if type(plr) == "table" then
		if (tonumber(plr.UserId) or 0) <= 0 then
			local lookup = tostring(plr.Name or plr.name or "")
			if lookup ~= "" then
				local live = Players:FindFirstChild(lookup)
				if live and live:IsA("Player") then
					plr.UserId = live.UserId
					plr.DisplayName = plr.DisplayName or live.DisplayName
					plr.AccountAge = plr.AccountAge or live.AccountAge
					plr.IsLocal = live == localPlayer
				end
			end
		end
		return plr
	end
	return {
		Name = tostring(plr or "Player"),
		DisplayName = tostring(plr or "Player"),
		AccountAge = 0,
		CountryRegion = "N/A",
		Rank = "Player",
		IsLocal = false,
	}
end

local function selectServerRowTarget(plr)
	if type(plr) ~= "table" then
		return
	end
	local target = tostring(plr.Name or plr.name or plr.DisplayName or plr.displayName or "")
	target = trim(target)
	if target == "" then
		return
	end
	state.currentTarget = target
	state.targetQueryRaw = target
	if targetBox then
		targetBox.Text = target
	end
	if state.mobileTargetBox then
		state.mobileTargetBox.Text = target
	end
	local resolved = resolveTarget(target)
	if resolved and state.selectedTab == "server" and refreshStreamerDependentUI then
		refreshStreamerDependentUI()
	end
end

function ensureServerRow(index)
	serverRows[index] = serverRows[index] or {}
	local row = serverRows[index]
	if row.frame and row.frame.Parent then
		return row
	end

	row.frame = make("Frame", {
		BackgroundColor3 = theme().card,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 82),
		Parent = serverPlayersHolder,
	})
	corner(row.frame, 12)
	stroke(row.frame, 0.92)

	local avatarHolder = make("Frame", {
		Name = "AvatarHolder",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(48, 48),
		BackgroundTransparency = 1,
		Parent = row.frame,
	})

	row.avatar = make("ImageLabel", {
		Name = "Avatar",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme().panel2,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Image = "",
		ScaleType = Enum.ScaleType.Fit,
		Parent = avatarHolder,
	})
	corner(row.avatar, 24)
	stroke(row.avatar, 0.88)

	row.dotRing = make("Frame", {
		Name = "PresenceRing",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 1, 1, 1),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = theme().card,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = avatarHolder,
	})
	corner(row.dotRing, 8)

	row.dot = make("Frame", {
		Name = "PresenceDot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(10, 10),
		BackgroundColor3 = theme().success,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = row.dotRing,
	})
	corner(row.dot, 5)

	row.name = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(68, 9),
		Size = UDim2.new(1, -148, 0, 16),
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row.frame,
	})
	row.status = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(68, 27),
		Size = UDim2.new(1, -88, 0, 15),
		Font = Enum.Font.GothamSemibold,
		TextSize = 11,
		TextColor3 = theme().success,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row.frame,
	})
	row.info = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(68, 44),
		Size = UDim2.new(1, -88, 0, 30),
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = row.frame,
	})
	row.selectBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(64, 30),
		BackgroundColor3 = theme().panel2,
		Text = "Select",
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		Parent = row.frame,
	})
	corner(row.selectBtn, 10)
	stroke(row.selectBtn, 0.92)
	row.selectBtn.MouseButton1Click:Connect(function()
		setTab("actions")
		task.defer(function()
			selectServerRowTarget(row.playerData)
		end)
	end)
	return row
end

-- 🛡 next to players under Ultimate Security (set by the server).
function zoneShieldTag(userId)
	local plr = Players:GetPlayerByUserId(tonumber(userId) or 0)
	if plr and plr:GetAttribute("ZoneUltimateSecurity") == true then
		return " 🛡"
	end
	return ""
end

function zoneWatchShield(plr)
	plr:GetAttributeChangedSignal("ZoneUltimateSecurity"):Connect(function()
		task.defer(function()
			if state.targetData and tonumber(state.targetData.UserId) == plr.UserId and type(updateTargetHeader) == "function" then
				updateTargetHeader()
			end
			if state.panelOpen and state.selectedTab == "home" and type(refreshHomePlayers) == "function" then
				refreshHomePlayers()
			end
		end)
	end)
end
for _, plr in ipairs(Players:GetPlayers()) do
	zoneWatchShield(plr)
end
Players.PlayerAdded:Connect(zoneWatchShield)

function updateServerRows(players)
	players = type(players) == "table" and players or {}
	for i, plr in ipairs(players) do
		plr = normalizeServerPlayerRecord(plr)
		local row = ensureServerRow(i)
		row.playerData = plr
		row.frame.Visible = true
		local rowUserId = tonumber(plr.UserId) or 0
		if row.avatar then
			row.avatar.Image = rowUserId > 0
				and ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(rowUserId)
				or ""
		end
		if row.dot then
			row.dot.BackgroundColor3 = presenceStateColor(select(1, presenceStateFor(rowUserId)))
		end
		if row.dotRing then
			row.dotRing.BackgroundColor3 = theme().card
		end
		if row.selectBtn then
			row.selectBtn.Text = plr.IsLocal and "You" or "Select"
			row.selectBtn.TextColor3 = plr.IsLocal and theme().warn or theme().text
		end
		row.name.Text = ("%s (@%s)%s%s"):format(
			visiblePlayerName(plr, true),
			visiblePlayerName(plr, false),
			plr.IsLocal and " • You" or "",
			zoneShieldTag(rowUserId)
		)
		if row.status then
			local stateName = select(1, presenceStateFor(rowUserId))
			row.status.Text = presenceStateText(stateName)
			row.status.TextColor3 = presenceStateColor(stateName)
		end
		row.info.Text = ("Age %s days  •  Region %s\nRank %s"):format(
			tostring(plr.AccountAge or "?"),
			tostring(plr.CountryRegion or "N/A"),
			visibleRankText(plr.Rank)
		)
	end
	for i = #players + 1, #serverRows do
		if serverRows[i] and serverRows[i].frame then
			serverRows[i].frame.Visible = false
		end
	end
end

function refreshServerPanel()
	if not serverScroll then
		return
	end
	local data = nil
	local ok = pcall(function()
		data = ServerDataRF:InvokeServer()
	end)
	if not ok or type(data) ~= "table" then
		data = {}
	end

	state.serverLastRefresh = os.clock()

	local livePlayers = Players:GetPlayers()
	local maxPlayers = tonumber(data.MaxPlayers) or Players.MaxPlayers or 0
	if maxPlayers <= 0 then
		maxPlayers = math.max(#livePlayers, 1)
	end
	local playerCount = tonumber(data.PlayerCount) or 0
	if playerCount <= 0 then
		playerCount = #livePlayers
	end
	local loadPct = (maxPlayers > 0) and math.floor((playerCount / maxPlayers) * 100 + 0.5) or 0
	local serverType = tostring(data.ServerType or "Public Server")
	local health = tostring(data.HealthState or (loadPct >= 95 and "Full" or (loadPct >= 75 and "Busy" or "Healthy")))
	local summary = tostring(data.SummaryText or ("%s • %d/%d players"):format(serverType, playerCount, maxPlayers))

	if serverTitleLabel then
		serverTitleLabel.Text = "Server Manager"
	end
	if serverRefreshLabel then
		serverRefreshLabel.Text = ("Last refresh: %s"):format(os.date("%H:%M:%S"))
	end
	local th = theme()

	if state.serverPlayersStat then
		state.serverPlayersStat.Text = ("%d/%d"):format(playerCount, maxPlayers)
	end
	if state.serverUptimeStat then
		state.serverUptimeBase = tonumber(data.Uptime) or 0
		state.serverUptimeStamp = os.clock()
		state.serverUptimeStat.Text = formatDuration(state.serverUptimeBase)
	end
	if state.serverHealthStat then
		state.serverHealthStat.Text = health
		local tone = th.success
		if health == "Full" then
			tone = th.danger
		elseif health == "Busy" then
			tone = th.warn
		end
		state.serverHealthStat.TextColor3 = tone
	end
	if state.serverPingStat then
		local ping = tonumber(state.ping) or 0
		state.serverPingStat.Text = ping > 0 and ("%d ms"):format(math.floor(ping + 0.5)) or "-"
	end

	if state.serverLoadFill then
		local tone = th.success
		if loadPct >= 90 then
			tone = th.danger
		elseif loadPct >= 70 then
			tone = th.warn
		end
		state.serverLoadFill.BackgroundColor3 = tone
		local fillScale = math.clamp(loadPct / 100, 0, 1)
		if playerCount > 0 and fillScale < 0.04 then
			fillScale = 0.04
		end
		if animationsEnabled() then
			tween(state.serverLoadFill, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(fillScale, 0, 1, 0),
			})
		else
			state.serverLoadFill.Size = UDim2.new(fillScale, 0, 1, 0)
		end
		if state.serverLoadPercent then
			state.serverLoadPercent.Text = ("%d%%"):format(loadPct)
			state.serverLoadPercent.TextColor3 = tone
		end
		if state.serverLoadNote then
			state.serverLoadNote.Text = ("%s  •  %d slot(s) free"):format(serverType, math.max(0, maxPlayers - playerCount))
			state.serverLoadNote.TextColor3 = th.muted
		end
	end

	if serverSummaryValue then
		serverSummaryValue.Text = ("Type: %s\nHealth: %s\nUptime: %s"):format(serverType, health, formatDuration(data.Uptime or 0))
	end
	if serverStatusValue then
		local hideIds = isStreamerModeEnabled()
		serverStatusValue.Text = ("PlaceId: %s\nJobId: %s\nPlayers: %d/%d\nServerType: %s\nPrivateServerId: %s"):format(
			hideIds and "***" or tostring(data.PlaceId or game.PlaceId),
			hideIds and "***" or tostring(data.JobId or game.JobId),
			playerCount,
			maxPlayers,
			serverType,
			hideIds and "***" or tostring(data.PrivateServerId or "N/A")
		)
	end
	if serverRegionValue then
		serverRegionValue.Text = ("Your region: %s\nRequesting player region: %s\nRoblox does not expose the server's physical country directly."):format(
			getCountryRegionCode(),
			tostring(data.RequestingPlayerRegion or "N/A")
		)
	end
	local serverPlayers = data.Players
	if type(serverPlayers) ~= "table" or #serverPlayers == 0 then
		serverPlayers = Players:GetPlayers()
	end
	if state.serverPlayersTitle then
		state.serverPlayersTitle.Text = ("Players in this server (%d)"):format(#serverPlayers)
		state.serverPlayersTitle.TextColor3 = th.text
	end
	updateServerRows(serverPlayers)
end

function aiPushMessage(role, text)
	return
end

function refreshAiPreview(cmd)
	return
end

local moderationRows = {}

function ensureModerationRow(index)
	local row = moderationRows[index]
	if row and row.frame then
		return row
	end
	local th = theme()
	local frame = make("Frame", {
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -4, 0, 80),
		Parent = moderationListHolder,
	})
	corner(frame, 12)
	stroke(frame, 0.92)
	addShadow(frame, 10, 0.78, 3, 0)

	local avatarHolder = make("Frame", {
		Name = "AvatarHolder",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(44, 44),
		BackgroundTransparency = 1,
		Parent = frame,
	})

	local avatar = make("ImageLabel", {
		Name = "Avatar",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = th.panel2,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Image = "",
		ScaleType = Enum.ScaleType.Fit,
		Parent = avatarHolder,
	})
	corner(avatar, 22)
	stroke(avatar, 0.88)

	local badge = make("Frame", {
		Name = "ActionBadge",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 2, 1, 2),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = th.card,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = avatarHolder,
	})
	corner(badge, 9)

	local badgeDot = make("Frame", {
		Name = "BadgeDot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = th.accent,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = badge,
	})
	corner(badgeDot, 6)

	local actionTag = make("TextLabel", {
		Name = "ActionTag",
		BackgroundColor3 = th.panel2,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(68, 10),
		Size = UDim2.fromOffset(84, 20),
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = th.accent,
		Text = "",
		Parent = frame,
	})
	corner(actionTag, 6)

	local title = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(158, 10),
		Size = UDim2.new(1, -252, 0, 20),
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = "",
		Parent = frame,
	})

	local whenLbl = make("TextLabel", {
		Name = "WhenLabel",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.fromOffset(86, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = "",
		Parent = frame,
	})

	local info = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(68, 34),
		Size = UDim2.new(1, -84, 0, 38),
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextWrapped = true,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = "",
		Parent = frame,
	})

	local row = {
		frame = frame,
		title = title,
		info = info,
		avatar = avatar,
		badge = badge,
		badgeDot = badgeDot,
		tag = actionTag,
		when = whenLbl,
	}
	moderationRows[index] = row
	return row
end

function historyActionTone(action)
	local th = theme()
	action = tostring(action or "")
	if action == "Ban" or action == "Kick" or action == "Kill" or action == "KillAll" or action == "PanicLock" then
		return th.danger
	end
	if action == "Warn" or action == "Mute" or action == "TempMute" or action == "Freeze" or action == "Jail" then
		return th.warn
	end
	if action == "Unban" or action == "Unmute" or action == "Unfreeze" or action == "Unjail" or action == "Heal" or action == "HealAll" then
		return th.success
	end
	return th.accent
end

function updateModerationRows(entries)
	entries = type(entries) == "table" and entries or {}
	local query = trim(state.moderationSearchQuery or "")
	if moderationCountLabel then
		local total = #(state.moderationLogData or {})
		if query ~= "" then
			moderationCountLabel.Text = ("Showing %d of %d results"):format(#entries, total)
		else
			moderationCountLabel.Text = ("Showing %d entries"):format(total)
		end
	end
	if moderationEmptyLabel then
		moderationEmptyLabel.Visible = (#entries == 0)
		if #entries == 0 then
			if query ~= "" then
				moderationEmptyLabel.Text = ('No matches for "%s".'):format(query)
			else
				moderationEmptyLabel.Text = "No moderation actions logged yet."
			end
		end
	end
	for i, entry in ipairs(entries) do
		local row = ensureModerationRow(i)
		local th = theme()
		local ts = tonumber(entry.timestamp or entry.time or 0) or 0
		local actionText = tostring(entry.action or "Action")
		local modText = streamerShortText(entry.moderatorDisplayName or entry.moderatorName or entry.moderator or "Unknown")
		local targetText = streamerShortText(entry.targetDisplayName or entry.targetName or entry.target or "Unknown")
		local reasonText = tostring(entry.reason or "")
		local resultText = tostring(entry.message or "")
		local tone = historyActionTone(actionText)
		local targetId = tonumber(entry.targetUserId) or 0

		if row.avatar then
			row.avatar.Image = targetId > 0
				and ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(targetId)
				or ""
		end
		if row.badge then
			row.badge.BackgroundColor3 = th.card
		end
		if row.badgeDot then
			row.badgeDot.BackgroundColor3 = tone
		end
		if row.tag then
			row.tag.Text = actionText
			row.tag.TextColor3 = tone
			row.tag.BackgroundColor3 = th.panel2
		end
		if row.when then
			row.when.Text = ts > 0 and homeRelativeTime(ts) or "unknown"
			row.when.TextColor3 = th.muted
		end

		row.title.Text = targetText
		row.title.TextColor3 = th.text

		local lines = { ("by %s"):format(modText) }
		if reasonText ~= "" and reasonText ~= "N/A" then
			table.insert(lines, reasonText)
		end
		if resultText ~= "" then
			table.insert(lines, resultText)
		end
		if ts > 0 then
			table.insert(lines, os.date("%Y-%m-%d %H:%M:%S", ts))
		end
		row.info.Text = table.concat(lines, "  •  ")
		row.info.TextColor3 = th.muted
		row.frame.Visible = true
	end
	for i = #entries + 1, #moderationRows do
		if moderationRows[i] and moderationRows[i].frame then
			moderationRows[i].frame.Visible = false
		end
	end
end

function refreshModerationLog()
	state.moderationLastRefresh = os.clock()
	if moderationTitleLabel then
		moderationTitleLabel.Text = "History"
	end


	local ok, res = pcall(function()
		return state.HistoryRF:InvokeServer("get")
	end)

	if ok and type(res) == "table" and res.ok and type(res.entries) == "table" then
		state.moderationLogData = res.entries

	else
		state.moderationLogData = {}

	end

	updateModerationFilterSummary()
	refreshModerationDisplay()
end

function moderationFilterEntries()
	local entries = state.moderationLogData or {}
	local query = trim(state.moderationSearchQuery or "")
	local filters = state.moderationFilters or {}
	local filtered = {}
	local q = string.lower(query)

	local function contains(value, needle)
		needle = trim(needle or "")
		if needle == "" then
			return true
		end
		return string.lower(tostring(value or "")):find(string.lower(needle), 1, true) ~= nil
	end

	for _, entry in ipairs(entries) do
		local ts = tonumber(entry.timestamp or entry.time or 0) or 0
		local whenText = ts > 0 and os.date("%Y-%m-%d %H:%M:%S", ts) or ""
		local fields = {
			entry.action,
			entry.moderatorDisplayName,
			entry.moderatorName,
			entry.moderator,
			entry.targetDisplayName,
			entry.targetName,
			entry.target,
			entry.reason,
			entry.message,
			entry.serverPlaceId,
			entry.serverJobId,
			whenText,
		}
		local searchOk = q == ""
		if not searchOk then
			for _, field in ipairs(fields) do
				if string.lower(tostring(field or "")):find(q, 1, true) then
					searchOk = true
					break
				end
			end
		end
		local filterOk = contains(entry.moderatorDisplayName or entry.moderatorName or entry.moderator, filters.moderator)
			and contains(entry.targetDisplayName or entry.targetName or entry.target, filters.target)
			and contains(entry.action, filters.action)
			and contains(entry.reason or entry.message, filters.reason)
		if searchOk and filterOk then
			table.insert(filtered, entry)
		end
	end
	return filtered
end

function refreshModerationDisplay()
	updateModerationRows(moderationFilterEntries())
end

function selectThemeName(name)
	local resolved = normalizeThemeName(name)
	state.pendingThemeName = resolved
	local draft = getSettingsDraftSafe()
	if draft then
		draft.theme = resolved
		setSettingsDirtySafe(true)
	end
	refreshThemeSwatches()
	return resolved
end

function setThemeName(name, markDirty)
	local resolved = normalizeThemeName(name)
	local previousPalette = state.appliedPalette or THEMES[state.themeName or DEFAULT_THEME_NAME] or THEMES[DEFAULT_THEME_NAME]
	local nextPalette = THEMES[resolved] or THEMES[DEFAULT_THEME_NAME]
	state.themeName = resolved
	state.pendingThemeName = resolved
	if markDirty == true then
		local draft = getSettingsDraftSafe()
		if draft then
			draft.theme = resolved
			setSettingsDirtySafe(true)
		end
	end
	if gui then
		local map = buildPaletteRemap(previousPalette, nextPalette)
		recolorTree(gui, map)
	end
	state.appliedPalette = snapshotPalette(nextPalette)
	applyThemeColors()
	refreshThemeSwatches()
	rebuildThemeDependentViews()
	return resolved
end

function refreshThemeSwatches()
	if type(state.themeButtons) ~= "table" then
		return
	end
	local active = normalizeThemeName(state.pendingThemeName or currentThemeName())
	for name, entry in pairs(state.themeButtons) do
		if type(entry) == "table" and entry.button and entry.button.Parent then
			local isActive = (name == active)
			local st = entry.button:FindFirstChildOfClass("UIStroke")
			if st then
				st.Color = isActive and (THEMES[name] and THEMES[name].accent or theme().accent) or theme().text
				st.Transparency = isActive and 0.1 or 0.85
				st.Thickness = isActive and 2 or 1
			end
			if entry.check then
				entry.check.Visible = isActive
			end
			local palette = THEMES[name]
			if palette then
				if entry.button then
					entry.button.BackgroundColor3 = palette.panel
					entry.button.BackgroundTransparency = 0.05
				end
				if entry.label then
					entry.label.TextColor3 = palette.text
				end
				if entry.check then
					entry.check.TextColor3 = palette.accent
				end
				if entry.swatch then
					if name == "Custom" then
						entry.swatch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						rainbowGradient(entry.swatch)
					else
						entry.swatch.BackgroundColor3 = palette.accent
					end
				end
				if entry.dots then
					for dotKey, dotFrame in pairs(entry.dots) do
						if dotFrame and dotFrame.Parent and palette[dotKey] then
							dotFrame.BackgroundColor3 = palette[dotKey]
						end
					end
				end
			end
		end
	end
end

function rebuildThemeDependentViews()
	if state.selectedTab == "server" then
		if type(refreshServerPanel) == "function" then
			pcall(refreshServerPanel)
		end
	end
	if state.selectedTab == "admins" then
		if type(updateAdminsList) == "function" then
			pcall(updateAdminsList)
		end
	elseif state.selectedTab == "ban" then
		if type(updateBanRows) == "function" and type(filterBanEntries) == "function" then
			pcall(function()
				updateBanRows(filterBanEntries())
			end)
		end
	elseif state.selectedTab == "moderation" then
		if type(refreshModerationDisplay) == "function" then
			pcall(refreshModerationDisplay)
		end
	end
end

ZONE_LANGUAGE_ORDER = { "en" }

ZONE_LANG = {
	en = {
		["tab.home"] = "Home",
		["tab.actions"] = "Actions",
		["tab.server"] = "Server",
		["tab.admins"] = "Admins",
		["tab.ban"] = "Ban",
		["tab.chat"] = "Chat",
		["tab.announce"] = "Announce",
		["tab.moderation"] = "History",
		["tab.credits"] = "Info",
		["tab.settings"] = "Settings",
		["settings.animations"] = "Animations",
		["settings.animations.note"] = "Smooth open, close and tab transitions.",
		["settings.blur"] = "Background blur",
		["settings.blur.note"] = "Blurs the game behind the panel while it is open.",
		["settings.openJoin"] = "Open on join",
		["settings.openJoin.note"] = "Show the panel automatically when you join.",
		["settings.rememberTab"] = "Remember last tab",
		["settings.rememberTab.note"] = "Reopen on the tab you used last time.",
		["settings.streamer"] = "Streamer mode",
		["settings.streamer.note"] = "Hides usernames and IDs from the panel.",
		["settings.sidebarSave"] = "Save sidebar order",
		["settings.sidebarSave.note"] = "Remember how you arranged the sidebar icons.",
		["settings.confirmActions"] = "Confirm actions",
		["settings.confirmActions.note"] = "Ask before running a command. Ban, Kick and server-wide actions always ask.",
		["settings.aiConfirm"] = "AI confirmations",
		["settings.aiConfirm.note"] = "Zone AI asks before running an action, right in the chat.",
		["settings.movingBg"] = "Moving background",
		["settings.movingBg.note"] = "Slowly drifting colours behind the panel.",
		["settings.bgstyle"] = "Background style",
		["settings.bgstyle.note"] = "Tap to open the style picker above the button.",
		["settings.bgstyle.stripes"] = "Stripes",
		["settings.bgstyle.orbs"] = "Orbs",
		["settings.bgstyle.bubbles"] = "Bubbles",
		["settings.bgstyle.sparkles"] = "Sparkles",
		["settings.bgstyle.rain"] = "Rain",
		["settings.openButton"] = "Open button",
		["settings.openButton.note"] = "Floating open button on PC and mobile. Drag to move it.",
		["settings.language"] = "Language",
		["settings.language.note"] = "Panel language. Auto follows your Roblox language.",
		["settings.tapSave"] = "Tap save after editing fields.",
		["settings.unsaved"] = "Unsaved changes. Tap Save settings to apply.",
		["settings.loaded"] = "Settings loaded.",
		["settings.loadFailed"] = "Failed to load settings.",
		["settings.saving"] = "Saving...",
		["settings.saved"] = "Saved.",
		["settings.saveFailed"] = "Save failed",
		["settings.resetting"] = "Resetting...",
		["settings.resetFailed"] = "Reset failed. Check that API Services are enabled.",
		["settings.resetDone"] = "Settings reset to defaults.",
		["settings.saveButton"] = "Save settings",
		["settings.hint"] = "Use the toggles below to control the panel.",
		["language.auto"] = "Auto",
		["ui.yes"] = "Yes",
		["ui.decline"] = "Decline",
		["ui.confirm"] = "Confirm",
		["ui.yesContinue"] = "Yes, continue",
		["ui.cancel"] = "Cancel",
		["ui.apply"] = "Apply",
		["ui.clear"] = "Clear",
		["ui.select"] = "Select",
		["ui.refresh"] = "Refresh",
		["ui.stop"] = "Stop",
		["ui.loading"] = "Loading...",
		["ui.on"] = "On",
		["ui.off"] = "Off",
		["update.title"] = "New Update",
		["update.version"] = "New version: v%s",
		["update.desc"] = "A new version of Zone Panel is available. Re-download it from your Parcel library!",
		["update.ok"] = "Ok",
		["ui.add"] = "Add",
		["ui.useColor"] = "Use this color",
		["ui.brightness"] = "Brightness",
		["ui.join"] = "Join",
		["confirm.sure"] = "Are you sure?",
		["confirm.execute"] = "Execute %s on %s?",
		["confirm.run"] = "Run %s on %s.",
		["group.joinMsg"] = "Open the Roblox join prompt for %s?",
		["chat.title"] = "Chat",
		["chat.adminsOnly"] = "Admins only chat.",
		["chat.loading"] = "Loading chat...",
		["chat.loaded"] = "Chat loaded.",
		["chat.typeFirst"] = "Type a message first.",
		["chat.sending"] = "Sending...",
		["chat.sendFailed"] = "Failed to send chat message.",
		["chat.sendError"] = "Chat send error.",
		["chat.sent"] = "Message sent.",
		["chat.placeholder"] = "Type a message...",
		["chat.none"] = "No chat messages yet.",
		["chat.deliverFailed"] = "Message could not be delivered. Try again.",
		["chat.pipBack"] = "Chat is open in a small window.\n\nClick here to bring it back into the panel.",
		["ai.title"] = "Zone AI",
		["ai.setupTitle"] = "How to Set Up Zone AI?",
		["ai.setupNote"] = "Paste the key into AI_API_KEY at the top of the server script, enable HTTP requests, and the Zone AI chat will appear here.",
		["ai.empty"] = "No messages yet. Ask Zone AI something!",
		["ai.thinking"] = "Zone AI is thinking...",
		["ai.sendFailed"] = "Send failed.",
		["ai.timeout"] = "Answer timed out.",
		["ai.error"] = "AI error.",
		["ai.running"] = "Zone AI is running it...",
		["ai.confirmHint"] = "Confirm the action below.",
		["ai.declined"] = "Command declined.",
		["ai.note"] = "Ask, or give a command with an admin action.",
		["ai.hintShort"] = "Ask, or give a command.",
		["ai.placeholder"] = "Ask Zone AI or give a command...",
		["spectate.title"] = "Spectating",
		["spectate.name"] = "Spectating %s",
		["ui.selectPlayer"] = "Select a player",
		["server.mgr"] = "Server Manager",
		["server.load"] = "Server load",
		["server.details"] = "Server details",
		["server.players"] = "Players in this server",
		["server.lastRefreshFmt"] = "Last refresh: %s",
		["server.playersCount"] = "Players in this server (%d)",
		["server.typeInfo"] = "Type: %s\nHealth: %s\nUptime: %s",
		["server.detailsFmt"] = "PlaceId: %s\nJobId: %s\nPlayers: %d/%d\nServerType: %s\nPrivateServerId: %s",
		["server.ageInfo"] = "Age %s days  •  Region %s\nRank %s",
		["server.regionInfo"] = "Your region: %s\nRequesting player region: %s\nRoblox does not expose the server's physical country directly.",
		["history.logTitle"] = "Moderation Log",
		["history.note"] = "Latest moderation actions for the current session.",
		["history.recent"] = "Recent moderation",
		["history.none"] = "No moderation actions logged yet.",
		["history.showingFmt"] = "Showing %d entries",
		["history.showingOf"] = "Showing %d of %d results",
		["history.filterTitle"] = "Moderation Filter",
		["history.filterNote"] = "Use these fields to filter by who did what.",
		["history.enterHint"] = "Press Enter inside a box to apply.",
		["history.noFilter"] = "No filter active.",
		["history.noLogs"] = "No logs yet.",
		["history.filter"] = "Filter",
		["admins.countFmt"] = "Admins: %d",
		["admins.none"] = "No admins loaded.",
		["admins.addTitle"] = "Add admin",
		["admins.idPh"] = "UserId or username",
		["admins.moderator"] = "Moderator",
		["admins.selectRank"] = "Select Rank",
		["players.noneSelected"] = "No player selected",
		["players.findHint"] = "Select a player and press Find.",
		["players.remove"] = "Remove",
		["players.unban"] = "Unban",
		["players.unbanning"] = "Unbanning...",
		["players.target"] = "Target",
		["players.usernamePh"] = "Username",
		["players.reasonPh"] = "Reason / note text",
		["players.valuePh"] = "Value (speed / jump / ban minutes)",
		["players.resolve"] = "Resolve Target",
		["players.searchPh"] = "Search commands",
		["players.pinned"] = "Pinned",
		["players.actionsHint"] = "Actions (tap to execute)",
		["players.notesCard"] = "Notes",
		["players.notesCount"] = "Notes (%d)",
		["players.notesTitle"] = "Notes — %s",
		["players.notePh"] = "Add a new note...",
		["players.noNotes"] = "No notes for this player yet.",
		["players.ageJoin"] = "Age: %d days • Join: %s",
		["player.line"] = "Player: %s (@%s)",
		["player.source"] = "Source: %s",
		["player.items"] = "Items: %d",
		["status.tempbanned"] = "Temp banned until %s\n%s",
		["status.permbanned"] = "Permanently banned\n%s",
		["status.tempmuted"] = "Temp muted until %s",
		["inv.name"] = "Inventory — %s",
		["inv.userid"] = "Inventory — UserId %s",
		["inv.timeout"] = "Loading inventory timed out for %s.\n\nThe target may be offline, in another server, or the server did not answer.",
		["ban.title"] = "Ban List",
		["ban.note"] = "Search banned players or unban them instantly.",
		["ban.searchPh"] = "Search by name, reason, or UserId",
		["ban.countFmt"] = "%d banned players",
		["ban.countOne"] = "1 banned player",

		["ban.none"] = "No banned players found.",
		["credits.follow"] = "Follow us for more panels and updates!",
		["credits.about"] = "Creator, helpers, and group details.",
		["credits.joinGroup"] = "Join To Group",
		["announce.title"] = "Announcements",
		["announce.note"] = "Broadcast a message, start a vote or run a timer across every server.",
		["announce.here"] = "Here — Current Server",
		["vote.winner"] = "Winner: ",
		["vote.optionA"] = "Option A",
		["vote.optionB"] = "Option B",
		["lock.title"] = "Server is LOCKED",
		["lock.panic"] = "PANIC - LOCK SERVER",
		["lock.unlock"] = "UNLOCK SERVER",
		["lock.note"] = "Kicks every non-admin and blocks new joins.",
		["lock.hintBy"] = " by ",
		["lock.hintUnlock"] = ". Tap to unlock.",
		["settings.resetTitle"] = "Reset settings",
		["settings.resetNote"] = "Restores every setting on this account to its default.",
		["settings.setupTitle"] = "Run setup again",
		["settings.setupNote"] = "Reopens the first time setup wizard.",
		["settings.themePick"] = "Pick a color theme and press Save settings to apply it.",
		["settings.themeLabel"] = "Theme: ",
		["settings.accentTitle"] = "Custom Accent Color",
		["settings.webhookPh"] = "Webhook URL",
		["settings.customColor"] = "Custom color #",
		["settings.sum.anim"] = "Animation: ",
		["settings.sum.openInStart"] = "Open in start: ",
		["settings.sum.remember"] = "Remember Last Tab: ",
		["settings.sum.streamer"] = "Streamer Mode: ",
		["settings.sum.blur"] = "Blur Background: ",
		["settings.sum.theme"] = "Theme: ",
		["theme.pendingFmt"] = "Theme: %s  ->  %s (press Save settings)",
		["theme.pendingCustomFmt"] = "Theme: %s  ->  Custom #%s (press Save settings)",
		["settings.customSelectedFmt"] = "Custom color #%s selected. Press Save settings to apply.",
		["settings.themeSelectedFmt"] = "Theme \"%s\" selected. Press Save settings to apply it.",
		["settings.tapSaveHint"] = "Tap save after editing fields.",
		["code.title"] = "Code Window",
		["code.note"] = "This window is used for confirmation and code-style preview.",
		["code.placeholder"] = "Code / action preview",
		["menu.title"] = "Menu",
		["menu.hint"] = "Tap a tab below and scroll the page.",
		["home.playersOnline"] = "Players online",
		["home.streamerHidden"] = "Hidden by streamer mode.",
		["home.tile.actions.note"] = "Run commands",
		["home.tile.server.note"] = "Live stats",
		["home.tile.ban.label"] = "Bans",
		["home.tile.ban.note"] = "Ban list",
		["home.tile.settings.note"] = "Preferences",
		["auth.welcomeBack"] = "Welcome back",
		["auth.signedIn"] = "Signed in",
		["auth.ph"] = "kick playername reason",
		["wiz.welcome"] = "Welcome!",
		["wiz.sub"] = "A quick setup before you start.",
		["wiz.themeTitle"] = "Choose a theme",
		["wiz.themeNote"] = "Pick a look. It changes instantly so you can compare.",
		["wiz.ifaceTitle"] = "Interface",
		["wiz.ifaceNote"] = "How the panel should behave.",
		["wiz.done"] = "Setup completed",
		["wiz.thanks"] = "Thanks for purchasing Zone Panel :D",
		["wiz.finish"] = "Finish",
		["wiz.fail"] = "Could not save. Check that API Services are enabled and try again.",
		["wiz.welcomeTitle"] = "Welcome",
		["wiz.next"] = "Next",
		["wiz.back"] = "Back",
		["notify.noServerPlayer"] = "That player is not in this server.",
		["notify.noCharacter"] = "That player has no character right now.",
		["notify.joinFailed"] = "Could not join that server.",
		["notify.resolveFailed"] = "Could not resolve that player.",
		["notify.targetMissing"] = "Target not found.",
		["notify.sidebarSaveFail"] = "Sidebar order could not be saved. Enable Studio Access to API Services.",
		["wiz.step"] = "Step %d of %d",
		["wiz.themeCustomNote"] = "Custom lets you build your own palette from a color wheel in Settings.",
		["wiz.langNote"] = "Pick your language. It changes the whole panel right away.",
		["home.greetingFmt"] = "Welcome back, %s",
		["home.rankFmt"] = "Signed in as %s",
		["home.playersOnlineFmt"] = "Players online (%d)",
		["home.statUptime"] = "Server uptime",
		["common.byFmt"] = "by %s",
		["history.byReasonFmt"] = "by %s - %s",
		["history.byUserFmt"] = "by UserId %s • %s",
		["confirm.reasonFmt"] = "\nReason: %s",
		["admins.rankLineFmt"] = "Rank: %s • UserId: %s%s",
		["admins.setRankFmt"] = "Set rank %s for UserId %s",
		["ban.detailFmt"] = "UserId: %s\nReason: %s\nModerator: %s (%s)\nType: %s",
		["players.targetLoadedFmt"] = "Target loaded: %s",
		["players.sentFmt"] = "Sent %s",
		["players.viewNotesFmt"] = "View Notes (%d)",
		["server.placeJobFmt"] = "Place %s\nJob %s",
		["server.summaryFmt"] = "%s • %d/%d players",
		["server.slotsFreeFmt"] = "%s  •  %d slot(s) free",
		["credits.joinedFmt"] = "Joined %s.",
		["credits.joinPendingFmt"] = "Join request pending for %s.",
		["credits.joinClosedFmt"] = "Join prompt closed for %s.",
		["credits.groupFmt"] = "Group: %s",
		["credits.groupIdFmt"] = "Group ID: %s",
		["credits.joinNoteFmt"] = "Join the %s group to get every new release first.",
		["notify.joinFriendFmt"] = "You will leave the current server and join the one %s is playing on.",
		["notify.warningSentFmt"] = "Warning sent to %s.",
		["time.mAgo"] = "%dm ago",
		["time.hAgo"] = "%dh ago",
		["time.dAgo"] = "%dd ago",
		["announce.global"] = "Global Announcement",
		["announce.messagePh"] = "Type your announcement...",
		["announce.send"] = "Send Announcement",
		["announce.warnTitle"] = "Warn Player",
		["announce.warnReasonPh"] = "Warning reason",
		["announce.warnSend"] = "Send Warning",
		["announce.voteTitle"] = "Vote (15 seconds)",
		["announce.voteQuestionPh"] = "Vote question",
		["announce.option1Ph"] = "Option 1",
		["announce.option2Ph"] = "Option 2",
		["announce.voteStart"] = "Start Vote",
		["announce.timerTitle"] = "Admin Abuse Timer",
		["announce.minutesPh"] = "Minutes",
		["announce.timerStart"] = "Start Timer",
		["announce.timerStop"] = "Stop Timer",
		["announce.enterUser"] = "Enter a username to warn.",
		["announce.enterReason"] = "Enter a warning reason.",
		["announce.sending"] = "Sending announcement...",
		["announce.voteNeedAll"] = "Question and both options are required.",
		["announce.startingVote"] = "Starting vote...",
		["announce.enterMinutes"] = "Enter a valid number of minutes.",
		["announce.startingTimer"] = "Starting timer...",
		["announce.stoppingTimer"] = "Stopping timer...",
		["settings.chatTranslate"] = "Automatic chat translation",
		["settings.chatTranslate.note"] = "AI translates other players' chat bubbles to your panel language.",
		["settings.aiTranslated"] = "ⓘ Translated by Artificial Intelligence.",
		["chat.original"] = "Original",
		["chat.translateNeedServer"] = "Chat translation: update the ServerScript too (V80+)!",
		["chat.translateNoKey"] = "Chat translation: AI_API_KEY missing or rejected (same key as Zone AI).",
		["chat.translateFailed"] = "Chat translation failed. Check HTTP requests and the server AI key.",
		["stats.title"] = "Game statistics",
		["stats.live"] = "Online now (all servers)",
		["stats.today"] = "Played today (unique)",
		["stats.total"] = "Total players (all time)",
		["stats.peak"] = "Peak today / ever",
		["stats.chartNote"] = "Statistics start counting from the day this version went live.",
		["stats.range.day"] = "1 Day",
		["stats.range.week"] = "1 Week",
		["stats.range.m6"] = "6 Months",
		["stats.range.m12"] = "12 Months",
		["stats.range.y3"] = "3 Years",
		["stats.noData"] = "No data yet",
		["stats.rangeLabel"] = "Period",
		["ui.close"] = "Close",
		["server.unknown"] = "Unknown",
		["server.notHere"] = "Not in this server",
		["server.measuring"] = "Measuring...",
		["settings.saveFailedFmt"] = "Save failed: %s",
		["settings.saveFailedPeriod"] = "Save failed.",
		["events.voteDuration"] = "15 s",
		["settings.glowSaveFailed"] = "Glow save failed. Tap Save settings to retry.",
		["settings.themeValueFmt"] = "Theme: %s",
		["settings.toggle.animFmt"] = "Animation: %s",
		["settings.toggle.openFmt"] = "Open in start: %s",
		["settings.toggle.rememberFmt"] = "Remember Last Tab: %s",
		["settings.toggle.streamerFmt"] = "Streamer Mode: %s",
		["settings.toggle.blurFmt"] = "Blur Background: %s",
		["rank.createTitle"] = "Create custom rank",
		["rank.namePh"] = "Rank name (3-18 characters)",
		["rank.everythingAllowed"] = "Everything is ticked. Untick what this rank should not get.",
		["rank.create"] = "Create rank",
		["rank.new"] = "+ New custom rank",
		["coin.foundFmt"] = "Found in this server: %s",
		["coin.notFound"] = "No number value found on any player yet.",
		["coin.title"] = "Coin Adder",
		["coin.note"] = "Pick a value, pick who gets it, then send.",
		["ui.value"] = "Value",
		["ui.give"] = "Give",
		["events.title"] = "Events",
		["events.scopeNote"] = "This server = local; Global = every server.",
		["events.scope"] = "Scope",
		["events.thisServer"] = "This server",
		["events.global"] = "Global",
		["events.durationPh"] = "Duration in minutes (empty = event default)",
		["ui.start"] = "Start",
		["vote.optionCountFmt"] = "%s - %d",
		["events.serverUpdate"] = "Server update",
		["events.messagePh"] = "Message (default Updating)",
		["events.updateThis"] = "Update this server",
		["events.updateAll"] = "Update all servers",
		["esp.statusFmt"] = "ESP: %s",
		["players.valuePhRoblox"] = "Value (speed / Roblox API ban minutes)",
		["settings.apiSaveFailed"] = "Could not save. Check that API Services are enabled, then try again.",
		["settings.themePickLong"] = "Pick a color theme, then press Save settings to apply it.",
		["menu.hintMobile"] = "Tap a tab below, then scroll the page.",
		["events.tacoTime"] = "Taco Time",
		["color.hexLabel"] = "HEX",
		["vote.winnerFmt"] = "Winner: %s",
		["license.title"] = "Verification failed",
		["license.http"] = "Turn ON HTTP Requests to verify. Game Settings > Security > Allow HTTP Requests, then restart the server.",
		["license.config"] = "Hub ID or Product ID is missing in the script. Fill in ZONE_LICENSE at the top of the ServerScript.",
		["license.unlicensed"] = "This place is not licensed to run Zone Panel V8.5 [Pro].",
		["license.error"] = "The license server could not be reached. Try again later.",
		["buildtools.wait"] = "Waiting up to 5 seconds for Build Tools to appear...",
		["buildtools.received"] = "Build Tools received.",
		["buildtools.notAppeared"] = "The server granted Build Tools, but they did not appear on your client after 5 seconds.",
		["buildtools.failed"] = "Build Tools failed.",
		["action.completed"] = "Action completed.",
		["action.failedFmt"] = "%s failed.",
		["action.completedFmt"] = "%s completed.",
		["chat.filterUnavailable"] = "Chat filtering is unavailable right now. Please try again.",
		["player.spectatingFmt"] = "Spectating %s",
		["player.notFoundFmt"] = "Could not find player: %s",
		["player.notFound"] = "Could not find that player.",
		["player.noServer"] = "Player is not in this server.",
		["player.noServerFmt"] = "Player is not in this server: %s",
		["player.targetNotFound"] = "Target not found on this server.",
		["player.missingTarget"] = "Missing target.",
		["player.selectTarget"] = "Select a target first.",
		["player.noTargetSelected"] = "No target selected",
		["player.groupJoinFailed"] = "Could not open the group join prompt.",
		["player.noInspect"] = "You cannot inspect that player.",
		["player.cannotTargetFmt"] = "You cannot target %s.",
		["player.ownerProtected"] = "The game owner cannot be targeted.",
		["player.selfProtected"] = "You cannot use that on yourself.",
		["player.accountAgeFmt"] = "%s account age: %d day(s)",
		["player.pingFmt"] = "%s ping: %d ms",
		["player.msFmt"] = "%d ms",
		["player.daysFmt"] = "%d days",
		["player.daysYearsFmt"] = "%d days  -  %d year(s)",
		["common.showingFmt"] = "Showing %d entries",
		["common.badRequest"] = "Bad request.",
		["common.emptyCommand"] = "Empty command.",
		["common.emptyBatch"] = "Empty batch.",
		["common.tooManyBatch"] = "Too many actions in one batch (max 6).",
		["common.actionUnsupported"] = "That action is not supported.",
		["common.nothingToUndo"] = "Nothing to undo.",
		["common.undoFailedFmt"] = "Could not undo %s.",
		["common.undoFmt"] = "Undid %s on %s.",
		["common.undoBanFmt"] = "Undid Ban on %s.",
		["common.executedFmt"] = "%s executed.",
		["common.doneFmt"] = "Done: %s",
		["command.unknownFmt"] = "Unknown command: %s",
		["command.unsupportedFound"] = "No supported admin command found.",
		["command.empty"] = "Message is empty.",
		["command.noPermission"] = "You do not have permission.",
		["command.noPermissionForThat"] = "You do not have permission for that.",
		["command.warnNeedReason"] = "Warn needs a reason.",
		["command.noReason"] = "No reason provided.",
		["command.typeFirst"] = "Type something first.",
		["command.waitPrevious"] = "Wait for the previous answer first.",
		["command.slowDown"] = "Slow down a little, then try again.",
		["command.needTargetFmt"] = "%s needs a target.",
		["command.cannotFindPlayerFmt"] = "Could not find player: %s",
		["command.playerNoLongerHereFmt"] = "%s is no longer in this server.",
		["command.cannotUseGlobalFmt"] = "%s cannot be used globally.",
		["command.cannotEveryoneFmt"] = "%s cannot be used on everyone.",
		["command.notAppliedAnyoneFmt"] = "%s could not be applied to anyone.",
		["command.appliedCountFmt"] = "%s applied to %d player(s).",
		["command.sentAllFmt"] = "%s sent to every server.",
		["command.offlineWarningFmt"] = "%s is offline. Warning saved for their next join.",
		["command.equalOrHigherFmt"] = "%s is staff with an equal or higher rank.",
		["command.rankCannotFmt"] = "Your rank cannot use %s.",
		["command.rankDoesNotAllowFmt"] = "Your rank does not allow %s.",
		["command.rankCannotUseCommands"] = "Your rank cannot use commands.",
		["ban.failed"] = "Ban failed.",
		["ban.unbanFailed"] = "Unban failed.",
		["ban.offlineFmt"] = "Banned %s (offline).",
		["ban.unbannedFmt"] = "Unbanned %s.",
		["ban.kickReasonFmt"] = "Banned: %s",
		["ban.tempUntilFmt"] = "Temp banned until %s: %s",
		["ban.untilFmt"] = "%s Until %s",
		["ban.defaultKick"] = "You Get Banned By Moderator.",
		["ban.invalidEntry"] = "Invalid ban entry.",
		["ban.unbanDoneFmt"] = "Undid Ban on %s.",
		["mute.enterMinutes"] = "Enter the mute length in minutes.",
		["warn.saveFailed"] = "Could not save the warning.",
		["warn.noteAddedFmt"] = "Note added to %s.",
		["undo.nothing"] = "Nothing to undo.",
		["undo.failedFmt"] = "Could not undo %s.",
		["events.alreadyRunningFmt"] = "Already running: %s.",
		["events.restartRunning"] = "A restart is already running.",
		["events.chooseScope"] = "Choose This server or Global.",
		["events.selectOne"] = "Select at least one event.",
		["events.noneLocal"] = "No selected event is running on this server.",
		["events.noneGlobal"] = "No selected global event is running.",
		["events.noValid"] = "No valid selected event.",
		["events.alreadySelectedFmt"] = "Selected event(s) already running: %s.",
		["events.startedFmt"] = "Started %s %s.",
		["events.stoppedFmt"] = "Stopped %s %s.",
		["events.startDenied"] = "Your rank cannot start events.",
		["events.stopDenied"] = "Your rank cannot stop events.",
		["events.serverUpdateDenied"] = "Only the owner can run a server update.",
		["events.serverUpdateSent"] = "Server update sent to all servers.",
		["events.serverUpdateStarted"] = "Server update started.",
		["events.serverUpdateSentFmt"] = "Update sent to every server (%d s).",
		["events.restartFmt"] = "This server restarts in %d s.",
		["events.lockedFmt"] = "Server LOCKED. %d player(s) removed.",
		["events.unlocked"] = "Server unlocked. Players can join again.",
		["events.discoOn"] = "Disco on.",
		["events.discoOff"] = "Disco off.",
		["events.serverTimeFmt"] = "Server time set to %s.",
		["time.invalidNumber"] = "Time needs a number, for example 14 or 14:30.",
		["time.invalidHour"] = "Time needs an hour, for example 14 or 14:30.",
		["time.changeFailed"] = "Could not change the time.",
		["timer.needMinutes"] = "Timer needs a number of minutes.",
		["timer.invalidMinutes"] = "Enter a valid number of minutes.",
		["timer.startedFmt"] = "Timer started for %d minute(s).",
		["timer.stopped"] = "Timer stopped.",
		["timer.startFailed"] = "Timer could not be started.",
		["announce.needMessage"] = "Announce needs a message.",
		["announce.sentAll"] = "Announcement sent to every server.",
		["announce.sent"] = "Announcement sent.",
		["announce.noticeFmt"] = "Announcement: %s",
		["group.idUnavailable"] = "Group ID unavailable.",
		["group.chooseAdd"] = "Enter a UserId or username to add.",
		["group.enterUsername"] = "Enter username or UserId.",
		["global.choose"] = "Choose This server or Global.",
		["global.chatSent"] = "Global chat message sent.",
		["global.chatSendFailed"] = "Global chat message could not be sent.",
		["global.chatDeliverFailed"] = "The global chat message could not be delivered. Please try again.",
		["global.commandsDisabled"] = "Global commands are disabled. Enable them in Settings.",
		["global.adminRequired"] = "Global commands need Admin rank.",
		["global.adminRequiredShort"] = "Global needs Admin rank.",
		["coin.noValueForPlayerFmt"] = "No %s value found on that player.",
		["coin.noPlayerValueFmt"] = "No player has a %s value in this server.",
		["coin.amountRangeFmt"] = "Enter an amount between %d and %d.",
		["inventory.unavailable"] = "Inventory unavailable.",
		["inventory.unavailablePlayer"] = "Inventory unavailable for that player.",
		["inventory.timeout"] = "Inventory request timed out.",
		["inventory.remoteTimeout"] = "Remote action request timed out.",
		["rank.exists"] = "A rank with that name already exists.",
		["rank.nameInvalid"] = "Name must be 3-18 letters and not a built-in rank.",
		["rank.ownerCreate"] = "Only the owner can create ranks.",
		["rank.ownerDelete"] = "Only the owner can delete ranks.",
		["rank.maxCustomFmt"] = "You can have %d custom ranks at most.",
		["rank.invalid"] = "Invalid rank. Use Helper / Moderator / Admin / Owner or a custom rank.",
		["rank.badRequest"] = "Bad request.",
		["rank.createSavedFailFmt"] = "Rank %s created, but saving failed. Enable Studio Access to API Services.",
		["rank.createdFmt"] = "Rank %s created with %d permissions.",
		["rank.deletedSavedFailFmt"] = "Rank %s deleted, but saving failed. Enable Studio Access to API Services.",
		["rank.deletedFmt"] = "Rank %s deleted (%d admins cleared).",
		["rank.missing"] = "That rank does not exist.",
		["rank.permissionCountFmt"] = "%s created with %d permissions.",
		["roles.ownerOnlyCreate"] = "Only the owner can create ranks.",
		["roles.ownerOnlyDelete"] = "Only the owner can delete ranks.",
		["api.noKey"] = "No API key set. Paste your API key into AI_API_KEY in the server script.",
		["api.keyError"] = "API key error. Check AI_API_KEY in the server script.",
		["api.httpOff"] = "HTTP requests are off. Enable Game Settings > Security > Allow HTTP Requests.",
		["ai.rateLimited"] = "The AI is rate limited. Wait a bit and try again.",
		["ai.wrongModel"] = "The AI provider says its model is wrong. Tell the panel developer.",
		["ai.noAnswer"] = "The AI did not answer. Try again in a moment.",
		["ai.answerOdd"] = "The AI answered oddly. Try again.",
		["ai.hitError"] = "The AI hit an error. Try again.",
		["ai.noTargetFmt"] = "The AI found no target for %s. Say exact player names?",
		["ai.noTarget"] = "The AI found no target. Say the exact player name?",
		["ai.noVoteQuestion"] = "The AI found no vote question. Rephrase it?",
		["ai.unsupportedActionFmt"] = "The AI picked an unsupported action (%s). Rephrase it?",
		["ai.unsupportedAction"] = "The AI picked an unsupported action. Rephrase it?",
		["ai.emptyBatch"] = "The AI sent an empty batch. Rephrase it?",
		["ai.batchFmt"] = "Batch %d/%d: %s",
		["ai.missingKeyMessage"] = "No API key set. Paste your API key into AI_API_KEY in the server script.",
		["ai.somethingFailed"] = "Something failed.",
		["ai.readyStatus"] = "Zone AI ready.",
		["chat.ackSent"] = "Message sent.",
		["chat.sendGenericError"] = "Chat send error.",
		["update.latest"] = "You are running the latest version.",
		["update.noticeFmt"] = "New update available: v%s (you have v%s). Re-download the panel from your Parcel library!",
		["update.bannerFmt"] = "New update available: v%s - re-download it from your Parcel library.",
		["admin.actionTitle"] = "Admin action",
		["admin.logsTitle"] = "AdminPanel Logs",
		["server.private"] = "Private Server",
		["server.public"] = "Public Server",
		["server.reserved"] = "Reserved Server",
		["server.typeShortFmt"] = "%s Until %s",
		["coin.givenOneFmt"] = "+%d %s given to %s.",
		["coin.givenCountFmt"] = "+%d %s given to %d player(s).",
		["coin.givenSkippedFmt"] = "+%d %s given to %d player(s), %d skipped.",
		["coin.givenLocalGlobalFmt"] = "+%d %s given here (%d), other servers could not be reached.",
		["coin.givenGlobalFmt"] = "+%d %s sent to every server (%d here).",
		["coin.noPlayerInServerFmt"] = "No player has a %s value in this server.",
		["command.announceAllFmt"] = "%s sent to every server.",
		["command.executedFmt"] = "%s executed.",
		["command.alreadyRunningFmt"] = "Already running: %s.",
		["command.noTarget"] = "Target not found.",
		["command.notInServerFmt"] = "%s is no longer in this server.",
		["command.rankStaffFmt"] = "%s is staff with an equal or higher rank.",
		["command.cannotGlobalFmt"] = "%s cannot be used globally.",
		["command.nobodyAppliedFmt"] = "%s could not be applied to anyone.",
		["command.appliedFmt"] = "%s applied to %d player(s).",
		["command.usedCountFmt"] = "%s applied to %d player(s).",
		["command.noPlayerValueFmt"] = "No %s value found on that player.",
		["commands.globalDisabled"] = "Global commands are disabled. Enable them in Settings.",
		["commands.adminNeeded"] = "Global commands need Admin rank.",
		["commands.needsAdmin"] = "Global needs Admin rank.",
		["commands.rankCommandDenied"] = "Your rank cannot use commands.",
		["events.timeCommandBad"] = "Timer needs a number of minutes.",
		["events.announceNeed"] = "Announce needs a message.",
		["events.voteNeed"] = "Vote needs a question.",
		["events.voteStarted"] = "Vote started.",
		["events.voteStartedFmt"] = "Vote started: %s",
		["events.restartAlready"] = "A restart is already running.",
		["coin.globalNeedAdmin"] = "Global needs Admin rank.",
		["coin.givenFmt"] = "+%d %s given to %d player(s), %d skipped.",
		["coin.givenSimpleFmt"] = "+%d %s given to %d player(s).",
		["coin.givenToFmt"] = "+%d %s given to %s.",
		["coin.givenHereFmt"] = "+%d %s given here (%d), other servers could not be reached.",
		["coin.givenAllFmt"] = "+%d %s sent to every server (%d here).",
		["server.lockedByAdmin"] = "This server is locked by an admin. Please try another server.",
		["notify.actionFailed"] = "Something failed.",
		["update.versionNotice"] = "New update available: v%s",
		["player.targetHidden"] = "Target hidden",
		["confirm.titleAction"] = "Confirm action",
		["esp.enabled"] = "ESP enabled.",
		["esp.disabled"] = "ESP disabled.",
		["esp.toggled"] = "ESP toggled.",
		["fly.disabled"] = "Fly disabled.",
		["command.executedActionFmt"] = "Executed %s",
		["chat.translationLabel"] = "Translation",
	},
}

ZONE_LANG_BINDINGS = {}

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

-- The panel is English only.
function ZoneCurrentLanguage()
	return "en"
end

function ZoneT(key)
	local lang = ZoneCurrentLanguage()
	local dict = ZONE_LANG[lang] or ZONE_LANG.en
	local value = dict[key]
	if value == nil then
		value = ZONE_LANG.en[key]
	end
	if value == nil then
		return tostring(key)
	end
	return value
end

function ZoneLanguageDisplayName(code)
	code = normalizeLanguageCode(code)
	if code == "en" then
		return "English"
	end
	if code == "es" then
		return "Español"
	end
	if code == "fr" then
		return "Français"
	end
	if code == "de" then
		return "Deutsch"
	end
	if code == "pt" then
		return "Português"
	end
	if code == "zh" then
		return "中文"
	end
	if code == "hu" then
		return "Magyar"
	end
	return ZoneT("language.auto")
end

function zoneSetLanguageProperty(guiObject, propName, textValue)
	local previousApplying = nil
	pcall(function()
		previousApplying = guiObject:GetAttribute("ZoneLangApplying")
		guiObject:SetAttribute("ZoneLangApplying", true)
	end)
	local okSet = pcall(function()
		guiObject[propName] = textValue
	end)
	pcall(function()
		guiObject:SetAttribute("ZoneLangApplying", previousApplying)
	end)
	return okSet
end

function registerLangText(guiObject, keyOrFn, propName)
	if guiObject == nil then
		return
	end
	local prop = type(propName) == "string" and propName or "Text"
	local getText = keyOrFn
	if type(keyOrFn) == "string" then
		getText = function()
			return ZoneT(keyOrFn)
		end
	end
	if type(getText) ~= "function" then
		return
	end
	local okText, textValue = pcall(function()
		return tostring(getText())
	end)
	if not okText then
		return
	end
	for index = #ZONE_LANG_BINDINGS, 1, -1 do
		local binding = ZONE_LANG_BINDINGS[index]
		if binding.obj == guiObject and (binding.prop or "Text") == prop then
			table.remove(ZONE_LANG_BINDINGS, index)
		end
	end
	if not zoneSetLanguageProperty(guiObject, prop, textValue) then
		return
	end
	table.insert(ZONE_LANG_BINDINGS, { obj = guiObject, fn = getText, prop = prop })
end

function ZoneRefreshLanguage()
	local alive = {}
	for _, binding in ipairs(ZONE_LANG_BINDINGS) do
		pcall(function()
			if binding.obj and binding.obj.Parent ~= nil then
				zoneSetLanguageProperty(binding.obj, binding.prop or "Text", tostring(binding.fn()))
				table.insert(alive, binding)
			end
		end)
	end
	ZONE_LANG_BINDINGS = alive
	pcall(function()
		if buildMobileNav then
			buildMobileNav()
		end
	end)
end

function normalizeMobileButtonPosition(value)
	if type(value) ~= "string" then return "" end
	local xText, yText = value:match("^([%d%.]+),([%d%.]+)$")
	local x = tonumber(xText)
	local y = tonumber(yText)
	if not x or not y or x < 0 or x > 1 or y < 0 or y > 1 then return "" end
	return string.format("%.4f,%.4f", x, y)
end

function normalizeSettingsPayload(data)
	if type(data) ~= "table" then
		return {
			animationOn = true,
			openInStart = true,
			rememberLastTab = true,
			streamerMode = false,
			blurBackground = false,
			saveSidebarOrder = true,
			confirmActions = true,
			aiConfirmActions = true,
			backgroundImage = false,
			chatPopups = true,
			animatedBackground = false,
			mobileButton = true,
			mobileButtonPosition = "",
			glowEffect = true,
			glowStrength = 40,
			globalCommands = false,
			autoTranslateChat = false,
			language = "auto",
			backgroundStyle = "stripes",
			customAccent = "00DCFF",
			theme = DEFAULT_THEME_NAME,
			lastTab = "home",
		}
	end
	if data.animationOn == nil then
		data.animationOn = true
	end
	if data.openInStart == nil then
		data.openInStart = true
	end
	if data.rememberLastTab == nil then
		data.rememberLastTab = true
	end
	if data.streamerMode == nil then
		data.streamerMode = false
	end
	if data.blurBackground == nil then
		data.blurBackground = false
	end
	if data.saveSidebarOrder == nil then
		data.saveSidebarOrder = true
	end
	if data.confirmActions == nil then
		data.confirmActions = true
	end
	if data.aiConfirmActions == nil then
		data.aiConfirmActions = true
	end
	if data.backgroundImage == nil then
		data.backgroundImage = false
	end
	if data.chatPopups == nil then
		data.chatPopups = true
	end
	if data.animatedBackground == nil then
		data.animatedBackground = false
	end
	if data.mobileButton == nil then
		data.mobileButton = true
	end
	local savedButtonPosition = normalizeMobileButtonPosition(data.mobileButtonPosition)
	if state.mobileButtonPositionTouched and type(state.settingsData) == "table" then
		savedButtonPosition = normalizeMobileButtonPosition(state.settingsData.mobileButtonPosition)
	end
	data.mobileButtonPosition = savedButtonPosition
	if data.glowEffect == nil then
		data.glowEffect = true
	end
	if data.globalCommands == nil then data.globalCommands = false end
	if data.autoTranslateChat == nil then data.autoTranslateChat = false end
	data.language = normalizeLanguageCode(data.language)
	data.backgroundStyle = normalizeBgStyleCode(data.backgroundStyle)
	local parsedAccent = hexToColor(data.customAccent)
	data.customAccent = parsedAccent and colorToHex(parsedAccent) or "00DCFF"
	data.glowStrength = 40
	data.theme = normalizeThemeName(data.theme)
	if data.openKeys == nil then
		data.openKeys = "RightControl,Insert,Home"
	end
	if data.lastTab == nil or tostring(data.lastTab) == "" then
		data.lastTab = "home"
	end
	return data
end

local function cloneSettingsTable(value, seen)
	if type(value) ~= "table" then
		return value
	end
	seen = seen or {}
	if seen[value] then
		return seen[value]
	end
	local out = {}
	seen[value] = out
	for k, v in pairs(value) do
		out[cloneSettingsTable(k, seen)] = cloneSettingsTable(v, seen)
	end
	return out
end

local function getSettingsDraft()
	if type(state.settingsDraft) ~= "table" then
		state.settingsDraft = cloneSettingsTable(state.settingsData or {})
	end
	state.settingsDraft = normalizeSettingsPayload(state.settingsDraft or {})
	return state.settingsDraft
end

local function setSettingsDirty(isDirty)
	state.settingsDirty = isDirty == true
	if state.settingsDirty and settingsStatusLabel then
		settingsStatusLabel.Text = "Unsaved changes. Tap Save settings to apply."
	end
end

function getSettingsDraftSafe()
	local ok, draft = pcall(getSettingsDraft)
	if ok and type(draft) == "table" then
		return draft
	end
	return nil
end

function setSettingsDirtySafe(isDirty)
	pcall(setSettingsDirty, isDirty)
end

local function syncSettingsPanelFromDraft()
	local data = getSettingsDraft()
	if settingsWebhookToggle then
		settingsWebhookToggle.Text = "Animation: " .. ((data.animationOn == true) and "On" or "Off")
	end
	if settingsOpenInStartToggle then
		settingsOpenInStartToggle.Text = "Open in start: " .. ((data.openInStart == true) and "On" or "Off")
	end
	if settingsRememberLastTabToggle then
		settingsRememberLastTabToggle.Text = "Remember Last Tab: " .. ((data.rememberLastTab ~= false) and "On" or "Off")
	end
	if settingsStreamerModeToggle then
		settingsStreamerModeToggle.Text = "Streamer Mode: " .. ((data.streamerMode == true) and "On" or "Off")
	end
	if settingsBlurToggle then
		settingsBlurToggle.Text = "Blur Background: " .. ((data.blurBackground == true) and "On" or "Off")
	end
	if settingsWebhookBox then
		settingsWebhookBox.Visible = false
	end
	if type(refreshSettingsSwitches) == "function" then
		refreshSettingsSwitches()
	end
	local draftTheme = normalizeThemeName(data.theme)
	state.pendingThemeName = draftTheme
	refreshThemeSwatches()
	if state.settingsThemeValueLabel then
		if draftTheme ~= currentThemeName() then
			state.settingsThemeValueLabel.Text = ("Theme: %s  ->  %s (press Save settings)"):format(currentThemeName(), draftTheme)
		else
			state.settingsThemeValueLabel.Text = "Theme: " .. draftTheme
		end
	end
	if settingsStatusLabel then
		settingsStatusLabel.Text = state.settingsDirty and "Unsaved changes. Tap Save settings to apply." or "Settings loaded."
	end
end


local DEFAULT_OPEN_PANEL_KEYS = {
	RightControl = true,
	Insert = true,
	Home = true,
}

local function normalizeOpenKeyToken(value)
	if typeof(value) == "EnumItem" then
		return value.Name
	end
	if type(value) == "table" then
		value = value.Name or value.name or value.KeyCode or value.keyCode or value.Value or value.value
	end
	value = trim(value)
	if value == "" then
		return nil
	end
	value = value:gsub("^%s+", ""):gsub("%s+$", "")
	if value == "" then
		return nil
	end
	return value
end

local function normalizeOpenKeyName(name)
	name = normalizeOpenKeyToken(name)
	if not name then
		return nil
	end
	local direct = Enum.KeyCode[name]
	if direct ~= nil then
		return direct.Name
	end
	return nil
end

local function collectOpenKeyTokens(value)
	local tokens = {}
	local seen = {}

	local function push(raw)
		local token = normalizeOpenKeyToken(raw)
		if token and not seen[token] then
			seen[token] = true
			table.insert(tokens, token)
		end
	end

	if type(value) == "string" then
		for token in string.gmatch(value, "[^,;|%z\r\n]+") do
			push(token)
		end
	elseif type(value) == "table" then
		for _, entry in ipairs(value) do
			local entryType = typeof(entry)
			if entryType == "EnumItem" then
				push(entry.Name)
			elseif type(entry) == "string" then
				push(entry)
			elseif type(entry) == "number" then
				push(tostring(entry))
			elseif type(entry) == "table" then
				push(entry.Name or entry.name or entry.KeyCode or entry.keyCode or entry.Value or entry.value)
			end
		end
	end
	return tokens
end

local function keyCodeLocalizedText(keyCode)
	if not keyCode or keyCode == Enum.KeyCode.Unknown then
		return ""
	end
	local ok, text = pcall(function()
		return UserInputService:GetStringForKeyCode(keyCode, Enum.KeyCodeStringFormat.Default)
	end)
	if ok and type(text) == "string" then
		return normalizeOpenKeyToken(text) or ""
	end
	return ""
end

local function tokenMatchesKeyCode(token, keyCode)
	token = normalizeOpenKeyToken(token)
	if not token or not keyCode or keyCode == Enum.KeyCode.Unknown then
		return false
	end

	local name = keyCode.Name or ""
	if name ~= "" and token == name then
		return true
	end

	local enumName = normalizeOpenKeyName(token)
	if enumName and enumName == name then
		return true
	end

	local localized = keyCodeLocalizedText(keyCode)
	if localized ~= "" and token == localized then
		return true
	end

	if localized ~= "" and string.lower(token) == string.lower(localized) then
		return true
	end
	if name ~= "" and string.lower(token) == string.lower(name) then
		return true
	end

	return false
end

local function applyOpenKeyConfig(source)
	local raw = type(source) == "table" and (source.openKeys or source.openKey or source.openKeyNames or source.panelOpenKeys) or source
	local tokens = collectOpenKeyTokens(raw)
	local finalNames = {}
	local finalTokens = {}

	if #tokens == 0 then
		for name in pairs(DEFAULT_OPEN_PANEL_KEYS) do
			table.insert(tokens, name)
		end
		table.sort(tokens)
	end

	for _, token in ipairs(tokens) do
		local enumName = normalizeOpenKeyName(token)
		table.insert(finalTokens, token)
		if enumName then
			finalNames[enumName] = true
		end
	end

	state.openKeyTokens = finalTokens
	state.openKeyNames = finalNames
	return finalNames
end

-- Only PANEL_OPEN_KEY (top of the script) opens the panel on PC.
local function isConfiguredPanelToggleKey(input)
	if not input or input.KeyCode == Enum.KeyCode.Unknown then
		return false
	end
	return input.KeyCode == PANEL_OPEN_KEY
end


function refreshSettingsPanel(forceLoad)
	if not settingsScroll then
		return
	end
	if forceLoad == nil then
		forceLoad = not state.settingsDirty
	end
	if forceLoad then
		state.settingsLoadToken = (state.settingsLoadToken or 0) + 1
		local loadToken = state.settingsLoadToken
		task.spawn(function()
			local data = nil
			local ok = pcall(function()
				data = SettingsRF:InvokeServer("get")
			end)
			if loadToken ~= state.settingsLoadToken then
				return
			end
			if ok and type(data) == "table" then
				state.settingsData = normalizeSettingsPayload(data)
				if type(applySavedMobileButtonPosition) == "function" then applySavedMobileButtonPosition() end
				state.settingsDraft = cloneSettingsTable(state.settingsData)
				local loadedAccent = hexToColor(state.settingsData.customAccent)
				if loadedAccent then applyCustomAccent(loadedAccent) end
				if ZoneRefreshLanguage then ZoneRefreshLanguage() end
				state.settingsDirty = false
				if data.lastTab then
					state.lastTab = tostring(data.lastTab)
				end
				setThemeName(normalizeThemeName(state.settingsData.theme), false)
				applyOpenKeyConfig(data)
				syncSettingsPanelFromDraft()
				maybeNotifyUpdate()
				maybeNotifyAnnounce()
				applyThemeColors()
				refreshAnimatedBackground()
				updateBackdropBlur()
				return
			end
			if settingsStatusLabel then
				settingsStatusLabel.Text = "Failed to load settings."
			end
		end)
		if state.settingsDraft then
			syncSettingsPanelFromDraft()
		end
	else
		syncSettingsPanelFromDraft()
	end
	applyThemeColors()
	updateBackdropBlur()
end

function saveSettingsPanel()
	if settingsBusy then
		return
	end
	settingsBusy = true
	state.settingsLoadToken = (state.settingsLoadToken or 0) + 1
	if type(collectSidebarOrder) == "function" then
		state.sidebarOrder = collectSidebarOrder()
		state.sidebarOrderText = collectSidebarOrderText()
	end
	local data = getSettingsDraft()
	local animationOn = data.animationOn == true
	local openInStart = data.openInStart == true
	local rememberLastTab = data.rememberLastTab ~= false
	local lastTab = tostring(state.selectedTab or state.lastTab or "home")
	local streamerMode = data.streamerMode == true
	local blurBackground = data.blurBackground == true
	local themeName = normalizeThemeName(data.theme)
	local customAccentHex = colorToHex(hexToColor(data.customAccent) or getCustomAccent())
	local payload = {
		animationOn = animationOn,
		openInStart = openInStart,
		rememberLastTab = rememberLastTab,
		lastTab = lastTab,
		streamerMode = streamerMode,
		blurBackground = blurBackground,
		theme = themeName,
		customAccent = customAccentHex,
		globalCommands = data.globalCommands == true,
		autoTranslateChat = data.autoTranslateChat == true,
		language = normalizeLanguageCode(data.language),
		backgroundStyle = normalizeBgStyleCode(data.backgroundStyle),
		saveSidebarOrder = data.saveSidebarOrder ~= false,
		confirmActions = data.confirmActions ~= false,
		aiConfirmActions = data.aiConfirmActions ~= false,
		backgroundImage = data.backgroundImage == true,
		chatPopups = data.chatPopups ~= false,
		animatedBackground = data.animatedBackground == true,
		mobileButton = data.mobileButton ~= false,
		glowEffect = data.glowEffect == true,
		glowStrength = 40,
		sidebarOrder = (data.saveSidebarOrder ~= false) and state.sidebarOrder or nil,
		sidebarOrderText = (data.saveSidebarOrder ~= false) and (state.sidebarOrderText or collectSidebarOrderText()) or nil,
	}
	if settingsStatusLabel then
		settingsStatusLabel.Text = "Saving..."
	end
	task.spawn(function()
		local ok, res = pcall(function()
			return SettingsRF:InvokeServer("set", payload)
		end)
		settingsBusy = false
		if ok and type(res) == "table" and res.ok == true then
			state.settingsLoadToken = (state.settingsLoadToken or 0) + 1
			state.settingsData = normalizeSettingsPayload(res)
			if type(applySavedMobileButtonPosition) == "function" then applySavedMobileButtonPosition() end
			state.settingsDraft = cloneSettingsTable(state.settingsData)
			state.settingsDirty = false
			local savedAccent = hexToColor(res.customAccent)
			if savedAccent then applyCustomAccent(savedAccent) end
			if res.lastTab then
				state.lastTab = tostring(res.lastTab)
			end
			if res.theme then
				setThemeName(normalizeThemeName(res.theme), false)
			end
			if state.settingsData.animationOn == nil then
				state.settingsData.animationOn = true
			end
			applyOpenKeyConfig(state.settingsData)
			if ZoneRefreshLanguage then ZoneRefreshLanguage() end
			syncSettingsPanelFromDraft()
			if settingsStatusLabel then
				settingsStatusLabel.Text = "Saved."
			end
			applyThemeColors()
			updateBackdropBlur()
			updateMobileButtonVisibility()
			updateBackgroundImage()
			if animatedBackgroundEnabled() then
				scheduleAnimatedBackground(0)
			else
				refreshAnimatedBackground()
			end
			state.settingsReturnTab = "settings"
			state.lastTab = "settings"
			state.settingsSaveReopenToken = (tonumber(state.settingsSaveReopenToken) or 0) + 1
			local reopenToken = state.settingsSaveReopenToken
			closePanel()
			task.delay(0.75, function()
				if state.settingsSaveReopenToken ~= reopenToken or state.accessGranted ~= true then
					return
				end
				if not gui or not gui.Parent then
					return
				end
				if state.panelOpen then
					setTab("settings")
				else
					openPanel("settings")
				end
				refreshSettingsPanel(false)
				if settingsStatusLabel then
					settingsStatusLabel.Text = "Saved."
				end
			end)
			return
		elseif settingsStatusLabel then
			local errText = (type(res) == "table" and tostring(res.error or "")) or ""
			if errText ~= "" then
				settingsStatusLabel.Text = "Save failed: " .. errText
			else
				settingsStatusLabel.Text = "Save failed."
			end
		end
	end)
end

function cycleTheme()
	local active = currentThemeName()
	local index = 1
	for i, name in ipairs(THEME_ORDER) do
		if name == active then
			index = i
			break
		end
	end
	local nextIndex = index + 1
	if nextIndex > #THEME_ORDER then
		nextIndex = 1
	end
	setThemeName(THEME_ORDER[nextIndex], true)
	return THEME_ORDER[nextIndex]
end


function layoutTargetInfo()
	local notesVisible = viewNotesBtn ~= nil and viewNotesBtn.Visible == true
	local statusY = notesVisible and 182 or 146
	local infoY = statusY + 20
	if statusLabel and statusLabel.Parent then
		statusLabel.Position = UDim2.fromOffset(0, statusY)
	end
	if state.targetInfoHolder and state.targetInfoHolder.Parent then
		state.targetInfoHolder.Position = UDim2.fromOffset(0, infoY)
		state.targetInfoHolder.Size = UDim2.new(1, 0, 1, -(infoY + 12))
	end
end

function updateTargetHeader()
	if type(requestTargetPing) == "function" then task.defer(requestTargetPing) end
	local r = state.targetData
	if not r then
		selectedName.Text = "No player selected"
		selectedInfo.Text = "Select a player and press Find."
		statusLabel.Text = ""
		if viewNotesBtn then viewNotesBtn.Visible = false end
		layoutTargetInfo()
		return
	end
	selectedName.Text = visiblePlayerName(r, true) .. zoneShieldTag(r.UserId)
	selectedInfo.Text = playerRankText(r)
	if viewNotesBtn then
		viewNotesBtn.Visible = true
		viewNotesBtn.Text = ("Notes (%d)"):format(tonumber(r.NotesCount) or 0)
	end
	layoutTargetInfo()
	updateTargetPresenceDot(tonumber(r.UserId) or 0, r)
end

function updateTargetPresenceDot(userId, record)
	if not state.targetPresenceRing or not state.targetPresenceDot then
		return
	end
	userId = tonumber(userId) or 0
	if userId <= 0 then
		state.targetPresenceRing.Visible = false
		return
	end
	presenceTrack(userId)
	local stateName
	if type(record) == "table" then
		if record.Banned == true then
			stateName = "banned"
		elseif record.InCurrentServer == true then
			stateName = "here"
		elseif record.Online == true then
			stateName = "elsewhere"
		end
	end
	if not stateName then
		stateName = select(1, presenceStateFor(userId))
	end
	state.targetPresenceRing.Visible = true
	state.targetPresenceRing.BackgroundColor3 = theme().panel
	state.targetPresenceDot.BackgroundColor3 = presenceStateColor(stateName)
end

function loadAvatarThumbnail(userId)
	if not avatarImage then return end
	avatarImage.Image = ""
	if typeof(userId) ~= "number" or userId <= 0 then
		if state.targetPresenceRing then
			state.targetPresenceRing.Visible = false
		end
		return
	end
	task.spawn(function()
		local ok, thumb = pcall(function()
			return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and thumb and avatarImage then
			avatarImage.Image = thumb
		end
	end)
end

function openInventoryLoadingTimeout(token, targetLabel)
	task.delay(12, function()
		if state.inventoryLoadingToken ~= token then
			return
		end
		state.inventoryLoadingToken = nil
		openCodeModal(
			"Inventory",
			("Loading inventory timed out for %s.\\n\\nThe target may be offline, in another server, or the server did not answer."):format(tostring(targetLabel or "that player")),
			function()
				closeCodeModal()
			end,
			"Close"
		)
	end)
end

function rebuildNotesModalList()
	if not notesModalListHolder then return end
	local th = theme()
	clearChildrenExcept(notesModalListHolder, {})
	local record = state.targetData
	local notes = record and record.Notes or {}

	if #notes == 0 then
		notesModalEmptyLabel.Visible = true
		return
	end
	notesModalEmptyLabel.Visible = false

	for _, note in ipairs(notes) do
		local text = tostring(note.note or note.Note or "")
		local row = make("Frame", {
			Size = UDim2.new(1, -4, 0, 60),
			BackgroundColor3 = th.card,
			BorderSizePixel = 0,
			Parent = notesModalListHolder,
		})
		corner(row, 12)
		stroke(row, 0.92)
		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 8),
			Size = UDim2.new(1, -24, 0, 30),
			Text = text,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = th.text,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Parent = row,
		})
		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 40),
			Size = UDim2.new(1, -24, 0, 16),
			Text = ("by UserId %s • %s"):format(tostring(note.moderatorUserId or "?"), os.date("%Y-%m-%d %H:%M", tonumber(note.timestamp or os.time()))),
			Font = Enum.Font.GothamSemibold,
			TextSize = 11,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
	end
end

function openNotesModal()
	if not state.targetData then
		return
	end
	state.notesModalOpen = true
	notesModalTitle.Text = ("Notes — %s"):format(visiblePlayerName(state.targetData, true))
	rebuildNotesModalList()
	notesModalOverlay.Visible = true
	notesModalFrame.Visible = true
	tween(notesModalFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 })
end

function closeNotesModal()
	state.notesModalOpen = false
	local fade = tween(notesModalFrame, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 1 })
	fade.Completed:Once(function()
		notesModalOverlay.Visible = false
		notesModalFrame.Visible = false
	end)
end

function updateModerationFilterSummary()
	if not moderationFilterSummaryLabel then
		return
	end
	local filters = state.moderationFilters or {}
	local parts = {}
	if trim(filters.moderator) ~= "" then table.insert(parts, "Mod: " .. trim(filters.moderator)) end
	if trim(filters.target) ~= "" then table.insert(parts, "Target: " .. trim(filters.target)) end
	if trim(filters.action) ~= "" then table.insert(parts, "Action: " .. trim(filters.action)) end
	if trim(filters.reason) ~= "" then table.insert(parts, "Reason: " .. trim(filters.reason)) end
	if #parts == 0 then
		moderationFilterSummaryLabel.Text = "No filter active."
	else
		moderationFilterSummaryLabel.Text = table.concat(parts, " • ")
	end
end

local function syncModerationFilterBoxes()
	if moderationFilterModeratorBox then moderationFilterModeratorBox.Text = tostring((state.moderationFilters or {}).moderator or "") end
	if moderationFilterTargetBox then moderationFilterTargetBox.Text = tostring((state.moderationFilters or {}).target or "") end
	if moderationFilterActionBox then moderationFilterActionBox.Text = tostring((state.moderationFilters or {}).action or "") end
	if moderationFilterReasonBox then moderationFilterReasonBox.Text = tostring((state.moderationFilters or {}).reason or "") end
	updateModerationFilterSummary()
end

function openModerationFilterModal()
	state.moderationFilterOpen = true
	syncModerationFilterBoxes()
	if moderationFilterOverlay then moderationFilterOverlay.Visible = true end
	if moderationFilterFrame then
		moderationFilterFrame.Visible = true
		tween(moderationFilterFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 })
	end
end

function closeModerationFilterModal()
	state.moderationFilterOpen = false
	if not moderationFilterFrame or not moderationFilterOverlay then
		return
	end
	local fade = tween(moderationFilterFrame, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 1 })
	fade.Completed:Once(function()
		moderationFilterOverlay.Visible = false
		moderationFilterFrame.Visible = false
	end)
end

function applyModerationFiltersFromBoxes()
	state.moderationFilters = {
		moderator = trim(moderationFilterModeratorBox and moderationFilterModeratorBox.Text or ""),
		target = trim(moderationFilterTargetBox and moderationFilterTargetBox.Text or ""),
		action = trim(moderationFilterActionBox and moderationFilterActionBox.Text or ""),
		reason = trim(moderationFilterReasonBox and moderationFilterReasonBox.Text or ""),
	}
	updateModerationFilterSummary()
	refreshModerationDisplay()
	closeModerationFilterModal()
end

function clearModerationFilters()
	state.moderationFilters = {
		moderator = "",
		target = "",
		action = "",
		reason = "",
	}
	syncModerationFilterBoxes()
	refreshModerationDisplay()
end

function updateAdminsList()
	if not adminsScroll or not adminsListHolder then
		return
	end

	local th = theme()
	clearChildrenExcept(adminsListHolder, {})

	local list = state.adminsData or {}
	if #list == 0 then
		adminsEmptyLabel.Visible = true
		adminsEmptyLabel.Text = "No admins loaded."
		if adminsCountLabel then
			adminsCountLabel.Text = "Admins: 0"
		end
		return
	end
	adminsEmptyLabel.Visible = false
	if adminsCountLabel then
		adminsCountLabel.Text = ("Admins: %d"):format(#list)
	end

	for _, entry in ipairs(list) do
		local name = tostring(entry.Name or "Unknown")
		local rank = tostring(entry.Rank or "Unknown")
		local protected = entry.Protected == true
		local autoOwner = entry.AutoOwner == true
		local ownerSource = tostring(entry.OwnerSource or "")
		local rankSuffix = protected and " • Protected" or ""
		if autoOwner then
			if ownerSource ~= "" then
				rankSuffix = rankSuffix .. " • " .. ownerSource
			else
				rankSuffix = rankSuffix .. " • Auto owner"
			end
		end

		local row = make("Frame", {
			Size = UDim2.new(1, -4, 0, 88),
			BackgroundColor3 = th.card,
			BorderSizePixel = 0,
			Parent = adminsListHolder,
		})
		corner(row, 12)
		stroke(row, 0.92)

		local hereNow = entry.HereNow == true
		local elsewhere = entry.Online == true and not hereNow
		local stateName = "offline"
		if entry.Banned == true then
			stateName = "banned"
		elseif hereNow then
			stateName = "here"
		elseif elsewhere then
			stateName = "elsewhere"
		end
		local dotColor = presenceStateColor(stateName)
		local statusText = presenceStateText(stateName)

		local avatarHolder = make("Frame", {
			Name = "AvatarHolder",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0.5, 0),
			Size = UDim2.fromOffset(56, 56),
			BackgroundTransparency = 1,
			Parent = row,
		})

		local avatar = make("ImageLabel", {
			Name = "Avatar",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = th.panel2,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(tonumber(entry.UserId) or 0),
			ScaleType = Enum.ScaleType.Fit,
			Parent = avatarHolder,
		})
		corner(avatar, 28)
		stroke(avatar, 0.88)

		local dotRing = make("Frame", {
			Name = "PresenceRing",
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, 1, 1, 1),
			Size = UDim2.fromOffset(18, 18),
			BackgroundColor3 = th.card,
			BorderSizePixel = 0,
			ZIndex = 3,
			Parent = avatarHolder,
		})
		corner(dotRing, 9)

		local dot = make("Frame", {
			Name = "PresenceDot",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = dotColor,
			BorderSizePixel = 0,
			ZIndex = 4,
			Parent = dotRing,
		})
		corner(dot, 6)

		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(80, 8),
			Size = UDim2.new(1, -92, 0, 18),
			Text = ("%s (@%s)"):format(streamerShortText(entry.DisplayName or name), streamerShortText(name)),
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextColor3 = th.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row,
		})
		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(80, 28),
			Size = UDim2.new(1, -92, 0, 18),
			Text = ("Rank: %s • UserId: %s%s"):format(visibleRankText(rank), visibleUserId(entry.UserId), isStreamerModeEnabled() and "" or rankSuffix),
			Font = Enum.Font.GothamSemibold,
			TextSize = 11,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = row,
		})

		make("TextLabel", {
			Name = "PresenceText",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(80, 46),
			Size = UDim2.new(1, -270, 0, 18),
			Text = statusText,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = dotColor,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})

		if elsewhere and stateName ~= "banned" and tostring(entry.JobId or "") ~= "" then
			local joinBtn = make("TextButton", {
				Name = "JoinBtn",
				Position = UDim2.new(1, -176, 1, -30),
				Size = UDim2.fromOffset(80, 22),
				BackgroundColor3 = th.accent,
				Text = "Join",
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = th.onAccent,
				AutoButtonColor = false,
				Parent = row,
			})
			corner(joinBtn, 8)
			joinBtn.MouseButton1Click:Connect(function()
				openConfirmModal(
					"Join this server?",
					("You will leave the current server and join the one %s is playing on."):format(tostring(entry.DisplayName or name)),
					function()
						local ok = pcall(function()
							TeleportService:TeleportToPlaceInstance(tonumber(entry.PlaceId) or game.PlaceId, tostring(entry.JobId), localPlayer)
						end)
						if not ok and type(notify) == "function" then
							notify("Could not join that server.", false, 4)
						end
					end,
					"Join"
				)
			end)
		end

		if not protected then
			local removeBtn = make("TextButton", {
				Position = UDim2.new(1, -90, 1, -30),
				Size = UDim2.fromOffset(80, 22),
				BackgroundColor3 = th.danger,
				Text = "Remove",
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				AutoButtonColor = false,
				Parent = row,
			})
			corner(removeBtn, 8)
			removeBtn.MouseButton1Click:Connect(function()
				RemoteEvent:FireServer("RemoveRank", { UserId = entry.UserId })
				task.wait(0.3)
				refreshAdmins()
			end)
		end
	end
end

-- Ban type label: Roblox ban (permanent, BanAsync) or timed panel ban.
local function banDurationText(entry)
	local expiresAt = tonumber(entry and entry.ExpiresAt) or 0
	if expiresAt > 0 then
		return ("Timed (until %s)"):format(os.date("%Y-%m-%d %H:%M", expiresAt))
	end
	if entry and entry.RobloxBan == true then
		return "Roblox (Permanent)"
	end
	return "Permanent"
end

function filterBanEntries()
	local entries = state.banData or {}
	local query = trim(state.banSearchQuery or "")
	if query == "" then
		return entries
	end
	local q = string.lower(query)
	local filtered = {}
	for _, entry in ipairs(entries) do
		local fields = {
			entry.DisplayName,
			entry.Name,
			entry.UserId,
			entry.Reason,
			entry.ModeratorName,
			entry.ModeratorUserId,
			banDurationText(entry),
		}
		local match = false
		for _, field in ipairs(fields) do
			if string.lower(tostring(field or "")):find(q, 1, true) then
				match = true
				break
			end
		end
		if match then
			table.insert(filtered, entry)
		end
	end
	return filtered
end

function ensureBanRow(index)
	banRows = banRows or {}
	local row = banRows[index]
	if row and row.frame and row.frame.Parent then
		return row
	end
	local th = theme()
	local frame = make("Frame", {
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -4, 0, 86),
		Parent = banListHolder,
	})
	corner(frame, 12)
	stroke(frame, 0.92)
	local avatarHolder = make("Frame", {
		Name = "AvatarHolder",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(56, 56),
		BackgroundTransparency = 1,
		Parent = frame,
	})

	local avatar = make("ImageLabel", {
		Name = "Avatar",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = th.panel2,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Image = "",
		ScaleType = Enum.ScaleType.Fit,
		Parent = avatarHolder,
	})
	corner(avatar, 28)
	stroke(avatar, 0.88)

	local dotRing = make("Frame", {
		Name = "PresenceRing",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 1, 1, 1),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = th.card,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = avatarHolder,
	})
	corner(dotRing, 9)

	local dot = make("Frame", {
		Name = "PresenceDot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = th.danger,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = dotRing,
	})
	corner(dot, 6)

	local title = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(80, 8),
		Size = UDim2.new(1, -188, 0, 18),
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = "",
		Parent = frame,
	})
	local info = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(80, 28),
		Size = UDim2.new(1, -92, 0, 38),
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextWrapped = true,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = "",
		Parent = frame,
	})
	local unbanBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -12, 1, -12),
		Size = UDim2.fromOffset(90, 26),
		BackgroundColor3 = th.success,
		Text = "Unban",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = theme().onAccent,
		AutoButtonColor = false,
		Parent = frame,
	})
	corner(unbanBtn, 8)
	stroke(unbanBtn, 0.92)
	row = { frame = frame, title = title, info = info, unbanBtn = unbanBtn, avatar = avatar, dotRing = dotRing, dot = dot }
	banRows[index] = row
	return row
end

function updateBanRows(entries)
	entries = type(entries) == "table" and entries or {}
	banRows = {}
	clearChildrenExcept(banListHolder, {})
	if banCountLabel then
		banCountLabel.Text = (#entries == 1) and "1 banned player" or ("%d banned players"):format(#entries)
	end
	if banEmptyLabel then
		banEmptyLabel.Visible = (#entries == 0)
		banEmptyLabel.Text = (#entries == 0) and "No banned players found." or ""
	end
	for i, entry in ipairs(entries) do
		local entryUserId = tonumber(entry.UserId) or 0
		local entryName = tostring(entry.Name or entry.DisplayName or "Unknown")
		local entryDisplayName = tostring(entry.DisplayName or entry.Name or "Unknown")
		local row = ensureBanRow(i)
		if row.avatar then
			row.avatar.Image = entryUserId > 0
				and ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(entryUserId)
				or ""
		end
		if row.dot then
			local banActive = entry.Active ~= false
			row.dot.BackgroundColor3 = banActive and theme().danger or presenceStateColor(select(1, presenceStateFor(entryUserId)))
		end
		if row.dotRing then
			row.dotRing.BackgroundColor3 = theme().card
		end
		row.title.Text = ("%s (@%s)"):format(streamerShortText(entryDisplayName), streamerShortText(entryName))
		row.info.Text = ("UserId: %s\nReason: %s\nModerator: %s (%s)\nType: %s"):format(
			visibleUserId(entryUserId > 0 and entryUserId or entry.UserId),
			tostring(entry.Reason or "N/A"),
			streamerShortText(entry.ModeratorName or "N/A"),
			visibleUserId(entry.ModeratorUserId),
			banDurationText(entry)
		)
		row.unbanBtn.MouseButton1Click:Connect(function()
			if entryUserId <= 0 then
				setStatus("Invalid ban entry.", false)
				return
			end
			row.unbanBtn.Active = false
			row.unbanBtn.AutoButtonColor = false
			row.unbanBtn.Text = "Unbanning..."
			RemoteEvent:FireServer("Unban", entryUserId)
		end)
	end
end

function refreshBanPanel()
	if not banScroll or not banListHolder then
		return
	end
	local ok, res = pcall(function()
		return BanListRF:InvokeServer()
	end)
	if ok and type(res) == "table" then
		state.banData = res
	else
		state.banData = {}
	end
	updateBanRows(filterBanEntries())
end

state.refreshBanPanel = refreshBanPanel

function refreshAdmins()
	if not canSeeAdminsTab() then
		state.adminsData = {}
		updateAdminsList()
		return
	end
	local ok, res = pcall(function()
		return AdminListRF:InvokeServer()
	end)
	if ok and type(res) == "table" then
		state.adminsData = res
	else
		state.adminsData = {}
	end
	updateAdminsList()
end


local function getUserAvatarUrl(userId)
	userId = tonumber(userId) or 0
	if userId <= 0 then
		return "rbxassetid://0"
	end
	state.avatarCache = state.avatarCache or {}
	local cacheKey = "credits_" .. tostring(userId)
	if state.avatarCache[cacheKey] then
		return state.avatarCache[cacheKey]
	end
	local url = "rbxassetid://0"
	local ok, result = pcall(function()
		return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)
	if ok and type(result) == "string" and result ~= "" then
		url = result
	end
	state.avatarCache[cacheKey] = url
	return url
end

local function getUsernameFromUserId(userId)
	userId = tonumber(userId) or 0
	if userId <= 0 then
		return ("UserId %d"):format(userId)
	end
	state.nameCache = state.nameCache or {}
	local key = tostring(userId)
	if state.nameCache[key] then
		return state.nameCache[key]
	end
	local fallback = ("UserId %d"):format(userId)
	local ok, result = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)
	if ok and type(result) == "string" and result ~= "" then
		fallback = result
	end
	state.nameCache[key] = fallback
	return fallback
end

local function createCreditPersonCard(parent, roleLabel, userId, accentLabel, order, displayName)
	local th = theme()
	local name = getUsernameFromUserId(userId)
	local display = tostring(displayName or "")
	local titleName = display ~= "" and display or name
	local card = make("Frame", {
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 82),
		LayoutOrder = tonumber(order) or 0,
		Parent = parent,
	})
	corner(card, 16)
	stroke(card, 0.9)
	padding(card, 10, 10, 10, 10)

	local avatar = make("ImageLabel", {
		BackgroundColor3 = th.panel2,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(60, 60),
		Image = getUserAvatarUrl(userId),
		ScaleType = Enum.ScaleType.Crop,
		Parent = card,
	})
	corner(avatar, 30)
	stroke(avatar, 0.82)

	local textHolder = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(76, 8),
		Size = UDim2.new(1, -86, 1, -16),
		Parent = card,
	})

	make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Text = titleName,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = textHolder,
	})

	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 20),
		Size = UDim2.new(1, 0, 0, 18),
		Text = display ~= "" and display ~= name and ("@%s • UserId: %d"):format(name, tonumber(userId) or 0) or ("UserId: %d"):format(tonumber(userId) or 0),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = textHolder,
	})

	local accentText = tostring(accentLabel or "")
	local accent = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 42),
		Size = UDim2.new(1, 0, 0, 20),
		Text = accentText,
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = textHolder,
	})
	accent.Visible = accentText ~= ""

	return card
end

local function createCreditSectionTitle(parent, titleText, subtitleText, order)
	local th = theme()
	local holder = make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 44),
		LayoutOrder = tonumber(order) or 0,
		Parent = parent,
	})
	make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Text = titleText,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.new(1, 0, 0, 18),
		Text = subtitleText or "",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})
	return holder
end

local function getCreditGroupImage(payload)
	payload = type(payload) == "table" and payload or {}
	local explicit = tostring(payload.groupImage or "")
	if explicit ~= "" then
		return explicit
	end
	local groupId = tonumber(payload.groupId or 0) or 0
	if groupId > 0 then
		return ("rbxthumb://type=GroupIcon&id=%d&w=150&h=150"):format(groupId)
	end
	local tabIcon = tostring(payload.tabIcon or 76311199408449)
	if tabIcon ~= "" then
		return "rbxassetid://" .. tabIcon
	end
	return "rbxassetid://0"
end

local function promptJoinCreditGroup(payload)
	payload = type(payload) == "table" and payload or {}
	local groupId = tonumber(payload.groupId or 0) or 0
	local groupName = tostring(payload.groupName or "this group")
	if groupId <= 0 then
		setStatus("Group ID unavailable.", false)
		return
	end

	if confirmYes then
		confirmYes.Text = "Join"
	end
	openConfirmModal("Join To Group", ("Open the Roblox join prompt for %s?"):format(groupName), function()
		closeConfirmModal()
		local ok, result = pcall(function()
			return GroupService:PromptJoinAsync(groupId)
		end)
		if ok then
			if result == Enum.GroupMembershipStatus.Joined then
				setStatus(("Joined %s."):format(groupName), true)
			elseif result == Enum.GroupMembershipStatus.JoinRequestPending then
				setStatus(("Join request pending for %s."):format(groupName), true)
			else
				setStatus(("Join prompt closed for %s."):format(groupName), true)
			end
		else
			warn("[Zone Panel] Group join prompt failed:", result)
			setStatus("Could not open the group join prompt.", false)
		end
	end)
end

function refreshCreditsPanel()
	if not creditsScroll or not creditsListHolder then
		return
	end

	local th = theme()
	local keep = {}
	local layout = creditsListHolder:FindFirstChildOfClass("UIListLayout")
	if layout then
		keep[layout] = true
	end
	clearChildrenExcept(creditsListHolder, keep)

	local payload = nil
	local ok, res = pcall(function()
		return CreditsRF:InvokeServer()
	end)
	if ok and type(res) == "table" then
		payload = res
	else
		payload = {
			ok = true,
			groupId = 1019776729,
			groupName = "FPS Zone",
			groupImage = "rbxthumb://type=GroupIcon&id=1019776729&w=150&h=150",
			tabIcon = 76311199408449,
			creator = { userId = 3964875415, role = "Creator" },
			helpers = {
				{ userId = 6014711675, role = "Helper" },
				{ userId = 5412427056, role = "Helper" },
				{ userId = 4710535322, role = "Helper" },
				{ userId = 1928091473, role = "Helper" },
				{ userId = 1962216904, role = "Helper" },
				{ userId = 7864126209, role = "Helper" },
			},
			followText = "Follow us for more panels and updates!",
		}
	end

	state.creditsData = payload

	local header = make("Frame", {
		BackgroundColor3 = th.panel,
		BackgroundTransparency = 0.14,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 112),
		LayoutOrder = 1,
		Parent = creditsListHolder,
	})
	corner(header, 18)
	stroke(header, 0.9)
	padding(header, 12, 12, 12, 12)

	local icon = make("ImageLabel", {
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(68, 68),
		Image = getCreditGroupImage(payload),
		ScaleType = Enum.ScaleType.Fit,
		Parent = header,
	})
	corner(icon, 16)
	stroke(icon, 0.84)

	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(82, 6),
		Size = UDim2.new(1, -230, 0, 26),
		Text = "Info",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(82, 32),
		Size = UDim2.new(1, -230, 0, 20),
		Text = "Creator, helpers, and group details.",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(82, 50),
		Size = UDim2.new(1, -230, 0, 18),
		Text = ("Group: %s"):format(tostring(payload.groupName or "FPS Zone")),
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(82, 68),
		Size = UDim2.new(1, -230, 0, 16),
		Text = ("Group ID: %s"):format(tostring(payload.groupId or 1019776729)),
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	local joinBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0, 26),
		Size = UDim2.fromOffset(124, 32),
		BackgroundColor3 = th.accent,
		BackgroundTransparency = 0.05,
		Text = "Join To Group",
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().onAccent,
		AutoButtonColor = false,
		Parent = header,
	})
	corner(joinBtn, 10)
	stroke(joinBtn, 0.88)
	joinBtn.MouseButton1Click:Connect(function()
		promptJoinCreditGroup(payload)
	end)

	local section = createCreditSectionTitle(creditsListHolder, "Creator", "The panel's primary creator.", 2)
	createCreditPersonCard(creditsListHolder, "Creator", (payload.creator and payload.creator.userId) or 3964875415, tostring(payload.groupName or "FPS Zone"), 3, (payload.creator and payload.creator.displayName) or nil)
	local order = 4

	local helpers = type(payload.helpers) == "table" and payload.helpers or {
		{ userId = 6014711675, role = "Helper" },
		{ userId = 5412427056, role = "Helper" },
		{ userId = 4710535322, role = "Helper" },
		{ userId = 1928091473, role = "Helper" },
		{ userId = 1962216904, role = "Helper" },
		{ userId = 7864126209, role = "Helper" },
	}
	if #helpers > 0 then
		createCreditSectionTitle(creditsListHolder, "Helpers", "People who help run the panel.", order)
		order = order + 1
		for _, helper in ipairs(helpers) do
			local helperUserId = tonumber(helper.userId or helper.UserId) or 0
			if helperUserId > 0 then
				createCreditPersonCard(creditsListHolder, "Helper", helperUserId, nil, order, helper.displayName or nil)
				order = order + 1
			end
		end
	end

	local followCard = make("Frame", {
		LayoutOrder = order,
		Size = UDim2.new(1, 0, 0, 68),
		BackgroundColor3 = th.panel,
		BackgroundTransparency = 0.14,
		BorderSizePixel = 0,
		Parent = creditsListHolder,
	})
	corner(followCard, 14)
	stroke(followCard, 0.9)
	padding(followCard, 14, 12, 14, 12)

	make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Text = tostring(payload.followText or "Follow us for more panels and updates!"),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = followCard,
	})
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 22),
		Size = UDim2.new(1, 0, 0, 18),
		Text = ("Join the %s group to get every new release first."):format(tostring(payload.groupName or "FPS Zone")),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = followCard,
	})

end


function addAdminFromInputs()
	local query = trim(adminAddBox and adminAddBox.Text or "")
	local rank = trim(adminAddRankBox and adminAddRankBox.Text or "")
	if rank == "" then rank = "Moderator" end
	if not RANK_ORDER[rank] and not zoneRoleDef(rank) then
		setStatus("Invalid rank. Use Helper / Moderator / Admin / Owner or a custom rank.", false)
		return
	end
	if query == "" then
		setStatus("Enter a UserId or username to add.", false)
		return
	end

	local resolved = nil
	local asNumber = tonumber(query)
	if asNumber then
		resolved = { UserId = asNumber }
	else
		local ok, record = pcall(function()
			return ResolveRF:InvokeServer(query)
		end)
		if ok and type(record) == "table" and record.ok then
			resolved = { UserId = record.UserId }
		end
	end

	if not resolved then
		setStatus("Could not resolve that player.", false)
		notify("Could not resolve that player.", false)
		return
	end

	RemoteEvent:FireServer("SetRank", { UserId = resolved.UserId, Rank = rank })
	setStatus(("Set rank %s for UserId %s"):format(rank, tostring(resolved.UserId)), true)
	adminAddBox.Text = ""
	task.wait(0.3)
	refreshAdmins()
end

function showModal(frame, overlayFrame)
	overlayFrame.Visible = true
	frame.Visible = true
	tween(frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 })
end

function hideModal(frame, overlayFrame)
	local fade = tween(frame, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 1 })
	fade.Completed:Once(function()
		overlayFrame.Visible = false
		frame.Visible = false
	end)
end

local codeModalCallback = nil
function openCodeModal(title, text, onConfirm, confirmText)
	codeTitle.Text = tostring(title or "Code")
	codeText.Text = tostring(text or "")
	if codeConfirmBtn then
		codeConfirmBtn.Text = tostring(confirmText or "Confirm")
	end
	codeModalCallback = onConfirm
	showModal(codeFrame, codeOverlay)
end

function openConfirmModal(title, body, onConfirm, confirmText)
	confirmTitle.Text = tostring(title or "Confirm action")
	confirmBody.Text = tostring(body or "Are you sure?")
	if confirmYes and confirmText ~= nil then
		confirmYes.Text = tostring(confirmText)
	end
	state.confirmCallback = onConfirm
	showModal(confirmFrame, confirmOverlay)
end

function closeCodeModal()
	hideModal(codeFrame, codeOverlay)
	if codeConfirmBtn then
		codeConfirmBtn.Text = "Confirm"
	end
	codeModalCallback = nil
end

function closeConfirmModal()
	hideModal(confirmFrame, confirmOverlay)
	if confirmYes then
		confirmYes.Text = "Yes, continue"
	end
	state.confirmCallback = nil
end

ZONE_GLOW = { fade = 0.14 }

function glowStrength()
	return 40
end



function glowValues()
	local t = glowStrength() / 100
	return {
		hoverBlur = math.floor(8 + (24 - 8) * t),
		hoverSpread = math.floor(0 + 3 * t),
		hoverT = 0.92 - (0.92 - 0.22) * t,
		activeBlur = math.floor(6 + (18 - 6) * t),
		activeSpread = 0,
		activeT = 0.96 - (0.96 - 0.45) * t,
	}
end

function glowEnabled()
	if state and type(state.settingsDraft) == "table" and state.settingsDraft.glowEffect ~= nil then
		return state.settingsDraft.glowEffect == true
	end
	if state and type(state.settingsData) == "table" then
		return state.settingsData.glowEffect == true
	end
	return false
end

ZONE_BTN_CORNER = UDim.new(1, 0)

function cornerSkip(btn)
	if sidebar and btn:IsDescendantOf(sidebar) then
		return true
	end
	if actionsScroll and btn:IsDescendantOf(actionsScroll) then
		return true
	end
	if left and btn:IsDescendantOf(left) then
		return true
	end
	if string.sub(tostring(btn.Name or ""), 1, 6) == "Theme_" then
		return true
	end
	if string.sub(tostring(btn.Name or ""), 1, 11) == "SetupTheme_" then
		return true
	end
	if state.settingsThemeGrid and btn:IsDescendantOf(state.settingsThemeGrid) then
		return true
	end
	return false
end

function applyButtonCorner(btn)
	if not btn or not btn.Parent or glowSkip(btn) or cornerSkip(btn) then
		return
	end
	local c = btn:FindFirstChildOfClass("UICorner")
	if not c then
		c = Instance.new("UICorner")
		c.Parent = btn
	end
	c.CornerRadius = ZONE_BTN_CORNER
end

ZONE_GLOW_SKIP = {
	ColorWheel = true,
	ValueSlider = true,
	WheelCursor = true,
	DragHandle = true,
	ResizeGrip = true,
	GlowShield = true,
	Backdrop = true,
	ChatPipPlaceholder = true,
}

ZONE_GLOW_FORCE = {
	EventStartBtn = true,
	EventStopBtn = true,
}

function glowSkip(btn)
	local name = tostring(btn.Name or "")
	if ZONE_GLOW_SKIP[name] or string.find(name, "Shield") or string.find(name, "Overlay") then
		return true
	end
	if btn.BackgroundTransparency >= 0.9 then
		return true
	end
	if ZONE_GLOW_FORCE[name] then
		return false
	end
	local sz = btn.Size
	if sz.X.Scale >= 0.95 and sz.Y.Scale >= 0.95 then
		return true
	end
	return false
end

function ensureGlow(btn)
	local existing = btn:FindFirstChild("ZoneGlow")
	if existing then
		return existing
	end
	local ok, shadow = pcall(function()
		return Instance.new("UIShadow")
	end)
	if not ok or not shadow then
		return nil
	end
	pcall(function()
		shadow.Name = "ZoneGlow"
		shadow.Offset = UDim2.fromOffset(0, 0)
		shadow.Transparency = 1
		shadow.Parent = btn
	end)
	if shadow.Parent ~= btn then
		shadow:Destroy()
		return nil
	end
	return shadow
end

function glowColor()
	local th = theme()
	return th.accent or th.neon or Color3.fromRGB(255, 255, 255)
end

function glowSet(btn, mode)
	if not btn or not btn.Parent then
		return
	end
	local glow = btn:FindFirstChild("ZoneGlow")
	if mode == "off" or not glowEnabled() then
		if glow then
			tween(glow, TweenInfo.new(ZONE_GLOW.fade), { Transparency = 1 })
		end
		return
	end
	glow = glow or ensureGlow(btn)
	if not glow then
		return
	end
	local g = glowValues()
	glow.Color = glowColor()
	if mode == "hover" then
		glow.BlurRadius = UDim.new(0, g.hoverBlur)
		glow.Spread = UDim2.fromOffset(g.hoverSpread, g.hoverSpread)
		tween(glow, TweenInfo.new(ZONE_GLOW.fade), { Transparency = g.hoverT })
	else
		glow.BlurRadius = UDim.new(0, g.activeBlur)
		glow.Spread = UDim2.fromOffset(g.activeSpread, g.activeSpread)
		tween(glow, TweenInfo.new(ZONE_GLOW.fade), { Transparency = g.activeT })
	end
end

function glowRest(btn)
	if btn:GetAttribute("ZoneGlowHover") == true then
		glowSet(btn, "hover")
	elseif btn:GetAttribute("ZoneGlowActive") == true then
		glowSet(btn, "active")
	else
		glowSet(btn, "off")
	end
end

function glowMarkActive(btn, active)
	if not btn then
		return
	end
	btn:SetAttribute("ZoneGlowActive", active == true)
	if btn:GetAttribute("ZoneGlowHover") == true then
		return
	end
	glowRest(btn)
end

function pressScale(btn)
	local existing = btn:FindFirstChild("ZonePress")
	if existing and existing:IsA("UIScale") then
		return existing
	end
	local scale = Instance.new("UIScale")
	scale.Name = "ZonePress"
	scale.Scale = 1
	scale.Parent = btn
	return scale
end

ZONE_PRESS_HOME = setmetatable({}, { __mode = "k" })
ZONE_PRESS_BASE = setmetatable({}, { __mode = "k" })

function pressBasePosition(btn)
	local saved = ZONE_PRESS_BASE[btn]
	if saved == nil then
		saved = btn.Position
		ZONE_PRESS_BASE[btn] = saved
	end
	return saved
end
ZONE_PRESS_LOOP = setmetatable({}, { __mode = "k" })

function pressStopCentered(btn)
	local conn = ZONE_PRESS_LOOP[btn]
	if conn then
		ZONE_PRESS_LOOP[btn] = nil
		conn:Disconnect()
	end
	local home = ZONE_PRESS_HOME[btn]
	if home then
		ZONE_PRESS_HOME[btn] = nil
		if btn.Parent then
			btn.AnchorPoint = home.anchor
			if home.position then
				TweenService:Create(btn, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = ZONE_PRESS_BASE[btn] or home.position }):Play()
			end
		end
	end
end

function pressLayoutOf(btn)
	local parent = btn.Parent
	if not parent then
		return nil
	end
	return parent:FindFirstChildOfClass("UIListLayout") or parent:FindFirstChildOfClass("UIGridLayout")
end

function pressCenterList(btn)
	local parent = btn.Parent
	if not parent or parent:GetAttribute("ZonePressCentered") == true then
		return
	end
	local layout = parent:FindFirstChildOfClass("UIListLayout")
	if not layout then
		return
	end
	if layout.FillDirection == Enum.FillDirection.Vertical then
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("GuiObject") and child.Size.X.Scale < 0.99 then
				return
			end
		end
		parent:SetAttribute("ZonePressCentered", true)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		return
	end
	parent:SetAttribute("ZonePressCentered", true)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
end

function pressKeepCentered(btn, target)
	local home = ZONE_PRESS_HOME[btn]
	if not home then
		return
	end
	if pressLayoutOf(btn) then
		pressCenterList(btn)
		return
	end
	local size = btn.AbsoluteSize
	if size.X <= 1 or size.Y <= 1 then
		return
	end
	local shrink = 1 - target
	local base = pressBasePosition(btn)
	home.position = base
	local dx = size.X * shrink * (0.5 - btn.AnchorPoint.X)
	local dy = size.Y * shrink * (0.5 - btn.AnchorPoint.Y)
	TweenService:Create(btn, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(base.X.Scale, base.X.Offset + dx, base.Y.Scale, base.Y.Offset + dy),
	}):Play()
end

function pressTween(btn, target)
	local scale = pressScale(btn)
	if not scale then
		return
	end
	local info = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	if target < 1 then
		if ZONE_PRESS_HOME[btn] == nil then
			ZONE_PRESS_HOME[btn] = {
				anchor = btn.AnchorPoint,
				centre = btn.AbsolutePosition + btn.AbsoluteSize * 0.5,
			}
		end
		TweenService:Create(scale, info, { Scale = target }):Play()
		pressKeepCentered(btn, target)
	else
		local back = TweenService:Create(scale, info, { Scale = 1 })
		back.Completed:Connect(function()
			pressStopCentered(btn)
		end)
		back:Play()
	end
end

ZONE_PRESS_GUIS = {
	AdminPanelUI = true,
	AdminPanelAnnounceGui = true,
}

function pressGuiAllowed(inst)
	local root = inst:FindFirstAncestorWhichIsA("ScreenGui")
	return root ~= nil and ZONE_PRESS_GUIS[root.Name] == true
end

function pressHookAll()
	for _, screen in ipairs(playerGui:GetChildren()) do
		if screen:IsA("ScreenGui") and ZONE_PRESS_GUIS[screen.Name] then
			for _, inst in ipairs(screen:GetDescendants()) do
				if inst:IsA("TextButton") or inst:IsA("ImageButton") then
					pressHook(inst)
				end
			end
		end
	end
end

function pressWatch()
	if state.pressWatch == true then
		return
	end
	state.pressWatch = true
	playerGui.DescendantAdded:Connect(function(inst)
		if inst:IsA("TextButton") or inst:IsA("ImageButton") then
			task.defer(function()
				if inst.Parent and pressGuiAllowed(inst) then
					pressHook(inst)
				end
			end)
		end
	end)
	pressHookAll()
end

function pressHook(btn)
	if not btn or btn:GetAttribute("ZonePressHooked") == true then
		return
	end
	local name = tostring(btn.Name or "")
	if name == "MobileOpenButton" or btn:GetAttribute("ZonePressIgnore") == true then
		return
	end
	if ZONE_GLOW_SKIP[name] or string.find(name, "Shield") or string.find(name, "Overlay") then
		return
	end
	if string.sub(name, 1, 10) == "SwitchRow_" then
		return
	end
	btn:SetAttribute("ZonePressHooked", true)
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pressTween(btn, 0.98)
		end
	end)
	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pressTween(btn, 1)
		end
	end)
	btn.MouseLeave:Connect(function()
		pressTween(btn, 1)
	end)
end

function glowHook(btn)
	if not btn then
		return
	end
	pressHook(btn)
	if btn:GetAttribute("ZoneGlowHooked") == true or glowSkip(btn) then
		return
	end
	btn:SetAttribute("ZoneGlowHooked", true)
	btn.MouseEnter:Connect(function()
		btn:SetAttribute("ZoneGlowHover", true)
		glowSet(btn, "hover")
	end)
	btn.MouseLeave:Connect(function()
		if btn:GetAttribute("ZoneGlowTouch") == true then
			return
		end
		btn:SetAttribute("ZoneGlowHover", false)
		glowRest(btn)
	end)
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			btn:SetAttribute("ZoneGlowTouch", true)
			btn:SetAttribute("ZoneGlowHover", true)
			glowSet(btn, "hover")
		end
	end)
	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			btn:SetAttribute("ZoneGlowTouch", false)
			btn:SetAttribute("ZoneGlowHover", false)
			glowRest(btn)
		end
	end)
end

function glowHookNew()
	if state.glowHooked == true or not gui then
		return
	end
	state.glowHooked = true
	gui.DescendantAdded:Connect(function(inst)
		if inst:IsA("TextButton") or inst:IsA("ImageButton") then
			task.defer(function()
				if inst.Parent then
					applyButtonCorner(inst)
					glowHook(inst)
					if not glowSkip(inst) and glowEnabled() then
						glowRest(inst)
					end
				end
			end)
		end
	end)
end

function applyGlowLook()
	if not gui then
		return
	end
	glowHookNew()
	pressHookAll()
	for _, inst in ipairs(gui:GetDescendants()) do
		if inst:IsA("TextButton") or inst:IsA("ImageButton") then
			applyButtonCorner(inst)
			glowHook(inst)
			if glowSkip(inst) then
				local stray = inst:FindFirstChild("ZoneGlow")
				if stray then
					stray:Destroy()
				end
			else
				glowRest(inst)
			end
		end
	end
end

function ensureBackdropBlur()
	local existing = Lighting:FindFirstChild("AdminPanelBackdropBlur")
	if existing and existing:IsA("BlurEffect") then
		backdropBlur = existing
		return backdropBlur
	end
	if backdropBlur and backdropBlur.Parent == Lighting and backdropBlur:IsA("BlurEffect") then
		return backdropBlur
	end
	local blur = Instance.new("BlurEffect")
	blur.Name = "AdminPanelBackdropBlur"
	blur.Size = 0
	blur.Parent = Lighting
	backdropBlur = blur
	return backdropBlur
end

function updateBackdropBlur()
	local blur = ensureBackdropBlur()
	if not blur then
		return
	end
	local enabled = state.settingsData and state.settingsData.blurBackground == true and state.panelOpen == true
	blur.Size = enabled and 16 or 0
end

function chatNotificationsEnabled()
	if state and type(state.settingsData) == "table" and state.settingsData.chatPopups ~= nil then
		return state.settingsData.chatPopups == true
	end
	return true
end

function ensureChatUnreadDot()
	local btn = state.chatTabBtn
	if not btn or not btn.Parent then
		return nil
	end
	local dot = btn:FindFirstChild("UnreadDot")
	if dot then
		state.chatUnreadDot = dot
		return dot
	end
	dot = make("Frame", {
		Name = "UnreadDot",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -3, 0, 3),
		Size = UDim2.fromOffset(10, 10),
		BackgroundColor3 = Color3.fromRGB(235, 60, 60),
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 9,
		Parent = btn,
	})
	local round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(1, 0)
	round.Parent = dot
	local ring = Instance.new("UIStroke")
	ring.Color = theme().panel2
	ring.Thickness = 1.5
	ring.Transparency = 0.15
	ring.Parent = dot
	state.chatUnreadDot = dot
	return dot
end

function setChatUnread(on)
	on = on == true
	if on and state.selectedTab == "chat" and state.panelOpen then
		on = false
	end
	state.chatUnread = on
	local dot = ensureChatUnreadDot()
	if not dot then
		return
	end
	if dot.Visible == on then
		return
	end
	dot.Visible = on
	if on and animationsEnabled() then
		dot.Size = UDim2.fromOffset(4, 4)
		tween(dot, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(10, 10),
		})
	end
end

function markChatRead()
	setChatUnread(false)
end

CHAT_POPUP_MAX = 3
CHAT_POPUP_LIFETIME = 5

function chatPopupWidth()
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	return math.clamp(math.floor(vp.X - 36), 200, 300)
end

function updateChatPopupPlacement()
	local holder = state.chatPopupHolder
	if not holder or not holder.Parent then
		return
	end
	local mobile = isMobileLayout()
	holder.Size = UDim2.fromOffset(chatPopupWidth(), 0)
	if mobile then
		holder.AnchorPoint = Vector2.new(1, 0)
		holder.Position = UDim2.new(1, -16, 0, 52)
	else
		holder.AnchorPoint = Vector2.new(1, 1)
		holder.Position = UDim2.new(1, -16, 1, -16)
	end
	local layout = holder:FindFirstChildOfClass("UIListLayout")
	if layout then
		layout.VerticalAlignment = mobile and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Bottom
	end
end

function ensureChatPopupHolder()
	if state.chatPopupHolder and state.chatPopupHolder.Parent then
		updateChatPopupPlacement()
		return state.chatPopupHolder
	end
	if not gui or not gui.Parent then
		return nil
	end
	local holder = make("Frame", {
		Name = "ChatPopupHolder",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.fromOffset(chatPopupWidth(), 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 4800,
		Parent = gui,
	})
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Parent = holder,
	})
	state.chatPopupHolder = holder
	state.chatPopupList = {}
	updateChatPopupPlacement()
	return holder
end

function dismissChatPopup(card)
	if not card or not card.Parent then
		return
	end
	if card:GetAttribute("Closing") then
		return
	end
	card:SetAttribute("Closing", true)
	for index, item in ipairs(state.chatPopupList or {}) do
		if item == card then
			table.remove(state.chatPopupList, index)
			break
		end
	end
	if animationsEnabled() then
		tween(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			GroupTransparency = 1,
		})
		task.delay(0.22, function()
			if card and card.Parent then
				card:Destroy()
			end
		end)
	else
		card:Destroy()
	end
end

function showChatPopup(entry)
	if state.accessGranted ~= true or type(entry) ~= "table" then
		return
	end
	if not chatNotificationsEnabled() then
		return
	end
	local holder = ensureChatPopupHolder()
	if not holder then
		return
	end

	local th = theme()
	local senderId = tonumber(entry.senderUserId) or 0
	local senderName = tostring(entry.senderDisplayName or entry.senderName or "Admin")
	local body = chatWrapLongWords(tostring(entry.message or ""))
	if body == "" then
		return
	end

	state.chatPopupList = state.chatPopupList or {}
	while #state.chatPopupList >= CHAT_POPUP_MAX do
		dismissChatPopup(state.chatPopupList[1])
	end

	local card = make("CanvasGroup", {
		Name = "ChatPopup",
		LayoutOrder = math.floor(os.clock() * 1000),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		GroupTransparency = animationsEnabled() and 1 or 0,
		ZIndex = 4801,
		Parent = holder,
	})
	corner(card, 14)
	stroke(card, 0.92)
	padding(card, 10, 10, 10, 10)

	local avatar = make("ImageLabel", {
		Name = "Avatar",
		BackgroundColor3 = th.panel2,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(36, 36),
		Position = UDim2.fromOffset(0, 0),
		Image = getChatAvatarUrl(senderId),
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 4802,
		Parent = card,
	})
	corner(avatar, 18)
	stroke(avatar, 0.7)

	local content = make("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(46, 0),
		Size = UDim2.new(1, -74, 0, 36),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 4802,
		Parent = card,
	})

	make("TextLabel", {
		Name = "Sender",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		Text = streamerShortText(senderName),
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 4802,
		Parent = content,
	})

	make("TextLabel", {
		Name = "Body",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 16),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = body,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextWrapped = true,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = 4802,
		Parent = content,
	})

	local closeBtn = make("TextButton", {
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 2),
		Size = UDim2.fromOffset(22, 22),
		BackgroundColor3 = th.panel2,
		BackgroundTransparency = 0.2,
		Text = "X",
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = th.text,
		AutoButtonColor = false,
		ZIndex = 4804,
		Parent = card,
	})
	corner(closeBtn, 11)
	closeBtn.MouseButton1Click:Connect(function()
		dismissChatPopup(card)
	end)

	local openBtn = make("TextButton", {
		Name = "OpenChat",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -30, 1, 0),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 4803,
		Parent = card,
	})
	openBtn.MouseButton1Click:Connect(function()
		dismissChatPopup(card)
		if state.accessGranted == true then
			if not state.panelOpen then
				openPanel()
			end
			setTab("chat")
		end
	end)

	table.insert(state.chatPopupList, card)

	if animationsEnabled() then
		tween(card, TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			GroupTransparency = 0,
		})
	end

	task.delay(CHAT_POPUP_LIFETIME, function()
		dismissChatPopup(card)
	end)
end

ESP_RANK_COLORS = {
	Owner = Color3.fromRGB(255, 100, 100),
	Admin = Color3.fromRGB(255, 180, 80),
	Moderator = Color3.fromRGB(100, 255, 160),
	Helper = Color3.fromRGB(100, 200, 255),
}

function espEnabled()
	return state.espActive == true
end

function espColorFor(plr)
	local rank = nil
	local ok = pcall(function()
		rank = plr:GetAttribute("AdminPanelRank")
	end)
	if ok and rank and ESP_RANK_COLORS[tostring(rank)] then
		return ESP_RANK_COLORS[tostring(rank)], tostring(rank)
	end
	return Color3.fromRGB(235, 235, 245), nil
end

function espClearFor(userId)
	local entry = (state.espEntries or {})[userId]
	if not entry then
		return
	end
	if entry.highlight then
		pcall(function()
			entry.highlight:Destroy()
		end)
	end
	if entry.tag then
		pcall(function()
			entry.tag:Destroy()
		end)
	end
	state.espEntries[userId] = nil
end

function espClearAll()
	for userId in pairs(state.espEntries or {}) do
		espClearFor(userId)
	end
	state.espEntries = {}
end

function espBuildFor(plr)
	if not plr or plr == localPlayer then
		return
	end
	local char = plr.Character
	if not char or not char:FindFirstChild("Head") then
		return
	end

	state.espEntries = state.espEntries or {}
	local entry = state.espEntries[plr.UserId]
	if entry and entry.char == char and entry.highlight and entry.highlight.Parent then
		return entry
	end
	espClearFor(plr.UserId)

	local tint, rank = espColorFor(plr)

	local highlight = Instance.new("Highlight")
	highlight.Name = "ZonePanelESP"
	highlight.FillColor = tint
	highlight.FillTransparency = 0.72
	highlight.OutlineColor = tint
	highlight.OutlineTransparency = 0.1
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = char
	highlight.Parent = char

	local tag = Instance.new("BillboardGui")
	tag.Name = "ZonePanelTag"
	tag.Adornee = char:FindFirstChild("Head")
	tag.Size = UDim2.fromOffset(190, 34)
	tag.StudsOffsetWorldSpace = Vector3.new(0, 2.6, 0)
	tag.AlwaysOnTop = true
	tag.MaxDistance = 1000
	tag.Parent = char

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0, 18)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 13
	nameLabel.TextColor3 = tint
	nameLabel.TextStrokeTransparency = 0.4
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.Text = streamerShortText(plr.DisplayName or plr.Name)
	nameLabel.Parent = tag

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Name = "Info"
	infoLabel.BackgroundTransparency = 1
	infoLabel.Position = UDim2.fromOffset(0, 17)
	infoLabel.Size = UDim2.new(1, 0, 0, 14)
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.TextSize = 11
	infoLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
	infoLabel.TextStrokeTransparency = 0.5
	infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	infoLabel.Text = rank or ""
	infoLabel.Parent = tag

	state.espEntries[plr.UserId] = {
		highlight = highlight,
		tag = tag,
		char = char,
		name = nameLabel,
		info = infoLabel,
	}
	return state.espEntries[plr.UserId]
end

function espRefreshDistances()
	local char = localPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	for userId, entry in pairs(state.espEntries or {}) do
		if entry and entry.info and entry.info.Parent then
			local plr = Players:GetPlayerByUserId(userId)
			local bits = {}
			local _, rank = espColorFor(plr)
			if rank then
				table.insert(bits, rank)
			end
			if root and plr and plr.Character then
				local theirRoot = plr.Character:FindFirstChild("HumanoidRootPart")
				if theirRoot then
					table.insert(bits, ("%dm"):format(math.floor((theirRoot.Position - root.Position).Magnitude)))
				end
			end
			local hum = plr and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health < hum.MaxHealth then
				table.insert(bits, ("%d hp"):format(math.floor(hum.Health)))
			end
			entry.info.Text = table.concat(bits, "  -  ")
		end
	end
end

function espSweep()
	if not espEnabled() then
		return
	end
	local alive = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= localPlayer then
			alive[plr.UserId] = true
			espBuildFor(plr)
		end
	end
	for userId in pairs(state.espEntries or {}) do
		if not alive[userId] then
			espClearFor(userId)
		end
	end
	espRefreshDistances()
end

function setEspActive(on)
	on = on == true
	state.espActive = on
	local th = theme()
	if state.espButton and state.espButton.Parent then
		state.espButton.BackgroundColor3 = on and th.accent or th.panel2
		state.espButton.TextColor3 = on and th.onAccent or th.text
		state.espButton.Text = on and "ESP: On" or "ESP: Off"
	end
	if state.espActionBtn and state.espActionBtn.Parent then
		state.espActionBtn.BackgroundColor3 = on and th.accent or th.card
		state.espActionBtn.TextColor3 = on and th.onAccent or th.text
		state.espActionBtn.Text = on and "ESP: On" or "ESP"
	end
	if not on then
		espClearAll()
		if state.espThread then
			task.cancel(state.espThread)
			state.espThread = nil
		end
		return
	end
	espSweep()
	if state.espThread then
		return
	end
	state.espThread = task.spawn(function()
		while espEnabled() do
			task.wait(0.5)
			pcall(espSweep)
		end
		state.espThread = nil
	end)
end

function toggleEsp()
	setEspActive(not espEnabled())
end

function maybeNotifyUpdate()
	local data = state.settingsData or {}
	if data.updateAvailable ~= true then
		return
	end
	local latest = tostring(data.latestVersion or "?")
	if state.updateNoticeVersion == latest then
		return
	end
	state.updateNoticeVersion = latest
	local current = tostring(data.scriptVersion or "?")
	notify(("New update available: v%s (you have v%s). Re-download the panel from your Parcel library!"):format(latest, current), "white", 10)
end

function maybeNotifyAnnounce()
	local data = state.settingsData or {}
	local title = tostring(data.announceTitle or "")
	if data.announceEnabled ~= true or title == "" then
		state.announceNoticeSig = nil
		return
	end
	if data.updateAvailable == true then
		return
	end
	local sig = title .. "\n" .. tostring(data.announceDescription or "")
	if state.announceNoticeSig == sig then
		return
	end
	state.announceNoticeSig = sig
	notify(("Announcement: %s"):format(title), "white", 12)
end

HOME_UPDATE_BASE_Y = {
	HomeHero = 0,
	QuickLinks = 162,
	HomeStats = 242,
	HomePlayers = 328,
	HomeActivityWrap = 472,
}

ZONE_HOME_QUICK_HEIGHT = 80

function zoneHomeQuickHidden()
	return zoneLocalRoleDef() ~= nil
end

function zoneHomeRoleOffset(name)
	if not zoneHomeQuickHidden() then
		return 0
	end
	if name == "HomeStats" or name == "HomePlayers" or name == "HomeActivityWrap" then
		return -ZONE_HOME_QUICK_HEIGHT
	end
	return 0
end

function zoneHomeApplyRoleLayout()
	local scroll = state.homeScroll
	if not scroll or not scroll.Parent then
		return
	end
	local hidden = zoneHomeQuickHidden()
	local quick = scroll:FindFirstChild("QuickLinks")
	if quick then
		quick.Visible = not hidden
	end
	refreshHomeUpdateCard()
end

function buildUpdateHomeCard(parent, yOffset)
	if not parent then
		return 0
	end
	local th = theme()
	local data = state.settingsData or {}
	local latest = tostring(data.latestVersion or "?")
	local current = tostring(data.scriptVersion or "?")
	local title = tostring(data.newsTitle or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if title == "" then
		title = "New update available: v" .. latest
	end
	local desc = tostring(data.newsDescription or "")
	if desc == "" then
		desc = "You are running v" .. current .. ". Re-download the latest version from your Parcel library."
	end
	local img = tostring(data.newsImageId or "")
	local hasImg = img:match("rbxassetid://%d+") ~= nil
	local cardH = hasImg and 100 or 76

	local card = make("Frame", {
		Name = "HomeUpdateCard",
		Position = UDim2.fromOffset(0, yOffset),
		Size = UDim2.new(1, 0, 0, cardH),
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Parent = parent,
	})
	corner(card, 12)
	local cstroke = stroke(card, 0.45)
	if cstroke then
		cstroke.Color = Color3.fromRGB(255, 255, 255)
		cstroke.Thickness = 1.5
	end

	local textWidth = hasImg and -106 or -24
	make("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, textWidth, 0, 18),
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})
	make("TextLabel", {
		Name = "Desc",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 28),
		Size = UDim2.new(1, textWidth, 0, cardH - 36),
		Text = desc,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})

	if hasImg then
		local pic = make("ImageLabel", {
			Name = "Image",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(84, 84),
			BackgroundColor3 = th.panel2,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Image = img,
			ScaleType = Enum.ScaleType.Crop,
			Parent = card,
		})
		corner(pic, 10)
	end

	return cardH + 12
end

function buildAnnounceHomeCard(parent, yOffset)
	if not parent then
		return 0
	end
	local th = theme()
	local data = state.settingsData or {}
	local title = tostring(data.announceTitle or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local desc = tostring(data.announceDescription or "")
	local cardH = (desc ~= "" and 76) or 54

	local card = make("Frame", {
		Name = "HomeAnnounceCard",
		Position = UDim2.fromOffset(0, yOffset),
		Size = UDim2.new(1, 0, 0, cardH),
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Parent = parent,
	})
	corner(card, 12)
	local astroke = stroke(card, 0.45)
	if astroke then
		astroke.Color = th.accent
		astroke.Thickness = 1.5
	end

	make("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -24, 0, 18),
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = th.accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})
	if desc ~= "" then
		make("TextLabel", {
			Name = "Desc",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 28),
			Size = UDim2.new(1, -24, 0, cardH - 36),
			Text = desc,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = th.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = card,
		})
	end

	return cardH + 12
end

function refreshHomeUpdateCard()
	local scroll = state.homeScroll
	if not scroll or not scroll.Parent then
		return
	end
	local data = state.settingsData or {}
	local wantCard = data.updateAvailable == true
	local wantAnnounce = data.announceEnabled == true and tostring(data.announceTitle or "") ~= ""
	local existing = scroll:FindFirstChild("HomeUpdateCard")
	local existingAnnounce = scroll:FindFirstChild("HomeAnnounceCard")
	if wantCard == (existing ~= nil) and wantAnnounce == (existingAnnounce ~= nil) then
		local extraNow = 0
		if existing then
			extraNow = extraNow + existing.Size.Y.Offset + 12
		end
		if existingAnnounce then
			extraNow = extraNow + existingAnnounce.Size.Y.Offset + 12
		end
		for name, baseY in pairs(HOME_UPDATE_BASE_Y) do
			local frame = scroll:FindFirstChild(name)
			if frame then
				frame.Position = UDim2.fromOffset(0, extraNow + baseY + zoneHomeRoleOffset(name))
				if name == "QuickLinks" then
					frame.Visible = not zoneHomeQuickHidden()
				end
			end
		end
		return
	end
	if existing then
		existing:Destroy()
	end
	if existingAnnounce then
		existingAnnounce:Destroy()
	end
	local extra = 0
	if wantCard then
		extra = extra + buildUpdateHomeCard(scroll, extra)
	end
	if wantAnnounce then
		extra = extra + buildAnnounceHomeCard(scroll, extra)
	end
	for name, baseY in pairs(HOME_UPDATE_BASE_Y) do
		local frame = scroll:FindFirstChild(name)
		if frame then
			frame.Position = UDim2.fromOffset(0, extra + baseY + zoneHomeRoleOffset(name))
			if name == "QuickLinks" then
				frame.Visible = not zoneHomeQuickHidden()
			end
		end
	end
end

function syncVersionInfoFromServer()
	if state.accessGranted ~= true then
		return
	end
	local ok, res = pcall(function()
		return SettingsRF:InvokeServer("get")
	end)
	if not ok or type(res) ~= "table" or res.ok == false then
		return
	end
	local data = state.settingsData
	if type(data) ~= "table" then
		return
	end
	data.scriptVersion = tostring(res.scriptVersion or data.scriptVersion or "8.5")
	data.latestVersion = tostring(res.latestVersion or "")
	data.updateAvailable = res.updateAvailable == true
	data.newsTitle = tostring(res.newsTitle or "")
	data.newsDescription = tostring(res.newsDescription or "")
	data.newsImageId = tostring(res.newsImageId or "")
	data.announceEnabled = res.announceEnabled == true
	data.announceTitle = tostring(res.announceTitle or "")
	data.announceDescription = tostring(res.announceDescription or "")
	maybeNotifyUpdate()
	maybeNotifyAnnounce()
	refreshHomeUpdateCard()
end

function buildUpdateBanner(parentCard, layoutOrder)
	if not parentCard then
		return
	end
	local th = theme()
	local data = state.settingsData or {}
	local current = tostring(data.scriptVersion or "8.5")
	local latest = tostring(data.latestVersion or current)
	local hasUpdate = data.updateAvailable == true

	local banner = make("Frame", {
		Name = "UpdateBanner",
		LayoutOrder = layoutOrder,
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 44),
		Parent = parentCard,
	})
	corner(banner, 10)
	local bstroke = stroke(banner, hasUpdate and 0.45 or 0.9)
	if bstroke and hasUpdate then
		bstroke.Color = Color3.fromRGB(255, 255, 255)
	end

	make("TextLabel", {
		Name = "Version",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 6),
		Size = UDim2.new(1, -24, 0, 18),
		Text = "Zone Panel  v" .. current,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = banner,
	})
	make("TextLabel", {
		Name = "Status",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 23),
		Size = UDim2.new(1, -24, 0, 15),
		Text = hasUpdate and ("New update available: v" .. latest .. " - re-download it from your Parcel library.") or "You are running the latest version.",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = hasUpdate and Color3.fromRGB(255, 255, 255) or th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = banner,
	})
	if hasUpdate then
		local detailsBtn = make("TextButton", {
			Name = "UpdateDetailsButton",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 4,
			Parent = banner,
		})
		detailsBtn.MouseButton1Click:Connect(function()
			if type(openUpdateModal) == "function" then openUpdateModal(latest) end
		end)
	end
end

function notify(text, good, duration)
	if state.accessGranted ~= true then
		return
	end
	if not gui or not gui.Parent then
		return
	end
	local th = theme()
	if not state.notificationHolder or not state.notificationHolder.Parent then
		state.notificationHolder = make("Frame", {
			Name = "NotificationHolder",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -18, 1, -18),
			Size = UDim2.fromOffset(320, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = gui,
			ZIndex = 5000,
		})
		state.notificationLayout = make("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Parent = state.notificationHolder,
		})
	end
	local isError = good == false
	local isWhite = good == "white"
	local bg = isWhite and Color3.fromRGB(255, 255, 255) or (isError and th.danger or th.success)
	local frame = make("CanvasGroup", {
		BackgroundColor3 = bg,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = state.notificationHolder,
		ZIndex = 5001,
		GroupTransparency = 1,
	})
	corner(frame, 12)
	stroke(frame, 0.85)
	padding(frame, 12, 10, 12, 10)

	local iconOffset = 0
	if isError then
		local icon = make("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.fromOffset(0, 0),
			Image = "rbxassetid://71503984286896",
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ScaleType = Enum.ScaleType.Fit,
			Parent = frame,
			ZIndex = 5002,
		})
		_ = icon
		iconOffset = 34
	end

	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(iconOffset, 0),
		Size = UDim2.new(1, -iconOffset, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = tostring(text or ""),
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextWrapped = true,
		TextColor3 = isWhite and Color3.fromRGB(24, 24, 28) or th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = frame,
		ZIndex = 5002,
	})
	_ = label
	tween(frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 })
	task.delay(duration or 3, function()
		if not frame or not frame.Parent then
			return
		end
		local out = tween(frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { GroupTransparency = 1 })
		out.Completed:Once(function()
			if frame then frame:Destroy() end
		end)
	end)
end

function setStatus(text, good)
	if state.accessGranted ~= true then
		return
	end
	local message = tostring(text or "")
	state.statusVersion = (tonumber(state.statusVersion) or 0) + 1
	if message:lower():find("select a target first", 1, true) then
		notify(message, false)
		if statusLabel then
			statusLabel.Text = ""
		end
		return
	end
	if good == false and message ~= "" then
		notify(message, false)
	end
	if statusLabel then
		statusLabel.Text = message
		local th = theme()
		statusLabel.TextColor3 = good == false and th.danger or th.success
	end
end

function resolveTarget(query)
	local target = trim(query or "")
	if target == "" then
		setStatus("Enter username or UserId.", false)
		return nil
	end
	local ok, result = pcall(function()
		return ResolveRF:InvokeServer(target)
	end)
	if ok and type(result) == "table" and result.ok then
		state.currentTarget = target
		state.targetQueryRaw = target
		state.resolvedTargetQuery = target
		state.resolvedTargetUserId = tonumber(result.UserId) or state.resolvedTargetUserId
		state.targetData = result
		if refreshStreamerDependentUI then
			refreshStreamerDependentUI()
		else
			updateTargetHeader()
			refreshInfoCards()
		end
		loadAvatarThumbnail(result.UserId)
		setStatus(("Target loaded: %s"):format(streamerShortText(tostring(result.DisplayName or result.Name or target))), true)
		return result
	end
	local msg = (type(result) == "table" and (result.message or result.error)) or "Target not found."
	setStatus(tostring(msg), false)
	notify(tostring(msg), false)
	return nil
end

function refreshTargetData()
	local q = getTargetLabel()
	if q then
		local rawCached = trim(state.targetQueryRaw or state.resolvedTargetQuery or "")
		local cached = trim(state.resolvedTargetQuery or "")
		if rawCached ~= "" then
			q = rawCached
		end
		if cached ~= "" and cached == trim(q) and state.resolvedTargetUserId then
			resolveTarget(state.resolvedTargetUserId)
		else
			resolveTarget(q)
		end
	else
		state.currentTarget = nil
		state.targetQueryRaw = nil
		state.resolvedTargetQuery = nil
		state.resolvedTargetUserId = nil
		state.targetData = nil
		updateTargetHeader()
		refreshInfoCards()
		loadAvatarThumbnail(nil)
	end
end

CLIENT_SELF_DEFAULT_ACTIONS = {
	Gravity = true, Refresh = true, Sit = true, God = true, Ungod = true,
	Fly = true, Unfly = true, Noclip = true, Invisible = true, Visible = true,
	SuperSpeed = true, SuperJump = true, Heal = true, Respawn = true,
	Freeze = true, Unfreeze = true, Kill = true, Jail = true, Unjail = true,
	Unspectate = true, Age = true, BigHead = true, Blind = true,
	Confuse = true, Damage = true, Dwarf = true, Explode = true, Fat = true,
	Fire = true, Fling = true, ForceField = true, Ghost = true, Giant = true,
	Glass = true, Grav = true, HideName = true, Launch = true, NoGravity = true,
	NormalHead = true, NormalSize = true, Paint = true, Ping = true, Ragdoll = true,
	SetHealth = true, ShowName = true, Size = true, SmallHead = true, Smoke = true,
	Sparkles = true, Spin = true, Squash = true, Thin = true, Trip = true,
	UnGhost = true, Unfire = true, Unpunish = true,
	Unragdoll = true, Unsmoke = true, Unsparkles = true, Unspin = true,
}

function sendAction(action, opts)
	opts = opts or {}
	if action == "Esp" then
		toggleEsp()
		setStatus(espEnabled() and "ESP enabled." or "ESP disabled.", true)
		return
	end
	local globalActions = { BringAll = true, HealAll = true, KillAll = true, RespawnAll = true, ServerShutdown = true, ServerRejoin = true }
	local target = opts.target or state.resolvedTargetUserId or state.currentTarget or getTargetLabel()
	if target == "" or (type(target) == "number" and target <= 0) then
		target = nil
	end
	if not target and not globalActions[action] then
		if CLIENT_SELF_DEFAULT_ACTIONS[action] == true then
			target = localPlayer.UserId
		else
			setStatus("Select a target first.", false)
			return
		end
	end
	local meta = ACTION_META[action] or {}
	local reason = trim(opts.reason or "")
	local value = opts.value

	if meta.needsReason and reason == "" then
		reason = "No reason provided."
	end

	local payload = value
	if action == "Ban" then
		local minutes = tonumber(value)
		payload = {
			reason = reason,
			duration = (minutes and minutes > 0) and (minutes * 60) or nil,
		}
	elseif action == "TempMute" then
		local minutes = tonumber(value)
		if not minutes or minutes <= 0 then
			setStatus("Enter the mute length in minutes.", false)
			return
		end
		payload = {
			reason = reason,
			duration = minutes * 60,
		}
	elseif action == "Timeout" then
		local minutes = tonumber(value)
		if not minutes or minutes < 1 then
			setStatus("Enter the timeout length in minutes.", false)
			return
		end
		payload = {
			minutes = math.floor(minutes),
			reason = reason ~= "No reason provided." and reason or "",
		}
	elseif action == "AddNote" then
		payload = reason
	elseif action == "SuperSpeed" or action == "SuperJump" then
		payload = tonumber(value)
	elseif action == "Noclip" then
		payload = true
	end

	local currentQuery = trim(getTargetLabel() or state.resolvedTargetQuery or state.currentTarget or "")
	local cachedQuery = trim(state.resolvedTargetQuery or "")
	if not globalActions[action] and currentQuery ~= "" and currentQuery ~= cachedQuery then
		local resolved = resolveTarget(currentQuery)
		if not resolved then
			setStatus("Target not found.", false)
			notify("Target not found.", false)
			return
		end
		target = state.resolvedTargetUserId or target
	elseif not globalActions[action] and not state.targetData and currentQuery ~= "" then
		local resolved = resolveTarget(currentQuery)
		if not resolved then
			setStatus("Target not found.", false)
			notify("Target not found.", false)
			return
		end
		target = state.resolvedTargetUserId or target
	end

	local targetIsLocalPlayer = (type(target) == "number" and target == localPlayer.UserId) or (type(target) == "string" and tonumber(target) == localPlayer.UserId) or (state.targetData and state.targetData.UserId == localPlayer.UserId)
	if action == "Fly" and targetIsLocalPlayer then
		local char = localPlayer.Character
		if char then startClientFly(char) end
		setStatus("Fly enabled (WASD + Space/Ctrl, Shift = fast)", true)
		RemoteEvent:FireServer(action, target, payload)
		return
	elseif action == "Unfly" and targetIsLocalPlayer then
		stopClientFly(localPlayer.Character)
		setStatus("Fly disabled.", true)
		RemoteEvent:FireServer(action, target, payload)
		return
	end

	RemoteEvent:FireServer(action, target, payload)
	setStatus(("Sent %s"):format(action), true)

	task.delay(0.4, function()
		if state.targetData then
			refreshTargetData()
		end
	end)
end

ALWAYS_CONFIRM_ACTIONS = {
	Ban = true,
	Kick = true,
	KillAll = true,
	BringAll = true,
	RespawnAll = true,
	ServerShutdown = true,
	ShutdownServer = true,
	ServerRejoin = true,
	RejoinServer = true,
	PanicLock = true,
	SetRank = true,
	RemoveRank = true,
}

function confirmPromptsEnabled()
	if state and type(state.settingsData) == "table" and state.settingsData.confirmActions ~= nil then
		return state.settingsData.confirmActions == true
	end
	return true
end

function askAndSend(action)
	local meta = ACTION_META[action] or { label = action }
	local target = state.currentTarget or getTargetLabel() or "N/A"
	local function run()
		sendAction(action, {
			reason = trim(reasonBox and reasonBox.Text or ""),
			value = trim(valueBox and valueBox.Text or "") ~= "" and trim(valueBox.Text) or nil,
		})
	end
	if not confirmPromptsEnabled() and not ALWAYS_CONFIRM_ACTIONS[action] then
		run()
		return
	end
	openConfirmModal("Are you sure?", ("Execute %s on %s?"):format(meta.label or action, tostring(target)), function()
		closeConfirmModal()
		run()
	end)
end

function actionNeedsNoTarget(action)
	return action == "Esp"
end

function buildActionButton(parent, action)
	if not canShowAction(action) then
		return nil
	end
	local meta = ACTION_META[action] or { label = action, serious = false }
	local th = theme()
	local btn = make("TextButton", {
		Name = action,
		Size = UDim2.new(1 / 3, -6, 0, 34),
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.08,
		Text = meta.label or action,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = th.text,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = parent,
	})
	corner(btn, 10)
	stroke(btn, 0.92)

	local holdStart = nil
	btn.MouseButton1Click:Connect(function()
		askAndSend(action)
	end)

	if action == "Esp" then
		state.espActionBtn = btn
		btn.Text = espEnabled() and "ESP: On" or "ESP"
	end
	state.actionButtons[action] = btn
	return btn
end

function buildActions()
	if not actionsHolder then
		return
	end
	clearChildrenExcept(actionsHolder, {})
	clearChildrenExcept(pinnedHolder, {})
	state.actionButtons = {}

	local hereActions = { BringAll = true, HealAll = true, KillAll = true, ServerRejoin = true, RespawnAll = true, ServerShutdown = true }

	if pinnedHolder then pinnedHolder.Visible = false end
	actionsHolder.Position = UDim2.fromOffset(0, 40)
	actionsHolder.Size = UDim2.new(1, 0, 1, -40)

	local allActions = {}
	for action in pairs(ACTION_RULES) do table.insert(allActions, action) end
	table.sort(allActions)

	local query = tostring(state.actionQuery or "")
	local normalActionCount = 0
	for _, action in ipairs(allActions) do
		local matches = query == "" or string.find(string.lower(action), query, 1, true) ~= nil
		if not hereActions[action] and canShowAction(action) and matches then
			normalActionCount += 1
			buildActionButton(actionsHolder, action)
		end
	end

	if not state.hereActionHolder or not state.hereActionHolder.Parent then
		state.hereActionHolder = make("Frame", { Name = "HereActionHolder", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 158), Parent = actionsScroll })
		state.hereActionTitle = make("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Text = "Here — Current Server", Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = theme().text, TextXAlignment = Enum.TextXAlignment.Left, Parent = state.hereActionHolder })
		state.hereActionGrid = make("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 126), Parent = state.hereActionHolder })
		make("UIGridLayout", { CellSize = UDim2.new(1 / 3, -6, 0, 34), CellPadding = UDim2.fromOffset(8, 8), FillDirectionMaxCells = 3, SortOrder = Enum.SortOrder.LayoutOrder, Parent = state.hereActionGrid })
	end

	state.hereActionHolder.Position = UDim2.fromOffset(0, 40 + (math.ceil(normalActionCount / 3) * 42) + 18)
	state.hereActionHolder.Visible = true
	state.hereActionTitle.Text = "Here — Current Server"
	clearChildrenExcept(state.hereActionGrid, {})
	for action in pairs(hereActions) do buildActionButton(state.hereActionGrid, action) end
end

function holdChatScrollDuringPress(active)
	if active then
		local hold = { holdUntil = os.clock() + 30, frames = {} }
		local function collectFrom(root)
			if not root then
				return
			end
			for _, child in ipairs(root:GetDescendants()) do
				local skipHold = child == sidebar or child == mobileScroll or child == mobileTabScroll
				if not skipHold and child:IsA("ScrollingFrame") and child.Visible then
					local pos = child.CanvasPosition
					local maxY = child.AbsoluteCanvasSize.Y - child.AbsoluteWindowSize.Y
					local frame = {
						scroll = child,
						pos = pos,
						bottom = (maxY - pos.Y) < 2,
						applying = false,
						conn = nil,
					}
					frame.conn = child:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
						if frame.applying then
							return
						end
						frame.applying = true
						pcall(function()
							if frame.bottom then
								child.CanvasPosition = Vector2.new(0, 999999)
							else
								child.CanvasPosition = frame.pos
							end
						end)
						frame.applying = false
					end)
					table.insert(hold.frames, frame)
				end
			end
		end
		collectFrom(main)
		if state.chatPip and state.chatPip.frame then
			collectFrom(state.chatPip.frame)
		end
		if #hold.frames > 0 then
			state.chatPressHold = hold
			local function applyHold(h)
				for _, f in ipairs(h.frames) do
					local s = f.scroll
					if s and s.Parent then
						pcall(function()
							if f.bottom then
								s.CanvasPosition = Vector2.new(0, 999999)
							else
								s.CanvasPosition = f.pos
							end
						end)
					end
				end
			end
			local function releaseHold(h)
				for _, f in ipairs(h.frames) do
					if f.conn then
						pcall(function()
							f.conn:Disconnect()
						end)
						f.conn = nil
					end
				end
			end
			applyHold(hold)
			if not state.chatPressConn then
				state.chatPressConn = RunService.RenderStepped:Connect(function()
					local h = state.chatPressHold
					if not h then
						return
					end
					if os.clock() > h.holdUntil then
						state.chatPressHold = nil
						releaseHold(h)
						applyHold(h)
						return
					end
					applyHold(h)
				end)
			end
		end
	else
		if state.chatPressHold then
			state.chatPressHold.holdUntil = os.clock() + 0.35
		end
	end
end
function attachDrag(frame, handle)
	handle = handle or frame
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil
	local pressActive = false

	local function setPressEffect(active)
		holdChatScrollDuringPress(active)
		if not animationsEnabled() or not mainScale then
			return
		end
		if active then
			if not pressActive then
				pressActive = true
				mainScale.Scale = 1
				tween(mainScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.99 })
			end
		else
			if pressActive then
				pressActive = false
				tween(mainScale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 })
			end
		end
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or (input.UserInputType == Enum.UserInputType.Touch and not isMobileLayout()) then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			dragInput = input
			setPressEffect(true)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					setPressEffect(false)
					if state then
						state.panelPosition = frame.Position
					end
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if dragInput and input ~= dragInput then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local delta = input.Position - dragStart
		local newPos = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
		frame.Position = newPos
		if state then
			state.panelPosition = newPos
		end
	end)
end

function attachResize(frame, grip)
	local resizing = false
	local startMouse = nil
	local startSize = nil
	local minSize = Vector2.new(780, 480)
	grip.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		resizing = true
		startMouse = input.Position
		startSize = frame.AbsoluteSize
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				resizing = false
			end
		end)
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not resizing then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local delta = input.Position - startMouse
		local newSize = Vector2.new(
			math.clamp(startSize.X + delta.X, minSize.X, 1400),
			math.clamp(startSize.Y + delta.Y, minSize.Y, 1000)
		)
		frame.Size = clampPanelSizeToViewport(UDim2.fromOffset(newSize.X, newSize.Y))
		state.panelSize = frame.Size
		if type(resizeSidebarToContent) == "function" then
			resizeSidebarToContent()
		end
	end)
end

function layoutForMode()
	local mobile = isMobileLayout()
	state.mobile = mobile
	if type(updateChatPopupPlacement) == "function" then
		updateChatPopupPlacement()
	end
	if type(updateMobileButtonVisibility) == "function" then
		updateMobileButtonVisibility()
	end

	if sidebar then
		sidebar.Visible = true
		sidebar.Active = true
		sidebar.ScrollingEnabled = true
		sidebar.ScrollBarThickness = mobile and 3 or 4
		sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
		sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	end
	if type(resizeSidebarToContent) == "function" then
		task.defer(resizeSidebarToContent)
	end
	if right then right.Visible = true end
	if left then left.Visible = true end
	if topbar then topbar.Visible = true end
	if resizeGrip then
		if resizeGripIcon then
			resizeGripIcon.ImageTransparency = mobile and 1 or 0.25
		end
		resizeGrip.Visible = not mobile
		local gripSize = mobile and 38 or 28
		resizeGrip.Size = UDim2.fromOffset(gripSize, gripSize)
	end
	if state.dragHandle then
		state.dragHandle.Visible = not mobile
	end
	if state.dragHandleBar then
		state.dragHandleBar.Visible = not mobile
	end
	if syncTopbarControls then
		syncTopbarControls()
	end
	if mobileHeader then mobileHeader.Visible = false end
	if mobileTabScroll then mobileTabScroll.Visible = false end
	if mobileScroll then mobileScroll.Visible = false end

	if responsiveScale then
		responsiveScale.Scale = mobile and math.max(0.68, getResponsivePanelScale() * 0.94) or 1
	end

	if mobile then
		main.Size = UDim2.new(0.84, 0, 0.82, 0)
		main.ClipsDescendants = true
		main.Position = UDim2.fromScale(0.5, 0.5)
		state.panelPosition = main.Position
	else
		main.ClipsDescendants = false
		main.Size = clampPanelSizeToViewport(state.panelSize or CONFIG.panels.main)
		state.panelSize = main.Size
		if state.panelPosition then
			main.Position = state.panelPosition
		end
	end
end
function rebuildMobile()
	if not mobileScroll or not mobileInner then return end
	clearChildrenExcept(mobileInner, {})

	local th = theme()

	if state.selectedTab == "chat" then
		local chatTitle = make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			Text = "Chat",
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			TextColor3 = th.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = mobileInner,
		})
		local mobilePipBtn = make("ImageButton", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.fromOffset(28, 24),
			BackgroundColor3 = th.card,
			BackgroundTransparency = 0.15,
			Image = "rbxassetid://117273761878755",
			ScaleType = Enum.ScaleType.Fit,
			AutoButtonColor = false,
			ZIndex = 20,
			Parent = mobileInner,
		})
		corner(mobilePipBtn, 8)
		stroke(mobilePipBtn, 0.9)
		mobilePipBtn.MouseButton1Click:Connect(openChatPip)
		mobilePipBtn.Activated:Connect(openChatPip)
		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 22),
			Size = UDim2.new(1, 0, 0, 16),
			Text = "Admins only chat.",
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = mobileInner,
		})
		local chatCard = make("Frame", {
			BackgroundColor3 = th.panel,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 430),
			Parent = mobileInner,
		})
		corner(chatCard, 18)
		stroke(chatCard, 0.92)
		padding(chatCard, 12, 12, 12, 12)
		state.chatStatusLabel = make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			Text = "Loading chat...",
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = chatCard,
		})
		state.chatTypingLabel = make("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, -60),
			Size = UDim2.new(1, 0, 0, 14),
			Text = "",
			Visible = false,
			Font = Enum.Font.GothamSemibold,
			TextSize = 11,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 11,
			Parent = chatCard,
		})
		local chatListScroll = make("ScrollingFrame", {
			Name = "ChatListScroll",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 40),
			Size = UDim2.new(1, 0, 1, -104),
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = th.text,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingEnabled = true,
			Parent = chatCard,
		})
		state.chatMobileScroll = chatListScroll
		state.chatListHolder = make("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = chatListScroll,
		})
		make("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = state.chatListHolder,
		})
		state.chatFooter = make("Frame", {
			Visible = true,
			BackgroundColor3 = th.panel2,
			BackgroundTransparency = 0.08,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 54),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = chatCard,
		})
		corner(state.chatFooter, 12)
		stroke(state.chatFooter, 0.92)
		padding(state.chatFooter, 0, 0, 0, 9)
		state.chatInputBox = make("TextBox", {
			Position = UDim2.fromOffset(10, 9),
			Size = UDim2.new(1, -114, 0, 36),
			BackgroundColor3 = th.card,
			Text = "",
			PlaceholderText = "Type a message...",
			ClearTextOnFocus = false,
			MultiLine = true,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = th.text,
			PlaceholderColor3 = th.muted,
			Parent = state.chatFooter,
		})
		corner(state.chatInputBox, 10)
		stroke(state.chatInputBox, 0.92)
		state.chatSendBtn = make("ImageButton", {
			Position = UDim2.new(1, -94, 0, 9),
			Size = UDim2.new(0, 84, 0, 36),
			BackgroundColor3 = th.panel2,
			BackgroundTransparency = 0.06,
			Image = "rbxassetid://79859235777238",
			ImageColor3 = th.text,
			ScaleType = Enum.ScaleType.Fit,
			AutoButtonColor = false,
			Active = true,
			Selectable = true,
			ZIndex = 10,
			Parent = state.chatFooter,
		})
		corner(state.chatSendBtn, 10)
		stroke(state.chatSendBtn, 0.92)
		local function sendChatFromButton()
			pcall(function()
				state.trySendChatMessage()
			end)
		end
		state.chatSendBtn.Activated:Connect(sendChatFromButton)
		state.chatSendBtn.MouseButton1Click:Connect(sendChatFromButton)
		state.chatInputBox.Focused:Connect(function()
			state.chatInputFocused = true
			state.bumpChatTyping()
		end)
		state.chatInputBox:GetPropertyChangedSignal("Text"):Connect(function()
			if state.chatInputSending then
				return
			end
			local current = state.chatInputBox.Text or ""
			if string.find(current, "\n", 1, true) then
				state.chatInputSending = true
				state.chatInputBox.Text = string.gsub(current, "\n", "")
				state.chatInputSending = false
				if trim(state.chatInputBox.Text or "") ~= "" then
					pcall(function()
						state.trySendChatMessage()
					end)
				end
				return
			end
			if state.chatInputFocused and trim(current) ~= "" then
				state.bumpChatTyping()
			end
		end)
		state.chatInputBox.FocusLost:Connect(function(enterPressed)
			state.chatInputFocused = false
			state.setChatTyping(false)
			if enterPressed then
				state.trySendChatMessage()
			end
		end)
		state.refreshChatPanel()
		if state.chatPipOpen == true and state.chatPip and state.chatPip.mobileScroll and state.chatPip.mobileScroll.Parent then
			for _, stale in ipairs(state.chatPip.mobileScroll:GetChildren()) do
				stale:Destroy()
			end
			for _, stale in ipairs(state.chatPip.frame:GetChildren()) do
				local keep = stale == state.chatPip.header
					or stale == state.chatPip.resizeGrip
					or stale == state.chatPip.mobileScroll
					or stale:IsA("UICorner") or stale:IsA("UIStroke")
					or stale:IsA("UIShadow") or stale:IsA("UIScale")
					or stale:IsA("UIGradient")
					or stale.Name == "AnimatedBackground"
				if not keep then
					stale:Destroy()
				end
			end
			state.chatStatusLabel.Parent = state.chatPip.frame
			state.chatStatusLabel.Position = UDim2.fromOffset(0, 42)
			state.chatStatusLabel.Size = UDim2.new(1, -140, 0, 18)
			state.chatStatusLabel.Visible = true
			state.chatListHolder.Parent = state.chatPip.mobileScroll
			state.chatListHolder.Position = UDim2.fromOffset(0, 0)
			state.chatListHolder.Size = UDim2.new(1, 0, 0, 0)
			state.chatListHolder.AutomaticSize = Enum.AutomaticSize.Y
			if state.chatMobileScroll then
				state.chatMobileScroll.Visible = false
			end
			if state.chatFooter then
				state.chatFooter.Parent = state.chatPip.frame
				state.chatFooter.Visible = true
			end
			if state.chatTypingLabel then
				state.chatTypingLabel.Parent = state.chatPip.frame
				state.chatTypingLabel.Position = UDim2.new(0, 10, 1, -58)
			end
			state.chatPipSaved = {
				mobile = true,
				statusParent = chatCard,
				statusPosition = UDim2.fromOffset(0, 0),
				statusSize = UDim2.new(1, 0, 0, 16),
				listParent = state.chatMobileScroll or chatCard,
				listPosition = UDim2.fromOffset(0, 0),
				listSize = UDim2.new(1, 0, 0, 0),
				footerParent = chatCard,
				footerPosition = UDim2.new(0, 0, 1, 0),
				footerSize = UDim2.new(1, 0, 0, 54),
				typingParent = chatCard,
				typingPosition = UDim2.new(0, 0, 1, -60),
				typingSize = UDim2.new(1, 0, 0, 14),
			}
		end
		return
	elseif state.selectedTab == "settings" then
		local settingsTitle = make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			Text = "Settings",
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			TextColor3 = th.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = mobileInner,
		})
		make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			Text = "Use the toggles below to control the panel.",
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = mobileInner,
		})
		local settingsCard = make("Frame", {
			BackgroundColor3 = th.panel,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = mobileInner,
		})
		corner(settingsCard, 18)
		stroke(settingsCard, 0.92)
		padding(settingsCard, 12, 8, 12, 12)
		make("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = settingsCard,
		})

		buildUpdateBanner(settingsCard, 4)
		buildSettingsSwitches(settingsCard, 5)
		buildSettingsBgStyleRow(settingsCard, 20)
		buildThemePicker(settingsCard, 21)
		settingsWebhookBox = make("TextBox", {
			LayoutOrder = 22,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = "",
			PlaceholderText = "Webhook URL",
			ClearTextOnFocus = false,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = th.text,
			PlaceholderColor3 = th.muted,
			Visible = false,
			Parent = settingsCard,
		})
		settingsStatusLabel = make("TextLabel", {
			Visible = true,
			LayoutOrder = 23,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Text = "Tap save after editing fields.",
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = settingsCard,
		})
		settingsSaveBtn = make("TextButton", {
			LayoutOrder = 24,
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = th.accent,
			Text = "Save settings",
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextColor3 = theme().onAccent,
			AutoButtonColor = false,
			Parent = settingsCard,
		})
		corner(settingsSaveBtn, 10)
		stroke(settingsSaveBtn, 0.92)
		buildPanicButton(settingsCard, 25)
		buildResetButton(settingsCard, 28)
		if settingsWebhookToggle then
			settingsWebhookToggle.MouseButton1Click:Connect(function()
				local draft = getSettingsDraft()
				draft.animationOn = not (draft.animationOn == true)
				setSettingsDirty(true)
				syncSettingsPanelFromDraft()
			end)
		end
		if settingsSaveBtn then
			settingsSaveBtn.MouseButton1Click:Connect(saveSettingsPanel)
		end
		return
	end

	if state.selectedTab == "moderation" then
		local moderationTitle = make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			Text = "Moderation Log",
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			TextColor3 = th.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = mobileInner,
		})
		make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			Text = "Latest moderation actions for the current session.",
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = mobileInner,
		})
		local moderationCard = make("Frame", {
			BackgroundColor3 = th.panel,
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 420),
			Parent = mobileInner,
		})
		corner(moderationCard, 18)
		stroke(moderationCard, 0.92)
		padding(moderationCard, 12, 12, 12, 12)
		local refreshBtn = make("TextButton", {
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(100, 30),
			BackgroundColor3 = th.panel2,
			Text = "Refresh",
			Font = Enum.Font.GothamSemibold,
			TextSize = 13,
			TextColor3 = th.text,
			AutoButtonColor = false,
			Parent = moderationCard,
		})
		corner(refreshBtn, 10)
		stroke(refreshBtn, 0.92)
		moderationCountLabel = make("TextLabel", {
			Visible = false,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 70),
			Size = UDim2.new(1, 0, 0, 16),
			Text = "Showing 0 entries",
			Font = Enum.Font.GothamSemibold,
			TextSize = 11,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = moderationCard,
		})
		moderationListHolder = make("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 88),
			Size = UDim2.new(1, 0, 1, -88),
			CanvasSize = UDim2.new(0,0,0,0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = th.text,
			Parent = moderationCard,
		})
		make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = moderationListHolder })
		moderationEmptyLabel = make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 24),
			Text = "No moderation actions logged yet.",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			Visible = true,
			Parent = moderationListHolder,
		})
		refreshModerationDisplay()
		refreshBtn.MouseButton1Click:Connect(function()
			refreshModerationLog()
		end)
		return
	end


	local searchCard = make("Frame", {
		BackgroundColor3 = th.panel,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 56),
		Parent = mobileInner,
	})
	corner(searchCard, 14)
	stroke(searchCard, 0.92)
	padding(searchCard, 10, 10, 10, 10)

	local mobileSearchRow = make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = searchCard,
	})

	local mobileTargetBox = make("TextBox", {
		Size = UDim2.new(1, -52, 1, 0),
		BackgroundColor3 = th.card,
		Text = state.currentTarget or "",
		PlaceholderText = "Username",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = th.text,
		PlaceholderColor3 = th.muted,
		Parent = mobileSearchRow,
	})
	corner(mobileTargetBox, 10)
	stroke(mobileTargetBox, 0.92)

	local mobileSearchBtn = make("TextButton", {
		Position = UDim2.new(1, -44, 0, 0),
		Size = UDim2.new(0, 44, 1, 0),
		BackgroundColor3 = th.panel2,
		Text = "🔍",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = th.text,
		AutoButtonColor = false,
		Parent = mobileSearchRow,
	})
	corner(mobileSearchBtn, 10)
	stroke(mobileSearchBtn, 0.92)

	mobileTargetBox.FocusLost:Connect(function(enter)
		if enter then
			state.currentTarget = trim(mobileTargetBox.Text)
			resolveTarget(state.currentTarget)
			rebuildMobile()
		end
	end)
	mobileSearchBtn.MouseButton1Click:Connect(function()
		state.currentTarget = trim(mobileTargetBox.Text)
		resolveTarget(state.currentTarget)
		rebuildMobile()
	end)

	state.mobileTargetBox = mobileTargetBox

	local info = make("Frame", {
		BackgroundColor3 = th.panel,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 260),
		Parent = mobileInner,
	})
	corner(info, 18)
	stroke(info, 0.92)
	padding(info, 12, 12, 12, 12)

	makeInfoCard(info, "Selected Player", state.targetData and (state.targetData.DisplayName or state.targetData.Name) or "None")
	makeInfoCard(info, "Account / Join", state.targetData and accountJoinText(state.targetData) or "Select a target first.")

	if state.targetData then
		local notesBtn = make("TextButton", {
			Position = UDim2.fromOffset(0, 178),
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = th.panel2,
			Text = ("View Notes (%d)"):format(tonumber(state.targetData.NotesCount) or 0),
			Font = Enum.Font.GothamSemibold,
			TextSize = 13,
			TextColor3 = th.text,
			AutoButtonColor = false,
			Parent = info,
		})
		corner(notesBtn, 10)
		notesBtn.MouseButton1Click:Connect(openNotesModal)

		local serverBtn = make("TextButton", {
			Position = UDim2.fromOffset(0, 214),
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = th.panel2,
			Text = "Server Manager",
			Font = Enum.Font.GothamSemibold,
			TextSize = 13,
			TextColor3 = th.text,
			AutoButtonColor = false,
			Parent = info,
		})
		corner(serverBtn, 10)
		serverBtn.MouseButton1Click:Connect(function()
			if state.sidebarSuppressClick then return end
			setTab("server")
		end)
	end

	local inputCard = make("Frame", {
		BackgroundColor3 = th.panel,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 94),
		Parent = mobileInner,
	})
	corner(inputCard, 14)
	stroke(inputCard, 0.92)
	padding(inputCard, 10, 10, 10, 10)

	local mobileReasonBox = make("TextBox", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = th.card,
		Text = (reasonBox and reasonBox.Text or ""),
		PlaceholderText = "Reason / note text",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = th.text,
		PlaceholderColor3 = th.muted,
		Parent = inputCard,
	})
	corner(mobileReasonBox, 10)
	stroke(mobileReasonBox, 0.92)
	mobileReasonBox:GetPropertyChangedSignal("Text"):Connect(function()
		if reasonBox then reasonBox.Text = mobileReasonBox.Text end
	end)

	local mobileValueBox = make("TextBox", {
		Position = UDim2.fromOffset(0, 44),
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = th.card,
		Text = (valueBox and valueBox.Text or ""),
		PlaceholderText = "Value (speed / Roblox API ban minutes)",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = th.text,
		PlaceholderColor3 = th.muted,
		Parent = inputCard,
	})
	corner(mobileValueBox, 10)
	stroke(mobileValueBox, 0.92)
	mobileValueBox:GetPropertyChangedSignal("Text"):Connect(function()
		if valueBox then valueBox.Text = mobileValueBox.Text end
	end)

	local actionCard = make("Frame", {
		BackgroundColor3 = th.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 240),
		Parent = mobileInner,
	})
	corner(actionCard, 18)
	stroke(actionCard, 0.92)
	padding(actionCard, 12, 12, 12, 12)

	make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Text = "Actions (tap to execute)",
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = actionCard,
	})

	local pinned = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 26),
		Size = UDim2.new(1, 0, 0, 80),
		Parent = actionCard,
	})
	make("UIGridLayout", {
		CellSize = UDim2.new(0.5, -4, 0, 34),
		CellPadding = UDim2.fromOffset(8, 8),
		FillDirectionMaxCells = 2,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = pinned,
	})
	for _, action in ipairs(state.pinnedActions) do
		buildActionButton(pinned, action)
	end
	local more = make("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 116),
		Size = UDim2.new(1, 0, 0, 112),
		ScrollBarThickness = 4,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = actionCard,
	})
	make("UIGridLayout", {
		CellSize = UDim2.new(0.5, -4, 0, 34),
		CellPadding = UDim2.fromOffset(8, 8),
		FillDirectionMaxCells = 2,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = more,
	})
	for action in pairs(ACTION_RULES) do
		if not table.find(state.pinnedActions, action) then
			buildActionButton(more, action)
		end
	end
end

function setPanelSizeToDefault()
	state.panelSize = clampPanelSizeToViewport(state.panelSize or CONFIG.panels.main)
	main.Size = state.panelSize
end

function setTabButtonState(btn, active)
	if not btn then
		return
	end
	if type(glowMarkActive) == "function" then
		glowMarkActive(btn, active)
	end
	local th = theme()
	btn.BackgroundColor3 = active and th.accent or th.card
	btn.BackgroundTransparency = active and 0.05 or 0.14
	if btn:IsA("ImageButton") then
		btn.ImageColor3 = active and th.onAccent or th.icon
	end
	local img = btn:FindFirstChild("Icon")
	if img and img:IsA("ImageLabel") then
		img.ImageColor3 = active and th.onAccent or th.icon
	end
	local sideLabel = btn:FindFirstChild("Label")
	if sideLabel and sideLabel:IsA("TextLabel") then
		sideLabel.TextColor3 = active and th.onAccent or th.text
	end
	local lbl = btn:FindFirstChildOfClass("TextLabel")
	if lbl then
		lbl.TextColor3 = active and th.onAccent or th.text
	end
	if btn:IsA("TextButton") then
		btn.TextColor3 = active and th.onAccent or th.text
	end
	local st = btn:FindFirstChildOfClass("UIStroke")
	if st then
		st.Transparency = active and 0.6 or 0.92
	end
	local sc = btn:FindFirstChildOfClass("UIScale")
	if sc then
		tween(sc, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = active and 1.12 or 1 })
	end
end

function syncTabButtons()
	task.defer(resizeSidebarToContent)
	local adminsVisible = canSeeAdminsTab()
	if sidebarHomeBtn then
		setTabButtonState(sidebarHomeBtn, state.selectedTab == "home")
	end
	if state.sidebarActionsBtn then
		setTabButtonState(state.sidebarActionsBtn, state.selectedTab == "actions")
	end
	if sidebarServerBtn then
		setTabButtonState(sidebarServerBtn, state.selectedTab == "server")
	end
	if sidebarAdminsBtn then
		sidebarAdminsBtn.Visible = adminsVisible
		setTabButtonState(sidebarAdminsBtn, adminsVisible and state.selectedTab == "admins")
	end
	if sidebarBanBtn then
		setTabButtonState(sidebarBanBtn, state.selectedTab == "ban")
	end
	if state.chatTabBtn then
		setTabButtonState(state.chatTabBtn, state.selectedTab == "chat")
		if state.selectedTab == "chat" and state.panelOpen then
			markChatRead()
		end
	end
	if sidebarCreditsBtn then
		setTabButtonState(sidebarCreditsBtn, state.selectedTab == "credits")
	end
	if sidebarSettingsBtn then
		setTabButtonState(sidebarSettingsBtn, state.selectedTab == "settings")
	end
	if state.sidebarModerationBtn then
		setTabButtonState(state.sidebarModerationBtn, state.selectedTab == "moderation")
	end
	if sidebarAnnounceBtn then
		local canAnnounce = canUseAnnounceTab()
		sidebarAnnounceBtn.Visible = canAnnounce
		setTabButtonState(sidebarAnnounceBtn, canAnnounce and state.selectedTab == "announce")
	end
	refreshMobileNavButtons()
end


function updateHomeTargetVisibility(tab)
	local isActions = tab == "actions"
	if actionsScroll then actionsScroll.Visible = isActions end
	if inputBar then inputBar.Visible = isActions end
	if left then left.Visible = isActions end
	if state.homeScroll then state.homeScroll.Visible = tab == "home" end
end
function setTab(tab)
	tab = sanitizePreferredTab(tab)
	local showChatControls = tab == "chat"
	if state.chatTitleLabel then
		state.chatTitleLabel.Visible = showChatControls
	end
	if state.chatPip.minimizeBtn then
		state.chatPip.minimizeBtn.Visible = showChatControls and state.chatPipOpen ~= true
	end
	if state.chatStatusLabel then
		state.chatStatusLabel.Visible = showChatControls
	end
	for _, hidden in ipairs({ state.announceStatusLabel }) do
		if hidden and hidden.Parent then
			hidden.Visible = false
		end
	end
	if state.chatTypingLabel then
		state.chatTypingLabel.Visible = showChatControls and tostring(state.chatTypingLabel.Text or "") ~= ""
	end
	local previousTab = state.selectedTab
	if previousTab ~= nil and previousTab ~= tab then
		state.lastTab = previousTab
	end
	if previousTab == tab then
		updateHomeTargetVisibility(tab)
		if tab == "home" or tab == "actions" then
			updateHomeTargetVisibility(tab)
		elseif tab == "admins" then
			if adminsScroll then adminsScroll.Visible = true end
		elseif tab == "credits" then
			if creditsScroll then creditsScroll.Visible = true end
		elseif tab == "server" then
			if serverScroll then serverScroll.Visible = true end
		elseif tab == "ban" then
			if banScroll then banScroll.Visible = true end
		elseif tab == "chat" then
			if state.chatScroll then state.chatScroll.Visible = true end
			if state.chatFooter then state.chatFooter.Visible = true end
		elseif tab == "settings" then
			if settingsScroll then settingsScroll.Visible = true end
		end
		syncTabButtons()
		return
	end
	state.selectedTab = tab
	state.lastTab = tab
	state.activeTabTransition = true

	if actionsScroll then actionsScroll.Visible = (tab == "actions") end
	if state.homeScroll then state.homeScroll.Visible = (tab == "home") end
	if adminsScroll then adminsScroll.Visible = (tab == "admins") end
	if creditsScroll then creditsScroll.Visible = (tab == "credits") end
	if serverScroll then serverScroll.Visible = (tab == "server") end
	if banScroll then banScroll.Visible = (tab == "ban") end
	if state.chatScroll then state.chatScroll.Visible = (tab == "chat") or state.chatPipOpen == true end
	if state.chatFooter then state.chatFooter.Visible = (tab == "chat") or state.chatPipOpen == true end
	if state.chatPip.placeholder then
		state.chatPip.placeholder.Visible = (tab == "chat") and state.chatPipOpen == true
	end
	if state.chatTypingLabel then
		state.chatTypingLabel.Visible = ((tab == "chat") or state.chatPipOpen == true) and tostring(state.chatTypingLabel.Text or "") ~= ""
	end
	if moderationScroll then moderationScroll.Visible = (tab == "moderation") end
	if state.announceScroll then state.announceScroll.Visible = (tab == "announce") end
	if settingsScroll then settingsScroll.Visible = (tab == "settings") end
	if inputBar then inputBar.Visible = (tab == "actions") end
	if left then left.Visible = (tab == "actions") end
	updateHomeTargetVisibility(tab)

	applySidebarMode(false)

	if previousTab and previousTab ~= tab then
		local prevFrame = (previousTab == "home" and state.homeScroll)
			or (previousTab == "actions" and actionsScroll)
			or (previousTab == "admins" and adminsScroll)
			or (previousTab == "credits" and creditsScroll)
			or (previousTab == "server" and serverScroll)
			or (previousTab == "ban" and banScroll)
			or (previousTab == "chat" and state.chatScroll)
			or (previousTab == "moderation" and moderationScroll)
			or (previousTab == "announce" and state.announceScroll)
			or (previousTab == "settings" and settingsScroll)
		if prevFrame and prevFrame.Visible and not (state.chatPipOpen and prevFrame == state.chatScroll) then
			prevFrame.Visible = false
		end
	end

	local nextFrame = (tab == "home" and state.homeScroll)
		or (tab == "actions" and actionsScroll)
		or (tab == "admins" and adminsScroll)
		or (tab == "credits" and creditsScroll)
		or (tab == "server" and serverScroll)
		or (tab == "ban" and banScroll)
		or (tab == "chat" and state.chatScroll)
		or (tab == "moderation" and moderationScroll)
		or (tab == "announce" and state.announceScroll)
		or (tab == "settings" and settingsScroll)

	if nextFrame and not nextFrame.Visible then
		nextFrame.Visible = true
		local basePos = nextFrame.Position
		nextFrame.Position = UDim2.fromOffset(basePos.X.Offset + 16, basePos.Y.Offset)
		tween(nextFrame, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = basePos })
	end

	if tab == "chat" then
		for _, chatControl in ipairs({ state.chatTitleLabel, state.chatStatusLabel }) do
			if chatControl then
				local basePos = chatControl.Position
				chatControl.Visible = true
				chatControl.Position = UDim2.fromOffset(basePos.X.Offset + 16, basePos.Y.Offset)
				tween(chatControl, TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = basePos })
			end
		end
	end

	syncTabButtons()
	refreshStreamerDependentUI()

	if tab == "admins" then
		refreshAdmins()
	elseif tab == "server" then
		refreshServerPanel()
	elseif tab == "ban" then
		refreshBanPanel()
	elseif tab == "chat" then
		state.requestChatHistory()
		state.refreshChatPanel()
	elseif tab == "moderation" then
		state.moderationRefreshClock = 0
		refreshModerationLog()
	elseif tab == "announce" then
		refreshAnnouncePanel()
	elseif tab == "settings" then
		refreshSettingsPanel()
		animateSettingsRows()
	elseif tab == "home" then
		refreshHomePanel()
	elseif tab == "actions" then
		refreshInfoCards()
	end

end

function bindGlobalInputEvents()
	UserInputService.InputChanged:Connect(function(input)
		if state.sidebarDrag and state.sidebarDrag.active then
			if input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch then
				updateSidebarReorder(input.Position)
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			endSidebarReorder()
		end
	end)
end

function switchOffColor()
	local th = theme()
	local h, sat, v = Color3.toHSV(th.card)
	if v > 0.6 then
		return Color3.fromHSV(h, sat, math.max(0, v - 0.3))
	end
	return Color3.fromHSV(h, math.min(sat, 0.25), math.min(1, v + 0.26))
end

function buildSettingsSwitchRow(parentCard, layoutOrder, title, note, getFn, setFn, availableFn, disabledNote)
	if not parentCard then
		return nil
	end
	local th = theme()
	local row = make("TextButton", {
		Name = "SwitchRow_" .. tostring(title),
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.15,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = parentCard,
	})
	corner(row, 10)
	stroke(row, 0.9)
	addShadow(row, 10, 0.72, 3, 0)

	local name = make("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 6),
		Size = UDim2.new(1, -90, 0, 18),
		Text = title,
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local hint = make("TextLabel", {
		Name = "Note",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 23),
		Size = UDim2.new(1, -90, 0, 15),
		Text = note,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local pill = make("Frame", {
		Name = "Pill",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(52, 28),
		BackgroundColor3 = th.muted,
		BorderSizePixel = 0,
		Parent = row,
	})
	corner(pill, 14)
	local pillStroke = make("UIStroke", {
		Color = th.text,
		Transparency = 0.72,
		Thickness = 1,
		Parent = pill,
	})

	local knob = make("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(22, 22),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = pill,
	})
	corner(knob, 11)

	local entry = {
		row = row,
		title = name,
		note = hint,
		pill = pill,
		pillStroke = pillStroke,
		knob = knob,
		get = getFn,
		baseNote = note,
		available = availableFn,
		disabledNote = disabledNote,
	}

	entry.isAvailable = function()
		if type(entry.available) ~= "function" then
			return true
		end
		local ok, result = pcall(entry.available)
		return ok and result == true
	end

	entry.render = function(animated)
		local enabled = entry.isAvailable()
		local on = enabled and getFn() == true
		local pal = theme()
		local info = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local pos = on and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		local disabledRow = Color3.fromRGB(102, 105, 112)
		local disabledText = Color3.fromRGB(205, 205, 210)
		local disabledPill = Color3.fromRGB(72, 75, 82)
		local col = enabled and (on and pal.accent or switchOffColor()) or disabledPill
		local knobCol = enabled and contrastTextFor(col) or Color3.fromRGB(155, 155, 160)
		row.Active = enabled
		row.Selectable = enabled
		row.BackgroundColor3 = enabled and pal.card or disabledRow
		row.BackgroundTransparency = enabled and 0.15 or 0.04
		name.TextColor3 = enabled and pal.text or disabledText
		hint.TextColor3 = enabled and pal.muted or disabledText
		hint.Text = enabled and tostring(entry.baseNote or "") or tostring(entry.disabledNote or entry.baseNote or "")
		pillStroke.Transparency = not enabled and 0.65 or (on and 1 or 0.45)
		if animated and enabled and animationsEnabled() then
			tween(pill, info, { BackgroundColor3 = col })
			tween(knob, info, { Position = pos, BackgroundColor3 = knobCol, BackgroundTransparency = 0 })
		else
			pill.BackgroundColor3 = col
			knob.Position = pos
			knob.BackgroundColor3 = knobCol
			knob.BackgroundTransparency = 0
		end
	end

	row.MouseButton1Click:Connect(function()
		if not entry.isAvailable() then
			return
		end
		setFn(not (getFn() == true))
		entry.render(true)
		if animationsEnabled() then
			local pop = TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			knob.Size = UDim2.fromOffset(18, 22)
			tween(knob, pop, { Size = UDim2.fromOffset(22, 22) })
		end
	end)

	state.settingsSwitchRows = state.settingsSwitchRows or {}
	table.insert(state.settingsSwitchRows, entry)
	entry.render(false)
	return row
end


function persistGlowEffectPreference(value)
	value = value == true
	state.glowEffectSavePending = value
	if state.glowEffectSaveRunning == true then
		return
	end
	state.glowEffectSaveRunning = true
	task.spawn(function()
		while state.glowEffectSavePending ~= nil do
			local requested = state.glowEffectSavePending
			state.glowEffectSavePending = nil
			local ok, result = pcall(function()
				return SettingsRF:InvokeServer("set", { glowEffect = requested, glowStrength = 40 })
			end)
			if ok and type(result) == "table" and result.ok ~= false then
				local savedValue = result.glowEffect
				if savedValue == nil then savedValue = requested end
				savedValue = savedValue == true
				if type(state.settingsData) == "table" then
					state.settingsData.glowEffect = savedValue
					state.settingsData.glowStrength = 40
				end
				if state.glowEffectSavePending == nil and type(state.settingsDraft) == "table" then
					state.settingsDraft.glowEffect = savedValue
				end
			else
				if state.glowEffectSavePending == nil and type(state.settingsDraft) == "table" then
					state.settingsDraft.glowEffect = type(state.settingsData) == "table" and state.settingsData.glowEffect == true
				end
				if state.glowEffectSavePending == nil and settingsStatusLabel then
					settingsStatusLabel.Text = "Glow save failed. Tap Save settings to retry."
				end
			end
			if type(applyGlowLook) == "function" then applyGlowLook() end
		end
		state.glowEffectSaveRunning = false
	end)
end

function buildSettingsSwitches(parentCard, startOrder)
	state.settingsSwitchRows = {}
	local function toggler(key, fallback)
		return function()
			local draft = getSettingsDraftSafe()
			if not draft then
				return fallback
			end
			if key == "rememberLastTab" or key == "saveSidebarOrder" then
				return draft[key] ~= false
			end
			return draft[key] == true
		end, function(value)
			local draft = getSettingsDraftSafe()
			if not draft then
				return
			end
			draft[key] = value == true
			setSettingsDirtySafe(true)
			if settingsStatusLabel then
				settingsStatusLabel.Text = "Unsaved changes. Tap Save settings to apply."
			end
		end
	end

	local getAnim, setAnim = toggler("animationOn", true)
	local getBlur, setBlur = toggler("blurBackground", false)
	local getOpen, setOpen = toggler("openInStart", true)
	local getRemember, setRemember = toggler("rememberLastTab", true)
	local getStreamer, setStreamer = toggler("streamerMode", false)
	local getGlobalCmd, setGlobalCmd = toggler("globalCommands", false)
	local getSidebarSave, setSidebarSave = toggler("saveSidebarOrder", true)
	local getConfirm, setConfirm = toggler("confirmActions", true)

	local getGlow, setGlowDraft = toggler("glowEffect", true)
	local getBgImage, setBgImage = toggler("backgroundImage", false)
	local getMovingBg, setMovingBg = toggler("animatedBackground", false)
	local getMobileBtn, setMobileBtn = toggler("mobileButton", true)


	buildSettingsSwitchRow(parentCard, startOrder, "Animations", "Smooth open, close and tab transitions.", getAnim, setAnim)
	buildSettingsSwitchRow(parentCard, startOrder + 1, "Background blur", "Blurs the game behind the panel while it is open.", getBlur, setBlur)
	buildSettingsSwitchRow(parentCard, startOrder + 2, "Open on join", "Show the panel automatically when you join.", getOpen, setOpen)
	buildSettingsSwitchRow(parentCard, startOrder + 3, "Remember last tab", "Reopen on the tab you used last time.", getRemember, setRemember)
	buildSettingsSwitchRow(parentCard, startOrder + 4, "Global commands", "Allow the global keyword across servers. Admin rank only.", getGlobalCmd, setGlobalCmd)
	buildSettingsSwitchRow(parentCard, startOrder + 5, "Streamer mode", "Hides usernames and IDs from the panel.", getStreamer, setStreamer)
	buildSettingsSwitchRow(parentCard, startOrder + 6, "Save sidebar order", "Remember how you arranged the sidebar icons.", getSidebarSave, setSidebarSave)
	buildSettingsSwitchRow(parentCard, startOrder + 7, "Confirm actions", "Ask before running a command. Ban, Kick and server-wide actions always ask.", getConfirm, setConfirm)


	local function setGlow(value)
		value = value == true
		setGlowDraft(value)
		if type(applyGlowLook) == "function" then applyGlowLook() end
		if type(persistGlowEffectPreference) == "function" then
			persistGlowEffectPreference(value)
		end
	end
	buildSettingsSwitchRow(parentCard, startOrder + 9, "Glow Effect", "Fixed at Medium intensity.", getGlow, setGlow)
	buildSettingsSwitchRow(parentCard, startOrder + 10, "Moving background", "Slowly drifting colours behind the panel.", getMovingBg, setMovingBg)
	buildSettingsSwitchRow(parentCard, startOrder + 11, "Open button", "Floating open button on PC and mobile. Drag to move it.", getMobileBtn, setMobileBtn)
	buildSettingsSwitchRow(parentCard, startOrder + 12, "Background image", "Shows the Zone backdrop picture behind the panel.", getBgImage, setBgImage)
end


function animateSettingsRows()
	if not animationsEnabled() then
		return
	end
	local rows = state.settingsSwitchRows or {}
	local index = 0
	for _, entry in ipairs(rows) do
		local row = entry.row
		if row and row.Parent then
			index = index + 1
			local baseTransparency = 0.15
			row.BackgroundTransparency = 1
			local children = row:GetChildren()
			for _, child in ipairs(children) do
				if child:IsA("TextLabel") then
					child.TextTransparency = 1
				end
			end
			task.delay(0.035 * index, function()
				if not row or not row.Parent then
					return
				end
				local info = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				tween(row, info, { BackgroundTransparency = baseTransparency })
				for _, child in ipairs(children) do
					if child:IsA("TextLabel") and child.Parent then
						tween(child, info, { TextTransparency = 0 })
					end
				end
			end)
		end
	end
end

function refreshSettingsSwitches()
	for _, entry in ipairs(state.settingsSwitchRows or {}) do
		if entry.row and entry.row.Parent then
			entry.render(false)
		end
	end
end

function recolorSettingsSwitches()
	local th = theme()
	for _, entry in ipairs(state.settingsSwitchRows or {}) do
		if entry.row and entry.row.Parent then
			entry.row.BackgroundColor3 = th.card
			entry.title.TextColor3 = th.text
			entry.note.TextColor3 = th.muted
			if entry.pillStroke then
				entry.pillStroke.Color = th.text
			end
			entry.render(false)
		end
	end
end

function buildThemePicker(parentCard, layoutOrder, useThemeFn)
	if not parentCard then
		return
	end
	local th = theme()
	state.themeButtons = {}
	state.pendingThemeName = state.pendingThemeName or currentThemeName()
	state.settingsThemeHolder = make("Frame", {
		LayoutOrder = layoutOrder,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parentCard,
	})
	make("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = state.settingsThemeHolder,
	})
	state.settingsThemeValueLabel = make("TextLabel", {
		LayoutOrder = 1,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Text = "Theme: " .. currentThemeName(),
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = state.settingsThemeHolder,
	})
	make("TextLabel", {
		LayoutOrder = 2,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Text = "Pick a color theme, then press Save settings to apply it.",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = state.settingsThemeHolder,
	})
	state.settingsThemeGrid = make("Frame", {
		LayoutOrder = 3,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = state.settingsThemeHolder,
	})
	make("UIGridLayout", {
		CellSize = UDim2.new(0.25, -6, 0, 78),
		CellPadding = UDim2.fromOffset(6, 6),
		FillDirectionMaxCells = 4,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = state.settingsThemeGrid,
	})
	for index, name in ipairs(THEME_ORDER) do
		local palette = THEMES[name]
		if palette then
			local btn = make("TextButton", {
				Name = "Theme_" .. name,
				LayoutOrder = index,
				BackgroundColor3 = palette.panel,
				BackgroundTransparency = 0.05,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				Parent = state.settingsThemeGrid,
			})
			corner(btn, 10)
			stroke(btn, 0.85)
			local swatch = make("Frame", {
				BackgroundColor3 = palette.accent,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(8, 10),
				Size = UDim2.new(1, -16, 0, 20),
				Parent = btn,
			})
			corner(swatch, 6)
			if name == "Custom" then
				swatch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				rainbowGradient(swatch)
			end
			local dotSuccess = make("Frame", {
				BackgroundColor3 = palette.success,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(8, 36),
				Size = UDim2.fromOffset(14, 6),
				Parent = btn,
			})
			local dotWarn = make("Frame", {
				BackgroundColor3 = palette.warn,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(26, 36),
				Size = UDim2.fromOffset(14, 6),
				Parent = btn,
			})
			local dotDanger = make("Frame", {
				BackgroundColor3 = palette.danger,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(44, 36),
				Size = UDim2.fromOffset(14, 6),
				Parent = btn,
			})
			local nameLabel = make("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(8, 50),
				Size = UDim2.new(1, -16, 0, 22),
				Text = name,
				Font = Enum.Font.GothamSemibold,
				TextSize = 12,
				TextScaled = false,
				TextColor3 = palette.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = btn,
			})
			local checkLabel = make("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -24, 0, 50),
				Size = UDim2.fromOffset(20, 20),
				Text = "*",
				Font = Enum.Font.GothamBold,
				TextSize = 16,
				TextColor3 = palette.accent,
				Visible = false,
				Parent = btn,
			})
			state.themeButtons[name] = {
				button = btn,
				label = nameLabel,
				check = checkLabel,
				swatch = swatch,
				dots = { success = dotSuccess, warn = dotWarn, danger = dotDanger },
			}
			btn.MouseButton1Click:Connect(function()
				if name == "Custom" then
					openColorPicker()
					return
				end
				selectThemeName(name)
				if state.settingsThemeValueLabel then
					if name ~= currentThemeName() then
						state.settingsThemeValueLabel.Text = ("Theme: %s  ->  %s (press Save settings)"):format(currentThemeName(), name)
					else
						state.settingsThemeValueLabel.Text = "Theme: " .. name
					end
				end
				if settingsStatusLabel then
					settingsStatusLabel.Text = "Theme \"" .. name .. "\" selected. Press Save settings to apply it."
				end
			end)
		end
	end
	state.settingsCustomColorBtn = nil
	state.settingsThemeCycleBtn = nil
	refreshThemeSwatches()
end

function applyThemeColors()
	local th = theme()
	if not gui then
		return
	end
	updateBackdropBlur()

	if main then
		main.BackgroundColor3 = th.bg
		refreshMobileButtonTheme()
		if state.bgGradient and state.bgGradient.Parent then
			state.bgGradient.Color = backgroundGradientColors()
			state.bgGradient.Transparency = backgroundFadeSequence()
		end
		main.BackgroundTransparency = 0.2
	end
	if topbar then
		topbar.BackgroundColor3 = th.panel
		topbar.BackgroundTransparency = 0.28
	end
	if left then
		left.BackgroundColor3 = th.panel
		left.BackgroundTransparency = 0.22
	end
	if right then
		right.BackgroundColor3 = th.panel
		right.BackgroundTransparency = 0.22
	end
	if sidebar then
		sidebar.BackgroundColor3 = th.panel2
		sidebar.BackgroundTransparency = 0.3
	end
	if closeBtn then
		closeBtn.BackgroundColor3 = th.card
		closeBtn.BackgroundTransparency = 0.16
		closeBtn.TextColor3 = th.text
	end
	if resizeGrip then
		resizeGrip.BackgroundTransparency = 1
		if resizeGripIcon then
			resizeGripIcon.ImageColor3 = th.muted
			resizeGripIcon.ImageTransparency = 0.25
		end
	end
	if targetBox then
		targetBox.BackgroundColor3 = th.card
		targetBox.BackgroundTransparency = 0.1
		targetBox.TextColor3 = th.text
		targetBox.PlaceholderColor3 = th.muted
	end
	if resolveBtn then
		resolveBtn.BackgroundColor3 = th.panel2
		resolveBtn.BackgroundTransparency = 0.12
		if resolveBtn:IsA("ImageButton") then
			resolveBtn.ImageColor3 = th.text
		end
	end
	if viewNotesBtn then
		viewNotesBtn.BackgroundColor3 = th.panel2
		viewNotesBtn.BackgroundTransparency = 0.12
		viewNotesBtn.TextColor3 = th.text
	end
	if selectedName then selectedName.TextColor3 = th.text end
	if selectedInfo then selectedInfo.TextColor3 = th.muted end
	if statusLabel then statusLabel.TextColor3 = th.success end
	if titleLbl then titleLbl.TextColor3 = th.text end
	if state.dragHandleBar and state.dragHandleBar.Parent then
		state.dragHandleBar.BackgroundColor3 = th.muted
	end
	if state.sidebarToggleBtn and state.sidebarToggleBtn.Parent then
		state.sidebarToggleBtn.BackgroundColor3 = th.panel2
	end
	for btn, parts in pairs(state.sidebarButtons or {}) do
		if parts.fill and parts.fill.Parent then
			parts.fill.BackgroundColor3 = th.muted
		end
	end
	if state.sidebarDrag and state.sidebarDrag.active and state.sidebarDrag.btn then
		state.sidebarDrag.btn.BackgroundTransparency = 0
	end
	if state.sidebarToggleGlyph and state.sidebarToggleGlyph.Parent then
		state.sidebarToggleGlyph.ImageColor3 = th.icon
	end
	if state.sidebarToggleLabel and state.sidebarToggleLabel.Parent then
		state.sidebarToggleLabel.TextColor3 = th.muted
	end
	if state.chatUnreadDot and state.chatUnreadDot.Parent then
		local ring = state.chatUnreadDot:FindFirstChildOfClass("UIStroke")
		if ring then
			ring.Color = th.panel2
		end
	end
	for _, card in ipairs(state.chatPopupList or {}) do
		if card and card.Parent then
			card.BackgroundColor3 = th.card
			local cardAvatar = card:FindFirstChild("Avatar")
			if cardAvatar then cardAvatar.BackgroundColor3 = th.panel2 end
			local content = card:FindFirstChild("Content")
			if content then
				local sender = content:FindFirstChild("Sender")
				if sender then sender.TextColor3 = th.muted end
				local body = content:FindFirstChild("Body")
				if body then body.TextColor3 = th.text end
			end
			local closeBtn = card:FindFirstChild("Close")
			if closeBtn then
				closeBtn.BackgroundColor3 = th.panel2
				closeBtn.TextColor3 = th.text
			end
		end
	end
	if state.chatTabBtn then
		local chatActive = state.selectedTab == "chat"
		state.chatTabBtn.BackgroundColor3 = chatActive and th.accent or th.card
		state.chatTabBtn.BackgroundTransparency = chatActive and 0.02 or 0.08
		if state.chatTabBtn:IsA("ImageButton") then
			state.chatTabBtn.ImageColor3 = chatActive and th.onAccent or th.icon
		end
		local chatIcon = state.chatTabBtn:FindFirstChild("Icon")
		if chatIcon and chatIcon:IsA("ImageLabel") then
			chatIcon.ImageColor3 = chatActive and th.onAccent or th.icon
		end
		local chatLabel = state.chatTabBtn:FindFirstChild("Label")
		if chatLabel and chatLabel:IsA("TextLabel") then
			chatLabel.TextColor3 = chatActive and th.onAccent or th.text
		end
	end
	if state.chatScroll then
		state.chatScroll.ScrollBarImageColor3 = th.text
	end
	if state.chatStatusLabel then
		state.chatStatusLabel.TextColor3 = th.muted
	end
	if state.chatTypingLabel then
		state.chatTypingLabel.TextColor3 = th.muted
	end
	if state.chatInputBox then
		state.chatInputBox.BackgroundColor3 = th.card
		state.chatInputBox.TextColor3 = th.text
		state.chatInputBox.PlaceholderColor3 = th.muted
	end
	if state.chatSendBtn then
		state.chatSendBtn.BackgroundColor3 = th.panel2
		if state.chatSendBtn:IsA("ImageButton") then
			state.chatSendBtn.ImageColor3 = th.text
		elseif state.chatSendBtn:IsA("TextButton") then
			state.chatSendBtn.TextColor3 = th.text
		end
	end

	if codeFrame then
		codeFrame.BackgroundColor3 = th.bg
		codeFrame.BackgroundTransparency = 0.08
	end
	if codeText then
		codeText.BackgroundColor3 = th.panel2
		codeText.BackgroundTransparency = 0.1
		codeText.TextColor3 = th.text
		codeText.PlaceholderColor3 = th.muted
	end
	if codeConfirmBtn then
		codeConfirmBtn.BackgroundColor3 = th.accent
		codeConfirmBtn.BackgroundTransparency = 0.05
		codeConfirmBtn.TextColor3 = theme().onAccent
	end
	if codeCancelBtn then
		codeCancelBtn.BackgroundColor3 = th.panel2
		codeCancelBtn.BackgroundTransparency = 0.12
		codeCancelBtn.TextColor3 = th.text
	end
	if codeTitle then codeTitle.TextColor3 = th.text end

	if confirmFrame then
		confirmFrame.BackgroundColor3 = th.bg
		confirmFrame.BackgroundTransparency = 0.08
	end
	if confirmTitle then confirmTitle.TextColor3 = th.text end
	if confirmBody then confirmBody.TextColor3 = th.muted end
	if confirmYes then
		confirmYes.BackgroundColor3 = th.danger
		confirmYes.BackgroundTransparency = 0.05
		confirmYes.TextColor3 = Color3.fromRGB(255,255,255)
	end
	if confirmNo then
		confirmNo.BackgroundColor3 = th.panel2
		confirmNo.BackgroundTransparency = 0.12
		confirmNo.TextColor3 = th.text
	end

	if notesModalFrame then
		notesModalFrame.BackgroundColor3 = th.bg
		notesModalFrame.BackgroundTransparency = 0.08
	end
	if notesModalTitle then notesModalTitle.TextColor3 = th.text end
	if notesModalCloseBtn then
		notesModalCloseBtn.BackgroundColor3 = th.card
		notesModalCloseBtn.TextColor3 = th.text
	end
	if notesModalAddBox then
		notesModalAddBox.BackgroundColor3 = th.panel2
		notesModalAddBox.TextColor3 = th.text
		notesModalAddBox.PlaceholderColor3 = th.muted
	end
	if notesModalAddBtn then
		notesModalAddBtn.BackgroundColor3 = th.accent
		notesModalAddBtn.TextColor3 = theme().onAccent
	end

	if adminAddBox then
		adminAddBox.BackgroundColor3 = th.card
		adminAddBox.TextColor3 = th.text
		adminAddBox.PlaceholderColor3 = th.muted
	end
	if adminAddRankBox then
		adminAddRankBox.BackgroundColor3 = th.card
		adminAddRankBox.TextColor3 = th.text
	end
	if adminAddBtn then
		adminAddBtn.BackgroundColor3 = th.accent
		adminAddBtn.TextColor3 = theme().onAccent
	end

	for _, card in ipairs(infoCards) do
		if card and card.frame then
			card.frame.BackgroundColor3 = th.card
			card.frame.BackgroundTransparency = 0.05
			local st = card.frame:FindFirstChildOfClass("UIStroke")
			if st then
				st.Color = th.text
				st.Transparency = 0.92
			end
			if card.title then card.title.TextColor3 = th.muted end
			if card.value then card.value.TextColor3 = th.text end
			if card.iconBox then card.iconBox.BackgroundColor3 = th.panel2 end
			if card.glyph then card.glyph.ImageColor3 = th.icon end
		end
	end
	if state.targetData then
		refreshInfoCards()
	end
	if state.settingsThemeValueLabel then
		state.settingsThemeValueLabel.TextColor3 = th.text
	end
	if settingsSaveBtn then
		settingsSaveBtn.BackgroundColor3 = th.accent
		settingsSaveBtn.TextColor3 = th.onAccent
	end
	refreshPanicButton()
	refreshThemeSwatches()
	if state.settingsCustomColorBtn and state.settingsCustomColorBtn.Parent then
		state.settingsCustomColorBtn.BackgroundColor3 = th.panel2
		state.settingsCustomColorBtn.TextColor3 = th.text
	end
	if type(applyColorPickerTheme) == "function" then
		applyColorPickerTheme()
	end
	if settingsStatusLabel then
		settingsStatusLabel.TextColor3 = th.muted
	end
	if settingsInfoLabel then
		settingsInfoLabel.TextColor3 = th.muted
	end
	for _, btnRef in ipairs({ settingsWebhookToggle, settingsOpenInStartToggle, settingsRememberLastTabToggle, settingsStreamerModeToggle, settingsBlurToggle }) do
		if btnRef then
			btnRef.BackgroundColor3 = th.panel2
			btnRef.TextColor3 = th.text
		end
	end
	recolorSettingsSwitches()
	presenceRepaintDots()
	for _, tile in ipairs(state.serverStatCards or {}) do
		if tile.card and tile.card.Parent then
			tile.card.BackgroundColor3 = th.card
			tile.box.BackgroundColor3 = th.panel2
			tile.glyph.ImageColor3 = th.icon
			tile.label.TextColor3 = th.muted
			tile.value.TextColor3 = th.text
		end
	end
	if state.serverLoadCard and state.serverLoadCard.Parent then
		state.serverLoadCard.BackgroundColor3 = th.card
		state.serverLoadLabel.TextColor3 = th.text
		state.serverLoadTrack.BackgroundColor3 = th.panel2
		state.serverLoadNote.TextColor3 = th.muted
	end
	if state.serverDetailCard and state.serverDetailCard.Parent then
		state.serverDetailCard.BackgroundColor3 = th.card
		local dTitle = state.serverDetailCard:FindFirstChild("DetailTitle")
		if dTitle then
			dTitle.TextColor3 = th.text
		end
	end
	if settingsScroll then
		settingsScroll.ScrollBarImageColor3 = th.text
	end
	refreshThemeSwatches()
	if state.announceScroll then
		state.announceScroll.ScrollBarImageColor3 = th.text
	end
	if state.announceTitleLabel then state.announceTitleLabel.TextColor3 = th.text end
	if state.announceSubLabel then state.announceSubLabel.TextColor3 = th.muted end
	if state.announceStatusLabel then state.announceStatusLabel.TextColor3 = th.muted end
	if state.announceCard then
		state.announceCard.BackgroundColor3 = th.card
		local cst = state.announceCard:FindFirstChildOfClass("UIStroke")
		if cst then
			cst.Color = th.text
			cst.Transparency = 0.92
		end
		for _, child in ipairs(state.announceCard:GetChildren()) do
			if child:IsA("TextLabel") then
				child.TextColor3 = (child.TextSize >= 13) and th.text or th.muted
			end
		end
	end
	for _, box in ipairs({ state.announceMessageBox, state.announceVoteQuestionBox, state.announceVoteOption1Box, state.announceVoteOption2Box, state.announceTimerBox }) do
		if box and box.Parent then
			box.BackgroundColor3 = th.panel2
			box.TextColor3 = th.text
			box.PlaceholderColor3 = th.muted
		end
	end
	if state.announceSendBtn and state.announceSendBtn.Parent then
		state.announceSendBtn.BackgroundColor3 = th.accent
		state.announceSendBtn.TextColor3 = th.onAccent
	end
	for _, btn in ipairs({ state.announceVoteBtn, state.announceTimerStartBtn }) do
		if btn and btn.Parent then
			btn.BackgroundColor3 = th.panel2
			btn.TextColor3 = th.text
		end
	end
	if state.announceTimerStopBtn and state.announceTimerStopBtn.Parent then
		state.announceTimerStopBtn.BackgroundColor3 = th.danger
		state.announceTimerStopBtn.TextColor3 = th.text
	end

	if state.espButton and state.espButton.Parent then
		state.espButton.BackgroundColor3 = espEnabled() and th.accent or th.panel2
		state.espButton.TextColor3 = espEnabled() and th.onAccent or th.text
	end
	if serverScroll then
		serverScroll.ScrollBarImageColor3 = th.text
	end
	if serverTitleLabel then serverTitleLabel.TextColor3 = th.text end
	if serverRefreshLabel then serverRefreshLabel.TextColor3 = th.muted end
	if serverSummaryValue then serverSummaryValue.TextColor3 = th.muted end
	if state.serverUpdateCard and state.serverUpdateCard.Parent then
		state.serverUpdateCard.BackgroundColor3 = th.card
		if state.serverUpdateTitle then state.serverUpdateTitle.TextColor3 = th.text end
		for _, box in ipairs({ state.serverUpdateMessageBox, state.serverUpdateSecondsBox }) do
			if box and box.Parent then
				box.BackgroundColor3 = th.panel2
				box.TextColor3 = th.text
				box.PlaceholderColor3 = th.muted
			end
		end
		if state.serverUpdateThisBtn and state.serverUpdateThisBtn.Parent then
			state.serverUpdateThisBtn.BackgroundColor3 = th.accent
			state.serverUpdateThisBtn.TextColor3 = th.onAccent
		end
		if state.serverUpdateAllBtn and state.serverUpdateAllBtn.Parent then
			state.serverUpdateAllBtn.BackgroundColor3 = th.warn
		end
	end
	if serverStatusValue then serverStatusValue.TextColor3 = th.muted end
	if serverRegionValue then serverRegionValue.TextColor3 = th.muted end
	if state.refreshServerBtn and state.refreshServerBtn.Parent then
		state.refreshServerBtn.BackgroundColor3 = th.panel2
		if state.refreshServerBtn:IsA("TextButton") then
			state.refreshServerBtn.TextColor3 = th.text
		elseif state.refreshServerBtn:IsA("ImageButton") then
			state.refreshServerBtn.ImageColor3 = th.icon
		end
		local rst = state.refreshServerBtn:FindFirstChildOfClass("UIStroke")
		if rst then
			rst.Color = th.text
			rst.Transparency = 0.92
		end
	end
	for _, row in ipairs(serverRows or {}) do
		if type(row) == "table" and row.frame and row.frame.Parent then
			row.frame.BackgroundColor3 = th.card
			local st = row.frame:FindFirstChildOfClass("UIStroke")
			if st then
				st.Color = th.text
				st.Transparency = 0.92
			end
			if row.name then row.name.TextColor3 = th.text end
			if row.info then row.info.TextColor3 = th.muted end
			if row.selectBtn then
				row.selectBtn.BackgroundColor3 = th.panel2
				local isLocal = row.playerData and row.playerData.IsLocal
				row.selectBtn.TextColor3 = isLocal and th.warn or th.text
				local bst = row.selectBtn:FindFirstChildOfClass("UIStroke")
				if bst then
					bst.Color = th.text
					bst.Transparency = 0.92
				end
			end
		end
	end

	if gui then
		for _, inst in ipairs(gui:GetDescendants()) do
			if (inst:IsA("ImageButton") or inst:IsA("ImageLabel")) and not isInsideThemePicker(inst) then
				local parentBtn = inst:IsA("ImageButton") and inst or inst.Parent
				local onAccentSurface = false
				if parentBtn and parentBtn:IsA("GuiObject") then
					local bg = parentBtn.BackgroundColor3
					onAccentSurface = (colorKey(bg) == colorKey(th.accent))
				end
				if inst.Name ~= "Avatar" and inst.Name ~= "Thumbnail" and inst.Name ~= "Artwork" and inst.Image ~= "" then
					local isAvatar = tostring(inst.Image):find("Thumbs") ~= nil or tostring(inst.Image):find("avatar") ~= nil
					if not isAvatar then
						inst.ImageColor3 = onAccentSurface and th.onAccent or th.icon
					end
				end
			end
		end
	end

	if state.selectedTab == "credits" then
		refreshCreditsPanel()
	end

	if type(zoneAnnounceRefreshScope) == "function" then
		zoneAnnounceRefreshScope()
	end

	if type(applyGlowLook) == "function" then
		applyGlowLook()
	end
end

function rebuildVisibility()
	layoutForMode()
	updateHomeTargetVisibility(state.selectedTab or "home")
	applyThemeColors()
	buildActions()
	refreshInfoCards()
	syncTabButtons()
	if state.selectedTab == "admins" then
		updateAdminsList()
	elseif state.selectedTab == "credits" then
		refreshCreditsPanel()
	elseif state.selectedTab == "server" then
		refreshServerPanel()
	end
end

ZONE_ROLE_COLORS = { "#5aa9ff", "#57d98a", "#ffb84d", "#ff6b6b", "#c77dff", "#4dd8d8", "#ff9ecb", "#b0b8c4" }

function zoneRolesApply(list)
	table.clear(ZONE_ROLE_DATA)
	if type(list) == "table" then
		for _, def in ipairs(list) do
			if type(def) == "table" and type(def.name) == "string" then
				ZONE_ROLE_DATA[def.name] = {
					name = def.name,
					color = tostring(def.color or "#5aa9ff"),
					level = tonumber(def.level) or 10,
					actions = type(def.actions) == "table" and def.actions or {},
					tabs = type(def.tabs) == "table" and def.tabs or {},
				}
			end
		end
	end
	if type(zoneRankPickerRefresh) == "function" then
		zoneRankPickerRefresh()
	end
	zoneApplyRoleTabs()
	if type(zoneHomeApplyRoleLayout) == "function" then
		zoneHomeApplyRoleLayout()
	end
	if type(buildActions) == "function" then
		buildActions()
	end
	if type(refreshPanicButton) == "function" then
		refreshPanicButton()
	end
end

function zoneRoleTabButton(tabId)
	if tabId == "actions" then
		return state.sidebarActionsBtn
	elseif tabId == "server" then
		return sidebarServerBtn
	elseif tabId == "ban" then
		return sidebarBanBtn
	elseif tabId == "chat" then
		return state.chatTabBtn
	elseif tabId == "announce" then
		return sidebarAnnounceBtn
	elseif tabId == "moderation" then
		return state.sidebarModerationBtn
	end
	return nil
end

function zoneApplyRoleTabs()
	local def = zoneLocalRoleDef()
	for _, tabId in ipairs(ZONE_ROLE_TABS) do
		local btn = zoneRoleTabButton(tabId)
		if btn and btn.Parent then
			if def then
				btn.Visible = def.tabs and def.tabs[tabId] == true
			elseif tabId == "announce" then
				btn.Visible = canUseAnnounceTab()
			else
				btn.Visible = true
			end
		end
	end
	if def and state.selectedTab then
		for _, tabId in ipairs(ZONE_ROLE_TABS) do
			if tabId == state.selectedTab and not (def.tabs and def.tabs[tabId] == true) then
				if type(setTab) == "function" then
					setTab("home")
				end
				break
			end
		end
	end
	if type(resizeSidebarToContent) == "function" then
		task.defer(resizeSidebarToContent)
	end
end

function zoneRoleSetStatus(text, good)
	if state.roleStatusLabel and state.roleStatusLabel.Parent then
		state.roleStatusLabel.Text = tostring(text or "")
		state.roleStatusLabel.TextColor3 = good and Color3.fromRGB(90, 210, 130) or theme().muted
	end
end

function closeRoleEditor()
	if state.roleEditor and state.roleEditor.Parent then
		state.roleEditor:Destroy()
	end
	state.roleEditor = nil
	state.roleChecks = nil
	state.roleStatusLabel = nil
	RemoteEvent:FireServer("RoleList", nil, nil)
end

function zoneRoleCheckRow(parent, order, key, label, note, isTab)
	local th = theme()
	local row = make("TextButton", {
		Name = "RoleCheck_" .. tostring(key),
		LayoutOrder = order,
		Size = UDim2.new(1, -6, 0, 32),
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.2,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = 3103,
		Parent = parent,
	})
	corner(row, 8)

	local box = make("Frame", {
		Name = "Box",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromOffset(8, 16),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = th.accent,
		BorderSizePixel = 0,
		ZIndex = 3104,
		Parent = row,
	})
	corner(box, 5)
	stroke(box, 0.6)

	local tick = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "✓",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = th.onAccent,
		Visible = true,
		ZIndex = 3105,
		Parent = box,
	})

	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(34, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Text = note and (label .. "   <font color='#8a8f98'>" .. note .. "</font>") or label,
		RichText = true,
		Font = isTab and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3104,
		Parent = row,
	})

	state.roleChecks = state.roleChecks or { actions = {}, tabs = {} }
	local bucket = isTab and state.roleChecks.tabs or state.roleChecks.actions
	bucket[key] = true

	row.MouseButton1Click:Connect(function()
		local on = not bucket[key]
		bucket[key] = on
		tick.Visible = on
		box.BackgroundColor3 = on and theme().accent or theme().panel2
	end)
	return row
end

function zoneRoleSetAllChecks(value)
	local editor = state.roleEditor
	if not editor or not editor.Parent then
		return
	end
	for _, inst in ipairs(editor:GetDescendants()) do
		if inst:IsA("TextButton") and string.sub(tostring(inst.Name or ""), 1, 10) == "RoleCheck_" then
			local key = string.sub(inst.Name, 11)
			local box = inst:FindFirstChild("Box")
			local tick = box and box:FindFirstChildOfClass("TextLabel")
			local bucket = state.roleChecks.tabs[key] ~= nil and state.roleChecks.tabs or state.roleChecks.actions
			bucket[key] = value == true
			if tick then
				tick.Visible = value == true
			end
			if box then
				box.BackgroundColor3 = value and theme().accent or theme().panel2
			end
		end
	end
end

function openRoleEditor()
	if state.roleEditor then
		return
	end
	local th = theme()

	local overlay = make("TextButton", {
		Name = "RoleEditorOverlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.45,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = 3100,
		Parent = gui,
	})
	state.roleEditor = overlay

	local frame = make("Frame", {
		Name = "RoleEditorFrame",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(430, 470),
		BackgroundColor3 = th.bg,
		BorderSizePixel = 0,
		ZIndex = 3101,
		Parent = overlay,
	})
	corner(frame, 14)
	stroke(frame, 0.84)

	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 14),
		Size = UDim2.new(1, -60, 0, 22),
		Text = "Create custom rank",
		Font = Enum.Font.GothamBold,
		TextSize = 17,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3102,
		Parent = frame,
	})

	local closeBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 12),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = th.card,
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = th.text,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = 3103,
		Parent = frame,
	})
	corner(closeBtn, 8)
	closeBtn.MouseButton1Click:Connect(closeRoleEditor)

	local nameBox = make("TextBox", {
		Position = UDim2.fromOffset(18, 46),
		Size = UDim2.new(1, -36, 0, 34),
		BackgroundColor3 = th.card,
		Text = "",
		PlaceholderText = "Rank name (3-18 characters)",
		PlaceholderColor3 = th.muted,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = th.text,
		BorderSizePixel = 0,
		ZIndex = 3102,
		Parent = frame,
	})
	corner(nameBox, 10)
	stroke(nameBox, 0.9)
	padding(nameBox, 10, 0, 10, 0)

	state.roleColor = ZONE_ROLE_COLORS[1]
	local colorRow = make("Frame", {
		Position = UDim2.fromOffset(18, 88),
		Size = UDim2.new(1, -36, 0, 26),
		BackgroundTransparency = 1,
		ZIndex = 3102,
		Parent = frame,
	})
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = colorRow,
	})
	local swatches = {}
	for index, hex in ipairs(ZONE_ROLE_COLORS) do
		local sw = make("TextButton", {
			LayoutOrder = index,
			Size = UDim2.fromOffset(26, 26),
			BackgroundColor3 = hexToColor(hex) or Color3.fromRGB(90, 169, 255),
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			ZIndex = 3103,
			Parent = colorRow,
		})
		corner(sw, 13)
		local ring = stroke(sw, index == 1 and 0 or 0.85)
		swatches[hex] = ring
		sw.MouseButton1Click:Connect(function()
			state.roleColor = hex
			for key, other in pairs(swatches) do
				other.Transparency = (key == hex) and 0 or 0.85
			end
		end)
	end

	local allRow = make("Frame", {
		Position = UDim2.fromOffset(18, 122),
		Size = UDim2.new(1, -36, 0, 26),
		BackgroundTransparency = 1,
		ZIndex = 3102,
		Parent = frame,
	})
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = allRow,
	})

	local function smallBtn(order, text, onClick)
		local btn = make("TextButton", {
			LayoutOrder = order,
			Size = UDim2.fromOffset(96, 26),
			BackgroundColor3 = th.card,
			BackgroundTransparency = 0.15,
			Text = text,
			Font = Enum.Font.GothamSemibold,
			TextSize = 11,
			TextColor3 = th.text,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			ZIndex = 3103,
			Parent = allRow,
		})
		corner(btn, 8)
		stroke(btn, 0.9)
		btn.MouseButton1Click:Connect(onClick)
		return btn
	end

	smallBtn(1, "Check all", function()
		zoneRoleSetAllChecks(true)
	end)
	smallBtn(2, "Uncheck all", function()
		zoneRoleSetAllChecks(false)
	end)

	local scroll = make("ScrollingFrame", {
		Position = UDim2.fromOffset(18, 156),
		Size = UDim2.new(1, -36, 1, -218),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = th.text,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 3102,
		Parent = frame,
	})
	make("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = scroll,
	})

	state.roleChecks = { actions = {}, tabs = {} }

	local order = 0
	local function sectionTitle(text)
		order = order + 1
		make("TextLabel", {
			LayoutOrder = order,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -6, 0, 22),
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3103,
			Parent = scroll,
		})
	end

	sectionTitle("Panel tabs")
	for _, tabId in ipairs(ZONE_ROLE_TABS) do
		order = order + 1
		zoneRoleCheckRow(scroll, order, tabId, string.upper(string.sub(tabId, 1, 1)) .. string.sub(tabId, 2), nil, true)
	end

	sectionTitle("Commands")
	local actionNames = {}
	for actionName, requiredRank in pairs(ACTION_RULES) do
		if requiredRank ~= "Owner" then
			table.insert(actionNames, actionName)
		end
	end
	table.sort(actionNames)
	for _, actionName in ipairs(actionNames) do
		order = order + 1
		zoneRoleCheckRow(scroll, order, actionName, actionName, ACTION_RULES[actionName], false)
	end

	state.roleStatusLabel = make("TextLabel", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 18, 1, -52),
		Size = UDim2.new(1, -36, 0, 16),
		BackgroundTransparency = 1,
		Text = "Everything is ticked. Untick what this rank should not get.",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3102,
		Parent = frame,
	})

	local createBtn = make("TextButton", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 18, 1, -14),
		Size = UDim2.new(1, -36, 0, 34),
		BackgroundColor3 = th.accent,
		Text = "Create rank",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = th.onAccent,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = 3102,
		Parent = frame,
	})
	corner(createBtn, 10)
	createBtn.MouseButton1Click:Connect(function()
		local roleName = trim(nameBox.Text)
		if #roleName < 3 then
			zoneRoleSetStatus("Give the rank a name first.", false)
			return
		end
		local actions = {}
		local picked = 0
		for key, on in pairs(state.roleChecks.actions or {}) do
			if on then
				actions[key] = true
				picked = picked + 1
			end
		end
		if picked == 0 then
			zoneRoleSetStatus("Tick at least one command.", false)
			return
		end
		local tabs = {}
		for key, on in pairs(state.roleChecks.tabs or {}) do
			if on then
				tabs[key] = true
			end
		end
		RemoteEvent:FireServer("RoleCreate", {
			name = roleName,
			color = state.roleColor or ZONE_ROLE_COLORS[1],
			actions = actions,
			tabs = tabs,
		}, nil)
		zoneRoleSetStatus("Creating rank...", true)
		state.roleWaitToken = (tonumber(state.roleWaitToken) or 0) + 1
		local waitToken = state.roleWaitToken
		task.delay(8, function()
			if state.roleWaitToken ~= waitToken or not state.roleEditor then
				return
			end
			zoneRoleSetStatus("No answer from the server. Update the ServerScript to the matching version.", false)
		end)
	end)

	overlay.MouseButton1Click:Connect(closeRoleEditor)
end

function canUseAnnounceTab()
	local rank = tostring(getLocalAdminRank() or "")
	local roleTab = zoneLocalRoleTab("announce")
	if roleTab ~= nil then
		return roleTab
	end
	local order = RANK_ORDER[rank] or 0
	return order >= (RANK_ORDER.Admin or 80)
end

function buildAnnouncePanel()
	local th = theme()
	state.announceScroll = make("ScrollingFrame", {
		Name = "AnnounceScroll",
		Visible = false,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = th.text,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = right,
	})

	state.announceTitleLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -12, 0, 20),
		Text = "Announcements",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = state.announceScroll,
	})
	state.announceSubLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 22),
		Size = UDim2.new(1, -12, 0, 16),
		Text = "Broadcast a message to this server or every server, start a vote or run a timer.",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = state.announceScroll,
	})

	local card = make("Frame", {
		Name = "AnnounceCard",
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 46),
		Size = UDim2.new(1, -12, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = state.announceScroll,
	})
	corner(card, 12)
	stroke(card, 0.92)
	padding(card, 12, 12, 12, 12)
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = card,
	})
	state.announceCard = card

	local function sectionLabel(order, text)
		return make("TextLabel", {
			LayoutOrder = order,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextColor3 = th.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = card,
		})
	end

	local function inputBox(order, placeholder)
		local box = make("TextBox", {
			LayoutOrder = order,
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = th.panel2,
			Text = "",
			PlaceholderText = placeholder,
			ClearTextOnFocus = false,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = th.text,
			PlaceholderColor3 = th.muted,
			BorderSizePixel = 0,
			Parent = card,
		})
		corner(box, 8)
		stroke(box, 0.9)
		padding(box, 10, 0, 10, 0)
		return box
	end

	local function actionButton(order, text, colorKey)
		local btn = make("TextButton", {
			LayoutOrder = order,
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = th[colorKey] or th.accent,
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextColor3 = (colorKey == "accent") and th.onAccent or th.text,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Parent = card,
		})
		corner(btn, 10)
		stroke(btn, 0.9)
		return btn
	end

	sectionLabel(1, "Announcement")
	state.announceMessageBox = inputBox(2, "Type your announcement...")

	-- Seconds box + "This server" / "Global" switch.
	state.announceScope = state.announceScope or "server"
	local announceOptions = make("Frame", {
		LayoutOrder = 2.5,
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Parent = card,
	})
	state.announceSecondsBox = make("TextBox", {
		Size = UDim2.new(0, 110, 1, 0),
		BackgroundColor3 = th.panel2,
		Text = "",
		PlaceholderText = "Seconds",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = th.text,
		PlaceholderColor3 = th.muted,
		BorderSizePixel = 0,
		Parent = announceOptions,
	})
	corner(state.announceSecondsBox, 8)
	stroke(state.announceSecondsBox, 0.9)
	padding(state.announceSecondsBox, 10, 0, 10, 0)
	state.announceSecondsBox:GetPropertyChangedSignal("Text"):Connect(function()
		local digits = string.gsub(state.announceSecondsBox.Text, "%D", "")
		digits = string.sub(digits, 1, 3)
		if digits ~= state.announceSecondsBox.Text then
			state.announceSecondsBox.Text = digits
		end
	end)

	local function scopeButton(xScale, xOffset, label, scopeId)
		local btn = make("TextButton", {
			Position = UDim2.new(xScale, xOffset, 0, 0),
			Size = UDim2.new(0.5, -63, 1, 0),
			BackgroundColor3 = th.panel2,
			Text = label,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextColor3 = th.text,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Parent = announceOptions,
		})
		corner(btn, 8)
		stroke(btn, 0.9)
		btn.MouseButton1Click:Connect(function()
			state.announceScope = scopeId
			zoneAnnounceRefreshScope()
		end)
		return btn
	end
	state.announceScopeServerBtn = scopeButton(0, 118, "This server", "server")
	state.announceScopeGlobalBtn = scopeButton(0.5, 59, "Global", "global")

	state.announceSendBtn = actionButton(3, "Send Announcement", "accent")
	if type(zoneAnnounceRefreshScope) == "function" then
		zoneAnnounceRefreshScope()
	end

	make("Frame", {
		LayoutOrder = 4,
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = th.muted,
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		Parent = card,
	})

	sectionLabel(4.1, "Warn Player")
	state.announceWarnTargetBox = inputBox(4.2, "Username")
	state.announceWarnReasonBox = inputBox(4.3, "Warning reason")
	state.announceWarnBtn = actionButton(4.4, "Send Warning", "panel2")

	make("Frame", {
		LayoutOrder = 4.5,
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = th.muted,
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		Parent = card,
	})

	sectionLabel(5, "Vote (15 seconds)")
	state.announceVoteQuestionBox = inputBox(6, "Vote question")
	state.announceVoteOption1Box = inputBox(7, "Option 1")
	state.announceVoteOption2Box = inputBox(8, "Option 2")
	state.announceVoteBtn = actionButton(9, "Start Vote", "panel2")

	make("Frame", {
		LayoutOrder = 10,
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = th.muted,
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		Parent = card,
	})

	sectionLabel(11, "Admin Abuse Timer")
	state.announceTimerBox = inputBox(12, "Minutes")
	state.announceTimerStartBtn = actionButton(13, "Start Timer", "panel2")
	state.announceTimerStopBtn = actionButton(14, "Stop Timer", "danger")

	state.announceStatusLabel = make("TextLabel", {
		Visible = false,
		LayoutOrder = 15,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})

	local function announceSetStatus(text)
		if state.announceStatusLabel then
			state.announceStatusLabel.Text = tostring(text or "")
		end
	end

	local function submitWarn()
		local who = trim(state.announceWarnTargetBox.Text)
		local why = trim(state.announceWarnReasonBox.Text)
		if who == "" then
			announceSetStatus("Enter a username to warn.")
			return
		end
		if why == "" then
			announceSetStatus("Enter a warning reason.")
			return
		end
		RemoteEvent:FireServer("Warn", who, why)
		state.announceWarnReasonBox.Text = ""
		announceSetStatus(("Warning sent to %s."):format(who))
	end

	local function submitAnnounce()
		local text = trim(state.announceMessageBox.Text)
		if text == "" then
			announceSetStatus("Type a message first.")
			return
		end
		local seconds = tonumber(trim(state.announceSecondsBox and state.announceSecondsBox.Text or ""))
		local data = type(state.settingsData) == "table" and state.settingsData or {}
		if seconds then
			local minSeconds = tonumber(data.announceDisplayMin) or 3
			local maxSeconds = tonumber(data.announceDisplayMax) or 120
			if seconds < minSeconds or seconds > maxSeconds then
				announceSetStatus(("Seconds must be between %d and %d."):format(minSeconds, maxSeconds))
				if type(notify) == "function" then
					notify(("Seconds must be between %d and %d."):format(minSeconds, maxSeconds), false, 3)
				end
				return
			end
		end
		RemoteEvent:FireServer("Announce", nil, {
			text = text,
			seconds = seconds,
			scope = state.announceScope == "global" and "global" or "server",
		})
		state.announceMessageBox.Text = ""
		announceSetStatus("Sending announcement...")
	end

	local function submitVote()
		local q = trim(state.announceVoteQuestionBox.Text)
		local o1 = trim(state.announceVoteOption1Box.Text)
		local o2 = trim(state.announceVoteOption2Box.Text)
		if q == "" or o1 == "" or o2 == "" then
			announceSetStatus("Question and both options are required.")
			return
		end
		RemoteEvent:FireServer("StartVote", nil, { question = q, option1 = o1, option2 = o2 })
		state.announceVoteQuestionBox.Text = ""
		state.announceVoteOption1Box.Text = ""
		state.announceVoteOption2Box.Text = ""
		announceSetStatus("Starting vote...")
	end

	local function submitTimer()
		local minutes = tonumber(trim(state.announceTimerBox.Text))
		if not minutes or minutes < 1 then
			announceSetStatus("Enter a valid number of minutes.")
			return
		end
		RemoteEvent:FireServer("StartAbuseTimer", nil, { minutes = minutes })
		state.announceTimerBox.Text = ""
		announceSetStatus("Starting timer...")
	end

	state.announceWarnBtn.MouseButton1Click:Connect(submitWarn)
	state.announceSendBtn.MouseButton1Click:Connect(submitAnnounce)
	state.announceVoteBtn.MouseButton1Click:Connect(submitVote)
	state.announceTimerStartBtn.MouseButton1Click:Connect(submitTimer)

	state.announceTimerStopBtn.MouseButton1Click:Connect(function()
		RemoteEvent:FireServer("StopAbuseTimer", nil, {})
		announceSetStatus("Stopping timer...")
	end)

	local function submitOnEnter(box, handler)
		if not box or not handler then
			return
		end
		box.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				handler()
			end
		end)
	end

	submitOnEnter(state.announceMessageBox, submitAnnounce)
	submitOnEnter(state.announceWarnTargetBox, submitWarn)
	submitOnEnter(state.announceWarnReasonBox, submitWarn)
	submitOnEnter(state.announceVoteQuestionBox, submitVote)
	submitOnEnter(state.announceVoteOption1Box, submitVote)
	submitOnEnter(state.announceVoteOption2Box, submitVote)
	submitOnEnter(state.announceTimerBox, submitTimer)
end

function zoneAnnounceRefreshScope()
	local th = theme()
	local current = state.announceScope == "global" and "global" or "server"
	for scopeId, btn in pairs({ server = state.announceScopeServerBtn, global = state.announceScopeGlobalBtn }) do
		if btn and btn.Parent then
			local active = scopeId == current
			btn.BackgroundColor3 = active and th.accent or th.panel2
			btn.TextColor3 = active and (th.onAccent or th.text) or th.text
		end
	end
	if state.announceSecondsBox and state.announceSecondsBox.Parent then
		local data = type(state.settingsData) == "table" and state.settingsData or {}
		state.announceSecondsBox.PlaceholderText = ("Seconds (%d)"):format(tonumber(data.announceDisplaySeconds) or 15)
	end
end

function refreshAnnouncePanel()
	if state.announceStatusLabel then
		state.announceStatusLabel.Text = ""
	end
	if type(zoneAnnounceRefreshScope) == "function" then
		zoneAnnounceRefreshScope()
	end
end

function initAnnouncementGui()
	if not announceNotifySound then
		announceNotifySound = Instance.new("Sound")
		announceNotifySound.Name = "AnnounceNotifySound"
		announceNotifySound.SoundId = "rbxassetid://7383525713"
		announceNotifySound.Volume = 1
		announceNotifySound.Parent = game:GetService("SoundService")
	end

	local TOP_PADDING = 18
	local GAP = 8
	-- Default time an announcement stays on screen. The server sends the real
	-- value (ANNOUNCE_DISPLAY_SECONDS or the Seconds box) with each message.
	local NORMAL_DURATION = 15
	local function announceDefaultSeconds()
		local data = type(state.settingsData) == "table" and state.settingsData or nil
		return tonumber(data and data.announceDisplaySeconds) or NORMAL_DURATION
	end
	local MAX_VISIBLE = 6

	local activeNotifications = {}
	local voteState = nil
	local adminBubble = nil
	local adminVisible = false
	local adminTimerGui = nil
	local adminTimerState = nil
	local adminTimerHeartbeat = nil


	local adminTimerBubble = nil
	local adminTimerLabel = nil
	local adminTimerState = nil
	local adminTimerHeartbeat = nil
	local showAdminAbuseTimer
	local removeNotification

	local function formatCountdownTime(seconds)
		seconds = math.max(0, math.floor(tonumber(seconds) or 0))
		local hours = math.floor(seconds / 3600)
		local minutes = math.floor((seconds % 3600) / 60)
		local secs = seconds % 60
		if hours > 0 then
			return string.format("%d:%02d:%02d", hours, minutes, secs)
		end
		return string.format("%02d:%02d", minutes, secs)
	end

	local function clearAdminTimerGui()
		for i = #activeNotifications, 1, -1 do
			local data = activeNotifications[i]
			if data and data.kind == "adminTimer" then
				removeNotification(data)
			end
		end

		adminTimerState = nil

		if adminTimerHeartbeat then
			adminTimerHeartbeat:Disconnect()
			adminTimerHeartbeat = nil
		end

		adminTimerBubble = nil
		adminTimerLabel = nil
	end

	local function getHolderWidth()
		local cam = Workspace.CurrentCamera
		local viewportX = cam and cam.ViewportSize.X or 420
		return math.clamp(viewportX * 0.42, 300, 560)
	end

	local function escapeRichText(text)
		text = tostring(text)
		text = text:gsub("&", "&amp;")
		text = text:gsub("<", "&lt;")
		text = text:gsub(">", "&gt;")
		return text
	end

	local function getOrCreateUI()
		local screenGui = playerGui:FindFirstChild("AdminPanelAnnounceGui")
		if not screenGui then
			screenGui = Instance.new("ScreenGui")
			screenGui.Name = "AdminPanelAnnounceGui"
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.DisplayOrder = 999
			screenGui.Parent = playerGui
		end

		local holder = screenGui:FindFirstChild("NotificationHolder")
		if not holder then
			holder = Instance.new("Frame")
			holder.Name = "NotificationHolder"
			holder.BackgroundTransparency = 1
			holder.BorderSizePixel = 0
			holder.AnchorPoint = Vector2.new(0.5, 0)
			holder.Position = UDim2.new(0.5, 0, 0, TOP_PADDING)
			holder.Size = UDim2.new(0, getHolderWidth(), 1, -TOP_PADDING)
			holder.Parent = screenGui
		end

		return screenGui, holder
	end

	local function removeFromList(list, item)
		for i, v in ipairs(list) do
			if v == item then
				table.remove(list, i)
				return
			end
		end
	end

	local function findMatchingNotification(list, sender, message)
		for _, data in ipairs(list) do
			if tostring(data.sender) == tostring(sender) and tostring(data.message) == tostring(message) then
				return data
			end
		end
		return nil
	end

	local function profileThumbnail(imageLabel, senderUserId, senderName, senderImage)
		if not imageLabel then
			return
		end

		if typeof(senderImage) == "string" and senderImage ~= "" then
			imageLabel.Image = senderImage
			return
		end

		task.spawn(function()
			local thumb
			local ok = false

			if typeof(senderUserId) == "number" and senderUserId > 0 then
				ok, thumb = pcall(function()
					return Players:GetUserThumbnailAsync(senderUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
				end)
			end

			if (not ok or not thumb) and typeof(senderName) == "string" and senderName ~= "" then
				local okId, userId = pcall(function()
					return Players:GetUserIdFromNameAsync(senderName)
				end)
				if okId and userId then
					ok, thumb = pcall(function()
						return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
					end)
				end
			end

			if ok and thumb and imageLabel.Parent then
				imageLabel.Image = thumb
			end
		end)
	end

	local function buildNormalText(data)
		if data.isCoin then
			return tostring(data.message)
		end
		if data.isRestart then
			return tostring(data.message)
		end
		if data.isWarning then
			return "WARNING: " .. tostring(data.message)
		end
		local base = tostring(data.sender) .. ": " .. tostring(data.message)
		if data.count and data.count > 1 then
			base ..= " x" .. tostring(data.count)
		end
		return base
	end

	local function buildNormalRichText(data)
		if data.isCoin then
			return "<b><font color='#ffd45c'>" .. escapeRichText(data.message) .. "</font></b>"
		end
		if data.isRestart then
			return "<b>" .. escapeRichText(data.message) .. "</b>"
		end
		if data.isWarning then
			return "<b><font color='#ffaa3c'>WARNING</font></b>  " .. escapeRichText(data.message)
		end
		local senderTag = "<b><font color='#ffffff'>" .. escapeRichText(data.sender) .. "</font></b>"
		local countTag = ""
		if data.count and data.count > 1 then
			countTag = " <font color='#aaaaaa'>x" .. tostring(data.count) .. "</font>"
		end
		return senderTag .. ": " .. escapeRichText(data.message) .. countTag
	end

	local function getVotePercents(counts)
		local a = tonumber(counts and counts[1]) or 0
		local b = tonumber(counts and counts[2]) or 0
		local total = a + b
		if total <= 0 then
			return 0, 0, total
		end
		return (a / total) * 100, (b / total) * 100, total
	end

	local function getTopOffset()
		local offset = TOP_PADDING
		if adminBubble and adminBubble.Visible then
			offset += adminBubble.Size.Y.Offset + GAP
		end
		return offset
	end

	local function positionNotifications(animated)
		local _, holder = getOrCreateUI()
		holder.Position = UDim2.new(0.5, 0, 0, TOP_PADDING)
		holder.Size = UDim2.new(0, getHolderWidth(), 1, -TOP_PADDING)

		local y = TOP_PADDING

		if adminBubble and adminBubble.Visible then
			local targetAdmin = UDim2.new(0.5, 0, 0, y)
			if animated then
				TweenService:Create(adminBubble, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = targetAdmin
				}):Play()
			else
				adminBubble.Position = targetAdmin
			end
			y += adminBubble.Size.Y.Offset + GAP
		end

		for _, data in ipairs(activeNotifications) do
			if data.frame and data.frame.Parent then
				local target = UDim2.new(0.5, 0, 0, y)
				if animated then
					TweenService:Create(data.frame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = target
					}):Play()
				else
					data.frame.Position = target
				end
				y += data.frame.Size.Y.Offset + GAP
			end
		end
	end

	removeNotification = function(data)
		if data.closing or not data.frame or not data.frame.Parent then
			return
		end

		data.closing = true
		data.hovering = false

		if data.heartbeatConn then
			data.heartbeatConn:Disconnect()
			data.heartbeatConn = nil
		end

		removeFromList(activeNotifications, data)
		if data.kind == "vote" and voteState == data then
			voteState = nil
		end
		positionNotifications(true)

		local frame = data.frame
		local function safeTween(obj, props, ti)
			if obj then
				TweenService:Create(obj, ti or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), props):Play()
			end
		end

		safeTween(frame, { BackgroundTransparency = 1 })
		safeTween(data.stroke, { Transparency = 1 })
		safeTween(data.scale, { Scale = 0.95 })
		safeTween(data.profileImg, { ImageTransparency = 1 })
		safeTween(data.closeBtn, { ImageTransparency = 1 })
		safeTween(data.circleStroke, { Transparency = 1 })
		safeTween(data.barBG, { BackgroundTransparency = 1 })
		safeTween(data.bar, { BackgroundTransparency = 1 })
		safeTween(data.fillLeft, { BackgroundTransparency = 1 })
		safeTween(data.fillRight, { BackgroundTransparency = 1 })

		if data.label then
			safeTween(data.label, { TextTransparency = 1 })
		end

		if data.optionButtons then
			for _, btn in ipairs(data.optionButtons) do
				if btn and btn.Parent then
					safeTween(btn, { BackgroundTransparency = 1, TextTransparency = 1 })
				end
			end
		end

		local slideOut = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Size = UDim2.new(0, frame.Size.X.Offset, 0, 0)
		})
		slideOut:Play()

		task.delay(0.32, function()
			if frame and frame.Parent then
				frame:Destroy()
			end
		end)
	end

	local function clearVoteIfAny()
		for _, data in ipairs(activeNotifications) do
			if data.kind == "vote" then
				removeNotification(data)
				return
			end
		end
	end

	local function makeBaseBubble(parent, width, height)
		local frame = Instance.new("Frame")
		frame.Name = "NotifFrame"
		frame.Size = UDim2.new(0, width, 0, height)
		frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.ClipsDescendants = true
		frame.ZIndex = 1
		frame.Active = true
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.Position = UDim2.new(0.5, 0, 0, -12)
		frame.Parent = parent

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 14)
		corner.Parent = frame

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(70, 70, 70)
		stroke.Transparency = 1
		stroke.Thickness = 1
		stroke.Parent = frame

		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 8)
		padding.PaddingBottom = UDim.new(0, 8)
		padding.PaddingLeft = UDim.new(0, 45)
		padding.PaddingRight = UDim.new(0, 35)
		padding.Parent = frame

		local scale = Instance.new("UIScale")
		scale.Scale = 0.96
		scale.Parent = frame

		local profileImg = Instance.new("ImageLabel")
		profileImg.Name = "ProfileImage"
		profileImg.Size = UDim2.new(0, 26, 0, 26)
		profileImg.Position = UDim2.new(0, -35, 0.5, 0)
		profileImg.AnchorPoint = Vector2.new(0, 0.5)
		profileImg.BackgroundTransparency = 1
		profileImg.ImageTransparency = 1
		profileImg.Image = "rbxassetid://10416531341"
		profileImg.ZIndex = 2
		profileImg.Parent = frame

		local imgCorner = Instance.new("UICorner")
		imgCorner.CornerRadius = UDim.new(1, 0)
		imgCorner.Parent = profileImg

		local closeBtn = Instance.new("ImageButton")
		closeBtn.Name = "CloseButton"
		closeBtn.Size = UDim2.new(0, 16, 0, 16)
		closeBtn.Position = UDim2.new(1, 25, 0.5, 0)
		closeBtn.AnchorPoint = Vector2.new(1, 0.5)
		closeBtn.BackgroundTransparency = 1
		closeBtn.ImageTransparency = 1
		closeBtn.Image = "rbxassetid://132261474823036"
		closeBtn.ImageColor3 = Color3.fromRGB(180, 180, 180)
		closeBtn.ZIndex = 2
		closeBtn.Parent = frame

		local circle = Instance.new("Frame")
		circle.Size = UDim2.new(1.8, 0, 1.8, 0)
		circle.Position = UDim2.new(0.5, 0, 0.5, 0)
		circle.AnchorPoint = Vector2.new(0.5, 0.5)
		circle.BackgroundTransparency = 1
		circle.ZIndex = 2
		circle.Parent = closeBtn

		local circleCorner = Instance.new("UICorner")
		circleCorner.CornerRadius = UDim.new(1, 0)
		circleCorner.Parent = circle

		local circleStroke = Instance.new("UIStroke")
		circleStroke.Color = Color3.fromRGB(255, 255, 255)
		circleStroke.Thickness = 1.5
		circleStroke.Transparency = 1
		circleStroke.Parent = circle

		return frame, stroke, scale, profileImg, closeBtn, circleStroke
	end



	showAdminAbuseTimer = function(payload)
		if typeof(payload) ~= "table" then
			return
		end

		local endsAt = tonumber(payload.EndsAt)
		if not endsAt then
			clearAdminTimerGui()
			return
		end

		local remaining = math.max(0, math.floor(endsAt - os.time()))
		if remaining <= 0 then
			clearAdminTimerGui()
			return
		end

		for i = #activeNotifications, 1, -1 do
			local data = activeNotifications[i]
			if data and data.kind == "adminTimer" then
				removeNotification(data)
			end
		end

		local _, holder = getOrCreateUI()
		local text = "Admin Abuse: " .. formatCountdownTime(remaining)
		local textSize = TextService:GetTextSize(text, 14, Enum.Font.GothamBold, Vector2.new(getHolderWidth() - 32, 9999))
		local safeWidth = math.ceil(textSize.X) + 6
		local safeHeight = math.ceil(textSize.Y) + 2
		local frameWidth = math.max(140, safeWidth + 24)
		local frameHeight = safeHeight + 18

		local data = {
			kind = "adminTimer",
			sender = "Admin Abuse",
			senderUserId = tonumber(payload.StartedByUserId) or 0,
			message = formatCountdownTime(remaining),
			count = 1,
			remaining = remaining,
			closing = false,
			persistent = true,
			endsAt = endsAt,
			title = tostring(payload.Title or "Admin Abuse"),
		}

		local frame = Instance.new("Frame")
		frame.Name = "NotifFrame"
		frame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
		frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.ClipsDescendants = true
		frame.ZIndex = 1
		frame.Active = true
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.Position = UDim2.new(0.5, 0, 0, -12)
		frame.Parent = holder

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 14)
		corner.Parent = frame

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(70, 70, 70)
		stroke.Transparency = 1
		stroke.Thickness = 1
		stroke.Parent = frame

		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 8)
		padding.PaddingBottom = UDim.new(0, 8)
		padding.PaddingLeft = UDim.new(0, 12)
		padding.PaddingRight = UDim.new(0, 12)
		padding.Parent = frame

		local scale = Instance.new("UIScale")
		scale.Scale = 0.96
		scale.Parent = frame

		local label = Instance.new("TextLabel")
		label.Name = "MessageLabel"
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, 0, 1, 0)
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextTransparency = 1
		label.TextWrapped = true
		label.TextScaled = false
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.Font = Enum.Font.GothamBold
		label.TextSize = 14
		label.RichText = true
		label.Text = buildNormalRichText(data)
		label.ZIndex = 2
		label.Parent = frame

		data.frame = frame
		data.stroke = stroke
		data.scale = scale
		data.label = label
		data.profileImg = nil
		data.closeBtn = nil
		data.circleStroke = nil
		data.barBG = nil
		data.bar = nil

		TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.12 }):Play()
		TweenService:Create(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.25 }):Play()
		TweenService:Create(label, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
		TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()

		if voteState then
			table.insert(activeNotifications, 2, data)
		else
			table.insert(activeNotifications, 1, data)
		end
		positionNotifications(true)

		frame.MouseEnter:Connect(function() data.hovering = true end)
		frame.MouseLeave:Connect(function() data.hovering = false end)

		data.heartbeatConn = RunService.Heartbeat:Connect(function(dt)
			if not data.frame or not data.frame.Parent or data.closing then
				return
			end

			local remainingNow = math.max(0, math.floor((tonumber(data.endsAt) or os.time()) - os.time()))
			data.remaining = remainingNow
			data.message = formatCountdownTime(remainingNow)
			if data.label then
				data.label.Text = buildNormalRichText(data)
			end
			if remainingNow <= 0 then
				clearAdminTimerGui()
			end
		end)
	end

	local function showNormalNotification(data)
		local _, holder = getOrCreateUI()
		data.kind = "normal"
		data.duration = tonumber(data.duration) or announceDefaultSeconds()
		data.remaining = data.duration
		data.hovering = false
		data.closing = false

		local fontSize = data.isWarning and 28 or 14
		local maxTextWidth = getHolderWidth() - (data.isWarning and 40 or 88)
		local textSize = TextService:GetTextSize(buildNormalText(data), fontSize, Enum.Font.GothamBold, Vector2.new(maxTextWidth, 9999))
		local safeWidth = math.ceil(textSize.X) + 6
		local safeHeight = math.ceil(textSize.Y) + 2
		local frameWidth = math.max(140, safeWidth + (data.isWarning and 32 or 84))
		local frameHeight = safeHeight + 18

		local frame, stroke, scale, profileImg, closeBtn, circleStroke = makeBaseBubble(holder, frameWidth, frameHeight)
		if data.isCoin and profileImg then
			local round = profileImg:FindFirstChildOfClass("UICorner")
			if round then
				round:Destroy()
			end
			profileImg.BackgroundTransparency = 1
			profileImg.ScaleType = Enum.ScaleType.Fit
			if circleStroke then
				circleStroke.Enabled = false
			end
		end
		data.frame = frame
		data.stroke = stroke
		data.scale = scale
		data.profileImg = profileImg
		data.closeBtn = closeBtn
		data.circleStroke = circleStroke

		local label = Instance.new("TextLabel")
		label.Name = "MessageLabel"
		label.BackgroundTransparency = 1
		label.Size = data.isWarning and UDim2.new(1, 0, 0, safeHeight) or UDim2.new(0, safeWidth, 0, safeHeight)
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextTransparency = 1
		label.TextWrapped = true
		label.TextScaled = false
		label.TextXAlignment = data.isWarning and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.Font = Enum.Font.GothamBold
		label.TextSize = fontSize
		label.RichText = true
		label.Text = buildNormalRichText(data)
		label.ZIndex = 2
		label.Parent = frame
		data.label = label

		local barBG = Instance.new("Frame")
		barBG.Name = "ProgressBarBG"
		barBG.Size = UDim2.new(1, 0, 0, 3)
		barBG.Position = UDim2.new(0, 0, 1, -3)
		barBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		barBG.BackgroundTransparency = 0.35
		barBG.BorderSizePixel = 0
		barBG.ZIndex = 2
		barBG.Parent = frame
		data.barBG = barBG

		local bar = Instance.new("Frame")
		bar.Name = "ProgressBar"
		bar.Size = UDim2.new(1, 0, 1, 0)
		bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		bar.BackgroundTransparency = 0.15
		bar.BorderSizePixel = 0
		bar.ZIndex = 3
		bar.Parent = barBG
		data.bar = bar

		TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.12 }):Play()
		TweenService:Create(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.25 }):Play()
		TweenService:Create(label, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
		TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		TweenService:Create(profileImg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
		TweenService:Create(closeBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
		TweenService:Create(circleStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.5 }):Play()

		if voteState then
			table.insert(activeNotifications, 2, data)
		else
			table.insert(activeNotifications, 1, data)
		end
		positionNotifications(true)

		if data.isWarning then
			profileImg.Visible = false
			circleStroke.Enabled = false
			closeBtn.Visible = false
			closeBtn.Active = false
			local pad = frame:FindFirstChildOfClass("UIPadding")
			if pad then
				pad.PaddingLeft = UDim.new(0, 16)
				pad.PaddingRight = UDim.new(0, 16)
			end
			stroke.Color = Color3.fromRGB(255, 170, 60)
			bar.BackgroundColor3 = Color3.fromRGB(255, 170, 60)

			task.spawn(function()
				local flashEnd = os.clock() + 5
				local bright = Color3.fromRGB(255, 170, 60)
				local dim = Color3.fromRGB(120, 60, 0)
				local on = true
				while os.clock() < flashEnd do
					if not frame or not frame.Parent then
						return
					end
					stroke.Color = on and bright or dim
					stroke.Thickness = on and 3 or 1
					stroke.Transparency = on and 0 or 0.5
					frame.BackgroundColor3 = on and Color3.fromRGB(74, 42, 6) or Color3.fromRGB(28, 28, 28)
					label.TextColor3 = on and Color3.fromRGB(255, 235, 200) or Color3.fromRGB(255, 255, 255)
					on = not on
					task.wait(0.16)
				end
				if frame and frame.Parent then
					stroke.Color = bright
					stroke.Thickness = 1
					stroke.Transparency = 0.25
					frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
					label.TextColor3 = Color3.fromRGB(255, 255, 255)
				end
			end)
		else
			profileThumbnail(profileImg, data.senderUserId, data.sender, data.senderImage)
			closeBtn.MouseButton1Click:Connect(function() removeNotification(data) end)
		end

		frame.MouseEnter:Connect(function() data.hovering = true end)
		frame.MouseLeave:Connect(function() data.hovering = false end)
		closeBtn.MouseEnter:Connect(function() closeBtn.ImageColor3 = Color3.fromRGB(255, 100, 100) end)
		closeBtn.MouseLeave:Connect(function() closeBtn.ImageColor3 = Color3.fromRGB(180, 180, 180) end)

		data.heartbeatConn = RunService.Heartbeat:Connect(function(dt)
			if not data.frame or not data.frame.Parent or data.closing then
				return
			end
			if not data.hovering then
				data.remaining = math.max(0, data.remaining - dt)
			end
			if data.bar then
				local span = tonumber(data.duration) or NORMAL_DURATION
				data.bar.Size = UDim2.new(math.clamp(data.remaining / span, 0, 1), 0, 1, 0)
			end
			if data.remaining <= 0 then
				removeNotification(data)
			end
		end)
	end

	local function updateVoteBubble(data, mode)
		if not data.frame or not data.frame.Parent then
			return
		end

		local counts = data.counts or { 0, 0 }
		local options = data.options or { "Option A", "Option B" }
		local a = tonumber(counts[1]) or 0
		local b = tonumber(counts[2]) or 0
		local total = a + b
		local aPercent = total > 0 and ((a / total) * 100) or 0
		local bPercent = total > 0 and ((b / total) * 100) or 0
		local remaining = math.max(0, (tonumber(data.endsAt) or os.time()) - os.time())

		local title = data.frame:FindFirstChild("VoteTitle")
		local timer = data.frame:FindFirstChild("Timer")
		local leftLabel = data.frame:FindFirstChild("LeftLabel")
		local rightLabel = data.frame:FindFirstChild("RightLabel")
		local fillLeft = data.fillLeft
		local fillRight = data.fillRight
		local divider = data.divider
		local winnerLabel = data.frame:FindFirstChild("WinnerLabel")

		if title then
			title.Text = tostring(data.question or "Vote")
		end
		if timer then
			timer.Text = "(" .. tostring(remaining) .. "s)"
		end

		if mode == "timerOnly" then
			if winnerLabel then
				if data.voteEnded then
					local winnerText = data.winner or "No winner"
					if winnerText == "Draw" then
						if a > b then
							winnerText = tostring(options[1] or "Option A")
						elseif b > a then
							winnerText = tostring(options[2] or "Option B")
						end
					end
					winnerLabel.Text = "Winner: " .. tostring(winnerText)
				else
					winnerLabel.Text = ""
				end
			end
			return
		end

		if leftLabel then
			leftLabel.Text = tostring(options[1] or "Option A") .. " - " .. tostring(a) .. " (" .. string.format("%.0f", aPercent) .. "%)"
		end
		if rightLabel then
			rightLabel.Text = tostring(options[2] or "Option B") .. " - " .. tostring(b) .. " (" .. string.format("%.0f", bPercent) .. "%)"
		end

		local leftScale = math.clamp(aPercent / 100, 0, 1)
		local rightScale = math.clamp(bPercent / 100, 0, 1)

		if fillLeft then
			fillLeft.Size = UDim2.new(leftScale, 0, 1, 0)
		end
		if fillRight then
			fillRight.Size = UDim2.new(rightScale, 0, 1, 0)
			fillRight.Position = UDim2.new(leftScale, 0, 0, 0)
		end
		if divider then
			divider.Position = UDim2.new(leftScale, -1, 0, 0)
		end

		if winnerLabel then
			if data.voteEnded then
				local winnerText = data.winner or "No winner"
				if winnerText == "Draw" then
					if a > b then
						winnerText = tostring(options[1] or "Option A")
					elseif b > a then
						winnerText = tostring(options[2] or "Option B")
					end
				end
				winnerLabel.Text = "Winner: " .. tostring(winnerText)
			else
				winnerLabel.Text = ""
			end
		end
	end

	local function showVoteNotification(payload)
		clearVoteIfAny()

		local _, holder = getOrCreateUI()
		local frameWidth = math.clamp(getHolderWidth(), 300, 560)

		local data = {
			kind = "vote",
			voteId = tostring(payload.VoteId or ""),
			sender = tostring(payload.Sender or "System"),
			senderUserId = payload.SenderUserId,
			question = tostring(payload.Question or "Vote"),
			options = payload.Options or { "Option A", "Option B" },
			counts = payload.Counts or { 0, 0 },
			endsAt = tonumber(payload.EndsAt) or os.time(),
			remaining = tonumber(payload.Duration) or 15,
			duration = tonumber(payload.Duration) or 15,
			voteEnded = false,
			winner = nil,
			closing = false,
			optionButtons = {},
		}

		local frame, stroke, scale, profileImg, closeBtn, circleStroke = makeBaseBubble(holder, frameWidth, 186)
		data.frame = frame
		data.stroke = stroke
		data.scale = scale
		data.profileImg = profileImg
		data.closeBtn = closeBtn
		data.circleStroke = circleStroke

		local senderLabel = Instance.new("TextLabel")
		senderLabel.Name = "SenderLabel"
		senderLabel.BackgroundTransparency = 1
		senderLabel.Size = UDim2.new(1, -70, 0, 16)
		senderLabel.Position = UDim2.new(0, 0, 0, 0)
		senderLabel.Font = Enum.Font.GothamBold
		senderLabel.TextSize = 14
		senderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		senderLabel.TextXAlignment = Enum.TextXAlignment.Left
		senderLabel.Text = tostring(data.sender)
		senderLabel.ZIndex = 2
		senderLabel.Parent = frame

		local title = Instance.new("TextLabel")
		title.Name = "VoteTitle"
		title.BackgroundTransparency = 1
		title.Size = UDim2.new(1, 0, 0, 20)
		title.Position = UDim2.new(0, 0, 0, 22)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 18
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		title.TextXAlignment = Enum.TextXAlignment.Center
		title.Text = tostring(data.question)
		title.ZIndex = 2
		title.Parent = frame

		local timer = Instance.new("TextLabel")
		timer.Name = "Timer"
		timer.BackgroundTransparency = 1
		timer.Size = UDim2.new(1, 0, 0, 16)
		timer.Position = UDim2.new(0, 0, 0, 46)
		timer.Font = Enum.Font.GothamBold
		timer.TextSize = 13
		timer.TextColor3 = Color3.fromRGB(220, 220, 220)
		timer.TextXAlignment = Enum.TextXAlignment.Center
		timer.Text = "(" .. tostring(data.duration) .. "s)"
		timer.ZIndex = 2
		timer.Parent = frame

		local barBack = Instance.new("Frame")
		barBack.Name = "VoteBarBack"
		barBack.Size = UDim2.new(1, -14, 0, 14)
		barBack.Position = UDim2.new(0, 7, 0, 68)
		barBack.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
		barBack.BackgroundTransparency = 0.05
		barBack.BorderSizePixel = 0
		barBack.ClipsDescendants = true
		barBack.ZIndex = 2
		barBack.Parent = frame

		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(0, 7)
		barCorner.Parent = barBack

		local fillLeft = Instance.new("Frame")
		fillLeft.Name = "FillLeft"
		fillLeft.BackgroundColor3 = Color3.fromRGB(255, 56, 56)
		fillLeft.BorderSizePixel = 0
		fillLeft.Size = UDim2.new(0.5, 0, 1, 0)
		fillLeft.ZIndex = 3
		fillLeft.Parent = barBack

		local fillRight = Instance.new("Frame")
		fillRight.Name = "FillRight"
		fillRight.BackgroundColor3 = Color3.fromRGB(56, 128, 255)
		fillRight.BorderSizePixel = 0
		fillRight.Size = UDim2.new(0.5, 0, 1, 0)
		fillRight.Position = UDim2.new(0.5, 0, 0, 0)
		fillRight.ZIndex = 3
		fillRight.Parent = barBack

		local divider = Instance.new("Frame")
		divider.Name = "VoteDivider"
		divider.Size = UDim2.new(0, 2, 1, 0)
		divider.Position = UDim2.new(0.5, -1, 0, 0)
		divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		divider.BackgroundTransparency = 0.15
		divider.BorderSizePixel = 0
		divider.ZIndex = 4
		divider.Parent = barBack

		local dividerCorner = Instance.new("UICorner")
		dividerCorner.CornerRadius = UDim.new(1, 0)
		dividerCorner.Parent = divider

		data.fillLeft = fillLeft
		data.fillRight = fillRight
		data.divider = divider

		local leftLabel = Instance.new("TextLabel")
		leftLabel.Name = "LeftLabel"
		leftLabel.BackgroundTransparency = 1
		leftLabel.Size = UDim2.new(0.5, -6, 0, 16)
		leftLabel.Position = UDim2.new(0, 7, 0, 92)
		leftLabel.Font = Enum.Font.GothamBold
		leftLabel.TextSize = 13
		leftLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		leftLabel.TextXAlignment = Enum.TextXAlignment.Left
		leftLabel.Text = "Option A - 0"
		leftLabel.ZIndex = 2
		leftLabel.Parent = frame

		local rightLabel = Instance.new("TextLabel")
		rightLabel.Name = "RightLabel"
		rightLabel.BackgroundTransparency = 1
		rightLabel.Size = UDim2.new(0.5, -6, 0, 16)
		rightLabel.Position = UDim2.new(0.5, 0, 0, 92)
		rightLabel.Font = Enum.Font.GothamBold
		rightLabel.TextSize = 13
		rightLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		rightLabel.TextXAlignment = Enum.TextXAlignment.Right
		rightLabel.Text = "Option B - 0"
		rightLabel.ZIndex = 2
		rightLabel.Parent = frame

		local winnerLabel = Instance.new("TextLabel")
		winnerLabel.Name = "WinnerLabel"
		winnerLabel.BackgroundTransparency = 1
		winnerLabel.Size = UDim2.new(1, 0, 0, 16)
		winnerLabel.Position = UDim2.new(0, 0, 0, 112)
		winnerLabel.Font = Enum.Font.GothamBold
		winnerLabel.TextSize = 13
		winnerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		winnerLabel.TextXAlignment = Enum.TextXAlignment.Center
		winnerLabel.Text = ""
		winnerLabel.ZIndex = 2
		winnerLabel.Parent = frame

		local buttonsHolder = Instance.new("Frame")
		buttonsHolder.Name = "ButtonsHolder"
		buttonsHolder.BackgroundTransparency = 1
		buttonsHolder.Size = UDim2.new(1, -14, 0, 34)
		buttonsHolder.Position = UDim2.new(0, 7, 0, 136)
		buttonsHolder.ZIndex = 2
		buttonsHolder.Parent = frame

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.Padding = UDim.new(0, 10)
		layout.Parent = buttonsHolder

		local colors = {
			Color3.fromRGB(255, 56, 56),
			Color3.fromRGB(56, 128, 255),
		}

		for i = 1, 2 do
			local option = data.options[i] or (i == 1 and "Option A" or "Option B")
			local btn = Instance.new("TextButton")
			btn.Name = tostring(i)
			btn.Size = UDim2.new(0.5, -5, 0, 32)
			btn.BackgroundColor3 = colors[i]
			btn.BorderSizePixel = 0
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.TextSize = 14
			btn.Font = Enum.Font.GothamBold
			btn.Text = tostring(option)
			btn.ZIndex = 3
			btn.Parent = buttonsHolder

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 8)
			btnCorner.Parent = btn

			btn.MouseButton1Click:Connect(function()
				if data.voteId and not data.voteEnded then
					state.AnnounceVoteRE:FireServer(data.voteId, i)
				end
			end)

			data.optionButtons[i] = btn
		end

		profileThumbnail(profileImg, data.senderUserId, data.sender, data.senderImage)

		TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.12 }):Play()
		TweenService:Create(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.25 }):Play()
		TweenService:Create(profileImg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
		TweenService:Create(closeBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
		TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		TweenService:Create(circleStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.5 }):Play()

		voteState = data
		table.insert(activeNotifications, 1, data)
		positionNotifications(true)
		updateVoteBubble(data)

		frame.MouseEnter:Connect(function() data.hovering = true end)
		frame.MouseLeave:Connect(function() data.hovering = false end)
		closeBtn.MouseButton1Click:Connect(function() removeNotification(data) end)
		closeBtn.MouseEnter:Connect(function() closeBtn.ImageColor3 = Color3.fromRGB(255, 100, 100) end)
		closeBtn.MouseLeave:Connect(function() closeBtn.ImageColor3 = Color3.fromRGB(180, 180, 180) end)

		data.heartbeatConn = RunService.Heartbeat:Connect(function(dt)
			if not data.frame or not data.frame.Parent or data.closing then
				return
			end

			if not data.voteEnded then
				data.remaining = math.max(0, data.remaining - dt)
				updateVoteBubble(data)
				if data.remaining <= 0 then
					data.voteEnded = true
					data.endHold = 1.5
					updateVoteBubble(data)
				end
			else
				data.endHold = math.max(0, (data.endHold or 0) - dt)
				if data.endHold <= 0 then
					removeNotification(data)
				end
			end
		end)
	end

	local function showVoteEndBubble(payload)
		showNormalNotification({
			sender = tostring(payload.Sender or "System"),
			senderUserId = payload.SenderUserId,
			message = "Voting ended: " .. tostring(payload.Question or "Vote") .. " | Winner: " .. tostring(payload.Winner or "None"),
			count = 1,
			duration = tonumber(payload.DisplaySeconds) or announceDefaultSeconds(),
			hovering = false,
			closing = false,
		})
	end

	function announceHandleIncoming(payload)
		if typeof(payload) ~= "table" then
			return false
		end

		local kind = tostring(payload.Kind or "Announcement")

		if kind == "AdminAbuseTimerStart" or kind == "AdminAbuseTimerSync" then
			showAdminAbuseTimer(payload)
			return true
		end

		if kind == "AdminAbuseTimerStop" then
			clearAdminTimerGui()
			return true
		end

		if kind == "VoteStart" then
			showVoteNotification(payload)
			return true
		end

		if kind == "VoteUpdate" then
			for _, data in ipairs(activeNotifications) do
				if data.kind == "vote" and data.voteId == tostring(payload.VoteId or "") then
					data.counts = payload.Counts or data.counts
					data.options = payload.Options or data.options
					data.endsAt = tonumber(payload.EndsAt) or data.endsAt
					updateVoteBubble(data)
					break
				end
			end
			return true
		end

		if kind == "VoteEnd" then
			for _, data in ipairs(activeNotifications) do
				if data.kind == "vote" and data.voteId == tostring(payload.VoteId or "") then
					data.counts = payload.Counts or data.counts
					data.options = payload.Options or data.options
					data.winner = payload.Winner or data.winner
					data.voteEnded = true
					data.remaining = 0
					data.endHold = 1.5
					updateVoteBubble(data)
					break
				end
			end
			showVoteEndBubble(payload)
			return true
		end

		showNormalNotification({
			sender = tostring(payload.Sender or "System"),
			senderUserId = payload.SenderUserId,
			message = tostring(payload.Message or ""),
			count = 1,
			duration = tonumber(payload.DisplaySeconds) or announceDefaultSeconds(),
			hovering = false,
			closing = false,
		})
		return false
	end

	RunService.RenderStepped:Connect(function()
		positionNotifications(false)
	end)

	announceShowWarning = function(message)
		showNormalNotification({
			sender = "Warning",
			senderUserId = nil,
			message = tostring(message or ""),
			count = 1,
			duration = 45,
			isWarning = true,
			hovering = false,
			closing = false,
		})
	end

	announceShowRestart = function(message, seconds)
		showNormalNotification({
			sender = "Server",
			senderUserId = nil,
			message = tostring(message or "Updating"),
			count = 1,
			duration = math.clamp(tonumber(seconds) or 15, 3, 300),
			isWarning = true,
			isRestart = true,
			hovering = false,
			closing = false,
		})
	end
end

initAnnouncementGui()

function canUseServerUpdate()
	local rank = tostring(getLocalAdminRank() or "")
	local def = zoneRoleDef(rank)
	if def then
		return def.actions and def.actions.ServerRestart == true
	end
	return (RANK_ORDER[rank] or 0) >= (RANK_ORDER.Owner or 100)
end

function refreshServerUpdateCard()
	local allowed = canUseServerUpdate()
	if state.serverUpdateCard and state.serverUpdateCard.Parent then
		state.serverUpdateCard.Visible = allowed
	end
	if state.serverPlayersTitle and state.serverPlayersTitle.Parent then
		state.serverPlayersTitle.Position = UDim2.fromOffset(0, allowed and 512 or 346)
	end
	if serverPlayersHolder and serverPlayersHolder.Parent then
		serverPlayersHolder.Position = UDim2.fromOffset(0, allowed and 536 or 370)
	end
end

function sendServerUpdate(everywhere)
	if not canUseServerUpdate() then
		setStatus("Only the owner can run a server update.", false)
		return
	end
	local message = trim(state.serverUpdateMessageBox and state.serverUpdateMessageBox.Text or "")
	local seconds = math.clamp(math.floor(tonumber(state.serverUpdateSecondsBox and state.serverUpdateSecondsBox.Text or "") or 15), 0, 300)
	if message == "" then
		message = "Updating"
	end
	local payload = ("%d %s"):format(seconds, message)
	RemoteEvent:FireServer(everywhere and "ServerUpdateAll" or "ServerRestart", payload, payload)
	setStatus(everywhere and ("Update sent to every server (%d s)."):format(seconds) or ("This server restarts in %d s."):format(seconds), true)
	notify(everywhere and "Server update sent to all servers." or "Server update started.", true, 4)
end

function canUsePanic()
	local rank = tostring(getLocalAdminRank() or "")
	local def = zoneRoleDef(rank)
	if def then
		return def.actions and def.actions.PanicLock == true
	end
	return (RANK_ORDER[rank] or 0) >= (RANK_ORDER.Admin or 80)
end

function refreshPanicButton()
	if type(refreshServerUpdateCard) == "function" then
		refreshServerUpdateCard()
	end
	local btn = state.panicBtn
	if not btn or not btn.Parent then
		return
	end
	local locked = state.panicActive == true
	btn.Visible = canUsePanic()
	btn.Text = locked and "UNLOCK SERVER" or "PANIC - LOCK SERVER"
	btn.BackgroundColor3 = locked and Color3.fromRGB(40, 150, 80) or Color3.fromRGB(200, 45, 45)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	if state.panicHint and state.panicHint.Parent then
		if locked then
			registerLangText(state.panicHint, function() return ZoneT("lock.title") .. (state.panicBy ~= "" and (ZoneT("lock.hintBy") .. tostring(state.panicBy)) or "") .. ZoneT("lock.hintUnlock") end)
			state.panicHint.TextColor3 = Color3.fromRGB(255, 170, 90)
		else
			registerLangText(state.panicHint, "lock.note")
			state.panicHint.TextColor3 = theme().muted
		end
	end
end

function resetSettingsToDefaults()
	if settingsBusy then
		return
	end
	settingsBusy = true
	state.settingsLoadToken = (state.settingsLoadToken or 0) + 1
	if settingsStatusLabel then
		settingsStatusLabel.Text = "Resetting..."
	end
	local payload = {
		animationOn = true,
		openInStart = true,
		rememberLastTab = true,
		streamerMode = false,
		blurBackground = false,
		saveSidebarOrder = true,
		confirmActions = true,
		aiConfirmActions = true,
		backgroundImage = false,
		chatPopups = true,
		animatedBackground = false,
		mobileButton = true,
		mobileButtonPosition = "",
		glowEffect = true,
		glowStrength = 40,
		theme = DEFAULT_THEME_NAME,
		customAccent = "00DCFF",
		globalCommands = false,
		autoTranslateChat = false,
		language = "auto",
		backgroundStyle = "stripes",
		lastTab = "home",
		sidebarOrder = {},
		sidebarOrderText = "",
	}
	local ok, res = pcall(function()
		return SettingsRF:InvokeServer("set", payload)
	end)
	settingsBusy = false
	if not ok or type(res) ~= "table" or res.ok ~= true then
		if settingsStatusLabel then
			settingsStatusLabel.Text = "Reset failed. Check that API Services are enabled."
		end
		return
	end

	state.settingsLoadToken = (state.settingsLoadToken or 0) + 1
	state.settingsData = normalizeSettingsPayload(res)
	if type(applySavedMobileButtonPosition) == "function" then applySavedMobileButtonPosition() end
	resetMobileButtonPosition()
	state.settingsDraft = cloneSettingsTable(state.settingsData)
	state.settingsDirty = false
	local resetAccent = hexToColor(state.settingsData.customAccent)
	if resetAccent then applyCustomAccent(resetAccent) end
	if ZoneRefreshLanguage then ZoneRefreshLanguage() end
	state.sidebarOrder = nil
	state.sidebarOrderText = nil
	state.sidebarLastSent = nil
	state.sidebarFullOrder = nil
	state.pendingThemeName = DEFAULT_THEME_NAME
	state.pendingCustomAccent = nil

	setThemeName(DEFAULT_THEME_NAME, false)
	applyOpenKeyConfig(state.settingsData)

	for btn in pairs(state.sidebarButtons or {}) do
		if btn and btn.Parent then
			local base = state.sidebarBaseOrder and state.sidebarBaseOrder[btn.Name]
			if base then
				btn.LayoutOrder = base
			end
		end
	end
	state.sidebarFullOrder = sidebarAllButtonsInOrder()

	refreshSettingsSwitches()
	syncSettingsPanelFromDraft()
	applyThemeColors()
	refreshAnimatedBackground()
	updateBackdropBlur()
	if settingsStatusLabel then
		settingsStatusLabel.Text = "Settings reset to defaults."
	end
	if type(notify) == "function" then
		notify("Settings reset to defaults.", true, 3)
	end
end

function buildResetButton(parentCard, layoutOrder)
	if not parentCard then
		return
	end
	local th = theme()
	make("Frame", {
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = th.muted,
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		Parent = parentCard,
	})
	local btn = make("TextButton", {
		Name = "ResetSettings",
		LayoutOrder = layoutOrder + 1,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = th.card,
		Text = "Reset settings",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = th.warn,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = parentCard,
	})
	corner(btn, 10)
	stroke(btn, 0.9)
	state.resetSettingsBtn = btn

	make("TextLabel", {
		LayoutOrder = layoutOrder + 2,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Text = "Restores every setting on this account to its default.",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parentCard,
	})

	btn.MouseButton1Click:Connect(function()
		openConfirmModal(
			"Reset all settings?",
			"Your theme, custom color, sidebar order and every toggle will go back to the default values. This only affects your own account.",
			resetSettingsToDefaults,
			"Reset"
		)
	end)
end

function buildSetupAgainButton(parentCard, layoutOrder)
	if not parentCard or getLocalAdminRank() ~= "Owner" then
		return
	end
	local th = theme()
	make("Frame", {
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = th.muted,
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		Parent = parentCard,
	})
	local btn = make("TextButton", {
		Name = "RunSetupAgain",
		LayoutOrder = layoutOrder + 1,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = th.card,
		Text = "Run setup again",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = th.text,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = parentCard,
	})
	corner(btn, 10)
	stroke(btn, 0.9)
	state.setupAgainBtn = btn

	make("TextLabel", {
		LayoutOrder = layoutOrder + 2,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Text = "Reopens the first time setup wizard.",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parentCard,
	})

	btn.MouseButton1Click:Connect(function()
		if state.setupWizard then
			return
		end
		closePanel()
		task.defer(openSetupWizard)
	end)
end

function buildPanicButton(parentCard, layoutOrder)
	if not parentCard then
		return
	end
	local th = theme()
	make("Frame", {
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = th.muted,
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		Parent = parentCard,
	})
	local btn = make("TextButton", {
		Name = "PanicButton",
		LayoutOrder = layoutOrder + 1,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(200, 45, 45),
		Text = "PANIC - LOCK SERVER",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = parentCard,
	})
	corner(btn, 10)
	stroke(btn, 0.6)
	state.panicBtn = btn

	state.panicHint = make("TextLabel", {
		LayoutOrder = layoutOrder + 2,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Text = "Kicks every non-admin and blocks new joins.",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parentCard,
	})

	btn.MouseButton1Click:Connect(function()
		if state.panicActive == true then
			RemoteEvent:FireServer("PanicUnlock", nil, {})
			return
		end
		openConfirmModal(
			"Lock this server?",
			"Every player without an admin rank will be kicked immediately, and nobody new can join until you unlock it.",
			function()
				RemoteEvent:FireServer("PanicLock", nil, {})
			end,
			"Lock server"
		)
	end)

	refreshPanicButton()
	RemoteEvent:FireServer("PanicQuery", nil, {})
end

function sidebarOrderKey()
	return "AdminPanelSidebarOrder"
end

function sidebarOrderEnabled()
	local data = state.settingsData
	if type(data) == "table" and data.saveSidebarOrder ~= nil then
		return data.saveSidebarOrder ~= false
	end
	return true
end

function sidebarAllButtonsInOrder()
	local list = {}
	for btn in pairs(state.sidebarButtons or {}) do
		if btn and btn.Parent then
			table.insert(list, btn)
		end
	end
	local base = state.sidebarBaseOrder or {}
	table.sort(list, function(a, b)
		if a.LayoutOrder == b.LayoutOrder then
			return (base[a.Name] or 0) < (base[b.Name] or 0)
		end
		return a.LayoutOrder < b.LayoutOrder
	end)
	return list
end

function renumberSidebarOrder(visibleOrder)
	local full = state.sidebarFullOrder
	if type(full) ~= "table" or #full == 0 then
		full = sidebarAllButtonsInOrder()
	end
	local result = {}
	for _, btn in ipairs(full) do
		if btn and btn.Parent then
			table.insert(result, btn)
		end
	end
	for btn in pairs(state.sidebarButtons or {}) do
		if btn and btn.Parent and not table.find(result, btn) then
			table.insert(result, btn)
		end
	end
	if type(visibleOrder) == "table" and #visibleOrder > 1 then
		local slots = {}
		for index, btn in ipairs(result) do
			if table.find(visibleOrder, btn) then
				table.insert(slots, index)
			end
		end
		if #slots == #visibleOrder then
			for i, slot in ipairs(slots) do
				result[slot] = visibleOrder[i]
			end
		end
	end
	for i, btn in ipairs(result) do
		btn.LayoutOrder = i
	end
	state.sidebarFullOrder = result
	return result
end

function sidebarOrderSignature()
	local list = sidebarAllButtonsInOrder()
	local parts = {}
	for _, btn in ipairs(list) do
		table.insert(parts, btn.Name)
	end
	return table.concat(parts, ",")
end

function syncSidebarOrderIfChanged()
	if not sidebarOrderEnabled() then
		return
	end
	local current = sidebarOrderSignature()
	if current == "" then
		return
	end
	if current == state.sidebarOrderText then
		return
	end
	saveSidebarOrder()
end

function startSidebarOrderWatcher()
	if state.sidebarWatcher then
		return
	end
	state.sidebarWatcher = task.spawn(function()
		while true do
			task.wait(2)
			if gui and gui.Parent and state.accessGranted == true then
				pcall(syncSidebarOrderIfChanged)
			end
		end
	end)
end

function collectSidebarOrderText()
	local list = sidebarAllButtonsInOrder()
	local names = {}
	for _, btn in ipairs(list) do
		table.insert(names, btn.Name)
	end
	return table.concat(names, ",")
end

function sidebarOrderTextToMap(text)
	local map = {}
	local index = 0
	for part in tostring(text or ""):gmatch("[^,]+") do
		local name = part:gsub("%s", "")
		if name ~= "" then
			index = index + 1
			map[name] = index
		end
	end
	if index == 0 then
		return nil
	end
	return map
end

function collectSidebarOrder()
	local order = {}
	for btn in pairs(state.sidebarButtons or {}) do
		if btn and btn.Parent then
			order[btn.Name] = btn.LayoutOrder
		end
	end
	return order
end

function flushSidebarOrder()
	if state.sidebarSavePending ~= true and state.sidebarSaving ~= true then
		return
	end
	local text = state.sidebarOrderText
	if type(text) ~= "string" or text == "" or not sidebarOrderEnabled() then
		return
	end
	pcall(function()
		SettingsRF:InvokeServer("set", {
			saveSidebarOrder = true,
			sidebarOrder = state.sidebarOrder,
			sidebarOrderText = text,
		})
	end)
end

function saveSidebarOrder()
	local order = collectSidebarOrder()
	local text = collectSidebarOrderText()
	state.sidebarOrder = order
	state.sidebarOrderText = text
	if not sidebarOrderEnabled() then
		return
	end
	if state.settingsData then
		state.settingsData.sidebarOrder = order
		state.settingsData.sidebarOrderText = text
	end
	if type(state.settingsDraft) == "table" then
		state.settingsDraft.sidebarOrder = order
		state.settingsDraft.sidebarOrderText = text
	end
	if state.sidebarSaving then
		state.sidebarSavePending = true
		return
	end
	if state.sidebarLastSent == text then
		return
	end
	state.sidebarLastSent = text
	state.sidebarSaving = true
	task.spawn(function()
		repeat
			state.sidebarSavePending = false
			local payload = {
				saveSidebarOrder = true,
				sidebarOrder = state.sidebarOrder,
				sidebarOrderText = state.sidebarOrderText,
			}
			local saved = false
			for attempt = 1, 3 do
				local ok, res = pcall(function()
					return SettingsRF:InvokeServer("set", payload)
				end)
				if ok and type(res) == "table" and res.ok ~= false then
					saved = true
					if type(res.sidebarOrderText) == "string" and res.sidebarOrderText ~= "" then
						state.sidebarOrderText = res.sidebarOrderText
						if state.settingsData then
							state.settingsData.sidebarOrderText = res.sidebarOrderText
						end
					end
					break
				end
				task.wait(attempt * 0.4)
			end
			if not saved then
				state.sidebarLastSent = nil
				if type(notify) == "function" then
					notify(ZoneT("notify.sidebarSaveFail"), "error")
				end
			end
		until not state.sidebarSavePending
		state.sidebarSaving = false
	end)
end

function applySavedSidebarOrder()
	local saved = nil
	local text = state.sidebarOrderText
	if (type(text) ~= "string" or text == "") and state.settingsData then
		text = state.settingsData.sidebarOrderText
	end
	if type(text) == "string" and text ~= "" then
		saved = sidebarOrderTextToMap(text)
		state.sidebarOrderText = text
	end
	if type(saved) ~= "table" then
		saved = state.sidebarOrder
	end
	if type(saved) ~= "table" and state.settingsData then
		saved = state.settingsData.sidebarOrder
		state.sidebarOrder = saved
	end
	if type(saved) == "table" and sidebarOrderEnabled() then
		local applied = false
		for btn in pairs(state.sidebarButtons or {}) do
			if btn and btn.Parent and saved[btn.Name] then
				btn.LayoutOrder = saved[btn.Name]
				applied = true
			end
		end
		if not applied then
			state.sidebarFullOrder = nil
		end
	end
	state.sidebarFullOrder = sidebarAllButtonsInOrder()
	for i, btn in ipairs(state.sidebarFullOrder) do
		btn.LayoutOrder = i
	end
	state.sidebarOrderText = sidebarOrderSignature()
end

function sidebarButtonsInOrder()
	local list = {}
	for btn in pairs(state.sidebarButtons or {}) do
		if btn and btn.Parent and btn.Visible then
			table.insert(list, btn)
		end
	end
	table.sort(list, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
	return list
end

function sidebarFillOf(btn)
	local parts = btn and state.sidebarButtons and state.sidebarButtons[btn]
	return parts and parts.fill or nil
end

function sidebarIconOf(btn)
	local parts = btn and state.sidebarButtons and state.sidebarButtons[btn]
	return parts and parts.icon or nil
end

function sidebarIconLayout(size)
	if state.sidebarExpanded then
		return UDim2.new(0, 9, 0.5, 0)
	end
	return UDim2.new(0.5, -(size / 2), 0.5, 0)
end

function setSidebarIconActive(btn, active)
	local icon = sidebarIconOf(btn)
	if not icon then
		return
	end
	local size = active and CONFIG.sidebarIconActiveSize or CONFIG.sidebarIconSize
	icon.ImageColor3 = theme().icon
	icon.ImageTransparency = 0
	tween(icon, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(size, size),
		Position = sidebarIconLayout(size),
	})
end

function startSidebarHoldFill(btn)
	local fill = sidebarFillOf(btn)
	if not fill then
		return
	end
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = theme().panel2
	fill.BackgroundTransparency = 0.25
	tween(fill, TweenInfo.new(CONFIG.sidebarReorderHold, Enum.EasingStyle.Linear), {
		Size = UDim2.fromScale(1, 1),
	})
end

function clearSidebarHoldFill(btn, instant)
	local fill = sidebarFillOf(btn)
	if not fill then
		return
	end
	if instant then
		fill.Size = UDim2.fromScale(0, 1)
	else
		tween(fill, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(0, 1),
		})
	end
end

function endSidebarReorder()
	local drag = state.sidebarDrag
	state.sidebarDrag = nil
	if not drag then
		return
	end
	if drag.holdThread then
		task.cancel(drag.holdThread)
	end
	if drag.fillThread then
		task.cancel(drag.fillThread)
	end
	if drag.scrollConn then
		drag.scrollConn:Disconnect()
		drag.scrollConn = nil
	end
	if sidebar and (drag.scrollWasEnabled ~= nil or drag.scrollLocked) then
		sidebar.ScrollingEnabled = true
		drag.scrollLocked = nil
		drag.scrollWasEnabled = nil
	end
	clearSidebarHoldFill(drag.btn, true)
	if drag.btn and drag.btn.Parent then
		local snap = drag.snapshot
		drag.btn.ZIndex = (snap and snap.zIndex) or drag.baseZ or 1

		local scale = drag.btn:FindFirstChildOfClass("UIScale")
		if scale then
			scale.Scale = 0.9
			tween(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
		end

		local restShadow = drag.shadow or drag.btn:FindFirstChild("SidebarShadow")
		if restShadow and restShadow.Parent then
			tween(restShadow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
			})
		end

		local doneFill = sidebarFillOf(drag.btn)
		if doneFill then
			doneFill.Size = UDim2.fromScale(0, 1)
		end

		if drag.active and drag.slots and drag.order then
			local landing = table.find(drag.order, drag.btn)
			if landing and drag.slots[landing] then
				tween(drag.btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Position = UDim2.fromOffset(drag.btn.Position.X.Offset, drag.slots[landing]),
				})
			end
		end

		if snap then
			drag.btn.BackgroundColor3 = snap.bgColor
			tween(drag.btn, TweenInfo.new(0.14), {
				BackgroundTransparency = snap.bgTransparency,
			})
			local restIcon = sidebarIconOf(drag.btn)
			if restIcon then
				if snap.iconColor then
					restIcon.ImageColor3 = snap.iconColor
				end
				if snap.iconSize and snap.iconPos then
					tween(restIcon, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = snap.iconSize,
						Position = snap.iconPos,
					})
				end
			end
			local st = drag.btn:FindFirstChildOfClass("UIStroke")
			if st then
				if snap.strokeColor then
					st.Color = snap.strokeColor
				end
				if snap.strokeThickness then
					st.Thickness = snap.strokeThickness
				end
				if snap.strokeTransparency then
					tween(st, TweenInfo.new(0.14), { Transparency = snap.strokeTransparency })
				end
			end
		end
	end
	if drag.active then
		sidebarThawLayout(drag)
		saveSidebarOrder()
	else
		sidebarThawLayout(drag)
		syncSidebarOrderIfChanged()
	end
end

function sidebarFreezeLayout(drag)
	local layout = sidebar and sidebar:FindFirstChildOfClass("UIListLayout")
	if not layout or not sidebar then
		return false
	end
	local origin = sidebar.AbsolutePosition
	local uiScale = 1
	if drag.btn and drag.btn.AbsoluteSize.Y > 0 then
		uiScale = drag.btn.AbsoluteSize.Y / math.max(1, CONFIG.sidebarBtnSize)
	end
	local keep = sidebar.CanvasPosition
	drag.uiScale = uiScale
	drag.canvasWasAuto = sidebar.AutomaticCanvasSize
	drag.canvasWasSize = sidebar.CanvasSize
	drag.canvasWasPos = keep

	local frozen = {}
	local places = {}
	for _, child in ipairs(sidebar:GetChildren()) do
		if child:IsA("GuiObject") then
			local offX = (child.AbsolutePosition.X - origin.X) / uiScale + keep.X
			local offY = (child.AbsolutePosition.Y - origin.Y) / uiScale + keep.Y
			frozen[child] = child.Position
			places[child] = UDim2.fromOffset(math.floor(offX + 0.5), math.floor(offY + 0.5))
		end
	end

	drag.layout = layout
	layout.Parent = nil
	for child, place in pairs(places) do
		if child.Parent then
			child.Position = place
		end
	end
	sidebar.CanvasPosition = keep
	task.defer(function()
		if sidebar and state.sidebarDrag == drag then
			sidebar.CanvasPosition = keep
		end
	end)

	drag.grabStartY = drag.btn and drag.btn.Position.Y.Offset or 0
	drag.grabStartCanvas = keep.Y
	drag.frozen = frozen
	drag.slots = {}
	state.sidebarFullOrder = sidebarAllButtonsInOrder()
	drag.order = sidebarButtonsInOrder()
	for i, item in ipairs(drag.order) do
		drag.slots[i] = item.Position.Y.Offset
	end
	return true
end

function sidebarThawLayout(drag)
	if not drag then
		return
	end
	if drag.order then
		local moved = {}
		for _, item in ipairs(drag.order) do
			if item and item.Parent then
				table.insert(moved, item)
			end
		end
		renumberSidebarOrder(moved)
	end
	if drag.frozen then
		for child, pos in pairs(drag.frozen) do
			if child and child.Parent then
				child.Position = pos
			end
		end
	end
	local layout = drag.layout or (sidebar and sidebar:FindFirstChildOfClass("UIListLayout"))
	if layout and sidebar then
		layout.Parent = sidebar
	end
	drag.layout = nil
	if sidebar and drag.canvasWasPos then
		local keep = drag.canvasWasPos
		sidebar.CanvasPosition = keep
		task.defer(function()
			if sidebar and not state.sidebarDrag then
				sidebar.CanvasPosition = keep
			end
		end)
		drag.canvasWasAuto = nil
		drag.canvasWasSize = nil
		drag.canvasWasPos = nil
	end
	drag.frozen = nil
	drag.slots = nil
	drag.order = nil
end

function beginSidebarReorder(btn)
	local drag = state.sidebarDrag
	if not drag or drag.btn ~= btn or not btn.Parent then
		return
	end
	drag.active = true
	if sidebar then
		drag.scrollWasEnabled = sidebar.ScrollingEnabled
		sidebar.ScrollingEnabled = false
	end
	sidebarFreezeLayout(drag)

	if drag.scrollConn then
		drag.scrollConn:Disconnect()
	end
	drag.scrollConn = RunService.Heartbeat:Connect(function(dt)
		local live = state.sidebarDrag
		if not live or not live.active or live ~= drag then
			return
		end
		if live.lastPos then
			sidebarAutoScroll(live.lastPos, dt)
			updateSidebarReorder(live.lastPos)
		end
	end)
	local snapIcon = sidebarIconOf(btn)
	local snapStroke = btn:FindFirstChildOfClass("UIStroke")
	drag.snapshot = {
		zIndex = btn.ZIndex,
		bgColor = btn.BackgroundColor3,
		bgTransparency = btn.BackgroundTransparency,
		iconColor = snapIcon and snapIcon.ImageColor3 or nil,
		iconSize = snapIcon and snapIcon.Size or nil,
		iconPos = snapIcon and snapIcon.Position or nil,
		strokeColor = snapStroke and snapStroke.Color or nil,
		strokeThickness = snapStroke and snapStroke.Thickness or nil,
		strokeTransparency = snapStroke and snapStroke.Transparency or nil,
	}
	drag.baseZ = btn.ZIndex
	btn.ZIndex = (btn.ZIndex or 1) + 10
	tween(btn, TweenInfo.new(0.14), { BackgroundTransparency = 0 })

	local scale = btn:FindFirstChildOfClass("UIScale")
	if scale then
		tween(scale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.08 })
	end

	local liftShadow = btn:FindFirstChild("SidebarShadow")
	if liftShadow then
		drag.shadow = liftShadow
		tween(liftShadow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0.4,
		})
	end

	local st = btn:FindFirstChildOfClass("UIStroke")
	if st then
		drag.baseStroke = st.Transparency
		tween(st, TweenInfo.new(0.12), { Transparency = 0.15 })
	end

	clearSidebarHoldFill(btn, false)
	setSidebarIconActive(btn, true)
	if snapIcon and drag.snapshot.iconColor then
		snapIcon.ImageColor3 = drag.snapshot.iconColor
	end
end

function sidebarAutoScroll(inputPos, dt)
	if not sidebar or not sidebar.Parent then
		return
	end
	local canvasY = sidebar.AbsoluteCanvasSize and sidebar.AbsoluteCanvasSize.Y or 0
	local windowY = sidebar.AbsoluteWindowSize and sidebar.AbsoluteWindowSize.Y or 0
	local maxScroll = math.max(0, canvasY - windowY)
	if maxScroll <= 0 then
		return
	end

	local top = sidebar.AbsolutePosition.Y
	local bottom = top + sidebar.AbsoluteSize.Y
	local zone = math.min(70, sidebar.AbsoluteSize.Y * 0.3)
	local pixelsPerSecond = 150
	local step = pixelsPerSecond * math.clamp(tonumber(dt) or (1 / 60), 0, 0.1)
	local speed = 0

	if inputPos.Y < top + zone then
		local depth = math.clamp((top + zone - inputPos.Y) / zone, 0, 1)
		speed = -depth * step
	elseif inputPos.Y > bottom - zone then
		local depth = math.clamp((inputPos.Y - (bottom - zone)) / zone, 0, 1)
		speed = depth * step
	end

	if speed == 0 then
		return
	end

	local currentY = sidebar.CanvasPosition.Y
	local nextY = math.clamp(currentY + speed, 0, maxScroll)
	if math.abs(nextY - currentY) < 0.05 then
		return
	end
	sidebar.CanvasPosition = Vector2.new(sidebar.CanvasPosition.X, nextY)
end

function updateSidebarReorder(inputPos)
	if state.sidebarDrag then
		state.sidebarDrag.lastPos = inputPos
	end
	sidebarAutoScroll(inputPos)
	local drag = state.sidebarDrag
	if not drag or not drag.active or not drag.btn or not drag.btn.Parent then
		return
	end

	local moving = drag.btn
	local list = drag.order
	if type(list) ~= "table" or #list < 2 then
		list = sidebarButtonsInOrder()
	end
	if #list < 2 then
		return
	end

	if drag.startPos and drag.slots and #drag.slots > 0 then
		local uiScale = drag.uiScale or 1
		local pointerDelta = (inputPos.Y - drag.startPos.Y) / math.max(uiScale, 0.05)
		local scrollDelta = sidebar and (sidebar.CanvasPosition.Y - (drag.grabStartCanvas or 0)) or 0
		local desiredY = (drag.grabStartY or 0) + pointerDelta + scrollDelta
		desiredY = math.clamp(desiredY, drag.slots[1], drag.slots[#drag.slots])
		moving.Position = UDim2.fromOffset(moving.Position.X.Offset, math.floor(desiredY + 0.5))
	end

	local movingIndex
	for i, btn in ipairs(list) do
		if btn == moving then
			movingIndex = i
			break
		end
	end
	if not movingIndex then
		return
	end

	local targetIndex = movingIndex
	if drag.slots and #drag.slots > 0 then
		local centre = moving.Position.Y.Offset + (CONFIG.sidebarBtnSize / 2)
		targetIndex = #drag.slots
		for i = 1, #drag.slots do
			if centre < drag.slots[i] + (CONFIG.sidebarBtnSize / 2) then
				targetIndex = i
				break
			end
		end
	else
		for i, btn in ipairs(list) do
			local mid = btn.AbsolutePosition.Y + (btn.AbsoluteSize.Y / 2)
			if inputPos.Y < mid then
				targetIndex = i
				break
			end
			targetIndex = i
		end
	end
	targetIndex = math.clamp(targetIndex, 1, #list)

	if targetIndex == movingIndex then
		return
	end

	table.remove(list, movingIndex)
	table.insert(list, targetIndex, moving)

	local lowIndex = math.min(movingIndex, targetIndex)
	local highIndex = math.max(movingIndex, targetIndex)
	local slide = TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	for i, btn in ipairs(list) do
		btn.LayoutOrder = i
		if btn ~= moving and drag.slots and drag.slots[i] then
			tween(btn, slide, {
				Position = UDim2.fromOffset(btn.Position.X.Offset, drag.slots[i]),
			})
		end
		if btn ~= moving and i >= lowIndex and i <= highIndex then
			local otherScale = btn:FindFirstChildOfClass("UIScale")
			if otherScale then
				otherScale.Scale = 0.9
				tween(otherScale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Scale = 1,
				})
			end
		end
	end
	drag.order = list
end

function attachSidebarReorder(btn)
	btn.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if input.UserInputType == Enum.UserInputType.Touch or state.mobile == true then
			return
		end
		endSidebarReorder()
		local drag = {
			btn = btn,
			active = false,
			startPos = input.Position,
			lastPos = input.Position,
			isTouch = false,
		}
		state.sidebarDrag = drag

		drag.fillThread = task.delay(CONFIG.sidebarReorderDelay, function()
			if state.sidebarDrag == drag then
				startSidebarHoldFill(btn)
			end
		end)
		drag.holdThread = task.delay(CONFIG.sidebarReorderDelay + CONFIG.sidebarReorderHold, function()
			if state.sidebarDrag == drag then
				beginSidebarReorder(btn)
			end
		end)
	end)

	btn.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch
			and input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local drag = state.sidebarDrag
		if not drag or drag.btn ~= btn then
			return
		end
		drag.lastPos = input.Position
		if drag.active then
			updateSidebarReorder(input.Position)
			return
		end
		if drag.startPos and math.abs(input.Position.Y - drag.startPos.Y) > 26 then
			endSidebarReorder()
		end
	end)

	btn.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local drag = state.sidebarDrag
		local wasActive = drag and drag.active
		endSidebarReorder()
		state.sidebarSuppressClick = wasActive == true
		if wasActive then
			task.delay(0.1, function()
				state.sidebarSuppressClick = false
			end)
		end
	end)
end

function resizeSidebarToContent()
	if not sidebar or not sidebar.Parent then
		return
	end
	local count = 0
	for btn in pairs(state.sidebarButtons or {}) do
		if btn and btn.Parent and btn.Visible then
			count = count + 1
		end
	end
	if count <= 0 then
		return
	end

	local gap = 8
	local toggleHeight = 34
	local padTop = 12
	local padBottom = 12
	local needed = padTop + toggleHeight + gap
		+ (count * CONFIG.sidebarBtnSize)
		+ ((count - 1) * gap)
		+ padBottom

	local panelHeight = 0
	if main then
		panelHeight = main.Size.Y.Offset
		if panelHeight <= 0 then
			local scaleY = 1
			for _, child in ipairs(main:GetChildren()) do
				if child:IsA("UIScale") then
					scaleY = scaleY * child.Scale
				end
			end
			panelHeight = main.AbsoluteSize.Y / math.max(scaleY, 0.05)
		end
	end

	local topOffset = 68
	local bottomMargin = 12
	local available = panelHeight > 0 and (panelHeight - topOffset - bottomMargin) or needed
	if available <= 0 then
		available = needed
	end

	local overflow = needed > available
	sidebar.Position = UDim2.fromOffset(12, topOffset)
	sidebar.Size = UDim2.new(0, sidebarWidth(), 1, -(topOffset + bottomMargin))
	sidebar.ScrollingEnabled = true
	sidebar.Active = true
	sidebar.ScrollBarThickness = overflow and (state.mobile and 3 or 4) or 0
	if overflow then
		sidebar.AutomaticCanvasSize = Enum.AutomaticSize.None
		sidebar.CanvasSize = UDim2.new(0, 0, 0, math.floor(needed + 0.5))
	else
		sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
		sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
		sidebar.CanvasPosition = Vector2.new(0, 0)
	end
end

function sidebarWidth()
	return state.sidebarExpanded and CONFIG.sidebarWide or CONFIG.sidebarNarrow
end

function sidebarButtonIsActive(btn)
	local st = btn and btn:FindFirstChildOfClass("UIStroke")
	return st ~= nil and st.Transparency < 0.8
end

function attachSidebarHover(btn)
	local scale = btn:FindFirstChildOfClass("UIScale")
	local info = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function restBackground()
		return sidebarButtonIsActive(btn) and 0.05 or 0.08
	end

	btn.MouseEnter:Connect(function()
		if state.sidebarDrag and state.sidebarDrag.active then
			return
		end
		tween(btn, info, { BackgroundTransparency = 0 })
		if scale then
			tween(scale, info, { Scale = 1.05 })
		end
	end)

	btn.MouseLeave:Connect(function()
		if state.sidebarDrag and state.sidebarDrag.btn == btn and state.sidebarDrag.active then
			return
		end
		tween(btn, info, { BackgroundTransparency = restBackground() })
		if scale then
			tween(scale, info, { Scale = 1 })
		end
	end)

	btn.MouseButton1Down:Connect(function()
		if scale then
			tween(scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.93 })
		end
	end)

	btn.MouseButton1Up:Connect(function()
		if state.sidebarDrag and state.sidebarDrag.active then
			return
		end
		clearSidebarHoldFill(btn, false)
		if scale then
			tween(scale, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
		end
	end)
end

function makeSidebarIconBtn(parent, layoutOrder, iconId, tooltipText, labelText)
	local th = theme()
	local btn = make("TextButton", {
		Name = tooltipText,
		LayoutOrder = layoutOrder,
		Size = UDim2.fromOffset(CONFIG.sidebarBtnSize, CONFIG.sidebarBtnSize),
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.08,
		Text = "",
		AutoButtonColor = false,
		Parent = parent,
	})
	corner(btn, 12)
	stroke(btn, 0.92)
	local btnShadow = addShadow(btn, 14, 1, 5, 0)
	if btnShadow then
		btnShadow.Name = "SidebarShadow"
	end
	make("UIScale", { Scale = 1, Parent = btn })

	local fillClip = make("Frame", {
		Name = "FillClip",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 0,
		Parent = btn,
	})
	corner(fillClip, 12)

	local fill = make("Frame", {
		Name = "Fill",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = th.panel2,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		ZIndex = 0,
		Parent = fillClip,
	})
	corner(fill, 12)

	local icon = make("ImageLabel", {
		Name = "Icon",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 9, 0.5, 0),
		Size = UDim2.fromOffset(CONFIG.sidebarIconSize, CONFIG.sidebarIconSize),
		BackgroundTransparency = 1,
		Image = iconId,
		ImageColor3 = th.icon,
		ScaleType = Enum.ScaleType.Fit,
		Parent = btn,
	})

	local label = make("TextLabel", {
		Name = "Label",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 46, 0.5, 0),
		Size = UDim2.new(1, -56, 0, 20),
		BackgroundTransparency = 1,
		Text = tostring(labelText or tooltipText),
		Font = Enum.Font.GothamSemibold,
		TextSize = 14,
		TextColor3 = th.text,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Visible = false,
		Parent = btn,
	})

	state.sidebarButtons[btn] = { icon = icon, label = label, fill = fill, order = layoutOrder }
	attachSidebarHover(btn)
	attachSidebarReorder(btn)
	return btn
end

function stopChatPipBackground()
	for _, key in ipairs({ "bgDriftTween", "bgSpinTween" }) do
		if state.chatPip and state.chatPip[key] then
			pcall(function()
				state.chatPip[key]:Cancel()
			end)
			state.chatPip[key] = nil
		end
	end
end

function startChatPipBackground()
	stopChatPipBackground()
	if not animatedBackgroundEnabled() then
		return
	end
	local frame = state.chatPip and state.chatPip.frame or nil
	if not frame or not frame.Parent then
		return
	end
	local layer = state.chatPip.bgLayer
	if not layer or not layer.Parent then
		layer = make("Frame", {
			Name = "AnimatedBackground",
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.12,
			BorderSizePixel = 0,
			ZIndex = 0,
			Parent = frame,
		})
		corner(layer, 16)
		state.chatPip.bgLayer = layer
	end
	local grad = layer:FindFirstChild("BackgroundSweep")
	if not grad then
		grad = Instance.new("UIGradient")
		grad.Name = "BackgroundSweep"
		grad.Parent = layer
	end
	layer.Visible = true
	grad.Color = backgroundGradientColors()
	grad.Transparency = backgroundFadeSequence()
	grad.Offset = Vector2.new(-1, 0)
	grad.Rotation = 25
	state.chatPip.bgDriftTween = TweenService:Create(
		grad,
		TweenInfo.new(13, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Offset = Vector2.new(1, 0) }
	)
	state.chatPip.bgDriftTween:Play()
	state.chatPip.bgSpinTween = TweenService:Create(
		grad,
		TweenInfo.new(19, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Rotation = -25 }
	)
	state.chatPip.bgSpinTween:Play()
end
function openChatPip()
	if state.chatPipOpen == true then
		return
	end
	if not gui then
		return
	end
	if state.mobile then
		if not state.chatListHolder or not state.chatListHolder.Parent then
			return
		end
	else
		if not state.chatScroll or not state.chatScroll.Parent then
			return
		end
	end
	state.chatPipOpen = true
	if not state.chatPip.frame then
		local th = theme()
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
		local baseW = 340
		local baseH = 430
		if state.mobile then
			baseW = math.min(420, math.max(220, vp.X - 24))
			baseH = math.min(520, math.max(240, math.floor(vp.Y * 0.6)))
		end
		state.chatPip.frame = make("Frame", {
			Name = "ChatPip",
			BackgroundColor3 = th.panel,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			AnchorPoint = state.mobile and Vector2.new(0.5, 0.5) or Vector2.new(0, 0),
			Position = state.mobile and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(1, -356, 1, -446),
			Size = UDim2.fromOffset(baseW, baseH),
			Visible = false,
			ZIndex = 4600,
			Parent = gui,
		})
		corner(state.chatPip.frame, 16)
		stroke(state.chatPip.frame, 0.9)
		addShadow(state.chatPip.frame, 20, 0.4, 8, 2)
		state.chatPip.scale = make("UIScale", { Scale = 1, Parent = state.chatPip.frame })
		state.chatPip.viewportConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			if not (state.mobile and state.chatPipOpen == true) then
				return
			end
			local cam2 = workspace.CurrentCamera
			local vp2 = cam2 and cam2.ViewportSize or Vector2.new(1280, 720)
			local w2 = math.min(420, math.max(220, vp2.X - 24))
			local h2 = math.min(520, math.max(240, math.floor(vp2.Y * 0.6)))
			if state.chatPip.size then
				w2 = math.clamp(state.chatPip.size.X.Offset, 240, math.max(240, vp2.X - 12))
				h2 = math.clamp(state.chatPip.size.Y.Offset, 280, math.max(280, vp2.Y - 12))
			end
			state.chatPip.frame.Size = UDim2.fromOffset(w2, h2)
			state.chatPip.frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		end)
		state.chatPip.header = make("Frame", {
			Name = "Header",
			BackgroundColor3 = th.panel2,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 42),
			Parent = state.chatPip.frame,
		})
		corner(state.chatPip.header, 16)
		state.chatPip.dragHandle = make("TextButton", {
			Name = "DragHandle",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.fromOffset(80, 16),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Parent = state.chatPip.header,
		})
		local pill = make("Frame", {
			Name = "DragPill",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(40, 4),
			BackgroundColor3 = th.muted,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Parent = state.chatPip.dragHandle,
		})
		corner(pill, 3)
		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -80, 1, 0),
			Text = "Chat",
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			TextColor3 = th.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = state.chatPip.header,
		})
		state.chatPip.closeBtn = make("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(26, 26),
			BackgroundColor3 = th.card,
			Text = "×",
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			TextColor3 = th.text,
			AutoButtonColor = false,
			Parent = state.chatPip.header,
		})
		corner(state.chatPip.closeBtn, 9)
		stroke(state.chatPip.closeBtn, 0.92)
		state.chatPip.closeBtn.MouseButton1Click:Connect(closeChatPip)

		local dragging = false
		local pressActive = false
		local dragStart = nil
		local startPos = nil
		local function setPressEffect(active)
			holdChatScrollDuringPress(active)
			if not animationsEnabled() or not state.chatPip.scale then
				return
			end
			if active then
				if not pressActive then
					pressActive = true
					tween(state.chatPip.scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.985 })
				end
			else
				if pressActive then
					pressActive = false
					tween(state.chatPip.scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 })
				end
			end
		end
		state.chatPip.dragHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = state.chatPip.frame.Position
				setPressEffect(true)
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
						setPressEffect(false)
					end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not dragging then
				return
			end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			state.chatPip.frame.Position = startPos + UDim2.fromOffset(input.Position.X - dragStart.X, input.Position.Y - dragStart.Y)
		end)

		state.chatPip.resizeGrip = make("TextButton", {
			Name = "ResizeGrip",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, 0, 1, 0),
			Size = UDim2.fromOffset(28, 28),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 40,
			Parent = state.chatPip.frame,
		})
		state.chatPip.resizeGripIcon = make("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(20, 20),
			Image = RESIZE_GRIP_ICON,
			ImageColor3 = th.muted,
			ImageTransparency = 0.25,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 41,
			Parent = state.chatPip.resizeGrip,
		})
		local resizing = false
		local resizeStartMouse = nil
		local resizeStartSize = nil
		state.chatPip.resizeGrip.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				holdChatScrollDuringPress(true)
				resizeStartMouse = input.Position
				resizeStartSize = Vector2.new(state.chatPip.frame.Size.X.Offset, state.chatPip.frame.Size.Y.Offset)
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						resizing = false
						holdChatScrollDuringPress(false)
					end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if not resizing then
				return
			end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			local camR = workspace.CurrentCamera
			local vpR = camR and camR.ViewportSize or Vector2.new(1280, 720)
			local delta = input.Position - resizeStartMouse
			local newW = math.clamp(resizeStartSize.X + delta.X, 240, math.max(240, vpR.X - 24))
			local newH = math.clamp(resizeStartSize.Y + delta.Y, 280, math.max(280, vpR.Y - 24))
			state.chatPip.frame.Size = UDim2.fromOffset(newW, newH)
			state.chatPip.size = UDim2.fromOffset(newW, newH)
		end)

		state.chatPip.placeholder = make("TextButton", {
			Name = "ChatPipPlaceholder",
			Visible = false,
			Position = UDim2.fromOffset(0, 56),
			Size = UDim2.new(1, 0, 1, -110),
			BackgroundColor3 = th.card,
			BackgroundTransparency = 0.12,
			Text = "Chat is open in a small window.\n\nClick here to bring it back into the panel.",
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = th.muted,
			TextWrapped = true,
			AutoButtonColor = false,
			Parent = right,
		})
		corner(state.chatPip.placeholder, 12)
		stroke(state.chatPip.placeholder, 0.9)
		state.chatPip.placeholder.MouseButton1Click:Connect(closeChatPip)
	end

	if state.mobile then
		state.chatPipSaved = {
			mobile = true,
			statusParent = state.chatStatusLabel and state.chatStatusLabel.Parent or nil,
			statusPosition = state.chatStatusLabel and state.chatStatusLabel.Position or nil,
			statusSize = state.chatStatusLabel and state.chatStatusLabel.Size or nil,
			listParent = state.chatListHolder and state.chatListHolder.Parent or nil,
			listPosition = state.chatListHolder and state.chatListHolder.Position or nil,
			listSize = state.chatListHolder and state.chatListHolder.Size or nil,
			footerParent = state.chatFooter and state.chatFooter.Parent or nil,
			footerPosition = state.chatFooter and state.chatFooter.Position or nil,
			footerSize = state.chatFooter and state.chatFooter.Size or nil,
			typingParent = state.chatTypingLabel and state.chatTypingLabel.Parent or nil,
			typingPosition = state.chatTypingLabel and state.chatTypingLabel.Position or nil,
			typingSize = state.chatTypingLabel and state.chatTypingLabel.Size or nil,
		}
		if not state.chatPip.mobileScroll or not state.chatPip.mobileScroll.Parent then
			state.chatPip.mobileScroll = make("ScrollingFrame", {
				Name = "PipScroll",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 60),
				Size = UDim2.new(1, 0, 1, -114),
				ScrollBarThickness = 4,
				ScrollBarImageColor3 = theme().text,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				Parent = state.chatPip.frame,
			})
		end
		state.chatPip.mobileScroll.Visible = true
		state.chatPip.mobileScroll.CanvasPosition = Vector2.new(0, 0)
		if state.chatStatusLabel then
			state.chatStatusLabel.Parent = state.chatPip.frame
			state.chatStatusLabel.Position = UDim2.fromOffset(0, 42)
			state.chatStatusLabel.Size = UDim2.new(1, -140, 0, 18)
			state.chatStatusLabel.Visible = true
		end
		state.chatListHolder.Parent = state.chatPip.mobileScroll
		state.chatListHolder.Position = UDim2.fromOffset(0, 0)
		state.chatListHolder.Size = UDim2.new(1, 0, 0, 0)
		state.chatListHolder.AutomaticSize = Enum.AutomaticSize.Y
		if state.chatMobileScroll then
			state.chatMobileScroll.Visible = false
		end
		if state.chatFooter then
			state.chatFooter.Parent = state.chatPip.frame
			state.chatFooter.Visible = true
		end
		if state.chatTypingLabel then
			state.chatTypingLabel.Parent = state.chatPip.frame
			state.chatTypingLabel.Position = UDim2.new(0, 10, 1, -58)
		end
	else
		state.chatPipSaved = {
			mobile = false,
			scrollParent = state.chatScroll.Parent,
			scrollPosition = state.chatScroll.Position,
			scrollSize = state.chatScroll.Size,
			footerParent = state.chatFooter and state.chatFooter.Parent or nil,
			footerPosition = state.chatFooter and state.chatFooter.Position or nil,
			footerSize = state.chatFooter and state.chatFooter.Size or nil,
			typingParent = state.chatTypingLabel and state.chatTypingLabel.Parent or nil,
			typingPosition = state.chatTypingLabel and state.chatTypingLabel.Position or nil,
			typingSize = state.chatTypingLabel and state.chatTypingLabel.Size or nil,
		}
		state.chatScroll.Parent = state.chatPip.frame
		state.chatScroll.Position = UDim2.fromOffset(0, 42)
		state.chatScroll.Size = UDim2.new(1, 0, 1, -96)
		state.chatScroll.Visible = true
		if state.chatFooter then
			state.chatFooter.Parent = state.chatPip.frame
			state.chatFooter.Visible = true
		end
		if state.chatTypingLabel then
			state.chatTypingLabel.Parent = state.chatPip.frame
			state.chatTypingLabel.Position = UDim2.new(0, 10, 1, -58)
		end
		if state.chatPip.minimizeBtn then
			state.chatPip.minimizeBtn.Visible = false
		end
		if state.chatPip.placeholder then
			state.chatPip.placeholder.Visible = state.selectedTab == "chat"
		end
	end
	if state.mobile then
		local camM = workspace.CurrentCamera
		local vpM = camM and camM.ViewportSize or Vector2.new(1280, 720)
		local wM = math.min(420, math.max(220, vpM.X - 24))
		local hM = math.min(520, math.max(240, math.floor(vpM.Y * 0.6)))
		state.chatPip.frame.Size = UDim2.fromOffset(wM, hM)
		state.chatPip.frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	end
	if state.chatPip.resizeGrip then
		state.chatPip.resizeGrip.Visible = not state.mobile
	end
	state.chatPip.frame.Visible = true
	if state.chatPip.scale then
		state.chatPip.scale.Scale = 1
	end
	startChatPipBackground()
	if animationsEnabled() and not state.mobile then
		local target = state.chatPip.size or UDim2.fromOffset(340, 430)
		state.chatPip.frame.Size = UDim2.fromOffset(math.max(300, target.X.Offset - 40), math.max(380, target.Y.Offset - 50))
		tween(state.chatPip.frame, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = target })
	end
end
function closeChatPip()
	if state.chatPipOpen ~= true then
		return
	end
	state.chatPipOpen = false
	stopChatPipBackground()
	if state.chatPip and state.chatPip.bgLayer and state.chatPip.bgLayer.Parent then
		state.chatPip.bgLayer.Visible = false
	end
	if state.chatPip.frame then
		state.chatPip.frame.Visible = false
	end
	local saved = state.chatPipSaved or {}
	if saved.mobile then
		if state.chatStatusLabel and saved.statusParent and saved.statusParent.Parent then
			pcall(function()
				state.chatStatusLabel.Parent = saved.statusParent
				state.chatStatusLabel.Position = saved.statusPosition or UDim2.fromOffset(0, 0)
				state.chatStatusLabel.Size = saved.statusSize or UDim2.new(1, 0, 0, 16)
				state.chatStatusLabel.Visible = true
			end)
		end
		if state.chatListHolder and saved.listParent and saved.listParent.Parent then
			pcall(function()
				state.chatListHolder.Parent = saved.listParent
				state.chatListHolder.Position = saved.listPosition or UDim2.fromOffset(0, 0)
				state.chatListHolder.Size = saved.listSize or UDim2.new(1, 0, 0, 0)
				state.chatListHolder.AutomaticSize = Enum.AutomaticSize.Y
			end)
		end
		if state.chatFooter and saved.footerParent and saved.footerParent.Parent then
			pcall(function()
				state.chatFooter.Parent = saved.footerParent
				state.chatFooter.Position = saved.footerPosition or UDim2.new(0, 0, 1, 0)
				state.chatFooter.Size = saved.footerSize or UDim2.new(1, 0, 0, 54)
				state.chatFooter.Visible = true
			end)
		end
		if state.chatTypingLabel and saved.typingParent and saved.typingParent.Parent then
			pcall(function()
				state.chatTypingLabel.Parent = saved.typingParent
				state.chatTypingLabel.Position = saved.typingPosition or UDim2.new(0, 0, 1, -60)
				state.chatTypingLabel.Size = saved.typingSize or UDim2.new(1, 0, 0, 14)
				state.chatTypingLabel.Visible = tostring(state.chatTypingLabel.Text or "") ~= ""
			end)
		end
		if state.chatPip.mobileScroll then
			state.chatPip.mobileScroll.Visible = false
		end
		if state.chatMobileScroll then
			state.chatMobileScroll.Visible = true
			pcall(function()
				state.chatMobileScroll.CanvasPosition = Vector2.new(0, 999999)
			end)
		end
	else
		if state.chatScroll then
			pcall(function()
				state.chatScroll.Parent = saved.scrollParent or right
				state.chatScroll.Position = saved.scrollPosition or UDim2.fromOffset(0, 56)
				state.chatScroll.Size = saved.scrollSize or UDim2.new(1, 0, 1, -110)
				state.chatScroll.Visible = state.selectedTab == "chat"
			end)
		end
		if state.chatFooter then
			pcall(function()
				state.chatFooter.Parent = saved.footerParent or right
				state.chatFooter.Position = saved.footerPosition or UDim2.new(0, 0, 1, 0)
				state.chatFooter.Size = saved.footerSize or UDim2.new(1, 0, 0, 54)
				state.chatFooter.Visible = state.selectedTab == "chat"
			end)
		end
		if state.chatTypingLabel then
			pcall(function()
				state.chatTypingLabel.Parent = saved.typingParent or right
				state.chatTypingLabel.Position = saved.typingPosition or UDim2.new(0, 10, 1, -60)
				state.chatTypingLabel.Size = saved.typingSize or UDim2.new(1, -20, 0, 14)
				state.chatTypingLabel.Visible = state.selectedTab == "chat" and tostring(state.chatTypingLabel.Text or "") ~= ""
			end)
		end
		if state.chatPip.placeholder then
			state.chatPip.placeholder.Visible = false
		end
		if state.chatPip.minimizeBtn then
			state.chatPip.minimizeBtn.Visible = state.chatTitleLabel ~= nil and state.chatTitleLabel.Visible == true
		end
	end
	state.chatPipSaved = nil
end
function applySidebarMode(animated)
	task.defer(resizeSidebarToContent)
	local expanded = state.sidebarExpanded
	local width = sidebarWidth()
	local btnSize = CONFIG.sidebarBtnSize
	local iconSize = CONFIG.sidebarIconSize
	local info = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	local function move(obj, props)
		if not obj or not obj.Parent then
			return
		end
		if animated then
			tween(obj, info, props)
		else
			for key, value in pairs(props) do
				obj[key] = value
			end
		end
	end

	for btn, parts in pairs(state.sidebarButtons or {}) do
		if btn and btn.Parent then
			move(btn, {
				Size = expanded and UDim2.new(1, 0, 0, btnSize) or UDim2.fromOffset(btnSize, btnSize),
			})
			if parts.icon then
				move(parts.icon, {
					Position = expanded
						and UDim2.new(0, 9, 0.5, 0)
						or UDim2.new(0.5, -(iconSize / 2), 0.5, 0),
				})
			end
			if parts.label then
				if expanded then
					parts.label.Visible = true
					move(parts.label, { TextTransparency = 0 })
				elseif animated then
					move(parts.label, { TextTransparency = 1 })
					task.delay(0.18, function()
						if not state.sidebarExpanded and parts.label and parts.label.Parent then
							parts.label.Visible = false
						end
					end)
				else
					parts.label.TextTransparency = 1
					parts.label.Visible = false
				end
			end
		end
	end

	if state.sidebarToggleBtn and state.sidebarToggleBtn.Parent then
		move(state.sidebarToggleBtn, {
			Size = expanded and UDim2.new(1, 0, 0, 34) or UDim2.fromOffset(btnSize, 34),
		})
	end
	if state.sidebarToggleGlyph and state.sidebarToggleGlyph.Parent then
		move(state.sidebarToggleGlyph, {
			Position = expanded and UDim2.new(0, 9, 0.5, 0) or UDim2.new(0.5, -11, 0.5, 0),
		})
	end
	if state.sidebarToggleLabel and state.sidebarToggleLabel.Parent then
		if expanded then
			state.sidebarToggleLabel.Visible = true
			move(state.sidebarToggleLabel, { TextTransparency = 0 })
		elseif animated then
			move(state.sidebarToggleLabel, { TextTransparency = 1 })
			task.delay(0.18, function()
				if not state.sidebarExpanded and state.sidebarToggleLabel and state.sidebarToggleLabel.Parent then
					state.sidebarToggleLabel.Visible = false
				end
			end)
		else
			state.sidebarToggleLabel.TextTransparency = 1
			state.sidebarToggleLabel.Visible = false
		end
	end

	local function place(obj, pos, size)
		if not obj then
			return
		end
		if animated then
			tween(obj, info, { Position = pos, Size = size })
		else
			obj.Position = pos
			obj.Size = size
		end
	end

	place(sidebar, UDim2.fromOffset(12, 68), UDim2.new(0, width, 1, -80))
	if sidebar then
		sidebar.Size = UDim2.new(0, width, 1, -80)
	end
	task.defer(resizeSidebarToContent)

	local contentX = width + 24
	place(left, UDim2.fromOffset(contentX, 68), UDim2.new(0, 260, 1, -80))
	if right then
		if state.selectedTab == "actions" then
			place(right, UDim2.fromOffset(contentX + 272, 68), UDim2.new(1, -(contentX + 284), 1, -80))
		else
			place(right, UDim2.fromOffset(contentX, 68), UDim2.new(1, -(contentX + 12), 1, -80))
		end
	end
end

function toggleSidebar()
	state.sidebarExpanded = not state.sidebarExpanded
	applySidebarMode(true)
end

function makeMobileTabBtn(parent, order, key, title)
	local th = theme()
	local btn = make("TextButton", {
		Name = key .. "MobileTab",
		LayoutOrder = order,
		Size = UDim2.fromOffset(96, 34),
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.08,
		Text = title,
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = th.text,
		AutoButtonColor = false,
		Parent = parent,
	})
	corner(btn, 12)
	stroke(btn, 0.92)
	make("UIScale", { Scale = 1, Parent = btn })
	return btn
end

function buildMobileNav()
	if not mobileTabHolder then
		return
	end
	clearChildrenExcept(mobileTabHolder, {})
	mobileTabButtons = {}
	local tabs = {
		{ key = "home", label = "Home" },
		{ key = "actions", label = "Actions" },
		{ key = "server", label = "Server" },
	}
	if canSeeAdminsTab() then
		table.insert(tabs, { key = "admins", label = "Admins" })
	end
	table.insert(tabs, { key = "ban", label = "Ban" })
	table.insert(tabs, { key = "chat", label = "Chat" })
	if canUseAnnounceTab() then
		table.insert(tabs, { key = "announce", label = "Announce" })
	end
	table.insert(tabs, { key = "moderation", label = "History" })
	table.insert(tabs, { key = "credits", label = "Info" })
	table.insert(tabs, { key = "settings", label = "Settings" })
	for i, tab in ipairs(tabs) do
		local btn = makeMobileTabBtn(mobileTabHolder, i, tab.key, tab.label)
		mobileTabButtons[tab.key] = btn
		btn.Activated:Connect(function()
			setTab(tab.key)
		end)
		btn.MouseButton1Click:Connect(function()
			setTab(tab.key)
		end)
	end
	refreshMobileNavButtons()
end

function refreshMobileNavButtons()
	if not mobileTabButtons then
		return
	end
	local adminsVisible = canSeeAdminsTab()
	for key, btn in pairs(mobileTabButtons) do
		if key == "admins" then
			btn.Visible = adminsVisible
			setTabButtonState(btn, adminsVisible and state.selectedTab == key)
		else
			setTabButtonState(btn, state.selectedTab == key)
		end
	end
end

function createUI()
	gui = make("ScreenGui", {
		Name = "AdminPanelUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = playerGui,
	})

	backdropBlur = { Size = 0 }

	state.notificationHolder = make("Frame", {
		Name = "NotificationHolder",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.fromOffset(320, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = gui,
		ZIndex = 5000,
	})
	state.notificationLayout = make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Parent = state.notificationHolder,
	})

	codeOverlay = make("Frame", {
		Name = "CodeOverlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,   
		Visible = false,
		BorderSizePixel = 0,
		ZIndex = 2100,
		Parent = gui,
	})

	codeFrame = make("CanvasGroup", {
		Name = "CodeFrame",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = CONFIG.panels.code,
		BackgroundColor3 = theme().bg,
		BackgroundTransparency = 0.2,
		Visible = false,
		GroupTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2101,
		Parent = codeOverlay,
	})
	corner(codeFrame, 14)
	stroke(codeFrame, 0.84)
	padding(codeFrame, 16, 14, 16, 14)

	codeTitle = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 14),
		Size = UDim2.new(1, -68, 0, 24),
		Text = "Code Window",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2102,
		Parent = codeFrame,
	})

	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 40),
		Size = UDim2.new(1, -32, 0, 18),
		Text = "This window is used for confirmation and code-style preview.",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2102,
		Parent = codeFrame,
	})

	codeText = make("TextBox", {
		Position = UDim2.fromOffset(16, 66),
		Size = UDim2.new(1, -32, 1, -128),
		BackgroundColor3 = theme().panel2,
		Text = "",
		ClearTextOnFocus = false,
		MultiLine = true,
		TextWrapped = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Font = Enum.Font.Code,
		TextSize = 14,
		TextColor3 = theme().text,
		PlaceholderColor3 = theme().muted,
		PlaceholderText = "Code / action preview",
		ZIndex = 2102,
		Parent = codeFrame,
	})
	corner(codeText, 12)
	stroke(codeText, 0.92)
	padding(codeText, 12, 12, 12, 12)

	codeConfirmBtn = make("TextButton", {
		Position = UDim2.new(0, 16, 1, -48),
		Size = UDim2.fromOffset(132, 34),
		BackgroundColor3 = theme().accent,
		Text = "Confirm",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = theme().onAccent,
		AutoButtonColor = false,
		ZIndex = 2102,
		Parent = codeFrame,
	})
	corner(codeConfirmBtn, 10)
	stroke(codeConfirmBtn, 0.82)

	codeCancelBtn = make("TextButton", {
		Position = UDim2.new(0, 156, 1, -48),
		Size = UDim2.fromOffset(132, 34),
		BackgroundColor3 = theme().panel2,
		Text = "Cancel",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		ZIndex = 2102,
		Parent = codeFrame,
	})
	corner(codeCancelBtn, 10)
	stroke(codeCancelBtn, 0.92)

	confirmOverlay = make("Frame", {
		Name = "ConfirmOverlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		BorderSizePixel = 0,
		ZIndex = 2200,
		Parent = gui,
	})

	confirmFrame = make("CanvasGroup", {
		Name = "ConfirmFrame",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = CONFIG.panels.confirm,
		BackgroundColor3 = theme().bg,
		BackgroundTransparency = 0.2,
		Visible = false,
		GroupTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2201,
		Parent = confirmOverlay,
	})
	corner(confirmFrame, 14)
	stroke(confirmFrame, 0.84)
	padding(confirmFrame, 18, 16, 18, 16)

	confirmTitle = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 16),
		Size = UDim2.new(1, -36, 0, 24),
		Text = "Are you sure?",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2202,
		Parent = confirmFrame,
	})

	confirmBody = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 50),
		Size = UDim2.new(1, -36, 0, 62),
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2202,
		Parent = confirmFrame,
	})

	confirmYes = make("TextButton", {
		Position = UDim2.new(0, 18, 1, -46),
		Size = UDim2.fromOffset(150, 34),
		BackgroundColor3 = theme().danger,
		Text = "Yes, continue",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(255,255,255),
		AutoButtonColor = false,
		ZIndex = 2202,
		Parent = confirmFrame,
	})
	corner(confirmYes, 10)
	stroke(confirmYes, 0.88)

	confirmNo = make("TextButton", {
		Position = UDim2.new(0, 176, 1, -46),
		Size = UDim2.fromOffset(120, 34),
		BackgroundColor3 = theme().panel2,
		Text = "Cancel",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		ZIndex = 2202,
		Parent = confirmFrame,
	})
	corner(confirmNo, 10)
	stroke(confirmNo, 0.92)

	bindGlobalInputEvents()

	state.updateRoot = make("Frame", {
		Name = "UpdateRoot",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		BorderSizePixel = 0,
		ZIndex = 6000,
		Parent = gui,
	})

	state.updateBackdrop = make("TextButton", {
		Name = "Backdrop",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 6000,
		Parent = state.updateRoot,
	})

	state.updateFrame = make("Frame", {
		Name = "UpdateCard",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(400, 250),
		BackgroundColor3 = theme().panel,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Active = true,
		ZIndex = 6001,
		Parent = state.updateRoot,
	})
	corner(state.updateFrame, 16)
	stroke(state.updateFrame, 0.8)
	addShadow(state.updateFrame, 24, 0.42, 10, 2)
	padding(state.updateFrame, 24, 22, 24, 18)

	local updateArt = make("ImageLabel", {
		Name = "Artwork",
		Position = UDim2.fromOffset(-24, -22),
		Size = UDim2.new(1, 48, 1, 44),
		BackgroundTransparency = 1,
		Image = SETUP_WELCOME_IMAGE,
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 6001,
		Parent = state.updateFrame,
	})
	corner(updateArt, 16)

	local updateShade = make("Frame", {
		Name = "Shade",
		Position = UDim2.fromOffset(-24, -22),
		Size = UDim2.new(1, 48, 1, 44),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		ZIndex = 6001,
		Parent = state.updateFrame,
	})
	corner(updateShade, 16)

	make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 26),
		Text = "New Update",
		LangKey = "update.title",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6002,
		Parent = state.updateFrame,
	})

	state.updateVersionLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 28),
		Size = UDim2.new(1, 0, 0, 18),
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6002,
		Parent = state.updateFrame,
	})

	state.updateDescLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 52),
		Size = UDim2.new(1, 0, 1, -112),
		Text = "",
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6002,
		Parent = state.updateFrame,
	})

	state.updateOkBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		Size = UDim2.fromOffset(104, 36),
		BackgroundColor3 = theme().accent,
		Text = "Ok",
		LangKey = "update.ok",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = theme().onAccent,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = 6002,
		Parent = state.updateFrame,
	})
	corner(state.updateOkBtn, 10)

	state.updateOkBtn.MouseButton1Click:Connect(function()
		local data = state.settingsData or {}
		local latest = tostring(data.latestVersion or "")
		data.seenNewsVersion = latest
		closeUpdateModal()
		if latest == "" then
			return
		end
		task.spawn(function()
			pcall(function()
				SettingsRF:InvokeServer("set", { seenNewsVersion = latest })
			end)
		end)
	end)

	state.colorPickerOverlay = make("Frame", {
		Name = "ColorPickerOverlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.45,
		Visible = false,
		BorderSizePixel = 0,
		ZIndex = 2400,
		Parent = gui,
	})

	state.colorPickerFrame = make("Frame", {
		Name = "ColorPickerFrame",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(360, 470),
		BackgroundColor3 = theme().bg,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		ZIndex = 2401,
		Parent = state.colorPickerOverlay,
	})
	corner(state.colorPickerFrame, 14)
	stroke(state.colorPickerFrame, 0.7)
	addShadow(state.colorPickerFrame, 22, 0.45, 8, 2)
	state.colorPickerScale = make("UIScale", { Scale = 1, Parent = state.colorPickerFrame })

	state.colorPickerTitle = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 14),
		Size = UDim2.new(1, -70, 0, 24),
		Text = "Custom Accent Color",
		LangKey = "settings.accentTitle",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2402,
		Parent = state.colorPickerFrame,
	})

	state.colorPickerCloseBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 12),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = theme().card,
		Text = "X",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		ZIndex = 2403,
		Parent = state.colorPickerFrame,
	})
	corner(state.colorPickerCloseBtn, 8)
	stroke(state.colorPickerCloseBtn, 0.5)

	state.colorWheelHolder = make("Frame", {
		Name = "ColorWheelHolder",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 52),
		Size = UDim2.fromOffset(200, 200),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2402,
		Parent = state.colorPickerFrame,
	})

	state.colorWheelImage = make("ImageButton", {
		Name = "ColorWheel",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = COLOR_WHEEL_IMAGE,
		Rotation = COLOR_WHEEL_ROTATION,
		ScaleType = Enum.ScaleType.Fit,
		AutoButtonColor = false,
		ZIndex = 2402,
		Parent = state.colorWheelHolder,
	})

	state.colorWheelShade = make("Frame", {
		Name = "WheelShade",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2403,
		Parent = state.colorWheelHolder,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = state.colorWheelShade })

	state.colorWheelCursor = make("Frame", {
		Name = "WheelCursor",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 2405,
		Parent = state.colorWheelHolder,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = state.colorWheelCursor })
	make("UIStroke", { Color = Color3.fromRGB(20, 20, 20), Thickness = 2, Parent = state.colorWheelCursor })

	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 262),
		Size = UDim2.new(1, -36, 0, 16),
		Text = "Brightness",
		LangKey = "ui.brightness",
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2402,
		Parent = state.colorPickerFrame,
	})

	state.colorValueSlider = make("TextButton", {
		Name = "ValueSlider",
		Position = UDim2.fromOffset(18, 282),
		Size = UDim2.new(1, -36, 0, 22),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = 2402,
		Parent = state.colorPickerFrame,
	})
	corner(state.colorValueSlider, 8)
	state.colorValueGradient = make("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), DEFAULT_CUSTOM_ACCENT),
		Parent = state.colorValueSlider,
	})
	state.colorValueKnob = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(1, 0.5),
		Size = UDim2.fromOffset(10, 28),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 2404,
		Parent = state.colorValueSlider,
	})
	corner(state.colorValueKnob, 4)
	make("UIStroke", { Color = Color3.fromRGB(20, 20, 20), Thickness = 2, Parent = state.colorValueKnob })

	state.colorPreviewBox = make("Frame", {
		Position = UDim2.fromOffset(18, 318),
		Size = UDim2.fromOffset(60, 44),
		BackgroundColor3 = DEFAULT_CUSTOM_ACCENT,
		BorderSizePixel = 0,
		ZIndex = 2402,
		Parent = state.colorPickerFrame,
	})
	corner(state.colorPreviewBox, 10)
	stroke(state.colorPreviewBox, 0.6)

	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(88, 318),
		Size = UDim2.fromOffset(40, 20),
		Text = "HEX",
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2402,
		Parent = state.colorPickerFrame,
	})
	state.colorHexBox = make("TextBox", {
		Position = UDim2.fromOffset(88, 338),
		Size = UDim2.new(1, -106, 0, 24),
		BackgroundColor3 = theme().panel2,
		Text = "#00DCFF",
		PlaceholderText = "#RRGGBB",
		ClearTextOnFocus = false,
		Font = Enum.Font.Code,
		TextSize = 13,
		TextColor3 = theme().text,
		PlaceholderColor3 = theme().muted,
		ZIndex = 2402,
		Parent = state.colorPickerFrame,
	})
	corner(state.colorHexBox, 8)
	stroke(state.colorHexBox, 0.85)

	state.colorRgbBoxes = {}
	for i, channel in ipairs({ "R", "G", "B" }) do
		local offsetX = 18 + (i - 1) * 110
		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(offsetX, 372),
			Size = UDim2.fromOffset(20, 18),
			Text = channel,
			Font = Enum.Font.GothamSemibold,
			TextSize = 12,
			TextColor3 = theme().muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 2402,
			Parent = state.colorPickerFrame,
		})
		local box = make("TextBox", {
			Position = UDim2.fromOffset(offsetX + 22, 370),
			Size = UDim2.fromOffset(76, 24),
			BackgroundColor3 = theme().panel2,
			Text = "0",
			ClearTextOnFocus = false,
			Font = Enum.Font.Code,
			TextSize = 13,
			TextColor3 = theme().text,
			ZIndex = 2402,
			Parent = state.colorPickerFrame,
		})
		corner(box, 8)
		stroke(box, 0.85)
		state.colorRgbBoxes[channel] = box
	end

	state.colorPickerApplyBtn = make("TextButton", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 18, 1, -16),
		Size = UDim2.new(0.5, -22, 0, 36),
		BackgroundColor3 = theme().accent,
		Text = "Use this color",
		LangKey = "ui.useColor",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = theme().onAccent,
		AutoButtonColor = false,
		ZIndex = 2402,
		Parent = state.colorPickerFrame,
	})
	corner(state.colorPickerApplyBtn, 10)
	stroke(state.colorPickerApplyBtn, 0.85)

	state.colorPickerCancelBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -18, 1, -16),
		Size = UDim2.new(0.5, -22, 0, 36),
		BackgroundColor3 = theme().panel2,
		Text = "Cancel",
		LangKey = "ui.cancel",
		Font = Enum.Font.GothamSemibold,
		TextSize = 14,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		ZIndex = 2402,
		Parent = state.colorPickerFrame,
	})
	corner(state.colorPickerCancelBtn, 10)
	stroke(state.colorPickerCancelBtn, 0.85)

	bindColorPickerEvents()

	notesModalOverlay = make("Frame", {
		Name = "NotesModalOverlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		BorderSizePixel = 0,
		ZIndex = 2300,
		Parent = gui,
	})

	notesModalFrame = make("CanvasGroup", {
		Name = "NotesModalFrame",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = CONFIG.panels.notes,
		BackgroundColor3 = theme().bg,
		BackgroundTransparency = 0.2,
		Visible = false,
		GroupTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2301,
		Parent = notesModalOverlay,
	})
	corner(notesModalFrame, 14)
	stroke(notesModalFrame, 0.84)
	padding(notesModalFrame, 18, 16, 18, 16)

	notesModalTitle = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 16),
		Size = UDim2.new(1, -70, 0, 24),
		Text = "Notes",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2302,
		Parent = notesModalFrame,
	})

	notesModalCloseBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 12),
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = theme().card,
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		ZIndex = 2303,
		Parent = notesModalFrame,
	})
	corner(notesModalCloseBtn, 10)
	stroke(notesModalCloseBtn, 0.4)

	notesModalAddBox = make("TextBox", {
		Position = UDim2.fromOffset(18, 54),
		Size = UDim2.new(1, -120, 0, 36),
		BackgroundColor3 = theme().panel2,
		Text = "",
		PlaceholderText = "Add a new note...",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = theme().text,
		PlaceholderColor3 = theme().muted,
		ZIndex = 2302,
		Parent = notesModalFrame,
	})
	corner(notesModalAddBox, 10)
	stroke(notesModalAddBox, 0.35)

	notesModalAddBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 54),
		Size = UDim2.fromOffset(86, 36),
		BackgroundColor3 = theme().accent,
		Text = "Add",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = theme().onAccent,
		AutoButtonColor = false,
		ZIndex = 2302,
		Parent = notesModalFrame,
	})
	corner(notesModalAddBtn, 10)
	stroke(notesModalAddBtn, 0.3)

	notesModalScroll = make("ScrollingFrame", {
		Position = UDim2.fromOffset(18, 100),
		Size = UDim2.new(1, -36, 1, -118),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme().text,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 2302,
		Parent = notesModalFrame,
	})
	notesModalListHolder = make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 2302,
		Parent = notesModalScroll,
	})
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = notesModalListHolder,
	})
	notesModalEmptyLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 30),
		Text = "No notes for this player yet.",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 2302,
		Parent = notesModalListHolder,
	})

	moderationFilterOverlay = make("Frame", {
		Name = "ModerationFilterOverlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		BorderSizePixel = 0,
		ZIndex = 2400,
		Parent = gui,
	})

	moderationFilterFrame = make("CanvasGroup", {
		Name = "ModerationFilterFrame",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(560, 360),
		BackgroundColor3 = theme().bg,
		BackgroundTransparency = 0.18,
		Visible = false,
		GroupTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 2401,
		Parent = moderationFilterOverlay,
	})
	corner(moderationFilterFrame, 14)
	stroke(moderationFilterFrame, 0.84)
	padding(moderationFilterFrame, 18, 16, 18, 16)

	moderationFilterTitle = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 16),
		Size = UDim2.new(1, -70, 0, 24),
		Text = "Moderation Filter",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2402,
		Parent = moderationFilterFrame,
	})

	moderationFilterCloseBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 12),
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = theme().card,
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		ZIndex = 2403,
		Parent = moderationFilterFrame,
	})
	corner(moderationFilterCloseBtn, 10)
	stroke(moderationFilterCloseBtn, 0.4)
	moderationFilterCloseBtn.MouseButton1Click:Connect(function()
		closeModerationFilterModal()
	end)

	local moderationFilterInfoLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 46),
		Size = UDim2.new(1, -36, 0, 18),
		Text = "Use these fields to filter by who did what.",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2402,
		Parent = moderationFilterFrame,
	})

	local function addFilterRow(y, labelText, placeholder)
		local label = make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(18, y),
			Size = UDim2.new(1, -36, 0, 16),
			Text = labelText,
			Font = Enum.Font.GothamSemibold,
			TextSize = 12,
			TextColor3 = theme().text,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 2402,
			Parent = moderationFilterFrame,
		})
		local box = make("TextBox", {
			Position = UDim2.fromOffset(18, y + 18),
			Size = UDim2.new(1, -36, 0, 34),
			BackgroundColor3 = theme().panel2,
			Text = "",
			PlaceholderText = placeholder,
			ClearTextOnFocus = false,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = theme().text,
			PlaceholderColor3 = theme().muted,
			ZIndex = 2402,
			Parent = moderationFilterFrame,
		})
		corner(box, 10)
		stroke(box, 0.35)
		return label, box
	end

	_, moderationFilterModeratorBox = addFilterRow(74, "Moderator / who did it", "e.g. Player1, admin name")
	_, moderationFilterTargetBox = addFilterRow(126, "Target / who it was done to", "e.g. Player2")
	_, moderationFilterActionBox = addFilterRow(178, "Action / what was done", "e.g. Kick, Fly, Ban")
	_, moderationFilterReasonBox = addFilterRow(230, "Reason / notes", "optional text")

	local filterBoxes = { moderationFilterModeratorBox, moderationFilterTargetBox, moderationFilterActionBox, moderationFilterReasonBox }
	for _, box in ipairs(filterBoxes) do
		if box then
			box.FocusLost:Connect(function(enterPressed)
				if enterPressed then
					applyModerationFiltersFromBoxes()
				end
			end)
		end
	end

	moderationFilterApplyBtn = make("TextButton", {
		Position = UDim2.new(0, 18, 1, -52),
		Size = UDim2.fromOffset(120, 34),
		BackgroundColor3 = theme().accent,
		Text = "Apply",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = theme().onAccent,
		AutoButtonColor = false,
		ZIndex = 2402,
		Parent = moderationFilterFrame,
	})
	corner(moderationFilterApplyBtn, 10)
	stroke(moderationFilterApplyBtn, 0.3)
	moderationFilterApplyBtn.MouseButton1Click:Connect(function()
		applyModerationFiltersFromBoxes()
	end)

	moderationFilterClearBtn = make("TextButton", {
		Position = UDim2.new(0, 150, 1, -52),
		Size = UDim2.fromOffset(120, 34),
		BackgroundColor3 = theme().card,
		Text = "Clear",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		ZIndex = 2402,
		Parent = moderationFilterFrame,
	})
	corner(moderationFilterClearBtn, 10)
	stroke(moderationFilterClearBtn, 0.35)
	moderationFilterClearBtn.MouseButton1Click:Connect(function()
		clearModerationFilters()
	end)

	local moderationFilterHintLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -18, 1, -44),
		Size = UDim2.new(1, -300, 0, 18),
		Text = "Press Enter inside a box to apply.",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 2402,
		Parent = moderationFilterFrame,
	})

	main = make("CanvasGroup", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = CONFIG.panels.main,
		BackgroundColor3 = theme().bg,
		BackgroundTransparency = 0.2,
		Visible = false,
		GroupTransparency = 1,
		ClipsDescendants = true,
		BorderSizePixel = 0,
		Parent = gui,
	})

	addShadow(main, 26, 0.45, 10, 2)
	mainScale = make("UIScale", { Scale = 1, Parent = main })
	responsiveScale = make("UIScale", { Scale = 1, Parent = main })
	corner(main, 18)
	stroke(main, 0.84)

	topbar = make("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = theme().panel,
		BackgroundTransparency = 0.28,
		BorderSizePixel = 0,
		Parent = main,
	})
	corner(topbar, 18)
	stroke(topbar, 0.9)

	state.dragHandle = make("TextButton", {
		Name = "DragHandle",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 2),
		Size = UDim2.fromOffset(64, 14),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = topbar,
	})

	state.dragHandleBar = make("Frame", {
		Name = "Bar",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(40, 4),
		BackgroundColor3 = theme().muted,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Parent = state.dragHandle,
	})
	corner(state.dragHandleBar, 3)

	state.dragHandle.MouseEnter:Connect(function()
		if state.dragHandleBar then
			state.dragHandleBar.BackgroundTransparency = 0.1
		end
	end)
	state.dragHandle.MouseLeave:Connect(function()
		if state.dragHandleBar then
			state.dragHandleBar.BackgroundTransparency = 0.35
		end
	end)

	state.titleIcon = make("ImageLabel", {
		Name = "TitleIcon",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		BackgroundTransparency = 1,
		Image = "rbxassetid://81909648565988",
		ImageTransparency = 0,
		ScaleType = Enum.ScaleType.Fit,
		Parent = topbar,
	})
	titleLbl = make("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0.5, 0),
		Size = UDim2.new(1, -80, 0, 26),
		Font = Enum.Font.GothamBold,
		Text = "Zone Panel V8.5 [Pro] [beta]",
		TextSize = 21,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = topbar,
	})

	task.defer(function()
		if state.titleIcon and titleLbl then
			state.titleIcon.Position = UDim2.new(0, 16 + math.ceil(titleLbl.TextBounds.X) + 8, 0.5, 0)
		end
	end)
	titleLbl:GetPropertyChangedSignal("TextBounds"):Connect(function()
		if state.titleIcon then
			state.titleIcon.Position = UDim2.new(0, 16 + math.ceil(titleLbl.TextBounds.X) + 8, 0.5, 0)
		end
	end)

	closeBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(36, 36),
		BackgroundColor3 = theme().card,
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 26,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		Parent = topbar,
	})
	corner(closeBtn, 12)
	stroke(closeBtn, 0.92)

	resizeGrip = make("TextButton", {
		Name = "ResizeGrip",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -6, 1, -6),
		Size = UDim2.fromOffset(28, 28),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 40,
		Parent = main,
	})

	resizeGripIcon = make("ImageLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(22, 22),
		Image = RESIZE_GRIP_ICON,
		ImageColor3 = theme().muted,
		ImageTransparency = 0.25,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 41,
		Parent = resizeGrip,
	})


	function syncTopbarControls()
		if not closeBtn or not resizeGrip then
			return
		end
		if state.mobile then
			return
		end
		closeBtn.AnchorPoint = Vector2.new(1, 0.5)
		closeBtn.Position = UDim2.new(1, -14, 0.5, 0)
		resizeGrip.AnchorPoint = Vector2.new(1, 1)
		resizeGrip.Position = UDim2.new(1, -6, 1, -6)
	end
	syncTopbarControls()

	resizeGrip.MouseEnter:Connect(function()
		if state.mobile then
			return
		end
		if resizeGripIcon then
			resizeGripIcon.ImageTransparency = 0
		end
	end)
	resizeGrip.MouseLeave:Connect(function()
		if state.mobile then
			return
		end
		if resizeGripIcon then
			resizeGripIcon.ImageTransparency = 0.25
		end
	end)

	sidebar = make("ScrollingFrame", {
		Name = "Sidebar",
		Position = UDim2.fromOffset(12, 68),
		Size = UDim2.new(0, 66, 1, -80),
		BackgroundColor3 = theme().panel2,
		BackgroundTransparency = 0.22,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme().text,
		ScrollBarImageTransparency = 0.25,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollingEnabled = true,
		Active = true,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = main,
	})
	corner(sidebar, 16)
	stroke(sidebar, 0.9)
	padding(sidebar, 8, 12, 8, 12)

	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sidebar,
	})

	state.sidebarToggleBtn = make("TextButton", {
		Name = "SidebarToggle",
		LayoutOrder = 0,
		Size = UDim2.fromOffset(CONFIG.sidebarBtnSize, 34),
		BackgroundColor3 = theme().panel2,
		BackgroundTransparency = 0.15,
		Text = "",
		AutoButtonColor = false,
		Parent = sidebar,
	})
	corner(state.sidebarToggleBtn, 10)
	stroke(state.sidebarToggleBtn, 0.92)

	state.sidebarToggleGlyph = make("ImageLabel", {
		Name = "Glyph",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0.5, -11, 0.5, 0),
		Size = UDim2.fromOffset(22, 22),
		BackgroundTransparency = 1,
		Image = SIDEBAR_MENU_ICON,
		ImageColor3 = theme().icon,
		ScaleType = Enum.ScaleType.Fit,
		Parent = state.sidebarToggleBtn,
	})

	state.sidebarToggleLabel = make("TextLabel", {
		Name = "Label",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 46, 0.5, 0),
		Size = UDim2.new(1, -56, 0, 18),
		BackgroundTransparency = 1,
		Text = "Menu",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = theme().muted,
		TextTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Visible = false,
		Parent = state.sidebarToggleBtn,
	})

	state.sidebarToggleBtn.MouseButton1Click:Connect(toggleSidebar)

	sidebarHomeBtn = makeSidebarIconBtn(sidebar, 1, "rbxassetid://135652227630352", "HomeTab", ZoneT("tab.home"))
	state.sidebarActionsBtn = makeSidebarIconBtn(sidebar, 2, "rbxassetid://140013014943385", "ActionsTab", ZoneT("tab.actions"))
	sidebarServerBtn = makeSidebarIconBtn(sidebar, 3, "rbxassetid://9692125126", "ServerTab", ZoneT("tab.server"))
	sidebarAdminsBtn = makeSidebarIconBtn(sidebar, 4, "rbxassetid://71587075450887", "AdminsTab", ZoneT("tab.admins"))
	sidebarBanBtn = makeSidebarIconBtn(sidebar, 5, "rbxassetid://83002980114464", "BanTab", ZoneT("home.tile.ban.label"))
	if sidebarAdminsBtn then
		sidebarAdminsBtn.Visible = canSeeAdminsTab()
	end
	state.chatTabBtn = makeSidebarIconBtn(sidebar, 6, "rbxassetid://7164927415", "ChatTab", ZoneT("tab.chat"))
	task.defer(function()
		ensureChatUnreadDot()
	end)
	sidebarAnnounceBtn = makeSidebarIconBtn(sidebar, 7, ANNOUNCE_TAB_ICON, "AnnounceTab", ZoneT("tab.announce"))
	if sidebarAnnounceBtn then
		sidebarAnnounceBtn.Visible = canUseAnnounceTab()
	end
	state.sidebarModerationBtn = makeSidebarIconBtn(sidebar, 8, HISTORY_TAB_ICON, "HistoryTab", ZoneT("tab.moderation"))
	sidebarCreditsBtn = makeSidebarIconBtn(sidebar, 9, "rbxassetid://76311199408449", "InfoTab", ZoneT("tab.credits"))
	sidebarSettingsBtn = makeSidebarIconBtn(sidebar, 10, "rbxassetid://7059346373", "SettingsTab", ZoneT("tab.settings"))
	zoneApplyRoleTabs()
	state.sidebarBaseOrder = {}
	for btn in pairs(state.sidebarButtons or {}) do
		if btn and btn.Parent then
			state.sidebarBaseOrder[btn.Name] = btn.LayoutOrder
		end
	end
	task.defer(resizeSidebarToContent)
	applySavedSidebarOrder()
	state.sidebarLastSent = state.sidebarOrderText
	startSidebarOrderWatcher()

	mobileScroll = make("ScrollingFrame", {
		Name = "MobileContentScroll",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = theme().text,
		ScrollingEnabled = true,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = main,
	})

	mobileInner = make("Frame", {
		Name = "MobileContentInner",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = mobileScroll,
	})
	padding(mobileInner, 0, 0, 0, 14)
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = mobileInner,
	})

	mobileHeader = make("Frame", {
		Name = "MobileHeader",
		BackgroundColor3 = theme().panel,
		BackgroundTransparency = 0.22,
		BorderSizePixel = 0,
		Visible = false,
		Parent = main,
	})
	corner(mobileHeader, 16)
	stroke(mobileHeader, 0.9)
	padding(mobileHeader, 12, 10, 12, 10)

	mobileHeaderTitle = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -48, 0, 24),
		Text = "Zone Panel V8.5 [Pro] [beta]",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = mobileHeader,
	})

	mobileHeaderSubtitle = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 26),
		Size = UDim2.new(1, -48, 0, 16),
		Text = "Tap a tab below, then scroll the page.",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = mobileHeader,
	})

	mobileCloseBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = theme().card,
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		Parent = mobileHeader,
	})
	corner(mobileCloseBtn, 10)
	stroke(mobileCloseBtn, 0.92)
	mobileCloseBtn.MouseButton1Click:Connect(function()
		togglePanel()
	end)

	mobileTabScroll = make("ScrollingFrame", {
		Name = "MobileTabScroll",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 50),
		Size = UDim2.new(1, 0, 0, 42),
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		Parent = mobileHeader,
	})

	mobileTabHolder = make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = mobileTabScroll,
	})
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = mobileTabHolder,
	})
	buildMobileNav()

	left = make("Frame", {
		Name = "Left",
		Position = UDim2.fromOffset(90, 68),
		Size = UDim2.new(0, 260, 1, -80),
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = theme().panel,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = main,
	})
	corner(left, 16)
	stroke(left, 0.92)
	padding(left, 12, 12, 12, 12)

	right = make("Frame", {
		Name = "Right",
		Position = UDim2.fromOffset(362, 68),
		Size = UDim2.new(1, -374, 1, -80),
		BackgroundColor3 = theme().panel,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = main,
	})

	rightScale = make("UIScale", { Scale = 1, Parent = right })
	corner(right, 16)
	stroke(right, 0.92)
	padding(right, 12, 12, 12, 12)

	make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Text = "Target",
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = left,
	})

	local targetRow = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 20),
		Size = UDim2.new(1, 0, 0, 38),
		Parent = left,
	})

	targetBox = make("TextBox", {
		Size = UDim2.new(1, -52, 1, 0),
		BackgroundColor3 = theme().card,
		Text = "",
		PlaceholderText = "Username",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = theme().text,
		PlaceholderColor3 = theme().muted,
		Parent = targetRow,
	})
	corner(targetBox, 12)
	stroke(targetBox, 0.92)

	resolveBtn = make("ImageButton", {
		Size = UDim2.new(0, 44, 1, 0),
		Position = UDim2.new(1, -44, 0, 0),
		BackgroundColor3 = theme().panel2,
		Image = "rbxassetid://118685771787843",   
		ImageColor3 = theme().text,
		ScaleType = Enum.ScaleType.Fit,
		AutoButtonColor = false,
		Parent = targetRow,
	})
	corner(resolveBtn, 12)
	stroke(resolveBtn, 0.92)

	avatarImage = make("ImageLabel", {
		Position = UDim2.fromOffset(0, 70),
		Size = UDim2.fromOffset(68, 68),
		BackgroundColor3 = theme().card,
		BorderSizePixel = 0,
		Image = "",
		ScaleType = Enum.ScaleType.Crop,
		Parent = left,
	})
	corner(avatarImage, 14)
	stroke(avatarImage, 0.9)

	state.targetPresenceRing = make("Frame", {
		Name = "PresenceRing",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 2, 1, 2),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = theme().panel,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 6,
		Parent = avatarImage,
	})
	corner(state.targetPresenceRing, 10)

	state.targetPresenceDot = make("Frame", {
		Name = "PresenceDot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = theme().muted,
		BorderSizePixel = 0,
		ZIndex = 7,
		Parent = state.targetPresenceRing,
	})
	corner(state.targetPresenceDot, 7)

	selectedName = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(78, 70),
		Size = UDim2.new(1, -78, 0, 20),
		Text = "No player selected",
		TextSize = 18,
		TextColor3 = theme().text,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = left,
	})

	selectedInfo = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(78, 94),
		Size = UDim2.new(1, -78, 0, 44),
		Text = "Select a player",
		TextSize = 13,
		TextColor3 = theme().muted,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = left,
	})

	viewNotesBtn = make("TextButton", {
		Position = UDim2.fromOffset(0, 146),
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = theme().panel2,
		Text = "Notes (0)",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		Visible = false,
		Parent = left,
	})
	corner(viewNotesBtn, 10)
	stroke(viewNotesBtn, 0.92)
	viewNotesBtn.MouseButton1Click:Connect(openNotesModal)

	statusLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 182),
		Size = UDim2.new(1, 0, 0, 18),
		Text = "",
		TextSize = 12,
		TextColor3 = theme().success,
		Font = Enum.Font.GothamSemibold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = left,
	})

	local infoHolder = make("ScrollingFrame", {
		BackgroundColor3 = theme().card,
		BackgroundTransparency = 0.15,
		Position = UDim2.fromOffset(0, 202),
		Size = UDim2.new(1, 0, 1, -214),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme().text,
		Parent = left,
	})

	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = infoHolder,
	})
	corner(infoHolder, 12)
	padding(infoHolder, 12, 12, 12, 12)
	state.targetInfoHolder = infoHolder
	layoutTargetInfo()

	infoCards = {}
	makeInfoCard(infoHolder, "Global Rank", "Player", 68, "rbxassetid://135652227630352")
	makeInfoCard(infoHolder, "Location", "N/A", 72, "rbxassetid://9692125126")
	makeInfoCard(infoHolder, "Ban status", "N/A", 72, "rbxassetid://83002980114464")
	makeInfoCard(infoHolder, "Mute status", "N/A", 68, "rbxassetid://7164927415")
	makeInfoCard(infoHolder, "Account age", "N/A", 68, "rbxassetid://16149111731")
	makeInfoCard(infoHolder, "Ping", "Measuring...", 68, "rbxassetid://105253464688580")

	inputBar = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 76),
		Parent = right,
	})

	reasonBox = make("TextBox", {
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = theme().card,
		Text = "",
		PlaceholderText = "Reason / note text",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = theme().text,
		PlaceholderColor3 = theme().muted,
		Parent = inputBar,
	})
	corner(reasonBox, 10)
	stroke(reasonBox, 0.92)

	valueBox = make("TextBox", {
		Position = UDim2.fromOffset(0, 40),
		Size = UDim2.new(0.5, -4, 0, 34),
		BackgroundColor3 = theme().card,
		Text = "",
		PlaceholderText = "Value (speed / jump / ban minutes)",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = theme().text,
		PlaceholderColor3 = theme().muted,
		Parent = inputBar,
	})
	corner(valueBox, 10)
	stroke(valueBox, 0.92)

	local quickResolveBtn = make("TextButton", {
		Position = UDim2.new(0.5, 4, 0, 40),
		Size = UDim2.new(0.5, -4, 0, 34),
		BackgroundColor3 = theme().panel2,
		Text = "Resolve Target",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		Parent = inputBar,
	})
	corner(quickResolveBtn, 10)
	stroke(quickResolveBtn, 0.92)
	quickResolveBtn.MouseButton1Click:Connect(refreshTargetData)

	actionsScroll = make("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 84),
		Size = UDim2.new(1, 0, 1, -84),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme().text,
		CanvasSize = UDim2.new(0,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = right,
	})
	state.actionSearchBox = make("TextBox", {
		Name = "ActionSearch",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = theme().card,
		BackgroundTransparency = 0.1,
		Text = "",
		PlaceholderText = "Search commands",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = theme().text,
		PlaceholderColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = actionsScroll,
	})
	corner(state.actionSearchBox, 10)
	stroke(state.actionSearchBox, 0.9)
	padding(state.actionSearchBox, 10, 0, 10, 0)

	state.actionSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		state.actionQuery = string.lower(trim(state.actionSearchBox.Text or ""))
		buildActions()
	end)
	pinnedHolder = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 40),
		Size = UDim2.new(1, 0, 0, 80),
		Parent = actionsScroll,
	})
	make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Text = "Pinned",
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = pinnedHolder,
	})
	local pinnedGrid = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.new(1, 0, 0, 52),
		Parent = pinnedHolder,
	})
	make("UIGridLayout", {
		CellSize = UDim2.new(1 / 3, -6, 0, 34),
		CellPadding = UDim2.fromOffset(8, 8),
		FillDirectionMaxCells = 3,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = pinnedGrid,
	})

	actionsHolder = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 112),
		Size = UDim2.new(1, 0, 1, -112),
		Parent = actionsScroll,
	})
	make("UIGridLayout", {
		CellSize = UDim2.new(1 / 3, -6, 0, 34),
		CellPadding = UDim2.fromOffset(8, 8),
		FillDirectionMaxCells = 3,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = actionsHolder,
	})

	buildHomePanel()
	refreshHomeUpdateCard()
	ensureBackgroundLayer()
	buildMobileOpenButton()

	adminsScroll = make("ScrollingFrame", {
		Visible = false,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme().text,
		CanvasSize = UDim2.new(0,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = right,
	})

	serverScroll = make("ScrollingFrame", {
		Visible = false,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme().text,
		CanvasSize = UDim2.new(0,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = right,
	})

	banScroll = make("ScrollingFrame", {
		Visible = false,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme().text,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = right,
	})
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -140, 0, 18),
		Text = "Ban List",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = banScroll,
	})
	banRefreshLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 20),
		Size = UDim2.new(1, 0, 0, 16),
		Text = "Search banned players or unban them instantly.",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = banScroll,
	})
	local banSearchRow = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 42),
		Size = UDim2.new(1, 0, 0, 38),
		Parent = banScroll,
	})
	banSearchBox = make("TextBox", {
		Size = UDim2.new(1, -92, 1, 0),
		BackgroundColor3 = theme().card,
		Text = "",
		PlaceholderText = "Search by name, reason, or UserId",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = theme().text,
		PlaceholderColor3 = theme().muted,
		Parent = banSearchRow,
	})
	corner(banSearchBox, 10)
	stroke(banSearchBox, 0.92)
	local banRefreshBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 82, 1, 0),
		BackgroundColor3 = theme().panel2,
		Text = "Refresh",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		Parent = banSearchRow,
	})
	corner(banRefreshBtn, 10)
	stroke(banRefreshBtn, 0.92)
	banRefreshBtn.MouseButton1Click:Connect(function()
		refreshBanPanel()
	end)
	banCountLabel = make("TextLabel", {
		Visible = false,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 84),
		Size = UDim2.new(1, 0, 0, 16),
		Text = "0 banned players",
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = banScroll,
	})
	banEmptyLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 106),
		Size = UDim2.new(1, 0, 0, 22),
		Text = "No banned players found.",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = banScroll,
	})
	banListHolder = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 132),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = banScroll,
	})
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = banListHolder,
	})

	settingsScroll = make("ScrollingFrame", {
		Visible = false,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme().text,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = right,
	})
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -140, 0, 18),
		Text = "Settings",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = settingsScroll,
	})
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 20),
		Size = UDim2.new(1, 0, 0, 16),
		Text = "Use the toggles below to control the panel.",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = settingsScroll,
	})
	local settingsCard = make("Frame", {
		BackgroundColor3 = theme().card,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.fromOffset(0, 40),
		Parent = settingsScroll,
	})
	corner(settingsCard, 12)
	stroke(settingsCard, 0.92)
	padding(settingsCard, 12, 8, 12, 12)
	make("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = settingsCard,
	})
	buildUpdateBanner(settingsCard, 4)
	buildSettingsSwitches(settingsCard, 5)
	buildSettingsBgStyleRow(settingsCard, 20)
	buildThemePicker(settingsCard, 21)
	settingsWebhookBox = make("TextBox", {
		LayoutOrder = 22,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "Webhook URL",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = theme().text,
		PlaceholderColor3 = theme().muted,
		Visible = false,
		Parent = settingsCard,
	})
	settingsStatusLabel = make("TextLabel", {
		Visible = true,
		LayoutOrder = 23,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Text = "Tap save after editing fields.",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = settingsCard,
	})
	settingsSaveBtn = make("TextButton", {
		LayoutOrder = 24,
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = theme().accent,
		Text = "Save settings",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = theme().onAccent,
		AutoButtonColor = false,
		Parent = settingsCard,
	})
	corner(settingsSaveBtn, 10)
	stroke(settingsSaveBtn, 0.92)
	buildPanicButton(settingsCard, 25)
	buildResetButton(settingsCard, 28)
	buildAnnouncePanel()

	moderationScroll = make("ScrollingFrame", {
		Visible = false,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme().text,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = right,
	})
	moderationTitleLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -264, 0, 18),
		Text = "History",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = moderationScroll,
	})
	moderationRefreshLabel = nil
	moderationCountLabel = make("TextLabel", {
		Visible = false,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 24),
		Size = UDim2.new(1, -264, 0, 16),
		Text = "Showing 0 entries",
		Font = Enum.Font.GothamSemibold,
		TextSize = 11,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = moderationScroll,
	})
	local moderationFilterBtn = make("TextButton", {
		Position = UDim2.new(1, -254, 0, 0),
		Size = UDim2.fromOffset(118, 24),
		BackgroundColor3 = theme().panel2,
		Text = "Filter",
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		Parent = moderationScroll,
	})
	corner(moderationFilterBtn, 8)
	stroke(moderationFilterBtn, 0.92)
	moderationFilterBtn.MouseButton1Click:Connect(function()
		openModerationFilterModal()
	end)

	local moderationRefreshBtn = make("TextButton", {
		Position = UDim2.new(1, -124, 0, 0),
		Size = UDim2.fromOffset(124, 24),
		BackgroundColor3 = theme().panel2,
		Text = "Refresh",
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		Parent = moderationScroll,
	})
	corner(moderationRefreshBtn, 8)
	stroke(moderationRefreshBtn, 0.92)
	moderationRefreshBtn.MouseButton1Click:Connect(function()
		refreshModerationLog()
	end)
	moderationFilterSummaryLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 44),
		Size = UDim2.new(1, -8, 0, 16),
		Text = "No filter active.",
		Font = Enum.Font.GothamSemibold,
		TextSize = 11,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = moderationScroll,
	})
	moderationListHolder = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 70),
		Size = UDim2.new(1, 0, 1, -70),
		Parent = moderationScroll,
	})
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = moderationListHolder,
	})
	moderationEmptyLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		Text = "No logs yet.",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = moderationListHolder,
	})
	refreshModerationDisplay()


	creditsScroll = make("ScrollingFrame", {
		Visible = false,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme().text,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = right,
	})
	creditsListHolder = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = creditsScroll,
	})
	make("UIListLayout", {
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = creditsListHolder,
	})

	state.chatScroll = make("ScrollingFrame", {
		Visible = false,
		Position = UDim2.fromOffset(0, 56),
		Size = UDim2.new(1, 0, 1, -110),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme().text,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = right,
	})
	state.chatTitleLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -140, 0, 18),
		Text = "Chat",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = right,
	})
	state.chatPip.minimizeBtn = make("ImageButton", {
		Name = "ChatMinimize",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -6, 0, 0),
		Size = UDim2.fromOffset(24, 24),
		BackgroundColor3 = theme().card,
		BackgroundTransparency = 0.15,
		Image = "rbxassetid://117273761878755",
		ScaleType = Enum.ScaleType.Fit,
		AutoButtonColor = false,
		Visible = false,
		Parent = right,
	})
	corner(state.chatPip.minimizeBtn, 8)
	stroke(state.chatPip.minimizeBtn, 0.9)
	state.chatPip.minimizeBtn.MouseButton1Click:Connect(openChatPip)
	state.chatStatusLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 20),
		Size = UDim2.new(1, 0, 0, 16),
		Text = "Admins only chat.",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = right,
	})
	state.chatTypingLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 10, 1, -60),
		Size = UDim2.new(1, -20, 0, 14),
		Text = "",
		Visible = false,
		Font = Enum.Font.GothamSemibold,
		TextSize = 11,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 11,
		Parent = right,
	})
	state.chatListHolder = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = state.chatScroll,
	})
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = state.chatListHolder,
	})
	state.chatFooter = make("Frame", {
		Visible = false,
		BackgroundColor3 = theme().panel2,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 54),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = right,
	})
	corner(state.chatFooter, 12)
	stroke(state.chatFooter, 0.92)
	padding(state.chatFooter, 0, 0, 0, 9)
	state.chatInputBox = make("TextBox", {
		Position = UDim2.fromOffset(10, 9),
		Size = UDim2.new(1, -114, 0, 36),
		BackgroundColor3 = theme().card,
		Text = "",
		PlaceholderText = "Type a message...",
		ClearTextOnFocus = false,
		MultiLine = true,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = theme().text,
		PlaceholderColor3 = theme().muted,
		Parent = state.chatFooter,
	})
	corner(state.chatInputBox, 10)
	stroke(state.chatInputBox, 0.92)
	state.chatSendBtn = make("ImageButton", {
		Position = UDim2.new(1, -94, 0, 9),
		Size = UDim2.new(0, 84, 0, 36),
		BackgroundColor3 = theme().panel2,
		BackgroundTransparency = 0.06,
		Image = "rbxassetid://98712755979169",
		ImageColor3 = theme().text,
		ScaleType = Enum.ScaleType.Fit,
		AutoButtonColor = false,
		Active = true,
		Selectable = true,
		ZIndex = 10,
		Parent = state.chatFooter,
	})
	corner(state.chatSendBtn, 10)
	stroke(state.chatSendBtn, 0.92)
	state.chatSendBtn.Activated:Connect(function()
		pcall(function()
			state.trySendChatMessage()
		end)
	end)
	state.chatSendBtn.MouseButton1Click:Connect(function()
		pcall(function()
			state.trySendChatMessage()
		end)
	end)
	state.chatInputBox.Focused:Connect(function()
		state.chatInputFocused = true
		state.bumpChatTyping()
	end)
	state.chatInputBox:GetPropertyChangedSignal("Text"):Connect(function()
		if state.chatInputSending then
			return
		end
		local current = state.chatInputBox.Text or ""
		if string.find(current, "\n", 1, true) then
			state.chatInputSending = true
			state.chatInputBox.Text = string.gsub(current, "\n", "")
			state.chatInputSending = false
			if trim(state.chatInputBox.Text or "") ~= "" then
				pcall(function()
					state.trySendChatMessage()
				end)
			end
			return
		end
		if state.chatInputFocused and trim(current) ~= "" then
			state.bumpChatTyping()
		end
	end)
	state.chatInputBox.FocusLost:Connect(function(enterPressed)
		state.chatInputFocused = false
		state.setChatTyping(false)
		if enterPressed then
			state.trySendChatMessage()
		end
	end)

	serverTitleLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -140, 0, 18),
		Text = "Server Manager",
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = serverScroll,
	})
	serverRefreshLabel = make("TextLabel", {
		Visible = false,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 20),
		Size = UDim2.new(1, -140, 0, 16),
		Text = "Last refresh: --:--:--",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = serverScroll,
	})
	state.espButton = make("TextButton", {
		Name = "EspToggle",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -128, 0, 0),
		Size = UDim2.fromOffset(86, 24),
		BackgroundColor3 = theme().panel2,
		Text = "ESP: Off",
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		Parent = serverScroll,
	})
	corner(state.espButton, 8)
	stroke(state.espButton, 0.92)
	state.espButton.MouseButton1Click:Connect(toggleEsp)

	local refreshServerBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(122, 24),
		BackgroundColor3 = theme().panel2,
		Text = "Refresh",
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		Parent = serverScroll,
	})
	corner(refreshServerBtn, 8)
	stroke(refreshServerBtn, 0.92)
	state.refreshServerBtn = refreshServerBtn
	refreshServerBtn.MouseButton1Click:Connect(refreshServerPanel)

	state.serverStatCards = {}

	local statRow = make("Frame", {
		Name = "ServerStatRow",
		Position = UDim2.fromOffset(0, 34),
		Size = UDim2.new(1, 0, 0, 88),
		BackgroundTransparency = 1,
		Parent = serverScroll,
	})
	make("UIGridLayout", {
		CellSize = UDim2.new(0.25, -6, 0, 88),
		CellPadding = UDim2.fromOffset(8, 8),
		FillDirectionMaxCells = 4,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = statRow,
	})

	local function statTile(order, caption, iconId)
		local th = theme()
		local card = make("Frame", {
			LayoutOrder = order,
			BackgroundColor3 = th.card,
			BackgroundTransparency = 0.08,
			BorderSizePixel = 0,
			Parent = statRow,
		})
		corner(card, 12)
		stroke(card, 0.92)
		addShadow(card, 10, 0.75, 3, 0)

		local box = make("Frame", {
			Name = "IconBox",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0.5, 0),
			Size = UDim2.fromOffset(52, 52),
			BackgroundColor3 = th.panel2,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Parent = card,
		})
		corner(box, 14)

		local glyph = make("ImageLabel", {
			Name = "Icon",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(34, 34),
			BackgroundTransparency = 1,
			Image = iconId,
			ImageColor3 = th.icon,
			ScaleType = Enum.ScaleType.Fit,
			Parent = box,
		})

		local label = make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(74, 20),
			Size = UDim2.new(1, -86, 0, 14),
			Text = caption,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = card,
		})

		local value = make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(74, 38),
			Size = UDim2.new(1, -86, 0, 26),
			Text = "-",
			Font = Enum.Font.GothamBold,
			TextSize = 19,
			TextColor3 = th.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = card,
		})

		table.insert(state.serverStatCards, { card = card, box = box, glyph = glyph, label = label, value = value })
		return value
	end

	state.serverPlayersStat = statTile(1, "Players", "rbxassetid://71587075450887")
	state.serverUptimeStat = statTile(2, "Uptime", "rbxassetid://9692125126")
	state.serverHealthStat = statTile(3, "Health", "rbxassetid://135652227630352")
	state.serverPingStat = statTile(4, "Your ping", "rbxassetid://7059346373")

	local loadCard = make("Frame", {
		Name = "ServerLoadCard",
		BackgroundColor3 = theme().card,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 66),
		Position = UDim2.fromOffset(0, 130),
		Parent = serverScroll,
	})
	corner(loadCard, 12)
	stroke(loadCard, 0.92)
	padding(loadCard, 14, 12, 14, 12)
	addShadow(loadCard, 10, 0.75, 3, 0)
	state.serverLoadCard = loadCard

	state.serverLoadLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -70, 0, 16),
		Text = "Server load",
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = loadCard,
	})

	state.serverLoadPercent = make("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(60, 16),
		BackgroundTransparency = 1,
		Text = "0%",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = theme().accent,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = loadCard,
	})

	local loadTrack = make("Frame", {
		Name = "LoadTrack",
		Position = UDim2.fromOffset(0, 24),
		Size = UDim2.new(1, 0, 0, 10),
		BackgroundColor3 = theme().panel2,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Parent = loadCard,
	})
	corner(loadTrack, 5)
	state.serverLoadTrack = loadTrack

	state.serverLoadFill = make("Frame", {
		Name = "LoadFill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = theme().success,
		BorderSizePixel = 0,
		Parent = loadTrack,
	})
	corner(state.serverLoadFill, 5)

	state.serverLoadNote = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 38),
		Size = UDim2.new(1, 0, 0, 14),
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = loadCard,
	})

	local detailCard = make("Frame", {
		Name = "ServerDetailCard",
		BackgroundColor3 = theme().card,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 128),
		Position = UDim2.fromOffset(0, 204),
		Parent = serverScroll,
	})
	corner(detailCard, 12)
	stroke(detailCard, 0.92)
	padding(detailCard, 14, 12, 14, 12)
	addShadow(detailCard, 10, 0.75, 3, 0)
	state.serverDetailCard = detailCard

	make("TextLabel", {
		Name = "DetailTitle",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Text = "Server details",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = detailCard,
	})

	serverSummaryValue = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 22),
		Size = UDim2.new(0.5, -8, 0, 44),
		Text = "Loading...",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextWrapped = true,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = detailCard,
	})

	serverStatusValue = make("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 22),
		Size = UDim2.new(0.5, -8, 0, 78),
		Text = "Loading...",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextWrapped = true,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = detailCard,
	})

	serverRegionValue = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 68),
		Size = UDim2.new(0.5, -8, 0, 44),
		Text = "Loading...",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextWrapped = true,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = detailCard,
	})

	local updateCard = make("Frame", {
		Name = "ServerUpdateCard",
		BackgroundColor3 = theme().card,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 150),
		Position = UDim2.fromOffset(0, 346),
		Parent = serverScroll,
	})
	corner(updateCard, 12)
	stroke(updateCard, 0.92)
	padding(updateCard, 14, 12, 14, 12)
	addShadow(updateCard, 10, 0.75, 3, 0)
	state.serverUpdateCard = updateCard

	state.serverUpdateTitle = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Text = "Server update",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = updateCard,
	})

	state.serverUpdateMessageBox = make("TextBox", {
		Name = "UpdateMessageBox",
		Position = UDim2.fromOffset(0, 24),
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = theme().panel2,
		Text = "",
		PlaceholderText = "Message (default Updating)",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = theme().text,
		PlaceholderColor3 = theme().muted,
		BorderSizePixel = 0,
		Parent = updateCard,
	})
	corner(state.serverUpdateMessageBox, 8)
	stroke(state.serverUpdateMessageBox, 0.9)

	state.serverUpdateSecondsBox = make("TextBox", {
		Name = "UpdateSecondsBox",
		Position = UDim2.fromOffset(0, 60),
		Size = UDim2.fromOffset(84, 30),
		BackgroundColor3 = theme().panel2,
		Text = "",
		PlaceholderText = "15 s",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = theme().text,
		PlaceholderColor3 = theme().muted,
		BorderSizePixel = 0,
		Parent = updateCard,
	})
	corner(state.serverUpdateSecondsBox, 8)
	stroke(state.serverUpdateSecondsBox, 0.9)

	state.serverUpdateThisBtn = make("TextButton", {
		Name = "UpdateThisBtn",
		Position = UDim2.fromOffset(92, 60),
		Size = UDim2.new(1, -92, 0, 30),
		BackgroundColor3 = theme().accent,
		Text = "Update this server",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = theme().onAccent,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = updateCard,
	})
	corner(state.serverUpdateThisBtn, 8)

	state.serverUpdateAllBtn = make("TextButton", {
		Name = "UpdateAllBtn",
		Position = UDim2.fromOffset(0, 96),
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = theme().warn,
		Text = "Update all servers",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = Color3.fromRGB(25, 25, 25),
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = updateCard,
	})
	corner(state.serverUpdateAllBtn, 8)

	state.serverUpdateThisBtn.MouseButton1Click:Connect(function()
		sendServerUpdate(false)
	end)
	state.serverUpdateAllBtn.MouseButton1Click:Connect(function()
		sendServerUpdate(true)
	end)
	refreshServerUpdateCard()

	state.serverPlayersTitle = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 512),
		Size = UDim2.new(1, 0, 0, 18),
		Text = "Players in this server",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = serverScroll,
	})
	serverPlayersHolder = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 536),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = serverScroll,
	})
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = serverPlayersHolder,
	})

	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, 0, 0, 16),
		Text = "Add admin",
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = adminsScroll,
	})

	local addRow = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 20),
		Size = UDim2.new(1, 0, 0, 38),
		Parent = adminsScroll,
	})
	adminAddBox = make("TextBox", {
		Size = UDim2.new(0.5, -4, 1, 0),
		BackgroundColor3 = theme().card,
		Text = "",
		PlaceholderText = "UserId or username",
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = theme().text,
		PlaceholderColor3 = theme().muted,
		Parent = addRow,
	})
	corner(adminAddBox, 10)
	stroke(adminAddBox, 0.92)

	adminAddRankBox = make("TextButton", {
		Position = UDim2.new(0.5, 4, 0, 0),
		Size = UDim2.new(0.32, -4, 1, 0),
		BackgroundColor3 = theme().card,
		Text = "Moderator",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		Parent = addRow,
	})
	corner(adminAddRankBox, 10)
	stroke(adminAddRankBox, 0.92)

	local rankPickerOverlay = make("ImageButton", {
		Name = "RankPickerOverlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = "",
		Visible = false,
		BorderSizePixel = 0,
		ZIndex = 3000,
		Parent = gui,
	})
	local rankPickerFrame = make("CanvasGroup", {
		Name = "RankPickerFrame",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(300, 360),
		BackgroundColor3 = theme().bg,
		BackgroundTransparency = 0.08,
		Visible = false,
		GroupTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 3001,
		Parent = rankPickerOverlay,
	})
	corner(rankPickerFrame, 14)
	stroke(rankPickerFrame, 0.84)
	padding(rankPickerFrame, 16, 14, 16, 14)

	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 14),
		Size = UDim2.new(1, -32, 0, 22),
		Text = "Select Rank",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = theme().text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3002,
		Parent = rankPickerFrame,
	})

	local rankCloseBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 10),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = theme().card,
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = theme().text,
		AutoButtonColor = false,
		ZIndex = 3003,
		Parent = rankPickerFrame,
	})
	corner(rankCloseBtn, 8)

	local rankButtonsHolder = make("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(16, 48),
		Size = UDim2.new(1, -32, 1, -64),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme().text,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 3002,
		Parent = rankPickerFrame,
	})
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = rankButtonsHolder,
	})

	local rankColors = {
		Helper = Color3.fromRGB(100, 200, 255),
		Moderator = Color3.fromRGB(100, 255, 160),
		Admin = Color3.fromRGB(255, 180, 80),
		Owner = Color3.fromRGB(255, 100, 100),
	}
	local rankOrder = { "Helper", "Moderator", "Admin", "Owner" }

	function closeRankPicker()
		local fade = tween(rankPickerFrame, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 1 })
		fade.Completed:Once(function()
			rankPickerOverlay.Visible = false
			rankPickerFrame.Visible = false
		end)
	end

	for _, rankName in ipairs(rankOrder) do
		local rb = make("TextButton", {
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = rankColors[rankName] or theme().card,
			BackgroundTransparency = 0.55,
			Text = rankName,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextColor3 = theme().text,
			AutoButtonColor = false,
			ZIndex = 3003,
			Parent = rankButtonsHolder,
		})
		corner(rb, 10)
		rb.MouseButton1Click:Connect(function()
			adminAddRankBox.Text = rankName
			closeRankPicker()
		end)
	end

	local newRoleBtn = make("TextButton", {
		Name = "NewRoleBtn",
		LayoutOrder = 999,
		Size = UDim2.new(1, -6, 0, 34),
		BackgroundColor3 = theme().accent,
		Text = "+ New custom rank",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = theme().onAccent,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 3003,
		Parent = rankButtonsHolder,
	})
	corner(newRoleBtn, 10)
	newRoleBtn.MouseButton1Click:Connect(function()
		closeRankPicker()
		openRoleEditor()
	end)

	zoneRankPickerRefresh = function()
		for _, child in ipairs(rankButtonsHolder:GetChildren()) do
			if child:IsA("TextButton") and child.Name == "CustomRankBtn" then
				child:Destroy()
			end
		end
		local isOwner = canSeeAdminsTab()
		newRoleBtn.Visible = isOwner
		local names = {}
		for roleName in pairs(ZONE_ROLE_DATA) do
			table.insert(names, roleName)
		end
		table.sort(names)
		for index, roleName in ipairs(names) do
			local def = ZONE_ROLE_DATA[roleName]
			local rb = make("TextButton", {
				Name = "CustomRankBtn",
				LayoutOrder = 100 + index,
				Size = UDim2.new(1, -6, 0, 34),
				BackgroundColor3 = hexToColor(def.color) or theme().card,
				BackgroundTransparency = 0.55,
				Text = roleName,
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				TextColor3 = theme().text,
				AutoButtonColor = false,
				ZIndex = 3003,
				Parent = rankButtonsHolder,
			})
			corner(rb, 10)
			rb.MouseButton1Click:Connect(function()
				adminAddRankBox.Text = roleName
				closeRankPicker()
			end)
			if isOwner then
				local del = make("ImageButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -8, 0.5, 0),
					Size = UDim2.fromOffset(24, 24),
					BackgroundTransparency = 1,
					Image = "rbxassetid://14002617467",
					ImageColor3 = Color3.fromRGB(255, 255, 255),
					ScaleType = Enum.ScaleType.Fit,
					AutoButtonColor = false,
					BorderSizePixel = 0,
					ZIndex = 3004,
					Parent = rb,
				})
				del.MouseButton1Click:Connect(function()
					RemoteEvent:FireServer("RoleDelete", { name = roleName }, nil)
				end)
			end
		end
	end
	zoneRankPickerRefresh()
	task.defer(function()
		RemoteEvent:FireServer("RoleList", nil, nil)
	end)

	rankCloseBtn.MouseButton1Click:Connect(closeRankPicker)
	rankPickerOverlay.MouseButton1Click:Connect(closeRankPicker)

	adminAddRankBox.MouseButton1Click:Connect(function()
		rankPickerOverlay.Visible = true
		rankPickerFrame.Visible = true
		if type(zoneRankPickerRefresh) == "function" then
			zoneRankPickerRefresh()
		end
		pcall(function()
			RemoteEvent:FireServer("RoleList", nil, nil)
		end)
		tween(rankPickerFrame, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 })
	end)

	adminAddBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0.18, 0, 1, 0),
		BackgroundColor3 = theme().accent,
		Text = "Add",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = theme().onAccent,
		AutoButtonColor = false,
		Parent = addRow,
	})
	corner(adminAddBtn, 10)
	stroke(adminAddBtn, 0.3)
	adminAddBtn.MouseButton1Click:Connect(addAdminFromInputs)

	adminsCountLabel = make("TextLabel", {
		Visible = false,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 66),
		Size = UDim2.new(1, 0, 0, 16),
		Text = "Admins: 0",
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = adminsScroll,
	})
	adminsEmptyLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 88),
		Size = UDim2.new(1, 0, 0, 22),
		Text = "No admins loaded.",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = theme().muted,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = adminsScroll,
	})
	adminsListHolder = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 114),
		Size = UDim2.new(1, 0, 1, -114),
		Parent = adminsScroll,
	})
	make("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = adminsListHolder,
	})

	setPanelSizeToDefault()
	layoutForMode()
	buildActions()
	applyThemeColors()


	if resizeGrip then
		resizeGrip.Visible = not state.mobile
		local gripSize = state.mobile and 38 or 28
		resizeGrip.Size = UDim2.fromOffset(gripSize, gripSize)
	end
	if state.dragHandle then
		state.dragHandle.Visible = not state.mobile
	end
	if state.dragHandleBar then
		state.dragHandleBar.Visible = not state.mobile
	end
	attachDrag(main, state.dragHandle)
	attachResize(main, resizeGrip)
end

-- Admin timeout screen. The server sets ZoneAdminTimeoutUntil (unix time)
-- on a timed-out admin; the panel still opens but only shows the countdown.
function zoneIsLocalTimedOut()
	local untilTime = tonumber(localPlayer:GetAttribute("ZoneAdminTimeoutUntil")) or 0
	return untilTime > workspace:GetServerTimeNow()
end

function zoneTimeoutClock(seconds)
	seconds = math.max(0, math.floor(tonumber(seconds) or 0))
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	if hours > 0 then
		return ("%d:%02d:%02d"):format(hours, minutes, secs)
	end
	return ("%02d:%02d"):format(minutes, secs)
end

function zoneTimeoutRefresh()
	if not main or not main.Parent then
		return
	end
	local timedOut = zoneIsLocalTimedOut()
	local cover = state.timeoutCover
	if timedOut and not (cover and cover.Parent) then
		local th = theme()
		cover = make("Frame", {
			Name = "TimeoutCover",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = th.panel,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Active = true,
			ZIndex = 1000,
			Parent = main,
		})
		make("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, -46),
			Size = UDim2.new(1, -40, 0, 30),
			BackgroundTransparency = 1,
			Text = "You are timed out",
			Font = Enum.Font.GothamBlack,
			TextSize = 26,
			TextColor3 = th.danger or th.text,
			ZIndex = 1001,
			Parent = cover,
		})
		state.timeoutClockLabel = make("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -40, 0, 44),
			BackgroundTransparency = 1,
			Text = "",
			Font = Enum.Font.GothamBold,
			TextSize = 38,
			TextColor3 = th.text,
			ZIndex = 1001,
			Parent = cover,
		})
		make("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 46),
			Size = UDim2.new(1, -60, 0, 36),
			BackgroundTransparency = 1,
			Text = "An Owner has paused your admin access. The panel unlocks when the timer ends.",
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextWrapped = true,
			TextColor3 = th.muted,
			ZIndex = 1001,
			Parent = cover,
		})
		local closeBtn = make("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 100),
			Size = UDim2.fromOffset(140, 34),
			BackgroundColor3 = th.panel2,
			Text = "Close",
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextColor3 = th.text,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			ZIndex = 1001,
			Parent = cover,
		})
		corner(closeBtn, 10)
		closeBtn.MouseButton1Click:Connect(function()
			closePanel()
		end)
		state.timeoutCover = cover
	end
	if cover and cover.Parent then
		cover.Visible = timedOut
	end
	if not timedOut then
		return
	end
	if type(commandBarVisible) == "function" and commandBarVisible() then
		closeCommandBar()
	end
	if state.timeoutTicking then
		return
	end
	state.timeoutTicking = true
	task.spawn(function()
		while zoneIsLocalTimedOut() do
			local untilTime = tonumber(localPlayer:GetAttribute("ZoneAdminTimeoutUntil")) or 0
			if state.timeoutClockLabel and state.timeoutClockLabel.Parent then
				state.timeoutClockLabel.Text = zoneTimeoutClock(untilTime - workspace:GetServerTimeNow())
			end
			task.wait(0.5)
		end
		state.timeoutTicking = false
		if state.timeoutCover and state.timeoutCover.Parent then
			state.timeoutCover.Visible = false
		end
	end)
end

localPlayer:GetAttributeChangedSignal("ZoneAdminTimeoutUntil"):Connect(function()
	zoneTimeoutRefresh()
end)

function openPanel(preferredTabOverride)
	if state.accessGranted ~= true or state.setupWizard then
		return
	end
	state.panelOpen = true
	scheduleAnimatedBackground(0)
	if not state.mobile then
		main.Size = clampPanelSizeToViewport(state.panelSize or main.Size or CONFIG.panels.main)
		state.panelSize = main.Size
	end
	local preferredTab = nil
	if type(preferredTabOverride) == "string" and preferredTabOverride ~= "" then
		preferredTab = preferredTabOverride
	else
		preferredTab = "home"
		if state.settingsData and state.settingsData.rememberLastTab == true then
			preferredTab = state.lastTab or state.settingsData.lastTab or state.selectedTab or "home"
		end
	end
	preferredTab = sanitizePreferredTab(preferredTab or "home")
	setTab(preferredTab or "home")
	updateBackdropBlur()
	if type(applyGlowLook) == "function" then
		applyGlowLook()
	end
	main.Visible = true
	zoneTimeoutRefresh()
	if state.chatPip.frame then
		state.chatPip.frame.Visible = state.chatPipOpen == true
	end
	main.GroupTransparency = 1
	local openShadow = main:FindFirstChildOfClass("UIShadow")
	if openShadow then
		if animationsEnabled() then
			openShadow.Transparency = 1
			tween(openShadow, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 0.45,
			})
		else
			openShadow.Transparency = 0.45
		end
	end
	if mainScale then
		if animationsEnabled() then
			mainScale.Scale = 0.94
			tween(mainScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 })
		else
			mainScale.Scale = 1
		end
	end
	tween(main, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 0 })
	rebuildVisibility()
	refreshStreamerDependentUI()
end

function closePanel()
	state.panelOpen = false
	stopBackgroundAnimation()
	if state.bgStartThread then
		task.cancel(state.bgStartThread)
		state.bgStartThread = nil
	end
	if state.bgLayer and state.bgLayer.Parent then
		state.bgLayer.Visible = false
	end
	if type(flushSidebarOrder) == "function" then
		flushSidebarOrder()
	end
	if state.accessGranted ~= true then
		return
	end
	state.lastTab = state.selectedTab or state.lastTab or "home"
	if state.settingsData and state.settingsData.rememberLastTab ~= false then
		task.spawn(function()
			pcall(function()
				SettingsRF:InvokeServer("set", {
					lastTab = state.lastTab or "home",
				})
			end)
		end)
	end
	state.panelOpen = false
	updateBackdropBlur()
	if type(applyGlowLook) == "function" then
		applyGlowLook()
	end
	local closeShadow = main:FindFirstChildOfClass("UIShadow")
	if closeShadow then
		if animationsEnabled() then
			tween(closeShadow, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
			})
		else
			closeShadow.Transparency = 1
		end
	end
	if mainScale then
		if animationsEnabled() then
			tween(mainScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.94 })
		else
			mainScale.Scale = 1
		end
	end
	tween(main, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { GroupTransparency = 1 })
	task.delay(0.14, function()
		if not state.panelOpen then
			main.Visible = false
		end
	end)
end

MOBILE_BUTTON_ICON = "rbxassetid://18979524646"

function mobileButtonEnabled()
	if state and type(state.settingsData) == "table" and state.settingsData.mobileButton ~= nil then
		return state.settingsData.mobileButton == true
	end
	return true
end

function refreshMobileButtonTheme()
	local btn = state.mobileOpenBtn
	if not btn or not btn.Parent then
		return
	end
	local th = theme()
	btn.BackgroundColor3 = th.panel
	local icon = btn:FindFirstChild("Icon")
	if icon and icon:IsA("ImageLabel") then
		icon.ImageColor3 = th.text
	end
	local st = btn:FindFirstChildOfClass("UIStroke")
	if st then
		st.Color = th.text
	end
end

function updateMobileButtonVisibility()
	local btn = state.mobileOpenBtn
	if not btn or not btn.Parent then
		return
	end
	local show = mobileButtonEnabled()
		and state.accessGranted == true
		and not state.setupWizard
	btn.Visible = show
end

function mobileButtonPositionForSize(buttonSize)
	local normalized = normalizeMobileButtonPosition(state.settingsData and state.settingsData.mobileButtonPosition)
	local xText, yText = normalized:match("^([%d%.]+),([%d%.]+)$")
	local scaleX = tonumber(xText)
	local scaleY = tonumber(yText)
	if not scaleX or not scaleY then return nil end
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local size = buttonSize or Vector2.new(54, 54)
	local maxX = math.max(4, viewport.X - size.X - 4)
	local maxY = math.max(4, viewport.Y - size.Y - 4)
	local x = 4 + scaleX * math.max(0, maxX - 4)
	local y = 4 + scaleY * math.max(0, maxY - 4)
	return UDim2.fromOffset(math.floor(x + 0.5), math.floor(y + 0.5))
end

function applySavedMobileButtonPosition(force)
	if state.mobileButtonPositionTouched and force ~= true then return end
	local btn = state.mobileOpenBtn
	if not btn or not btn.Parent then return end
	local position = mobileButtonPositionForSize(btn.AbsoluteSize)
	if position then
		state.mobileButtonPos = position
		btn.Position = position
	end
end

function encodeMobileButtonPosition(btn)
	if not btn or not btn.Parent then return "" end
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local size = btn.AbsoluteSize
	local maxX = math.max(4, viewport.X - size.X - 4)
	local maxY = math.max(4, viewport.Y - size.Y - 4)
	local spanX = math.max(1, maxX - 4)
	local spanY = math.max(1, maxY - 4)
	local x = math.clamp(btn.AbsolutePosition.X, 4, maxX)
	local y = math.clamp(btn.AbsolutePosition.Y, 4, maxY)
	return normalizeMobileButtonPosition(string.format("%.4f,%.4f", (x - 4) / spanX, (y - 4) / spanY))
end

function persistMobileButtonPosition(btn)
	local encoded = encodeMobileButtonPosition(btn)
	if encoded == "" then return end
	state.mobileButtonPositionTouched = true
	state.settingsData = type(state.settingsData) == "table" and state.settingsData or {}
	state.settingsData.mobileButtonPosition = encoded
	task.spawn(function()
		pcall(function()
			SettingsRF:InvokeServer("set", { mobileButtonPosition = encoded })
		end)
	end)
end

function resetMobileButtonPosition()
	state.mobileButtonPositionTouched = false
	state.mobileButtonPos = nil
	state.settingsData = type(state.settingsData) == "table" and state.settingsData or {}
	state.settingsData.mobileButtonPosition = ""
	local btn = state.mobileOpenBtn
	if btn and btn.Parent then
		btn.Position = UDim2.new(1, -74, 0.5, -27)
	end
end

function attachMobileButtonDrag(btn)
	local dragging = false
	local moved = false
	local startPos = nil
	local startOffset = nil
	local suppressClickUntil = 0

	btn.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		moved = false
		startPos = input.Position
		startOffset = btn.AbsolutePosition
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if moved then
					state.mobileButtonPos = btn.Position
					persistMobileButtonPosition(btn)
					suppressClickUntil = os.clock() + 0.25
				end
			end
		end)
	end)

	btn.Activated:Connect(function()
		if os.clock() < suppressClickUntil then
			return
		end
		requestPanelToggle()
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or not btn.Parent then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local delta = input.Position - startPos
		if math.abs(delta.X) > 10 or math.abs(delta.Y) > 10 then
			moved = true
		end
		if not moved then
			return
		end
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
		local size = btn.AbsoluteSize
		local x = math.clamp(startOffset.X + delta.X, 4, math.max(4, vp.X - size.X - 4))
		local y = math.clamp(startOffset.Y + delta.Y, 4, math.max(4, vp.Y - size.Y - 4))
		btn.Position = UDim2.fromOffset(math.floor(x + 0.5), math.floor(y + 0.5))
	end)
end

function buildMobileOpenButton()
	if state.mobileOpenBtn and state.mobileOpenBtn.Parent then
		applySavedMobileButtonPosition()
		updateMobileButtonVisibility()
		return state.mobileOpenBtn
	end
	if not gui then
		return nil
	end
	local th = theme()
	local savedPosition = state.mobileButtonPos or mobileButtonPositionForSize(Vector2.new(54, 54))
	if savedPosition then state.mobileButtonPos = savedPosition end
	local btn = make("TextButton", {
		Name = "MobileOpenButton",
		AnchorPoint = Vector2.new(0, 0),
		Position = savedPosition or UDim2.new(1, -74, 0.5, -27),
		Size = UDim2.fromOffset(54, 54),
		BackgroundColor3 = th.panel,
		BackgroundTransparency = 0.5,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 4000,
		Parent = gui,
	})
	btn:SetAttribute("ZonePressIgnore", true)
	local round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(1, 0)
	round.Parent = btn
	stroke(btn, 0.75)
	addShadow(btn, 16, 0.6, 4, 0)

	make("ImageLabel", {
		Name = "Icon",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(28, 28),
		BackgroundTransparency = 1,
		Image = MOBILE_BUTTON_ICON,
		ImageColor3 = th.text,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 4001,
		Parent = btn,
	})

	state.mobileOpenBtn = btn
	attachMobileButtonDrag(btn)
	updateMobileButtonVisibility()
	local camera = workspace.CurrentCamera
	if camera and not state.mobileButtonViewportConn then
		state.mobileButtonViewportConn = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			applySavedMobileButtonPosition(true)
		end)
	end
	return btn
end

function togglePanel()
	if state.accessGranted ~= true or state.setupWizard then
		return
	end
	if state.panelOpen then
		closePanel()
	else
		openPanel()
	end
end

function requestPanelToggle()
	if state.accessGranted ~= true or state.setupWizard then
		return
	end
	togglePanel()
end

function initHomePanel()
	HOME_HERO_IMAGE = "rbxassetid://102442843725215"

	function homeRelativeTime(ts)
		ts = tonumber(ts) or 0
		if ts <= 0 then
			return "unknown"
		end
		local diff = os.time() - ts
		if diff < 0 then
			diff = 0
		end
		if diff < 60 then
			return "just now"
		end
		if diff < 3600 then
			return ("%dm ago"):format(math.floor(diff / 60))
		end
		if diff < 86400 then
			return ("%dh ago"):format(math.floor(diff / 3600))
		end
		return ("%dd ago"):format(math.floor(diff / 86400))
	end

	function homeSelectPlayer(plr)
		if not plr or not plr.Parent then
			return
		end
		selectServerRowTarget({ Name = plr.Name, DisplayName = plr.DisplayName })
		setTab("actions")
	end

	function homeQuickLinks()
		return {
			{ key = "actions", label = "Actions", note = "Run commands", icon = "rbxassetid://140013014943385" },
			{ key = "server", label = "Server", note = "Live stats", icon = "rbxassetid://9692125126" },
			{ key = "ban", label = "Bans", note = "Ban list", icon = "rbxassetid://83002980114464" },
			{ key = "settings", label = "Settings", note = "Preferences", icon = "rbxassetid://7059346373" },
		}
	end

	function refreshHomePanel()
		local th = theme()
		if type(zoneHomeApplyRoleLayout) == "function" then
			zoneHomeApplyRoleLayout()
		end
		if state.homeGreeting then
			state.homeGreeting.Text = ("Welcome back, %s"):format(streamerShortText(localPlayer.DisplayName))
		end
		if state.homeRank then
			local rank = getLocalAdminRank()
			state.homeRank.Text = rank ~= "" and ("Signed in as %s"):format(rank) or "Signed in"
		end

		if state.homePlayersValue then
			state.homePlayersValue.Text = tostring(#Players:GetPlayers())
		end
		if state.homeUptimeValue then
			state.homeUptimeValue.Text = formatDuration(workspace.DistributedGameTime or 0)
		end

		refreshHomePlayers()
		refreshHomeActivity()

		for _, entry in ipairs(state.homeQuickButtons or {}) do
			if entry.button and entry.button.Parent then
				entry.button.BackgroundColor3 = th.card
				if entry.label then entry.label.TextColor3 = th.text end
				if entry.note then entry.note.TextColor3 = th.muted end
				if entry.iconBox then entry.iconBox.BackgroundColor3 = th.panel2 end
				if entry.icon then entry.icon.ImageColor3 = th.icon end
			end
		end
		for _, card in ipairs(state.homeStatCards or {}) do
			if card and card.Parent then
				card.BackgroundColor3 = th.card
			end
		end
		if state.homeGreeting then state.homeGreeting.TextColor3 = Color3.fromRGB(255, 255, 255) end
		if state.homeRank then state.homeRank.TextColor3 = Color3.fromRGB(226, 226, 232) end
	end

	function refreshHomePlayers()
		local holder = state.homePlayersHolder
		if not holder or not holder.Parent then
			return
		end
		local th = theme()
		local streamer = isStreamerModeEnabled()

		if state.homePlayersHidden then
			state.homePlayersHidden.Visible = false
		end
		if state.homePlayersStrip then
			state.homePlayersStrip.Visible = true
		end

		local strip = state.homePlayersStrip
		local seen = {}
		state.homePlayerCards = state.homePlayerCards or {}

		for _, plr in ipairs(Players:GetPlayers()) do
			seen[plr.UserId] = true
			local card = state.homePlayerCards[plr.UserId]
			if not card or not card.frame.Parent then
				local btn = make("TextButton", {
					Name = "P_" .. tostring(plr.UserId),
					Size = UDim2.fromOffset(72, 92),
					BackgroundColor3 = th.card,
					BackgroundTransparency = 0.1,
					Text = "",
					AutoButtonColor = false,
					BorderSizePixel = 0,
					Parent = strip,
				})
				corner(btn, 12)
				stroke(btn, 0.9)

				local head = make("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 8),
					Size = UDim2.fromOffset(48, 48),
					BackgroundColor3 = th.panel2,
					BackgroundTransparency = 0.2,
					BorderSizePixel = 0,
					Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(plr.UserId),
					ScaleType = Enum.ScaleType.Fit,
					Parent = btn,
				})
				corner(head, 24)

				local nameLbl = make("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 60),
					Size = UDim2.new(1, -8, 0, 15),
					BackgroundTransparency = 1,
					Text = plr.DisplayName,
					Font = Enum.Font.GothamSemibold,
					TextSize = 11,
					TextColor3 = th.text,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Parent = btn,
				})

				local rankLbl = make("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 74),
					Size = UDim2.new(1, -8, 0, 13),
					BackgroundTransparency = 1,
					Text = "",
					Font = Enum.Font.Gotham,
					TextSize = 10,
					TextColor3 = th.muted,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Parent = btn,
				})

				local scale = make("UIScale", { Scale = 1, Parent = btn })
				btn.MouseEnter:Connect(function()
					tween(scale, TweenInfo.new(0.12), { Scale = 1.06 })
				end)
				btn.MouseLeave:Connect(function()
					tween(scale, TweenInfo.new(0.12), { Scale = 1 })
				end)
				btn.MouseButton1Click:Connect(function()
					homeSelectPlayer(plr)
				end)

				presenceAttachDot(head, plr.UserId, 16)
				card = { frame = btn, head = head, name = nameLbl, rank = rankLbl }
				state.homePlayerCards[plr.UserId] = card
			end

			card.frame.BackgroundColor3 = th.card
			card.name.Text = streamerShortText(plr.DisplayName) .. zoneShieldTag(plr.UserId)
			card.name.TextColor3 = th.text
			local rank = tostring(plr:GetAttribute("AdminPanelRank") or "")
			card.rank.Text = visibleRankText(rank)
			card.rank.TextColor3 = (rank ~= "" and not isStreamerModeEnabled()) and th.accent or th.muted
		end

		for userId, card in pairs(state.homePlayerCards) do
			if not seen[userId] then
				if card.frame and card.frame.Parent then
					card.frame:Destroy()
				end
				state.homePlayerCards[userId] = nil
			end
		end

		if state.homePlayersTitle then
			state.homePlayersTitle.Text = ("Players online (%d)"):format(#Players:GetPlayers())
			state.homePlayersTitle.TextColor3 = th.text
		end
	end

	function refreshHomeActivity()
		local holder = state.homeActivityHolder
		if not holder or not holder.Parent then
			return
		end
		local th = theme()

		if state.homeActivityTitle then
			state.homeActivityTitle.TextColor3 = th.text
		end

		local entries = state.moderationLogData
		if type(entries) ~= "table" or #entries == 0 then
			if state.homeActivityLoaded ~= true then
				state.homeActivityLoaded = true
				task.spawn(function()
					local ok, res = pcall(function()
						return state.HistoryRF:InvokeServer("get")
					end)
					if ok and type(res) == "table" and res.ok and type(res.entries) == "table" then
						state.moderationLogData = res.entries
						refreshHomeActivity()
					end
				end)
			end
		end

		entries = type(state.moderationLogData) == "table" and state.moderationLogData or {}

		local sorted = {}
		for _, entry in ipairs(entries) do
			table.insert(sorted, entry)
		end
		table.sort(sorted, function(a, b)
			return (tonumber(a.timestamp or a.time) or 0) > (tonumber(b.timestamp or b.time) or 0)
		end)

		state.homeActivityRows = state.homeActivityRows or {}
		local shown = 0

		for index = 1, 5 do
			local entry = sorted[index]
			local row = state.homeActivityRows[index]

			if entry then
				if not row or not row.frame.Parent then
					local frame = make("Frame", {
						Name = "Activity_" .. index,
						LayoutOrder = index,
						Size = UDim2.new(1, 0, 0, 42),
						BackgroundColor3 = th.card,
						BackgroundTransparency = 0.12,
						BorderSizePixel = 0,
						Parent = holder,
					})
					corner(frame, 10)

					local dot = make("Frame", {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 12, 0.5, 0),
						Size = UDim2.fromOffset(6, 6),
						BackgroundColor3 = th.accent,
						BorderSizePixel = 0,
						Parent = frame,
					})
					corner(dot, 3)

					local title = make("TextLabel", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(28, 5),
						Size = UDim2.new(1, -110, 0, 17),
						Text = "",
						Font = Enum.Font.GothamSemibold,
						TextSize = 12,
						TextColor3 = th.text,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Parent = frame,
					})

					local sub = make("TextLabel", {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(28, 21),
						Size = UDim2.new(1, -110, 0, 15),
						Text = "",
						Font = Enum.Font.Gotham,
						TextSize = 11,
						TextColor3 = th.muted,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Parent = frame,
					})

					local when = make("TextLabel", {
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, -12, 0.5, 0),
						Size = UDim2.fromOffset(76, 16),
						BackgroundTransparency = 1,
						Text = "",
						Font = Enum.Font.Gotham,
						TextSize = 11,
						TextColor3 = th.muted,
						TextXAlignment = Enum.TextXAlignment.Right,
						Parent = frame,
					})

					row = { frame = frame, dot = dot, title = title, sub = sub, when = when }
					state.homeActivityRows[index] = row
				end

				local action = tostring(entry.action or "Action")
				local mod = streamerShortText(entry.moderatorDisplayName or entry.moderatorName or entry.moderator or "Unknown")
				local target = streamerShortText(entry.targetDisplayName or entry.targetName or entry.target or "Unknown")
				local reason = tostring(entry.reason or "")

				row.frame.BackgroundColor3 = th.card
				row.dot.BackgroundColor3 = th.accent
				row.title.Text = ("%s  %s"):format(action, target)
				row.title.TextColor3 = th.text
				row.sub.Text = reason ~= "" and reason ~= "N/A" and ("by %s - %s"):format(mod, reason) or ("by %s"):format(mod)
				row.sub.TextColor3 = th.muted
				row.when.Text = homeRelativeTime(entry.timestamp or entry.time)
				row.when.TextColor3 = th.muted
				row.frame.Visible = true
				shown = shown + 1
			elseif row and row.frame then
				row.frame.Visible = false
			end
		end

		if state.homeActivityEmpty then
			state.homeActivityEmpty.Visible = shown == 0
			state.homeActivityEmpty.TextColor3 = th.muted
		end
	end

	function buildHomePanel()
		if not right then
			return
		end
		local th = theme()

		state.homeScroll = make("ScrollingFrame", {
			Name = "HomeScroll",
			Visible = false,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = th.text,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Parent = right,
		})

		local hero = make("Frame", {
			Name = "HomeHero",
			Size = UDim2.new(1, 0, 0, 150),
			BackgroundColor3 = th.panel,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = state.homeScroll,
		})
		corner(hero, 16)
		stroke(hero, 0.9)

		local heroArt = make("ImageLabel", {
			Name = "Artwork",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = HOME_HERO_IMAGE,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ScaleType = Enum.ScaleType.Crop,
			Parent = hero,
		})
		corner(heroArt, 16)
		make("Frame", {
			Name = "HeroShade",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.42,
			BorderSizePixel = 0,
			Parent = hero,
		})
		corner(hero:FindFirstChild("HeroShade"), 16)

		state.homeGreeting = make("TextLabel", {
			Name = "Greeting",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 18, 1, -34),
			Size = UDim2.new(1, -36, 0, 30),
			BackgroundTransparency = 1,
			Text = "Welcome back",
			Font = Enum.Font.GothamBold,
			TextSize = 24,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 3,
			Parent = hero,
		})
		make("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Transparency = 0.6, Thickness = 1, Parent = state.homeGreeting })

		state.homeRank = make("TextLabel", {
			Name = "RankLine",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 18, 1, -14),
			Size = UDim2.new(1, -36, 0, 18),
			BackgroundTransparency = 1,
			Text = "Signed in",
			Font = Enum.Font.GothamSemibold,
			TextSize = 13,
			TextColor3 = Color3.fromRGB(226, 226, 232),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3,
			Parent = hero,
		})
		make("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Transparency = 0.65, Thickness = 1, Parent = state.homeRank })

		local quickHolder = make("Frame", {
			Name = "QuickLinks",
			Position = UDim2.fromOffset(0, 162),
			Size = UDim2.new(1, 0, 0, 68),
			BackgroundTransparency = 1,
			Parent = state.homeScroll,
		})
		make("UIGridLayout", {
			CellSize = UDim2.new(0.25, -6, 0, 68),
			CellPadding = UDim2.fromOffset(8, 8),
			FillDirectionMaxCells = 4,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = quickHolder,
		})

		state.homeQuickButtons = {}
		for index, item in ipairs(homeQuickLinks()) do
			local btn = make("TextButton", {
				Name = "Quick_" .. item.key,
				LayoutOrder = index,
				BackgroundColor3 = th.card,
				BackgroundTransparency = 0.1,
				Text = "",
				AutoButtonColor = false,
				BorderSizePixel = 0,
				Parent = quickHolder,
			})
			corner(btn, 12)
			stroke(btn, 0.9)

			local iconBox = make("Frame", {
				Name = "IconBox",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 12, 0.5, 0),
				Size = UDim2.fromOffset(44, 44),
				BackgroundColor3 = th.panel2,
				BackgroundTransparency = 0.25,
				BorderSizePixel = 0,
				Parent = btn,
			})
			corner(iconBox, 12)

			local icon = make("ImageLabel", {
				Name = "Icon",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(28, 28),
				BackgroundTransparency = 1,
				Image = item.icon or "",
				ImageColor3 = th.icon,
				ScaleType = Enum.ScaleType.Fit,
				Parent = iconBox,
			})

			local label = make("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(66, 12),
				Size = UDim2.new(1, -78, 0, 19),
				Text = item.label,
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				TextColor3 = th.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = btn,
			})
			local note = make("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(66, 31),
				Size = UDim2.new(1, -78, 0, 15),
				Text = item.note,
				Font = Enum.Font.Gotham,
				TextSize = 11,
				TextColor3 = th.muted,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = btn,
			})

			btn.MouseButton1Click:Connect(function()
				setTab(item.key)
			end)

			local scale = make("UIScale", { Scale = 1, Parent = btn })
			btn.MouseEnter:Connect(function()
				tween(scale, TweenInfo.new(0.12), { Scale = 1.04 })
			end)
			btn.MouseLeave:Connect(function()
				tween(scale, TweenInfo.new(0.12), { Scale = 1 })
			end)

			table.insert(state.homeQuickButtons, { button = btn, label = label, note = note, icon = icon, iconBox = iconBox })
		end

		local statHolder = make("Frame", {
			Name = "HomeStats",
			Position = UDim2.fromOffset(0, 242),
			Size = UDim2.new(1, 0, 0, 74),
			BackgroundTransparency = 1,
			Parent = state.homeScroll,
		})
		make("UIGridLayout", {
			CellSize = UDim2.new(0.5, -5, 0, 74),
			CellPadding = UDim2.fromOffset(10, 10),
			FillDirectionMaxCells = 2,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = statHolder,
		})

		state.homeStatCards = {}
		local function statCard(order, title)
			local card = make("Frame", {
				LayoutOrder = order,
				BackgroundColor3 = th.card,
				BackgroundTransparency = 0.1,
				BorderSizePixel = 0,
				Parent = statHolder,
			})
			corner(card, 12)
			stroke(card, 0.9)
			make("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(14, 12),
				Size = UDim2.new(1, -28, 0, 16),
				Text = title,
				Font = Enum.Font.Gotham,
				TextSize = 11,
				TextColor3 = th.muted,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = card,
			})
			local value = make("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(14, 30),
				Size = UDim2.new(1, -28, 0, 30),
				Text = "-",
				Font = Enum.Font.GothamBold,
				TextSize = 24,
				TextColor3 = th.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = card,
			})
			table.insert(state.homeStatCards, card)
			return value
		end

		state.homePlayersValue = statCard(1, "Players online")
		state.homeUptimeValue = statCard(2, "Server uptime")

		state.homePlayersHolder = make("Frame", {
			Name = "HomePlayers",
			Position = UDim2.fromOffset(0, 328),
			Size = UDim2.new(1, 0, 0, 132),
			BackgroundTransparency = 1,
			Parent = state.homeScroll,
		})

		state.homePlayersTitle = make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Text = "Players online",
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			TextColor3 = th.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = state.homePlayersHolder,
		})

		state.homePlayersStrip = make("ScrollingFrame", {
			Name = "PlayerStrip",
			Position = UDim2.fromOffset(0, 24),
			Size = UDim2.new(1, 0, 0, 104),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = th.text,
			ScrollBarImageTransparency = 0.5,
			ScrollingDirection = Enum.ScrollingDirection.X,
			AutomaticCanvasSize = Enum.AutomaticSize.X,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Parent = state.homePlayersHolder,
		})
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.Name,
			Parent = state.homePlayersStrip,
		})

		state.homePlayersHidden = make("TextLabel", {
			Name = "PlayersHidden",
			Position = UDim2.fromOffset(0, 24),
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundColor3 = th.card,
			BackgroundTransparency = 0.12,
			BorderSizePixel = 0,
			Text = "Hidden by streamer mode.",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = th.muted,
			Visible = false,
			Parent = state.homePlayersHolder,
		})
		corner(state.homePlayersHidden, 10)

		state.homeActivityHolderWrap = make("Frame", {
			Name = "HomeActivityWrap",
			Position = UDim2.fromOffset(0, 472),
			Size = UDim2.new(1, 0, 0, 268),
			BackgroundTransparency = 1,
			Parent = state.homeScroll,
		})

		state.homeActivityTitle = make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Text = "Recent moderation",
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			TextColor3 = th.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = state.homeActivityHolderWrap,
		})

		state.homeActivityHolder = make("Frame", {
			Name = "ActivityList",
			Position = UDim2.fromOffset(0, 24),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = state.homeActivityHolderWrap,
		})
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = state.homeActivityHolder,
		})

		state.homeActivityEmpty = make("TextLabel", {
			Name = "ActivityEmpty",
			Position = UDim2.fromOffset(0, 24),
			Size = UDim2.new(1, 0, 0, 42),
			BackgroundColor3 = th.card,
			BackgroundTransparency = 0.12,
			BorderSizePixel = 0,
			Text = "No moderation actions logged yet.",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = th.muted,
			Visible = false,
			Parent = state.homeActivityHolderWrap,
		})
		corner(state.homeActivityEmpty, 10)

		task.spawn(function()
			while state.homeScroll and state.homeScroll.Parent do
				task.wait(10)
				if state.panelOpen then
					pcall(presenceRefresh)
				end
			end
		end)

		task.spawn(function()
			while state.homeScroll and state.homeScroll.Parent do
				task.wait(5)
				if not state.panelOpen then
					continue
				end
				local tab = state.selectedTab
				if tab == "home" then
					local ok, res = pcall(function()
						return state.HistoryRF:InvokeServer("get")
					end)
					if ok and type(res) == "table" and res.ok and type(res.entries) == "table" then
						state.moderationLogData = res.entries
						refreshHomeActivity()
					end
				elseif tab == "admins" then
					pcall(refreshAdmins)
				end
			end
		end)

		Players.PlayerAdded:Connect(function()
			if state.selectedTab == "home" then
				task.defer(refreshHomePlayers)
			end
		end)
		Players.PlayerRemoving:Connect(function()
			if state.selectedTab == "home" then
				task.defer(refreshHomePlayers)
			end
		end)

		task.spawn(function()
			while state.homeScroll and state.homeScroll.Parent do
				if state.panelOpen and state.selectedTab == "home" then
					refreshHomePanel()
				end
				task.wait(1)
			end
		end)
	end
end

initHomePanel()

function initCommandBar()
	COMMAND_BAR_MAX_SUGGESTIONS = 8
	COMMAND_BAR_ROW_HEIGHT = 30

	-- What each command needs after its name (shown under the bar).
	COMMAND_USAGE = {
		Kick = "<player> <reason>",
		Ban = "<player> <minutes> <reason>   (no minutes = permanent)",
		Unban = "<player>",
		Mute = "<player> <reason>",
		TempMute = "<player> <minutes> <reason>",
		Unmute = "<player>",
		VoiceMute = "<player>",
		VoiceUnmute = "<player>",
		Warn = "<player> <reason>",
		AddNote = "<player> <text>",
		Note = "<player> <text>",
		TpTo = "<player> <destination>",
		Gravity = "<player> <number>",
		SuperSpeed = "<player> <number>",
		SuperJump = "<player> <number>",
		Damage = "<player> <amount>",
		SetHealth = "<player> <health>",
		Size = "<player> <scale 0.3-4>",
		Fling = "<player> <power>",
		Launch = "<player> <power>",
		Blind = "<player> <seconds>",
		Confuse = "<player> <seconds>",
		Paint = "<player> <colour>",
		SetRank = "<player> <rank>",
		RemoveRank = "<player>",
		UltimateSecurity = "<player>",
		UnUltimateSecurity = "<player>",
		Timeout = "<player> <minutes> <reason>",
		Untimeout = "<player>",
		Announce = "<message>   (every server)",
		Timer = "<minutes>",
		Time = "<hour or hh:mm>",
		ServerRestart = "<seconds> <message>",
		Restart = "<seconds> <message>",
		ServerUpdateAll = "<seconds> <message>",
		Undo = "",
		Esp = "",
		Disco = "",
		UnDisco = "",
		BringAll = "",
		HealAll = "",
		KillAll = "",
		RespawnAll = "",
		ServerShutdown = "",
		ShutdownServer = "",
		ServerRejoin = "",
		RejoinServer = "",
		PanicLock = "",
		PanicUnlock = "",
	}

	function commandBarVisible()
		return state.commandBar ~= nil and state.commandBar.root ~= nil and state.commandBar.root.Visible == true
	end

	function commandBarSetStatus(text, isError)
		local bar = state.commandBar
		if not bar or not bar.status then
			return
		end
		local th = theme()
		bar.status.Text = tostring(text or "")
		bar.status.TextColor3 = isError and th.danger or th.muted
	end

	function commandBarPaint()
		local bar = state.commandBar
		if not bar or not bar.root or not bar.root.Parent then
			return
		end
		local th = theme()
		bar.card.BackgroundColor3 = th.panel
		bar.prefix.TextColor3 = th.accent
		bar.box.TextColor3 = th.text
		bar.box.PlaceholderColor3 = th.muted
		bar.status.TextColor3 = th.muted
		bar.usage.TextColor3 = th.muted
		bar.suggestHolder.ScrollBarImageColor3 = th.text
		commandBarHighlight()
		if bar.cardStroke then
			bar.cardStroke.Color = th.accent
		end
	end

	function commandBarWords(text)
		local parts = {}
		for word in string.gmatch(tostring(text or ""), "%S+") do
			table.insert(parts, word)
		end
		return parts
	end

	-- Can my rank run this action? (same rules the server uses)
	function commandBarCanRun(action)
		local requiredRank = ACTION_RULES[action]
		if not requiredRank then
			return true
		end
		local myRank = getLocalAdminRank()
		local def = zoneRoleDef(myRank)
		if def then
			return def.actions and def.actions[action] == true
		end
		local myValue = rankValue(myRank)
		return myValue > 0 and myValue >= rankValue(requiredRank)
	end

	-- Every command word the local admin may use: server aliases + real names.
	function commandBarCatalog()
		local list = {}
		local seen = {}
		local function add(word, action)
			word = string.lower(tostring(word or ""))
			if word == "" or seen[word] or not commandBarCanRun(action) then
				return
			end
			seen[word] = true
			table.insert(list, { word = word, action = action })
		end
		for alias, action in pairs(state.commandAliases or {}) do
			add(alias, tostring(action))
		end
		for action in pairs(ACTION_RULES) do
			add(action, action)
		end
		return list
	end

	function commandBarActionFor(word)
		word = string.lower(tostring(word or ""))
		if word == "" then
			return nil
		end
		local aliases = state.commandAliases or {}
		if aliases[word] then
			return tostring(aliases[word])
		end
		for action in pairs(ACTION_RULES) do
			if string.lower(action) == word then
				return action
			end
		end
		return nil
	end

	function commandBarUsageText(word, action)
		if not action then
			return ""
		end
		local usage = COMMAND_USAGE[action]
		if usage == nil then
			usage = CLIENT_SELF_DEFAULT_ACTIONS[action] and "<player>   (empty = you)" or "<player>"
		end
		if usage == "" then
			return ("%s   (no arguments)"):format(word)
		end
		return ("%s %s"):format(word, usage)
	end

	function commandBarClearSuggestions()
		local bar = state.commandBar
		if not bar or not bar.suggestHolder then
			return
		end
		for _, child in ipairs(bar.suggestHolder:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
		bar.suggestHolder.Visible = false
		bar.suggestItems = {}
		bar.suggestIndex = 0
	end

	function commandBarHighlight()
		local bar = state.commandBar
		if not bar then
			return
		end
		local th = theme()
		for index, item in ipairs(bar.suggestItems or {}) do
			if item.row and item.row.Parent then
				local active = index == bar.suggestIndex
				item.row.BackgroundColor3 = active and th.accent or th.card
				item.row.BackgroundTransparency = active and 0.55 or 0.1
			end
		end
		local picked = bar.suggestItems and bar.suggestItems[bar.suggestIndex]
		bar.topSuggestion = picked and picked.text or nil
		if picked and picked.row and bar.suggestHolder then
			local top = (bar.suggestIndex - 1) * (COMMAND_BAR_ROW_HEIGHT + 4)
			local view = bar.suggestHolder.AbsoluteWindowSize.Y
			local scrollY = bar.suggestHolder.CanvasPosition.Y
			if top < scrollY then
				bar.suggestHolder.CanvasPosition = Vector2.new(0, top)
			elseif top + COMMAND_BAR_ROW_HEIGHT > scrollY + view then
				bar.suggestHolder.CanvasPosition = Vector2.new(0, top + COMMAND_BAR_ROW_HEIGHT - view)
			end
		end
	end

	function commandBarMoveSelection(delta)
		local bar = state.commandBar
		local count = bar and #(bar.suggestItems or {}) or 0
		if count == 0 then
			return
		end
		local index = (tonumber(bar.suggestIndex) or 0) + delta
		if index < 1 then
			index = count
		elseif index > count then
			index = 1
		end
		bar.suggestIndex = index
		commandBarHighlight()
	end

	function commandBarAcceptSuggestion(text)
		local bar = state.commandBar
		if not bar or not bar.box or not text or text == "" then
			return
		end
		bar.box.Text = text .. " "
		bar.box.CursorPosition = #bar.box.Text + 1
		commandBarRefreshSuggestions()
	end

	function commandBarAddSuggestion(label, detail, fullText, order, imageUserId)
		local bar = state.commandBar
		local th = theme()
		local row = make("TextButton", {
			LayoutOrder = order,
			Size = UDim2.new(1, -6, 0, COMMAND_BAR_ROW_HEIGHT),
			BackgroundColor3 = th.card,
			BackgroundTransparency = 0.1,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			ZIndex = 5502,
			Parent = bar.suggestHolder,
		})
		corner(row, 8)

		local textLeft = 12
		if imageUserId then
			local head = make("ImageLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(6, 3),
				Size = UDim2.fromOffset(24, 24),
				Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=48&h=48"):format(tonumber(imageUserId) or 0),
				ZIndex = 5503,
				Parent = row,
			})
			corner(head, 12)
			textLeft = 36
		end

		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(textLeft, 0),
			Size = UDim2.new(0.5, -textLeft, 1, 0),
			Text = label,
			Font = Enum.Font.GothamSemibold,
			TextSize = 13,
			TextColor3 = th.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 5503,
			Parent = row,
		})

		make("TextLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 0),
			Size = UDim2.new(0.5, -12, 1, 0),
			Text = detail,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 5503,
			Parent = row,
		})

		-- Clicking a suggestion fills it in; the bar stays open (FocusLost no
		-- longer closes it), and focus goes back to the box.
		row.MouseButton1Click:Connect(function()
			commandBarAcceptSuggestion(fullText)
			task.defer(function()
				if commandBarVisible() and bar.box then
					bar.box:CaptureFocus()
				end
			end)
		end)

		table.insert(bar.suggestItems, { row = row, text = fullText })
		return row
	end

	function commandBarFinishSuggestions(shown)
		local bar = state.commandBar
		local visibleRows = math.min(shown, COMMAND_BAR_MAX_SUGGESTIONS)
		bar.suggestHolder.Size = UDim2.new(1, 0, 0, visibleRows * (COMMAND_BAR_ROW_HEIGHT + 4))
		bar.suggestHolder.Visible = shown > 0
		bar.suggestIndex = shown > 0 and 1 or 0
		bar.suggestHolder.CanvasPosition = Vector2.new(0, 0)
		commandBarHighlight()
	end

	function commandBarRefreshSuggestions()
		local bar = state.commandBar
		if not bar or not bar.box or not bar.suggestHolder then
			return
		end
		commandBarClearSuggestions()
		bar.topSuggestion = nil
		bar.usage.Text = ""

		local text = bar.box.Text or ""
		local parts = commandBarWords(text)
		if parts[1] then
			parts[1] = string.gsub(parts[1], "^[;:]+", "")
		end
		local trailingSpace = string.match(text, "%s$") ~= nil

		-- 1) Typing the command name: prefix matches first, then "contains".
		if #parts == 0 or (#parts == 1 and not trailingSpace) then
			local typed = string.lower(parts[1] or "")
			local starts, contains = {}, {}
			for _, entry in ipairs(commandBarCatalog()) do
				if typed == "" or string.sub(entry.word, 1, #typed) == typed then
					table.insert(starts, entry)
				elseif string.find(entry.word, typed, 1, true) then
					table.insert(contains, entry)
				end
			end
			local function byWord(a, b)
				if #a.word == #b.word then
					return a.word < b.word
				end
				return #a.word < #b.word
			end
			table.sort(starts, byWord)
			table.sort(contains, byWord)
			local shown = 0
			for _, group in ipairs({ starts, contains }) do
				for _, entry in ipairs(group) do
					shown += 1
					local rank = tostring(ACTION_RULES[entry.action] or "")
					local usage = COMMAND_USAGE[entry.action]
					if usage == nil then
						usage = "<player>"
					end
					local detail = rank ~= "" and (rank .. (usage ~= "" and ("  ·  " .. usage) or "")) or usage
					commandBarAddSuggestion(entry.word, detail, entry.word, shown)
				end
			end
			local exactAction = commandBarActionFor(typed)
			if exactAction then
				bar.usage.Text = commandBarUsageText(typed, exactAction)
			end
			commandBarFinishSuggestions(shown)
			return
		end

		local firstWord = string.lower(parts[1] or "")
		local action = commandBarActionFor(firstWord)
		bar.usage.Text = commandBarUsageText(firstWord, action)
		local usage = action and COMMAND_USAGE[action]
		local wantsPlayer = action ~= nil and (usage == nil or string.find(usage, "<player>", 1, true) ~= nil)

		-- 2) Typing the player: me / all / others / global, then Name or DisplayName.
		if wantsPlayer and (#parts == 1 or (#parts == 2 and not trailingSpace)) then
			local typed = string.lower(parts[2] or "")
			local shown = 0
			for _, word in ipairs({ "me", "all", "others", "global" }) do
				if typed == "" or string.sub(word, 1, #typed) == typed then
					shown += 1
					local detail = word == "me" and "yourself" or (word == "all" and "everyone" or (word == "others" and "everyone else" or "every server"))
					commandBarAddSuggestion(word, detail, parts[1] .. " " .. word, shown)
				end
			end
			local starts, contains = {}, {}
			for _, plr in ipairs(Players:GetPlayers()) do
				local lname = string.lower(plr.Name)
				local ldisplay = string.lower(plr.DisplayName)
				if typed == "" or string.sub(lname, 1, #typed) == typed or string.sub(ldisplay, 1, #typed) == typed then
					table.insert(starts, plr)
				elseif string.find(lname, typed, 1, true) or string.find(ldisplay, typed, 1, true) then
					table.insert(contains, plr)
				end
			end
			for _, group in ipairs({ starts, contains }) do
				table.sort(group, function(a, b)
					return string.lower(a.Name) < string.lower(b.Name)
				end)
				for _, plr in ipairs(group) do
					shown += 1
					local detail = plr.DisplayName ~= plr.Name and ("@" .. plr.Name) or ""
					if plr:GetAttribute("ZoneUltimateSecurity") == true then
						detail = "🛡 " .. detail
					end
					commandBarAddSuggestion(plr.DisplayName, detail, parts[1] .. " " .. plr.Name, shown, plr.UserId)
				end
			end
			-- Put a real player first when something was typed.
			if typed ~= "" and #starts + #contains > 0 then
				commandBarFinishSuggestions(shown)
				local firstPlayerIndex = shown - (#starts + #contains) + 1
				bar.suggestIndex = firstPlayerIndex
				commandBarHighlight()
				return
			end
			commandBarFinishSuggestions(shown)
			return
		end

		commandBarFinishSuggestions(0)
	end

	function closeCommandBar()
		local bar = state.commandBar
		if not bar or not bar.root then
			return
		end
		bar.root.Visible = false
		commandBarClearSuggestions()
		if bar.usage then
			bar.usage.Text = ""
		end
		if bar.box then
			bar.box.Text = ""
			bar.box:ReleaseFocus()
		end
	end

	function submitCommandBar()
		local bar = state.commandBar
		if not bar or not bar.box then
			return
		end
		local text = trim(bar.box.Text or "")
		if text == "" then
			closeCommandBar()
			return
		end
		bar.box.Text = ""
		RemoteEvent:FireServer("RunCommand", text, nil)
		closeCommandBar()
	end

	function commandBarPointInside(position)
		local bar = state.commandBar
		if not bar or not bar.root then
			return false
		end
		local inset = GuiService:GetGuiInset()
		local point = Vector2.new(position.X, position.Y) + inset
		for _, frame in ipairs({ bar.card, bar.suggestHolder.Visible and bar.suggestHolder or nil }) do
			if frame then
				local pos, size = frame.AbsolutePosition, frame.AbsoluteSize
				if point.X >= pos.X and point.X <= pos.X + size.X and point.Y >= pos.Y and point.Y <= pos.Y + size.Y then
					return true
				end
			end
		end
		return false
	end

	function buildCommandBar()
		if state.commandBar or not gui then
			return
		end
		local th = theme()
		local bar = {}
		state.commandBar = bar

		bar.root = make("Frame", {
			Name = "CommandBar",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 90),
			Size = UDim2.fromOffset(520, 46),
			BackgroundTransparency = 1,
			Visible = false,
			ZIndex = 5500,
			Parent = gui,
		})

		bar.card = make("Frame", {
			Name = "Card",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = th.panel,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			ZIndex = 5500,
			Parent = bar.root,
		})
		corner(bar.card, 12)
		bar.cardStroke = make("UIStroke", {
			Color = th.accent,
			Transparency = 0.4,
			Thickness = 1,
			Parent = bar.card,
		})

		bar.prefix = make("TextLabel", {
			Name = "Prefix",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.fromOffset(16, 46),
			Text = ":",
			Font = Enum.Font.GothamBold,
			TextSize = 20,
			TextColor3 = th.accent,
			ZIndex = 5501,
			Parent = bar.card,
		})

		bar.box = make("TextBox", {
			Name = "Input",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(32, 0),
			Size = UDim2.new(1, -44, 1, 0),
			Text = "",
			PlaceholderText = "kick playername reason",
			ClearTextOnFocus = false,
			Font = Enum.Font.Gotham,
			TextSize = 15,
			TextColor3 = th.text,
			PlaceholderColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 5501,
			Parent = bar.card,
		})

		bar.usage = make("TextLabel", {
			Name = "Usage",
			Position = UDim2.new(0, 14, 1, 4),
			Size = UDim2.new(1, -28, 0, 16),
			BackgroundTransparency = 1,
			Text = "",
			Font = Enum.Font.Code,
			TextSize = 12,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 5501,
			Parent = bar.root,
		})

		bar.suggestHolder = make("ScrollingFrame", {
			Name = "Suggestions",
			Position = UDim2.new(0, 0, 1, 24),
			Size = UDim2.new(1, 0, 0, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = th.text,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 5502,
			Parent = bar.root,
		})
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = bar.suggestHolder,
		})
		bar.suggestItems = {}
		bar.suggestIndex = 0

		bar.status = make("TextLabel", {
			Name = "Status",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 0, -6),
			Size = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1,
			Text = "",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = th.muted,
			ZIndex = 5501,
			Parent = bar.root,
		})

		bar.box:GetPropertyChangedSignal("Text"):Connect(function()
			local raw = bar.box.Text or ""
			if string.find(raw, "\t", 1, true) then
				-- Tab inserts the highlighted suggestion.
				local cleaned = raw:gsub("\t", "")
				local pick = bar.topSuggestion
				if pick and pick ~= "" then
					bar.box.Text = pick .. " "
				else
					bar.box.Text = cleaned
				end
				bar.box.CursorPosition = #bar.box.Text + 1
				task.defer(function()
					if commandBarVisible() then
						commandBarRefreshSuggestions()
					end
				end)
				return
			end
			if commandBarVisible() then
				commandBarRefreshSuggestions()
			end
		end)

		UserInputService.InputBegan:Connect(function(input)
			if not commandBarVisible() then
				return
			end
			local key = input.KeyCode
			if key == Enum.KeyCode.Escape then
				closeCommandBar()
				return
			end
			if key == Enum.KeyCode.Up or key == Enum.KeyCode.Down then
				commandBarMoveSelection(key == Enum.KeyCode.Up and -1 or 1)
				return
			end
			if key == Enum.KeyCode.Tab then
				if bar.box:IsFocused() then
					return -- handled by the Text change above
				end
				local pick = bar.topSuggestion
				if pick and pick ~= "" then
					commandBarAcceptSuggestion(pick)
					bar.box:CaptureFocus()
				end
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				-- A click outside the bar closes it; clicks on suggestions do not.
				if not commandBarPointInside(input.Position) then
					closeCommandBar()
				end
			end
		end)

		bar.box.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				submitCommandBar()
			end
		end)

		return bar
	end

	function toggleCommandBar()
		if state.accessGranted ~= true or state.setupWizard then
			return
		end
		if zoneLocalRoleTab("actions") == false then
			if type(notify) == "function" then
				notify("Your rank cannot use commands.", false, 3)
			end
			return
		end
		if type(zoneIsLocalTimedOut) == "function" and zoneIsLocalTimedOut() then
			if type(notify) == "function" then
				notify("You are timed out and cannot use commands right now.", false, 3)
			end
			return
		end
		if not state.commandBar then
			buildCommandBar()
		end
		local bar = state.commandBar
		if not bar or not bar.root then
			return
		end
		if bar.root.Visible then
			closeCommandBar()
			return
		end
		commandBarPaint()
		commandBarSetStatus("", false)
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
		bar.root.Size = UDim2.fromOffset(math.clamp(vp.X - 40, 260, 520), 46)
		bar.root.Visible = true
		bar.box.Text = ""
		bar.box:CaptureFocus()
		commandBarRefreshSuggestions()
	end

	function connectCommandResults()
		if state.commandResultsBound then
			return
		end
		state.commandResultsBound = true
		RemoteEvent.OnClientEvent:Connect(function(action, payload)
			if action == "ToggleEsp" then
				toggleEsp()
				return
			end
			if action == "ZonePingResult" and type(payload) == "table" then
				if tonumber(payload.userId) == tonumber(state.targetData and state.targetData.UserId or 0) then
					state.targetPingMs = tonumber(payload.ping) or 0
					refreshInfoCards()
				end
				return
			end
			if action == "ZoneDisco" and type(payload) == "table" then
				if payload.active == true then zoneDiscoStart() else zoneDiscoStop() end
				return
			end
			if action == "ZoneBlind" and type(payload) == "table" then
				zoneBlindEffect(tonumber(payload.seconds) or 5)
				return
			end
			if action == "ZoneConfuse" and type(payload) == "table" then
				zoneConfuseEffect(tonumber(payload.seconds) or 10)
				return
			end
			if action == "ZoneRestartNotice" and type(payload) == "table" then
				if type(announceShowRestart) == "function" then
					announceShowRestart(tostring(payload.message or "Updating"), tonumber(payload.seconds) or 15)
				end
				return
			end
			if action == "OpenCommandBar" then
				if zoneLocalRoleTab("actions") == false then
					return
				end
				if not commandBarVisible() then
					toggleCommandBar()
				end
				return
			end
			if action ~= "CommandResult" or type(payload) ~= "table" then
				return
			end
			if type(notify) == "function" then
				notify(tostring(payload.message or ""), payload.ok == true, 4)
			else
				commandBarSetStatus(payload.message, payload.ok ~= true)
			end
		end)
	end
end

initCommandBar()

function initSetupWizard()
	SETUP_WELCOME_IMAGE = "rbxassetid://102442843725215"
	SETUP_NEXT_ICON = "rbxassetid://6031091004"

	function setupWizardPaint()
		local w = state.setupWizard
		if not w or not w.root or not w.root.Parent then
			return
		end
		local th = theme()
		w.backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		w.card.BackgroundColor3 = th.panel
		w.title.TextColor3 = th.text
		w.subtitle.TextColor3 = th.muted
		w.stepLabel.TextColor3 = th.muted
		w.backBtn.BackgroundColor3 = th.card
		w.backBtn.TextColor3 = th.text
		w.nextBtn.BackgroundColor3 = th.accent
		w.nextBtn.TextColor3 = th.onAccent
		if w.nextIcon then
			w.nextIcon.ImageColor3 = th.onAccent
		end
		local heroStep = w.step == 1 or w.step >= w.total
		if w.welcomeArt then
			w.welcomeArt.Visible = heroStep
		end
		if w.welcomeShade then
			w.welcomeShade.Visible = heroStep
		end
		for _, dot in ipairs(w.dots) do
			dot.BackgroundColor3 = th.accent
		end
		for _, obj in ipairs(w.tinted or {}) do
			if obj and obj.Parent then
				if obj:IsA("TextLabel") then
					obj.TextColor3 = obj:GetAttribute("SetupMuted") and th.muted or th.text
				elseif obj:IsA("Frame") then
					obj.BackgroundColor3 = th.card
				end
			end
		end
		setupWizardSyncDots()
	end

	function setupWizardSyncDots()
		local w = state.setupWizard
		if not w then
			return
		end
		for index, dot in ipairs(w.dots) do
			local active = index == w.step
			dot.Size = active and UDim2.fromOffset(20, 6) or UDim2.fromOffset(6, 6)
			dot.BackgroundTransparency = active and 0 or 0.65
		end
	end

	function setupWizardClearBody()
		local w = state.setupWizard
		if not w then
			return
		end
		w.tinted = {}
		w.welcomeTitle = nil
		w.welcomeUser = nil
		w.welcomeHint = nil
		w.finishTitle = nil
		w.finishUser = nil
		w.finishThanks = nil
		w.themeGrid = nil
		w.themeTiles = {}
		if w.title then
			w.title.Visible = true
		end
		if w.subtitle then
			w.subtitle.Visible = true
		end
		for _, child in ipairs(w.body:GetChildren()) do
			if child:IsA("GuiObject") then
				child:Destroy()
			end
		end
	end

	function setupWizardTrack(obj, muted)
		local w = state.setupWizard
		if w then
			if muted then
				obj:SetAttribute("SetupMuted", true)
			end
			table.insert(w.tinted, obj)
		end
		return obj
	end

	function setupWizardLine(text, order, muted, size)
		local w = state.setupWizard
		local label = make("TextLabel", {
			LayoutOrder = order,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, size or 18),
			Text = text,
			Font = muted and Enum.Font.Gotham or Enum.Font.GothamSemibold,
			TextSize = muted and 12 or 14,
			TextColor3 = muted and theme().muted or theme().text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Parent = w.body,
		})
		return setupWizardTrack(label, muted)
	end

	function setupWizardToggleRow(key, title, note, order)
		local w = state.setupWizard
		local th = theme()
		local row = make("TextButton", {
			LayoutOrder = order,
			Size = UDim2.new(1, 0, 0, w.rowH or 44),
			BackgroundColor3 = th.card,
			BackgroundTransparency = 0.15,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Parent = w.body,
		})
		corner(row, 10)
		stroke(row, 0.9)
		addShadow(row, 10, 0.72, 3, 0)
		setupWizardTrack(row)

		local name = make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 6),
			Size = UDim2.new(1, -90, 0, 18),
			Text = title,
			Font = Enum.Font.GothamSemibold,
			TextSize = 13,
			TextColor3 = th.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		setupWizardTrack(name)

		local hint = make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 23),
			Size = UDim2.new(1, -90, 0, 15),
			Text = note,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		setupWizardTrack(hint, true)

		local pill = make("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(52, 28),
			BackgroundColor3 = th.muted,
			BorderSizePixel = 0,
			Parent = row,
		})
		corner(pill, 14)
		local pillStroke = make("UIStroke", {
			Color = th.text,
			Transparency = 0.72,
			Thickness = 1,
			Parent = pill,
		})

		local knob = make("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 3, 0.5, 0),
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Parent = pill,
		})
		corner(knob, 11)

		local function render(animated)
			local on = w.draft[key] == true
			local pal = theme()
			local info = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local pos = on and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
			local col = on and pal.accent or switchOffColor()
			local knobCol = contrastTextFor(col)
			pillStroke.Transparency = on and 1 or 0.45
			if animated then
				tween(pill, info, { BackgroundColor3 = col })
				tween(knob, info, { Position = pos, BackgroundColor3 = knobCol, BackgroundTransparency = 0 })
			else
				pill.BackgroundColor3 = col
				knob.Position = pos
				knob.BackgroundColor3 = knobCol
				knob.BackgroundTransparency = 0
			end
		end

		row.MouseButton1Click:Connect(function()
			w.draft[key] = not (w.draft[key] == true)
			render(true)
		end)

		render(false)
		return row
	end

	function setupWizardThemeTile(name, order, parent)
		local w = state.setupWizard
		local palette = THEMES[name]
		if not palette then
			return
		end
		local btn = make("TextButton", {
			Name = "SetupTheme_" .. name,
			LayoutOrder = order,
			BackgroundColor3 = palette.panel,
			BackgroundTransparency = 0.05,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Parent = parent,
		})
		corner(btn, 8)
		local st = stroke(btn, 0.85)

		local swatch = make("Frame", {
			BackgroundColor3 = palette.accent,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(8, 8),
			Size = UDim2.new(1, -16, 0, 20),
			Parent = btn,
		})
		corner(swatch, 5)
		if name == "Custom" then
			swatch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			rainbowGradient(swatch)
		end

		local label = make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(8, 36),
			Size = UDim2.new(1, -16, 0, 22),
			Text = name,
			Font = Enum.Font.GothamSemibold,
			TextSize = 12,
			TextColor3 = palette.text,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = btn,
		})

		w.themeTiles[name] = { button = btn, stroke = st, swatch = swatch, label = label }

		btn.MouseButton1Click:Connect(function()
			if name == "Custom" then
				openSetupColorPicker()
				return
			end
			w.draft.theme = name
			setThemeName(name, false)
			setupWizardPaint()
			task.defer(setupWizardSyncThemeTiles)
		end)
	end

	function openSetupColorPicker()
		if not state.colorPickerOverlay then
			return
		end
		state.setupPickerActive = true
		state.colorPickerBaseZ = state.colorPickerBaseZ or state.colorPickerOverlay.ZIndex
		state.colorPickerOverlay.ZIndex = 6100
		openColorPicker()
	end

	function closeSetupColorPicker()
		state.setupPickerActive = false
		if state.colorPickerOverlay and state.colorPickerBaseZ then
			state.colorPickerOverlay.ZIndex = state.colorPickerBaseZ
		end
	end

	function setupWizardApplyCustom(chosen)
		local w = state.setupWizard
		if not w or typeof(chosen) ~= "Color3" then
			return
		end
		w.draft.theme = "Custom"
		w.draft.customAccent = colorToHex(chosen)
		state.pendingCustomAccent = chosen
		setupWizardSyncThemeTiles()
	end

	function setupWizardSyncThemeTiles()
		local w = state.setupWizard
		if not w or not w.themeTiles then
			return
		end
		local th = theme()
		for name, entry in pairs(w.themeTiles) do
			local palette = THEMES[name]
			if palette and entry.button and entry.button.Parent then
				entry.button.BackgroundColor3 = palette.panel
				if entry.swatch and entry.swatch.Parent then
					if name == "Custom" then
						entry.swatch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						rainbowGradient(entry.swatch)
					else
						entry.swatch.BackgroundColor3 = palette.accent
					end
				end
				if entry.label and entry.label.Parent then
					entry.label.TextColor3 = palette.text
				end
			end
			if entry.stroke and entry.stroke.Parent then
				local selected = name == w.draft.theme
				entry.stroke.Transparency = selected and 0 or 0.85
				entry.stroke.Thickness = selected and 2 or 1
				entry.stroke.Color = selected and th.accent or th.muted
			end
		end
	end

	function setupWizardStepWelcome()
		local w = state.setupWizard
		local th = theme()
		w.title.Visible = false
		w.subtitle.Visible = false

		local hero = make("Frame", {
			LayoutOrder = 1,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 6002,
			Parent = w.body,
		})

		w.welcomeTitle = make("TextLabel", {
			Name = "WelcomeTitle",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, w.compact and 26 or 44),
			Size = UDim2.new(1, -40, 0, w.compact and 44 or 62),
			BackgroundTransparency = 1,
			Text = "Welcome!",
			Font = Enum.Font.GothamBlack,
			TextSize = w.compact and 36 or 52,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 6003,
			Parent = hero,
		})
		make("UIStroke", {
			Color = Color3.fromRGB(0, 0, 0),
			Transparency = 0.55,
			Thickness = 2,
			Parent = w.welcomeTitle,
		})

		w.welcomeUser = make("TextLabel", {
			Name = "WelcomeUser",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, w.compact and 74 or 112),
			Size = UDim2.new(1, -40, 0, 26),
			BackgroundTransparency = 1,
			Text = localPlayer.DisplayName,
			Font = Enum.Font.GothamSemibold,
			TextSize = 20,
			TextColor3 = Color3.fromRGB(235, 235, 240),
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 6003,
			Parent = hero,
		})
		make("UIStroke", {
			Color = Color3.fromRGB(0, 0, 0),
			Transparency = 0.65,
			Thickness = 1,
			Parent = w.welcomeUser,
		})

		w.welcomeHint = make("TextLabel", {
			Name = "WelcomeHint",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -10),
			Size = UDim2.new(1, -60, 0, 20),
			BackgroundTransparency = 1,
			Text = "A quick setup before you start.",
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = Color3.fromRGB(215, 215, 222),
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 6003,
			Parent = hero,
		})
	end

	function setupWizardStepTheme()
		local w = state.setupWizard
		w.title.Text = "Choose a theme"
		w.subtitle.Text = "Pick a look. It changes instantly so you can compare."
		w.themeTiles = {}
		local grid = make("Frame", {
			Name = "SetupThemeGrid",
			LayoutOrder = 1,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = w.body,
		})
		local cells = w.gridCells or 4
		make("UIGridLayout", {
			CellSize = UDim2.new(1 / cells, -8, 0, w.compact and 60 or 66),
			CellPadding = UDim2.fromOffset(8, 8),
			FillDirectionMaxCells = cells,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = grid,
		})
		w.themeGrid = grid
		for index, name in ipairs(THEME_ORDER) do
			setupWizardThemeTile(name, index, grid)
		end
		setupWizardSyncThemeTiles()
	end

	function setupWizardStepInterface()
		local w = state.setupWizard
		w.title.Text = "Interface"
		w.subtitle.Text = "How the panel should behave."
		setupWizardToggleRow("animationOn", "Animations", "Smooth open, close and tab transitions.", 1)
		setupWizardToggleRow("blurBackground", "Background blur", "Blurs the game behind the panel while it is open.", 2)
		setupWizardToggleRow("openInStart", "Open on join", "Show the panel automatically when you join.", 3)
		setupWizardToggleRow("rememberLastTab", "Remember last tab", "Reopen on the tab you used last time.", 4)
		setupWizardToggleRow("saveSidebarOrder", "Save sidebar order", "Remember how you arranged the sidebar icons.", 5)
	end

	function setupWizardStepFinish()
		local w = state.setupWizard
		w.title.Visible = false
		w.subtitle.Visible = false

		local hero = make("Frame", {
			LayoutOrder = 1,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 6002,
			Parent = w.body,
		})

		w.finishTitle = make("TextLabel", {
			Name = "FinishTitle",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, w.compact and 26 or 44),
			Size = UDim2.new(1, -40, 0, w.compact and 44 or 62),
			BackgroundTransparency = 1,
			Text = "Setup completed",
			Name = "FinishTitleText",
			Font = Enum.Font.GothamBlack,
			TextSize = w.compact and 28 or 44,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 6003,
			Parent = hero,
		})
		make("UIStroke", {
			Color = Color3.fromRGB(0, 0, 0),
			Transparency = 0.55,
			Thickness = 2,
			Parent = w.finishTitle,
		})

		w.finishThanks = make("TextLabel", {
			Name = "FinishThanks",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -8),
			Size = UDim2.new(1, -40, 0, 22),
			BackgroundTransparency = 1,
			Text = "Thanks for purchasing Zone Panel :D",
			Font = Enum.Font.GothamSemibold,
			TextSize = w.compact and 13 or 15,
			TextColor3 = Color3.fromRGB(240, 240, 245),
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 6003,
			Parent = hero,
		})
		make("UIStroke", {
			Color = Color3.fromRGB(0, 0, 0),
			Transparency = 0.6,
			Thickness = 1,
			Parent = w.finishThanks,
		})

		w.finishUser = make("TextLabel", {
			Name = "FinishUser",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, w.compact and 74 or 112),
			Size = UDim2.new(1, -40, 0, 26),
			BackgroundTransparency = 1,
			Text = localPlayer.DisplayName,
			Font = Enum.Font.GothamSemibold,
			TextSize = 20,
			TextColor3 = Color3.fromRGB(235, 235, 240),
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 6003,
			Parent = hero,
		})
		make("UIStroke", {
			Color = Color3.fromRGB(0, 0, 0),
			Transparency = 0.65,
			Thickness = 1,
			Parent = w.finishUser,
		})
	end

	function setupWizardRender()
		local w = state.setupWizard
		if not w then
			return
		end
		setupWizardClearBody()
		if w.step == 1 then
			setupWizardStepWelcome()
		elseif w.step == 2 then
			setupWizardStepTheme()
		elseif w.step == 3 then
			setupWizardStepInterface()
		else
			setupWizardStepFinish()
		end
		w.stepLabel.Text = ("Step %d of %d"):format(w.step, w.total)
		w.backBtn.Visible = w.step > 1
		local lastStep = w.step >= w.total
		w.nextBtn.Text = lastStep and "Finish" or ""
		if w.nextIcon then
			w.nextIcon.Visible = not lastStep
		end
		setupWizardPaint()
	end

	function setupWizardGo(delta)
		local w = state.setupWizard
		if not w or w.busy then
			return
		end
		local target = math.clamp(w.step + delta, 1, w.total)
		if target == w.step then
			return
		end
		w.step = target
		setupWizardRender()
		if animationsEnabled() then
			local restY = w.bodyY or 58
			w.body.Position = UDim2.fromOffset(delta > 0 and 26 or -26, restY)
			tween(w.body, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(0, restY),
			})
		end
	end

	function setupWizardFinish()
		local w = state.setupWizard
		if not w or w.busy then
			return
		end
		w.busy = true
		w.nextBtn.Text = "Saving..."
		if w.nextIcon then
			w.nextIcon.Visible = false
		end
		local payload = {
			animationOn = w.draft.animationOn == true,
			blurBackground = w.draft.blurBackground == true,
			openInStart = w.draft.openInStart == true,
			rememberLastTab = w.draft.rememberLastTab == true,
			saveSidebarOrder = w.draft.saveSidebarOrder == true,
			confirmActions = w.draft.confirmActions ~= false,
			aiConfirmActions = w.draft.aiConfirmActions ~= false,
			backgroundImage = w.draft.backgroundImage == true,
			chatPopups = w.draft.chatPopups ~= false,
			animatedBackground = w.draft.animatedBackground == true,
			mobileButton = w.draft.mobileButton ~= false,
			glowEffect = w.draft.glowEffect ~= false,
			glowStrength = 40,
			theme = normalizeThemeName(w.draft.theme),
			customAccent = colorToHex(hexToColor(w.draft.customAccent) or getCustomAccent()),
			globalCommands = w.draft.globalCommands == true,
			autoTranslateChat = w.draft.autoTranslateChat == true,
			language = normalizeLanguageCode(w.draft.language),
			backgroundStyle = normalizeBgStyleCode(w.draft.backgroundStyle),
			lastTab = "home",
			setupDone = true,
		}
		local ok, res = pcall(function()
			return SettingsRF:InvokeServer("set", payload)
		end)
		if ok and type(res) == "table" and res.ok ~= false then
			state.settingsData = normalizeSettingsPayload(res)
			if type(applySavedMobileButtonPosition) == "function" then applySavedMobileButtonPosition() end
			state.settingsData.setupDone = true
			state.settingsDraft = cloneSettingsTable(state.settingsData)
			state.settingsDirty = false
			local wizardAccent = hexToColor(state.settingsData.customAccent)
			if wizardAccent then applyCustomAccent(wizardAccent) end
			if ZoneRefreshLanguage then ZoneRefreshLanguage() end
			setThemeName(normalizeThemeName(state.settingsData.theme), false)
			applyThemeColors()
			refreshAnimatedBackground()
			updateBackdropBlur()
			syncSettingsPanelFromDraft()
		else
			w.busy = false
			w.nextBtn.Text = "Finish"
			w.subtitle.Text = "Could not save. Check that API Services are enabled, then try again."
			return
		end
		setupWizardClose()
	end

	function setupWizardClose()
		local w = state.setupWizard
		state.setupWizard = nil
		if w and w.viewportConn then
			w.viewportConn:Disconnect()
			w.viewportConn = nil
		end
		if not w or not w.root or not w.root.Parent then
			openPanel()
			return
		end
		if animationsEnabled() then
			tween(w.card, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.fromOffset(w.cardWidth, w.cardHeight - 24),
			})
			tween(w.backdrop, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
			task.delay(0.22, function()
				if w.root and w.root.Parent then
					w.root:Destroy()
				end
			end)
		else
			w.root:Destroy()
		end
		task.delay(0.16, function()
			openPanel()
		end)
	end

	function setupWizardMeasure(w)
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
		local compact = vp.X < 720 or vp.Y < 520 or UserInputService.TouchEnabled
		w.compact = compact
		w.cardWidth = math.floor(math.clamp(vp.X - 32, 280, compact and 520 or 560))
		w.cardHeight = math.floor(math.clamp(vp.Y - 40, 260, compact and 430 or 430))
		w.bodyY = compact and 50 or 58
		w.padX = compact and 16 or 24
		w.padY = compact and 14 or 22
		w.gridCells = (w.cardWidth < 400) and 2 or ((w.cardWidth < 500) and 3 or 4)
		w.btnH = compact and 40 or 36
		w.rowH = compact and 50 or 44
		return w
	end

	function setupWizardApplyMetrics()
		local w = state.setupWizard
		if not w or not w.card or not w.card.Parent then
			return
		end
		setupWizardMeasure(w)
		w.card.Size = UDim2.fromOffset(w.cardWidth, w.cardHeight)
		if w.cardPadding then
			w.cardPadding.PaddingLeft = UDim.new(0, w.padX)
			w.cardPadding.PaddingRight = UDim.new(0, w.padX)
			w.cardPadding.PaddingTop = UDim.new(0, w.padY)
			w.cardPadding.PaddingBottom = UDim.new(0, math.max(14, w.padY - 4))
		end
		if w.welcomeArt then
			w.welcomeArt.Position = UDim2.fromOffset(-w.padX, -w.padY)
			w.welcomeArt.Size = UDim2.new(1, w.padX * 2, 1, w.padY * 2)
		end
		if w.welcomeShade then
			w.welcomeShade.Position = UDim2.fromOffset(-w.padX, -w.padY)
			w.welcomeShade.Size = UDim2.new(1, w.padX * 2, 1, w.padY * 2)
		end
		if w.body then
			w.body.Position = UDim2.fromOffset(0, w.bodyY)
			w.body.Size = UDim2.new(1, 0, 1, -(w.bodyY + w.btnH + 22))
		end
		if w.title then
			w.title.TextSize = w.compact and 18 or 20
		end
		if w.subtitle then
			w.subtitle.Position = UDim2.fromOffset(0, w.compact and 24 or 28)
			w.subtitle.TextSize = w.compact and 11 or 12
		end
		if w.nextBtn then
			w.nextBtn.Size = UDim2.fromOffset(w.compact and 88 or 104, w.btnH)
		end
		if w.backBtn then
			w.backBtn.Size = UDim2.fromOffset(w.compact and 74 or 84, w.btnH)
			w.backBtn.Position = UDim2.new(1, -((w.compact and 88 or 104) + 8), 1, 0)
		end
		if w.stepLabel then
			w.stepLabel.Visible = not w.compact
		end
		setupWizardRender()
	end

	function openSetupWizard()
		if state.setupWizard or not gui then
			return
		end
		local th = theme()
		local source = tostring(localPlayer:GetAttribute("AdminPanelOwnerSource") or "")
		local data = state.settingsData or {}
		local w = {
			step = 1,
			total = 4,
			busy = false,
			tinted = {},
			dots = {},
			themeTiles = {},
			cardWidth = 560,
			cardHeight = 430,
			bodyY = 58,
			compact = false,
			ownerSource = source,
			draft = {
				theme = normalizeThemeName(data.theme),
				customAccent = colorToHex(hexToColor(data.customAccent) or getCustomAccent()),
				animationOn = data.animationOn ~= false,
				blurBackground = data.blurBackground == true,
				openInStart = data.openInStart ~= false,
				rememberLastTab = data.rememberLastTab ~= false,
				saveSidebarOrder = data.saveSidebarOrder ~= false,
			},
		}
		state.setupWizard = w
		setupWizardMeasure(w)

		w.root = make("Frame", {
			Name = "SetupWizard",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 6000,
			Parent = gui,
		})

		w.backdrop = make("TextButton", {
			Name = "Backdrop",
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			ZIndex = 6000,
			Parent = w.root,
		})

		w.card = make("Frame", {
			Name = "Card",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(w.cardWidth, w.cardHeight),
			BackgroundColor3 = th.panel,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Active = true,
			ZIndex = 6001,
			Parent = w.root,
		})
		corner(w.card, 16)
		stroke(w.card, 0.8)

		w.welcomeArt = make("ImageLabel", {
			Name = "Artwork",
			Position = UDim2.fromOffset(-w.padX, -w.padY),
			Size = UDim2.new(1, w.padX * 2, 1, w.padY * 2),
			BackgroundTransparency = 1,
			Image = SETUP_WELCOME_IMAGE,
			ScaleType = Enum.ScaleType.Crop,
			ZIndex = 6001,
			Parent = w.card,
		})
		corner(w.welcomeArt, 16)

		w.welcomeShade = make("Frame", {
			Name = "WelcomeShade",
			Position = UDim2.fromOffset(-w.padX, -w.padY),
			Size = UDim2.new(1, w.padX * 2, 1, w.padY * 2),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.45,
			BorderSizePixel = 0,
			ZIndex = 6001,
			Parent = w.card,
		})
		corner(w.welcomeShade, 16)

		addShadow(w.card, 24, 0.42, 10, 2)
		w.cardPadding = padding(w.card, w.padX, w.padY, w.padX, math.max(14, w.padY - 4))

		w.title = make("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 26),
			Text = "Welcome",
			Font = Enum.Font.GothamBold,
			TextSize = 20,
			TextColor3 = th.text,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 6002,
			Parent = w.card,
		})

		w.subtitle = make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 28),
			Size = UDim2.new(1, 0, 0, 18),
			Text = "",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = th.muted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 6002,
			Parent = w.card,
		})

		w.body = make("ScrollingFrame", {
			Name = "Body",
			ScrollBarThickness = 3,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarImageTransparency = 0.4,
			Active = true,
			Position = UDim2.fromOffset(0, w.bodyY),
			Size = UDim2.new(1, 0, 1, -(w.bodyY + w.btnH + 22)),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 6002,
			Parent = w.card,
		})
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = w.body,
		})

		local dotRow = make("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, -6),
			Size = UDim2.fromOffset(120, 20),
			BackgroundTransparency = 1,
			ZIndex = 6002,
			Parent = w.card,
		})
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = dotRow,
		})
		for index = 1, w.total do
			local dot = make("Frame", {
				LayoutOrder = index,
				Size = UDim2.fromOffset(6, 6),
				BackgroundColor3 = th.accent,
				BackgroundTransparency = 0.65,
				BorderSizePixel = 0,
				ZIndex = 6002,
				Parent = dotRow,
			})
			corner(dot, 3)
			table.insert(w.dots, dot)
		end

		w.stepLabel = make("TextLabel", {
			Visible = not w.compact,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -4),
			Size = UDim2.fromOffset(120, 18),
			BackgroundTransparency = 1,
			Text = "",
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = th.muted,
			ZIndex = 6002,
			Parent = w.card,
		})

		w.nextBtn = make("TextButton", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, 0, 1, 0),
			Size = UDim2.fromOffset(w.compact and 88 or 104, w.btnH),
			BackgroundColor3 = th.accent,
			Text = "Next",
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextColor3 = th.onAccent,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			ZIndex = 6002,
			Parent = w.card,
		})
		corner(w.nextBtn, 10)

		w.nextIcon = make("ImageLabel", {
			Name = "NextIcon",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(30, 30),
			Rotation = -90,
			BackgroundTransparency = 1,
			Image = SETUP_NEXT_ICON,
			ImageColor3 = th.onAccent,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 6003,
			Parent = w.nextBtn,
		})

		w.backBtn = make("TextButton", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -((w.compact and 88 or 104) + 8), 1, 0),
			Size = UDim2.fromOffset(w.compact and 74 or 84, w.btnH),
			BackgroundColor3 = th.card,
			Text = "Back",
			Font = Enum.Font.GothamSemibold,
			TextSize = 13,
			TextColor3 = th.text,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 6002,
			Parent = w.card,
		})
		corner(w.backBtn, 10)
		stroke(w.backBtn, 0.9)

		w.nextBtn.MouseButton1Click:Connect(function()
			if state.setupWizard ~= w then
				return
			end
			if w.step >= w.total then
				setupWizardFinish()
			else
				setupWizardGo(1)
			end
		end)

		w.backBtn.MouseButton1Click:Connect(function()
			if state.setupWizard == w then
				setupWizardGo(-1)
			end
		end)

		setupWizardRender()

		local cam = workspace.CurrentCamera
		if cam then
			w.viewportConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				if state.setupWizard == w then
					setupWizardApplyMetrics()
				end
			end)
		end

		if animationsEnabled() then
			w.card.Size = UDim2.fromOffset(w.cardWidth, w.cardHeight - 30)
			tween(w.backdrop, TweenInfo.new(0.22), { BackgroundTransparency = 0.35 })
			tween(w.card, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(w.cardWidth, w.cardHeight),
			})
		else
			w.backdrop.BackgroundTransparency = 0.35
		end
	end

	function shouldRunSetupWizard()
		if getLocalAdminRank() ~= "Owner" then
			return false
		end
		return not (state.settingsData and state.settingsData.setupDone == true)
	end
end

initSetupWizard()

function initPanel()
	if state.accessGranted ~= true or state.panelInitialized == true then
		return
	end
	state.panelInitialized = true
	local startupSettings = nil
	pcall(function()
		startupSettings = SettingsRF:InvokeServer("get")
	end)
	if type(startupSettings) == "table" then
		if type(startupSettings.sidebarOrder) == "table" then
			state.sidebarOrder = startupSettings.sidebarOrder
		end
		if type(startupSettings.sidebarOrderText) == "string" then
			state.sidebarOrderText = startupSettings.sidebarOrderText
		end
		state.commandPrefix = tostring(startupSettings.commandPrefix or ":")
		if type(startupSettings.commandAliases) == "table" then
			state.commandAliases = startupSettings.commandAliases
		end
		state.settingsData = normalizeSettingsPayload(startupSettings)
		if type(applySavedMobileButtonPosition) == "function" then applySavedMobileButtonPosition() end
		local startupAccent = hexToColor(state.settingsData.customAccent)
		if startupAccent then applyCustomAccent(startupAccent) end
		state.themeName = normalizeThemeName(state.settingsData.theme)
		state.settingsDraft = cloneSettingsTable(state.settingsData)
		applyOpenKeyConfig(state.settingsData)
		if startupSettings.lastTab then
			state.lastTab = tostring(startupSettings.lastTab)
		end
	end
	if state.settingsData then
	end
	createUI()
	if zoneAutoBindLanguage then task.defer(zoneAutoBindLanguage) end
	state.appliedPalette = snapshotPalette(THEMES[DEFAULT_THEME_NAME])
	setThemeName(state.themeName or DEFAULT_THEME_NAME, false)
	maybeNotifyUpdate()
	maybeNotifyAnnounce()
	local startupTab = "home"
	if state.settingsData and state.settingsData.rememberLastTab == true then
		startupTab = state.settingsData.lastTab or state.lastTab or state.selectedTab or "home"
	end
	setTab(startupTab)
	if shouldRunSetupWizard() then
		closePanel()
		task.defer(openSetupWizard)
	elseif state.settingsData and state.settingsData.openInStart == false then
		closePanel()
	else
		openPanel()
	end
	updateBackdropBlur()
	connectPingAck()
	startPingLoop()

	task.spawn(function()
		for _, delaySeconds in ipairs({ 0.5, 2, 5, 10 }) do
			task.wait(delaySeconds)
			if not gui or not gui.Parent then
				return
			end
			if next(ZONE_ROLE_DATA) ~= nil then
				return
			end
			pcall(function()
				RemoteEvent:FireServer("RoleList", nil, nil)
			end)
		end
	end)
	task.delay(8, syncVersionInfoFromServer)

	task.spawn(function()
		while gui and gui.Parent do
			task.wait(300)
			syncVersionInfoFromServer()
		end
	end)

	task.spawn(function()
		while gui and gui.Parent do
			if state.panelOpen and state.selectedTab == "server" then
				refreshServerPanel()
			end
			task.wait(5)
		end
	end)

	task.spawn(function()
		while gui and gui.Parent do
			if state.panelOpen and state.selectedTab == "server" and state.serverUptimeStat and state.serverUptimeStat.Parent then
				local base = tonumber(state.serverUptimeBase) or 0
				local since = os.clock() - (tonumber(state.serverUptimeStamp) or os.clock())
				state.serverUptimeStat.Text = formatDuration(base + since)
			end
			task.wait(1)
		end
	end)

	if UserInputService.TouchEnabled and false then
		local mobileOpenBtn = make("TextButton", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -24),
			Size = UDim2.fromOffset(140, 44),
			BackgroundColor3 = Color3.fromRGB(28, 28, 30),
			BackgroundTransparency = 0.1,
			Text = "🛡 Zone Panel",
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextColor3 = Color3.fromRGB(245, 245, 245),
			AutoButtonColor = false,
			ZIndex = 500,
			Parent = playerGui:WaitForChild("AdminPanelUI"),
		})
		corner(mobileOpenBtn, 22)
		stroke(mobileOpenBtn, 0.5)
		mobileOpenBtn.MouseButton1Click:Connect(function()
			requestPanelToggle()
			mobileOpenBtn.Visible = not state.panelOpen
		end)
		RunService.RenderStepped:Connect(function()
			mobileOpenBtn.Visible = not state.panelOpen
		end)
	end

	resolveBtn.MouseButton1Click:Connect(function()
		state.targetQueryRaw = captureTargetQueryFromBox()
		refreshTargetData()
	end)

	targetBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			state.targetQueryRaw = captureTargetQueryFromBox()
			refreshTargetData()
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		togglePanel()
	end)

	codeConfirmBtn.MouseButton1Click:Connect(function()
		if codeModalCallback then
			local fn = codeModalCallback
			codeModalCallback = nil
			fn()
		end
	end)
	codeCancelBtn.MouseButton1Click:Connect(function()
		closeCodeModal()
	end)

	confirmYes.MouseButton1Click:Connect(function()
		local fn = state.confirmCallback
		state.confirmCallback = nil
		closeConfirmModal()
		if fn then
			fn()
		end
	end)
	confirmNo.MouseButton1Click:Connect(function()
		closeConfirmModal()
	end)

	notesModalCloseBtn.MouseButton1Click:Connect(function()
		closeNotesModal()
	end)
	notesModalAddBtn.MouseButton1Click:Connect(function()
		local text = trim(notesModalAddBox.Text)
		if text == "" or not state.targetData then
			return
		end
		local targetValue = state.resolvedTargetUserId or state.targetData.UserId or state.currentTarget
		RemoteEvent:FireServer("AddNote", targetValue, text)
		notesModalAddBox.Text = ""
		task.delay(0.4, function()
			if state.targetData then
				local ok, res = pcall(function()
					return ResolveRF:InvokeServer(targetValue)
				end)
				if ok and type(res) == "table" and res.ok then
					state.targetData = res
					state.resolvedTargetUserId = tonumber(res.UserId) or state.resolvedTargetUserId
					updateTargetHeader()
					rebuildNotesModalList()
				end
			end
		end)
	end)

	if sidebarHomeBtn then
		sidebarHomeBtn.MouseButton1Click:Connect(function()
			if state.sidebarSuppressClick then return end
			setTab("home")
		end)
	end
	if state.sidebarActionsBtn then
		state.sidebarActionsBtn.MouseButton1Click:Connect(function()
			if state.sidebarSuppressClick then return end
			setTab("actions")
		end)
	end
	if sidebarServerBtn then
		sidebarServerBtn.MouseButton1Click:Connect(function()
			if state.sidebarSuppressClick then return end
			setTab("server")
		end)
	end
	if sidebarAdminsBtn then
		sidebarAdminsBtn.MouseButton1Click:Connect(function()
			if state.sidebarSuppressClick then return end
			setTab("admins")
		end)
	end
	if sidebarBanBtn then
		sidebarBanBtn.MouseButton1Click:Connect(function()
			if state.sidebarSuppressClick then return end
			setTab("ban")
		end)
	end
	if sidebarCreditsBtn then
		sidebarCreditsBtn.MouseButton1Click:Connect(function()
			if state.sidebarSuppressClick then return end
			setTab("credits")
		end)
	end
	if state.chatTabBtn then
		state.chatTabBtn.MouseButton1Click:Connect(function()
			if state.sidebarSuppressClick then return end
			setTab("chat")
		end)
	end
	if state.sidebarModerationBtn then
		state.sidebarModerationBtn.MouseButton1Click:Connect(function()
			if state.sidebarSuppressClick then return end
			setTab("moderation")
		end)
	end
	if sidebarAnnounceBtn then
		sidebarAnnounceBtn.MouseButton1Click:Connect(function()
			if state.sidebarSuppressClick then return end
			setTab("announce")
		end)
	end
	if sidebarSettingsBtn then
		sidebarSettingsBtn.MouseButton1Click:Connect(function()
			if state.sidebarSuppressClick then return end
			setTab("settings")
		end)
	end
	if settingsWebhookToggle then
		settingsWebhookToggle.MouseButton1Click:Connect(function()
			local draft = getSettingsDraft()
			draft.animationOn = not (draft.animationOn == true)
			setSettingsDirty(true)
			syncSettingsPanelFromDraft()
		end)
	end
	if settingsOpenInStartToggle then
		settingsOpenInStartToggle.MouseButton1Click:Connect(function()
			local draft = getSettingsDraft()
			draft.openInStart = not (draft.openInStart == true)
			setSettingsDirty(true)
			syncSettingsPanelFromDraft()
		end)
	end
	if settingsRememberLastTabToggle then
		settingsRememberLastTabToggle.MouseButton1Click:Connect(function()
			local draft = getSettingsDraft()
			draft.rememberLastTab = not (draft.rememberLastTab == true)
			setSettingsDirty(true)
			syncSettingsPanelFromDraft()
		end)
	end
	if settingsStreamerModeToggle then
		settingsStreamerModeToggle.MouseButton1Click:Connect(function()
			local draft = getSettingsDraft()
			draft.streamerMode = not (draft.streamerMode == true)
			setSettingsDirty(true)
			syncSettingsPanelFromDraft()
		end)
	end
	if settingsBlurToggle then
		settingsBlurToggle.MouseButton1Click:Connect(function()
			local draft = getSettingsDraft()
			draft.blurBackground = not (draft.blurBackground == true)
			setSettingsDirty(true)
			syncSettingsPanelFromDraft()
		end)
	end
	if banSearchBox then
		banSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
			state.banSearchQuery = banSearchBox.Text or ""
			if state.selectedTab == "ban" then
				updateBanRows(filterBanEntries())
			end
		end)
	end

	if settingsSaveBtn then
		settingsSaveBtn.MouseButton1Click:Connect(saveSettingsPanel)
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.KeyCode == Enum.KeyCode.Escape and commandBarVisible() then
			closeCommandBar()
			return
		end
		if UserInputService:GetFocusedTextBox() then
			return
		end
		if input.KeyCode == Enum.KeyCode.Semicolon then
			toggleCommandBar()
			return
		end
		if isConfiguredPanelToggleKey(input) then
			requestPanelToggle()
			return
		end
		if input.KeyCode == Enum.KeyCode.F2 then
			toggleCommandBar()
			return
		end
	end)

	local PANEL_COMMAND_ALIASES = {
		panel = true,
		adminpanel = true,
		menu = true,
	}
	local function normalizePanelCommandText(msg)
		msg = tostring(msg or "")
		msg = msg:gsub("[\r\n\t]", " ")
		msg = trim(msg):lower()
		msg = msg:gsub("%s+", " ")
		return msg
	end

	local function getPanelCommandHead(msg)
		msg = normalizePanelCommandText(msg)
		if msg == "" then
			return ""
		end

		local head = msg:match("^(%S+)")
		if not head then
			return ""
		end

		head = head:gsub("^[;/]+", "")
		head = trim(head)
		return head
	end

	local function isPanelCommandText(msg)
		local head = getPanelCommandHead(msg)
		if head == "" then
			return false
		end

		return PANEL_COMMAND_ALIASES[head] == true
	end

	local function handlePanelChatCommand(msg, sourceTag)
		local normalized = normalizePanelCommandText(msg)
		if not isPanelCommandText(normalized) then
			return false
		end

		state.lastPanelCommandHandled = state.lastPanelCommandHandled or {
			text = "",
			time = 0,
			source = "",
		}

		local stamp = os.clock()
		if state.lastPanelCommandHandled.text == normalized and (stamp - state.lastPanelCommandHandled.time) < 0.35 then
			return true
		end

		state.lastPanelCommandHandled.text = normalized
		state.lastPanelCommandHandled.time = stamp
		state.lastPanelCommandHandled.source = tostring(sourceTag or "chat")

		requestPanelToggle()
		return true
	end

	local function bindChatCommand(msg, recipient)
		return handlePanelChatCommand(msg, "legacy")
	end

	local function bindTextChatCommand(message)
		if type(message) ~= "table" then
			return false
		end

		local text = tostring(message.Text or "")
		return handlePanelChatCommand(text, "text")
	end

	local function bindTextChatServiceCommands()
		local ok, TextChatService = pcall(function()
			return game:GetService("TextChatService")
		end)
		if not ok or not TextChatService then
			return
		end

		pcall(function()
			local command = TextChatService:FindFirstChild("PanelToggleCommand")
			if not command then
				command = Instance.new("TextChatCommand")
				command.Name = "PanelToggleCommand"
				command.PrimaryAlias = "/panel"
				command.SecondaryAlias = ";panel"
				command.AutocompleteVisible = false
				command.Enabled = true
				command.Parent = TextChatService
			end

			if command and command.Triggered then
				command.Triggered:Connect(function(originTextSource, unfilteredText)
					if originTextSource and originTextSource.UserId == localPlayer.UserId then
						handlePanelChatCommand(unfilteredText or "/panel", "command")
					end
				end)
			end
		end)

		if TextChatService.MessageReceived then
			TextChatService.MessageReceived:Connect(function(message)
				if message and message.TextSource and message.TextSource.UserId == localPlayer.UserId then
					bindTextChatCommand(message)
				end
			end)
		end

		if TextChatService.SendingMessage then
			TextChatService.SendingMessage:Connect(function(message)
				if message and message.TextSource and message.TextSource.UserId == localPlayer.UserId then
					bindTextChatCommand(message)
				end
			end)
		end
	end

	if localPlayer and localPlayer.Chatted then
		localPlayer.Chatted:Connect(bindChatCommand)
	end

	bindTextChatServiceCommands()

	RunService.RenderStepped:Connect(function(dt)
		state.fpsSamples += 1
		state.fpsClock += dt
		if state.fpsClock >= 1 then
			state.fps = state.fpsSamples / state.fpsClock
			state.fpsSamples = 0
			state.fpsClock = 0
			if state.targetData then
				refreshInfoCards()
			end
		end

		if state.panelOpen and state.mobile ~= isMobileLayout() then
			rebuildVisibility()
		end
		if state.panelOpen and state.selectedTab == "moderation" then
			state.moderationRefreshClock = (state.moderationRefreshClock or 0) + dt
			if state.moderationRefreshClock >= 5 then
				state.moderationRefreshClock = 0
				refreshModerationLog()
			end
		else
			state.moderationRefreshClock = 0
		end
	end)

	task.defer(function()
		rebuildVisibility()
		syncTabButtons()
		applySidebarMode(false)
	end)
end


-- Merged donor-only feature helpers (base functions win on overlap).
function wheelPointToColor(offsetX, offsetY, radius, value)
	if radius <= 0 then
		return DEFAULT_CUSTOM_ACCENT
	end
	local dist = math.sqrt(offsetX * offsetX + offsetY * offsetY)
	local sat = clamp01(dist / radius)
	local angleDeg = math.deg(math.atan2(offsetY, offsetX))
	local hueDeg = (180 - angleDeg) % 360
	return Color3.fromHSV(hueDeg / 360, sat, clamp01(value or 1))
end

function colorToWheelPoint(color, radius)
	if typeof(color) ~= "Color3" then
		return 0, 0, 1
	end
	local h, sv, v = Color3.toHSV(color)
	local angleDeg = (180 - (h * 360)) % 360
	local angle = math.rad(angleDeg)
	local dist = clamp01(sv) * radius
	return math.cos(angle) * dist, math.sin(angle) * dist, v
end

function getCustomAccent()
	if typeof(state.customAccent) == "Color3" then
		return state.customAccent
	end
	return DEFAULT_CUSTOM_ACCENT
end

function applyCustomAccent(color)
	if typeof(color) ~= "Color3" then
		return
	end
	state.customAccent = color
	state.bgElementsStyle = nil
	local palette = THEMES.Custom
	if not palette then
		return
	end

	local hue, sat = Color3.toHSV(color)
	local bgSat = math.min(clamp01(sat) * 0.55, 0.42)

	palette.accent = color
	palette.neon = color
	palette.onAccent = contrastTextFor(color)

	palette.bg = Color3.fromHSV(hue, bgSat, 0.075)
	palette.panel = Color3.fromHSV(hue, bgSat, 0.125)
	palette.panel2 = Color3.fromHSV(hue, bgSat, 0.098)
	palette.card = Color3.fromHSV(hue, bgSat * 0.9, 0.18)
	palette.text = Color3.fromHSV(hue, bgSat * 0.12, 0.97)
	palette.muted = Color3.fromHSV(hue, bgSat * 0.35, 0.70)
	palette.icon = palette.text
end

function backgroundStyleCode()
	if state and type(state.settingsData) == "table" then
		return normalizeBgStyleCode(state.settingsData.backgroundStyle)
	end
	return "stripes"
end

function ensureBackgroundElementHolder(layer)
	if not layer then
		return nil
	end
	local holder = state.bgOrbsHolder
	if holder and holder.Parent == layer then
		return holder
	end
	holder = make("Frame", {
		Name = "OrbsHolder",
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 1,
		Parent = layer,
	})
	state.bgOrbsHolder = holder
	return holder
end

function buildBackgroundElements(holder, style)
	if not holder then
		return
	end
	for _, child in ipairs(holder:GetChildren()) do
		child:Destroy()
	end
	state.bgOrbFloatTweens = {}
	local count = 7
	if style == "bubbles" then
		count = 10
	end
	if style == "sparkles" then
		count = 14
	end
	if style == "rain" then
		count = 12
	end
	for index = 1, count do
		local size = 60
		if style == "bubbles" then
			size = 14 + ((index * 29) % 26)
		end
		if style == "sparkles" then
			size = 9 + (index % 3) * 4
		end
		if style == "rain" then
			size = 26 + (index % 4) * 10
		end
		local wide = size
		if style == "rain" then
			wide = 3
		end
		local posX = ((index * 37) % 88 + 6) / 100
		local posY = ((index * 61) % 66 + 17) / 100
		if style == "sparkles" then
			posY = ((index * 41) % 78 + 11) / 100
		end
		if style == "bubbles" then
			posY = 1.12
		end
		if style == "rain" then
			posY = -0.10
		end
		local transparency = 0.35
		if style == "sparkles" then
			transparency = 0.15 + ((index * 31) % 55) / 100
		end
		local rotation = 0
		if style == "rain" then
			rotation = 10
		end
		local orb = make("Frame", {
			Name = "Elem" .. index,
			Size = UDim2.fromOffset(wide, size),
			Position = UDim2.fromScale(posX, posY),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = transparency,
			BorderSizePixel = 0,
			Rotation = rotation,
			ZIndex = 1,
			Parent = holder,
		})
		corner(orb, 999)
		local orbGrad = Instance.new("UIGradient")
		orbGrad.Color = backgroundGradientColors()
		orbGrad.Rotation = 45 + index * 17
		orbGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0.00, 0.15),
			NumberSequenceKeypoint.new(0.55, 0.55),
			NumberSequenceKeypoint.new(1.00, 1.00),
		})
		orbGrad.Parent = orb
		local info = nil
		local goal = nil
		if style == "orbs" then
			local dur = 8 + index * 2
			local driftX = ((index % 3) == 0) and -0.07 or 0.07
			local driftY = ((index % 2) == 0) and 0.09 or -0.09
			info = TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
			goal = { Position = UDim2.new(posX + driftX, 0, posY + driftY, 0) }
		end
		if style == "bubbles" then
			local dur = 7 + (index % 5) * 2
			info = TweenInfo.new(dur, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false)
			goal = { Position = UDim2.new(posX, 0, -0.15, 0) }
		end
		if style == "sparkles" then
			local dur = 1.6 + (index % 7) * 0.45
			info = TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
			goal = { BackgroundTransparency = 0.95 }
		end
		if style == "rain" then
			local dur = 1.1 + (index % 6) * 0.35
			info = TweenInfo.new(dur, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false)
			goal = { Position = UDim2.new(posX, 0, 1.12, 0) }
		end
		if info ~= nil and goal ~= nil then
			local tw = TweenService:Create(orb, info, goal)
			tw:Play()
			table.insert(state.bgOrbFloatTweens, tw)
		end
	end
end

function requestTargetPing()
	local r = state.targetData
	if type(r) ~= "table" or r.InCurrentServer ~= true then
		state.targetPingMs = nil
		return
	end
	local userId = tonumber(r.UserId) or 0
	if userId <= 0 then
		return
	end
	pcall(function()
		RemoteEvent:FireServer("ZonePingQuery", userId, nil)
	end)
end

function notesModalSize()
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local w = math.clamp(vp.X - 40, 260, 480)
	local h = math.clamp(vp.Y - 90, 240, 460)
	return UDim2.fromOffset(math.floor(w), math.floor(h))
end

function openUpdateModal(latest)
	local root = state.updateRoot
	if not root then
		return
	end
	local data = state.settingsData or {}
	local desc = tostring(data.newsDescription or "")
	desc = desc:gsub("^%s+", ""):gsub("%s+$", "")
	if desc == "" then
		desc = ZoneT("update.desc")
	end
	state.updateVersionLabel.Text = ZoneT("update.version"):format(tostring(latest or "?"))
	state.updateDescLabel.Text = desc
	root.Visible = true
	if animationsEnabled() then
		if state.updateFrame then
			state.updateFrame.Size = UDim2.fromOffset(400, 210)
			tween(state.updateFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(400, 250),
			})
		end
		if state.updateBackdrop then
			state.updateBackdrop.BackgroundTransparency = 1
			tween(state.updateBackdrop, TweenInfo.new(0.3), { BackgroundTransparency = 0.35 })
		end
	else
		if state.updateBackdrop then
			state.updateBackdrop.BackgroundTransparency = 0.35
		end
	end
end

function closeUpdateModal()
	local root = state.updateRoot
	if not root then
		return
	end
	if animationsEnabled() then
		if state.updateFrame then
			tween(state.updateFrame, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Size = UDim2.fromOffset(400, 226),
			})
		end
		if state.updateBackdrop then
			tween(state.updateBackdrop, TweenInfo.new(0.25), { BackgroundTransparency = 1 })
		end
		task.delay(0.28, function()
			if root and root.Parent then
				root.Visible = false
			end
			if state.updateFrame then
				state.updateFrame.Size = UDim2.fromOffset(400, 250)
			end
			if state.updateBackdrop then
				state.updateBackdrop.BackgroundTransparency = 1
			end
		end)
	else
		root.Visible = false
	end
end

function zoneBlindEffect(seconds)
	if not gui or not gui.Parent then
		return
	end
	local old = gui:FindFirstChild("ZoneBlindOverlay")
	if old then
		old:Destroy()
	end
	local cover = make("Frame", {
		Name = "ZoneBlindOverlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 9000,
		Parent = gui,
	})
	tween(cover, TweenInfo.new(0.4), { BackgroundTransparency = 0 })
	task.delay(math.clamp(seconds, 1, 60), function()
		if cover and cover.Parent then
			local fade = tween(cover, TweenInfo.new(0.5), { BackgroundTransparency = 1 })
			task.delay(0.55, function()
				if cover and cover.Parent then
					cover:Destroy()
				end
			end)
		end
	end)
end

function zoneConfuseEffect(seconds)
	if state.zoneConfuseActive then
		return
	end
	state.zoneConfuseActive = true
	local cam = workspace.CurrentCamera
	local conn
	conn = RunService.RenderStepped:Connect(function()
		if not state.zoneConfuseActive then
			if conn then conn:Disconnect() end
			return
		end
		local char = localPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.AutoRotate = false
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(4), 0)
			end
		end
	end)
	task.delay(math.clamp(seconds, 1, 60), function()
		state.zoneConfuseActive = false
		if conn then
			conn:Disconnect()
		end
		local char = localPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.AutoRotate = true
		end
	end)
end

ZONE_DISCO_STATE = ZONE_DISCO_STATE or { active = false }

function zoneDiscoStop()
	ZONE_DISCO_STATE.active = false
	if ZONE_DISCO_STATE.conn then
		ZONE_DISCO_STATE.conn:Disconnect()
		ZONE_DISCO_STATE.conn = nil
	end
	if ZONE_DISCO_STATE.saved then
		for part, info in pairs(ZONE_DISCO_STATE.saved) do
			if part and part.Parent then
				pcall(function()
					part.Color = info.color
					part.Material = info.material
				end)
			end
		end
		ZONE_DISCO_STATE.saved = nil
	end
end

function zoneDiscoStart()
	if ZONE_DISCO_STATE.active then
		return
	end
	ZONE_DISCO_STATE.active = true
	ZONE_DISCO_STATE.saved = {}

	local parts = {}
	local function collectFrom(root)
		for _, item in ipairs(root:GetDescendants()) do
			if item:IsA("BasePart") and item.Transparency < 1 then
				local skip = false
				local model = item:FindFirstAncestorOfClass("Model")
				if model and Players:GetPlayerFromCharacter(model) then
					skip = true
				end
				if not skip then
					table.insert(parts, item)
				end
			end
		end
	end
	collectFrom(workspace)

	if #parts == 0 then
		ZONE_DISCO_STATE.active = false
		return
	end

	for _, part in ipairs(parts) do
		ZONE_DISCO_STATE.saved[part] = { color = part.Color, material = part.Material }
	end

	local cursor = 1
	local batch = math.max(120, math.ceil(#parts / 8))
	ZONE_DISCO_STATE.conn = RunService.Heartbeat:Connect(function(dt)
		if not ZONE_DISCO_STATE.active then
			return
		end
		local hue = (tick() * 0.32) % 1
		local last = math.min(cursor + batch - 1, #parts)
		for index = cursor, last do
			local part = parts[index]
			if part and part.Parent then
				local shift = (hue + (index * 0.011)) % 1
				part.Color = Color3.fromHSV(shift, 0.9, 0.95)
				part.Material = Enum.Material.Neon
			end
		end
		cursor = last + 1
		if cursor > #parts then
			cursor = 1
		end
	end)
end

function refreshNotesModalSize()
	if notesModalFrame and notesModalFrame.Parent and state.notesModalOpen then
		notesModalFrame.Size = notesModalSize()
	end
end

function syncColorPickerWidgets(color, skipHexBox, skipRgbBoxes)
	if typeof(color) ~= "Color3" then
		return
	end
	state.pickerColor = color
	local _, _, value = Color3.toHSV(color)
	state.pickerValue = value

	if state.colorPreviewBox then
		state.colorPreviewBox.BackgroundColor3 = color
	end
	if state.colorWheelShade then
		state.colorWheelShade.BackgroundTransparency = clamp01(value)
	end
	if state.colorValueGradient then
		local h, sv = Color3.toHSV(color)
		state.colorValueGradient.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromHSV(h, sv, 1))
	end
	if state.colorValueKnob then
		state.colorValueKnob.Position = UDim2.fromScale(clamp01(value), 0.5)
	end
	local cursorHost = state.colorWheelHolder or state.colorWheelImage
	if state.colorWheelCursor and cursorHost then
		local radius = cursorHost.AbsoluteSize.X / 2
		if radius > 0 then
			local px, py = colorToWheelPoint(color, radius)
			state.colorWheelCursor.Position = UDim2.fromScale(
				clamp01(0.5 + (px / (radius * 2))),
				clamp01(0.5 + (py / (radius * 2)))
			)
		end
	end
	if state.colorHexBox and not skipHexBox then
		state.colorHexBox.Text = "#" .. colorToHex(color)
	end
	if state.colorRgbBoxes and not skipRgbBoxes then
		if state.colorRgbBoxes.R then state.colorRgbBoxes.R.Text = tostring(math.floor(color.R * 255 + 0.5)) end
		if state.colorRgbBoxes.G then state.colorRgbBoxes.G.Text = tostring(math.floor(color.G * 255 + 0.5)) end
		if state.colorRgbBoxes.B then state.colorRgbBoxes.B.Text = tostring(math.floor(color.B * 255 + 0.5)) end
	end
end

function fitColorPickerToViewport()
	if not state.colorPickerScale then
		return
	end
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)

	local usableW = math.max(160, vp.X - 32)
	local usableH = math.max(200, vp.Y - 32)

	local scale = math.min(1, usableW / COLOR_PICKER_BASE_W, usableH / COLOR_PICKER_BASE_H)
	state.colorPickerScale.Scale = math.max(0.45, scale)
end

function openColorPicker()
	if not state.colorPickerOverlay then
		return
	end
	local draft = getSettingsDraftSafe()
	local startColor = hexToColor(draft and draft.customAccent) or getCustomAccent()
	state.colorPickerOpen = true
	state.colorPickerOverlay.Visible = true
	fitColorPickerToViewport()
	syncColorPickerWidgets(startColor)
	applyColorPickerTheme()

	if not state.colorPickerResizeBound then
		state.colorPickerResizeBound = true
		local cam = workspace.CurrentCamera
		if cam then
			cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				if state.colorPickerOpen then
					fitColorPickerToViewport()
					syncColorPickerWidgets(state.pickerColor or getCustomAccent())
				end
			end)
		end
	end
end

function closeColorPicker()
	state.colorPickerOpen = false
	if state.setupPickerActive then
		closeSetupColorPicker()
	end
	state.wheelDragging = false
	state.valueDragging = false
	if state.colorPickerOverlay then
		state.colorPickerOverlay.Visible = false
	end
end

function handleWheelInput(inputPosition)
	local wheelHost = state.colorWheelHolder or state.colorWheelImage
	if not wheelHost then
		return
	end
	local size = wheelHost.AbsoluteSize
	local origin = wheelHost.AbsolutePosition
	local radius = size.X / 2
	if radius <= 0 then
		return
	end
	local centreX = origin.X + radius
	local centreY = origin.Y + (size.Y / 2)
	local dx = inputPosition.X - centreX
	local dy = inputPosition.Y - centreY
	local dist = math.sqrt(dx * dx + dy * dy)
	if dist > radius then
		dx = dx / dist * radius
		dy = dy / dist * radius
	end
	local picked = wheelPointToColor(dx, dy, radius, state.pickerValue or 1)
	syncColorPickerWidgets(picked)
end

function handleValueSliderInput(inputPosition)
	if not state.colorValueSlider then
		return
	end
	local origin = state.colorValueSlider.AbsolutePosition.X
	local width = state.colorValueSlider.AbsoluteSize.X
	if width <= 0 then
		return
	end
	local ratio = clamp01((inputPosition.X - origin) / width)
	local base = state.pickerColor or getCustomAccent()
	local h, sv = Color3.toHSV(base)
	syncColorPickerWidgets(Color3.fromHSV(h, sv, ratio))
end

function applyColorPickerTheme()
	local th = theme()
	if state.colorPickerFrame then
		state.colorPickerFrame.BackgroundColor3 = th.bg
	end
	if state.colorWheelImage then
		state.colorWheelImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
		state.colorWheelImage.ImageTransparency = 0
	end
	if state.colorPickerTitle then state.colorPickerTitle.TextColor3 = th.text end
	if state.colorPickerCloseBtn then
		state.colorPickerCloseBtn.BackgroundColor3 = th.card
		state.colorPickerCloseBtn.TextColor3 = th.text
	end
	if state.colorHexBox then
		state.colorHexBox.BackgroundColor3 = th.panel2
		state.colorHexBox.TextColor3 = th.text
		state.colorHexBox.PlaceholderColor3 = th.muted
	end
	if state.colorRgbBoxes then
		for _, box in pairs(state.colorRgbBoxes) do
			if box and box.Parent then
				box.BackgroundColor3 = th.panel2
				box.TextColor3 = th.text
			end
		end
	end
	if state.colorPickerApplyBtn then
		state.colorPickerApplyBtn.BackgroundColor3 = th.accent
		state.colorPickerApplyBtn.TextColor3 = th.onAccent
	end
	if state.colorPickerCancelBtn then
		state.colorPickerCancelBtn.BackgroundColor3 = th.panel2
		state.colorPickerCancelBtn.TextColor3 = th.text
	end
end

function bindColorPickerEvents()
	if state.colorWheelImage then
		state.colorWheelImage.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				state.wheelDragging = true
				handleWheelInput(input.Position)
			end
		end)
		state.colorWheelImage.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				state.wheelDragging = false
			end
		end)
	end
	if state.colorValueSlider then
		state.colorValueSlider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				state.valueDragging = true
				handleValueSliderInput(input.Position)
			end
		end)
		state.colorValueSlider.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				state.valueDragging = false
			end
		end)
	end

	UserInputService.InputChanged:Connect(function(input)
		if state.sidebarDrag and state.sidebarDrag.active then
			if input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch then
				updateSidebarReorder(input.Position)
			end
		end
		if not state.colorPickerOpen then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if state.wheelDragging then
			handleWheelInput(input.Position)
		elseif state.valueDragging then
			handleValueSliderInput(input.Position)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			state.wheelDragging = false
			state.valueDragging = false
			endSidebarReorder()
		end
	end)

	if state.colorHexBox then
		state.colorHexBox.FocusLost:Connect(function()
			local parsed = hexToColor(state.colorHexBox.Text)
			if parsed then
				syncColorPickerWidgets(parsed, true)
			else
				state.colorHexBox.Text = "#" .. colorToHex(state.pickerColor or getCustomAccent())
			end
		end)
	end

	if state.colorRgbBoxes then
		for _, box in pairs(state.colorRgbBoxes) do
			box.FocusLost:Connect(function()
				local r = math.clamp(tonumber(state.colorRgbBoxes.R and state.colorRgbBoxes.R.Text) or 0, 0, 255)
				local g = math.clamp(tonumber(state.colorRgbBoxes.G and state.colorRgbBoxes.G.Text) or 0, 0, 255)
				local b = math.clamp(tonumber(state.colorRgbBoxes.B and state.colorRgbBoxes.B.Text) or 0, 0, 255)
				syncColorPickerWidgets(Color3.fromRGB(r, g, b), false, true)
			end)
		end
	end

	if state.colorPickerApplyBtn then
		state.colorPickerApplyBtn.MouseButton1Click:Connect(function()
			local chosen = state.pickerColor or getCustomAccent()
			local draft = getSettingsDraftSafe()
			if draft then
				draft.customAccent = colorToHex(chosen)
				draft.theme = "Custom"
				setSettingsDirtySafe(true)
			end
			state.pendingThemeName = "Custom"
			state.pendingCustomAccent = chosen
			refreshThemeSwatches()
			if state.settingsThemeValueLabel then
				state.settingsThemeValueLabel.Text = ZoneT("theme.pendingCustomFmt"):format(currentThemeName(), colorToHex(chosen))
			end
			if settingsStatusLabel then
				settingsStatusLabel.Text = ZoneT("settings.customSelectedFmt"):format(colorToHex(chosen))
			end
			if state.setupPickerActive then
				setupWizardApplyCustom(chosen)
			end
			closeColorPicker()
		end)
	end
	if state.colorPickerCancelBtn then
		state.colorPickerCancelBtn.MouseButton1Click:Connect(closeColorPicker)
	end
	if state.colorPickerCloseBtn then
		state.colorPickerCloseBtn.MouseButton1Click:Connect(closeColorPicker)
	end
end

function buildSettingsBgStyleRow(parentCard, layoutOrder)
	if not parentCard then
		return nil
	end
	local th = theme()
	local row = make("TextButton", {
		Name = "BgStyleRow",
		LayoutOrder = layoutOrder,
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = th.card,
		BackgroundTransparency = 0.15,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = parentCard,
	})
	corner(row, 10)
	stroke(row, 0.9)
	addShadow(row, 10, 0.72, 3, 0)

	local name = make("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 6),
		Size = UDim2.new(1, -175, 0, 18),
		Text = "",
		Font = Enum.Font.GothamSemibold,
		TextSize = 13,
		TextColor3 = th.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local hint = make("TextLabel", {
		Name = "Note",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 23),
		Size = UDim2.new(1, -175, 0, 15),
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextColor3 = th.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local valueBtn = make("TextButton", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(150, 28),
		BackgroundColor3 = th.accent,
		Text = "",
		Font = Enum.Font.GothamSemibold,
		TextSize = 12,
		TextColor3 = theme().onAccent,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = row,
	})
	corner(valueBtn, 10)

	registerLangText(name, "settings.bgstyle")
	registerLangText(hint, "settings.bgstyle.note")

	local function renderValue()
		local draft = getSettingsDraftSafe()
		local code = draft and normalizeBgStyleCode(draft.backgroundStyle) or "stripes"
		valueBtn.Text = ZoneT("settings.bgstyle." .. code)
	end

	local optionDefs = { "stripes", "orbs", "bubbles", "sparkles", "rain" }
	local function closePicker()
		if state.bgStylePickerConn then
			state.bgStylePickerConn:Disconnect()
		end
		state.bgStylePickerConn = nil
		if state.bgStylePicker and state.bgStylePicker.Parent then
			state.bgStylePicker:Destroy()
		end
		state.bgStylePicker = nil
		if state.bgStylePickerShield and state.bgStylePickerShield.Parent then
			state.bgStylePickerShield:Destroy()
		end
		state.bgStylePickerShield = nil
	end
	closeBgStylePicker = closePicker
	local function openPicker()
		closePicker()
		if not parentCard or not parentCard.Parent then
			return
		end
		local draft = getSettingsDraftSafe()
		if not draft then
			return
		end
		local th = theme()
		local overlayHost = main
		if overlayHost == nil then
			overlayHost = parentCard
		end
		local hostPos = overlayHost.AbsolutePosition
		local btnX = valueBtn.AbsolutePosition.X - hostPos.X
		local btnY = valueBtn.AbsolutePosition.Y - hostPos.Y
		local btnW = valueBtn.AbsoluteSize.X
		local btnH = valueBtn.AbsoluteSize.Y
		local pickerW = btnW
		local pickerH = 100
		local anchorPoint = Vector2.new(1, 1)
		local posX = btnX + btnW
		local posY = btnY - 6
		if posY - pickerH < 8 then
			posY = btnY + btnH + 6
			anchorPoint = Vector2.new(1, 0)
		end
		local shield = make("TextButton", {
			Name = "BgStyleShield",
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			BorderSizePixel = 0,
			ZIndex = 29,
			Parent = overlayHost,
		})
		shield.MouseButton1Click:Connect(function()
			closePicker()
		end)
		state.bgStylePickerShield = shield
		local picker = make("Frame", {
			Name = "BgStylePicker",
			AnchorPoint = anchorPoint,
			Position = UDim2.fromOffset(posX, posY),
			Size = UDim2.new(0, pickerW, 0, pickerH),
			BackgroundColor3 = th.card,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			ZIndex = 30,
			Parent = overlayHost,
		})
		corner(picker, 12)
		stroke(picker, 0.9)
		addShadow(picker, 14, 0.6, 4, 0)
		state.bgStylePicker = picker
		if state.bgStylePickerConn then
			state.bgStylePickerConn:Disconnect()
		end
		state.bgStylePickerConn = RunService.RenderStepped:Connect(function()
			if not state.bgStylePicker or not state.bgStylePicker.Parent then
				return
			end
			if not valueBtn.Parent then
				closePicker()
				return
			end
			local bAbs = valueBtn.AbsolutePosition
			local mAbs = overlayHost.AbsolutePosition
			local trackX = bAbs.X - mAbs.X + pickerW
			local trackY = bAbs.Y - mAbs.Y - 6
			if trackY - pickerH < 8 then
				state.bgStylePicker.AnchorPoint = Vector2.new(1, 0)
				trackY = bAbs.Y - mAbs.Y + btnH + 6
			else
				state.bgStylePicker.AnchorPoint = Vector2.new(1, 1)
			end
			state.bgStylePicker.Position = UDim2.fromOffset(trackX, trackY)
		end)
		local scroll = make("ScrollingFrame", {
			Name = "List",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(6, 6),
			Size = UDim2.new(1, -12, 1, -12),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = th.accent,
			BorderSizePixel = 0,
			ZIndex = 30,
			Parent = picker,
		})
		local listLayout = Instance.new("UIListLayout")
		listLayout.Padding = UDim.new(0, 5)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Parent = scroll
		local current = normalizeBgStyleCode(draft.backgroundStyle)
		for index, optionCode in ipairs(optionDefs) do
			local optBtn = make("TextButton", {
				Name = "Option" .. index,
				Size = UDim2.new(1, 0, 0, 26),
				BackgroundColor3 = (optionCode == current) and th.accent or th.panel,
				BackgroundTransparency = (optionCode == current) and 0.1 or 0.35,
				Text = "",
				AutoButtonColor = false,
				BorderSizePixel = 0,
				LayoutOrder = index,
				ZIndex = 31,
				Parent = scroll,
			})
			corner(optBtn, 8)
			local optLabel = make("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(10, 0),
				Size = UDim2.new(1, -20, 1, 0),
				Text = ZoneT("settings.bgstyle." .. optionCode),
				Font = Enum.Font.GothamSemibold,
				TextSize = 12,
				TextColor3 = (optionCode == current) and th.onAccent or th.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 32,
				Parent = optBtn,
			})
			optBtn.MouseButton1Click:Connect(function()
				local freshDraft = getSettingsDraftSafe()
				if freshDraft then
					freshDraft.backgroundStyle = optionCode
					setSettingsDirtySafe(true)
					if settingsStatusLabel then
						settingsStatusLabel.Text = ZoneT("settings.unsaved")
					end
					renderValue()
				end
				closePicker()
			end)
		end
	end
	row.MouseButton1Click:Connect(function()
		if state.bgStylePicker and state.bgStylePicker.Parent then
			closePicker()
			return
		end
		openPicker()
	end)
	valueBtn.MouseButton1Click:Connect(function()
		if state.bgStylePicker and state.bgStylePicker.Parent then
			closePicker()
			return
		end
		openPicker()
	end)
	renderValue()
	return row
end

function zoneAutoBindLanguage()
	if not gui then return end
	if type(ZONE_LANG_INDEX_BY_CODE) ~= "table" then
		ZONE_LANG_INDEX_BY_CODE = {}
		ZONE_LANG_PATTERNS_BY_CODE = {}
		local patternMagic = {
			["^"] = true, ["$"] = true, ["("] = true, [")"] = true,
			["%"] = true, ["."] = true, ["["] = true, ["]"] = true,
			["*"] = true, ["+"] = true, ["-"] = true, ["?"] = true,
		}
		local localeOrder = { "en", "es", "fr", "de", "pt", "zh", "hu" }
		for _, locale in ipairs(localeOrder) do
			local dict = ZONE_LANG and ZONE_LANG[locale]
			if type(dict) == "table" then
				local textIndex = {}
				local patterns = {}
				for key, text in pairs(dict) do
					if type(text) == "string" and #text > 0 and #text < 500 then
						if textIndex[text] == nil then textIndex[text] = key end
						local pieces = { "^" }
						local kinds = {}
						local index = 1
						while index <= #text do
							local char = text:sub(index, index)
							if char == "%" and index < #text then
								local spec = text:sub(index + 1, index + 1)
								if spec == "s" or spec == "d" then
									table.insert(kinds, spec)
									table.insert(pieces, spec == "d" and "(%d+)" or "(.-)")
									index += 2
								else
									table.insert(pieces, "%%")
									index += 1
								end
							else
								if patternMagic[char] then
									table.insert(pieces, "%" .. char)
								else
									table.insert(pieces, char)
								end
								index += 1
							end
						end
						if #kinds > 0 then
							table.insert(pieces, "$")
							table.insert(patterns, { key = key, pattern = table.concat(pieces), kinds = kinds, length = #text })
						end
					end
				end
				table.sort(patterns, function(a, b) return a.length > b.length end)
				ZONE_LANG_INDEX_BY_CODE[locale] = textIndex
				ZONE_LANG_PATTERNS_BY_CODE[locale] = patterns
			end
		end
	end

	local function localeLookupOrder()
		local result, seen = {}, {}
		local current = ZoneCurrentLanguage()
		if ZONE_LANG_INDEX_BY_CODE[current] then
			table.insert(result, current)
			seen[current] = true
		end
		for _, locale in ipairs({ "en", "es", "fr", "de", "pt", "zh", "hu" }) do
			if not seen[locale] and ZONE_LANG_INDEX_BY_CODE[locale] then
				table.insert(result, locale)
				seen[locale] = true
			end
		end
		return result
	end

	local function findLanguageEntry(text)
		text = tostring(text or "")
		local order = localeLookupOrder()
		for _, locale in ipairs(order) do
			local exact = ZONE_LANG_INDEX_BY_CODE[locale] and ZONE_LANG_INDEX_BY_CODE[locale][text]
			if exact then return exact, nil, nil, locale end
		end
		for _, locale in ipairs(order) do
			for _, entry in ipairs(ZONE_LANG_PATTERNS_BY_CODE[locale] or {}) do
				local captures = { string.match(text, entry.pattern) }
				if #captures == #entry.kinds then
					return entry.key, captures, entry.kinds, locale
				end
			end
		end
		return nil, nil, nil, nil
	end

	local function makeLocalizedGetter(key, captures, kinds, sourceLocale)
		return function()
			local template = ZoneT(key)
			if type(captures) ~= "table" or #captures == 0 then return template end
			local args = {}
			local sourceDict = ZONE_LANG[sourceLocale] or ZONE_LANG.en
			for index, capture in ipairs(captures) do
				local kind = kinds and kinds[index]
				if kind == "d" then
					args[index] = tonumber(capture) or 0
				else
					local value = tostring(capture)
					if string.sub(key, 1, 16) == "settings.toggle." or key == "esp.statusFmt" then
						if value == sourceDict["ui.on"] then value = ZoneT("ui.on") end
						if value == sourceDict["ui.off"] then value = ZoneT("ui.off") end
					elseif key == "vote.optionCountFmt" then
						if value == sourceDict["vote.optionA"] then value = ZoneT("vote.optionA") end
						if value == sourceDict["vote.optionB"] then value = ZoneT("vote.optionB") end
					end
					args[index] = value
				end
			end
			local ok, formatted = pcall(string.format, template, table.unpack(args))
			if ok then return formatted end
			return template
		end
	end

	local function bindProperty(inst, propName)
		local explicitAttribute = propName == "Text" and "LangKey" or "LangPlaceholder"
		local explicitKey = inst:GetAttribute(explicitAttribute)
		local key, captures, kinds, sourceLocale
		if type(explicitKey) == "string" and explicitKey ~= "" then
			key = explicitKey
			local matchedKey, matchedCaptures, matchedKinds, matchedLocale = findLanguageEntry(tostring(inst[propName] or ""))
			if matchedKey == key then captures, kinds, sourceLocale = matchedCaptures, matchedKinds, matchedLocale end
		else
			key, captures, kinds, sourceLocale = findLanguageEntry(tostring(inst[propName] or ""))
		end
		if key then
			registerLangText(inst, makeLocalizedGetter(tostring(key), captures, kinds, sourceLocale or "en"), propName)
		end
	end

	local function bindObject(inst)
		if not inst then return end
		if inst:GetAttribute("ZoneLangSkip") == true then return end
		if not (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then return end
		local function observe(propName, marker)
			if inst:GetAttribute(marker) ~= true then
				inst:SetAttribute(marker, true)
				inst:GetPropertyChangedSignal(propName):Connect(function()
					if inst:GetAttribute("ZoneLangApplying") == true then return end
					task.defer(function()
						if inst.Parent ~= nil then bindProperty(inst, propName) end
					end)
				end)
			end
			bindProperty(inst, propName)
		end
		if not inst:IsA("TextBox") then observe("Text", "ZoneLangTextObserved") end
		if inst:IsA("TextBox") then observe("PlaceholderText", "ZoneLangPlaceholderObserved") end
	end

	for _, inst in ipairs(gui:GetDescendants()) do bindObject(inst) end
	if state.langAutoBound ~= true then
		state.langAutoBound = true
		gui.DescendantAdded:Connect(function(inst)
			task.defer(function() if inst.Parent then bindObject(inst) end end)
		end)
	end
	ZoneRefreshLanguage()
end

function startScript()
	local attempts = 0
	local hasAccess = false
	local lastError = nil

	while attempts < 8 and hasAccess ~= true do
		attempts += 1
		local ok, result = pcall(function()
			return AuthRF:InvokeServer()
		end)
		if ok and result == true then
			hasAccess = true
			break
		end
		lastError = ok and result or result
		task.wait(math.min(0.35 * attempts, 1.5))
	end

	state.accessGranted = hasAccess == true
	if not state.accessGranted then
		return
	end
	initPanel()
end

RemoteEvent.OnClientEvent:Connect(function(action)
	if action ~= "AdminGranted" or state.accessGranted == true then return end
	state.accessGranted = true
	task.defer(initPanel)
end)

function connectAnnouncementReceiver()
	if state.announceConnected or not state.AnnounceNotifyRE then
		return
	end
	state.announceConnected = true
	state.AnnounceNotifyRE.OnClientEvent:Connect(function(payload)
		local ok, silent = pcall(announceHandleIncoming, payload)
		if not ok then
			warn("[Zone Panel] announcement error:", silent)
			return
		end
		if not silent and announceNotifySound then
			if announceNotifySound.IsPlaying then
				announceNotifySound:Stop()
			end
			announceNotifySound:Play()
		end
	end)
end

pressWatch()
connectAdminFlyReceiver()
connectAnnouncementReceiver()
connectCommandResults()
connectSpectateReceiver()
connectWarningReceiver()
startScript()