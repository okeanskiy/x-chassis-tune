--[[	
	   ___  _____
	  / _ |/ ___/	Avxnturador   	| Novena						    Eniiqzz	    |
	 / __ / /__		LuaInt         	| Novena						    midmm5	    |
    /_/ |_\___/	 	Detomiks		| Base Chassis                      autopilo7   |

	                Version 1.6.4
--]]
-- Redesigned gauges by Detomiks (definitely not a gran turismo clone!1!!11)
-- Hold "V" to hide gauges
local autoscaling	= true		--Estimates top speed
local Units = require(script.Parent.Parent.Car.Value["A-Chassis Tune"].Units)

local UNITS	= {								--Click on speed to change units
											--First unit is default	
	{
		units			= "mph"				,
		scaling			= (Units.Length_mm/1000) * 2.23693629	, -- 1 stud : 280 mm | m/s to mi/h
		maxSpeed		= 225				,
		spInc			= 20				, -- Increment between labelled notches
	},
	
	{
		units			= "km/h"			,
		scaling			= (Units.Length_mm/1000) * 3.6	, -- 1 stud : 280 mm | m/s to km/h
		maxSpeed		= 355				,
		spInc			= 40				, -- Increment between labelled notches
	},
	
	{
		units			= "sps"				,
		scaling			= 1					, -- Roblox standard
		maxSpeed		= 380				,
		spInc			= 40				, -- Increment between labelled notches
	}
}

-----------------------------------------------------------------------------------------------

local player=game.Players.LocalPlayer
local mouse=player:GetMouse()

local car = script.Parent.Parent.Car.Value
local _Tune = require(car["A-Chassis Tune"])
local supermax = 0
local pushes = 0
local pressed = false
local gauges = script.Parent
local center = gauges.Center
local values = script.Parent.Parent.Values
local isOn = script.Parent.Parent.IsOn
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, isTyping)
	if not isTyping then
		if input.KeyCode == Enum.KeyCode.V then
			if not pressed then
				pressed = true
				if script.Parent.Visible == false then
					script.Parent.Visible = true
				end
				repeat wait(.1)
					pushes += 1
				until not pressed or pushes >= 5
				if pushes >= 5 then
					script.Parent.Visible = false
				end
			end
		end
	end
end)

car.DriveSeat.HeadsUpDisplay = false

wait()
local _pRPM = _Tune.PeakRPM
local _sRPM = _Tune.ShiftRPM
local _lRPM = _Tune.Redline

if not _Tune.Engine and _Tune.Electric then _lRPM = _Tune.E_Redline _pRPM = _Tune.E_Trans2 end

local currentUnits = 1
local revEnd = math.ceil(_lRPM/1000)

--Automatic Gauge Scaling
if autoscaling then
	local Drive={}
	if _Tune.Config == "FWD" or _Tune.Config == "AWD" then
		if car.Wheels:FindFirstChild("FL")~= nil then
			table.insert(Drive,car.Wheels.FL)
		end
		if car.Wheels:FindFirstChild("FR")~= nil then
			table.insert(Drive,car.Wheels.FR)
		end
		if car.Wheels:FindFirstChild("F")~= nil then
			table.insert(Drive,car.Wheels.F)
		end
	end
	if _Tune.Config == "RWD" or _Tune.Config == "AWD" then
		if car.Wheels:FindFirstChild("RL")~= nil then
			table.insert(Drive,car.Wheels.RL)
		end
		if car.Wheels:FindFirstChild("RR")~= nil then
			table.insert(Drive,car.Wheels.RR)
		end
		if car.Wheels:FindFirstChild("R")~= nil then
			table.insert(Drive,car.Wheels.R)
		end
	end

	local wDia = 0
	for i,v in pairs(Drive) do
		if v.Size.Y>wDia then wDia = v.Size.Y end
	end
	Drive = nil
	for i,v in pairs(UNITS) do
		v.maxSpeed = math.ceil(v.scaling*wDia*math.pi*_lRPM/60/(_Tune.ClutchType == "CVT" and _Tune.CVTMinRatio or _Tune.Ratios[#_Tune.Ratios])/_Tune.FinalDrive/_Tune.FDMult)
		v.spInc = math.max(math.ceil(v.maxSpeed/150)*10,10)
	end
end

wait()
for i=0,revEnd*2 do
	local ln = gauges.ln:clone()
	ln.Parent = center.Tach
	ln.Rotation = 45 + i * 270 / (revEnd*2)
	ln.Num.Text = i/2
	ln.Num.Rotation = -ln.Rotation
	ln.Num.Size = UDim2.new(6, 0, 4, 0)
	if i%2==0 then
		ln.Frame.Size = UDim2.new(.3, 0, 1, 0)
		ln.Num.Visible = true
	else
		ln.Frame.Size = UDim2.new(.3, 0, 2, 0)
		ln.Num:Destroy()
	end
	ln.Visible=true
end

-- Redline
wait()
do
	local rot = 270 - (math.ceil(_Tune.Redline/1000)*1000 - _Tune.ShiftRPM) / (math.ceil(_Tune.Redline/1000)*1000) * 270
	center.Tach.Redline.N1.Image.Rotation = math.clamp(rot, 0, 180)
	center.Tach.Redline.N2.Image.Rotation = math.clamp(rot, 90, 270)
end

local blns = Instance.new("Frame",center.Boost)
blns.Name = "blns"
blns.BackgroundTransparency = 1
blns.BorderSizePixel = 0
blns.Size = UDim2.new(1, 0, 1, 0)
for i=0,24 do
	local bln = gauges.bln:clone()
	bln.Parent = blns
	bln.Rotation = 270*(i/24)
	bln.Num.Rotation = -bln.Rotation
	if i%4==0 then
		bln.Frame.Size = UDim2.new(1, 0, 4, 0)
		if i % 8 == 0 then
			bln.Num.Text = i/8 - 1
		else
			bln.Num:Destroy()
		end
	else
		bln.Frame.Size = UDim2.new(1, 0, 1, 0)
		bln.Num:Destroy()
	end
	bln.Visible=true
end

wait()
for i,v in pairs(UNITS) do
	local lnn = Instance.new("Frame",center.Speedo)
	lnn.BackgroundTransparency = 1
	lnn.BorderSizePixel = 0
	lnn.Size = UDim2.new(1,0,1,0)
	lnn.Name = v.units
	if i~= 1 then lnn.Visible=false end
	
	for i=0,v.maxSpeed,v.spInc do
		local ln = gauges.ln:clone()
		ln.Parent = lnn
		ln.Rotation = 45 + 270 * (i / v.maxSpeed)
		ln.Num.Text = i
		ln.Num.Rotation = -ln.Rotation
		ln.Frame.Size = UDim2.new(.3, 0, 1, 0)
		ln.Num.Visible=true
		ln.Visible=ln.Rotation < (45+270)
		for a = 1/4, 3/4, 1/4 do
			local lna = gauges.ln:clone()
			lna.Name = "lna"
			lna.Parent = lnn
			lna.Rotation = ln.Rotation + ((45 + 270 * ((i + v.spInc) / v.maxSpeed)) - ln.Rotation) * a
			lna.Frame.Size = UDim2.new(.3, 0, .5, 0)
			lna.Num:Destroy()
			lna.Visible=lna.Rotation < (45+270)
		end
	end
end

if isOn.Value then
	gauges:TweenPosition(UDim2.new(0, 0, 0, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,1,true)
end

isOn.Changed:connect(function()
	if isOn.Value then
		gauges:TweenPosition(UDim2.new(0, 0, 0, 0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,1,true)
	end
end)

local _TCount = _Tune.Turbochargers
local _SCount = _Tune.Superchargers
if _TCount==0 and _SCount==0 then
	center.Boost.Visible = false
end

values.Gear.Changed:connect(function()
	local gearText = values.Gear.Value
	if gearText == 0 then gearText = "N"
	elseif gearText == -1 then gearText = "R"
	elseif _Tune.ClutchType == "CVT" then gearText = "D"
	end
	center.SM.Gear.Text = gearText
end)

function Gear()
	if values.TransmissionMode.Value == "Auto" then
		center.SM.TMode.Text = "AT"
		center.SM.TMode.BackgroundColor3 = Color3.new(1,170/255,0)
	elseif values.TransmissionMode.Value == "Semi" then
		center.SM.TMode.Text = "ST"
		center.SM.TMode.BackgroundColor3 = Color3.new(0, 170/255, 127/255) 
	else
		center.SM.TMode.Text = "MT"
		center.SM.TMode.BackgroundColor3 = Color3.new(1,85/255,.5)
	end
end
values.TransmissionMode.Changed:connect(Gear)

UserInputService.InputEnded:Connect(function(input, isTyping)
	if not isTyping then
		if input.KeyCode == Enum.KeyCode.V then
			pressed = false
			pushes = 0
		end
	end
end)

center.SM.Speed.MouseButton1Click:connect(function()
	if currentUnits==#UNITS then
		currentUnits = 1
	else
		currentUnits = currentUnits+1
	end
	for i,v in pairs(center.Speedo:GetChildren()) do
		if v:IsA("GuiObject") then
			v.Visible=v.Name==UNITS[currentUnits].units or v.Name=="Needle" or v.Name=="lns" or v.Name == "Line" or v.Name == "bg" or v.Name == "Scale"
		end
	end
	center.SM.Speed.Text = math.floor(UNITS[currentUnits].scaling*values.Velocity.Value.Magnitude)
	center.SM.Unit.Text = UNITS[currentUnits].units
end)

RunService.RenderStepped:Connect(function(dt)
	-- RPM
	do
		center.Tach.Needle.GroupColor3 = Color3.new(1 + math.min((values.RPM.Value - _Tune.ShiftRPM + 500) / 500 * -.33, 0), (1 - (values.RPM.Value + 500 - _Tune.ShiftRPM + 2000) / 2000) + math.max((values.RPM.Value - _Tune.ShiftRPM + 500) / 500 * .99, 0), math.max(1 - (values.RPM.Value + 500 - _Tune.ShiftRPM + 2000) / 2000, 0) + math.max((values.RPM.Value - _Tune.ShiftRPM + 500) / 500 * 1, 0))
		center.Tach.Needle.GroupTransparency = 0
		if values.RPM.Value > _Tune.ShiftRPM then
			center.Tach.Needle.GroupColor3 = Color3.new(0, 1, 1)
			center.Tach.Needle.GroupTransparency = ((tick() * 10) % 1 < .5) and 1 or 0
		end
		local rot = 270 * math.min(1,values.RPM.Value / (revEnd*1000)) - 180
		center.Tach.Needle.N1.Image.Rotation = math.min(rot, 0)
		center.Tach.Needle.N2.Image.Rotation = math.max(rot, -90)
		center.Tach.Needle.Frame.Rotation = rot + 270
		center.SM.Bar.Size = UDim2.new(math.clamp(values.RPM.Value - _Tune.ShiftRPM + 1000, 0, 1000) / 1000, 0, .3, 0)
		center.SM.Bar.ImageLabel.ImageColor3 = center.Tach.Needle.GroupColor3
		center.SM.Bar.ImageLabel.ImageTransparency = center.Tach.Needle.GroupTransparency

		-- Gear
		center.SM.Gear.TextTransparency = values.Clutch.Value == 1 and .8 or .1
	end
	
	-- Speed
	do
		local rot = 270 * math.min(1,UNITS[currentUnits].scaling*values.Velocity.Value.Magnitude/UNITS[currentUnits].maxSpeed) - 180
		center.Speedo.Needle.N1.Image.Rotation = math.min(rot, 0)
		center.Speedo.Needle.N2.Image.Rotation = math.max(rot, -90)
		center.Speedo.Needle.Frame.Rotation = rot + 270
		center.SM.Speed.Text = math.floor(UNITS[currentUnits].scaling*values.Velocity.Value.Magnitude)
		center.SM.Unit.Text = UNITS[currentUnits].units
		center.Speedo.Scale.Text = UNITS[currentUnits].units
	end
	
	-- Inputs
	do
		if values:FindFirstChild("IThrottle") then
			center.Throttle.Bar.Size = UDim2.new(.5, 0, values.Throttle.Value * .94, 0)
			center.Brake.Bar.Size = UDim2.new(.5, 0, values.Brake.Value * .94, 0)
			center.Throttle.IBar.Size = UDim2.new(.5, 0, values.IThrottle.Value * .94, 0)
			center.Brake.IBar.Size = UDim2.new(.5, 0, values.IBrake.Value * .94, 0)
		end
	end
	
	--Warnings (yes I know it's not the best looking but at least its easy to understand)
	if values.TCS.Value then
		if values.TCSActive.Value then
			center.TCS.ImageColor3 = Color3.new(1,1,1)
			center.TCS.ImageTransparency = 0
		else
			center.TCS.ImageColor3 = Color3.new(0,0,0)
			center.TCS.ImageTransparency = .8
		end
	else
		if _Tune.TCSEnabled then
			center.TCS.ImageColor3 = Color3.new(1,0,0)
			center.TCS.ImageTransparency = 0
		else
			center.TCS.ImageColor3 = Color3.new(0,0,0)
			center.TCS.ImageTransparency = .8
		end
	end

	if values.ABS.Value then
		if values.ABSActive.Value then
			center.ABS.ImageColor3 = Color3.new(1,1,1)
			center.ABS.ImageTransparency = 0
		else
			center.ABS.ImageColor3 = Color3.new(0,0,0)
			center.ABS.ImageTransparency = .8
		end
	else
		if _Tune.ABSEnabled then
			center.ABS.ImageColor3 = Color3.new(1,0,0)
			center.ABS.ImageTransparency = 0
		else
			center.ABS.ImageColor3 = Color3.new(0,0,0)
			center.ABS.ImageTransparency = .8
		end
	end
	if values.PBrake.Value then
		center.PBrake.ImageColor3 = Color3.new(1,1,1)
		center.PBrake.ImageTransparency = 0
	else
		center.PBrake.ImageColor3 = Color3.new(0,0,0)
		center.PBrake.ImageTransparency = .8
	end
	
	-- Steering
	do
		if values.MouseSteerOn.Value then
			if center.SM.Steer:FindFirstChildWhichIsA("UIAspectRatioConstraint") then
				center.SM.Steer:FindFirstChildWhichIsA("UIAspectRatioConstraint"):Destroy()
			end
			center.SM.Steer.AnchorPoint = Vector2.new(0, .5)
			center.SM.Steer.Position = UDim2.new(.5, 0, -.1, 0)
			center.SM.Steer.Size = UDim2.new(.5*values.SteerC.Value,0,.06,0)
		else
			if not center.SM.Steer:FindFirstChildWhichIsA("UIAspectRatioConstraint") then
				local x = Instance.new("UIAspectRatioConstraint", center.SM.Steer)
				x.AspectRatio = 1
				x.AspectType = Enum.AspectType.FitWithinMaxSize
				x.DominantAxis = Enum.DominantAxis.Width
			end
			center.SM.Steer.AnchorPoint = Vector2.new(.5, .5)
			center.SM.Steer.Position = UDim2.new(.5+.5*values.SteerC.Value, 0, -.1, 0)
			center.SM.Steer.Size = UDim2.new(1, 0, .06, 0)
		end
	end
	
	-- Boost
	if _TCount~=0 or _SCount~=0 then
		local _T = 0
		local _S = 0
		if _TCount~=0 then _T = _Tune.T_Boost*_TCount end
		if _SCount~=0 then _S = _Tune.S_PeakBoost*_SCount end
		local tboost = values.BoostTurbo.Value*1.2-_T/5
		local sboost = values.BoostSuper.Value

		center.Boost.Needle.N1.Image.Rotation = 180 + math.clamp(90 * ((tboost+sboost)/(_T+_S)), 0, 180)
		center.Boost.Needle.N2.Image.Rotation = math.min(90 * ((tboost+sboost)/(_T+_S)), 0)
		center.Boost.Scale.Text = "x" .. math.floor((_T+_S) * 10) / 10 .. "\npsi"
	end
end)

-- Fix ui
RunService.RenderStepped:Connect(function()
	center.SM.Bar.ImageLabel.Position = UDim2.new(0, -center.SM.Bar.ImageLabel.AbsoluteSize.X / 2 + center.SM.AbsoluteSize.X / 2, 0, 0)
end)
Gear()
