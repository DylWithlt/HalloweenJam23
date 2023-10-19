local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)
local BehaviorTreeCreator = require(Globals.Vendor.BehaviorTreeCreator)
local SimplePath = require(Globals.Vendor.SimplePath)

local EnemyTemplate = Globals.Assets.Enemies.Monster
local RoamSearchRange = 25

local Monster = {}

local RNG = Random.new()

function Monster:GameInit()
	self.SoundService = require(Globals.Services.SoundService)
end

local function Walk(Entity)
	local RootPart = Entity.HumanoidRootPart
	local Humanoid = Entity.Humanoid
	Humanoid.HipHeight = 4

	local LeftHip = Entity:FindFirstChild("LeftHipSocket", true)
	local LeftTarget = Instance.new("Part", Entity)
	LeftTarget.Anchored = true
	LeftTarget.CanCollide = false
	LeftTarget.Transparency = 0.5
	LeftTarget.Size = Vector3.new(0.2, 0.2, 0.2)
	LeftTarget.Color = Color3.new(0, 0, 1)
	LeftTarget.CFrame = RootPart.CFrame * CFrame.new(-0.6, 0, 0) + Vector3.new(0, -5.26, 0)
	local LeftPole = Instance.new("Attachment", LeftTarget)
	LeftPole.Position = Vector3.new(0, 3.319, -3.249)
	LeftPole.Name = "Pole"
	local LeftLegControl = Instance.new("IKControl", Humanoid)
	LeftLegControl.ChainRoot = Entity:FindFirstChild("L.Leg.1", true)
	LeftLegControl.EndEffector = Entity:FindFirstChild("LeftLegTip", true)
	LeftLegControl.Target = LeftTarget
	LeftLegControl.Pole = LeftTarget.Pole

	local RightHip = Entity:FindFirstChild("RightHipSocket", true)
	local RightTarget = LeftTarget:Clone()
	RightTarget.Parent = Entity
	RightTarget.Color = Color3.new(0, 0, 1)
	RightTarget.CFrame = RootPart.CFrame * CFrame.new(0.6, 0, 0) + Vector3.new(0, -5.26, 0)
	local RightPole = RightTarget.Pole
	local RightLegControl = Instance.new("IKControl", Humanoid)
	RightLegControl.ChainRoot = Entity:FindFirstChild("R.Leg.1", true)
	RightLegControl.EndEffector = Entity:FindFirstChild("RightLegTip", true)
	RightLegControl.Target = RightTarget
	RightLegControl.Pole = RightTarget.Pole

	local MAXIMUM_TARGET_DISTANCE_TO_GOAL = 4

	local rotation = CFrame.Angles(-math.pi / 2, -math.pi / 2, 0)
	local function UpdateTargetOrientation(target, hip, rightVector)
		target.CFrame = CFrame.lookAt(target.Position, hip.WorldPosition, rightVector) * rotation
	end

	local function ShouldMoveTarget(target, goals, goalOffset, maxDistance)
		local targetGoal = goals[target].WorldPosition + goalOffset
		return maxDistance < (target.Position - targetGoal).Magnitude
	end

	local function ShouldMoveAnyTarget(targets, goals, goalOffset, maxDistance)
		for _, target in ipairs(targets) do
			if ShouldMoveTarget(target, goals, goalOffset, maxDistance) then
				return true, target
			end
		end

		return false
	end

	local floorCastParams = RaycastParams.new()
	floorCastParams.RespectCanCollide = true

	local Goals = {
		[LeftTarget] = RootPart.L,
		[RightTarget] = RootPart.R,
	}

	local waistMotor6D, waistC0 = RootPart.Waist, RootPart.Waist.C0
	local movingTarget, movingLastPosition, movingOrigin, movingDistance
	RunService.PreSimulation:Connect(function()
		-- local offset = (workspace.Goal.Position - RootPart.Position) * Vector3.new(1, 0, 1)
		-- if offset.Magnitude > 1 then
		-- 	Humanoid:Move(offset)
		-- else
		-- 	Humanoid:Move(Vector3.zero)
		-- end

		local maxDistance = Entity:GetAttribute("MaximumTargetDistance") or 4
		local rootVelocity = RootPart.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
		local goalOffset = maxDistance / 2 * rootVelocity / Humanoid.WalkSpeed

		if not movingTarget then
			local shouldMove, target = ShouldMoveAnyTarget({ LeftTarget, RightTarget }, Goals, goalOffset, maxDistance)

			if shouldMove then
				movingTarget = target
				movingOrigin = movingTarget.Position
				movingDistance = 0
				movingLastPosition = RootPart.Position
			elseif rootVelocity.Magnitude > 0 then
				movingTarget = RightTarget
				movingOrigin = movingTarget.Position
				movingDistance = 0
				movingLastPosition = RootPart.Position
			end
		end

		if movingTarget then
			movingDistance += (movingLastPosition - RootPart.Position).Magnitude
			local t = math.min(movingDistance / maxDistance, 1)

			local movingGoal = Goals[movingTarget]
			local desiredPosition = movingGoal.WorldPosition + goalOffset
			local desired = movingOrigin:Lerp(desiredPosition, t)
			local origin, direction = desired + 1.5 * Vector3.yAxis, -3 * Vector3.yAxis
			local floorResult = workspace:Raycast(origin, direction, floorCastParams)
			local floorHeight = if floorResult then floorResult.Position else origin + direction
			local desired_y = floorHeight.Y + math.sin(math.pi * t)
			movingTarget.CFrame = movingTarget.CFrame.Rotation + Vector3.new(desired.X, desired_y, desired.Z)
			-- waistMotor6D.C0 = waistC0 + desired_y / 4 * Vector3.yAxis

			if t == 1 then
				local nextTarget = if LeftTarget == movingTarget then RightTarget else LeftTarget
				if ShouldMoveTarget(nextTarget, Goals, goalOffset, maxDistance) then
					movingTarget = nextTarget
					movingOrigin = nextTarget.Position
					movingDistance = 0
				else
					movingTarget = nil
				end
			end

			movingLastPosition = RootPart.Position
		end

		UpdateTargetOrientation(LeftTarget, LeftHip, RootPart.CFrame.RightVector)
		UpdateTargetOrientation(RightTarget, RightHip, RootPart.CFrame.RightVector)
	end)
end

local function SetupPath(Path, self)
	Path.Reached:Connect(function()
		warn("Path Reached")
		if self.Target then
			Path:Run(self.Target)
		end
	end)

	Path.Blocked:Connect(function()
		warn("Path Blocked")
		if self.Target then
			Path:Run(self.Target)
		end
	end)

	Path.Error:Connect(function(errorType)
		-- warn("Path Error")
		if self.Target then
			Path:Run(self.Target)
		end
	end)

	Path.WaypointReached:Connect(function()
		warn("Path waypoint reached")
		if self.Target then
			Path:Run(self.Target)
		end
	end)

	Path.Visualize = false
end

function Monster.new(spawnPosition)
	local Janitor = Janitor.new()

	local player = Players:GetPlayers()[1]

	local Entity = Janitor:Add(EnemyTemplate:Clone())
	Entity.Parent = workspace
	Entity.Grog:PivotTo(CFrame.Angles(0, RNG:NextNumber(0, 2 * math.pi), 0) + spawnPosition)
	Entity.Grog.PrimaryPart:SetNetworkOwner(player)

	local Path = SimplePath.new(Entity.Grog, {})

	local self = {
		Model = Entity.Grog,
		CloseDistance = 15,
		FarDistance = 40,

		RoamSpeed = 6,
		ChaseSpeed = 30,

		Path = Path,
		-- Waypoints = waypoints,
		Janitor = Janitor,
		lastSoundPosition = nil,

		Aggroed = false,
		Target = nil,
		SoundAggro = 0,
		MaxSoundAggro = 10,
	}

	SetupPath(Path, self)

	Walk(Entity.Grog)

	local Brain = BehaviorTreeCreator:Create(Entity.Brain.Value, self)

	Janitor:Add(
		RunService.PostSimulation:Connect(function(dt)
			Brain:run(self)
			self.SoundAggro = math.clamp(self.SoundAggro - dt * 0.1, 0, self.MaxSoundAggro)
			if self.Target then
				Path:Run(self.Target)
			end
		end),
		"Disconnect"
	)

	Janitor:Add(
		self.SoundService.SoundSignal:Connect(function(pos: Vector3, value: number)
			self.lastSoundPosition = pos
			self.SoundAggro = math.clamp(self.SoundAggro + value, 0, self.MaxSoundAggro)
		end),
		"Disconnect"
	)

	return self
end

local function PickRandomWithWeight(array, weightFunction)
	local selectable = {}

	local totalWeight = 0
	for _, v in ipairs(array) do
		local weight = weightFunction(v)

		table.insert(selectable, {
			Value = v,
			Weight = weight,
		})

		totalWeight += weight
	end

	local travelled = 0
	local x = RNG:GetNextNumber(0, totalWeight)
	for _, v in ipairs(selectable) do
		if travelled < x then
			travelled += v.Weight
			continue
		end

		return v
	end
end

function Monster.GetNextRoamPoint(self)
	local overlapParams = OverlapParams.new()
	overlapParams.CollisionGroup = "Waypoint"
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = self.Waypoints

	local nearbyPoints = workspace:GetPartBoundsInBox(
		CFrame.new(self.Model.Origin.Position),
		RoamSearchRange * Vector3.new(1, 1, 1),
		overlapParams
	)

	local player = game.Players:GetChildren()[1]
	if player and player.Character and #nearbyPoints > 0 then
		local characterPosition = player.Character.Origin.Position
		local entityToCharacter = (characterPosition - self.Model.Origin.Position).Unit

		return PickRandomWithWeight(self.Waypoints, function(waypoint)
			local product = (waypoint - characterPosition).Unit:Dot(entityToCharacter)
			return math.max(0, (1 + product) / 2)
		end)
	else
		return self.Waypoints[RNG:NextInteger(1, #self.Waypoints)]
	end
end

return Monster
