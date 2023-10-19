local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Signal = require(Globals.Packages.Signal)

local SoundService = {}
SoundService.SoundSignal = Signal.new()

function SoundService:GameInit()
	--Prestart Code
end

function SoundService:GameStart()
	--Start Code
end

function SoundService:MakeSound(pos, value)
	SoundService.SoundSignal:Fire(pos, value)
end

return SoundService
