local ReplicatedStorage = game:GetService("ReplicatedStorage")

local x_chassis = ReplicatedStorage:FindFirstChild("x-chassis")

x_chassis:Clone().Parent = workspace
