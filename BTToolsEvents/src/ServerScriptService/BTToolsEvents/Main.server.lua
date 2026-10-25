--[[
	BT Tools Event: Main (Script, সার্ভার)
	জায়গা: ServerScriptService > BTToolsEvents > Main

	শুধু মডিউলগুলো চালু করে। আসল কাজ Modules ফোল্ডারের ফাইলগুলোতে।
]]

-- ফাইলটা ইনসার্ট করার পর ঠিক জায়গায় সরানোর আগে Play চাপলে যেন ভুল জায়গা থেকে না চলে।
if not script:IsDescendantOf(game:GetService("ServerScriptService")) then
	warn("[BTToolsEvents] Main স্ক্রিপ্টটা ServerScriptService এ রাখুন, তারপর চালু হবে।")
	return
end

local Modules = script.Parent:WaitForChild("Modules")

local ToolData = require(Modules:WaitForChild("ToolData"))
local BoxSpawner = require(Modules:WaitForChild("BoxSpawner"))
local Showcase = require(Modules:WaitForChild("Showcase"))
local EventManager = require(Modules:WaitForChild("EventManager"))
local AdminService = require(Modules:WaitForChild("AdminService"))

ToolData.Init()
BoxSpawner.Init()
Showcase.Init()
EventManager.Init()
AdminService.Init()
