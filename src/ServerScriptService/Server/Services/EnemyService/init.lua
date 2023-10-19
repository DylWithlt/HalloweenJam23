local CollectionService = game:GetService("CollectionService")

local EnemyService = {}
EnemyService.Spawns = {}

local MinSpawnDistanceFromPlayer
local random = Random.new()

function EnemyService:GameInit()
	for _, spawnPart in ipairs(CollectionService:GetTagged("Spawn")) do
		local enemyName = spawnPart:GetAttribute("EnemyName")
		local spawns = self.Spawns[enemyName]
		if not spawns then
			spawns = {}
			self.Spawns[enemyName] = spawns
		end
		table.insert(spawns, spawnPart)
	end
end

function EnemyService:SpawnEnemy(enemyName)
	local enemyModule = script:FindFirstChild(enemyName)
	if not enemyModule then
		error(`No such enemy ${enemyName}`)
	end

	local player = game.Players:GetChildren()[1]

	-- local spawnpoint = waypoints[random:NextInteger(1, #waypoints)]
	-- if player and player.Character then
	-- 	while (spawnpoint - player.Character.Origin.Position).Magnitude < MinSpawnDistanceFromPlayer do
	-- 		spawnpoint = waypoints[random:NextInteger(1, #waypoints)]
	-- 	end
	-- end
	local spawnpoint = workspace.Level1:FindFirstChild("EnemySpawn")

	self:SpawnEnemyAt(enemyModule, spawnpoint.CFrame.Position)
end

function EnemyService:SpawnEnemyAt(enemyModule, spawnpoint)
	return require(enemyModule).new(spawnpoint)
end

function EnemyService:GameStart()
	self:SpawnEnemy("Monster", 0)
end

return EnemyService
