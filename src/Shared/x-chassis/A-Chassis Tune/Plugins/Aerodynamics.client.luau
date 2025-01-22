local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Values = script.Parent.Values
local Units = require(ReplicatedStorage.Units)

local WindVolumeCoefficient = 0.6
local BodyVolumeCoefficient = 0.4

local DragCoefficient = 0.42

local DownforceFrontCoefficient = 336
local DownforceRearCoefficient = 381
local DownforceBlownDiffuser = 25

local SlipstreamDragReduction = 0.6
local SlipstreamTimeWindow = 0.7
local SlipstreamSamples = 5

local car = script.Parent.Car.Value
local player = game.Players.LocalPlayer
local weight = car.Body["#Weight"]

local toKMH = (Units.Length_mm / 1000) * 3.6
local fromKGF = 9.81 * Units.Force_N

wait()
local WindSound = weight:FindFirstChild("AerodynamicsWindSound") or Instance.new("Sound")
WindSound.Name = "AerodynamicsWindSound"
WindSound.RollOffMaxDistance = 30
WindSound.RollOffMinDistance = 10
WindSound.Looped = true
WindSound.SoundId = "rbxassetid://188608071"

local eq = WindSound:FindFirstChild("EQ") or Instance.new("EqualizerSoundEffect")
eq.Name = "EQ"
eq.HighGain = -20
eq.LowGain = 10
eq.MidGain = -10
eq.Parent = WindSound

WindSound.Parent = weight
WindSound:Play()

local BodySound = weight:FindFirstChild("AerodynamicsBodySound") or Instance.new("Sound")
BodySound.Name = "AerodynamicsBodySound"
BodySound.RollOffMaxDistance = 30
BodySound.RollOffMinDistance = 10
BodySound.Looped = true
BodySound.SoundId = "rbxassetid://4471836491"

BodySound.Parent = weight
BodySound:Play()

local aeroParams = RaycastParams.new()
aeroParams.FilterDescendantsInstances = { car, player.Character }
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

local function calcDownforce(speed, constant)
	return (speed ^ 2 / 200 ^ 2) * constant
end

local function calcSlipstreamCoefficient()
	local lookVector = weight.CFrame.LookVector
	local rightVector = weight.CFrame.RightVector
	local carWidth = weight.Size.X
	local accumulatedCoefficient = 0

	for i = 0, SlipstreamSamples - 1 do
		local fraction = i / (SlipstreamSamples - 1) - 0.5
		local offsetPos = weight.Position + rightVector * (fraction * carWidth)

		local forwardSlipstreamResult = workspace:Raycast(offsetPos, lookVector * 1000, aeroParams)

		if forwardSlipstreamResult then
			aeroParamsFrom.FilterDescendantsInstances = forwardSlipstreamResult.Instance:GetConnectedParts()

			local backwardSlipstreamResult = workspace:Raycast(
				forwardSlipstreamResult.Position,
				-forwardSlipstreamResult.Instance.Velocity * SlipstreamTimeWindow,
				aeroParamsFrom
			)

			if backwardSlipstreamResult and backwardSlipstreamResult.Instance:IsDescendantOf(car) then
				local streamSourceVelocity = forwardSlipstreamResult.Instance.Velocity
				local streamMagnitude = (streamSourceVelocity * SlipstreamTimeWindow).Magnitude
				local distance = backwardSlipstreamResult.Distance

				if streamMagnitude > 0 then
					local streamCoefficient = 1 - (distance / streamMagnitude)
					streamCoefficient = math.clamp(streamCoefficient, 0, 1)
					accumulatedCoefficient += streamCoefficient
				end
			end
		end
	end

	local averagedCoefficient = accumulatedCoefficient / SlipstreamSamples
	return averagedCoefficient
end

local function updateSoundVolume(windSpeedKMH: number)
	WindSound.Volume = windSpeedKMH ^ 2 * WindVolumeCoefficient / 200 ^ 2
	BodySound.Volume = windSpeedKMH ^ 2 * BodyVolumeCoefficient / 200 ^ 2
end

local function onHeartbeat(dt)
	local dragFactor = 1

	local slipstreamCoefficient = calcSlipstreamCoefficient()
	dragFactor -= dragFactor * SlipstreamDragReduction * slipstreamCoefficient

	local velocity = Values.Velocity.Value
	local throttle = Values.Throttle.Value
	local windSpeedKMH = (velocity - workspace.GlobalWind).Magnitude * toKMH

	DownforceFrontCoefficient = workspace.DebugValues.AeroDownforceFrontCoefficient.Value
	DownforceRearCoefficient = workspace.DebugValues.AeroDownforceRearCoefficient.Value

	local downforce_front = calcDownforce(windSpeedKMH, DownforceFrontCoefficient * dragFactor)
	local downforce_rear = calcDownforce(windSpeedKMH, DownforceRearCoefficient * dragFactor)
	local downforce_diffuser = DownforceBlownDiffuser * throttle

	DragCoefficient = workspace.DebugValues.AeroDragCoefficient.Value
	local dragForce = windSpeedKMH ^ 2 * DragCoefficient / 100
	local upVector = weight.CFrame.UpVector

	weight:ApplyImpulseAtPosition(-upVector * dt * downforce_front * fromKGF, car.Body.Downforce_WingF.Position)

	weight:ApplyImpulseAtPosition(-upVector * dt * downforce_rear * fromKGF, car.Body.Downforce_WingR.Position)

	weight:ApplyImpulseAtPosition(-upVector * dt * downforce_diffuser * fromKGF, car.Body.Diffuser.Position)

	weight:ApplyImpulseAtPosition(-velocity.Unit * dt * dragForce * fromKGF, car.Body.Drag.Position)

	updateSoundVolume(windSpeedKMH)
end

RunService.Heartbeat:Connect(onHeartbeat)
