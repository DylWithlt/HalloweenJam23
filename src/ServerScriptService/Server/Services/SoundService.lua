local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Signal = require(Globals.Packages.Signal)
local Net = require(Globals.Packages.Net)

Net:RemoteEvent("Flash")

local SoundService = {}
SoundService.SoundSignal = Signal.new()

function SoundService:GameInit()
	--Prestart Code
end

function SoundService:GameStart()
	Net:Connect("Flash", function(player)
		print("Flash")
		local pos = player.Character:GetPivot().Position
		SoundService:MakeSound(pos, 2)
	end)

	Net:Connect("PlayStepSound", function(player)
		local pos = player.Character:GetPivot().Position
		SoundService:MakeSound(pos, 1)
	end)
	--Start Code
end

function SoundService:MakeSound(pos, value)
	-- print(`make sound: {pos} {value}`)
	SoundService.SoundSignal:Fire(pos, value)
end

return SoundService
