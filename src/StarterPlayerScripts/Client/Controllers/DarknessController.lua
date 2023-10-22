local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local LocalPlayer = Players.LocalPlayer

local MaxSanity = 100
local TimeToDrain = 10
local TimeToReplenish = 0.75
local ReplenishedByFlash = MaxSanity / 3

local overlapParams = OverlapParams.new()
overlapParams.CollisionGroup = "LightColliders"

local DarknessController = {}
DarknessController.Sanity = MaxSanity

function DarknessController:GameInit()
	self.FlashlightController = require(Globals.Client.Controllers.FlashlightController)
end

function DarknessController:GameStart()
	local darknessFrame = LocalPlayer.PlayerGui.Darkness.Frame
	local leftHand, rightHand = darknessFrame["LeftHand"], darknessFrame["RightHand"]

	LocalPlayer.CharacterAdded:Connect(function()
		self.Sanity = MaxSanity
	end)

	self.FlashlightController.Flashed:Connect(function()
		self.Sanity = math.min(MaxSanity, self.Sanity + ReplenishedByFlash)
	end)

	RunService.Stepped:Connect(function(_, dt)
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not root or self.Sanity == 0 then
			return
		end

		local isInLight = #workspace:GetPartBoundsInRadius(root.Position, 3, overlapParams) > 0
		self.Sanity += MaxSanity * dt / (if isInLight then TimeToReplenish else -TimeToDrain)
		self.Sanity = math.clamp(self.Sanity, 0, MaxSanity)

		local t = self.Sanity / MaxSanity
		leftHand.AnchorPoint = Vector2.new(t, leftHand.AnchorPoint.Y)
		leftHand.ImageTransparency = t
		rightHand.AnchorPoint = Vector2.new(1 - t, rightHand.AnchorPoint.Y)
		rightHand.ImageTransparency = t

		if self.Sanity == 0 then
			darknessFrame.BackgroundTransparency = 0
			--@todo: tell server that sanity ran out
		end
	end)
end

return DarknessController
