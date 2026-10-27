--[[
	Fixed "Data" script for the JamerLF Roblox Plus Donation System.
	Location in Studio: ServerScriptService > RobloxPlusDonationv1#JamerLF > Data

	What was wrong with the original:
	1) On shutdown, ProfileService releases every profile. The original
	   ListenToRelease handler called player:Kick() at that moment, which
	   cancels the teleport to the new server ("Your profile has been released").
	2) When many players join at once (or right after a crash/shutdown),
	   LoadProfileAsync can return nil because the old session lock is still
	   held or another server is force-loading the same profile. The original
	   script kicked on the first nil ("Profile load failed").

	This version never kicks while the server is closing, and retries the
	load instead of kicking.
--]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileService = require(ReplicatedStorage["RobloxPlusDonationv1#JamerLF"].ProfileService)

local ProfileTemplate = {
	Donated = 0,
	Raised = 0,
}

local ProfileStore = ProfileService.GetProfileStore(
	"DonationProfiles",
	ProfileTemplate
)

local RETRY_DELAY = 5 -- Seconds before the first retry
local MAX_RETRY_DELAY = 30 -- Retry delay grows up to this value

-- Profiles cache
local Profiles = {}

local ServerClosing = false
game:BindToClose(function()
	ServerClosing = true
end)

-- ProfileService sets ServiceLocked as soon as its own shutdown handler starts,
-- before it releases profiles, so checking both covers any BindToClose order
local function isClosing()
	return ServerClosing or ProfileService.ServiceLocked
end

local function setupLeaderstats(player, profile)
	local folder = player:WaitForChild("leaderstats",30)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "leaderstats"
		folder.Parent = player
	end

	-- Donated
	local Donated = folder:FindFirstChild("Donated")
	if not Donated then
		Donated = Instance.new("IntValue")
		Donated.Name = "Donated"
		Donated.Parent = folder
	end
	Donated.Value = profile.Data.Donated or 0
	Donated.Changed:Connect(function()
		profile.Data.Donated = Donated.Value
	end)

	-- Raised
	local Raised = folder:FindFirstChild("Raised")
	if not Raised then
		Raised = Instance.new("IntValue")
		Raised.Name = "Raised"
		Raised.Parent = folder
	end
	Raised.Value = profile.Data.Raised or 0
	Raised.Changed:Connect(function()
		profile.Data.Raised = Raised.Value
	end)
end

-- Keeps trying while the player is in the server. A nil result is usually
-- temporary: old session lock not released yet, another server force-loading
-- the same key, or DataStore throttling when many players join together.
local function loadProfile(player)
	local delay = RETRY_DELAY
	local attempt = 0
	while player:IsDescendantOf(Players) and not isClosing() do
		attempt += 1
		local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId, "ForceLoad")
		if profile then
			return profile
		end
		warn(("[Donation Data] Load attempt %d failed for %s, retrying in %ds"):format(attempt, player.Name, delay))
		task.wait(delay)
		delay = math.min(delay * 2, MAX_RETRY_DELAY)
	end
	return nil
end

-- Player join
local function onPlayerAdded(player)
	local profile = loadProfile(player)
	if not profile then
		-- Player left or the server is closing; nothing to do and no kick
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	profile:ListenToRelease(function()
		Profiles[player] = nil
		-- Every profile is released on shutdown; kicking here would cancel the
		-- player's teleport to the new server
		if isClosing() then
			return
		end
		-- Released mid-session means another server took this profile
		if player:IsDescendantOf(Players) then
			player:Kick("Your donation data was loaded in another server. Please rejoin.")
		end
	end)

	if player:IsDescendantOf(Players) then
		Profiles[player] = profile
		setupLeaderstats(player, profile)
	else
		profile:Release()
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

-- Player leaving
Players.PlayerRemoving:Connect(function(player)
	local profile = Profiles[player]
	if profile then
		profile:Release()
	end
end)
