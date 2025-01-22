
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

script.Parent:WaitForChild("Car")
script.Parent:WaitForChild("IsOn")
script.Parent:WaitForChild("ControlsOpen")
script.Parent:WaitForChild("Values")

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local car = script.Parent.Car.Value

local TuneData = require(car["A-Chassis Tune"])
local Units = require(ReplicatedStorage.Units)
local Values = script.Parent.Values

player.PlayerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor

GuiService.TouchControlsEnabled = false
local _MobileMode = "Tap"
local _MobileModes = {"Tap", "Tilt"}

local FBrakeForce = TuneData.BrakeForce * 9.80665 * Units.Force_N * TuneData.BrakeBias
local RBrakeForce = TuneData.BrakeForce * 9.80665 * Units.Force_N * (1 - TuneData.BrakeBias)
local FParkingBrakeForce = TuneData.PBrakeForce * 9.80665 * Units.Force_N * TuneData.PBrakeBias
local RParkingBrakeForce = TuneData.PBrakeForce * 9.80665 * Units.Force_N * (1 - TuneData.PBrakeBias)
local EBrakeForce = TuneData.EBrakeForce
local SteerOuter = TuneData.SteerOuter
local SteerInner = TuneData.SteerInner

local boolToNum = {[true] = 1, [false] = 0}

local _IsOn = TuneData.AutoStart
if TuneData.AutoStart and (TuneData.Engine or TuneData.Electric) then
	script.Parent.IsOn.Value = true
end

local _GSteerT=0
local _GSteerC=0
local _GThrot=0
local _InThrot=0
local _IThrot=0
local _GBrake=0
local _InBrake=0
local _IBrake=0

local _GClutch = 0
local ClutchPressing = false
local _PlayerClutch = false
local _Clutch = 0
local _ClutchKick = 0
local _ClutchModulate = 0

local RPM = TuneData.IgnitionRPM
local _OutTorque = 0
local CurrentGear = 0
local ShiftUp = false
local ShiftDown = false
local isShifting = false
local _spLimit = 0

local _Boost = 0
local _TBoost = 0
local _SBoost = 0

local HP = 0
local Torque = 0
local NetHP = 0
local NetTorque = 0
local ElectricHP = 0
local ElectricTorque = 0
local TurboHP = 0
local TurboTorque = 0
local SuperHp = 0
local SuperTorque = 0
local BoostedHP = 0
local BoostedTorque = 0

local _CurrentRatio = TuneData.Ratios[CurrentGear+2]
local _FlywheelEnergy = 0

local _TMode = TuneData.TransModes[1]

local _MSteer = false
local _SteerL = false
local _SteerR = false
local _PBrake = false

local _TCSTracker = {}
local _TCS = TuneData.TCSEnabled
local _TCSActive = false
local _TCSAmt = 0

local _ABSTracker = {}
local _ABS = TuneData.ABSEnabled
local _ABSActive = false
local _ABSAmt = 0

local FlipWait=tick()
local FlipDB=false

local _InControls = false
local _LastInputWasGamepad = false

local revLimiting = false

local _WheelSpeedsTable = {}
local _WheelSpeeds = {}
local _OldVelocity = Vector3.new()

local _CarCenter = CFrame.new()

local _DragFactor = 1

--[[Shutdown]]
car.DriveSeat.ChildRemoved:connect(function(child) 
	if child.Name=="SeatWeld" and child:IsA("Weld") then
		GuiService.TouchControlsEnabled = true
		script.Parent:Destroy()
	end
end)

--[[Controls]]
local _CTRL = TuneData.Controls
local Controls = Instance.new("Folder",script.Parent)
Controls.Name = "Controls"
for i,v in next, (_CTRL) do
	local a=Instance.new("StringValue",Controls)
	a.Name=i
	a.Value=v.Name
	a.Changed:connect(function()
		if i=="MouseThrottle" or i=="MouseBrake" then
			if a.Value == "MouseButton1" or a.Value == "MouseButton2" then
				_CTRL[i]=Enum.UserInputType[a.Value]
			else
				_CTRL[i]=Enum.KeyCode[a.Value]
			end
		else
			_CTRL[i]=Enum.KeyCode[a.Value]
		end
	end)
end

--Deadzone Adjust
local _PPH = TuneData.Peripherals
	for i,v in next, (_PPH) do
	local a = Instance.new("IntValue",Controls)
	a.Name = i
	a.Value = v
	a.Changed:connect(function() 
		a.Value=math.min(100,math.max(0,a.Value))
		_PPH[i] = a.Value
	end)
end

function GetCarCenter()
	local centerF = Vector3.new()
	local centerR = Vector3.new()
	local countF = 0
	local countR = 0
	for i,v in next, car.Wheels:GetChildren() do
		if v.Name=="FL" or v.Name=="FR" or v.Name=="F" then
			centerF = centerF+v.CFrame.p
			countF = countF+1
		else
			centerR = centerR+v.CFrame.p
			countR = countR+1
		end
	end
	centerF = centerF/countF
	centerR = centerR/countR
	local center = CFrame.lookAt(centerR:Lerp(centerF,.5),centerF)
	return center
end

--Input Handler
function DealWithInput(input, gameProcessedEvent)
	-- if gameProcessedEvent then
	-- 	return
	-- end

	if (UserInputService:GetFocusedTextBox() ~= nil) or _InControls then
		_IThrot = 0
		_GSteerT = 0
		_IBrake = 0
		return
	end

	local assemblySpeed = car.DriveSeat.AssemblyLinearVelocity.Magnitude

	local inputShiftDown = input.KeyCode == _CTRL["ContlrShiftDown"] or (_MSteer and input.KeyCode == _CTRL["MouseShiftDown"]) or (not _MSteer and input.KeyCode == _CTRL["ShiftDown"])
	local isDownshiftable = (_IsOn and ((_TMode == "Auto" and CurrentGear <= 1) and TuneData.AutoShiftVers == "New") or _TMode == "Semi") or _TMode == "Manual"

	local inputShiftUp = input.KeyCode == _CTRL["ContlrShiftUp"] or (_MSteer and input.KeyCode == _CTRL["MouseShiftUp"]) or (not _MSteer and input.KeyCode == _CTRL["ShiftUp"])
	local isUpshiftable = (_IsOn and ((_TMode == "Auto" and CurrentGear < 1) and TuneData.AutoShiftVers == "New") or _TMode == "Semi") or _TMode == "Manual"

	local inputClutch = input.KeyCode == _CTRL["ContlrClutch"] or (_MSteer and input.KeyCode == _CTRL["MouseClutch"]) or (not _MSteer and input.KeyCode == _CTRL["Clutch"])

	local inputPBrake = input.KeyCode == _CTRL["ContlrPBrake"] or (_MSteer and input.KeyCode == _CTRL["MousePBrake"]) or (not _MSteer and input.KeyCode == _CTRL["PBrake"]) or (not _MSteer and input.KeyCode == _CTRL["PBrake2"])

	local inputChangeTransmissionMode = input.KeyCode == _CTRL["ContlrToggleTMode"] or input.KeyCode == _CTRL["ToggleTransMode"]

	local inputThrottle = (not _MSteer and (input.KeyCode == _CTRL["Throttle"] or input.KeyCode == _CTRL["Throttle2"])) or ((((_CTRL["MouseThrottle"] == Enum.UserInputType.MouseButton1 or _CTRL["MouseThrottle"] == Enum.UserInputType.MouseButton2) and input.UserInputType == _CTRL["MouseThrottle"]) or input.KeyCode == _CTRL["MouseThrottle"])and _MSteer)

	local inputBrake = (not _MSteer and (input.KeyCode == _CTRL["Brake"] or input.KeyCode == _CTRL["Brake2"])) or ((((_CTRL["MouseBrake"] == Enum.UserInputType.MouseButton1 or _CTRL["MouseBrake"] == Enum.UserInputType.MouseButton2) and input.UserInputType == _CTRL["MouseBrake"]) or input.KeyCode == _CTRL["MouseBrake"]) and _MSteer)

	local inputSteerLeft = not _MSteer and (input.KeyCode == _CTRL["SteerLeft"] or input.KeyCode == _CTRL["SteerLeft2"])
	local inputSteerRight = not _MSteer and (input.KeyCode == _CTRL["SteerRight"] or input.KeyCode == _CTRL["SteerRight2"])

	local inputToggleTCS = TuneData.TCSEnabled and _IsOn and input.KeyCode == _CTRL["ToggleTCS"] or input.KeyCode == _CTRL["ContlrToggleTCS"]
	local inputToggleABS = TuneData.ABSEnabled and _IsOn and input.KeyCode == _CTRL["ToggleABS"] or input.KeyCode == _CTRL["ContlrToggleABS"]

	if inputShiftDown and isDownshiftable and input.UserInputState == Enum.UserInputState.Begin then

		if not ShiftDown then
			ShiftDown = true
		end

	elseif inputShiftUp and isUpshiftable and input.UserInputState == Enum.UserInputState.Begin then

		if not ShiftUp then
			ShiftUp = true
		end

	elseif inputClutch and _TMode == "Manual" then

		if input.UserInputState == Enum.UserInputState.Begin then
			ClutchPressing = true
			_PlayerClutch = true
		elseif input.UserInputState == Enum.UserInputState.End then
			ClutchPressing = false
			_PlayerClutch = false
		end

	elseif inputPBrake then

		if input.UserInputState == Enum.UserInputState.Begin then
			_PBrake = not _PBrake
		elseif input.UserInputState == Enum.UserInputState.End then
			if assemblySpeed > 5 then
				_PBrake = false
			end
		end

	elseif inputChangeTransmissionMode and input.UserInputState == Enum.UserInputState.Begin then
		local n = 1

		for i, v in TuneData.TransModes do
			if v == _TMode then
				n = i
				break
			end
		end

		n = n + 1

		if n > #TuneData.TransModes then
			n = 1
		end

		_TMode = TuneData.TransModes[n]

	elseif inputThrottle then
		if input.UserInputState == Enum.UserInputState.Begin then
			_IThrot = 1
		else
			_IThrot = 0
		end

	elseif inputBrake then
		if input.UserInputState == Enum.UserInputState.Begin then
			_IBrake = 1
		else
			_IBrake = 0
		end

	elseif inputSteerLeft then
		if input.UserInputState == Enum.UserInputState.Begin then
			_GSteerT = -1
			_SteerL = true
		else
			if _SteerR then
				_GSteerT = 1
			else
				_GSteerT = 0
			end
			_SteerL = false
		end

	elseif inputSteerRight then
		if input.UserInputState == Enum.UserInputState.Begin then
			_GSteerT = 1
			_SteerR = true
		else
			if _SteerL then
				_GSteerT = -1
			else
				_GSteerT = 0
			end
			_SteerR = false
		end

	elseif input.KeyCode == _CTRL["ToggleMouseDrive"] then
		if input.UserInputState == Enum.UserInputState.End then
			_MSteer = not _MSteer
			_IThrot = 0
			_IBrake = 0
			_GSteerT = 0
		end

	elseif inputToggleTCS then
		if input.UserInputState == Enum.UserInputState.End then
			_TCS = not _TCS
		end

	elseif inputToggleABS then
		if input.UserInputState == Enum.UserInputState.End then
			_ABS = not _ABS
		end
		
	end
	
	--Variable Controls
	if input.UserInputType.Name:find("Gamepad") then
		--Gamepad Steering
		if input.KeyCode == _CTRL["ContlrSteer"] then
			if input.Position.X >= 0 then
				local cDZone = math.min(.99, TuneData.Peripherals.ControlRDZone / 100)
				if math.abs(input.Position.X) > cDZone then
					_GSteerT = (input.Position.X - cDZone) / (1 - cDZone)
				else
					_GSteerT = 0
				end
			else
				local cDZone = math.min(.99, TuneData.Peripherals.ControlLDZone / 100)
				if math.abs(input.Position.X) > cDZone then
					_GSteerT = (input.Position.X + cDZone) / (1 - cDZone)
				else
					_GSteerT = 0
				end
			end
			
		--Gamepad Throttle
		elseif input.KeyCode == _CTRL["ContlrThrottle"] then
			_IThrot = math.max(0,input.Position.Z)
			
		--Gamepad Brake
		elseif input.KeyCode == _CTRL["ContlrBrake"] then
			_IBrake = input.Position.Z
		end
	end
end

UserInputService.InputBegan:connect(DealWithInput)
UserInputService.InputChanged:connect(DealWithInput)
UserInputService.InputEnded:connect(DealWithInput)

function DealWithMobileInput()
	local mobile = script.Parent.Mobile
	
	mobile.Jump.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		
		player.Character:FindFirstChildWhichIsA("Humanoid").Jump = true
	end)
	
	mobile.ModeSwitch.MouseButton1Click:Connect(function()
		local mobileModeKey = (table.find(_MobileModes, _MobileMode) or 0) + 1

		_MobileMode = _MobileModes[mobileModeKey]
		if not _MobileMode then
			_MobileMode = _MobileModes[1]
		end
	end)
	
	-- Tap
	for _, button in mobile.Tap:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		button.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			button.ImageColor3 = Color3.fromRGB(178,178,178)
			button.ImageLabel.ImageColor3 = Color3.new(0,0,0)
			button.ImageLabel.ImageTransparency = .5

			if button.Name == "Throttle" then
				_IThrot = 1
			elseif button.Name == "Brake" then
				_IBrake = 1
			elseif button.Name == "Left" then
				_GSteerT = -1
				_SteerL = true
			elseif button.Name == "Right" then
				_GSteerT = 1
				_SteerR = true
			end
		end)

		button.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			button.ImageColor3 = Color3.new(0, 0, 0)
			button.ImageLabel.ImageColor3 = Color3.new(1,1,1)
			button.ImageLabel.ImageTransparency = .8

			if button.Name == "Throttle" then
				_IThrot = 0
			elseif button.Name == "Brake" then
				_IBrake = 0
			elseif button.Name == "Left" then
				if _SteerR then
					_GSteerT = 1
				else
					_GSteerT = 0
				end
				_SteerL = false
			elseif button.Name == "Right" then
				if _SteerL then
					_GSteerT = -1
				else
					_GSteerT = 0
				end
				_SteerR = false
			end
		end)
	end
	
	-- Tilt
	for _, button in mobile.Tilt:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		button.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			if button.Name == "Throttle" then
				_IThrot = 1
			elseif button.Name == "Brake" then
				_IBrake = 1
			end
		end)

		button.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			if button.Name == "Throttle" then
				_IThrot = 0
			elseif button.Name == "Brake" then
				_IBrake = 0
			end
		end)
	end

	if UserInputService.GyroscopeEnabled then
		UserInputService.DeviceRotationChanged:Connect(function(rotation, cframe)
			if _MobileMode == "Tilt" then
				_GSteerT = -math.clamp(
					rotation.Position.Z*2,
					-1,
					1
				)
			end
		end)
	end
end

DealWithMobileInput()

--[[Drivetrain Initialize]]
local Drivetrain = {}

--Power Front Wheels
if TuneData.Config == "FWD" or TuneData.Config == "AWD" then
	for _, wheel in car.Wheels:GetChildren() do
		if wheel.Name == "FL" or wheel.Name == "FR" or wheel.Name == "F" then
			table.insert(Drivetrain, wheel)
		end
	end
end

--Power Rear Wheels
if TuneData.Config == "RWD" or TuneData.Config == "AWD" then
	for _, wheel in car.Wheels:GetChildren() do
		if wheel.Name == "RL" or wheel.Name == "RR" or wheel.Name == "R" then
			table.insert(Drivetrain, wheel)
		end
	end
end

--Determine Wheel Size
local wheelDiameter = 0
for _, wheel in Drivetrain do
	if wheel.Size.Y > wheelDiameter then
		wheelDiameter = wheel.Size.Y
	end
end

--[[Throttle and Brake Input Smoothing]]
function Inputs(dt)
	local deltaTime = (60/(1/dt))
	if _InThrot <= _IThrot then
		_InThrot = math.min(_IThrot,_InThrot+(TuneData.ThrotAccel*deltaTime))
	else
		_InThrot = math.max(_IThrot,_InThrot-(TuneData.ThrotDecel*deltaTime))
	end
	if _InBrake <= _IBrake then
		_InBrake = math.min(_IBrake,_InBrake+(TuneData.BrakeAccel*deltaTime))
	else
		_InBrake = math.max(_IBrake,_InBrake-(TuneData.BrakeDecel*deltaTime))
	end
end

--[[Steering]]
SteerOuter = (TuneData.LockToLock*180)/TuneData.SteerRatio
SteerInner = math.min(SteerOuter-(SteerOuter*(1-TuneData.Ackerman)),SteerOuter*1.2)

function Steering(dt)
	local deltaTime = (60/(1/dt))
	local controller = _LastInputWasGamepad or (TuneData.MSteerUsesContlr and _MSteer or false)
	local SteerSpeed = controller and (TuneData.ContlrSteerSpeed>0 and TuneData.ContlrSteerSpeed or TuneData.Steerspeed) or TuneData.SteerSpeed * (1-math.min(car.DriveSeat.AssemblyLinearVelocity.Magnitude/(Units.Velocity_mdivs/3.6)/TuneData.SteerSpeedDecay,1-(TuneData.MinSteerSpeed/100)))
	local ReturnSpeed = controller and (TuneData.ContlrReturnSpeed>0 and TuneData.ContlrReturnSpeed or TuneData.ReturnSpeed) or TuneData.ReturnSpeed * (1-math.min(car.DriveSeat.AssemblyLinearVelocity.Magnitude/(Units.Velocity_mdivs/3.6)/TuneData.SteerSpeedDecay,1-(TuneData.MinSteerSpeed/100)))
	
	if _MSteer then
		local msWidth = math.max(1,mouse.ViewSizeX*TuneData.Peripherals.MSteerWidth/200)
		local mdZone = TuneData.Peripherals.MSteerDZone/100
		local mST = ((mouse.X-mouse.ViewSizeX/2)/msWidth)
		if math.abs(mST)<=mdZone then
			_GSteerT = 0
		else
			_GSteerT = (math.max(math.min((math.abs(mST)-mdZone),(1-mdZone)),0)/(1-mdZone))^TuneData.MSteerExp * (mST / math.abs(mST))
		end
	end
	
	--Interpolate Steering
	if _GSteerC < _GSteerT then
		if _GSteerC<0 then
			_GSteerC = math.min(_GSteerT,_GSteerC+(ReturnSpeed*deltaTime))
		else
			_GSteerC = math.min(_GSteerT,_GSteerC+(SteerSpeed*deltaTime))
		end
	else
		if _GSteerC>0 then
			_GSteerC = math.max(_GSteerT,_GSteerC-(ReturnSpeed*deltaTime))
		else
			_GSteerC = math.max(_GSteerT,_GSteerC-(SteerSpeed*deltaTime))
		end
	end
	
	--Steer Decay Multiplier
	local sDecay = (1 - math.min(car.DriveSeat.AssemblyLinearVelocity.Magnitude/(Units.Velocity_mdivs/3.6)/(TuneData.SteerDecay/(Units.Velocity_mdivs/3.6)),1-(TuneData.MinSteer/100)))
	
	--Apply Steering
	for _, wheel in next, car.Wheels:GetChildren() do
		if wheel.Name=="F" then
			wheel.Arm.Steer.CFrame=wheel.Base.CFrame*CFrame.Angles(0,-math.rad(_GSteerC*SteerInner*sDecay),0)
		elseif wheel.Name=="FL" then
			if _GSteerC>= 0 then
				wheel.Arm.Steer.CFrame=wheel.Base.CFrame*CFrame.Angles(0,-math.rad(_GSteerC*SteerOuter*sDecay),0)
			else
				wheel.Arm.Steer.CFrame=wheel.Base.CFrame*CFrame.Angles(0,-math.rad(_GSteerC*SteerInner*sDecay),0)
			end	
		elseif wheel.Name=="FR" then
			if _GSteerC>= 0 then
				wheel.Arm.Steer.CFrame=wheel.Base.CFrame*CFrame.Angles(0,-math.rad(_GSteerC*SteerInner*sDecay),0)
			else
				wheel.Arm.Steer.CFrame=wheel.Base.CFrame*CFrame.Angles(0,-math.rad(_GSteerC*SteerOuter*sDecay),0)
			end
		end
		if wheel:GetAttribute("SteerDisabled") then
			wheel.Arm.Steer.CFrame = wheel.Base.CFrame
		end
	end
end

--[[Engine]]
local finalDriveRatio = TuneData.FinalDrive * TuneData.FDMult
local finalDriveRatioRPM = finalDriveRatio * 30 / math.pi
local compensatedGravity = (TuneData.GravComp > 0 and TuneData.GravComp or workspace.Gravity) * TuneData.InclineComp / 35
local wheelDriveRatio = wheelDiameter * math.pi / 60

--Electric Only Setup
if not TuneData.Engine and TuneData.Electric then 
	TuneData.Redline = TuneData.E_Redline 
	TuneData.ShiftRPM = TuneData.E_Redline
	TuneData.Turbochargers = 0
	TuneData.Superchargers = 0
	TuneData.Clutch = false 
	TuneData.IdleRPM = 0 
	TuneData.IdleThrottle = 0
	TuneData.ShiftUpTime = 0.1 
	TuneData.ShiftDnTime = 0.1 
end

--Powertrain
wait()

function Auto()
	if not (_IsOn) then
		return
	end

	local assemblySpeed = car.DriveSeat.AssemblyLinearVelocity.Magnitude

	local isLegacyShiftVersion = TuneData.AutoShiftVers == "Old"
	local isLowSpeed = assemblySpeed < 5

	if isLegacyShiftVersion and CurrentGear == 0 then
		CurrentGear = 1
		ClutchPressing = false
	end

	if CurrentGear <= 0 then
		if _InThrot > 0 and isLowSpeed and isLegacyShiftVersion then
			CurrentGear = 1
			ClutchPressing = false
		end
	end

	if CurrentGear >= 1 then
		if isLegacyShiftVersion and CurrentGear == 1 and _InBrake > 0 and isLowSpeed then
			CurrentGear = -1
			ClutchPressing = false
			return
		end

		if not isLowSpeed then
			local rpmShiftUp = TuneData.ShiftRPM + TuneData.AutoUpThresh
			local rpmShiftDown = TuneData.ShiftRPM - TuneData.AutoDownThresh

			local speedToShiftUp = math.ceil(wheelDriveRatio * rpmShiftUp / _CurrentRatio / finalDriveRatio)
			local speedToShiftDown = math.ceil(wheelDriveRatio * rpmShiftDown / TuneData.Ratios[CurrentGear+1] / finalDriveRatio)

			if assemblySpeed > speedToShiftUp then
				if not ShiftUp and not isShifting then
					ShiftUp = true
				end
			elseif assemblySpeed < speedToShiftDown and CurrentGear > 1 then
				if not ShiftDown and not isShifting then
					ShiftDown = true
				end
			end
		end
	end
end

function Gear()
	local maxSpin = 0
	for _, v in Drivetrain do 
		if _WheelSpeeds[v.Name] > maxSpin then
			maxSpin = _WheelSpeeds[v.Name]
		end
	end

	if ShiftUp and not isShifting then
		if _TMode == "Manual" and not ClutchPressing then
			ShiftUp = false 
			return
		end

		if CurrentGear == #TuneData.Ratios-2 then
			ShiftUp = false
			return
		end

		if _TMode ~= "Manual" and not _IsOn then
			return
		end
		
		if _TMode ~= "Manual" then
			isShifting = true
			if CurrentGear > 0 then 
				task.wait(TuneData.ShiftUpTime)
			end
		end

		ShiftUp = false
		isShifting = false

		if _TMode ~= "Manual" and not _IsOn then
			return
		end

		CurrentGear = math.min(CurrentGear + 1, #TuneData.Ratios - 2)
		if _TMode ~= "Manual" or (_TMode == "Manual" and CurrentGear == 1) and _IsOn then
			ClutchPressing = false
		end
	end

	if ShiftDown and not isShifting then
		if (_TMode == "Manual" and not ClutchPressing) or CurrentGear == -1 or (_TMode ~= "Manual" and not _IsOn) then
			ShiftDown = false
			return
		end

		if _TMode~="Manual" then
			isShifting = true
			if CurrentGear > 1 then 
				task.wait(TuneData.ShiftDnTime)
			end
		end

		ShiftDown = false
		isShifting = false

		if _TMode ~= "Manual" and not _IsOn then
			return
		end

		CurrentGear = math.max(CurrentGear - 1, -1)

		if _TMode ~= "Manual" or (_TMode == "Manual" and CurrentGear == -1) and _IsOn then
			ClutchPressing = false
		end
	end
end

local _GoalRPM=0
local tqTCS = 1
local _StallOK = false
local ticc = tick()

--Power calculation prerequesites
local function computeTorqueCurve(m, n, p, q, M, b, x)
	return math.clamp(
		M - ( (q-n) / (b^p - b^m) * (b^x - b^m) + n ),
		0,
		M
	)
end

--Apply Power
function Engine(rawDeltaTime)
	local dt = (60 / (1/rawDeltaTime))
	
	--Average Rotational Speed Calculation
	local avgFWheelSpeed = 0
	local fwcount = 0
	local avgRWheelSpeed = 0
	local rwcount = 0

	for _, wheel in car.Wheels:GetChildren() do
		if wheel.Name == "FL" or wheel.Name == "FR" or wheel.Name == "F" then
			avgFWheelSpeed = avgFWheelSpeed + _WheelSpeeds[wheel.Name]
			fwcount=fwcount+1
		elseif wheel.Name == "RL" or wheel.Name == "RR" or wheel.Name == "R" then
			avgRWheelSpeed = avgRWheelSpeed + _WheelSpeeds[wheel.Name]
			rwcount=rwcount+1
		end
	end

	avgFWheelSpeed=avgFWheelSpeed/fwcount
	avgRWheelSpeed=avgRWheelSpeed/rwcount

	local avgDrivetrainSpin = 0
	local maxCount = 0
	for _, v in Drivetrain do
		avgDrivetrainSpin = avgDrivetrainSpin + _WheelSpeeds[v.Name]
		maxCount = maxCount + 1
	end
	avgDrivetrainSpin = avgDrivetrainSpin / maxCount

	local revThrot = _GThrot
	local _WheelRPM = avgDrivetrainSpin*_CurrentRatio*finalDriveRatioRPM

	--Update ratio
	_CurrentRatio = TuneData.Ratios[CurrentGear + 2]
	_spLimit = (TuneData.Redline + 100) / (finalDriveRatioRPM * _CurrentRatio)
	
	--Neutral Gear
	if (CurrentGear == 0 or isShifting) and _IsOn then 
		ClutchPressing = true
		_Clutch = 1
		_StallOK = false
	end
	
	_FlywheelEnergy = math.max(
		_FlywheelEnergy - TuneData.Flywheel,
		0
	)
	
	if _Clutch == 1 then
		_FlywheelEnergy = math.max(
			(RPM - _WheelRPM) / 1000 * _GThrot * TuneData.FlywheelEnergy,
			0
		)
	end
	
	local revMin = 1
	local goalMin = 1
	local goalMax = TuneData.Redline + 100
	if TuneData.Stall and TuneData.Clutch then
		revMin = 0
	end
	
	if isShifting and ShiftUp then
		_GThrot = TuneData.IdleThrottle / 100
	elseif isShifting and ShiftDown then
		_GThrot = TuneData.ShiftThrot / 100
	else
		if TuneData.AutoShiftVers == "Old" and CurrentGear == -1 and _TMode == "Auto" then
			_GThrot = _InBrake
		else
			_GThrot = math.max(
				_InThrot,
				TuneData.IdleThrottle / 100
			)
		end
	end
	
	if TuneData.AutoShiftVers == "Old" and CurrentGear == -1 and _TMode == "Auto" then
		_GBrake = _InThrot
	else
		_GBrake = _InBrake
	end
	
	if not _IsOn then 
		ticc = tick()
		_Clutch = 1 
		if not script.Parent.Starting.Value then
			_GThrot = 0
		end
	end
	
	if ((ClutchPressing and CurrentGear == 0) or (_PlayerClutch and CurrentGear ~= 0)) and TuneData.NeutralLimit then
		if (CurrentGear == 0 and not TuneData.LimitClutch) or TuneData.LimitClutch then
			goalMax = TuneData.NeutralRevRPM
		end
	end

	--Determine RPM
	-- Rev limiter/speed limiter
	if RPM >= TuneData.Redline then
		revLimiting = true
	elseif RPM < TuneData.Redline - TuneData.RevBounce then
		revLimiting = false
	end

	if revLimiting then
		_GThrot = TuneData.IdleThrottle/100
	end
	
	local limit = (CurrentGear < 0 and TuneData.ReverseSpeed or TuneData.SpeedLimit)
	if limit > 0 then
		local assemblySpeed = car.DriveSeat.AssemblyLinearVelocity.Magnitude
		if assemblySpeed >= limit-TuneData.SLimitGradient then
			_GThrot = math.max(
				math.min(
					_GThrot,
					math.max(
						(limit - assemblySpeed / (Units.Velocity_mdivs / 3.6)) / TuneData.SLimitGradient,
						0
					)
				),
				TuneData.IdleThrottle / 100
			)
		end
	end

	-- Idle
	if RPM < TuneData.IdleRPM and _IsOn then
		_GThrot = math.max(
			_GThrot,
			math.clamp(
				(TuneData.IdleRPM - RPM) / 400,
				0,
				1
			)
		)
	end
	
	if (TuneData.Engine or TuneData.Electric) and (not script.Parent.Starting.Value) then
		local rpmAboveIdle = math.max(RPM - TuneData.IdleRPM, 0)
		local idleToRedlineRange = math.max(TuneData.Redline - TuneData.IdleRPM, 1)

		local revDecayAdjustment = math.clamp(
			rpmAboveIdle / idleToRedlineRange,
			0,
			1
		) * TuneData.RevDecayRPM * dt

		_GoalRPM = math.clamp(
			RPM - (TuneData.RevDecay * dt) + (TuneData.RevAccel * revThrot * Values.Torque.Value * dt) - revDecayAdjustment,
			goalMin,
			goalMax
		)
	end

	--Starting
	if script.Parent.Starting.Value then
		if RPM > TuneData.IgnitionRPM then
			script.Parent.IsOn.Value = true
			script.Parent.Starting.Value = false
			_GThrot = 0
		else
			_GoalRPM += TuneData.IgnitionAccel
			_GThrot = 1
		end
	end
	
	if TuneData.Clutch then
		if _IsOn then
			if ClutchPressing then
				_ClutchKick = 1
			end

			_ClutchKick = _ClutchKick * (TuneData.ClutchEngage / 100)		
			
			local ClRPMInfluence = math.max(RPM * TuneData.ClutchRPMMult / TuneData.Redline, 0)
			
			if TuneData.ClutchMode == "New" then
				ClRPMInfluence = 0
			end
			
			local assemblySpeed = script.Parent.Values.Velocity.Value.Magnitude
			_ClutchModulate = math.min(
				assemblySpeed / (Units.Velocity_mdivs / 3.6) / TuneData.SpeedEngage / math.abs(CurrentGear) + ClRPMInfluence - _ClutchKick,
				1
			)

			if not ClutchPressing then
				_Clutch = math.min(1 - _ClutchModulate, 1)
			else
				_Clutch = 1
			end
			
			_StallOK = (_Clutch<=0.01) or _StallOK
		else
			_StallOK = TuneData.Stall
			_Clutch = script.Parent.Values.Clutch.Value
		end
	else
		_StallOK = false
		if not ClutchPressing and not isShifting then
			_Clutch = 0
		else
			_Clutch = 1
		end
	end
	
	if revLimiting or script.Parent.Starting.Value then
		_Clutch = 1
	end
	if RPM <= TuneData.IdleRPM+TuneData.ClutchIdle and _IsOn then
		_Clutch = math.max(_Clutch, math.clamp((TuneData.IdleRPM+TuneData.ClutchIdle-RPM)/100, 0, 1))
	end
	
	local aRPM = math.max(math.min((_GoalRPM*_Clutch) + (_WheelRPM*(1-_Clutch)),TuneData.Redline+100),revMin)
	local clutchP = math.min(math.abs(aRPM-RPM)/(TuneData.Flywheel*dt),.9)
	if ClutchPressing then
		clutchP = 0
	end
	RPM = RPM * clutchP + aRPM * (1 - clutchP)
	if RPM > goalMax then
		RPM = goalMax
	elseif RPM < goalMin then
		RPM = goalMin
	end
	
	if RPM <= (TuneData.IdleRPM / 4) and _StallOK and (tick() - ticc >= 0.2) then
		script.Parent.IsOn.Value = not TuneData.Stall
	end

	-- Torque calculations (Detomiks)
	-- What you see here is mostly just ported over from Desmos.
	local x = RPM/1000
	local NTorque = 0
	local ETorque = 0
	local TTorque = 0
	local STorque = 0
	if TuneData.Engine then
		local NIdleTorque = computeTorqueCurve(
			TuneData.IdleRPM/1000,
			TuneData.IdleTorque,
			TuneData.PeakTorqueRPM/1000,
			TuneData.PeakTorque,
			TuneData.PeakTorque,
			TuneData.IdleTorqueCurve,
			x
		)

		local NRedlineTorque = computeTorqueCurve(
			TuneData.PeakTorqueRPM/1000,
			TuneData.PeakTorque,
			TuneData.Redline/1000,
			TuneData.RedlineTorque,
			TuneData.PeakTorque,
			1/TuneData.RedlineTorqueCurve,
			x
		)

		NTorque = boolToNum[TuneData.Engine] * (TuneData.PeakTorque - NIdleTorque - NRedlineTorque)

		NetHP = (NTorque*x)/5.252
		NetTorque = NTorque
		
		if TuneData.Turbochargers > 0 then
			local _TBoostGoal = TuneData.Turbochargers * _GThrot^3 * (TuneData.T_Boost - computeTorqueCurve(TuneData.IdleRPM/1000, TuneData.T_IdleBoost, TuneData.T_PeakRPM/1000, TuneData.T_Boost, TuneData.T_Boost, 1/TuneData.T_Curve, x))
			if _TBoostGoal > _TBoost then
				_TBoost = math.min(_TBoost + TuneData.T_SpoolIncrease * _GThrot * dt, _TBoostGoal)
			elseif _TBoost > _TBoostGoal then
				_TBoost = math.max(_TBoost * TuneData.T_SpoolDecrease, _TBoostGoal)
			end
			TTorque = _TBoost * TuneData.T_Efficiency
			TurboHP, TurboTorque = (TTorque*x)/5.252, TTorque
		end
		if TuneData.Superchargers > 0 then
			local SIdleBoost = computeTorqueCurve(TuneData.IdleRPM/1000, TuneData.S_IdleBoost, TuneData.S_PeakRPM/1000, TuneData.S_PeakBoost, TuneData.S_PeakBoost, TuneData.S_IdleCurve, x)
			local SRedlineBoost = computeTorqueCurve(TuneData.S_PeakRPM/1000, TuneData.S_PeakBoost, TuneData.Redline/1000, TuneData.S_RedlineBoost, TuneData.S_PeakBoost, 1/TuneData.S_RedlineCurve, x)
			local _SBoostGoal = TuneData.Superchargers * _GThrot * (TuneData.S_PeakBoost - SIdleBoost - SRedlineBoost)
			if _SBoostGoal > _SBoost then
				_SBoost = math.min(_SBoost + TuneData.S_PeakBoost*TuneData.S_Response*dt, _SBoostGoal)
			elseif _SBoost > _SBoostGoal then
				_SBoost = math.max(_SBoost - TuneData.S_PeakBoost*TuneData.S_Response*dt, _SBoostGoal)
			end
			STorque = _SBoost * TuneData.S_Efficiency
			SuperHp, SuperTorque = (STorque*x)/5.252, STorque
		end
		if TuneData.Turbochargers > 0 or TuneData.Superchargers > 0 then
			BoostedHP, BoostedTorque = ((TTorque+STorque)*x)/5.252, TTorque+STorque
		end
	end
	if TuneData.Electric then
		ETorque = boolToNum[TuneData.Electric] * (TuneData.E_Torque - computeTorqueCurve(TuneData.E_TransitionRPM/1000, TuneData.E_Torque, TuneData.E_Redline/1000, TuneData.E_RedlineTorque, TuneData.E_Torque, TuneData.E_Curve, x))
		ElectricHP, ElectricTorque = (ETorque*x)/5.252, ETorque
	end
	
	local TotalTorque = math.clamp(NTorque + ETorque + TTorque + STorque, 0, (TuneData.HPLimit > 0 and TuneData.HPLimit or math.huge)*(5.252/x))
	HP, Torque = (TotalTorque*x)/5.252, TotalTorque
	
	-- Exit engine
	_OutTorque = Torque * _CurrentRatio * finalDriveRatio
	local iComp = (_CarCenter.LookVector.Y)*compensatedGravity
	if CurrentGear==-1 then
		iComp = -iComp
	end
	_OutTorque = _OutTorque*math.max(1,(1+iComp))
	
	--Update Wheels
	for _, wheel in next, (car.Wheels:GetChildren()) do
		--Reference Wheel Orientation

		local RRdiffMult = 1
		local RLdiffMult = 1
		local FRdiffMult = 1
		local FLdiffMult = 1
		
		--Differential/Torque-Vectoring
		if wheel.Name=="FR" then
			local avg=((_WheelSpeeds[wheel.Name]/_WheelSpeeds["FL"])-1)*(TuneData.FDiffPreload/10)
			FRdiffMult=math.ceil(math.max(0,math.min(2,1-( ((TuneData.FDiffPower/100)*avg*_GThrot) + ((TuneData.FDiffCoast/100)*avg*(1-_GThrot)))))*100)/100
			FLdiffMult=2-FRdiffMult
		elseif wheel.Name=="FL" then
			local avg=((_WheelSpeeds[wheel.Name]/_WheelSpeeds["FR"])-1)*(TuneData.FDiffPreload/10)
			FLdiffMult=math.ceil(math.max(0,math.min(2,1-( ((TuneData.FDiffPower/100)*avg*_GThrot) + ((TuneData.FDiffCoast/100)*avg*(1-_GThrot)))))*100)/100
			FRdiffMult=2-FLdiffMult
		elseif wheel.Name=="RR" then
			local avg=((_WheelSpeeds[wheel.Name]/_WheelSpeeds["RL"])-1)*(TuneData.RDiffPreload/10)
			RRdiffMult=math.ceil(math.max(0,math.min(2,1-( ((TuneData.RDiffPower/100)*avg*_GThrot) + ((TuneData.RDiffCoast/100)*avg*(1-_GThrot)))))*100)/100
			RLdiffMult=2-RRdiffMult
		elseif wheel.Name=="RL" then
			local avg=((_WheelSpeeds[wheel.Name]/_WheelSpeeds["RR"])-1)*(TuneData.RDiffPreload/10)
			RLdiffMult=math.ceil(math.max(0,math.min(2,1-( ((TuneData.RDiffPower/100)*avg*_GThrot) + ((TuneData.RDiffCoast/100)*avg*(1-_GThrot)))))*100)/100
			RRdiffMult=2-RLdiffMult
		end

		--Limit values to prevent physics death
		if RRdiffMult > 2 then
			RRdiffMult = 2
		elseif RRdiffMult < 0 then
			RRdiffMult = 0
		end

		if RLdiffMult > 2 then
			RLdiffMult = 2
		elseif RLdiffMult < 0 then
			RLdiffMult = 0
		end

		if FRdiffMult > 2 then
			FRdiffMult = 2
		elseif FRdiffMult < 0 then
			FRdiffMult = 0
		end

		if FLdiffMult > 2 then
			FLdiffMult = 2
		elseif FLdiffMult < 0 then
			FLdiffMult = 0
		end
		
		--Output
	
		--Apply Power
		local on=1
		if not script.Parent.IsOn.Value then
			on=0
		end
		local throt = _GThrot
		local brake = _GBrake
		local clutch=1
		if ClutchPressing then
			clutch = 0
		end
		if RPM < TuneData.IdleRPM then
			clutch = 0
		end
		local tq = (_OutTorque+_FlywheelEnergy)/#Drivetrain
				
		--Apply ABS
		local tqABS = 1
		if _ABS and brake > 0 and math.abs(wheel.RotVelocity.Magnitude*(wheel.Size.Y/2)/(Units.Velocity_mdivs/3.6) - wheel.Velocity.Magnitude/(Units.Velocity_mdivs/3.6))-TuneData.ABSThreshold>0 then
			tqABS = math.max(0, TuneData.ABSLimit / 100)
		end
		if tqABS < 1 then
			_ABSActive = true
		end
		_ABSAmt += tqABS
		_ABSTracker[wheel.Name] = 1 - tqABS
	
		local PBrakeV=0
		if _PBrake == true then
			PBrakeV = 1
		else
			PBrakeV=0
		end
		
		local inDrivetrain = false
		for _, a in Drivetrain do
			if a == wheel then
				inDrivetrain = true
			end
		end

		if inDrivetrain then
			--Apply AWD Vectoring
			if TuneData.Config == "AWD" then
				local bias = (TuneData.TorqueVector+1)
				if string.find(wheel.Name,"F") then
					tq = tq*(2-bias)
				elseif string.find(wheel.Name,"R") then
					tq = tq*bias
				end
			end
			
			--Apply TCS
			tqTCS = 1
			if _TCS and throt>0 then
				tqTCS = 1-(math.min(math.max(0,math.abs(wheel.RotVelocity.Magnitude*(wheel.Size.Y/2)/(Units.Velocity_mdivs/3.6) - wheel.Velocity.Magnitude/(Units.Velocity_mdivs/3.6))-TuneData.TCSThreshold)/TuneData.TCSGradient,1)*(1-(TuneData.TCSLimit/100)))
			end
			if tqTCS < 1 then
				_TCSActive = true
			end
			_TCSTracker[wheel.Name] = 1 - tqTCS
			
			--Update Forces
			local tqOUT = tq*1.356*Units.Torque_nm*(60/workspace:GetRealPhysicsFPS())*throt*tqTCS*on*clutch
			if tqOUT < 0 then tqOUT = 0 elseif tqOUT > 1000000 then tqOUT = 0 end
			-- convert lb-ft to nm to roblox stuff
			-- if it reaches an absurdly high number, set it to 0 to prevent physics death
			
			if wheel.Name=='RR' then
				wheel["#AV"].MotorMaxTorque=tqOUT*RRdiffMult
			elseif wheel.Name=='RL' then
				wheel["#AV"].MotorMaxTorque=tqOUT*RLdiffMult
			elseif wheel.Name=='FR' then
				wheel["#AV"].MotorMaxTorque=tqOUT*FRdiffMult
			elseif wheel.Name=='FL' then
				wheel["#AV"].MotorMaxTorque=tqOUT*FLdiffMult
			else
				wheel["#AV"].MotorMaxTorque=tqOUT
			end
			wheel["#AV"].AngularVelocity=_spLimit*math.sign(CurrentGear)

			if string.find(wheel.Name,"F") then
				local force = (FBrakeForce*(60/workspace:GetRealPhysicsFPS())*brake*tqABS)+(EBrakeForce*((1-throt)*(RPM/TuneData.Redline)))+(FParkingBrakeForce*PBrakeV)
				if force > 1000000 then force = 0 elseif force < 0 then force = 0 end
				wheel["#BV"].MotorMaxTorque = force
			else
				local force = (RBrakeForce*(60/workspace:GetRealPhysicsFPS())*brake*tqABS)+(EBrakeForce*((1-throt)*(RPM/TuneData.Redline)))+(RParkingBrakeForce*PBrakeV)
				if force > 1000000 then force = 0 elseif force < 0 then force = 0 end
				wheel["#BV"].MotorMaxTorque = force
			end
		else--luaint edit
			wheel["#AV"].MotorMaxTorque=0
			wheel["#AV"].AngularVelocity=0
			if string.find(wheel.Name,"F") then
				wheel["#BV"].MotorMaxTorque=(FBrakeForce*(60/workspace:GetRealPhysicsFPS())*brake*tqABS)+(FParkingBrakeForce*PBrakeV)
			else
				wheel["#BV"].MotorMaxTorque=(RBrakeForce*(60/workspace:GetRealPhysicsFPS())*brake*tqABS)+(RParkingBrakeForce*PBrakeV)
			end
		end
	end
end

--[[Flip]]
function Flip()
	--Detect Orientation
	local driveSeatCF = car.DriveSeat.CFrame
	if driveSeatCF.UpVector.Y > .1 or FlipDB then
		FlipWait=tick()
		
	--Apply Flip
	else
		if tick() - FlipWait >= 3 then
			FlipDB=true

			local gyro = car.DriveSeat.Flip
			gyro.maxTorque = Vector3.new(10000, 0, 10000)
			gyro.P=3000
			gyro.D=500

			task.wait(1)

			gyro.maxTorque = Vector3.new(0,0,0)
			gyro.P=0
			gyro.D=0

			FlipDB=false
		end
	end
end

--[[Run]]

--Print Version
local ver = "1.6.4"
print("A-Chassis, Version "..ver)

local originalAutoShiftVers = TuneData.AutoShiftVers

--Runtime Loops
game:GetService("RunService").Heartbeat:connect(function(dt)
	--Update Internal Values
	_IsOn = script.Parent.IsOn.Value
	_InControls = script.Parent.ControlsOpen.Value
	_LastInputWasGamepad = string.find(UserInputService:GetLastInputType().Name, "Gamepad") and true or false
	_CarCenter = GetCarCenter()
	
	--Update External Values
	-- Transmission
	Values.Clutch.Value = _Clutch
	Values.Gear.Value = CurrentGear
	Values.TransmissionMode.Value = _TMode
	Values.CurrentRatio.Value = _CurrentRatio
	Values.RPM.Value = RPM
	-- Boost
	Values.Boost.Value = _TBoost + _SBoost
	Values.BoostTurbo.Value = _TBoost
	Values.BoostSuper.Value = _SBoost
	-- Horsepower
	Values.HpNatural.Value = NetHP
	Values.HpElectric.Value = ElectricHP
	Values.HpTurbo.Value = TurboHP
	Values.HpSuper.Value = SuperHp
	Values.HpBoosted.Value = BoostedHP
	Values.Horsepower.Value = HP
	-- Torque
	Values.TqNatural.Value = NetTorque
	Values.TqElectric.Value = ElectricTorque
	Values.TqTurbo.Value = TurboTorque
	Values.TqSuper.Value = SuperTorque
	Values.TqBoosted.Value = BoostedTorque
	Values.Torque.Value = Torque
	-- Inputs
	Values.Throttle.Value = _GThrot
	Values.IThrottle.Value = _IThrot
	Values.Brake.Value = _GBrake
	Values.IBrake.Value = _IBrake
	Values.SteerC.Value = _GSteerC
	Values.SteerT.Value = _GSteerT
	Values.MouseSteerOn.Value = _MSteer
	Values.PBrake.Value = _PBrake
	-- Velocity
	Values.Velocity.Value = car.DriveSeat.AssemblyLinearVelocity
	Values.CarCenter.Value = _CarCenter
	
	-- TCS
	_TCSAmt = 0
	local count = 0
	for i, v in next, _TCSTracker do
		if not Values.TCSTracker:FindFirstChild(i) then
			Instance.new("NumberValue", Values.TCSTracker).Name = i
		end
		Values.TCSTracker[i].Value = v
		_TCSAmt += v
		count += 1
	end
	Values.TCS.Value = _TCS
	Values.TCSActive.Value = _TCSActive
	_TCSAmt /= count
	Values.TCSAmt.Value = _TCSAmt
	_TCSActive = false
	-- ABS
	_ABSAmt = 0
	local count = 0
	for i, v in next, _ABSTracker do
		if not Values.ABSTracker:FindFirstChild(i) then
			Instance.new("NumberValue", Values.ABSTracker).Name = i
		end
		Values.ABSTracker[i].Value = v
		_ABSAmt += v
		count += 1
	end
	Values.ABS.Value = _ABS
	Values.ABSActive.Value = _ABSActive
	_ABSAmt /= count
	Values.ABSAmt.Value = _ABSAmt
	_ABSActive = false
	-- Wheel speeds
	for _, wheel in next, car.Wheels:GetChildren() do
		if not _WheelSpeedsTable[wheel.Name] then
			_WheelSpeedsTable[wheel.Name] = {}
		end
		table.insert(_WheelSpeedsTable[wheel.Name], wheel.RotVelocity.Magnitude)
		if #_WheelSpeedsTable[wheel.Name] > 6 then
			table.remove(_WheelSpeedsTable[wheel.Name], 1)
		end
		local avg = 0
		for _, a in next, _WheelSpeedsTable[wheel.Name] do
			avg += a
		end
		avg /= #_WheelSpeedsTable[wheel.Name]
		_WheelSpeeds[wheel.Name] = avg
	end
	local rot = 0
	for i, v in next, _WheelSpeeds do
		if not Values.WheelSpeeds:FindFirstChild(i) then
			Instance.new("NumberValue", Values.WheelSpeeds).Name = i
		end
		Values.WheelSpeeds[i].Value = v
		rot += v*(car.Wheels[i].Size.Y/2)
	end
	
	Values.AverageRotSpeed.Value = rot/#car.Wheels:GetChildren()
	Values.Acceleration.Value = (car.DriveSeat.AssemblyLinearVelocity-_OldVelocity)*(1/dt)
	_OldVelocity = car.DriveSeat.AssemblyLinearVelocity
	Values.DragFactor.Value = _DragFactor
	
	--Inputs
	
	Inputs(dt)

	--Steering

	Steering(dt)

	--Gear

	Gear()

	--Power

	Engine(dt)
	
	--Automatic Transmission
	if _TMode == "Auto" then
		Auto()
	end

	--Flip
	if TuneData.AutoFlip then
		Flip()
	end
	
	--Mobile UI
	local mobile = UserInputService:GetLastInputType() == Enum.UserInputType.Touch
	script.Parent.Mobile.Visible = mobile
	script.Parent.Mobile.ModeSwitch.Visible = car.DriveSeat.AssemblyLinearVelocity.Magnitude < 5
	script.Parent.Mobile.ModeSwitch.Text = _MobileMode
	script.Parent.Mobile.Jump.Visible = script.Parent.Mobile.ModeSwitch.Visible
	if mobile then
		TuneData.AutoShiftVers = "Old"
		_TMode = "Auto"
	else
		TuneData.AutoShiftVers = originalAutoShiftVers
	end
	for _, v in next, script.Parent.Mobile:GetChildren() do
		if v.ClassName ~= "Frame" then continue end
		v.Visible = _MobileMode == v.Name
	end
end)
