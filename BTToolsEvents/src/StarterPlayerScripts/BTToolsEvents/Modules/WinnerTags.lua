--[[
	BT Tools Event: WinnerTags (ModuleScript, ক্লায়েন্ট)
	বিজয়ীর "👑 WINNER" ট্যাগে countdown বার আর সোনালি ঝিলিক চালায়।
	ট্যাগগুলো সার্ভার বানায় (Showcase), এখানে শুধু নিজের স্ক্রিনে নড়াচড়া।
]]

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local TAG_NAME = "BTWinnerTag"

local WinnerTags = {}

local tags: { [BillboardGui]: boolean } = {}

local function update(tag: BillboardGui, now: number, shimmer: number)
	local card = tag:FindFirstChild("Card")
	if not card then
		return
	end
	local title = card:FindFirstChild("Title")
	local gradient = title and title:FindFirstChildOfClass("UIGradient")
	if gradient then
		gradient.Offset = Vector2.new(0, shimmer)
	end

	local expiresAt = tag:GetAttribute("ExpiresAt")
	local duration = tag:GetAttribute("Duration")
	if type(expiresAt) ~= "number" or type(duration) ~= "number" or duration <= 0 then
		return
	end
	local left = math.max(0, expiresAt - now)
	local barBack = card:FindFirstChild("BarBack")
	local fill = barBack and barBack:FindFirstChild("BarFill")
	if fill and fill:IsA("Frame") then
		fill.Size = UDim2.fromScale(math.clamp(left / duration, 0, 1), 1)
	end
	local timeText = card:FindFirstChild("TimeText")
	if timeText and timeText:IsA("TextLabel") then
		timeText.Text = `{math.ceil(left)}s`
	end
end

function WinnerTags.Init()
	local function add(instance: Instance)
		if instance:IsA("BillboardGui") then
			tags[instance] = true
		end
	end
	CollectionService:GetInstanceAddedSignal(TAG_NAME):Connect(add)
	CollectionService:GetInstanceRemovedSignal(TAG_NAME):Connect(function(instance)
		if instance:IsA("BillboardGui") then
			tags[instance] = nil
		end
	end)
	for _, instance in CollectionService:GetTagged(TAG_NAME) do
		add(instance)
	end

	RunService.Heartbeat:Connect(function()
		if not next(tags) then
			return
		end
		local now = Workspace:GetServerTimeNow()
		local shimmer = math.sin(os.clock() * 2) * 0.3
		for tag in tags do
			if tag.Parent then
				update(tag, now, shimmer)
			else
				tags[tag] = nil
			end
		end
	end)
end

return WinnerTags
