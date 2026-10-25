--[[
	BT Tools Event: ClientMain (LocalScript, ক্লায়েন্ট)
	জায়গা: StarterPlayer > StarterPlayerScripts > BTToolsEvents > ClientMain

	শুধু ক্লায়েন্টের মডিউলগুলো চালু করে।
]]

local Modules = script.Parent:WaitForChild("Modules")

local Sounds = require(Modules:WaitForChild("Sounds"))
local HUD = require(Modules:WaitForChild("HUD"))
local Minigame = require(Modules:WaitForChild("Minigame"))
local BoxVisuals = require(Modules:WaitForChild("BoxVisuals"))
local WinnerTags = require(Modules:WaitForChild("WinnerTags"))
local AdminPanel = require(Modules:WaitForChild("AdminPanel"))

Sounds.Init()
HUD.Init()
Minigame.Init()
BoxVisuals.Init()
WinnerTags.Init()
AdminPanel.Init()
