--[[	
	   ___  _____
	  / _ |/ ___/	Avxnturador   	| Novena						    Eniiqzz	    |
	 / __ / /__		LuaInt         	| Novena						    midmm5	    |
    /_/ |_\___/	 	Detomiks		| Base Chassis                      autopilo7   |

	                Version 1.6.4
--]]

-- All units derived from: https://create.roblox.com/docs/physics/units
-- Converting from the SI unit to the Roblox unit
local Units = {}

Units.Mass_kg = 0.0456		-- Mass in kilograms (kg)
Units.Length_mm = 280		-- Length in milimeters (mm)
Units.Force_N = .163		-- Force in Newtons (N)
Units.Stiffness_Ndivm = Units.Mass_kg		-- Stiffness in Newtons per meter (N/m)
Units.Damping_N_sdivm = Units.Mass_kg		-- Damping in Newton-seconds per meter (N*s/m)
Units.Velocity_mdivs = 1/(Units.Length_mm/1000)			-- Velocity in meters per second (m/s)
Units.Torque_nm = Units.Force_N/(Units.Length_mm/1000)	-- Torque in Newton-meters (Nm)

return Units
