local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)
local BehaviorTreeCreator = require(Globals.Vendor.BehaviorTreeCreator)
local SimplePath = require(Globals.Vendor.SimplePath)
local Net = require(Globals.Packages.Net)

local EnemyTemplate = Globals.Assets.Enemies.Monster
local RoamSearchRange = 25

local Monster = {}

local RNG = Random.new()

function Monster:GameInit()
	--print("Game Init Monster")
	Monster.SoundService = require(Globals.Services.SoundService)
end

local function SetupPath(Path, self)
	Path.Reached:Connect(function()
		--warn("Path Reached")
		self.Target = nil
	end)

	Path.Blocked:Connect(function()
		--warn("Path Blocked")
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

local function CheckIfStuck(self)
	local pos = self.Model.PrimaryPart.Position
	local v = (self.lastPos - pos)
	if v:Dot(v) > 0 then
		self.lastMoveTime = time()
	end
	self.lastPos = pos

	if time() - self.lastMoveTime > 4 then
		warn("Entity may be stuck... attempting respawn.")
		self.Aggroed = false
		self.Target = nil
		self.Model:PivotTo(CFrame.Angles(0, RNG:NextNumber(0, 2 * math.pi), 0) + self.Spawn)
	end
end

function Monster.new(spawnPosition)
	local jan = Janitor.new()

	local player = Players:GetPlayers()[1]

	local Entity = jan:Add(EnemyTemplate:Clone())
	Entity.HumanoidModel:PivotTo(CFrame.Angles(0, RNG:NextNumber(0, 2 * math.pi), 0) + spawnPosition)
	Entity.Parent = workspace
	Entity.HumanoidModel.PrimaryPart:SetNetworkOwner(player)

	local Path = SimplePath.new(Entity.HumanoidModel, {
		AgentRadius = 2,
		AgentHeight = 4,
		AgentCanJump = false,
		AgentCanClimb = false,
		WaypointSpacing = 4,
		Costs = {
			Padding = math.huge,
		},
	}, { JUMP_WHEN_STUCK = false })

	local self = {
		Model = Entity.HumanoidModel,
		Spawn = spawnPosition,
		InstantAggroDistance = 5,
		CloseDistance = 15,
		FarDistance = 40,

		RemoteActions = {
			Scan = Net:RemoteEvent("Scan"),
			Jumpscare = Net:RemoteEvent("Jumpscare"),
		},

		ScanTime = 1.5,
		RoamSpeed = 6,
		ChaseSpeed = 60,

		Path = Path,
		-- Waypoints = waypoints,
		Janitor = jan,
		lastSoundPosition = nil,

		Aggroed = false,
		Target = nil,
		SoundAggro = 0,
		AggroThresh = 5,
		MaxSoundAggro = 5,
		lastSoundTime = time(),
		lastMoveTime = time(),
	}

	self.lastPos = self.Model.PrimaryPart.Position

	Entity:SetAttribute("AggroThresh", self.AggroThresh)

	SetupPath(Path, self)

	-- Walk(Entity.HumanoidModel)

	local Brain = BehaviorTreeCreator:Create(Entity.Brain.Value, self)

	jan:Add(
		RunService.PostSimulation:Connect(function(dt)
			Brain:run(self)

			self.Model:SetAttribute("Aggroed", self.Aggroed)
			local timeToReachMaxDecay = 1
			local timeSinceLast = time() - self.lastSoundTime
			local decayRate = if timeSinceLast > 1 then math.max(timeSinceLast / timeToReachMaxDecay, 1) * 2 else 0.2

			self.SoundAggro = math.clamp(self.SoundAggro - (decayRate * dt), 0, self.MaxSoundAggro)
			Entity:SetAttribute("SoundAggro", self.SoundAggro)
			-- print(`SoundAggro: {self.SoundAggro} {decayRate}`)

			if self.Target then
				Path:Run(self.Target)
			end

			-- last pos
			CheckIfStuck(self)
		end),
		"Disconnect"
	)

	jan:Add(
		Monster.SoundService.SoundSignal:Connect(function(pos: Vector3, value: number)
			self.lastSoundPosition = pos
			self.lastSoundTime = time()
			self.SoundAggro = math.clamp(self.SoundAggro + value, 0, self.MaxSoundAggro)
			Entity:SetAttribute("SoundAggro", self.SoundAggro)
		end),
		"Disconnect"
	)

	--print("Grog initialized")

	return self
end

return Monster
