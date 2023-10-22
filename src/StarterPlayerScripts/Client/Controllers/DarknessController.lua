local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local Acts = require(Globals.Shared.Acts)

local sounds = Globals.Assets.Sounds

local LocalPlayer = Players.LocalPlayer

local MaxSanity = 100
local TimeToDrain = 10
local TimeToReplenish = 0.75
local ReplenishedByFlash = MaxSanity / 3

local overlapParams = OverlapParams.new()
overlapParams.CollisionGroup = "LightColliders"

local DarknessController = {}
DarknessController.Sanity = MaxSanity
DarknessController.InsanityReached = Net:RemoteEvent("InsanityReached")

function DarknessController:GameInit()
	self.FlashlightController = require(Globals.Client.Controllers.FlashlightController)
end

function DarknessController:GameStart()
	local darknessFrame = LocalPlayer.PlayerGui.Darkness.Frame
	local leftHand, rightHand = darknessFrame["LeftHand"], darknessFrame["RightHand"]

	local tweenInfo = TweenInfo.new(0.4)
	local tweenToTransparent = TweenService:Create(darknessFrame, tweenInfo, {
		BackgroundTransparency = 1,
	})

	LocalPlayer.CharacterAdded:Connect(function()
		self.Sanity = MaxSanity
		tweenToTransparent:Play()
	end)

	self.FlashlightController.Flashed:Connect(function()
		self.Sanity = math.min(MaxSanity, self.Sanity + ReplenishedByFlash)
	end)

	RunService.Stepped:Connect(function(_, dt)
		local sNumber = math.abs((self.Sanity / MaxSanity) - 1)

		sounds.Whispers.Volume = sNumber
		sounds.Heartbeat.Volume = sNumber
		sounds.EarRinging.Volume = 1.8 * sNumber ^ 2
		sounds.Heartbeat.PlaybackSpeed = (1 + (sNumber / 2)) ^ 2

		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not root or self.Sanity == 0 then
			return
		end

		local isInLight = #workspace:GetPartBoundsInRadius(root.Position, 3, overlapParams) > 0
			or Acts:checkAct("MinigameRunning", "Jumpscare")
		self.Sanity += MaxSanity * dt / (if isInLight then TimeToReplenish else -TimeToDrain)
		self.Sanity = math.clamp(self.Sanity, 0, MaxSanity)

		local t = self.Sanity / MaxSanity
		leftHand.AnchorPoint = Vector2.new(t, leftHand.AnchorPoint.Y)
		leftHand.ImageTransparency = t

		rightHand.AnchorPoint = Vector2.new(1 - t, rightHand.AnchorPoint.Y)
		rightHand.ImageTransparency = t

		if self.Sanity == 0 then
			tweenToTransparent:Cancel()
			darknessFrame.BackgroundTransparency = 0
			leftHand.ImageTransparency = 1
			rightHand.ImageTransparency = 1
			self.InsanityReached:FireServer()
			sounds.Whispers:Stop()
			sounds.Heartbeat:Stop()
			sounds.EarRinging:Stop()
			sounds.Crack1:Play()
			sounds.Crack2:Play()
			sounds.Crack3:Play()
		elseif not sounds.Whispers.Playing then
			sounds.Whispers:Play()
			sounds.Heartbeat:Play()
			sounds.EarRinging:Play()
		end
	end)
end

return DarknessController
