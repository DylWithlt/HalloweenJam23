local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)

local WALK_SPEED = 8
local SPRINT_SPEED = 15
local _speedDiff = SPRINT_SPEED - WALK_SPEED
local TIME_TO_SPRINT = 0.45
local TIME_TO_UNSPRINT = 0.25

local LocalPlayer = Players.LocalPlayer

local CharacterController = {}
CharacterController.PlayStepSound = Net:RemoteEvent("PlayStepSound")
CharacterController.TimeSinceLastStepSound = time()

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
	humanoid.WalkSpeed = WALK_SPEED

	RunService:BindToRenderStep("Handle Sprint", Enum.RenderPriority.Character.Value, function(dt)
		local isMoving = humanoid.MoveDirection.Magnitude > 0.01
		local isSprinting = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and isMoving
		if isSprinting and time() - self.TimeSinceLastStepSound > 1 then
			self.TimeSinceLastStepSound = time()
			CharacterController.PlayStepSound:FireServer()
		end

		if not isMoving then
			humanoid.WalkSpeed = WALK_SPEED
		elseif isSprinting and humanoid.WalkSpeed < SPRINT_SPEED then
			humanoid.WalkSpeed += _speedDiff * dt / TIME_TO_SPRINT
		elseif not isSprinting and humanoid.WalkSpeed > WALK_SPEED then
			humanoid.WalkSpeed -= _speedDiff * dt / TIME_TO_UNSPRINT
		end
	end)
end

function CharacterController:CharacterRemoving(character)
	RunService:UnbindFromRenderStep("Handle Sprint")
end

return CharacterController
