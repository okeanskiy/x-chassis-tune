--[[	
	   ___  _____
	  / _ |/ ___/	Avxnturador   	| Novena						    Eniiqzz	    |
	 / __ / /__		LuaInt         	| Novena						    midmm5	    |
    /_/ |_\___/	 	Detomiks		| Base Chassis

	                Version 1.6.3
--]]
-- By Detomiks
-- Press "V" To enable
local car = script.Parent.Parent.Car.Value
local values = script.Parent.Parent.Values
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Units = require(car["A-Chassis Tune"].Units)
local _Tune = require(car["A-Chassis Tune"])
local player=game.Players.LocalPlayer
local mouse=player:GetMouse()

mouse.KeyDown:connect(function(key)
	if key=="v" then
		script.Parent.Visible = not script.Parent.Visible
	end
end)

wait()
RunService.Heartbeat:Connect(function()
	local accel = values.Acceleration.Value*Vector3.new(1, 0, 1)/(Units.Velocity_mdivs)/((_Tune.GravComp>0 and _Tune.GravComp or workspace.Gravity)*(Units.Length_mm/1000)) + Vector3.new(0,-1,0) -- counts gravity in acceleration
	local g = -(car.Body["#Weight"].CFrame:VectorToObjectSpace(accel))
	local gnormal = g.Unit
	local gmag = g.Magnitude
	local gclamped = gnormal*math.clamp(gmag, -3, 3)
	local old = script.Parent.Indicator.Position
	script.Parent.Indicator.Position = UDim2.new(.5+(gclamped.X/4.5*.5), 0, .5+(gclamped.Z/3*.5), 0)
	
	local vec = Vector2.new(((script.Parent.Indicator.Position-old)).X.Scale, (script.Parent.Indicator.Position-old).Y.Scale)
	local frame = Instance.new("Frame", script.Parent.Visuals)
	frame.Name = "Visual"
	frame.Size = UDim2.new(vec.Magnitude, 0, .01, 0)
	frame.AnchorPoint = Vector2.new(.5, .5)
	frame.Rotation = math.atan(vec.Unit.Y/vec.Unit.X)*(180/math.pi)
	frame.Position = old:Lerp(script.Parent.Indicator.Position, .5)
	frame.BackgroundColor3 = Color3.new(1,1,1)
	frame.BorderSizePixel = 0
	frame:SetAttribute("time", tick())
	Debris:AddItem(frame, 3)
	if workspace.CurrentCamera.ViewportSize.X < 900 or workspace.CurrentCamera.ViewportSize.Y < 600 then --move to simplified
		script.Parent.Visible = false
	end
	for _, f in next, script.Parent.Visuals:GetChildren() do
		f.BackgroundTransparency = .8 + .2*((tick()-f:GetAttribute("time"))/3)
	end
end)