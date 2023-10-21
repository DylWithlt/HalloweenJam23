local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local MaxSanity = 100
local TimeToDrain = 10
local TimeToReplenish = 1
local ReplenishedByFlash = MaxSanity / 3

local LocalPlayer = Players.LocalPlayer

local overlapParams = OverlapParams.new()
overlapParams.CollisionGroup = "LightColliders"

local DarknessController = {}
DarknessController.Sanity = MaxSanity

function DarknessController:GameInit()
	local FlashlightController
end

function DarknessController:GameStart()
	RunService.RenderStepped:Connect(function()
		local root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
		if not root then
			return
		end

		local isInLight = #workspace:GetPartBoundsInRadius(root.Position, 3, overlapParams)
	end)
end

return DarknessController
