--[[
	BT Tools Event: Config (ModuleScript)
	জায়গা: ReplicatedStorage > BTToolsEvents > Config

	পুরো সিস্টেমের সব সেটিং এই একটা ফাইলে। এখানে মান বদলালেই কাজ হবে,
	অন্য কোনো স্ক্রিপ্টে হাত দেওয়ার দরকার নেই।
	সার্ভার আর ক্লায়েন্ট দুজনেই এই ফাইল পড়ে, তাই এখানে কোনো গোপন জিনিস রাখবেন না।
]]

local RunService = game:GetService("RunService")

local Config = {}

----------------------------------------------------------------------
-- 👑 অ্যাডমিন
----------------------------------------------------------------------
-- নতুন অ্যাডমিন যোগ করতে এই লিস্টে তার UserId লিখুন, কমা দিয়ে আলাদা করে।
Config.ADMIN_USER_IDS = {
	7864126209,
}

-- Studio তে টেস্ট করার সময় সবাই অ্যাডমিন হবে (লাইভ গেমে এর কোনো প্রভাব নেই)।
Config.ALLOW_ADMIN_IN_STUDIO = true

----------------------------------------------------------------------
-- 💰 খালি বক্সের টাকা
----------------------------------------------------------------------
-- leaderstats এর ভেতরে যে ভ্যালুতে টাকা যোগ হবে তার নাম।
Config.CURRENCY_NAME = "Taka"
-- খালি বক্স থেকে কত টাকা পাবে (দুটো সমান রাখলে সবসময় একই টাকা)।
Config.COIN_REWARD_MIN = 1000
Config.COIN_REWARD_MAX = 3000

----------------------------------------------------------------------
-- 🧰 টুল আর ডেটা
----------------------------------------------------------------------
-- ServerStorage এ পুরস্কারের টুলের ফোল্ডারের নাম।
Config.TOOLS_FOLDER_NAME = "Tools"
-- গেমে ঢোকার কত সেকেন্ড পরে সেভ করা টুলগুলো দেওয়া হবে।
Config.JOIN_GRANT_DELAY = 5
-- ডেটাস্টোরের নাম। এটা বদলালে আগের সব সেভ করা টুল হারিয়ে যাবে, তাই বদলাবেন না।
Config.DATASTORE_NAME = "BTToolsEvents_OwnedTools_v1"
Config.HISTORY_DATASTORE_NAME = "BTToolsEvents_WinHistory_v1"
-- জেতার ইতিহাসে সর্বোচ্চ কয়টা লাইন রাখা হবে।
Config.HISTORY_MAX_ENTRIES = 200

----------------------------------------------------------------------
-- 🎁 ইভেন্ট (অ্যাডমিন প্যানেলে এগুলোই ডিফল্ট হিসেবে দেখাবে)
----------------------------------------------------------------------
Config.DEFAULT_TOTAL_BOXES = 20
Config.MAX_TOTAL_BOXES = 100
Config.DEFAULT_EVENT_MINUTES = 5
Config.MAX_EVENT_MINUTES = 60

-- টুল শুরুতেই যেন না পাওয়া যায় (R14)।
-- প্রথম কত % বক্সে কখনো টুল আসবে না।
Config.DEFAULT_TOOL_SAFE_PERCENT = 40
-- একটা টুল পাওয়ার পর পরের কয়টা বক্সে টুল আসবে না।
Config.DEFAULT_TOOL_GAP = 2

----------------------------------------------------------------------
-- 📍 বক্স স্পনের জায়গা
----------------------------------------------------------------------
-- Workspace এ এই নামের ফোল্ডারে রাখা পার্টগুলোর এলাকায় বক্স পড়বে।
Config.SPAWN_ZONES_FOLDER_NAME = "HuntSpawnZones"
-- কোনো জোন না থাকলে অ্যাডমিনের চারপাশে কত stud পর্যন্ত বক্স পড়বে।
Config.DEFAULT_SPAWN_RADIUS = 200
Config.MAX_SPAWN_RADIUS = 1500
-- দুইটা বক্সের মাঝে কমপক্ষে কত stud দূরত্ব থাকবে।
Config.MIN_DISTANCE_BETWEEN_BOXES = 20
-- এর চেয়ে খাড়া ঢালে বক্স পড়বে না (1 = একদম সমান, 0 = খাড়া দেয়াল)।
Config.MIN_GROUND_FLATNESS = 0.6
-- মাটি থেকে বক্স কত উপরে ভাসবে।
Config.BOX_HOVER_HEIGHT = 2

----------------------------------------------------------------------
-- 📦 বক্স তোলা আর খোলা
----------------------------------------------------------------------
Config.BOX_PROMPT_DISTANCE = 10
Config.BOX_PROMPT_HOLD_DURATION = 0.3
-- বক্স হাতে আসার পর কমপক্ষে কত সেকেন্ড না গেলে সার্ভার বক্স খুলবে না (চিট বন্ধ করতে)।
Config.MIN_OPEN_TIME = 1.5

----------------------------------------------------------------------
-- 🎯 বক্স খোলার মিনি-গেম (টাইমিং বার)
----------------------------------------------------------------------
Config.Minigame = {
	HITS_REQUIRED = 3, -- কয়বার সঠিক ক্লিক করতে হবে
	ZONE_SIZE_START = 0.24, -- প্রথম রাউন্ডে সোনালি জোন বারের কত অংশ (0.24 = 24%)
	ZONE_SHRINK = 0.04, -- প্রতি রাউন্ডে জোন কতটা ছোট হবে
	ZONE_SIZE_MIN = 0.1, -- জোন এর চেয়ে ছোট হবে না
	NEEDLE_SPEED_START = 0.9, -- কাঁটার গতি (প্রতি সেকেন্ডে বারের কত অংশ পার হয়)
	NEEDLE_SPEED_UP = 0.3, -- প্রতি রাউন্ডে গতি কত বাড়বে
	MISS_STUN = 0.6, -- ভুল ক্লিকের পর কত সেকেন্ড অপেক্ষা
}

----------------------------------------------------------------------
-- 🏆 বিজয়ীর শোকেস
----------------------------------------------------------------------
-- Workspace এ এই নামের পার্টের জায়গায় বিজয়ীর বড় অবতার নাচবে।
Config.SHOWCASE_PART_NAME = "WinnerShowcase"
Config.SHOWCASE_SCALE = 3
Config.SHOWCASE_DURATION = 25
-- পাশাপাশি দুইটা অবতারের মাঝের দূরত্ব (stud)।
Config.SLOT_SPACING = 12
Config.MAX_SHOWCASE_SLOTS = 3
-- নাচের অ্যানিমেশন ID। এখানে নিজের ID বসান।
Config.DANCE_ANIMATION_ID = "rbxassetid://0"
-- আসল বিজয়ীর মাথার ওপরে ইভেন্ট শেষ না হওয়া পর্যন্ত "👑 WINNER" ট্যাগ থাকবে কিনা।
Config.WINNER_TAG_ON_PLAYER = true

----------------------------------------------------------------------
-- 🔊 সাউন্ড ID (rbxassetid://0 থাকলে সেই সাউন্ড বাজবে না)
----------------------------------------------------------------------
Config.SOUND_IDS = {
	EventStart = "rbxassetid://96924810403789", -- ইভেন্ট শুরুর ব্যানার
	Pickup = "rbxassetid://0", -- বক্স তোলা
	Hit = "rbxassetid://0", -- মিনি-গেমে সঠিক ক্লিক
	Miss = "rbxassetid://0", -- মিনি-গেমে ভুল ক্লিক
	Unbox = "rbxassetid://128852575896829", -- বক্স ফাটা
	Coin = "rbxassetid://99023919906775", -- খালি বক্স থেকে টাকা
	ToolWin = "rbxassetid://99856221174802", -- টুল জেতা
	EventEnd = "rbxassetid://0", -- ইভেন্ট শেষ
}
Config.SOUND_VOLUME = 0.6

----------------------------------------------------------------------
-- এর নিচে কিছু বদলানোর দরকার নেই
----------------------------------------------------------------------
local adminSet: { [number]: boolean } = {}
for _, userId in Config.ADMIN_USER_IDS do
	adminSet[userId] = true
end

function Config.IsAdmin(player: Player): boolean
	if Config.ALLOW_ADMIN_IN_STUDIO and RunService:IsStudio() then
		return true
	end
	return adminSet[player.UserId] == true
end

function Config.IsSoundSet(id: string?): boolean
	return type(id) == "string" and id ~= "" and not string.match(id, "^rbxassetid://0*$")
end

return Config
