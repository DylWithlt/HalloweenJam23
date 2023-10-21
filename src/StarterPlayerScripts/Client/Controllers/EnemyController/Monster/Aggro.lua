local TweenService = game:GetService("TweenService")

local function GetLanternTweens(entityModel)
	local lanterns = {
		entityModel:FindFirstChild("LanternL", true),
		entityModel:FindFirstChild("LanternR", true),
	}

	local aggroTweens, passiveTweens = {}, {}
	for _, lantern in ipairs(lanterns) do
		local light = lantern:FindFirstChildWhichIsA("Light", true)
		local neon = lantern.Neon

		local tweenInfo = TweenInfo.new(0.2)

		table.insert(
			aggroTweens,
			TweenService:Create(light, tweenInfo, {
				Color = Color3.new(1, 0, 0),
			})
		)

		table.insert(
			aggroTweens,
			TweenService:Create(neon, tweenInfo, {
				Color = Color3.new(1, 0, 0),
			})
		)

		table.insert(
			passiveTweens,
			TweenService:Create(light, tweenInfo, {
				Color = Color3.new(1, 1, 1),
			})
		)

		table.insert(
			passiveTweens,
			TweenService:Create(neon, tweenInfo, {
				Color = Color3.new(1, 1, 1),
			})
		)
	end

	return aggroTweens, passiveTweens
end

local function CallTweens(tweens)
	for _, tween in ipairs(tweens) do
		tween:Play()
	end
end

return function(entityModel, janitor)
	local aggroTweens, passiveTweens = GetLanternTweens(entityModel)

	if entityModel:GetAttribute("Aggroed") then
		CallTweens(aggroTweens)
	end

	janitor:Add(
		entityModel:GetAttributeChangedSignal("Aggroed"):Connect(function()
			print("!!!!!!")
			local isAggro = entityModel:GetAttribute("Aggroed")
			CallTweens(if isAggro then aggroTweens else passiveTweens)
		end),
		"Disconnect"
	)
end
