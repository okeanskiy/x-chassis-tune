--[[	
	   ___  _____
	  / _ |/ ___/	Avxnturador   	| Novena						    Eniiqzz	    |
	 / __ / /__		LuaInt         	| Novena						    midmm5	    |
    /_/ |_\___/	 	Detomiks		| Base Chassis                      autopilo7   |

	                Version 1.6.4
--]]





--[[					THIS IS NOT WHERE YOU EDIT VALUES. IT IS INSIDE "Edit" UNDER THIS SCRIPT.																			]]






-- This script was made by Detomiks

-- // Vars
-- General
local newEngineSounds = {}
local newTurboSounds = {}
local newSuperSounds = {}
local newBOVSounds = {}
local newTransSounds = {}

local car = script.Parent.Car.Value
local values = script.Parent.Values
local _Tune = require(car["A-Chassis Tune"])
local vars = require(script.Edit)
local hb = game:GetService("RunService").Heartbeat
local event = car:WaitForChild("Sounds")

local prevBoost = -1000
local lastBOV = tick() -- debounce method

wait()
-- // Functions
local function create()
	table.clear(newEngineSounds)
	table.clear(newTurboSounds)
	table.clear(newSuperSounds)
	table.clear(newBOVSounds)
	table.clear(newTransSounds)
	for i, v in next, vars.EngineSounds do
		local ns = Instance.new("Sound")
		ns.Name = v.name
		ns.SoundId = "rbxassetid://"..v.id
		ns.Looped = true
		ns.Volume = 0
		ns.RollOffMaxDistance = v.rollOffMax
		ns.RollOffMinDistance = v.rollOffMin
		local success, errormessage = pcall(function()
			ns.Parent = car.Body[v.parent]
		end)
		if not success then
			ns.Parent = car.DriveSeat
		end
		local e1 = Instance.new("EqualizerSoundEffect", ns)
		e1.Name = "E1"
		e1.HighGain = v.eq[1]
		e1.MidGain = v.eq[2]
		e1.LowGain = v.eq[3]
		local e2 = Instance.new("DistortionSoundEffect", ns)
		e2.Name = "E2"
		e2.Level = 0
		e2.Enabled = true
		local e3 = Instance.new("ReverbSoundEffect", ns)
		e3.Name = "E3"
		e3.Enabled = v.reverb[1]
		e3.DecayTime = v.reverb[2]
		e3.Density = v.reverb[3]
		e3.Diffusion = v.reverb[4]
		e3.DryLevel = v.reverb[5]
		e3.WetLevel = v.reverb[6]
		table.insert(newEngineSounds, i, ns)
	end
	for i, v in next, vars.TurboSounds do
		local ns = Instance.new("Sound")
		ns.Name = v.name
		ns.SoundId = "rbxassetid://"..v.id
		ns.Looped = true
		ns.Volume = 0
		ns.RollOffMaxDistance = v.rollOffMax
		ns.RollOffMinDistance = v.rollOffMin
		local success, errormessage = pcall(function()
			ns.Parent = car.Body.Engine
		end)
		if not success then
			ns.Parent = car.DriveSeat
		end
		table.insert(newTurboSounds, i, ns)
	end
	for i, v in next, vars.SuperSounds do
		local ns = Instance.new("Sound")
		ns.Name = v.name
		ns.SoundId = "rbxassetid://"..v.id
		ns.Looped = true
		ns.Volume = 0
		ns.RollOffMaxDistance = v.rollOffMax
		ns.RollOffMinDistance = v.rollOffMin
		local success, errormessage = pcall(function()
			ns.Parent = car.Body.Engine
		end)
		if not success then
			ns.Parent = car.DriveSeat
		end
		table.insert(newSuperSounds, i, ns)
	end
	for i, v in next, vars.BovSounds do
		local ns = Instance.new("Sound")
		ns.Name = v.name
		ns.SoundId = "rbxassetid://"..v.id
		ns.Volume = 0
		ns.RollOffMaxDistance = v.rollOffMax
		ns.RollOffMinDistance = v.rollOffMin
		local success, errormessage = pcall(function()
			ns.Parent = car.Body.Engine
		end)
		if not success then
			ns.Parent = car.DriveSeat
		end
		table.insert(newBOVSounds, i, ns)
	end
	for i, v in next, vars.TransmissionSounds do
		local ns = Instance.new("Sound")
		ns.Name = v.name
		ns.SoundId = "rbxassetid://"..v.id
		ns.Looped = true
		ns.Volume = 0
		ns.RollOffMaxDistance = v.rollOffMax
		ns.RollOffMinDistance = v.rollOffMin
		local success, errormessage = pcall(function()
			ns.Parent = car.Body.Transmission
		end)
		if not success then
			ns.Parent = car.DriveSeat
		end
		table.insert(newTransSounds, i, ns)
	end
end

local function getWheelSpeed()
	local total = 0
	local count = 0
	for _, v in next, values.WheelSpeeds:GetChildren() do
		if _Tune.Config == "FWD" then
			if v.Name == "R" or v.Name == "RL" or v.Name == "RR" then continue end
		elseif _Tune.Config == "RWD" then
			if v.Name == "F" or v.Name == "FL" or v.Name == "FR" then continue end
		end
		total += v.Value
		count += 1
	end
	total /= count
	return total
end

local function gain(data, x)
	return data.eq[x] + (data.decelEq[x] * (1 - values.Throttle.Value))
end

local function update()
	for i, data in next, vars.EngineSounds do
		local fade = math.clamp(1 / data.fadeStart[2] * values.RPM.Value - data.fadeStart[1] * (1 / data.fadeStart[2]), 0, math.clamp(data.fadeEnd[1] * (1 / data.fadeEnd[2]) - (1 / data.fadeEnd[2]) * values.RPM.Value, 0, 1))
		local vol = data.vol * ((data.throtVolMult - 1) * values.Throttle.Value + 1) * ((data.revVolMult - 1) * (values.RPM.Value / _Tune.Redline) + 1) * fade
		local pit = data.pit + (data.rev - data.pit) * (values.RPM.Value / _Tune.Redline) * ((data.throtPitMult - 1) * values.Throttle.Value + 1)

		local highGain = gain(data, 1)
		local midGain = gain(data, 2)
		local lowGain = gain(data, 3)
		local level = data.decelDistortion + (data.distortion - data.decelDistortion) * (values.RPM.Value / _Tune.Redline)
		if vars.FE then
			event:FireServer("updateEngine", car, i, vol, pit, highGain, midGain, lowGain, level)
		else
			local v = newEngineSounds[i]
			v.Volume = vol
			v.PlaybackSpeed = pit
			v.E1.HighGain = highGain
			v.E1.MidGain = midGain
			v.E1.LowGain = lowGain
			v.E2.Level = level
		end
	end
	for i, data in next, vars.TurboSounds do
		local vol = data.vol * values.BoostTurbo.Value
		local pit = data.pitch + data.pitchIncrease * values.BoostTurbo.Value
		if vars.FE then
			event:FireServer("updateTurbo", car, i, vol, pit)
		else
			local v = newTurboSounds[i]
			v.Volume = vol
			v.PlaybackSpeed = pit
		end
	end
	for i, data in next, vars.SuperSounds do
		local vol = data.vol * values.BoostSuper.Value
		local pit = data.pitch + data.pitchIncrease * values.BoostSuper.Value
		if vars.FE then
			event:FireServer("updateSuper", car, i, vol, pit)
		else
			local v = newSuperSounds[i]
			v.Volume = vol
			v.PlaybackSpeed = pit
		end
	end
	local updateLastBOV = false
	for i, data in next, vars.BovSounds do
		local vol = data.vol * values.BoostTurbo.Value
		local pit = data.pitch + data.pitchIncrease * values.BoostTurbo.Value

		if (values.BoostTurbo.Value + data.sensitivity < prevBoost) and (tick() - lastBOV > .5) and values.Throttle.Value < .8 then
			updateLastBOV = true
			if vars.FE then
				event:FireServer("updateBOV", car, i, vol, pit)
			else
				local v = newBOVSounds[i]
				v.Volume = vol
				v.PlaybackSpeed = pit
				v:Play()
			end
		end

		prevBoost = values.BoostTurbo.Value
	end
	if updateLastBOV then
		lastBOV = tick()
	end
	for i, data in next, vars.TransmissionSounds do
		local vol = data.vol - values.Clutch.Value * (data.vol - data.clutchVol)
		local off = true
		for i, v in next, data.gear do
			if v == values.Gear.Value then
				off = false
			end
		end
		if off then
			vol = data.offVol
		end
		local pit = data.pitch * (getWheelSpeed() / 300)

		if vars.FE then
			event:FireServer("updateTrans", car, i, vol, pit)
		else
			local v = newTransSounds[i]
			v.Volume = vol
			v.PlaybackSpeed = pit
		end
	end
end

local function play()
	for _, v in next, newEngineSounds do v:Play() end
	for _, v in next, newTurboSounds do v:Play() end
	for _, v in next, newSuperSounds do v:Play() end
	for _, v in next, newTransSounds do v:Play() end
end

local function stop()
	for _, v in next, newEngineSounds do v:Stop() end
	for _, v in next, newTurboSounds do v:Stop() end
	for _, v in next, newSuperSounds do v:Stop() end
	for _, v in next, newTransSounds do v:Stop() end
end

local function remove()
	for _, v in next, newEngineSounds do v:Destroy() end
	for _, v in next, newTurboSounds do v:Destroy() end
	for _, v in next, newSuperSounds do v:Destroy() end
	for _, v in next, newBOVSounds do v:Destroy() end
	for _, v in next, newTransSounds do v:Destroy() end
end

-- // Events
car.DriveSeat.ChildRemoved:Connect(function(child)
	if child.Name == "SeatWeld" and child:IsA("Weld") then
		if vars.FE then
			event:FireServer("remove")
		else
			remove()
		end
	end
end)

-- // Run
wait()
if vars.FE then
	event:FireServer("create", car, vars)
else
	create()
end

if vars.FE==true then
	event:FireServer('play')
else
	play()
end

while wait(1/24) do
	update()
end


