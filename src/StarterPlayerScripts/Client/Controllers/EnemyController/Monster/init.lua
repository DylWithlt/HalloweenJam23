local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)
local Animate = require(script.Animate)

local Enemy = {}

function Enemy.new(entityModel)
	local janitor = Janitor.new()
	Animate(entityModel, janitor)

	return {
		Janitor = janitor,
		Model = entityModel,
	}
end

return Enemy
