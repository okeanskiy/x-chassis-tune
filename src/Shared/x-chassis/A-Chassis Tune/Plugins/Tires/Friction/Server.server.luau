
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local car = script.Parent.Parent
local _Tune = require(car["A-Chassis Tune"])
local Units = require(ReplicatedStorage.Units)

local functionTable = {
	create = function(_WheelTune)
		for _, v in next, car.Wheels:GetChildren() do
			if not v:FindFirstChild("SmokePart") then
				local caster = string.find(v.Name, "F") and _Tune.FCaster or _Tune.RCaster
				caster = (v.Name == "FR" or v.Name == "RR") and -caster or caster
				
				local smokePart = v.Arm:Clone()
				smokePart.Name = "SmokePart"
				smokePart.Massless = true
				smokePart:ClearAllChildren()
				smokePart.CFrame = CFrame.new((v.CFrame * CFrame.new(0, -v.Size.Y/2, 0)).Position) * v.Arm.CFrame.Rotation
				smokePart.Parent = v
				
				local sa0 = Instance.new("Attachment", v)
				sa0.Name = "SmokePartAttachment0"
				local sa1 = Instance.new("Attachment", smokePart)
				sa1.Name = "SmokePartAttachment1"
				sa1.Position = Vector3.new(0, v.Size.Y/2, 0)
				local sa2 = Instance.new("Attachment", v.Arm)
				sa2.Name = "SmokePartAttachment2"
				local smokePartAlignment = Instance.new("AlignPosition", smokePart)
				smokePartAlignment.RigidityEnabled = true
				smokePartAlignment.ReactionForceEnabled = true
				smokePartAlignment.Attachment0 = sa0
				smokePartAlignment.Attachment1 = sa1
				local smokePartOrientation = Instance.new("AlignOrientation", smokePart)
				smokePartOrientation.RigidityEnabled = true
				smokePartOrientation.ReactionTorqueEnabled = true
				smokePartOrientation.Attachment0 = sa1
				smokePartOrientation.Attachment1 = sa2
				
				for _, a in next, script:GetChildren() do
					local clone = a:Clone()
					clone.Parent = smokePart
				end
				
				if _WheelTune.TireFlex then
					v.CanCollide = false
					v.Massless = true
					
					local collision = Instance.new("Part", v)
					collision.Name = "Collision"
					collision.CanCollide = true -- set false for now we will make it collide in loop
					collision.CFrame = v.CFrame
					collision.Transparency = _WheelTune.ShowTF and .5 or 1
					collision.Shape = Enum.PartType.Cylinder
					collision.Size = v.Size
					sa0.Parent = collision
					
					local gc = Instance.new("BodyForce", collision)
					gc.Name = "#GRAVCOMP"
					gc.Force = Vector3.new(0, _Tune.GravComp > 0 and collision.Mass*(workspace.Gravity-_Tune.GravComp) or 0, 0)
					
					local mainAttachment = Instance.new("Attachment", collision)
					mainAttachment.Orientation = v["AB"].Orientation

					local force = Instance.new("AlignPosition", collision)
					force.ReactionForceEnabled = true
					force.Attachment0 = v["AB"]
					force.Attachment1 = mainAttachment
					force.ForceLimitMode = Enum.ForceLimitMode.Magnitude
					force.ForceRelativeTo = Enum.ActuatorRelativeTo.World
					force.Responsiveness = 150
					force.MaxVelocity = 3

					local rotationForce = Instance.new("AlignOrientation", collision)
					rotationForce.ReactionTorqueEnabled = true
					rotationForce.RigidityEnabled = true
					rotationForce.Attachment0 = v["AB"]
					rotationForce.Attachment1 = mainAttachment
					rotationForce.Responsiveness = math.huge

					local limiter = Instance.new("SpringConstraint", collision)
					limiter.Name = "Limiter"
					limiter.Damping = 0
					limiter.Stiffness = 0
					limiter.MaxForce = 0
					limiter.Coils = 0
					limiter.Attachment0 = v["AB"]
					limiter.Attachment1 = mainAttachment
					limiter.LimitsEnabled = true
					limiter.FreeLength = 0

					if string.find(v.Name, "F") then
						limiter.MaxLength = _WheelTune.FTireThickness/Units.Length_mm
					else
						limiter.MaxLength = _WheelTune.RTireThickness/Units.Length_mm
					end
				end
				
				-- create trails
				local trailAttachmentPart = smokePart:Clone()
				trailAttachmentPart:ClearAllChildren()
				trailAttachmentPart.Name = "TrailAttachmentPart"
				trailAttachmentPart.Parent = v
				local ta0 = Instance.new("Attachment", trailAttachmentPart)
				local ta1 = Instance.new("Attachment", smokePart)
				local tapalign = Instance.new("AlignPosition", trailAttachmentPart)
				tapalign.ReactionForceEnabled = true
				tapalign.RigidityEnabled = true
				tapalign.Attachment0 = ta0
				tapalign.Attachment1 = ta1
				local tapOrientation = Instance.new("AlignOrientation", trailAttachmentPart)
				tapOrientation.RigidityEnabled = true
				tapOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
				tapOrientation.Attachment0 = ta0
				local a0 = Instance.new("Attachment", trailAttachmentPart)
				a0.Name = "TrailAttachment0"
				local a1 = Instance.new("Attachment", trailAttachmentPart)
				a1.Name = "TrailAttachment1"
				if _WheelTune.TireMarkTransparencyLevels > 0 then
					for m = 1, 4 do
						for i = 1, _WheelTune.TireMarkTransparencyLevels do
							local trail = Instance.new("Trail", smokePart)
							trail.Name = m==1 and "road" or m==2 and "snow" or m==3 and "sand" or m==4 and "dirt"
							trail.Transparency = NumberSequence.new(_WheelTune.TireMarkTransparency)
							trail.Texture = "rbxassetid://14987871952"
							trail.TextureMode = Enum.TextureMode.Static
							trail.Lifetime = 20
							trail.Enabled = false
							trail.Attachment0 = a0
							trail.Attachment1 = a1
							trail:SetAttribute("stress", i/_WheelTune.TireMarkTransparencyLevels)
							if m == 1 then
								trail.Color = ColorSequence.new(Color3.new(0, 0, 0))
							elseif m == 2 then
								trail.Color = ColorSequence.new(Color3.fromRGB(205, 250, 255))
							elseif m == 3 then
								trail.Color = ColorSequence.new(Color3.fromRGB(255, 241, 136))
							else
								trail.Color = ColorSequence.new(Color3.fromRGB(255, 173, 102))
							end
						end
					end
					local con
					con = RunService.Heartbeat:Connect(function()
						a0.Position = Vector3.new(v.Size.X/2-.1, .02, 0)
						a1.Position = Vector3.new(-v.Size.X/2+.1, .02, 0)
						trailAttachmentPart.AlignOrientation.CFrame = CFrame.lookAt(trailAttachmentPart.Position, trailAttachmentPart.Position+v.Velocity, smokePart.CFrame.UpVector)
					end)
					smokePart.AncestryChanged:Connect(function()
						if smokePart.Parent == nil then con:Disconnect() end
					end)
				end
				
			end
		end
	end,
	update = function(currentSound, currentSmoke, materialType, data)
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
			end
		end
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
		
	end,
	stop = function()
		for _, v in next, car.Wheels:GetChildren() do
			if v:FindFirstChild("SmokePart") then
				v.SmokePart:Destroy()
			end
			if v:FindFirstChild("Collision") then
				v.Collision:Destroy()
				v.CanCollide = true
			end
		end
	end,
}

script.Parent.OnServerEvent:Connect(function(player, func, ...)
	if functionTable[func] then
		functionTable[func](...)
	end
end)
