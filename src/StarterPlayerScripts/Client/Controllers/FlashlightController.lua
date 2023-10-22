local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)
local Net = require(Globals.Packages.Net)
local Signal = require(Globals.Packages.Signal)
local acts = require(Globals.Shared.Acts)

local sounds = Globals.Assets.Sounds

local LocalPlayer = Players.LocalPlayer

local FlashLightController = {}
FlashLightController.Flashed = Signal.new()

local flashJanitor = Janitor.new()

local FlashTemplate = ReplicatedStorage.Assets.FlashTemplate
local FlashTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quart)
local FlashOffset = 0.1

local function Flash(_, actionType)
	if acts:checkAct("MinigameRunning") then
		return
	end

	if actionType ~= Enum.UserInputState.Begin then
		return
	end
	flashJanitor:Cleanup()

	local flash = flashJanitor:Add(FlashTemplate:Clone())
	flash.Parent = workspace.CurrentCamera

	print("Flash")
	Net:RemoteEvent("Flash"):FireServer()
	FlashLightController.Flashed:Fire()

	flashJanitor:Add(
		RunService.RenderStepped:Connect(function()
			flash.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -FlashOffset)
		end),
		"Disconnect"
	)

	local tween = TweenService:Create(flash.SurfaceLight, FlashTweenInfo, {
		Brightness = 0,
	})

	flashJanitor:Add(tween, "Cancel")
	sounds.CameraFlash:Play()

	tween:Play()
	tween.Completed:Wait()

	flashJanitor:Cleanup()
end

local function debounce(func)
	local db = false
	return function(...)
		if db then
			return
		end
		db = true
		task.spawn(function(...)
			func(...)
			db = false
		end, ...)
	end
end

function FlashLightController:GameStart()
	--Start Code

	-- LocalPlayer.CharacterAdded:Connect(CharacterAdded)

	-- if LocalPlayer.Character then
	-- 	CharacterAdded(LocalPlayer.Character)
	-- end

	ContextActionService:BindAction("Flash", debounce(Flash), false, Enum.UserInputType.MouseButton1)
end

return FlashLightController
