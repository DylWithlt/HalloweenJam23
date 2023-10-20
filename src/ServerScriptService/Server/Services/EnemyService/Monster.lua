local CollectionService = game:GetService("CollectionService")
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
	print("Game Init Monster")
	Monster.SoundService = require(Globals.Services.SoundService)
end

local function SetupPath(Path, self)
	Path.Reached:Connect(function()
		warn("Path Reached")
		self.Target = nil
	end)

	Path.Blocked:Connect(function()
		warn("Path Blocked")
		if self.Target then
			Path:Run(self.Target)
		end
	end)

	Path.Error:Connect(function(errorType)
		-- if errorType == "AgentStuck" then
		-- 	warn(errorType)
		-- 	local waypoints = CollectionService:GetTagged("PatrolPaypoint")
		-- 	local point = waypoints[RNG:NextInteger(1, #waypoints)]
		-- 	if not point then
		-- 		return
		-- 	end
		-- 	self.Model:PivotTo(point.CFrame)
		-- end
	end)

	Path.WaypointReached:Connect(function()
		-- warn("Path waypoint reached")
		if self.Target then
			Path:Run(self.Target)
		end
	end)

	Path.Visualize = false
end

function Monster.new(spawnPosition)
	local jan = Janitor.new()

	local player = Players:GetPlayers()[1]

	local Entity = jan:Add(EnemyTemplate:Clone())
	Entity.HumanoidModel:PivotTo(CFrame.Angles(0, RNG:NextNumber(0, 2 * math.pi), 0) + spawnPosition)
	Entity.Parent = workspace
	Entity.HumanoidModel.PrimaryPart:SetNetworkOwner(player)

	local Path = SimplePath.new(Entity.HumanoidModel, {
		AgentRadius = 3,
		AgentHeight = 6,
		AgentCanJump = false,
		AgentCanClimb = false,
		WaypointSpacing = 4,
		Costs = {
			Padding = math.huge,
		},
	}, { JUMP_WHEN_STUCK = false })

	local self = {
		Model = Entity.HumanoidModel,
		CloseDistance = 15,
		FarDistance = 40,

		ScanTime = 1,
		RoamSpeed = 6,
		ChaseSpeed = 60,

		Path = Path,
		-- Waypoints = waypoints,
		Janitor = jan,
		lastSoundPosition = nil,

		Aggroed = false,
		Target = nil,
		SoundAggro = 0,
		MaxSoundAggro = 10,
	}

	SetupPath(Path, self)

	-- Walk(Entity.HumanoidModel)

	local Brain = BehaviorTreeCreator:Create(Entity.Brain.Value, self)

	jan:Add(
		RunService.PostSimulation:Connect(function(dt)
			Brain:run(self)
			self.SoundAggro = math.clamp(self.SoundAggro - dt * 0.4, 0, self.MaxSoundAggro)
			print(`SoundAggro: {self.SoundAggro}`)

			if self.Target then
				Path:Run(self.Target)
			end
		end),
		"Disconnect"
	)

	jan:Add(
		Monster.SoundService.SoundSignal:Connect(function(pos: Vector3, value: number)
			self.lastSoundPosition = pos
			self.SoundAggro = math.clamp(self.SoundAggro + value, 0, self.MaxSoundAggro)
		end),
		"Disconnect"
	)

	print("Grog initialized")

	return self
end

-- local function PickRandomWithWeight(array, weightFunction)
-- 	local selectable = {}

-- 	local totalWeight = 0
-- 	for _, v in ipairs(array) do
-- 		local weight = weightFunction(v)

-- 		table.insert(selectable, {
-- 			Value = v,
-- 			Weight = weight,
-- 		})

-- 		totalWeight += weight
-- 	end

-- 	local travelled = 0
-- 	local x = RNG:GetNextNumber(0, totalWeight)
-- 	for _, v in ipairs(selectable) do
-- 		if travelled < x then
-- 			travelled += v.Weight
-- 			continue
-- 		end

-- 		return v
-- 	end
-- end

-- function Monster.GetNextRoamPoint(self)
-- 	local overlapParams = OverlapParams.new()
-- 	overlapParams.CollisionGroup = "Waypoint"
-- 	overlapParams.FilterType = Enum.RaycastFilterType.Include
-- 	overlapParams.FilterDescendantsInstances = self.Waypoints

-- 	local nearbyPoints = workspace:GetPartBoundsInBox(
-- 		CFrame.new(self.Model.Origin.Position),
-- 		RoamSearchRange * Vector3.new(1, 1, 1),
-- 		overlapParams
-- 	)

-- 	local player = game.Players:GetChildren()[1]
-- 	if player and player.Character and #nearbyPoints > 0 then
-- 		local characterPosition = player.Character.Origin.Position
-- 		local entityToCharacter = (characterPosition - self.Model.Origin.Position).Unit

-- 		return PickRandomWithWeight(self.Waypoints, function(waypoint)
-- 			local product = (waypoint - characterPosition).Unit:Dot(entityToCharacter)
-- 			return math.max(0, (1 + product) / 2)
-- 		end)
-- 	else
-- 		return self.Waypoints[RNG:NextInteger(1, #self.Waypoints)]
-- 	end
-- end

return Monster
