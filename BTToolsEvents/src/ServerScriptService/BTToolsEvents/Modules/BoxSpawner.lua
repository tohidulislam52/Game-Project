--[[
	BT Tools Event: BoxSpawner (ModuleScript, সার্ভার)

	বক্স কোথায় পড়বে সেটা খুঁজে বের করে।
	1. Workspace > HuntSpawnZones ফোল্ডারে পার্ট থাকলে বক্স শুধু ওই পার্টগুলোর এলাকায় পড়বে।
	   জোনের ওপর থেকে নিচে ray ছুড়ে মাটি (Terrain বা পার্ট) খোঁজা হয়। মাটিটা জোনের
	   উচ্চতার ভেতরে না পড়লে বাতিল, তাই পাতলা জোন রাখলে বক্স ছাদ বা গাছে উঠবে না।
	2. জোন না থাকলে অ্যাডমিনের চারপাশে radius এর মধ্যে পড়বে।
	পানি, খাড়া ঢাল আর CanCollide = false পার্ট (ঘাস, পাতা ইত্যাদি) বাদ যায়।
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("BTToolsEvents")
local Config = require(Shared:WaitForChild("Config"))

local BoxSpawner = {}

local rng = Random.new()

local function getZones(): { BasePart }
	local zones = {}
	local folder = Workspace:FindFirstChild(Config.SPAWN_ZONES_FOLDER_NAME)
	if folder then
		for _, d in folder:GetDescendants() do
			if d:IsA("BasePart") then
				table.insert(zones, d)
			end
		end
	end
	return zones
end

-- জোন পার্টগুলোকে গেমের ভেতরে অদৃশ্য আর স্পর্শহীন করে দেয়।
local function hideZone(part: BasePart)
	part.Anchored = true
	part.Transparency = 1
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
end

function BoxSpawner.Init()
	local folder = Workspace:FindFirstChild(Config.SPAWN_ZONES_FOLDER_NAME)
	if folder then
		for _, zone in getZones() do
			hideZone(zone)
		end
		folder.DescendantAdded:Connect(function(d)
			if d:IsA("BasePart") then
				hideZone(d)
			end
		end)
	end
end

function BoxSpawner.CountZones(): number
	return #getZones()
end

local function makeRaycastParams(exclude: { Instance }): RaycastParams
	local list = table.clone(exclude)
	for _, player in Players:GetPlayers() do
		if player.Character then
			table.insert(list, player.Character)
		end
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = list
	params.IgnoreWater = false
	params.RespectCanCollide = true
	return params
end

local function isGoodGround(hit: RaycastResult?): boolean
	if not hit then
		return false
	end
	if hit.Material == Enum.Material.Water then
		return false
	end
	if string.find(string.lower(hit.Instance.Name), "water", 1, true) then
		return false
	end
	return hit.Normal.Y >= Config.MIN_GROUND_FLATNESS
end

local function farEnough(position: Vector3, taken: { Vector3 }): boolean
	local minDistance = Config.MIN_DISTANCE_BETWEEN_BOXES
	for _, other in taken do
		local dx, dz = position.X - other.X, position.Z - other.Z
		if dx * dx + dz * dz < minDistance * minDistance then
			return false
		end
	end
	return true
end

local function pickWeightedZone(zones: { BasePart }, totalArea: number): BasePart
	local roll = rng:NextNumber() * totalArea
	for _, zone in zones do
		roll -= zone.Size.X * zone.Size.Z
		if roll <= 0 then
			return zone
		end
	end
	return zones[#zones]
end

local function sampleZone(zone: BasePart, params: RaycastParams): Vector3?
	local size = zone.Size
	local top = zone.CFrame:PointToWorldSpace(
		Vector3.new((rng:NextNumber() - 0.5) * size.X, size.Y / 2, (rng:NextNumber() - 0.5) * size.Z)
	)
	local hit = Workspace:Raycast(top, -zone.CFrame.UpVector * size.Y, params)
	if hit and isGoodGround(hit) then
		return hit.Position
	end
	return nil
end

local function sampleRadius(center: Vector3, radius: number, params: RaycastParams): Vector3?
	local angle = rng:NextNumber() * math.pi * 2
	local distance = math.sqrt(rng:NextNumber()) * radius
	local origin = center + Vector3.new(math.cos(angle) * distance, 150, math.sin(angle) * distance)
	local hit = Workspace:Raycast(origin, Vector3.new(0, -400, 0), params)
	if hit and isGoodGround(hit) then
		return hit.Position
	end
	return nil
end

-- count টা বক্সের জায়গা খোঁজে। যতগুলো পাওয়া গেল সেগুলো ফেরত দেয় (count এর চেয়ে কম হতে পারে)।
-- exclude: যেগুলোতে ray লাগবে না (বক্স ফোল্ডার, শোকেস ইত্যাদি)।
function BoxSpawner.FindPositions(
	count: number,
	center: Vector3?,
	radius: number,
	exclude: { Instance }
): ({ Vector3 }, string)
	local params = makeRaycastParams(exclude)
	local zones = getZones()
	local positions: { Vector3 } = {}
	local attempts = count * 40

	if #zones > 0 then
		local totalArea = 0
		for _, zone in zones do
			totalArea += zone.Size.X * zone.Size.Z
		end
		while #positions < count and attempts > 0 do
			attempts -= 1
			local ground = sampleZone(pickWeightedZone(zones, totalArea), params)
			if ground and farEnough(ground, positions) then
				table.insert(positions, ground + Vector3.new(0, Config.BOX_HOVER_HEIGHT, 0))
			end
		end
		return positions, "zones"
	end

	if not center then
		return positions, "none"
	end
	while #positions < count and attempts > 0 do
		attempts -= 1
		local ground = sampleRadius(center, radius, params)
		if ground and farEnough(ground, positions) then
			table.insert(positions, ground + Vector3.new(0, Config.BOX_HOVER_HEIGHT, 0))
		end
	end
	return positions, "radius"
end

return BoxSpawner
