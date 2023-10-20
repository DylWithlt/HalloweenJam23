local Lighting = game:GetService("Lighting")

local LightingService = {}

function LightingService:GameInit()
	--Prestart Code
end

function LightingService:GameStart()
	--Start Code
	Lighting.Ambient = Color3.fromRGB(16, 16, 16)
end

return LightingService
