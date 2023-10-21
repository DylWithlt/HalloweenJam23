local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)
local Animate = require(script.Animate)

local stepSoundsFolder = Globals.Assets.Enemies.Monster.Sounds.Steps

local Enemy = {}

function Enemy.new(entityModel)
	local janitor = Janitor.new()
	local stepped = Animate(entityModel, janitor)

	local stepSounds = {}
	local root = entityModel:FindFirstChild("HumanoidRootPart", true)
	for _, stepSound in ipairs(stepSoundsFolder:GetChildren()) do
		stepSound = stepSound:Clone()
		stepSound.Parent = root
		table.insert(stepSounds, stepSound)
	end

	janitor:Add(
		stepped:Connect(function()
			local sound = stepSounds[math.random(1, #stepSounds)]
			sound:Play()
		end),
		"Disconnect"
	)

	return {
		Janitor = janitor,
		Model = entityModel,
	}
end

return Enemy
