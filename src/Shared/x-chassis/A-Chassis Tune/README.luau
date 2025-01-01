--[[	
	   ___  _____
	  / _ |/ ___/	Avxnturador   	| Novena						    Eniiqzz	    |
	 / __ / /__		LuaInt         	| Novena						    midmm5	    |
    /_/ |_\___/	 	Detomiks		| Base Chassis                      autopilo7   |

	                Version 1.6.4
	                
	               	A-Chassis and its plugins, scripts, and assets, is free, open-source software under the GNU GENERAL PUBLIC LICENSE. 
	               	A-Chasssis 1.6 and onward is the official continuation of A-Chassis 6C by Novena.

-- Changelog
[07/20/2024 : A-Chassis, Version 1.6.4] - Gauges. Just gauges.
	[Features] -autopilo7
		- Gauges. They look better.
		
[05/01/2024 : A-Chassis, Version 1.6.3.5] - This holds no mass.
	[Fixes] -Detomiks
		- Player does not return to un-massless state.
		
[02/27/2024 : A-Chassis, Version 1.6.3.4] - A fix from a Roblox update.
	[Fixes] -Detomiks
		- Clamped all density values in Initialize to stop warnings.
		
[01/31/2024 : A-Chassis, Version 1.6.3.3] - january moment
	[Fixes] -Detomiks
		- Fixed the turbos dying randomly.
		
[01/25/2024 : A-Chassis, Version 1.6.3.2] - another little patch
	[Fixes] -Detomiks
		- Changed density of players to 0.01 from 0 in initialize to follow Roblox's buoyancy update.
		
[01/20/2024 : A-Chassis, Version 1.6.3.1] - a little patch
	[Fixes] -Detomiks
		- Removed the progressive springs, as the calculations were broken, and this can be easily replicated with a plugin.
		
[12/17/2023 : A-Chassis, Version 1.6.3] - the moral of the story...
	[Features] -Detomiks, midmm55
		- Tires plugin includes optional tire flex and tire weight, and tire marks.
		- Pressing V hides things like tires, power graphs, G-Force and holding hides everything.
		- Redid the engine calculations to be more intuitive.

	[Fixes] -Detomiks
		- Performance improvements and code optimizations.
		- Proper body welding.
		
[08/10/2023 : A-Chassis, Version 1.6.2.1] - Minor fixing...
	[Fixes] -Detomiks
		- Removed the camera plugin
		- Fixed incline compensation

[01/10/2023 : A-Chassis, Version 1.6.2] - little update
	[Features] -Detomiks
		- Added SteerSpeedDecay and MinSteerSpeed to configure the new steer speed settings
		- Added variable spring rates.
		
	[Fixes] -Detomiks
		- Hinge surface connecting Base to Arm is now a hinge constraint to stop wheels from steering backwards. (Detomiks)
		- Fixed engine calculations being broken. (Detomiks)
		- Fixed serious ping issue.
		- Fixed wheels flippimg around.
		- Reverted back to unscalable values for performance.
		* General default tune fixes.
		
	[Plugins] -Detomiks, chedsapp
		- New Camera plugin found by phen/midmm5
		- Default plugins now have A-Chassis credits. (Detomiks)
		- Aerodynamics uses ApplyImpulseAtPosition. (chedsapp)
		- Rewrote Controls Module in case controls are added later down the line. (Detomiks)

[08/07/2023 : A-Chassis, Version 1.6.1] - A bunch of bugs
	[Fixes] -Detomiks
		- *Most* 1.5 plugins can be easily ported to 1.6.
		- Auto/CVT conflicts resolved.
		- New Gauges look
		- Aerodynamics is a plugin again.
		- "Wobbly" wheel parts solved.
		- G-Force meter displays correctly with unrealistic gravities.
		- Units is relative to length, mass, and force now.
		
[08/07/2023 : A-Chassis, Version 1.6.0] - The Modern Era
	[OVERHAULS] -Detomiks
		- Completely redid all the engine calculations. Begone terrible horsepower numbers!
		- Changed scaling chassis-wide using: https://create.roblox.com/docs/physics/units
		- Mobile support with taps and tilting.
		- CVT behaves A LOT more realistically now.
		
	[Features] -Detomiks
		- Added cylinder wheels by changing some Initialize stuff... you can easily change back to ball wheels by setting the Shape property to "Ball" and setting all 3 sizes to be the same.
		- Sway bar is now a spring constraint. It is now MUCH, MUCH, MUCH easier to tune properly. A tutorial on how to set it up might be coming soon...
		- Gravity compensation because you people keep complaining about it...
		- Individual disabling of steering in each wheel. Just add a boolean attribute in the wheel called "SteerDisabled". Thanks @MEGAHACKER2228 for the idea.
		- Wheel weight instead of density.
		
	[Fixes] -Detomiks
		- RPM management improved:
			- Revlimiter that changes the throttle.
			- Removed idle throttle since idle is actually held with throttle now.
			- "Starting" value added. Use this for a Drive-controlled startup.
			- Rev acceleration and deceleration is now more like Automation and BeamNG.
			- Smoother overall by averaging the wheel rotational velocity to account for jittery Roblox physics.
		- Made axle structural member positions not garbage in code.
		- Update system works with new update codes and is mostly future-proofed.
	
	[Plugins] -Detomiks
		- Renamed many plugins to be more user-friendly and fit with the possibly new naming scheme?
		- Removed many plugins to reduce bloat. Most have been migrated directly into the drive.
		- Added new sounds module to go with the new calculations.
		- Controls module has working deadzone sliders now along with rounded corners. A full redesign and overhaul is coming soon.
		- Gauges have finally been updated.
		- Tires features new haptics among a standalone wheel tune module.
		- Mouse Steer Camera retains camera position before activation.
		- Little G-Force meter.
		
[26/01/2023 : A-Chassis C Version 1.51.2] - just a fix: the late sequel
	[Features] -Adhamkhedrhuman
		- A RodConstraint sway bar is now dumped into the chassis and will be scriptable in 1.52 but in the meantime you can have a customizable sway bar you can enable.
		
	[Fixes] -Adhamkhedrhuman and hwoagh_a	
		- Attach camera is now used in mouse steering to restrict movement when braking
		- Added hwoagh_a's turbocharger fix

	[Miscellaneous] -Adhamkhedrhuman
		- Balanced the slipstream multiplier for better racing against 1.52 cars (to backport the change change slipstreamMult to 25)
		
[02/07/2022 : A-Chassis C Version 1.51.1] - just a fix
	[Fixes] -SW_TK and Adhamkhedrhuman
		- Editable values for what enables and disables in the mouse steering added by Adhamkhedrhuman
		- Mouse steering by SW_TK is added

[27/05/2022 : A-Chassis C Version 1.51] - The up to Date for 2022 Update.
	[Features] -Eniiqz
		- Speed limiter added

	[Fixes] -Adhamkhedrhuman and Gam3rPlay3r
		- The gear you are on resetting to neutral when re entering the car is fixed
		- Added Gam3rPlay3r's Anti-Loop plugin
		- Fixed the mouse steering camera
		
	[Engine sounds] -Adhamkhedrhuman
		- Added a reverb effect that can be enabled
		
	[Plugins] -Adhamkhedrhuman, SW_TK, hwoagh_a, riojr100, moonaux, EA11_R, itzt, crazy378, Arriva_chessboy, Birdatoo, Eniiqz, 7h3L337Dude and ArisNeta
		- Added SW_TK's fortune advanced first person plugin with ArisNeta's invisible first person hats integrated with values to turn both on and off
		- Added the liftoff backfire plugin that makes crackle sounds uploaded but not made by 7h3L337Dude with on and off values
		- Added an engine shake plugin with on and off values sent to me by a friend (creator unknown)
		- Added a basic version of Pog Mobile Support 1.4 by Eniiqz and Adhamkhedrhuman
		- Added Birdatoo's universal transmission whine adapted for a chassis which is enabled in te IgnitionHandler
		- Added SWT_K's mouse steering but with the indicator removed and the inivisble cursor kept
		- Added my modified transmission shift sound (original creator unknown)
		- Added Arriva_chessboy's brake squeal plugin with a value to enable and disable it
		- Added hwoagh_a's AC6 SoundPack with the sounds that are good for being played from the DriveSeat
		- Added the burnout script uploaded but not made by crazy378 with on and off values
		- Added itzt's creep plugin with on and off values
		- Added EA11_R's brake fade with a heat display that can be enabled
		- Added moonaux's editable AC6C gauges with color reset back to normal
		- Added Adhamkhedrhuman and riojr100's upgraded AC6C startup with all sounds able to be enabled and disabled
		- Power to weight modified power and torque reader by hwoagh_a added
		- Added PacejkaTires 
		- IgnoreGuiInset enabled in the interface for better mobile scaling

	[Aerodynamics] -Adhamkhedrhuman and RikOne2
		- Readded the body sound 
		- Blown diffuser system added
	    - Integrated the stuart six slipstream plugin
		- Wind sound replaced to a sound that i can unprivate later when it is possible
		
	[Optimizations] -Adhamkhedrhuman
		- Default invisible positonable system parts and SUSpension parts very slightly optimized
		- More massless parts for better weight accuracy 
	
	[Miscellaneous] -Adhamkhedrhuman
		- Speed autoscaling in the gauges is off by default
		- Turning on SUSvisible actually makes your SUSpension fully visible with no transparency
		- Pre toggled parking brake turned off by default
		- Transmission mode order changed to order from easiest to hardest
		
[02/01/2021 : A-Chassis C Version 1.5, Update 2] - DO People Read These?
	[Misc] -LuaInt
		- Weight brick density cap added
		- Rear caster fixed
		- Aerodynamics fixed
		- Engine and induction sounds fixed

[12/31/2020 : A-Chassis C Version 1.5, Update 1] - The Movement Update 2, The Reckoning
		[Overhaul] -LuaInt
			- Weight calculation entirely rewritten
			- Torque delivery calculation simplified, engine untouched
			
		[New Suspension System] -LuaInt
			- In-depth player-built suspension (Tutorial can be found on our server)
			- Chassis contains double-wishbone suspension on all 4 wheels by default
			- Deleting the "SuspensionGeometry" model inside of a wheel will revert it to pre-1.5 suspension
			
		[Plugins] -LuaInt
			- New aerodynamics plugin
			- New stock engine and exhaust sound plugin
			- New forced induction sound plugin
			
		[Miscellaneous] -LuaInt
			- Tune reorganized

[07/09/2020 : A-Chassis C Version 1.4, Update 4] - The Burnout Update
		[Welding Bugfix] -Avxnturador and LuaInt
			- Fixed a parenting issue in the Initialize script regarding welds, making client and server replication break.
			
		[Parking Brake Bias] -Avxnturador
			- Added Parking Brake Bias, works like regular Brake Bias
			
		[Four Wheel Steering Update] -LuaInt
			- Updated Static 4WS as part of a bugfix.
			
[06/19/2020 : A-Chassis C Version 1.4, Update 3] - The Braking Bugfix
		[Updated Parking Brake] -LuaInt
			- Updated Parking Brake for simplicity in the Drive
			- Also fixes a bug where all 4 wheels have the parking brake applied

[06/14/2020 : A-Chassis C Version 1.4, Updates 1 and 2] - The Movement Update
		[Pertaining to Update 2] -LuaInt and Avxnturador
			- Separated Front and Rear Steering gyro options (Added Tune.RSteerD, Tune.RSteerMaxTorque and Tune.RSteerP)
			- Added rear wheel steering to "R" wheels
				Please add Tune.RSteerD, Tune.RSteerMaxTorque and Tune.RSteerP to the tune to take advantage of separated gryo options

		(Personal Note by Avxnturador)
			This update would not have been as big of an update without LuaInt
			With that said, LuaInt is now the newest member to the AC6 and NCT chassis team.
			Thank him endlessly.
			
		[New Engine] -Avxnturador 
			- Combining AC6C V1.2's engines alongside AC6C V1.3's aspiration, the engine now has its final revision
			- Instructions to tune it are now similar to both previous versions of the chassis', and a new Desmos graph reflects it
		
		[PGS Physics Overhaul] -LuaInt
			- The chassis now uses PGS Physics Solver Components to replace the legacy BodyMovers
			- Different Power and Brake motors are now implemented, bringing a more realistic driving experience
			
		[Rev Limiter] -Avxnturador
			- Limits the RPM to a certain set RPM
			- Can be limited in Neutral gear or when the clutch is in
		
		[New Steering] -LuaInt
			- More realistic steering options
			- Ackermann steering included for more true-to-life steering
		
		[Four Wheel Steering] -LuaInt
			- If activated, the rear wheels will turn alongside and/or against the front wheels
			- Check the Tune to see how to tune it
			- Note: Always have the rear wheels' degrees (e.g. 12, 15) LESS THAN the front wheels (e.g. 37, 45)
		
		[New Differential] -LuaInt
			- The new differential is easier to understand and tune
			- Includes power, coast, and preload
		
		[Clutch Kick] -LuaInt
			- Torque will be multiplied if a clutck kick occurs
			- Helpful for getting extra power to drift or get up hills
		
		[Braking Overhaul] -LuaInt
			- Braking has been combined, alongside with brake bias
			- Engine braking has also been introduced
		
		[Suspension Geometry Separation] -Avxnturador
			- The suspension geometry (the wishbone and spring) can now be separated
			- This is done with the new Spring Offset values
			- This will move the spring offset IN RELATION TO THE ANCHOR OFFSET

		[Weight Optimization] -Avxnturador
			- Objects with the Massless property enabled will be ignored when calculating weight
			- This is insanely helpful for highly detailed cars where the cars' mass would reach excess of 1000 or so

		[Others] -Avxnturador
			- Revamped the Auto Update feature to be better alongside the new model
			- Removed the Drag feature, allowing third-party plugins to handle that force by itself
			- Added RCaster for four wheel steering enabled cars 
		
		[Legacy Physics Deprecated] -LuaInt and Avxnturador
			- With the release of this new chassis, Legacy physics engine support has been completely deprecated
		
	[09/18/2019 : A-Chassis C Version 1.3, Update 1] - The Engine Update
		[Engine]
			-The engine from the NCT: M chassis has been carried over
			-This allows for great control over your power graphs
			-This also separates aspiration, allowing for twincharging and unlimited aspiration objects
		
		[Backwards Compatibility]
			-If you don't want to retune your engine, backwards compatibility has been brought over
			-You can use your AC6C V1.2 engine tune with this update
			-Take a look at #ENGINE to look at engine backwards compatibility
			-YOU MUST UPDATE THE WHOLE ENGINE CODE IN THE TUNE, #ENGINE WILL THEN OVERRIDE THAT CODE!
		
		[Clutch]
			-Added three different clutch types, all under Tune.ClutchType
				-Clutch, standard clutch present in AC6C
				-Torque Converter, keeps RPM up overall
				-CVT (however not a true CVT), keeps RPM at a set RPM until above
		
		[Other]
			-Added Tune.Drag, simulating drag right from the chassis
			-Added throttle and brake responsiveness
				-Tune.ThrotAccel and Tune.ThrotDecel
				-Tune.BrakeAccel and Tune.BrakeDecel
			
			-Fixed auto-updating feature, PLEASE update or reinstall this chassis to your cars.
	
	[05/28/2019, 05/30/2019 and 07/31/2019 : A-Chassis C Version 1.2, Updates 3, 4 and 5] - The Optimization Update
		[Bugfixes]
			-Added delta time so the chassis runs smooth at any framerate
				-RPM, steering, and power all contain these fixes.
				-The clutch, due to its' nature, is not optimized, however it should still be good.
			-Fixed curve caching so HP and Torque don't jump from one value to the other
			-Fixed a typo that disallowed electric motors to rev (yes, really)
			-Fixed boost intakes so they cut off once throttle is cut off (mainly in shifting)
		
		To install, please replace the Drive script, and update the "Version" value to 5.
	
	[04/28/2019 : A-Chassis C Version 1.2, Update 2] - The Rev Update
		[Bugfixes]
			-I literally just made it so revving with clutch off felt like old A-Chassis.
			-That's it. It's just so it revs like it should.
	
	[04/16/2019 : A-Chassis C Version 1.2, Update 1] - The Transmission and Future-Proof Update 
		[Clutch]
			-After having a very rough start and notoriety, a newer clutch system has been added. 
			-Torque should now be fixed, tune revision from previous versions highly recommended.
			-Special thanks to IMeanBiz, the creator of the newly-revised clutch.
				Note: PLEASE DO NOT SEND TRANSMISSION QUESTIONS TO HIM! Send them to Avxnturador instead.
			-Tune.Clutch has been added, disabling it makes the chassis act like AC6.81T (no realistic clutch).
			-Tune.ClutchMode has been added, changes if RPM will influence the clutch or not.
		
		[Transmission Changes]
			-Automatic shifting has been revamped, making it fail-safe.
			-Automatic shifting settings has been expanded on.
				-Automatic shifting mode, toggle between Speed and RPM
				-Automatic shifting type, toggle between DCT (AC6.81T) and Rev (AC6C V1)
				-Automatic shifting version, toggle between Old (AC6.52S2) and New (AC6.81T)
			-Old "Shift Time" shifting behavior is reintroduced under "DCT".
			-Revmatching is modified, values for throttle behavior introduced.
		
		[Automatic Updates]
			-In an attempt to heavily reduce bugfix releases, an auto updater has been added.
			-You are heavily advised to take a copy of this chassis if you haven't already.
			-Minor bugfixes will automatically be installed, while major updates will not.
			-You will be notified of any update, minor or major. 
			-You can opt out of this by changing "Tune.AutoUpdate" to false.
		
		[Tune Changes]
			-A completely new Transmission tune panel, check the values inside for more information.
	
	[12/09/2018 : A-Chassis C Version 1.1] - The Refinement Update
		[Drive Changes]
			-Manual transmission gearshifts now work properly.
			-Downshift revmatching has been implemented.
			-The clutch is now smooth when the clutch is disengaged. Only works and makes sense in Manual transmissions.
		
		[Tune Changes]
			-Added "Tune.ClutchSens", Clutch Sensitivity. 
			-Added "Tune.Stall", the ability to stall. 
		
		[Plugin Changes]
			-Added "AC6C_Ignition", a stock ignition switch. "F" is the key to start/stop the engine.
		
		[Note]
			-To stop stalling at low RPM's, most noted in first gear, engage the clutch around where Idle RPM is set right before you come to a stop.
		
		[Planned future updates]
			-New, more efficient sound scripts. Thanks to lsThisThingOn for the idea of replacing the scripts for something better.
	
	[12/02/2018 : A-Chassis C Version 1.0] - The Anniversary Update
		[Clutch]
			-With a humongous thanks to DJay500, the newest member to Novena, a proper clutch has been added. 
		
		[Drive Changes]
			-A new clutch system has been added, along with new RPM calculations.
			-The gear system has been reworked. Upshift revmatching is now implemented.
		
		[Tune Changes]
			-Changed "Tune.ClutchTol" to "Tune.Flywheel"
			-Added "Tune.ClutchMult", Clutch Multilpier.
		
		[Plugin Changes]
			-Changed the stock gauges to include options to change the clutch input.
			-The white button will allow you to change the clutch amount. Full white bar means clutch engaged, no white bar means clutch disengaged.
		
		[Planned future updates]
			-Stalling is planned, a stock ignition plugin would be included if so.
			-Downshift revmatching is planned to complement everything else.
--]]

return "1.6.4"