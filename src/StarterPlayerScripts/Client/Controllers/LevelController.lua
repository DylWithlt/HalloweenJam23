
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)
local Signal = require(Globals.Packages.Signal)

local currentLevel = nil
local LevelController = {}
LevelController.OnLevelChanged = Signal.new()

function LevelController:GetLevel()
    return currentLevel
end

function LevelController:GameInit()
    --Prestart Code
end

function LevelController:GameStart()
    --Start Code
    Net:Connect("NewLevel" ,function(level)
        currentLevel = level
        LevelController.OnLevelChanged:Fire(currentLevel)
    end)
end

return LevelController