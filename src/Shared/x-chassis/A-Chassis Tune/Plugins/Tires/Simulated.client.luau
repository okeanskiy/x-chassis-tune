
local HapticService = game:GetService("HapticService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local car = script.Parent.Parent.Car.Value
local _Tune = require(car["A-Chassis Tune"])
local _WheelTune = require(script.Parent.Tune)
local Units = require(ReplicatedStorage.Units)
local values = script.Parent.Parent:WaitForChild("Values")
local event = car:WaitForChild("Friction")

local player=game.Players.LocalPlayer
local mouse=player:GetMouse()

mouse.KeyDown:connect(function(key)
	if key=="v" then
		script.Parent.Visible = not script.Parent.Visible
	end
end)

wait()
--Load SmokePart
event:FireServer("create", _WheelTune)

--Wheels Array
local WheelData = {}
for _, v in next, car.Wheels:GetChildren() do
	local data = {}
	data.Object = v
	data.Temperature = _WheelTune.AmbientTemp
	data.Dirt = 0
	data.Stress = 0
	data.SmokePart = v:WaitForChild("SmokePart")
	data.FlexCollision = data.Object:FindFirstChild("Collision")
	WheelData[v.Name] = data
end

--Open/Load Heat Data
if _WheelTune.SaveHeatData then
	local wd = car:FindFirstChild("HeatData")
	if wd then
		local t = tick()-wd.STime.Value
		for name, data in WheelData do
			if wd:FindFirstChild(name) then
				local front = string.find(name, "F")
				data.Temperature = wd[name]:GetAttribute("Temperature") - 60*t*(front and _WheelTune.FCooling or _WheelTune.RCooling)
				data.Dirt = wd[name]:GetAttribute("Dirt")
			end
		end
	end
end

--Close/Store Heat Data
car.DriveSeat.ChildRemoved:connect(function(child)
	if child.Name=="SeatWeld" then
		if _WheelTune.SaveHeatData then
			local wd=car:FindFirstChild("HeatData")
			if not wd then
				wd = script.Parent.HeatData:Clone()
				wd.Parent = car
			end
			for name, data in WheelData do
				local config = wd:FindFirstChild(name) or Instance.new("Configuration", wd)
				config.Name = name
				config:SetAttribute("Temperature", data.Temperature)
				config:SetAttribute("Dirt", data.Dirt)
			end
			wd.STime.Value=tick()
		end
		event:FireServer("stop")
		if HapticService:IsVibrationSupported(Enum.UserInputType.Gamepad1) then
			HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
		end
	end
end)

--Ray Data (Detomiks)
local rayParams = RaycastParams.new()
rayParams.FilterDescendantsInstances = {car}
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local materialSort = {

	road = {
		"Plastic",
		"Slate",
		"Concrete",
		"Granite",
		"Brick",
		"Pebble",
		"Cobblestone",
		"Rock",
		"Basalt",
		"Ground",
		"Pavement",
		"SmoothPlastic",
		"Asphalt",
	},

	dirt = {
		"Grass",
		"Mud",
		"Ground",
		"LeafyGrass",
	},

	sand = {
		"Sand",
		"Sandstone",
		"Limestone"
	},

	snow = {
		"Glacier",
		"Snow",
	}

}

--Runtime Loops
local rate = 1/8
while wait(rate) do
	local stress = 0
	local count = 0
	
	for name, data in next, WheelData do
		local rotSpeed = math.abs(data.Object.RotVelocity:Dot(data.SmokePart.CFrame.RightVector))
		local rotLinearSpeed = rotSpeed*(data.Object.Size.Y/2)
		local speed = values.Velocity.Value.Magnitude
		local diff = math.abs(rotLinearSpeed-speed)
		
		local ray = nil -- Assuming they are the same material
		local materialType = ""
		
		local front = string.find(name, "F")
		
		-- Rays
		-- Two rays, one for the inside and outside of the wheel for camber support.
		local rayI = workspace:Raycast(
			(data.SmokePart.CFrame * CFrame.new(data.Object.Size.X/2, 0.1, 0)).Position,
			-data.SmokePart.CFrame.UpVector * 0.2,
			rayParams)
		local rayO = workspace:Raycast(
			(data.SmokePart.CFrame * CFrame.new(-data.Object.Size.X/2, 0.1, 0)).Position,
			-data.SmokePart.CFrame.UpVector * 0.2,
			rayParams)
		ray = rayI or rayO
		if ray then
			-- Run a loop through the materialSort table. Set materialType and break when a material is found.
			for name, values in next, materialSort do
				if table.find(values, ray.Material.Name) then
					materialType = name
					break
				end
			end
		end	
		
		-- Slip
		local vstress = (math.max(ray and diff/20 or 0, ray and materialType~="road" and rotSpeed/50 or 0) + (front and _WheelTune.FSpeedStress or _WheelTune.RSpeedStress)*(rotLinearSpeed/(Units.Velocity_mdivs/3.6)/100))
		if ray and materialType ~= "road" then
			data.Object.Velocity = data.Object.Velocity + Vector3.new(0, math.random(0, _WheelTune.DirtBumps), 0) * math.min(data.Object.Velocity.Magnitude / 100, 5)
		end
		if vstress > 0.05 * (rate/(1/60)) and vstress > data.Stress then 
			data.Stress = math.min(data.Stress + 0.05 * (rate/(1/60)), math.min(vstress, 1))
		else
			data.Stress = math.max(data.Stress - 0.05 * (rate/(1/60)), vstress)	
		end
		
		-- Update dirt
		if materialType ~= "road" and materialType ~= "" then
			data.Dirt = 1
		else
			data.Dirt = math.max(data.Dirt - (front and _WheelTune.FDirtFadeRate or _WheelTune.RDirtFadeRate) * (rotSpeed/100) * (rate/(1/60)), 0)
		end
		
		-- Apply friction
		local materialHeatFactor = materialType ~= "road" and .01 or 1
		if front then
			data.Temperature = math.clamp(data.Temperature + (data.Stress*(_WheelTune.FHeating+_WheelTune.FCooling)*materialHeatFactor - _WheelTune.FCooling) * (rate/(1/60)), _WheelTune.AmbientTemp, _WheelTune.FMaxTemp)
		else
			data.Temperature = math.clamp(data.Temperature + (data.Stress*(_WheelTune.RHeating+_WheelTune.RCooling)*materialHeatFactor - _WheelTune.RCooling) * (rate/(1/60)), _WheelTune.AmbientTemp, _WheelTune.RMaxTemp)
		end
		local coldLoss = front and 
			(_WheelTune.FColdStats[1] * (1/(math.exp(_WheelTune.FColdStats[2]*(data.Temperature/100-_WheelTune.FColdStats[3]))+1))) or 
			(_WheelTune.RColdStats[1] * (1/(math.exp(_WheelTune.RColdStats[2]*(data.Temperature/100-_WheelTune.RColdStats[3]))+1)))
		local heatLoss = front and 
			(_WheelTune.FHotStats[1] * (-(1/(math.exp(_WheelTune.FHotStats[2]*(data.Temperature/100-_WheelTune.FHotStats[3]))+1))+1)) or 
			(_WheelTune.RHotStats[1] * (-(1/(math.exp(_WheelTune.RHotStats[2]*(data.Temperature/100-_WheelTune.RHotStats[3]))+1))+1))
		if front then
			data.Object.CustomPhysicalProperties = PhysicalProperties.new(
				((_Tune.FWheelWeight-(_WheelTune.TireFlex and _WheelTune.FTireWeight or 0))*Units.Mass_kg)/(math.pi*(data.Object.Size.Y/2)^2*(data.Object.Size.X)),
				_WheelTune.FMaxFriction - coldLoss - heatLoss - data.Dirt*_WheelTune.FDirtLoss,
				data.Object.CurrentPhysicalProperties.Elasticity,
				data.Object.CurrentPhysicalProperties.FrictionWeight,
				data.Object.CurrentPhysicalProperties.ElasticityWeight
			)
		else
			data.Object.CustomPhysicalProperties = PhysicalProperties.new(
				((_Tune.RWheelWeight-(_WheelTune.TireFlex and _WheelTune.RTireWeight or 0))*Units.Mass_kg)/(math.pi*(data.Object.Size.Y/2)^2*(data.Object.Size.X)),
				_WheelTune.RMaxFriction - coldLoss - heatLoss - data.Dirt*_WheelTune.RDirtLoss,
				data.Object.CurrentPhysicalProperties.Elasticity,
				data.Object.CurrentPhysicalProperties.FrictionWeight,
				data.Object.CurrentPhysicalProperties.ElasticityWeight
			)
		end
		
		-- Smoke
		local currentSound = data.SmokePart:FindFirstChild("Sound_" .. materialType)
		local currentSmoke = data.SmokePart:FindFirstChild("Smoke_" .. materialType)
		if _WheelTune.SmokeEffects == "Local" then
			-- Set smokepart data
			for _, d in next, data.SmokePart:GetChildren() do 
				if d:IsA("Sound") and d ~= currentSound then d.Playing = false end
				if d:IsA("ParticleEmitter") and d ~= currentSmoke then d.Enabled = false end
				if d:IsA("Trail") then
					if d.Name == materialType then
						if d:GetAttribute("stress") < data.Stress^3 then
							d.Enabled = true
						else
							d.Enabled = false
						end
					else
						d.Enabled = false
					end
				end			end
			if currentSound then
				-- Sound
				currentSound.Playing = true
				currentSound.Volume = data.Stress ^ 3 * 1.4
				currentSound.PlaybackSpeed = 0.4 * data.Stress + 0.8
			end
			if currentSmoke then
				-- Smoke
				currentSmoke.Enabled = true
				currentSmoke.Rate = (data.Stress*100-99) * 100
			end
		elseif _WheelTune.SmokeEffects == "All" then
			event:FireServer("update", currentSound, currentSmoke, materialType, data)
		end

		-- Update UI
		local tire = script.Parent.Tires:FindFirstChild(name)
		if tire then
			local front = string.find(tire.Name, "F")
			tire.First.Second.Size = UDim2.new(1, 0, math.clamp(1-(data.Temperature-40)/((front and _WheelTune.FMaxTemp or _WheelTune.RMaxTemp)-40),0,1), 0)
			tire.BackgroundColor3 = Color3.fromHSV(0, data.Stress, 1)
			tire.BackgroundTransparency = .8 - .3 * data.Stress
		end
		data.Object:SetAttribute("Temperature", data.Temperature)
		data.Object:SetAttribute("Dirt", data.Dirt)
		
		-- Update haptic values
		stress += data.Stress
		count += 1
		
		-- Tire flex
		if _WheelTune.TireFlex then
			data.FlexCollision.CustomPhysicalProperties = PhysicalProperties.new(
				((string.find(name, "F") and _WheelTune.FTireWeight or _WheelTune.RTireWeight)*Units.Mass_kg)/(math.pi*(data.Object.Size.Y/2)^2*(data.Object.Size.X)),
				data.Object.CurrentPhysicalProperties.Friction,
				data.Object.CurrentPhysicalProperties.Elasticity,
				data.Object.CurrentPhysicalProperties.FrictionWeight,
				data.Object.CurrentPhysicalProperties.ElasticityWeight
			)
			data.FlexCollision["#GRAVCOMP"].Force = Vector3.new(0, _Tune.GravComp > 0 and data.FlexCollision.Mass*(workspace.Gravity-_Tune.GravComp) or 0, 0)
			data.Object["#GRAVCOMP"].Force = Vector3.new(0, _Tune.GravComp > 0 and data.Object.Mass*(workspace.Gravity-_Tune.GravComp) or 0, 0)

			if string.find(name, "F") then
				data.FlexCollision.AlignPosition.MaxForce = _WheelTune.FPressureForce*100
			else
				data.FlexCollision.AlignPosition.MaxForce = _WheelTune.RPressureForce*100
			end
		end
	end
	-- Haptics
	local lastInput = game:GetService("UserInputService"):GetLastInputType()
	if HapticService:IsVibrationSupported(Enum.UserInputType.Gamepad1) and ((_WheelTune.Haptics == "Controller" or _WheelTune.Haptics == "Both" and string.find(lastInput.Name, "Gamepad")) or (_WheelTune.Haptics == "Mobile" or _WheelTune.Haptics == "Both" and lastInput == Enum.UserInputType.Touch)) then
		stress /= count
		stress = math.clamp(stress/2, 0, .5)
		HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, stress)
	end
end
