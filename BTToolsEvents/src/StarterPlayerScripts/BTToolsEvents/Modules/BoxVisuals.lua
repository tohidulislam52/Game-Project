--[[
	BT Tools Event: BoxVisuals (ModuleScript, ক্লায়েন্ট)
	মাটির বক্সগুলো ঘোরায় আর হালকা ভাসায়। শুধু নিজের স্ক্রিনে চলে, তাই সার্ভারে কোনো ল্যাগ নেই (I15)।
	সার্ভার শুধু স্থির Root আর Prompt রাখে, এখানে শুধু "Visual" অংশটা নড়ে।
]]

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local SPIN_SPEED = math.rad(50) -- প্রতি সেকেন্ডে
local BOB_HEIGHT = 0.4
local BOB_SPEED = 2

local BoxVisuals = {}

type Entry = { visual: Model, base: CFrame, phase: number }

local entries: { [Model]: Entry } = {}

local function track(model: Instance)
	if not model:IsA("Model") then
		return
	end
	local visual = model:WaitForChild("Visual", 5)
	if not visual or not visual:IsA("Model") or not model.Parent then
		return
	end
	entries[model] = { visual = visual, base = visual:GetPivot(), phase = math.random() * math.pi * 2 }
end

function BoxVisuals.Init()
	task.spawn(function()
		local folder = Workspace:WaitForChild("BTToolsEvents_Boxes")
		folder.ChildAdded:Connect(function(child)
			track(child)
		end)
		folder.ChildRemoved:Connect(function(child)
			if child:IsA("Model") then
				entries[child] = nil
			end
		end)
		for _, child in folder:GetChildren() do
			task.spawn(track, child)
		end
	end)

	RunService.RenderStepped:Connect(function()
		local now = os.clock()
		for model, entry in entries do
			if not model.Parent or not entry.visual.Parent then
				entries[model] = nil
				continue
			end
			local t = now + entry.phase
			local bob = math.sin(t * BOB_SPEED) * BOB_HEIGHT
			entry.visual:PivotTo(entry.base * CFrame.new(0, bob, 0) * CFrame.Angles(0, t * SPIN_SPEED, 0))
		end
	end)
end

return BoxVisuals
