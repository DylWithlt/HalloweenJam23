local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.Shared.Globals)

local FlickerPatternsFolder = Globals.Assets.FlickerPatterns

local FLICKER_RADIUS = 50

local overlapParams = OverlapParams.new()
overlapParams.CollisionGroup = "Lights"

function EvaluateNumberSequence(ns, t)
	if t == 0 then
		return ns.Keypoints[1].Value
	elseif t == 1 then
		return ns.Keypoints[#ns.Keypoints].Value
	end

	for i = 1, #ns.Keypoints - 1 do
		local this = ns.Keypoints[i]
		local next = ns.Keypoints[i + 1]
		if t >= this.Time and t < next.Time then
			local alpha = (t - this.Time) / (next.Time - this.Time)
			return (next.Value - this.Value) * alpha + this.Value
		end
	end
end

local function GetRandomFlickerPattern()
	local children = FlickerPatternsFolder:GetChildren()
	return children[math.random(1, #children)]
end

local flickering = {}
local function FlickerLight(lightInstance)
	if flickering[lightInstance] then
		return
	end

	flickering[lightInstance] = true
	local originalBrightness = lightInstance.Brightness
	local pattern = GetRandomFlickerPattern()
	local sequence, duration = pattern:GetAttribute("Sequence"), pattern:GetAttribute("Duration")

	local t = 0
	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		local scalar = EvaluateNumberSequence(sequence, t / duration)
		lightInstance.Brightness = originalBrightness * scalar
		t += dt
		if t > duration then
			connection:Disconnect()
			flickering[lightInstance] = nil
			lightInstance.Brightness = originalBrightness
		end
	end)
end

return function(entityModel, janitor)
	local root = entityModel:FindFirstChild("HumanoidRootPart", true)

	local thread = task.spawn(function()
		while true do
			task.wait(math.random(1, 3))

			local lightsToFlicker = workspace:GetPartBoundsInRadius(root.Position, FLICKER_RADIUS, overlapParams)
			for _, part in ipairs(lightsToFlicker) do
				local lightInstance = part:FindFirstChildWhichIsA("Light")
				if not lightInstance then
					return
				end
				FlickerLight(lightInstance)
			end
		end
	end)

	janitor:Add(function()
		task.cancel(thread)
	end)
end
