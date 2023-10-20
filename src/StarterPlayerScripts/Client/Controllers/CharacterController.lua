local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)

local _speedDiff = Globals.Config.Character.SprintSpeed - Globals.Config.Character.WalkSpeed
local TIME_TO_SPRINT = 0.45
local TIME_TO_UNSPRINT = 0.25

local LocalPlayer = Players.LocalPlayer

local CharacterController = {}
CharacterController.PlayStepSound = Net:RemoteEvent("PlayStepSound")
CharacterController.TimeSinceLastStepSound = time()

local diedConn

function CharacterController:GameInit()
	self.CameraController = require(Globals.Client.Controllers.CameraController)
end

function CharacterController:GameStart()
	if LocalPlayer.Character then
		CharacterController:CharacterAdded(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(function(character)
		CharacterController:CharacterAdded(character)
	end)

	LocalPlayer.CharacterRemoving:Connect(function(character)
		CharacterController:CharacterRemoving(character)
	end)
end

function CharacterController:CharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = Globals.Config.Character.WalkSpeed
	self.CameraController:Enable()

	diedConn = humanoid.Died:Connect(function()
		diedConn:Disconnect()
		self.CameraController:Disable()
	end)

	RunService:BindToRenderStep("Handle Sprint", Enum.RenderPriority.Character.Value, function(dt)
		local isMoving = humanoid.MoveDirection.Magnitude > 0.01
		local isSprinting = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and isMoving
		if isSprinting and time() - self.TimeSinceLastStepSound > 1 then
			self.TimeSinceLastStepSound = time()
			CharacterController.PlayStepSound:FireServer()
		end

		if not isMoving then
			humanoid.WalkSpeed = Globals.Config.Character.WalkSpeed
		elseif isSprinting and humanoid.WalkSpeed < Globals.Config.Character.SprintSpeed then
			humanoid.WalkSpeed += _speedDiff * dt / TIME_TO_SPRINT
		elseif not isSprinting and humanoid.WalkSpeed > Globals.Config.Character.WalkSpeed then
			humanoid.WalkSpeed -= _speedDiff * dt / TIME_TO_UNSPRINT
		end
	end)
end

function CharacterController:CharacterRemoving(character)
	RunService:UnbindFromRenderStep("Handle Sprint")
end

return CharacterController
