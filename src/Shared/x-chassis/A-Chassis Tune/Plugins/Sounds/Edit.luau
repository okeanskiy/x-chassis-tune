--[[	
	   ___  _____
	  / _ |/ ___/	Avxnturador   	| Novena						    Eniiqzz	    |
	 / __ / /__		LuaInt         	| Novena						    midmm5	    |
    /_/ |_\___/	 	Adhamkhedrhuman	| Plate Productions				    autopilo7   |
	    			Detomiks		| Base Chassis                      

	                Version 1.6.4
--]]
local module = {}
local _Tune = require(script.Parent.Parent.Car.Value["A-Chassis Tune"])

module.EngineSounds = {
	--[[To add new engine sounds, create a table and place it in here with this format:
	{
		name			= string,		-- Sound name
		id				= number,		-- Sound ID
		vol				= number,		-- Sound base volume
		throtVolMult	= number,		-- Throttle multiplier
		revVolMult		= number,		-- RPM multiplier
		rollOffMax		= number,
		rollOffMin		= number,
		eq				= table {HighGain, MidGain, LowGain},	-- Engine equalizer
		decelEq			= table {HighGain, MidGain, LowGain},	-- Engine decel equalizer
		vvlEq			= table {HighGain, MidGain, LowGain},	-- VVL equalizer
		reverb			= table {Enabled, Decay time, # reflections, surface roughness, original sound volume, echo sound volume}	-- Reverb
		pit				= number,		-- Base engine playback speed
		rev				= number,		-- Engine playback speed at redline
		throtPitMult	= number,
		
		fadeStart		= table {Start Fade In, Finish Fade In},		-- First value is when the sound starts to fade in, second value is when the sound finishes fading (in RPM)
		fadeEnd			= table {Finish Fade Out, Fade Out Time},		-- First value is when the sound finishes to fading out, second value is  how long the sound fades out (in RPM)
		
		parent			= string (Name Of Parent)		-- If not found in car.Body, will default to DriveSeat
	}
	]]
	{
		name = "Exhaust", -- Sound name
		id = 5937167081, -- Sound ID
		vol = 0.1, -- Sound base volume
		throtVolMult = 6, -- Throttle multiplier
		revVolMult = 1.5, -- RPM multiplier
		rollOffMax = 100,
		rollOffMin = 10,
		eq = { -80, 0, 10 },
		decelEq = { 55, 0, -5 },
		vvlEq = { 80, 10, -10 },
		reverb = { true, 0.1, 0.4, 1, 0, -40 },
		distortion = 0.2, -- Sound distortion at redline with full throttle
		decelDistortion = 0, -- Sound distortion at redline with no throttle
		pit = 0, -- Base engine playback speed
		rev = 1.4, -- Engine playback speed at redline
		throtPitMult = 1.1,

		fadeStart = { 0, 1 }, -- First value is when the sound starts to fade in, second value is when the sound finishes fading (in RPM)
		fadeEnd = { 16001, 1 }, -- First value is when the sound finishes to fading out, second value is how long the sound fades out (in RPM)

		parent = "Exhaust", -- If not found in car.Body, will default to DriveSeat
	},
	{
		name = "Engine",
		id = 6002661882,
		vol = 0.1,
		throtVolMult = 3,
		revVolMult = 1.5,
		rollOffMax = 100,
		rollOffMin = 10,
		eq = { -80, 5, 10 },
		decelEq = { 55, 0, -5 },
		vvlEq = { 0, 10, 0 },
		reverb = { false, 0.1, 0.2, 1, 0, -40 },
		distortion = 0.1,
		decelDistortion = 0,
		pit = 0,
		rev = 1,
		throtPitMult = 1.1,

		fadeStart = { 3000, 3000 },
		fadeEnd = { 16001, 1 },

		parent = "Engine",
	},
	{
		name = "Idle",
		id = 5226685480,
		vol = 1,
		throtVolMult = 1,
		revVolMult = 1,
		rollOffMax = 100,
		rollOffMin = 10,
		eq = { -80, 5, 10 },
		decelEq = { 55, 0, -5 },
		vvlEq = { 0, 10, 0 },
		reverb = { true, 0.1, 0.2, 1, 0, -40 },
		distortion = 0.1,
		decelDistortion = 0,
		pit = 1,
		rev = 1,
		throtPitMult = 1.1,

		fadeStart = { _Tune.IdleRPM - 400, 200 },
		fadeEnd = { _Tune.IdleRPM + 200, 200 },

		parent = "Exhaust",
	},
}

module.TurboSounds = {
	--Do the same for the turbo sounds, but with this format
	{
		name = "Turbo",
		id = 240323039,
		vol = 0.01, -- Per PSI
		pitch = 1, -- Base Pitch
		pitchIncrease = 0.05, -- Per PSI
		rollOffMax = 30,
		rollOffMin = 10,
		-- The parent for forced induction is "Engine"
	},

	{
		name = "Turbo2",
		id = 1033010834,
		vol = 0.03, -- Per PSI
		pitch = 0.2, -- Base Pitch
		pitchIncrease = 0.5, -- Per PSI
		rollOffMax = 50,
		rollOffMin = 10,
	},
}

module.SuperSounds = {
	--same
	{
		name = "Supercharger",
		id = 404779487,
		vol = 0.01, -- Per PSI
		pitch = 0.8, -- Base pitch
		pitchIncrease = 0.05, -- Per PSI
		rollOffMax = 50,
		rollOffMin = 10,
	},
}

module.BovSounds = {
	--top text
	{
		name = "BOV",
		id = 3568930062,
		sensitivity = 1,
		vol = 0.025, -- Per PSI
		pitch = 0.7, -- Base pitch
		pitchIncrease = 0.05, -- Per PSI
		rollOffMax = 50,
		rollOffMin = 10,
	},
}

module.TransmissionSounds = {
	-- The parent for transmission sounds is "Transmission"
	{
		name = "Trans",
		id = 406864489,
		vol = 0.4,
		clutchVol = 0.1, -- Volume when the clutch is fully pressed
		offVol = 0.1,
		pitch = 1.3, -- At 300 SPS
		rollOffMax = 50,
		rollOffMin = 10,
		gear = { 1, 2, 3, 4, 5, 6 }, -- Gears that this transmission sound is enabled. If not enabled, the volume will go to "offVol"
	},
	{
		name = "Reverse",
		id = 404779487,
		vol = 1.2,
		clutchVol = 0.1,
		offVol = 0,
		pitch = 6,
		rollOffMax = 50,
		rollOffMin = 10,
		gear = { -1 },
	},
}

module.FE = true

return module
