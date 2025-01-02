--[[	
	   ___  _____
	  / _ |/ ___/	Avxnturador   	| Novena						    Eniiqzz	    |
	 / __ / /__		LuaInt         	| Novena						    midmm5	    |
    /_/ |_\___/	 	Detomiks		| Base Chassis                      autopilo7   |

	                Version 1.6.4
--]]

local Tune = {}
do	
--[[Misc]]
	Tune.LoadDelay		= 2			    -- Delay before initializing chassis (in seconds)
	Tune.AutoStart		= true		    -- Set to false if using manual ignition plugin
	Tune.AutoFlip		= true		    -- Set to false if using manual flip plugin

--[[Wheel Alignment]]
	--[Values are in degrees]
	Tune.FCamber		= -2
	Tune.RCamber		= -1.5
	Tune.FCaster		= 0
	Tune.RCaster		= 0
	Tune.FToe			= 0
	Tune.RToe			= 0

--[[Weight and CG]]
	Tune.Weight			= 1360		-- Total weight (in kilograms, under Earth's gravity, including wheel and suspension weight)
	Tune.WeightBSize	= {			-- Size of weight brick, dimensions of your car in milimeters
		--[[Width]]			1802	,
		--[[Height]]		1408	,
		--[[Length]]		4551	}
	Tune.WeightDist		= 52		-- Weight distribution (0 - on rear wheels, 100 - on front wheels, can be <0 or >100)
	Tune.CGHeight		= .1		-- Center of gravity height (studs relative to average of all wheels)
	Tune.WBVisible		= false		-- Makes the weight brick visible
	
	Tune.GravComp		= 35		-- Desired gravitational force in Roblox units. (Set to 0 to use workspace.Gravity instead)

	--Unsprung Weight
	Tune.FWheelWeight	= 23		-- Front Wheel Weight in kg
	Tune.RWheelWeight	= 24		-- Rear Wheel Weight in kg

	Tune.AxleSize		= 1.5		-- Size of structural members (larger = MORE STABLE / carry more weight)
	Tune.AxleDensity	= .1		-- Density of structural members

	Tune.CustomSuspensionDensity	= 0	-- Density of suspension joints, only applies to custom suspension

--[[Suspension]]
	Tune.SuspensionEnabled	= true		-- Enables suspension, true or false
	--*Suspension may require stiffer settings on higher gravities
	
	--Front Strut
	Tune.FSusStiffness	= 14.1		-- Spring Force in kgf/mm 
	Tune.FSusDamping	= 5000		-- Spring Damping in kg/s
	Tune.FSusLength		= 1.2		-- Base spring height (in studs)
	Tune.FPreCompress	= .2		-- Adds to base spring height (in studs)
	Tune.FExtensionLim	= .5		-- Max Extension Travel (in studs)
	Tune.FCompressLim	= .3		-- Max Compression Travel (in studs)
	Tune.FSwayBar		= 4.5		-- Sway Bar Force in kgf/mm (more = less roll)

	--Rear Strut
	Tune.RSusStiffness	= 14.5		-- Spring Force in kgf/mm
	Tune.RSusDamping	= 5400		-- Spring Damping in kg/s
	Tune.RSusLength		= 1.2		-- Base spring height (in studs)
	Tune.RPreCompress	= .2		-- Adds to base spring height (in studs)
	Tune.RExtensionLim	= .5		-- Max Extension Travel (in studs)
	Tune.RCompressLim	= .3		-- Max Compression Travel (in studs)
	Tune.RSwayBar		= 4.2		-- Sway Bar Force in kgf/mm (more = less roll)

	--Old Suspension Settings, applies if there is no SuspensionGeometry for the respective wheel
	Tune.FSusAngle		= 80		-- Spring Angle (degrees from horizontal)
	Tune.FWsBoneLen		= 4			-- Wishbone Length
	Tune.FWsBoneAngle	= 0			-- Wishbone angle (degrees from horizontal)
	Tune.FAnchorOffset	= {			-- Suspension anchor point offset (relative to center of wheel)
		--[[Lateral]]		-.4		,	-- positive = outward
		--[[Vertical]]		-.5		,	-- positive = upward
		--[[Forward]]		0		}	-- positive = forward
	Tune.FSpringOffset	= {			-- Suspension anchor point offset (relative to ABOVE anchor offset) (Avxnturador)
		--[[Lateral]]		0		,	-- positive = outward 
		--[[Vertical]]		0		,	-- positive = upward
		--[[Forward]]		0		}	-- positive = forward

	Tune.RSusAngle		= 80		-- Spring Angle (degrees from horizontal)
	Tune.RWsBoneLen		= 4			-- Wishbone Length
	Tune.RWsBoneAngle	= 0			-- Wishbone angle (degrees from horizontal)
	Tune.RAnchorOffset	= {			-- Suspension anchor point offset (relative to center of wheel)
		--[[Lateral]]		-.4		,	-- positive = outward
		--[[Vertical]]		-.5		,	-- positive = upward
		--[[Forward]]		0		}	-- positive = forward
	Tune.RSpringOffset	= {			-- Suspension anchor point offset (relative to ABOVE anchor offset) (Avxnturador)
		--[[Lateral]]		0		,	-- positive = outward 
		--[[Vertical]]		0		,	-- positive = upward
		--[[Forward]]		0		}	-- positive = forward

	--Aesthetics	
	Tune.SusVisible		= true			-- Suspension Visible
	Tune.SpringsVisible	= true			-- Springs Visible
	Tune.SusRadius		= .2			-- Spring Coil Radius
	Tune.SusThickness	= .1			-- Spring Coil Thickness
	Tune.SusColor		= "Bright red"	-- Spring Color [BrickColor]
	Tune.SusCoilCount	= 6				-- Spring Coil Count

--[[Wheel Stabilizer Gyro]]
	Tune.FGyroDampening = 50		-- Front Suspension Gyro Dampening
	Tune.FGyroDamp		= 0		-- Front Wheel Non-Axial Dampening
	Tune.RGyroDamp		= 0		-- Rear Wheel Non-Axial Dampening
	Tune.RGyroDampening = 50		-- Rear Suspension Gyro Dampening
	
--[[Steering]]
	-- Front wheel steering
	Tune.SteerRatio			= 15/1		-- Steering ratio of your steering rack, google it for your car
	Tune.LockToLock			= 2.6		-- Number of turns of the steering wheel lock to lock, google it for your car
	Tune.Ackerman			= 1.1		-- If you don't know what it is don't touch it, ranges from .7 to 1.2

	Tune.SteerSpeed			= .055		-- Steering increment per tick (in degrees)
	Tune.ReturnSpeed		= .1		-- Steering increment per tick (in degrees)
	Tune.ContlrSteerSpeed	= 0			-- Controller version of steer speed (0 or less to be the same as SteerSpeed)
	Tune.ContlrReturnSpeed	= 0			-- Controller version of return speed (0 or less to be the same as ReturnSpeed)
	Tune.MSteerUsesContlr	= true		-- Set to false if you want mouse steer to use the keyboard steer speeds instead of controller speeds.
	
	Tune.SteerSpeedDecay	= 300		-- Speed of gradient cutoff of steering speed (in km/h)
	Tune.MinSteerSpeed		= 50		-- Minimum steering speed at max decay (in percent)
	
	Tune.SteerDecay			= 300		-- Speed of gradient cutoff (in km/h)
	Tune.MinSteer			= 25		-- Minimum steering angle at max steer decay (in percent)
	Tune.MSteerExp			= 1			-- Mouse steering exponential degree

	-- Four Wheel Steering (LuaInt)
	Tune.FWSteer			= 'None'	-- Static, Speed, Both, or None
	Tune.RSteerOuter		= 10		-- Outer rear wheel steering angle (in degrees)
	Tune.RSteerInner		= 10		-- Inner rear wheel steering angle (in degrees)
	Tune.RSteerSpeed		= 60		-- Speed at which 4WS fully activates (Speed), deactivates (Static), or transition begins (Both) (km/h)
	Tune.RSteerDecay		= 330		-- Speed of gradient cutoff (in km/h)

	-- Steer Tuning
	Tune.SteerD				= 1000		-- Steering Dampening
	Tune.SteerMaxTorque		= 50000		-- Steering Force
	Tune.SteerP				= 100000	-- Steering Aggressiveness

--[[Engine (Detomiks)]]

	-- *USE THE GRAPH BELOW TO PROPERLY TUNE THE ENGINE.*
	-- https://www.desmos.com/calculator/tbcwzlkq9l

	-- Naturally Aspirated Engine
	Tune.Engine 		= true		

		Tune.PeakTorque				= 208		-- The maximum amount of torque the engine makes in lb-ft.
		Tune.PeakTorqueRPM			= 4480		-- When the engine reaches PeakTorque in RPM.

		Tune.IdleRPM				= 1200		-- The engine's idle RPM.
		Tune.IdleTorque				= 89		-- How much torque the engine makes at idle.
		Tune.IdleTorqueCurve		= 0.274		-- The shape of the torque curve between idle and PeakRPM.

		Tune.Redline				= 9000		-- The maximum RPM.
		Tune.RedlineTorque			= 169		-- How much torque the engine makes at redline.
		Tune.RedlineTorqueCurve		= 0.42		-- The shape of the torque curve between PeakRPM and redline.

		Tune.HPLimit				= 400		-- The horsepower limit of the engine (set to 0 to turn off).

	-- Electric Engine
	Tune.Electric		= false

		Tune.E_Torque				= 1080		-- The amount of electric torque in lb-ft.
		Tune.E_TransitionRPM		= 4800		-- When the torque begins decaying.

		Tune.E_Redline				= 20000		-- The maximum RPM of the electric motor.
		Tune.E_RedlineTorque		= 214		-- How much torque is made at the maximum RPM.

		Tune.E_Curve				= 0.802		-- The shape of the curve between TransitionRPM and the redline.

	-- Turbocharger
	Tune.Turbochargers	= 1			-- Number of turbochargers in the engine, set to 0 for no turbochargers

		Tune.T_Boost			= 13		-- The maximum amount of boost of one turbocharger in PSI.
		Tune.T_PeakRPM			= 4020		-- When the turbo reaches maximum boost.

		Tune.T_IdleBoost		= 1.2		-- How much boost is made at idle.
		Tune.T_Curve			= 0.2		-- The shape of the boost curve between idle and PeakRPM.
		
		Tune.T_Efficiency		= 5			-- How much torque is made with 1 PSI.

		Tune.T_SpoolIncrease	= .7		-- Throttle response of the turbo. (Higher = more responsive, ranges from 0 to 1)
		Tune.T_SpoolDecrease	= .95		-- Throttle response of the turbo. (Higher = more responsive, ranges from 0 to 1)

	-- Supercharger
	Tune.Superchargers	= 0			-- Number of superchargers in the engine, Set to 0 for no superchargers

		Tune.S_PeakBoost		= 13.3		-- The maximum amount of boost of one supercharger in PSI.
		Tune.S_PeakRPM			= 5500		-- When the supercharger reaches its maximum boost.
		
		Tune.S_IdleBoost		= 6.1		-- The amount of boost at idle.
		Tune.S_IdleCurve		= 0.31		-- The shape of the boost curve between idle and PeakRPM.

		Tune.S_RedlineBoost		= 5.6		-- The amount of boost at redline.
		Tune.S_RedlineCurve		= 0.187		-- The shape of the boost curve between PeakRPM and redline.

		Tune.S_Efficiency		= 4.34		-- How much torque is made with 1 PSI.

		Tune.S_Response			= .1		-- Throttle response of the supercharger. (Higher = more responsive, ranges from 0 to 1)

	--Misc
	Tune.ThrotAccel		= .05		-- Throttle acceleration, applied per tick (recommended values between 0.1 to 0.3)
	Tune.ThrotDecel		= .2		-- Throttle deceleration, applied per tick (recommended values between 0.05 to 0.1)
	Tune.BrakeAccel		= .05		-- Brake acceleration, applied per tick
	Tune.BrakeDecel		= .2		-- Brake deceleration, applied per tick

	Tune.RevAccel		= 1			-- RPM acceleration when clutch is off
	Tune.RevDecay		= 20		-- RPM decay when clutch is off
	Tune.RevDecayRPM	= 100		-- RPM decay from engine speed
	Tune.RevBounce		= 200		-- RPM kickback from redline	
	
	Tune.IgnitionRPM	= 2400		-- This is how high the engine revs for the ignition.
	Tune.IgnitionAccel	= 100		-- The acceleration of the RPM while starting the car.
	Tune.ShiftRPM		= 6500		-- This is when the engine shifts.

	Tune.Flywheel		= 500		-- Flywheel weight (higher = faster response, lower = more stable RPM)
	Tune.FlywheelEnergy	= 1000		-- How much torque per 1000 RPM the flywheel can produce when the clutch is dumped.

	Tune.Roughness		= 5			-- Engine roughness (higher = more powerband jitter)

	Tune.InclineComp	= 1		    -- Torque compensation multiplier for inclines (applies gradient from 0-90 degrees)

	Tune.IdleThrottle	= 5			-- Percent throttle with no input. (in percent)
	
--[[Drivetrain]]	
	Tune.Config			= "AWD"		-- "FWD" , "RWD" , "AWD"
	Tune.TorqueVector	= .2		-- AWD ONLY, "-1" has a 100% front bias, "0" has a 50:50 bias, and "1" has a 100% rear bias. Can be any number between that range.

	-- Options (LuaInt)
	Tune.FDiffPower		= 20		-- 0 - 100				Higher values yield more wheel lock-up under throttle, more stability (Front wheels if driven only)
	Tune.FDiffCoast		= 20		-- 0 - 100				Higher values yield more wheel lock-up when off throttle, more stability (Front wheels if driven only)
	Tune.FDiffPreload	= 20		-- 0 - 100				Higher values will make the wheels generally lock up faster in any environment (Front wheels if driven only)
	Tune.RDiffPower		= 20		-- 0 - 100				(Rear wheels if driven only)
	Tune.RDiffCoast		= 20		-- 0 - 100				(Rear wheels if driven only)
	Tune.RDiffPreload	= 20		-- 0 - 100				(Rear wheels if driven only)

	-- Traction Control Settings
	Tune.TCSEnabled		= true		-- Implements TCS
	Tune.TCSThreshold	= 10		-- Slip speed allowed before TCS starts working (in km/h)
	Tune.TCSGradient	= 20		-- Slip speed gradient between 0 to max reduction (in km/h)
	Tune.TCSLimit		= 8		-- Minimum amount of torque at max reduction (in percent)

--[[Transmission]]
	Tune.Clutch			= true		-- Implements a realistic clutch, change to "false" for the chassis to act like AC6.81T.

	Tune.TransModes		= {"Auto", "Semi", "Manual"}												--[[
	[Modes]
		"Auto"		: Automatic shifting
		"Semi"		: Clutchless manual shifting, dual clutch transmission
		"Manual"	: Manual shifting with clutch
		
		>Include within brackets
			eg: {"Semi"} or {"Auto", "Manual"}								
	>First mode is default mode													]]

	Tune.ClutchMode		= "New"												--[[
	[Modes]
		"New"		: Speed controls clutch engagement			(AC6C V1.2)
		"Old"		: Speed and RPM control clutch engagement	(AC6C V1.1)		]]

--[[Transmission]]
	--Transmission Settings
	Tune.Stall			= true		-- Stalling, enables the car to stall. An ignition plugin would be necessary. Disables if Tune.Clutch is false.
	Tune.ClutchEngage	= 10		-- How fast engagement is (0 = instant, 99 = super slow)	
	Tune.SpeedEngage 	= 20		-- Speed the clutch fully engages at (Based on km/h)
	Tune.ClutchIdle		= 400		-- How much RPM past idle is needed to engage the clutch.

	--Clutch: "Old" mode
	Tune.ClutchRPMMult	= 1.0		-- Clutch RPM multiplier, recommended to leave at 1.0

	--Torque Converter:
	Tune.TQLock 		= false		-- Torque converter starts locking at a certain RPM
	Tune.RPMEngage 		= 3500		-- Keeps RPMs to this level until passed

	--CVT:
	Tune.CVTRPM			= 7000		-- RPM that the CVT wants to keep at full throttle.
	Tune.CVTMaxRatio	= 6			-- The gear ratio that the CVT cannot go over.
	Tune.CVTMinRatio	= 1			-- The gear ratio that the CVT cannot go under.

	--Neutral Rev Limiter (Avxnturador)
	Tune.NeutralLimit	= false		-- Enables a different redline RPM for when the car is in neutral
	Tune.NeutralRevRPM	= 5000		-- The rev limiter when the car is in neutral
	Tune.LimitClutch	= false		-- Will also limit RPMs while the clutch is pressed down

	--Automatic Settings
	Tune.AutoShiftType	= "DCT"												--[[
	[Types]
		"Rev"		: Clutch engages fully once RPM reached			(AC6C V1)
		"DCT"		: Clutch engages after a set time has passed	(AC6.81T)	]]
	Tune.AutoShiftVers	= "New"												--[[
	[Versions]
		"New"		: Shift from Reverse, Neutral, and Drive		(AC6.81T)
		"Old"		: Auto shifts into R or D when stopped.			(AC6.52S2)	]]
	Tune.AutoUpThresh	= -200		-- Automatic upshift point 	(relative to peak RPM, positive = Over-rev)
	Tune.AutoDownThresh = 1400		-- Automatic downshift point (relative to peak RPM, positive = Under-rev)

	--Automatic: Revmatching
	Tune.ShiftThrot		= 100		-- Throttle level when shifting down to revmatch, 0 - 100%

	--Automatic: DCT
	Tune.ShiftUpTime	= 0.2		-- Time required to shift into next gear, from a lower gear to a higher one.
	Tune.ShiftDnTime	= 0.1		-- Time required to shift into next gear, from a higher gear to a lower one.

	--Gear Ratios

	Tune.FinalDrive		= 3.6
	Tune.Ratios			= {
		--[[Reverse]]	3.28		,
		--[[Neutral]]	0			,
		--[[ 1 ]]		3.827		,
		--[[ 2 ]]		2.36		,
		--[[ 3 ]]		1.685		,
		--[[ 4 ]]		1.313		,
		--[[ 5 ]]		1			,
		--[[ 6 ]]		.793		,
	}


	Tune.FDMult			= 1			-- Ratio multiplier (keep this at 1 if car is not struggling with torque)

	-- Speed Limiter (Detomiks)
	Tune.SpeedLimit 	= 0 		-- Maximum speed limit in km/h (0 or less for no limiter)
	Tune.ReverseSpeed	= 30		-- Maximum reverse speed limit
	Tune.SLimitGradient	= 2			-- Throttle interpolation

	--[[Brakes]]
	Tune.ABSEnabled		= true		-- Implements ABS
	Tune.ABSLimit		= 0
	Tune.ABSThreshold	= 4			-- Slip speed allowed before ABS starts working (in km/h) 

	Tune.BrakeForce		= 4000		-- Total brake force in kgf
	Tune.BrakeBias		= .7		-- Brake bias towards the front, percentage (1 = Front, 0 = Rear, .5 = 50/50)
	Tune.PBrakeForce	= 3000		-- Handbrake force in kgf
	Tune.PBrakeBias		= 0			-- Handbrake bias towards the front, percentage (1 = Front, 0 = Rear, .5 = 50/50)
	Tune.EBrakeForce	= 500		-- Engine braking force at redline in kgf

--[[[Default Controls]]
	--Peripheral Deadzones
	Tune.Peripherals = {
		MSteerWidth				= 67		,	-- Mouse steering control width	(0 - 100% of screen width)
		MSteerDZone				= 10		,	-- Mouse steering deadzone (0 - 100%)

		ControlLDZone			= 5			,	-- Controller steering L-deadzone (0 - 100%)
		ControlRDZone			= 5			,	-- Controller steering R-deadzone (0 - 100%)
	}

	--Control Mapping
	Tune.Controls = {

		--Keyboard Controls
		--Mode Toggles
		ToggleTCS				= Enum.KeyCode.T					,
		ToggleABS				= Enum.KeyCode.Y					,
		ToggleTransMode			= Enum.KeyCode.M					,
		ToggleMouseDrive		= Enum.KeyCode.R					,

		--Primary Controls
		Throttle				= Enum.KeyCode.Up					,
		Brake					= Enum.KeyCode.Down					,
		SteerLeft				= Enum.KeyCode.Left					,
		SteerRight				= Enum.KeyCode.Right				,

		--Secondary Controls
		Throttle2				= Enum.KeyCode.W					,
		Brake2					= Enum.KeyCode.S					,
		SteerLeft2				= Enum.KeyCode.A					,
		SteerRight2				= Enum.KeyCode.D					,

		--Manual Transmission
		ShiftUp					= Enum.KeyCode.E					,
		ShiftDown				= Enum.KeyCode.Q					,
		Clutch					= Enum.KeyCode.LeftShift			,

		--Handbrake
		PBrake					= Enum.KeyCode.P					,

		--Mouse Controls
		MouseThrottle			= Enum.UserInputType.MouseButton1	,
		MouseBrake				= Enum.UserInputType.MouseButton2	,
		MouseClutch				= Enum.KeyCode.W					,
		MouseShiftUp			= Enum.KeyCode.E					,
		MouseShiftDown			= Enum.KeyCode.Q					,
		MousePBrake				= Enum.KeyCode.LeftShift			,

		--Controller Mapping
		ContlrThrottle			= Enum.KeyCode.ButtonR2				,
		ContlrBrake				= Enum.KeyCode.ButtonL2				,
		ContlrSteer				= Enum.KeyCode.Thumbstick1			,
		ContlrShiftUp			= Enum.KeyCode.ButtonY				,
		ContlrShiftDown			= Enum.KeyCode.ButtonX				,
		ContlrClutch			= Enum.KeyCode.ButtonR1				,
		ContlrPBrake			= Enum.KeyCode.ButtonL1				,
		ContlrToggleTMode		= Enum.KeyCode.DPadUp				,
		ContlrToggleTCS			= Enum.KeyCode.DPadDown				,
		ContlrToggleABS			= Enum.KeyCode.DPadRight			,
	}
end
return Tune