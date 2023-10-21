local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Globals = require(ReplicatedStorage.Shared.Globals)

local LocalPlayer = Players.LocalPlayer
local StrideLength = 6
local DefaultFOV, SprintFOV = 70, 85
local WalkSpeed, SprintSpeed = Globals.Config.Character.WalkSpeed, Globals.Config.Character.SprintSpeed

local function Map(v, min1, max1, min2, max2)
	return min2 + (v - min1) * (max2 - min2) / (max1 - min1)
end

local CameraController = {}
CameraController.Enabled = false

function CameraController:GameInit()
	--Prestart Code
end

function CameraController:GameStart()
	--Start Code
end

function CameraController:Enable()
	print("enable")
	if self.Enabled then
		return
	end
	self.Enabled = true
	UserInputService.MouseIconEnabled = false
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

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

function CameraController:Disable()
	print("disable")
	if not self.Enabled then
		return
	end
	self.Enabled = false
	UserInputService.MouseIconEnabled = true
	RunService:UnbindFromRenderStep("Update Camera")
end

return CameraController
