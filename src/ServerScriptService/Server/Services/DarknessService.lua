local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Timer = require(Globals.Packages.Timer)

local overlapParams = OverlapParams.new()
overlapParams.CollisionGroup = "Lights"

local DarknessService = {}
DarknessService.CheckTimer = Timer.new(1)

function DarknessService:GameInit() end

function DarknessService:GameStart()
	self.CheckTimer:Start()

	self.CheckTimer.Tick:Connect(function()
		for _, player in ipairs(Players:GetPlayers()) do
			local root = player.Character and player.Character.PrimaryPart
			if not root then
				continue
			end

			local numLightsInside = 0
			for _, nearbyLight in ipairs(workspace:GetPartBoundsInRadius(root.Position, 60, overlapParams)) do
				local lightInstance = nearbyLight:FindFirstChildWhichIsA("Light", true)
				if not lightInstance then
					continue
				end

				local range = nearbyLight.Range

				workspace:Raycast()
			end
		end
	end)
end

return DarknessService
