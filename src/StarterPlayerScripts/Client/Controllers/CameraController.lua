local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)
local Net = require(Globals.Packages.Net)
local CameraShaker = require(Globals.Vendor.CameraShaker)
local CameraShakeInstance = require(Globals.Vendor.CameraShaker.CameraShakeInstance)

local LocalPlayer = Players.LocalPlayer
local MaxStepShakeDistance = 50
local StrideLength = 6
local DefaultFOV, SprintFOV = 70, 85
local WalkSpeed, SprintSpeed = Globals.Config.Character.WalkSpeed, Globals.Config.Character.SprintSpeed

local Jumpscare = Net:RemoteEvent("Jumpscare")
local JumpscareJanitor = Janitor.new()

local function Map(v, min1, max1, min2, max2)
	return min2 + (v - min1) * (max2 - min2) / (max1 - min1)
end

local CameraController = {}
CameraController.Enabled = false
CameraController.Shake = CameraShaker.new(Enum.RenderPriority.Camera.Value + 2, function(shakeCF)
	workspace.CurrentCamera.CFrame *= shakeCF
end)

local function createStepShake(stepPosition)
	local distance = (stepPosition - workspace.CurrentCamera.CFrame.Position).Magnitude
	local scale = 1 - math.min(distance / MaxStepShakeDistance, 1)
	local c = CameraShakeInstance.new(scale * 3, 4, 0.1, 0.2)
	c.PositionInfluence = Vector3.new(0.5, 0.5, 0.5)
	return c
end

function CameraController:GameInit()
	CameraController.JumpscareBox = workspace:WaitForChild("JumpscareBox")
	CameraController.FlashbangUI = LocalPlayer.PlayerGui:WaitForChild("Flashbang")
	self.Shake:Start()
end

function CameraController:GameStart()
	Jumpscare.OnClientEvent:Connect(function()
		self:Jumpscare()
	end)
end

function CameraController:Enable()
	if self.Enabled then
		return
	end
	self.Enabled = true

	JumpscareJanitor:Cleanup()
	self.FlashbangUI.Enabled = false

	UserInputService.MouseIconEnabled = false
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

	local distanceTravelled, lastPosition = 0, workspace.CurrentCamera.CFrame.Position
	local currentVelocityTilt = Vector3.zero
	RunService:BindToRenderStep("Update Camera", Enum.RenderPriority.Camera.Value + 1, function(dt)
		local camera = workspace.CurrentCamera
		local origin = camera.CFrame
		distanceTravelled += (camera.CFrame.Position - lastPosition).Magnitude
		lastPosition = camera.CFrame.Position

		local bobSpeed = math.pi / StrideLength
		local x = 0.35 * math.cos(distanceTravelled * bobSpeed)
		local y = 0.1 * math.sin(distanceTravelled * 2 * bobSpeed)
		local z = math.rad(0.5) * math.cos(distanceTravelled * -bobSpeed)
		local currentVelocity = if LocalPlayer.Character
			then LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity
			else Vector3.zero
		currentVelocityTilt = currentVelocityTilt:Lerp(camera.CFrame:VectorToObjectSpace(currentVelocity), 0.1)
		z += math.rad(math.clamp(-currentVelocityTilt.X, -math.rad(10), math.rad(10)))
		camera.CFrame = origin * CFrame.new(x, y, 0) * CFrame.Angles(0, 0, z)

		local desiredFOV =
			math.max(Map(currentVelocity.Magnitude, WalkSpeed, SprintSpeed, DefaultFOV, SprintFOV), DefaultFOV)
		camera.FieldOfView += (desiredFOV - camera.FieldOfView) * (1 - math.pow(2, -10 * dt))
	end)
end

function CameraController:ShakeStep(stepPosition)
	self.Shake:Shake(createStepShake(stepPosition))
end

function CameraController:Jumpscare()
	self:Disable()
	UserInputService.MouseIconEnabled = false

	self.FlashbangUI.Frame.BackgroundColor3 = Color3.new(1, 1, 1)
	self.FlashbangUI.Frame.BackgroundTransparency = 0
	self.FlashbangUI.Enabled = true

	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = self.JumpscareBox.CameraOrigin.CFrame

	local flashTween = JumpscareJanitor:Add(
		TweenService:Create(self.FlashbangUI.Frame, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 1,
		}),
		"Cancel"
	)

	local cameraTween = JumpscareJanitor:Add(
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad),
			{ CFrame = self.JumpscareBox.CameraDestination.CFrame }
		),
		"Cancel"
	)

	flashTween:Play()
	JumpscareJanitor:Add(task.delay(0.75, function()
		self.FlashbangUI.Enabled = false
		cameraTween:Play()
	end))

	JumpscareJanitor:Add(
		cameraTween.Completed:Connect(function()
			flashTween:Cancel()
			self.FlashbangUI.Frame.BackgroundColor3 = Color3.new()
			self.FlashbangUI.Frame.BackgroundTransparency = 0
			self.FlashbangUI.Enabled = true
		end),
		"Disconnect"
	)
end

function CameraController:Disable()
	if not self.Enabled then
		return
	end
	self.Enabled = false
	UserInputService.MouseIconEnabled = true
	RunService:UnbindFromRenderStep("Update Camera")
end

return CameraController
