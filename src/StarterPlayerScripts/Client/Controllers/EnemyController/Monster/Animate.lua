local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local util = require(Globals.Shared.Util)

local assets = Globals.Assets
local sounds = assets.Sounds

local animations = Globals.Assets.Enemies.Monster.Animations
local upperWalking = animations.UpperWalking

local floorCastParams = RaycastParams.new()
floorCastParams.CollisionGroup = "FloorRaycast"
floorCastParams.RespectCanCollide = true

local function lerp(a, b, t)
	return (1 - t) * a + b * t
end

local function playStepSound(entity)
	local soundToPlay = util.getRandomChild(sounds.Steps)
	util.PlaySound(soundToPlay, entity.PrimaryPart, 0.15)
end
playStepSound()

local function SetupEntity(entity, janitor)
	local rootPart = entity:FindFirstChild("HumanoidRootPart")
	local humanoid = entity:FindFirstChild("Humanoid")
	local upperWalkingTrack = humanoid:LoadAnimation(upperWalking)
	upperWalkingTrack:AdjustSpeed(0)

	local LeftHip = entity:FindFirstChild("LeftHipSocket", true)
	local LeftTarget = janitor:Add(Instance.new("Part", entity))
	LeftTarget.Anchored = true
	LeftTarget.CanCollide = false
	LeftTarget.Transparency = 0.5
	LeftTarget.Size = Vector3.new(0.2, 0.2, 0.2)
	LeftTarget.Color = Color3.new(0, 0, 1)
	LeftTarget.CFrame = rootPart.CFrame * CFrame.new(-0.6, 0, 0) + Vector3.new(0, -5.26, 0)
	local LeftPole = janitor:Add(Instance.new("Attachment", LeftTarget))
	LeftPole.Position = Vector3.new(0, 3.319, -3.249)
	LeftPole.Name = "Pole"
	local LeftLegControl = janitor:Add(Instance.new("IKControl", humanoid))
	LeftLegControl.ChainRoot = entity:FindFirstChild("L.Leg.1", true)
	LeftLegControl.EndEffector = entity:FindFirstChild("LeftLegTip", true)
	LeftLegControl.Target = LeftTarget
	LeftLegControl.Pole = LeftTarget.Pole
	LeftLegControl.SmoothTime = 0

	local RightHip = entity:FindFirstChild("RightHipSocket", true)
	local RightTarget = janitor:Add(LeftTarget:Clone())
	RightTarget.Parent = entity
	RightTarget.Color = Color3.new(0, 0, 1)
	RightTarget.CFrame = rootPart.CFrame * CFrame.new(0.6, 0, 0) + Vector3.new(0, -5.26, 0)
	local RightPole = RightTarget.Pole
	local RightLegControl = janitor:Add(Instance.new("IKControl", humanoid))
	RightLegControl.ChainRoot = entity:FindFirstChild("R.Leg.1", true)
	RightLegControl.EndEffector = entity:FindFirstChild("RightLegTip", true)
	RightLegControl.Target = RightTarget
	RightLegControl.Pole = RightTarget.Pole
	RightLegControl.SmoothTime = 0

	local ikInstances = {
		Left = {
			Target = LeftTarget,
			Hip = LeftHip,
			Pole = LeftPole,
			Control = LeftLegControl,
		},
		Right = {
			Target = RightTarget,
			Hip = RightHip,
			Pole = RightPole,
			Control = RightLegControl,
		},
	}

	local goals = {
		[LeftTarget] = rootPart.L,
		[RightTarget] = rootPart.R,
	}

	return rootPart, humanoid, upperWalkingTrack, rootPart.Waist, ikInstances, goals
end

local function ShouldMoveTarget(target, goals, goalOffset, maxDistance)
	local targetGoal = goals[target].WorldPosition + goalOffset
	return maxDistance < (target.Position - targetGoal).Magnitude
end

local function ShouldMoveAnyTarget(ikInstances, goals, goalOffset, maxDistance)
	for _, instances in pairs(ikInstances) do
		if ShouldMoveTarget(instances.Target, goals, goalOffset, maxDistance) then
			return true, instances.Target
		end
	end

	return false
end

local function SetMovingTarget(movingTargetData, target, rootPart)
	if not target then
		movingTargetData.target = nil
		movingTargetData.origin = nil
	else
		movingTargetData.target = target
		movingTargetData.origin = target.Position
	end

	movingTargetData.lastPosition = rootPart.Position
	movingTargetData.distance = 0
end

local function MoveTarget(movingTargetData, goals, goalOffset, ikInstances, rootPart, maxDistance, upperWalkingTrack)
	local movingTarget = movingTargetData.target
	movingTargetData.distance += (movingTargetData.lastPosition - rootPart.Position).Magnitude
	local t = math.min(movingTargetData.distance / maxDistance, 1)
	local tAnim = (t / 2 + if movingTargetData.target == ikInstances.Right.Target then 0 else 0.5)
	upperWalkingTrack.TimePosition = tAnim * upperWalkingTrack.Length

	local movingGoal = goals[movingTarget]
	local desired = movingTargetData.origin:Lerp(movingGoal.WorldPosition + goalOffset, t)

	local origin, direction = desired + 1.5 * Vector3.yAxis, -3 * Vector3.yAxis
	local floorResult = workspace:Raycast(origin, direction, floorCastParams)
	local floorLevel = if floorResult then floorResult.Position else origin + direction

	local desired_y = floorLevel.Y + math.sin(math.pi * t)
	movingTarget.CFrame = movingTarget.CFrame.Rotation + Vector3.new(desired.X, desired_y, desired.Z)

	if t == 1 then
		local nextTarget = if ikInstances.Left.Target == movingTarget
			then ikInstances.Right.Target
			else ikInstances.Left.Target
		if ShouldMoveTarget(nextTarget, goals, goalOffset, maxDistance) then
			SetMovingTarget(movingTargetData, nextTarget, rootPart)
		else
			SetMovingTarget(movingTargetData, nil, rootPart)
		end
	end

	movingTargetData.lastPosition = rootPart.Position
end

local rotation = CFrame.Angles(-math.pi / 2, -math.pi / 2, 0)
local function UpdateTargetOrientations(ikInstances, rightVector)
	for _, instances in pairs(ikInstances) do
		instances.Target.CFrame = CFrame.lookAt(instances.Target.Position, instances.Hip.WorldPosition, rightVector)
			* rotation
	end
end

function UpdateWaistHeight(ikInstances, rootPart, waistMotor6D, waistC0)
	local LY, RY = ikInstances.Left.Target.Position.Y, ikInstances.Right.Target.Position.Y
	local minHeight = math.min(LY, RY)
	local maxHeight = if minHeight == LY then RY else LY
	local waistPosition = (rootPart.Position.Y - lerp(minHeight, maxHeight, 0.25) - 4) * Vector3.yAxis
	local offset = rootPart.CFrame:VectorToObjectSpace(waistPosition)
	waistMotor6D.C0 = waistC0 + offset
end

return function(entity, janitor)
	local rootPart, humanoid, upperWalkingTrack, waistMotor6D, ikInstances, goals = SetupEntity(entity, janitor)
	local waistC0 = waistMotor6D.C0

	local movingTargetData = {
		target = nil,
		origin = nil,
		lastPosition = rootPart.Position,
		distance = 0,
	}

	upperWalkingTrack:Play()

	janitor:Add(RunService.PreSimulation:Connect(function()
		local rootVelocity = rootPart.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
		local maxDistance = (entity:GetAttribute("MaximumTargetDistance") or 4) + rootVelocity.Magnitude / 6
		local goalOffset = maxDistance / 2 * rootVelocity / humanoid.WalkSpeed

		if not movingTargetData.target then
			local shouldMove, target = ShouldMoveAnyTarget(ikInstances, goals, goalOffset, maxDistance)
			if shouldMove then
				SetMovingTarget(movingTargetData, target, rootPart)
			elseif rootVelocity.Magnitude > 0 then
				SetMovingTarget(movingTargetData, ikInstances.Right.Target, rootPart)
			end
		end

		if movingTargetData.target then
			MoveTarget(movingTargetData, goals, goalOffset, ikInstances, rootPart, maxDistance, upperWalkingTrack)
		end

		UpdateWaistHeight(ikInstances, rootPart, waistMotor6D, waistC0)
		UpdateTargetOrientations(ikInstances, rootPart.CFrame.RightVector)
	end))

	return janitor
end
