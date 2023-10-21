local module = { endingResult = {} }

--// Services
local SoundService = game:GetService("SoundService")
local ts = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Globals = require(ReplicatedStorage.Shared.Globals)

--// Instances
local assets = Globals.Assets
local shared = Globals.Shared
local sounds = assets.Sounds
local guiTemplate = assets:FindFirstChild("MinigameGui")
local loadedGui

local player = Players.LocalPlayer

local camera = workspace.CurrentCamera

--// Modules
local presets = require(script.GamePresets)
local timer = require(shared.Timer)
local acts = require(shared.Acts)
local util = require(shared.Util)

--// Values
local rng = Random.new()
local logCamera

--// Functions
module.actions = {
	Spare = function(ui, autoSpare)
		if not autoSpare and not module.showSpareQTE(ui) then
			return 0
		end

		util.PlaySound(sounds.SpareEffect, script)

		local ti = TweenInfo.new(0.9, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local ti_0 = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		local ti_1 = TweenInfo.new(0.375, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)

		local entityFrame = ui.Frame.EntityFrame
		local effect = entityFrame.SpareEffect

		effect.Visible = true
		effect.Size = UDim2.fromOffset(20, 20)
		effect.Rotation = 25

		effect.Position = UDim2.new(0.5, -40, 0.5, 6)

		task.wait(0.15)

		util.tween(
			effect,
			ti,
			{ Position = UDim2.new(0.5, -2, 0.5, -12), Size = UDim2.fromOffset(100, 100), Rotation = 0 },
			true
		)
		task.wait(0.1)
		util.tween(effect, ti_0, { Position = UDim2.new(0.5, 6, 0.5, -6), Size = UDim2.fromOffset(64, 64) }, true)

		effect.Position = UDim2.new(0.5, 0, 0.5, -6)
		util.tween(effect, ti_1, { Position = UDim2.new(0.5, 6, 0.5, -6) }, true)

		task.wait(0.35)

		module.endEncounter(ui)
		effect.Visible = false

		return 1
	end,

	Kill = function(ui)
		local ti = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
		local ti_1 = TweenInfo.new(0.375, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)

		local entityFrame = ui.Frame.EntityFrame
		local effect = entityFrame.KillEffect

		effect.Visible = true
		effect.Size = UDim2.fromOffset(100, 100)

		effect.Position = UDim2.new(0.5, 30, 0.5, -30)

		util.tween(
			effect,
			ti,
			{ Position = UDim2.new(0.5, 6, 0.5, -6), Size = UDim2.fromOffset(64, 64) },
			true,
			function()
				util.PlaySound(sounds.Kill, script)
				effect.Position = UDim2.new(0.5, 0, 0.5, -6)
				util.tween(effect, ti_1, { Position = UDim2.new(0.5, 6, 0.5, -6) }, true)

				task.wait(0.35)

				module.endEncounter(ui)
				effect.Visible = false
			end
		)

		return 2
	end,

	Run = function(ui)
		module.endEncounter(ui)

		return 3
	end,
}

local function compareTables(table1, table2)
	for i, v in table1 do
		if table2[i] ~= v then
			return false
		end
	end

	return true
end

function module.endGame(ui, endDialog, model)
	game.SoundService.Monster.Volume = 0.5
	sounds.ComputerAmbience:Stop()

	local frame = ui.Frame
	local bti = TweenInfo.new(0.15, Enum.EasingStyle.Linear)
	local ti = TweenInfo.new(1, Enum.EasingStyle.Quart)

	frame.Bars.Visible = true

	util.tween(frame.Bars, bti, { Size = UDim2.fromScale(1, 0) })

	task.wait(1)
	module.displayComputerDialog(ui, endDialog)

	model.Display.Transparency = 1
	model.Display.Attachment.PointLight.Enabled = false
	model.Display.SurfaceLight.Enabled = false
	model.Screen.Transparency = 0

	sounds.Button:Play()
	util.tween(camera, ti, { CFrame = logCamera }, true)
	camera.CameraType = Enum.CameraType.Custom
	module.CameraController:Enable()
end

function module.endEncounter(ui)
	local dialogFrame = ui.Frame.DialogFrame
	local buttonFrame = ui.Frame.ButtonFrame
	local entityFrame = ui.Frame.EntityFrame

	ui.Text.Dialog.DialogLabel.Text = ""

	util.PlaySound(sounds.Next, script)

	for _ = 0, 6 do
		task.wait(0.02)
		entityFrame.Visible = not entityFrame.Visible
		buttonFrame.Visible = not buttonFrame.Visible
		dialogFrame.Visible = not dialogFrame.Visible
	end
end

function module.showSpareQTE(ui)
	local qte = ui.Frame.SpareQTE
	local hitBar = qte.HitBar
	local bar = qte.Bar

	local ti = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, math.huge, true)
	local result
	local onInput

	qte.Visible = true
	hitBar.Position = UDim2.fromScale(0, 0.5)

	local moveTween = util.tween(hitBar, ti, { Position = UDim2.fromScale(1, 0.5) })

	onInput = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if input.KeyCode ~= Enum.KeyCode.E or gameProcessedEvent then
			return
		end

		local x = hitBar.AbsolutePosition.X
		local min = 64 - bar.Size.X.Offset / 2
		local max = 64 + bar.Size.X.Offset / 2

		if x > min and x < max then
			result = true
		else
			result = false
		end

		onInput:Disconnect()
	end)

	repeat
		task.wait()
	until result ~= nil

	moveTween:Destroy()
	qte.Visible = false

	if result then
		util.PlaySound(sounds.Spare, script)
		task.wait(0.2)
	else
		util.PlaySound(sounds.Death, script)
		task.wait(1.25)
	end

	return result
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

function module.displayComputerDialog(ui, dialog)
	local computerDialog = ui.Text.ComputerDialog
	computerDialog.Text = ""

	for _, text in ipairs(dialog) do
		for i = 1, string.len(text) do
			task.wait(0.05)
			computerDialog.Text = string.sub(text, 1, i)
			util.PlaySound(sounds.PC, script)
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

	util.PlaySound(sounds.Appear, script)

	for _ = 0, 4 do
		task.wait(0.025)
		entityFrame.Visible = not entityFrame.Visible
	end
end

function module.loadBackground(ui, background)
	local ti = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local backgroundImage = ui.Frame.Background

	util.tween(backgroundImage, ti, { ImageTransparency = 1 }, true, function()
		backgroundImage.Image = background
		util.tween(backgroundImage, ti, { ImageTransparency = 0 }, true)
	end)
end

function module.displayDialog(ui, entity)
	local ti = TweenInfo.new(0.35, Enum.EasingStyle.Quart)
	local dialogFrame = ui.Frame.DialogFrame
	local textFrame = ui.Text.Dialog.DialogLabel

	dialogFrame.Position = UDim2.fromOffset(0, 19)
	dialogFrame.Visible = true

	util.tween(dialogFrame, ti, { Position = UDim2.fromOffset(0, 0) }, true)
	task.wait(0.75)

	sounds.Voice.SoundId = entity["Voice"] or ""
	for i = 1, string.len(entity.Dialog) do
		task.wait(0.025)
		textFrame.Text = string.sub(entity.Dialog, 1, i)
		util.PlaySound(sounds.Voice, script)
	end

	task.wait(0.75)
end

function module.displayChoices(ui)
	local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quart)
	local buttonFrame = ui.Frame.ButtonFrame

	buttonFrame.Position = UDim2.fromOffset(0, 22)
	buttonFrame.Visible = true
	buttonFrame.Buttons.Visible = false

	util.tween(buttonFrame, ti, { Position = UDim2.fromOffset(0, 0) }, true)
	task.wait(0.5)
end

function module.enableChoices(ui, autoSpare)
	local buttons = ui.Buttons.Frame
	local buttonsVisual = ui.Frame.ButtonFrame.Buttons

	buttons.Visible = false
	buttonsVisual.Visible = false

	if autoSpare then
		buttonsVisual.Spare.Image = "rbxassetid://15106755313"
	else
		buttonsVisual.Spare.Image = "rbxassetid://15089599254"
	end

	for _ = 0, 6 do
		task.wait(0.025)
		buttonsVisual.Visible = not buttonsVisual.Visible
	end

	buttons.Visible = true

	local connections = {}
	local result

	for _, button in ipairs(buttons:GetChildren()) do
		connections[#connections + 1] = button.MouseButton1Click:Connect(function()
			for _, connection in ipairs(connections) do
				connection:Disconnect()
			end

			util.PlaySound(sounds.Select, script)

			local action = module.actions[button.Name]
			result = action(ui, autoSpare)
			print(result)
		end)
	end

	repeat
		task.wait()
	until result ~= nil

	return result
end

function module.loadGame(player, model)
	local ui = loadGui(player)
	local preset = presets[model:GetAttribute("PresetName")]

	ui.Adornee = model.PrimaryPart
	ui.Text.Adornee = ui.Adornee
	ui.Buttons.Adornee = ui.Adornee

	local frame = ui.Frame
	frame.Bars.Size = UDim2.fromScale(1, 0)

	table.insert(module.endingResult, module.runGame(ui, preset, model))

	local hud = player.PlayerGui:FindFirstChild("Hud")

	hud.ComputersFound.Text = #module.endingResult .. "/" .. 3
end

function module.runGame(ui, preset, model)
	game.SoundService.Monster.Volume = 0

	sounds.ComputerAmbience:Play()
	sounds.Button:Play()
	sounds.ScreenOn:Play()

	model.Screen.Transparency = 1
	model.Display.Transparency = 1

	local frame = ui.Frame
	local entityFrame = frame.EntityFrame

	local bti = TweenInfo.new(0.15, Enum.EasingStyle.Linear)
	local fadeTi = TweenInfo.new(1.5, Enum.EasingStyle.Linear)

	local breathTi = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, math.huge, true)

	ui.Enabled = true
	ui.Text.Enabled = true
	ui.Buttons.Enabled = true

	ui.Frame.Bars.Visible = true
	ui.Buttons.Frame.Visible = false

	util.tween(entityFrame, breathTi, { Position = UDim2.new(0.5, 0, 0.5, 3) }, false)
	util.tween(frame.Fade, fadeTi, { BackgroundTransparency = 1 }, true)

	module.displayComputerDialog(ui, preset.Intro)

	util.tween(frame.Bars, bti, { Size = UDim2.fromScale(1, 1) })

	local results = {}

	for _, section in ipairs(preset.Progression) do
		local entity = preset.Entities[section.Entity]
		local setting = preset.Backgrounds[section.Setting]

		module.loadBackground(ui, setting)
		module.displayEntity(ui, entity)

		task.wait(1)
		module.displayChoices(ui)
		module.displayDialog(ui, entity)

		local choiceResult = module.enableChoices(ui, entity["Higher"])
		table.insert(results, choiceResult)

		task.wait(0.1)

		if choiceResult == 0 then
			break
		end
	end

	local endDialog
	local endingResult = 5

	if table.find(results, 0) then -- Weakness
		endDialog = preset.Weakness
		endingResult = 5
	elseif compareTables(results, preset.AcceptanceResult) then -- Acceptance
		endDialog = preset.Acceptance
		endingResult = 1
	elseif compareTables(results, table.create(#results, 2)) then -- hate
		endDialog = preset.Hate
		endingResult = 3
	elseif compareTables(results, table.create(#results, 1)) then -- Love
		endDialog = preset.Love
		endingResult = 4
	else -- Denial
		endDialog = preset.Denial
		endingResult = 2
	end

	module.endGame(ui, endDialog, model)
	return endingResult
end

local function setCamera(computer)
	logCamera = camera.CFrame
	local goal = computer:GetPivot() * CFrame.new(0, 0, 1.4)

	local ti = TweenInfo.new(1, Enum.EasingStyle.Quart)

	module.CameraController:Disable()
	camera.CameraType = Enum.CameraType.Scriptable
	util.tween(camera, ti, { CFrame = goal })
end

function module.ApplyMonitorPrompts()
	repeat
		task.wait()
	until #workspace.Computers:GetChildren() >= 3

	for i, computer in ipairs(workspace.Computers:GetChildren()) do
		print(i)
		local newPrompt = Instance.new("ProximityPrompt")
		newPrompt.Parent = computer.PrimaryPart

		newPrompt.Triggered:Connect(function(playerWhoTriggered)
			task.spawn(function()
				acts:createTempAct("MinigameRunning", module.loadGame, nil, playerWhoTriggered, computer)
			end)

			newPrompt.Enabled = false
			setCamera(computer)
		end)
	end
end

--// Main //--
function module:GameInit()
	module.CameraController = require(Globals.Client.Controllers.CameraController)
	task.spawn(module.ApplyMonitorPrompts)
end

player.CharacterAdded:Connect(function(character)
	if loadedGui then
		loadedGui:Destroy()
	end

	for _, computer in ipairs(workspace.Computers:GetChildren()) do
		computer.Display.Transparency = 0
		computer.Display.SurfaceLight.Enabled = false
		computer.Screen.Transparency = 0

		local p = computer.PrimaryPart:FindFirstChild("ProximityPrompt")
		if not p then
			continue
		end
		p.Enabled = true
	end

	module.endingResult = {}

	local hud = player.PlayerGui:FindFirstChild("Hud")
	hud.ComputersFound.Text = #module.endingResult .. "/" .. 3
end)

return module
