local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local globals = require(ReplicatedStorage.Shared.Globals)

local camera = workspace.CurrentCamera

function module.ApplyMonitorPrompts()
	for _, computer in ipairs(workspace.Computers:GetChildren()) do
		local newPrompt = Instance.new("ProximityPrompt")
		newPrompt.Parent = computer.PrimaryPart
	end
end

return module
