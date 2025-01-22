local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Graph = require(ReplicatedStorage.Modules.Graph)
local screen = script:FindFirstAncestorOfClass("ScreenGui")
local car = screen.Car.Value
local boolToNum = { [true] = 1, [false] = 0 }
local _Tune = require(car["A-Chassis Tune"])
local values = screen.Values

local RPMBar = script.Parent.Bar
local CurrentStats = script.Parent.Current
local MaxStats = script.Parent.Max
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

mouse.KeyDown:connect(function(key)
	if key == "v" then
		script.Parent.Visible = not script.Parent.Visible
	end
end)

-- Graphing

local MaxPower = { 0, 0 }
local MaxTorque = { 0, 0 }

local Graphs = {
	Torque = {},
	Power = {},
	TorqueNA = {},
	PowerNA = {},
}
local function calculate()
	MaxPower = { 0, 0 }
	MaxTorque = { 0, 0 }

	local x = 0

	local _Boost = 0
	local _TBoost = 0
	local _SBoost = 0

	local _HP = 0
	local _TQ = 0
	local _NH = 0
	local _NT = 0
	local _EH = 0
	local _ET = 0
	local _TH = 0
	local _TT = 0
	local _SH = 0
	local _ST = 0
	local _BH = 0
	local _BT = 0

	local _GThrot = 1

	local function computeTorqueCurve(m, n, p, q, M, b, x)
		return math.clamp(M - ((q - n) / (b ^ p - b ^ m) * (b ^ x - b ^ m) + n), 0, M)
	end

	local waitThreshold = 0

	for i = _Tune.IdleRPM, _Tune.Redline do
		x = i / 1000
		waitThreshold += 1
		if waitThreshold > 100 then
			waitThreshold = 0
			wait()
		end
		local NTorque = 0
		local ETorque = 0
		local TTorque = 0
		local STorque = 0
		if _Tune.Engine then
			local NIdleTorque = computeTorqueCurve(
				_Tune.IdleRPM / 1000,
				_Tune.IdleTorque,
				_Tune.PeakTorqueRPM / 1000,
				_Tune.PeakTorque,
				_Tune.PeakTorque,
				_Tune.IdleTorqueCurve,
				x
			)
			local NRedlineTorque = computeTorqueCurve(
				_Tune.PeakTorqueRPM / 1000,
				_Tune.PeakTorque,
				_Tune.Redline / 1000,
				_Tune.RedlineTorque,
				_Tune.PeakTorque,
				1 / _Tune.RedlineTorqueCurve,
				x
			)
			NTorque = boolToNum[_Tune.Engine] * (_Tune.PeakTorque - NIdleTorque - NRedlineTorque)
			_NH, _NT = (NTorque * x) / 5.252, NTorque

			if _Tune.Turbochargers > 0 then
				local _TBoostGoal = _Tune.Turbochargers
					* _GThrot ^ 3
					* (
						_Tune.T_Boost
						- computeTorqueCurve(
							_Tune.IdleRPM / 1000,
							_Tune.T_IdleBoost,
							_Tune.T_PeakRPM / 1000,
							_Tune.T_Boost,
							_Tune.T_Boost,
							1 / _Tune.T_Curve,
							x
						)
					)
				_TBoost = _TBoostGoal
				TTorque = _TBoost * _Tune.T_Efficiency
				_TH, _TT = (TTorque * x) / 5.252, TTorque
			end
			if _Tune.Superchargers > 0 then
				local SIdleBoost = computeTorqueCurve(
					_Tune.IdleRPM / 1000,
					_Tune.S_IdleBoost,
					_Tune.S_PeakRPM / 1000,
					_Tune.S_PeakBoost,
					_Tune.S_PeakBoost,
					_Tune.S_IdleCurve,
					x
				)
				local SRedlineBoost = computeTorqueCurve(
					_Tune.S_PeakRPM / 1000,
					_Tune.S_PeakBoost,
					_Tune.Redline / 1000,
					_Tune.S_RedlineBoost,
					_Tune.S_PeakBoost,
					1 / _Tune.S_RedlineCurve,
					x
				)
				local _SBoostGoal = _Tune.Superchargers * _GThrot * (_Tune.S_PeakBoost - SIdleBoost - SRedlineBoost)
				_SBoost = _SBoostGoal
				STorque = _SBoost * _Tune.S_Efficiency
				_SH, _ST = (STorque * x) / 5.252, STorque
			end
			if _Tune.Turbochargers > 0 or _Tune.Superchargers > 0 then
				_BH, _BT = ((TTorque + STorque) * x) / 5.252, TTorque + STorque
			end
		end
		if _Tune.Electric then
			ETorque = boolToNum[_Tune.Electric]
				* (
					_Tune.E_Torque
					- computeTorqueCurve(
						_Tune.E_TransitionRPM / 1000,
						_Tune.E_Torque,
						_Tune.E_Redline / 1000,
						_Tune.E_RedlineTorque,
						_Tune.E_Torque,
						_Tune.E_Curve,
						x
					)
				)
			_EH, _ET = (ETorque * x) / 5.252, ETorque
		end

		local TotalTorque = math.clamp(
			NTorque + ETorque + TTorque + STorque,
			0,
			(_Tune.HPLimit > 0 and _Tune.HPLimit or math.huge) * (5.252 / x)
		)
		_HP, _TQ = (TotalTorque * x) / 5.252, TotalTorque

		_NH, _NT = (NTorque * x) / 5.252, NTorque
		_EH, _ET = (ETorque * x) / 5.252, ETorque
		_BH, _BT = ((TTorque + STorque) * x) / 5.252, TTorque + STorque
		_TH, _TT = (TTorque * x) / 5.252, TTorque
		_SH, _ST = (STorque * x) / 5.252, STorque
		_HP, _TQ = (TotalTorque * x) / 5.252, TotalTorque

		Graphs.TorqueNA[i] = _NT
		Graphs.PowerNA[i] = _NH
		Graphs.Torque[i] = _TQ
		Graphs.Power[i] = _HP

		if Graphs.Torque[i] > MaxTorque[1] then
			MaxTorque = { Graphs.Torque[i], i }
		end
		if Graphs.Power[i] > MaxPower[1] then
			MaxPower = { Graphs.Power[i], i }
		end
	end
end
calculate()

local GraphA = Graph.new(script.Parent.Graphs, {
	_Tune = _Tune,
})

GraphA.Resolution = 40
GraphA.Data = Graphs
GraphA.Colors = {
	Torque = Color3.fromRGB(200, 60, 60),
	Power = Color3.fromRGB(60, 120, 200),
	TorqueNA = Color3.fromRGB(200, 60, 60),
	PowerNA = Color3.fromRGB(60, 120, 200),
}
GraphA.LineTypes = {
	Torque = 1,
	Power = 1,
	TorqueNA = 0.5,
	PowerNA = 0.5,
}
GraphA.BaselineZero = true
GraphA.Render()

-- Runtime Loop
RunService.RenderStepped:Connect(function()
	if not car.DriveSeat:FindFirstChild("SeatWeld") then
		return
	end

	-- RPM Bar
	RPMBar.Position = UDim2.new(0.09 + values.RPM.Value / _Tune.Redline * 0.75, 0, 0.07, 0)
	-- Stats
	CurrentStats.Power.Text = "Power (HP): " .. string.format("%.2f", values.Horsepower.Value)
	CurrentStats.Torque.Text = "Torque (lb-ft): " .. string.format("%.2f", values.Torque.Value)
	MaxStats.Power.Text = "Power (HP @RPM): " .. string.format("%.2f", MaxPower[1]) .. " @" .. MaxPower[2]
	MaxStats.Torque.Text = "Torque (lb-ft @RPM): " .. string.format("%.2f", MaxTorque[1]) .. " @" .. MaxTorque[2]

	if workspace.CurrentCamera.ViewportSize.X < 900 or workspace.CurrentCamera.ViewportSize.Y < 600 then --move to simplified
		script.Parent.Visible = false
	end
end)
