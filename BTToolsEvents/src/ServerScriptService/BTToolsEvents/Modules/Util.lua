--[[
	BT Tools Event: Util (ModuleScript, সার্ভার)
	ছোট ছোট সাহায্যকারী ফাংশন: retry, rate limit, ক্যারেক্টার খোঁজা।
]]

local Players = game:GetService("Players")

local Util = {}

-- fn কে pcall দিয়ে চালায়, ফেল করলে exponential backoff দিয়ে আবার চেষ্টা করে।
-- shouldStop(err) true দিলে আর চেষ্টা করে না (যেমন Studio তে API বন্ধ থাকলে)।
function Util.Retry(label: string, attempts: number, fn: () -> any, shouldStop: ((string) -> boolean)?): (boolean, any)
	local delaySeconds = 1
	local lastError: any = nil
	for attempt = 1, attempts do
		local ok, result = pcall(fn)
		if ok then
			return true, result
		end
		lastError = result
		if shouldStop and shouldStop(tostring(result)) then
			break
		end
		warn(`[BTToolsEvents] {label} ব্যর্থ ({attempt}/{attempts}): {result}`)
		if attempt < attempts then
			task.wait(delaySeconds)
			delaySeconds = math.min(delaySeconds * 2, 16)
		end
	end
	return false, lastError
end

-- প্রতি প্লেয়ার interval সেকেন্ডে একবার অনুমতি দেয়।
function Util.RateLimiter(interval: number): (Player) -> boolean
	local lastCall: { [Player]: number } = {}
	Players.PlayerRemoving:Connect(function(player)
		lastCall[player] = nil
	end)
	return function(player: Player): boolean
		local now = os.clock()
		local last = lastCall[player]
		if last and now - last < interval then
			return false
		end
		lastCall[player] = now
		return true
	end
end

-- জীবিত ক্যারেক্টার থাকলে (character, humanoid, root) দেয়।
function Util.GetLiveCharacter(player: Player): (Model?, Humanoid?, BasePart?)
	local character = player.Character
	if not character then
		return nil, nil, nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return nil, nil, nil
	end
	return character, humanoid, root
end

function Util.IsInteger(value: any, minValue: number, maxValue: number): boolean
	return type(value) == "number" and value == value and value % 1 == 0 and value >= minValue and value <= maxValue
end

return Util
