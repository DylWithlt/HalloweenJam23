local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Signal = require(Globals.Packages.Signal)
local Net = require(Globals.Packages.Net)

Net:RemoteEvent("Flash")
Net:RemoteEvent("UpdateProgress")

local SoundService = {}
SoundService.SoundSignal = Signal.new()

function SoundService:GameInit()
	--Prestart Code
end

local currentProgress = 0

function SoundService:GameStart()
	Net:Connect("Flash", function(player)
		local pos = player.Character.PrimaryPart.Position
		SoundService:MakeSound(pos, 2 + currentProgress * 0.5)
	end)

	Net:Connect("PlayStepSound", function(player)
		local pos = player.Character.PrimaryPart.Position
		SoundService:MakeSound(pos, 1)
	end)

	Net:Connect("UpdateProgress", function(player, progressNum) -- really bad security
		currentProgress = progressNum
	end)
	--Start Code
end

function SoundService:MakeSound(pos, value)
	-- print(`make sound: {pos} {value}`)
	SoundService.SoundSignal:Fire(pos, value)
end

return SoundService
