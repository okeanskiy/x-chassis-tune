--[[	
	   ___  _____
	  / _ |/ ___/	Avxnturador   	| Novena						    Eniiqzz	    |
	 / __ / /__		LuaInt         	| Novena						    midmm5	    |
    /_/ |_\___/	 	Detomiks		| Base Chassis                      autopilo7   |

	                Version 1.6.4
--]]

local Tune = {}

-- It is recommended that you go to: https://www.desmos.com/calculator/lhxwlpppyh
-- to tune your vehicle's tires.

-- The default configuration is of a soft-compound sports tire.

--[[Misc]]
Tune.SaveHeatData = true -- Whether to save heat data when leaving the car
Tune.TireWearOn = true -- False sets friction to maximum
Tune.Haptics = "Controller" -- Tire slippage will activate the small motor ("Controller", "Mobile", "Both", "Off")
Tune.DirtBumps = 0 -- Aggresiveness of artificial bumps in dirt-, sand-, and snow-type surfaces (0 for none)
Tune.AmbientTemp = workspace:GetAttribute("GlobalTemperature") or 22

--[[Aesthetics]]
Tune.SmokeEffects = "All" -- Turns smoke effects on or off, "All" for viewable by everyone, "Local" for only viewable by you, "Off" for none.
Tune.TireMarkTransparencyLevels = 4 -- How many levels of transparency there are (0 for no marks)
Tune.TireMarkTransparency = 0.9 -- The transparency of the tire marks

--[[Friction]]
Tune.FMinTemp = 8 -- Minimum temperature of the front tires in celcius
Tune.FMaxTemp = 100 -- Maximum temperature of the front tires in celcius
Tune.FMaxFriction = 1.7 -- Maximum friction of the front tires
Tune.FColdStats = { 0.72, 11.7, 0.32 } -- Loss, Sharpness, Offset
Tune.FHotStats = { 1.56, 18.3, 1.05 } -- Loss, Sharpness, Offset
Tune.FDirtLoss = 0.1 -- Friction loss from dirty tires
Tune.FDirtFadeRate = 0.001 -- The rate that dirt fades
Tune.FHeating = 0.01 -- Heat gain from maximum slippage
Tune.FCooling = 0.002 -- Heat loss at no slippage
Tune.FSpeedStress = 0.04 -- Stress generated at 100 km/h

Tune.RMinTemp = 8 -- Minimum temperature of the front tires in celcius
Tune.RMaxTemp = 100 -- Maximum temperature of the front tires in celcius
Tune.RMaxFriction = 1.7 -- Maximum friction of the front tires
Tune.RColdStats = { 0.72, 11.7, 0.32 } -- Loss, Sharpness, Offset
Tune.RHotStats = { 1.56, 18.3, 1.05 } -- Loss, Sharpness, Offset
Tune.RDirtLoss = 0.1 -- Friction loss from dirty tires
Tune.RDirtFadeRate = 0.001 -- The rate that dirt fades
Tune.RHeating = 0.01 -- Heat gain from maximum slippage
Tune.RCooling = 0.002 -- Heat loss at no slippage
Tune.RSpeedStress = 0.04 -- Stress generated at 100 km/h

--[[Tire Flex]]
Tune.TireFlex = true -- Uses a separate collision to simulate tire flex
Tune.ShowTF = false -- Debug tire flex

Tune.FPressureForce = 20 -- Pressure force (no unit)
Tune.FTireThickness = 50 -- Tire sidewall thickness in milimeters
Tune.FTireWeight = 9 -- Tire weight in kg

Tune.RPressureForce = 20 -- Pressure force (no unit)
Tune.RTireThickness = 50 -- Tire sidewall thickness in milimeters
Tune.RTireWeight = 9 -- Tire weight in kg

return Tune
