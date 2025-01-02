
-- All units derived from: https://create.roblox.com/docs/physics/units
-- Converting from the SI unit to the Roblox unit

local Units = {}

Units.Mass_kg = 0.0456
Units.Length_mm = 280
Units.Force_N = .163
Units.Stiffness_Ndivm = Units.Mass_kg
Units.Damping_N_sdivm = Units.Mass_kg
Units.Velocity_mdivs = 1 / (Units.Length_mm / 1000)
Units.Torque_nm = Units.Force_N / (Units.Length_mm / 1000)

return Units
