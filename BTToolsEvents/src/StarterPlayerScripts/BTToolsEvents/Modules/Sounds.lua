--[[
	BT Tools Event: Sounds (ModuleScript, ক্লায়েন্ট)
	Config.SOUND_IDS থেকে সাউন্ড বাজায়। ID 0 বা খালি হলে চুপচাপ কিছু করে না।
]]

local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage:WaitForChild("BTToolsEvents"):WaitForChild("Config"))

local Sounds = {}

local templates: { [string]: Sound } = {}

function Sounds.Init()
	local folder = Instance.new("Folder")
	folder.Name = "BTToolsEventsSounds"
	folder.Parent = SoundService
	local toPreload = {}
	for name, id in Config.SOUND_IDS do
		if Config.IsSoundSet(id) then
			local sound = Instance.new("Sound")
			sound.Name = name
			sound.SoundId = id
			sound.Volume = Config.SOUND_VOLUME
			sound.Parent = folder
			templates[name] = sound
			table.insert(toPreload, sound)
		end
	end
	task.spawn(function()
		pcall(function()
			ContentProvider:PreloadAsync(toPreload)
		end)
	end)
end

function Sounds.Play(name: string, pitch: number?)
	local template = templates[name]
	if not template then
		return
	end
	local sound = template:Clone()
	sound.PlaybackSpeed = pitch or 1
	sound.Parent = SoundService
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	sound:Play()
	task.delay(15, function()
		if sound.Parent then
			sound:Destroy()
		end
	end)
end

return Sounds
