local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

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

local RNG = Random.new()

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local soundFolder = Globals.Assets.Enemies.Monster.Sounds

return function(entityModel, janitor)
	local aggroTweens, passiveTweens = GetLanternTweens(entityModel)

	local root = entityModel:FindFirstChild("HumanoidRootPart", true)

	local aggroSound = janitor:Add(soundFolder.Aggro:Clone())
	aggroSound.Parent = root

	local scream = janitor:Add(soundFolder.Notice:Clone())
	scream.Parent = root

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

	local aggroThresh = entityModel.Parent:GetAttribute("AggroThresh") or 1
	local aggro = entityModel.Parent:GetAttribute("SoundAggro") or 0
	-- print(`Max sound aggro: {maxSoundAggro}`)

	local lastScream = time()

	janitor:Add(
		entityModel.Parent:GetAttributeChangedSignal("SoundAggro"):Connect(function()
			-- print(`SoundAggro: {entityModel.Parent:GetAttribute("SoundAggro")}`)

			aggro = entityModel.Parent:GetAttribute("SoundAggro")

			local ui = LocalPlayer.PlayerGui.Hud.Sound.UIGradient

			local aggroPct = aggro / aggroThresh

			ui.Offset = Vector2.new(aggroPct, 0)

			if aggroPct >= 1 then
				aggroSound:Play()
			end

			if time() - lastScream > 2 then
				lastScream = time()

				if RNG:NextNumber() > 0.9 then
					scream:Play()
				end
			end
		end),
		"Disconnect"
	)

	local aggroPct = aggro / aggroThresh
	local ui = LocalPlayer.PlayerGui.Hud.Sound.UIGradient
	ui.Offset = Vector2.new(aggroPct, 0)
end
