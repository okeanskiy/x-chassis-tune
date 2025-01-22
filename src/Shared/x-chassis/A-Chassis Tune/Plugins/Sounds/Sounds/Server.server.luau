local newEngineSounds = {}
local newTurboSounds = {}
local newSuperSounds = {}
local newBOVSounds = {}
local newTransSounds = {}

local function create(car, vars)
	table.clear(newEngineSounds)
	table.clear(newTurboSounds)
	table.clear(newSuperSounds)
	table.clear(newBOVSounds)
	table.clear(newTransSounds)
	for i, v in next, vars.EngineSounds do
		local ns = Instance.new("Sound")
		ns.Name = v.name
		ns.SoundId = "rbxassetid://" .. v.id
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
		ns.SoundId = "rbxassetid://" .. v.id
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
		ns.SoundId = "rbxassetid://" .. v.id
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
		ns.SoundId = "rbxassetid://" .. v.id
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
		ns.SoundId = "rbxassetid://" .. v.id
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

local function updateEngine(i, vol, pit, highGain, midGain, lowGain, level)
	local v = newEngineSounds[i]
	v.Volume = vol
	v.PlaybackSpeed = pit
	v.E1.HighGain = highGain
	v.E1.MidGain = midGain
	v.E1.LowGain = lowGain
	v.E2.Level = level
end

local function updateTurbo(i, vol, pit)
	local v = newTurboSounds[i]
	v.Volume = vol
	v.PlaybackSpeed = pit
end

local function updateSuper(i, vol, pit)
	local v = newSuperSounds[i]
	v.Volume = vol
	v.PlaybackSpeed = pit
end

local function updateBOV(i, vol, pit)
	local v = newBOVSounds[i]
	v.Volume = vol
	v.PlaybackSpeed = pit
	v:Play()
end

local function updateTrans(i, vol, pit)
	local v = newTransSounds[i]
	v.Volume = vol
	v.PlaybackSpeed = pit
end

local function play()
	for _, v in next, newEngineSounds do
		v:Play()
	end
	for _, v in next, newTurboSounds do
		v:Play()
	end
	for _, v in next, newSuperSounds do
		v:Play()
	end
	for _, v in next, newTransSounds do
		v:Play()
	end
end

local function stop()
	for _, v in next, newEngineSounds do
		v:Stop()
	end
	for _, v in next, newTurboSounds do
		v:Stop()
	end
	for _, v in next, newSuperSounds do
		v:Stop()
	end
	for _, v in next, newTransSounds do
		v:Stop()
	end
end

local function remove()
	for _, v in next, newEngineSounds do
		v:Destroy()
	end
	for _, v in next, newTurboSounds do
		v:Destroy()
	end
	for _, v in next, newSuperSounds do
		v:Destroy()
	end
	for _, v in next, newBOVSounds do
		v:Destroy()
	end
	for _, v in next, newTransSounds do
		v:Destroy()
	end
end

script.Parent.OnServerEvent:Connect(function(player, func, car, ...)
	if func == "create" then
		create(car, ...)
	elseif func == "updateEngine" then
		updateEngine(...)
	elseif func == "updateTurbo" then
		updateTurbo(...)
	elseif func == "updateSuper" then
		updateSuper(...)
	elseif func == "updateBOV" then
		updateBOV(...)
	elseif func == "updateTrans" then
		updateTrans(...)
	elseif func == "play" then
		play()
	elseif func == "stop" then
		stop()
	elseif func == "remove" then
		remove()
	end
end)
