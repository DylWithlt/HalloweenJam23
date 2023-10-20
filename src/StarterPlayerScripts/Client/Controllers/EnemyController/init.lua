local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local EnemyController = {}
EnemyController.WrappedEnemies = {}

local function SetupEnemy(humanoidModel, entityModel)
	humanoidModel.HumanoidRootPart.Waist.Part1 = entityModel.Waist
	entityModel.Parent = humanoidModel
end

function EnemyController:GameStart()
	for _, enemyModel in ipairs(CollectionService:GetTagged("Enemy")) do
		self:WrapEnemy(enemyModel)
	end

	CollectionService:GetInstanceAddedSignal("Enemy"):Connect(function(enemyModel)
		self:WrapEnemy(enemyModel)
	end)

	CollectionService:GetInstanceRemovedSignal("Enemy"):Connect(function(enemyModel)
		self:CleanupEnemy(enemyModel)
	end)
end

function EnemyController:WrapEnemy(humanoidModel)
	if not humanoidModel:IsDescendantOf(workspace) then
		return
	end

	local enemyType = humanoidModel:GetAttribute("EnemyType")
	local enemyModule = script:FindFirstChild(enemyType)
	if not enemyModule then
		warn(`No such enemy {enemyType}`)
		return
	end

	SetupEnemy(humanoidModel, Globals.Assets.Enemies[enemyType].EntityModel:Clone())
	self.WrappedEnemies[humanoidModel] = require(enemyModule).new(humanoidModel)
end

function EnemyController:CleanupEnemy(humanoidModel)
	local wrappedEnemy = self.WrappedEnemies[humanoidModel]
	if not wrappedEnemy then
		return
	end
	wrappedEnemy.Janitor:Destroy()
	self.WrappedEnemies[humanoidModel] = nil
end

return EnemyController
