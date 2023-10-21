local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Net = require(Globals.Packages.Net)

local soundFolder = Globals.Assets.Enemies.Monster.Sounds

return function(entityModel, janitor)
	local root = entityModel:FindFirstChild("HumanoidRootPart", true)

	local chargeup = janitor:Add(soundFolder.Chargeup:Clone())
	chargeup.Parent = root

	local flash = janitor:Add(soundFolder.Flash:Clone())
	flash.Parent = root

	janitor:Add(
		Net:Connect("Scan", function(model)
			if model.Parent ~= entityModel.Parent then
				return
			end

			local leftLight = entityModel.EntityModel.LanternL.Bottom.Attachment.PointLight
			local rightLight = entityModel.EntityModel.LanternR.Bottom.Attachment.PointLight

			chargeup:Play()

			task.wait(1.5)

			flash:Play()

			leftLight.Brightness = 3
			leftLight.Range = 60

			rightLight.Brightness = 3
			rightLight.Range = 60

			task.wait(0.1)
			TweenService:Create(leftLight, TweenInfo.new(1), { Brightness = 0.1, Range = 12 }):Play()
			TweenService:Create(rightLight, TweenInfo.new(1), { Brightness = 0.1, Range = 12 }):Play()
		end),
		"Disconnect"
	)
end
