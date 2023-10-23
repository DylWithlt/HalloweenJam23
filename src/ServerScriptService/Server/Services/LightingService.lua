local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LightingService = {}

function LightingService:GameInit()
	--Prestart Code
end

function LightingService:GameStart()
	--Start Code
	if RunService:IsStudio() then
		return
	end
	Lighting.Ambient = Color3.fromRGB(16, 16, 16)
end

return LightingService
