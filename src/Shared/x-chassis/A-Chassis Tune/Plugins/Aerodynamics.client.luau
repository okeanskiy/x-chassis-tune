
local WindVolume       	= .6			-- Volume of wind at 200 km/h.
local BodyVolume		= .4		-- Volume of body sounds at 200 km/h.

local Drag				= .42		-- Drag coefficient of the car.
local DownforceF		= 336		-- Front downforce in kgf at 200 km/h. 
local DownforceR		= 381		-- Rear downforce in kgf at 200 km/h. 
local DownforceD		= 81		-- Diffuser in kgf at 200 km/h. 
local Slipstream		= 60		-- How much drag is reduced in slipstream (in percent)
local SlipstreamTime	= .7		-- Maximum amount of time you can be behind a car to gain slipstream.
	
local BlownDiffuser		= 25			-- Usually on high end race cars. Downforce from full throttle in kgf. Only applies if weight is used.

local values = script.Parent.Values
local car = script.Parent.Car.Value
local player = game.Players.LocalPlayer
local Units = require(car["A-Chassis Tune"].Units)
local RunService = game:GetService("RunService")
local weight = car.Body["#Weight"]

local toKMH = (Units.Length_mm/1000) * 3.6
local fromKGF = 9.81*Units.Force_N

wait()
local wind = weight:FindFirstChild("WindSound") or Instance.new("Sound", weight)
wind.Name = "WindSound"
wind.RollOffMaxDistance = 30
wind.RollOffMinDistance = 10
wind.Looped = true
wind.SoundId = "rbxassetid://188608071"

local eq = wind:FindFirstChild("EQ") or Instance.new("EqualizerSoundEffect", wind)
eq.Name = "EQ"
eq.HighGain = -20
eq.LowGain = 10
eq.MidGain = -10

wind:Play()

local body = weight:FindFirstChild("BodySound") or Instance.new("Sound", weight)
body.Name = "BodySound"
body.RollOffMaxDistance = 30
body.RollOffMinDistance = 10
body.Looped = true
body.SoundId = "rbxassetid://4471836491"

body:Play()

local aeroParams = RaycastParams.new()
aeroParams.FilterDescendantsInstances = {car, player.Character}
aeroParams.FilterType = Enum.RaycastFilterType.Exclude
local aeroParamsFrom = RaycastParams.new()
aeroParamsFrom.FilterDescendantsInstances = {}
aeroParamsFrom.FilterType = Enum.RaycastFilterType.Exclude

wait()
for _, v in next, car:GetDescendants() do
	if v:IsA("BasePart") then
		v.EnableFluidForces = false
	end
end

RunService.Heartbeat:Connect(function(dt)
	local _DragFactor = workspace.DebugValues.AeroDragFactor.Value
	
	-- Slipstream
	local toRay = workspace:Raycast(weight.Position, weight.CFrame.LookVector*1000, aeroParams)
	if toRay then
		aeroParamsFrom.FilterDescendantsInstances = toRay.Instance:GetConnectedParts()
		local fromRay = workspace:Raycast(toRay.Position, -toRay.Instance.Velocity*SlipstreamTime, aeroParamsFrom)
		if fromRay and fromRay.Instance:IsDescendantOf(car) then
			_DragFactor = (1-(Slipstream/100))+(fromRay.Distance/(toRay.Instance.Velocity*SlipstreamTime).Magnitude*(Slipstream/100))
		end
	end
	
	-- Apply forces
	local diff = (values.Velocity.Value - workspace.GlobalWind).Magnitude * toKMH
	workspace.DebugOutput.AeroDiffKmh.Value = diff

	local df = -(diff^2/(200)^2)*(DownforceF)*_DragFactor
	local dr = -(diff^2/(200)^2)*(DownforceR)*_DragFactor
	local br = BlownDiffuser*values.Throttle.Value
	local dragForce = diff^2*(Drag/100)
	weight:ApplyImpulseAtPosition(weight.CFrame.UpVector*dt*(df)*fromKGF, car.Body.Downforce_WingF.Position)
	weight:ApplyImpulseAtPosition(weight.CFrame.UpVector*dt*(dr)*fromKGF, car.Body.Downforce_WingR.Position)
	weight:ApplyImpulseAtPosition(weight.CFrame.UpVector*dt*(br)*fromKGF, car.Body.Diffuser.Position)
	weight:ApplyImpulseAtPosition(weight.CFrame.LookVector*dt*-dragForce*fromKGF, car.Body.Drag.Position)
	car.Body.Downforce_WingF:SetAttribute("Downforce", df)
	car.Body.Downforce_WingR:SetAttribute("Downforce", dr)
	car.Body.Diffuser:SetAttribute("BDForce", br)
	car.Body.Drag:SetAttribute("DragForce", dragForce)

	wind.Volume = diff^2 * WindVolume / (200)^2
	body.Volume = diff^2 * BodyVolume / (200)^2
end)
