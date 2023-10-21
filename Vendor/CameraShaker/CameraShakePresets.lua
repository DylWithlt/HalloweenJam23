-- Camera Shake Presets
-- Stephen Leitnick
-- February 26, 2018

--[[
	
	CameraShakePresets.Bump
	CameraShakePresets.Explosion
	CameraShakePresets.Earthquake
	CameraShakePresets.BadTrip
	CameraShakePresets.HandheldCamera
	CameraShakePresets.Vibration
	CameraShakePresets.RoughDriving
	
--]]

local CameraShakeInstance = require(script.Parent.CameraShakeInstance)

local CameraShakePresets = {

	-- A high-magnitude, short, yet smooth shake.
	-- Should happen once.
	Bump = function()
		local c = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		c.PositionInfluence = Vector3.new(0.15, 0.15, 0.15)
		c.RotationInfluence = Vector3.new(1, 1, 1)
		return c
	end,

	-- An intense and rough shake.
	-- Should happen once.
	Explosion = function()
		local c = CameraShakeInstance.new(5, 10, 0, 1.5)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(4, 1, 1)
		return c
	end,

	Damaged = function()
		local c = CameraShakeInstance.new(2, 20, 0, 0.25)
		c.PositionInfluence = Vector3.new(0.1, 0.1, 0.1)
		c.RotationInfluence = Vector3.new(5, 5, 5)
		return c
	end,

	Recoil = function()
		local c = CameraShakeInstance.new(4, 8, 0, 0.5)
		c.PositionInfluence = Vector3.new(0.2, 0, 0.2)
		c.RotationInfluence = Vector3.new(0, 0.75, 4)
		return c
	end,

	Reload = function()
		local c = CameraShakeInstance.new(0.5, 30, 0.1, 0.3)
		c.PositionInfluence = Vector3.new(0.5, 0.5, 0.1)
		c.RotationInfluence = Vector3.new(1, 1, 6)
		return c
	end,

	DoubleJump = function()
		local c = CameraShakeInstance.new(1, 30, 0, 0.4)
		c.PositionInfluence = Vector3.new(0.5, 1.5, 0.1)
		c.RotationInfluence = Vector3.new(1, 1, 10)
		return c
	end,

	Jump = function()
		local c = CameraShakeInstance.new(1, 10, 0.1, 0.2)
		c.PositionInfluence = Vector3.new(0.5, 2.5, 0)
		c.RotationInfluence = Vector3.new(1, 1.2, 1)
		return c
	end,

	Land = function()
		local c = CameraShakeInstance.new(1, 15, 0, 0.5)
		c.PositionInfluence = Vector3.new(1, 2, 0.1)
		c.RotationInfluence = Vector3.new(5, 1, 5)
		return c
	end,

	ElevatorFalling = function()
		local c = CameraShakeInstance.new(1.2, 8, 2, 10)
		c.PositionInfluence = Vector3.new(0.35, 0.35, 0.35)
		c.RotationInfluence = Vector3.new(1, 1, 4)
		return c
	end,

	-- A continuous, rough shake
	-- Sustained.
	Earthquake = function()
		local c = CameraShakeInstance.new(0.6, 3.5, 2, 10)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(1, 1, 4)
		return c
	end,

	-- A bizarre shake with a very high magnitude and low roughness.
	-- Sustained.
	BadTrip = function()
		local c = CameraShakeInstance.new(10, 0.15, 5, 10)
		c.PositionInfluence = Vector3.new(0, 0, 0.15)
		c.RotationInfluence = Vector3.new(2, 1, 4)
		return c
	end,

	-- A subtle, slow shake.
	-- Sustained.
	HandheldCamera = function()
		local c = CameraShakeInstance.new(1, 0.25, 5, 10)
		c.PositionInfluence = Vector3.new(0, 0, 0)
		c.RotationInfluence = Vector3.new(1, 0.5, 0.5)
		return c
	end,

	-- A very rough, yet low magnitude shake.
	-- Sustained.
	Vibration = function()
		local c = CameraShakeInstance.new(0.4, 20, 2, 2)
		c.PositionInfluence = Vector3.new(0, 0.15, 0)
		c.RotationInfluence = Vector3.new(1.25, 0, 4)
		return c
	end,

	-- A slightly rough, medium magnitude shake.
	-- Sustained.
	RoughDriving = function()
		local c = CameraShakeInstance.new(1, 2, 1, 1)
		c.PositionInfluence = Vector3.new(0, 0, 0)
		c.RotationInfluence = Vector3.new(1, 1, 1)
		return c
	end,

	WalkBobbing = function()
		local c = CameraShakeInstance.new(1.5, 3.5, 0.1, 1)
		c.PositionInfluence = Vector3.new(0.5, 0.5, 0)
		c.RotationInfluence = Vector3.new(0.3, 0, 1.75)
		return c
	end,
}

return setmetatable({}, {
	__index = function(t, i)
		local f = CameraShakePresets[i]
		if type(f) == "function" then
			return f()
		end
		error('No preset found with index "' .. i .. '"')
	end,
})
