local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)
local Animate = require(script.Animate)
local Flicker = require(script.Flicker)
local Aggro = require(script.Aggro)
local Scan = require(script.Scan)

local stepSoundsFolder = Globals.Assets.Enemies.Monster.Sounds.Steps

local Enemy = {}

function Enemy:GameInit()
	Enemy.CameraController = require(Globals.Client.Controllers.CameraController)
end

function Enemy.new(entityModel)
	local janitor = Janitor.new()
	Flicker(entityModel, janitor)
	Aggro(entityModel, janitor)
	Scan(entityModel, janitor)
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
			Enemy.CameraController:ShakeStep(root.Position)
		end),
		"Disconnect"
	)

	return {
		Janitor = janitor,
		Model = entityModel,
	}
end

return Enemy
