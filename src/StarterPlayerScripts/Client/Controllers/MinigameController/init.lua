local module = {}

--// Services
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local PLAYERS = game:GetService("Players")
local ts = game:GetService("TweenService")
local RUN_SERVICE = game:GetService("RunService")

--// Instances
local assets = REPLICATED_STORAGE.Assets
local shared = REPLICATED_STORAGE.Shared
local sounds = assets.Sounds
local guiTemplate = assets.MinigameGui
local loadedGui

--// Modules
local presets = require(script.GamePresets)
local timer = require(shared.Timer)
local acts = require(shared.Acts)

--// Values
module.actions = {
	Spare = function(ui, autoSpare)
		print("Spare")

		module.endEncounter(ui)
	end,

	Kill = function(ui)
		print("Kill")

		local ti = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
		local ti_1 = TweenInfo.new(0.375, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)

		local entityFrame = ui.Frame.EntityFrame
		local killEffect = entityFrame.KillEffect

		killEffect.Visible = true
		killEffect.Size = UDim2.fromOffset(100, 100)

		killEffect.Position = UDim2.new(0.5, 30, 0.5, -30)

		module.tween(
			killEffect,
			ti,
			{ Position = UDim2.new(0.5, 6, 0.5, -6), Size = UDim2.fromOffset(64, 64) },
			true,
			function()
				killEffect.Position = UDim2.new(0.5, 0, 0.5, -6)
				module.tween(killEffect, ti_1, { Position = UDim2.new(0.5, 6, 0.5, -6) }, true)

				task.wait(0.35)

				module.endEncounter(ui)
			end
		)
	end,

	Run = function(ui)
		print("Run")

		module.endEncounter(ui)
	end,
}

function module.endEncounter(ui)
	local dialogFrame = ui.Frame.DialogFrame
	local buttonFrame = ui.Frame.ButtonFrame
	local entityFrame = ui.Frame.EntityFrame

	ui.Text.Dialog.DialogLabel.Text = ""

	for _ = 0, 4 do
		task.wait(0.05)
		entityFrame.Visible = not entityFrame.Visible
		buttonFrame.Visible = not buttonFrame.Visible
		dialogFrame.Visible = not dialogFrame.Visible
	end
end

local function tween(instance, tweenInfo, propertyTable)
	local newTween = ts:Create(instance, tweenInfo, propertyTable)
	newTween:Play()
	newTween.Completed:Connect(function()
		task.wait()
		newTween:Destroy()
	end)

	return newTween
end

function module.tween(instance, tweenInfo, propertyTable, yield, endingFunction, endingState)
	local createdTween

	if typeof(instance) == "table" then
		for _, v in pairs(instance) do
			createdTween = tween(v, tweenInfo, propertyTable)
		end
	else
		createdTween = tween(instance, tweenInfo, propertyTable)
	end

	if yield then
		createdTween.Completed:Wait()
		if not endingFunction then
			return createdTween
		end

		local state = createdTween.PlaybackState
		if state ~= (endingState or Enum.PlaybackState.Completed) then
			return
		end
		endingFunction()
	elseif endingFunction then
		createdTween.Completed:Connect(function(state)
			if state ~= (endingState or Enum.PlaybackState.Completed) then
				return
			end

			endingFunction()
		end)
	end

	return createdTween
end

local function loadGui(player)
	if loadedGui then
		loadedGui:Destroy()
	end

	local newGui = guiTemplate:Clone()
	newGui.Parent = player.PlayerGui
	newGui.Enabled = false
	newGui.Text.Enabled = false

	loadedGui = newGui

	return loadedGui
end

-- local function alignAsset(asset)
-- 	local p = asset.Position
-- 	local s = asset.Size
-- 	asset.Position = UDim2.new(p.X.Scale, math.round(p.X.Offset / 10) * 10, p.Y.Scale, math.round(p.Y.Offset / 10) * 10)
-- 	asset.Size = UDim2.new(s.X.Scale, math.round(s.X.Offset / 10) * 10, s.Y.Scale, math.round(s.Y.Offset / 10) * 10)
-- end

function module.displayComputerDialog(ui, dialog)
	local computerDialog = ui.Text.ComputerDialog
	computerDialog.Text = ""

	for _, text in ipairs(dialog) do
		for i = 1, string.len(text) do
			task.wait(0.05)
			computerDialog.Text = string.sub(text, 1, i)
		end

		task.wait(dialog.WaitTime)

		computerDialog.Text = ""
	end
end

function module.displayEntity(ui, entity)
	local frame = ui.Frame
	local entityFrame = frame.EntityFrame

	entityFrame.Visible = false
	entityFrame.Image = entity.Image

	for _ = 0, 4 do
		task.wait(0.025)
		entityFrame.Visible = not entityFrame.Visible
	end
end

function module.loadBackground(ui, background)
	local ti = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local backgroundImage = ui.Frame.Background

	module.tween(backgroundImage, ti, { ImageTransparency = 1 }, true, function()
		backgroundImage.Image = background
		module.tween(backgroundImage, ti, { ImageTransparency = 0 }, true)
	end)
end

function module.displayDialog(ui, entity)
	local ti = TweenInfo.new(0.35, Enum.EasingStyle.Quart)
	local dialogFrame = ui.Frame.DialogFrame
	local textFrame = ui.Text.Dialog.DialogLabel

	dialogFrame.Position = UDim2.fromOffset(0, 19)
	dialogFrame.Visible = true

	module.tween(dialogFrame, ti, { Position = UDim2.fromOffset(0, 0) }, true)
	task.wait(0.75)

	for i = 1, string.len(entity.Dialog) do
		task.wait(0.025)
		textFrame.Text = string.sub(entity.Dialog, 1, i)
	end

	task.wait(0.75)
end

function module.displayChoices(ui)
	local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quart)
	local buttonFrame = ui.Frame.ButtonFrame

	buttonFrame.Position = UDim2.fromOffset(0, 22)
	buttonFrame.Visible = true
	buttonFrame.Buttons.Visible = false

	module.tween(buttonFrame, ti, { Position = UDim2.fromOffset(0, 0) }, true)
	task.wait(0.5)
end

function module.enableChoices(ui, autoSpare)
	local buttons = ui.Buttons.Frame
	local buttonsVisual = ui.Frame.ButtonFrame.Buttons

	buttons.Visible = false
	buttonsVisual.Visible = false

	for _ = 0, 6 do
		task.wait(0.025)
		buttonsVisual.Visible = not buttonsVisual.Visible
	end

	buttons.Visible = true

	local connections = {}

	for _, button in ipairs(buttons:GetChildren()) do
		connections[#connections + 1] = button.MouseButton1Click:Connect(function()
			local action = module.actions[button.Name]
			action(ui, autoSpare)
		end)
	end
end

function module.loadGame(player, model)
	local ui = loadGui(player)
	local preset = presets[model:GetAttribute("PresetName")]

	ui.Adornee = model.PrimaryPart
	ui.Text.Adornee = ui.Adornee
	ui.Buttons.Adornee = ui.Adornee

	local frame = ui.Frame
	frame.Bars.Size = UDim2.fromScale(1, 0)

	module.runGame(ui, preset, model)
end

function module.runGame(ui, preset, model)
	sounds.ComputerAmbience:Play()

	model.Screen.Transparency = 1
	model.Display.Transparency = 1

	local frame = ui.Frame
	local entityFrame = frame.EntityFrame

	local bti = TweenInfo.new(0.15, Enum.EasingStyle.Linear)

	local breathTi = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, math.huge, true)

	ui.Enabled = true
	ui.Text.Enabled = true
	ui.Buttons.Enabled = true

	ui.Buttons.Frame.Visible = false

	module.tween(entityFrame, breathTi, { Position = UDim2.new(0.5, 0, 0.5, 3) }, false)

	--module.displayComputerDialog(ui, preset.Intro)

	module.tween(frame.Bars, bti, { Size = UDim2.fromScale(1, 1) })

	for _, section in ipairs(preset.Progression) do
		local entity = preset.Entities[section.Entity]
		local setting = preset.Backgrounds[section.Setting]

		module.loadBackground(ui, setting)
		module.displayEntity(ui, entity)

		task.wait(1)
		module.displayChoices(ui)
		module.displayDialog(ui, entity)
		module.enableChoices(ui)

		task.wait(1000000)
	end
end

--// Main //--
return module
